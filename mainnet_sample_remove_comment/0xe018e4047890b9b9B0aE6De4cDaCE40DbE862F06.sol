 


 
 

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



 
abstract contract ERC165 is IERC165 {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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



 
interface IERC721Enumerable is IERC721 {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 
 

pragma solidity ^0.8.0;



 
interface IERC721Metadata is IERC721 {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
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

 
 

pragma solidity ^0.8.4;










error ApprovalCallerNotOwnerNorApproved();
error ApprovalQueryForNonexistentToken();
error ApproveToCaller();
error ApprovalToCurrentOwner();
error BalanceQueryForZeroAddress();
error MintedQueryForZeroAddress();
error BurnedQueryForZeroAddress();
error MintToZeroAddress();
error MintZeroQuantity();
error OwnerIndexOutOfBounds();
error OwnerQueryForNonexistentToken();
error TokenIndexOutOfBounds();
error TransferCallerNotOwnerNorApproved();
error TransferFromIncorrectOwner();
error TransferToNonERC721ReceiverImplementer();
error TransferToZeroAddress();
error URIQueryForNonexistentToken();

 
contract ERC721A is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    using Strings for uint256;

     
    struct TokenOwnership {
         
        address addr;
         
        uint64 startTimestamp;
         
        bool burned;
    }

     
    struct AddressData {
         
        uint64 balance;
         
        uint64 numberMinted;
         
        uint64 numberBurned;
    }

     
     
    
     
    uint128 internal _currentIndex;

     
    uint128 internal _burnCounter;

     
    string private _name;

     
    string private _symbol;

     
     
    mapping(uint256 => TokenOwnership) internal _ownerships;

     
    mapping(address => AddressData) private _addressData;

     
    mapping(uint256 => address) private _tokenApprovals;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

     
    function totalSupply() public view override returns (uint256) {
         
         
        unchecked {
            return _currentIndex - _burnCounter;    
        }
    }

     
    function tokenByIndex(uint256 index) public view override returns (uint256) {
        uint256 numMintedSoFar = _currentIndex;
        uint256 tokenIdsIdx;

         
         
        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (!ownership.burned) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }
        revert TokenIndexOutOfBounds();
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        if (index >= balanceOf(owner)) revert OwnerIndexOutOfBounds();
        uint256 numMintedSoFar = _currentIndex;
        uint256 tokenIdsIdx;
        address currOwnershipAddr;

         
         
        unchecked {
            for (uint256 i; i < numMintedSoFar; i++) {
                TokenOwnership memory ownership = _ownerships[i];
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    if (tokenIdsIdx == index) {
                        return i;
                    }
                    tokenIdsIdx++;
                }
            }
        }

         
        revert();
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

     
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    function _numberMinted(address owner) internal view returns (uint256) {
        if (owner == address(0)) revert MintedQueryForZeroAddress();
        return uint256(_addressData[owner].numberMinted);
    }

    function _numberBurned(address owner) internal view returns (uint256) {
        if (owner == address(0)) revert BurnedQueryForZeroAddress();
        return uint256(_addressData[owner].numberBurned);
    }

     
    function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        uint256 curr = tokenId;

        unchecked {
            if (curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                     
                     
                     
                     
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

     
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return ownershipOf(tokenId).addr;
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
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

     
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

     
    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721A.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

     
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public override {
        if (operator == _msgSender()) revert ApproveToCaller();

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
        if (!_checkOnERC721Received(from, to, tokenId, _data)) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

     
    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId < _currentIndex && !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

     
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        _mint(to, quantity, _data, true);
    }

     
    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

         
         
         
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;

            for (uint256 i; i < quantity; i++) {
                emit Transfer(address(0), to, updatedIndex);
                if (safe && !_checkOnERC721Received(address(0), to, updatedIndex, _data)) {
                    revert TransferToNonERC721ReceiverImplementer();
                }
                updatedIndex++;
            }

            _currentIndex = uint128(updatedIndex);
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

     
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
            isApprovedForAll(prevOwnership.addr, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

         
        _approve(address(0), tokenId, prevOwnership.addr);

         
         
         
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            _ownerships[tokenId].addr = to;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);

             
             
            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                 
                 
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        TokenOwnership memory prevOwnership = ownershipOf(tokenId);

        _beforeTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

         
        _approve(address(0), tokenId, prevOwnership.addr);

         
         
         
        unchecked {
            _addressData[prevOwnership.addr].balance -= 1;
            _addressData[prevOwnership.addr].numberBurned += 1;

             
            _ownerships[tokenId].addr = prevOwnership.addr;
            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);
            _ownerships[tokenId].burned = true;

             
             
            uint256 nextTokenId = tokenId + 1;
            if (_ownerships[nextTokenId].addr == address(0)) {
                 
                 
                if (nextTokenId < _currentIndex) {
                    _ownerships[nextTokenId].addr = prevOwnership.addr;
                    _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(prevOwnership.addr, address(0), tokenId);
        _afterTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);

         
        unchecked { 
            _burnCounter++;
        }
    }

     
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

     
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert TransferToNonERC721ReceiverImplementer();
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
}
 

pragma solidity ^0.8.0;




 

contract AstarCats is ERC721A, Ownable, ReentrancyGuard {
  using Address for address;
  using Strings for uint;

  string  public  baseTokenURI = "ipfs://QmP5FzQ5cgVSDRGj9PTozM9v8MUiAyaYBQPvMyVXnQTcsx";

  uint256 public  maxSupply = 3333;
  uint256 public  MAX_MINTS_PER_TX = 20;
  uint256 public  FREE_MINTS_PER_TX = 5;
  uint256 public  PUBLIC_SALE_PRICE = 0.005 ether;
  uint256 public  TOTAL_FREE_MINTS = 500;
  bool public isPublicSaleActive = true;

  constructor(

  ) ERC721A("AstarCats", "AstarCats") {

  }

  function mint(uint256 numberOfTokens)
      external
      payable
  {
    require(isPublicSaleActive, "Public sale is not open");
    require(
      totalSupply() + numberOfTokens <= maxSupply,
      "Maximum supply exceeded"
    );

    if(totalSupply() + numberOfTokens > TOTAL_FREE_MINTS || numberOfTokens > FREE_MINTS_PER_TX){
        require(
            (PUBLIC_SALE_PRICE * numberOfTokens) <= msg.value,
            "Incorrect ETH value sent"
        );
    }
    _safeMint(msg.sender, numberOfTokens);
  }

  function setBaseURI(string memory baseURI)
    public
    onlyOwner
  {
    baseTokenURI = baseURI;
  }

  function treasuryMint(uint quantity, address user)
    public
    onlyOwner
  {
    require(
      quantity > 0,
      "Invalid mint amount"
    );
    require(
      totalSupply() + quantity <= maxSupply,
      "Maximum supply exceeded"
    );
    _safeMint(user, quantity);
  }

  function withdraw()
    public
    onlyOwner
    nonReentrant
  {
    Address.sendValue(payable(msg.sender), address(this).balance);
  }

  function tokenURI(uint _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    return string(abi.encodePacked(baseTokenURI, "/", _tokenId.toString(), ".json"));
  }

  function _baseURI()
    internal
    view
    virtual
    override
    returns (string memory)
  {
    return baseTokenURI;
  }

  function setIsPublicSaleActive(bool _isPublicSaleActive)
      external
      onlyOwner
  {
      isPublicSaleActive = _isPublicSaleActive;
  }

  function setNumFreeMints(uint256 _numfreemints)
      external
      onlyOwner
  {
      TOTAL_FREE_MINTS = _numfreemints;
  }

  function setSalePrice(uint256 _price)
      external
      onlyOwner
  {
      PUBLIC_SALE_PRICE = _price;
  }

  function setMaxLimitPerTransaction(uint256 _limit)
      external
      onlyOwner
  {
      MAX_MINTS_PER_TX = _limit;
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

 
 

pragma solidity ^0.8.0;

 
interface IERC721Receiver {
     
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
