 

 

 

 
pragma solidity 0.6.12;

 
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

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

     
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

     
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

     
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

     
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

     
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

     
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

     
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

     
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

     
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

     
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

     
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

     
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

 
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract Staking is AccessControl {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

   
  IUniswapV2Pair public PAIR;
   
  IERC20 public YIELD;
   
  bytes32 public constant DISTRIBUTER_ROLE = 0x09630fffc1c31ed9c8dd68f6e39219ed189b07ff9a25e1efc743b828f69d555e;

  uint256 private s_totalSupply;
  uint256 private s_periodFinish;
  uint256 private s_rewardRate;
  uint256 private s_lastUpdateTime;
  uint256 private s_rewardPerTokenStored;
  uint256 private s_stakingLimit;
  uint256 private s_leftover;
  mapping(address => uint256) private s_balances;
  mapping(address => uint256) private s_userRewardPerTokenPaid;
  mapping(address => uint256) private s_rewards;

  event RewardAdded(address indexed distributer, uint256 reward, uint256 duration);
  event LeftoverCollected(address indexed distributer, uint256 amount);
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);

  modifier updateReward(address account) {
    s_rewardPerTokenStored = rewardPerToken();
    uint256 lastTimeRewardApplicable = lastTimeRewardApplicable();
    if (s_totalSupply == 0) {
      s_leftover = s_leftover.add(lastTimeRewardApplicable.sub(s_lastUpdateTime).mul(s_rewardRate));
    }
    s_lastUpdateTime = lastTimeRewardApplicable;
    if (account != address(0)) {
      s_rewards[account] = earned(account);
      s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
    }
    _;
  }

  modifier onlyDistributer() {
    require(hasRole(DISTRIBUTER_ROLE, msg.sender), "Staking: Caller is not a distributer");
    _;
  }

  constructor (address pair, address yield) public {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(DISTRIBUTER_ROLE, msg.sender);
    PAIR = IUniswapV2Pair(pair);
    YIELD = IERC20(yield);
    s_stakingLimit = 7e18;
    require(address(PAIR).isContract(), "Staking: pair is not a contract");
    require(address(YIELD).isContract(), "Staking: YIELD is not a contract");
    require(address(PAIR) != address(YIELD), "Staking: pair and YIELD are the same");
  }

  receive() external payable {
    require(false, "Staking: not aceepting ether");
  }

  function setStakingLimit(uint256 other) external onlyDistributer() {
    s_stakingLimit = other;
  }

  function addReward(address from, uint256 amount, uint256 duration) external onlyDistributer() updateReward(address(0)) {
    require(amount > duration, 'Staking: Cannot approve less than 1');
    uint256 newRate = amount.div(duration);
    require(newRate >= s_rewardRate, "Staking: degragration is not allowed");
    if(now < s_periodFinish)
      amount = amount.sub(s_periodFinish.sub(now).mul(s_rewardRate));
    s_rewardRate = newRate;
    s_lastUpdateTime = now;
    s_periodFinish = now.add(duration);
    YIELD.safeTransferFrom(from, address(this), amount);
    emit RewardAdded(msg.sender, amount, duration);
  }

  function collectLeftover() external onlyDistributer() updateReward(address(0)) {
    uint256 balance = YIELD.balanceOf(address(this));
    uint256 amount = Math.min(s_leftover, balance);
    s_leftover = 0;
    YIELD.safeTransfer(msg.sender, amount);
    emit LeftoverCollected(msg.sender, amount);
  }

  function stake(uint256 amount) external updateReward(msg.sender) {
    require(amount > 0, "Staking: cannot stake 0");
    require(amount <= pairLimit(msg.sender), "Staking: amount exceeds limit");
    s_balances[msg.sender] = s_balances[msg.sender].add(amount);
    s_totalSupply = s_totalSupply.add(amount);
    IERC20(address(PAIR)).safeTransferFrom(msg.sender, address(this), amount);
    emit Staked(msg.sender, amount);
  }

  function exit() external {
    withdraw(s_balances[msg.sender]);
    getReward();
  }

  function withdraw(uint256 amount) public updateReward(msg.sender) {
    require(amount > 0, 'Staking: cannot withdraw 0');
    s_totalSupply = s_totalSupply.sub(amount);
    s_balances[msg.sender] = s_balances[msg.sender].sub(amount);
    IERC20(address(PAIR)).safeTransfer(msg.sender, amount);
    emit Withdrawn(msg.sender, amount);
  }

  function getReward() public updateReward(msg.sender) {
    uint256 reward = earned(msg.sender);
    if (reward > 0) {
      s_rewards[msg.sender] = 0;
      YIELD.safeTransfer(msg.sender, reward);
      emit RewardPaid(msg.sender, reward);
    }
  }

  function earned(address account) public view returns (uint256) {
    return
    (
      s_balances[account]
      .mul
      (
        rewardPerToken()
        .sub(s_userRewardPerTokenPaid[account])
      )
      .div(1e18)
      .add(s_rewards[account])
    );
  }

  function rewardPerToken() public view returns (uint256) {
    if (s_totalSupply == 0) {
      return s_rewardPerTokenStored;
    }
    return
      s_rewardPerTokenStored
      .add
      (
        lastTimeRewardApplicable()
        .sub(s_lastUpdateTime)
        .mul(s_rewardRate)
        .mul(1e18)
        .div(s_totalSupply)
      );
  }

  function lastTimeRewardApplicable() public view returns (uint256) {
    return Math.min(now, s_periodFinish);
  }

  function pairLimit(address account) public view returns (uint256) {
    (, uint256 other, uint256 totalSupply) = pairInfo();
    uint256 limit = totalSupply.mul(s_stakingLimit).div(other);
    uint256 balance = s_balances[account];
    return limit > balance ? limit - balance : 0;
  }

  function pairInfo() public view returns (uint256 yield, uint256 other, uint256 totalSupply) {
    totalSupply = PAIR.totalSupply();
    (uint256 reserves0, uint256 reserves1,) = PAIR.getReserves();
    (yield, other) = address(YIELD) == PAIR.token0() ? (reserves0, reserves1) : (reserves1, reserves0);
  }

  function pairOtherBalance(uint256 amount) external view returns (uint256) {
    (, uint256 other, uint256 totalSupply) = pairInfo();
    return other.mul(amount).div(totalSupply);
  }

  function pairYieldBalance(uint256 amount) external view returns (uint256) {
    (uint256 yield, , uint256 totalSupply) = pairInfo();
    return yield.mul(amount).div(totalSupply);
  }

  function totalSupply() external view returns (uint256) {
    return s_totalSupply;
  }

  function periodFinish() external view returns (uint256) {
    return s_periodFinish;
  }

  function rewardRate() external view returns (uint256) {
    return s_rewardRate;
  }

  function lastUpdateTime() external view returns (uint256) {
    return s_lastUpdateTime;
  }

  function rewardPerTokenStored() external view returns (uint256) {
    return s_rewardPerTokenStored;
  }

  function balanceOf(address account) external view returns (uint256) {
    return s_balances[account];
  }

  function userRewardPerTokenPaid(address account) external view returns (uint256) {
    return s_userRewardPerTokenPaid[account];
  }

  function rewards(address account) external view returns (uint256) {
    return s_rewards[account];
  }

  function stakingLimit() external view returns (uint256) {
    return s_stakingLimit;
  }

  function leftover() external view returns (uint256) {
    return s_leftover;
  }

}