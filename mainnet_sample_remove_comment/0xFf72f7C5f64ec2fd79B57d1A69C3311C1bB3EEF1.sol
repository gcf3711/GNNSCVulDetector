 
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

 

interface IBaseFee {
    function isCurrentBaseFeeAcceptable() external view returns (bool);
}

 

interface IBaseFeeOracle {
    function basefee_global() external view returns (uint256);
}

 

interface IPriceFeed {
     
    event LastGoodPriceUpdated(uint256 _lastGoodPrice);

     
    function fetchPrice() external returns (uint256);

    function lastGoodPrice() external view returns (uint256);
}

 

 
interface IStabilityPool {

     
    
    event StabilityPoolETHBalanceUpdated(uint _newBalance);
    event StabilityPoolLUSDBalanceUpdated(uint _newBalance);

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event LUSDTokenAddressChanged(address _newLUSDTokenAddress);
    event SortedTrovesAddressChanged(address _newSortedTrovesAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event CommunityIssuanceAddressChanged(address _newCommunityIssuanceAddress);

    event P_Updated(uint _P);
    event S_Updated(uint _S, uint128 _epoch, uint128 _scale);
    event G_Updated(uint _G, uint128 _epoch, uint128 _scale);
    event EpochUpdated(uint128 _currentEpoch);
    event ScaleUpdated(uint128 _currentScale);

    event FrontEndRegistered(address indexed _frontEnd, uint _kickbackRate);
    event FrontEndTagSet(address indexed _depositor, address indexed _frontEnd);

    event DepositSnapshotUpdated(address indexed _depositor, uint _P, uint _S, uint _G);
    event FrontEndSnapshotUpdated(address indexed _frontEnd, uint _P, uint _G);
    event UserDepositChanged(address indexed _depositor, uint _newDeposit);
    event FrontEndStakeChanged(address indexed _frontEnd, uint _newFrontEndStake, address _depositor);

    event ETHGainWithdrawn(address indexed _depositor, uint _ETH, uint _LUSDLoss);
    event LQTYPaidToDepositor(address indexed _depositor, uint _LQTY);
    event LQTYPaidToFrontEnd(address indexed _frontEnd, uint _LQTY);
    event EtherSent(address _to, uint _amount);

     

     
    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress,
        address _lusdTokenAddress,
        address _sortedTrovesAddress,
        address _priceFeedAddress,
        address _communityIssuanceAddress
    ) external;

     
    function provideToSP(uint _amount, address _frontEndTag) external;

     
    function withdrawFromSP(uint _amount) external;

     
    function withdrawETHGainToTrove(address _upperHint, address _lowerHint) external;

     
    function registerFrontEnd(uint _kickbackRate) external;

     
    function offset(uint _debt, uint _coll) external;

     
    function getETH() external view returns (uint);

     
    function getTotalLUSDDeposits() external view returns (uint);

     
    function getDepositorETHGain(address _depositor) external view returns (uint);

     
    function getDepositorLQTYGain(address _depositor) external view returns (uint);

     
    function getFrontEndLQTYGain(address _frontEnd) external view returns (uint);

     
    function getCompoundedLUSDDeposit(address _depositor) external view returns (uint);

     
    function getCompoundedFrontEndStake(address _frontEnd) external view returns (uint);

     
}

 

interface IStableSwapExchange {
    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);
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

     
     
    function refundETH() external payable;
}

 

interface IWETH9 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
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

 

contract Strategy is BaseStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

     
    IERC20 internal constant LQTY =
        IERC20(0x6DEA81C8171D0bA574754EF6F8b412F2Ed88c54D);

     
    IStabilityPool internal constant stabilityPool =
        IStabilityPool(0x66017D22b0f8556afDd19FC67041899Eb65a21bb);

     
    IPriceFeed internal constant priceFeed =
        IPriceFeed(0x4c517D4e2C851CA76d7eC94B805269Df0f2201De);

     
    ISwapRouter internal constant router =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

     
    IStableSwapExchange internal constant curvePool =
        IStableSwapExchange(0xEd279fDD11cA84bEef15AF5D39BB4d4bEE23F0cA);

     
    IWETH9 internal constant WETH =
        IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

     
    IERC20 internal constant DAI =
        IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

     
    bool public convertDAItoLUSDonCurve;

     
    uint24 public lqtyToEthFee;
    uint24 public ethToDaiFee;
    uint24 public daiToLusdFee;

     
     
    uint256 public minExpectedSwapPercentage;

     
    uint256 internal constant MAX_BPS = 10000;

     
    uint256 public harvestProfitMin;  

     
     
     
    uint256 public maxTendBaseFee;
     
    uint256 public maxEthPercent;
     
    uint256 public maxEthAmount;
     
    uint256 public maxEthToSell;

    constructor(address _vault) public BaseStrategy(_vault) {
         
        convertDAItoLUSDonCurve = true;

         
        healthCheck = 0xDDCea799fF1699e98EDF118e0629A974Df7DF012;

         
        lqtyToEthFee = 3000;
        ethToDaiFee = 3000;
        daiToLusdFee = 500;

         
        minExpectedSwapPercentage = 9800;

         
        harvestProfitMin = 1_000e18;

        maxTendBaseFee = 200e9;

         
        maxEthPercent = 100;
        maxEthAmount = 100e18;
         
        maxEthToSell = type(uint256).max;
    }

     
    receive() external payable {}

     

     
     
     
    function swallowETH() external onlyGovernance {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);  
    }

     
    function wrapETH() external onlyGovernance {
        WETH.deposit{value: address(this).balance}();
    }

     
    function setConvertDAItoLUSDonCurve(bool _convertDAItoLUSDonCurve)
        external
        onlyEmergencyAuthorized
    {
        convertDAItoLUSDonCurve = _convertDAItoLUSDonCurve;
    }

     
     
    function setSwapFees(
        uint24 _lqtyToEthFee,
        uint24 _ethToDaiFee,
        uint24 _daiToLusdFee
    ) external onlyEmergencyAuthorized {
        lqtyToEthFee = _lqtyToEthFee;
        ethToDaiFee = _ethToDaiFee;
        daiToLusdFee = _daiToLusdFee;
    }

     
     
     
     
    function setMinExpectedSwapPercentage(uint256 _minExpectedSwapPercentage)
        external
        onlyEmergencyAuthorized
    {
        minExpectedSwapPercentage = _minExpectedSwapPercentage;
    }

     
    function setTendAmounts(
        uint256 _maxEthPercent,
        uint256 _maxEthAmount,
        uint256 _maxEthToSell,
        uint256 _maxTendBaseFee
    ) external onlyEmergencyAuthorized {
        require(_maxEthPercent <= MAX_BPS, "Too Many Bips");
        require(_maxEthToSell > 0, "Can't be 0");
        maxEthPercent = _maxEthPercent;
        maxEthAmount = _maxEthAmount;
        maxEthToSell = _maxEthToSell;
        maxTendBaseFee = _maxTendBaseFee;
    }   

     
    function setHarvestTriggerMin(
        uint256 _harvestProfitMin
    ) external onlyEmergencyAuthorized {
        harvestProfitMin = _harvestProfitMin;
    }

     
     
     
     
    function depositLUSD(uint256 _amount) external onlyEmergencyAuthorized {
        stabilityPool.provideToSP(_amount, address(0));
    }

     
     
     
     
     
    function withdrawLUSD(uint256 _amount) external onlyEmergencyAuthorized {
        stabilityPool.withdrawFromSP(_amount);
    }

     

    function name() external view override returns (string memory) {
        return "StrategyLiquityStabilityPoolLUSD";
    }

    function estimatedTotalAssets() public view override returns (uint256) {
         
        uint256 daiBalance = DAI.balanceOf(address(this));
        uint256 daiToWant = daiBalance > 0 ? curvePool.get_dy_underlying(1, 0, daiBalance) : 0;

        return
            totalLUSDBalance().add(daiToWant).add(
                totalETHBalance().mul(priceFeed.lastGoodPrice()).div(1e18)
            );
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
         
        uint256 totalDebt = vault.strategies(address(this)).totalDebt;

         
         
        _claimRewards();

         
        uint256 totalAssetsAfterClaim = totalLUSDBalance();

        if (totalAssetsAfterClaim > totalDebt) {
            _profit = totalAssetsAfterClaim.sub(totalDebt);
            _loss = 0;
        } else {
            _profit = 0;
            _loss = totalDebt.sub(totalAssetsAfterClaim);
        }

         
         
        uint256 _amountFreed;
        (_amountFreed, ) = liquidatePosition(_debtOutstanding.add(_profit));
        _debtPayment = Math.min(_debtOutstanding, _amountFreed);
        
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {
         
         
        if(totalETHBalance() > 0) {
           claimAndSellEth();
        }

        if(DAI.balanceOf(address(this)) > 0) {
             
             
            _tryToSellDAIForLUSDonCurve();
        }
        

         
         
        uint256 wantBalance = balanceOfWant();
        if (wantBalance > _debtOutstanding) {
            stabilityPool.provideToSP(
                wantBalance.sub(_debtOutstanding),
                address(0)
            );
        }
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        uint256 balance = balanceOfWant();

         
        if (balance >= _amountNeeded) {
            return (_amountNeeded, 0);
        }

         
        uint256 amountToWithdraw = _amountNeeded.sub(balance);

        uint256 stabilityBalance = stabilityPool.getCompoundedLUSDDeposit(address(this));
        if(amountToWithdraw > stabilityBalance) {
             
             
            require(DAI.balanceOf(address(this)) == 0, "To much DAI");
            stabilityPool.withdrawFromSP(stabilityBalance);
        } else {
            stabilityPool.withdrawFromSP(amountToWithdraw);
        }

         
         
         
         
         
        uint256 looseWant = balanceOfWant();
        if (_amountNeeded > looseWant) {
            _liquidatedAmount = looseWant;
            _loss = _amountNeeded.sub(looseWant);
        } else {
            _liquidatedAmount = _amountNeeded;
            _loss = 0;
        }
    }

    function liquidateAllPositions()
        internal
        override
        returns (uint256 _amountFreed)
    {
        stabilityPool.withdrawFromSP(
            stabilityPool.getCompoundedLUSDDeposit(address(this))
        );
         
         
        uint256 daiBalance = DAI.balanceOf(address(this));
        if (daiBalance > 0) {
            _sellDAIAmountForLusd(daiBalance);
        }

        return balanceOfWant();
    }

    function prepareMigration(address _newStrategy) internal override {
        if (stabilityPool.getCompoundedLUSDDeposit(address(this)) <= 0) {
            return;
        }

         
         
         
        stabilityPool.withdrawFromSP(
            stabilityPool.getCompoundedLUSDDeposit(address(this))
        );
    }

    function protectedTokens()
        internal
        view
        override
        returns (address[] memory)
    {}

    function ethToWant(uint256 _amtInWei)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _amtInWei.mul(priceFeed.lastGoodPrice()).div(1e18);
    }

     

    function balanceOfWant() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    function totalLUSDBalance() public view returns (uint256) {
        return
            balanceOfWant().add(
                stabilityPool.getCompoundedLUSDDeposit(address(this))
            );
    }

    function totalLQTYBalance() public view returns (uint256) {
        return
            LQTY.balanceOf(address(this)).add(
                stabilityPool.getDepositorLQTYGain(address(this))
            );
    }

    function totalETHBalance() public view returns (uint256) {
        return
            address(this).balance.add(
                stabilityPool.getDepositorETHGain(address(this))
            );
    }

     

    function _checkAllowance(
        address _contract,
        IERC20 _token,
        uint256 _amount
    ) internal {
        if (_token.allowance(address(this), _contract) < _amount) {
            _token.safeApprove(_contract, 0);
            _token.safeApprove(_contract, type(uint256).max);
        }
    }

    function _claimRewards() internal {
         
        if (stabilityPool.getCompoundedLUSDDeposit(address(this)) > 0) {
            stabilityPool.withdrawFromSP(0);
        }

         
        if (LQTY.balanceOf(address(this)) > 0) {
            _sellLQTYforDAI();
        }

         
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            _sellETHforDAI(ethBalance);
        }

         
        uint256 daiBalance = DAI.balanceOf(address(this));
        if (daiBalance > 0) {
            _sellDAIAmountForLusd(daiBalance);
        }
    }

     

    function _sellLQTYforDAI() internal {
        _checkAllowance(address(router), LQTY, LQTY.balanceOf(address(this)));

        bytes memory path =
            abi.encodePacked(
                address(LQTY),  
                lqtyToEthFee,
                address(WETH),  
                ethToDaiFee,
                address(DAI)
            );

         
         
        router.exactInput(
            ISwapRouter.ExactInputParams(
                path,
                address(this),
                now,
                LQTY.balanceOf(address(this)),
                0
            )
        );
    }

    function _sellETHforDAI(uint256 ethBalance) internal {
        uint256 ethUSD = priceFeed.fetchPrice();

         
        uint256 minExpected =
            ethBalance
                .mul(ethUSD)
                .mul(minExpectedSwapPercentage)
                .div(MAX_BPS)
                .div(1e18);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams(
                address(WETH),  
                address(DAI),  
                ethToDaiFee,  
                address(this),  
                now,  
                ethBalance,  
                minExpected,  
                0  
            );

        router.exactInputSingle{value: ethBalance}(params);
        router.refundETH();
    }

    function _sellDAIAmountForLusd(uint256 _amount) internal {
        
        require(DAI.balanceOf(address(this)) >= _amount, "Not enough DAI");

        if (convertDAItoLUSDonCurve) {
            _sellDAIAmountForLUSDonCurve(_amount);
        } else {
            _sellDAIAmountForLUSDonUniswap(_amount);
        }
    }

    function _sellDAIAmountForLUSDonCurve(uint256 daiBalance) internal {

        _checkAllowance(address(curvePool), DAI, daiBalance);

        curvePool.exchange_underlying(
                1,  
                0,  
                daiBalance,  
                daiBalance.mul(minExpectedSwapPercentage).div(MAX_BPS)  
            );
    }

    function _sellDAIAmountForLUSDonUniswap(uint256 daiBalance) internal {

        _checkAllowance(address(router), DAI, daiBalance);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams(
                address(DAI),  
                address(want),  
                daiToLusdFee,  
                address(this),  
                now,  
                daiBalance,  
                daiBalance.mul(minExpectedSwapPercentage).div(MAX_BPS),  
                0  
            );
        router.exactInputSingle(params);
    }
    
     
     
     
    function _tryToSellDAIForLUSDonCurve() internal {
        uint256 _amount =  DAI.balanceOf(address(this));

        uint256 minOut = _amount.mul(minExpectedSwapPercentage).div(MAX_BPS);

        uint256 actualOut = curvePool.get_dy_underlying(1, 0, _amount);

        if(actualOut >= minOut) {
        
            _checkAllowance(address(curvePool), DAI, _amount);

            curvePool.exchange_underlying(
                1,  
                0,  
                _amount,  
                minOut  
            );
        }
    }

     
     
    function claimAndSellEth() internal {
        if (stabilityPool.getCompoundedLUSDDeposit(address(this)) > 0) {
            stabilityPool.withdrawFromSP(0);
        }

        uint256 ethBalance = Math.min(address(this).balance, maxEthToSell);
         
        if(ethBalance == 0) return;

        _sellETHforDAI(ethBalance);
    }

     
    function sellDaiAmountToLusd(uint256 _amount) external onlyEmergencyAuthorized {
        _sellDAIAmountForLusd(_amount);
    }

    function tendTrigger(uint256 callCostInWei) public view override returns (bool){
        uint256 totalAssets = estimatedTotalAssets();
        uint256 ethBalance = totalETHBalance();

        if(ethBalance == 0) return false;

        if(getBaseFee() > maxTendBaseFee) return false;

        if(ethBalance >= maxEthAmount) return true;

         
        if (callCostInWei > ethBalance / 10) return false;

        uint256 ethInWant = ethToWant(ethBalance);
        uint256 maxAllowedEth = totalAssets.mul(maxEthPercent).div(MAX_BPS);

        if(ethInWant > maxAllowedEth) return true;

        return false;
    }

     
    function harvestTrigger(uint256 callCostInWei) public view override returns (bool) {
         
        if (!isActive()) {
            return false;
        }

        StrategyParams memory params = vault.strategies(address(this));
        uint256 assets = estimatedTotalAssets();
        uint256 debt = params.totalDebt;

         
         
        uint256 needToSwap = assets.sub(totalLUSDBalance());
        if(needToSwap > 0) {
            if(curvePool.get_dy_underlying(1, 0, needToSwap) < needToSwap.mul(minExpectedSwapPercentage).div(MAX_BPS)) {
                return false;
            }
        }

         
        if (!isBaseFeeAcceptable()) {
            return false;
        }

         
        uint256 claimableProfit = assets > debt ? assets.sub(debt) : 0;

         
        if (claimableProfit > harvestProfitMin) {
            return true;
        }
        
         
        if (block.timestamp.sub(params.lastReport) < minReportDelay) return false;

         
        if (block.timestamp.sub(params.lastReport) > maxReportDelay) {
            return true;
        }

         
        return false;
    }
    
      
    function isBaseFeeAcceptable() internal view returns (bool) {
        return
            IBaseFee(0xb5e1CAcB567d98faaDB60a1fD4820720141f064F)
                .isCurrentBaseFeeAcceptable();
    }

    function getBaseFee() internal view returns (uint256) {
        uint256 baseFee;
        try IBaseFeeOracle(0xf8d0Ec04e94296773cE20eFbeeA82e76220cD549)
                .basefee_global() returns (uint256 currentBaseFee) {
            baseFee = currentBaseFee;
        } catch {
             
             
             
             
            baseFee = 1000 gwei;
        }
    }

}