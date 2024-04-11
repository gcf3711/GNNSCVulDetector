 

 

 

 


 

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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

 


 
 

pragma solidity ^0.8.4;

 
interface IERC721A {
     
    error ApprovalCallerNotOwnerNorApproved();

     
    error ApprovalQueryForNonexistentToken();

     
    error ApproveToCaller();

     
    error BalanceQueryForZeroAddress();

     
    error MintToZeroAddress();

     
    error MintZeroQuantity();

     
    error OwnerQueryForNonexistentToken();

     
    error TransferCallerNotOwnerNorApproved();

     
    error TransferFromIncorrectOwner();

     
    error TransferToNonERC721ReceiverImplementer();

     
    error TransferToZeroAddress();

     
    error URIQueryForNonexistentToken();

     
    error MintERC2309QuantityExceedsLimit();

     
    error OwnershipNotInitializedForExtraData();

     
     
     

    struct TokenOwnership {
         
        address addr;
         
        uint64 startTimestamp;
         
        bool burned;
         
        uint24 extraData;
    }

     
     
     

     
    function totalSupply() external view returns (uint256);

     
     
     

     
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

     
     
     

     
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}

 


 
 

pragma solidity ^0.8.4;


 
interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 
contract ERC721A is IERC721A {
     
    struct TokenApprovalRef {
        address value;
    }

     
     
     

     
    uint256 private constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

     
    uint256 private constant _BITPOS_NUMBER_MINTED = 64;

     
    uint256 private constant _BITPOS_NUMBER_BURNED = 128;

     
    uint256 private constant _BITPOS_AUX = 192;

     
    uint256 private constant _BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

     
    uint256 private constant _BITPOS_START_TIMESTAMP = 160;

     
    uint256 private constant _BITMASK_BURNED = 1 << 224;

     
    uint256 private constant _BITPOS_NEXT_INITIALIZED = 225;

     
    uint256 private constant _BITMASK_NEXT_INITIALIZED = 1 << 225;

     
    uint256 private constant _BITPOS_EXTRA_DATA = 232;

     
    uint256 private constant _BITMASK_EXTRA_DATA_COMPLEMENT = (1 << 232) - 1;

     
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

     
     
     
     
    uint256 private constant _MAX_MINT_ERC2309_QUANTITY_LIMIT = 5000;

     
     
    bytes32 private constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

     
     
     

     
    uint256 private _currentIndex;

     
    uint256 private _burnCounter;

     
    string private _name;

     
    string private _symbol;

     
     
     
     
     
     
     
     
     
     
    mapping(uint256 => uint256) private _packedOwnerships;

     
     
     
     
     
     
     
    mapping(address => uint256) private _packedAddressData;

     
    mapping(uint256 => TokenApprovalRef) private _tokenApprovals;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
     
     

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

     
     
     

     
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

     
    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

     
    function totalSupply() public view virtual override returns (uint256) {
         
         
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

     
    function _totalMinted() internal view virtual returns (uint256) {
         
         
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

     
    function _totalBurned() internal view virtual returns (uint256) {
        return _burnCounter;
    }

     
     
     

     
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return _packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

     
    function _numberMinted(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> _BITPOS_NUMBER_MINTED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

     
    function _numberBurned(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> _BITPOS_NUMBER_BURNED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

     
    function _getAux(address owner) internal view returns (uint64) {
        return uint64(_packedAddressData[owner] >> _BITPOS_AUX);
    }

     
    function _setAux(address owner, uint64 aux) internal virtual {
        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
         
        assembly {
            auxCasted := aux
        }
        packed = (packed & _BITMASK_AUX_COMPLEMENT) | (auxCasted << _BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

     
     
     

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
         
         
         
         
        return
            interfaceId == 0x01ffc9a7 ||  
            interfaceId == 0x80ac58cd ||  
            interfaceId == 0x5b5e139f;  
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

     
     
     

     
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

     
    function _ownershipOf(uint256 tokenId) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

     
    function _ownershipAt(uint256 index) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnerships[index]);
    }

     
    function _initializeOwnershipAt(uint256 index) internal virtual {
        if (_packedOwnerships[index] == 0) {
            _packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

     
    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr)
                if (curr < _currentIndex) {
                    uint256 packed = _packedOwnerships[curr];
                     
                    if (packed & _BITMASK_BURNED == 0) {
                         
                         
                         
                         
                         
                         
                         
                         
                         
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
        ownership.startTimestamp = uint64(packed >> _BITPOS_START_TIMESTAMP);
        ownership.burned = packed & _BITMASK_BURNED != 0;
        ownership.extraData = uint24(packed >> _BITPOS_EXTRA_DATA);
    }

     
    function _packOwnershipData(address owner, uint256 flags) private view returns (uint256 result) {
        assembly {
             
            owner := and(owner, _BITMASK_ADDRESS)
             
            result := or(owner, or(shl(_BITPOS_START_TIMESTAMP, timestamp()), flags))
        }
    }

     
    function _nextInitializedFlag(uint256 quantity) private pure returns (uint256 result) {
         
        assembly {
             
            result := shl(_BITPOS_NEXT_INITIALIZED, eq(quantity, 1))
        }
    }

     
     
     

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);

        if (_msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                revert ApprovalCallerNotOwnerNorApproved();
            }

        _tokenApprovals[tokenId].value = to;
        emit Approval(owner, to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId].value;
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSenderERC721A()) revert ApproveToCaller();

        _operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex &&  
            _packedOwnerships[tokenId] & _BITMASK_BURNED == 0;  
    }

     
    function _isSenderApprovedOrOwner(
        address approvedAddress,
        address owner,
        address msgSender
    ) private pure returns (bool result) {
        assembly {
             
            owner := and(owner, _BITMASK_ADDRESS)
             
            msgSender := and(msgSender, _BITMASK_ADDRESS)
             
            result := or(eq(msgSender, owner), eq(msgSender, approvedAddress))
        }
    }

     
    function _getApprovedSlotAndAddress(uint256 tokenId)
        private
        view
        returns (uint256 approvedAddressSlot, address approvedAddress)
    {
        TokenApprovalRef storage tokenApproval = _tokenApprovals[tokenId];
         
        assembly {
            approvedAddressSlot := tokenApproval.slot
            approvedAddress := sload(approvedAddressSlot)
        }
    }

     
     
     

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

         
        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
            if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();

        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

         
        assembly {
            if approvedAddress {
                 
                sstore(approvedAddressSlot, 0)
            }
        }

         
         
         
        unchecked {
             
            --_packedAddressData[from];  
            ++_packedAddressData[to];  

             
             
             
             
             
            _packedOwnerships[tokenId] = _packOwnershipData(
                to,
                _BITMASK_NEXT_INITIALIZED | _nextExtraData(from, to, prevOwnershipPacked)
            );

             
            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
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
        transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
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

     
     
     

     
    function _mint(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

         
         
         
        unchecked {
             
             
             
             
             
            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

             
             
             
             
             
            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            uint256 toMasked;
            uint256 end = startTokenId + quantity;

             
            assembly {
                 
                toMasked := and(to, _BITMASK_ADDRESS)
                 
                log4(
                    0,  
                    0,  
                    _TRANSFER_EVENT_SIGNATURE,  
                    0,  
                    toMasked,  
                    startTokenId  
                )

                for {
                    let tokenId := add(startTokenId, 1)
                } iszero(eq(tokenId, end)) {
                    tokenId := add(tokenId, 1)
                } {
                     
                    log4(0, 0, _TRANSFER_EVENT_SIGNATURE, 0, toMasked, tokenId)
                }
            }
            if (toMasked == 0) revert MintToZeroAddress();

            _currentIndex = end;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

     
    function _mintERC2309(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();
        if (quantity > _MAX_MINT_ERC2309_QUANTITY_LIMIT) revert MintERC2309QuantityExceedsLimit();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

         
        unchecked {
             
             
             
             
             
            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

             
             
             
             
             
            _packedOwnerships[startTokenId] = _packOwnershipData(
                to,
                _nextInitializedFlag(quantity) | _nextExtraData(address(0), to, 0)
            );

            emit ConsecutiveTransfer(startTokenId, startTokenId + quantity - 1, address(0), to);

            _currentIndex = startTokenId + quantity;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

     
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal virtual {
        _mint(to, quantity);

        unchecked {
            if (to.code.length != 0) {
                uint256 end = _currentIndex;
                uint256 index = end - quantity;
                do {
                    if (!_checkContractOnERC721Received(address(0), to, index++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (index < end);
                 
                if (_currentIndex != end) revert();
            }
        }
    }

     
    function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, '');
    }

     
     
     

     
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

     
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        if (approvalCheck) {
             
            if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
                if (!isApprovedForAll(from, _msgSenderERC721A())) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

         
        assembly {
            if approvedAddress {
                 
                sstore(approvedAddressSlot, 0)
            }
        }

         
         
         
        unchecked {
             
             
             
             
             
             
            _packedAddressData[from] += (1 << _BITPOS_NUMBER_BURNED) - 1;

             
             
             
             
             
            _packedOwnerships[tokenId] = _packOwnershipData(
                from,
                (_BITMASK_BURNED | _BITMASK_NEXT_INITIALIZED) | _nextExtraData(from, address(0), prevOwnershipPacked)
            );

             
            if (prevOwnershipPacked & _BITMASK_NEXT_INITIALIZED == 0) {
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

     
     
     

     
    function _setExtraDataAt(uint256 index, uint24 extraData) internal virtual {
        uint256 packed = _packedOwnerships[index];
        if (packed == 0) revert OwnershipNotInitializedForExtraData();
        uint256 extraDataCasted;
         
        assembly {
            extraDataCasted := extraData
        }
        packed = (packed & _BITMASK_EXTRA_DATA_COMPLEMENT) | (extraDataCasted << _BITPOS_EXTRA_DATA);
        _packedOwnerships[index] = packed;
    }

     
    function _extraData(
        address from,
        address to,
        uint24 previousExtraData
    ) internal view virtual returns (uint24) {}

     
    function _nextExtraData(
        address from,
        address to,
        uint256 prevOwnershipPacked
    ) private view returns (uint256) {
        uint24 extraData = uint24(prevOwnershipPacked >> _BITPOS_EXTRA_DATA);
        return uint256(_extraData(from, to, extraData)) << _BITPOS_EXTRA_DATA;
    }

     
     
     

     
    function _msgSenderERC721A() internal view virtual returns (address) {
        return msg.sender;
    }

     
    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
             
             
             
             
            str := add(mload(0x40), 0x80)
             
            mstore(0x40, str)

             
            let end := str

             
             
             
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                 
                 
                mstore8(str, add(48, mod(temp, 10)))
                 
                temp := div(temp, 10)
                 
                if iszero(temp) { break }
            }

            let length := sub(end, str)
             
            str := sub(str, 0x20)
             
            mstore(str, length)
        }
    }
}

 



pragma solidity ^0.8.0;








contract gogogo is ERC721A, Ownable, ReentrancyGuard {
	using Strings for uint256;

    string private baseTokenURI = "ipfs://QmNLiNP7UvqcM8eLxC6uHg6uFkTJP8mTACnUyx5LQSpdtF";
	uint256 public cost = 0.0069 ether;
	uint256 public maxSupply = 4200;
    uint256 public maxFreeSupply = 1000;
    uint256 public freePerWallet = 2;
	uint256 public maxMint = 10;
	bool public status = false;

    mapping(address => uint) public mintedByAddress;

	constructor() ERC721A("googoogog", "googoog") {}

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function mint(uint256 _count) external payable {
        uint256 supply = totalSupply();
        uint256 _cost = getCost(msg.sender, _count);

        require(msg.sender == tx.origin, "No contracts!");
        require(status,  "Not yet");
        require(supply + _count <= maxSupply, "Would excced supply");
        require(_count <= maxMint, "Too many");
        require(msg.value == _cost, "Ether sent is incorrect");

        mintedByAddress[msg.sender] += _count;
        _safeMint(msg.sender, _count);
    }

    function getCost (address _address, uint256 _count) public view returns (uint256) {
        uint256 _mintedByAddress = mintedByAddress[_address];
        bool _canClaim = canClaim(_address);

        if ( _canClaim ) {
            if (_count <= freePerWallet - _mintedByAddress) {
                return 0;
            } else {
                return cost * (_count - (freePerWallet - _mintedByAddress));
            }
        } else {
                return cost * _count;
        }
    }

	function gift(uint _mintAmount, address recipient) external onlyOwner{
		require( totalSupply() + _mintAmount <= maxSupply, "Too many" );
  		_safeMint(recipient, _mintAmount);
	}
	
    function canClaim(address _wallet) public view returns (bool) {
        return(mintedByAddress[_wallet] < freePerWallet && totalSupply() < maxFreeSupply);
    }

	function setCost(uint256 _newCost) public onlyOwner {
	    cost = _newCost;
	}

	function setmaxFreeSupply(uint256 _newMaxFreeSupply) public onlyOwner {
	    maxFreeSupply = _newMaxFreeSupply;
	}

    function setFreePerWallet(uint256 _newFreePerWallet) public onlyOwner {
	    freePerWallet = _newFreePerWallet;
	}
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_baseURI(), _tokenId.toString(), ".json"));
    }
	
	function flipSaleStatus() public onlyOwner {
	    status = !status;
	}

    function withdraw(address payable recipient)
        external
        onlyOwner
        nonReentrant
    {
        uint256 balance = address(this).balance;
        (bool success, ) = recipient.call{value: balance}("");
        require(success, "-Withdraw failed-");
    }

}