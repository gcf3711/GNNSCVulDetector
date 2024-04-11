 

 

 

 
 

pragma solidity  ^0.8.0;

 
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

 



pragma solidity  ^0.8.0;


 
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

 



pragma solidity  ^0.8.0;

 
 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 



 
pragma solidity  ^0.8.0;

 

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
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


 

pragma solidity  ^0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 



pragma solidity  ^0.8.0;



 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

     
    function transferFrom(address from, address to, uint256 tokenId) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

 



pragma solidity  ^0.8.0;



 
interface IERC721Metadata is IERC721 {

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

 


pragma solidity  ^0.8.0;

 
 
 
 
interface IERC721Enumerable is IERC721 {

     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}



 



pragma solidity  ^0.8.0;

 
interface IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

 



pragma solidity  ^0.8.0;


 
abstract contract ERC165 is IERC165 {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
         
         
        _registerInterface(_INTERFACE_ID_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

 

 
interface IERC2981 is IERC165 {
     
     
     
     
     
     

    
     
    
    
    
    
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );
}

 

pragma solidity  ^0.8.0;

 
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

     
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0);  
        return (true, map._entries[keyIndex - 1]._value);  
    }

     
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key");  
        return map._entries[keyIndex - 1]._value;  
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
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
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
        return (uint256(key), address(uint160(uint256(value))));
    }

     
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

     
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

     
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}
pragma solidity ^0.8.0;

 
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

     
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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

     
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

     
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

 
pragma solidity  ^0.8.0;

 
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

     
     
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

     
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

     
    EnumerableMap.UintToAddressMap private _tokenOwners;

     
    mapping (uint256 => address) private _tokenApprovals;

     
    mapping (address => mapping (address => bool)) private _operatorApprovals;

     
    string private _name;

     
    string private _symbol;


     
     

     
    string private _baseURI;

     
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

     
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

     
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

     
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

         
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }



     
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

     
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
         
         
         
        return string(abi.encodePacked(baseURI(),tokenId.toString(),".json"));

         
    }


     
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(baseURI(), "contract_metadata", '.json'));
    }

     
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

      
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

     
    function totalSupply() public view virtual override returns (uint256) {
         
        return _tokenOwners.length();
    }

     
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

     
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

     
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);  

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        _approve(address(0), tokenId);

         
         
         
         

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

     
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");  
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

     
     
     
     
     

     
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

     
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);  
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}


 
pragma solidity  ^0.8.0;

 

contract ColourTime721 is Context, ERC721, Ownable {

     
    address payable public withdrawalAddress;

     
    uint256 public maxNumberOfPieces;
    uint256 public tokenCounter;
    uint256 public minTokenIdForSale;
    uint256 public maxTokenIdForSale;
    
     
    uint256 public royaltiesPercentage = 10;
    
     
    bool public standardSaleActive;
    uint256 public pricePerPiece;

     
    struct tokenData {
        string[] colours;
        uint256[] speeds;
        string title;
    }

    mapping (uint256 => tokenData) public tokenDataMap;
    event Mint(address buyer, uint256 price, uint256 tokenId);

    constructor(
        uint256 givenPricePerPiece,
        address payable givenWithdrawalAddress
        
    ) ERC721("Colour Time", "CT") {
        pricePerPiece = givenPricePerPiece;
        withdrawalAddress = givenWithdrawalAddress;
        tokenCounter = 0;
        maxTokenIdForSale = 0;
        minTokenIdForSale = 1;
    }

    function setRoyaltiesPercentage( uint256 givenRoyaltiesPercentage ) external onlyOwner{
        royaltiesPercentage = givenRoyaltiesPercentage;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC2981).interfaceId ||
        super.supportsInterface(interfaceId);
    }
    
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view
    returns (address receiver, uint256 royaltyAmount) {
        uint256 _royalties = (_salePrice * royaltiesPercentage) / 100;
        return (withdrawalAddress, _royalties);
    }

     
    function tokenURI(uint256 tokenId) override public view returns (string memory){
            
            require(_exists(tokenId)  || msg.sender == owner(), "ERC721Metadata: URI query for nonexistent token");
            string[9] memory parts;
            parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 10 10">  <rect width="10" height="10"><animate id="outerbox" attributeName="fill" values="';
            parts[1] = tokenDataMap[tokenId].colours[0];
            parts[2] = '" dur="';
            parts[3] = toString(tokenDataMap[tokenId].speeds[0]);
            parts[4] = '" repeatCount="indefinite"></animate></rect><rect x="2" y="2" width="6" height="6"><animate id="innerbox" attributeName="fill" values="';
            parts[5] = tokenDataMap[tokenId].colours[1];
            parts[6] = '" dur="';
            parts[7] = toString(tokenDataMap[tokenId].speeds[1]);
            parts[8] = '" repeatCount="indefinite"></animate></rect></svg>';

            string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6],parts[7], parts[8]));
            string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Colour Time ', tokenDataMap[tokenId].title, '", "description": "Slowly shifting colours, records of time past. Jonathan Chomko, 2021", "image": "data:image/svg+xml;base64,',Base64.encode(bytes(output)),'"}'))));
            output = string(abi.encodePacked('data:application/json;base64,', json));
            return output;
    }

    function setSaleActive(bool isActive) external onlyOwner {
        standardSaleActive = isActive;
    }

    function setSaleRange(uint256 givenMinTokenIdForSale, uint256 givenMaxTokenIdForSale) external onlyOwner {
         maxTokenIdForSale = givenMaxTokenIdForSale;
         minTokenIdForSale = givenMinTokenIdForSale;
    }

    function setPrice(uint256 givenPrice) external onlyOwner {
        pricePerPiece = givenPrice;
    }

     
    function setTokenData(tokenData[] memory givenData )external onlyOwner {
        for(uint256 i = 0; i < givenData.length; i ++){
                     tokenDataMap[i] = givenData[i];
        }
    }

     
    function setWithdrawalAddress(address payable givenWithdrawalAddress) external onlyOwner {
        withdrawalAddress = givenWithdrawalAddress;
    }

    function withdrawEth() external onlyOwner {
        Address.sendValue(withdrawalAddress, address(this).balance);
    }

     
    function tokenInfo(uint256 tokenId) external view returns (address) {
        return (ownerOf(tokenId));
    }

    function getOwners(uint256 start, uint256 end) public view returns (address[] memory){
        address[] memory re = new address[](end - start);
        for (uint256 i = start; i < end; i++) {
                re[i - start] = ownerOf(i);
        }
        return re;
    }

    function mintItem(uint256 givenTokenId) public payable returns (uint256) {
        require(givenTokenId <= maxTokenIdForSale, "given token value is greater than sale limit");
        require(givenTokenId >= minTokenIdForSale, "given token value is less than sale limit");
        require(standardSaleActive || msg.sender == owner(), "sale must be active");
        require(msg.value == pricePerPiece, "must send in correct amount");

        _safeMint(msg.sender, givenTokenId);

        tokenCounter += 1;
        emit Mint(msg.sender, msg.value, givenTokenId);
        return tokenCounter;
    }

     
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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}


 



library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

         
        uint256 encodedLen = 4 * ((len + 2) / 3);

         
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}