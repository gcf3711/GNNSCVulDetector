 

 

 
pragma solidity ^0.7.6;


 

interface IMultiOwnedEvents {
    
    event Confirmation(address owner, uint txId);

    
    event Revoke(address owner, uint txId);

    
    event OwnerChanged(address oldOwner, address newOwner);

    
    event OwnerAdded(address newOwner);

    
    event OwnerRemoved(address oldOwner);

    
    event RequirementChanged(uint newRequirement);
}

 

interface IMultiOwnedState {
    
    function requiredNum() external view returns(uint);

    
    function ownerNums() external view returns(uint);

    
    
    
    function pendingOf(uint txId) external view returns(uint yetNeeded, uint ownersDone);

    
    function nextPendingTxId() external view returns(uint);

    
    
    function getOwner(uint ownerIndex) external view returns (address);

    
    function isOwner(address addr) external view returns (bool);
    
    
    
    
    function hasConfirmed(uint txId, address owner) external view returns (bool);
}

 

interface IMultiOwnedActions {
    
    
    
    function revoke(uint txId) external;

    
    
    
    
    function changeOwner(address from, address to) external;

    
    
    
    function addOwner(address newOwner) external;

    
    
    
    function removeOwner(address owner) external;

    
    
    
    function changeRequirement(uint newRequired) external;
}

 


interface IMultiOwned is 
    IMultiOwnedEvents, 
    IMultiOwnedState, 
    IMultiOwnedActions
{    
}

 
contract MultiOwned is IMultiOwned {
    
    uint public override requiredNum;
    
    uint public override ownerNums;
    
     
    uint public constant MAX_OWNERS = 16;
    address[MAX_OWNERS + 1] owners;
    mapping(address => uint) ownerIndexOf;

    
    mapping(uint => PendingState) public override pendingOf;
    
    uint public override nextPendingTxId = 1;

    struct PendingState {
        uint yetNeeded;
        uint ownersDone;
    }

     
    modifier onlySelfCall() {
        require(msg.sender == address(this), "OSC");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        uint nums = _owners.length + 1;
        require(MAX_OWNERS >= nums, "MAX");
        require(_required <= nums && _required > 0, "REQ");
        
        ownerNums = nums;
        owners[1] = msg.sender;
        ownerIndexOf[msg.sender] = 1;
        for (uint i = 0; i < _owners.length; ++i) {
            require(_owners[i] != address(0), "ZA");
            require(!isOwner(_owners[i]), "ISO");
            owners[2 + i] = _owners[i];
            ownerIndexOf[_owners[i]] = 2 + i;
        }
        requiredNum = _required;
    }
    
    
    function revoke(uint txId) external override {
        uint ownerIndex = ownerIndexOf[msg.sender];
        require(ownerIndex != 0, "OC");

        uint ownerIndexBit = 2**ownerIndex;
        PendingState storage pending = pendingOf[txId];
        require(pending.ownersDone & ownerIndexBit > 0, "OD");

        pending.yetNeeded++;
        pending.ownersDone -= ownerIndexBit;
        emit Revoke(msg.sender, txId);
    }
    

    
    function changeOwner(address from, address to) onlySelfCall external override {
        uint ownerIndex = ownerIndexOf[from];
        require(ownerIndex > 0, "COF");
        require(!isOwner(to) && to != address(0), "COT");

        clearPending();
        owners[ownerIndex] = to;
        ownerIndexOf[from] = 0;
        ownerIndexOf[to] = ownerIndex;
        emit OwnerChanged(from, to);
    }
    
    
    function addOwner(address newOwner) onlySelfCall external override {
        require(!isOwner(newOwner), "AON");
        require(ownerNums < MAX_OWNERS, "AOM");
        
        clearPending();
        ownerNums++;
        owners[ownerNums] = newOwner;
        ownerIndexOf[newOwner] = ownerNums;
        emit OwnerAdded(newOwner);
    }
    
    
    function removeOwner(address owner) onlySelfCall external override {
        uint ownerIndex = ownerIndexOf[owner];
        require(ownerIndex > 0, "ROI");
        require(requiredNum <= ownerNums - 1, "RON");

        owners[ownerIndex] = address(0);
        ownerIndexOf[owner] = 0;
        clearPending();
        reorganizeOwners(); 
        emit OwnerRemoved(owner);
    }
    
    
    function changeRequirement(uint newRequired) onlySelfCall external override {
        require(newRequired <= ownerNums && newRequired > 0, "CR");

        requiredNum = newRequired;
        clearPending();
        emit RequirementChanged(newRequired);
    }

    
    function getOwner(uint ownerIndex) external override view returns (address) {
        return address(owners[ownerIndex + 1]);
    }

    
    function isOwner(address addr) public override view returns (bool) {
        return ownerIndexOf[addr] > 0;
    }
    
    
    function hasConfirmed(uint txId, address owner) external override view returns (bool) {
        PendingState storage pending = pendingOf[txId];
        uint ownerIndex = ownerIndexOf[owner];
        if (ownerIndex == 0) return false;
        
         
        uint ownerIndexBit = 2**ownerIndex;
        return (pending.ownersDone & ownerIndexBit > 0);
    }
    

    function confirmAndCheck(uint txId, uint ownerIndex) internal returns (bool) {
        PendingState storage pending = pendingOf[txId];
         
        if (pending.yetNeeded == 0) {
             
            pending.yetNeeded = requiredNum;
             
            pending.ownersDone = 0;
            nextPendingTxId = txId + 1;
        }
         
        uint ownerIndexBit = 2**ownerIndex;
         
        if (pending.ownersDone & ownerIndexBit == 0) {
            emit Confirmation(msg.sender, txId);
             
            if (pending.yetNeeded <= 1) {
                 
                delete pendingOf[txId];
                return true;
            } else {
                 
                pending.yetNeeded--;
                pending.ownersDone |= ownerIndexBit;
            }
        }
        return false;
    }

    function reorganizeOwners() private {
        uint free = 1;
        while (free < ownerNums) {
            while (free < ownerNums && owners[free] != address(0)) free++;
            while (ownerNums > 1 && owners[ownerNums] == address(0)) ownerNums--;
            if (free < ownerNums && owners[ownerNums] != address(0) && owners[free] == address(0)) {
                owners[free] = owners[ownerNums];
                ownerIndexOf[owners[free]] = free;
                owners[ownerNums] = address(0);
            }
        }
    }
    
    function clearPending() virtual internal {
        uint length = nextPendingTxId;
        for (uint i = 1; i < length; ++i)
            if (pendingOf[i].yetNeeded != 0) delete pendingOf[i];
        nextPendingTxId = 1;
    }
}

 

interface IMultiSigWallet {    
    
    event MultiTransact(address owner, uint txId, uint value, address to, bytes data);
    
     
    event ConfirmationNeeded(uint txId, address initiator, uint value, address to, bytes data);


    
    
     function txsOf(uint txId) external view returns(
        address to,
        uint value,
        bytes memory data
    );


    
    
    
    
    
    
    function execute(address to, uint value, bytes memory data) external returns (uint txId);

    
    
    
    
    function confirm(uint txId) external returns (bool success);
}

 
contract MultiSigWallet is IMultiSigWallet, MultiOwned {
    
    mapping (uint => Transaction) public override txsOf;

    struct Transaction {
        address to;
        uint value;
        bytes data;
    }

    constructor(address[] memory _owners, uint _required)
            MultiOwned(_owners, _required) {
    }
    
    function kill(address payable to) onlySelfCall external {
        selfdestruct(to);
    }

    receive() external payable {

    }
    
    
    function execute(address to, uint value, bytes memory data) override external returns (uint txId) {
        uint ownerIndex = ownerIndexOf[msg.sender];
        require(ownerIndex != 0, "OC");
        require(to != address(0), "EXT");

        if(requiredNum <= 1){
            (bool success, ) = to.call{value:value}(data);
            require(success, "EXC");
            emit MultiTransact(msg.sender, txId, value, to, data);
            return 0;
        }
        
        txId = nextPendingTxId;
        confirmAndCheck(txId, ownerIndex);
        txsOf[txId].to = to;
        txsOf[txId].value = value;
        txsOf[txId].data = data;
        emit ConfirmationNeeded(txId, msg.sender, value, to, data);
    }
    
    
    function confirm(uint txId) override external returns (bool success) {
        uint ownerIndex = ownerIndexOf[msg.sender];
        require(ownerIndex != 0, "OC");

        address to = txsOf[txId].to;
        uint value = txsOf[txId].value;
        bytes memory data = txsOf[txId].data;
        require(to != address(0), "TXI"); 
        if(!confirmAndCheck(txId, ownerIndex)) return true;

        (success, ) = to.call{value:value}(data);
        emit MultiTransact(msg.sender, txId, value, to, data);
        
        if (to != address(this)) delete txsOf[txId];
    }
    
    function clearPending() override internal {
        uint length = nextPendingTxId;
        for (uint i = 1; i < length; ++i)
            if (txsOf[i].to != address(0)) delete txsOf[i];
        super.clearPending();
    }
}