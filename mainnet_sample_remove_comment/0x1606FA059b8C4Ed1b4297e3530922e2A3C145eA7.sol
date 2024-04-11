 


 

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

 

pragma solidity ^0.7.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () {
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
}

 
pragma solidity >=0.7.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

 
pragma solidity >=0.7.0;

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









interface IDecimals {
    function decimals() external view returns (uint8);
}

 
contract SmtPriceFeed is Ownable {
    using SafeMath for uint256;

     
    uint256 public immutable decimals;
    uint256 public constant ONE_BASE18 = 10**18;
    address public immutable USDC_ADDRESS;
    uint256 public immutable ONE_ON_USDC;

    
    address public smtTokenAddress;
    
    IBRegistry public registry;
    
    IEurPriceFeedForSmtPriceFeed public eurPriceFeed;
    
    IXTokenWrapper public xTokenWrapper;
    
    uint256 public currentPrice;

     
    event RegistrySet(address registry);

     
    event EurPriceFeedSet(address eurPriceFeed);

     
    event SmtSet(address smtTokenAddress);

     
    event XTokenWrapperSet(address xTokenWrapper);

     
    event PriceComputed(address caller, uint256 price);

    modifier onlyValidAsset(address _asset) {
        require(xTokenWrapper.xTokenToToken(_asset) != address(0), "invalid asset");
        _;
    }

     
    constructor(
        address _registry,
        address _eurPriceFeed,
        address _smt,
        address _xTokenWrapper,
        address _usdcAddress
    ) {
        _setRegistry(_registry);
        _setEurPriceFeed(_eurPriceFeed);
        _setSmt(_smt);
        _setXTokenWrapper(_xTokenWrapper);

        require(_usdcAddress != address(0), "err: _usdcAddress is ZERO address");
        USDC_ADDRESS = _usdcAddress;
        uint8 usdcDecimals = IDecimals(_usdcAddress).decimals();
        decimals = usdcDecimals;
        ONE_ON_USDC = 10**usdcDecimals;
    }

     
    function setRegistry(address _registry) external onlyOwner {
        _setRegistry(_registry);
    }

     
    function setEurPriceFeed(address _eurPriceFeed) external onlyOwner {
        _setEurPriceFeed(_eurPriceFeed);
    }

     
    function setSmt(address _smt) external onlyOwner {
        _setSmt(_smt);
    }

     
    function setXTokenWrapper(address _xTokenWrapper) external onlyOwner {
        _setXTokenWrapper(_xTokenWrapper);
    }

     
    function _setRegistry(address _registry) internal {
        require(_registry != address(0), "registry is the zero address");
        emit RegistrySet(_registry);
        registry = IBRegistry(_registry);
    }

     
    function _setEurPriceFeed(address _eurPriceFeed) internal {
        require(_eurPriceFeed != address(0), "eurPriceFeed is the zero address");
        emit EurPriceFeedSet(_eurPriceFeed);
        eurPriceFeed = IEurPriceFeedForSmtPriceFeed(_eurPriceFeed);
    }

     
    function _setSmt(address _smtTokenAddress) internal {
        require(_smtTokenAddress != address(0), "smtTokenAddress is the zero address");
        emit SmtSet(_smtTokenAddress);
        smtTokenAddress = _smtTokenAddress;
    }

     
    function _setXTokenWrapper(address _xTokenWrapper) internal {
        require(_xTokenWrapper != address(0), "xTokenWrapper is the zero address");
        emit XTokenWrapperSet(_xTokenWrapper);
        xTokenWrapper = IXTokenWrapper(_xTokenWrapper);
    }

     
    function getPrice(address _asset) external view onlyValidAsset(_asset) returns (uint256) {
        uint8 assetDecimals = IDecimals(_asset).decimals();
        return calculateAmount(_asset, 10**assetDecimals);
    }

     
    function calculateAmount(address _asset, uint256 _assetAmountIn)
        public
        view
        onlyValidAsset(_asset)
        returns (uint256)
    {
         
        address xSMT = xTokenWrapper.tokenToXToken(smtTokenAddress);

         
        if (_asset == xSMT) {
            return _assetAmountIn;
        }

         
         
        uint256 amount = getAvgAmountFromPools(_asset, xSMT, _assetAmountIn);

         
         
        if (amount == 0) {
             
            address xUSDC = xTokenWrapper.tokenToXToken(USDC_ADDRESS);

             
             
            uint256 xUsdcForSmtAmount = getAvgAmountFromPools(xUSDC, xSMT, ONE_ON_USDC);
            require(xUsdcForSmtAmount > 0, "no xUSDC/xSMT pool to get _asset price");

             
            uint256 eurAmountForAsset = eurPriceFeed.calculateAmount(_asset, _assetAmountIn);
            if (eurAmountForAsset == 0) {
                return 0;
            }

            uint256 eurPriceFeedDecimals = eurPriceFeed.RETURN_DIGITS_BASE18();
             
            address eurUsdFeedAddress = eurPriceFeed.eurUsdFeed();

             
             
            uint256 eurUsdDecimals = AggregatorV2V3Interface(eurUsdFeedAddress).decimals();
            int256 amountUsdToGetEur = AggregatorV2V3Interface(eurUsdFeedAddress).latestAnswer();
            if (amountUsdToGetEur == 0) {
                return 0;
            }
            uint256 amountUsdToGetEur18 = uint256(amountUsdToGetEur).mul(
                10**(eurPriceFeedDecimals.sub(eurUsdDecimals))
            );

             
            uint256 assetAmountInUSD = amountUsdToGetEur18.mul(eurAmountForAsset).div(ONE_BASE18);

             
             
             
             
            amount = assetAmountInUSD.mul(xUsdcForSmtAmount).div(ONE_BASE18);
        }
        return amount;
    }

     
    function latestAnswer() external view returns (int256) {
        return int256(currentPrice);
    }

     
    function computePrice() public {
         
         
        currentPrice = getAvgAmountFromPools(
            xTokenWrapper.tokenToXToken(smtTokenAddress),
            xTokenWrapper.tokenToXToken(USDC_ADDRESS),
            ONE_BASE18
        );

        emit PriceComputed(msg.sender, currentPrice);
    }

    function getAvgAmountFromPools(
        address _assetIn,
        address _assetOut,
        uint256 _assetAmountIn
    ) internal view returns (uint256) {
        address[] memory poolAddresses = registry.getBestPoolsWithLimit(_assetIn, _assetOut, 10);

        uint256 totalAmount;
        uint256 totalQty = 0;
        uint256 singlePoolOutGivenIn = 0;
        for (uint256 i = 0; i < poolAddresses.length; i++) {
            singlePoolOutGivenIn = calcOutGivenIn(poolAddresses[i], _assetIn, _assetOut, _assetAmountIn);

            if (singlePoolOutGivenIn > 0) {
                totalQty = totalQty.add(1);
                totalAmount = totalAmount.add(singlePoolOutGivenIn);
            }
        }
        uint256 amountToReturn = 0;
        if (totalAmount > 0 && totalQty > 0) {
            amountToReturn = totalAmount.div(totalQty);
        }

        return amountToReturn;
    }

    function calcOutGivenIn(
        address poolAddress,
        address _assetIn,
        address _assetOut,
        uint256 _assetAmountIn
    ) internal view returns (uint256) {
        IBPool pool = IBPool(poolAddress);
        uint256 tokenBalanceIn = pool.getBalance(_assetIn);
        uint256 tokenBalanceOut = pool.getBalance(_assetOut);

        if (tokenBalanceIn == 0 || tokenBalanceOut == 0) {
            return 0;
        } else {
            uint256 tokenWeightIn = pool.getDenormalizedWeight(_assetIn);
            uint256 tokenWeightOut = pool.getDenormalizedWeight(_assetOut);
            uint256 amount = pool.calcOutGivenIn(
                tokenBalanceIn,
                tokenWeightIn,
                tokenBalanceOut,
                tokenWeightOut,
                _assetAmountIn,
                0
            );
            return amount;
        }
    }
}

 

pragma solidity ^0.7.0;

 
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

 
pragma solidity >=0.7.0;




interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{
}

 
pragma solidity ^0.7.0;

 
interface IBPool {
    function getDenormalizedWeight(address token) external view returns (uint256);

    function getBalance(address token) external view returns (uint256);

    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);
}

 
pragma solidity ^0.7.0;

 

interface IBRegistry {
    function getBestPoolsWithLimit(
        address fromToken,
        address destToken,
        uint256 limit
    ) external view returns (address[] memory);
}

 
pragma solidity ^0.7.0;

 
interface IEurPriceFeedForSmtPriceFeed {
     
    function RETURN_DIGITS_BASE18() external view returns (uint256);

     
    function eurUsdFeed() external view returns (address);

     
    function calculateAmount(address _asset, uint256 _amount) external view returns (uint256);
}

 
pragma solidity ^0.7.0;

 
interface IXTokenWrapper {
     
    function tokenToXToken(address _token) external view returns (address);

    function xTokenToToken(address _token) external view returns (address);
}
