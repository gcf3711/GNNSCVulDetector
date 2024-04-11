 

 

 
 
pragma solidity >=0.8.0 <0.9.0;



library Base64 {
    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';
        
         
        string memory table = TABLE;

         
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

         
        string memory result = new string(encodedLen + 32);

        assembly {
             
            mstore(result, encodedLen)
            
             
            let tablePtr := add(table, 1)
            
             
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            
             
            let resultPtr := add(result, 32)
            
             
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               
                
               let input := mload(dataPtr)
               
                
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            
             
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        
        return result;
    }
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
 
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

     
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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function uint2str(uint _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bStr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bStr[k] = b1;
            _i /= 10;
        }
        return string(bStr);
    }
}
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _transferOwnership(_msgSender());
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
} 

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
 
abstract contract ERC165 is IERC165 {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
 
interface IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
 
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
 
interface IERC721Metadata is IERC721 {

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

 
contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

     
    string private _name;

     
    string private _symbol;

     
    mapping (uint256 => address) private _owners;

     
    mapping (address => uint256) private _balances;

     
    mapping (uint256 => address) private _tokenApprovals;

     
    mapping (address => mapping (address => bool)) private _operatorApprovals;

     
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

     
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

     
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

     
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
         
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

     
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

         

         
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

     
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

     
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                     
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

 
interface IERC721Enumerable is IERC721 {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
     
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

     
    mapping(uint256 => uint256) private _ownedTokensIndex;

     
    uint256[] private _allTokens;

     
    mapping(uint256 => uint256) private _allTokensIndex;

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

     
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

     
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

     
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

     
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

     
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
         
         

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

         
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId;  
            _ownedTokensIndex[lastTokenId] = tokenIndex;  
        }

         
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

     
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
         
         

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

         
         
         
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;  
        _allTokensIndex[lastTokenId] = tokenIndex;  

         
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

 

 
contract SellYourSoul is ERC721Enumerable, Ownable  {
     
    string private metadataURI = ""; 
    address public _owned;
     
    address proxyRegistryAddress;
    uint256 private _currentTokenId = 0;
    uint public constant TOKEN_LIMIT = 1000*1024;  
    uint public constant ARTIST_PRINTS = 32;  
    uint public constant PRICE = 30 * 1000000000000000;  
     
    address public constant BENEFICIARY = 0x340281d051B6F0BBE305a352967419d05D4dFfa6;
    mapping(uint256=>string) tokenName; 


    string[] private relation = [
        "acceptance",      
        "acquiescence",    
        "bend",            
        "cave",            
        "condescend",      
        "hold",            
        "peace",           
        "resignation",     
        "settle",          
        "tolerate",        
        "yield to sth"     
    ];
    string[] private characteristic = [
        "capitulation",    
        "compromise",      
        "defer",           
        "hold your nose",  
        "philosophical",   
        "resort",          
        "surrender",       
        "trade",           
        "bend",            
        "cave",            
        "relent",          
        "reconcile",       
        "submit",          
        "trade",           
        "yield"            
    ];
    string[] private feature = [
        "resign",          
        "accumulation",    
        "production",      
        "exchange",        
        "market",          
        "maximize",        
        "value",           
        "ownership",       
        "labor",           
        "investment",      
        "money",           
        "profit",          
        "competition",     
        "efficient",       
        "factors",         
        "production",      
        "maximization",    
        "process"          
    ];
    string[] private presence = [
        "sellers",         
        "buyers",          
        "hodlers",         
        "speculators",     
        "scammers",        
        "developers",      
        "marketers",       
        "leaders"          
    ];
    string[] private direction = [
        "bulls",         
        "bears"          
    ];
     
      
      
      
    constructor (string memory name_, string memory symbol_, address _proxyRegistryAddress, string memory uri) ERC721(name_, symbol_) {
        proxyRegistryAddress = _proxyRegistryAddress;
        _owned = msg.sender;
         
        metadataURI = uri;

        for(uint i=0;i<=ARTIST_PRINTS;i++)
           _mintTo(msg.sender); 
    }
    
    function _mintTo(address newOwner) internal  
    {
        super._mint(newOwner, _getNextTokenId());
    }
    function mint(address toAddress) payable public {
        require( totalSupply() < TOKEN_LIMIT,"token limit"); 
        
        uint amount = 0;
        if (totalSupply() >= ARTIST_PRINTS) {
            amount = PRICE;
            require(msg.value >= amount, "!value 0.03 eth");
        }
        
        _mintTo(toAddress); 
        
        if (msg.value > amount) {
            payable(msg.sender).transfer(msg.value - amount);  
        }
        if (amount > 0) {
            payable(BENEFICIARY).transfer(amount);  
        }
    }
    function mintAndSign(string memory signature) payable public {
        require( totalSupply() < TOKEN_LIMIT,"token limit"); 
        
        uint amount = 0;
        if (totalSupply() >= ARTIST_PRINTS) {
            amount = PRICE;
            require(msg.value >= amount, "!value 100 finney");
        }
        
        _mintTo(msg.sender); 
        
        if (msg.value > amount) {
            payable(msg.sender).transfer(msg.value - amount);  
        }
        if (amount > 0) {
            payable(BENEFICIARY).transfer(amount);  
        }
        
        tokenName[totalSupply()] = signature; 
    }
    function mintWithSignature(address toAddress, string memory signature) payable public {
        require( totalSupply() < TOKEN_LIMIT,"token limit"); 
        
        uint amount = 0;
        if (totalSupply() >= ARTIST_PRINTS) {
            amount = PRICE;
            require(msg.value >= amount, "!value 100 finney");
        }
        
        _mintTo(toAddress); 
        
        if (msg.value > amount) {
            payable(msg.sender).transfer(msg.value - amount);  
        }
        if (amount > 0) {
            payable(BENEFICIARY).transfer(amount);  
        }
        
        tokenName[totalSupply()] = signature; 
    }
    
     
    function _getNextTokenId() private view returns (uint256) {
        return totalSupply() + 1;
    }
     
    function setMetadata(string memory uri) public
    {
        require(msg.sender==_owned,"!owned"); 
        metadataURI = uri;
    }
    function signDeed(uint256 tokenId, string memory newName) public
    {
        require(_exists(tokenId),"!exists");
        require(msg.sender==ownerOf(tokenId),"!owner");
        tokenName[tokenId] = newName;
    }
    function contractURI() public view returns (string memory) {
        return metadataURI; 
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
     
    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }
    function toByte(uint8 _uint8) internal pure returns (bytes1) {
        if(_uint8 < 10) {
            return bytes1(_uint8 + 48);
        } else {
            return bytes1(_uint8 + 87);
        }
    }
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        bytes memory bytesArray = new bytes(64);
        for (i = 0; i < bytesArray.length; i++) {
    
            uint8 _f = uint8(_bytes32[i/2] & 0x0f);
            uint8 _l = uint8(_bytes32[i/2] >> 4);
    
            bytesArray[i] = toByte(_f);
            i = i + 1;
            bytesArray[i] = toByte(_l);
        }
        return string(bytesArray);
    }
     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory name = string(abi.encodePacked('Sell Your Soul #', toString(tokenId), ' '));
        string memory description = "With Signature You Comply To Sell Your Soul"; 
        string memory image = Base64.encode(bytes(generateImage(tokenId)));  
        string memory attributes = string(abi.encodePacked('","attributes":[{"trait_type":"Feature", "value": "',
                                                              getFeature(tokenId),
                                                              '"},{"trait_type":"Characteristic", "value": "',
                                                              getCharacteristic(tokenId),
                                                              '"},{"trait_type":"Direction", "value": "',
                                                              getDirection(tokenId),
                                                              '"},{"trait_type":"Type", "value": "',
                                                              getRelation(tokenId),
                                                              '"},{"trait_type":"Tribe", "value": "'
                                                              ,getPresence(tokenId),'"}]}'));
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"', name, tokenName[tokenId], 
                            '", "description":"', description,
                            '","image_data":"data:image/svg+xml;base64,',
                            image,
                            '","image":"data:image/svg+xml;base64,', 
                            image,
                            attributes
                        )
                    )
                )
            )
        );
    }
    
    function getTokenSignature(uint256 tokenId) public view returns (string memory) {
        return tokenName[tokenId];
    }
    function getRelation(uint256 tokenId) public view returns (string memory) {
        return relation[tokenId%10];
    }
    function getFeature(uint256 tokenId) public view returns (string memory) {
        return feature[tokenId%18];
    }
    function getCharacteristic(uint256 tokenId) public view returns (string memory) {
        return characteristic[tokenId%15];
    }
    function getPresence(uint256 tokenId) public view returns (string memory) {
        return presence[tokenId%8];
    }
    function getDirection(uint256 tokenId) public view returns (string memory) {
        return direction[tokenId%2];
    }
    function generateBase64Image(uint256 tokenId) public view returns (string memory) {
        return Base64.encode(bytes(generateImage(tokenId)));
    }
    function generateImage(uint256 tokenId) public view returns (string memory) {
         
        string memory back = bytes32ToString(keccak256(abi.encodePacked(tokenId, tokenName[tokenId])));
    
        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><defs><style type="text/css">@import url("https://fonts.googleapis.com/css?family=Indie+Flower|New+Rocker");</style></defs>',
                '<style>.bl {mix-blend-mode:color-dodge;stroke-dasharray:6;stroke:#ffffff05;stroke-width:200;}.main {fill:#aaaaaa;direction:ltr;font-size:55px;font-family:New Rocker}.undr {fill:#999999;direction:ltr;font-size:15px;font-family:New Rocker}.old  {fill:#999999;mix-blend-mode:overlay;direction:ltr;font-size:55px;font-family:New Rocker} .sig  {fill:white;direction:ltr;font-size:25px;font-family:Indie Flower}</style>',
                '<rect width="100%" height="100%" fill="black"/>',
                '<text x="50%" y="40%" dominant-baseline="middle" text-anchor="middle" class="main">Sell your soul</text>',
                '<text x="20" y="210" dominant-baseline="middle" text-anchor="left" class="undr">Sign here: ...................................................................</text>',
                '<text x="10%" y="17%" dominant-baseline="middle" text-anchor="left" class="old" transform="scale(0.19 3)">', back, '</text>',
                '<text x="90" y="205" dominant-baseline="middle" text-anchor="right" class="sig" textLength="246" lengthAdjust="spacingAndGlyphs">',tokenName[tokenId],'</text>'
                '</svg>'
            )
        );
    }
    
    
    function isApprovedForAll(address owner, address operator) override public view returns (bool)
    {
         
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}