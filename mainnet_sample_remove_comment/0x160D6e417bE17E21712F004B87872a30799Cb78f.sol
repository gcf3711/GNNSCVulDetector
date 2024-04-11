 


 

 
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



interface IAladdinCRV is IERC20Upgradeable {
  event Harvest(address indexed _caller, uint256 _amount);
  event Deposit(address indexed _sender, address indexed _recipient, uint256 _amount);
  event Withdraw(
    address indexed _sender,
    address indexed _recipient,
    uint256 _shares,
    IAladdinCRV.WithdrawOption _option
  );

  event UpdateWithdrawalFeePercentage(uint256 _feePercentage);
  event UpdatePlatformFeePercentage(uint256 _feePercentage);
  event UpdateHarvestBountyPercentage(uint256 _percentage);
  event UpdatePlatform(address indexed _platform);
  event UpdateZap(address indexed _zap);

  enum WithdrawOption {
    Withdraw,
    WithdrawAndStake,
    WithdrawAsCRV,
    WithdrawAsCVX,
    WithdrawAsETH
  }

  
  function totalUnderlying() external view returns (uint256);

  
  function balanceOfUnderlying(address _user) external view returns (uint256);

  function deposit(address _recipient, uint256 _amount) external returns (uint256);

  function depositAll(address _recipient) external returns (uint256);

  function depositWithCRV(address _recipient, uint256 _amount) external returns (uint256);

  function depositAllWithCRV(address _recipient) external returns (uint256);

  function withdraw(
    address _recipient,
    uint256 _shares,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);

  function withdrawAll(
    address _recipient,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);

  function harvest(address _recipient, uint256 _minimumOut) external returns (uint256);
}
 

pragma solidity ^0.7.6;













 
contract AladdinCRV is ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, IAladdinCRV {
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  uint256 private constant FEE_DENOMINATOR = 1e9;
  uint256 private constant MAX_WITHDRAW_FEE = 1e8;  
  uint256 private constant MAX_PLATFORM_FEE = 2e8;  
  uint256 private constant MAX_HARVEST_BOUNTY = 1e8;  

   
  address private constant CVXCRV = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
   
  address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
   
  address private constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
   
  address private constant THREE_CRV = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
   
  address private constant CVXCRV_STAKING = 0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e;
   
  address private constant CVX_MINING = 0x3c75BFe6FbfDa3A94E7E7E8c2216AFc684dE5343;
   
  address private constant THREE_CRV_REWARDS = 0x7091dbb7fcbA54569eF1387Ac89Eb2a5C9F6d2EA;

  
  address public zap;

  
  uint256 public withdrawFeePercentage;
  
  uint256 public platformFeePercentage;
  
  uint256 public harvestBountyPercentage;
  
  address public platform;

  function initialize(
    address _zap,
    address _platform,
    uint256 _withdrawFeePercentage,
    uint256 _platformFeePercentage,
    uint256 _harvestBountyPercentage
  ) external initializer {
    ERC20Upgradeable.__ERC20_init("Aladdin cvxCRV", "aCRV");
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

    require(_zap != address(0), "AladdinCRV: zero zap address");
    require(_platform != address(0), "AladdinCRV: zero platform address");
    require(_withdrawFeePercentage <= MAX_WITHDRAW_FEE, "AladdinCRV: fee too large");
    require(_platformFeePercentage <= MAX_PLATFORM_FEE, "AladdinCRV: fee too large");
    require(_harvestBountyPercentage <= MAX_HARVEST_BOUNTY, "AladdinCRV: fee too large");

    zap = _zap;
    platform = _platform;
    withdrawFeePercentage = _withdrawFeePercentage;
    platformFeePercentage = _platformFeePercentage;
    harvestBountyPercentage = _harvestBountyPercentage;
  }

   

  
  function totalUnderlying() public view override returns (uint256) {
     
    return IConvexBasicRewards(CVXCRV_STAKING).balanceOf(address(this));
  }

  
  
  function balanceOfUnderlying(address _user) external view override returns (uint256) {
    uint256 _totalSupply = totalSupply();
    if (_totalSupply == 0) return 0;
    uint256 _balance = balanceOf(_user);
    return _balance.mul(totalUnderlying()) / _totalSupply;
  }

  
  function pendingCRVRewards() public view returns (uint256) {
    return IConvexBasicRewards(CVXCRV_STAKING).earned(address(this));
  }

  
  function pendingCVXRewards() external view returns (uint256) {
    return ICVXMining(CVX_MINING).ConvertCrvToCvx(pendingCRVRewards());
  }

  
  function pending3CRVRewards() external view returns (uint256) {
    return IConvexVirtualBalanceRewardPool(THREE_CRV_REWARDS).earned(address(this));
  }

   

  
  
  
  
  function deposit(address _recipient, uint256 _amount) public override nonReentrant returns (uint256 share) {
    require(_amount > 0, "AladdinCRV: zero amount deposit");
    uint256 _before = IERC20Upgradeable(CVXCRV).balanceOf(address(this));
    IERC20Upgradeable(CVXCRV).safeTransferFrom(msg.sender, address(this), _amount);
    _amount = IERC20Upgradeable(CVXCRV).balanceOf(address(this)).sub(_before);
    return _deposit(_recipient, _amount);
  }

  
  
  
  function depositAll(address _recipient) external override returns (uint256 share) {
    uint256 _balance = IERC20Upgradeable(CVXCRV).balanceOf(msg.sender);
    return deposit(_recipient, _balance);
  }

  
  
  
  
  function depositWithCRV(address _recipient, uint256 _amount) public override nonReentrant returns (uint256 share) {
    uint256 _before = IERC20Upgradeable(CRV).balanceOf(address(this));
    IERC20Upgradeable(CRV).safeTransferFrom(msg.sender, address(this), _amount);
    _amount = IERC20Upgradeable(CRV).balanceOf(address(this)).sub(_before);

    _amount = _zapToken(_amount, CRV, _amount, CVXCRV);
    return _deposit(_recipient, _amount);
  }

  
  
  
  function depositAllWithCRV(address _recipient) external override returns (uint256 share) {
    uint256 _balance = IERC20Upgradeable(CRV).balanceOf(msg.sender);
    return depositWithCRV(_recipient, _balance);
  }

  
  
  
  
  
  
  function withdraw(
    address _recipient,
    uint256 _shares,
    uint256 _minimumOut,
    WithdrawOption _option
  ) public override nonReentrant returns (uint256 withdrawn) {
    uint256 _withdrawed = _withdraw(_shares);
    if (_option == WithdrawOption.Withdraw) {
      require(_withdrawed >= _minimumOut, "AladdinCRV: insufficient output");
      IERC20Upgradeable(CVXCRV).safeTransfer(_recipient, _withdrawed);
    } else {
      _withdrawed = _withdrawAs(_recipient, _withdrawed, _minimumOut, _option);
    }

    emit Withdraw(msg.sender, _recipient, _shares, _option);
    return _withdrawed;
  }

  
  
  
  
  
  function withdrawAll(
    address _recipient,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external override returns (uint256) {
    uint256 _shares = balanceOf(msg.sender);
    return withdraw(_recipient, _shares, _minimumOut, _option);
  }

  
  
  
  function harvest(address _recipient, uint256 _minimumOut) public override nonReentrant returns (uint256) {
    return _harvest(_recipient, _minimumOut);
  }

   

  
  
  function updateWithdrawFeePercentage(uint256 _feePercentage) external onlyOwner {
    require(_feePercentage <= MAX_WITHDRAW_FEE, "AladdinCRV: fee too large");
    withdrawFeePercentage = _feePercentage;

    emit UpdateWithdrawalFeePercentage(_feePercentage);
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

  
  function updateZap(address _zap) external onlyOwner {
    require(_zap != address(0), "AladdinCRV: zero zap address");
    zap = _zap;

    emit UpdateZap(_zap);
  }

  
  function claimEPS(
    address _distributor,
    address _recipient,
    uint256 merkleIndex,
    uint256 index,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external onlyOwner {
    address eps = 0xA7f552078dcC247C2684336020c03648500C6d9F;
    IEllipsisMerkleDistributor(_distributor).claim(merkleIndex, index, amount, merkleProof);
    IERC20Upgradeable(eps).safeTransfer(_recipient, IERC20Upgradeable(eps).balanceOf(address(this)));
  }

   

  function _deposit(address _recipient, uint256 _amount) internal returns (uint256) {
    require(_amount > 0, "AladdinCRV: zero amount deposit");
    uint256 _underlying = totalUnderlying();
    uint256 _totalSupply = totalSupply();

    IERC20Upgradeable(CVXCRV).safeApprove(CVXCRV_STAKING, 0);
    IERC20Upgradeable(CVXCRV).safeApprove(CVXCRV_STAKING, _amount);
    IConvexBasicRewards(CVXCRV_STAKING).stake(_amount);

    uint256 _shares;
    if (_totalSupply == 0) {
      _shares = _amount;
    } else {
      _shares = _amount.mul(_totalSupply) / _underlying;
    }
    _mint(_recipient, _shares);

    emit Deposit(msg.sender, _recipient, _amount);
    return _shares;
  }

  function _withdraw(uint256 _shares) internal returns (uint256 _withdrawable) {
    require(_shares > 0, "AladdinCRV: zero share withdraw");
    require(_shares <= balanceOf(msg.sender), "AladdinCRV: shares not enough");
    uint256 _amount = _shares.mul(totalUnderlying()) / totalSupply();
    _burn(msg.sender, _shares);

    if (totalSupply() == 0) {
       
       
      _harvest(msg.sender, 0);
      IConvexBasicRewards(CVXCRV_STAKING).withdraw(totalUnderlying(), false);
      _withdrawable = IERC20Upgradeable(CVXCRV).balanceOf(address(this));
    } else {
       
      _withdrawable = _amount;
       
       
       
      uint256 _withdrawFee = (_withdrawable * withdrawFeePercentage) / FEE_DENOMINATOR;
      _withdrawable = _withdrawable - _withdrawFee;  
      IConvexBasicRewards(CVXCRV_STAKING).withdraw(_withdrawable, false);
    }
    return _withdrawable;
  }

  function _withdrawAs(
    address _recipient,
    uint256 _amount,
    uint256 _minimumOut,
    WithdrawOption _option
  ) internal returns (uint256) {
    if (_option == WithdrawOption.WithdrawAndStake) {
       
      require(_amount >= _minimumOut, "AladdinCRV: insufficient output");
      IERC20Upgradeable(CVXCRV).safeApprove(CVXCRV_STAKING, 0);
      IERC20Upgradeable(CVXCRV).safeApprove(CVXCRV_STAKING, _amount);
      require(IConvexBasicRewards(CVXCRV_STAKING).stakeFor(_recipient, _amount), "AladdinCRV: stakeFor failed");
    } else if (_option == WithdrawOption.WithdrawAsCRV) {
      _amount = _zapToken(_amount, CVXCRV, _minimumOut, CRV);
      IERC20Upgradeable(CRV).safeTransfer(_recipient, _amount);
    } else if (_option == WithdrawOption.WithdrawAsETH) {
      _amount = _zapToken(_amount, CVXCRV, _minimumOut, address(0));

       
      (bool success, ) = _recipient.call{ value: _amount }("");
      require(success, "AladdinCRV: ETH transfer failed");
    } else if (_option == WithdrawOption.WithdrawAsCVX) {
      _amount = _zapToken(_amount, CVXCRV, _minimumOut, CVX);
      IERC20Upgradeable(CVX).safeTransfer(_recipient, _amount);
    } else {
      revert("AladdinCRV: unsupported option");
    }
    return _amount;
  }

  function _harvest(address _recipient, uint256 _minimumOut) internal returns (uint256) {
    IConvexBasicRewards(CVXCRV_STAKING).getReward();
     
    uint256 _amount = _zapToken(IERC20Upgradeable(CVX).balanceOf(address(this)), CVX, 0, address(0));
     
    _amount += _zapToken(IERC20Upgradeable(THREE_CRV).balanceOf(address(this)), THREE_CRV, 0, address(0));
     
    _zapToken(_amount, address(0), 0, CRV);
     
    _amount = IERC20Upgradeable(CRV).balanceOf(address(this));
    _zapToken(_amount, CRV, _amount, CVXCRV);

    _amount = IERC20Upgradeable(CVXCRV).balanceOf(address(this));
    require(_amount >= _minimumOut, "AladdinCRV: insufficient rewards");

    emit Harvest(msg.sender, _amount);

    uint256 _totalSupply = totalSupply();
    if (_amount > 0 && _totalSupply > 0) {
      uint256 _stakeAmount = _amount;
      uint256 _platformFee = platformFeePercentage;
      uint256 _harvestBounty = harvestBountyPercentage;
      if (_platformFee > 0) {
        _platformFee = (_platformFee * _stakeAmount) / FEE_DENOMINATOR;
        _stakeAmount = _stakeAmount - _platformFee;  
      }
      if (_harvestBounty > 0) {
        _harvestBounty = (_harvestBounty * _stakeAmount) / FEE_DENOMINATOR;
        _stakeAmount = _stakeAmount - _harvestBounty;  
      }
       
      uint256 _underlying = totalUnderlying() + _stakeAmount;
       
      _platformFee = (_platformFee * _totalSupply) / _underlying;
       
      _harvestBounty = (_harvestBounty * _totalSupply) / _underlying;

      IERC20Upgradeable(CVXCRV).safeApprove(CVXCRV_STAKING, 0);
      IERC20Upgradeable(CVXCRV).safeApprove(CVXCRV_STAKING, _amount);
      IConvexBasicRewards(CVXCRV_STAKING).stake(_amount);
      _mint(platform, _platformFee);
      _mint(_recipient, _harvestBounty);
    }
    return _amount;
  }

  function _zapToken(
    uint256 _amount,
    address _fromToken,
    uint256 _minimumOut,
    address _toToken
  ) internal returns (uint256) {
    if (_amount == 0) return 0;

     
    (bool success, bytes memory data) = zap.delegatecall(
      abi.encodeWithSignature("zap(address,uint256,address,uint256)", _fromToken, _amount, _toToken, _minimumOut)
    );
    require(success, "AladdinCRV: zap failed");
    return abi.decode(data, (uint256));
  }

  receive() external payable {}
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

interface IConvexBasicRewards {
  function stakeFor(address, uint256) external returns (bool);

  function balanceOf(address) external view returns (uint256);

  function earned(address) external view returns (uint256);

  function withdrawAll(bool) external returns (bool);

  function withdraw(uint256, bool) external returns (bool);

  function withdrawAndUnwrap(uint256, bool) external returns (bool);

  function getReward() external returns (bool);

  function stake(uint256) external returns (bool);
}

 

pragma solidity ^0.7.6;

interface IConvexCRVDepositor {
  function deposit(
    uint256 _amount,
    bool _lock,
    address _stakeAddress
  ) external;

  function deposit(uint256 _amount, bool _lock) external;

  function lockIncentive() external view returns (uint256);
}

 

pragma solidity ^0.7.6;

interface IConvexVirtualBalanceRewardPool {
  function earned(address account) external view returns (uint256);
}

 

pragma solidity ^0.7.6;

 
interface ICVXMining {
  function ConvertCrvToCvx(uint256 _amount) external view returns (uint256);
}

 

pragma solidity ^0.7.6;

interface IEllipsisMerkleDistributor {
  function claim(
    uint256 merkleIndex,
    uint256 index,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external;
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