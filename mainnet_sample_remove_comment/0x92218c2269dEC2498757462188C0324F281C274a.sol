 

 

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.5.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity ^0.5.0;




 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity ^0.5.0;



contract IRewardDistributionRecipient is Ownable {
    address rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        public
        onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}

 

pragma solidity ^0.5.0;



interface IUpdateTBD {
    function updateTopbidderDivident(uint256 _tb) external;
}

 
 
 
 
contract vBid {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public bid = IERC20(0x00000000000045166C45aF0FC6E4Cf31D9E14B9A);

     
    uint256 public STAKE_DURATION;
    uint256 public MAX_STAKE_TIME;

    uint256 private _totalSupply;
    uint256 public _totalSupplyBid;
     
    mapping(address => uint256) public _balances; 
    mapping(address => uint256) public _bidBalances;
    mapping(address => uint256) public _startTimes;
    mapping(address => uint256) public _stakeTimes;
     
    mapping(address => address) public _voteContracts;
    mapping(address => uint256) public _voteDate;
    mapping(address => uint256) public _contractTotals;
    
    function nowtime() public view returns (uint256) {
        return block.timestamp;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function voteContract(address _contract) internal {
        require(_voteDate[msg.sender]<block.timestamp - 10 days,"can not change vote in 10 days");
        require(_voteContracts[msg.sender]!=_contract,"can not vote same contract");
        _voteDate[msg.sender]=block.timestamp;
        address old_contract=_voteContracts[msg.sender];
        _voteContracts[msg.sender]=_contract;
        if(old_contract!=address(0)){
             
            _contractTotals[_contract]-=_balances[msg.sender].div(12);
            updateContract(old_contract,_contractTotals[msg.sender]);
        }
         
        _contractTotals[_contract]+=_balances[msg.sender].div(12);
        updateContract(_contract,_contractTotals[_contract]);
    }
    function updateContract(address _contract,uint256 value) internal {

        IUpdateTBD(_contract).updateTopbidderDivident(value);

    }
     
     
    function vstake(uint256 bidAmount,uint256 stakeTime) internal {
        require((stakeTime<=MAX_STAKE_TIME)&&(stakeTime>=STAKE_DURATION),"stakeTime not in range");
        require(bidAmount>0,"bid amount must > 0");
        require(_balances[msg.sender]==0,"this should be called with zero stake");
        
        uint256 amount=bidAmount.mul(stakeTime).div(STAKE_DURATION);
        
         
        _totalSupply = _totalSupply.add(amount);
        _totalSupplyBid= _totalSupplyBid.add(bidAmount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
         
        bid.safeTransferFrom(msg.sender, address(this), bidAmount);
        _bidBalances[msg.sender]=bidAmount;
        _startTimes[msg.sender]=block.timestamp;
        _stakeTimes[msg.sender]=stakeTime;

        address _contract=_voteContracts[msg.sender];
        if(_contract!=address(0)){
            _contractTotals[_contract]=_contractTotals[_contract].add(_balances[msg.sender].div(12));
            updateContract(_contract,_contractTotals[_contract]);
        }
    
    }
     
     
    function increaseStakeAndTime(uint256 bidAmount,uint256 stakeTime1) internal {
        require(block.timestamp<=_startTimes[msg.sender].add(_stakeTimes[msg.sender]), "stake time expire, please withdraw all");
 
        require(_balances[msg.sender]>0,"this should be called with non-zero stake");
        uint256 newStakeTime=_stakeTimes[msg.sender].add(stakeTime1);
        require(newStakeTime<=MAX_STAKE_TIME,"newStakeTime 》MAX");
        
        uint256 amountNew=bidAmount.mul(_startTimes[msg.sender]+newStakeTime-block.timestamp).div(STAKE_DURATION);
        uint256 amountOri=_bidBalances[msg.sender].mul(stakeTime1).div(STAKE_DURATION);
        uint256 amount=amountNew.add(amountOri);
        
         
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
         
        if(bidAmount>0){
            bid.safeTransferFrom(msg.sender, address(this), bidAmount);
            _bidBalances[msg.sender]=_bidBalances[msg.sender].add(bidAmount);
            _totalSupplyBid= _totalSupplyBid.add(bidAmount);
        }

        _stakeTimes[msg.sender]=newStakeTime;

        address _contract=_voteContracts[msg.sender];
        if(_contract!=address(0)){
            _contractTotals[_contract]=_contractTotals[_contract].add(amountNew.div(12));
            updateContract(_contract,_contractTotals[_contract]);
        }

    }


     
    function withdraw() public {
         
         
        
        uint256 amount=_balances[msg.sender];
        
        _totalSupply = _totalSupply.sub(amount);
        _totalSupplyBid= _totalSupplyBid.sub(_bidBalances[msg.sender]);
        _balances[msg.sender] = 0;
        bid.safeTransfer(msg.sender, _bidBalances[msg.sender]);
        _bidBalances[msg.sender]=0;
        _startTimes[msg.sender]=0;
        _stakeTimes[msg.sender]=0;

        address _contract=_voteContracts[msg.sender];
        if(_contract!=address(0)){
            _contractTotals[_contract]=_contractTotals[_contract].sub(amount.div(12));
            _voteContracts[msg.sender]=address(0);
            updateContract(_contract,_contractTotals[_contract]);
        }
    }
}

contract TBV2Pool is vBid, IRewardDistributionRecipient {
     
    IERC20 public lptoken = IERC20(0xec9220eE98FB1C045110D675BAFb1A8DDA6Ae7F1);
     

    uint256 public BONUS_DURATION;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount,uint256 time);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(uint256 _bonus_duration,uint256 _stake_duration ) Ownable() public {
        BONUS_DURATION=_bonus_duration;
        STAKE_DURATION=_stake_duration;
        MAX_STAKE_TIME=12*STAKE_DURATION;
        setRewardDistribution(owner());
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 bidAmount,uint256 time) public updateReward(msg.sender) {
        require(bidAmount > 0, "Cannot stake 0");
        super.vstake(bidAmount,time);
        emit Staked(msg.sender, bidAmount,time);
    }
    function increaseStakeWTime(uint256 bidAmount,uint256 time) public updateReward(msg.sender) {
        super.increaseStakeAndTime(bidAmount,time);
        emit Staked(msg.sender, bidAmount,time);
    }


    function withdraw() public updateReward(msg.sender) {
        uint256 bidAmount=_bidBalances[msg.sender];
        super.withdraw();
        emit Withdrawn(msg.sender,bidAmount);
    }

    function exit() external {
        withdraw();
        getReward();
    }

    function vote(address _contract) external {
        super.voteContract(_contract);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            lptoken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(BONUS_DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(BONUS_DURATION);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(BONUS_DURATION);
        emit RewardAdded(reward);
    }
}