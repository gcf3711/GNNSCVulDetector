 


 
pragma solidity ^0.8.0;

contract Nonce {

    uint256 public constant MAX_INCREASE = 100;
    
    uint256 private compound;
    
    constructor(){
        setBoth(128, 0);
    }
    
     
    function nextNonce() external view returns (uint128){
        return getMax() + 1;
    }

      
    function isFree(uint128 nonce) external view returns (bool){
        uint128 max = getMax();
        return isValidHighNonce(max, nonce) || isValidLowNonce(max, getRegister(), nonce);
    }

     
    function flagUsed(uint128 nonce) internal {
        uint256 comp = compound;
        uint128 max = uint128(comp);
        uint128 reg = uint128(comp >> 128);
        if (isValidHighNonce(max, nonce)){
            setBoth(nonce, ((reg << 1) | 0x1) << (nonce - max - 1));
        } else if (isValidLowNonce(max, reg, nonce)){
            setBoth(max, uint128(reg | 0x1 << (max - nonce - 1)));
        } else {
            revert("used");
        }
    }
    
    function getMax() private view returns (uint128) {
        return uint128(compound);
    }
    
    function getRegister() private view returns (uint128) {
        return uint128(compound >> 128);
    }
    
    function setBoth(uint128 max, uint128 reg) private {
        compound = uint256(reg) << 128 | max;
    }

    function isValidHighNonce(uint128 max, uint128 nonce) private pure returns (bool){
        return nonce > max && nonce <= max + MAX_INCREASE;
    }

    function isValidLowNonce(uint128 max, uint128 reg, uint128 nonce) private pure returns (bool){
        uint256 diff = max - nonce;
        return diff > 0 && diff <= 128 && ((0x1 << (diff - 1)) & reg == 0);
    }
    
}

 
 

pragma solidity ^0.8.0;

 
abstract contract Initializable {
     
    bool private _initialized;

     
    modifier initializer() {
        require(!_initialized, "already initialized");
        _;
        _initialized = true;
    }

} 

pragma solidity ^0.8.0;

 
library Clones {
     
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

     
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

     
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

     
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

 

pragma solidity ^0.8.0;




contract MultiSigCloneFactory {

  address immutable public multiSigImplementation;

  event ContractCreated(address indexed contractAddress, string indexed typeName);

  constructor(address _multiSigImplementation) {
    multiSigImplementation = _multiSigImplementation;
  }
  
  function predict(bytes32 salt) external view returns (address) {
    return Clones.predictDeterministicAddress(multiSigImplementation, salt);
  }

  function create(address owner, bytes32 salt) external returns (MultiSigWallet) {
    address payable instance = payable(Clones.cloneDeterministic(multiSigImplementation, salt));
    MultiSigWallet(instance).initialize(owner);
    emit ContractCreated(instance, "MultiSigWallet");
    return MultiSigWallet(instance);
  }
}

 

pragma solidity ^0.8.0;






 
contract MultiSigWallet is Nonce, Initializable {

  mapping (address => uint8) public signers;  

  uint16 public signerCount;
  bytes public contractId;  

  event SignerChange(
    address indexed signer,
    uint8 signaturesNeeded
  );

  event Transacted(
    address indexed toAddress,   
    bytes4 selector,  
    address[] signers  
  );

  event Received(address indexed sender, uint amount);

  function initialize(address owner) external initializer {
     
     
     
     
     
    contractId = toBytes(uint32(uint160(address(this))));
    signerCount = 0;
    _setSigner(owner, 1);  
  }

   
  receive() external payable {
    emit Received(msg.sender, msg.value);
  }

   
  function checkSignatures(uint128 nonce, address to, uint value, bytes calldata data,
    uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external view returns (address[] memory) {
    bytes32 transactionHash = calculateTransactionHash(nonce, contractId, to, value, data);
    return verifySignatures(transactionHash, v, r, s);
  }

   
  function checkExecution(address to, uint value, bytes calldata data) external {
    Address.functionCallWithValue(to, data, value);
    revert("Test passed. Reverting.");
  }

  function execute(uint128 nonce, address to, uint value, bytes calldata data, uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external returns (bytes memory) {
    bytes32 transactionHash = calculateTransactionHash(nonce, contractId, to, value, data);
    address[] memory found = verifySignatures(transactionHash, v, r, s);
    bytes memory returndata = Address.functionCallWithValue(to, data, value);
    flagUsed(nonce);
    emit Transacted(to, extractSelector(data), found);
    return returndata;
  }

  function extractSelector(bytes calldata data) private pure returns (bytes4){
    if (data.length < 4){
      return bytes4(0);
    } else {
      return bytes4(data[0]) | (bytes4(data[1]) >> 8) | (bytes4(data[2]) >> 16) | (bytes4(data[3]) >> 24);
    }
  }

  function toBytes(uint number) internal pure returns (bytes memory){
    uint len = 0;
    uint temp = 1;
    while (number >= temp){
      temp = temp << 8;
      len++;
    }
    temp = number;
    bytes memory data = new bytes(len);
    for (uint i = len; i>0; i--) {
      data[i-1] = bytes1(uint8(temp));
      temp = temp >> 8;
    }
    return data;
  }

   
  function calculateTransactionHash(uint128 sequence, bytes memory id, address to, uint value, bytes calldata data)
    internal view returns (bytes32){
    bytes[] memory all = new bytes[](9);
    all[0] = toBytes(sequence);  
    all[1] = id;  
    all[2] = toBytes(21000);  
    all[3] = abi.encodePacked(to);
    all[4] = toBytes(value);
    all[5] = data;
    all[6] = toBytes(block.chainid);
    all[7] = toBytes(0);
    for (uint i = 0; i<8; i++){
      all[i] = RLPEncode.encodeBytes(all[i]);
    }
    all[8] = all[7];
    return keccak256(RLPEncode.encodeList(all));
  }

  function verifySignatures(bytes32 transactionHash, uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s)
    public view returns (address[] memory) {
    address[] memory found = new address[](r.length);
    require(r.length > 0, "sig missing");
    for (uint i = 0; i < r.length; i++) {
      address signer = ecrecover(transactionHash, v[i], r[i], s[i]);
      uint8 signaturesNeeded = signers[signer];
      require(signaturesNeeded > 0 && signaturesNeeded <= r.length, "cosigner error");
      found[i] = signer;
    }
    requireNoDuplicates(found);
    return found;
  }

  function requireNoDuplicates(address[] memory found) private pure {
    for (uint i = 0; i < found.length; i++) {
      for (uint j = i+1; j < found.length; j++) {
        require(found[i] != found[j], "duplicate signature");
      }
    }
  }

   
  function setSigner(address signer, uint8 signaturesNeeded) external authorized {
    _setSigner(signer, signaturesNeeded);
    require(signerCount > 0, "signer count 0");
  }

  function migrate(address destination) external {
    _migrate(msg.sender, destination);
  }

  function migrate(address source, address destination) external authorized {
    _migrate(source, destination);
  }

  function _migrate(address source, address destination) private {
    require(signers[destination] == 0, "destination not new");  
    _setSigner(destination, signers[source]);
    _setSigner(source, 0);
  }

  function _setSigner(address signer, uint8 signaturesNeeded) private {
    require(!Address.isContract(signer), "signer cannot be a contract");
    require(signer != address(0x0), "0x0 signer");
    uint8 prevValue = signers[signer];
    signers[signer] = signaturesNeeded;
    if (prevValue > 0 && signaturesNeeded == 0){
      signerCount--;
    } else if (prevValue == 0 && signaturesNeeded > 0){
      signerCount++;
    }
    emit SignerChange(signer, signaturesNeeded);
  }

  modifier authorized() {
    require(address(this) == msg.sender || signers[msg.sender] == 1, "not authorized");
    _;
  }

}

 

pragma solidity ^0.8.0;
 
library RLPEncode {
     

     
    function encodeBytes(bytes memory self) internal pure returns (bytes memory) {
        bytes memory encoded;
        if (self.length == 1 && uint8(self[0]) < 128) {
            encoded = self;
        } else {
            encoded = abi.encodePacked(encodeLength(self.length, 128), self);
        }
        return encoded;
    }

     
    function encodeList(bytes[] memory self) internal pure returns (bytes memory) {
        bytes memory list = flatten(self);
        return abi.encodePacked(encodeLength(list.length, 192), list);
    }

     

     
    function encodeLength(uint len, uint offset) private pure returns (bytes memory) {
        bytes memory encoded;
        if (len < 56) {
            encoded = new bytes(1);
            encoded[0] = bytes32(len + offset)[31];
        } else {
            uint lenLen;
            uint i = 1;
            while (len >= i) {
                lenLen++;
                i <<= 8;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = bytes32(lenLen + offset + 55)[31];
            for(i = 1; i <= lenLen; i++) {
                encoded[i] = bytes32((len / (256**(lenLen-i))) % 256)[31];
            }
        }
        return encoded;
    }

     
    function memcpy(uint _dest, uint _src, uint _len) private pure {
        uint dest = _dest;
        uint src = _src;
        uint len = _len;

        for(; len >= 32; len -= 32) {
             
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = type(uint).max >> (len << 3);
         
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

     
    function flatten(bytes[] memory _list) private pure returns (bytes memory) {
        if (_list.length == 0) {
            return new bytes(0);
        }

        uint len;
        uint i;
        for (i = 0; i < _list.length; i++) {
            len += _list[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint flattenedPtr;
         
        assembly { flattenedPtr := add(flattened, 0x20) }

        for(i = 0; i < _list.length; i++) {
            bytes memory item = _list[i];
            
            uint listPtr;
             
            assembly { listPtr := add(item, 0x20)}

            memcpy(flattenedPtr, listPtr, item.length);
            flattenedPtr += item.length;
        }

        return flattened;
    }

}

 
 
 

pragma solidity ^0.8.0;

library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        return account.code.length > 0;
    }

    function functionCallWithValue(address target, bytes memory data, uint256 weiValue) internal returns (bytes memory) {
        require(data.length == 0 || isContract(target), "transfer or contract");
         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else if (returndata.length > 0) {
            assembly{
                revert (add (returndata, 0x20), mload (returndata))
            }
        } else {
           revert("failed");
        }
    }
}
