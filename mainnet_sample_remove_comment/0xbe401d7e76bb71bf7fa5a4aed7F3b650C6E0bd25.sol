 
pragma abicoder v2;


 

pragma solidity ^0.7.0;




 
abstract contract ERC1967Upgrade {
     
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

     
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

     
    event Upgraded(address indexed implementation);

     
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

     
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

     
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

     
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

     
    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

         
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

         
        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
             
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
             
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
             
            _upgradeTo(newImplementation);
        }
    }

}

 
pragma solidity ^0.7.0;




 
contract StorageLayoutV1 {
     
    uint16 internal maxCurrencyId;
     
     
    bytes1 internal liquidationEnabledState;
     
    bool internal hasInitialized;

     
     
    address public owner;
     
    address public pauseRouter;
     
    address public pauseGuardian;
     
    address internal rollbackRouterImplementation;

     
     
     
    mapping(address => mapping(address => uint256)) internal nTokenWhitelist;
     
     
    mapping(address => mapping(address => mapping(uint16 => uint256))) internal nTokenAllowance;

     
     
    mapping(address => bool) internal globalTransferOperator;
     
     
    mapping(address => mapping(address => bool)) internal accountAuthorizedTransferOperator;
     
     
    mapping(address => bool) internal authorizedCallbackContract;

     
     
    mapping(address => uint16) internal tokenAddressToCurrencyId;

     
    uint256 internal reentrancyStatus;
}

 

pragma solidity ^0.7.0;



 
abstract contract UUPSUpgradeable is ERC1967Upgrade {
     
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, bytes(""), false);
    }

     
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

     
    function _authorizeUpgrade(address newImplementation) internal virtual;
}

 
pragma solidity >=0.6.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

 
pragma solidity >=0.6.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

   
   
   
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

 
pragma solidity ^0.7.0;


interface nTokenERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function nTokenTotalSupply(address nTokenAddress) external view returns (uint256);

    function nTokenTransferAllowance(
        uint16 currencyId,
        address owner,
        address spender
    ) external view returns (uint256);

    function nTokenBalanceOf(uint16 currencyId, address account) external view returns (uint256);

    function nTokenTransferApprove(
        uint16 currencyId,
        address owner,
        address spender,
        uint256 amount
    ) external returns (bool);

    function nTokenTransfer(
        uint16 currencyId,
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function nTokenTransferFrom(
        uint16 currencyId,
        address spender,
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function nTokenTransferApproveAll(address spender, uint256 amount) external returns (bool);

    function nTokenClaimIncentives() external returns (uint256);

    function nTokenPresentValueAssetDenominated(uint16 currencyId) external view returns (int256);

    function nTokenPresentValueUnderlyingDenominated(uint16 currencyId)
        external
        view
        returns (int256);
}

 
pragma solidity ^0.7.0;




interface nERC1155Interface {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function supportsInterface(bytes4 interfaceId) external pure returns (bool);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function signedBalanceOf(address account, uint256 id) external view returns (int256);

    function signedBalanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (int256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external payable;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external payable;

    function decodeToAssets(uint256[] calldata ids, uint256[] calldata amounts)
        external
        view
        returns (PortfolioAsset[] memory);

    function encodeToId(
        uint16 currencyId,
        uint40 maturity,
        uint8 assetType
    ) external pure returns (uint256 id);
}

 
pragma solidity ^0.7.0;






interface NotionalGovernance {
    event ListCurrency(uint16 newCurrencyId);
    event UpdateETHRate(uint16 currencyId);
    event UpdateAssetRate(uint16 currencyId);
    event UpdateCashGroup(uint16 currencyId);
    event DeployNToken(uint16 currencyId, address nTokenAddress);
    event UpdateDepositParameters(uint16 currencyId);
    event UpdateInitializationParameters(uint16 currencyId);
    event UpdateIncentiveEmissionRate(uint16 currencyId, uint32 newEmissionRate);
    event UpdateTokenCollateralParameters(uint16 currencyId);
    event UpdateGlobalTransferOperator(address operator, bool approved);
    event UpdateAuthorizedCallbackContract(address operator, bool approved);
    event UpdateMaxCollateralBalance(uint16 currencyId, uint72 maxCollateralBalance);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PauseRouterAndGuardianUpdated(address indexed pauseRouter, address indexed pauseGuardian);

    function transferOwnership(address newOwner) external;

    function setPauseRouterAndGuardian(address pauseRouter_, address pauseGuardian_) external;

    function listCurrency(
        TokenStorage calldata assetToken,
        TokenStorage calldata underlyingToken,
        AggregatorV2V3Interface rateOracle,
        bool mustInvert,
        uint8 buffer,
        uint8 haircut,
        uint8 liquidationDiscount
    ) external returns (uint16 currencyId);

    function updateMaxCollateralBalance(
        uint16 currencyId,
        uint72 maxCollateralBalanceInternalPrecision
    ) external;

    function enableCashGroup(
        uint16 currencyId,
        AssetRateAdapter assetRateOracle,
        CashGroupSettings calldata cashGroup,
        string calldata underlyingName,
        string calldata underlyingSymbol
    ) external;

    function updateDepositParameters(
        uint16 currencyId,
        uint32[] calldata depositShares,
        uint32[] calldata leverageThresholds
    ) external;

    function updateInitializationParameters(
        uint16 currencyId,
        uint32[] calldata annualizedAnchorRates,
        uint32[] calldata proportions
    ) external;

    function updateIncentiveEmissionRate(uint16 currencyId, uint32 newEmissionRate) external;

    function updateTokenCollateralParameters(
        uint16 currencyId,
        uint8 residualPurchaseIncentive10BPS,
        uint8 pvHaircutPercentage,
        uint8 residualPurchaseTimeBufferHours,
        uint8 cashWithholdingBuffer10BPS,
        uint8 liquidationHaircutPercentage
    ) external;

    function updateCashGroup(uint16 currencyId, CashGroupSettings calldata cashGroup) external;

    function updateAssetRate(uint16 currencyId, AssetRateAdapter rateOracle) external;

    function updateETHRate(
        uint16 currencyId,
        AggregatorV2V3Interface rateOracle,
        bool mustInvert,
        uint8 buffer,
        uint8 haircut,
        uint8 liquidationDiscount
    ) external;

    function updateGlobalTransferOperator(address operator, bool approved) external;

    function updateAuthorizedCallbackContract(address operator, bool approved) external;
}

 
pragma solidity ^0.7.0;




interface NotionalViews {
    function getMaxCurrencyId() external view returns (uint16);

    function getCurrencyId(address tokenAddress) external view returns (uint16 currencyId);

    function getCurrency(uint16 currencyId)
        external
        view
        returns (Token memory assetToken, Token memory underlyingToken);

    function getRateStorage(uint16 currencyId)
        external
        view
        returns (ETHRateStorage memory ethRate, AssetRateStorage memory assetRate);

    function getCurrencyAndRates(uint16 currencyId)
        external
        view
        returns (
            Token memory assetToken,
            Token memory underlyingToken,
            ETHRate memory ethRate,
            AssetRateParameters memory assetRate
        );

    function getCashGroup(uint16 currencyId) external view returns (CashGroupSettings memory);

    function getCashGroupAndAssetRate(uint16 currencyId)
        external
        view
        returns (CashGroupSettings memory cashGroup, AssetRateParameters memory assetRate);

    function getInitializationParameters(uint16 currencyId)
        external
        view
        returns (int256[] memory annualizedAnchorRates, int256[] memory proportions);

    function getDepositParameters(uint16 currencyId)
        external
        view
        returns (int256[] memory depositShares, int256[] memory leverageThresholds);

    function nTokenAddress(uint16 currencyId) external view returns (address);

    function getNoteToken() external view returns (address);

    function getSettlementRate(uint16 currencyId, uint40 maturity)
        external
        view
        returns (AssetRateParameters memory);

    function getMarket(uint16 currencyId, uint256 maturity, uint256 settlementDate)
        external view returns (MarketParameters memory);

    function getActiveMarkets(uint16 currencyId) external view returns (MarketParameters[] memory);

    function getActiveMarketsAtBlockTime(uint16 currencyId, uint32 blockTime)
        external
        view
        returns (MarketParameters[] memory);

    function getReserveBalance(uint16 currencyId) external view returns (int256 reserveBalance);

    function getNTokenPortfolio(address tokenAddress)
        external
        view
        returns (PortfolioAsset[] memory liquidityTokens, PortfolioAsset[] memory netfCashAssets);

    function getNTokenAccount(address tokenAddress)
        external
        view
        returns (
            uint16 currencyId,
            uint256 totalSupply,
            uint256 incentiveAnnualEmissionRate,
            uint256 lastInitializedTime,
            bytes5 nTokenParameters,
            int256 cashBalance,
            uint256 integralTotalSupply,
            uint256 lastSupplyChangeTime
        );

    function getAccount(address account)
        external
        view
        returns (
            AccountContext memory accountContext,
            AccountBalance[] memory accountBalances,
            PortfolioAsset[] memory portfolio
        );

    function getAccountContext(address account) external view returns (AccountContext memory);

    function getAccountBalance(uint16 currencyId, address account)
        external
        view
        returns (
            int256 cashBalance,
            int256 nTokenBalance,
            uint256 lastClaimTime
        );

    function getAccountPortfolio(address account) external view returns (PortfolioAsset[] memory);

    function getfCashNotional(
        address account,
        uint16 currencyId,
        uint256 maturity
    ) external view returns (int256);

    function getAssetsBitmap(address account, uint16 currencyId) external view returns (bytes32);

    function getFreeCollateral(address account) external view returns (int256, int256[] memory);

    function calculateNTokensToMint(uint16 currencyId, uint88 amountToDepositExternalPrecision)
        external
        view
        returns (uint256);

    function getfCashAmountGivenCashAmount(
        uint16 currencyId,
        int88 netCashToAccount,
        uint256 marketIndex,
        uint256 blockTime
    ) external view returns (int256);

    function getCashAmountGivenfCashAmount(
        uint16 currencyId,
        int88 fCashAmount,
        uint256 marketIndex,
        uint256 blockTime
    ) external view returns (int256, int256);

    function nTokenGetClaimableIncentives(address account, uint256 blockTime)
        external
        view
        returns (uint256);

} 
pragma solidity ^0.7.0;







 
contract PauseRouter is StorageLayoutV1, UUPSUpgradeable {
    address public immutable VIEWS;
    address public immutable LIQUIDATE_CURRENCY;
    address public immutable LIQUIDATE_FCASH;

    constructor(
        address views_,
        address liquidateCurrency_,
        address liquidatefCash_
    ) {
        VIEWS = views_;
        LIQUIDATE_CURRENCY = liquidateCurrency_;
        LIQUIDATE_FCASH = liquidatefCash_;
    }

    
     
     
     
     
    function _authorizeUpgrade(address newImplementation) internal override {
         
        bool isRollbackCheck = rollbackRouterImplementation != address(0) &&
            newImplementation == rollbackRouterImplementation;

        require(
            owner == msg.sender || (msg.sender == pauseGuardian && isRollbackCheck),
            "Unauthorized upgrade"
        );

         
         
        rollbackRouterImplementation = address(0);
    }

    
    
    function getLiquidationEnabledState() external view returns (bytes1) {
        return liquidationEnabledState;
    }

    
    function setLiquidationEnabledState(bytes1 liquidationEnabledState_) external {
         
        require(owner == msg.sender || msg.sender == pauseGuardian);
        liquidationEnabledState = liquidationEnabledState_;
    }

    function isEnabled(bytes1 state) private view returns (bool) {
        return (liquidationEnabledState & state == state);
    }

    function getRouterImplementation(bytes4 sig) public view returns (address) {
         
         
        if (
            (sig == NotionalProxy.calculateCollateralCurrencyLiquidation.selector ||
                sig == NotionalProxy.liquidateCollateralCurrency.selector) &&
            isEnabled(Constants.COLLATERAL_CURRENCY_ENABLED)
        ) {
            return LIQUIDATE_CURRENCY;
        }

        if (
            (sig == NotionalProxy.calculateLocalCurrencyLiquidation.selector ||
                sig == NotionalProxy.liquidateLocalCurrency.selector) &&
            isEnabled(Constants.LOCAL_CURRENCY_ENABLED)
        ) {
            return LIQUIDATE_CURRENCY;
        }

        if (
            (sig == NotionalProxy.liquidatefCashLocal.selector ||
                sig == NotionalProxy.calculatefCashLocalLiquidation.selector) &&
            isEnabled(Constants.LOCAL_FCASH_ENABLED)
        ) {
            return LIQUIDATE_FCASH;
        }

        if (
            (sig == NotionalProxy.liquidatefCashCrossCurrency.selector ||
                sig == NotionalProxy.calculatefCashCrossCurrencyLiquidation.selector) &&
            isEnabled(Constants.CROSS_CURRENCY_FCASH_ENABLED)
        ) {
            return LIQUIDATE_FCASH;
        }

         
         
        return VIEWS;
    }

    
     
    function _delegate(address implementation) private {
         
        assembly {
             
             
             
            calldatacopy(0, 0, calldatasize())

             
             
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

             
            returndatacopy(0, 0, returndatasize())

            switch result
             
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate(getRouterImplementation(msg.sig));
    }
}

 
pragma solidity ^0.7.0;


library Constants {
     
    uint256 internal constant COMPOUND_RETURN_CODE_NO_ERROR = 0;
    uint8 internal constant CETH_DECIMAL_PLACES = 8;

     
     
    int256 internal constant INTERNAL_TOKEN_PRECISION = 1e8;

     
    uint256 internal constant ETH_CURRENCY_ID = 1;
    uint8 internal constant ETH_DECIMAL_PLACES = 18;
    int256 internal constant ETH_DECIMALS = 1e18;
     
     
     
    uint256 internal constant MAX_DECIMAL_PLACES = 36;

     
    address internal constant RESERVE = address(0);
     
    address constant NOTE_TOKEN_ADDRESS = 0xCFEAead4947f0705A14ec42aC3D44129E1Ef3eD5;

     
    bytes32 internal constant MSB =
        0x8000000000000000000000000000000000000000000000000000000000000000;

     
    int256 internal constant PERCENTAGE_DECIMALS = 100;
     
    uint256 internal constant MAX_TRADED_MARKET_INDEX = 7;
     
     
    uint256 internal constant MAX_BITMAP_ASSETS = 20;
    uint256 internal constant FIVE_MINUTES = 300;

     
    uint256 internal constant DAY = 86400;
     
    uint256 internal constant WEEK = DAY * 6;
    uint256 internal constant MONTH = WEEK * 5;
    uint256 internal constant QUARTER = MONTH * 3;
    uint256 internal constant YEAR = QUARTER * 4;
    
     
    uint256 internal constant DAYS_IN_WEEK = 6;
    uint256 internal constant DAYS_IN_MONTH = 30;
    uint256 internal constant DAYS_IN_QUARTER = 90;

     
    uint256 internal constant MAX_DAY_OFFSET = 90;
    uint256 internal constant MAX_WEEK_OFFSET = 360;
    uint256 internal constant MAX_MONTH_OFFSET = 2160;
    uint256 internal constant MAX_QUARTER_OFFSET = 7650;

     
    uint256 internal constant WEEK_BIT_OFFSET = 90;
    uint256 internal constant MONTH_BIT_OFFSET = 135;
    uint256 internal constant QUARTER_BIT_OFFSET = 195;

     
    uint256 internal constant IMPLIED_RATE_TIME = 360 * DAY;
     
    int256 internal constant RATE_PRECISION = 1e9;
     
    uint256 internal constant BASIS_POINT = uint256(RATE_PRECISION / 10000);
     
    uint256 internal constant DELEVERAGE_BUFFER = 300 * BASIS_POINT;
     
    uint256 internal constant FIVE_BASIS_POINTS = 5 * BASIS_POINT;
     
    uint256 internal constant TEN_BASIS_POINTS = 10 * BASIS_POINT;

     
     
    int128 internal constant RATE_PRECISION_64x64 = 0x3b9aca000000000000000000;
    int128 internal constant LOG_RATE_PRECISION_64x64 = 382276781265598821176;
     
    int256 internal constant MAX_MARKET_PROPORTION = RATE_PRECISION * 96 / 100;

    uint8 internal constant FCASH_ASSET_TYPE = 1;
     
    uint8 internal constant MIN_LIQUIDITY_TOKEN_INDEX = 2;
    uint8 internal constant MAX_LIQUIDITY_TOKEN_INDEX = 8;

     
     
    bytes1 internal constant BOOL_FALSE = 0x00;
    bytes1 internal constant BOOL_TRUE = 0x01;

     
    bytes1 internal constant HAS_ASSET_DEBT = 0x01;
    bytes1 internal constant HAS_CASH_DEBT = 0x02;
    bytes2 internal constant ACTIVE_IN_PORTFOLIO = 0x8000;
    bytes2 internal constant ACTIVE_IN_BALANCES = 0x4000;
    bytes2 internal constant UNMASK_FLAGS = 0x3FFF;
    uint16 internal constant MAX_CURRENCIES = uint16(UNMASK_FLAGS);

     
    int256 internal constant DEPOSIT_PERCENT_BASIS = 1e8;

     
     
    uint8 internal constant LIQUIDATION_HAIRCUT_PERCENTAGE = 0;
    uint8 internal constant CASH_WITHHOLDING_BUFFER = 1;
    uint8 internal constant RESIDUAL_PURCHASE_TIME_BUFFER = 2;
    uint8 internal constant PV_HAIRCUT_PERCENTAGE = 3;
    uint8 internal constant RESIDUAL_PURCHASE_INCENTIVE = 4;

     
     
     
    int256 internal constant DEFAULT_LIQUIDATION_PORTION = 40;
     
    int256 internal constant TOKEN_REPO_INCENTIVE_PERCENT = 30;

     
    bytes1 internal constant LOCAL_CURRENCY_ENABLED = 0x01;
    bytes1 internal constant COLLATERAL_CURRENCY_ENABLED = 0x02;
    bytes1 internal constant LOCAL_FCASH_ENABLED = 0x04;
    bytes1 internal constant CROSS_CURRENCY_FCASH_ENABLED = 0x08;
}

 
pragma solidity ^0.7.0;








interface NotionalProxy is nTokenERC20, nERC1155Interface, NotionalGovernance, NotionalViews {
     
    event CashBalanceChange(address indexed account, uint16 indexed currencyId, int256 netCashChange);
    event nTokenSupplyChange(address indexed account, uint16 indexed currencyId, int256 tokenSupplyChange);
    event MarketsInitialized(uint16 currencyId);
    event SweepCashIntoMarkets(uint16 currencyId, int256 cashIntoMarkets);
    event SettledCashDebt(
        address indexed settledAccount,
        uint16 indexed currencyId,
        address indexed settler,
        int256 amountToSettleAsset,
        int256 fCashAmount
    );
    event nTokenResidualPurchase(
        uint16 indexed currencyId,
        uint40 indexed maturity,
        address indexed purchaser,
        int256 fCashAmountToPurchase,
        int256 netAssetCashNToken
    );
    event LendBorrowTrade(
        address indexed account,
        uint16 indexed currencyId,
        uint40 maturity,
        int256 netAssetCash,
        int256 netfCash
    );
    event AddRemoveLiquidity(
        address indexed account,
        uint16 indexed currencyId,
        uint40 maturity,
        int256 netAssetCash,
        int256 netfCash,
        int256 netLiquidityTokens
    );

    
    event ReserveFeeAccrued(uint16 indexed currencyId, int256 fee);
    
    event AccountContextUpdate(address indexed account);
    
    event AccountSettled(address indexed account);
    
    event SetSettlementRate(uint256 indexed currencyId, uint256 indexed maturity, uint128 rate);

     
    event LiquidateLocalCurrency(
        address indexed liquidated,
        address indexed liquidator,
        uint16 localCurrencyId,
        int256 netLocalFromLiquidator
    );

    event LiquidateCollateralCurrency(
        address indexed liquidated,
        address indexed liquidator,
        uint16 localCurrencyId,
        uint16 collateralCurrencyId,
        int256 netLocalFromLiquidator,
        int256 netCollateralTransfer,
        int256 netNTokenTransfer
    );

    event LiquidatefCashEvent(
        address indexed liquidated,
        address indexed liquidator,
        uint16 localCurrencyId,
        uint16 fCashCurrency,
        int256 netLocalFromLiquidator,
        uint256[] fCashMaturities,
        int256[] fCashNotionalTransfer
    );

     
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
    function getImplementation() external view returns (address);
    function owner() external view returns (address);
    function pauseRouter() external view returns (address);
    function pauseGuardian() external view returns (address);

     
    function initializeMarkets(uint16 currencyId, bool isFirstInit) external;

    function sweepCashIntoMarkets(uint16 currencyId) external;

     
    function nTokenRedeem(
        address redeemer,
        uint16 currencyId,
        uint96 tokensToRedeem_,
        bool sellTokenAssets
    ) external returns (int256);

     
    function enableBitmapCurrency(uint16 currencyId) external;

    function settleAccount(address account) external;

    function depositUnderlyingToken(
        address account,
        uint16 currencyId,
        uint256 amountExternalPrecision
    ) external payable returns (uint256);

    function depositAssetToken(
        address account,
        uint16 currencyId,
        uint256 amountExternalPrecision
    ) external returns (uint256);

    function withdraw(
        uint16 currencyId,
        uint88 amountInternalPrecision,
        bool redeemToUnderlying
    ) external returns (uint256);

     
    function batchBalanceAction(address account, BalanceAction[] calldata actions) external payable;

    function batchBalanceAndTradeAction(address account, BalanceActionWithTrades[] calldata actions)
        external
        payable;

    function batchBalanceAndTradeActionWithCallback(
        address account,
        BalanceActionWithTrades[] calldata actions,
        bytes calldata callbackData
    ) external payable;

     
    function calculateLocalCurrencyLiquidation(
        address liquidateAccount,
        uint16 localCurrency,
        uint96 maxNTokenLiquidation
    ) external returns (int256, int256);

    function liquidateLocalCurrency(
        address liquidateAccount,
        uint16 localCurrency,
        uint96 maxNTokenLiquidation
    ) external returns (int256, int256);

    function calculateCollateralCurrencyLiquidation(
        address liquidateAccount,
        uint16 localCurrency,
        uint16 collateralCurrency,
        uint128 maxCollateralLiquidation,
        uint96 maxNTokenLiquidation
    )
        external
        returns (
            int256,
            int256,
            int256
        );

    function liquidateCollateralCurrency(
        address liquidateAccount,
        uint16 localCurrency,
        uint16 collateralCurrency,
        uint128 maxCollateralLiquidation,
        uint96 maxNTokenLiquidation,
        bool withdrawCollateral,
        bool redeemToUnderlying
    )
        external
        returns (
            int256,
            int256,
            int256
        );

    function calculatefCashLocalLiquidation(
        address liquidateAccount,
        uint16 localCurrency,
        uint256[] calldata fCashMaturities,
        uint256[] calldata maxfCashLiquidateAmounts
    ) external returns (int256[] memory, int256);

    function liquidatefCashLocal(
        address liquidateAccount,
        uint16 localCurrency,
        uint256[] calldata fCashMaturities,
        uint256[] calldata maxfCashLiquidateAmounts
    ) external returns (int256[] memory, int256);

    function calculatefCashCrossCurrencyLiquidation(
        address liquidateAccount,
        uint16 localCurrency,
        uint16 fCashCurrency,
        uint256[] calldata fCashMaturities,
        uint256[] calldata maxfCashLiquidateAmounts
    ) external returns (int256[] memory, int256);

    function liquidatefCashCrossCurrency(
        address liquidateAccount,
        uint16 localCurrency,
        uint16 fCashCurrency,
        uint256[] calldata fCashMaturities,
        uint256[] calldata maxfCashLiquidateAmounts
    ) external returns (int256[] memory, int256);
}

 
pragma solidity ^0.7.0;






 
 
 
 
 
enum TokenType {UnderlyingToken, cToken, cETH, Ether, NonMintable}


 
 
enum TradeActionType {
     
    Lend,
     
    Borrow,
     
    AddLiquidity,
     
    RemoveLiquidity,
     
    PurchaseNTokenResidual,
     
    SettleCashDebt
}


enum DepositActionType {
     
    None,
     
    DepositAsset,
     
     
    DepositUnderlying,
     
     
    DepositAssetAndMintNToken,
     
    DepositUnderlyingAndMintNToken,
     
     
    RedeemNToken,
     
     
    ConvertCashToNToken
}


enum AssetStorageState {NoChange, Update, Delete, RevertIfStored}

 


struct BalanceAction {
     
    DepositActionType actionType;
    uint16 currencyId;
     
    uint256 depositActionAmount;
     
    uint256 withdrawAmountInternalPrecision;
     
     
    bool withdrawEntireCashBalance;
     
    bool redeemToUnderlying;
}


struct BalanceActionWithTrades {
    DepositActionType actionType;
    uint16 currencyId;
    uint256 depositActionAmount;
    uint256 withdrawAmountInternalPrecision;
    bool withdrawEntireCashBalance;
    bool redeemToUnderlying;
     
    bytes32[] trades;
}

 

struct SettleAmount {
    uint256 currencyId;
    int256 netCashChange;
}


struct Token {
    address tokenAddress;
    bool hasTransferFee;
    int256 decimals;
    TokenType tokenType;
    uint256 maxCollateralBalance;
}


struct nTokenPortfolio {
    CashGroupParameters cashGroup;
    PortfolioState portfolioState;
    int256 totalSupply;
    int256 cashBalance;
    uint256 lastInitializedTime;
    bytes6 parameters;
    address tokenAddress;
}


struct LiquidationFactors {
    address account;
     
    int256 netETHValue;
     
    int256 localAssetAvailable;
     
    int256 collateralAssetAvailable;
     
     
    int256 nTokenHaircutAssetValue;
     
    bytes6 nTokenParameters;
     
    ETHRate localETHRate;
     
    ETHRate collateralETHRate;
     
    AssetRateParameters localAssetRate;
     
    CashGroupParameters collateralCashGroup;
     
    bool isCalculation;
}


struct PortfolioState {
     
    PortfolioAsset[] storedAssets;
     
    PortfolioAsset[] newAssets;
    uint256 lastNewAssetIndex;
     
    uint256 storedAssetLength;
}


struct ETHRate {
     
    int256 rateDecimals;
     
    int256 rate;
     
    int256 buffer;
     
    int256 haircut;
     
     
    int256 liquidationDiscount;
}


struct BalanceState {
    uint16 currencyId;
     
    int256 storedCashBalance;
     
    int256 storedNTokenBalance;
     
    int256 netCashChange;
     
    int256 netAssetTransferInternalPrecision;
     
    int256 netNTokenTransfer;
     
    int256 netNTokenSupplyChange;
     
    uint256 lastClaimTime;
     
    uint256 lastClaimIntegralSupply;
}


struct AssetRateParameters {
     
    AssetRateAdapter rateOracle;
     
    int256 rate;
     
    int256 underlyingDecimals;
}


struct CashGroupParameters {
    uint16 currencyId;
    uint256 maxMarketIndex;
    AssetRateParameters assetRate;
    bytes32 data;
}


struct PortfolioAsset {
     
    uint256 currencyId;
    uint256 maturity;
     
    uint256 assetType;
     
    int256 notional;
     
    uint256 storageSlot;
     
    AssetStorageState storageState;
}


struct MarketParameters {
    bytes32 storageSlot;
    uint256 maturity;
     
    int256 totalfCash;
     
    int256 totalAssetCash;
     
    int256 totalLiquidity;
     
     
    uint256 lastImpliedRate;
     
     
    uint256 oracleRate;
     
    uint256 previousTradeTime;
}

 


 
 
 
 
 
struct TokenStorage {
     
    address tokenAddress;
     
    bool hasTransferFee;
    TokenType tokenType;
    uint8 decimalPlaces;
     
    uint72 maxCollateralBalance;
}


struct ETHRateStorage {
     
    AggregatorV2V3Interface rateOracle;
     
    uint8 rateDecimalPlaces;
     
    bool mustInvert;
     
     
    uint8 buffer;
     
    uint8 haircut;
     
    uint8 liquidationDiscount;
}


struct AssetRateStorage {
     
    AssetRateAdapter rateOracle;
     
    uint8 underlyingDecimalPlaces;
}


 
 
 
struct CashGroupSettings {
     
     
    uint8 maxMarketIndex;
     
    uint8 rateOracleTimeWindow5Min;
     
    uint8 totalFeeBPS;
     
    uint8 reserveFeeShare;
     
    uint8 debtBuffer5BPS;
     
    uint8 fCashHaircut5BPS;
     
     
    uint8 settlementPenaltyRate5BPS;
     
    uint8 liquidationfCashHaircut5BPS;
     
    uint8 liquidationDebtBuffer5BPS;
     
    uint8[] liquidityTokenHaircuts;
     
    uint8[] rateScalars;
}


 
struct AccountContext {
     
    uint40 nextSettleTime;
     
    bytes1 hasDebt;
     
    uint8 assetArrayLength;
     
    uint16 bitmapCurrencyId;
     
    bytes18 activeCurrencies;
}


 
struct nTokenContext {
     
    uint16 currencyId;
     
     
    uint32 incentiveAnnualEmissionRate;
     
     
    uint32 lastInitializedTime;
     
     
    uint8 assetArrayLength;
     
    bytes5 nTokenParameters;
}


struct BalanceStorage {
     
    uint80 nTokenBalance;
     
    uint32 lastClaimTime;
     
     
    uint56 packedLastClaimIntegralSupply;
     
    int88 cashBalance;
}


struct SettlementRateStorage {
    uint40 blockTime;
    uint128 settlementRate;
    uint8 underlyingDecimalPlaces;
}


 
struct MarketStorage {
     
    uint80 totalfCash;
     
    uint80 totalAssetCash;
     
    uint32 lastImpliedRate;
     
    uint32 oracleRate;
     
    uint32 previousTradeTime;
     
    uint80 totalLiquidity;
}

struct ifCashStorage {
     
     
    int128 notional;
}


struct PortfolioAssetStorage {
     
    uint16 currencyId;
     
    uint40 maturity;
     
    uint8 assetType;
     
    int88 notional;
}


 
struct nTokenTotalSupplyStorage {
     
    uint96 totalSupply;
     
    uint128 integralTotalSupply;
     
    uint32 lastSupplyChangeTime;
}


struct AccountBalance {
    uint16 currencyId;
    int256 cashBalance;
    int256 nTokenBalance;
    uint256 lastClaimTime;
    uint256 lastClaimIntegralSupply;
}

 
pragma solidity >=0.6.0;




interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{
}

 
pragma solidity >=0.7.0;


 
 
interface AssetRateAdapter {
    function token() external view returns (address);

    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function underlying() external view returns (address);

    function getExchangeRateStateful() external returns (int256);

    function getExchangeRateView() external view returns (int256);

    function getAnnualizedSupplyRate() external view returns (uint256);
}

 

pragma solidity >=0.6.2 <0.8.0;

 
library Address {
     
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

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
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

 

pragma solidity ^0.7.0;

 
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

     
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}
