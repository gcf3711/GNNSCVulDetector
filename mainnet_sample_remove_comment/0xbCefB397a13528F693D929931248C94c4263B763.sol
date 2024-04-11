 
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
 

pragma solidity >=0.6.0 <0.8.0;





 
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

     
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

     
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

     
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

     
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

     
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

     
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

     
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

     
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

     
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

     
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

     
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

     
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

 

pragma solidity >=0.6.2 <0.8.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

         
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct Bytes32Set {
        Set _inner;
    }

     
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

     
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

     
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

     
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

 

pragma solidity >=0.6.0 <0.8.0;





 
contract NodeEnv is AccessControl {
    using EnumerableStringMap for EnumerableStringMap.StringToStringMap;
     
    bytes32 public constant BRIDGEMANAGER_ROLE = keccak256('BRIDGEMANAGER_ROLE');
     
    EnumerableStringMap.StringToStringMap private _config;  

     
    event ConfigUpdate(
        string key
    );

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(BRIDGEMANAGER_ROLE, msg.sender);
    }

     
    function keyCount()
    public
    view
    returns (uint256){
        return _config.length();
    }

     
    function keyValueByIndex(uint256 index) public view returns(string memory, string memory){
        return _config.at(index);
    }

     
    function get(string calldata _key) public view returns(string memory){
        string memory key = _key;
        return _config.get(key);
    }

     
    function set(string calldata _key, string calldata _value) public returns(bool) {
        require(
            hasRole(BRIDGEMANAGER_ROLE, msg.sender),
            'Caller is not Bridge Manager'
        );
        string memory key = _key;
        string memory value = _value;

        return _config.set(key, value);
    }
}

 

pragma solidity >=0.6.0 <0.8.0;



 
library EnumerableStringMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

     
     
     
     
     
     
     
     

    struct Map {
         
        EnumerableSet.Bytes32Set _keys;
         
        mapping(bytes32 => string) _hashKeyMap;
         
        mapping(bytes32 => string) _values;
    }

     
    function _set(
        Map storage map,
        string memory key,
        string memory value
    ) private returns (bool) {
        bytes32 keyHash = keccak256(abi.encodePacked(key));
        map._values[keyHash] = value;
        map._hashKeyMap[keyHash] = key;
        return map._keys.add(keyHash);
    }

     
    function _remove(Map storage map, bytes32 keyHash) private returns (bool) {
        delete map._values[keyHash];
        delete map._hashKeyMap[keyHash];
        return map._keys.remove(keyHash);
    }

     
    function _contains(Map storage map, bytes32 keyHash) private view returns (bool) {
        return map._keys.contains(keyHash);
    }

     
    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

     
    function _at(Map storage map, uint256 index) private view returns (string memory, string memory) {
        bytes32 keyHash = map._keys.at(index);
        return (map._hashKeyMap[keyHash], map._values[keyHash]);
    }

     
    function _tryGet(Map storage map, bytes32 keyHash) private view returns (bool, string memory) {
        string memory value = map._values[keyHash];
        if (keccak256(bytes(value)) == keccak256(bytes(""))) {
            return (_contains(map, keyHash), "");
        } else {
            return (true, value);
        }
    }

     
    function _get(Map storage map, bytes32 keyHash) private view returns (string memory) {
        string memory value = map._values[keyHash];
        require(_contains(map, keyHash), "EnumerableMap: nonexistent key");
        return value;
    }

     
    struct StringToStringMap {
        Map _inner;
    }

     
    function set(
        StringToStringMap storage map,
        string memory key,
        string memory value
    ) internal returns (bool) {
        return _set(map._inner, key, value);
    }

     
    function remove(StringToStringMap storage map, string memory key) internal returns (bool) {
        return _remove(map._inner, keccak256(abi.encodePacked(key)));
    }

     
    function contains(StringToStringMap storage map, string memory key) internal view returns (bool) {
        return _contains(map._inner, keccak256(abi.encodePacked(key)));
    }

     
    function length(StringToStringMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

     
    function at(StringToStringMap storage map, uint256 index) internal view returns (string memory, string memory) {
        return _at(map._inner, index);
    }

     
    function tryGet(StringToStringMap storage map, uint256 key) internal view returns (bool, string memory) {
        (bool success, string memory value) = _tryGet(map._inner, bytes32(key));
        return (success, value);
    }

     
    function get(StringToStringMap storage map, string memory key) internal view returns (string memory) {
        return _get(map._inner, keccak256(abi.encodePacked(key)));
    }
}