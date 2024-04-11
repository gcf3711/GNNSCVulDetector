 

 

 

 

 

 

pragma solidity >=0.7.6 <0.8.0;

 
abstract contract ManagedIdentity {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}


 

pragma solidity >=0.7.6 <0.8.0;

 
interface IPolygonTokenPredicate {
     
    function lockTokens(
        address depositor,
        address depositReceiver,
        address rootToken,
        bytes calldata depositData
    ) external;

     
    function exitTokens(
        address sender,
        address rootToken,
        bytes calldata logRLPList
    ) external;
}


 

 
pragma solidity >=0.7.6 <0.8.0;

library RLPReader {
    uint8 private constant _STRING_SHORT_START = 0x80;
    uint8 private constant _STRING_LONG_START = 0xb8;
    uint8 private constant _LIST_SHORT_START = 0xc0;
    uint8 private constant _LIST_LONG_START = 0xf8;
    uint8 private constant _WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

     
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {
        require(item.length > 0, "RLPReader: INVALID_BYTES_LENGTH");
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

     
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item), "RLP: ITEM_NOT_LIST");

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);
        uint256 listLength = _itemLength(item.memPtr);
        require(listLength == item.len, "RLP: LIST_LENGTH_MISMATCH");

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

     
    function isList(RLPItem memory item) internal pure returns (bool) {
        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < _LIST_SHORT_START) return false;
        return true;
    }

     

     
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
        bytes memory result = new bytes(item.len);

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        require(!isList(item), "RLP: DECODING_LIST_AS_ADDRESS");
         
        require(item.len == 21, "RLP: INVALID_ADDRESS_LEN");

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {
        require(!isList(item), "RLP: DECODING_LIST_AS_UINT");
        require(item.len <= 33, "RLP: INVALID_UINT_LEN");

        uint256 itemLength = _itemLength(item.memPtr);
        require(itemLength == item.len, "RLP: UINT_LEN_MISMATCH");

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset;
        uint256 result;
        uint256 memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

             
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

     
    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {
        uint256 itemLength = _itemLength(item.memPtr);
        require(itemLength == item.len, "RLP: UINT_STRICT_LEN_MISMATCH");
         
        require(item.len == 33, "RLP: INVALID_UINT_STRICT_LEN");

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        uint256 listLength = _itemLength(item.memPtr);
        require(listLength == item.len, "RLP: BYTES_LEN_MISMATCH");
        uint256 offset = _payloadOffset(item.memPtr);

        uint256 len = item.len - offset;  
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }

     

     
    function numItems(RLPItem memory item) private pure returns (uint256) {
         
         

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr);  
            require(currPtr <= endPtr, "RLP: NUM_ITEMS_LEN_MISMATCH");
            count++;
        }

        return count;
    }

     
    function _itemLength(uint256 memPtr) private pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < _STRING_SHORT_START) itemLen = 1;
        else if (byte0 < _STRING_LONG_START) itemLen = byte0 - _STRING_SHORT_START + 1;
        else if (byte0 < _LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7)  
                memPtr := add(memPtr, 1)  

                 
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen)))  
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < _LIST_LONG_START) {
            itemLen = byte0 - _LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen)))  
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

     
    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < _STRING_SHORT_START) return 0;
        else if (byte0 < _STRING_LONG_START || (byte0 >= _LIST_SHORT_START && byte0 < _LIST_LONG_START)) return 1;
        else if (byte0 < _LIST_SHORT_START)
             
            return byte0 - (_STRING_LONG_START - 1) + 1;
        else return byte0 - (_LIST_LONG_START - 1) + 1;
    }

     
    function copy(
        uint256 src,
        uint256 dest,
        uint256 len
    ) private pure {
        if (len == 0) return;

         
        for (; len >= _WORD_SIZE; len -= _WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += _WORD_SIZE;
            dest += _WORD_SIZE;
        }

         
        uint256 mask = 256**(_WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))  
            let destpart := and(mload(dest), mask)  
            mstore(dest, or(destpart, srcpart))
        }
    }
}


 

pragma solidity >=0.7.6 <0.8.0;


 
abstract contract PolygonERC20PredicateBase is IPolygonTokenPredicate {
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    event LockedERC20(address indexed depositor, address indexed depositReceiver, address indexed rootToken, uint256 amount);

     
    bytes32 public constant WITHDRAWN_EVENT_SIG = 0x7084f5476618d8e60b11ef0d7d3f06914655adb8793e28ff7f018d4c76d505d5;

     
    address public rootChainManager;

     
    constructor(address rootChainManager_) {
        rootChainManager = rootChainManager_;
    }

     

    function _requireManagerRole(address account) internal view {
        require(account == rootChainManager, "Predicate: only manager");
    }

    function _verifyWithdrawalLog(bytes memory log) internal pure returns (address withdrawer, uint256 amount) {
        RLPReader.RLPItem[] memory logRLPList = log.toRlpItem().toList();
        RLPReader.RLPItem[] memory logTopicRLPList = logRLPList[1].toList();  

        require(
            bytes32(logTopicRLPList[0].toUint()) == WITHDRAWN_EVENT_SIG,  
            "Predicate: invalid signature"
        );

        bytes memory logData = logRLPList[2].toBytes();
        (withdrawer, amount) = abi.decode(logData, (address, uint256));
    }
}


 

pragma solidity >=0.7.6 <0.8.0;


 
contract PolygonERC20MintBurnPredicate is ManagedIdentity, PolygonERC20PredicateBase {
     
    constructor(address rootChainManager_) PolygonERC20PredicateBase(rootChainManager_) {}

     

     
    function lockTokens(
        address depositor,
        address depositReceiver,
        address rootToken,
        bytes calldata depositData
    ) external override {
        _requireManagerRole(_msgSender());
        uint256 amount = abi.decode(depositData, (uint256));
        emit LockedERC20(depositor, depositReceiver, rootToken, amount);
        require(IERC20BurnableMintable(rootToken).burnFrom(depositor, amount), "Predicate: burn failed");
    }

     
    function exitTokens(
        address,
        address rootToken,
        bytes memory log
    ) public override {
        _requireManagerRole(_msgSender());
        (address withdrawer, uint256 amount) = _verifyWithdrawalLog(log);
        IERC20BurnableMintable(rootToken).mint(withdrawer, amount);
    }
}

interface IERC20BurnableMintable {
    function burnFrom(address from, uint256 value) external returns (bool);

    function mint(address to, uint256 value) external;
}