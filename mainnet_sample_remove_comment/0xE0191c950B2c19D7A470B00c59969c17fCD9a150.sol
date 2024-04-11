 


 

pragma solidity 0.7.6;

interface IBaseOracle {
  
  function getICHIPrice(address pair_, address chainlink_) external view returns (uint256);
  function getBaseToken() external view returns (address);
  function decimals() external view returns (uint256);
}

 

pragma solidity 0.7.6;




abstract contract UsingBaseOracle is IBaseOracle {
  
}
 

pragma solidity 0.7.6;






interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

 
contract ICHISpotOracleUSDBancor is UsingBaseOracle{
    using SafeMath for uint256;

    address public ICHI = 0x903bEF1736CDdf2A537176cf3C64579C3867A881;

    uint256 constant PERCISION = 18;

    function getICHIPrice(address pair_, address chainlink_) external view override returns (uint256 price) {
        IBancorPair _pair = IBancorPair(pair_);
        
        (uint256 reserve0, uint256 reserve1) = _pair.reserveBalances();
        address[] memory tokens = _pair.reserveTokens();

        uint eth_usd = getChainLinkPrice(chainlink_);
        uint chainlink_decimals = AggregatorV3Interface(chainlink_).decimals();
        if (chainlink_decimals < PERCISION) {
            eth_usd = eth_usd.mul(10 ** (PERCISION - chainlink_decimals));
        }
        if (tokens[0] == ICHI) {
            uint ichi_reserve = reserve0 * 10**9;
            uint eth_reserve = reserve1;
            price = eth_usd.mul(eth_reserve).div(ichi_reserve);

        } else if (tokens[1] == ICHI) {
            uint ichi_reserve = reserve1 * 10**9;
            uint eth_reserve = reserve0;
            price = eth_usd.mul(eth_reserve).div(ichi_reserve);
        } else {
            price = 0;
        }
    }
    
    function getBaseToken() external view override returns (address token) {
        token = ICHI;
    }

    function decimals() external view override returns (uint256) {
        return PERCISION;
    }

    function getChainLinkPrice(address chainlink_) public view returns (uint256 price) {

        (
            , 
            int256 price_,
            ,
            ,
            
        ) = AggregatorV3Interface(chainlink_).latestRoundData();
        price = uint256(price_);
    }



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

 
pragma solidity ^0.7.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

   
   
   
  function getRoundData(
    uint80 _roundId
  )
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

 
pragma solidity >=0.5.0;

interface IBancorPair {
    function reserveBalances()
    external
    view
    returns (
      uint256 reserveBalance0,
      uint256 reserveBalance1
    );
    function reserveTokens()
    external
    view
    returns (
      address[] memory tokens
    );
}
