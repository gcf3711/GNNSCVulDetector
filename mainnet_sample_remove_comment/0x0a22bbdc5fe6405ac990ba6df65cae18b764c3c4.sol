 
pragma abicoder v2;

 

 
pragma solidity ^0.7.6;


 
 
 

 

interface IPriceChecker {
    function checkPrice(
        uint256 _amountIn,
        address _fromToken,
        address _toToken,
        uint256 _feeAmount,
        uint256 _minOut,
        bytes calldata _data
    ) external view returns (bool);
}

 

 
contract AlwaysAcceptPriceChecker is IPriceChecker {
    function checkPrice(
        uint256,
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bool) {
        return true;
    }
}