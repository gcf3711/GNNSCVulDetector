 
pragma experimental ABIEncoderV2;


 
pragma solidity >0.5.0 <0.8.0;


 


 
interface iOVM_StateManager {

     

    enum ItemState {
        ITEM_UNTOUCHED,
        ITEM_LOADED,
        ITEM_CHANGED,
        ITEM_COMMITTED
    }

     

    function isAuthenticated(address _address) external view returns (bool);

     

    function owner() external view returns (address _owner);
    function ovmExecutionManager() external view returns (address _ovmExecutionManager);
    function setExecutionManager(address _ovmExecutionManager) external;


     

    function putAccount(address _address, Lib_OVMCodec.Account memory _account) external;
    function putEmptyAccount(address _address) external;
    function getAccount(address _address) external view
        returns (Lib_OVMCodec.Account memory _account);
    function hasAccount(address _address) external view returns (bool _exists);
    function hasEmptyAccount(address _address) external view returns (bool _exists);
    function setAccountNonce(address _address, uint256 _nonce) external;
    function getAccountNonce(address _address) external view returns (uint256 _nonce);
    function getAccountEthAddress(address _address) external view returns (address _ethAddress);
    function getAccountStorageRoot(address _address) external view returns (bytes32 _storageRoot);
    function initPendingAccount(address _address) external;
    function commitPendingAccount(address _address, address _ethAddress, bytes32 _codeHash)
        external;
    function testAndSetAccountLoaded(address _address) external
        returns (bool _wasAccountAlreadyLoaded);
    function testAndSetAccountChanged(address _address) external
        returns (bool _wasAccountAlreadyChanged);
    function commitAccount(address _address) external returns (bool _wasAccountCommitted);
    function incrementTotalUncommittedAccounts() external;
    function getTotalUncommittedAccounts() external view returns (uint256 _total);
    function wasAccountChanged(address _address) external view returns (bool);
    function wasAccountCommitted(address _address) external view returns (bool);


     

    function putContractStorage(address _contract, bytes32 _key, bytes32 _value) external;
    function getContractStorage(address _contract, bytes32 _key) external view
        returns (bytes32 _value);
    function hasContractStorage(address _contract, bytes32 _key) external view
        returns (bool _exists);
    function testAndSetContractStorageLoaded(address _contract, bytes32 _key) external
        returns (bool _wasContractStorageAlreadyLoaded);
    function testAndSetContractStorageChanged(address _contract, bytes32 _key) external
        returns (bool _wasContractStorageAlreadyChanged);
    function commitContractStorage(address _contract, bytes32 _key) external
        returns (bool _wasContractStorageCommitted);
    function incrementTotalUncommittedContractStorage() external;
    function getTotalUncommittedContractStorage() external view returns (uint256 _total);
    function wasContractStorageChanged(address _contract, bytes32 _key) external view
        returns (bool);
    function wasContractStorageCommitted(address _contract, bytes32 _key) external view
        returns (bool);
}

 
pragma solidity >0.5.0 <0.8.0;

 


 
interface iOVM_StateManagerFactory {

     

    function create(
        address _owner
    )
        external
        returns (
            iOVM_StateManager _ovmStateManager
        );
}
 
pragma solidity >0.5.0 <0.8.0;

 



 


 
contract OVM_StateManagerFactory is iOVM_StateManagerFactory {

     

     
    function create(
        address _owner
    )
        override
        public
        returns (
            iOVM_StateManager
        )
    {
        return new OVM_StateManager(_owner);
    }
}

 
pragma solidity >0.5.0 <0.8.0;


 


 


 
contract OVM_StateManager is iOVM_StateManager {

     

    bytes32 constant internal EMPTY_ACCOUNT_STORAGE_ROOT =
        0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421;
    bytes32 constant internal EMPTY_ACCOUNT_CODE_HASH =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    bytes32 constant internal STORAGE_XOR_VALUE =
        0xFEEDFACECAFEBEEFFEEDFACECAFEBEEFFEEDFACECAFEBEEFFEEDFACECAFEBEEF;

     

    address override public owner;
    address override public ovmExecutionManager;
    mapping (address => Lib_OVMCodec.Account) internal accounts;
    mapping (address => mapping (bytes32 => bytes32)) internal contractStorage;
    mapping (address => mapping (bytes32 => bool)) internal verifiedContractStorage;
    mapping (bytes32 => ItemState) internal itemStates;
    uint256 internal totalUncommittedAccounts;
    uint256 internal totalUncommittedContractStorage;

     

     
    constructor(
        address _owner
    )
    {
        owner = _owner;
    }

     

     
    modifier authenticated() {
         
        require(
            msg.sender == owner || msg.sender == ovmExecutionManager,
            "Function can only be called by authenticated addresses"
        );
        _;
    }

     

     
    function isAuthenticated(
        address _address
    )
        override
        public
        view
        returns (
            bool
        )
    {
        return (_address == owner || _address == ovmExecutionManager);
    }

     
    function setExecutionManager(
        address _ovmExecutionManager
    )
        override
        public
        authenticated
    {
        ovmExecutionManager = _ovmExecutionManager;
    }

     
    function putAccount(
        address _address,
        Lib_OVMCodec.Account memory _account
    )
        override
        public
        authenticated
    {
        accounts[_address] = _account;
    }

     
    function putEmptyAccount(
        address _address
    )
        override
        public
        authenticated
    {
        Lib_OVMCodec.Account storage account = accounts[_address];
        account.storageRoot = EMPTY_ACCOUNT_STORAGE_ROOT;
        account.codeHash = EMPTY_ACCOUNT_CODE_HASH;
    }

     
    function getAccount(
        address _address
    )
        override
        public
        view
        returns (
            Lib_OVMCodec.Account memory
        )
    {
        return accounts[_address];
    }

     
    function hasAccount(
        address _address
    )
        override
        public
        view
        returns (
            bool
        )
    {
        return accounts[_address].codeHash != bytes32(0);
    }

     
    function hasEmptyAccount(
        address _address
    )
        override
        public
        view
        returns (
            bool
        )
    {
        return (
            accounts[_address].codeHash == EMPTY_ACCOUNT_CODE_HASH
            && accounts[_address].nonce == 0
        );
    }

     
    function setAccountNonce(
        address _address,
        uint256 _nonce
    )
        override
        public
        authenticated
    {
        accounts[_address].nonce = _nonce;
    }

     
    function getAccountNonce(
        address _address
    )
        override
        public
        view
        returns (
            uint256
        )
    {
        return accounts[_address].nonce;
    }

     
    function getAccountEthAddress(
        address _address
    )
        override
        public
        view
        returns (
            address
        )
    {
        return accounts[_address].ethAddress;
    }

     
    function getAccountStorageRoot(
        address _address
    )
        override
        public
        view
        returns (
            bytes32
        )
    {
        return accounts[_address].storageRoot;
    }

     
    function initPendingAccount(
        address _address
    )
        override
        public
        authenticated
    {
        Lib_OVMCodec.Account storage account = accounts[_address];
        account.nonce = 1;
        account.storageRoot = EMPTY_ACCOUNT_STORAGE_ROOT;
        account.codeHash = EMPTY_ACCOUNT_CODE_HASH;
        account.isFresh = true;
    }

     
    function commitPendingAccount(
        address _address,
        address _ethAddress,
        bytes32 _codeHash
    )
        override
        public
        authenticated
    {
        Lib_OVMCodec.Account storage account = accounts[_address];
        account.ethAddress = _ethAddress;
        account.codeHash = _codeHash;
    }

     
    function testAndSetAccountLoaded(
        address _address
    )
        override
        public
        authenticated
        returns (
            bool
        )
    {
        return _testAndSetItemState(
            _getItemHash(_address),
            ItemState.ITEM_LOADED
        );
    }

     
    function testAndSetAccountChanged(
        address _address
    )
        override
        public
        authenticated
        returns (
            bool
        )
    {
        return _testAndSetItemState(
            _getItemHash(_address),
            ItemState.ITEM_CHANGED
        );
    }

     
    function commitAccount(
        address _address
    )
        override
        public
        authenticated
        returns (
            bool
        )
    {
        bytes32 item = _getItemHash(_address);
        if (itemStates[item] != ItemState.ITEM_CHANGED) {
            return false;
        }

        itemStates[item] = ItemState.ITEM_COMMITTED;
        totalUncommittedAccounts -= 1;

        return true;
    }

     
    function incrementTotalUncommittedAccounts()
        override
        public
        authenticated
    {
        totalUncommittedAccounts += 1;
    }

     
    function getTotalUncommittedAccounts()
        override
        public
        view
        returns (
            uint256
        )
    {
        return totalUncommittedAccounts;
    }

     
    function wasAccountChanged(
        address _address
    )
        override
        public
        view
        returns (
            bool
        )
    {
        bytes32 item = _getItemHash(_address);
        return itemStates[item] >= ItemState.ITEM_CHANGED;
    }

     
    function wasAccountCommitted(
        address _address
    )
        override
        public
        view
        returns (
            bool
        )
    {
        bytes32 item = _getItemHash(_address);
        return itemStates[item] >= ItemState.ITEM_COMMITTED;
    }


     

     
    function putContractStorage(
        address _contract,
        bytes32 _key,
        bytes32 _value
    )
        override
        public
        authenticated
    {
         
         
         
        contractStorage[_contract][_key] = _value ^ STORAGE_XOR_VALUE;

         
         
         
         
         
        if (verifiedContractStorage[_contract][_key] == false) {
            verifiedContractStorage[_contract][_key] = true;
        }
    }

     
    function getContractStorage(
        address _contract,
        bytes32 _key
    )
        override
        public
        view
        returns (
            bytes32
        )
    {
         
         
        if (
            verifiedContractStorage[_contract][_key] == false
            && accounts[_contract].isFresh
        ) {
            return bytes32(0);
        }

         
        return contractStorage[_contract][_key] ^ STORAGE_XOR_VALUE;
    }

     
    function hasContractStorage(
        address _contract,
        bytes32 _key
    )
        override
        public
        view
        returns (
            bool
        )
    {
        return verifiedContractStorage[_contract][_key] || accounts[_contract].isFresh;
    }

     
    function testAndSetContractStorageLoaded(
        address _contract,
        bytes32 _key
    )
        override
        public
        authenticated
        returns (
            bool
        )
    {
        return _testAndSetItemState(
            _getItemHash(_contract, _key),
            ItemState.ITEM_LOADED
        );
    }

     
    function testAndSetContractStorageChanged(
        address _contract,
        bytes32 _key
    )
        override
        public
        authenticated
        returns (
            bool
        )
    {
        return _testAndSetItemState(
            _getItemHash(_contract, _key),
            ItemState.ITEM_CHANGED
        );
    }

     
    function commitContractStorage(
        address _contract,
        bytes32 _key
    )
        override
        public
        authenticated
        returns (
            bool
        )
    {
        bytes32 item = _getItemHash(_contract, _key);
        if (itemStates[item] != ItemState.ITEM_CHANGED) {
            return false;
        }

        itemStates[item] = ItemState.ITEM_COMMITTED;
        totalUncommittedContractStorage -= 1;

        return true;
    }

     
    function incrementTotalUncommittedContractStorage()
        override
        public
        authenticated
    {
        totalUncommittedContractStorage += 1;
    }

     
    function getTotalUncommittedContractStorage()
        override
        public
        view
        returns (
            uint256
        )
    {
        return totalUncommittedContractStorage;
    }

     
    function wasContractStorageChanged(
        address _contract,
        bytes32 _key
    )
        override
        public
        view
        returns (
            bool
        )
    {
        bytes32 item = _getItemHash(_contract, _key);
        return itemStates[item] >= ItemState.ITEM_CHANGED;
    }

     
    function wasContractStorageCommitted(
        address _contract,
        bytes32 _key
    )
        override
        public
        view
        returns (
            bool
        )
    {
        bytes32 item = _getItemHash(_contract, _key);
        return itemStates[item] >= ItemState.ITEM_COMMITTED;
    }


     

     
    function _getItemHash(
        address _address
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return keccak256(abi.encodePacked(_address));
    }

     
    function _getItemHash(
        address _contract,
        bytes32 _key
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return keccak256(abi.encodePacked(
            _contract,
            _key
        ));
    }

     
    function _testAndSetItemState(
        bytes32 _item,
        ItemState _minItemState
    )
        internal
        returns (
            bool
        )
    {
        bool wasItemState = itemStates[_item] >= _minItemState;

        if (wasItemState == false) {
            itemStates[_item] = _minItemState;
        }

        return wasItemState;
    }
}

 
pragma solidity >0.5.0 <0.8.0;


 





 
library Lib_OVMCodec {

     

    enum QueueOrigin {
        SEQUENCER_QUEUE,
        L1TOL2_QUEUE
    }


     

    struct Account {
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
        address ethAddress;
        bool isFresh;
    }

    struct EVMAccount {
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
    }

    struct ChainBatchHeader {
        uint256 batchIndex;
        bytes32 batchRoot;
        uint256 batchSize;
        uint256 prevTotalElements;
        bytes extraData;
    }

    struct ChainInclusionProof {
        uint256 index;
        bytes32[] siblings;
    }

    struct Transaction {
        uint256 timestamp;
        uint256 blockNumber;
        QueueOrigin l1QueueOrigin;
        address l1TxOrigin;
        address entrypoint;
        uint256 gasLimit;
        bytes data;
    }

    struct TransactionChainElement {
        bool isSequenced;
        uint256 queueIndex;   
        uint256 timestamp;    
        uint256 blockNumber;  
        bytes txData;         
    }

    struct QueueElement {
        bytes32 transactionHash;
        uint40 timestamp;
        uint40 blockNumber;
    }


     

     
    function encodeTransaction(
        Transaction memory _transaction
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        return abi.encodePacked(
            _transaction.timestamp,
            _transaction.blockNumber,
            _transaction.l1QueueOrigin,
            _transaction.l1TxOrigin,
            _transaction.entrypoint,
            _transaction.gasLimit,
            _transaction.data
        );
    }

     
    function hashTransaction(
        Transaction memory _transaction
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return keccak256(encodeTransaction(_transaction));
    }

     
    function toEVMAccount(
        Account memory _in
    )
        internal
        pure
        returns (
            EVMAccount memory
        )
    {
        return EVMAccount({
            nonce: _in.nonce,
            balance: _in.balance,
            storageRoot: _in.storageRoot,
            codeHash: _in.codeHash
        });
    }

     
    function encodeEVMAccount(
        EVMAccount memory _account
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        bytes[] memory raw = new bytes[](4);

         
         
         
        raw[0] = Lib_RLPWriter.writeBytes(
            Lib_Bytes32Utils.removeLeadingZeros(
                bytes32(_account.nonce)
            )
        );
        raw[1] = Lib_RLPWriter.writeBytes(
            Lib_Bytes32Utils.removeLeadingZeros(
                bytes32(_account.balance)
            )
        );
        raw[2] = Lib_RLPWriter.writeBytes(abi.encodePacked(_account.storageRoot));
        raw[3] = Lib_RLPWriter.writeBytes(abi.encodePacked(_account.codeHash));

        return Lib_RLPWriter.writeList(raw);
    }

     
    function decodeEVMAccount(
        bytes memory _encoded
    )
        internal
        pure
        returns (
            EVMAccount memory
        )
    {
        Lib_RLPReader.RLPItem[] memory accountState = Lib_RLPReader.readList(_encoded);

        return EVMAccount({
            nonce: Lib_RLPReader.readUint256(accountState[0]),
            balance: Lib_RLPReader.readUint256(accountState[1]),
            storageRoot: Lib_RLPReader.readBytes32(accountState[2]),
            codeHash: Lib_RLPReader.readBytes32(accountState[3])
        });
    }

     
    function hashBatchHeader(
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return keccak256(
            abi.encode(
                _batchHeader.batchRoot,
                _batchHeader.batchSize,
                _batchHeader.prevTotalElements,
                _batchHeader.extraData
            )
        );
    }
}

 
pragma solidity >0.5.0 <0.8.0;

 
library Lib_RLPReader {

     

    uint256 constant internal MAX_LIST_LENGTH = 32;


     

    enum RLPItemType {
        DATA_ITEM,
        LIST_ITEM
    }


     

    struct RLPItem {
        uint256 length;
        uint256 ptr;
    }


     

     
    function toRLPItem(
        bytes memory _in
    )
        internal
        pure
        returns (
            RLPItem memory
        )
    {
        uint256 ptr;
        assembly {
            ptr := add(_in, 32)
        }

        return RLPItem({
            length: _in.length,
            ptr: ptr
        });
    }

     
    function readList(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            RLPItem[] memory
        )
    {
        (
            uint256 listOffset,
            ,
            RLPItemType itemType
        ) = _decodeLength(_in);

        require(
            itemType == RLPItemType.LIST_ITEM,
            "Invalid RLP list value."
        );

         
         
         
         
        RLPItem[] memory out = new RLPItem[](MAX_LIST_LENGTH);

        uint256 itemCount = 0;
        uint256 offset = listOffset;
        while (offset < _in.length) {
            require(
                itemCount < MAX_LIST_LENGTH,
                "Provided RLP list exceeds max list length."
            );

            (
                uint256 itemOffset,
                uint256 itemLength,
            ) = _decodeLength(RLPItem({
                length: _in.length - offset,
                ptr: _in.ptr + offset
            }));

            out[itemCount] = RLPItem({
                length: itemLength + itemOffset,
                ptr: _in.ptr + offset
            });

            itemCount += 1;
            offset += itemOffset + itemLength;
        }

         
        assembly {
            mstore(out, itemCount)
        }

        return out;
    }

     
    function readList(
        bytes memory _in
    )
        internal
        pure
        returns (
            RLPItem[] memory
        )
    {
        return readList(
            toRLPItem(_in)
        );
    }

     
    function readBytes(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        (
            uint256 itemOffset,
            uint256 itemLength,
            RLPItemType itemType
        ) = _decodeLength(_in);

        require(
            itemType == RLPItemType.DATA_ITEM,
            "Invalid RLP bytes value."
        );

        return _copy(_in.ptr, itemOffset, itemLength);
    }

     
    function readBytes(
        bytes memory _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        return readBytes(
            toRLPItem(_in)
        );
    }

     
    function readString(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            string memory
        )
    {
        return string(readBytes(_in));
    }

     
    function readString(
        bytes memory _in
    )
        internal
        pure
        returns (
            string memory
        )
    {
        return readString(
            toRLPItem(_in)
        );
    }

     
    function readBytes32(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        require(
            _in.length <= 33,
            "Invalid RLP bytes32 value."
        );

        (
            uint256 itemOffset,
            uint256 itemLength,
            RLPItemType itemType
        ) = _decodeLength(_in);

        require(
            itemType == RLPItemType.DATA_ITEM,
            "Invalid RLP bytes32 value."
        );

        uint256 ptr = _in.ptr + itemOffset;
        bytes32 out;
        assembly {
            out := mload(ptr)

             
            if lt(itemLength, 32) {
                out := div(out, exp(256, sub(32, itemLength)))
            }
        }

        return out;
    }

     
    function readBytes32(
        bytes memory _in
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return readBytes32(
            toRLPItem(_in)
        );
    }

     
    function readUint256(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            uint256
        )
    {
        return uint256(readBytes32(_in));
    }

     
    function readUint256(
        bytes memory _in
    )
        internal
        pure
        returns (
            uint256
        )
    {
        return readUint256(
            toRLPItem(_in)
        );
    }

     
    function readBool(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            bool
        )
    {
        require(
            _in.length == 1,
            "Invalid RLP boolean value."
        );

        uint256 ptr = _in.ptr;
        uint256 out;
        assembly {
            out := byte(0, mload(ptr))
        }

        require(
            out == 0 || out == 1,
            "Lib_RLPReader: Invalid RLP boolean value, must be 0 or 1"
        );

        return out != 0;
    }

     
    function readBool(
        bytes memory _in
    )
        internal
        pure
        returns (
            bool
        )
    {
        return readBool(
            toRLPItem(_in)
        );
    }

     
    function readAddress(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            address
        )
    {
        if (_in.length == 1) {
            return address(0);
        }

        require(
            _in.length == 21,
            "Invalid RLP address value."
        );

        return address(readUint256(_in));
    }

     
    function readAddress(
        bytes memory _in
    )
        internal
        pure
        returns (
            address
        )
    {
        return readAddress(
            toRLPItem(_in)
        );
    }

     
    function readRawBytes(
        RLPItem memory _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        return _copy(_in);
    }


     

     
    function _decodeLength(
        RLPItem memory _in
    )
        private
        pure
        returns (
            uint256,
            uint256,
            RLPItemType
        )
    {
        require(
            _in.length > 0,
            "RLP item cannot be null."
        );

        uint256 ptr = _in.ptr;
        uint256 prefix;
        assembly {
            prefix := byte(0, mload(ptr))
        }

        if (prefix <= 0x7f) {
             

            return (0, 1, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xb7) {
             

            uint256 strLen = prefix - 0x80;

            require(
                _in.length > strLen,
                "Invalid RLP short string."
            );

            return (1, strLen, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xbf) {
             
            uint256 lenOfStrLen = prefix - 0xb7;

            require(
                _in.length > lenOfStrLen,
                "Invalid RLP long string length."
            );

            uint256 strLen;
            assembly {
                 
                strLen := div(
                    mload(add(ptr, 1)),
                    exp(256, sub(32, lenOfStrLen))
                )
            }

            require(
                _in.length > lenOfStrLen + strLen,
                "Invalid RLP long string."
            );

            return (1 + lenOfStrLen, strLen, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xf7) {
             
            uint256 listLen = prefix - 0xc0;

            require(
                _in.length > listLen,
                "Invalid RLP short list."
            );

            return (1, listLen, RLPItemType.LIST_ITEM);
        } else {
             
            uint256 lenOfListLen = prefix - 0xf7;

            require(
                _in.length > lenOfListLen,
                "Invalid RLP long list length."
            );

            uint256 listLen;
            assembly {
                 
                listLen := div(
                    mload(add(ptr, 1)),
                    exp(256, sub(32, lenOfListLen))
                )
            }

            require(
                _in.length > lenOfListLen + listLen,
                "Invalid RLP long list."
            );

            return (1 + lenOfListLen, listLen, RLPItemType.LIST_ITEM);
        }
    }

     
    function _copy(
        uint256 _src,
        uint256 _offset,
        uint256 _length
    )
        private
        pure
        returns (
            bytes memory
        )
    {
        bytes memory out = new bytes(_length);
        if (out.length == 0) {
            return out;
        }

        uint256 src = _src + _offset;
        uint256 dest;
        assembly {
            dest := add(out, 32)
        }

         
        for (uint256 i = 0; i < _length / 32; i++) {
            assembly {
                mstore(dest, mload(src))
            }

            src += 32;
            dest += 32;
        }

         
        uint256 mask = 256 ** (32 - (_length % 32)) - 1;
        assembly {
            mstore(
                dest,
                or(
                    and(mload(src), not(mask)),
                    and(mload(dest), mask)
                )
            )
        }

        return out;
    }

     
    function _copy(
        RLPItem memory _in
    )
        private
        pure
        returns (
            bytes memory
        )
    {
        return _copy(_in.ptr, 0, _in.length);
    }
}

 
pragma solidity >0.5.0 <0.8.0;


 
library Lib_RLPWriter {

     

     
    function writeBytes(
        bytes memory _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        bytes memory encoded;

        if (_in.length == 1 && uint8(_in[0]) < 128) {
            encoded = _in;
        } else {
            encoded = abi.encodePacked(_writeLength(_in.length, 128), _in);
        }

        return encoded;
    }

     
    function writeList(
        bytes[] memory _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        bytes memory list = _flatten(_in);
        return abi.encodePacked(_writeLength(list.length, 192), list);
    }

     
    function writeString(
        string memory _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        return writeBytes(bytes(_in));
    }

     
    function writeAddress(
        address _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        return writeBytes(abi.encodePacked(_in));
    }

     
    function writeBytes32(
        bytes32 _in
    )
        internal
        pure
        returns (
            bytes memory _out
        )
    {
        return writeBytes(abi.encodePacked(_in));
    }

     
    function writeUint(
        uint256 _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        return writeBytes(_toBinary(_in));
    }

     
    function writeBool(
        bool _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        bytes memory encoded = new bytes(1);
        encoded[0] = (_in ? bytes1(0x01) : bytes1(0x80));
        return encoded;
    }


     

     
    function _writeLength(
        uint256 _len,
        uint256 _offset
    )
        private
        pure
        returns (
            bytes memory
        )
    {
        bytes memory encoded;

        if (_len < 56) {
            encoded = new bytes(1);
            encoded[0] = byte(uint8(_len) + uint8(_offset));
        } else {
            uint256 lenLen;
            uint256 i = 1;
            while (_len / i != 0) {
                lenLen++;
                i *= 256;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = byte(uint8(lenLen) + uint8(_offset) + 55);
            for(i = 1; i <= lenLen; i++) {
                encoded[i] = byte(uint8((_len / (256**(lenLen-i))) % 256));
            }
        }

        return encoded;
    }

     
    function _toBinary(
        uint256 _x
    )
        private
        pure
        returns (
            bytes memory
        )
    {
        bytes memory b = abi.encodePacked(_x);

        uint256 i = 0;
        for (; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }

        bytes memory res = new bytes(32 - i);
        for (uint256 j = 0; j < res.length; j++) {
            res[j] = b[i++];
        }

        return res;
    }

     
    function _memcpy(
        uint256 _dest,
        uint256 _src,
        uint256 _len
    )
        private
        pure
    {
        uint256 dest = _dest;
        uint256 src = _src;
        uint256 len = _len;

        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint256 mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

     
    function _flatten(
        bytes[] memory _list
    )
        private
        pure
        returns (
            bytes memory
        )
    {
        if (_list.length == 0) {
            return new bytes(0);
        }

        uint256 len;
        uint256 i = 0;
        for (; i < _list.length; i++) {
            len += _list[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint256 flattenedPtr;
        assembly { flattenedPtr := add(flattened, 0x20) }

        for(i = 0; i < _list.length; i++) {
            bytes memory item = _list[i];

            uint256 listPtr;
            assembly { listPtr := add(item, 0x20)}

            _memcpy(flattenedPtr, listPtr, item.length);
            flattenedPtr += _list[i].length;
        }

        return flattened;
    }
}

 
pragma solidity >0.5.0 <0.8.0;

 
library Lib_BytesUtils {

     

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                 
                 
                tempBytes := mload(0x40)

                 
                 
                 
                 
                 
                 
                 
                 
                let lengthmod := and(_length, 31)

                 
                 
                 
                 
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                     
                     
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                 
                 
                mstore(0x40, and(add(mc, 31), not(31)))
            }
             
            default {
                tempBytes := mload(0x40)

                 
                 
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function slice(
        bytes memory _bytes,
        uint256 _start
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        if (_start >= _bytes.length) {
            return bytes("");
        }

        return slice(_bytes, _start, _bytes.length - _start);
    }

    function toBytes32PadLeft(
        bytes memory _bytes
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        bytes32 ret;
        uint256 len = _bytes.length <= 32 ? _bytes.length : 32;
        assembly {
            ret := shr(mul(sub(32, len), 8), mload(add(_bytes, 32)))
        }
        return ret;
    }

    function toBytes32(
        bytes memory _bytes
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        if (_bytes.length < 32) {
            bytes32 ret;
            assembly {
                ret := mload(add(_bytes, 32))
            }
            return ret;
        }

        return abi.decode(_bytes,(bytes32));  
    }

    function toUint256(
        bytes memory _bytes
    )
        internal
        pure
        returns (
            uint256
        )
    {
        return uint256(toBytes32(_bytes));
    }

    function toUint24(
        bytes memory _bytes,
        uint256 _start
    )
        internal
        pure
        returns (
            uint24
        )
    {
        require(_start + 3 >= _start, "toUint24_overflow");
        require(_bytes.length >= _start + 3 , "toUint24_outOfBounds");
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }

    function toUint8(
        bytes memory _bytes,
        uint256 _start
    )
        internal
        pure
        returns (
            uint8
        )
    {
        require(_start + 1 >= _start, "toUint8_overflow");
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toAddress(
        bytes memory _bytes,
        uint256 _start
    )
        internal
        pure
        returns (
            address
        )
    {
        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toNibbles(
        bytes memory _bytes
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        bytes memory nibbles = new bytes(_bytes.length * 2);

        for (uint256 i = 0; i < _bytes.length; i++) {
            nibbles[i * 2] = _bytes[i] >> 4;
            nibbles[i * 2 + 1] = bytes1(uint8(_bytes[i]) % 16);
        }

        return nibbles;
    }

    function fromNibbles(
        bytes memory _bytes
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        bytes memory ret = new bytes(_bytes.length / 2);

        for (uint256 i = 0; i < ret.length; i++) {
            ret[i] = (_bytes[i * 2] << 4) | (_bytes[i * 2 + 1]);
        }

        return ret;
    }

    function equal(
        bytes memory _bytes,
        bytes memory _other
    )
        internal
        pure
        returns (
            bool
        )
    {
        return keccak256(_bytes) == keccak256(_other);
    }
}

 
pragma solidity >0.5.0 <0.8.0;

 
library Lib_Bytes32Utils {

     

     
    function toBool(
        bytes32 _in
    )
        internal
        pure
        returns (
            bool
        )
    {
        return _in != 0;
    }

     
    function fromBool(
        bool _in
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return bytes32(uint256(_in ? 1 : 0));
    }

     
    function toAddress(
        bytes32 _in
    )
        internal
        pure
        returns (
            address
        )
    {
        return address(uint160(uint256(_in)));
    }

     
    function fromAddress(
        address _in
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return bytes32(uint256(_in));
    }

     
    function removeLeadingZeros(
        bytes32 _in
    )
        internal
        pure
        returns (
            bytes memory
        )
    {
        bytes memory out;

        assembly {
             
            let shift := 0
            for { let i := 0 } and(lt(i, 32), eq(byte(i, _in), 0)) { i := add(i, 1) } {
                shift := add(shift, 1)
            }

             
            out := mload(0x40)
            mstore(0x40, add(out, 0x40))

             
            mstore(add(out, 0x20), shl(mul(shift, 8), _in))

             
            mstore(out, sub(32, shift))
        }

        return out;
    }
}
