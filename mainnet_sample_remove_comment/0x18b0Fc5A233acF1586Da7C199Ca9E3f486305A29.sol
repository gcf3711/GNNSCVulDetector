 
pragma abicoder v2;


 

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
pragma solidity ^0.7.0;






 
 
contract nTokenERC20Proxy is IERC20 {
    
     
    string public name;

    
    string public symbol;

    
    uint8 public constant decimals = 8;

    
    nTokenERC20 public immutable proxy;

    
    uint16 public immutable currencyId;

    constructor(
        nTokenERC20 proxy_,
        uint16 currencyId_,
        string memory underlyingName_,
        string memory underlyingSymbol_
    ) {
        proxy = proxy_;
        currencyId = currencyId_;
        name = string(abi.encodePacked("nToken ", underlyingName_));
        symbol = string(abi.encodePacked("n", underlyingSymbol_));
    }

    
    function totalSupply() external view override returns (uint256) {
         
        return proxy.nTokenTotalSupply(address(this));
    }

    
    
    
    function balanceOf(address account) external view override returns (uint256) {
        return proxy.nTokenBalanceOf(currencyId, account);
    }

    
    
    
    
    function allowance(address account, address spender) external view override returns (uint256) {
        return proxy.nTokenTransferAllowance(currencyId, account, spender);
    }

    
    
     
     
    
    
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        bool success = proxy.nTokenTransferApprove(currencyId, msg.sender, spender, amount);
         
        if (success) emit Approval(msg.sender, spender, amount);
        return success;
    }

    
    
    
    
    
    function transfer(address to, uint256 amount) external override returns (bool) {
        bool success = proxy.nTokenTransfer(currencyId, msg.sender, to, amount);
         
        if (success) emit Transfer(msg.sender, to, amount);
        return success;
    }

    
    
    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        bool success =
            proxy.nTokenTransferFrom(currencyId, msg.sender, from, to, amount);

         
        if (success) emit Transfer(from, to, amount);
        return success;
    }

    
    function getPresentValueAssetDenominated() external view returns (int256) {
        return proxy.nTokenPresentValueAssetDenominated(currencyId);
    }

    
    function getPresentValueUnderlyingDenominated() external view returns (int256) {
        return proxy.nTokenPresentValueUnderlyingDenominated(currencyId);
    }
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
