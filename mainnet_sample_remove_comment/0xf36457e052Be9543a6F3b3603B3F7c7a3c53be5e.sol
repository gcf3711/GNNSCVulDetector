

 

pragma solidity ^0.5.9;


contract IOwnable {

    
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    
    function transferOwnership(address newOwner)
        public;
}

 

pragma solidity ^0.5.9;






contract Ownable is
    IOwnable
{
    
    
    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _assertSenderIsOwner();
        _;
    }

    
    
    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        if (newOwner == address(0)) {
            LibRichErrors.rrevert(LibOwnableRichErrors.TransferOwnerToZeroError());
        } else {
            owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function _assertSenderIsOwner()
        internal
        view
    {
        if (msg.sender != owner) {
            LibRichErrors.rrevert(LibOwnableRichErrors.OnlyOwnerError(
                msg.sender,
                owner
            ));
        }
    }
}

 

pragma solidity ^0.5.9;




contract IAuthorizable is
    IOwnable
{
     
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

     
    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    
    
    function addAuthorizedAddress(address target)
        external;

    
    
    function removeAuthorizedAddress(address target)
        external;

    
    
    
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external;

    
    
    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory);
}

 

pragma solidity ^0.5.9;





contract MixinAuthorizable is
    Ownable,
    IAuthorizable
{
    
    modifier onlyAuthorized {
        require(
            authorized[msg.sender],
            "SENDER_NOT_AUTHORIZED"
        );
        _;
    }

    mapping (address => bool) public authorized;
    address[] public authorities;

    
    
    function addAuthorizedAddress(address target)
        external
        onlyOwner
    {
        require(
            !authorized[target],
            "TARGET_ALREADY_AUTHORIZED"
        );

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    
    
    function removeAuthorizedAddress(address target)
        external
        onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );

        delete authorized[target];
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    
    
    
    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        onlyOwner
    {
        require(
            authorized[target],
            "TARGET_NOT_AUTHORIZED"
        );
        require(
            index < authorities.length,
            "INDEX_OUT_OF_BOUNDS"
        );
        require(
            authorities[index] == target,
            "AUTHORIZED_ADDRESS_MISMATCH"
        );

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.length -= 1;
        emit AuthorizedAddressRemoved(target, msg.sender);
    }

    
    
    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory)
    {
        return authorities;
    }
}
 

pragma solidity ^0.5.9;




contract ERC20Proxy is
    MixinAuthorizable
{
     
    bytes4 constant internal PROXY_ID = bytes4(keccak256("ERC20Token(address)"));

     
    function ()
        external
    {
        assembly {
             
            let selector := and(calldataload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)

             
             
             
             
             
             
            if eq(selector, 0xa85e59e400000000000000000000000000000000000000000000000000000000) {

                 
                 
                let start := mload(64)
                mstore(start, and(caller, 0xffffffffffffffffffffffffffffffffffffffff))
                mstore(add(start, 32), authorized_slot)

                 
                if iszero(sload(keccak256(start, 64))) {
                     
                    mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                    mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                    mstore(64, 0x0000001553454e4445525f4e4f545f415554484f52495a454400000000000000)
                    mstore(96, 0)
                    revert(0, 100)
                }

                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 

                 
                 
                 
                 
                 
                 
                 

                 
                 
                 
                 
                 
                 
                 
                 
                 
                 

                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                let token := calldataload(add(calldataload(4), 40))

                 
                 
                 
                 
                mstore(0, 0x23b872dd00000000000000000000000000000000000000000000000000000000)

                 
                 
                 
                calldatacopy(4, 36, 96)

                 
                let success := call(
                    gas,             
                    token,           
                    0,               
                    0,               
                    100,             
                    0,               
                    32               
                )

                 
                 
                 
                 
                 
                 
                 
                 
                success := and(success, or(
                    iszero(returndatasize),
                    and(
                        eq(returndatasize, 32),
                        gt(mload(0), 0)
                    )
                ))
                if success {
                    return(0, 0)
                }

                 
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000f5452414e534645525f4641494c454400000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }

             
            revert(0, 0)
        }
    }

    
    
    function getProxyId()
        external
        pure
        returns (bytes4)
    {
        return PROXY_ID;
    }
}

pragma solidity ^0.5.9;


library LibOwnableRichErrors {

     
    bytes4 internal constant ONLY_OWNER_ERROR_SELECTOR =
        0x1de45ad1;

     
    bytes internal constant TRANSFER_OWNER_TO_ZERO_ERROR_BYTES =
        hex"e69edc3e";

     
    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ONLY_OWNER_ERROR_SELECTOR,
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return TRANSFER_OWNER_TO_ZERO_ERROR_BYTES;
    }
}

 

pragma solidity ^0.5.9;


library LibRichErrors {

     
    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

     
    
     
     
    
    
    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }
     

    
    
    function rrevert(bytes memory errorData)
        internal
        pure
    {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}
