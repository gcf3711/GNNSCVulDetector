 
pragma experimental ABIEncoderV2;

 

 

pragma solidity 0.6.12;


 


struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

library DataTypes {
     
    struct ReserveData {
         
        ReserveConfigurationMap configuration;
         
        uint128 liquidityIndex;
         
        uint128 variableBorrowIndex;
         
        uint128 currentLiquidityRate;
         
        uint128 currentVariableBorrowRate;
         
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
         
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
         
        address interestRateStrategyAddress;
         
        uint8 id;
    }

    struct ReserveConfigurationMap {
         
         
         
         
         
         
         
         
         
         
        uint256 data;
    }

    struct UserConfigurationMap {
        uint256 data;
    }

    enum InterestRateMode {NONE, STABLE, VARIABLE}
}

 

interface IAaveIncentivesController {
     
    function getRewardsBalance(address[] calldata assets, address user)
        external
        view
        returns (uint256);

     
    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external returns (uint256);

     
    function claimRewardsOnBehalf(
        address[] calldata assets,
        uint256 amount,
        address user,
        address to
    ) external returns (uint256);

     
    function getUserUnclaimedRewards(address user)
        external
        view
        returns (uint256);

     
    function REWARD_TOKEN() external view returns (address);

    function getDistributionEnd() external view returns (uint256);

    function getAssetData(address asset)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}

 

interface IERC3156FlashBorrower {
     
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

 

 
interface ILendingPoolAddressesProvider {
    event MarketIdSet(string newMarketId);
    event LendingPoolUpdated(address indexed newAddress);
    event ConfigurationAdminUpdated(address indexed newAddress);
    event EmergencyAdminUpdated(address indexed newAddress);
    event LendingPoolConfiguratorUpdated(address indexed newAddress);
    event LendingPoolCollateralManagerUpdated(address indexed newAddress);
    event PriceOracleUpdated(address indexed newAddress);
    event LendingRateOracleUpdated(address indexed newAddress);
    event ProxyCreated(bytes32 id, address indexed newAddress);
    event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

    function getMarketId() external view returns (string memory);

    function setMarketId(string calldata marketId) external;

    function setAddress(bytes32 id, address newAddress) external;

    function setAddressAsProxy(bytes32 id, address impl) external;

    function getAddress(bytes32 id) external view returns (address);

    function getLendingPool() external view returns (address);

    function setLendingPoolImpl(address pool) external;

    function getLendingPoolConfigurator() external view returns (address);

    function setLendingPoolConfiguratorImpl(address configurator) external;

    function getLendingPoolCollateralManager() external view returns (address);

    function setLendingPoolCollateralManager(address manager) external;

    function getPoolAdmin() external view returns (address);

    function setPoolAdmin(address admin) external;

    function getEmergencyAdmin() external view returns (address);

    function setEmergencyAdmin(address admin) external;

    function getPriceOracle() external view returns (address);

    function setPriceOracle(address priceOracle) external;

    function getLendingRateOracle() external view returns (address);

    function setLendingRateOracle(address lendingRateOracle) external;
}

 

interface IOptionalERC20 {
    function decimals() external view returns (uint8);
}

 

interface IPriceOracle {
    function getAssetPrice(address _asset) external view returns (uint256);

    function getAssetsPrices(address[] calldata _assets)
        external
        view
        returns (uint256[] memory);

    function getSourceOfAsset(address _asset) external view returns (address);

    function getFallbackOracle() external view returns (address);
}

 

interface IScaledBalanceToken {
     
    function scaledBalanceOf(address user) external view returns (uint256);

     
    function getScaledUserBalanceAndSupply(address user)
        external
        view
        returns (uint256, uint256);

     
    function scaledTotalSupply() external view returns (uint256);
}

 

interface IStakedAave {
    function stake(address to, uint256 amount) external;

    function redeem(address to, uint256 amount) external;

    function cooldown() external;

    function claimRewards(address to, uint256 amount) external;

    function getTotalRewardsBalance(address) external view returns (uint256);

    function COOLDOWN_SECONDS() external view returns (uint256);

    function stakersCooldowns(address) external view returns (uint256);

    function UNSTAKE_WINDOW() external view returns (uint256);
}

 

interface IUni{
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

 



interface IUniswapV3SwapCallback {
    
    
     
     
    
     
    
     
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

 

 
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

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

 

interface HealthCheck {
    function check(
        uint256 profit,
        uint256 loss,
        uint256 debtPayment,
        uint256 debtOutstanding,
        uint256 totalDebt
    ) external view returns (bool);
}

 

interface IERC3156FlashLender {
     
    function maxFlashLoan(address token) external view returns (uint256);

     
    function flashFee(address token, uint256 amount)
        external
        view
        returns (uint256);

     
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

 

interface ILendingPool {
     
    event Deposit(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referral
    );

     
    event Withdraw(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256 amount
    );

     
    event Borrow(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint256 borrowRateMode,
        uint256 borrowRate,
        uint16 indexed referral
    );

     
    event Repay(
        address indexed reserve,
        address indexed user,
        address indexed repayer,
        uint256 amount
    );

     
    event Swap(address indexed reserve, address indexed user, uint256 rateMode);

     
    event ReserveUsedAsCollateralEnabled(
        address indexed reserve,
        address indexed user
    );

     
    event ReserveUsedAsCollateralDisabled(
        address indexed reserve,
        address indexed user
    );

     
    event RebalanceStableBorrowRate(
        address indexed reserve,
        address indexed user
    );

     
    event FlashLoan(
        address indexed target,
        address indexed initiator,
        address indexed asset,
        uint256 amount,
        uint256 premium,
        uint16 referralCode
    );

     
    event Paused();

     
    event Unpaused();

     
    event LiquidationCall(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed user,
        uint256 debtToCover,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        bool receiveAToken
    );

     
    event ReserveDataUpdated(
        address indexed reserve,
        uint256 liquidityRate,
        uint256 stableBorrowRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );

     
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

     
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

     
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

     
    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);

     
    function swapBorrowRateMode(address asset, uint256 rateMode) external;

     
    function rebalanceStableBorrowRate(address asset, address user) external;

     
    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral)
        external;

     
    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveAToken
    ) external;

     
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;

     
    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );

    function initReserve(
        address reserve,
        address aTokenAddress,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external;

    function setReserveInterestRateStrategyAddress(
        address reserve,
        address rateStrategyAddress
    ) external;

    function setConfiguration(address reserve, uint256 configuration) external;

     
    function getConfiguration(address asset)
        external
        view
        returns (DataTypes.ReserveConfigurationMap memory);

     
    function getUserConfiguration(address user)
        external
        view
        returns (DataTypes.UserConfigurationMap memory);

     
    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);

     
    function getReserveNormalizedVariableDebt(address asset)
        external
        view
        returns (uint256);

     
    function getReserveData(address asset)
        external
        view
        returns (DataTypes.ReserveData memory);

    function finalizeTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256 balanceFromAfter,
        uint256 balanceToBefore
    ) external;

    function getReservesList() external view returns (address[] memory);

    function getAddressesProvider()
        external
        view
        returns (ILendingPoolAddressesProvider);

    function setPause(bool val) external;

    function paused() external view returns (bool);
}

 

interface IProtocolDataProvider {
    struct TokenData {
        string symbol;
        address tokenAddress;
    }

    function ADDRESSES_PROVIDER()
        external
        view
        returns (ILendingPoolAddressesProvider);

    function getAllReservesTokens() external view returns (TokenData[] memory);

    function getAllATokens() external view returns (TokenData[] memory);

    function getReserveConfigurationData(address asset)
        external
        view
        returns (
            uint256 decimals,
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            uint256 reserveFactor,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive,
            bool isFrozen
        );

    function getReserveData(address asset)
        external
        view
        returns (
            uint256 availableLiquidity,
            uint256 totalStableDebt,
            uint256 totalVariableDebt,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            uint40 lastUpdateTimestamp
        );

    function getUserReserveData(address asset, address user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentStableDebt,
            uint256 currentVariableDebt,
            uint256 principalStableDebt,
            uint256 scaledVariableDebt,
            uint256 stableBorrowRate,
            uint256 liquidityRate,
            uint40 stableRateLastUpdated,
            bool usageAsCollateralEnabled
        );

    function getReserveTokensAddresses(address asset)
        external
        view
        returns (
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress
        );
}

 



interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}

 

 
interface IVariableDebtToken is IERC20, IScaledBalanceToken {
     
    event Mint(
        address indexed from,
        address indexed onBehalfOf,
        uint256 value,
        uint256 index
    );

     
    function mint(
        address user,
        address onBehalfOf,
        uint256 amount,
        uint256 index
    ) external returns (bool);

     
    event Burn(address indexed user, uint256 amount, uint256 index);

     
    function burn(
        address user,
        uint256 amount,
        uint256 index
    ) external;

     
    function getIncentivesController()
        external
        view
        returns (IAaveIncentivesController);
}

 

 
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
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

interface VaultAPI is IERC20 {
    function name() external view returns (string calldata);

    function symbol() external view returns (string calldata);

    function decimals() external view returns (uint256);

    function apiVersion() external pure returns (string memory);

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        bytes calldata signature
    ) external returns (bool);

     
    function deposit() external returns (uint256);

    function deposit(uint256 amount) external returns (uint256);

    function deposit(uint256 amount, address recipient) external returns (uint256);

     
    function withdraw() external returns (uint256);

    function withdraw(uint256 maxShares) external returns (uint256);

    function withdraw(uint256 maxShares, address recipient) external returns (uint256);

    function token() external view returns (address);

    function strategies(address _strategy) external view returns (StrategyParams memory);

    function pricePerShare() external view returns (uint256);

    function totalAssets() external view returns (uint256);

    function depositLimit() external view returns (uint256);

    function maxAvailableShares() external view returns (uint256);

     
    function creditAvailable() external view returns (uint256);

     
    function debtOutstanding() external view returns (uint256);

     
    function expectedReturn() external view returns (uint256);

     
    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);

     
    function revokeStrategy() external;

     
    function governance() external view returns (address);

     
    function management() external view returns (address);

     
    function guardian() external view returns (address);
}

 

 
interface IInitializableAToken {
     
    event Initialized(
        address indexed underlyingAsset,
        address indexed pool,
        address treasury,
        address incentivesController,
        uint8 aTokenDecimals,
        string aTokenName,
        string aTokenSymbol,
        bytes params
    );

     
    function initialize(
        ILendingPool pool,
        address treasury,
        address underlyingAsset,
        IAaveIncentivesController incentivesController,
        uint8 aTokenDecimals,
        string calldata aTokenName,
        string calldata aTokenSymbol,
        bytes calldata params
    ) external;
}

 

 

abstract contract BaseStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string public metadataURI;

     
    bool public doHealthCheck;
    address public healthCheck;

     
    function apiVersion() public pure returns (string memory) {
        return "0.4.3";
    }

     
    function name() external view virtual returns (string memory);

     
    function delegatedAssets() external view virtual returns (uint256) {
        return 0;
    }

    VaultAPI public vault;
    address public strategist;
    address public rewards;
    address public keeper;

    IERC20 public want;

     
    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);

    event UpdatedStrategist(address newStrategist);

    event UpdatedKeeper(address newKeeper);

    event UpdatedRewards(address rewards);

    event UpdatedMinReportDelay(uint256 delay);

    event UpdatedMaxReportDelay(uint256 delay);

    event UpdatedProfitFactor(uint256 profitFactor);

    event UpdatedDebtThreshold(uint256 debtThreshold);

    event EmergencyExitEnabled();

    event UpdatedMetadataURI(string metadataURI);

     
     
    uint256 public minReportDelay;

     
     
    uint256 public maxReportDelay;

     
     
    uint256 public profitFactor;

     
     
    uint256 public debtThreshold;

     
    bool public emergencyExit;

     
    modifier onlyAuthorized() {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyEmergencyAuthorized() {
        require(
            msg.sender == strategist || msg.sender == governance() || msg.sender == vault.guardian() || msg.sender == vault.management(),
            "!authorized"
        );
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "!strategist");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyKeepers() {
        require(
            msg.sender == keeper ||
                msg.sender == strategist ||
                msg.sender == governance() ||
                msg.sender == vault.guardian() ||
                msg.sender == vault.management(),
            "!authorized"
        );
        _;
    }

    modifier onlyVaultManagers() {
        require(msg.sender == vault.management() || msg.sender == governance(), "!authorized");
        _;
    }

    constructor(address _vault) public {
        _initialize(_vault, msg.sender, msg.sender, msg.sender);
    }

     
    function _initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) internal {
        require(address(want) == address(0), "Strategy already initialized");

        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.safeApprove(_vault, uint256(-1));  
        strategist = _strategist;
        rewards = _rewards;
        keeper = _keeper;

         
        minReportDelay = 0;
        maxReportDelay = 86400;
        profitFactor = 100;
        debtThreshold = 0;

        vault.approve(rewards, uint256(-1));  
    }

    function setHealthCheck(address _healthCheck) external onlyVaultManagers {
        healthCheck = _healthCheck;
    }

    function setDoHealthCheck(bool _doHealthCheck) external onlyVaultManagers {
        doHealthCheck = _doHealthCheck;
    }

     
    function setStrategist(address _strategist) external onlyAuthorized {
        require(_strategist != address(0));
        strategist = _strategist;
        emit UpdatedStrategist(_strategist);
    }

     
    function setKeeper(address _keeper) external onlyAuthorized {
        require(_keeper != address(0));
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

     
    function setRewards(address _rewards) external onlyStrategist {
        require(_rewards != address(0));
        vault.approve(rewards, 0);
        rewards = _rewards;
        vault.approve(rewards, uint256(-1));
        emit UpdatedRewards(_rewards);
    }

     
    function setMinReportDelay(uint256 _delay) external onlyAuthorized {
        minReportDelay = _delay;
        emit UpdatedMinReportDelay(_delay);
    }

     
    function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
        maxReportDelay = _delay;
        emit UpdatedMaxReportDelay(_delay);
    }

     
    function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
        profitFactor = _profitFactor;
        emit UpdatedProfitFactor(_profitFactor);
    }

     
    function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
        debtThreshold = _debtThreshold;
        emit UpdatedDebtThreshold(_debtThreshold);
    }

     
    function setMetadataURI(string calldata _metadataURI) external onlyAuthorized {
        metadataURI = _metadataURI;
        emit UpdatedMetadataURI(_metadataURI);
    }

     
    function governance() internal view returns (address) {
        return vault.governance();
    }

     
    function ethToWant(uint256 _amtInWei) public view virtual returns (uint256);

     
    function estimatedTotalAssets() public view virtual returns (uint256);

     
    function isActive() public view returns (bool) {
        return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
    }

     
    function prepareReturn(uint256 _debtOutstanding)
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        );

     
    function adjustPosition(uint256 _debtOutstanding) internal virtual;

     
    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

     

    function liquidateAllPositions() internal virtual returns (uint256 _amountFreed);

     
    function tendTrigger(uint256 callCostInWei) public view virtual returns (bool) {
         
         
         
         
         

        return false;
    }

     
    function tend() external onlyKeepers {
         
        adjustPosition(vault.debtOutstanding());
    }

     
    function harvestTrigger(uint256 callCostInWei) public view virtual returns (bool) {
        uint256 callCost = ethToWant(callCostInWei);
        StrategyParams memory params = vault.strategies(address(this));

         
        if (params.activation == 0) return false;

         
        if (block.timestamp.sub(params.lastReport) < minReportDelay) return false;

         
        if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

         
         
         
         
         
        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

         
        uint256 total = estimatedTotalAssets();
         
        if (total.add(debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total.sub(params.totalDebt);  

         
         
        uint256 credit = vault.creditAvailable();
        return (profitFactor.mul(callCost) < credit.add(profit));
    }

     
    function harvest() external onlyKeepers {
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = vault.debtOutstanding();
        uint256 debtPayment = 0;
        if (emergencyExit) {
             
            uint256 amountFreed = liquidateAllPositions();
            if (amountFreed < debtOutstanding) {
                loss = debtOutstanding.sub(amountFreed);
            } else if (amountFreed > debtOutstanding) {
                profit = amountFreed.sub(debtOutstanding);
            }
            debtPayment = debtOutstanding.sub(loss);
        } else {
             
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }

         
         
         
        uint256 totalDebt = vault.strategies(address(this)).totalDebt;
        debtOutstanding = vault.report(profit, loss, debtPayment);

         
        adjustPosition(debtOutstanding);

         
        if (doHealthCheck && healthCheck != address(0)) {
            require(HealthCheck(healthCheck).check(profit, loss, debtPayment, debtOutstanding, totalDebt), "!healthcheck");
        } else {
            doHealthCheck = true;
        }

        emit Harvested(profit, loss, debtPayment, debtOutstanding);
    }

     
    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
         
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
         
        want.safeTransfer(msg.sender, amountFreed);
         
    }

     
    function prepareMigration(address _newStrategy) internal virtual;

     
    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault));
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

     
    function setEmergencyExit() external onlyEmergencyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

     
    function protectedTokens() internal view virtual returns (address[] memory);

     
    function sweep(address _token) external onlyGovernance {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(governance(), IERC20(_token).balanceOf(address(this)));
    }
}

 

interface IAToken is IERC20, IScaledBalanceToken, IInitializableAToken {
     
    event Mint(address indexed from, uint256 value, uint256 index);

     
    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external returns (bool);

     
    event Burn(
        address indexed from,
        address indexed target,
        uint256 value,
        uint256 index
    );

     
    event BalanceTransfer(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 index
    );

     
    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external;

     
    function mintToTreasury(uint256 amount, uint256 index) external;

     
    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external;

     
    function transferUnderlyingTo(address user, uint256 amount)
        external
        returns (uint256);

     
    function handleRepayment(address user, uint256 amount) external;

     
    function getIncentivesController()
        external
        view
        returns (IAaveIncentivesController);

     
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}

 

library FlashMintLib {
    using SafeMath for uint256;
    event Leverage(
        uint256 amountRequested,
        uint256 amountUsed,
        uint256 requiredDAI,
        uint256 amountToCloseLTVGap,
        bool deficit,
        address flashLoan
    );

    address public constant LENDER = 0x1EB4CF3A948E7D72A198fe073cCb8C7a948cD853;
    uint256 private constant DAI_DECIMALS = 1e18;
    uint256 private constant COLLAT_RATIO_PRECISION = 1 ether;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IAToken public constant ADAI =
        IAToken(0x028171bCA77440897B824Ca71D1c56caC55b68A3);
    IProtocolDataProvider private constant protocolDataProvider =
        IProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);
    ILendingPool private constant lendingPool =
        ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    bytes32 public constant CALLBACK_SUCCESS =
        keccak256("ERC3156FlashBorrower.onFlashLoan");

    uint16 private constant referral = 7;  

    function doFlashMint(
        bool deficit,
        uint256 amountDesired,
        address token,
        uint256 collatRatioDAI,
        uint256 depositToCloseLTVGap
    ) public returns (uint256 amount) {
        if (amountDesired == 0) {
            return 0;
        }
        amount = amountDesired;
        address dai = DAI;

         
        uint256 requiredDAI;
        {
            requiredDAI = _toDAI(amount, token).mul(COLLAT_RATIO_PRECISION).div(
                collatRatioDAI
            );

            uint256 requiredDAIToCloseLTVGap = 0;
            if (depositToCloseLTVGap > 0) {
                requiredDAIToCloseLTVGap = _toDAI(depositToCloseLTVGap, token);
                requiredDAI = requiredDAI.add(requiredDAIToCloseLTVGap);
            }

            uint256 _maxLiquidity = maxLiquidity();
            if (requiredDAI > _maxLiquidity) {
                requiredDAI = _maxLiquidity;
                 
                amount = _fromDAI(
                    requiredDAI.sub(requiredDAIToCloseLTVGap),
                    token
                )
                    .mul(collatRatioDAI)
                    .div(COLLAT_RATIO_PRECISION);
            }
        }

        bytes memory data = abi.encode(deficit, amount);
        uint256 _fee = IERC3156FlashLender(LENDER).flashFee(dai, requiredDAI);
         
        require(_fee == 0);
        uint256 _allowance =
            IERC20(dai).allowance(address(this), address(LENDER));
        if (_allowance < requiredDAI) {
            IERC20(dai).approve(address(LENDER), 0);
            IERC20(dai).approve(address(LENDER), type(uint256).max);
        }
        IERC3156FlashLender(LENDER).flashLoan(
            IERC3156FlashBorrower(address(this)),
            dai,
            requiredDAI,
            data
        );

        emit Leverage(
            amountDesired,
            amount,
            requiredDAI,
            depositToCloseLTVGap,
            deficit,
            LENDER
        );

        return amount;  
    }

    function loanLogic(
        bool deficit,
        uint256 amount,
        uint256 amountFlashmint,
        address want
    ) public returns (bytes32) {
        address dai = DAI;
        bool isDai = (want == dai);

        ILendingPool lp = lendingPool;

        if (isDai) {
            if (deficit) {
                lp.deposit(
                    dai,
                    amountFlashmint.sub(amount),
                    address(this),
                    referral
                );
                lp.repay(
                    dai,
                    IERC20(dai).balanceOf(address(this)),
                    2,
                    address(this)
                );
                lp.withdraw(dai, amountFlashmint, address(this));
            } else {
                lp.deposit(
                    dai,
                    IERC20(dai).balanceOf(address(this)),
                    address(this),
                    referral
                );
                lp.borrow(dai, amount, 2, referral, address(this));
                lp.withdraw(dai, amountFlashmint.sub(amount), address(this));
            }
        } else {
             
            lp.deposit(dai, amountFlashmint, address(this), referral);

            if (deficit) {
                 
                lp.withdraw(want, amount, address(this));
                lp.repay(
                    want,
                    IERC20(want).balanceOf(address(this)),
                    2,
                    address(this)
                );
            } else {
                 
                lp.borrow(want, amount, 2, referral, address(this));
                lp.deposit(
                    want,
                    IERC20(want).balanceOf(address(this)),
                    address(this),
                    referral
                );
            }
             
            lp.withdraw(dai, amountFlashmint, address(this));
        }

        return CALLBACK_SUCCESS;
    }

    function _priceOracle() internal view returns (IPriceOracle) {
        return
            IPriceOracle(
                protocolDataProvider.ADDRESSES_PROVIDER().getPriceOracle()
            );
    }

    function _toDAI(uint256 _amount, address asset)
        internal
        view
        returns (uint256)
    {
        address dai = DAI;
        if (
            _amount == 0 || _amount == type(uint256).max || asset == dai  
        ) {
            return _amount;
        }

        if (asset == WETH) {
            return
                _amount
                    .mul(uint256(10)**uint256(IOptionalERC20(dai).decimals()))
                    .div(_priceOracle().getAssetPrice(dai));
        }

        address[] memory tokens = new address[](2);
        tokens[0] = asset;
        tokens[1] = dai;
        uint256[] memory prices = _priceOracle().getAssetsPrices(tokens);

        uint256 ethPrice =
            _amount.mul(prices[0]).div(
                uint256(10)**uint256(IOptionalERC20(asset).decimals())
            );
        return ethPrice.mul(DAI_DECIMALS).div(prices[1]);
    }

    function _fromDAI(uint256 _amount, address asset)
        internal
        view
        returns (uint256)
    {
        address dai = DAI;
        if (
            _amount == 0 || _amount == type(uint256).max || asset == dai  
        ) {
            return _amount;
        }

        if (asset == WETH) {
            return
                _amount.mul(_priceOracle().getAssetPrice(dai)).div(
                    uint256(10)**uint256(IOptionalERC20(dai).decimals())
                );
        }

        address[] memory tokens = new address[](2);
        tokens[0] = asset;
        tokens[1] = dai;
        uint256[] memory prices = _priceOracle().getAssetsPrices(tokens);

        uint256 ethPrice = _amount.mul(prices[1]).div(DAI_DECIMALS);

        return
            ethPrice
                .mul(uint256(10)**uint256(IOptionalERC20(asset).decimals()))
                .div(prices[0]);
    }

    function maxLiquidity() public view returns (uint256) {
        return IERC3156FlashLender(LENDER).maxFlashLoan(DAI);
    }
}

 

contract Strategy is BaseStrategy, IERC3156FlashBorrower {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

     
    IProtocolDataProvider private constant protocolDataProvider =
        IProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);
    IAaveIncentivesController private constant incentivesController =
        IAaveIncentivesController(0xd784927Ff2f95ba542BfC824c8a8a98F3495f6b5);
    ILendingPool private constant lendingPool =
        ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

     
    address private constant aave = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    IStakedAave private constant stkAave =
        IStakedAave(0x4da27a545c0c5B758a6BA100e3a049001de870f5);
    address private constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

     
    IAToken public aToken;
    IVariableDebtToken public debtToken;

     
     
     
     
    enum CooldownStatus {None, Claim, Initiated}

     
    IUni private constant UNI_V2_ROUTER =
        IUni(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUni private constant SUSHI_V2_ROUTER =
        IUni(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    ISwapRouter private constant UNI_V3_ROUTER =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

     
    uint256 private constant DEFAULT_COLLAT_TARGET_MARGIN = 0.02 ether;
    uint256 private constant DEFAULT_COLLAT_MAX_MARGIN = 0.005 ether;
    uint256 private constant LIQUIDATION_WARNING_THRESHOLD = 0.01 ether;

    uint256 public maxBorrowCollatRatio;  
    uint256 public targetCollatRatio;  
    uint256 public maxCollatRatio;  
    uint256 public daiBorrowCollatRatio;  

    uint8 public maxIterations;
    bool public isFlashMintActive;
    bool public withdrawCheck;

    uint256 public minWant;
    uint256 public minRatio;
    uint256 public minRewardToSell;

    enum SwapRouter {UniV2, SushiV2, UniV3}
    SwapRouter public swapRouter = SwapRouter.UniV2;  

    bool public sellStkAave;
    bool public cooldownStkAave;
    uint256 public maxStkAavePriceImpactBps;

    uint24 public stkAaveToAaveSwapFee;
    uint24 public aaveToWethSwapFee;
    uint24 public wethToWantSwapFee;

    bool private alreadyAdjusted;  

    uint16 private constant referral = 7;  

    uint256 private constant MAX_BPS = 1e4;
    uint256 private constant BPS_WAD_RATIO = 1e14;
    uint256 private constant COLLATERAL_RATIO_PRECISION = 1 ether;
    uint256 private constant PESSIMISM_FACTOR = 1000;
    uint256 private DECIMALS;

    constructor(address _vault) public BaseStrategy(_vault) {
        _initializeThis();
    }

    function initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) external {
        _initialize(_vault, _strategist, _rewards, _keeper);
        _initializeThis();
    }

    function _initializeThis() internal {
        require(address(aToken) == address(0));

         
        maxIterations = 6;
        isFlashMintActive = true;
        withdrawCheck = false;

         
        minWant = 100;
        minRatio = 0.005 ether;
        minRewardToSell = 1e15;

         
        swapRouter = SwapRouter.UniV2;
        sellStkAave = true;
        cooldownStkAave = false;
        maxStkAavePriceImpactBps = 500;

        stkAaveToAaveSwapFee = 3000;
        aaveToWethSwapFee = 3000;
        wethToWantSwapFee = 3000;

        alreadyAdjusted = false;

         
        (address _aToken, , address _debtToken) =
            protocolDataProvider.getReserveTokensAddresses(address(want));
        aToken = IAToken(_aToken);
        debtToken = IVariableDebtToken(_debtToken);

         
        (uint256 ltv, uint256 liquidationThreshold) =
            getProtocolCollatRatios(address(want));
        targetCollatRatio = liquidationThreshold.sub(
            DEFAULT_COLLAT_TARGET_MARGIN
        );
        maxCollatRatio = liquidationThreshold.sub(DEFAULT_COLLAT_MAX_MARGIN);
        maxBorrowCollatRatio = ltv.sub(DEFAULT_COLLAT_MAX_MARGIN);
        (uint256 daiLtv, ) = getProtocolCollatRatios(dai);
        daiBorrowCollatRatio = daiLtv.sub(DEFAULT_COLLAT_MAX_MARGIN);

        DECIMALS = 10**vault.decimals();

         
        approveMaxSpend(address(want), address(lendingPool));
        approveMaxSpend(address(aToken), address(lendingPool));

         
        address _dai = dai;
        if (address(want) != _dai) {
            approveMaxSpend(_dai, address(lendingPool));
        }
        approveMaxSpend(_dai, FlashMintLib.LENDER);

         
        approveMaxSpend(address(stkAave), address(UNI_V3_ROUTER));
        approveMaxSpend(aave, address(UNI_V2_ROUTER));
        approveMaxSpend(aave, address(SUSHI_V2_ROUTER));
        approveMaxSpend(aave, address(UNI_V3_ROUTER));
    }

     
    function setCollateralTargets(
        uint256 _targetCollatRatio,
        uint256 _maxCollatRatio,
        uint256 _maxBorrowCollatRatio,
        uint256 _daiBorrowCollatRatio
    ) external onlyVaultManagers {
        (uint256 ltv, uint256 liquidationThreshold) =
            getProtocolCollatRatios(address(want));
        (uint256 daiLtv, ) = getProtocolCollatRatios(dai);
        require(_targetCollatRatio < liquidationThreshold);
        require(_maxCollatRatio < liquidationThreshold);
        require(_targetCollatRatio < _maxCollatRatio);
        require(_maxBorrowCollatRatio < ltv);
        require(_daiBorrowCollatRatio < daiLtv);

        targetCollatRatio = _targetCollatRatio;
        maxCollatRatio = _maxCollatRatio;
        maxBorrowCollatRatio = _maxBorrowCollatRatio;
        daiBorrowCollatRatio = _daiBorrowCollatRatio;
    }

    function setIsFlashMintActive(bool _isFlashMintActive)
        external
        onlyVaultManagers
    {
        isFlashMintActive = _isFlashMintActive;
    }

    function setWithdrawCheck(bool _withdrawCheck) external onlyVaultManagers {
        withdrawCheck = _withdrawCheck;
    }

    function setMinsAndMaxs(
        uint256 _minWant,
        uint256 _minRatio,
        uint8 _maxIterations
    ) external onlyVaultManagers {
        require(_minRatio < maxBorrowCollatRatio);
        require(_maxIterations > 0 && _maxIterations < 16);
        minWant = _minWant;
        minRatio = _minRatio;
        maxIterations = _maxIterations;
    }

    function setRewardBehavior(
        SwapRouter _swapRouter,
        bool _sellStkAave,
        bool _cooldownStkAave,
        uint256 _minRewardToSell,
        uint256 _maxStkAavePriceImpactBps,
        uint24 _stkAaveToAaveSwapFee,
        uint24 _aaveToWethSwapFee,
        uint24 _wethToWantSwapFee
    ) external onlyVaultManagers {
        require(
            _swapRouter == SwapRouter.UniV2 ||
                _swapRouter == SwapRouter.SushiV2 ||
                _swapRouter == SwapRouter.UniV3
        );
        require(_maxStkAavePriceImpactBps <= MAX_BPS);
        swapRouter = _swapRouter;
        sellStkAave = _sellStkAave;
        cooldownStkAave = _cooldownStkAave;
        minRewardToSell = _minRewardToSell;
        maxStkAavePriceImpactBps = _maxStkAavePriceImpactBps;
        stkAaveToAaveSwapFee = _stkAaveToAaveSwapFee;
        aaveToWethSwapFee = _aaveToWethSwapFee;
        wethToWantSwapFee = _wethToWantSwapFee;
    }

    function name() external view override returns (string memory) {
        return "StrategyGenLevAAVE-Flashmint";
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        uint256 balanceExcludingRewards =
            balanceOfWant().add(getCurrentSupply());

         
        if (balanceExcludingRewards < minWant) {
            return balanceExcludingRewards;
        }

        uint256 rewards =
            estimatedRewardsInWant().mul(MAX_BPS.sub(PESSIMISM_FACTOR)).div(
                MAX_BPS
            );
        return balanceExcludingRewards.add(rewards);
    }

    function estimatedRewardsInWant() public view returns (uint256) {
        uint256 aaveBalance = balanceOfAave();
        uint256 stkAaveBalance = balanceOfStkAave();

        uint256 pendingRewards =
            incentivesController.getRewardsBalance(
                getAaveAssets(),
                address(this)
            );
        uint256 stkAaveDiscountFactor = MAX_BPS.sub(maxStkAavePriceImpactBps);
        uint256 combinedStkAave =
            pendingRewards.add(stkAaveBalance).mul(stkAaveDiscountFactor).div(
                MAX_BPS
            );

        return tokenToWant(aave, aaveBalance.add(combinedStkAave));
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {
         
        _claimAndSellRewards();

         
        uint256 totalDebt = vault.strategies(address(this)).totalDebt;

         
        uint256 supply = getCurrentSupply();
        uint256 totalAssets = balanceOfWant().add(supply);

        if (totalDebt > totalAssets) {
             
            _loss = totalDebt.sub(totalAssets);
        } else {
             
            _profit = totalAssets.sub(totalDebt);
        }

         
        uint256 amountAvailable = balanceOfWant();
        uint256 amountRequired = _debtOutstanding.add(_profit);

        if (amountRequired > amountAvailable) {
             
             
             
            (amountAvailable, ) = liquidatePosition(amountRequired);

             
            alreadyAdjusted = true;

            if (amountAvailable >= amountRequired) {
                _debtPayment = _debtOutstanding;
                 
                if (amountRequired.sub(_debtPayment) < _profit) {
                    _profit = amountRequired.sub(_debtPayment);
                }
            } else {
                 
                if (amountAvailable < _debtOutstanding) {
                     
                    _profit = 0;
                    _debtPayment = amountAvailable;
                     
                     
                } else {
                     
                     
                    _debtPayment = _debtOutstanding;
                    _profit = amountAvailable.sub(_debtPayment);
                }
            }
        } else {
            _debtPayment = _debtOutstanding;
             
            if (amountRequired.sub(_debtPayment) < _profit) {
                _profit = amountRequired.sub(_debtPayment);
            }
        }
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {
        if (alreadyAdjusted) {
            alreadyAdjusted = false;  
            return;
        }

        uint256 wantBalance = balanceOfWant();
         
        if (
            wantBalance > _debtOutstanding &&
            wantBalance.sub(_debtOutstanding) > minWant
        ) {
            _depositCollateral(wantBalance.sub(_debtOutstanding));
             
            wantBalance = balanceOfWant();
        }
         
        uint256 currentCollatRatio = getCurrentCollatRatio();

         
        if (_debtOutstanding > wantBalance) {
             
            uint256 amountRequired = _debtOutstanding.sub(wantBalance);

             
            _freeFunds(amountRequired);
        } else if (currentCollatRatio < targetCollatRatio) {
             
            if (targetCollatRatio.sub(currentCollatRatio) > minRatio) {
                 
                _leverMax();
            }
        } else if (currentCollatRatio > targetCollatRatio) {
            if (currentCollatRatio.sub(targetCollatRatio) > minRatio) {
                (uint256 deposits, uint256 borrows) = getCurrentPosition();
                uint256 newBorrow =
                    getBorrowFromSupply(
                        deposits.sub(borrows),
                        targetCollatRatio
                    );
                _leverDownTo(newBorrow, borrows);
            }
        }
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
         
         
        uint256 wantBalance = balanceOfWant();
        if (wantBalance > _amountNeeded) {
             
            return (_amountNeeded, 0);
        }

         
        uint256 amountRequired = _amountNeeded.sub(wantBalance);
        _freeFunds(amountRequired);

        uint256 freeAssets = balanceOfWant();
        if (_amountNeeded > freeAssets) {
            _liquidatedAmount = freeAssets;
            uint256 diff = _amountNeeded.sub(_liquidatedAmount);
            if (diff <= minWant) {
                _loss = diff;
            }
        } else {
            _liquidatedAmount = _amountNeeded;
        }

        if (withdrawCheck) {
            require(_amountNeeded == _liquidatedAmount.add(_loss));  
        }
    }

    function tendTrigger(uint256 gasCost) public view override returns (bool) {
        if (harvestTrigger(gasCost)) {
             
            return false;
        }
         
        (, uint256 liquidationThreshold) =
            getProtocolCollatRatios(address(want));

        uint256 currentCollatRatio = getCurrentCollatRatio();

        if (currentCollatRatio >= liquidationThreshold) {
            return true;
        }

        return (liquidationThreshold.sub(currentCollatRatio) <=
            LIQUIDATION_WARNING_THRESHOLD);
    }

    function liquidateAllPositions()
        internal
        override
        returns (uint256 _amountFreed)
    {
        (_amountFreed, ) = liquidatePosition(type(uint256).max);
    }

    function prepareMigration(address _newStrategy) internal override {
        require(getCurrentSupply() < minWant);
    }

    function protectedTokens()
        internal
        view
        override
        returns (address[] memory)
    {}

     
    function manualDeleverage(uint256 amount) external onlyVaultManagers {
        _withdrawCollateral(amount);
        _repayWant(amount);
    }

     
    function manualReleaseWant(uint256 amount) external onlyVaultManagers {
        _withdrawCollateral(amount);
    }

     
    function manualClaimAndSellRewards() external onlyVaultManagers {
        _claimAndSellRewards();
    }

     

    function _claimAndSellRewards() internal returns (uint256) {
        uint256 stkAaveBalance = balanceOfStkAave();
        CooldownStatus cooldownStatus;
        if (stkAaveBalance > 0) {
            cooldownStatus = _checkCooldown();  
        }

         
        if (stkAaveBalance > 0 && cooldownStatus == CooldownStatus.Claim) {
             
            stkAave.claimRewards(address(this), type(uint256).max);
            stkAave.redeem(address(this), stkAaveBalance);
        }

         
        incentivesController.claimRewards(
            getAaveAssets(),
            type(uint256).max,
            address(this)
        );

        stkAaveBalance = balanceOfStkAave();

         
        if (
            cooldownStkAave &&
            stkAaveBalance > 0 &&
            cooldownStatus == CooldownStatus.None
        ) {
            stkAave.cooldown();
        }

         
        if (sellStkAave && stkAaveBalance >= minRewardToSell.add(1)) {
            uint256 minAAVEOut =
                stkAaveBalance.mul(MAX_BPS.sub(maxStkAavePriceImpactBps)).div(
                    MAX_BPS
                );
            _sellSTKAAVEToAAVE(stkAaveBalance.sub(1), minAAVEOut);
        }

         
        uint256 aaveBalance = balanceOfAave();
        if (aaveBalance >= minRewardToSell) {
            _sellAAVEForWant(aaveBalance, 0);
        }
    }

    function _freeFunds(uint256 amountToFree) internal returns (uint256) {
        if (amountToFree == 0) return 0;

        (uint256 deposits, uint256 borrows) = getCurrentPosition();

        uint256 realAssets = deposits.sub(borrows);
        uint256 amountRequired = Math.min(amountToFree, realAssets);
        uint256 newSupply = realAssets.sub(amountRequired);
        uint256 newBorrow = getBorrowFromSupply(newSupply, targetCollatRatio);

         
        _leverDownTo(newBorrow, borrows);

        return balanceOfWant();
    }

    function _leverMax() internal {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();

         
        uint256 realSupply = deposits.sub(borrows);
        uint256 newBorrow = getBorrowFromSupply(realSupply, targetCollatRatio);
        uint256 totalAmountToBorrow = newBorrow.sub(borrows);

        if (isFlashMintActive) {
             
            totalAmountToBorrow = totalAmountToBorrow.sub(
                _leverUpStep(totalAmountToBorrow)
            );

            if (totalAmountToBorrow > minWant) {
                totalAmountToBorrow = totalAmountToBorrow.sub(
                    _leverUpFlashLoan(totalAmountToBorrow)
                );
            }
        } else {
            for (
                uint8 i = 0;
                i < maxIterations && totalAmountToBorrow > minWant;
                i++
            ) {
                totalAmountToBorrow = totalAmountToBorrow.sub(
                    _leverUpStep(totalAmountToBorrow)
                );
            }
        }
    }

    function _leverUpFlashLoan(uint256 amount) internal returns (uint256) {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();
        uint256 depositsToMeetLtv =
            getDepositFromBorrow(borrows, maxBorrowCollatRatio);
        uint256 depositsDeficitToMeetLtv = 0;
        if (depositsToMeetLtv > deposits) {
            depositsDeficitToMeetLtv = depositsToMeetLtv.sub(deposits);
        }
        return
            FlashMintLib.doFlashMint(
                false,
                amount,
                address(want),
                daiBorrowCollatRatio,
                depositsDeficitToMeetLtv
            );
    }

    function _leverUpStep(uint256 amount) internal returns (uint256) {
        if (amount == 0) {
            return 0;
        }

        uint256 wantBalance = balanceOfWant();

         
        (uint256 deposits, uint256 borrows) = getCurrentPosition();
        uint256 canBorrow =
            getBorrowFromDeposit(
                deposits.add(wantBalance),
                maxBorrowCollatRatio
            );

        if (canBorrow <= borrows) {
            return 0;
        }
        canBorrow = canBorrow.sub(borrows);

        if (canBorrow < amount) {
            amount = canBorrow;
        }

         
        _depositCollateral(wantBalance);

         
        _borrowWant(amount);

        return amount;
    }

    function _leverDownTo(uint256 newAmountBorrowed, uint256 currentBorrowed)
        internal
    {
        if (currentBorrowed > newAmountBorrowed) {
            uint256 totalRepayAmount = currentBorrowed.sub(newAmountBorrowed);

            if (isFlashMintActive) {
                totalRepayAmount = totalRepayAmount.sub(
                    _leverDownFlashLoan(totalRepayAmount)
                );
            }

            uint256 _maxCollatRatio = maxCollatRatio;

            for (
                uint8 i = 0;
                i < maxIterations && totalRepayAmount > minWant;
                i++
            ) {
                _withdrawExcessCollateral(_maxCollatRatio);
                uint256 toRepay = totalRepayAmount;
                uint256 wantBalance = balanceOfWant();
                if (toRepay > wantBalance) {
                    toRepay = wantBalance;
                }
                uint256 repaid = _repayWant(toRepay);
                totalRepayAmount = totalRepayAmount.sub(repaid);
            }
        }

         
        (uint256 deposits, uint256 borrows) = getCurrentPosition();
        uint256 _targetCollatRatio = targetCollatRatio;
        uint256 targetDeposit =
            getDepositFromBorrow(borrows, _targetCollatRatio);
        if (targetDeposit > deposits) {
            uint256 toDeposit = targetDeposit.sub(deposits);
            if (toDeposit > minWant) {
                _depositCollateral(Math.min(toDeposit, balanceOfWant()));
            }
        } else {
            _withdrawExcessCollateral(_targetCollatRatio);
        }
    }

    function _leverDownFlashLoan(uint256 amount) internal returns (uint256) {
        if (amount <= minWant) return 0;
        (, uint256 borrows) = getCurrentPosition();
        if (amount > borrows) {
            amount = borrows;
        }
        return
            FlashMintLib.doFlashMint(
                true,
                amount,
                address(want),
                daiBorrowCollatRatio,
                0
            );
    }

    function _withdrawExcessCollateral(uint256 collatRatio)
        internal
        returns (uint256 amount)
    {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();
        uint256 theoDeposits = getDepositFromBorrow(borrows, collatRatio);
        if (deposits > theoDeposits) {
            uint256 toWithdraw = deposits.sub(theoDeposits);
            return _withdrawCollateral(toWithdraw);
        }
    }

    function _depositCollateral(uint256 amount) internal returns (uint256) {
        if (amount == 0) return 0;
        lendingPool.deposit(address(want), amount, address(this), referral);
        return amount;
    }

    function _withdrawCollateral(uint256 amount) internal returns (uint256) {
        if (amount == 0) return 0;
        lendingPool.withdraw(address(want), amount, address(this));
        return amount;
    }

    function _repayWant(uint256 amount) internal returns (uint256) {
        if (amount == 0) return 0;
        return lendingPool.repay(address(want), amount, 2, address(this));
    }

    function _borrowWant(uint256 amount) internal returns (uint256) {
        if (amount == 0) return 0;
        lendingPool.borrow(address(want), amount, 2, referral, address(this));
        return amount;
    }

     
    function balanceOfWant() internal view returns (uint256) {
        return want.balanceOf(address(this));
    }

    function balanceOfAToken() internal view returns (uint256) {
        return aToken.balanceOf(address(this));
    }

    function balanceOfDebtToken() internal view returns (uint256) {
        return debtToken.balanceOf(address(this));
    }

    function balanceOfAave() internal view returns (uint256) {
        return IERC20(aave).balanceOf(address(this));
    }

    function balanceOfStkAave() internal view returns (uint256) {
        return IERC20(address(stkAave)).balanceOf(address(this));
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        require(msg.sender == FlashMintLib.LENDER);
        require(initiator == address(this));
        (bool deficit, uint256 amountWant) = abi.decode(data, (bool, uint256));

        return
            FlashMintLib.loanLogic(deficit, amountWant, amount, address(want));
    }

    function getCurrentPosition()
        public
        view
        returns (uint256 deposits, uint256 borrows)
    {
        deposits = balanceOfAToken();
        borrows = balanceOfDebtToken();
    }

    function getCurrentCollatRatio()
        public
        view
        returns (uint256 currentCollatRatio)
    {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();

        if (deposits > 0) {
            currentCollatRatio = borrows.mul(COLLATERAL_RATIO_PRECISION).div(
                deposits
            );
        }
    }

    function getCurrentSupply() public view returns (uint256) {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();
        return deposits.sub(borrows);
    }

     
    function tokenToWant(address token, uint256 amount)
        internal
        view
        returns (uint256)
    {
        if (amount == 0 || address(want) == token) {
            return amount;
        }

         
        IUni router =
            swapRouter == SwapRouter.SushiV2 ? SUSHI_V2_ROUTER : UNI_V2_ROUTER;
        uint256[] memory amounts =
            router.getAmountsOut(
                amount,
                getTokenOutPathV2(token, address(want))
            );

        return amounts[amounts.length - 1];
    }

    function ethToWant(uint256 _amtInWei)
        public
        view
        override
        returns (uint256)
    {
        return tokenToWant(weth, _amtInWei);
    }

    function _checkCooldown() internal view returns (CooldownStatus) {
        uint256 cooldownStartTimestamp =
            IStakedAave(stkAave).stakersCooldowns(address(this));
        uint256 COOLDOWN_SECONDS = IStakedAave(stkAave).COOLDOWN_SECONDS();
        uint256 UNSTAKE_WINDOW = IStakedAave(stkAave).UNSTAKE_WINDOW();
        uint256 nextClaimStartTimestamp =
            cooldownStartTimestamp.add(COOLDOWN_SECONDS);

        if (cooldownStartTimestamp == 0) {
            return CooldownStatus.None;
        }
        if (
            block.timestamp > nextClaimStartTimestamp &&
            block.timestamp <= nextClaimStartTimestamp.add(UNSTAKE_WINDOW)
        ) {
            return CooldownStatus.Claim;
        }
        if (block.timestamp < nextClaimStartTimestamp) {
            return CooldownStatus.Initiated;
        }
    }

    function getTokenOutPathV2(address _token_in, address _token_out)
        internal
        pure
        returns (address[] memory _path)
    {
        bool is_weth =
            _token_in == address(weth) || _token_out == address(weth);
        _path = new address[](is_weth ? 2 : 3);
        _path[0] = _token_in;

        if (is_weth) {
            _path[1] = _token_out;
        } else {
            _path[1] = address(weth);
            _path[2] = _token_out;
        }
    }

    function getTokenOutPathV3(address _token_in, address _token_out)
        internal
        view
        returns (bytes memory _path)
    {
        if (address(want) == weth) {
            _path = abi.encodePacked(
                address(aave),
                aaveToWethSwapFee,
                address(weth)
            );
        } else {
            _path = abi.encodePacked(
                address(aave),
                aaveToWethSwapFee,
                address(weth),
                wethToWantSwapFee,
                address(want)
            );
        }
    }

    function _sellAAVEForWant(uint256 amountIn, uint256 minOut) internal {
        if (amountIn == 0) {
            return;
        }
        if (swapRouter == SwapRouter.UniV3) {
            UNI_V3_ROUTER.exactInput(
                ISwapRouter.ExactInputParams(
                    getTokenOutPathV3(address(aave), address(want)),
                    address(this),
                    now,
                    amountIn,
                    minOut
                )
            );
        } else {
            IUni router =
                swapRouter == SwapRouter.UniV2
                    ? UNI_V2_ROUTER
                    : SUSHI_V2_ROUTER;
            router.swapExactTokensForTokens(
                amountIn,
                minOut,
                getTokenOutPathV2(address(aave), address(want)),
                address(this),
                now
            );
        }
    }

    function _sellSTKAAVEToAAVE(uint256 amountIn, uint256 minOut) internal {
         
         
        UNI_V3_ROUTER.exactInputSingle(
            ISwapRouter.ExactInputSingleParams(
                address(stkAave),
                address(aave),
                stkAaveToAaveSwapFee,
                address(this),
                now,
                amountIn,  
                minOut,
                0
            )
        );
    }

    function getAaveAssets() internal view returns (address[] memory assets) {
        assets = new address[](2);
        assets[0] = address(aToken);
        assets[1] = address(debtToken);
    }

    function getProtocolCollatRatios(address token)
        internal
        view
        returns (uint256 ltv, uint256 liquidationThreshold)
    {
        (, ltv, liquidationThreshold, , , , , , , ) = protocolDataProvider
            .getReserveConfigurationData(token);
         
        ltv = ltv.mul(BPS_WAD_RATIO);
        liquidationThreshold = liquidationThreshold.mul(BPS_WAD_RATIO);
    }

    function getBorrowFromDeposit(uint256 deposit, uint256 collatRatio)
        internal
        pure
        returns (uint256)
    {
        return deposit.mul(collatRatio).div(COLLATERAL_RATIO_PRECISION);
    }

    function getDepositFromBorrow(uint256 borrow, uint256 collatRatio)
        internal
        pure
        returns (uint256)
    {
        return borrow.mul(COLLATERAL_RATIO_PRECISION).div(collatRatio);
    }

    function getBorrowFromSupply(uint256 supply, uint256 collatRatio)
        internal
        pure
        returns (uint256)
    {
        return
            supply.mul(collatRatio).div(
                COLLATERAL_RATIO_PRECISION.sub(collatRatio)
            );
    }

    function approveMaxSpend(address token, address spender) internal {
        IERC20(token).safeApprove(spender, type(uint256).max);
    }
}

 

contract LevAaveFactory {
    address public immutable original;

    event Cloned(address indexed clone);
    event Deployed(address indexed original);

    constructor(address _vault) public {
        Strategy _original = new Strategy(_vault);
        emit Deployed(address(_original));

        original = address(_original);
        _original.setRewards(msg.sender);
        _original.setKeeper(msg.sender);
        _original.setStrategist(msg.sender);
    }

    function name() external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "Factory",
                    Strategy(payable(original)).name(),
                    "@",
                    Strategy(payable(original)).apiVersion()
                )
            );
    }

    function cloneLevAave(address _vault)
        external
        returns (address payable newStrategy)
    {
         
        bytes20 addressBytes = bytes20(original);
        assembly {
             
            let clone_code := mload(0x40)
            mstore(
                clone_code,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(
                add(clone_code, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            newStrategy := create(0, clone_code, 0x37)
        }

        Strategy(newStrategy).initialize(
            _vault,
            msg.sender,
            msg.sender,
            msg.sender
        );

        emit Cloned(newStrategy);
    }
}