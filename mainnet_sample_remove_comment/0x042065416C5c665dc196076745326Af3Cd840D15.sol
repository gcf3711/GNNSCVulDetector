 
pragma experimental ABIEncoderV2;


 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
pragma solidity >0.5.0 <0.8.0;

 


 
abstract contract Lib_AddressResolver {

     

    Lib_AddressManager public libAddressManager;


     

     
    constructor(
        address _libAddressManager
    ) {
        libAddressManager = Lib_AddressManager(_libAddressManager);
    }


     

     
    function resolve(
        string memory _name
    )
        public
        view
        returns (
            address
        )
    {
        return libAddressManager.getAddress(_name);
    }
}
 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 
pragma solidity >0.5.0 <0.8.0;




 
 
abstract contract Abs_FraudContributor is Lib_AddressResolver {
     
     
    modifier contributesToFraudProof(bytes32 preStateRoot, bytes32 txHash) {
        uint256 startGas = gasleft();
        _;
        uint256 gasSpent = startGas - gasleft();
        iOVM_BondManager(resolve('OVM_BondManager')).recordGasSpent(preStateRoot, txHash, msg.sender, gasSpent);
    }
}

 
pragma solidity >0.5.0 <0.8.0;


 


 


 
interface iOVM_FraudVerifier {

     

    event FraudProofInitialized(
        bytes32 _preStateRoot,
        uint256 _preStateRootIndex,
        bytes32 _transactionHash,
        address _who
    );

    event FraudProofFinalized(
        bytes32 _preStateRoot,
        uint256 _preStateRootIndex,
        bytes32 _transactionHash,
        address _who
    );


     

    function getStateTransitioner(bytes32 _preStateRoot, bytes32 _txHash) external view returns (iOVM_StateTransitioner _transitioner);


     

    function initializeFraudVerification(
        bytes32 _preStateRoot,
        Lib_OVMCodec.ChainBatchHeader calldata _preStateRootBatchHeader,
        Lib_OVMCodec.ChainInclusionProof calldata _preStateRootProof,
        Lib_OVMCodec.Transaction calldata _transaction,
        Lib_OVMCodec.TransactionChainElement calldata _txChainElement,
        Lib_OVMCodec.ChainBatchHeader calldata _transactionBatchHeader,
        Lib_OVMCodec.ChainInclusionProof calldata _transactionProof
    ) external;

    function finalizeFraudVerification(
        bytes32 _preStateRoot,
        Lib_OVMCodec.ChainBatchHeader calldata _preStateRootBatchHeader,
        Lib_OVMCodec.ChainInclusionProof calldata _preStateRootProof,
        bytes32 _txHash,
        bytes32 _postStateRoot,
        Lib_OVMCodec.ChainBatchHeader calldata _postStateRootBatchHeader,
        Lib_OVMCodec.ChainInclusionProof calldata _postStateRootProof
    ) external;
}

 
pragma solidity >0.5.0 <0.8.0;


 



 







 




 
contract OVM_FraudVerifier is Lib_AddressResolver, Abs_FraudContributor, iOVM_FraudVerifier {

     

    mapping (bytes32 => iOVM_StateTransitioner) internal transitioners;


     

     
    constructor(
        address _libAddressManager
    )
        Lib_AddressResolver(_libAddressManager)
    {}


     

     
    function getStateTransitioner(
        bytes32 _preStateRoot,
        bytes32 _txHash
    )
        override
        public
        view
        returns (
            iOVM_StateTransitioner _transitioner
        )
    {
        return transitioners[keccak256(abi.encodePacked(_preStateRoot, _txHash))];
    }


     

     
    function initializeFraudVerification(
        bytes32 _preStateRoot,
        Lib_OVMCodec.ChainBatchHeader memory _preStateRootBatchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _preStateRootProof,
        Lib_OVMCodec.Transaction memory _transaction,
        Lib_OVMCodec.TransactionChainElement memory _txChainElement,
        Lib_OVMCodec.ChainBatchHeader memory _transactionBatchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _transactionProof
    )
        override
        public
        contributesToFraudProof(_preStateRoot, Lib_OVMCodec.hashTransaction(_transaction))
    {
        bytes32 _txHash = Lib_OVMCodec.hashTransaction(_transaction);

        if (_hasStateTransitioner(_preStateRoot, _txHash)) {
            return;
        }

        iOVM_StateCommitmentChain ovmStateCommitmentChain = iOVM_StateCommitmentChain(resolve("OVM_StateCommitmentChain"));
        iOVM_CanonicalTransactionChain ovmCanonicalTransactionChain = iOVM_CanonicalTransactionChain(resolve("OVM_CanonicalTransactionChain"));

        require(
            ovmStateCommitmentChain.verifyStateCommitment(
                _preStateRoot,
                _preStateRootBatchHeader,
                _preStateRootProof
            ),
            "Invalid pre-state root inclusion proof."
        );

        require(
            ovmCanonicalTransactionChain.verifyTransaction(
                _transaction,
                _txChainElement,
                _transactionBatchHeader,
                _transactionProof
            ),
            "Invalid transaction inclusion proof."
        );

        require (
            _preStateRootBatchHeader.prevTotalElements + _preStateRootProof.index + 1 == _transactionBatchHeader.prevTotalElements + _transactionProof.index,
            "Pre-state root global index must equal to the transaction root global index."
        );

        _deployTransitioner(_preStateRoot, _txHash, _preStateRootProof.index);

        emit FraudProofInitialized(
            _preStateRoot,
            _preStateRootProof.index,
            _txHash,
            msg.sender
        );
    }

     
    function finalizeFraudVerification(
        bytes32 _preStateRoot,
        Lib_OVMCodec.ChainBatchHeader memory _preStateRootBatchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _preStateRootProof,
        bytes32 _txHash,
        bytes32 _postStateRoot,
        Lib_OVMCodec.ChainBatchHeader memory _postStateRootBatchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _postStateRootProof
    )
        override
        public
        contributesToFraudProof(_preStateRoot, _txHash)
    {
        iOVM_StateTransitioner transitioner = getStateTransitioner(_preStateRoot, _txHash);
        iOVM_StateCommitmentChain ovmStateCommitmentChain = iOVM_StateCommitmentChain(resolve("OVM_StateCommitmentChain"));

        require(
            transitioner.isComplete() == true,
            "State transition process must be completed prior to finalization."
        );

        require (
            _postStateRootBatchHeader.prevTotalElements + _postStateRootProof.index == _preStateRootBatchHeader.prevTotalElements + _preStateRootProof.index + 1,
            "Post-state root global index must equal to the pre state root global index plus one."
        );

        require(
            ovmStateCommitmentChain.verifyStateCommitment(
                _preStateRoot,
                _preStateRootBatchHeader,
                _preStateRootProof
            ),
            "Invalid pre-state root inclusion proof."
        );

        require(
            ovmStateCommitmentChain.verifyStateCommitment(
                _postStateRoot,
                _postStateRootBatchHeader,
                _postStateRootProof
            ),
            "Invalid post-state root inclusion proof."
        );

         
        require(
            _postStateRoot != transitioner.getPostStateRoot(),
            "State transition has not been proven fraudulent."
        );

        _cancelStateTransition(_postStateRootBatchHeader, _preStateRoot);

         
        transitioners[keccak256(abi.encodePacked(_preStateRoot, _txHash))] = iOVM_StateTransitioner(0x0000000000000000000000000000000000000000);

        emit FraudProofFinalized(
            _preStateRoot,
            _preStateRootProof.index,
            _txHash,
            msg.sender
        );
    }


     

     
    function _hasStateTransitioner(
        bytes32 _preStateRoot,
        bytes32 _txHash
    )
        internal
        view
        returns (
            bool _exists
        )
    {
        return address(getStateTransitioner(_preStateRoot, _txHash)) != address(0);
    }

     
    function _deployTransitioner(
        bytes32 _preStateRoot,
        bytes32 _txHash,
        uint256 _stateTransitionIndex
    )
        internal
    {
        transitioners[keccak256(abi.encodePacked(_preStateRoot, _txHash))] = iOVM_StateTransitionerFactory(
            resolve("OVM_StateTransitionerFactory")
        ).create(
            address(libAddressManager),
            _stateTransitionIndex,
            _preStateRoot,
            _txHash
        );
    }

     
    function _cancelStateTransition(
        Lib_OVMCodec.ChainBatchHeader memory _postStateRootBatchHeader,
        bytes32 _preStateRoot
    )
        internal
    {
        iOVM_StateCommitmentChain ovmStateCommitmentChain = iOVM_StateCommitmentChain(resolve("OVM_StateCommitmentChain"));
        iOVM_BondManager ovmBondManager = iOVM_BondManager(resolve("OVM_BondManager"));

         
        ovmStateCommitmentChain.deleteStateBatch(
            _postStateRootBatchHeader
        );

         
        (uint256 timestamp, address publisher) = abi.decode(_postStateRootBatchHeader.extraData, (uint256, address));

         
        ovmBondManager.finalize(
            _preStateRoot,
            publisher,
            timestamp
        );
    }
}

 
pragma solidity >0.5.0 <0.8.0;


 


 


 
interface iOVM_CanonicalTransactionChain {

     

    event TransactionEnqueued(
        address _l1TxOrigin,
        address _target,
        uint256 _gasLimit,
        bytes _data,
        uint256 _queueIndex,
        uint256 _timestamp
    );

    event QueueBatchAppended(
        uint256 _startingQueueIndex,
        uint256 _numQueueElements,
        uint256 _totalElements
    );

    event SequencerBatchAppended(
        uint256 _startingQueueIndex,
        uint256 _numQueueElements,
        uint256 _totalElements
    );

    event TransactionBatchAppended(
        uint256 indexed _batchIndex,
        bytes32 _batchRoot,
        uint256 _batchSize,
        uint256 _prevTotalElements,
        bytes _extraData
    );


     

    struct BatchContext {
        uint256 numSequencedTransactions;
        uint256 numSubsequentQueueTransactions;
        uint256 timestamp;
        uint256 blockNumber;
    }


     


     
    function batches()
        external
        view
        returns (
            iOVM_ChainStorageContainer
        );

     
    function queue()
        external
        view
        returns (
            iOVM_ChainStorageContainer
        );

     
    function getTotalElements()
        external
        view
        returns (
            uint256 _totalElements
        );

     
    function getTotalBatches()
        external
        view
        returns (
            uint256 _totalBatches
        );

     
    function getNextQueueIndex()
        external
        view
        returns (
            uint40
        );

     
    function getQueueElement(
        uint256 _index
    )
        external
        view
        returns (
            Lib_OVMCodec.QueueElement memory _element
        );

     
    function getLastTimestamp()
        external
        view
        returns (
            uint40
        );

     
    function getLastBlockNumber()
        external
        view
        returns (
            uint40
        );

     
    function getNumPendingQueueElements()
        external
        view
        returns (
            uint40
        );

     
    function getQueueLength()
        external
        view
        returns (
            uint40
        );


     
    function enqueue(
        address _target,
        uint256 _gasLimit,
        bytes memory _data
    )
        external;

     
    function appendQueueBatch(
        uint256 _numQueuedTransactions
    )
        external;

     
    function appendSequencerBatch(
         
         
         
         
    )
        external;

     
    function verifyTransaction(
        Lib_OVMCodec.Transaction memory _transaction,
        Lib_OVMCodec.TransactionChainElement memory _txChainElement,
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _inclusionProof
    )
        external
        view
        returns (
            bool
        );
}

 
pragma solidity >0.5.0 <0.8.0;

 
interface iOVM_ChainStorageContainer {

     

     
    function setGlobalMetadata(
        bytes27 _globalMetadata
    )
        external;

     
    function getGlobalMetadata()
        external
        view
        returns (
            bytes27
        );

     
    function length()
        external
        view
        returns (
            uint256
        );

     
    function push(
        bytes32 _object
    )
        external;

     
    function push(
        bytes32 _object,
        bytes27 _globalMetadata
    )
        external;

     
    function get(
        uint256 _index
    )
        external
        view
        returns (
            bytes32
        );

     
    function deleteElementsAfterInclusive(
        uint256 _index
    )
        external;

     
    function deleteElementsAfterInclusive(
        uint256 _index,
        bytes27 _globalMetadata
    )
        external;
}

 
pragma solidity >0.5.0 <0.8.0;


 


 
interface iOVM_StateCommitmentChain {

     

    event StateBatchAppended(
        uint256 indexed _batchIndex,
        bytes32 _batchRoot,
        uint256 _batchSize,
        uint256 _prevTotalElements,
        bytes _extraData
    );

    event StateBatchDeleted(
        uint256 indexed _batchIndex,
        bytes32 _batchRoot
    );


     

     
    function getTotalElements()
        external
        view
        returns (
            uint256 _totalElements
        );

     
    function getTotalBatches()
        external
        view
        returns (
            uint256 _totalBatches
        );

     
    function getLastSequencerTimestamp()
        external
        view
        returns (
            uint256 _lastSequencerTimestamp
        );

     
    function appendStateBatch(
        bytes32[] calldata _batch,
        uint256 _shouldStartAtElement
    )
        external;

     
    function deleteStateBatch(
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader
    )
        external;

     
    function verifyStateCommitment(
        bytes32 _element,
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _proof
    )
        external
        view
        returns (
            bool _verified
        );

     
    function insideFraudProofWindow(
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader
    )
        external
        view
        returns (
            bool _inside
        );
}

 
pragma solidity >0.5.0 <0.8.0;

interface ERC20 {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

 
library Errors {
    string constant ERC20_ERR = "BondManager: Could not post bond";
    string constant ALREADY_FINALIZED = "BondManager: Fraud proof for this pre-state root has already been finalized";
    string constant SLASHED = "BondManager: Cannot finalize withdrawal, you probably got slashed";
    string constant WRONG_STATE = "BondManager: Wrong bond state for proposer";
    string constant CANNOT_CLAIM = "BondManager: Cannot claim yet. Dispute must be finalized first";

    string constant WITHDRAWAL_PENDING = "BondManager: Withdrawal already pending";
    string constant TOO_EARLY = "BondManager: Too early to finalize your withdrawal";

    string constant ONLY_TRANSITIONER = "BondManager: Only the transitioner for this pre-state root may call this function";
    string constant ONLY_FRAUD_VERIFIER = "BondManager: Only the fraud verifier may call this function";
    string constant ONLY_STATE_COMMITMENT_CHAIN = "BondManager: Only the state commitment chain may call this function";
    string constant WAIT_FOR_DISPUTES = "BondManager: Wait for other potential disputes";
}

 
interface iOVM_BondManager {

     

     
    enum State {
         
        NOT_COLLATERALIZED,
         
        COLLATERALIZED,
         
        WITHDRAWING
    }

     
    struct Bond {
         
        State state;
         
        uint32 withdrawalTimestamp;
         
        uint256 firstDisputeAt;
         
        bytes32 earliestDisputedStateRoot;
         
        uint256 earliestTimestamp;
    }

     
     
     
    struct Rewards {
         
        bool canClaim;
         
        uint256 total;
         
         
        mapping(address => uint256) gasSpent;
    }


     

    function recordGasSpent(
        bytes32 _preStateRoot,
        bytes32 _txHash,
        address _who,
        uint256 _gasSpent
    ) external;

    function finalize(
        bytes32 _preStateRoot,
        address _publisher,
        uint256 _timestamp
    ) external;

    function deposit() external;

    function startWithdrawal() external;

    function finalizeWithdrawal() external;

    function claim(
        address _who
    ) external;

    function isCollateralized(
        address _who
    ) external view returns (bool);

    function getGasSpent(
        bytes32 _preStateRoot,
        address _who
    ) external view returns (uint256);
}

 
pragma solidity >0.5.0 <0.8.0;


 


 
interface iOVM_StateTransitioner {

     

    event AccountCommitted(
        address _address
    );

    event ContractStorageCommitted(
        address _address,
        bytes32 _key
    );


     

    function getPreStateRoot() external view returns (bytes32 _preStateRoot);
    function getPostStateRoot() external view returns (bytes32 _postStateRoot);
    function isComplete() external view returns (bool _complete);


     

    function proveContractState(
        address _ovmContractAddress,
        address _ethContractAddress,
        bytes calldata _stateTrieWitness
    ) external;

    function proveStorageSlot(
        address _ovmContractAddress,
        bytes32 _key,
        bytes calldata _storageTrieWitness
    ) external;


     

    function applyTransaction(
        Lib_OVMCodec.Transaction calldata _transaction
    ) external;


     

    function commitContractState(
        address _ovmContractAddress,
        bytes calldata _stateTrieWitness
    ) external;

    function commitStorageSlot(
        address _ovmContractAddress,
        bytes32 _key,
        bytes calldata _storageTrieWitness
    ) external;


     

    function completeTransition() external;
}

 
pragma solidity >0.5.0 <0.8.0;

 


 
interface iOVM_StateTransitionerFactory {

     

    function create(
        address _proxyManager,
        uint256 _stateTransitionIndex,
        bytes32 _preStateRoot,
        bytes32 _transactionHash
    )
        external
        returns (
            iOVM_StateTransitioner _ovmStateTransitioner
        );
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

 


 
contract Lib_AddressManager is Ownable {

     

    event AddressSet(
        string indexed _name,
        address _newAddress,
        address _oldAddress
    );


     

    mapping (bytes32 => address) private addresses;


     

     
    function setAddress(
        string memory _name,
        address _address
    )
        external
        onlyOwner
    {
        bytes32 nameHash = _getNameHash(_name);
        address oldAddress = addresses[nameHash];
        addresses[nameHash] = _address;

        emit AddressSet(
            _name,
            _address,
            oldAddress
        );
    }

     
    function getAddress(
        string memory _name
    )
        external
        view
        returns (
            address
        )
    {
        return addresses[_getNameHash(_name)];
    }


     

     
    function _getNameHash(
        string memory _name
    )
        internal
        pure
        returns (
            bytes32
        )
    {
        return keccak256(abi.encodePacked(_name));
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
            return bytes('');
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
