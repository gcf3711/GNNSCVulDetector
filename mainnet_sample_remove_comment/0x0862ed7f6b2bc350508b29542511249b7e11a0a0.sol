 

 

 

 

 

pragma solidity >=0.6.0 <=0.8.0;

 
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this;  
    return msg.data;
  }
}

 

pragma solidity ^0.7.6;

 

abstract contract Pausable is Context {
   
  event Paused(address account);

   
  event Unpaused(address account);

  bool private _paused;

   
  constructor() {
    _paused = false;
  }

   
  function paused() public view virtual returns (bool) {
    return _paused;
  }

   
  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
    _;
  }

   
  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }

   
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

   
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}

 

pragma solidity ^0.7.6;

 

contract Ownable is Pausable {
  address public _owner;
  address public _admin;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor(address ownerAddress) {
    _owner = msg.sender;
    _admin = ownerAddress;
    emit OwnershipTransferred(address(0), _owner);
  }

   
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

   
  modifier onlyAdmin() {
    require(_admin == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

   
  function renounceOwnership() public onlyAdmin {
    emit OwnershipTransferred(_owner, _admin);
    _owner = _admin;
  }

   
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

 

pragma solidity >=0.6.0 <=0.8.0;

 
library SafeMath {
   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

   
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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

   
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
     

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

   
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

 

pragma solidity >=0.6.0 <=0.8.0;

 
interface IERC20 {
   
  function totalSupply() external view returns (uint256);

   
  function balanceOf(address account) external view returns (uint256);

   
  function transfer(address recipient, uint256 amount) external returns (bool);

   
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

   
  function approve(address spender, uint256 amount) external returns (bool);

   
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

   
  event Transfer(address indexed from, address indexed to, uint256 value);

   
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.7.0;

abstract contract Admin {
  struct tokenInfo {
    bool isExist;
    uint8 decimal;
    uint256 userStakeLimit;
    uint256 maxStake;
  }

  uint256 public stakeDuration;

  mapping(address => address[]) public tokensSequenceList;
  mapping(address => mapping(address => uint256)) public tokenDailyDistribution;
  mapping(address => mapping(address => bool)) public tokenBlockedStatus;
  mapping(address => tokenInfo) public tokenDetails;
}

abstract contract UnifarmV1 is Admin {
  mapping(address => uint256) public totalStaking;

  function viewStakingDetails(address _user)
    external
    view
    virtual
    returns (
      address[] memory,
      bool[] memory,
      uint256[] memory,
      uint256[] memory,
      uint256[] memory
    );
}

 

pragma solidity ^0.7.6;

abstract contract AdminV1Proxy {
  mapping(address => uint256) public totalUnStakingB;
  mapping(address => uint256) public totalUnStakingA;
  mapping(address => mapping(uint256 => bool)) public unstakeStatus;

  function safeWithdraw(address tokenAddress, uint256 amount) external virtual;

  function transferOwnership(address newOwner) external virtual;

  function owner() external virtual returns (address);
}

 

pragma solidity ^0.7.6;

abstract contract U1Proxy is AdminV1Proxy {}

 

pragma solidity ^0.7.6;

contract U1ProxyUpgradeAdmin is Ownable {
  
  UnifarmV1 public u1;

  
  U1Proxy public u1Proxy;

  mapping(address => address[]) public tokensSequenceList;

  mapping(address => mapping(address => uint256)) public tokenDailyDistribution;

  uint256[] public intervalDays = [1, 8, 15, 22, 29];

  
  uint256 public poolStartTime;

  event TokenDetails(
    address indexed tokenAddress,
    uint256 userStakeimit,
    uint256 totalStakeLimit,
    uint256 Time
  );

  event WithdrawDetails(
    address indexed tokenAddress,
    uint256 withdrawalAmount,
    uint256 time
  );

  constructor() Ownable(msg.sender) {}

  function setDailyDistribution(
    address[] memory stakedToken,
    address[] memory rewardToken,
    uint256[] memory dailyDistribution
  ) public onlyOwner {
    require(
      stakedToken.length == rewardToken.length &&
        rewardToken.length == dailyDistribution.length,
      "Invalid Input"
    );

    for (uint8 i = 0; i < stakedToken.length; i++) {
      tokenDailyDistribution[stakedToken[i]][
        rewardToken[i]
      ] = dailyDistribution[i];
    }
  }

  function updateSequence(
    address stakedToken,
    address[] memory rewardTokenSequence
  ) public onlyOwner {
    tokensSequenceList[stakedToken] = new address[](0);

    for (uint8 i = 0; i < rewardTokenSequence.length; i++) {
      require(
        rewardTokenSequence.length <= intervalDays.length,
        " Invalid Index"
      );
      tokensSequenceList[stakedToken].push(rewardTokenSequence[i]);
    }
  }

  function safeWithdraw(address tokenAddress, uint256 amount)
    external
    onlyOwner
  {
    require(
      IERC20(tokenAddress).balanceOf(address(this)) >= amount,
      "SAFEWITHDRAW: Insufficient Balance"
    );

    require(
      IERC20(tokenAddress).transfer(_owner, amount) == true,
      "SAFEWITHDRAW: Transfer failed"
    );

    emit WithdrawDetails(tokenAddress, amount, block.timestamp);
  }

  function setPoolStartTime(uint256 epoch) external onlyOwner returns (bool) {
    poolStartTime = epoch;
    return true;
  }

  function setLegacyU1Addresses(address u1_, address u1Proxy_)
    external
    onlyOwner
    returns (bool)
  {
    u1 = UnifarmV1(u1_);
    u1Proxy = U1Proxy(u1Proxy_);
    return true;
  }
}

 

pragma solidity ^0.7.6;

contract U1ProxyUpgradablity is U1ProxyUpgradeAdmin {
  
  using SafeMath for uint256;

  
  uint256 public constant DAYS = 1 days;

  
  mapping(address => uint256) public u1UpgradeTotalUnStaking;

  
  mapping(address => mapping(uint256 => bool)) public u1UnstakeStatus;

  
  event IntervalDaysDetails(uint256[] updatedIntervals, uint256 time);

  event Claim(
    address indexed userAddress,
    address indexed stakedTokenAddress,
    address indexed tokenAddress,
    uint256 claimRewards,
    uint256 time
  );

  event UnStake(
    address indexed userAddress,
    address indexed unStakedtokenAddress,
    uint256 unStakedAmount,
    uint256 time,
    uint256 stakeID
  );

  function init(address[] memory tokenAddress)
    external
    onlyOwner
    returns (bool)
  {
    for (uint256 i = 0; i < tokenAddress.length; i++) {
      safeTransfer(tokenAddress[i]);
    }

    return true;
  }

  function safeTransfer(address tokenAddress) internal {
    uint256 bal = IERC20(tokenAddress).balanceOf(address(u1Proxy));
    if (bal > 0) u1Proxy.safeWithdraw(tokenAddress, bal);
  }

  function updateIntervalDays(uint256[] memory _interval) external onlyOwner {
    intervalDays = new uint256[](0);

    for (uint8 i = 0; i < _interval.length; i++) {
      uint256 noD = u1.stakeDuration().div(DAYS);
      require(noD > _interval[i], "Invalid Interval Day");
      intervalDays.push(_interval[i]);
    }
    emit IntervalDaysDetails(intervalDays, block.timestamp);
  }

  function transferV1ProxyOwnership(address newOwner) external onlyOwner {
    u1Proxy.transferOwnership(newOwner);
  }

   

  function getOneDayReward(
    uint256 stakedAmount,
    address stakedToken,
    address rewardToken,
    uint256 totalStake
  ) public view returns (uint256 reward) {
    reward = (
      stakedAmount.mul(tokenDailyDistribution[stakedToken][rewardToken])
    )
    .div(totalStake);
    return reward;
  }

   

  function sendToken(
    address user,
    address stakedToken,
    address tokenAddress,
    uint256 amount
  ) internal {
     

    if (tokenAddress != address(0)) {
      require(
        IERC20(tokenAddress).balanceOf(address(this)) >= amount,
        "SEND : Insufficient Balance"
      );
       
      require(IERC20(tokenAddress).transfer(user, amount), "Transfer failed");
       
      emit Claim(user, stakedToken, tokenAddress, amount, block.timestamp);
    }
  }

  function totalStaking(address tokenAddress) public view returns (uint256) {
    uint256 actualUnStaking = u1UpgradeTotalUnStaking[tokenAddress]
    .add(u1Proxy.totalUnStakingB(tokenAddress))
    .add(u1Proxy.totalUnStakingA(tokenAddress));
    return u1.totalStaking(tokenAddress).sub(actualUnStaking);
  }

   
  function unStake(address user, uint256 stakeId) external whenNotPaused {
    require(
      msg.sender == user || msg.sender == _owner,
      "UNSTAKE: Invalid User Entry"
    );

    (
      address[] memory tokenAddress,
      bool[] memory activeStatus,
      ,
      uint256[] memory stakedAmount,
      uint256[] memory startTime
    ) = (u1.viewStakingDetails(user));

    bool isAlreadyUnstaked = u1Proxy.unstakeStatus(user, stakeId);

     
    if (
      u1UnstakeStatus[user][stakeId] == false &&
      activeStatus[stakeId] == true &&
      isAlreadyUnstaked == false
    ) u1UnstakeStatus[user][stakeId] = true;
    else revert("UNSTAKE : Unstaked Already");

     
    uint256 actualStaking = totalStaking(tokenAddress[stakeId]);

     
    u1UpgradeTotalUnStaking[tokenAddress[stakeId]] = u1UpgradeTotalUnStaking[
      tokenAddress[stakeId]
    ]
    .add(stakedAmount[stakeId]);

     
    require(
      IERC20(tokenAddress[stakeId]).balanceOf(address(this)) >=
        stakedAmount[stakeId],
      "UNSTAKE : Insufficient Balance"
    );

    IERC20(tokenAddress[stakeId]).transfer(user, stakedAmount[stakeId]);

    if (startTime[stakeId] < poolStartTime.add(u1.stakeDuration())) {
      claimRewards(
        user,
        startTime[stakeId],
        stakedAmount[stakeId],
        tokenAddress[stakeId],
        actualStaking
      );
    }

     
    emit UnStake(
      user,
      tokenAddress[stakeId],
      stakedAmount[stakeId],
      block.timestamp,
      stakeId
    );
  }

  function claimRewards(
    address user,
    uint256 stakeTime,
    uint256 stakedAmount,
    address stakedToken,
    uint256 totalStake
  ) internal {
     
    uint256 interval;
    uint256 endOfProfit;

    interval = poolStartTime.add(u1.stakeDuration());

    if (interval > block.timestamp) endOfProfit = block.timestamp;
    else endOfProfit = interval;

    interval = endOfProfit.sub(stakeTime);
     

    if (interval >= DAYS)
      _rewardCalculation(user, stakedAmount, interval, stakedToken, totalStake);
  }

  function _rewardCalculation(
    address user,
    uint256 stakedAmount,
    uint256 interval,
    address stakedToken,
    uint256 totalStake
  ) internal {
    uint256 rewardsEarned;
    uint256 noOfDays;

    noOfDays = interval.div(DAYS);
    rewardsEarned = noOfDays.mul(
      getOneDayReward(stakedAmount, stakedToken, stakedToken, totalStake)
    );

     
    sendToken(user, stakedToken, stakedToken, rewardsEarned);

    uint8 i = 1;
    while (i < intervalDays.length) {
      if (noOfDays >= intervalDays[i]) {
        uint256 balDays = noOfDays.sub((intervalDays[i].sub(1)));

        address rewardToken = tokensSequenceList[stakedToken][i];

        if (
          rewardToken != stakedToken &&
          u1.tokenBlockedStatus(stakedToken, rewardToken) == false
        ) {
          rewardsEarned = balDays.mul(
            getOneDayReward(stakedAmount, stakedToken, rewardToken, totalStake)
          );
           
          sendToken(user, stakedToken, rewardToken, rewardsEarned);
        }
        i = i + 1;
      } else {
        break;
      }
    }
  }

  function emergencyUnstake(
    uint256 stakeId,
    address userAddress,
    address[] memory rewardtokens,
    uint256[] memory amount
  ) external onlyOwner {
    (
      address[] memory tokenAddress,
      bool[] memory activeStatus,
      ,
      uint256[] memory stakedAmount,

    ) = (u1.viewStakingDetails(userAddress));

    bool isAlreadyUnstaked = u1Proxy.unstakeStatus(userAddress, stakeId);

    if (
      u1UnstakeStatus[userAddress][stakeId] == false &&
      isAlreadyUnstaked == false &&
      activeStatus[stakeId] == true
    ) u1UnstakeStatus[userAddress][stakeId] = true;
    else revert("EMERGENCY: Unstaked Already");

     
    require(
      IERC20(tokenAddress[stakeId]).balanceOf(address(this)) >=
        stakedAmount[stakeId],
      "EMERGENCY : Insufficient Balance"
    );

    IERC20(tokenAddress[stakeId]).transfer(userAddress, stakedAmount[stakeId]);

    for (uint256 i; i < rewardtokens.length; i++) {
      require(
        IERC20(rewardtokens[i]).balanceOf(address(this)) >= amount[i],
        "EMERGENCY : Insufficient Reward Balance"
      );
      sendToken(userAddress, tokenAddress[stakeId], rewardtokens[i], amount[i]);
    }

    u1UpgradeTotalUnStaking[tokenAddress[stakeId]] = u1UpgradeTotalUnStaking[
      tokenAddress[stakeId]
    ]
    .add(stakedAmount[stakeId]);

     
    emit UnStake(
      userAddress,
      tokenAddress[stakeId],
      stakeId,
      stakedAmount[stakeId],
      block.timestamp
    );
  }

  function lockContract(bool pauseStatus) external onlyOwner {
    if (pauseStatus == true) _pause();
    else if (pauseStatus == false) _unpause();
  }
}