 
pragma abicoder v2;


 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.7.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

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









contract YINSoloStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint64;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct DepositInfo {
        uint256 amount;
        uint64 begin;
        uint64 until;
    }

    uint256 public constant MIN_LOCK_DURATION = 1 weeks;
    uint256 public immutable maxLockDuration;
    uint256 public startTime;
    uint256 public periodFinish;
    uint256 public totalReward;
    uint256 public accruedReward;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerShareStored;

    mapping(address => DepositInfo[]) public depositsOf;
    mapping(address => uint256) public rewardDebt;
    mapping(address => uint256) private _userShare;
    mapping(address => uint256) public userRewardPerSharePaid;
    uint256 private _totalShare;
    address public provider;
    IERC20 public depositToken;

    event Stake(uint256 amount, uint256 duration, address indexed from);
    event UnStake(
        uint256 depositId,
        address indexed from,
        address indexed receiver
    );
    event ClaimReward(address account, uint256 reward);
    event ModifyRewardRate(uint256 o, uint256 n);
    event ModifyPeriodFinish(uint256 o, uint256 n);
    event ModifyTotalReward(uint256 o, uint256 n);

    constructor(
        address _depositToken,
        address _provider,
        uint256 _rewardRate,
        uint256 _startTime,
        uint256 _totalReward,
        uint256 _maxLockDuration  
    ) {
        depositToken = IERC20(_depositToken);
        provider = _provider;
        maxLockDuration = _maxLockDuration;
        rewardRate = _rewardRate;
        totalReward = _totalReward;
        accruedReward = 0;

        if (_startTime == 0) {
            _startTime = block.timestamp;
        }
        startTime = _startTime;
        lastUpdateTime = _startTime;
        periodFinish = _startTime.add(_maxLockDuration);
    }

    function totalShare() public view returns (uint256) {
        return _totalShare;
    }

    function userShare(address account) public view returns (uint256) {
        return _userShare[account];
    }

    function stake(uint256 amount, uint256 duration)
        external
        nonReentrant
        notifyUpdateReward(msg.sender)
    {
        require(amount > 0, "AM0");
        duration = Math.max(
            Math.min(duration, maxLockDuration),
            MIN_LOCK_DURATION
        );
        depositToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 shares = getMultiper(
            amount,
            block.timestamp,
            block.timestamp.add(duration)
        );
        _userShare[msg.sender] = shares;
        _totalShare = _totalShare.add(_userShare[msg.sender]);

        depositsOf[msg.sender].push(
            DepositInfo({
                amount: amount,
                begin: uint64(block.timestamp),
                until: uint64(block.timestamp) + uint64(duration)
            })
        );

        emit Stake(amount, duration, msg.sender);
    }

    function unstake(uint256 depositId, address receiver)
        external
        nonReentrant
        notifyUpdateReward(msg.sender)
    {
        require(depositId < depositsOf[msg.sender].length, "MISS");
        DepositInfo memory userDeposit = depositsOf[msg.sender][depositId];
        require(block.timestamp >= userDeposit.until, "EARLY");

        uint256 depositOfLength = getDepositsOfLength(msg.sender);
        depositsOf[msg.sender][depositId] = depositsOf[msg.sender][
            depositOfLength - 1
        ];
        depositsOf[msg.sender].pop();

        uint256 shares = getMultiper(
            userDeposit.amount,
            userDeposit.begin,
            userDeposit.until
        );
        _totalShare = _totalShare.sub(shares);
        _userShare[msg.sender] = _userShare[msg.sender].sub(shares);

         
        depositToken.safeTransfer(receiver, userDeposit.amount);

        emit UnStake(depositId, msg.sender, receiver);
    }

    function claimReward()
        external
        nonReentrant
        notifyUpdateReward(msg.sender)
    {
        uint256 reward = Math.min(
            rewardDebt[msg.sender],
            totalReward.sub(accruedReward)
        );
        if (reward > 0) {
            rewardDebt[msg.sender] = 0;
            accruedReward = accruedReward.add(reward);
            depositToken.safeTransferFrom(provider, msg.sender, reward);
        }

        emit ClaimReward(msg.sender, reward);
    }

    function pendingReward(address account, uint256 depositId)
        external
        view
        returns (uint256)
    {
        DepositInfo memory userDeposit = depositsOf[account][depositId];
        uint256 shares = getMultiper(
            userDeposit.amount,
            userDeposit.begin,
            userDeposit.until
        );
        uint256 reward = earned(account);
        return reward.mul(shares).div(_userShare[account]);
    }

    function rewardPerShare() public view returns (uint256) {
        if (_totalShare == 0) {
            return rewardPerShareStored;
        }
        return
            rewardPerShareStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(3e18)
                    .div(_totalShare)
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            _userShare[account]
                .mul(rewardPerShare().sub(userRewardPerSharePaid[account]))
                .div(5e18)
                .add(rewardDebt[account]);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function getTotalDeposit(address account)
        public
        view
        returns (uint256 totalAmount)
    {
        for (uint256 idx; idx < depositsOf[account].length; idx++) {
            totalAmount += depositsOf[account][idx].amount;
        }
    }

    function getDepositsOf(address account)
        public
        view
        returns (DepositInfo[] memory)
    {
        return depositsOf[account];
    }

    function getDepositsOfLength(address account)
        public
        view
        returns (uint256)
    {
        return depositsOf[account].length;
    }

    function getMultiper(
        uint256 amount,
        uint256 _from,
        uint256 _to
    ) public view returns (uint256) {
        require(_to >= _from, "NEG");
        uint256 duration = _to.sub(_from);
        require(
            duration >= MIN_LOCK_DURATION && duration <= maxLockDuration,
            "DURATION"
        );
        return
            amount
                .mul(duration.mul(1e18).div(1 weeks).mul(2).div(100))
                .div(1e18)
                .add(amount);
    }

    function modifyRewardRate(uint256 _rewardRate) external onlyOwner {
        emit ModifyRewardRate(rewardRate, _rewardRate);
        rewardRate = _rewardRate;
    }

    function modifyPeriodFinish(uint256 _periodFinish) external onlyOwner {
        emit ModifyPeriodFinish(periodFinish, _periodFinish);
        periodFinish = _periodFinish;
    }

    function modifyTotalReward(uint256 _totalReward) external onlyOwner {
        emit ModifyTotalReward(totalReward, _totalReward);
        totalReward = _totalReward;
    }

    modifier notifyUpdateReward(address account) {
        rewardPerShareStored = rewardPerShare();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewardDebt[account] = earned(account);
            userRewardPerSharePaid[account] = rewardPerShareStored;
        }
        _;
    }
}

 

pragma solidity ^0.7.0;

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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