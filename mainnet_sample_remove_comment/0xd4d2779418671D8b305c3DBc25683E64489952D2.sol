 
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

 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeMath {
     
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

     
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

     
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
         
         
         
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

     
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

     
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
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





contract BridgeConfig is AccessControl {
  bytes32 public constant BRIDGEMANAGER_ROLE = keccak256('BRIDGEMANAGER_ROLE');
  address[] private _allTokenIDs;
  using SafeMath for uint256;
  mapping(address => MultichainToken[]) private _allMultichainTokens;  
  mapping(uint256 => mapping(address => address)) private _tokenIDMap;  
  mapping(address => mapping(uint256 => TokenConfig)) private _tokenConfig;  

   
   
  uint256 private constant FEE_DENOMINATOR = 10**10;

  modifier checkTokenConfig(TokenConfig memory config) {
    require(config.maxSwap > 0, 'zero MaximumSwap');
    require(config.minSwap > 0, 'zero MinimumSwap');
    require(config.maxSwap >= config.minSwap, 'MaximumSwap < MinimumSwap');
    require(
      config.maxSwapFee >= config.minSwapFee,
      'MaximumSwapFee < MinimumSwapFee'
    );
    require(
      config.maxSwapFee >= config.minSwapFee,
      'MinimumSwap < MinimumSwapFee'
    );
    _;
  }

  struct TokenConfig {
    uint256 chainId;
    address tokenAddress;
    uint8 tokenDecimals;
    uint256 maxSwap;
    uint256 minSwap;
    uint256 swapFee;
    uint256 maxSwapFee;
    uint256 minSwapFee;
  }

  struct MultichainToken {
    uint256 chainId;
    address tokenAddress;
  }

  function getAllTokenIDs() external view returns (address[] memory result) {
    uint256 length = _allTokenIDs.length;
    result = new address[](length);
    for (uint256 i = 0; i < length; ++i) {
      result[i] = _allTokenIDs[i];
    }
  }

  function getTokenID(uint256 chainID, address tokenAddress)
    public
    view
    returns (address)
  {
    return _tokenIDMap[chainID][tokenAddress];
  }

  function getMultichainToken(address token, uint256 chainID)
    public
    view
    returns (address)
  {
    address tokenID;
    if (getTokenID(chainID, token) != address(0)) {
      tokenID = getTokenID(chainID, token);
    } else {
      tokenID = token;
    }
    MultichainToken[] storage _mcTokens = _allMultichainTokens[tokenID];
    for (uint256 i = 0; i < _mcTokens.length; ++i) {
      if (_mcTokens[i].chainId == chainID) {
        return _mcTokens[i].tokenAddress;
      }
    }
    return address(0);
  }

  function _isTokenIDExist(address tokenID) internal view returns (bool) {
    for (uint256 i = 0; i < _allTokenIDs.length; ++i) {
      if (_allTokenIDs[i] == tokenID) {
        return true;
      }
    }
    return false;
  }

  function isTokenIDExist(address tokenID) public view returns (bool) {
    return _isTokenIDExist(tokenID);
  }

  function getTokenConfig(address tokenID, uint256 chainID)
    public
    view
    returns (TokenConfig memory)
  {
    return _tokenConfig[tokenID][chainID];
  }

  function _setTokenConfig(
    address tokenID,
    uint256 chainID,
    TokenConfig memory config
  ) internal checkTokenConfig(config) returns (bool) {
    _tokenConfig[tokenID][chainID] = config;
    if (!_isTokenIDExist(tokenID)) {
      _allTokenIDs.push(tokenID);
    }
    _setMultichainToken(tokenID, chainID, config.tokenAddress);

    return true;
  }

  function setTokenConfig(
    address tokenID,
    uint256 chainID,
    address tokenAddress,
    uint8 tokenDecimals,
    uint256 maxSwap,
    uint256 minSwap,
    uint256 swapFee,
    uint256 maxSwapFee,
    uint256 minSwapFee
  ) external returns (bool) {
    TokenConfig memory config;
    config.tokenAddress = tokenAddress;
    config.tokenDecimals = tokenDecimals;
    config.maxSwap = maxSwap;
    config.minSwap = minSwap;
    config.swapFee = swapFee;
    config.maxSwapFee = maxSwapFee;
    config.minSwapFee = minSwapFee;
    require(hasRole(BRIDGEMANAGER_ROLE, msg.sender));
    return _setTokenConfig(tokenID, chainID, config);
  }

  function _setMultichainToken(
    address tokenID,
    uint256 chainID,
    address token
  ) internal {
    MultichainToken[] storage _mcTokens = _allMultichainTokens[tokenID];
    for (uint256 i = 0; i < _mcTokens.length; ++i) {
      if (_mcTokens[i].chainId == chainID) {
        address oldToken = _mcTokens[i].tokenAddress;
        if (token != oldToken) {
          _mcTokens[i].tokenAddress = token;
          _tokenIDMap[chainID][oldToken] = address(0);
          _tokenIDMap[chainID][token] = tokenID;
        }
        return;
      }
    }
    _mcTokens.push(MultichainToken(chainID, token));
    _tokenIDMap[chainID][token] = tokenID;
  }

  function calculateSwapFee(
    uint256 chainId,
    address tokenAddress,
    uint256 amount
  ) external view returns (uint256) {
    address tokenId = getTokenID(chainId, tokenAddress);
    TokenConfig memory config = getTokenConfig(tokenId, chainId);
    uint256 calculatedSwapFee = amount.mul(config.swapFee).div(FEE_DENOMINATOR);
    if (calculatedSwapFee > config.minSwapFee) {
      return calculatedSwapFee;
    } else {
      return config.minSwapFee;
    }
  }

  constructor() public {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(BRIDGEMANAGER_ROLE, msg.sender);
  }
}
