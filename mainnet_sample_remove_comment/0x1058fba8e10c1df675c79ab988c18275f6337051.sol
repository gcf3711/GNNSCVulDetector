 

 

 
 
pragma solidity ^0.6.0;


 
library AddressUpgradeable {
     
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


 
library EnumerableSetUpgradeable {
     
     
     
     
     
     
     
     

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
        return _add(set._inner, bytes32(uint256(value)));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
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


 
library CountersUpgradeable {
    using SafeMathUpgradeable for uint256;

    struct Counter {
         
         
         
        uint256 _value;  
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
         
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}


 
library SafeMathUpgradeable {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


 
abstract contract Initializable {

     
    bool private _initialized;

     
    bool private _initializing;

     
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    
    function _isConstructor() private view returns (bool) {
         
         
         
         
         
        address self = address(this);
        uint256 cs;
         
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}


 
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
    uint256[50] private __gap;
}


 
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

     
    function paused() public view returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

     
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}


 
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
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
    uint256[49] private __gap;
}


 
interface IERC20Upgradeable {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    uint256[44] private __gap;
}


 
abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {
    }
    using SafeMathUpgradeable for uint256;

     
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

     
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
    uint256[50] private __gap;
}


 
abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {
    }
     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}


 
contract ERC20PresetMinterPauserUpgradeable is Initializable, ContextUpgradeable, AccessControlUpgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable {
    function initialize(string memory name, string memory symbol) public virtual initializer {
        __ERC20PresetMinterPauser_init(name, symbol);
    }
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

     
    function __ERC20PresetMinterPauser_init(string memory name, string memory symbol) internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
        __ERC20PresetMinterPauser_init_unchained(name, symbol);
    }

    function __ERC20PresetMinterPauser_init_unchained(string memory name, string memory symbol) internal initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

     
    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

     
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

     
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._beforeTokenTransfer(from, to, amount);
    }
    uint256[50] private __gap;
}


 
interface IERC20PermitUpgradeable {
     
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

     
    function nonces(address owner) external view returns (uint256);

     
     
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


 
abstract contract EIP712Upgradeable is Initializable {
     
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
     

     
    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

     
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

     
    function _hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this;  
         
        assembly {
            chainId := chainid()
        }
    }

     
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

     
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
}


 
abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping (address => CountersUpgradeable.Counter) private _nonces;

     
    bytes32 private _PERMIT_TYPEHASH;

     
    function __ERC20Permit_init(string memory name) internal initializer {
        __Context_init_unchained();
        __EIP712_init_unchained(name, "1");
        __ERC20Permit_init_unchained(name);
    }

    function __ERC20Permit_init_unchained(string memory name) internal initializer {
        _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    }

     
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
         
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                amount,
                _nonces[owner].current(),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = _recoverSigner(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, amount);
    }

     
    function _recoverSigner(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
         
         
         
         
         
         
         
         
         
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

         
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

     
    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }

     
     
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    uint256[49] private __gap;
}


 
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


 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


 
contract HHToken is ERC20PresetMinterPauserUpgradeable, ERC20PermitUpgradeable {
    using SafeERC20 for IERC20;

     
    function initialize(string memory name, string memory symbol) public override initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
        __ERC20PresetMinterPauser_init_unchained(name, symbol);
        __ERC20Permit_init(name);
    }

    function uniqueIdentifier() public pure returns(string memory) {
        return "HolyheldToken";
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20PresetMinterPauserUpgradeable, ERC20Upgradeable) {
        super._beforeTokenTransfer(from, to, amount);
    }

     
	 
	 
	function emergencyTransfer(address _token, address _destination, uint256 _amount) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
		IERC20(_token).safeTransfer(_destination, _amount);
	}
}

 
interface IHolyPool {
    function getBaseAsset() external view returns(address);

     
    function depositOnBehalf(address beneficiary, uint256 amount) external;
    function withdraw(address beneficiary, uint256 amount) external;

     
     
    function borrowToInvest(uint256 amount) external returns(uint256);
     
    function returnInvested(uint256 amountCapitalBody) external;

     
    function harvestYield(uint256 amount) external;  
}

 
interface IHolyWing {
     
     
    function executeSwap(address tokenFrom, address tokenTo, uint256 amount, bytes calldata data) external returns(uint256);
}

 
contract HolyHand is AccessControlUpgradeable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 private constant ALLOWANCE_SIZE = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

   
  uint256 public depositFee;
   
  uint256 public exchangeFee;
   
  uint256 public withdrawFee;

   
  IHolyWing private exchangeProxyContract;

   
   
   
  address private yieldDistributorAddress;

  event TokenSwap(address indexed tokenFrom, address indexed tokenTo, address sender, uint256 amountFrom, uint256 expectedMinimumReceived, uint256 amountReceived);

  event FeeChanged(string indexed name, uint256 value);
  
  event EmergencyTransfer(address indexed token, address indexed destination, uint256 amount);

  function initialize() public initializer {
		_setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    depositFee = 0;
    exchangeFee = 0;
    withdrawFee = 0;
  }

  function setExchangeProxy(address _exchangeProxyContract) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
    exchangeProxyContract = IHolyWing(_exchangeProxyContract);
  }

  function setYieldDistributor(address _tokenAddress, address _distributorAddress) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
    yieldDistributorAddress = _distributorAddress;
     
     
    IERC20(_tokenAddress).approve(_distributorAddress, ALLOWANCE_SIZE);
  }

   
   
  function depositToPool(address _poolAddress, 
                         address _token, 
                         uint256 _amount,
                         uint256 _expectedMinimumReceived, 
                         bytes memory convertData) public {
    IHolyPool holyPool = IHolyPool(_poolAddress);
    IERC20 poolToken = IERC20(holyPool.getBaseAsset());
    if (address(poolToken) == _token) {
       
       
      IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

       
      if (poolToken.allowance(address(this), _poolAddress) < _amount) {
        poolToken.approve(_poolAddress, ALLOWANCE_SIZE);
      }

       
      if (depositFee > 0) {
         
        uint256 feeAmount = _amount.mul(depositFee).div(1e18);
         
        holyPool.depositOnBehalf(msg.sender, _amount.sub(feeAmount));
      } else {
        holyPool.depositOnBehalf(msg.sender, _amount);
      }
      return;
    }

     

    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

     
    if (IERC20(_token).allowance(address(this), address(exchangeProxyContract)) < _amount) {
      IERC20(_token).approve(address(exchangeProxyContract), ALLOWANCE_SIZE);
    }
    uint256 amountNew = exchangeProxyContract.executeSwap(_token, address(poolToken), _amount, convertData);
    require(amountNew >= _expectedMinimumReceived, "minimum swap amount not met");

     
    if (exchangeFee > 0 || depositFee > 0) {
      uint256 feeAmount = amountNew.mul(exchangeFee).div(1e18);
      feeAmount = feeAmount.add(feeAmount.mul(depositFee).div(1e18));
       
      amountNew = amountNew.sub(feeAmount);
    } 

     
    if (poolToken.allowance(address(this), _poolAddress) < _amount) {
      poolToken.approve(_poolAddress, ALLOWANCE_SIZE);
    }

     
    holyPool.depositOnBehalf(msg.sender, amountNew);
  }

  function withdrawFromPool(address _poolAddress, uint256 _amount) public {
    IHolyPool holyPool = IHolyPool(_poolAddress);
    IERC20 poolToken = IERC20(holyPool.getBaseAsset());
    uint256 amountBefore = poolToken.balanceOf(address(this));
    holyPool.withdraw(msg.sender, _amount);
    uint256 withdrawnAmount = poolToken.balanceOf(address(this)).sub(amountBefore); 
    
     
    if (withdrawFee > 0) {
      uint256 feeAmount = withdrawnAmount.mul(withdrawFee).div(1e18);
       
      poolToken.safeTransfer(msg.sender, withdrawnAmount.sub(feeAmount));
    } else {
      poolToken.safeTransfer(msg.sender, withdrawnAmount);
    }    
     
  }

	function setDepositFee(uint256 _depositFee) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
		depositFee = _depositFee;
    emit FeeChanged("deposit", _depositFee);
	}

	function setExchangeFee(uint256 _exchangeFee) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
		exchangeFee = _exchangeFee;
    emit FeeChanged("exchange", _exchangeFee);
	}

	function setWithdrawFee(uint256 _withdrawFee) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
		withdrawFee = _withdrawFee;
    emit FeeChanged("withdraw", _withdrawFee);
	}

   
   
  function executeSwap(address _tokenFrom, 
                       address _tokenTo,
                       uint256 _amountFrom, 
                       uint256 _expectedMinimumReceived, 
                       bytes memory convertData) public {
    require(_tokenFrom != _tokenTo, "Same tokens provided");

    IERC20(_tokenFrom).safeTransferFrom(msg.sender, address(this), _amountFrom);
    uint256 amountToSwap = _amountFrom;

     
    if (exchangeFee > 0 || depositFee > 0) {
      uint256 feeAmount = _amountFrom.mul(exchangeFee).div(1e18);
      feeAmount = feeAmount.add(feeAmount.mul(depositFee).div(1e18));
       
      amountToSwap = amountToSwap.sub(feeAmount);
    } 
    
     
    if (IERC20(_tokenFrom).allowance(address(this), address(exchangeProxyContract)) < amountToSwap) {
      IERC20(_tokenFrom).approve(address(exchangeProxyContract), ALLOWANCE_SIZE);
    }

    uint256 amountReceived = exchangeProxyContract.executeSwap(_tokenFrom, _tokenTo, amountToSwap, convertData);
    require(amountReceived >= _expectedMinimumReceived, "minimum swap amount not met");

     
    IERC20(_tokenTo).safeTransfer(msg.sender, amountReceived);

    emit TokenSwap(_tokenFrom, _tokenTo, msg.sender, _amountFrom, _expectedMinimumReceived, amountReceived);
  }

   

   
	 
	 
	function emergencyTransfer(address _token, address _destination, uint256 _amount) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
		IERC20(_token).safeTransfer(_destination, _amount);
    emit EmergencyTransfer(_token, _destination, _amount);
	}

   
   
   
   
   
   
   
  function claimFees(address _token, uint256 _amount) public {
		require(msg.sender == yieldDistributorAddress, "yield distributor only");
		IERC20(_token).safeTransfer(msg.sender, _amount);
	}
}

 
contract HolyWing is AccessControlUpgradeable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function initialize() public initializer {
            _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    uint256 private constant ALLOWANCE_SIZE = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

     
    receive() external payable {}

    event ExecuteSwap(address indexed user, address indexed tokenFrom, address tokenTo, uint256 amount, uint256 amountReceived);

    event EmergencyTransfer(address indexed token, address indexed destination, uint256 amount);

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
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

     
     
     
     
     
     
     
     
    function executeSwap(address _tokenFrom, address _tokenTo, uint256 _amount, bytes memory _data) public returns(uint256) {
         
         
         
         
         
         
         
         
          

        address executorAddress;
        address spenderAddress;
        uint256 ethValue;

        bytes memory callData = slice(_data, 72, _data.length - 72);
        assembly {
            executorAddress := mload(add(_data, add(0x14, 0)))
            spenderAddress := mload(add(_data, add(0x14, 0x14)))
            ethValue := mload(add(_data, add(0x20, 0x28)))
        }

         
         
        IERC20(_tokenFrom).safeTransferFrom(msg.sender, address(this), _amount);

        if (spenderAddress != address(0) && IERC20(_tokenFrom).allowance(address(this), address(spenderAddress)) < _amount) {
            IERC20(_tokenFrom).approve(address(spenderAddress), ALLOWANCE_SIZE);
        }

        uint balanceBefore = IERC20(_tokenTo).balanceOf(address(this));
        
         
        (bool success,) = executorAddress.call{value: ethValue}(callData);
        require(success, "SWAP_CALL_FAILED");
        
        uint balanceAfter = IERC20(_tokenTo).balanceOf(address(this));

         
        uint256 amountReceived = balanceAfter - balanceBefore;

         
        emit ExecuteSwap(msg.sender, _tokenFrom, _tokenTo, _amount, amountReceived);
    
         
        IERC20(_tokenTo).safeTransfer(msg.sender, amountReceived);

        return amountReceived;
    }

     
	 
	 
	function emergencyTransfer(address _token, address _destination, uint256 _amount) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
		IERC20(_token).safeTransfer(_destination, _amount);
        emit EmergencyTransfer(_token, _destination, _amount);
	}
}

 
interface IHolyHand {
}

 
interface IHolyValor {
     
    function safeReclaimAmount() external view returns(uint256);
     
    function totalReclaimAmount() external view returns(uint256);
     
    function reclaimFunds(uint256 amount, bool _safeExecution) external returns(uint256);
}

 
contract HolyPool is AccessControlUpgradeable, IHolyPool {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

     
    bytes32 public constant FINMGMT_ROLE = keccak256("FINMGMT_ROLE");

    uint256 private constant lpPrecision = 1e3;   

     
    event EmergencyTransferSet(address indexed token, address indexed destination, uint256 amount);
    event EmergencyTransferExecute(address indexed token, address indexed destination, uint256 amount);
    address private emergencyTransferToken;
    address private emergencyTransferDestination;
    uint256 private emergencyTransferTimestamp;
    uint256 private emergencyTransferAmount;

     
    address public baseAsset;

    IHolyHand public transferProxy;

     
     
     
     
     
    IHolyValor[] public investProxies;
    mapping(address => uint256) public investProxiesStatuses;

     
    uint256 public totalAssetAmount;

     
    uint256 public totalShareAmount; 
     
    mapping(address => uint256) public shares;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amountRequested, uint256 amountActual);

    event FundsInvested(address indexed investProxy, uint256 amount);
    event FundsDivested(address indexed investProxy, uint256 amount);
    event YieldRealized(uint256 amount);

    event ReclaimFunds(address indexed investProxy, uint256 amountRequested, uint256 amountReclaimed);

    bool depositsEnabled;

    uint256 public hotReserveTarget;  

     
    uint256 public inceptionTimestamp;     

    function initialize(address _baseAsset) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FINMGMT_ROLE, _msgSender());

        baseAsset = _baseAsset;
         
         
         
        totalShareAmount = 1e6;
        totalAssetAmount = 1e6;
        depositsEnabled = true;
        hotReserveTarget = 0;

        inceptionTimestamp = block.timestamp;        
    }

    function getBaseAsset() public override view returns(address) {
        return baseAsset;
    }

    function getDepositBalance(address _beneficiary) public view returns (uint256) {
        return shares[_beneficiary].mul(baseAssetPerShare()).div(1e18);
    }

    function baseAssetPerShare() public view returns (uint256) {
        return totalAssetAmount.mul(1e18).div(totalShareAmount);
    }

    function setTransferProxy(address _transferProxy) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        transferProxy = IHolyHand(_transferProxy);
    }

    function setReserveTarget(uint256 _reserveTarget) public {
        require(hasRole(FINMGMT_ROLE, msg.sender), "Finmgmt only");
        hotReserveTarget = _reserveTarget;
    }

     
     
    function addHolyValor(address _address) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        investProxies.push(IHolyValor(_address));
        investProxiesStatuses[_address] = 1;
    }

     
    function setHolyValorStatus(address _address, uint256 _status) public {
        require(hasRole(FINMGMT_ROLE, msg.sender), "Finmgmt only");
        investProxiesStatuses[_address] = _status;
    }

     
    function setDepositsEnabled(bool _enabled) public {
        require(hasRole(FINMGMT_ROLE, msg.sender), "Finmgmt only");
        depositsEnabled = _enabled;
    }


    function depositOnBehalf(address _beneficiary, uint256 _amount) public override {
        require(msg.sender == address(transferProxy), "transfer proxy only");
        require(depositsEnabled, "deposits disabled");

         
        IERC20(baseAsset).safeTransferFrom(msg.sender, address(this), _amount);

         
        uint256 assetPerShare = baseAssetPerShare();
        uint256 sharesToDeposit = _amount.mul(1e18).div(assetPerShare);
        totalShareAmount = totalShareAmount.add(sharesToDeposit);
        totalAssetAmount = totalAssetAmount.add(_amount);
        shares[_beneficiary] = shares[_beneficiary].add(sharesToDeposit);

        emit Deposit(_beneficiary, _amount);
    }

     
     
     
     
     
     
     
     
     
     
    function withdraw(address _beneficiary, uint256 _amount) public override {
         
        require(msg.sender == address(transferProxy), "transfer proxy only");

        uint256 sharesAvailable = shares[_beneficiary];
        uint256 assetPerShare = baseAssetPerShare();
        uint256 assetsAvailable = sharesAvailable.mul(assetPerShare).div(1e18);
        require(_amount <= assetsAvailable, "requested amount exceeds balance");

        uint256 currentBalance = IERC20(baseAsset).balanceOf(address(this));

        if (currentBalance >= _amount) {
             
            performWithdraw(msg.sender, _beneficiary, _amount, _amount);
            return;
        }

        uint256 amountToReclaim = _amount.sub(currentBalance);
        uint256 reclaimedFunds = retrieveFunds(amountToReclaim);
        if (reclaimedFunds >= amountToReclaim) {
             
            performWithdraw(msg.sender, _beneficiary, _amount, _amount);
        } else {
             
            performWithdraw(msg.sender, _beneficiary, _amount, currentBalance.add(reclaimedFunds));
        }
    }

    function performWithdraw(address _addressProxy, address _beneficiary, uint256 _amountRequested, uint256 _amountActual) internal {
         
        uint256 sharesToWithdraw = _amountRequested.mul(1e18).div(baseAssetPerShare());

         
        require(sharesToWithdraw <= shares[_beneficiary], "requested pool share exceeded");

         
        IERC20(baseAsset).safeTransfer(_addressProxy, _amountActual);

         
         
         
        shares[_beneficiary] = shares[_beneficiary].sub(sharesToWithdraw);
        totalShareAmount = totalShareAmount.sub(sharesToWithdraw);
        totalAssetAmount = totalAssetAmount.sub(_amountRequested);

        emit Withdraw(_beneficiary, _amountRequested, _amountActual);
    }

     
     
     
     
     
     
     
     
     
    function retrieveFunds(uint256 _amount) internal returns(uint256) {
        uint256 safeAmountTotal = 0;

         
        uint length = investProxies.length;
        uint256[] memory safeAmounts = new uint[](length);
        uint256[] memory indexes = new uint[](length);

        for (uint256 i; i < length; i++) {
            safeAmounts[i] = investProxies[i].safeReclaimAmount();
            if (safeAmounts[i] >= _amount && investProxiesStatuses[address(investProxies[i])] > 0) {
                 
                 
                 
                uint256 amountToWithdraw = _amount.add(hotReserveTarget);
                if (amountToWithdraw > safeAmounts[i]) {
                  amountToWithdraw = safeAmounts[i];  
                }
                uint256 reclaimed = investProxies[i].reclaimFunds(amountToWithdraw, true);
                require(reclaimed > amountToWithdraw.sub(lpPrecision) && reclaimed.sub(lpPrecision) < amountToWithdraw, "reclaim amount mismatch");
                emit ReclaimFunds(address(investProxies[i]), _amount, amountToWithdraw);
                return amountToWithdraw;
            }
            indexes[i] = i;
            safeAmountTotal = safeAmountTotal.add(safeAmounts[i]);
        }

         
         
         
        for (uint256 i = length - 1; i >= 0; i--) {
            uint256 picked = safeAmounts[i];
            uint256 pickedIndex = indexes[i];
            uint256 j = i + 1;
            while ((j < length) && (safeAmounts[j] > picked)) {
                safeAmounts[j - 1] = safeAmounts[j];
                indexes[j - 1] = indexes[j];
                j++;
            }
            safeAmounts[j - 1] = picked;
            indexes[j - 1] = pickedIndex;
            if (i == 0) {
                break;  
            }
        }

        if (safeAmountTotal > _amount) {
            uint256 totalReclaimed = 0;
             
             
            for (uint256 i; i < length; i++) {
                uint256 amountToWithdraw = safeAmounts[indexes[i]];
                if (amountToWithdraw > _amount.sub(totalReclaimed).add(hotReserveTarget)) {
                    amountToWithdraw = _amount.sub(totalReclaimed).add(hotReserveTarget);
                }
                uint256 reclaimed = investProxies[indexes[i]].reclaimFunds(amountToWithdraw, true);
                require(reclaimed > amountToWithdraw.sub(lpPrecision) && reclaimed.sub(lpPrecision) < amountToWithdraw, "reclaim amount mismatch");
                totalReclaimed = totalReclaimed.add(amountToWithdraw);
                emit ReclaimFunds(address(investProxies[indexes[i]]), _amount, amountToWithdraw);
                if (totalReclaimed >= _amount) {
                  break;
                }
            }
            return totalReclaimed;
        }

         
        uint256 totalReclaimedNoFees = 0;  
                                           
        uint256 totalActualReclaimed = 0;
         
         
         
        for (uint256 i; i < length; i++) {
            uint256 amountToWithdraw = _amount.sub(totalReclaimedNoFees);
             
            uint256 totalAvailableInValor = investProxies[indexes[i]].totalReclaimAmount();
            if (amountToWithdraw > totalAvailableInValor) {
              amountToWithdraw = totalAvailableInValor;
            }
            uint256 actualReclaimed = investProxies[indexes[i]].reclaimFunds(amountToWithdraw, false);
            totalReclaimedNoFees = totalReclaimedNoFees.add(amountToWithdraw);
            totalActualReclaimed = totalActualReclaimed.add(actualReclaimed);
            emit ReclaimFunds(address(investProxies[indexes[i]]), amountToWithdraw, actualReclaimed);
            if (totalReclaimedNoFees >= _amount) {
                break;
            }
        }
        return totalActualReclaimed;
    }

     
     
     
     
     
    function getSafeWithdrawAmount() public view returns(uint256) {
        uint256 safeAmount = IERC20(baseAsset).balanceOf(address(this));
        uint length = investProxies.length;

        for (uint256 i; i < length; i++) {
            if (investProxiesStatuses[address(investProxies[i])] > 0) {
              safeAmount = safeAmount.add(investProxies[i].safeReclaimAmount());
            }
        }
        return safeAmount;
    }


     
    function borrowToInvest(uint256 _amount) override public returns(uint256) {
        require(investProxiesStatuses[msg.sender] == 1, "active invest proxy only");

        uint256 borrowableAmount = IERC20(baseAsset).balanceOf(address(this));
        require(borrowableAmount > hotReserveTarget, "not enough funds");

        borrowableAmount = borrowableAmount.sub(hotReserveTarget);
        if (_amount > borrowableAmount) {
          _amount = borrowableAmount;
        }

        IERC20(baseAsset).safeTransfer(msg.sender, _amount);

        emit FundsInvested(msg.sender, _amount);

        return _amount;
    }

     
    function returnInvested(uint256 _amountCapitalBody) override public {
        require(investProxiesStatuses[msg.sender] > 0, "invest proxy only");  

        IERC20(baseAsset).safeTransferFrom(address(msg.sender), address(this), _amountCapitalBody);

        emit FundsDivested(msg.sender, _amountCapitalBody);
    }

     
    function harvestYield(uint256 _amountYield) override public {
         
         

         
        IERC20(baseAsset).safeTransferFrom(msg.sender, address(this), _amountYield);

         
        totalAssetAmount = totalAssetAmount.add(_amountYield);

         
        emit YieldRealized(_amountYield);
    }

     
     
     
    function getDailyAPY() public view returns(uint256) {
      uint256 secondsFromInception = block.timestamp.sub(inceptionTimestamp);
      
      return baseAssetPerShare().sub(1e18).mul(100)  
                 .mul(86400).div(secondsFromInception);  
    }


     
     
     
    function emergencyTransferTimelockSet(address _token, address _destination, uint256 _amount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        emergencyTransferTimestamp = block.timestamp;
        emergencyTransferToken = _token;
        emergencyTransferDestination = _destination;
        emergencyTransferAmount = _amount;
          
        emit EmergencyTransferSet(_token, _destination, _amount);
    }

    function emergencyTransferExecute() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        require(block.timestamp > emergencyTransferTimestamp + 24 * 3600, "timelock too early");
        require(block.timestamp < emergencyTransferTimestamp + 72 * 3600, "timelock too late");

        IERC20(emergencyTransferToken).safeTransfer(emergencyTransferDestination, emergencyTransferAmount);

        emit EmergencyTransferExecute(emergencyTransferToken, emergencyTransferDestination, emergencyTransferAmount);
         
        emergencyTransferTimestamp = 0;
        emergencyTransferToken = address(0);
        emergencyTransferDestination = address(0);
        emergencyTransferAmount = 0;
    }
}