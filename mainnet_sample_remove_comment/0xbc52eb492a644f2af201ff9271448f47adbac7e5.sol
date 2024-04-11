 

 

pragma solidity ^0.5.5;

 
interface ITRC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
library Strings {
     
    function toString(uint256 value) internal pure returns (string memory) {
         
         

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}








 
contract ITRC721 is ITRC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) public view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) public view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
     
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

 
contract ITRC721Enumerable is ITRC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}






contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




 
contract TRC165 is ITRC165 {
     
    bytes4 private constant _INTERFACE_ID_TRC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
         
         
        _registerInterface(_INTERFACE_ID_TRC165);
    }

     
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "TRC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}






 
contract IERC721Metadata is ITRC721 {

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);
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



 
library Address {
     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}




 
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


 
library EnumerableMap {
     
     
     
     
     
     
     
     

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
         
        MapEntry[] _entries;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
         
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) {  
            map._entries.push(MapEntry({ _key: key, _value: value }));
             
             
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

     
    function _remove(Map storage map, bytes32 key) private returns (bool) {
         
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

             
             

            MapEntry storage lastEntry = map._entries[lastIndex];

             
            map._entries[toDeleteIndex] = lastEntry;
             
            map._indexes[lastEntry._key] = toDeleteIndex + 1;  

             
            map._entries.pop();

             
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

     
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

     
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

     
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        return _get(map, key, "EnumerableMap: nonexistent key");
    }

     
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage);  
        return map._entries[keyIndex - 1]._value;  
    }

     

    struct UintToAddressMap {
        Map _inner;
    }

     
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

     
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

     
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

     
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

     
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

     
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key))));
    }

     
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}



 
contract ITRC721Receiver {
     
    function onTRC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

 





contract VerifySignature is Ownable {

    address public  signaturer;

    constructor() public {
        signaturer = msg.sender;
    }

    function changeSignaturer(address value) public onlyOwner {
        signaturer = value;
    }

    function getMessageHash(address owner, address contract_addr, address to, uint _nonce) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(owner, contract_addr, to, _nonce));
    }

    function getMessageHash2(address owner, address contract_addr, address to, uint256 tokenId, uint256 genes, uint _nonce) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(owner, contract_addr, to, tokenId, genes, _nonce));
    }


    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(address to, uint _nonce, bytes memory signature) public view returns (bool)
    {
        bytes32 messageHash = getMessageHash(signaturer, address(this), to, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signaturer;
    }

    function verify2(address to, uint256 tokenId, uint256 genes, uint _nonce, bytes memory signature) public view returns (bool)
    {
        bytes32 messageHash = getMessageHash2(signaturer, address(this), to, tokenId, genes, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signaturer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

}




 
contract IAxie is ITRC721 {

    function spawnAxie(uint256 _genes, address _owner) external returns (uint256);

    function getAxie(uint256 token_id) external returns (uint256, uint256);

}


contract ITpunks is ITRC721Enumerable {
     
}

 
contract WIN_NFT_HORSE_MYSTERY_BOX is Context, Ownable, TRC165, ITpunks, IERC721Metadata, VerifySignature {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

     

     
     
    string public constant Tpunk_PROVENANCE = "ffa993388253d151e96ed2d68f9ed78b3f1ac2bc6e2c5cf5041d30897dd2943d";

    uint256 public MAX_NFT_SUPPLY = 0;

     

     

     
     
    bytes4 private constant _TRC721_RECEIVED = 0x5175f878;

     
    mapping(address => EnumerableSet.UintSet) private _holderTokens;

     
    EnumerableMap.UintToAddressMap private _tokenOwners;

     
    mapping(uint256 => address) private _tokenApprovals;

     
    mapping(uint256 => string) private _tokenName;

     
    mapping(string => bool) private _nameReserved;

     
    mapping(uint256 => bool) private _mintedBeforeReveal;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => uint256) private _horseId;

    mapping(uint256 => address) private _exchanger;

     
    string private _name;

     
    string private _symbol;

    uint256 private _price = 0;

     
    uint256[10] private punks_index = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    uint256[10] private punks_index_exists = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    uint256 private punks_index_exists_length = 10;

    uint256 public punks_per_colum = 0;

    uint256 private nonce = 0;

     
    struct userAirdrop {
        bool isExists;
        uint256 id;
         
        uint256 referral_buy_index;
    }

    mapping(address => userAirdrop) public usersAirdrop;

    mapping(uint256 => address) public usersAirdropAddress;

    uint256 public airDrop_id = 1000;

    uint256 public airDrop_reward = 100;

    mapping(uint256 => address) public winners;

    mapping(address => bool) public whitelist;

    uint256 public whitelist_size = 0;

    function setWhite(address addr, bool value) public onlyOwner {
        whitelist[addr] = value;
        whitelist_size++;
    }


    function enableWhitelist(address[] memory addresses) public onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
            whitelist_size++;
        }
    }

     
    bool private start_sale = true;


     
    bytes4 private constant _INTERFACE_ID_TRC721 = 0x80ac58cd;

     
    bytes4 private constant _INTERFACE_ID_TRC721_METADATA = 0x5b5e139f;

     
    bytes4 private constant _INTERFACE_ID_TRC721_ENUMERABLE = 0x780e9d63;

     
    event exchange (uint256 indexed tokenId, uint256 genes, address spawner, uint256 horse_id);

     
    constructor (string memory name, string memory symbol, uint256 price, uint256 max_supply,address core_addr) public {
        CORE_ADDRESS = core_addr;
        _name = name;
        _symbol = symbol;
        _price = price;
        MAX_NFT_SUPPLY = max_supply;
        punks_per_colum = max_supply / 10;

         
        _registerInterface(_INTERFACE_ID_TRC721);
        _registerInterface(_INTERFACE_ID_TRC721_METADATA);
        _registerInterface(_INTERFACE_ID_TRC721_ENUMERABLE);
    }

    function initializeOwners(address[] memory users, uint256 _column) onlyOwner public {
        require(!start_sale, 'You can not do it when sale is start');

        for (uint256 i = 0; i < users.length; i++) {

            uint256 p_index = ((punks_index[_column]) + ((_column * punks_per_colum)));

            _safeMint(users[i], p_index);

            punks_index[_column]++;
        }
    }

    function finishInitilizeOwners() onlyOwner public {
        start_sale = true;
    }

    function startInitilizeOwners() onlyOwner public {
        start_sale = false;
    }

     
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "TRC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

     
    function ownerOf(uint256 tokenId) public view returns (address) {
        return _tokenOwners.get(tokenId, "TRC721: owner query for nonexistent token");
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        return _holderTokens[owner].at(index);
    }

     
    function totalSupply() public view returns (uint256) {
         
        return _tokenOwners.length();
    }

     
    function tokenByIndex(uint256 index) public view returns (uint256) {
        (uint256 tokenId,) = _tokenOwners.at(index);
        return tokenId;
    }

     
    function getNFTPrice() public view returns (uint256) {
        require(totalSupply() < MAX_NFT_SUPPLY, "Sale has already ended");
        return _price;
    }

    function setNFTPrice(uint256 value) public onlyOwner {
        _price = value;
    }

    function setMaxSupply(uint256 value) public onlyOwner {
        MAX_NFT_SUPPLY = value;
        punks_per_colum = value / 10;
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender] == true, "only whitelist");
        _;
    }

    modifier onlyOnce() {
        require(_holderTokens[msg.sender].length() == 0, "only once");
        _;
    }


     
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

     
    function withdraw() onlyOwner public {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }


    function getNextPunkIndex() private returns (uint256){


        if (punks_index_exists_length > 1) {
            nonce++;
            for (uint256 i = 0; i < punks_index_exists_length; i++) {
                uint256 n = i + uint256(keccak256(abi.encodePacked(now + nonce))) % (punks_index_exists_length - i);
                uint256 temp = punks_index_exists[n];
                punks_index_exists[n] = punks_index_exists[i];
                punks_index_exists[i] = temp;
            }
        } else if (punks_index[punks_index_exists[0]] == punks_per_colum) {
            revert("we don't have any item !");
        }

        uint256 p_index = ((punks_index[punks_index_exists[0]]) + ((punks_index_exists[0] * punks_per_colum)));

        punks_index[punks_index_exists[0]]++;

        if (punks_index[punks_index_exists[0]] >= punks_per_colum) {
            punks_index_exists_length--;
            punks_index_exists[0] = punks_index_exists[punks_index_exists_length];
        }

        return p_index;

    }


     
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "TRC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "TRC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != _msgSender(), "TRC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(address from, address to, uint256 tokenId) public {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "TRC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "TRC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnTRC721Received(from, to, tokenId, _data), "TRC721: transfer to non TRC721Receiver implementer");
    }

     
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "TRC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

     
    function _safeMint(address to, uint256 tokenId) internal {
        require(totalSupply() < MAX_NFT_SUPPLY);
        _safeMint(to, tokenId, "");

    }

     
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        _mint(to, tokenId);
        require(totalSupply() < MAX_NFT_SUPPLY);
        require(_checkOnTRC721Received(address(0), to, tokenId, _data), "TRC721: transfer to non TRC721Receiver implementer");
    }

     
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "TRC721: mint to the zero address");
        require(!_exists(tokenId), "TRC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        _approve(address(0), tokenId);

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

     
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "TRC721: transfer of token that is not own");
        require(to != address(0), "TRC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }


     
    function _checkOnTRC721Received(address from, address to, uint256 tokenId, bytes memory _data)
    internal returns (bool)
    {
        return true;
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {}


    address public CORE_ADDRESS;

    function SET_CORE_ADDRESS(address core) public onlyOwner returns (address){
        CORE_ADDRESS = core;
        return CORE_ADDRESS;
    }

    function startExchange(uint256 tokenId, uint256 genes, uint256 _nonce, bytes memory _signature) public returns (uint256){
        require(verify2(msg.sender, tokenId, genes, _nonce, _signature), "signature is not correct");
        _safeMint(msg.sender, tokenId);
        _transfer(msg.sender, address(0x410000000000000000000000000000000000000001), tokenId);
        IAxie core = IAxie(CORE_ADDRESS);
        uint256 horse_id = core.spawnAxie(genes, msg.sender);
        _horseId[tokenId] = horse_id;
        _exchanger[tokenId] = msg.sender;
        emit exchange(tokenId, genes, msg.sender, horse_id);
        return horse_id;
    }

    function getHorseId(uint256 tokenId) public view returns (uint256){
        return _horseId[tokenId];
    }

    function getExchanger(uint256 tokenId) public view returns (address){
        return _exchanger[tokenId];
    }

}