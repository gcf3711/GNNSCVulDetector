 


pragma solidity ^0.6.0;

 
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

pragma solidity ^0.6.0;

 
contract Context {
     
     
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity 0.6.12;



interface IPodOption is IERC20 {
     
     
    enum OptionType { PUT, CALL }
     
    enum ExerciseType { EUROPEAN, AMERICAN }

     
    event Mint(address indexed minter, uint256 amount);
    event Unmint(address indexed minter, uint256 optionAmount, uint256 strikeAmount, uint256 underlyingAmount);
    event Exercise(address indexed exerciser, uint256 amount);
    event Withdraw(address indexed minter, uint256 strikeAmount, uint256 underlyingAmount);

     

     
    function mint(uint256 amountOfOptions, address owner) external;

     
    function exercise(uint256 amountOfOptions) external;

     
    function withdraw() external;

     
    function unmint(uint256 amountOfOptions) external;

    function optionType() external view returns (OptionType);

    function exerciseType() external view returns (ExerciseType);

    function underlyingAsset() external view returns (address);

    function underlyingAssetDecimals() external view returns (uint8);

    function strikeAsset() external view returns (address);

    function strikeAssetDecimals() external view returns (uint8);

    function strikePrice() external view returns (uint256);

    function strikePriceDecimals() external view returns (uint8);

    function expiration() external view returns (uint256);

    function startOfExerciseWindow() external view returns (uint256);

    function hasExpired() external view returns (bool);

    function isTradeWindow() external view returns (bool);

    function isExerciseWindow() external view returns (bool);

    function isWithdrawWindow() external view returns (bool);

    function strikeToTransfer(uint256 amountOfOptions) external view returns (uint256);

    function getSellerWithdrawAmounts(address owner)
        external
        view
        returns (uint256 strikeAmount, uint256 underlyingAmount);

    function underlyingReserves() external view returns (uint256);

    function strikeReserves() external view returns (uint256);
}

pragma solidity ^0.6.0;






 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
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

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 

pragma solidity 0.6.12;






 
abstract contract CappedOption is IERC20 {
    using SafeMath for uint256;

    IConfigurationManager private immutable _configurationManager;

    constructor(IConfigurationManager configurationManager) public {
        _configurationManager = configurationManager;
    }

     
    modifier capped(uint256 amountOfOptions) {
        uint256 cap = capSize();
        if (cap > 0) {
            require(this.totalSupply().add(amountOfOptions) <= cap, "CappedOption: amount exceed cap");
        }
        _;
    }

     
    function capSize() public view returns (uint256) {
        ICapProvider capProvider = ICapProvider(_configurationManager.getCapProvider());
        return capProvider.getCap(address(this));
    }
}

 

pragma solidity 0.6.12;



contract RequiredDecimals {
     
    function tryDecimals(IERC20 token) internal view returns (uint8) {
         
        bytes memory payload = abi.encodeWithSignature("decimals()");
         
        (bool success, bytes memory returnData) = address(token).staticcall(payload);

        require(success, "RequiredDecimals: required decimals");
        uint8 decimals = abi.decode(returnData, (uint8));
        require(decimals < 77, "RequiredDecimals: token decimals should be lower than 77");

        return decimals;
    }
}

 

pragma solidity 0.6.12;




interface IOptionBuilder {
    function buildOption(
        string memory _name,
        string memory _symbol,
        IPodOption.ExerciseType _exerciseType,
        address _underlyingAsset,
        address _strikeAsset,
        uint256 _strikePrice,
        uint256 _expiration,
        uint256 _exerciseWindowSize,
        IConfigurationManager _configurationManager
    ) external returns (IPodOption);
}

 

pragma solidity 0.6.12;










 
abstract contract PodOption is IPodOption, ERC20, RequiredDecimals, CappedOption {
    using SafeERC20 for IERC20;

     
    uint256 public constant MIN_EXERCISE_WINDOW_SIZE = 86400;

    OptionType private immutable _optionType;
    ExerciseType private immutable _exerciseType;
    IConfigurationManager public immutable configurationManager;

    address private immutable _underlyingAsset;
    address private immutable _strikeAsset;
    uint256 private immutable _strikePrice;
    uint256 private immutable _expiration;
    uint256 private _startOfExerciseWindow;

     
    mapping(address => uint256) public shares;

     
    mapping(address => uint256) public mintedOptions;

     
    uint256 public totalShares = 0;

    constructor(
        string memory name,
        string memory symbol,
        OptionType optionType,
        ExerciseType exerciseType,
        address underlyingAsset,
        address strikeAsset,
        uint256 strikePrice,
        uint256 expiration,
        uint256 exerciseWindowSize,
        IConfigurationManager _configurationManager
    ) public ERC20(name, symbol) CappedOption(_configurationManager) {
        require(Address.isContract(underlyingAsset), "PodOption: underlying asset is not a contract");
        require(Address.isContract(strikeAsset), "PodOption: strike asset is not a contract");
        require(underlyingAsset != strikeAsset, "PodOption: underlying asset and strike asset must differ");
        require(expiration > block.timestamp, "PodOption: expiration should be in the future");
        require(strikePrice > 0, "PodOption: strike price must be greater than zero");

        if (exerciseType == ExerciseType.EUROPEAN) {
            require(
                exerciseWindowSize >= MIN_EXERCISE_WINDOW_SIZE,
                "PodOption: exercise window must be greater than or equal 86400"
            );
            _startOfExerciseWindow = expiration.sub(exerciseWindowSize);
        } else {
            require(exerciseWindowSize == 0, "PodOption: exercise window size must be equal to zero");
            _startOfExerciseWindow = block.timestamp;
        }

        configurationManager = _configurationManager;

        _optionType = optionType;
        _exerciseType = exerciseType;
        _expiration = expiration;

        _underlyingAsset = underlyingAsset;
        _strikeAsset = strikeAsset;

        uint8 underlyingDecimals = tryDecimals(IERC20(underlyingAsset));
        tryDecimals(IERC20(strikeAsset));

        _strikePrice = strikePrice;
        _setupDecimals(underlyingDecimals);
    }

     
    function hasExpired() external override view returns (bool) {
        return _hasExpired();
    }

     
    function strikeToTransfer(uint256 amountOfOptions) external override view returns (uint256) {
        return _strikeToTransfer(amountOfOptions);
    }

     
    function isTradeWindow() external override view returns (bool) {
        return _isTradeWindow();
    }

     
    function isExerciseWindow() external override view returns (bool) {
        return _isExerciseWindow();
    }

     
    function isWithdrawWindow() external override view returns (bool) {
        return _isWithdrawWindow();
    }

     
    function optionType() external override view returns (OptionType) {
        return _optionType;
    }

     
    function exerciseType() external override view returns (ExerciseType) {
        return _exerciseType;
    }

     
    function strikePrice() external override view returns (uint256) {
        return _strikePrice;
    }

     
    function strikePriceDecimals() external override view returns (uint8) {
        return ERC20(_strikeAsset).decimals();
    }

     
    function expiration() external override view returns (uint256) {
        return _expiration;
    }

     
    function strikeAssetDecimals() external override view returns (uint8) {
        return ERC20(_strikeAsset).decimals();
    }

     
    function strikeAsset() public override view returns (address) {
        return _strikeAsset;
    }

     
    function underlyingAssetDecimals() public override view returns (uint8) {
        return ERC20(_underlyingAsset).decimals();
    }

     
    function underlyingAsset() public override view returns (address) {
        return _underlyingAsset;
    }

     
    function getSellerWithdrawAmounts(address owner)
        public
        override
        view
        returns (uint256 strikeAmount, uint256 underlyingAmount)
    {
        uint256 ownerShares = shares[owner];

        strikeAmount = ownerShares.mul(strikeReserves()).div(totalShares);
        underlyingAmount = ownerShares.mul(underlyingReserves()).div(totalShares);

        return (strikeAmount, underlyingAmount);
    }

     
    function startOfExerciseWindow() public override view returns (uint256) {
        return _startOfExerciseWindow;
    }

     
    function underlyingReserves() public override view returns (uint256) {
        return IERC20(_underlyingAsset).balanceOf(address(this));
    }

     
    function strikeReserves() public override view returns (uint256) {
        return IERC20(_strikeAsset).balanceOf(address(this));
    }

     
    modifier tradeWindow() {
        require(_isTradeWindow(), "PodOption: trade window has closed");
        _;
    }

     
    modifier exerciseWindow() {
        require(_isExerciseWindow(), "PodOption: not in exercise window");
        _;
    }

     
    modifier withdrawWindow() {
        require(_isWithdrawWindow(), "PodOption: option has not expired yet");
        _;
    }

     
    function _hasExpired() internal view returns (bool) {
        return block.timestamp >= _expiration;
    }

     
    function _isTradeWindow() internal view returns (bool) {
        if (_hasExpired()) {
            return false;
        } else if (_exerciseType == ExerciseType.EUROPEAN) {
            return !_isExerciseWindow();
        }
        return true;
    }

     
    function _isExerciseWindow() internal view returns (bool) {
        return !_hasExpired() && block.timestamp >= _startOfExerciseWindow;
    }

     
    function _isWithdrawWindow() internal view returns (bool) {
        return _hasExpired();
    }

     
    function _strikeToTransfer(uint256 amountOfOptions) internal view returns (uint256) {
        uint256 strikeAmount = amountOfOptions.mul(_strikePrice).div(10**uint256(underlyingAssetDecimals()));
        require(strikeAmount > 0, "PodOption: amount of options is too low");
        return strikeAmount;
    }

     
    function _calculatedShares(uint256 amountOfCollateral) internal view returns (uint256 ownerShares) {
        uint256 currentStrikeReserves = strikeReserves();
        uint256 currentUnderlyingReserves = underlyingReserves();

        uint256 numerator = amountOfCollateral.mul(totalShares);
        uint256 denominator;

        if (_optionType == OptionType.PUT) {
            denominator = currentStrikeReserves.add(
                currentUnderlyingReserves.mul(_strikePrice).div(uint256(10)**underlyingAssetDecimals())
            );
        } else {
            denominator = currentUnderlyingReserves.add(
                currentStrikeReserves.mul(uint256(10)**underlyingAssetDecimals()).div(_strikePrice)
            );
        }
        ownerShares = numerator.div(denominator);
        return ownerShares;
    }

     
    function _mintOptions(
        uint256 amountOfOptions,
        uint256 amountOfCollateral,
        address owner
    ) internal capped(amountOfOptions) {
        require(owner != address(0), "PodOption: zero address cannot be the owner");

        if (totalShares > 0) {
            uint256 ownerShares = _calculatedShares(amountOfCollateral);

            shares[owner] = shares[owner].add(ownerShares);
            totalShares = totalShares.add(ownerShares);
        } else {
            shares[owner] = amountOfCollateral;
            totalShares = amountOfCollateral;
        }

        mintedOptions[owner] = mintedOptions[owner].add(amountOfOptions);

        _mint(msg.sender, amountOfOptions);
    }

     
    function _burnOptions(uint256 amountOfOptions, address owner)
        internal
        returns (
            uint256 strikeToSend,
            uint256 underlyingToSend,
            uint256 currentStrikeReserves,
            uint256 currentUnderlyingReserves
        )
    {
        uint256 ownerShares = shares[owner];
        require(ownerShares > 0, "PodOption: you do not have minted options");

        uint256 ownerMintedOptions = mintedOptions[owner];
        require(amountOfOptions <= ownerMintedOptions, "PodOption: not enough minted options");

        currentStrikeReserves = strikeReserves();
        currentUnderlyingReserves = underlyingReserves();

        uint256 burnedShares = ownerShares.mul(amountOfOptions).div(ownerMintedOptions);
        strikeToSend = burnedShares.mul(currentStrikeReserves).div(totalShares);
        underlyingToSend = burnedShares.mul(currentUnderlyingReserves).div(totalShares);

        shares[owner] = shares[owner].sub(burnedShares);
        mintedOptions[owner] = mintedOptions[owner].sub(amountOfOptions);
        totalShares = totalShares.sub(burnedShares);

        _burn(owner, amountOfOptions);
    }

     
    function _withdraw() internal returns (uint256 strikeToSend, uint256 underlyingToSend) {
        uint256 ownerShares = shares[msg.sender];
        require(ownerShares > 0, "PodOption: you do not have balance to withdraw");

        (strikeToSend, underlyingToSend) = getSellerWithdrawAmounts(msg.sender);

        shares[msg.sender] = 0;
        mintedOptions[msg.sender] = 0;
        totalShares = totalShares.sub(ownerShares);
    }
}
 

pragma solidity 0.6.12;





 
contract PodPutBuilder is IOptionBuilder {
     
    function buildOption(
        string memory name,
        string memory symbol,
        IPodOption.ExerciseType exerciseType,
        address underlyingAsset,
        address strikeAsset,
        uint256 strikePrice,
        uint256 expiration,
        uint256 exerciseWindowSize,
        IConfigurationManager configurationManager
    ) external override returns (IPodOption) {
        PodPut option = new PodPut(
            name,
            symbol,
            exerciseType,
            underlyingAsset,
            strikeAsset,
            strikePrice,
            expiration,
            exerciseWindowSize,
            configurationManager
        );

        return option;
    }
}

 

pragma solidity 0.6.12;



 
contract PodPut is PodOption {
    constructor(
        string memory name,
        string memory symbol,
        IPodOption.ExerciseType exerciseType,
        address underlyingAsset,
        address strikeAsset,
        uint256 strikePrice,
        uint256 expiration,
        uint256 exerciseWindowSize,
        IConfigurationManager configurationManager
    )
        public
        PodOption(
            name,
            symbol,
            IPodOption.OptionType.PUT,
            exerciseType,
            underlyingAsset,
            strikeAsset,
            strikePrice,
            expiration,
            exerciseWindowSize,
            configurationManager
        )
    {}  

     
    function mint(uint256 amountOfOptions, address owner) external override tradeWindow {
        require(amountOfOptions > 0, "PodPut: you can not mint zero options");

        uint256 amountToTransfer = _strikeToTransfer(amountOfOptions);
        _mintOptions(amountOfOptions, amountToTransfer, owner);

        IERC20(strikeAsset()).safeTransferFrom(msg.sender, address(this), amountToTransfer);

        emit Mint(owner, amountOfOptions);
    }

     
    function unmint(uint256 amountOfOptions) external virtual override tradeWindow {
        (uint256 strikeToSend, uint256 underlyingToSend, , uint256 underlyingReserves) = _burnOptions(
            amountOfOptions,
            msg.sender
        );
        require(strikeToSend > 0, "PodPut: amount of options is too low");

         
        IERC20(strikeAsset()).safeTransfer(msg.sender, strikeToSend);

         
        if (underlyingReserves > 0) {
            require(underlyingToSend > 0, "PodPut: amount of options is too low");
            IERC20(underlyingAsset()).safeTransfer(msg.sender, underlyingToSend);
        }

        emit Unmint(msg.sender, amountOfOptions, strikeToSend, underlyingToSend);
    }

     
    function exercise(uint256 amountOfOptions) external virtual override exerciseWindow {
        require(amountOfOptions > 0, "PodPut: you can not exercise zero options");
         
        uint256 amountOfStrikeToTransfer = _strikeToTransfer(amountOfOptions);

         
        _burn(msg.sender, amountOfOptions);

         
        IERC20(underlyingAsset()).safeTransferFrom(msg.sender, address(this), amountOfOptions);

         
        IERC20(strikeAsset()).safeTransfer(msg.sender, amountOfStrikeToTransfer);

        emit Exercise(msg.sender, amountOfOptions);
    }

     
    function withdraw() external virtual override withdrawWindow {
        (uint256 strikeToSend, uint256 underlyingToSend) = _withdraw();

        IERC20(strikeAsset()).safeTransfer(msg.sender, strikeToSend);

        if (underlyingToSend > 0) {
            IERC20(underlyingAsset()).safeTransfer(msg.sender, underlyingToSend);
        }
        emit Withdraw(msg.sender, strikeToSend, underlyingToSend);
    }
}

pragma solidity ^0.6.0;





 
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
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.6.2;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

pragma solidity 0.6.12;

interface IConfigurationManager {
    function setParameter(bytes32 name, uint256 value) external;

    function setEmergencyStop(address emergencyStop) external;

    function setPricingMethod(address pricingMethod) external;

    function setSigmaGuesser(address sigmaGuesser) external;

    function setPriceProvider(address priceProvider) external;

    function setCapProvider(address capProvider) external;

    function setAMMFactory(address ammFactory) external;

    function setOptionFactory(address optionFactory) external;

    function setOptionHelper(address optionHelper) external;

    function getParameter(bytes32 name) external view returns (uint256);

    function getEmergencyStop() external view returns (address);

    function getPricingMethod() external view returns (address);

    function getSigmaGuesser() external view returns (address);

    function getPriceProvider() external view returns (address);

    function getCapProvider() external view returns (address);

    function getAMMFactory() external view returns (address);

    function getOptionFactory() external view returns (address);

    function getOptionHelper() external view returns (address);
}

pragma solidity ^0.6.0;

 
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

 

pragma solidity 0.6.12;

interface ICapProvider {
    function setCap(address target, uint256 value) external;

    function getCap(address target) external view returns (uint256);
}
