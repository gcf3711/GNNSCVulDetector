 
pragma experimental ABIEncoderV2;


 
pragma solidity ^0.6.12;





abstract contract StakingBase {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct StakeData {
        uint256 amount;
        uint256 rewards;
        uint256 withdrawn;
        uint256 startsAt;
    }

    uint256 public minStakeAmount;
    uint256 public revenue;
    IERC20 public stakingToken;

    event MinStakeAmountUpdated(address indexed owner, uint256 value);
    event Staked(address indexed account, uint256 stakeId, uint256 amount);
    event RewardPoolDecreased(address indexed owner, uint256 amount);
    event RewardPoolIncreased(address indexed owner, uint256 amount);
    event Withdrawn(address indexed account, uint256 stakeId, uint256 amount);

    function _calculateWithdrawAmountParts(
        StakeData memory stake_,
        uint256 amount
    ) internal pure returns (uint256 rewardsSubValue, uint256 totalStakedSubValue) {
        if (stake_.withdrawn < stake_.rewards) {
            uint256 difference = stake_.rewards.sub(stake_.withdrawn);
            if (difference >= amount) {
                rewardsSubValue = amount;
            } else {
                rewardsSubValue = difference;
                totalStakedSubValue = amount.sub(difference);
            }
        } else {
            totalStakedSubValue = amount;
        }
    }

    modifier onlyPositiveAmount(uint256 amount) {
        require(amount > 0, "Amount not positive");
        _;
    }
}

 
pragma solidity ^0.6.12;

abstract contract TwoStageOwnable {
    address private _nominatedOwner;
    address private _owner;

    function nominatedOwner() public view returns (address) {
        return _nominatedOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    event OwnerChanged(address indexed newOwner);
    event OwnerNominated(address indexed nominatedOwner);

    constructor(address owner_) internal {
        require(owner_ != address(0), "Owner is zero");
        _setOwner(owner_);
    }

    function acceptOwnership() external returns (bool success) {
        require(msg.sender == _nominatedOwner, "Not nominated to ownership");
        _setOwner(_nominatedOwner);
        return true;
    }

    function nominateNewOwner(address owner_) external onlyOwner returns (bool success) {
        _nominateNewOwner(owner_);
        return true;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function _nominateNewOwner(address owner_) internal {
        if (_nominatedOwner == owner_) return;
        require(_owner != owner_, "Already owner");
        _nominatedOwner = owner_;
        emit OwnerNominated(owner_);
    }

    function _setOwner(address newOwner) internal {
        if (_owner == newOwner) return;
        _owner = newOwner;
        _nominatedOwner = address(0);
        emit OwnerChanged(newOwner);
    }
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

 

pragma solidity >=0.6.0 <0.8.0;

 
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

 

pragma solidity >=0.6.0 <0.8.0;





 
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

 

pragma solidity >=0.6.2 <0.8.0;

 
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

 
pragma solidity ^0.6.12;





contract StakingMonthly is StakingBase, TwoStageOwnable  {

    uint256 private _intervalDuration;
    uint256 private _rewardPool;
    uint256 private _totalStaked;
    mapping(address => StakeData[]) private _stakedInformation;

    function getTimestamp() internal virtual view returns (uint256) {
        return block.timestamp;
    }

    
    function intervalsCount() public pure returns (uint256) {
        return 1;
    }

    
    function size() public pure returns (uint256) {
        return 0;
    }

    function freeSize() public view returns (uint256) {
        return _rewardPool.mul(100).div(revenue).sub(_totalStaked);
    }

    function intervalDuration() public view returns (uint256) {
        return _intervalDuration;
    }

    function requiredRewards() public view returns (uint256) {
        return _calculateRewards(_totalStaked);
    }

    function rewardPool() public view returns (uint256) {
        return _rewardPool;
    }

    function totalStaked() public view returns (uint256) {
        return _totalStaked;
    }

    function availableToWithdraw(address account, uint256 id) public view returns (uint256 amountToWithdraw) {
        StakeData storage stake_ = _getStake(account, id);
        if (stake_.startsAt.add(_intervalDuration) <= getTimestamp()) {
            amountToWithdraw = stake_.amount.add(stake_.rewards).sub(stake_.withdrawn);
        }
    }

    function getStake(address account, uint256 id) public view returns (StakeData memory) {
        return _getStake(account, id);
    }

    function getStakesCount(address account) public view returns (uint256) {
        return _stakedInformation[account].length;
    }

    function getStakes(
        address account,
        uint256 offset,
        uint256 limit
    ) public view returns (StakeData[] memory stakeData) {
        StakeData[] storage stakedInformation = _stakedInformation[account];
        uint256 stakedInformationLength = stakedInformation.length;
        uint256 to = offset.add(limit);
        if (stakedInformationLength < to) to = stakedInformationLength;
        stakeData = new StakeData[](to - offset);
        for (uint256 i = offset; i < to; i++) {
            stakeData[i - offset] = stakedInformation[stakedInformationLength - i - 1];
        }
    }

    constructor(
        address owner_,
        IERC20 stakingToken_,
        uint256 revenue_,
        uint256 intervalDuration_
    ) public TwoStageOwnable(owner_) {
        require(revenue_ > 0, "Revenue not positive");
        require(intervalDuration_ > 0, "IntervalDuration not positive");
        stakingToken = stakingToken_;
        revenue = revenue_;
        _intervalDuration = intervalDuration_ * 1 days;
    }

    function decreaseRewardPool(uint256 amount) external onlyOwner onlyPositiveAmount(amount) returns (bool) {
        address caller = msg.sender;
        uint256 requiredRewards_ = requiredRewards();
        require(_rewardPool > requiredRewards_, "No tokens to decrease");
        require(amount <= _rewardPool.sub(requiredRewards_), "Not enough amount");
        stakingToken.safeTransfer(caller, amount);
        _rewardPool = _rewardPool.sub(amount);
        emit RewardPoolDecreased(caller, amount);
        return true;
    }

    function increaseRewardPool(uint256 amount) external onlyOwner onlyPositiveAmount(amount) returns (bool) {
        address caller = msg.sender;
        stakingToken.safeTransferFrom(caller, address(this), amount);
        _rewardPool = _rewardPool.add(amount);
        emit RewardPoolIncreased(caller, amount);
        return true;
    }

    function setMinStakeAmount(uint256 value) external onlyOwner returns (bool) {
        minStakeAmount = value;
        emit MinStakeAmountUpdated(msg.sender, value);
        return true;
    }

    function stake(uint256 amount) external onlyPositiveAmount(amount) returns (bool) {
        address caller = msg.sender;
        uint256 rewards = _calculateRewards(amount);
        uint256 currentTimestamp = getTimestamp();
        uint256 stakeId = _stakedInformation[caller].length;
        _stakedInformation[caller].push();
        StakeData storage stake_ = _stakedInformation[caller][stakeId];
        bool canStake = true;
        if (stakeId > 0) {
            StakeData memory previousStake_ = _getStake(caller, stakeId.sub(1));
            canStake = previousStake_.startsAt.add(_intervalDuration) <= currentTimestamp;
        }
        require(amount >= minStakeAmount, "Amount lt minimum stake");
        require(rewards <= _rewardPool.sub(requiredRewards()), "Not enough rewards");
        require(canStake, "Previous stake is not over");
        _totalStaked = _totalStaked.add(amount);
        stake_.amount = amount;
        stake_.rewards = rewards;
        stake_.startsAt = currentTimestamp;
        stakingToken.safeTransferFrom(caller, address(this), amount);
        emit Staked(caller, stakeId, amount);
        return true;
    }

    function withdraw(uint256 id, uint256 amount) external onlyPositiveAmount(amount) returns (bool) {
        address caller = msg.sender;
        require(amount <= availableToWithdraw(caller, id), "Not enough available tokens");
        StakeData storage stake_ = _stakedInformation[caller][id];
        (uint256 rewardsSubValue, uint256 totalStakedSubValue) = _calculateWithdrawAmountParts(stake_, amount);
        _rewardPool = _rewardPool.sub(rewardsSubValue);
        _totalStaked = _totalStaked.sub(totalStakedSubValue);
        stake_.withdrawn = stake_.withdrawn.add(amount);
        stakingToken.safeTransfer(caller, amount);
        emit Withdrawn(caller, id, amount);
        return true;
    }

    function _calculateRewards(uint256 amount) internal view returns (uint256) {
        return amount.mul(revenue).div(100);
    }

    function _getStake(address account, uint256 id) internal view returns (StakeData storage) {
        require(id < _stakedInformation[account].length, "Invalid stake id");
        return _stakedInformation[account][id];
    }
}
