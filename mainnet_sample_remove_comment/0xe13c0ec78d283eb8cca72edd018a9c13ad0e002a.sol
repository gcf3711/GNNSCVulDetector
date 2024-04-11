 

 

 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC20 {
   
  function totalSupply() external view returns (uint256);

   
  function balanceOf(address account) external view returns (uint256);

   
  function transfer(address recipient, uint256 amount) external returns (bool);

   
  function allowance(address owner, address spender) external view returns (uint256);

   
  function approve(address spender, uint256 amount) external returns (bool);

   
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

   
  event Transfer(address indexed from, address indexed to, uint256 value);

   
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
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
    require(c >= a, 'SafeMath: addition overflow');
    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath: subtraction overflow');
    return a - b;
  }

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, 'SafeMath: division by zero');
    return a / b;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, 'SafeMath: modulo by zero');
    return a % b;
  }

   
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

   
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

   
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

 

pragma solidity >=0.6.2 <0.8.0;

 
library Address {
   
  function isContract(address account) internal view returns (bool) {
     
     
     

    uint256 size;
     
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

   
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

     
    (bool success, ) = recipient.call{ value: amount }('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }

   
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, 'Address: low-level call failed');
  }

   
  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

   
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
  }

   
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, 'Address: insufficient balance for call');
    require(isContract(target), 'Address: call to non-contract');

     
    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

   
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return functionStaticCall(target, data, 'Address: low-level static call failed');
  }

   
  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), 'Address: static call to non-contract');

     
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

   
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, 'Address: low-level delegate call failed');
  }

   
  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), 'Address: delegate call to non-contract');

     
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
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

 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
  }

   
  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
     
     
     
     
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance =
      token.allowance(address(this), spender).sub(
        value,
        'SafeERC20: decreased allowance below zero'
      );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

   
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
     
     
     

    bytes memory returndata = address(token).functionCall(data, 'SafeERC20: low-level call failed');
    if (returndata.length > 0) {
       
       
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library Math {
   
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

   
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

   
  function average(uint256 a, uint256 b) internal pure returns (uint256) {
     
    return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
  }
}

 

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

 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  constructor() internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

   
  function owner() public view virtual returns (address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

   
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

   
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

 

pragma solidity >=0.6.0 <0.8.0;

contract MasterChefMod is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
  event Claim(address indexed user, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

  
  struct UserInfo {
    uint256 amount;  
    uint256 rewardDebt;  
     
     
     
     
     
     
     
     
     
  }

  
  struct PoolInfo {
    address token;  
    uint256 allocPoint;  
    uint256 lastUpdateTime;  
    uint256 accRewardPerShare;  
    uint256 totalStaked;  
    uint256 accUndistributedReward;  
  }

  
  uint256 private precision = 1e18;

  
  uint256 public rewardTokenBalance;

  
  uint256 public totalAllocPoint;

  
  uint256 public timeDeployed;

  
  uint256 public totalRewards;

  
  address public rewardToken;

  
  PoolInfo[] public poolInfo;

  
  uint256 public periodFinish;

  
  uint256 public rewardRate;

  
  uint256 public rewardsDuration;

  
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;
  mapping(address => bool) private poolToken;

  constructor(address _rewardToken, uint256 _rewardsDuration) public {
    rewardToken = _rewardToken;
    rewardsDuration = _rewardsDuration;
    timeDeployed = block.timestamp;
    periodFinish = timeDeployed.add(rewardsDuration);
  }

  
  function avgRewardsPerSecondTotal() external view returns (uint256 avgPerSecond) {
    return totalRewards.div(block.timestamp.sub(timeDeployed));
  }

  
  function poolLength() external view returns (uint256) {
    return poolInfo.length;
  }

  
  function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];
    uint256 accRewardPerShare = pool.accRewardPerShare;

    if (pool.totalStaked != 0 && totalAllocPoint != 0) {
      accRewardPerShare = accRewardPerShare.add(
        _getPoolRewardsSinceLastUpdate(_pid).mul(precision).div(pool.totalStaked)
      );
    }

    return user.amount.mul(accRewardPerShare).div(precision).sub(user.rewardDebt);
  }

  
  function add(
    uint256 _allocPoint,
    address _token,
    bool _withUpdate
  ) public onlyOwner {
    if (_withUpdate) {
      massUpdatePools();
    }

    require(
      poolToken[address(_token)] == false,
      'MasterChefMod: Stake token has already been added'
    );

    totalAllocPoint = totalAllocPoint.add(_allocPoint);

    poolInfo.push(
      PoolInfo({
        token: _token,
        allocPoint: _allocPoint,
        lastUpdateTime: block.timestamp,
        accRewardPerShare: 0,
        totalStaked: 0,
        accUndistributedReward: 0
      })
    );

    poolToken[address(_token)] = true;
  }

  
  function set(
    uint256 _pid,
    uint256 _allocPoint,
    bool _withUpdate
  ) public onlyOwner {
    if (_withUpdate) {
      massUpdatePools();
    }

    totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
    poolInfo[_pid].allocPoint = _allocPoint;
  }

  
  function deposit(uint256 _pid, uint256 _amount) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];

    _updatePool(_pid);

    uint256 pending;

    if (pool.totalStaked == 0) {
       
      pending = pool.accUndistributedReward;
      pool.accUndistributedReward = 0;
    }
    if (user.amount != 0) {
      pending = _getUserPendingReward(_pid);
    }

    _claimFromPool(_pid, pending);
    _transferAmountIn(_pid, _amount);
    _updateRewardDebt(_pid);

    emit Deposit(msg.sender, _pid, _amount);
  }

   
  function withdraw(uint256 _pid, uint256 _amount) public {
    UserInfo storage user = userInfo[_pid][msg.sender];
    require(user.amount >= _amount, 'MasterChefMod: Withdraw amount is greater than user stake.');

    _updatePool(_pid);
    _claimFromPool(_pid, _getUserPendingReward(_pid));
    _transferAmountOut(_pid, _amount);
    _updateRewardDebt(_pid);

    emit Withdraw(msg.sender, _pid, _amount);
  }

   
   
  function emergencyWithdraw(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];

    uint256 _amount = user.amount;
    user.amount = 0;
    user.rewardDebt = 0;
    pool.totalStaked = pool.totalStaked.sub(_amount);

    IERC20(pool.token).safeTransfer(address(msg.sender), _amount);
    emit EmergencyWithdraw(msg.sender, _pid, _amount);
     
  }

   
  function updateRewards(uint256 amount) external onlyOwner {
    require(amount != 0, 'MasterChefMod: Reward amount must be greater than zero');

    IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), amount);
    rewardTokenBalance = rewardTokenBalance.add(amount);

    if (totalAllocPoint == 0) {
      return;
    }

    massUpdatePools();

     
    if (block.timestamp >= periodFinish) {
      rewardRate = amount.mul(precision).div(rewardsDuration);
    } else {
      uint256 periodSecondsLeft = periodFinish.sub(block.timestamp);
      uint256 periodRewardsLeft = periodSecondsLeft.mul(rewardRate);
      rewardRate = periodRewardsLeft.add(amount.mul(precision)).div(rewardsDuration);
    }

    totalRewards = totalRewards.add(amount);
    periodFinish = block.timestamp.add(rewardsDuration);
  }

  
   
  function massUpdatePools() public {
    uint256 length = poolInfo.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      _updatePool(pid);
    }
  }

  
  function _updatePool(uint256 _pid) internal {
    if (totalAllocPoint == 0) return;

    PoolInfo storage pool = poolInfo[_pid];
    uint256 poolRewards = _getPoolRewardsSinceLastUpdate(_pid);

    if (pool.totalStaked == 0) {
      pool.accRewardPerShare = pool.accRewardPerShare.add(poolRewards);
      pool.accUndistributedReward = pool.accUndistributedReward.add(poolRewards);
    } else {
      pool.accRewardPerShare = pool.accRewardPerShare.add(
        poolRewards.mul(precision).div(pool.totalStaked)
      );
    }

    pool.lastUpdateTime = block.timestamp;
  }

  function _getPoolRewardsSinceLastUpdate(uint256 _pid)
    internal
    view
    returns (uint256 _poolRewards)
  {
    PoolInfo storage pool = poolInfo[_pid];
    uint256 lastTimeRewardApplicable = Math.min(block.timestamp, periodFinish);

    uint256 lastUpdateTime = pool.lastUpdateTime;

    if (lastUpdateTime > lastTimeRewardApplicable) {
      lastUpdateTime = lastTimeRewardApplicable;
    }

    uint256 numSeconds = lastTimeRewardApplicable.sub(lastUpdateTime);

    return numSeconds.mul(rewardRate).mul(pool.allocPoint).div(totalAllocPoint).div(precision);
  }

  function _safeRewardTokenTransfer(address _to, uint256 _amount)
    internal
    returns (uint256 _claimed)
  {
    _claimed = Math.min(_amount, rewardTokenBalance);
    IERC20(rewardToken).transfer(_to, _claimed);
    rewardTokenBalance = rewardTokenBalance.sub(_claimed);
  }

  function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
    require(_token != address(rewardToken), 'MasterChefMod: Cannot withdraw reward tokens');
    require(poolToken[address(_token)] == false, 'MasterChefMod: Cannot withdraw stake tokens');
    IERC20(_token).safeTransfer(msg.sender, _amount);
  }

  function _getUserPendingReward(uint256 _pid) internal view returns (uint256 _reward) {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    return user.amount.mul(pool.accRewardPerShare).div(precision).sub(user.rewardDebt);
  }

  function _claimFromPool(uint256 _pid, uint256 _amount) internal {
    if (_amount != 0) {
      uint256 amountClaimed = _safeRewardTokenTransfer(msg.sender, _amount);
      emit Claim(msg.sender, _pid, amountClaimed);
    }
  }

  function _transferAmountIn(uint256 _pid, uint256 _amount) internal {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];

    if (_amount != 0) {
      IERC20(pool.token).safeTransferFrom(msg.sender, address(this), _amount);
      user.amount = user.amount.add(_amount);
      pool.totalStaked = pool.totalStaked.add(_amount);
    }
  }

  function _transferAmountOut(uint256 _pid, uint256 _amount) internal {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];

    if (_amount != 0) {
      IERC20(pool.token).safeTransfer(msg.sender, _amount);
      user.amount = user.amount.sub(_amount);
      pool.totalStaked = pool.totalStaked.sub(_amount);
    }
  }

  function _updateRewardDebt(uint256 _pid) internal {
    UserInfo storage user = userInfo[_pid][msg.sender];
    user.rewardDebt = user.amount.mul(poolInfo[_pid].accRewardPerShare).div(precision);
  }
}

