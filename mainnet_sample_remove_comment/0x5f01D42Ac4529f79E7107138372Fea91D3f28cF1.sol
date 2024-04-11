 
pragma experimental ABIEncoderV2;


 

pragma solidity ^0.7.0;

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

 

pragma solidity ^0.7.6;

interface IVault {
  function getRewardTokens() external view returns (address[] memory);

  function balance() external view returns (uint256);

  function balanceOf(address _user) external view returns (uint256);

  function deposit(uint256 _amount) external;

  function withdraw(uint256 _amount) external;

  function claim() external;

  function exit() external;

  function harvest() external;
}
 

pragma solidity ^0.7.6;





abstract contract VaultBase is ReentrancyGuard, IVault {
  uint256 public constant PRECISION = 1e18;

   
  address public immutable baseToken;
   
  address public depositor;

   
  address public governor;

   
  uint256 public bondPercentage;

   
  uint256 public override balance;
   
  mapping(address => uint256) public override balanceOf;

  modifier onlyGovernor() {
    require(msg.sender == governor, "VaultBase: only governor");
    _;
  }

  constructor(
    address _baseToken,
    address _depositor,
    address _governor
  ) {
    baseToken = _baseToken;
    depositor = _depositor;
    governor = _governor;

    bondPercentage = PRECISION;
  }

  function setGovernor(address _governor) external onlyGovernor {
    governor = _governor;
  }

  function setBondPercentage(uint256 _bondPercentage) external onlyGovernor {
    require(_bondPercentage <= PRECISION, "VaultBase: percentage too large");

    bondPercentage = _bondPercentage;
  }
}

 

pragma solidity ^0.7.6;








abstract contract MultipleRewardsVaultBase is VaultBase {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  uint256 private constant MAX_REWARD_TOKENS = 4;

  event Deposit(address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event Claim(address indexed user, uint256[] amount);
  event Harvest(address indexed keeper, uint256[] bondAmount, uint256[] rewardAmount);

   
  address[] private rewardTokens;

   
  uint256 public lastUpdateBlock;
   
  mapping(uint256 => uint256) public rewardsPerShareStored;
   
  mapping(address => mapping(uint256 => uint256)) public userRewardPerSharePaid;
   
  mapping(address => mapping(uint256 => uint256)) public rewards;

  
  
  
  constructor(
    address _baseToken,
    address _depositor,
    address _governor
  ) VaultBase(_baseToken, _depositor, _governor) {}

  
  
  function _setupRewardTokens(address[] memory _rewardTokens) internal {
    require(_rewardTokens.length <= MAX_REWARD_TOKENS, "MultipleRewardsVaultBase: too much reward");
    rewardTokens = _rewardTokens;
    for (uint256 i = 0; i < _rewardTokens.length; i++) {
      IERC20(_rewardTokens[i]).safeApprove(depositor, uint256(-1));
    }
  }

  
  function getRewardTokens() external view override returns (address[] memory) {
    return rewardTokens;
  }

  
  
  
  function earned(address _account, uint256 _index) public view returns (uint256) {
    uint256 _balance = balanceOf[_account];
    return
      _balance.mul(rewardsPerShareStored[_index].sub(userRewardPerSharePaid[_account][_index])).div(PRECISION).add(
        rewards[_account][_index]
      );
  }

  
  function getPricePerFullShare() public view returns (uint256) {
    if (balance == 0) return 0;
    return _strategyBalance().mul(PRECISION).div(balance);
  }

  
  
  function deposit(uint256 _amount) external override nonReentrant {
    _updateReward(msg.sender);

    address _token = baseToken;  
    uint256 _pool = IERC20(_token).balanceOf(address(this));
    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    _amount = IERC20(_token).balanceOf(address(this)).sub(_pool);

    uint256 _share;
    if (balance == 0) {
      _share = _amount;
    } else {
      _share = _amount.mul(balance).div(_strategyBalance());
    }

    balance = balance.add(_share);
    balanceOf[msg.sender] = balanceOf[msg.sender].add(_share);

    _deposit();

    emit Deposit(msg.sender, _amount);
  }

  
  
  function withdraw(uint256 _share) public override nonReentrant {
    require(_share <= balanceOf[msg.sender], "Vault: not enough share");
    _updateReward(msg.sender);

    uint256 _amount = _share.mul(_strategyBalance()).div(balance);

     
    balanceOf[msg.sender] = balanceOf[msg.sender] - _share;
    balance = balance - _share;

    address _token = baseToken;  
    uint256 _pool = IERC20(_token).balanceOf(address(this));
    if (_pool < _amount) {
      uint256 _withdrawAmount = _amount - _pool;
       
      _withdraw(_withdrawAmount);
      uint256 _poolAfter = IERC20(_token).balanceOf(address(this));
      uint256 _diff = _poolAfter.sub(_pool);
      if (_diff < _withdrawAmount) {
        _amount = _pool.add(_diff);
      }
    }

    IERC20(_token).safeTransfer(msg.sender, _amount);

    emit Withdraw(msg.sender, _amount);
  }

  
  function claim() public override {
    _updateReward(msg.sender);

    uint256 length = rewardTokens.length;
    uint256[] memory _rewards = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      uint256 reward = rewards[msg.sender][i];
      if (reward > 0) {
        rewards[msg.sender][i] = 0;
        IERC20(rewardTokens[i]).safeTransfer(msg.sender, reward);
      }
      _rewards[i] = reward;
    }

    emit Claim(msg.sender, _rewards);
  }

  
  function exit() external override {
    withdraw(balanceOf[msg.sender]);
    claim();
  }

  
  function harvest() public override {
    if (lastUpdateBlock == block.number) {
      return;
    }
    lastUpdateBlock = block.number;
    if (balance == 0) {
      IRewardBondDepositor(depositor).notifyRewards(msg.sender, new uint256[](rewardTokens.length));
      return;
    }

    uint256 length = rewardTokens.length;
    uint256[] memory harvested = new uint256[](length);
    uint256[] memory bondAmount = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      harvested[i] = IERC20(rewardTokens[i]).balanceOf(address(this));
    }
     
    _harvest();

    for (uint256 i = 0; i < length; i++) {
      harvested[i] = IERC20(rewardTokens[i]).balanceOf(address(this)).sub(harvested[i]);
      bondAmount[i] = harvested[i].mul(bondPercentage).div(PRECISION);
      harvested[i] = harvested[i].sub(bondAmount[i]);
    }

    IRewardBondDepositor(depositor).notifyRewards(msg.sender, bondAmount);

     
    for (uint256 i = 0; i < length; i++) {
      rewardsPerShareStored[i] = rewardsPerShareStored[i].add(harvested[i].mul(1e18).div(balance));
    }

    emit Harvest(msg.sender, bondAmount, harvested);
  }

   

  
  function _deposit() internal virtual;

  
  function _withdraw(uint256 _amount) internal virtual;

  
  function _harvest() internal virtual;

  
  function _strategyBalance() internal view virtual returns (uint256);

   

  
  
  function _updateReward(address _account) internal {
    harvest();

    uint256 length = rewardTokens.length;
    for (uint256 i = 0; i < length; i++) {
      rewards[_account][i] = earned(_account, i);
      userRewardPerSharePaid[_account][i] = rewardsPerShareStored[i];
    }
  }
}

abstract contract BaseConvexVault is MultipleRewardsVaultBase {
  using SafeERC20 for IERC20;

  IBooster public booster;
  IBaseRewardPool public cvxRewardPool;

  uint256 public pid;

  constructor(
    address _baseToken,
    address _depositor,
    address _governor,
    address _booster,
    uint256 _pid
  ) MultipleRewardsVaultBase(_baseToken, _depositor, _governor) {
    IBooster.PoolInfo memory info = IBooster(_booster).poolInfo(_pid);
    require(info.lptoken == _baseToken, "invalid pid or token");

    booster = IBooster(_booster);
    cvxRewardPool = IBaseRewardPool(info.crvRewards);
    pid = _pid;
  }

   
  function _deposit() internal override {
    IERC20 _baseToken = IERC20(baseToken);
    uint256 amount = _baseToken.balanceOf(address(this));
    if (amount > 0) {
      IBooster _booster = booster;
      _baseToken.safeApprove(address(_booster), amount);
      _booster.deposit(pid, amount, true);
    }
  }

   
  function _withdraw(uint256 _amount) internal override {
    cvxRewardPool.withdrawAndUnwrap(_amount, false);
  }

   
  function _harvest() internal override {
    cvxRewardPool.getReward();
  }

   
  function _strategyBalance() internal view override returns (uint256) {
     
    return cvxRewardPool.balanceOf(address(this));
  }
}
 

pragma solidity ^0.7.3;




contract TriCrypto2ConvexVault is BaseConvexVault {
  constructor(address _depositor, address _governor)
    BaseConvexVault(
      address(0xc4AD29ba4B3c580e6D59105FFf484999997675Ff),  
      _depositor,
      _governor,
      address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31),  
      38  
    )
  {
    address[] memory _rewardTokens = new address[](2);
    _rewardTokens[0] = address(0xD533a949740bb3306d119CC777fa900bA034cd52);  
    _rewardTokens[1] = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);  

    _setupRewardTokens(_rewardTokens);
  }
}

 

pragma solidity ^0.7.6;




interface IBooster {
  struct PoolInfo {
    address lptoken;
    address token;
    address gauge;
    address crvRewards;
    address stash;
    bool shutdown;
  }

  function poolInfo(uint256 _pid) external view returns (PoolInfo memory);

  function deposit(
    uint256 _pid,
    uint256 _amount,
    bool _stake
  ) external returns (bool);

  function depositAll(uint256 _pid, bool _stake) external returns (bool);

  function withdraw(uint256 _pid, uint256 _amount) external returns (bool);

  function withdrawAll(uint256 _pid) external returns (bool);
}

interface IBaseRewardPool {
  function balanceOf(address account) external view returns (uint256);

  function getReward() external returns (bool);

  function getReward(address _account, bool _claimExtras) external returns (bool);

  function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);

  function earned(address _account) external view returns (uint256);
}

 

pragma solidity ^0.7.0;

 
library SafeMath {
     
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

     
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

     
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
         
         
         
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

     
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

     
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity ^0.7.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.7.0;





 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity ^0.7.6;

interface IRewardBondDepositor {
  function currentEpoch()
    external
    view
    returns (
      uint64 epochNumber,
      uint64 startBlock,
      uint64 nextBlock,
      uint64 epochLength
    );

  function rewardShares(uint256 _epoch, address _vault) external view returns (uint256);

  function getVaultsFromAccount(address _user) external view returns (address[] memory);

  function getAccountRewardShareSince(
    uint256 _epoch,
    address _user,
    address _vault
  ) external view returns (uint256[] memory);

  function bond(address _vault) external;

  function rebase() external;

  function notifyRewards(address _user, uint256[] memory _amounts) external;
}

 

pragma solidity ^0.7.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

         
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
