 


 

 
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

 

pragma solidity ^0.7.0;






 
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

     
    function name() public view virtual returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    uint256[44] private __gap;
}

 

pragma solidity ^0.7.6;











 
 
 

abstract contract AladdinCompounder is
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  ERC20Upgradeable,
  FeeCustomization,
  IAladdinCompounder
{
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  
  
  
  
  
  event UpdateFeeInfo(
    address indexed _platform,
    uint32 _platformPercentage,
    uint32 _bountyPercentage,
    uint32 _repayPercentage
  );

  
  event UpdateRewardPeriodLength(uint256 _length);

  
  bytes32 internal constant WITHDRAW_FEE_TYPE = keccak256("AladdinCompounder.WithdrawFee");

  
  uint256 internal constant MAX_WITHDRAW_FEE = 1e8;  

  
  uint256 internal constant MAX_PLATFORM_FEE = 2e8;  

  
  uint256 internal constant MAX_HARVEST_BOUNTY = 1e8;  

  
  struct FeeInfo {
     
    address platform;
     
    uint32 platformPercentage;
     
    uint32 bountyPercentage;
     
    uint32 withdrawPercentage;
  }

  
  struct RewardInfo {
     
    uint128 rate;
     
     
    uint32 periodLength;
    uint48 lastUpdate;
    uint48 finishAt;
  }

  
  FeeInfo public feeInfo;

  
  RewardInfo public rewardInfo;

  
  uint256 internal totalAssetsStored;

  function _initialize(string memory _name, string memory _symbol) internal {
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    ERC20Upgradeable.__ERC20_init(_name, _symbol);
  }

  
  function asset() public view virtual override returns (address);

  
  function totalAssets() public view virtual override returns (uint256) {
    RewardInfo memory _info = rewardInfo;
    uint256 _period;
    if (block.timestamp > _info.finishAt) {
       
      _period = _info.finishAt >= _info.lastUpdate ? _info.finishAt - _info.lastUpdate : 0;
    } else {
      _period = block.timestamp - _info.lastUpdate;  
    }
    return totalAssetsStored + _period * _info.rate;
  }

  
  function convertToShares(uint256 _assets) public view override returns (uint256) {
    uint256 _totalAssets = totalAssets();
    if (_totalAssets == 0) return _assets;

    uint256 _totalShares = totalSupply();
    return _totalShares.mul(_assets) / _totalAssets;
  }

  
  function convertToAssets(uint256 _shares) public view override returns (uint256) {
    uint256 _totalShares = totalSupply();
    if (_totalShares == 0) return _shares;

    uint256 _totalAssets = totalAssets();
    return _totalAssets.mul(_shares) / _totalShares;
  }

  
  function maxDeposit(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  
  function previewDeposit(uint256 _assets) external view override returns (uint256) {
    return convertToShares(_assets);
  }

  
  function maxMint(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  
  function previewMint(uint256 _shares) external view override returns (uint256) {
    return convertToAssets(_shares);
  }

  
  function maxWithdraw(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  
  function previewWithdraw(uint256 _assets) external view override returns (uint256) {
    uint256 _totalAssets = totalAssets();
    require(_assets <= _totalAssets, "exceed total assets");
    uint256 _shares = convertToShares(_assets);
    if (_assets == _totalAssets) {
      return _shares;
    } else {
      FeeInfo memory _fees = feeInfo;
      return _shares.mul(FEE_PRECISION).div(FEE_PRECISION - _fees.withdrawPercentage);
    }
  }

  
  function maxRedeem(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  
  function previewRedeem(uint256 _shares) external view override returns (uint256) {
    uint256 _totalSupply = totalSupply();
    require(_shares <= _totalSupply, "exceed total supply");

    uint256 _assets = convertToAssets(_shares);
    if (_shares == totalSupply()) {
      return _assets;
    } else {
      FeeInfo memory _fees = feeInfo;
      uint256 _withdrawFee = _assets.mul(_fees.withdrawPercentage) / FEE_PRECISION;
      return _assets - _withdrawFee;
    }
  }

   

  
  function deposit(uint256 _assets, address _receiver) public override nonReentrant returns (uint256) {
    if (_assets == uint256(-1)) {
      _assets = IERC20Upgradeable(asset()).balanceOf(msg.sender);
    }

    _distributePendingReward();

    IERC20Upgradeable(asset()).safeTransferFrom(msg.sender, address(this), _assets);

    return _deposit(_assets, _receiver);
  }

  
  function mint(uint256 _shares, address _receiver) external override nonReentrant returns (uint256) {
    _distributePendingReward();

    uint256 _assets = convertToAssets(_shares);
    IERC20Upgradeable(asset()).safeTransferFrom(msg.sender, address(this), _assets);

    _deposit(_assets, _receiver);
    return _assets;
  }

  
  function withdraw(
    uint256 _assets,
    address _receiver,
    address _owner
  ) external override nonReentrant returns (uint256) {
    _distributePendingReward();
    if (_assets == uint256(-1)) {
      _assets = convertToAssets(balanceOf(_owner));
    }

    uint256 _totalAssets = totalAssets();
    require(_assets <= _totalAssets, "exceed total assets");

    uint256 _shares = convertToShares(_assets);
    if (_assets < _totalAssets) {
      uint256 _withdrawPercentage = getFeeRate(WITHDRAW_FEE_TYPE, _owner);
      _shares = _shares.mul(FEE_PRECISION).div(FEE_PRECISION - _withdrawPercentage);
    }

    if (msg.sender != _owner) {
      uint256 _allowance = allowance(_owner, msg.sender);
      require(_allowance >= _shares, "withdraw exceeds allowance");
      if (_allowance != uint256(-1)) {
         
        _approve(_owner, msg.sender, _allowance - _shares);
      }
    }

    _withdraw(_shares, _receiver, _owner);
    return _shares;
  }

  
  function redeem(
    uint256 _shares,
    address _receiver,
    address _owner
  ) public override nonReentrant returns (uint256) {
    if (_shares == uint256(-1)) {
      _shares = balanceOf(_owner);
    }
    _distributePendingReward();

    if (msg.sender != _owner) {
      uint256 _allowance = allowance(_owner, msg.sender);
      require(_allowance >= _shares, "redeem exceeds allowance");
      if (_allowance != uint256(-1)) {
         
        _approve(_owner, msg.sender, _allowance - _shares);
      }
    }

    return _withdraw(_shares, _receiver, _owner);
  }

  
  function checkpoint() external {
    _distributePendingReward();
  }

   

  
  
  
  
  
  function updateFeeInfo(
    address _platform,
    uint32 _platformPercentage,
    uint32 _bountyPercentage,
    uint32 _withdrawPercentage
  ) external onlyOwner {
    require(_platform != address(0), "zero platform address");
    require(_platformPercentage <= MAX_PLATFORM_FEE, "platform fee too large");
    require(_bountyPercentage <= MAX_HARVEST_BOUNTY, "bounty fee too large");
    require(_withdrawPercentage <= MAX_WITHDRAW_FEE, "withdraw fee too large");

    feeInfo = FeeInfo(_platform, _platformPercentage, _bountyPercentage, _withdrawPercentage);

    emit UpdateFeeInfo(_platform, _platformPercentage, _bountyPercentage, _withdrawPercentage);
  }

  
  
  function updateRewardPeriodLength(uint32 _length) external onlyOwner {
    rewardInfo.periodLength = _length;

    emit UpdateRewardPeriodLength(_length);
  }

  
  
  
  function setWithdrawFeeForUser(address _user, uint32 _percentage) external onlyOwner {
    require(_percentage <= MAX_WITHDRAW_FEE, "withdraw fee too large");

    _setFeeCustomization(WITHDRAW_FEE_TYPE, _user, _percentage);
  }

   

  
  
  
  
  function _deposit(uint256 _assets, address _receiver) internal virtual returns (uint256);

  
  
  
  
  
  function _withdraw(
    uint256 _shares,
    address _receiver,
    address _owner
  ) internal virtual returns (uint256);

  
  function _distributePendingReward() internal virtual {
    RewardInfo memory _info = rewardInfo;
    if (_info.periodLength == 0) return;

    uint256 _period;
    if (block.timestamp > _info.finishAt) {
       
      _period = _info.finishAt >= _info.lastUpdate ? _info.finishAt - _info.lastUpdate : 0;
    } else {
      _period = block.timestamp - _info.lastUpdate;  
    }

    uint256 _totalAssetsStored = totalAssetsStored;
    if (_totalAssetsStored == 0) {
       
       
       
       
       
    } else {
      totalAssetsStored = _totalAssetsStored + _period * _info.rate;
      rewardInfo.lastUpdate = uint48(block.timestamp);
    }
  }

  
  
  
  function _notifyHarvestedReward(uint256 _amount) internal virtual {
    RewardInfo memory _info = rewardInfo;
    if (_info.periodLength == 0) {
      totalAssetsStored = totalAssetsStored.add(_amount);
    } else {
      require(_amount < uint128(-1), "amount overflow");

      if (block.timestamp >= _info.finishAt) {
        _info.rate = uint128(_amount / _info.periodLength);
      } else {
        uint256 _remaining = _info.finishAt - block.timestamp;
        uint256 _leftover = _remaining * _info.rate;
        _info.rate = uint128((_amount + _leftover) / _info.periodLength);
      }

      _info.lastUpdate = uint48(block.timestamp);
      _info.finishAt = uint48(block.timestamp + _info.periodLength);

      rewardInfo = _info;
    }
  }

  
  function _defaultFeeRate(bytes32) internal view override returns (uint256) {
    return feeInfo.withdrawPercentage;
  }
}

 

pragma solidity ^0.7.6;









 
 
 

abstract contract AladdinCompounderWithStrategy is AladdinCompounder {
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  
  
  event UpdateZap(address _zap);

  
  
  
  event Migrate(address _oldStrategy, address _newStrategy);

  
  address public zap;

  
  address public strategy;

  
  uint256[48] private __gap;

  function _initialize(
    address _zap,
    address _strategy,
    string memory _name,
    string memory _symbol
  ) internal {
    require(_zap != address(0), "AladdinCompounder: zero zap address");
    require(_strategy != address(0), "AladdinCompounder: zero strategy address");

    AladdinCompounder._initialize(_name, _symbol);

    zap = _zap;
    strategy = _strategy;
  }

   

  
  function harvest(address _recipient, uint256 _minAssets) external override nonReentrant returns (uint256) {
    _distributePendingReward();

    uint256 _amountLP = IConcentratorStrategy(strategy).harvest(zap, _intermediate());
    require(_amountLP >= _minAssets, "AladdinCompounder: insufficient rewards");

    FeeInfo memory _info = feeInfo;
    uint256 _platformFee;
    uint256 _harvestBounty;
    uint256 _totalAssets = totalAssetsStored;  
    uint256 _totalShare = totalSupply();
    if (_info.platformPercentage > 0) {
      _platformFee = (_info.platformPercentage * _amountLP) / FEE_PRECISION;
       
      _mint(_info.platform, _platformFee.mul(_totalShare) / _totalAssets);
    }
    if (_info.bountyPercentage > 0) {
      _harvestBounty = (_info.bountyPercentage * _amountLP) / FEE_PRECISION;
       
      _mint(_recipient, _harvestBounty.mul(_totalShare) / _totalAssets);
    }
    totalAssetsStored = _totalAssets.add(_platformFee).add(_harvestBounty);

    emit Harvest(msg.sender, _recipient, _amountLP, _platformFee, _harvestBounty);

     
    _notifyHarvestedReward(_amountLP - _platformFee - _harvestBounty);

    return _amountLP;
  }

   

  
  
  function updateRewards(address[] memory _rewards) external onlyOwner {
    IConcentratorStrategy(strategy).updateRewards(_rewards);
  }

  
  
  function updateZap(address _zap) external onlyOwner {
    require(_zap != address(0), "AladdinCompounder: zero zap address");
    zap = _zap;

    emit UpdateZap(_zap);
  }

  
  
  function migrateStrategy(address _newStrategy) external onlyOwner {
    require(_newStrategy != address(0), "AladdinCompounder: zero new strategy address");

    _distributePendingReward();

    uint256 _totalUnderlying = totalAssetsStored;
    RewardInfo memory _info = rewardInfo;
    if (_info.periodLength > 0) {
      if (block.timestamp < _info.finishAt) {
        _totalUnderlying += (_info.finishAt - block.timestamp) * _info.rate;
      }
    }

    address _oldStrategy = strategy;
    strategy = _newStrategy;

    IConcentratorStrategy(_oldStrategy).prepareMigrate(_newStrategy);
    IConcentratorStrategy(_oldStrategy).withdraw(_newStrategy, _totalUnderlying);
    IConcentratorStrategy(_oldStrategy).finishMigrate(_newStrategy);

    IConcentratorStrategy(_newStrategy).deposit(address(this), _totalUnderlying);

    emit Migrate(_oldStrategy, _newStrategy);
  }

   

  
  
  function _deposit(uint256 _assets, address _receiver) internal override returns (uint256) {
    require(_assets > 0, "AladdinCompounder: deposit zero amount");

    uint256 _totalAssets = totalAssetsStored;  
    uint256 _totalShare = totalSupply();
    uint256 _shares;
    if (_totalAssets == 0) _shares = _assets;
    else _shares = _assets.mul(_totalShare) / _totalAssets;

    _mint(_receiver, _shares);

    totalAssetsStored = _totalAssets + _assets;

    address _strategy = strategy;  
    IERC20Upgradeable(asset()).safeTransfer(_strategy, _assets);
    IConcentratorStrategy(_strategy).deposit(_receiver, _assets);

    emit Deposit(msg.sender, _receiver, _assets, _shares);

    return _shares;
  }

  
  
  function _withdraw(
    uint256 _shares,
    address _receiver,
    address _owner
  ) internal override returns (uint256) {
    require(_shares > 0, "AladdinCompounder: withdraw zero share");
    require(_shares <= balanceOf(_owner), "AladdinCompounder: insufficient owner shares");
    uint256 _totalAssets = totalAssetsStored;  
    uint256 _totalShare = totalSupply();
    uint256 _amount = _shares.mul(_totalAssets) / _totalShare;
    _burn(_owner, _shares);

    if (_totalShare != _shares) {
       
      uint256 _withdrawPercentage = getFeeRate(WITHDRAW_FEE_TYPE, _owner);
      uint256 _withdrawFee = (_amount * _withdrawPercentage) / FEE_PRECISION;
      _amount = _amount - _withdrawFee;  
    } else {
       
       
    }

    totalAssetsStored = _totalAssets - _amount;  

    IConcentratorStrategy(strategy).withdraw(_receiver, _amount);

    emit Withdraw(msg.sender, _receiver, _owner, _amount, _shares);

    return _amount;
  }

  
  function _intermediate() internal view virtual returns (address);
}
 

pragma solidity ^0.7.6;



contract AladdinETH is AladdinCompounderWithStrategy {
  
  address private underlying;

  function initialize(
    address _zap,
    address _underlying,
    address _strategy,
    string memory _name,
    string memory _symbol
  ) external initializer {
    AladdinCompounderWithStrategy._initialize(_zap, _strategy, _name, _symbol);

    underlying = _underlying;
  }

   

  
  function asset() public view override returns (address) {
    return underlying;
  }

  
  function _intermediate() internal pure override returns (address) {
    return address(0);
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