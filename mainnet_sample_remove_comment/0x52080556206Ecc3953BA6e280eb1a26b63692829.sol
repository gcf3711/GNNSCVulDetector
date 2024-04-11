 
pragma experimental ABIEncoderV2;


 
pragma solidity 0.7.6;


abstract contract IModuleAuth {
   
  function _subDigest(
    bytes32 _digest
  ) internal virtual view returns (bytes32);

   
  function _signatureValidation(
    bytes32 _hash,
    bytes memory _signature
  ) internal virtual view returns (bool);
}

 
pragma solidity 0.7.6;



abstract contract ModuleERC165 {
   
  function supportsInterface(bytes4 _interfaceID) virtual public pure returns (bool) {
    return _interfaceID == this.supportsInterface.selector;
  }
}

 
pragma solidity 0.7.6;





 
contract SignatureValidator {
  using LibBytes for bytes;

   

   
  bytes4 constant internal ERC1271_MAGICVALUE = 0x20c13b0b;

   
  bytes4 constant internal ERC1271_MAGICVALUE_BYTES32 = 0x1626ba7e;

   
  uint256 private constant SIG_TYPE_EIP712 = 1;
  uint256 private constant SIG_TYPE_ETH_SIGN = 2;
  uint256 private constant SIG_TYPE_WALLET_BYTES32 = 3;

   

  
  function recoverSigner(
    bytes32 _hash,
    bytes memory _signature
  ) internal pure returns (address signer) {
    uint256 signatureType = uint8(_signature[_signature.length - 1]);

     
    uint8 v = uint8(_signature[64]);
    bytes32 r = _signature.readBytes32(0);
    bytes32 s = _signature.readBytes32(32);

     
     
     
     
     
     
     
     
     
     
     
     

    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      revert("SignatureValidator#recoverSigner: invalid signature 's' value");
    }

    if (v != 27 && v != 28) {
      revert("SignatureValidator#recoverSigner: invalid signature 'v' value");
    }

     
    if (signatureType == SIG_TYPE_EIP712) {
      signer = ecrecover(_hash, v, r, s);

     
    } else if (signatureType == SIG_TYPE_ETH_SIGN) {
      signer = ecrecover(
        keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)),
        v,
        r,
        s
      );

    } else {
       
       
       
       
       
      revert("SignatureValidator#recoverSigner: UNSUPPORTED_SIGNATURE_TYPE");
    }

     
    require(
      signer != address(0x0),
      "SignatureValidator#recoverSigner: INVALID_SIGNER"
    );

    return signer;
  }

  
  function isValidSignature(
    bytes32 _hash,
    address _signer,
    bytes memory _signature
  ) internal view returns (bool valid) {
    uint256 signatureType = uint8(_signature[_signature.length - 1]);

    if (signatureType == SIG_TYPE_EIP712 || signatureType == SIG_TYPE_ETH_SIGN) {
       
      valid = recoverSigner(_hash, _signature) == _signer;

    } else if (signatureType == SIG_TYPE_WALLET_BYTES32) {
       
      uint256 prevSize; assembly { prevSize := mload(_signature) mstore(_signature, sub(prevSize, 1)) }
      valid = ERC1271_MAGICVALUE_BYTES32 == IERC1271Wallet(_signer).isValidSignature(_hash, _signature);
      assembly { mstore(_signature, prevSize) }

    } else {
       
       
       
       
       
      revert("SignatureValidator#isValidSignature: UNSUPPORTED_SIGNATURE_TYPE");
    }
  }
}

 
pragma solidity 0.7.6;


interface IERC1271Wallet {

   
  function isValidSignature(
    bytes calldata _data,
    bytes calldata _signature)
    external
    view
    returns (bytes4 magicValue);

   
  function isValidSignature(
    bytes32 _hash,
    bytes calldata _signature)
    external
    view
    returns (bytes4 magicValue);
}

 
pragma solidity 0.7.6;

 
contract Implementation {
   
  function _setImplementation(address _imp) internal {
    assembly {
      sstore(address(), _imp)
    }
  }

   
  function _getImplementation() internal view returns (address _imp) {
    assembly {
      _imp := sload(address())
    }
  }
}

 
pragma solidity 0.7.6;


interface IERC1155Receiver {
  function onERC1155Received(address, address, uint256, uint256, bytes calldata) external returns (bytes4);
  function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external returns (bytes4);
}

 
pragma solidity 0.7.6;


interface IERC721Receiver {
  function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4);
}

 
pragma solidity 0.7.6;










abstract contract ModuleAuth is IModuleAuth, ModuleERC165, SignatureValidator, IERC1271Wallet {
  using LibBytes for bytes;

  uint256 private constant FLAG_SIGNATURE = 0;
  uint256 private constant FLAG_ADDRESS = 1;
  uint256 private constant FLAG_DYNAMIC_SIGNATURE = 2;

  bytes4 private constant SELECTOR_ERC1271_BYTES_BYTES = 0x20c13b0b;
  bytes4 private constant SELECTOR_ERC1271_BYTES32_BYTES = 0x1626ba7e;

   
  function _signatureValidation(
    bytes32 _hash,
    bytes memory _signature
  )
    internal override view returns (bool)
  {
    (
      uint16 threshold,   
      uint256 rindex      
    ) = _signature.readFirstUint16();

     
    bytes32 imageHash = bytes32(uint256(threshold));

     
    uint256 totalWeight;

     
    while (rindex < _signature.length) {
       
      uint256 flag; uint256 addrWeight; address addr;
      (flag, addrWeight, rindex) = _signature.readUint8Uint8(rindex);

      if (flag == FLAG_ADDRESS) {
         
        (addr, rindex) = _signature.readAddress(rindex);
      } else if (flag == FLAG_SIGNATURE) {
         
        bytes memory signature;
        (signature, rindex) = _signature.readBytes66(rindex);
        addr = recoverSigner(_hash, signature);

         
        totalWeight += addrWeight;
      } else if (flag == FLAG_DYNAMIC_SIGNATURE) {
         
        (addr, rindex) = _signature.readAddress(rindex);

         
        uint256 size;
        (size, rindex) = _signature.readUint16(rindex);

         
        bytes memory signature;
        (signature, rindex) = _signature.readBytes(rindex, size);
        require(isValidSignature(_hash, addr, signature), "ModuleAuth#_signatureValidation: INVALID_SIGNATURE");

         
        totalWeight += addrWeight;
      } else {
        revert("ModuleAuth#_signatureValidation INVALID_FLAG");
      }

       
      imageHash = keccak256(abi.encode(imageHash, addrWeight, addr));
    }

    return totalWeight >= threshold && _isValidImage(imageHash);
  }

   
  function _isValidImage(bytes32 _imageHash) internal virtual view returns (bool);

   
  function _subDigest(bytes32 _digest) internal override view returns (bytes32) {
    uint256 chainId; assembly { chainId := chainid() }
    return keccak256(
      abi.encodePacked(
        "\x19\x01",
        chainId,
        address(this),
        _digest
      )
    );
  }

   
  function isValidSignature(
    bytes calldata _data,
    bytes calldata _signatures
  ) external override view returns (bytes4) {
     
    if (_signatureValidation(_subDigest(keccak256(_data)), _signatures)) {
      return SELECTOR_ERC1271_BYTES_BYTES;
    }
  }

   
  function isValidSignature(
    bytes32 _hash,
    bytes calldata _signatures
  ) external override view returns (bytes4) {
     
    if (_signatureValidation(_subDigest(_hash), _signatures)) {
      return SELECTOR_ERC1271_BYTES32_BYTES;
    }
  }

   
  function supportsInterface(bytes4 _interfaceID) public override virtual pure returns (bool) {
    if (
      _interfaceID == type(IModuleAuth).interfaceId ||
      _interfaceID == type(IERC1271Wallet).interfaceId
    ) {
      return true;
    }

    return super.supportsInterface(_interfaceID);
  }
}

 
pragma solidity 0.7.6;


interface IModuleHooks {
   
  function readHook(bytes4 _signature) external view returns (address);

   
  function addHook(bytes4 _signature, address _implementation) external;

   
  function removeHook(bytes4 _signature) external;
}

 
pragma solidity 0.7.6;


contract ModuleSelfAuth {
  modifier onlySelf() {
    require(msg.sender == address(this), "ModuleSelfAuth#onlySelf: NOT_AUTHORIZED");
    _;
  }
}

 
pragma solidity 0.7.6;



interface IModuleCalls {
   
  event NonceChange(uint256 _space, uint256 _newNonce);
  event TxFailed(bytes32 _tx, bytes _reason);
  event TxExecuted(bytes32 _tx) anonymous;

   
  struct Transaction {
    bool delegateCall;    
    bool revertOnError;   
    uint256 gasLimit;     
    address target;       
    uint256 value;        
    bytes data;           
  }

   
  function nonce() external view returns (uint256);

   
  function readNonce(uint256 _space) external view returns (uint256);

   
  function execute(
    Transaction[] calldata _txs,
    uint256 _nonce,
    bytes calldata _signature
  ) external;

   
  function selfExecute(
    Transaction[] calldata _txs
  ) external;
}

 
pragma solidity 0.7.6;


interface IModuleUpdate {
   
  function updateImplementation(address _implementation) external;
}

 
pragma solidity 0.7.6;


interface IModuleCreator {
   
  function createContract(bytes calldata _code) external payable returns (address addr);
}
 
pragma solidity 0.7.6;




 
abstract contract ModuleAuthFixed is ModuleAuth {
  bytes32 public immutable INIT_CODE_HASH;
  address public immutable FACTORY;

  constructor(address _factory) {
     
    bytes32 initCodeHash = keccak256(abi.encodePacked(Wallet.creationCode, uint256(address(this))));

    INIT_CODE_HASH = initCodeHash;
    FACTORY = _factory;
  }

   
  function _isValidImage(bytes32 _imageHash) internal override view returns (bool) {
    return address(
      uint256(
        keccak256(
          abi.encodePacked(
            byte(0xff),
            FACTORY,
            _imageHash,
            INIT_CODE_HASH
          )
        )
      )
    ) == address(this);
  }
}

 
pragma solidity 0.7.6;












contract ModuleHooks is IERC1155Receiver, IERC721Receiver, IModuleHooks, ModuleERC165, ModuleSelfAuth {
   
  bytes32 private constant HOOKS_KEY = bytes32(0xbe27a319efc8734e89e26ba4bc95f5c788584163b959f03fa04e2d7ab4b9a120);

   
  function readHook(bytes4 _signature) external override view returns (address) {
    return _readHook(_signature);
  }

   
  function addHook(bytes4 _signature, address _implementation) external override onlySelf {
    require(_readHook(_signature) == address(0), "ModuleHooks#addHook: HOOK_ALREADY_REGISTERED");
    _writeHook(_signature, _implementation);
  }

   
  function removeHook(bytes4 _signature) external override onlySelf {
    require(_readHook(_signature) != address(0), "ModuleHooks#removeHook: HOOK_NOT_REGISTERED");
    _writeHook(_signature, address(0));
  }

   
  function _readHook(bytes4 _signature) private view returns (address) {
    return address(uint256(ModuleStorage.readBytes32Map(HOOKS_KEY, _signature)));
  }

   
  function _writeHook(bytes4 _signature, address _implementation) private {
    ModuleStorage.writeBytes32Map(HOOKS_KEY, _signature, bytes32(uint256(_implementation)));
  }

   
  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes calldata
  ) external override returns (bytes4) {
    return ModuleHooks.onERC1155Received.selector;
  }

   
  function onERC1155BatchReceived(
    address,
    address,
    uint256[] calldata,
    uint256[] calldata,
    bytes calldata
  ) external override returns (bytes4) {
    return ModuleHooks.onERC1155BatchReceived.selector;
  }

   
  function onERC721Received(address, address, uint256, bytes calldata) external override returns (bytes4) {
    return ModuleHooks.onERC721Received.selector;
  }

   
  fallback() external payable {
    address target = _readHook(msg.sig);
    if (target != address(0)) {
      (bool success, bytes memory result) = target.delegatecall(msg.data);
      assembly {
        if iszero(success)  {
          revert(add(result, 0x20), mload(result))
        }

        return(add(result, 0x20), mload(result))
      }
    }
  }

   
  receive() external payable { }

   
  function supportsInterface(bytes4 _interfaceID) public override virtual pure returns (bool) {
    if (
      _interfaceID == type(IModuleHooks).interfaceId ||
      _interfaceID == type(IERC1155Receiver).interfaceId ||
      _interfaceID == type(IERC721Receiver).interfaceId ||
      _interfaceID == type(IERC223Receiver).interfaceId
    ) {
      return true;
    }

    return super.supportsInterface(_interfaceID);
  }
}

 
pragma solidity 0.7.6;










abstract contract ModuleCalls is IModuleCalls, IModuleAuth, ModuleERC165, ModuleSelfAuth {
   
  bytes32 private constant NONCE_KEY = bytes32(0x8d0bf1fd623d628c741362c1289948e57b3e2905218c676d3e69abee36d6ae2e);

  uint256 private constant NONCE_BITS = 96;
  bytes32 private constant NONCE_MASK = bytes32((1 << NONCE_BITS) - 1);

   
  function nonce() external override virtual view returns (uint256) {
    return readNonce(0);
  }

   
  function readNonce(uint256 _space) public override virtual view returns (uint256) {
    return uint256(ModuleStorage.readBytes32Map(NONCE_KEY, bytes32(_space)));
  }

   
  function _writeNonce(uint256 _space, uint256 _nonce) private {
    ModuleStorage.writeBytes32Map(NONCE_KEY, bytes32(_space), bytes32(_nonce));
  }

   
  function execute(
    Transaction[] memory _txs,
    uint256 _nonce,
    bytes memory _signature
  ) public override virtual {
     
    _validateNonce(_nonce);

     
    bytes32 txHash = _subDigest(keccak256(abi.encode(_nonce, _txs)));

     
    require(
      _signatureValidation(txHash, _signature),
      "ModuleCalls#execute: INVALID_SIGNATURE"
    );

     
    _execute(txHash, _txs);
  }

   
  function selfExecute(
    Transaction[] memory _txs
  ) public override virtual onlySelf {
     
    bytes32 txHash = _subDigest(keccak256(abi.encode('self:', _txs)));

     
    _execute(txHash, _txs);
  }

   
  function _execute(
    bytes32 _txHash,
    Transaction[] memory _txs
  ) private {
     
    for (uint256 i = 0; i < _txs.length; i++) {
      Transaction memory transaction = _txs[i];

      bool success;
      bytes memory result;

      require(gasleft() >= transaction.gasLimit, "ModuleCalls#_execute: NOT_ENOUGH_GAS");

      if (transaction.delegateCall) {
        (success, result) = transaction.target.delegatecall{
          gas: transaction.gasLimit == 0 ? gasleft() : transaction.gasLimit
        }(transaction.data);
      } else {
        (success, result) = transaction.target.call{
          value: transaction.value,
          gas: transaction.gasLimit == 0 ? gasleft() : transaction.gasLimit
        }(transaction.data);
      }

      if (success) {
        emit TxExecuted(_txHash);
      } else {
        _revertBytes(transaction, _txHash, result);
      }
    }
  }

   
  function _validateNonce(uint256 _rawNonce) private {
     
    (uint256 space, uint256 providedNonce) = _decodeNonce(_rawNonce);
    uint256 currentNonce = readNonce(space);

     
    require(
      providedNonce == currentNonce,
      "MainModule#_auth: INVALID_NONCE"
    );

     
    uint256 newNonce = providedNonce + 1;
    _writeNonce(space, newNonce);
    emit NonceChange(space, newNonce);
  }

   
  function _revertBytes(
    Transaction memory _tx,
    bytes32 _txHash,
    bytes memory _reason
  ) internal {
    if (_tx.revertOnError) {
      assembly { revert(add(_reason, 0x20), mload(_reason)) }
    } else {
      emit TxFailed(_txHash, _reason);
    }
  }

   
  function _decodeNonce(uint256 _rawNonce) private pure returns (uint256 _space, uint256 _nonce) {
    _nonce = uint256(bytes32(_rawNonce) & NONCE_MASK);
    _space = _rawNonce >> NONCE_BITS;
  }

   
  function supportsInterface(bytes4 _interfaceID) public override virtual pure returns (bool) {
    if (_interfaceID == type(IModuleCalls).interfaceId) {
      return true;
    }

    return super.supportsInterface(_interfaceID);
  }
}

 
pragma solidity 0.7.6;










contract ModuleUpdate is IModuleUpdate, ModuleERC165, ModuleSelfAuth, Implementation {
  using LibAddress for address;

  event ImplementationUpdated(address newImplementation);

   
  function updateImplementation(address _implementation) external override onlySelf {
    require(_implementation.isContract(), "ModuleUpdate#updateImplementation: INVALID_IMPLEMENTATION");
    _setImplementation(_implementation);
    emit ImplementationUpdated(_implementation);
  }

   
  function supportsInterface(bytes4 _interfaceID) public override virtual pure returns (bool) {
    if (_interfaceID == type(IModuleUpdate).interfaceId) {
      return true;
    }

    return super.supportsInterface(_interfaceID);
  }
}

 
pragma solidity 0.7.6;







contract ModuleCreator is IModuleCreator, ModuleERC165, ModuleSelfAuth {
  event CreatedContract(address _contract);

   
  function createContract(bytes memory _code) public override payable onlySelf returns (address addr) {
    assembly { addr := create(callvalue(), add(_code, 32), mload(_code)) }
    emit CreatedContract(addr);
  }

   
  function supportsInterface(bytes4 _interfaceID) public override virtual pure returns (bool) {
    if (_interfaceID == type(IModuleCreator).interfaceId) {
      return true;
    }

    return super.supportsInterface(_interfaceID);
  }
}
 
pragma solidity 0.7.6;

















 
contract MainModule is
  ModuleAuthFixed,
  ModuleCalls,
  ModuleUpdate,
  ModuleHooks,
  ModuleCreator
{
  constructor(
    address _factory
  ) public ModuleAuthFixed(
    _factory
  ) { }

   
  function supportsInterface(
    bytes4 _interfaceID
  ) public override(
    ModuleAuth,
    ModuleCalls,
    ModuleUpdate,
    ModuleHooks,
    ModuleCreator
  ) pure returns (bool) {
    return super.supportsInterface(_interfaceID);
  }
}

 
pragma solidity 0.7.6;

library LibBytes {
  using LibBytes for bytes;

   

   
  function readFirstUint16(
    bytes memory data
  ) internal pure returns (
    uint16 a,
    uint256 newIndex
  ) {
    assembly {
      let word := mload(add(32, data))
      a := shr(240, word)
      newIndex := 2
    }
    require(2 <= data.length, "LibBytes#readFirstUint16: OUT_OF_BOUNDS");
  }

   
  function readUint8Uint8(
    bytes memory data,
    uint256 index
  ) internal pure returns (
    uint8 a,
    uint8 b,
    uint256 newIndex
  ) {
    assembly {
      let word := mload(add(index, add(32, data)))
      a := shr(248, word)
      b := and(shr(240, word), 0xff)
      newIndex := add(index, 2)
    }
    require(newIndex <= data.length, "LibBytes#readUint8Uint8: OUT_OF_BOUNDS");
  }

   
  function readAddress(
    bytes memory data,
    uint256 index
  ) internal pure returns (
    address a,
    uint256 newIndex
  ) {
    assembly {
      let word := mload(add(index, add(32, data)))
      a := and(shr(96, word), 0xffffffffffffffffffffffffffffffffffffffff)
      newIndex := add(index, 20)
    }
    require(newIndex <= data.length, "LibBytes#readAddress: OUT_OF_BOUNDS");
  }

   
  function readBytes66(
    bytes memory data,
    uint256 index
  ) internal pure returns (
    bytes memory a,
    uint256 newIndex
  ) {
    a = new bytes(66);
    assembly {
      let offset := add(32, add(data, index))
      mstore(add(a, 32), mload(offset))
      mstore(add(a, 64), mload(add(offset, 32)))
      mstore(add(a, 66), mload(add(offset, 34)))
      newIndex := add(index, 66)
    }
    require(newIndex <= data.length, "LibBytes#readBytes66: OUT_OF_BOUNDS");
  }

   
  function readBytes32(
    bytes memory b,
    uint256 index
  )
    internal
    pure
    returns (bytes32 result)
  {
    require(
      b.length >= index + 32,
      "LibBytes#readBytes32: GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
    );

     
    uint256 pos = index + 32;

     
    assembly {
      result := mload(add(b, pos))
    }
    return result;
  }

   
  function readUint16(
    bytes memory data,
    uint256 index
  ) internal pure returns (uint16 a, uint256 newIndex) {
    assembly {
      let word := mload(add(index, add(32, data)))
      a := and(shr(240, word), 0xffff)
      newIndex := add(index, 2)
    }
    require(newIndex <= data.length, "LibBytes#readUint16: OUT_OF_BOUNDS");
  }

   
  function readBytes(
    bytes memory data,
    uint256 index,
    uint256 size
  ) internal pure returns (bytes memory a, uint256 newIndex) {
    a = new bytes(size);

    assembly {
      let offset := add(32, add(data, index))

      let i := 0 let n := 32
       
      for { } lt(n, size) { i := n n := add(n, 32) } {
        mstore(add(a, n), mload(add(offset, i)))
      }

       
      let suffix := add(a, add(32, size))
      let suffixWord := mload(suffix)

       
      mstore(add(a, n), mload(add(offset, i)))

       
      mstore(suffix, suffixWord)

      newIndex := add(index, size)
    }

    require(newIndex <= data.length, "LibBytes#readBytes: OUT_OF_BOUNDS");
  }
}

 
pragma solidity 0.7.6;

 
library Wallet {
  bytes internal constant creationCode = hex"603a600e3d39601a805130553df3363d3d373d3d3d363d30545af43d82803e903d91601857fd5bf3";
}

 
pragma solidity 0.7.6;


library ModuleStorage {
  function writeBytes32(bytes32 _key, bytes32 _val) internal {
    assembly { sstore(_key, _val) }
  }

  function readBytes32(bytes32 _key) internal view returns (bytes32 val) {
    assembly { val := sload(_key) }
  }

  function writeBytes32Map(bytes32 _key, bytes32 _subKey, bytes32 _val) internal {
    bytes32 key = keccak256(abi.encode(_key, _subKey));
    assembly { sstore(key, _val) }
  }

  function readBytes32Map(bytes32 _key, bytes32 _subKey) internal view returns (bytes32 val) {
    bytes32 key = keccak256(abi.encode(_key, _subKey));
    assembly { val := sload(key) }
  }
}

 
pragma solidity 0.7.6;


interface IERC223Receiver {
  function tokenFallback(address, uint256, bytes calldata) external;
}

 
pragma solidity 0.7.6;


library LibAddress {
   
  function isContract(address account) internal view returns (bool) {
    uint256 csize;
     
    assembly { csize := extcodesize(account) }
    return csize != 0;
  }
}
