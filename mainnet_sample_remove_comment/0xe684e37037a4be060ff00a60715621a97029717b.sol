 

 

 

 

 
pragma solidity ^0.7.1;


 
contract Auth {

     
    VaultParameters public vaultParameters;

    constructor(address _parameters) public {
        vaultParameters = VaultParameters(_parameters);
    }

     
    modifier onlyManager() {
        require(vaultParameters.isManager(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

     
    modifier hasVaultAccess() {
        require(vaultParameters.canModifyVault(msg.sender), "Unit Protocol: AUTH_FAILED");
        _;
    }

     
    modifier onlyVault() {
        require(msg.sender == vaultParameters.vault(), "Unit Protocol: AUTH_FAILED");
        _;
    }
}


 
contract VaultParameters is Auth {

     
    mapping(address => uint) public stabilityFee;

     
    mapping(address => uint) public liquidationFee;

     
    mapping(address => uint) public tokenDebtLimit;

     
    mapping(address => bool) public canModifyVault;

     
    mapping(address => bool) public isManager;

     
    mapping(uint => mapping (address => bool)) public isOracleTypeEnabled;

     
    address payable public vault;

     
    address public foundation;

     
    constructor(address payable _vault, address _foundation) public Auth(address(this)) {
        require(_vault != address(0), "Unit Protocol: ZERO_ADDRESS");
        require(_foundation != address(0), "Unit Protocol: ZERO_ADDRESS");

        isManager[msg.sender] = true;
        vault = _vault;
        foundation = _foundation;
    }

     
    function setManager(address who, bool permit) external onlyManager {
        isManager[who] = permit;
    }

     
    function setFoundation(address newFoundation) external onlyManager {
        require(newFoundation != address(0), "Unit Protocol: ZERO_ADDRESS");
        foundation = newFoundation;
    }

     
    function setCollateral(
        address asset,
        uint stabilityFeeValue,
        uint liquidationFeeValue,
        uint usdpLimit,
        uint[] calldata oracles
    ) external onlyManager {
        setStabilityFee(asset, stabilityFeeValue);
        setLiquidationFee(asset, liquidationFeeValue);
        setTokenDebtLimit(asset, usdpLimit);
        for (uint i=0; i < oracles.length; i++) {
            setOracleType(oracles[i], asset, true);
        }
    }

     
    function setVaultAccess(address who, bool permit) external onlyManager {
        canModifyVault[who] = permit;
    }

     
    function setStabilityFee(address asset, uint newValue) public onlyManager {
        stabilityFee[asset] = newValue;
    }

     
    function setLiquidationFee(address asset, uint newValue) public onlyManager {
        require(newValue <= 100, "Unit Protocol: VALUE_OUT_OF_RANGE");
        liquidationFee[asset] = newValue;
    }

     
    function setOracleType(uint _type, address asset, bool enabled) public onlyManager {
        isOracleTypeEnabled[_type][asset] = enabled;
    }

     
    function setTokenDebtLimit(address asset, uint limit) public onlyManager {
        tokenDebtLimit[asset] = limit;
    }
}

 

 
pragma solidity ^0.7.1;


contract OracleRegistry is Auth {

     
    mapping(address => address) public oracleByAsset;

     
    mapping(uint => address) public oracleByType;

    constructor(address vaultParameters) Auth(vaultParameters) {
        require(vaultParameters != address(0), "Unit Protocol: ZERO_ADDRESS");
    }

     
    function setOracle(address asset, address oracle, uint oracleType) public onlyManager {
        require(asset != address(0) && oracleType != 0, "Unit Protocol: INVALID_ARGS");
        oracleByAsset[asset] = oracle;
        oracleByType[oracleType] = oracle;
    }

}

 

 
pragma solidity ^0.7.1;


interface ERC20Like {
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint8);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function totalSupply() external view returns (uint256);
}

 

 
pragma solidity ^0.7.1;


 
abstract contract OracleSimple {
    function assetToUsd(address asset, uint amount) public virtual view returns (uint);
}


 
abstract contract OracleSimplePoolToken is OracleSimple {
    ChainlinkedOracleSimple public oracleMainAsset;
}


 
abstract contract ChainlinkedOracleSimple is OracleSimple {
    address public WETH;
    function ethToUsd(uint ethAmount) public virtual view returns (uint);
    function assetToEth(address asset, uint amount) public virtual view returns (uint);
}

 

 
pragma solidity ^0.7.1;




interface CurveProvider {
    function get_registry() external view returns (address);
}

interface CurveRegistry {
    function get_pool_from_lp_token(address) external view returns (address);
    function get_n_coins(address) external view returns (uint[2] memory);
}

interface CurvePool {
    function get_virtual_price() external view returns (uint);
    function coins(uint) external view returns (address);
}

 
contract CurveLPOracle is OracleSimple {

    uint public constant Q112 = 2 ** 112;
    uint public constant PRECISION = 1e18;

     
    CurveProvider public immutable curveProvider;
     
    ChainlinkedOracleSimple public immutable chainlinkedOracle;

     
    constructor(address _curveProvider, address _chainlinkedOracle) {
        require(_curveProvider != address(0) && _chainlinkedOracle != address(0), "Unit Protocol: ZERO_ADDRESS");
        curveProvider = CurveProvider(_curveProvider);
        chainlinkedOracle = ChainlinkedOracleSimple(_chainlinkedOracle);
    }

     
    function assetToUsd(address asset, uint amount) public override view returns (uint) {
        if (amount == 0) return 0;
        CurveRegistry cR = CurveRegistry(curveProvider.get_registry());
        CurvePool cP = CurvePool(cR.get_pool_from_lp_token(asset));
        require(address(cP) != address(0), "Unit Protocol: NOT_A_CURVE_LP");
        require(ERC20Like(asset).decimals() == uint8(18), "Unit Protocol: INCORRECT_DECIMALS");

        uint coinsCount = cR.get_n_coins(address(cP))[0];
        require(coinsCount != 0, "Unit Protocol: CURVE_INCORRECT_COINS_COUNT");

        uint minEthCoinPrice_q112;

        for (uint i = 0; i < coinsCount; i++) {
            uint ethCoinPrice_q112 = chainlinkedOracle.assetToEth(cP.coins(i), 1 ether);
            if (i == 0 || ethCoinPrice_q112 < minEthCoinPrice_q112) {
                minEthCoinPrice_q112 = ethCoinPrice_q112;
            }
        }

        uint minUsdCoinPrice_q112 = chainlinkedOracle.ethToUsd(minEthCoinPrice_q112) / 1 ether;

        uint price_q112 = cP.get_virtual_price() * minUsdCoinPrice_q112 / PRECISION;

        return amount * price_q112;
    }

}