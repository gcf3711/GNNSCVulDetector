 

 
 
pragma solidity >=0.5.15;

contract Auth {
    mapping (address => uint256) public wards;
    
    event Rely(address indexed usr);
    event Deny(address indexed usr);

    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }
    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }

    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

}

 
pragma solidity >=0.7.6;



interface TrancheLike {
    function supplyOrder(address usr, uint256 currencyAmount) external;
    function redeemOrder(address usr, uint256 tokenAmount) external;
    function disburse(address usr)
        external
        returns (
            uint256 payoutCurrencyAmount,
            uint256 payoutTokenAmount,
            uint256 remainingSupplyCurrency,
            uint256 remainingRedeemToken
        );
    function disburse(address usr, uint256 endEpoch)
        external
        returns (
            uint256 payoutCurrencyAmount,
            uint256 payoutTokenAmount,
            uint256 remainingSupplyCurrency,
            uint256 remainingRedeemToken
        );
    function currency() external view returns (address);
}

interface RestrictedTokenLike {
    function hasMember(address) external view returns (bool);
}

interface EIP2612PermitLike {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
}

interface DaiPermitLike {
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}


contract Operator is Auth {
    TrancheLike public tranche;
    RestrictedTokenLike public token;

     
    event SupplyOrder(uint256 indexed amount);
    event RedeemOrder(uint256 indexed amount);
    event Depend(bytes32 indexed contractName, address addr);

    constructor(address tranche_) {
        tranche = TrancheLike(tranche_);
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    
    
    
    function depend(bytes32 contractName, address addr) public auth {
        if (contractName == "tranche") tranche = TrancheLike(addr);
        else if (contractName == "token") token = RestrictedTokenLike(addr);
        else revert();
        emit Depend(contractName, addr);
    }

    
    
    function supplyOrder(uint256 amount) public {
        require((token.hasMember(msg.sender) == true), "user-not-allowed-to-hold-token");
        tranche.supplyOrder(msg.sender, amount);
        emit SupplyOrder(amount);
    }

    
    
    function redeemOrder(uint256 amount) public {
        require((token.hasMember(msg.sender) == true), "user-not-allowed-to-hold-token");
        tranche.redeemOrder(msg.sender, amount);
        emit RedeemOrder(amount);
    }

    
    
    
    
    
    function disburse()
        external
        returns (
            uint256 payoutCurrencyAmount,
            uint256 payoutTokenAmount,
            uint256 remainingSupplyCurrency,
            uint256 remainingRedeemToken
        )
    {
        require((token.hasMember(msg.sender) == true), "user-not-allowed-to-hold-token");
        return tranche.disburse(msg.sender);
    }

    
    
     
    
    
    
    
    function disburse(uint256 endEpoch)
        external
        returns (
            uint256 payoutCurrencyAmount,
            uint256 payoutTokenAmount,
            uint256 remainingSupplyCurrency,
            uint256 remainingRedeemToken
        )
    {
        require((token.hasMember(msg.sender) == true), "user-not-allowed-to-hold-token");
        return tranche.disburse(msg.sender, endEpoch);
    }

    
    
    
    
    
    
    
    function supplyOrderWithDaiPermit(uint256 amount, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)
        public
    {
        DaiPermitLike(tranche.currency()).permit(msg.sender, address(tranche), nonce, expiry, true, v, r, s);
        supplyOrder(amount);
    }
    
    
    
    
    
    

    function supplyOrderWithPermit(uint256 amount, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        public
    {
        EIP2612PermitLike(tranche.currency()).permit(msg.sender, address(tranche), value, deadline, v, r, s);
        supplyOrder(amount);
    }

    
    
    
    
    
    
    function redeemOrderWithPermit(uint256 amount, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        public
    {
        EIP2612PermitLike(address(token)).permit(msg.sender, address(tranche), value, deadline, v, r, s);
        redeemOrder(amount);
    }
}