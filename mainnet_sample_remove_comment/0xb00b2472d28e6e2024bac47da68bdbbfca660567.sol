 

 

 

 

 

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


 
pragma solidity 0.7.6;





interface IPussyFarm {
    event Staked(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event Claimed(address indexed account, uint256 reward);

    function getProgram()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getStakeToken() external view returns (IERC20);

    function getRewardToken() external view returns (IERC20);

    function getStake(address account) external view returns (uint256);

    function getClaimed(address account) external view returns (uint256);

    function getTotalStaked() external view returns (uint256);

    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getPendingRewards(address account) external view returns (uint256);

    function claim() external returns (uint256);
}


 
pragma solidity 0.7.6;





contract PussyFarm is IPussyFarm, Ownable {
    using Math for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant RATE_FACTOR = 1e18;

    IERC20 internal immutable _stakeToken;
    IERC20 internal immutable _rewardToken;
    uint256 internal immutable _startTime;
    uint256 internal immutable _endTime;
    uint256 private immutable _rewardRate;

    mapping(address => uint256) internal _stakes;
    uint256 internal _totalStaked;

    uint256 private _lastUpdateTime;
    uint256 private _rewardPerTokenStored;
    mapping(address => uint256) private _stakerRewardPerTokenPaid;
    mapping(address => uint256) private _rewards;
    mapping(address => uint256) private _claimed;

     
    constructor(
        IERC20 stakeToken,
        IERC20 rewardToken,
        uint256 startTime,
        uint256 endTime,
        uint256 rewardRate
    ) {
        require(address(stakeToken) != address(0) && address(rewardToken) != address(0), "INVALID_ADDRESS");
        require(startTime < endTime && endTime > _time(), "INVALID_DURATION");
        require(rewardRate > 0, "INVALID_VALUE");

        _stakeToken = stakeToken;
        _rewardToken = rewardToken;
        _startTime = startTime;
        _endTime = endTime;
        _rewardRate = rewardRate;
    }

     
    modifier updateReward() {
        _rewardPerTokenStored = _rewardPerToken();
        _lastUpdateTime = Math.min(_time(), _endTime);

        _rewards[msg.sender] = _pendingRewards(msg.sender);
        _stakerRewardPerTokenPaid[msg.sender] = _rewardPerTokenStored;

        _;
    }

     
    function getProgram()
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (_startTime, _endTime, _rewardRate, _endTime.sub(_startTime).mul(_rewardRate));
    }

     
    function getStakeToken() external view override returns (IERC20) {
        return _stakeToken;
    }

     
    function getRewardToken() external view override returns (IERC20) {
        return _rewardToken;
    }

     
    function getStake(address account) external view override returns (uint256) {
        return _stakes[account];
    }

     
    function getClaimed(address account) external view override returns (uint256) {
        return _claimed[account];
    }

     
    function getTotalStaked() external view override returns (uint256) {
        return _totalStaked;
    }

     
    function stake(uint256 amount) public virtual override updateReward {
        require(amount > 0, "INVALID_AMOUNT");

        _stakes[msg.sender] = _stakes[msg.sender].add(amount);
        _totalStaked = _totalStaked.add(amount);

        _stakeToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

     
    function withdraw(uint256 amount) public virtual override updateReward {
        require(amount > 0, "INVALID_AMOUNT");

        claim();

        _stakes[msg.sender] = _stakes[msg.sender].sub(amount);
        _totalStaked = _totalStaked.sub(amount);

        _stakeToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

     
    function getPendingRewards(address account) external view override returns (uint256) {
        return _pendingRewards(account);
    }

     
    function claim() public virtual override updateReward returns (uint256) {
        uint256 reward = _pendingRewards(msg.sender);
        if (reward == 0) {
            return reward;
        }

        _rewards[msg.sender] = 0;
        _claimed[msg.sender] = _claimed[msg.sender].add(reward);

        _rewardToken.safeTransfer(msg.sender, reward);

        emit Claimed(msg.sender, reward);

        return reward;
    }

     
    function withdrawTokens(IERC20 token, uint256 amount) external onlyOwner {
        require(
            address(token) != address(_stakeToken) || amount <= token.balanceOf(address(this)).sub(_totalStaked),
            "INVALID_AMOUNT"
        );

        token.safeTransfer(msg.sender, amount);
    }

     
    function _rewardPerToken() private view returns (uint256) {
        if (_totalStaked == 0) {
            return _rewardPerTokenStored;
        }

        uint256 currentTime = _time();
        if (currentTime < _startTime) {
            return 0;
        }

        uint256 stakingEndTime = Math.min(currentTime, _endTime);
        uint256 stakingStartTime = Math.max(_startTime, _lastUpdateTime);
        if (stakingStartTime == stakingEndTime) {
            return _rewardPerTokenStored;
        }

        return
            _rewardPerTokenStored.add(
                stakingEndTime.sub(stakingStartTime).mul(_rewardRate).mul(RATE_FACTOR).div(_totalStaked)
            );
    }

     
    function _pendingRewards(address account) private view returns (uint256) {
        return
            _stakes[account].mul(_rewardPerToken().sub(_stakerRewardPerTokenPaid[account])).div(RATE_FACTOR).add(
                _rewards[account]
            );
    }

     
    function _time() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}