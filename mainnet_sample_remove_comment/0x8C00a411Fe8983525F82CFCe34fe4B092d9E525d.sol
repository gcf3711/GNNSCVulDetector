 

 

pragma solidity ^0.7.6;




interface ILendingPoolV1 {
    function getReserveData(address _reserve)
        external
        view
        returns (
            uint256 totalLiquidity,
            uint256 availableLiquidity,
            uint256 totalBorrowsStable,
            uint256 totalBorrowsVariable,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 utilizationRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            IERC20 aTokenAddress,
            uint40 lastUpdateTimestamp
        );
}

 

pragma solidity 0.7.6;




interface IWrapper {
    function wrap(IERC20 token) external view returns (IERC20 wrappedToken, uint256 rate);
}

 

pragma solidity 0.7.6;





contract AaveWrapperV1 is IWrapper {
    IERC20 private constant _ETH = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant _EEE = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    ILendingPoolV1 private constant _LENDING_POOL = ILendingPoolV1(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);

    mapping(IERC20 => IERC20) public aTokenToToken;
    mapping(IERC20 => IERC20) public tokenToaToken;

    function addMarkets(IERC20[] memory tokens) external {
        for (uint256 i = 0; i < tokens.length; i++) {
            (,,,,,,,,,,, IERC20 aToken,) = _LENDING_POOL.getReserveData(address(tokens[i]));
            require(aToken != IERC20(0), "Token is not supported");
            aTokenToToken[aToken] = tokens[i];
            tokenToaToken[tokens[i]] = aToken;
        }
    }

    function removeMarkets(IERC20[] memory tokens) external {
        for (uint256 i = 0; i < tokens.length; i++) {
            (,,,,,,,,,,, IERC20 aToken,) = _LENDING_POOL.getReserveData(address(tokens[i]));
            require(aToken == IERC20(0), "Token is still supported");
            delete aTokenToToken[aToken];
            delete tokenToaToken[tokens[i]];
        }
    }

    function wrap(IERC20 token) external view override returns (IERC20 wrappedToken, uint256 rate) {
        token = token == _ETH ? _EEE : token;
        IERC20 underlying = aTokenToToken[token];
        IERC20 aToken = tokenToaToken[token];
        if (underlying != IERC20(0)) {
            return (underlying == _EEE ? _ETH : underlying, 1e18);
        } else if (aToken != IERC20(0)) {
            return (aToken, 1e18);
        } else {
            revert("Unsupported token");
        }
    }
}

 

pragma solidity ^0.7.0;

 
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