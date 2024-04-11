// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// 
pragma solidity ^0.7.0;






/// balances and allowances are stored in at single address for gas efficiency. This contract
/// is used simply for ERC20 compliance.
contract nTokenERC20Proxy is IERC20 {
    
    /// nToken USD Coin
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
        // Total supply is looked up via the token address
        return proxy.nTokenTotalSupply(address(this));
    }

    
    
    
    function balanceOf(address account) external view override returns (uint256) {
        return proxy.nTokenBalanceOf(currencyId, account);
    }

    
    
    
    
    function allowance(address account, address spender) external view override returns (uint256) {
        return proxy.nTokenTransferAllowance(currencyId, account, spender);
    }

    
    
    ///  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
    ///  emit:Approval
    
    
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        bool success = proxy.nTokenTransferApprove(currencyId, msg.sender, spender, amount);
        // Emit approvals here so that they come from the correct contract address
        if (success) emit Approval(msg.sender, spender, amount);
        return success;
    }

    
    
    
    
    
    function transfer(address to, uint256 amount) external override returns (bool) {
        bool success = proxy.nTokenTransfer(currencyId, msg.sender, to, amount);
        // Emit transfer events here so they come from the correct contract
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

        // Emit transfer events here so they come from the correct contract
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

// 
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
