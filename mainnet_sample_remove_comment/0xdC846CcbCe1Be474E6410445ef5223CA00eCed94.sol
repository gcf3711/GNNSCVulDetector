 
pragma abicoder v2;


 

 
pragma solidity >=0.4.24 <0.8.0;



 
abstract contract Initializable {

     
    bool private _initialized;

     
    bool private _initializing;

     
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
    uint256[50] private __gap;
}

 

pragma solidity ^0.7.0;



 
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

 

pragma solidity ^0.7.6;




interface ICLeverCVXLocker {
  event Deposit(address indexed _account, uint256 _amount);
  event Unlock(address indexed _account, uint256 _amount);
  event Withdraw(address indexed _account, uint256 _amount);
  event Repay(address indexed _account, uint256 _cvxAmount, uint256 _clevCVXAmount);
  event Borrow(address indexed _account, uint256 _amount);
  event Claim(address indexed _account, uint256 _amount);
  event Harvest(address indexed _caller, uint256 _reward, uint256 _platformFee, uint256 _harvestBounty);

  function getUserInfo(address _account)
    external
    view
    returns (
      uint256 totalDeposited,
      uint256 totalPendingUnlocked,
      uint256 totalUnlocked,
      uint256 totalBorrowed,
      uint256 totalReward
    );

  function deposit(uint256 _amount) external;

  function unlock(uint256 _amount) external;

  function withdrawUnlocked() external;

  function repay(uint256 _cvxAmount, uint256 _clevCVXAmount) external;

  function borrow(uint256 _amount, bool _depositToFurnace) external;

  function donate(uint256 _amount) external;

  function harvest(address _recipient, uint256 _minimumOut) external returns (uint256);

  function harvestVotium(IVotiumMultiMerkleStash.claimParam[] calldata claims, uint256 _minimumOut)
    external
    returns (uint256);
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

pragma solidity ^0.7.6;














 

contract CLeverCVXLocker is OwnableUpgradeable, ICLeverCVXLocker {
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  event UpdateWhitelist(address indexed _whitelist, bool _status);
  event UpdateStakePercentage(uint256 _percentage);
  event UpdateStakeThreshold(uint256 _threshold);
  event UpdateRepayFeePercentage(uint256 _feePercentage);
  event UpdatePlatformFeePercentage(uint256 _feePercentage);
  event UpdateHarvestBountyPercentage(uint256 _percentage);
  event UpdatePlatform(address indexed _platform);
  event UpdateZap(address indexed _zap);
  event UpdateGovernor(address indexed _governor);

   
  uint256 private constant PRECISION = 1e18;
   
  uint256 private constant FEE_DENOMINATOR = 1e9;
   
  uint256 private constant MAX_REPAY_FEE = 1e8;  
   
  uint256 private constant MAX_PLATFORM_FEE = 2e8;  
   
  uint256 private constant MAX_HARVEST_BOUNTY = 1e8;  
   
  uint256 private constant REWARDS_DURATION = 86400 * 7;  

   
  address private constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
   
  address private constant CVXCRV = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
   
  address private constant CVX_REWARD_POOL = 0xCF50b810E57Ac33B91dCF525C6ddd9881B139332;
   
  address private constant CVX_LOCKER = 0x72a19342e8F1838460eBFCCEf09F6585e32db86E;
   
  address private constant VOTIUM_DISTRIBUTOR = 0x378Ba9B73309bE80BF4C2c027aAD799766a7ED5A;

  struct EpochUnlockInfo {
     
    uint192 pendingUnlock;
     
    uint64 unlockEpoch;
  }

  struct UserInfo {
     
    uint128 totalDebt;
     
    uint128 rewards;
     
    uint192 rewardPerSharePaid;
     
    uint64 lastInteractedBlock;
     
    uint112 totalLocked;
     
    uint112 totalUnlocked;
     
    uint32 nextUnlockIndex;
     
     
     
     
     
     
     
     
     
    uint256[17] epochLocked;
     
    EpochUnlockInfo[] pendingUnlockList;
  }

  
  address public governor;
  
  address public clevCVX;

  
   
   
   
  
  uint256 public totalLockedGlobal;
  
  uint256 public totalPendingUnlockGlobal;
  
  uint256 public totalUnlockedGlobal;
  
  uint256 public totalDebtGlobal;

  
  uint256 public accRewardPerShare;
  
  mapping(address => UserInfo) public userInfo;
  
  mapping(uint256 => uint256) public pendingUnlocked;
  
  address public furnace;
  
  uint256 public stakePercentage;
  
  uint256 public stakeThreshold;
  
  uint256 public reserveRate;
  
  mapping(address => bool) public manualSwapRewardToken;

  
  address public zap;
  
  uint256 public repayFeePercentage;
  
  uint256 public harvestBountyPercentage;
  
  uint256 public platformFeePercentage;
  
  address public platform;

  
  mapping(address => bool) public isKeeper;

  modifier onlyGovernorOrOwner() {
    require(msg.sender == governor || msg.sender == owner(), "CLeverCVXLocker: only governor or owner");
    _;
  }

  modifier onlyKeeper() {
    require(isKeeper[msg.sender], "CLeverCVXLocker: only keeper");
    _;
  }

  function initialize(
    address _governor,
    address _clevCVX,
    address _zap,
    address _furnace,
    address _platform,
    uint256 _platformFeePercentage,
    uint256 _harvestBountyPercentage
  ) external initializer {
    OwnableUpgradeable.__Ownable_init();

    require(_governor != address(0), "CLeverCVXLocker: zero governor address");
    require(_clevCVX != address(0), "CLeverCVXLocker: zero clevCVX address");
    require(_zap != address(0), "CLeverCVXLocker: zero zap address");
    require(_furnace != address(0), "CLeverCVXLocker: zero furnace address");
    require(_platform != address(0), "CLeverCVXLocker: zero platform address");
    require(_platformFeePercentage <= MAX_PLATFORM_FEE, "CLeverCVXLocker: fee too large");
    require(_harvestBountyPercentage <= MAX_HARVEST_BOUNTY, "CLeverCVXLocker: fee too large");

    governor = _governor;
    clevCVX = _clevCVX;
    zap = _zap;
    furnace = _furnace;
    platform = _platform;
    platformFeePercentage = _platformFeePercentage;
    harvestBountyPercentage = _harvestBountyPercentage;
    reserveRate = 500_000_000;
  }

   

  
  
  
  
  
  
  
  function getUserInfo(address _account)
    external
    view
    override
    returns (
      uint256 totalDeposited,
      uint256 totalPendingUnlocked,
      uint256 totalUnlocked,
      uint256 totalBorrowed,
      uint256 totalReward
    )
  {
    UserInfo storage _info = userInfo[_account];

    totalDeposited = _info.totalLocked;

     
    totalBorrowed = _info.totalDebt;
    totalReward = uint256(_info.rewards).add(
      accRewardPerShare.sub(_info.rewardPerSharePaid).mul(totalDeposited) / PRECISION
    );
    if (totalBorrowed > 0) {
      if (totalReward >= totalBorrowed) {
        totalReward -= totalBorrowed;
        totalBorrowed = 0;
      } else {
        totalBorrowed -= totalReward;
        totalReward = 0;
      }
    }

     
    totalUnlocked = _info.totalUnlocked;
    EpochUnlockInfo[] storage _pendingUnlockList = _info.pendingUnlockList;
    uint256 _nextUnlockIndex = _info.nextUnlockIndex;
    uint256 _currentEpoch = block.timestamp / REWARDS_DURATION;
    while (_nextUnlockIndex < _pendingUnlockList.length) {
      if (_pendingUnlockList[_nextUnlockIndex].unlockEpoch <= _currentEpoch) {
        totalUnlocked += _pendingUnlockList[_nextUnlockIndex].pendingUnlock;
      } else {
        totalPendingUnlocked += _pendingUnlockList[_nextUnlockIndex].pendingUnlock;
      }
      _nextUnlockIndex += 1;
    }
  }

  
  
  
  
  function getUserLocks(address _account)
    external
    view
    returns (EpochUnlockInfo[] memory locks, EpochUnlockInfo[] memory pendingUnlocks)
  {
    UserInfo storage _info = userInfo[_account];

    uint256 _currentEpoch = block.timestamp / REWARDS_DURATION;
    uint256 lengthLocks;
    for (uint256 i = 0; i < 17; i++) {
      if (_info.epochLocked[i] > 0) {
        lengthLocks++;
      }
    }
    locks = new EpochUnlockInfo[](lengthLocks);
    lengthLocks = 0;
    for (uint256 i = 0; i < 17; i++) {
      uint256 _index = (_currentEpoch + i + 1) % 17;
      if (_info.epochLocked[_index] > 0) {
        locks[lengthLocks].pendingUnlock = uint192(_info.epochLocked[_index]);
        locks[lengthLocks].unlockEpoch = uint64(_currentEpoch + i + 1);
        lengthLocks += 1;
      }
    }

    uint256 _nextUnlockIndex = _info.nextUnlockIndex;
    EpochUnlockInfo[] storage _pendingUnlockList = _info.pendingUnlockList;
    uint256 lengthPendingUnlocks;
    for (uint256 i = _nextUnlockIndex; i < _pendingUnlockList.length; i++) {
      if (_pendingUnlockList[i].unlockEpoch > _currentEpoch) {
        lengthPendingUnlocks += 1;
      }
    }
    pendingUnlocks = new EpochUnlockInfo[](lengthPendingUnlocks);
    lengthPendingUnlocks = 0;
    for (uint256 i = _nextUnlockIndex; i < _pendingUnlockList.length; i++) {
      if (_pendingUnlockList[i].unlockEpoch > _currentEpoch) {
        pendingUnlocks[lengthPendingUnlocks] = _pendingUnlockList[i];
        lengthPendingUnlocks += 1;
      }
    }
  }

  
  
  function totalCVXInPool() public view returns (uint256) {
    return
      IERC20Upgradeable(CVX).balanceOf(address(this)).add(
        IConvexCVXRewardPool(CVX_REWARD_POOL).balanceOf(address(this))
      );
  }

   

  
  
  function deposit(uint256 _amount) external override {
    require(_amount > 0, "CLeverCVXLocker: deposit zero CVX");
    IERC20Upgradeable(CVX).safeTransferFrom(msg.sender, address(this), _amount);

     
    _updateReward(msg.sender);

     
    IERC20Upgradeable(CVX).safeApprove(CVX_LOCKER, 0);
    IERC20Upgradeable(CVX).safeApprove(CVX_LOCKER, _amount);
    IConvexCVXLocker(CVX_LOCKER).lock(address(this), _amount, 0);

     
    uint256 _currentEpoch = block.timestamp / REWARDS_DURATION;
    uint256 _reminder = _currentEpoch % 17;

    UserInfo storage _info = userInfo[msg.sender];
    _info.totalLocked = uint112(_amount + uint256(_info.totalLocked));  
    _info.epochLocked[_reminder] = _amount + _info.epochLocked[_reminder];  

     
    totalLockedGlobal = _amount.add(totalLockedGlobal);  

    emit Deposit(msg.sender, _amount);
  }

  
   
  
  function unlock(uint256 _amount) external override {
    require(_amount > 0, "CLeverCVXLocker: unlock zero CVX");
     
    _updateReward(msg.sender);

     
    _updateUnlocked(msg.sender);

     
    UserInfo storage _info = userInfo[msg.sender];
    {
      uint256 _totalLocked = _info.totalLocked;
      uint256 _totalDebt = _info.totalDebt;
      require(_amount <= _totalLocked, "CLeverCVXLocker: insufficient CVX to unlock");

      _checkAccountHealth(_totalLocked, _totalDebt, _amount, 0);
       
      _info.totalLocked = uint112(_totalLocked - _amount);  
       
      totalLockedGlobal -= _amount;
      totalPendingUnlockGlobal += _amount;
    }

    emit Unlock(msg.sender, _amount);

     
    uint256 _nextEpoch = block.timestamp / REWARDS_DURATION + 1;
    EpochUnlockInfo[] storage _pendingUnlockList = _info.pendingUnlockList;
    uint256 _index;
    uint256 _locked;
    uint256 _unlocked;
    for (uint256 i = 0; i < 17; i++) {
      _index = _nextEpoch % 17;
      _locked = _info.epochLocked[_index];
      if (_amount >= _locked) _unlocked = _locked;
      else _unlocked = _amount;

      if (_unlocked > 0) {
        _info.epochLocked[_index] = _locked - _unlocked;  
        _amount = _amount - _unlocked;  
        pendingUnlocked[_nextEpoch] = pendingUnlocked[_nextEpoch] + _unlocked;  

        if (
          _pendingUnlockList.length == 0 || _pendingUnlockList[_pendingUnlockList.length - 1].unlockEpoch != _nextEpoch
        ) {
          _pendingUnlockList.push(
            EpochUnlockInfo({ pendingUnlock: uint192(_unlocked), unlockEpoch: uint64(_nextEpoch) })
          );
        } else {
          _pendingUnlockList[_pendingUnlockList.length - 1].pendingUnlock = uint192(
            _unlocked + _pendingUnlockList[_pendingUnlockList.length - 1].pendingUnlock
          );
        }
      }

      if (_amount == 0) break;
      _nextEpoch = _nextEpoch + 1;
    }
  }

  
  function withdrawUnlocked() external override {
     
    _updateReward(msg.sender);

     
    _updateUnlocked(msg.sender);

     
    UserInfo storage _info = userInfo[msg.sender];
    uint256 _unlocked = _info.totalUnlocked;
    _info.totalUnlocked = 0;

     
    totalUnlockedGlobal = totalUnlockedGlobal.sub(_unlocked);

    uint256 _balanceInContract = IERC20Upgradeable(CVX).balanceOf(address(this));
     
    if (_balanceInContract < _unlocked) {
      IConvexCVXRewardPool(CVX_REWARD_POOL).withdraw(_unlocked - _balanceInContract, false);
    }

    IERC20Upgradeable(CVX).safeTransfer(msg.sender, _unlocked);

    emit Withdraw(msg.sender, _unlocked);
  }

  
  
  
  function repay(uint256 _cvxAmount, uint256 _clevCVXAmount) external override {
    require(_cvxAmount > 0 || _clevCVXAmount > 0, "CLeverCVXLocker: repay zero amount");

     
    _updateReward(msg.sender);

    UserInfo storage _info = userInfo[msg.sender];
    uint256 _totalDebt = _info.totalDebt;
    uint256 _totalDebtGlobal = totalDebtGlobal;

     
    if (_cvxAmount > 0 && _totalDebt > 0) {
      if (_cvxAmount > _totalDebt) _cvxAmount = _totalDebt;
      uint256 _fee = _cvxAmount.mul(repayFeePercentage) / FEE_DENOMINATOR;
      _totalDebt = _totalDebt - _cvxAmount;  
      _totalDebtGlobal = _totalDebtGlobal - _cvxAmount;  

       
      IERC20Upgradeable(CVX).safeTransferFrom(msg.sender, address(this), _cvxAmount + _fee);
      if (_fee > 0) {
        IERC20Upgradeable(CVX).safeTransfer(platform, _fee);
      }
      address _furnace = furnace;
      IERC20Upgradeable(CVX).safeApprove(_furnace, 0);
      IERC20Upgradeable(CVX).safeApprove(_furnace, _cvxAmount);
      IFurnace(_furnace).distribute(address(this), _cvxAmount);
    }

     
    if (_clevCVXAmount > 0 && _totalDebt > 0) {
      if (_clevCVXAmount > _totalDebt) _clevCVXAmount = _totalDebt;
      uint256 _fee = _clevCVXAmount.mul(repayFeePercentage) / FEE_DENOMINATOR;
      _totalDebt = _totalDebt - _clevCVXAmount;  
      _totalDebtGlobal = _totalDebtGlobal - _clevCVXAmount;

       
      if (_fee > 0) {
        IERC20Upgradeable(clevCVX).safeTransferFrom(msg.sender, platform, _fee);
      }
      ICLeverToken(clevCVX).burnFrom(msg.sender, _clevCVXAmount);
    }

    _info.totalDebt = uint128(_totalDebt);
    totalDebtGlobal = _totalDebtGlobal;

    emit Repay(msg.sender, _cvxAmount, _clevCVXAmount);
  }

  
   
  
  
  function borrow(uint256 _amount, bool _depositToFurnace) external override {
    require(_amount > 0, "CLeverCVXLocker: borrow zero amount");

     
    _updateReward(msg.sender);

    UserInfo storage _info = userInfo[msg.sender];
    uint256 _rewards = _info.rewards;
    uint256 _borrowWithLocked;

     
    if (_rewards >= _amount) {
      _info.rewards = uint128(_rewards - _amount);
    } else {
      _info.rewards = 0;
      _borrowWithLocked = _amount - _rewards;
    }

     
    if (_borrowWithLocked > 0) {
      uint256 _totalLocked = _info.totalLocked;
      uint256 _totalDebt = _info.totalDebt;
      _checkAccountHealth(_totalLocked, _totalDebt, 0, _borrowWithLocked);
       
      _info.totalDebt = uint128(_totalDebt + _borrowWithLocked);  
       
      totalDebtGlobal = totalDebtGlobal + _borrowWithLocked;  
    }

    _mintOrDeposit(_amount, _depositToFurnace);

    emit Borrow(msg.sender, _amount);
  }

  
  
  function donate(uint256 _amount) external override {
    require(_amount > 0, "CLeverCVXLocker: donate zero amount");
    IERC20Upgradeable(CVX).safeTransferFrom(msg.sender, address(this), _amount);

    _distribute(_amount);
  }

  
  
  
  
  function harvest(address _recipient, uint256 _minimumOut) external override returns (uint256) {
     
    IConvexCVXRewardPool(CVX_REWARD_POOL).getReward(false);
    IConvexCVXLocker(CVX_LOCKER).getReward(address(this));

     
    uint256 _amount = IERC20Upgradeable(CVXCRV).balanceOf(address(this));
    if (_amount > 0) {
      IERC20Upgradeable(CVXCRV).safeTransfer(zap, _amount);
      _amount = IZap(zap).zap(CVXCRV, _amount, CVX, _minimumOut);
    }
    require(_amount >= _minimumOut, "CLeverCVXLocker: insufficient output");

     
    uint256 _platformFee = platformFeePercentage;
    uint256 _distributeAmount = _amount;
    if (_platformFee > 0) {
      _platformFee = (_distributeAmount * _platformFee) / FEE_DENOMINATOR;
      _distributeAmount = _distributeAmount - _platformFee;
      IERC20Upgradeable(CVX).safeTransfer(platform, _platformFee);
    }
    uint256 _harvestBounty = harvestBountyPercentage;
    if (_harvestBounty > 0) {
      _harvestBounty = (_distributeAmount * _harvestBounty) / FEE_DENOMINATOR;
      _distributeAmount = _distributeAmount - _harvestBounty;
      IERC20Upgradeable(CVX).safeTransfer(_recipient, _harvestBounty);
    }

     
    _distribute(_distributeAmount);

    emit Harvest(msg.sender, _distributeAmount, _platformFee, _harvestBounty);

    return _amount;
  }

  
  
  
  
  function harvestVotium(IVotiumMultiMerkleStash.claimParam[] calldata claims, uint256 _minimumOut)
    external
    override
    onlyKeeper
    returns (uint256)
  {
     
    for (uint256 i = 0; i < claims.length; i++) {
       
      if (!IVotiumMultiMerkleStash(VOTIUM_DISTRIBUTOR).isClaimed(claims[i].token, claims[i].index)) {
        IVotiumMultiMerkleStash(VOTIUM_DISTRIBUTOR).claim(
          claims[i].token,
          claims[i].index,
          address(this),
          claims[i].amount,
          claims[i].merkleProof
        );
      }
    }
    address[] memory _rewardTokens = new address[](claims.length);
    uint256[] memory _amounts = new uint256[](claims.length);
    for (uint256 i = 0; i < claims.length; i++) {
      _rewardTokens[i] = claims[i].token;
       
      _amounts[i] = claims[i].amount;
    }

     
    uint256 _amount = _swapToCVX(_rewardTokens, _amounts, _minimumOut);

     
    uint256 _distributeAmount = _amount;
    uint256 _platformFee = platformFeePercentage;
    if (_platformFee > 0) {
      _platformFee = (_distributeAmount * _platformFee) / FEE_DENOMINATOR;
      _distributeAmount = _distributeAmount - _platformFee;
      IERC20Upgradeable(CVX).safeTransfer(platform, _platformFee);
    }

     
    _distribute(_distributeAmount);

    emit Harvest(msg.sender, _distributeAmount, _platformFee, 0);

    return _amount;
  }

  
   
   
   
   
  function processUnlockableCVX() external onlyKeeper {
     
     
     

     
    uint256 _extraCVX = totalCVXInPool().sub(totalUnlockedGlobal);

     
    uint256 _unlocked = IERC20Upgradeable(CVX).balanceOf(address(this));
    IConvexCVXLocker(CVX_LOCKER).processExpiredLocks(false);
    _unlocked = IERC20Upgradeable(CVX).balanceOf(address(this)).sub(_unlocked).add(_extraCVX);

     
    uint256 currentEpoch = block.timestamp / REWARDS_DURATION;
    uint256 _pending = pendingUnlocked[currentEpoch];
    if (_pending > 0) {
       
      require(_unlocked >= _pending, "CLeverCVXLocker: insufficient unlocked CVX");
      _unlocked -= _pending;
       
      totalUnlockedGlobal = totalUnlockedGlobal.add(_pending);
      totalPendingUnlockGlobal -= _pending;  
      pendingUnlocked[currentEpoch] = 0;
    }

     
    if (_unlocked > 0) {
      IERC20Upgradeable(CVX).safeApprove(CVX_LOCKER, 0);
      IERC20Upgradeable(CVX).safeApprove(CVX_LOCKER, _unlocked);
      IConvexCVXLocker(CVX_LOCKER).lock(address(this), _unlocked, 0);
    }
  }

   

  
  
  
  
  function delegate(
    address _registry,
    bytes32 _id,
    address _delegate
  ) external onlyGovernorOrOwner {
    ISnapshotDelegateRegistry(_registry).setDelegate(_id, _delegate);
  }

  
  
  function updateGovernor(address _governor) external onlyGovernorOrOwner {
    require(_governor != address(0), "CLeverCVXLocker: zero governor address");
    governor = _governor;

    emit UpdateGovernor(_governor);
  }

  
  
  function updateStakePercentage(uint256 _percentage) external onlyGovernorOrOwner {
    require(_percentage <= FEE_DENOMINATOR, "CLeverCVXLocker: percentage too large");
    stakePercentage = _percentage;

    emit UpdateStakePercentage(_percentage);
  }

  
  
  function updateStakeThreshold(uint256 _threshold) external onlyGovernorOrOwner {
    stakeThreshold = _threshold;

    emit UpdateStakeThreshold(_threshold);
  }

  
  
  
  function updateManualSwapRewardToken(address[] memory _tokens, bool _status) external onlyGovernorOrOwner {
    for (uint256 i = 0; i < _tokens.length; i++) {
      require(_tokens[i] != CVX, "CLeverCVXLocker: invalid token");
      manualSwapRewardToken[_tokens[i]] = _status;
    }
  }

  
  
  function updateRepayFeePercentage(uint256 _feePercentage) external onlyOwner {
    require(_feePercentage <= MAX_REPAY_FEE, "AladdinCRV: fee too large");
    repayFeePercentage = _feePercentage;

    emit UpdateRepayFeePercentage(_feePercentage);
  }

  
  
  function updatePlatformFeePercentage(uint256 _feePercentage) external onlyOwner {
    require(_feePercentage <= MAX_PLATFORM_FEE, "AladdinCRV: fee too large");
    platformFeePercentage = _feePercentage;

    emit UpdatePlatformFeePercentage(_feePercentage);
  }

  
  
  function updateHarvestBountyPercentage(uint256 _percentage) external onlyOwner {
    require(_percentage <= MAX_HARVEST_BOUNTY, "AladdinCRV: fee too large");
    harvestBountyPercentage = _percentage;

    emit UpdateHarvestBountyPercentage(_percentage);
  }

  
  function updatePlatform(address _platform) external onlyOwner {
    require(_platform != address(0), "AladdinCRV: zero platform address");
    platform = _platform;

    emit UpdatePlatform(_platform);
  }

  
  function updateZap(address _zap) external onlyGovernorOrOwner {
    require(_zap != address(0), "CLeverCVXLocker: zero zap address");
    zap = _zap;

    emit UpdateZap(_zap);
  }

  function updateReserveRate(uint256 _reserveRate) external onlyOwner {
    require(_reserveRate <= FEE_DENOMINATOR, "CLeverCVXLocker: invalid reserve rate");
    reserveRate = _reserveRate;
  }

  
  
  
  function withdrawManualSwapRewardTokens(address[] memory _tokens, address _recipient) external onlyOwner {
    for (uint256 i = 0; i < _tokens.length; i++) {
      if (!manualSwapRewardToken[_tokens[i]]) continue;
      uint256 _balance = IERC20Upgradeable(_tokens[i]).balanceOf(address(this));
      IERC20Upgradeable(_tokens[i]).safeTransfer(_recipient, _balance);
    }
  }

  
  
  
  function updateKeepers(address[] memory _accounts, bool _status) external onlyGovernorOrOwner {
    for (uint256 i = 0; i < _accounts.length; i++) {
      isKeeper[_accounts[i]] = _status;
    }
  }

   

  
  
  function _updateReward(address _account) internal {
    UserInfo storage _info = userInfo[_account];
    require(_info.lastInteractedBlock != block.number, "CLeverCVXLocker: enter the same block");

    uint256 _totalDebtGlobal = totalDebtGlobal;
    uint256 _totalDebt = _info.totalDebt;
    uint256 _rewards = uint256(_info.rewards).add(
      accRewardPerShare.sub(_info.rewardPerSharePaid).mul(_info.totalLocked) / PRECISION
    );

    _info.rewardPerSharePaid = uint192(accRewardPerShare);  
    _info.lastInteractedBlock = uint64(block.number);

     
    if (_totalDebt > 0) {
      if (_rewards >= _totalDebt) {
        _rewards -= _totalDebt;
        _totalDebtGlobal -= _totalDebt;
        _totalDebt = 0;
      } else {
        _totalDebtGlobal -= _rewards;
        _totalDebt -= _rewards;
        _rewards = 0;
      }
    }

    _info.totalDebt = uint128(_totalDebt);  
    _info.rewards = uint128(_rewards);  
    totalDebtGlobal = _totalDebtGlobal;
  }

  
  
  function _updateUnlocked(address _account) internal {
    UserInfo storage _info = userInfo[_account];
    uint256 _currentEpoch = block.timestamp / REWARDS_DURATION;
    uint256 _nextUnlockIndex = _info.nextUnlockIndex;
    uint256 _totalUnlocked = _info.totalUnlocked;
    EpochUnlockInfo[] storage _pendingUnlockList = _info.pendingUnlockList;

    uint256 _unlockEpoch;
    uint256 _unlockAmount;
    while (_nextUnlockIndex < _pendingUnlockList.length) {
      _unlockEpoch = _pendingUnlockList[_nextUnlockIndex].unlockEpoch;
      _unlockAmount = _pendingUnlockList[_nextUnlockIndex].pendingUnlock;
      if (_unlockEpoch <= _currentEpoch) {
        _totalUnlocked = _totalUnlocked + _unlockAmount;
        delete _pendingUnlockList[_nextUnlockIndex];  
      } else {
        break;
      }
      _nextUnlockIndex += 1;
    }
    _info.totalUnlocked = uint112(_totalUnlocked);
    _info.nextUnlockIndex = uint32(_nextUnlockIndex);
  }

  
  
  
  
  
  function _swapToCVX(
    address[] memory _rewardTokens,
    uint256[] memory _amounts,
    uint256 _minimumOut
  ) internal returns (uint256) {
    uint256 _amount;
    address _token;
    address _zap = zap;
    for (uint256 i = 0; i < _rewardTokens.length; i++) {
      _token = _rewardTokens[i];
       
      if (manualSwapRewardToken[_token]) continue;
      if (_token != CVX) {
        if (_amounts[i] > 0) {
          IERC20Upgradeable(_token).safeTransfer(_zap, _amounts[i]);
          _amount = _amount.add(IZap(_zap).zap(_token, _amounts[i], CVX, 0));
        }
      } else {
        _amount = _amount.add(_amounts[i]);
      }
    }
    require(_amount >= _minimumOut, "CLeverCVXLocker: insufficient output");
    return _amount;
  }

  
  function _distribute(uint256 _amount) internal {
     
    uint256 _totalLockedGlobal = totalLockedGlobal;  
     
    if (_totalLockedGlobal > 0) {
      accRewardPerShare = accRewardPerShare.add(_amount.mul(PRECISION) / uint256(_totalLockedGlobal));
    }

     
    address _furnace = furnace;
    IERC20Upgradeable(CVX).safeApprove(_furnace, 0);
    IERC20Upgradeable(CVX).safeApprove(_furnace, _amount);
    IFurnace(_furnace).distribute(address(this), _amount);

     
    uint256 _balanceStaked = IConvexCVXRewardPool(CVX_REWARD_POOL).balanceOf(address(this));
    uint256 _toStake = _balanceStaked.add(IERC20Upgradeable(CVX).balanceOf(address(this))).mul(stakePercentage).div(
      FEE_DENOMINATOR
    );
    if (_balanceStaked < _toStake) {
      _toStake = _toStake - _balanceStaked;
      if (_toStake >= stakeThreshold) {
        IERC20Upgradeable(CVX).safeApprove(CVX_REWARD_POOL, 0);
        IERC20Upgradeable(CVX).safeApprove(CVX_REWARD_POOL, _toStake);
        IConvexCVXRewardPool(CVX_REWARD_POOL).stake(_toStake);
      }
    }
  }

  
  
  
  function _mintOrDeposit(uint256 _amount, bool _depositToFurnace) internal {
    if (_depositToFurnace) {
      address _clevCVX = clevCVX;
      address _furnace = furnace;
       
      ICLeverToken(_clevCVX).mint(address(this), _amount);
      IERC20Upgradeable(_clevCVX).safeApprove(_furnace, 0);
      IERC20Upgradeable(_clevCVX).safeApprove(_furnace, _amount);
      IFurnace(_furnace).depositFor(msg.sender, _amount);
    } else {
       
      ICLeverToken(clevCVX).mint(msg.sender, _amount);
    }
  }

  
   
   
   
   
  
  
  
  
  function _checkAccountHealth(
    uint256 _totalDeposited,
    uint256 _totalDebt,
    uint256 _newUnlock,
    uint256 _newBorrow
  ) internal view {
    require(
      _totalDeposited.sub(_newUnlock).mul(reserveRate) >= _totalDebt.add(_newBorrow).mul(FEE_DENOMINATOR),
      "CLeverCVXLocker: unlock or borrow exceeds limit"
    );
  }
}

 

pragma solidity ^0.7.0;

 
interface IERC20Upgradeable {
     
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





 
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity ^0.7.6;



interface ICLeverToken is IERC20 {
  function mint(address _recipient, uint256 _amount) external;

  function burn(uint256 _amount) external;

  function burnFrom(address _account, uint256 _amount) external;
}

 

pragma solidity ^0.7.6;


interface IConvexCVXLocker {
  struct LockedBalance {
    uint112 amount;
    uint112 boosted;
    uint32 unlockTime;
  }

  function lockedBalanceOf(address _user) external view returns (uint256 amount);

   
  function lockedBalances(address _user)
    external
    view
    returns (
      uint256 total,
      uint256 unlockable,
      uint256 locked,
      LockedBalance[] memory lockData
    );

  function lock(
    address _account,
    uint256 _amount,
    uint256 _spendRatio
  ) external;

  function processExpiredLocks(
    bool _relock,
    uint256 _spendRatio,
    address _withdrawTo
  ) external;

  function processExpiredLocks(bool _relock) external;

  function kickExpiredLocks(address _account) external;

  function getReward(address _account, bool _stake) external;

  function getReward(address _account) external;
}

 

pragma solidity ^0.7.6;

interface IConvexCVXRewardPool {
  function balanceOf(address account) external view returns (uint256);

  function earned(address account) external view returns (uint256);

  function withdraw(uint256 _amount, bool claim) external;

  function withdrawAll(bool claim) external;

  function stake(uint256 _amount) external;

  function stakeAll() external;

  function stakeFor(address _for, uint256 _amount) external;

  function getReward(
    address _account,
    bool _claimExtras,
    bool _stake
  ) external;

  function getReward(bool _stake) external;
}

 

pragma solidity ^0.7.6;

interface IFurnace {
  event Deposit(address indexed _account, uint256 _amount);
  event Withdraw(address indexed _account, address _recipient, uint256 _amount);
  event Claim(address indexed _account, address _recipient, uint256 _amount);
  event Distribute(address indexed _origin, uint256 _amount);
  event Harvest(address indexed _caller, uint256 _amount);

  
  
  
  
  function getUserInfo(address _account) external view returns (uint256 unrealised, uint256 realised);

  
  
  function deposit(uint256 _amount) external;

  
  
  
  function depositFor(address _account, uint256 _amount) external;

  
  
  
  function withdraw(address _recipient, uint256 _amount) external;

  
  
  function withdrawAll(address _recipient) external;

  
  
  function claim(address _recipient) external;

  
  
  function exit(address _recipient) external;

  
  
  
  function distribute(address _origin, uint256 _amount) external;
}

 

pragma solidity ^0.7.6;

interface ISnapshotDelegateRegistry {
  function setDelegate(bytes32 id, address delegate) external;
}

 

pragma solidity ^0.7.6;

interface IZap {
  function zap(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256 _minOut
  ) external payable returns (uint256);
}

 

pragma solidity ^0.7.0;

 
library SafeMathUpgradeable {
     
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

 
library AddressUpgradeable {
     
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

 

pragma solidity ^0.7.6;


interface IVotiumMultiMerkleStash {
   
  struct claimParam {
    address token;
    uint256 index;
    uint256 amount;
    bytes32[] merkleProof;
  }

  function isClaimed(address token, uint256 index) external view returns (bool);

  function claim(
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external;

  function claimMulti(address account, claimParam[] calldata claims) external;
}
