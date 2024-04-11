pragma experimental ABIEncoderV2;

pragma solidity ^0.4.24;


 

 
library AddressUtils {

   
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
     
     
     
     
     
     
     
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

 

 
contract CvcPricingInterface {

    struct CredentialItemPrice {
        bytes32 id;
        uint256 price;
        address idv;
        string credentialItemType;
        string credentialItemName;
        string credentialItemVersion;
        bool deprecated;
    }

     
    event CredentialItemPriceSet(
        bytes32 indexed id,
        uint256 price,
        address indexed idv,
        string credentialItemType,
        string credentialItemName,
        string credentialItemVersion,
        bytes32 indexed credentialItemId
    );

     
    event CredentialItemPriceDeleted(
        bytes32 indexed id,
        address indexed idv,
        string credentialItemType,
        string credentialItemName,
        string credentialItemVersion,
        bytes32 indexed credentialItemId
    );

     
    function setPrice(
        string _credentialItemType,
        string _credentialItemName,
        string _credentialItemVersion,
        uint256 _price
        ) external;

     
    function deletePrice(
        string _credentialItemType,
        string _credentialItemName,
        string _credentialItemVersion
        ) external;

     
    function getPrice(
        address _idv,
        string _credentialItemType,
        string _credentialItemName,
        string _credentialItemVersion
        ) external view returns (
            bytes32 id,
            uint256 price,
            address idv,
            string credentialItemType,
            string credentialItemName,
            string credentialItemVersion,
            bool deprecated
        );

     
    function getPriceByCredentialItemId(
        address _idv,
        bytes32 _credentialItemId
        ) external view returns (
            bytes32 id,
            uint256 price,
            address idv,
            string credentialItemType,
            string credentialItemName,
            string credentialItemVersion,
            bool deprecated
        );

     
    function getAllPrices() external view returns (CredentialItemPrice[]);

     
    function getAllIds() external view returns (bytes32[]);

     
    function getPriceById(
        bytes32 _id
        ) public view returns (
            bytes32 id,
            uint256 price,
            address idv,
            string credentialItemType,
            string credentialItemName,
            string credentialItemVersion,
            bool deprecated
        );
}

 

 
contract CvcValidatorRegistryInterface {

     
    function set(address _idv, string _name, string _description) external;

     
    function get(address _idv) external view returns (string name, string description);

     
    function exists(address _idv) external view returns (bool);
}

 

 
contract CvcOntologyInterface {

    struct CredentialItem {
        bytes32 id;
        string recordType;
        string recordName;
        string recordVersion;
        string reference;
        string referenceType;
        bytes32 referenceHash;
    }

     
    function add(
        string _recordType,
        string _recordName,
        string _recordVersion,
        string _reference,
        string _referenceType,
        bytes32 _referenceHash
        ) external;

     
    function deprecate(string _type, string _name, string _version) public;

     
    function deprecateById(bytes32 _id) public;

     
    function getById(bytes32 _id) public view returns (
        bytes32 id,
        string recordType,
        string recordName,
        string recordVersion,
        string reference,
        string referenceType,
        bytes32 referenceHash,
        bool deprecated
        );

     
    function getByTypeNameVersion(
        string _type,
        string _name,
        string _version
        ) public view returns (
            bytes32 id,
            string recordType,
            string recordName,
            string recordVersion,
            string reference,
            string referenceType,
            bytes32 referenceHash,
            bool deprecated
        );

     
    function getAllIds() public view returns (bytes32[]);

     
    function getAll() public view returns (CredentialItem[]);
}

 

 
contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
    mapping(bytes32 => bytes32) internal bytes32Storage;

}

 

 
contract ImplementationStorage {

     
    bytes32 internal constant IMPLEMENTATION_SLOT = 0xa490aab0d89837371982f93f57ffd20c47991f88066ef92475bc8233036969bb;

     
    constructor() public {
        assert(IMPLEMENTATION_SLOT == keccak256("cvc.proxy.implementation"));
    }

     
    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}

 

 
contract Initializable is EternalStorage, ImplementationStorage {

     

     
    modifier onlyInitialized() {
         
        require(boolStorage[keccak256(abi.encodePacked(implementation(), "initialized"))], "Contract is not initialized");
        _;
    }

     
    modifier initializes() {
        address impl = implementation();
         
        require(!boolStorage[keccak256(abi.encodePacked(impl, "initialized"))], "Contract is already initialized");
        _;
         
        boolStorage[keccak256(abi.encodePacked(impl, "initialized"))] = true;
    }
}

 

 
contract Ownable is EternalStorage {

     

     
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    modifier onlyOwner() {
        require(msg.sender == owner(), "Message sender must be contract admin");
        _;
    }

     
    function owner() public view returns (address) {
         
        return addressStorage[keccak256("owner")];
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Contract owner cannot be zero address");
        setOwner(newOwner);
    }

     
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
         
        addressStorage[keccak256("owner")] = newOwner;
    }
}

 

 
contract Pausable is Ownable, ImplementationStorage {

     

    event Pause();
    event Unpause();

     
    modifier whenNotPaused() {
        require(!paused(), "Contract is paused");
        _;
    }

     
    modifier whenPaused() {
        require(paused(), "Contract must be paused");
        _;
    }

     
    function pause() public onlyOwner whenNotPaused {
         
        boolStorage[keccak256(abi.encodePacked(implementation(), "paused"))] = true;
        emit Pause();
    }

     
    function unpause() public onlyOwner whenPaused {
         
        boolStorage[keccak256(abi.encodePacked(implementation(), "paused"))] = false;
        emit Unpause();
    }

     
    function paused() public view returns (bool) {
         
        return boolStorage[keccak256(abi.encodePacked(implementation(), "paused"))];
    }
}

 

 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
     
     
     
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 

 
contract CvcPricing is EternalStorage, Initializable, Pausable, CvcPricingInterface {

    using SafeMath for uint256;

     


     
    uint256 constant private CVC_TOTAL_SUPPLY = 1e17;

     
     
    uint256 constant private FALLBACK_PRICE = CVC_TOTAL_SUPPLY + 1;  

     
     
     
    uint256 constant private ZERO_PRICE = ~uint256(0);

     
    constructor(address _ontology, address _idvRegistry) public {
        initialize(_ontology, _idvRegistry, msg.sender);
    }

     
    modifier onlyRegisteredValidator() {
        require(idvRegistry().exists(msg.sender), "Identity Validator is not registered");
        _;
    }

     
    function setPrice(
        string _credentialItemType,
        string _credentialItemName,
        string _credentialItemVersion,
        uint256 _price
    )
        external
        onlyRegisteredValidator
        whenNotPaused
    {
         
        require(_price <= CVC_TOTAL_SUPPLY, "Price value cannot be more than token total supply");

         
        bytes32 credentialItemId;
        bool deprecated;
        (credentialItemId, , , , , , , deprecated) = ontology().getByTypeNameVersion(
            _credentialItemType,
            _credentialItemName,
            _credentialItemVersion
        );
         
        require(credentialItemId != 0x0, "Cannot set price for unknown credential item");
        require(deprecated == false, "Cannot set price for deprecated credential item");

         
        bytes32 id = calculateId(msg.sender, credentialItemId);

         
        if (getPriceCredentialItemId(id) == 0x0) {
            registerNewRecord(id);
        }

         
        setPriceIdv(id, msg.sender);
        setPriceCredentialItemId(id, credentialItemId);
        setPriceValue(id, _price);

        emit CredentialItemPriceSet(
            id,
            _price,
            msg.sender,
            _credentialItemType,
            _credentialItemName,
            _credentialItemVersion,
            credentialItemId
        );
    }

     
    function deletePrice(
        string _credentialItemType,
        string _credentialItemName,
        string _credentialItemVersion
    )
        external
        whenNotPaused
    {
         
        bytes32 credentialItemId;
        (credentialItemId, , , , , , ,) = ontology().getByTypeNameVersion(
            _credentialItemType,
            _credentialItemName,
            _credentialItemVersion
        );

         
        bytes32 id = calculateId(msg.sender, credentialItemId);

         
        credentialItemId = getPriceCredentialItemId(id);
        require(credentialItemId != 0x0, "Cannot delete unknown price record");

         
        deletePriceIdv(id);
        deletePriceCredentialItemId(id);
        deletePriceValue(id);

        unregisterRecord(id);

        emit CredentialItemPriceDeleted(
            id,
            msg.sender,
            _credentialItemType,
            _credentialItemName,
            _credentialItemVersion,
            credentialItemId
        );
    }

     
    function getPrice(
        address _idv,
        string _credentialItemType,
        string _credentialItemName,
        string _credentialItemVersion
    )
        external
        view
        onlyInitialized
        returns (
            bytes32 id,
            uint256 price,
            address idv,
            string credentialItemType,
            string credentialItemName,
            string credentialItemVersion,
            bool deprecated
        )
    {
         
        bytes32 credentialItemId;
        (credentialItemId, credentialItemType, credentialItemName, credentialItemVersion, , , , deprecated) = ontology().getByTypeNameVersion(
            _credentialItemType,
            _credentialItemName,
            _credentialItemVersion
        );
        idv = _idv;
        id = calculateId(idv, credentialItemId);
        price = getPriceValue(id);
        if (price == FALLBACK_PRICE) {
            return (0x0, price, 0x0, "", "", "", false);
        }
    }

     
    function getPriceByCredentialItemId(address _idv, bytes32 _credentialItemId) external view returns (
        bytes32 id,
        uint256 price,
        address idv,
        string credentialItemType,
        string credentialItemName,
        string credentialItemVersion,
        bool deprecated
    ) {
        return getPriceById(calculateId(_idv, _credentialItemId));
    }

     
    function getAllPrices() external view onlyInitialized returns (CredentialItemPrice[]) {
        uint256 count = getCount();
        CredentialItemPrice[] memory prices = new CredentialItemPrice[](count);
        for (uint256 i = 0; i < count; i++) {
            bytes32 id = getRecordId(i);
            bytes32 credentialItemId = getPriceCredentialItemId(id);
            string memory credentialItemType;
            string memory credentialItemName;
            string memory credentialItemVersion;
            bool deprecated;

            (, credentialItemType, credentialItemName, credentialItemVersion, , , , deprecated) = ontology().getById(credentialItemId);

            prices[i] = CredentialItemPrice(
                id,
                getPriceValue(id),
                getPriceIdv(id),
                credentialItemType,
                credentialItemName,
                credentialItemVersion,
                deprecated
            );
        }

        return prices;
    }

     
    function getAllIds() external view onlyInitialized returns(bytes32[]) {
        uint256 count = getCount();
        bytes32[] memory ids = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = getRecordId(i);
        }

        return ids;
    }

     
    function initialize(address _ontology, address _idvRegistry, address _owner) public initializes {
        require(AddressUtils.isContract(_ontology), "Initialization error: no contract code at ontology contract address");
        require(AddressUtils.isContract(_idvRegistry), "Initialization error: no contract code at IDV registry contract address");
         
        addressStorage[keccak256("cvc.ontology")] = _ontology;
         
        addressStorage[keccak256("cvc.idv.registry")] = _idvRegistry;
         
        setOwner(_owner);
    }

     
    function getPriceById(bytes32 _id) public view onlyInitialized returns (
        bytes32 id,
        uint256 price,
        address idv,
        string credentialItemType,
        string credentialItemName,
        string credentialItemVersion,
        bool deprecated
    ) {
         
        price = getPriceValue(_id);
         
        bytes32 credentialItemId = getPriceCredentialItemId(_id);
        if (credentialItemId != 0x0) {
             
            id = _id;
            idv = getPriceIdv(_id);

            (, credentialItemType, credentialItemName, credentialItemVersion, , , , deprecated) = ontology().getById(credentialItemId);
        }
    }

     
    function ontology() public view returns (CvcOntologyInterface) {
         
        return CvcOntologyInterface(addressStorage[keccak256("cvc.ontology")]);
    }

     
    function idvRegistry() public view returns (CvcValidatorRegistryInterface) {
         
        return CvcValidatorRegistryInterface(addressStorage[keccak256("cvc.idv.registry")]);
    }

     
    function getCount() internal view returns (uint256) {
         
        return uintStorage[keccak256("prices.count")];
    }

     
    function incrementCount() internal {
         
        uintStorage[keccak256("prices.count")] = getCount().add(1);
    }

     
    function decrementCount() internal {
         
        uintStorage[keccak256("prices.count")] = getCount().sub(1);
    }

     
    function getRecordId(uint256 _index) internal view returns (bytes32) {
         
        return bytes32Storage[keccak256(abi.encodePacked("prices.ids.", _index))];
    }

     
    function registerNewRecord(bytes32 _id) internal {
        bytes32 indexSlot = keccak256(abi.encodePacked("prices.indices.", _id));
         
         
        require(uintStorage[indexSlot] == 0, "Integrity error: price with the same ID is already registered");

        uint256 index = getCount();
         
         
        bytes32Storage[keccak256(abi.encodePacked("prices.ids.", index))] = _id;
         
         
        uintStorage[indexSlot] = index.add(1);
        incrementCount();
    }

     
    function unregisterRecord(bytes32 _id) internal {
         
         

         
        bytes32 deletionIndexSlot = keccak256(abi.encodePacked("prices.indices.", _id));
         
        uint256 deletionIndex = uintStorage[deletionIndexSlot].sub(1);
        bytes32 deletionIdSlot = keccak256(abi.encodePacked("prices.ids.", deletionIndex));

         
        uint256 lastIndex = getCount().sub(1);
        bytes32 lastIdSlot = keccak256(abi.encodePacked("prices.ids.", lastIndex));

         
        bytes32 lastIndexSlot = keccak256(abi.encodePacked("prices.indices.", bytes32Storage[lastIdSlot]));

         
         
        bytes32Storage[deletionIdSlot] = bytes32Storage[lastIdSlot];
         
         
        uintStorage[lastIndexSlot] = uintStorage[deletionIndexSlot];
         
         
        delete bytes32Storage[lastIdSlot];
         
         
        delete uintStorage[deletionIndexSlot];
        decrementCount();
    }
     
    function getPriceValue(bytes32 _id) internal view returns (uint256) {
         
        uint256 value = uintStorage[keccak256(abi.encodePacked("prices.", _id, ".value"))];
         
         
        if (value == 0) {
            return FALLBACK_PRICE;
        }
         
        if (value == ZERO_PRICE) {
            return 0;
        }

        return value;
    }

     
    function setPriceValue(bytes32 _id, uint256 _value) internal {
         
         
        uintStorage[keccak256(abi.encodePacked("prices.", _id, ".value"))] = (_value == 0) ? ZERO_PRICE : _value;
    }

     
    function deletePriceValue(bytes32 _id) internal {
         
        delete uintStorage[keccak256(abi.encodePacked("prices.", _id, ".value"))];
    }

     
    function getPriceCredentialItemId(bytes32 _id) internal view returns (bytes32) {
         
        return bytes32Storage[keccak256(abi.encodePacked("prices.", _id, ".credentialItemId"))];
    }

     
    function setPriceCredentialItemId(bytes32 _id, bytes32 _credentialItemId) internal {
         
        bytes32Storage[keccak256(abi.encodePacked("prices.", _id, ".credentialItemId"))] = _credentialItemId;
    }

     
    function deletePriceCredentialItemId(bytes32 _id) internal {
         
        delete bytes32Storage[keccak256(abi.encodePacked("prices.", _id, ".credentialItemId"))];
    }

     
    function getPriceIdv(bytes32 _id) internal view returns (address) {
         
        return addressStorage[keccak256(abi.encodePacked("prices.", _id, ".idv"))];
    }

     
    function setPriceIdv(bytes32 _id, address _idv) internal {
         
        addressStorage[keccak256(abi.encodePacked("prices.", _id, ".idv"))] = _idv;
    }

     
    function deletePriceIdv(bytes32 _id) internal {
         
        delete addressStorage[keccak256(abi.encodePacked("prices.", _id, ".idv"))];
    }

     
    function calculateId(address _idv, bytes32 _credentialItemId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idv, ".", _credentialItemId));
    }
}