 
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

 

pragma solidity ^0.7.6;

 

abstract contract FeeCustomization {
  
  
  
  
  event CustomizeFee(bytes32 _feeType, address _user, uint256 _rate);

  
  
  
  event CancleCustomizeFee(bytes32 _feeType, address _user);

  
  uint256 internal constant FEE_PRECISION = 1e9;

  
  bytes32 private constant SALT = keccak256("FeeCustomization");

  
  
  
  
  function getFeeRate(bytes32 _feeType, address _user) public view returns (uint256 rate) {
    rate = _defaultFeeRate(_feeType);

    (uint8 _customized, uint32 _rate) = _loadFeeCustomization(_feeType, _user);
    if (_customized == 1) {
      rate = _rate;
    }
  }

  
  
  
  
  function _setFeeCustomization(
    bytes32 _feeType,
    address _user,
    uint32 _rate
  ) internal {
    require(_rate <= FEE_PRECISION, "rate too large");

    uint256 _slot = _computeStorageSlot(_feeType, _user);
    uint256 _encoded = _encode(1, _rate);
    assembly {
      sstore(_slot, _encoded)
    }

    emit CustomizeFee(_feeType, _user, _rate);
  }

  
  
  
  function _cancleFeeCustomization(bytes32 _feeType, address _user) internal {
    uint256 _slot = _computeStorageSlot(_feeType, _user);
    assembly {
      sstore(_slot, 0)
    }

    emit CancleCustomizeFee(_feeType, _user);
  }

  
  
  
  function _defaultFeeRate(bytes32 _feeType) internal view virtual returns (uint256 rate);

  
  
  
  
  
  function _loadFeeCustomization(bytes32 _feeType, address _user) private view returns (uint8 customized, uint32 rate) {
    uint256 _slot = _computeStorageSlot(_feeType, _user);
    uint256 _encoded;
    assembly {
      _encoded := sload(_slot)
    }
    (customized, rate) = _decode(_encoded);
  }

  
  
  
  
  function _computeStorageSlot(bytes32 _feeType, address _user) private pure returns (uint256 slot) {
    bytes32 salt = SALT;
    assembly {
      mstore(0x00, _feeType)
      mstore(0x20, xor(_user, salt))
      slot := keccak256(0x00, 0x40)
    }
  }

  
   
   
   
   
  
  
  function _encode(uint8 customized, uint32 rate) private pure returns (uint256 encoded) {
    encoded = (uint256(rate) << 8) | uint256(customized);
  }

  
  
  
  
  function _decode(uint256 _encoded) private pure returns (uint8 customized, uint32 rate) {
    customized = uint8(_encoded & 0xff);
    rate = uint32((_encoded >> 8) & 0xffffffff);
  }
}

 

pragma solidity ^0.7.6;

interface IConcentratorGeneralVault {
  
  
  
  
  
  event Approval(uint256 indexed pid, address indexed owner, address indexed spender, uint256 value);

  
  
  
  
  
  
  event Deposit(
    uint256 indexed pid,
    address indexed sender,
    address indexed recipient,
    uint256 assetsIn,
    uint256 sharesOut
  );

  
  
  
  
  
  
  
  event Withdraw(
    uint256 indexed pid,
    address indexed sender,
    address indexed owner,
    address recipient,
    uint256 sharesIn,
    uint256 assetsOut
  );

  
  
  
  
  
  event Claim(uint256 indexed pid, address indexed sender, address indexed recipient, uint256 rewards);

  
  
  
  
  
  
  
  event Harvest(
    uint256 indexed pid,
    address indexed caller,
    address indexed recipient,
    uint256 rewards,
    uint256 platformFee,
    uint256 harvestBounty
  );

  
  function rewardToken() external view returns (address);

  
  
  
  function pendingReward(uint256 pid, address account) external view returns (uint256);

  
  
  function pendingRewardAll(address account) external view returns (uint256);

  
  
  
  function getUserShare(uint256 pid, address account) external view returns (uint256);

  
  
  function underlying(uint256 pid) external view returns (address);

  
  
  function getTotalUnderlying(uint256 pid) external view returns (uint256);

  
  
  function getTotalShare(uint256 pid) external view returns (uint256);

  
  
  
  
  function allowance(
    uint256 pid,
    address owner,
    address spender
  ) external view returns (uint256);

  
  
  
  
  function approve(
    uint256 pid,
    address spender,
    uint256 amount
  ) external;

  
  
  
  
  
  function deposit(
    uint256 pid,
    address recipient,
    uint256 assets
  ) external returns (uint256 share);

  
  
  
  
  
  
  function withdraw(
    uint256 pid,
    uint256 shares,
    address recipient,
    address owner
  ) external returns (uint256 assets);

  
  
  
  
  
  
  function claim(
    uint256 pid,
    address recipient,
    uint256 minOut,
    address claimAsToken
  ) external returns (uint256 claimed);

  
  
  
  
  
  
  function claimMulti(
    uint256[] memory pids,
    address recipient,
    uint256 minOut,
    address claimAsToken
  ) external returns (uint256 claimed);

  
  
  
  
  
  function claimAll(
    uint256 minOut,
    address recipient,
    address claimAsToken
  ) external returns (uint256 claimed);

  
  
  
  
  
  function harvest(
    uint256 pid,
    address recipient,
    uint256 minOut
  ) external returns (uint256 harvested);
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

 

pragma solidity ^0.7.0;


 
abstract contract ReentrancyGuardUpgradeable is Initializable {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

 

pragma solidity ^0.7.6;













 
 
 

abstract contract ConcentratorGeneralVault is
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  FeeCustomization,
  IConcentratorGeneralVault
{
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  
  
  
  
  
  event UpdatePoolFeeRatio(
    uint256 indexed _pid,
    uint32 _withdrawFeeRatio,
    uint32 _platformFeeRatio,
    uint32 _harvestBountyRatio
  );

  
  
  event UpdatePlatform(address indexed _platform);

  
  
  event UpdateZap(address indexed _zap);

  
  
  
  
  event Migrate(uint256 indexed _pid, address _oldStrategy, address _newStrategy);

  
  
  
  event UpdateRewardPeriod(uint256 indexed _pid, uint32 _period);

  
  
  
  event UpdatePoolRewardTokens(uint256 indexed _pid, address[] _rewardTokens);

  
  
  
  
  event AddPool(uint256 indexed _pid, address _underlying, address _strategy);

  
  
  
  event PausePoolDeposit(uint256 indexed _pid, bool _status);

  
  
  
  event PausePoolWithdraw(uint256 indexed _pid, bool _status);

  
  struct PoolRewardInfo {
     
    uint128 rate;
     
     
    uint32 periodLength;
     
    uint48 lastUpdate;
     
    uint48 finishAt;
     
    uint256 accRewardPerShare;
  }

  
  struct PoolSupplyInfo {
     
    uint128 totalUnderlying;
     
    uint128 totalShare;
  }

  
  struct PoolFeeInfo {
     
    uint32 withdrawFeeRatio;
     
    uint32 platformFeeRatio;
     
    uint32 harvestBountyRatio;
     
    uint160 reserved;
  }

  
  struct PoolStrategyInfo {
     
    address token;
     
    address strategy;
     
    bool pauseDeposit;
     
    bool pauseWithdraw;
  }

  struct PoolInfo {
    PoolSupplyInfo supply;  
    PoolStrategyInfo strategy;  
    PoolRewardInfo reward;  
    PoolFeeInfo fee;  
  }

  struct UserInfo {
     
    uint128 shares;
     
    uint128 rewards;
     
    uint256 rewardPerSharePaid;
     
    mapping(address => uint256) allowances;
  }

  
  bytes32 internal constant WITHDRAW_FEE_TYPE = keccak256("ConcentratorGeneralVault.WithdrawFee");

  
  uint256 internal constant REWARD_PRECISION = 1e18;

  
  uint256 internal constant MAX_WITHDRAW_FEE = 1e8;  

  
  uint256 internal constant MAX_PLATFORM_FEE = 2e8;  

  
  uint256 internal constant MAX_HARVEST_BOUNTY = 1e8;  

  
  uint256 internal constant WEEK = 86400 * 7;

  
  mapping(uint256 => PoolInfo) public poolInfo;

  
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;

  
  uint256 private poolIndex;

  
  address public platform;

  
  address public zap;

  
  uint256[45] private __gap;

  modifier onlyExistPool(uint256 _pid) {
    require(_pid < poolIndex, "Concentrator: pool not exist");
    _;
  }

   
  receive() external payable {}

  function _initialize(address _zap, address _platform) internal {
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

    require(_zap != address(0), "Concentrator: zero zap address");
    require(_platform != address(0), "Concentrator: zero platform address");

    platform = _platform;
    zap = _zap;
  }

   

  
  function rewardToken() public view virtual override returns (address) {}

  
  function poolLength() external view returns (uint256 pools) {
    pools = poolIndex;
  }

  
  function pendingReward(uint256 _pid, address _account) public view override returns (uint256) {
    PoolInfo storage _pool = poolInfo[_pid];
    PoolRewardInfo memory _reward = _pool.reward;
    PoolSupplyInfo memory _supply = _pool.supply;

    if (_reward.periodLength > 0) {
      uint256 _currentTime = _reward.finishAt;
      if (_currentTime > block.timestamp) _currentTime = block.timestamp;
      uint256 _duration = _currentTime >= _reward.lastUpdate ? _currentTime - _reward.lastUpdate : 0;
      if (_duration > 0 && _supply.totalShare > 0) {
        _reward.accRewardPerShare = _reward.accRewardPerShare.add(
          _duration.mul(_reward.rate).mul(REWARD_PRECISION) / _supply.totalShare
        );
      }
    }

    return _pendingReward(_pid, _account, _reward.accRewardPerShare);
  }

  
  function pendingRewardAll(address _account) external view override returns (uint256) {
    uint256 _length = poolIndex;
    uint256 _pending;
    for (uint256 i = 0; i < _length; i++) {
      _pending += pendingReward(i, _account);
    }
    return _pending;
  }

  
  function getUserShare(uint256 _pid, address _account) external view override returns (uint256) {
    return userInfo[_pid][_account].shares;
  }

  
  function underlying(uint256 _pid) external view override returns (address) {
    return poolInfo[_pid].strategy.token;
  }

  
  function getTotalUnderlying(uint256 _pid) external view override returns (uint256) {
    return poolInfo[_pid].supply.totalUnderlying;
  }

  
  function getTotalShare(uint256 _pid) external view override returns (uint256) {
    return poolInfo[_pid].supply.totalShare;
  }

  
  function allowance(
    uint256 _pid,
    address _owner,
    address _spender
  ) external view override returns (uint256) {
    UserInfo storage _info = userInfo[_pid][_owner];
    return _info.allowances[_spender];
  }

   

  
  function approve(
    uint256 _pid,
    address _spender,
    uint256 _amount
  ) external override {
    _approve(_pid, msg.sender, _spender, _amount);
  }

  
  function deposit(
    uint256 _pid,
    address _recipient,
    uint256 _assetsIn
  ) public override onlyExistPool(_pid) nonReentrant returns (uint256) {
    PoolStrategyInfo memory _strategy = poolInfo[_pid].strategy;
    require(!_strategy.pauseDeposit, "Concentrator: deposit paused");

    if (_assetsIn == uint256(-1)) {
      _assetsIn = IERC20Upgradeable(_strategy.token).balanceOf(msg.sender);
    }
    require(_assetsIn > 0, "Concentrator: deposit zero amount");

     
    _updateRewards(_pid, _recipient);

     
    uint256 _before = IERC20Upgradeable(_strategy.token).balanceOf(_strategy.strategy);
    IERC20Upgradeable(_strategy.token).safeTransferFrom(msg.sender, _strategy.strategy, _assetsIn);
    _assetsIn = IERC20Upgradeable(_strategy.token).balanceOf(_strategy.strategy) - _before;

     
    return _deposit(_pid, _recipient, _assetsIn);
  }

  
  function withdraw(
    uint256 _pid,
    uint256 _sharesIn,
    address _recipient,
    address _owner
  ) public override onlyExistPool(_pid) nonReentrant returns (uint256) {
    if (_sharesIn == uint256(-1)) {
      _sharesIn = userInfo[_pid][_owner].shares;
    }
    require(_sharesIn > 0, "Concentrator: withdraw zero share");

    if (msg.sender != _owner) {
      UserInfo storage _info = userInfo[_pid][_owner];
      uint256 _allowance = _info.allowances[msg.sender];
      require(_allowance >= _sharesIn, "Concentrator: withdraw exceeds allowance");
      if (_allowance != uint256(-1)) {
         
        _approve(_pid, _owner, msg.sender, _allowance - _sharesIn);
      }
    }

     
    PoolInfo storage _pool = poolInfo[_pid];
    require(!_pool.strategy.pauseWithdraw, "Concentrator: withdraw paused");
    _updateRewards(_pid, _owner);

     
    return _withdraw(_pid, _sharesIn, _owner, _recipient);
  }

  
  function claim(
    uint256 _pid,
    address _recipient,
    uint256 _minOut,
    address _claimAsToken
  ) public override onlyExistPool(_pid) nonReentrant returns (uint256) {
    _updateRewards(_pid, msg.sender);

    UserInfo storage _userInfo = userInfo[_pid][msg.sender];
    uint256 _rewards = _userInfo.rewards;
    _userInfo.rewards = 0;

    emit Claim(_pid, msg.sender, _recipient, _rewards);

    _rewards = _claim(_rewards, _minOut, _recipient, _claimAsToken);
    return _rewards;
  }

  
  function claimMulti(
    uint256[] memory _pids,
    address _recipient,
    uint256 _minOut,
    address _claimAsToken
  ) public override nonReentrant returns (uint256) {
    uint256 _poolIndex = poolIndex;
    uint256 _rewards;
    for (uint256 i = 0; i < _pids.length; i++) {
      uint256 _pid = _pids[i];
      require(_pid < _poolIndex, "Concentrator: pool not exist");

      UserInfo storage _userInfo = userInfo[_pid][msg.sender];
       
      if (_userInfo.shares > 0) {
        _updateRewards(_pid, msg.sender);
      }
       
      if (_userInfo.rewards > 0) {
        _rewards = _rewards.add(_userInfo.rewards);
        emit Claim(_pid, msg.sender, _recipient, _userInfo.rewards);

        _userInfo.rewards = 0;
      }
    }

    return _claim(_rewards, _minOut, _recipient, _claimAsToken);
  }

  
  function claimAll(
    uint256 _minOut,
    address _recipient,
    address _claimAsToken
  ) external override nonReentrant returns (uint256) {
    uint256 _length = poolIndex;
    uint256 _rewards;
    for (uint256 _pid = 0; _pid < _length; _pid++) {
      UserInfo storage _userInfo = userInfo[_pid][msg.sender];
       
      if (_userInfo.shares > 0) {
        _updateRewards(_pid, msg.sender);
      }
       
      if (_userInfo.rewards > 0) {
        _rewards = _rewards.add(_userInfo.rewards);
        emit Claim(_pid, msg.sender, _recipient, _userInfo.rewards);

        _userInfo.rewards = 0;
      }
    }

    return _claim(_rewards, _minOut, _recipient, _claimAsToken);
  }

  
  function harvest(
    uint256 _pid,
    address _recipient,
    uint256 _minOut
  ) external virtual override onlyExistPool(_pid) nonReentrant returns (uint256) {
     
    _updateRewards(_pid, address(0));

     
    uint256 _rewards = _harvest(_pid);
    require(_rewards >= _minOut, "Concentrator: insufficient rewards");

     
    address _token = rewardToken();
    PoolFeeInfo memory _fees = poolInfo[_pid].fee;
    uint256 _platformFee;
    uint256 _harvestBounty;
    if (_fees.platformFeeRatio > 0) {
      _platformFee = (uint256(_fees.platformFeeRatio) * _rewards) / FEE_PRECISION;
      IERC20Upgradeable(_token).safeTransfer(platform, _platformFee);
    }
    if (_fees.harvestBountyRatio > 0) {
      _harvestBounty = (uint256(_fees.harvestBountyRatio) * _rewards) / FEE_PRECISION;
      IERC20Upgradeable(_token).safeTransfer(_recipient, _harvestBounty);
    }

    emit Harvest(_pid, msg.sender, _recipient, _rewards, _platformFee, _harvestBounty);

     
    _notifyHarvestedReward(_pid, _rewards - _platformFee - _harvestBounty);

    return _rewards;
  }

  
  
  
  function checkpoint(uint256 _pid, address _account) external {
    _updateRewards(_pid, _account);
  }

   

  
  
  
  
  
  function updatePoolFeeRatio(
    uint256 _pid,
    uint32 _withdrawFeeRatio,
    uint32 _platformFeeRatio,
    uint32 _harvestBountyRatio
  ) external onlyExistPool(_pid) onlyOwner {
    require(_withdrawFeeRatio <= MAX_WITHDRAW_FEE, "Concentrator: withdraw fee too large");
    require(_platformFeeRatio <= MAX_PLATFORM_FEE, "Concentrator: platform fee too large");
    require(_harvestBountyRatio <= MAX_HARVEST_BOUNTY, "Concentrator: harvest bounty too large");

    poolInfo[_pid].fee = PoolFeeInfo({
      withdrawFeeRatio: _withdrawFeeRatio,
      platformFeeRatio: _platformFeeRatio,
      harvestBountyRatio: _harvestBountyRatio,
      reserved: 0
    });

    emit UpdatePoolFeeRatio(_pid, _withdrawFeeRatio, _platformFeeRatio, _harvestBountyRatio);
  }

  
  
  
  
  function setWithdrawFeeForUser(
    uint256 _pid,
    address _user,
    uint32 _ratio
  ) external onlyExistPool(_pid) onlyOwner {
    require(_ratio <= MAX_WITHDRAW_FEE, "Concentrator: withdraw fee too large");

    _setFeeCustomization(_getWithdrawFeeType(_pid), _user, _ratio);
  }

  
  
  function updatePlatform(address _platform) external onlyOwner {
    require(_platform != address(0), "Concentrator: zero platform address");
    platform = _platform;

    emit UpdatePlatform(_platform);
  }

  
  function updateZap(address _zap) external onlyOwner {
    require(_zap != address(0), "Concentrator: zero zap address");
    zap = _zap;

    emit UpdateZap(_zap);
  }

  
  
  
  
  
  
  function addPool(
    address _underlying,
    address _strategy,
    uint32 _withdrawFeeRatio,
    uint32 _platformFeeRatio,
    uint32 _harvestBountyRatio
  ) external onlyOwner {
    require(_withdrawFeeRatio <= MAX_WITHDRAW_FEE, "Concentrator: withdraw fee too large");
    require(_platformFeeRatio <= MAX_PLATFORM_FEE, "Concentrator: platform fee too large");
    require(_harvestBountyRatio <= MAX_HARVEST_BOUNTY, "Concentrator: harvest bounty too large");

    uint256 _pid = poolIndex;
    poolIndex = _pid + 1;

    poolInfo[_pid].strategy = PoolStrategyInfo({
      token: _underlying,
      strategy: _strategy,
      pauseDeposit: false,
      pauseWithdraw: false
    });

    poolInfo[_pid].fee = PoolFeeInfo({
      withdrawFeeRatio: _withdrawFeeRatio,
      platformFeeRatio: _platformFeeRatio,
      harvestBountyRatio: _harvestBountyRatio,
      reserved: 0
    });

    emit AddPool(_pid, _underlying, _strategy);
  }

  
  
  
  function updateRewardPeriod(uint256 _pid, uint32 _period) external onlyExistPool(_pid) onlyOwner {
    require(_period <= WEEK, "Concentrator: reward period too long");

    poolInfo[_pid].reward.periodLength = _period;

    emit UpdateRewardPeriod(_pid, _period);
  }

  
  
  
  function updatePoolRewardTokens(uint256 _pid, address[] memory _rewardTokens) external onlyExistPool(_pid) onlyOwner {
    IConcentratorStrategy(poolInfo[_pid].strategy.strategy).updateRewards(_rewardTokens);

    emit UpdatePoolRewardTokens(_pid, _rewardTokens);
  }

  
  
  
  function pausePoolWithdraw(uint256 _pid, bool _status) external onlyExistPool(_pid) onlyOwner {
    poolInfo[_pid].strategy.pauseWithdraw = _status;

    emit PausePoolWithdraw(_pid, _status);
  }

  
  
  
  function pausePoolDeposit(uint256 _pid, bool _status) external onlyExistPool(_pid) onlyOwner {
    poolInfo[_pid].strategy.pauseDeposit = _status;

    emit PausePoolDeposit(_pid, _status);
  }

  
  
  
  function migrateStrategy(uint256 _pid, address _newStrategy) external onlyExistPool(_pid) onlyOwner {
    uint256 _totalUnderlying = poolInfo[_pid].supply.totalUnderlying;
    address _oldStrategy = poolInfo[_pid].strategy.strategy;
    poolInfo[_pid].strategy.strategy = _newStrategy;

    IConcentratorStrategy(_oldStrategy).prepareMigrate(_newStrategy);
    IConcentratorStrategy(_oldStrategy).withdraw(_newStrategy, _totalUnderlying);
    IConcentratorStrategy(_oldStrategy).finishMigrate(_newStrategy);
    IConcentratorStrategy(_newStrategy).deposit(address(this), _totalUnderlying);

    emit Migrate(_pid, _oldStrategy, _newStrategy);
  }

   

  
  
  
  
  function _pendingReward(
    uint256 _pid,
    address _account,
    uint256 _accRewardPerShare
  ) internal view returns (uint256) {
    UserInfo storage _userInfo = userInfo[_pid][_account];
    return
      uint256(_userInfo.rewards).add(
        _accRewardPerShare.sub(_userInfo.rewardPerSharePaid).mul(_userInfo.shares) / REWARD_PRECISION
      );
  }

  
  
  
  function _updateRewards(uint256 _pid, address _account) internal virtual {
    PoolInfo storage _pool = poolInfo[_pid];

     
    PoolRewardInfo memory _poolRewardInfo = _pool.reward;
    PoolSupplyInfo memory _supply = _pool.supply;
    if (_poolRewardInfo.periodLength > 0) {
      uint256 _currentTime = _poolRewardInfo.finishAt;
      if (_currentTime > block.timestamp) {
        _currentTime = block.timestamp;
      }
      uint256 _duration = _currentTime >= _poolRewardInfo.lastUpdate ? _currentTime - _poolRewardInfo.lastUpdate : 0;
      if (_duration > 0) {
        _poolRewardInfo.lastUpdate = uint48(block.timestamp);
        if (_supply.totalShare > 0) {
          _poolRewardInfo.accRewardPerShare = _poolRewardInfo.accRewardPerShare.add(
            _duration.mul(_poolRewardInfo.rate).mul(REWARD_PRECISION) / _supply.totalShare
          );
        }

        _pool.reward = _poolRewardInfo;
      }
    }

     
    if (_account != address(0)) {
      uint256 _rewards = _pendingReward(_pid, _account, _poolRewardInfo.accRewardPerShare);
      UserInfo storage _userInfo = userInfo[_pid][_account];

      _userInfo.rewards = SafeCastUpgradeable.toUint128(_rewards);
      _userInfo.rewardPerSharePaid = _poolRewardInfo.accRewardPerShare;
    }
  }

  
  
  
  
  
  function _deposit(
    uint256 _pid,
    address _recipient,
    uint256 _assetsIn
  ) internal returns (uint256) {
    PoolInfo storage _pool = poolInfo[_pid];

    IConcentratorStrategy(_pool.strategy.strategy).deposit(_recipient, _assetsIn);

    PoolSupplyInfo memory _supply = _pool.supply;
    uint256 _sharesOut;
    if (_supply.totalShare == 0) {
      _sharesOut = _assetsIn;
    } else {
      _sharesOut = _assetsIn.mul(_supply.totalShare) / _supply.totalUnderlying;
    }
    _supply.totalShare = _supply.totalShare + uint128(_sharesOut);
    _supply.totalUnderlying = _supply.totalUnderlying + uint128(_assetsIn);
    _pool.supply = _supply;

    UserInfo storage _userInfo = userInfo[_pid][_recipient];
    _userInfo.shares = uint128(_sharesOut + _userInfo.shares);

    emit Deposit(_pid, msg.sender, _recipient, _assetsIn, _sharesOut);
    return _sharesOut;
  }

  
  
  
  
  
  
  function _withdraw(
    uint256 _pid,
    uint256 _sharesIn,
    address _owner,
    address _recipient
  ) internal returns (uint256) {
    PoolInfo storage _pool = poolInfo[_pid];

     
    UserInfo storage _userInfo = userInfo[_pid][_owner];
    require(_sharesIn <= _userInfo.shares, "Concentrator: exceed user shares");

    PoolSupplyInfo memory _supply = _pool.supply;
    uint256 _assetsOut;
    if (_sharesIn == _supply.totalShare) {
       
       
       
      _assetsOut = _supply.totalUnderlying;
    } else {
      uint256 _withdrawFeeRatio = getFeeRate(_getWithdrawFeeType(_pid), _owner);
       
      _assetsOut = _sharesIn.mul(_supply.totalUnderlying) / _supply.totalShare;
      uint256 _fee = _assetsOut.mul(_withdrawFeeRatio) / FEE_PRECISION;
      _assetsOut = _assetsOut - _fee;  
    }

    _supply.totalShare = _supply.totalShare - uint128(_sharesIn);
    _supply.totalUnderlying = _supply.totalUnderlying - uint128(_assetsOut);
    _pool.supply = _supply;

    _userInfo.shares = _userInfo.shares - uint128(_sharesIn);

    IConcentratorStrategy(_pool.strategy.strategy).withdraw(_recipient, _assetsOut);

    emit Withdraw(_pid, msg.sender, _owner, _recipient, _sharesIn, _assetsOut);

    return _assetsOut;
  }

  
  
  
  
  
  function _approve(
    uint256 _pid,
    address _owner,
    address _spender,
    uint256 _amount
  ) internal {
    require(_owner != address(0), "Concentrator: approve from the zero address");
    require(_spender != address(0), "Concentrator: approve to the zero address");

    UserInfo storage _info = userInfo[_pid][_owner];
    _info.allowances[_spender] = _amount;
    emit Approval(_pid, _owner, _spender, _amount);
  }

  
  
  
  
  function _notifyHarvestedReward(uint256 _pid, uint256 _amount) internal virtual {
    require(_amount < uint128(-1), "Concentrator: harvested amount overflow");
    PoolRewardInfo memory _info = poolInfo[_pid].reward;

    if (_info.periodLength == 0) {
      _info.accRewardPerShare = _info.accRewardPerShare.add(
        _amount.mul(REWARD_PRECISION) / poolInfo[_pid].supply.totalShare
      );
    } else {
      if (block.timestamp >= _info.finishAt) {
        _info.rate = uint128(_amount / _info.periodLength);
      } else {
        uint256 _remaining = _info.finishAt - block.timestamp;
        uint256 _leftover = _remaining * _info.rate;
        _info.rate = uint128((_amount + _leftover) / _info.periodLength);
      }

      _info.lastUpdate = uint48(block.timestamp);
      _info.finishAt = uint48(block.timestamp + _info.periodLength);
    }

    poolInfo[_pid].reward = _info;
  }

  
  
  function _getWithdrawFeeType(uint256 _pid) internal pure returns (bytes32) {
    return bytes32(uint256(WITHDRAW_FEE_TYPE) + _pid);
  }

  
  function _defaultFeeRate(bytes32 _feeType) internal view override returns (uint256 rate) {
    uint256 _pid = uint256(_feeType) - uint256(WITHDRAW_FEE_TYPE);
    rate = poolInfo[_pid].fee.withdrawFeeRatio;
  }

  
  
  
  
  
  
  function _claim(
    uint256 _amount,
    uint256 _minOut,
    address _recipient,
    address _claimAsToken
  ) internal virtual returns (uint256) {}

  
  
  
  function _harvest(uint256 _pid) internal virtual returns (uint256) {}
}
 

pragma solidity ^0.7.6;









 

contract ConcentratorAladdinETHVault is ConcentratorGeneralVault {
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  
  address private aladdinETH;

  
  address private aladdinETHUnderlying;

  function initialize(
    address _aladdinETH,
    address _zap,
    address _platform
  ) external initializer {
    require(_aladdinETH != address(0), "Concentrator: zero aladdinETH address");
    ConcentratorGeneralVault._initialize(_zap, _platform);

    address _aladdinETHUnderlying = IAladdinCompounder(_aladdinETH).asset();
    IERC20Upgradeable(_aladdinETHUnderlying).safeApprove(_aladdinETH, uint256(-1));

    aladdinETH = _aladdinETH;
    aladdinETHUnderlying = _aladdinETHUnderlying;
  }

   

  
  function rewardToken() public view virtual override returns (address) {
    return aladdinETH;
  }

   

  
  function _claim(
    uint256 _amount,
    uint256 _minOut,
    address _recipient,
    address _claimAsToken
  ) internal virtual override returns (uint256) {
    address _aladdinETH = aladdinETH;
    uint256 _amountOut;
    if (_claimAsToken == _aladdinETH) {
      _amountOut = _amount;
    } else {
      _amountOut = IAladdinCompounder(_aladdinETH).redeem(_amount, address(this), address(this));
      address _aladdinETHUnderlying = aladdinETHUnderlying;
      if (_claimAsToken != _aladdinETHUnderlying) {
        address _zap = zap;
        IERC20Upgradeable(_aladdinETHUnderlying).safeTransfer(_zap, _amountOut);
        _amountOut = IZap(_zap).zap(_aladdinETHUnderlying, _amountOut, _claimAsToken, 0);
      }
    }

    require(_amountOut >= _minOut, "Concentrator: insufficient rewards");

    if (_claimAsToken == address(0)) {
       
      (bool _success, ) = msg.sender.call{ value: _amount }("");
      require(_success, "Concentrator: transfer ETH failed");
    } else {
      IERC20Upgradeable(_claimAsToken).safeTransfer(_recipient, _amountOut);
    }

    return _amountOut;
  }

  
  function _harvest(uint256 _pid) internal virtual override returns (uint256) {
    address _strategy = poolInfo[_pid].strategy.strategy;
    address _zap = zap;
    uint256 _amountETH = IConcentratorStrategy(_strategy).harvest(_zap, address(0));

    uint256 _amount = IZap(_zap).zap{ value: _amountETH }(address(0), _amountETH, aladdinETHUnderlying, 0);

    return IAladdinCompounder(aladdinETH).deposit(_amount, address(this));
  }
}

 

pragma solidity ^0.7.6;

interface IZap {
  function zap(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256 _minOut
  ) external payable returns (uint256);

  function zapWithRoutes(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256[] calldata _routes,
    uint256 _minOut
  ) external payable returns (uint256);

  function zapFrom(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256 _minOut
  ) external payable returns (uint256);
}

 

pragma solidity ^0.7.6;



interface IAladdinCompounder {
  
  
  
  
  
  
  event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

  
  
  
  
  
  
  
  event Withdraw(
    address indexed sender,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares
  );

  
  
  
  
  
  
  event Harvest(
    address indexed caller,
    address indexed recipient,
    uint256 assets,
    uint256 platformFee,
    uint256 harvestBounty
  );

  
  
  function asset() external view returns (address assetTokenAddress);

  
  
  function totalAssets() external view returns (uint256 totalManagedAssets);

  
  
  
  function convertToShares(uint256 assets) external view returns (uint256 shares);

  
  
  
  function convertToAssets(uint256 shares) external view returns (uint256 assets);

  
  
  
  function maxDeposit(address receiver) external view returns (uint256 maxAssets);

  
  
  
  function previewDeposit(uint256 assets) external view returns (uint256 shares);

  
  
  
  
  
  function deposit(uint256 assets, address receiver) external returns (uint256 shares);

  
  
  
  function maxMint(address receiver) external view returns (uint256 maxShares);

  
  
  
  function previewMint(uint256 shares) external view returns (uint256 assets);

  
  
  
  
  
  function mint(uint256 shares, address receiver) external returns (uint256 assets);

  
  
  
  function maxWithdraw(address owner) external view returns (uint256 maxAssets);

  
  
  
  function previewWithdraw(uint256 assets) external view returns (uint256 shares);

  
  
  
  
  
  
  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  ) external returns (uint256 shares);

  
  
  
  function maxRedeem(address owner) external view returns (uint256 maxShares);

  
  
  
  function previewRedeem(uint256 shares) external view returns (uint256 assets);

  
  
  
  
  
  
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) external returns (uint256 assets);

  
  
  
  
  function harvest(address recipient, uint256 minAssets) external returns (uint256 assets);
}

 

pragma solidity ^0.7.6;

 


 
 
 
 
 
 
interface ICurveETHPool {
  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external payable returns (uint256);

  function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 i,
    uint256 _min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external payable returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);

  function lp_token() external view returns (address);
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

 

pragma solidity ^0.7.6;

interface IConcentratorStrategy {
  
  function name() external view returns (string memory);

  
  
  function updateRewards(address[] memory _rewards) external;

  
  
   
   
   
  
  
  function deposit(address _recipient, uint256 _amount) external;

  
  
   
   
  
  
  function withdraw(address _recipient, uint256 _amount) external;

  
   
  
  
  
  function harvest(address _zapper, address _intermediate) external returns (uint256 amount);

  
  
   
   
  
  
  
  function execute(
    address _to,
    uint256 _value,
    bytes calldata _data
  ) external payable returns (bool, bytes memory);

  
  
  function prepareMigrate(address _newStrategy) external;

  
  
  function finishMigrate(address _newStrategy) external;
}

 

pragma solidity ^0.7.0;


 
library SafeCastUpgradeable {

     
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

     
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

     
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

     
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

     
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

     
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

     
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

     
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

     
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

     
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

     
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

     
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
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