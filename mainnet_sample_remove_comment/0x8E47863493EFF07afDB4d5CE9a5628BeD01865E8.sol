 


 
 

pragma solidity ^0.8.0;

 
interface IERC165Upgradeable {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 
 

pragma solidity ^0.8.2;



 
abstract contract Initializable {
     
    uint8 private _initialized;

     
    bool private _initializing;

     
    event Initialized(uint8 version);

     
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

     
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

     
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

     
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

     
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

     
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

 
 

pragma solidity ^0.8.0;



 
interface IERC721Upgradeable is IERC165Upgradeable {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

     
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

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

 
 

pragma solidity ^0.8.0;


 
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

     
    uint256[50] private __gap;
}

 
 

pragma solidity ^0.8.0;




 
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

     
    uint256[50] private __gap;
}

 
 

pragma solidity ^0.8.0;



 
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
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



 
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 
 

pragma solidity ^0.8.0;










 
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

     
    string private _name;

     
    string private _symbol;

     
    mapping(uint256 => address) private _owners;

     
    mapping(address => uint256) private _balances;

     
    mapping(uint256 => address) private _tokenApprovals;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

     
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

     
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

     
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

     
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

     
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

     
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

     
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

     
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

         
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
             
             
             
             
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        owner = ERC721Upgradeable.ownerOf(tokenId);

         
        delete _tokenApprovals[tokenId];

        unchecked {
             
             
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

     
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

         
        delete _tokenApprovals[tokenId];

        unchecked {
             
             
             
             
             
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

     
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

     
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

     
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

     
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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

     
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

     
    function _beforeConsecutiveTokenTransfer(
        address from,
        address to,
        uint256,  
        uint96 size
    ) internal virtual {
        if (from != address(0)) {
            _balances[from] -= size;
        }
        if (to != address(0)) {
            _balances[to] += size;
        }
    }

     
    function _afterConsecutiveTokenTransfer(
        address,  
        address,  
        uint256,  
        uint96  
    ) internal virtual {}

     
    uint256[44] private __gap;
}

 
pragma solidity ^0.8.0;

contract VRFRequestIDBase {
   
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

   
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

 
 

pragma solidity ^0.8.0;




 
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

     
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

     
    uint256[49] private __gap;
}

 
 

pragma solidity ^0.8.0;



 
interface IERC2981Upgradeable is IERC165Upgradeable {
     
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

 
 

pragma solidity ^0.8.0;





 
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
     
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

     
    mapping(uint256 => uint256) private _ownedTokensIndex;

     
    uint256[] private _allTokens;

     
    mapping(uint256 => uint256) private _allTokensIndex;

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

     
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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

     
    function _beforeConsecutiveTokenTransfer(
        address,
        address,
        uint256,
        uint96 size
    ) internal virtual override {
         
         
        if (size > 0) {
            revert("ERC721Enumerable: consecutive transfers not supported");
        }
    }

     
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

     
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

     
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
         
         

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
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

     
    uint256[46] private __gap;
}

 
 

pragma solidity ^0.8.0;



 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _transferOwnership(_msgSender());
    }

     
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

 
pragma solidity ^0.8.0;





 
abstract contract VRFConsumerBase is VRFRequestIDBase {
   
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

   
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

   
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
     
     
     
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
     
     
     
     
     
     
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

   
   
   
  mapping(bytes32 => uint256)    
    private nonces;

   
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

   
   
   
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}
 

pragma solidity ^0.8.4;







contract CowardGambit is Initializable, OwnableUpgradeable {
    address public adminAddress;
    address public randomNumberAddress;
    address public SomAddress;
    address public ownerAddress;

    bool public isRandomNumber;
    uint256 public randomNumber;
    uint256 public constant DENOMINATOR = 100;

    bool public roundStarted = false;

    struct SOM {
        uint256 tokenId;
        uint256 state;
    }

    struct Round {
        uint256 roundId;
        uint256 deathPercent;
    }

    mapping(uint256 => Round) public rounds;
    
    SOM[] public joinItems;
    SOM[] public Coward;
    SOM[] public Mars;

    uint256 public currentRoundId = 0;
    uint256 public TimeLineID = 0;
    uint256 public ROUND_COUNT = 5;

    uint256 public MainWinner = 0;
    uint256 public CowardIndex = 0;
     
    uint256[] public CowardTokenIDs;
    bool[1001] public CowardFlg;
    bool[1001] public MarsFlg;
    bool public CowardHasWinner = true;
    uint256 public CowardWinner = 0;
    bool public CowardFinished = false;
    bool public MarsFinished = false;


    event setRandomNumber();

    function setSOMAddress(address _address) external onlySOM {
        SomAddress = _address;        
    }
    
    function numbersDrawn(
        uint256 _randomNumber
    )
        external
    {
        randomNumber = _randomNumber;
        isRandomNumber = true;
        emit setRandomNumber();
    }

    function initialize(
        address _randomNumberAddress,
        address _adminAddress
    ) public initializer {
        __Ownable_init();
        randomNumberAddress = _randomNumberAddress;
        adminAddress = _adminAddress;
        ownerAddress = msg.sender;
        for (uint256 i = 0; i < ROUND_COUNT; i++) {
            rounds[i + 1].roundId = i + 1;
            if(i == 0) rounds[i + 1].deathPercent = 20;
            if(i == 1) rounds[i + 1].deathPercent = 25;
            if(i == 2) rounds[i + 1].deathPercent = 33;
            if(i == 3) rounds[i + 1].deathPercent = 50;
            if(i == 4) rounds[i + 1].deathPercent = 75;
        }
    }

    modifier onlySOM() {
        require(
            adminAddress == msg.sender || ownerAddress == msg.sender || SomAddress == msg.sender, "RNG: Caller is not the SOM address"
        );
        _;
    }

    function setJoinItems(uint256 _tokenId, uint256 _state) external onlySOM {
        joinItems.push(SOM({
            tokenId: _tokenId,
            state: _state
        }));
    }

    function endRound() external onlySOM {
        require(currentRoundId <= ROUND_COUNT + 1, "Game Finished!");
         
        TimeLineID ++;
        updateCowardList();
        if(currentRoundId == 0) {
            isRandomNumber = false;
            MainWinner = 0;
            currentRoundId++;
            
            RandomGenerator(randomNumberAddress).requestRandomNumber();
        } else if(currentRoundId == 6) {
            uint256 index = randomNumber % joinItems.length;
            MainWinner = joinItems[index].tokenId;
            if(SOMFactory(SomAddress).getSOMarray(MainWinner) == 17) {
                SOMFactory(SomAddress).setSOMarray(MainWinner, 19);
            } else {
                SOMFactory(SomAddress).setSOMarray(MainWinner, 18);
            }
            joinItems[index] = joinItems[joinItems.length - 1];
            joinItems.pop();
            uint256 deathAmount = joinItems.length;
            for(uint256 i = 0; i < deathAmount; i ++) {
                uint256 dead_index = randomNumber % joinItems.length;
                if(SOMFactory(SomAddress).getSOMarray(joinItems[dead_index].tokenId) != 17) {
                    SOMFactory(SomAddress).setSOMarray(joinItems[dead_index].tokenId, 12);
                }
                joinItems[dead_index] = joinItems[joinItems.length - 1];
                joinItems.pop();
            }
            joinItems.push(SOM({
                tokenId: MainWinner,
                state: 1
            }));
        } else {
            uint256 deathAmount = uint256(joinItems.length * rounds[currentRoundId].deathPercent / DENOMINATOR);
            for (uint256 i = 0; i < deathAmount; i ++) {
                uint256 index = randomNumber % joinItems.length;
                if(currentRoundId == 1) SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 6);
                if(currentRoundId == 2) SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 5);
                if(currentRoundId == 3) {
                    if(i < deathAmount / 2) SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 8);
                    else SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 7);
                }
                if(currentRoundId == 4) {
                    if(i < deathAmount / 2) SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 9);
                    else SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 10);
                }
                if(currentRoundId == 5) {
                    if(i < deathAmount / 2) SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 3);
                    else SOMFactory(SomAddress).setSOMarray(joinItems[index].tokenId, 11);
                }
                joinItems[index] = joinItems[joinItems.length - 1];
                joinItems.pop();
            }

            currentRoundId ++;
        }
        roundStarted = false;
    }

    function setCoward(uint256 _tokenId) external {
        require(msg.sender == SOMFactory(SomAddress).ownerOf(_tokenId), "not yours");
        require(currentRoundId != 0, "Can't join Coward!");
        require(SOMFactory(SomAddress).getSOMarray(_tokenId) != 15, "Already Joined!");
        require(CowardFlg[_tokenId] == false, "Already joined!");
        CowardFlg[_tokenId] = true;
        CowardTokenIDs.push(_tokenId);
    }

    function updateCowardList() public {
        for(uint256 i = CowardIndex; i < CowardTokenIDs.length; i ++) {
            Coward.push(SOM({
                tokenId: CowardTokenIDs[i],
                state: 15
            }));
            SOMFactory(SomAddress).setSOMarray(CowardTokenIDs[i], 15);
            for (uint256 j = 0; j < joinItems.length; j ++) {
                if (joinItems[j].tokenId == CowardTokenIDs[i]) {
                    joinItems[j] = joinItems[joinItems.length - 1];
                    joinItems.pop();
                    break;
                }
            }
        }
        CowardIndex = CowardTokenIDs.length;
    }

    function setFinishCoward() external onlySOM {
        CowardFinished = true;
        if(Coward.length > 200) {
            CowardHasWinner = false;
        } else {
            uint256 index = randomNumber % Coward.length;
            CowardWinner = Coward[index].tokenId;
            SOMFactory(SomAddress).setSOMarray(CowardWinner, 16);
        }
    }

    function setMars(uint256 _tokenId) external {
        require(MarsFlg[_tokenId] == false, "Already joined!");
        MarsFlg[_tokenId] = true;
        uint256 state = SOMFactory(SomAddress).getSOMarray(_tokenId);
        require(msg.sender == SOMFactory(SomAddress).ownerOf(_tokenId), "not yours");
        require(state != 1 && state != 15 && currentRoundId == 6, "Can't join Mars' Gambit!");
        Mars.push(SOM({
            tokenId: _tokenId,
            state: state
        }));
    }

    function setFinishMars() external onlySOM {
        uint256 burnAmount = uint256(Mars.length * 90 / DENOMINATOR);
        MarsFinished = true;

        for (uint256 i = 0; i < burnAmount; i ++) {
            uint256 index = randomNumber % Mars.length;
                SOMFactory(SomAddress).Burn(Mars[index].tokenId);
                SOMFactory(SomAddress).setSOMarray(Mars[index].tokenId, 20);
                Mars[index] = Mars[Mars.length - 1];
                Mars.pop();
        }

        for (uint256 i = 0; i < Mars.length; i ++) {
            SOMFactory(SomAddress).setSOMarray(Mars[i].tokenId, 17);
            Mars[i].state = 17;
            joinItems.push(Mars[i]);
        }
    }

    function fetchCowardAmount() external view returns(uint256) {
        return Coward.length;
    }
    
    function fetchMarsAmount() external view returns(uint256) {
        return Mars.length;
    }

    function fetchTotalAliveAmount() external view returns(uint256) {
        return joinItems.length;
    }
}

 
pragma solidity ^0.8.6;







contract RandomGenerator is VRFConsumerBase, Ownable {
    using Address for address;

    bytes32 internal keyHash;
    uint256 internal fee;

    address public SOMAddress;
    address public CowardAddress;

    bytes32 currentRequestID;

    mapping(bytes32 => uint256) public requestToRandom;
    mapping(bytes32 => bool) public hasReturned;

    
    event newSOM(address SOM);

    
    event randomNumberArrived(
        bool arrived,
        uint256 randomNumber,
        bytes32 batchID
    );

    modifier onlySOM() {
        require(SOMAddress == msg.sender, "RNG: Caller is not the SOM address");
        _;
    }

     
    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    )
        VRFConsumerBase(
            _vrfCoordinator,
            _link
        )
    {
        keyHash = _keyHash;
        fee = _fee;
    }

     
    function requestRandomNumber() public returns (bytes32 requestID) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "RandomNumberConsumer: Not enough LINK - fill contract with faucet"
        );

        uint256 prevRandomNumber = requestToRandom[currentRequestID];

        emit randomNumberArrived(false, prevRandomNumber, currentRequestID);

        currentRequestID = requestRandomness(keyHash, fee);
        hasReturned[currentRequestID] = false;

        return currentRequestID;
    }

     
    function fulfillRandomness(bytes32 requestID, uint256 _randomness)
        internal
        override
    {
        requestToRandom[requestID] = _randomness;
        hasReturned[requestID] = true;
        CowardGambit(CowardAddress).numbersDrawn(
            _randomness
        );
        emit randomNumberArrived(true, _randomness, requestID);
    }

     
    function getVerifiedRandomNumber(bytes32 _reqeustId)
        public
        view
        onlySOM
        returns (uint256)
    {
        require(
            hasReturned[_reqeustId] == true,
            "RandomGenerator: Random number is not arrived yet"
        );
        return requestToRandom[_reqeustId];
    }

     
    function setSOMAddress(address _SOMAddr) public onlyOwner {
        require(
            _SOMAddr.isContract() == true,
            "RandomGenerator: This is not a Contract Address"
        );
        SOMAddress = _SOMAddr;
    }

    function setCowardAddress(address _address) public onlyOwner {
        require(
            _address.isContract() == true,
            "RandomGenerator: This is not a Contract Address"
        );
        CowardAddress = _address;
    }
}

 
 
pragma solidity ^0.8.4;









contract SOMFactory is Initializable, ERC721EnumerableUpgradeable, OwnableUpgradeable, IERC2981Upgradeable {
    address public CowardAddress;

    using Counters for Counters.Counter;

    bool private isInitialized;

    Counters.Counter private _tokenIds;

    struct SOM {
        uint256 tokenId;
        uint256 state;
    }
    
    address public adminAddress;
    uint256 public constant DENOMINATOR = 100;
    uint256 public TotalMintCount = 0;

     
    uint256 public MINT_PRICE = 2500000000000000;
     
    address public BankAddress;
    address public devAddress;

     
    uint256[1001] private Randomorder;
    mapping(address => uint256) public NFTcountPerAddress;
    mapping(address => bool) public WhiteList;

     
    string public _baseTokenURI;
    string public _unrevealedURI;

    bool public isRevealed = false;
    bool public PublicSaleStarted = false;

     
    mapping(uint256 => SOM) public soms;

    event SOMMinted();

    function initialize(
        string memory baseTokenURI_,
        string memory unrevealedURI_,
        address _adminAddress,
        address _BankAddress,
        address _devAddress,
        uint256[] memory randomorder_
    ) public initializer {
        __ERC721_init("Sons Of Mars", "SOM");
        __Ownable_init();
        _baseTokenURI = baseTokenURI_;
        _unrevealedURI = unrevealedURI_;
        isInitialized = true;
        adminAddress = _adminAddress;
        BankAddress = _BankAddress;
        devAddress = _devAddress;
        
        for (uint256 i = 0 ; i < randomorder_.length; i ++) {
            Randomorder[i] = randomorder_[i];
        }
    }

    
    modifier onlySOM() {
        require(
            adminAddress == msg.sender || owner() == msg.sender || CowardAddress == msg.sender, "RNG: Caller is not the SOM address"
        );
        _;
    }

    function isInitialize() external view returns(bool) {
        return isInitialized;
    }

     

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;  
    }

     
     
     

     
     
     

     
     
     

    function setWhiteList(address[] memory _addresses) external onlySOM {
        for(uint256 i = 0; i < _addresses.length; i ++) {
            WhiteList[_addresses[i]] = true;
        }
    }

    function setStartPublicMint() external onlySOM {
        PublicSaleStarted = true;
    }

    function setRevealed() external onlySOM {
        isRevealed = true;
        CowardGambit(CowardAddress).endRound();
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI;
        if(isRevealed == true) {
            currentBaseURI = _baseURI();
        }
        else {
            currentBaseURI = _unrevealedURI;
            return currentBaseURI;
        }
        
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, Strings.toString((Randomorder[tokenId - 1] - 1) * 19 + soms[tokenId].state), "")) : "";
    }

     

    function setCowardAddress(address _address) external onlySOM {
        CowardAddress = _address;
    }

    function getSOMarray(uint256 _tokenId) onlySOM public view returns (uint256) {
        return soms[_tokenId].state;
    }

    function setSOMarray(uint256 _tokenId, uint256 _state) onlySOM public {
        soms[_tokenId].state = _state;
    }

     

    function mint(uint256 _mintAmount) external payable {
        require(_mintAmount + totalSupply() < 1001, "Overflow amount!");
        if(PublicSaleStarted == false) {
            require(WhiteList[msg.sender] == true, "You didn't join WhiteList!");
        }

        uint256 restAmount = 0;
        if(msg.sender != adminAddress) {
            require(msg.value >= MINT_PRICE * _mintAmount, "Invalid Amount");
            require(NFTcountPerAddress[msg.sender] + _mintAmount < 4, "Can't mint over 3 NFTs!");
            restAmount = msg.value - MINT_PRICE * _mintAmount;
            payable(BankAddress).transfer(MINT_PRICE * _mintAmount * 95 / DENOMINATOR);
            payable(devAddress).transfer(MINT_PRICE * _mintAmount * 5 / DENOMINATOR);
            payable(msg.sender).transfer(restAmount);
        }

        for (uint256 k = 0; k < _mintAmount; k++) {

            _tokenIds.increment();
            uint256 tokenId = _tokenIds.current();
            _safeMint(msg.sender, tokenId);
            soms[tokenId] = SOM({
                tokenId: tokenId,
                state: 1
            });

            TotalMintCount ++;
            CowardGambit(CowardAddress).setJoinItems(soms[tokenId].tokenId, soms[tokenId].state);
            NFTcountPerAddress[msg.sender] ++;
        }

        emit SOMMinted();
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount)
    {
        uint256 payout = (_salePrice * 10) / DENOMINATOR;
         
        return (BankAddress, payout);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721EnumerableUpgradeable, IERC165Upgradeable)
    returns (bool)
    {
        return (
        interfaceId == type(IERC2981Upgradeable).interfaceId ||
        super.supportsInterface(interfaceId)
        );
    }

    function Burn(uint256 _tokenId) public {
        _burn(_tokenId);
    }
    
    function fetchSOMs() external view returns (SOM[] memory) {
        uint256 itemCount = _tokenIds.current(); 
        SOM[] memory items = new SOM[](itemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if(soms[i + 1].state == 20) continue;
            SOM memory currentItem = soms[i + 1];
            items[i] = currentItem;
        }
        return items;
    }
    function fetchMySOMs(address _address) external view returns(SOM[] memory) {

        uint256 itemCount = 0;
        for(uint256 i = 0; i < _tokenIds.current(); i++) {
            if(soms[i + 1].state == 20) continue;
            address owner = ownerOf(i + 1);
            if(owner == _address) itemCount ++;
        }

        SOM[] memory myItems = new SOM[](itemCount);
        
        itemCount = 0;
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            if(soms[i + 1].state == 20) continue;
            address owner = ownerOf(i + 1);
            if(owner == _address) {
                SOM memory item = soms[i + 1];
                myItems[itemCount ++] = item;
            }
        }
        return myItems;
    }
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

 
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

     
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

     
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

 
 

pragma solidity ^0.8.1;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        return account.code.length > 0;
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

 
 

pragma solidity ^0.8.1;

 
library AddressUpgradeable {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        return account.code.length > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

     
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                 
                 
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

     
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
         
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

 
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

 
 

pragma solidity ^0.8.0;



 
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

     
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

     
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

     
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

     
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

 
 

pragma solidity ^0.8.0;

 
interface IERC721ReceiverUpgradeable {
     
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 
 

pragma solidity ^0.8.0;

 
library MathUpgradeable {
    enum Rounding {
        Down,  
        Up,  
        Zero  
    }

     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a & b) + (a ^ b) / 2;
    }

     
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

     
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
             
             
             
            uint256 prod0;  
            uint256 prod1;  
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

             
            if (prod1 == 0) {
                return prod0 / denominator;
            }

             
            require(denominator > prod1);

             
             
             

             
            uint256 remainder;
            assembly {
                 
                remainder := mulmod(x, y, denominator)

                 
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

             
             

             
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                 
                denominator := div(denominator, twos)

                 
                prod0 := div(prod0, twos)

                 
                twos := add(div(sub(0, twos), twos), 1)
            }

             
            prod0 |= prod1 * twos;

             
             
             
            uint256 inverse = (3 * denominator) ^ 2;

             
             
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  
            inverse *= 2 - denominator * inverse;  

             
             
             
             
            result = prod0 * inverse;
            return result;
        }
    }

     
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

     
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

         
         
         
         
         
         
         
         
         
         
        uint256 result = 1 << (log2(a) >> 1);

         
         
         
         
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

     
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

     
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

     
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

     
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

     
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

     
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

     
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}