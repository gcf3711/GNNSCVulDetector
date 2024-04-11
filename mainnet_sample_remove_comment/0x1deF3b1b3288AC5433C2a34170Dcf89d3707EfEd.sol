

pragma solidity ^0.7.4;
abstract contract ResolverBase {
    bytes4 private constant INTERFACE_META_ID = 0x01ffc9a7;

    function supportsInterface(bytes4 interfaceID) virtual public pure returns(bool) {
        return interfaceID == INTERFACE_META_ID;
    }

    function isAuthorised(bytes32 node) internal virtual view returns(bool);

    modifier authorised(bytes32 node) {
        require(isAuthorised(node));
        _;
    }

    function bytesToAddress(bytes memory b) internal pure returns(address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addressToBytes(address a) internal pure returns(bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }
}
pragma solidity ^0.7.6;




 
contract StealthKeyFIFSRegistrar {
    ENS public ens;
    bytes32 public rootNode;

     
    constructor(ENS _ens, bytes32 _rootNode) {
        ens = _ens;
        rootNode = _rootNode;
    }

     
    function register(
        bytes32 _label,
        address _owner,
        StealthKeyResolver _resolver,
        uint256 _spendingPubKeyPrefix,
        uint256 _spendingPubKey,
        uint256 _viewingPubKeyPrefix,
        uint256 _viewingPubKey
    ) public {
         
        bytes32 _node = keccak256(abi.encodePacked(rootNode, _label));

         
        address _currentOwner = ens.owner(_node);
        require(_currentOwner == address(0x0), 'StealthKeyFIFSRegistrar: Already claimed');

         
        ens.setSubnodeOwner(rootNode, _label, address(this));
        _resolver.setStealthKeys(_node, _spendingPubKeyPrefix, _spendingPubKey, _viewingPubKeyPrefix, _viewingPubKey);

         
        ens.setSubnodeRecord(rootNode, _label, _owner, address(_resolver), 0);
    }
}

pragma solidity ^0.7.0;

interface ENS {

     
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

     
    event Transfer(bytes32 indexed node, address owner);

     
    event NewResolver(bytes32 indexed node, address resolver);

     
    event NewTTL(bytes32 indexed node, uint64 ttl);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external virtual;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external virtual;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external virtual returns(bytes32);
    function setResolver(bytes32 node, address resolver) external virtual;
    function setOwner(bytes32 node, address owner) external virtual;
    function setTTL(bytes32 node, uint64 ttl) external virtual;
    function setApprovalForAll(address operator, bool approved) external virtual;
    function owner(bytes32 node) external virtual view returns (address);
    function resolver(bytes32 node) external virtual view returns (address);
    function ttl(bytes32 node) external virtual view returns (uint64);
    function recordExists(bytes32 node) external virtual view returns (bool);
    function isApprovedForAll(address owner, address operator) external virtual view returns (bool);
}

pragma solidity ^0.7.4;


abstract contract StealthKeyResolver is ResolverBase {
    bytes4 constant private STEALTH_KEY_INTERFACE_ID = 0x69a76591;

    
    event StealthKeyChanged(bytes32 indexed node, uint256 spendingPubKeyPrefix, uint256 spendingPubKey, uint256 viewingPubKeyPrefix, uint256 viewingPubKey);

     
    mapping(bytes32 => mapping(uint256 => uint256)) _stealthKeys;

     
    function setStealthKeys(bytes32 node, uint256 spendingPubKeyPrefix, uint256 spendingPubKey, uint256 viewingPubKeyPrefix, uint256 viewingPubKey) external authorised(node) {
        require(
            (spendingPubKeyPrefix == 2 || spendingPubKeyPrefix == 3) &&
            (viewingPubKeyPrefix == 2 || viewingPubKeyPrefix == 3),
            "StealthKeyResolver: Invalid Prefix"
        );

        emit StealthKeyChanged(node, spendingPubKeyPrefix, spendingPubKey, viewingPubKeyPrefix, viewingPubKey);

         
        spendingPubKeyPrefix -= 2;

         
        delete _stealthKeys[node][1 - spendingPubKeyPrefix];
        delete _stealthKeys[node][5 - viewingPubKeyPrefix];

         
        _stealthKeys[node][spendingPubKeyPrefix] = spendingPubKey;
        _stealthKeys[node][viewingPubKeyPrefix] = viewingPubKey;
    }

     
    function stealthKeys(bytes32 node) external view returns (uint256 spendingPubKeyPrefix, uint256 spendingPubKey, uint256 viewingPubKeyPrefix, uint256 viewingPubKey) {
        if (_stealthKeys[node][0] != 0) {
            spendingPubKeyPrefix = 2;
            spendingPubKey = _stealthKeys[node][0];
        } else {
            spendingPubKeyPrefix = 3;
            spendingPubKey = _stealthKeys[node][1];
        }

        if (_stealthKeys[node][2] != 0) {
            viewingPubKeyPrefix = 2;
            viewingPubKey = _stealthKeys[node][2];
        } else {
            viewingPubKeyPrefix = 3;
            viewingPubKey = _stealthKeys[node][3];
        }

        return (spendingPubKeyPrefix, spendingPubKey, viewingPubKeyPrefix, viewingPubKey);
    }

    function supportsInterface(bytes4 interfaceID) public virtual override pure returns(bool) {
        return interfaceID == STEALTH_KEY_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}
