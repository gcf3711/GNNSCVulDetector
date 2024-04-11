 

 

 
pragma solidity ^0.8.7;



 
 
 
interface IERC721A {
     
    error ApprovalCallerNotOwnerNorApproved();

     
    error ApprovalQueryForNonexistentToken();

     
    error ApproveToCaller();

     
    error ApprovalToCurrentOwner();

     
    error BalanceQueryForZeroAddress();

     
    error MintToZeroAddress();

     
    error MintZeroQuantity();

     
    error OwnerQueryForNonexistentToken();

     
    error TransferCallerNotOwnerNorApproved();

     
    error TransferFromIncorrectOwner();

     
    error TransferToNonERC721ReceiverImplementer();

     
    error TransferToZeroAddress();

     
    error URIQueryForNonexistentToken();

    struct TokenOwnership {
         
        address addr;
         
        uint64 startTimestamp;
         
        bool burned;
    }

     
     

     
     
     

     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

     
     
     

     
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

     
     
     

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


 
 
 
interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 
contract ERC721A is IERC721A {
     
    uint256 private constant BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

     
    uint256 private constant BITPOS_NUMBER_MINTED = 64;

     
    uint256 private constant BITPOS_NUMBER_BURNED = 128;

     
    uint256 private constant BITPOS_AUX = 192;

     
    uint256 private constant BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

     
    uint256 private constant BITPOS_START_TIMESTAMP = 160;

     
    uint256 private constant BITMASK_BURNED = 1 << 224;
    
     
    uint256 private constant BITPOS_NEXT_INITIALIZED = 225;

     
    uint256 private constant BITMASK_NEXT_INITIALIZED = 1 << 225;

     
    uint256 private _currentIndex;

     
    uint256 private _burnCounter;

     
    string private _name;

     
    string private _symbol;

     
     
     
     
     
     
     
     
     
    mapping(uint256 => uint256) private _packedOwnerships;

     
     
     
     
     
     
     
    mapping(address => uint256) private _packedAddressData;

     
    mapping(uint256 => address) private _tokenApprovals;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

     
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

     
    function _nextTokenId() internal view returns (uint256) {
        return _currentIndex;
    }

     
    function totalSupply() public view virtual returns (uint256) {
         
         
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

     
    function _totalMinted() internal view returns (uint256) {
         
         
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

     
    function _totalBurned() internal view returns (uint256) {
        return _burnCounter;
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
         
         
         
        return
            interfaceId == 0x01ffc9a7 ||  
            interfaceId == 0x80ac58cd ||  
            interfaceId == 0x5b5e139f;  
    }

     
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return _packedAddressData[owner] & BITMASK_ADDRESS_DATA_ENTRY;
    }

     
    function _numberMinted(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> BITPOS_NUMBER_MINTED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

     
    function _numberBurned(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> BITPOS_NUMBER_BURNED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

     
    function _getAux(address owner) internal view returns (uint64) {
        return uint64(_packedAddressData[owner] >> BITPOS_AUX);
    }

     
    function _setAux(address owner, uint64 aux) internal {
        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
        assembly {  
            auxCasted := aux
        }
        packed = (packed & BITMASK_AUX_COMPLEMENT) | (auxCasted << BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

     
    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr)
                if (curr < _currentIndex) {
                    uint256 packed = _packedOwnerships[curr];
                     
                    if (packed & BITMASK_BURNED == 0) {
                         
                         
                         
                         
                         
                         
                         
                        while (packed == 0) {
                            packed = _packedOwnerships[--curr];
                        }
                        return packed;
                    }
                }
        }
        revert OwnerQueryForNonexistentToken();
    }

     
    function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {
        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> BITPOS_START_TIMESTAMP);
        ownership.burned = packed & BITMASK_BURNED != 0;
    }

     
    function _ownershipAt(uint256 index) internal view returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnerships[index]);
    }

     
    function _initializeOwnershipAt(uint256 index) internal {
        if (_packedOwnerships[index] == 0) {
            _packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

     
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

     
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
    }

     
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

     
    function _addressToUint256(address value) private pure returns (uint256 result) {
        assembly {
            result := value
        }
    }

     
    function _boolToUint256(bool value) private pure returns (uint256 result) {
        assembly {
            result := value
        }
    }

     
    function approve(address to, uint256 tokenId) public override {
        address owner = address(uint160(_packedOwnershipOf(tokenId)));
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                revert ApprovalCallerNotOwnerNorApproved();
            }

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSenderERC721A()) revert ApproveToCaller();

        _operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
            }
    }

     
    function _exists(uint256 tokenId) internal view returns (bool) {
        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex &&  
            _packedOwnerships[tokenId] & BITMASK_BURNED == 0;  
    }

     
    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

     
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

         
         
         
        unchecked {
             
             
             
             
             
            _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

             
             
             
             
             
            _packedOwnerships[startTokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                (_boolToUint256(quantity == 1) << BITPOS_NEXT_INITIALIZED);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (to.code.length != 0) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex < end);
                 
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex < end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

     
    function _mint(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

         
         
         
        unchecked {
             
             
             
             
             
            _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

             
             
             
             
             
            _packedOwnerships[startTokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                (_boolToUint256(quantity == 1) << BITPOS_NEXT_INITIALIZED);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

     
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSenderERC721A() == from ||
            isApprovedForAll(from, _msgSenderERC721A()) ||
            getApproved(tokenId) == _msgSenderERC721A());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

         
        delete _tokenApprovals[tokenId];

         
         
         
        unchecked {
             
            --_packedAddressData[from];  
            ++_packedAddressData[to];  

             
             
             
             
             
            _packedOwnerships[tokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                BITMASK_NEXT_INITIALIZED;

             
            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                 
                if (_packedOwnerships[nextTokenId] == 0) {
                     
                    if (nextTokenId != _currentIndex) {
                         
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

     
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSenderERC721A() == from ||
                isApprovedForAll(from, _msgSenderERC721A()) ||
                getApproved(tokenId) == _msgSenderERC721A());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

         
        delete _tokenApprovals[tokenId];

         
         
         
        unchecked {
             
             
             
             
             
             
            _packedAddressData[from] += (1 << BITPOS_NUMBER_BURNED) - 1;

             
             
             
             
             
            _packedOwnerships[tokenId] =
                _addressToUint256(from) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                BITMASK_BURNED | 
                BITMASK_NEXT_INITIALIZED;

             
            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                 
                if (_packedOwnerships[nextTokenId] == 0) {
                     
                    if (nextTokenId != _currentIndex) {
                         
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

         
        unchecked {
            _burnCounter++;
        }
    }

     
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try ERC721A__IERC721Receiver(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns (
            bytes4 retval
        ) {
            return retval == ERC721A__IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

     
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

     
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

     
    function _msgSenderERC721A() internal view virtual returns (address) {
        return msg.sender;
    }

     
    function _toString(uint256 value) internal pure returns (string memory ptr) {
        assembly {
             
             
             
             
            ptr := add(mload(0x40), 128)
             
            mstore(0x40, ptr)

             
            let end := ptr

             
             
             
             
            for { 
                 
                let temp := value
                 
                ptr := sub(ptr, 1)
                 
                mstore8(ptr, add(48, mod(temp, 10)))
                temp := div(temp, 10)
            } temp { 
                 
                temp := div(temp, 10)
            } {  
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
            }
            
            let length := sub(end, ptr)
             
            ptr := sub(ptr, 32)
             
            mstore(ptr, length)
        }
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


contract goblinzukiwtf is ERC721A, Ownable {
    using Address for address;
    using Strings for uint256;

    uint256 private maxTokens;

    mapping(uint256 => string) private customTokensURIs;

    bool private _saleEnabled = false;

    bool private _freeMintEnabled = false;

    uint256 private _maxMintForUser;

    uint256 private _maxFreeMints;

    uint256 private _currentFreeMints;
    
    string private _contractURI;
    string  private _baseTokenURI;

    address private serverAddress = address(0);
    
    mapping(bytes => bool) private signatureUsed;

    uint256 price = 1 ether;

    mapping (address => uint256) freeMints;

    
    constructor(uint256 maxTokens_, bool saleEnabled_, bool freeMintEnabled_, string memory baseURI_, uint256 maxMintForUser_, uint256 maxFreeMints_, uint256 price_) ERC721A("goblinzuki.wtf","goblinzuki") {
        maxTokens = maxTokens_;

        _saleEnabled = saleEnabled_;

        _freeMintEnabled = freeMintEnabled_;

        _baseTokenURI = baseURI_;

        _maxMintForUser = maxMintForUser_;

        _maxFreeMints = maxFreeMints_;

        price = price_;
    }

    function setServerAddress(address target) external onlyOwner {
        serverAddress = target;
    }

    function setMaxTokens(uint256 _maxTokens) external onlyOwner {
        maxTokens = _maxTokens;
    }

    function setMaxMintForUser(uint256 maxMintForUser_) external onlyOwner {
        _maxMintForUser = maxMintForUser_;
    }

    function setMaxFreeMints(uint256 maxFreeMints_) external onlyOwner {
        _maxFreeMints = maxFreeMints_;
    }

    function getMaxTokens()  external view returns(uint256) {
        return maxTokens;
    }
    
    function hasFreeMint(address target) public view returns(bool){
        return _freeMintEnabled && freeMints[target] < _maxMintForUser && _currentFreeMints < _maxFreeMints;
    }
    
    function freeMintEnabled() external view returns(bool){
        return _freeMintEnabled;
    }
    
    function freeMintOn() external onlyOwner{
        _freeMintEnabled = true;
    }
    
    function freeMintOff() external onlyOwner{
        _freeMintEnabled = false;
    }
    
    function saleEnabled() external view returns(bool){
        return _saleEnabled;
    }
    
    function saleOn() external onlyOwner{
        _saleEnabled = true;
    }
    
    function saleOff() external onlyOwner{
        _saleEnabled = false;
    }

    function totalSupply() public view override returns(uint256) {
        return maxTokens;
    }
    
    function setPrice(uint256 price_) external onlyOwner {
        price = price_;
    }


    function mintAdmin(address _to, uint256 count) external onlyOwner {
        require(tokensAvailable() >= count, "Max tokens reached");
        _safeMint(_to, count);
    }
    

    function mint(uint256 count) external payable {
        require(_saleEnabled, "Sale off");
        require(msg.value >= count*price, "Insufficient value to mint");
        require(tokensAvailable() >= count, "Max tokens reached");
        _safeMint(msg.sender, count);
    }


    function freeMint(uint256 count) external {
        require(_freeMintEnabled, "Free mint off");
        require(freeMints[msg.sender] + count <= _maxMintForUser, "You have max tokens");
        require(_currentFreeMints + count <= _maxFreeMints, "You have max tokens");
        _safeMint(msg.sender, count);
        freeMints[msg.sender] += count;
        _currentFreeMints += count;
    }
    

    function mintServer(uint256 count, string memory salt, bytes memory signature) external payable {
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.value, msg.sender, count, salt)));
        require(recoverSigner(message, signature) == serverAddress, "Error");
        signatureUsed[signature] = true;
        _safeMint(msg.sender, count);
    }

    function mintServer(uint256 count, string memory uri, string memory salt, bytes memory signature) external payable {
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.value, msg.sender, count, uri, salt)));
        require(recoverSigner(message, signature) == serverAddress, "Error");
        signatureUsed[signature] = true;
        for (uint256 i; i < count; i++) {
            customTokensURIs[_totalMinted() + i] = uri;
        }
        _safeMint(msg.sender, count);
    }


    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender || msg.sender == owner(), "You dont have this token");
        _burn(tokenId, false);
    }


    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
             
            r := mload(add(sig, 32))
             
            s := mload(add(sig, 64))
             
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }


    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }
    
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function setTokenURI(uint256 token, string memory uri) external onlyOwner {
        customTokensURIs[token] = uri;
    }

    function contractURI() public view returns (string memory) {
    	return _contractURI;
    }
    
    function withdraw() external onlyOwner
    {
        Address.sendValue(payable(msg.sender), address(this).balance);
    }

    function tokensAvailable() public view returns (uint256) {
        return maxTokens - _totalMinted();
    }

    function _baseURI() internal view override  returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _baseTokenURI = uri;
    }
    
    function setContractURI(string memory uri) external onlyOwner {
        _contractURI = uri;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if(bytes(customTokensURIs[tokenId]).length != 0) return customTokensURIs[tokenId];
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    function URI(uint256 tokenId) external view virtual returns (string memory) {
        return tokenURI(tokenId);
    }
}