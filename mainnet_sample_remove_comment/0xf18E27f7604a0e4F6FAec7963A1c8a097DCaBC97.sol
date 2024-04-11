 


 
 
 

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



 
interface IERC721AQueryable is IERC721A {
     
    error InvalidQueryRange();

     
    function explicitOwnershipOf(uint256 tokenId) external view returns (TokenOwnership memory);

     
    function explicitOwnershipsOf(uint256[] memory tokenIds) external view returns (TokenOwnership[] memory);

     
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view returns (uint256[] memory);

     
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 
 

pragma solidity ^0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
 
 
 

pragma solidity ^0.8.4;




 
abstract contract ERC721AQueryable is ERC721A, IERC721AQueryable {
     
    function explicitOwnershipOf(uint256 tokenId) public view virtual override returns (TokenOwnership memory) {
        TokenOwnership memory ownership;
        if (tokenId < _startTokenId() || tokenId >= _nextTokenId()) {
            return ownership;
        }
        ownership = _ownershipAt(tokenId);
        if (ownership.burned) {
            return ownership;
        }
        return _ownershipOf(tokenId);
    }

     
    function explicitOwnershipsOf(uint256[] calldata tokenIds)
        external
        view
        virtual
        override
        returns (TokenOwnership[] memory)
    {
        unchecked {
            uint256 tokenIdsLength = tokenIds.length;
            TokenOwnership[] memory ownerships = new TokenOwnership[](tokenIdsLength);
            for (uint256 i; i != tokenIdsLength; ++i) {
                ownerships[i] = explicitOwnershipOf(tokenIds[i]);
            }
            return ownerships;
        }
    }

     
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view virtual override returns (uint256[] memory) {
        unchecked {
            if (start >= stop) revert InvalidQueryRange();
            uint256 tokenIdsIdx;
            uint256 stopLimit = _nextTokenId();
             
            if (start < _startTokenId()) {
                start = _startTokenId();
            }
             
            if (stop > stopLimit) {
                stop = stopLimit;
            }
            uint256 tokenIdsMaxLength = balanceOf(owner);
             
             
            if (start < stop) {
                uint256 rangeLength = stop - start;
                if (rangeLength < tokenIdsMaxLength) {
                    tokenIdsMaxLength = rangeLength;
                }
            } else {
                tokenIdsMaxLength = 0;
            }
            uint256[] memory tokenIds = new uint256[](tokenIdsMaxLength);
            if (tokenIdsMaxLength == 0) {
                return tokenIds;
            }
             
             
            TokenOwnership memory ownership = explicitOwnershipOf(start);
            address currOwnershipAddr;
             
             
            if (!ownership.burned) {
                currOwnershipAddr = ownership.addr;
            }
            for (uint256 i = start; i != stop && tokenIdsIdx != tokenIdsMaxLength; ++i) {
                ownership = _ownershipAt(i);
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    tokenIds[tokenIdsIdx++] = i;
                }
            }
             
            assembly {
                mstore(tokenIds, tokenIdsIdx)
            }
            return tokenIds;
        }
    }

     
    function tokensOfOwner(address owner) external view virtual override returns (uint256[] memory) {
        unchecked {
            uint256 tokenIdsIdx;
            address currOwnershipAddr;
            uint256 tokenIdsLength = balanceOf(owner);
            uint256[] memory tokenIds = new uint256[](tokenIdsLength);
            TokenOwnership memory ownership;
            for (uint256 i = _startTokenId(); tokenIdsIdx != tokenIdsLength; ++i) {
                ownership = _ownershipAt(i);
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    tokenIds[tokenIdsIdx++] = i;
                }
            }
            return tokenIds;
        }
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



 
interface IERC721 is IERC165 {
     
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









contract The313RABBIT is ERC721AQueryable, Ownable, ReentrancyGuard {
    mapping(uint256 => uint256) public status;

    mapping(uint256 => bool) public returned;

    mapping(uint256 => bool) public passUsed;

    mapping(address => uint256) public wlMined;

    mapping(address => uint256) public publicMined;

    string public baseURI;

    string public defaultURI;

    uint256 public sleepReturnTime;

    IERC20 public USDT;

    uint256 public returnUSDTAmount;

    IERC721Enumerable public littelMamiPASS;

    uint256 public publicPrice;

    uint256 public wlPrice;

    uint256 public PASSPrice;

    uint256 public maxSupply;

    bytes32 public wlRoot;

    uint256 public maxWlSupply;

    uint256 public maxPASSSupply;

    uint256 public wlNum;

    uint256 public PASSNum;

    uint256 public PASSStartTime;

    uint256 public PASSEndTime;

    uint256 public wlStartTime;

    uint256 public wlEndTime;

    uint256 public publicStartTime;

    uint256 public publicEndTime;

    uint256 public maxPublicMint;

    uint256 public maxWlMint;

    uint256 public partnerPrice;

    bytes32 public partnerRoot;

    bool public turnSleep;

    using Strings for uint256;

    event RemoveSleep(uint256 indexed tokenId);

    event ToggleSleep(uint256 indexed tokenId, uint256 startTime);

    constructor() public ERC721A("313 RABBIT", "313 RABBIT") {
        publicPrice = 0.3 ether;
        wlPrice = 0.27 ether;
        partnerPrice = 0.24 ether;
        PASSPrice = 0.24 ether;
        maxSupply = 666;
        maxWlSupply = 166;
        maxPASSSupply = 300;
        maxPublicMint = 2;
        maxWlMint = 1;
        PASSStartTime = 1664713800;
        PASSEndTime = 1664886600;
        wlStartTime = 1664713800;
        wlEndTime = 1664886600;
        publicStartTime = 1664886600;
        publicEndTime = 1665318600;
        littelMamiPASS = IERC721Enumerable(
            0x6F555695B057c081F0A0f7c1d1a854EF7e2FEAa2
        );
        USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        returnUSDTAmount = 0;
        sleepReturnTime = 60 days;
        defaultURI = "ipfs://bafkreidxgd6vbljc5s436zxub3iarcntpzzayiicotzvkevkrn4tcdi52u";
    }

    function adminMint(address _address, uint256 _num) external onlyOwner {
        mint(_address, _num);
    }

    function adminMintBatch(
        address[] calldata _address,
        uint256[] calldata _num
    ) external onlyOwner {
        require(_address.length == _num.length);
        for (uint256 i = 0; i < _address.length; i++) {
            mint(_address[i], _num[i]);
        }
    }

    function withdrawETH(address payable _to) external onlyOwner {
        (bool success, ) = _to.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function withdrawToken(IERC20 _token, address _to) external onlyOwner {
        _token.transfer(_to, _token.balanceOf(address(this)));
    }

    function setSleep(uint256 _sleepReturnTime, uint256 _returnUSDTAmount)
        external
        onlyOwner
    {
        sleepReturnTime = _sleepReturnTime;
        returnUSDTAmount = _returnUSDTAmount;
    }

    function setReturnAmount(uint256 _returnUSDTAmount) external onlyOwner {
        returnUSDTAmount = _returnUSDTAmount;
    }

    function setContract(IERC721Enumerable _littelMamiPASS, IERC20 _USDT)
        external
        onlyOwner
    {
        littelMamiPASS = _littelMamiPASS;
        USDT = _USDT;
    }

    function setMaxMint(uint256 _maxPublicMint, uint256 _maxWlMint)
        external
        onlyOwner
    {
        maxPublicMint = _maxPublicMint;
        maxWlMint = _maxWlMint;
    }

    function setRoot(bytes32 _wlRoot, bytes32 _partnerRoot) external onlyOwner {
        wlRoot = _wlRoot;
        partnerRoot = _partnerRoot;
    }

    function setMaxSupply(uint256 _maxPASSSupply, uint256 _maxWlSupply)
        external
        onlyOwner
    {
        maxPASSSupply = _maxPASSSupply;
        maxWlSupply = _maxWlSupply;
    }

    function setTime(
        uint256 _PASSStartTime,
        uint256 _PASSEndTime,
        uint256 _wlStartTime,
        uint256 _wlEndTime,
        uint256 _publicStartTime,
        uint256 _publicEndTime
    ) external onlyOwner {
        PASSStartTime = _PASSStartTime;
        PASSEndTime = _PASSEndTime;
        wlStartTime = _wlStartTime;
        wlEndTime = _wlEndTime;
        publicStartTime = _publicStartTime;
        publicEndTime = _publicEndTime;
    }

    function setPrice(
        uint256 _publicPrice,
        uint256 _wlPrice,
        uint256 _PASSPrice,
        uint256 _partnerPrice
    ) external onlyOwner {
        publicPrice = _publicPrice;
        wlPrice = _wlPrice;
        PASSPrice = _PASSPrice;
        partnerPrice = _partnerPrice;
    }

     
    function removeSleep(uint256 _tokenId) external onlyOwner {
        status[_tokenId] = 0;
        emit RemoveSleep(_tokenId);
    }

    function turnToggleSleep(bool _turnSleep) external onlyOwner {
        turnSleep = _turnSleep;
    }

    function toggleSleep(uint256 _tokenId) external {
        require(
            ownerOf(_tokenId) == _msgSender(),
            "313 RABBIT : Not the owner"
        );
        require(turnSleep, "313 RABBIT : Sleep function is not open yet");
        if (status[_tokenId] == 0) {
            status[_tokenId] = block.timestamp;
            emit ToggleSleep(_tokenId, block.timestamp);
        } else {
            if (
                block.timestamp - status[_tokenId] >= sleepReturnTime &&
                !returned[_tokenId]
            ) {
                USDT.transfer(_msgSender(), returnUSDTAmount);
                returned[_tokenId] = true;
            }
            status[_tokenId] = 0;
            emit ToggleSleep(_tokenId, 0);
        }
    }

    function PASSMint(uint256 _num) external payable {
        require(
            block.timestamp >= PASSStartTime && block.timestamp <= PASSEndTime,
            "313 RABBIT : Not at mint time"
        );
        require(
            msg.value >= PASSPrice * _num,
            "313 RABBIT : Too little ether sent"
        );

        uint256 holdNum = littelMamiPASS.balanceOf(_msgSender());
        require(holdNum > 0, "313 RABBIT : HoldNum is zero");
        require(
            _num > 0 && _num <= holdNum,
            "313 RABBIT : Num must greater than 0 and lower than holdNum"
        );
        uint256 mintNum = 0;
        for (uint256 i = 0; i < holdNum; i++) {
            if (mintNum == _num) break;
            uint256 tokenId = littelMamiPASS.tokenOfOwnerByIndex(
                _msgSender(),
                i
            );
            if (!passUsed[tokenId]) {
                passUsed[tokenId] = true;
                mintNum++;
            }
        }
        require(
            mintNum == _num,
            "313 RABBIT : Exceeds the maximum eligible PASS mint"
        );
        require(
            PASSNum + mintNum <= maxPASSSupply,
            "313 RABBIT : Exceeds the maximum PASS supply number"
        );
        mint(_msgSender(), mintNum);
        PASSNum += mintNum;
    }

    function partnerMint(uint256 _num, bytes32[] memory _proof)
        external
        payable
    {
        require(
            block.timestamp >= wlStartTime && block.timestamp <= wlEndTime,
            "313 RABBIT : Not at mint time"
        );
        require(
            msg.value >= partnerPrice * _num,
            "313 RABBIT : Too little ether sent"
        );
        require(
            wlMined[_msgSender()] + _num <= maxWlMint,
            "313 RABBIT : Mint exceeds the maximum wl number"
        );
        require(
            _num > 0 && _num <= maxWlMint,
            "313 RABBIT : Num must greater than 0 and lower than maxWlMint"
        );
        require(
            wlNum + _num <= maxWlSupply,
            "313 RABBIT : Exceeds the maximum PASS supply number"
        );
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        require(
            MerkleProof.verify(_proof, partnerRoot, leaf),
            "313 RABBIT : Merkle verification failed"
        );
        mint(_msgSender(), _num);
        wlNum += _num;
        wlMined[_msgSender()] += _num;
    }

    function wlMint(uint256 _num, bytes32[] memory _proof) external payable {
        require(
            block.timestamp >= wlStartTime && block.timestamp <= wlEndTime,
            "313 RABBIT : Not at mint time"
        );
        require(
            msg.value >= wlPrice * _num,
            "313 RABBIT : Too little ether sent"
        );
        require(
            wlMined[_msgSender()] + _num <= maxWlMint,
            "313 RABBIT : Mint exceeds the maximum wl number"
        );
        require(
            _num > 0 && _num <= maxWlMint,
            "313 RABBIT : Num must greater than 0 and lower than maxWlMint"
        );
        require(
            wlNum + _num <= maxWlSupply,
            "313 RABBIT : Exceeds the maximum PASS supply number"
        );
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        require(
            MerkleProof.verify(_proof, wlRoot, leaf),
            "313 RABBIT : Merkle verification failed"
        );
        mint(_msgSender(), _num);
        wlNum += _num;
        wlMined[_msgSender()] += _num;
    }

    function publicMint(uint256 _num) external payable {
        require(
            block.timestamp >= publicStartTime &&
                block.timestamp <= publicEndTime,
            "313 RABBIT : Not at mint time"
        );
        require(
            publicMined[_msgSender()] + _num <= maxPublicMint,
            "313 RABBIT : Mint exceeds the maximum public number"
        );
        require(
            _num > 0 && _num <= maxPublicMint,
            "313 RABBIT : Num must greater than 0 and lower than maxPublicMint"
        );
        require(
            msg.value >= publicPrice * _num,
            "313 RABBIT : Too little ether sent"
        );
        mint(_msgSender(), _num);
        publicMined[_msgSender()] += _num;
    }

    function mint(address _address, uint256 _num) internal nonReentrant {
        require(
            totalSupply() + _num <= maxSupply,
            "313 RABBIT : Exceeds the maximum supply number"
        );
        _mint(_address, _num);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
        for (uint256 i = startTokenId; i < startTokenId + quantity; i++) {
            require(status[startTokenId] == 0, "313 RABBIT : Sleepping");
        }
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setDefaultURI(string memory _defaultURI) public onlyOwner {
        defaultURI = _defaultURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory imageURI = bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"))
            : defaultURI;

        return imageURI;
    }
}

 
 

pragma solidity ^0.8.0;

 
interface IERC20 {
     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address to, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

 
 

pragma solidity ^0.8.0;



 
interface IERC721Enumerable is IERC721 {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
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

 
 

pragma solidity ^0.8.0;

 
library MerkleProof {
     
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

     
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

     
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

     
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

     
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

     
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

     
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
         
         
         
         
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

         
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

         
         
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
         
         
         
         
         
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

     
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
         
         
         
         
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

         
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

         
         
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
         
         
         
         
         
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
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
