 
pragma abicoder v2;


 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity >=0.6.2 <0.8.0;



 
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

 
pragma solidity ^0.7.6;


abstract contract StringUpper {
    function _upper(bytes1 _b1) internal pure returns (bytes1) {
        if (_b1 >= 0x61 && _b1 <= 0x7A) {
            return bytes1(uint8(_b1) - 32);
        }

        return _b1;
    }

    function upper(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _upper(_baseBytes[i]);
        }
        return string(_baseBytes);
    }
}

 

pragma solidity >=0.6.0 <0.8.0;



 
abstract contract ERC165 is IERC165 {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
         
         
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

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC721Enumerable is IERC721 {

     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC721Metadata is IERC721 {

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

 

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
 
pragma solidity ^0.7.6;




abstract contract DenyList is StringUpper {
    mapping (string => bool) denyList;

    function addDenyList (string[] memory _words) public virtual {
        for(uint index = 0; index < _words.length; index+=1) {
            denyList[upper(_words[index])] = true;
            emit AddedDenyList(_words[index]);
        }
    }

    function removeDenyList (string[] memory _words) public virtual {
        for(uint index = 0; index < _words.length; index+=1) {
            denyList[upper(_words[index])] = false;
            emit RemovedDenyList(_words[index]);
        }
    }

    function inDenyList(string memory _word) public view virtual returns (bool) {
        return bool(denyList[upper(_word)]);
    }

    event AddedDenyList(string _word);
    event RemovedDenyList(string _word);
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
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

 

pragma solidity >=0.6.0 <0.8.0;













 
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
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

     
    mapping (uint256 => string) private _tokenURIs;

     
    string private _baseURI;

     
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

     
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

     
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

     
    constructor (string memory name_, string memory symbol_) public {
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

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

         
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
         
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
         
        return string(abi.encodePacked(base, tokenId.toString()));
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

         
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

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

     
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
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

     
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);  
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

 
pragma solidity ^0.7.6;








contract NameTag is ERC721, Ownable, StringUpper, DenyList {

    using SafeMath for uint256;

    struct Wave {
        uint256 limit;
        uint256 startTime;
    }

    Wave[] waves;

     
    uint8 private _currentWaveIndex = 0;

    mapping(uint256 => string) tokenNames;
    mapping(string => uint256) names;

    string private _defaultMetadata;
    string private _defaultNamedMetadata;

    uint8 private _tokenAmountBuyLimit;
    uint256 private _price;
    uint256 private _metadataFee;
    address private _metadataRole;
    mapping(uint256 => string) private _tokenURIs;

    event NameChanged(uint256 indexed tokenId, string from, string to);

    constructor(string memory name_, string memory symbol_, uint256 price_, uint256 metadataFee_, uint8 tokenAmountBuyLimit_) ERC721(name_, symbol_) {
        _price = price_;
        _metadataFee = metadataFee_;
        _tokenAmountBuyLimit = tokenAmountBuyLimit_;

        _metadataRole = msg.sender;

        waves.push(Wave(2500, 0));
        waves.push(Wave(5000, 0));
        waves.push(Wave(7500, 0));
        waves.push(Wave(10000, 0));
        waves.push(Wave(type(uint256).max, 0));
    }

    function currentWaveIndex() public view virtual returns (uint8) {
        return _currentWaveIndex;
    }

    function currentLimit() public view virtual returns (uint256) {
        return waves[_currentWaveIndex].limit;
    }

    function currentWave() public view virtual returns (uint256, uint256) {
        return (waves[_currentWaveIndex].limit, waves[_currentWaveIndex].startTime);
    }

    function waveByIndex(uint8 waveIndex_) public view virtual returns (uint256, uint256) {
        require(waveIndex_ >= 0 && waveIndex_ < waves.length);
        return (waves[waveIndex_].limit, waves[waveIndex_].startTime);
    }

    function price() public view virtual returns (uint256) {
        return _price;
    }

    function metadataFee() public view virtual returns (uint256) {
        return _metadataFee;
    }

    function defaultMetadata() public view virtual returns (string memory) {
        return _defaultMetadata;
    }

    function defaultNamedMetadata() public view virtual returns (string memory) {
        return _defaultNamedMetadata;
    }

    function tokenAmountBuyLimit() public view virtual returns (uint8) {
        return _tokenAmountBuyLimit;
    }

    function metadataRole() public view virtual returns (address) {
        return _metadataRole;
    }

    function changeMetadataRole(address newAddress) public virtual onlyOwner {
        require(newAddress != address(0));
        _metadataRole = newAddress;
    }

    function setWaveStartTime(uint8 waveIndex_, uint256 startTime_) public virtual onlyOwner {
        require(waveIndex_ >= 0 && waveIndex_ < waves.length);

        require(startTime_ != 0);
        require(block.timestamp <= startTime_);

        uint256 time = waves[waveIndex_].startTime;
        require(time == 0 || time > block.timestamp);
        waves[waveIndex_].startTime = startTime_;
    }

    function setPrice(uint256 price_) public virtual onlyOwner {
        require(price_ > 0);
        _price = price_;
    }

    function setMetadataFee(uint256 metadataFee_) public virtual onlyOwner {
        require(metadataFee_ >= 0);
        _metadataFee = metadataFee_;
    }

    function setDefaultMetadata(string memory metadata_) public virtual onlyOwner {
        _defaultMetadata = metadata_;
    }

    function setDefaultNamedMetadata(string memory metadata_) public virtual onlyOwner {
        _defaultNamedMetadata = metadata_;
    }

    function setTokenAmountBuyLimit(uint8 tokenAmountBuyLimit_) public virtual onlyOwner {
        require(tokenAmountBuyLimit_ > 0);
        _tokenAmountBuyLimit = tokenAmountBuyLimit_;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        _setBaseURI(baseURI_);
    }

    function withdraw(address payable wallet, uint256 amount) external onlyOwner {
        require(amount <= address(this).balance);
        wallet.transfer(amount);
    }

    function addDenyList(string[] memory _words) public override onlyOwner {
        super.addDenyList(_words);
    }

    function removeDenyList(string[] memory _words) public override onlyOwner {
        super.removeDenyList(_words);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal override virtual {
        require(_exists(tokenId), "NT: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _preValidatePurchase() internal view {
        uint256 time = waves[currentWaveIndex()].startTime;
        require(time != 0 && block.timestamp >= time, "NT: Current wave has not started yet");
        require(msg.sender != address(0));
        require(msg.value >= price(), "NT: Insufficient funds");
    }

    function _getTokenAmount(uint256 _weiAmount) internal returns (uint256) {
        if (currentWaveIndex() < waves.length - 1) {
            uint256 amount = _weiAmount.div(price());
            uint256 toNextLimitAmount = currentLimit().sub(totalSupply());

            if (amount >= toNextLimitAmount) {
                _currentWaveIndex += 1;
                return toNextLimitAmount;
            }
            return amount;
        }

        return _weiAmount.div(price());
    }

    function _processPurchaseToken(address recipient) internal returns (uint256) {
        uint256 newItemId = totalSupply().add(1);
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function validate(string memory name) internal pure returns (bool, string memory) {
        bytes memory b = bytes(name);
        if (b.length == 0) return (false, '');
        if (b.length > 36) return (false, '');

        bytes memory bUpperName = new bytes(b.length);

        bool prevSpace = false;
        for (uint i; i < b.length; i++) {
            bytes1 char = b[i];
            if (char == 0x20) {  
                if (i == 0 || i == b.length - 1 || prevSpace) {
                    return (false, '');
                }

                prevSpace = true;
            } else {
                if (
                    !(char >= 0x30 && char <= 0x39) &&  
                    !(char >= 0x41 && char <= 0x5A) &&  
                    !(char >= 0x61 && char <= 0x7A)  
                ) {
                    return (false, '');
                }
                prevSpace = false;
            }
            bUpperName[i] = _upper(char);
        }

        return (true, string(bUpperName));
    }

    function _setName(uint256 _token, string memory _name) internal returns (bool) {
        require(msg.sender != address(0));

        if (msg.sender != ownerOf(_token)) {
            return false;
        }

        return _changeTokenName(_token, _name);
    }

    function setNames(uint256[] memory _tokens, string[] memory _names) public payable returns (bool[] memory) {
        require(_tokens.length == _names.length);

        uint256 weiAmount = msg.value;
        bool[] memory statuses = new bool[](_tokens.length);
        bool fullStatus = false;
        for (uint index = 0; index < _tokens.length; index += 1) {
            bool hasName = bytes(getTokenName(_tokens[index])).length > 0;
            statuses[index] = _setName(_tokens[index], _names[index]);

            if (hasName && statuses[index]) {
                require(weiAmount >= metadataFee(), "NT: Insufficient fee funds");
                weiAmount -= metadataFee();

                _setTokenURI(_tokens[index], '');
            }

            if (!fullStatus && statuses[index]) {
                fullStatus = statuses[index];
            }
        }

        require(fullStatus);  

        return statuses;
    }

    function setMetadata(uint256 _token, string memory _metadata) public {
        require(msg.sender == metadataRole());
        _setTokenURI(_token, _metadata);
    }

    function setMetadataList(uint256[] memory _tokens, string[] memory _metadata) public {
        require(msg.sender == metadataRole());

        require(_tokens.length == _metadata.length);
        for (uint index = 0; index < _tokens.length; index += 1) {
            _setTokenURI(_tokens[index], _metadata[index]);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "NT: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        if (bytes(getTokenName(tokenId)).length > 0) {
            return string(abi.encodePacked(base, defaultNamedMetadata()));
        }
        return string(abi.encodePacked(base, defaultMetadata()));
    }

    function getByName(string memory name) public view virtual returns (uint256) {
        return names[upper(name)];
    }

    function getTokenName(uint256 tokenId) public view virtual returns (string memory) {
        return tokenNames[tokenId];
    }

    function _changeTokenName(uint256 tokenId, string memory _name) internal virtual returns(bool){
        require(_exists(tokenId), "NT: Name set of nonexistent token");

        bool status;
        string memory upperName;
        (status, upperName) = validate(_name);
        if (status == false || names[upperName] != 0 || denyList[upperName]) {
            return false;
        }

        string memory oldName = getTokenName(tokenId);
        string memory oldUpperName = upper(oldName);
        names[oldUpperName] = 0;
        tokenNames[tokenId] = _name;
        names[upperName] = tokenId;

        emit NameChanged(tokenId, oldName, _name);
        return true;
    }

    function _buyTokens() internal returns(uint256) {
        _preValidatePurchase();
        uint256 tokensAmount = _getTokenAmount(msg.value);
        require(tokensAmount <= tokenAmountBuyLimit(), "NT: Limited amount of tokens");
        return tokensAmount;
    }

    function buyNamedTokens(string[] memory _names) external payable returns (uint256[] memory) {
        uint256 tokensAmount = _buyTokens();

        uint256[] memory tokens = new uint256[](tokensAmount);

        for (uint index = 0; index < tokensAmount; index += 1) {
            tokens[index] = _processPurchaseToken(msg.sender);

            if (index < _names.length) {
                require(_setName(tokens[index], _names[index]), "NT: Name cannot be assigned");
            }
        }

        return tokens;
    }

    function buyTokens() external payable returns (uint256[] memory) {
        uint256 tokensAmount = _buyTokens();

        uint256[] memory tokens = new uint256[](tokensAmount);

        for (uint index = 0; index < tokensAmount; index += 1) {
            tokens[index] = _processPurchaseToken(msg.sender);
        }

        return tokens;
    }

    function buyNamedToken(string memory _name) external payable returns (uint256) {
        _preValidatePurchase();

        uint256 token = _processPurchaseToken(msg.sender);
        require(_setName(token, _name), "NT: Name cannot be assigned");
        return token;
    }

    function buyToken() external payable returns (uint256) {
        _preValidatePurchase();

        return _processPurchaseToken(msg.sender);
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

 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
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
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}
