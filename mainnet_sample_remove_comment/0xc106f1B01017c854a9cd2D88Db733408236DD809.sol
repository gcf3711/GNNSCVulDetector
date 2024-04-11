 
pragma experimental ABIEncoderV2;


 

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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

 

pragma solidity 0.6.12;






abstract contract FundDeployerOwnerMixin {
    address internal immutable FUND_DEPLOYER;

    modifier onlyFundDeployerOwner() {
        require(
            msg.sender == getOwner(),
            "onlyFundDeployerOwner: Only the FundDeployer owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer) public {
        FUND_DEPLOYER = _fundDeployer;
    }

    
    
    
    function getOwner() public view returns (address owner_) {
        return IFundDeployer(FUND_DEPLOYER).getOwner();
    }

     
     
     

    
    
    function getFundDeployer() external view returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }
}

 

 

pragma solidity 0.6.12;




interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
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





 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name_, string memory symbol_) public {
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
}

 

 

pragma solidity 0.6.12;



interface IFundDeployer {
    enum ReleaseStatus {PreLaunch, Live, Paused}

    function getOwner() external view returns (address);

    function getReleaseStatus() external view returns (ReleaseStatus);

    function isRegisteredVaultCall(address, bytes4) external view returns (bool);
}

 

 

pragma solidity 0.6.12;














contract CurvePriceFeed is IDerivativePriceFeed, FundDeployerOwnerMixin {
    using SafeMath for uint256;

    event DerivativeAdded(
        address indexed derivative,
        address indexed pool,
        address indexed invariantProxyAsset,
        uint256 invariantProxyAssetDecimals
    );

    event DerivativeRemoved(address indexed derivative);

     
     
    struct DerivativeInfo {
        address pool;
        address invariantProxyAsset;
        uint256 invariantProxyAssetDecimals;
    }

    uint256 private constant VIRTUAL_PRICE_UNIT = 10**18;

    address private immutable ADDRESS_PROVIDER;

    mapping(address => DerivativeInfo) private derivativeToInfo;

    constructor(address _fundDeployer, address _addressProvider)
        public
        FundDeployerOwnerMixin(_fundDeployer)
    {
        ADDRESS_PROVIDER = _addressProvider;
    }

    
    
    
    
    
    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        public
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        DerivativeInfo memory derivativeInfo = derivativeToInfo[_derivative];
        require(
            derivativeInfo.pool != address(0),
            "calcUnderlyingValues: _derivative is not supported"
        );

        underlyings_ = new address[](1);
        underlyings_[0] = derivativeInfo.invariantProxyAsset;

        underlyingAmounts_ = new uint256[](1);
        if (derivativeInfo.invariantProxyAssetDecimals == 18) {
            underlyingAmounts_[0] = _derivativeAmount
                .mul(ICurveLiquidityPool(derivativeInfo.pool).get_virtual_price())
                .div(VIRTUAL_PRICE_UNIT);
        } else {
            underlyingAmounts_[0] = _derivativeAmount
                .mul(ICurveLiquidityPool(derivativeInfo.pool).get_virtual_price())
                .mul(10**derivativeInfo.invariantProxyAssetDecimals)
                .div(VIRTUAL_PRICE_UNIT)
                .div(VIRTUAL_PRICE_UNIT);
        }

        return (underlyings_, underlyingAmounts_);
    }

    
    
    
    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return derivativeToInfo[_asset].pool != address(0);
    }

     
     
     

    
    
    
     
    function addDerivatives(
        address[] calldata _derivatives,
        address[] calldata _invariantProxyAssets
    ) external onlyFundDeployerOwner {
        require(_derivatives.length > 0, "addDerivatives: Empty _derivatives");
        require(
            _derivatives.length == _invariantProxyAssets.length,
            "addDerivatives: Unequal arrays"
        );

        ICurveRegistry curveRegistryContract = ICurveRegistry(
            ICurveAddressProvider(ADDRESS_PROVIDER).get_registry()
        );

        for (uint256 i; i < _derivatives.length; i++) {
            require(_derivatives[i] != address(0), "addDerivatives: Empty derivative");
            require(
                _invariantProxyAssets[i] != address(0),
                "addDerivatives: Empty invariantProxyAsset"
            );
            require(!isSupportedAsset(_derivatives[i]), "addDerivatives: Value already set");

             
            address pool = curveRegistryContract.get_pool_from_lp_token(_derivatives[i]);

             
            if (pool == address(0)) {
                 
                 
                 
                pool = curveRegistryContract.get_pool_from_lp_token(
                    ICurveLiquidityGaugeToken(_derivatives[i]).lp_token()
                );

                 
                require(
                    pool != address(0),
                    "addDerivatives: Not a valid LP token or liquidity gauge token"
                );
            }

            uint256 invariantProxyAssetDecimals = ERC20(_invariantProxyAssets[i]).decimals();
            derivativeToInfo[_derivatives[i]] = DerivativeInfo({
                pool: pool,
                invariantProxyAsset: _invariantProxyAssets[i],
                invariantProxyAssetDecimals: invariantProxyAssetDecimals
            });

             
            (, uint256[] memory underlyingAmounts) = calcUnderlyingValues(
                _derivatives[i],
                1 ether
            );
            require(underlyingAmounts[0] > 0, "addDerivatives: could not calculate valid price");

            emit DerivativeAdded(
                _derivatives[i],
                pool,
                _invariantProxyAssets[i],
                invariantProxyAssetDecimals
            );
        }
    }

    
    
    function removeDerivatives(address[] calldata _derivatives) external onlyFundDeployerOwner {
        require(_derivatives.length > 0, "removeDerivatives: Empty _derivatives");
        for (uint256 i; i < _derivatives.length; i++) {
            require(_derivatives[i] != address(0), "removeDerivatives: Empty derivative");
            require(isSupportedAsset(_derivatives[i]), "removeDerivatives: Value is not set");

            delete derivativeToInfo[_derivatives[i]];

            emit DerivativeRemoved(_derivatives[i]);
        }
    }

     
     
     

    
    
    function getAddressProvider() external view returns (address addressProvider_) {
        return ADDRESS_PROVIDER;
    }

    
    
    
    function getDerivativeInfo(address _derivative)
        external
        view
        returns (DerivativeInfo memory derivativeInfo_)
    {
        return derivativeToInfo[_derivative];
    }
}

 

 

pragma solidity 0.6.12;



interface ICurveAddressProvider {
    function get_address(uint256) external view returns (address);

    function get_registry() external view returns (address);
}

 

 

pragma solidity 0.6.12;




interface ICurveLiquidityGaugeToken {
    function lp_token() external view returns (address);
}

 

 

pragma solidity 0.6.12;



interface ICurveLiquidityPool {
    function coins(uint256) external view returns (address);

    function get_virtual_price() external view returns (uint256);
}

 

 

pragma solidity 0.6.12;



interface ICurveRegistry {
    function get_gauges(address) external view returns (address[10] memory, int128[10] memory);

    function get_lp_token(address) external view returns (address);

    function get_pool_from_lp_token(address) external view returns (address);
}
