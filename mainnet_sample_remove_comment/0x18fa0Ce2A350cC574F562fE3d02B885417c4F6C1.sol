 


 

 
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










 

contract Furnace is OwnableUpgradeable, IFurnace {
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  event UpdateWhitelist(address indexed _whitelist, bool _status);
  event UpdateStakePercentage(uint256 _percentage);
  event UpdateStakeThreshold(uint256 _threshold);
  event UpdatePlatformFeePercentage(uint256 _feePercentage);
  event UpdateHarvestBountyPercentage(uint256 _percentage);
  event UpdatePlatform(address indexed _platform);
  event UpdateZap(address indexed _zap);
  event UpdateGovernor(address indexed _governor);
  event UpdatePeriodLength(uint256 _length);

  uint256 private constant E128 = 2**128;
  uint256 private constant FEE_PRECISION = 1e9;
  uint256 private constant MAX_PLATFORM_FEE = 2e8;  
  uint256 private constant MAX_HARVEST_BOUNTY = 1e8;  

  address private constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
   
  address private constant CVXCRV = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
  address private constant CVX_REWARD_POOL = 0xCF50b810E57Ac33B91dCF525C6ddd9881B139332;

  
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
  struct UserInfo {
     
    uint128 unrealised;
     
    uint128 realised;
     
    uint192 accUnrealisedFractionPaid;
     
    uint64 lastDistributeIndex;
  }

  
  address public governor;
  
  address public clevCVX;
  
  uint128 public totalUnrealised;
  
  uint128 public totalRealised;
  
  uint128 public accUnrealisedFraction;
  
  uint64 public distributeIndex;
  
  uint64 public lastPaidOffDistributeIndex;
  
  mapping(address => UserInfo) public userInfo;
  
  mapping(address => bool) public isWhitelisted;
  
  uint256 public stakePercentage;
  
  uint256 public stakeThreshold;

  
  address public zap;
  
  uint256 public platformFeePercentage;
  
  uint256 public harvestBountyPercentage;
  
  address public platform;

  
  struct LinearReward {
     
    uint128 ratePerSecond;
     
     
    uint32 periodLength;
     
    uint48 lastUpdate;
     
    uint48 finishAt;
  }

  
  LinearReward public rewardInfo;

  modifier onlyWhitelisted() {
    require(isWhitelisted[msg.sender], "Furnace: only whitelisted");
    _;
  }

  modifier onlyGovernorOrOwner() {
    require(msg.sender == governor || msg.sender == owner(), "Furnace: only governor or owner");
    _;
  }

  function initialize(
    address _governor,
    address _clevCVX,
    address _zap,
    address _platform,
    uint256 _platformFeePercentage,
    uint256 _harvestBountyPercentage
  ) external initializer {
    OwnableUpgradeable.__Ownable_init();

    require(_governor != address(0), "Furnace: zero governor address");
    require(_clevCVX != address(0), "Furnace: zero clevCVX address");
    require(_zap != address(0), "Furnace: zero zap address");
    require(_platform != address(0), "Furnace: zero platform address");
    require(_platformFeePercentage <= MAX_PLATFORM_FEE, "Furnace: fee too large");
    require(_harvestBountyPercentage <= MAX_HARVEST_BOUNTY, "Furnace: fee too large");

    governor = _governor;
    clevCVX = _clevCVX;
    zap = _zap;
    platform = _platform;
    platformFeePercentage = _platformFeePercentage;
    harvestBountyPercentage = _harvestBountyPercentage;
  }

   

  
  
  
  
  function getUserInfo(address _account) external view override returns (uint256 unrealised, uint256 realised) {
    UserInfo memory _info = userInfo[_account];
    if (_info.lastDistributeIndex < lastPaidOffDistributeIndex) {
       
      return (0, _info.unrealised + _info.realised);
    } else {
       
      uint128 _newUnrealised = _toU128(
        _muldiv128(_info.unrealised, accUnrealisedFraction, uint128(_info.accUnrealisedFractionPaid))
      ) + 1;
      if (_newUnrealised >= _info.unrealised) {
        _newUnrealised = _info.unrealised;
      }
      uint128 _newRealised = _info.unrealised - _newUnrealised + _info.realised;  
      return (_newUnrealised, _newRealised);
    }
  }

  
  
  function totalCVXInPool() public view returns (uint256) {
    LinearReward memory _info = rewardInfo;
    uint256 _leftover = 0;
    if (_info.periodLength != 0) {
      if (block.timestamp < _info.finishAt) {
        _leftover = (_info.finishAt - block.timestamp) * _info.ratePerSecond;
      }
    }
    return
      IERC20Upgradeable(CVX)
        .balanceOf(address(this))
        .add(IConvexCVXRewardPool(CVX_REWARD_POOL).balanceOf(address(this)))
        .sub(_leftover);
  }

   

  
  
  function deposit(uint256 _amount) external override {
    require(_amount > 0, "Furnace: deposit zero clevCVX");

     
    IERC20Upgradeable(clevCVX).safeTransferFrom(msg.sender, address(this), _amount);

    _deposit(msg.sender, _amount);
  }

  
  
  
  function depositFor(address _account, uint256 _amount) external override {
    require(_amount > 0, "Furnace: deposit zero clevCVX");

     
    IERC20Upgradeable(clevCVX).safeTransferFrom(msg.sender, address(this), _amount);

    _deposit(_account, _amount);
  }

  
  
  
  function withdraw(address _recipient, uint256 _amount) external override {
    require(_amount > 0, "Furnace: withdraw zero CVX");

    _updateUserInfo(msg.sender);
    _withdraw(_recipient, _amount);
  }

  
  
  function withdrawAll(address _recipient) external override {
    _updateUserInfo(msg.sender);

    _withdraw(_recipient, userInfo[msg.sender].unrealised);
  }

  
  
  function claim(address _recipient) external override {
    _updateUserInfo(msg.sender);

    _claim(_recipient);
  }

  
  
  function exit(address _recipient) external override {
    _updateUserInfo(msg.sender);

    _withdraw(_recipient, userInfo[msg.sender].unrealised);
    _claim(_recipient);
  }

  
  
  
  function distribute(address _origin, uint256 _amount) external override onlyWhitelisted {
    require(_amount > 0, "Furnace: distribute zero CVX");

    IERC20Upgradeable(CVX).safeTransferFrom(_origin, address(this), _amount);

    _distribute(_origin, _amount);
  }

  
  
  
  
  function harvest(address _recipient, uint256 _minimumOut) external returns (uint256) {
     
    IConvexCVXRewardPool(CVX_REWARD_POOL).getReward(false);

     
    uint256 _amount = IERC20Upgradeable(CVXCRV).balanceOf(address(this));
    if (_amount > 0) {
      IERC20Upgradeable(CVXCRV).safeTransfer(zap, _amount);
      _amount = IZap(zap).zap(CVXCRV, _amount, CVX, _minimumOut);
    }

    emit Harvest(msg.sender, _amount);

    if (_amount > 0) {
      uint256 _distributeAmount = _amount;
       
      uint256 _platformFee = platformFeePercentage;
      if (_platformFee > 0) {
        _platformFee = (_platformFee * _distributeAmount) / FEE_PRECISION;
        IERC20Upgradeable(CVX).safeTransfer(platform, _platformFee);
        _distributeAmount = _distributeAmount - _platformFee;  
      }
      uint256 _harvestBounty = harvestBountyPercentage;
      if (_harvestBounty > 0) {
        _harvestBounty = (_harvestBounty * _distributeAmount) / FEE_PRECISION;
        _distributeAmount = _distributeAmount - _harvestBounty;  
        IERC20Upgradeable(CVX).safeTransfer(_recipient, _harvestBounty);
      }
       
       
      _distribute(address(this), _distributeAmount);
    }
    return _amount;
  }

  
  function updatePendingDistribution() external {
    _updatePendingDistribution();
  }

   

  
  
  
  function updateWhitelists(address[] memory _whitelists, bool _status) external onlyOwner {
    for (uint256 i = 0; i < _whitelists.length; i++) {
       
      require(_whitelists[i] != address(0), "Furnace: zero whitelist address");
      isWhitelisted[_whitelists[i]] = _status;

      emit UpdateWhitelist(_whitelists[i], _status);
    }
  }

  
  
  function updateGovernor(address _governor) external onlyGovernorOrOwner {
    require(_governor != address(0), "Furnace: zero governor address");
    governor = _governor;

    emit UpdateGovernor(_governor);
  }

  
  
  function updateStakePercentage(uint256 _percentage) external onlyGovernorOrOwner {
    require(_percentage <= FEE_PRECISION, "Furnace: percentage too large");
    stakePercentage = _percentage;

    emit UpdateStakePercentage(_percentage);
  }

  
  
  function updateStakeThreshold(uint256 _threshold) external onlyGovernorOrOwner {
    stakeThreshold = _threshold;

    emit UpdateStakeThreshold(_threshold);
  }

  
  
  function updatePlatformFeePercentage(uint256 _feePercentage) external onlyOwner {
    require(_feePercentage <= MAX_PLATFORM_FEE, "Furnace: fee too large");
    platformFeePercentage = _feePercentage;

    emit UpdatePlatformFeePercentage(_feePercentage);
  }

  
  
  function updateHarvestBountyPercentage(uint256 _percentage) external onlyOwner {
    require(_percentage <= MAX_HARVEST_BOUNTY, "Furnace: fee too large");
    harvestBountyPercentage = _percentage;

    emit UpdateHarvestBountyPercentage(_percentage);
  }

  
  
  function updatePlatform(address _platform) external onlyOwner {
    require(_platform != address(0), "Furnace: zero platform address");
    platform = _platform;

    emit UpdatePlatform(_platform);
  }

  
  
  function updateZap(address _zap) external onlyGovernorOrOwner {
    require(_zap != address(0), "Furnace: zero zap address");
    zap = _zap;

    emit UpdateZap(_zap);
  }

  
  
  
  function updatePeriodLength(uint32 _length) external onlyGovernorOrOwner {
    rewardInfo.periodLength = _length;

    emit UpdatePeriodLength(_length);
  }

   

  
   
  function _updatePendingDistribution() internal {
    LinearReward memory _info = rewardInfo;
    if (_info.periodLength > 0) {
      uint256 _currentTime = _info.finishAt;
      if (_currentTime > block.timestamp) {
        _currentTime = block.timestamp;
      }
      uint256 _duration = _currentTime >= _info.lastUpdate ? _currentTime - _info.lastUpdate : 0;
      if (_duration > 0) {
        _info.lastUpdate = uint48(block.timestamp);
        rewardInfo = _info;

        _reduceGlobalDebt(_duration.mul(_info.ratePerSecond));
      }
    }
  }

  
  
  function _updateUserInfo(address _account) internal {
    _updatePendingDistribution();

    UserInfo memory _info = userInfo[_account];
    uint128 _accUnrealisedFraction = accUnrealisedFraction;
    uint64 _distributeIndex = distributeIndex;
    if (_info.lastDistributeIndex < lastPaidOffDistributeIndex) {
       
      userInfo[_account] = UserInfo({
        unrealised: 0,
        realised: _info.unrealised + _info.realised,  
        accUnrealisedFractionPaid: _accUnrealisedFraction,
        lastDistributeIndex: _distributeIndex
      });
    } else {
       
      uint128 _newUnrealised = _toU128(
        _muldiv128(_info.unrealised, _accUnrealisedFraction, uint128(_info.accUnrealisedFractionPaid))
      ) + 1;
      if (_newUnrealised >= _info.unrealised) {
        _newUnrealised = _info.unrealised;
      }
      uint128 _newRealised = _info.unrealised - _newUnrealised + _info.realised;  
      userInfo[_account] = UserInfo({
        unrealised: _newUnrealised,
        realised: _newRealised,
        accUnrealisedFractionPaid: _accUnrealisedFraction,
        lastDistributeIndex: _distributeIndex
      });
    }
  }

  
   
  
  
  function _deposit(address _account, uint256 _amount) internal {
     
    _updateUserInfo(_account);

     
    uint256 _totalUnrealised = totalUnrealised;
    uint256 _totalRealised = totalRealised;
    uint256 _freeCVX = totalCVXInPool().sub(_totalRealised);

    uint256 _newUnrealised;
    uint256 _newRealised;
    if (_freeCVX >= _amount) {
       
      _newUnrealised = 0;
      _newRealised = _amount;
    } else {
       
       
      _newUnrealised = _amount - _freeCVX;
      _newRealised = _freeCVX;
    }

     
    userInfo[_account].realised = _toU128(_newRealised.add(userInfo[_account].realised));
    userInfo[_account].unrealised = _toU128(_newUnrealised.add(userInfo[_account].unrealised));

    totalRealised = _toU128(_totalRealised.add(_newRealised));
    totalUnrealised = _toU128(_totalUnrealised.add(_newUnrealised));

    emit Deposit(_account, _amount);
  }

  
  
  
  function _withdraw(address _recipient, uint256 _amount) internal {
    require(_amount <= userInfo[msg.sender].unrealised, "Furnace: clevCVX not enough");

    userInfo[msg.sender].unrealised = uint128(uint256(userInfo[msg.sender].unrealised) - _amount);  
    totalUnrealised = uint128(uint256(totalUnrealised) - _amount);  

    IERC20Upgradeable(clevCVX).safeTransfer(_recipient, _amount);

    emit Withdraw(msg.sender, _recipient, _amount);
  }

  
  
  function _claim(address _recipient) internal {
    uint256 _amount = userInfo[msg.sender].realised;
     
    totalRealised = uint128(uint256(totalRealised).sub(_amount));
    userInfo[msg.sender].realised = 0;

    uint256 _balanceInContract = IERC20Upgradeable(CVX).balanceOf(address(this));
    if (_balanceInContract < _amount) {
       
      IConvexCVXRewardPool(CVX_REWARD_POOL).withdraw(_amount - _balanceInContract, false);
    }
    IERC20Upgradeable(CVX).safeTransfer(_recipient, _amount);
     
    ICLeverToken(clevCVX).burn(_amount);

    emit Claim(msg.sender, _recipient, _amount);
  }

  
  
  
  function _distribute(address _origin, uint256 _amount) internal {
     
    _updatePendingDistribution();

     
    LinearReward memory _info = rewardInfo;
    if (_info.periodLength == 0) {
      _reduceGlobalDebt(_amount);
    } else {
      if (block.timestamp >= _info.finishAt) {
        _info.ratePerSecond = _toU128(_amount / _info.periodLength);
      } else {
        uint256 _remaining = _info.finishAt - block.timestamp;
        uint256 _leftover = _remaining * _info.ratePerSecond;
        _info.ratePerSecond = _toU128((_amount + _leftover) / _info.periodLength);
      }

      _info.lastUpdate = uint48(block.timestamp);
      _info.finishAt = uint48(block.timestamp + _info.periodLength);

      rewardInfo = _info;
    }

     
    uint256 _toStake = totalCVXInPool().mul(stakePercentage).div(FEE_PRECISION);
    uint256 _balanceStaked = IConvexCVXRewardPool(CVX_REWARD_POOL).balanceOf(address(this));
    if (_balanceStaked < _toStake) {
      _toStake = _toStake - _balanceStaked;
      if (_toStake >= stakeThreshold) {
        IERC20Upgradeable(CVX).safeApprove(CVX_REWARD_POOL, 0);
        IERC20Upgradeable(CVX).safeApprove(CVX_REWARD_POOL, _toStake);
        IConvexCVXRewardPool(CVX_REWARD_POOL).stake(_toStake);
      }
    }

    emit Distribute(_origin, _amount);
  }

  
  
  function _reduceGlobalDebt(uint256 _amount) internal {
    distributeIndex += 1;

    uint256 _totalUnrealised = totalUnrealised;
    uint256 _totalRealised = totalRealised;
    uint128 _accUnrealisedFraction = accUnrealisedFraction;
     
    if (_amount >= _totalUnrealised) {
       
      totalUnrealised = 0;
      totalRealised = _toU128(_totalUnrealised + _totalRealised);

      accUnrealisedFraction = 0;
      lastPaidOffDistributeIndex = distributeIndex;
    } else {
      totalUnrealised = uint128(_totalUnrealised - _amount);
      totalRealised = _toU128(_totalRealised + _amount);

      uint128 _fraction = _toU128(((_totalUnrealised - _amount) * E128) / _totalUnrealised);  
      accUnrealisedFraction = _mul128(_accUnrealisedFraction, _fraction);
    }
  }

  
  function _toU128(uint256 _value) internal pure returns (uint128) {
    require(_value < 340282366920938463463374607431768211456, "Furnace: overflow");
    return uint128(_value);
  }

  
  function _mul128(uint128 _a, uint128 _b) internal pure returns (uint128) {
    if (_a == 0) return _b;
    if (_b == 0) return _a;
    return uint128((uint256(_a) * uint256(_b)) / E128);
  }

  
  function _muldiv128(
    uint256 _a,
    uint128 _b,
    uint128 _c
  ) internal pure returns (uint256) {
    if (_b == 0) {
      if (_c == 0) return _a;
      else return _a / _c;
    } else {
      if (_c == 0) return _a.mul(_b) / E128;
      else return _a.mul(_b) / _c;
    }
  }
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



interface ICLeverToken is IERC20 {
  function mint(address _recipient, uint256 _amount) external;

  function burn(uint256 _amount) external;

  function burnFrom(address _account, uint256 _amount) external;
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
