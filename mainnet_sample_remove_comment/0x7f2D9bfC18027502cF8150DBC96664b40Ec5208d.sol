 


 

pragma solidity ^0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
 

pragma solidity ^0.8.0;



 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

 

pragma solidity ^0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 

pragma solidity ^0.8.0;



 
interface IERC721Metadata is IERC721 {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

 

pragma solidity ^0.8.0;



 
abstract contract ERC165 is IERC165 {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

 

pragma solidity ^0.8.0;









 
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

     
    string private _name;

     
    string private _symbol;

     
    mapping(uint256 => address) private _owners;

     
    mapping(address => uint256) private _balances;

     
    mapping(uint256 => address) private _tokenApprovals;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

     
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
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

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
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

     
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
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

     
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
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

     
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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

 

pragma solidity ^0.8.0;



 
interface IERC721Enumerable is IERC721 {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 

pragma solidity ^0.8.0;




 
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

 

pragma solidity ^0.8.0;

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

 

pragma solidity ^0.8.0;



 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _setOwner(_msgSender());
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
 

 

pragma solidity 0.8.7;







contract MetaverseClub is ERC721Enumerable, ReentrancyGuard, Ownable {

   
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdCounter;

   
  string public _roomBaseUrl = "https://metaverseclub.io/";

   
  mapping(uint256 => string) private _roomMessage;

   
  uint256 public _price = 0.1 ether;

   
  uint256 public _maxSupply = 10000;

   
  bool public _publicSale = false;

   
  string private tokenIdInvalid = "tokenId invalid";

   
  function setRoomMessage(uint256 tokenId, string memory newRoomMessage) external payable {
    require(_tokenIdCounter.current() >= tokenId && tokenId > 0, tokenIdInvalid);
    require( msg.sender == ownerOf(tokenId), "token owner only");
    require( msg.value >= _price, "incorrect ETH sent" );
    _roomMessage[tokenId] = newRoomMessage;
  }

   
  function getRoomMessage(uint256 tokenId) public view returns (string memory) {
    require(_tokenIdCounter.current() >= tokenId && tokenId > 0, tokenIdInvalid);
    bytes memory tempEmptyStringTest = bytes(_roomMessage[tokenId]);
    if (tempEmptyStringTest.length == 0) {
      uint256 randMsg = random("nft", tokenId);
      if (randMsg % 17 == 3)
        return "LFG!";
      else if (randMsg % 7 == 3)
        return "WAGMI!";
      else
        return "gm!";
    } else {
      return _roomMessage[tokenId];
    }
  }

   
  function setPrice(uint256 newPrice) external onlyOwner {
    _price = newPrice;
  }

   
  function setRoomBaseUrl(string memory newUrl) external onlyOwner {
    _roomBaseUrl = newUrl;
  }

   
  function publicSale(bool val) external onlyOwner {
    _publicSale = val;
  }

   
  function withdraw() external payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

   
  function mint(uint256 num) external payable nonReentrant {
    require( _publicSale, "public sale paused" );
    require( num <= 10, "max 10 per TX" );
    require( _tokenIdCounter.current() + num <= _maxSupply, "max supply reached" );
    require( msg.value >= _price * num, "incorrect ETH sent" );

    for( uint i = 0; i < num; i++ ) {
      _safeMint(_msgSender(), _tokenIdCounter.current() + 1);
      _tokenIdCounter.increment();
    }
  }

   
  function mintToCreator(address creatorAddress) external nonReentrant onlyOwner {
    require( _tokenIdCounter.current() + 1 <= _maxSupply, "max supply reached" );
    _safeMint(creatorAddress, _tokenIdCounter.current() + 1);
    _tokenIdCounter.increment();
  }

   
  function ownerClaim(uint256 num) external nonReentrant onlyOwner {
    require( _tokenIdCounter.current() + num <= _maxSupply, "max supply reached" );
    for (uint i = 0; i < num; i++) {
      _safeMint(owner(), _tokenIdCounter.current() + 1);
      _tokenIdCounter.increment();
    }
  }

   
  string[] private assetRoomType = [
    "Camp",
    "Verse",
    "Vault",
    "Plaza",
    "Theater",
    "State",
    "Gallery",
    "Room",
    "Base",
    "Cafe",
    "Yacht",
    "School",
    "Keep",
    "Lab",
    "Home",
    "Factory",
    "Place",
    "Market",
    "Dream",
    "Bank",
    "City",
    "Class",
    "Kingdom",
    "Hall",
    "World",
    "Museum",
    "Game",
    "Dungeon",
    "Pit",
    "Hideout",
    "Planet",
    "Party",
    "Workshop",
    "Country",
    "Nation",
    "Maze",
    "Club",
    "Land",
    "Garden",
    "Asylum",
    "Heaven",
    "Salon",
    "Station",
    "Study",
    "Zone",
    "Arena",
    "Mansion",
    "Matrix",
    "Pub",
    "Space"
  ];

   
  string[] private assetRoomTheme = [
    "Gothic",
    "Bitcoin",
    "Sci-Fi",
    "Fugazi",
    "Open",
    "VR",
    "Mindful",
    "Meta",
    "Magical",
    "Doge",
    "Haunted",
    "YOLO",
    "DeFi",
    "Flow",
    "Logical",
    "Lion",
    "Doom",
    "Web3",
    "AI",
    "Mega",
    "Orc",
    "Bored",
    "Ethereum",
    "Toad",
    "Hidden",
    "Techno",
    "WAGMI",
    "Mutant",
    "3D",
    "Ape",
    "Network",
    "Skull",
    "Unicorn",
    "Satoshi",
    "Zombie",
    "Moon",
    "Robotic",
    "Crypto",
    "Cyber",
    "Cat",
    "Degen",
    "GM",
    "NFT",
    "Mad",
    "FOMO",
    "Punk",
    "Bear",
    "Coin"
  ];

   
  function random(string memory input, uint256 tokenId) private pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input, toString(tokenId + 420001))));
  }

   
  function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) private pure returns (string memory) {
    return sourceArray[random(keyPrefix, tokenId) % sourceArray.length];
  }

   
  function getRoomTheme(uint256 tokenId) public view returns (string memory) {
    require(_tokenIdCounter.current() >= tokenId && tokenId > 0, tokenIdInvalid);
    return string(abi.encodePacked(pluck(tokenId, "theme", assetRoomTheme)));
  }

   
  function getRoomType(uint256 tokenId) public view returns (string memory) {
    require(_tokenIdCounter.current() >= tokenId && tokenId > 0, tokenIdInvalid);
    return string(abi.encodePacked(pluck(tokenId, "type", assetRoomType)));
  }

   
  function getRoomURL(uint256 tokenId) public view returns (string memory) {
    require(_tokenIdCounter.current() >= tokenId && tokenId > 0, tokenIdInvalid);
    return string(abi.encodePacked(_roomBaseUrl, toString(tokenId)));
  }

   
  function getAssetLink1(uint256 tokenId) private pure returns (uint256) {
    if (tokenId > 1) {
      uint256 rand = random("link1", tokenId);
      if (rand % 99 < 70)
        return rand % (tokenId - 1) + 1;
      else
        return 0;
    } else {
      return 0;
    }
  }

   
  function getAssetLink2(uint256 tokenId) private pure returns (uint256) {
    uint256 rand = random("link2", tokenId);
    uint256 link2Id = rand % (tokenId - 1) + 1;
    if (link2Id == getAssetLink1(tokenId)){
      return 0;
    } else {
      if (rand % 99 < 50)
        return link2Id;
      else
        return 0;
    }
  }

   
  function getAssetLinks(uint256 tokenId) private pure returns (string memory) {
    string memory traitTypeJson = ', {"trait_type": "Linked", "value": "';
    if (getAssetLink1(tokenId) < 1)
      return '';
    if (getAssetLink2(tokenId) > 0) {
      return string(abi.encodePacked(traitTypeJson, '2 Rooms"}'));
    } else {
      return string(abi.encodePacked(traitTypeJson, '1 Room"}'));
    }
  }

   
  function haveStar(uint256 tokenId) private pure returns (string memory) {
    uint256 starSeed = random("star", tokenId);
    string memory traitTypeJson = ', {"trait_type": "Star", "value": "';
    if (starSeed % 47 == 1)
      return string(abi.encodePacked(traitTypeJson, 'Sirius"}'));
    if (starSeed % 11 == 1)
      return string(abi.encodePacked(traitTypeJson, 'Vega"}'));
    return '';
  }

   
  function renderStar(uint256 tokenId) private pure returns (string memory) {
    string memory starFirstPart = '<defs><linearGradient id="star" x1="100%" y1="100%"><stop offset="0%" stop-color="black" stop-opacity=".5"><animate attributeName="stop-color" values="black;black;black;black;gray;';
    string memory starLastPart = ';gray;black;black;black;black" dur="3s" repeatCount="indefinite" /></stop></linearGradient></defs><g style="transform:translate(130px,244px)"><g style="transform:scale(0.1,0.1)"><path fill="url(#star)" d="M189.413,84c-36.913,0-37.328,38.157-37.328,38.157c0-33.181-36.498-38.157-36.498-38.157  c37.328,0,36.498-38.157,36.498-38.157C152.085,84,189.413,84,189.413,84z" /></g></g>';
    uint256 starSeed = random("star", tokenId);
    if (starSeed % 47 == 1)
      return string(abi.encodePacked(starFirstPart, 'aqua', starLastPart));
    if (starSeed % 11 == 1)
      return string(abi.encodePacked(starFirstPart, 'white', starLastPart));
    return '';
  }

   
  function haveKey(uint256 tokenId) private pure returns (string memory) {
    uint256 keySeed = random("key", tokenId);
    string memory traitTypeJson = ', {"trait_type": "Key", "value": "';
    if (keySeed % 301 == 1)
      return string(abi.encodePacked(traitTypeJson, 'Rainbow Key"}'));
    if (keySeed % 161 == 1)
      return string(abi.encodePacked(traitTypeJson, 'Crystal Key"}'));  
    if (keySeed % 59 == 1)
      return string(abi.encodePacked(traitTypeJson, 'Gold Key"}'));  
    if (keySeed % 31 == 1)
      return string(abi.encodePacked(traitTypeJson, 'Silver Key"}'));  
    if (keySeed % 11 == 1)
      return string(abi.encodePacked(traitTypeJson, 'Jade Key"}'));  
    return string(abi.encodePacked(traitTypeJson, 'Copper Key"}'));  
  }

   
  function renderKey(uint256 tokenId) private pure returns (string memory) {
    string memory keyFirstPart = '<g transform="translate(267,63) scale(0.02,-0.02) rotate(135)" fill="';
    string memory keyLastPart = '" stroke="none"><path d="M832 1024q0 80-56 136t-136 56q-80 0-136-56t-56-136q0-42 19-83-41 19-83 19-80 0-136-56t-56-136q0-80 56-136t136-56q80 0 136 56t56 136q0 42-19 83 41-19 83-19 80 0 136 56t56 136zm851-704q0-17-49-66t-66-49q-9 0-28.5 16t-36.5 33q-17 17-38.5 40t-24.5 26l-96-96L1564 4q28-28 28-68 0-42-39-81t-81-39q-40 0-68 28L733 515Q557 384 368 384q-163 0-265.5 102.5T0 752q0 160 95 313t248 248q153 95 313 95 163 0 265.5-102.5T1024 1040q0-189-131-365l355-355 96 96q-3 3-26 24.5t-40 38.5q-17 17-33 36.5t-16 28.5q0 17 49 66t66 49q13 0 23-10 6-6 46-44.5t82-79.5q42-41 86.5-86t73-78q28.5-33 28.5-41z"/></g>';
    uint256 keySeed = random("key", tokenId);
    if (keySeed % 301 == 1)
      return string(abi.encodePacked('<defs><linearGradient id="rainbow" x1="100%" y1="100%"><stop offset="0%" stop-color="white" stop-opacity=".9"><animate attributeName="stop-color" values="white;red;orange;yellow;green;lightblue;lightpurple;white;" dur="7s" repeatCount="indefinite" /></stop></linearGradient></defs>', keyFirstPart, 'url(#rainbow)', keyLastPart));
    if (keySeed % 161 == 1)
      return string(abi.encodePacked(keyFirstPart, '#afcfff', keyLastPart));
    if (keySeed % 59 == 1)
      return string(abi.encodePacked(keyFirstPart, '#ffff33', keyLastPart));
    if (keySeed % 31 == 1)
      return string(abi.encodePacked(keyFirstPart, '#dddddd', keyLastPart));
    if (keySeed % 11 == 1)
      return string(abi.encodePacked(keyFirstPart, '#66ff66', keyLastPart));
    return string(abi.encodePacked(keyFirstPart, '#995500', keyLastPart));
  }

   
  function getDescription(uint256 tokenId) private view returns (string memory) {
    string memory description0 = string(abi.encodePacked('This is a keycard to launch [#', toString(tokenId), ' ', getRoomTheme(tokenId), ' ', getRoomType(tokenId),'](', string(abi.encodePacked(_roomBaseUrl, toString(tokenId))), ') with one click.'));
    string memory description1 = ' And check the linked ';
    uint256 link1Id = getAssetLink1(tokenId);
      if (link1Id > 0) {
        string memory link1description = string(abi.encodePacked('[#', toString(link1Id), ' ', getRoomTheme(link1Id), ' ', getRoomType(link1Id), '](', string(abi.encodePacked(_roomBaseUrl, toString(link1Id))) ,')'));
        uint256 link2Id = getAssetLink2(tokenId);
        if (link2Id > 0) {
          string memory link2description = string(abi.encodePacked('[#', toString(link2Id), ' ', getRoomTheme(link2Id), ' ', getRoomType(link2Id), '](', string(abi.encodePacked(_roomBaseUrl, toString(link2Id))) ,')'));
          if (link2Id > link1Id)
            return string(abi.encodePacked(description0, description1, link1description,' and ',link2description, '.'));
          else
            return string(abi.encodePacked(description0, description1, link2description,' and ',link1description, '.'));
        } else {
          return string(abi.encodePacked(description0, description1, link1description,'.'));
        }
      } else {
        return description0;
      }
    }

   
  function getBackgrounGradient(uint256 tokenId) private pure returns (string memory) {
    uint256 colorSeed = random("color", tokenId);
    if ( colorSeed % 7 == 3)
      return "black;red;gray;red;purple;black;";
    if ( colorSeed % 7 == 2)
      return "black;green;black;";
    if ( colorSeed % 7 == 1)
      return "black;blue;black;";
    if ( colorSeed % 7 == 4)
      return "black;lightblue;black;";
    if ( colorSeed % 7 == 5)
      return "black;red;purple;blue;black;";
    if ( colorSeed % 7 == 6)
      return "black;blue;purple;blue;black;";
    return "black;gray;red;purple;black;";
  }

   
  function haveLaser(uint256 tokenId) private pure returns (string memory) {
    uint256 laserSeed = random("laser", tokenId);
    string memory traitTypeJson = ', {"trait_type": "Laser", "value": "';
    if (laserSeed % 251 == 2)
      return string(abi.encodePacked(traitTypeJson, 'Dual Green Lasers"}'));
    if (laserSeed % 167 == 2)
      return string(abi.encodePacked(traitTypeJson, 'Dual Red Lasers"}'));
    if (laserSeed % 71 == 2)
      return string(abi.encodePacked(traitTypeJson, 'Green Laser"}'));
    if (laserSeed % 31 == 2)
      return string(abi.encodePacked(traitTypeJson, 'Red Laser"}'));
    return '';
  }

   
  function renderBackground(uint256 tokenId) private pure returns (string memory) {
    uint256 laserSeed = random("laser", tokenId);
    string memory attribPyramidLasers = '';
    bool dualLasers = false;
    bool singleLaser = false;
    string memory laserColor = 'red';

    if (laserSeed % 31 == 2) { 
      singleLaser = true;
      dualLasers = false;
      laserColor = 'red';
    }

    if (laserSeed % 71 == 2) { 
      singleLaser = true;
      laserColor = 'green';
    }

    if (laserSeed % 167 == 2) { 
      singleLaser = false;
      dualLasers = true;
      laserColor = 'red';
    }

    if (laserSeed % 251 == 2) { 
      singleLaser = false;
      dualLasers = true;
      laserColor = 'green';
    }

    string memory attribPyramidLasersFirstPart = string(abi.encodePacked('<g transform="translate(-154.5,-36)"><line x1="0" y1="0" x2="300" y2="300" stroke="', laserColor, '" stroke-width="1.5" stroke-opacity="1.0"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 300 300" to="360 300 300" dur="20s" repeatCount="indefinite" /></line>'));
    string memory attribPyramidLasersDoublePart = string(abi.encodePacked('<line x1="0" y1="0" x2="300" y2="300" stroke="', laserColor, '" stroke-width="1.5" stroke-opacity="1.0"><animateTransform attributeName="transform" attributeType="XML" type="rotate" from="5 300 300" to="365 300 300" dur="20s" repeatCount="indefinite" /></line>'));
    string memory attribPyramidLasersEndingPart = '</g>';

    if (singleLaser)
      attribPyramidLasers = string(abi.encodePacked(attribPyramidLasersFirstPart, attribPyramidLasersEndingPart));

    if (dualLasers)
      attribPyramidLasers = string(abi.encodePacked(attribPyramidLasersFirstPart, attribPyramidLasersDoublePart, attribPyramidLasersEndingPart));

    return string(abi.encodePacked('<g clip-path="url(#b)"><path fill="000000" d="M0 0h290v500H0z" /><path fill="url(#backgroundGradient)" d="M0 0h290v500H0z" /><g style="filter:url(#d);transform:scale(2.9);transform-origin:center top"><path fill="none" d="M0 0h290v500H0z" /><ellipse cx="50%" rx="180" ry="120" opacity=".95" /></g>', string(abi.encodePacked('<g><filter id="dpf"><feTurbulence type="turbulence" baseFrequency="0.', toString(random("fq", tokenId) % 4), '2" numOctaves="2" result="turbulence" /><feDisplacementMap in2="turbulence" in="SourceGraphic" scale="50" xChannelSelector="R" yChannelSelector="G" /></filter><circle cx="120" cy="-10" r="200" fill="url(#backgroundGradient)" opacity=".3" style="filter: url(#dpf)" /></g>')), '<g style="transform:translate(94px,264px)"><g style="transform:scale(.4,.4)" fill="url(#backgroundGradient)" stroke="rgba(255,255,255,1)"><path stroke-width="2.5" opacity=".5" d="m127.961 0-2.795 9.5v275.668l2.795 2.79 127.962-75.638z"/><path stroke-width="1.8" opacity=".85" d="M127.962 0 0 212.32l127.962 75.639V154.158z"/></g></g>', attribPyramidLasers, '</g>'));
  }

   
  function haveBasicAttributes(uint256 tokenId) private view returns (string memory) {
    string memory traitTypeJson = '{"trait_type": "';
    return string(abi.encodePacked(string(abi.encodePacked(traitTypeJson, 'Room Type", "value": "', getRoomType(tokenId), '"}, ')), string(abi.encodePacked(traitTypeJson, 'Room Theme", "value": "', getRoomTheme(tokenId), '"}')), getAssetLinks(tokenId)));
  }

   
  function tokenURI(uint256 tokenId) override public view returns (string memory) {
    require(_tokenIdCounter.current() >= tokenId && tokenId > 0, tokenIdInvalid);

     
    string memory tokenFullName = string(abi.encodePacked(getRoomTheme(tokenId), ' ', getRoomType(tokenId)));
    string memory cardInfo = string(abi.encodePacked('<g><text y="70" x="29" fill="#fff" font-family="monospace" font-weight="200" font-size="36">#',toString(tokenId),'</text><text y="115" x="28" fill="#fff" font-family="monospace" font-weight="200" font-size="22">',tokenFullName,'</text><text y="140" x="29" font-family="monospace" font-size="14" fill="#fff"><tspan fill="rgba(255,255,255,0.8)">Metaverse Club</tspan></text></g><g style="transform:translate(22px,444px)" clip-path="url(#e)"><rect width="247" height="26" rx="8" ry="8" fill="rgba(0,0,0,0.6)" /><text x="9" y="17" font-family="monospace" font-size="14" fill="#fff"><tspan fill="rgba(255,255,255,0.6)">',tokenFullName,': </tspan>', getRoomMessage(tokenId),'<animate attributeType="XML" attributeName="x" values="300;-300" dur="15s" repeatCount="indefinite" /></text></g>'));
    string memory svgExtra = string(abi.encodePacked(renderKey(tokenId), renderStar(tokenId)));
    string memory renderDefs = string(abi.encodePacked('<defs><linearGradient id="backgroundGradient" x1="100%" y1="100%"><stop offset="0%" stop-color="black" stop-opacity=".5"><animate attributeName="stop-color" values="', getBackgrounGradient(tokenId),'" dur="20s" repeatCount="indefinite" /></stop></linearGradient></defs><defs><filter id="c"><feImage result="p0" xlink:href="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nMjkwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI5MCA1MDAnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PHJlY3Qgd2lkdGg9JzI5MHB4JyBoZWlnaHQ9JzUwMHB4JyBmaWxsPScjZjY1YjVjJy8+PC9zdmc+" /></filter><filter id="d"><feGaussianBlur in="SourceGraphic" stdDeviation="', toString(random("sd", tokenId) % 50 + 10), '" /></filter><linearGradient id="a"><stop offset=".7" stop-color="#fff" /><stop offset=".95" stop-color="#fff" stop-opacity="0" /></linearGradient><clipPath id="b"><rect width="290" height="500" rx="42" ry="42" /></clipPath><clipPath id="e"><rect width="247" height="26" rx="8" ry="8"/></clipPath></defs>'));
    string memory outputSVG = string(abi.encodePacked('<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="290" height="500" viewBox="0 0 290 500">', renderDefs, renderBackground(tokenId), cardInfo, svgExtra, '</svg>'));

     
    string memory attributes = string(abi.encodePacked('"attributes": [{"trait_type": "Room Name", "value": "', tokenFullName, '"}, ', haveBasicAttributes(tokenId), haveStar(tokenId), haveKey(tokenId), haveLaser(tokenId), ']'));

     
    string memory basicInfo = string(abi.encodePacked('"name": "#', toString(tokenId), ' ', tokenFullName, '", "description": "', getDescription(tokenId),'", "external_url": "', string(abi.encodePacked(_roomBaseUrl, toString(tokenId))), '", '));
    string memory output = string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked('{', basicInfo, attributes,', "image": "data:image/svg+xml;base64,', Base64.encode(bytes(outputSVG)),'"}'))))));
    return output;
  }

  function toString(uint256 value) private pure returns (string memory) {
   
   

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

  constructor() ERC721("Metaverse Club", "MCLUB") Ownable() {}
}

 

pragma solidity ^0.8.0;

 
library Counters {
    struct Counter {
         
         
         
        uint256 _value;  
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

 




pragma solidity ^0.8.0;

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

 

pragma solidity ^0.8.0;

 
interface IERC721Receiver {
     
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 

pragma solidity ^0.8.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
