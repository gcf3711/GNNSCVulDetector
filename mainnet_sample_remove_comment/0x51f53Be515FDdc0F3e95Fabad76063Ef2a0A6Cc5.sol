 
pragma experimental ABIEncoderV2;

 
pragma solidity 0.7.6;






contract QueryHelper {
    using DexData for bytes;
    using SafeMath for uint;

    constructor ()
    {

    }
    struct PositionVars {
        uint deposited;
        uint held;
        uint borrowed;
        uint marginRatio;
        uint32 marginLimit;
    }
    enum LiqStatus{
        HEALTHY,  
        UPDATE,  
        WAITING,  
        LIQ,  
        NOP 
    }

    struct LiqVars {
        LiqStatus status;
        uint lastUpdateTime;
        uint currentMarginRatio;
        uint cAvgMarginRatio;
        uint hAvgMarginRatio;
        uint32 marginLimit;
    }

    struct PoolVars {
        uint totalBorrows;
        uint cash;
        uint totalReserves;
        uint availableForBorrow;
        uint insurance;
        uint supplyRatePerBlock;
        uint borrowRatePerBlock;
        uint reserveFactorMantissa;
        uint exchangeRate;
        uint baseRatePerBlock;
        uint multiplierPerBlock;
        uint jumpMultiplierPerBlock;
        uint kink;
    }

    struct XOLEVars {
        uint totalStaked;
        uint totalShared;
        uint tranferedToAccount;
        uint devFund;
        uint balanceOf;
    }

    function getTraderPositons(IOpenLev openLev, uint16 marketId, address[] calldata traders, bool[] calldata longTokens, bytes calldata dexData) external view returns (PositionVars[] memory results){
        results = new PositionVars[](traders.length);
        IOpenLev.MarketVar memory market = openLev.markets(marketId);
        for (uint i = 0; i < traders.length; i++) {
            PositionVars memory item;
            Types.Trade memory trade = openLev.activeTrades(traders[i], marketId, longTokens[i]);
            if (trade.held == 0) {
                results[i] = item;
                continue;
            }
            item.held = trade.held;
            item.deposited = trade.deposited;
            (item.marginRatio,,,item.marginLimit) = openLev.marginRatio(traders[i], marketId, longTokens[i], dexData);
            item.borrowed = longTokens[i] ? market.pool0.borrowBalanceCurrent(traders[i]) : market.pool1.borrowBalanceCurrent(traders[i]);
            results[i] = item;
        }
        return results;
    }

    struct LiqReqVars {
        IOpenLev openLev;
        address owner;
        uint16 marketId;
        bool longToken;
        uint256 token0price;
        uint256 token0cAvgPrice;
        uint256 token1price;
        uint256 token1cAvgPrice;
        uint256 timestamp;
        bytes dexData;
    }
     
    function getTraderLiqs(IOpenLev openLev, uint16 marketId, address[] calldata traders, bool[] calldata longTokens, bytes calldata dexData) external returns (LiqVars[] memory results){
        results = new LiqVars[](traders.length);
        LiqReqVars memory reqVar;
        reqVar.openLev = openLev;
        reqVar.marketId = marketId;
        reqVar.dexData = dexData;
        IOpenLev.MarketVar memory market = reqVar.openLev.markets(reqVar.marketId);
        IOpenLev.AddressConfig memory adrConf = reqVar.openLev.addressConfig();
        IOpenLev.CalculateConfig memory calConf = reqVar.openLev.getCalculateConfig();
        (,,,, reqVar.timestamp) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(market.token0, market.token1, calConf.twapDuration, reqVar.dexData);
        openLev.updatePrice(marketId, dexData);
        (reqVar.token0price, reqVar.token0cAvgPrice,,,) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(market.token0, market.token1, calConf.twapDuration, reqVar.dexData);
        (reqVar.token1price, reqVar.token1cAvgPrice,,,) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(market.token1, market.token0, calConf.twapDuration, reqVar.dexData);

        for (uint i = 0; i < traders.length; i++) {
            reqVar.owner = traders[i];
            reqVar.longToken = longTokens[i];
            LiqVars memory item;
            Types.Trade memory trade = reqVar.openLev.activeTrades(reqVar.owner, reqVar.marketId, reqVar.longToken);
            if (trade.held == 0) {
                item.status = LiqStatus.NOP;
                results[i] = item;
                continue;
            }
            item.lastUpdateTime = reqVar.timestamp;
            (item.currentMarginRatio, item.cAvgMarginRatio, item.hAvgMarginRatio, item.marginLimit) = reqVar.openLev.marginRatio(reqVar.owner, reqVar.marketId, reqVar.longToken, reqVar.dexData);
            if (item.currentMarginRatio > item.marginLimit && item.cAvgMarginRatio > item.marginLimit && item.hAvgMarginRatio > item.marginLimit) {
                item.status = LiqStatus.HEALTHY;
            }
            else if (item.currentMarginRatio < item.marginLimit && item.cAvgMarginRatio > item.marginLimit && item.hAvgMarginRatio > item.marginLimit) {
                if (dexData.isUniV2Class()) {
                    if (block.timestamp - calConf.twapDuration > item.lastUpdateTime) {
                        item.status = LiqStatus.UPDATE;
                    } else {
                        item.status = LiqStatus.WAITING;
                    }
                } else {
                    item.status = LiqStatus.WAITING;
                }
            } else if (item.currentMarginRatio < item.marginLimit && item.cAvgMarginRatio < item.marginLimit) {
                 
                if (block.timestamp - calConf.twapDuration > item.lastUpdateTime || item.hAvgMarginRatio < item.marginLimit) {
                     
                    if ((longTokens[i] == false && reqVar.token0cAvgPrice > reqVar.token0price && reqVar.token0cAvgPrice.mul(100).div(reqVar.token0price) - 100 >= calConf.maxLiquidationPriceDiffientRatio)
                        || (longTokens[i] == true && reqVar.token1cAvgPrice > reqVar.token1price && reqVar.token1cAvgPrice.mul(100).div(reqVar.token1price) - 100 >= calConf.maxLiquidationPriceDiffientRatio)) {
                        if (dexData.isUniV2Class()) {
                            item.status = LiqStatus.UPDATE;
                        } else {
                            item.status = LiqStatus.WAITING;
                        }
                    } else {
                        item.status = LiqStatus.LIQ;
                    }
                } else {
                    item.status = LiqStatus.WAITING;
                }
            }
            results[i] = item;
        }
        return results;
    }
     
    function calPriceCAvgPriceHAvgPrice(IOpenLev openLev, uint16 marketId, address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external
    returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp){
        IOpenLev.AddressConfig memory adrConf = openLev.addressConfig();
        (,,,, timestamp) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(desToken, quoteToken, secondsAgo, dexData);
        openLev.updatePrice(marketId, dexData);
        (price, cAvgPrice, hAvgPrice, decimals,) = adrConf.dexAggregator.getPriceCAvgPriceHAvgPrice(desToken, quoteToken, secondsAgo, dexData);
    }

    struct LiqCallVars {
        uint defaultFees;
        uint newFees;
        uint penalty;
        uint heldAfterFees;
        uint borrows;
        uint currentBuyAmount;
        uint currentSellAmount;
        bool canRepayBorrows;
    }
     
    function getLiqCallData(IOpenLev openLev, IV3Quoter v3Quoter, uint16 marketId, uint16 slippage, address trader, bool longToken, bytes memory dexData) external returns (uint minOrMaxAmount,
        bytes memory callDexData)
    {
        IOpenLev.MarketVar memory market = openLev.markets(marketId);
        Types.Trade memory trade = openLev.activeTrades(trader, marketId, longToken);
        LiqCallVars memory callVars;
         
        callVars.defaultFees = trade.held.mul(market.feesRate).div(10000);
        callVars.newFees = callVars.defaultFees;
        IOpenLev.AddressConfig memory adrConf = openLev.addressConfig();
        IOpenLev.CalculateConfig memory calConf = openLev.getCalculateConfig();
         
        if (IXOLE(adrConf.xOLE).balanceOf(trader) > calConf.feesDiscountThreshold) {
            callVars.newFees = callVars.defaultFees.sub(callVars.defaultFees.mul(calConf.feesDiscount).div(100));
        }
         
        if (market.priceUpdater == trader) {
            callVars.newFees = callVars.newFees.sub(callVars.defaultFees.mul(calConf.updatePriceDiscount).div(100));
        }
        callVars.penalty = trade.held.mul(calConf.penaltyRatio).div(10000);
        callVars.heldAfterFees = trade.held.sub(callVars.penalty).sub(callVars.newFees);
        callVars.borrows = longToken ? market.pool0.borrowBalanceCurrent(trader) : market.pool1.borrowBalanceCurrent(trader);

        callVars.currentBuyAmount = dexData.isUniV2Class() ?
        adrConf.dexAggregator.calBuyAmount(longToken ?
            market.token0 : market.token1, longToken ? market.token1 : market.token0, callVars.heldAfterFees, dexData) :
        v3Quoter.quoteExactInputSingle(longToken ? market.token1 : market.token0, longToken ? market.token0 : market.token1, dexData.toFee(), callVars.heldAfterFees, 0);
        callVars.canRepayBorrows = callVars.currentBuyAmount >= callVars.borrows;
         
        if (trade.depositToken != longToken || !callVars.canRepayBorrows) {
            minOrMaxAmount = callVars.currentBuyAmount.sub(callVars.currentBuyAmount.mul(slippage).div(1000));
            callDexData = dexData.isUniV2Class() ? dexData : abi.encodePacked(dexData, hex"01");
        }
         
        else {
            callVars.currentSellAmount = dexData.isUniV2Class() ?
            adrConf.dexAggregator.calSellAmount(longToken ?
                market.token0 : market.token1, longToken ? market.token1 : market.token0, callVars.borrows, dexData) :
            v3Quoter.quoteExactOutputSingle(longToken ? market.token1 : market.token0, longToken ? market.token0 : market.token1, dexData.toFee(), callVars.borrows, 0);
            minOrMaxAmount = callVars.currentSellAmount.add(callVars.currentSellAmount.mul(slippage).div(1000));
            callDexData = dexData.isUniV2Class() ? dexData : abi.encodePacked(dexData, hex"00");
        }
    }

    function getPoolDetails(IOpenLev openLev, uint16[] calldata marketIds, LPoolInterface[] calldata pools) external view returns (PoolVars[] memory results){
        results = new PoolVars[](pools.length);
        for (uint i = 0; i < pools.length; i++) {
            LPoolInterface pool = pools[i];
            IOpenLev.MarketVar memory market = openLev.markets(marketIds[i]);
            PoolVars memory item;
            item.insurance = address(market.pool0) == address(pool) ? market.pool0Insurance : market.pool1Insurance;
            item.cash = pool.getCash();
            item.totalBorrows = pool.totalBorrowsCurrent();
            item.totalReserves = pool.totalReserves();
            item.availableForBorrow = pool.availableForBorrow();
            item.supplyRatePerBlock = pool.supplyRatePerBlock();
            item.borrowRatePerBlock = pool.borrowRatePerBlock();
            item.reserveFactorMantissa = pool.reserveFactorMantissa();
            item.exchangeRate = pool.exchangeRateStored();
            item.baseRatePerBlock = pool.baseRatePerBlock();
            item.multiplierPerBlock = pool.multiplierPerBlock();
            item.jumpMultiplierPerBlock = pool.jumpMultiplierPerBlock();
            item.kink = pool.kink();
            results[i] = item;
        }
        return results;
    }

    function getXOLEDetail(IXOLE xole, IERC20 balanceOfToken) external view returns (XOLEVars memory vars){
        vars.totalStaked = xole.totalLocked();
        vars.totalShared = xole.totalRewarded();
        vars.tranferedToAccount = xole.withdrewReward();
        vars.devFund = xole.devFund();
        if (address(0) != address(balanceOfToken)) {
            vars.balanceOf = balanceOfToken.balanceOf(address(xole));
        }
    }
}

interface IXOLE {
    function totalLocked() external view returns (uint256);

    function totalRewarded() external view returns (uint256);

    function withdrewReward() external view returns (uint256);

    function devFund() external view returns (uint256);

    function balanceOf(address addr) external view returns (uint256);


}

interface DexAggregatorInterface {
    function calBuyAmount(address buyToken, address sellToken, uint sellAmount, bytes memory data) external view returns (uint);

    function calSellAmount(address buyToken, address sellToken, uint buyAmount, bytes memory data) external view returns (uint);

    function getPriceCAvgPriceHAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);

}

interface IV3Quoter {
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);

    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);
}

interface IOpenLev {
    struct MarketVar { 
        LPoolInterface pool0;        
        LPoolInterface pool1;        
        address token0;               
        address token1;               
        uint16 marginLimit;          
        uint16 feesRate;             
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint pool0Insurance;         
        uint pool1Insurance;         
    }

    struct AddressConfig {
        DexAggregatorInterface dexAggregator;
        address controller;
        address wETH;
        address xOLE;
    }

    struct CalculateConfig {
        uint16 defaultFeesRate;  
        uint8 insuranceRatio;  
        uint16 defaultMarginLimit;  
        uint16 priceDiffientRatio;  
        uint16 updatePriceDiscount; 
        uint16 feesDiscount;  
        uint128 feesDiscountThreshold;  
        uint16 penaltyRatio; 
        uint8 maxLiquidationPriceDiffientRatio; 
        uint16 twapDuration; 
    }

    function activeTrades(address owner, uint16 marketId, bool longToken) external view returns (Types.Trade memory);

    function marginRatio(address owner, uint16 marketId, bool longToken, bytes memory dexData) external view returns (uint current, uint cAvg, uint hAvg, uint32 limit);

    function markets(uint16 marketId) external view returns (MarketVar memory);

    function getMarketSupportDexs(uint16 marketId) external view returns (uint32[] memory);

    function addressConfig() external view returns (AddressConfig memory);

    function getCalculateConfig() external view returns (CalculateConfig memory);

    function updatePrice(uint16 marketId, bytes memory dexData) external;

}

 
pragma solidity 0.7.6;


abstract contract LPoolStorage {

     
    bool internal _notEntered;

     
    string public name;

     
    string public symbol;

     
    uint8 public decimals;

     
    uint public totalSupply;


     
    mapping(address => uint) internal accountTokens;

     
    mapping(address => mapping(address => uint)) internal transferAllowances;


     
    uint internal constant borrowRateMaxMantissa = 0.0005e16;

     
    uint public  borrowCapFactorMantissa;
     
    address public controller;


     
    uint internal initialExchangeRateMantissa;

     
    uint public accrualBlockNumber;

     
    uint public borrowIndex;

     
    uint public totalBorrows;

    uint internal totalCash;

     
    uint public reserveFactorMantissa;

    uint public totalReserves;

    address public underlying;

    bool public isWethPool;

     
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    uint256 public baseRatePerBlock;
    uint256 public multiplierPerBlock;
    uint256 public jumpMultiplierPerBlock;
    uint256 public kink;

     

    mapping(address => BorrowSnapshot) internal accountBorrows;




     

     
    event Mint(address minter, uint mintAmount, uint mintTokens);

     
    event Transfer(address indexed from, address indexed to, uint amount);

     
    event Approval(address indexed owner, address indexed spender, uint amount);

     

     
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

     
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

     
    event Borrow(address borrower, address payee, uint borrowAmount, uint accountBorrows, uint totalBorrows);

     
    event RepayBorrow(address payer, address borrower, uint repayAmount, uint badDebtsAmount, uint accountBorrows, uint totalBorrows);

     

     
    event NewController(address oldController, address newController);

     
    event NewInterestParam(uint baseRatePerBlock, uint multiplierPerBlock, uint jumpMultiplierPerBlock, uint kink);

     
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

     
    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

     
    event ReservesReduced(address to, uint reduceAmount, uint newTotalReserves);

    event NewBorrowCapFactorMantissa(uint oldBorrowCapFactorMantissa, uint newBorrowCapFactorMantissa);

}

abstract contract LPoolInterface is LPoolStorage {


     

    function transfer(address dst, uint amount) external virtual returns (bool);

    function transferFrom(address src, address dst, uint amount) external virtual returns (bool);

    function approve(address spender, uint amount) external virtual returns (bool);

    function allowance(address owner, address spender) external virtual view returns (uint);

    function balanceOf(address owner) external virtual view returns (uint);

    function balanceOfUnderlying(address owner) external virtual returns (uint);

     

    function mint(uint mintAmount) external virtual;

    function mintTo(address to) external payable virtual;

    function mintEth() external payable virtual;

    function redeem(uint redeemTokens) external virtual;

    function redeemUnderlying(uint redeemAmount) external virtual;

    function borrowBehalf(address borrower, uint borrowAmount) external virtual;

    function repayBorrowBehalf(address borrower, uint repayAmount) external virtual;

    function repayBorrowEndByOpenLev(address borrower, uint repayAmount) external virtual;

    function availableForBorrow() external view virtual returns (uint);

    function getAccountSnapshot(address account) external virtual view returns (uint, uint, uint);

    function borrowRatePerBlock() external virtual view returns (uint);

    function supplyRatePerBlock() external virtual view returns (uint);

    function totalBorrowsCurrent() external virtual view returns (uint);

    function borrowBalanceCurrent(address account) external virtual view returns (uint);

    function borrowBalanceStored(address account) external virtual view returns (uint);

    function exchangeRateCurrent() public virtual returns (uint);

    function exchangeRateStored() public virtual view returns (uint);

    function getCash() external view virtual returns (uint);

    function accrueInterest() public virtual;

    function sync() public virtual;

     

    function setController(address newController) external virtual;

    function setBorrowCapFactorMantissa(uint newBorrowCapFactorMantissa) external virtual;

    function setInterestParams(uint baseRatePerBlock_, uint multiplierPerBlock_, uint jumpMultiplierPerBlock_, uint kink_) external virtual;

    function setReserveFactor(uint newReserveFactorMantissa) external virtual;

    function addReserves(uint addAmount) external virtual;

    function reduceReserves(address payable to, uint reduceAmount) external virtual;

}

 
pragma solidity >=0.6.0 <0.8.0;



library DexData {
    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant FEE_SIZE = 3;
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;


    uint constant dexNameStart = 0;
    uint constant dexNameLength = 1;
    uint constant feeStart = 1;
    uint constant feeLength = 3;
    uint constant uniV3QuoteFlagStart = 4;
    uint constant uniV3QuoteFlagLength = 1;

    uint8 constant DEX_UNIV2 = 1;
    uint8 constant DEX_UNIV3 = 2;
    uint8 constant DEX_PANCAKE = 3;
    uint8 constant DEX_SUSHI = 4;
    uint8 constant DEX_MDEX = 5;
    uint8 constant DEX_TRADERJOE = 6;
    uint8 constant DEX_SPOOKY = 7;
    uint8 constant DEX_QUICK = 8;
    uint8 constant DEX_SHIBA = 9;
    uint8 constant DEX_APE = 10;

    bytes constant UNIV2 = hex"01";

    struct V3PoolData {
        address tokenA;
        address tokenB;
        uint24 fee;
    }

    function toDex(bytes memory data) internal pure returns (uint8) {
        require(data.length >= dexNameLength, 'dex error');
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, dexNameStart))))
        }
        return temp;
    }

    function toFee(bytes memory data) internal pure returns (uint24) {
        require(data.length >= dexNameLength + feeLength, 'fee error');
        uint temp;
        assembly {
            temp := mload(add(data, add(0x20, feeStart)))
        }
        return uint24(temp >> (256 - (feeLength * 8)));
    }

    function toDexDetail(bytes memory data) internal pure returns (uint32) {
        if (data.length == dexNameLength) {
            uint8 temp;
            assembly {
                temp := byte(0, mload(add(data, add(0x20, dexNameStart))))
            }
            return uint32(temp);
        } else {
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, dexNameStart)))
            }
            return uint32(temp >> (256 - ((feeLength + dexNameLength) * 8)));
        }
    }
     
    function toUniV3QuoteFlag(bytes memory data) internal pure returns (bool) {
        require(data.length >= dexNameLength + feeLength + uniV3QuoteFlagLength, 'v3flag error');
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, uniV3QuoteFlagStart))))
        }
        return temp > 0;
    }

     
    function isUniV2Class(bytes memory data) internal pure returns (bool) {
        return (data.length - dexNameLength) % 20 == 0;
    }
     
    function toUniV2Path(bytes memory data) internal pure returns (address[] memory path) {
        data = slice(data, dexNameLength, data.length - dexNameLength);
        uint pathLength = data.length / 20;
        path = new address[](pathLength);
        for (uint i = 0; i < pathLength; i++) {
            path[i] = toAddress(data, 20 * i);
        }
    }

     
    function toUniV3Path(bytes memory data) internal pure returns (V3PoolData[] memory path) {
        data = slice(data, uniV3QuoteFlagStart + uniV3QuoteFlagLength, data.length - (uniV3QuoteFlagStart + uniV3QuoteFlagLength));
        uint pathLength = numPools(data);
        path = new V3PoolData[](pathLength);
        for (uint i = 0; i < pathLength; i++) {
            V3PoolData memory pool;
            if (i != 0) {
                data = slice(data, NEXT_OFFSET, data.length - NEXT_OFFSET);
            }
            pool.tokenA = toAddress(data, 0);
            pool.fee = toUint24(data, ADDR_SIZE);
            pool.tokenB = toAddress(data, NEXT_OFFSET);
            path[i] = pool;
        }
    }

    function numPools(bytes memory path) internal pure returns (uint256) {
         
        return ((path.length - ADDR_SIZE) / NEXT_OFFSET);
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }
        return tempUint;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;
        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }
        return tempAddress;
    }


    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
             
             
                tempBytes := mload(0x40)

             
             
             
             
             
             
             
             
                let lengthmod := and(_length, 31)

             
             
             
             
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                 
                 
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

             
             
                mstore(0x40, and(add(mc, 31), not(31)))
            }
             
            default {
                tempBytes := mload(0x40)
             
             
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

}

 
pragma solidity 0.7.6;






library Types {
    using SafeERC20 for IERC20;

    struct Market { 
        LPoolInterface pool0;        
        LPoolInterface pool1;        
        address token0;               
        address token1;               
        uint16 marginLimit;          
        uint16 feesRate;             
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint pool0Insurance;         
        uint pool1Insurance;         
        uint32[] dexs;
    }

    struct Trade { 
        uint deposited;              
        uint held;                   
        bool depositToken;           
        uint128 lastBlockNum;        
    }

    struct MarketVars { 
        LPoolInterface buyPool;      
        LPoolInterface sellPool;     
        IERC20 buyToken;             
        IERC20 sellToken;            
        uint buyPoolInsurance;       
        uint sellPoolInsurance;      
        uint16 marginLimit;          
        uint16 priceDiffientRatio;
        uint32[] dexs;
    }

    struct TradeVars { 
        uint depositValue;           
        IERC20 depositErc20;         
        uint fees;                   
        uint depositAfterFees;       
        uint tradeSize;              
        uint newHeld;                
        uint borrowValue;
        uint token0Price;
        uint32 dexDetail;
    }

    struct CloseTradeVars { 
        uint16 marketId;
        bool longToken;
        bool depositToken;
        uint closeRatio;           
        bool isPartialClose;         
        uint closeAmountAfterFees;   
        uint repayAmount;            
        uint depositDecrease;        
        uint depositReturn;          
        uint sellAmount;
        uint receiveAmount;
        uint token0Price;
        uint fees;                   
        uint32 dexDetail;
    }


    struct LiquidateVars { 
        uint16 marketId;
        bool longToken;
        uint borrowed;               
        uint fees;                   
        uint penalty;                
        uint remainHeldAfterFees;    
        bool isSellAllHeld;          
        uint depositDecrease;        
        uint depositReturn;          
        uint sellAmount;
        uint receiveAmount;
        uint token0Price;
        uint outstandingAmount;
        uint32 dexDetail;
    }

    struct MarginRatioVars {
        address heldToken;
        address sellToken;
        address owner;
        uint held;
        bytes dexData;
        uint16 multiplier;
    }
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

 

pragma solidity >=0.6.0 <0.8.0;





 
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