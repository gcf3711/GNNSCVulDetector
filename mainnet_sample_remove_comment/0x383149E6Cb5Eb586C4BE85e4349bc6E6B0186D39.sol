
 

 


pragma solidity ^0.8.2;

 



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


library SVG721 {
  function metadata(
    string memory tokenName,
    string memory tokenDescription,
    string memory svgString,
    string memory attributes
  ) internal pure returns (string memory) {
    string memory json = string(abi.encodePacked('{"name":"', tokenName, '","description":"', tokenDescription, '","image": "data:image/svg+xml;base64,', Base64.encode(bytes(svgString)),'",',attributes,'}'));
    return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
  }
}

 


pragma solidity ^0.8.0;

contract VRFRequestIDBase {

   
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

   
  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}
 


pragma solidity ^0.8.0;

interface LinkTokenInterface {

  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );

  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );

  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );

  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );

  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;

  function name()
    external
    view
    returns (
      string memory tokenName
    );

  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );

  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );

  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );

}

 


pragma solidity ^0.8.0;



 
abstract contract VRFConsumerBase is VRFRequestIDBase {

   
  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

   
  uint256 constant private USER_SEED_PLACEHOLDER = 0;

   
  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
     
     
     
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
     
     
     
     
     
     
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

   
   
   
  mapping(bytes32   => uint256  ) private nonces;

   
  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

   
   
   
  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

 


 

pragma solidity ^0.8.0;

 
 
 

 
library SafeMath {
     
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

     
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

     
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
             
             
             
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

     
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

     
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

     
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

     
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

     
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                 
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                 
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 


 

pragma solidity ^0.8.0;


 
abstract contract Pausable is Context {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    constructor() {
        _paused = false;
    }

     
    function paused() public view virtual returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

     
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

 
interface IERC721Receiver {
     
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 


 

pragma solidity ^0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 


 

pragma solidity ^0.8.0;


 
abstract contract ERC165 is IERC165 {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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


 
interface IERC721Enumerable is IERC721 {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 


pragma solidity ^0.8.4;


interface IScrambles is IERC721Enumerable {
    function mint(uint8 windowIndex, uint8 amount, bytes32[] calldata merkleProof) external;
    function unpause() external;
    function pause() external;
    function editRedemptionWindow(uint8 _windowID, bytes32 _merkleRoot, bool _open, uint8 _maxPerWallet) external;
    function getCoreNumbers(uint256 tokenId) external returns(string memory);
}
 


 

pragma solidity ^0.8.0;


 
interface IERC721Metadata is IERC721 {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
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

     
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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



 
abstract contract ERC721Burnable is Context, ERC721 {
     
    function burn(uint256 tokenId) public virtual {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

 


 

pragma solidity ^0.8.0;



 
abstract contract ERC721Pausable is ERC721, Pausable {
     
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}

 



pragma solidity ^0.8.4;













 
                                                                                                                                               
contract Scrambles is IScrambles, ERC721Enumerable, ERC721Pausable, ERC721Burnable, Ownable, VRFConsumerBase {
    using Strings for uint256;
    using Strings for uint8;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private generalCounter; 
    uint public constant MAX_MINT = 963;

     
    address public VRFCoordinator;
    address public LinkToken;
    bytes32 internal keyHash;
    uint256 public baseSeed;
  
    struct RedemptionWindow {
        bool open;
        uint8 maxRedeemPerWallet;
        bytes32 merkleRoot;
    }

    mapping(uint8 => RedemptionWindow) public redemptionWindows;
    mapping(address => uint8) public mintedTotal;
    mapping(uint8 => string[]) colours;

     
    string public _contractURI;

    bool public revealed;

    event Minted(address indexed account, string tokens);

     
    
    constructor (
        string memory _name, 
        string memory _symbol,
        uint8[] memory _maxRedeemPerWallet,
        bytes32[] memory _merkleRoots,
        string memory _contractMetaDataURI,
        address _VRFCoordinator, 
        address _LinkToken,
        bytes32 _keyHash
    ) 
    
    VRFConsumerBase(_VRFCoordinator, _LinkToken)

    ERC721(_name, _symbol) {

         
        VRFCoordinator = _VRFCoordinator;
        LinkToken = _LinkToken;

         
        _contractURI = _contractMetaDataURI;
        keyHash = _keyHash;
        
         
        for(uint8 i = 0; i < _merkleRoots.length; i++) {
            redemptionWindows[i].open = false;
            redemptionWindows[i].maxRedeemPerWallet = _maxRedeemPerWallet[i];
            redemptionWindows[i].merkleRoot = _merkleRoots[i];
        }

         
        colours[0].push("#ff0000");
        colours[0].push("#00ff00");
        colours[0].push("#0000ff");
        colours[0].push("#ff8000");
        colours[0].push("#ffff00");
        colours[0].push("#ffffff");

         
        colours[1].push("#ff00ff");
        colours[1].push("#00ffff");
        colours[1].push("#ffff00");
        colours[1].push("#000000");
        colours[1].push("#808080");
        colours[1].push("#ffffff");

         
        colours[2].push("#000000");
        colours[2].push("#333333");
        colours[2].push("#666666");
        colours[2].push("#999999");
        colours[2].push("#cccccc");
        colours[2].push("#ffffff");
    }

     
    function pause() external override onlyOwner {
        _pause();
    }

     
    function unpause() external override onlyOwner {
        _unpause();
    }

     
    function reveal(bool state) external onlyOwner {
        revealed = state;
    }

     
    function editRedemptionWindow(
        uint8 _windowID,
        bytes32 _merkleRoot, 
        bool _open,
        uint8 _maxPerWallet
    ) external override onlyOwner {
        if(redemptionWindows[_windowID].open != _open)
        {
            redemptionWindows[_windowID].open = _open;
        }
        if(redemptionWindows[_windowID].maxRedeemPerWallet != _maxPerWallet)
        {
            redemptionWindows[_windowID].maxRedeemPerWallet = _maxPerWallet;
        }
        if(redemptionWindows[_windowID].merkleRoot != _merkleRoot)
        {
            redemptionWindows[_windowID].merkleRoot = _merkleRoot;
        }
    }       

     
    function withdrawEther(address payable _to, uint256 _amount) public onlyOwner
    {
        _to.transfer(_amount);
    }

     
    function mint(uint8 windowIndex, uint8 amount, bytes32[] calldata merkleProof) external override{
         
        require(redemptionWindows[windowIndex].open, "Redeem: window is not open");
        require(amount > 0, "Redeem: amount cannot be zero");
        require(amount < 11, "Redeem: amount cannot be more than 10");
        require(generalCounter.current() + amount <= MAX_MINT, "Max limit");

        if(windowIndex != 3)
        {
             
            require(mintedTotal[msg.sender] + amount <=  redemptionWindows[windowIndex].maxRedeemPerWallet, "Too many for presale window");

             
            require(verifyMerkleProof(merkleProof, redemptionWindows[windowIndex].merkleRoot),"Invalid proof");          
        }

        string memory tokens = "";

        for(uint8 j = 0; j < amount; j++) {
            _safeMint(msg.sender, generalCounter.current());
            tokens = string(abi.encodePacked(tokens, generalCounter.current().toString(), ","));
            generalCounter.increment();
        }
        mintedTotal[msg.sender] = mintedTotal[msg.sender] + amount;
        emit Minted(msg.sender, tokens);
    }  

     
    function verifyMerkleProof(bytes32[] memory proof, bytes32 root) public view returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(proof, root, leaf);
    }

     
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        baseSeed = randomness;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }    

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    } 

    function setContractURI(string memory uri) external onlyOwner{
        _contractURI = uri;
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory name = string(abi.encodePacked("Scramble #", tokenId.toString()));
        return SVG721.metadata(name, getCoreNumbers(tokenId), getSVGString(tokenId),getTraits(tokenId));
    }

     
    function getCoreNumbers(uint256 tokenId) public view virtual override returns (string memory){
        string memory coreNumbers = "";

        if(!revealed)
        {
            return coreNumbers;
        }

        coreNumbers = string(abi.encodePacked(coreNumbers,getPaletteIndex(getSeed(tokenId)).toString()," "));

        for(uint8 i = 1; i < 10; i++)
        {
            coreNumbers = string(abi.encodePacked(coreNumbers,(expandRandom(getSeed(tokenId),i) % 6).toString()," "));
        }

        return coreNumbers;
    }

     
    function checkConnection(string[9] memory cols, uint8 a, uint8 b) internal pure returns(uint8)
    {
        if(keccak256(abi.encodePacked(cols[a])) == keccak256(abi.encodePacked(cols[b]))){
            return 1;
        }
        else{
            return 0;
        }
    }

     
    function getTraits(uint256 tokenId) public view returns (string memory)
    {
        if(!revealed){
            return '"attributes": [{"value": "Unscrambled"}]';
        }

        string[9] memory cols;
        uint256[6] memory colTotals;

        for(uint8 j = 1; j < 10; j++) {
            
            string memory col = getColour(j,getSeed(tokenId));
            cols[j-1] =col; 

            for (uint i = 0; i<6; i++)
            {
                string memory colToCheck = colours[getPaletteIndex(getSeed(tokenId))][i];
                if(keccak256(abi.encodePacked(col)) == keccak256(abi.encodePacked(colToCheck)))
                {
                    colTotals[i]++;
                }
            }
        }

        uint8 connections = 0;

        connections += checkConnection(cols,0,1);
        connections += checkConnection(cols,1,2);
        connections += checkConnection(cols,0,3);
        connections += checkConnection(cols,1,4);
        connections += checkConnection(cols,2,5);
        connections += checkConnection(cols,3,4);
        connections += checkConnection(cols,4,5);
        connections += checkConnection(cols,3,6);
        connections += checkConnection(cols,4,7);
        connections += checkConnection(cols,5,8);
        connections += checkConnection(cols,6,7);
        connections += checkConnection(cols,7,8);

        uint256 totalCols = 0;

        for (uint256 h=0; h<6; h++){

            if(colTotals[h] > 0)
            {
                totalCols++;
            }
        }

        string memory traits = '"attributes": [';
        string memory newTrait = "";

        for (uint256 h = 0; h < 6; h++){
            string memory traitName = string(abi.encodePacked('Colour #', h.toString()));
            newTrait = getPropertyString(traitName,colTotals[h]);
            traits = string(abi.encodePacked(traits,newTrait,","));
        }

        newTrait = getPropertyString("Connections",connections);
        traits = string(abi.encodePacked(traits,newTrait,","));

        newTrait = getPropertyString("Palette",getPaletteIndex(getSeed(tokenId)));
        traits = string(abi.encodePacked(traits,newTrait,","));

        newTrait = getPropertyString("Total Colours",totalCols);
        traits = string(abi.encodePacked(traits,newTrait,","));

        newTrait = getLevelString("Background Colour",expandRandom(getSeed(tokenId),10) % 256);
        traits = string(abi.encodePacked(traits,newTrait,","));

        newTrait = getLevelString("Shirt Colour",expandRandom(getSeed(tokenId),11) % 256);
        traits = string(abi.encodePacked(traits,newTrait,"]"));

        return traits;
    }

     
    function getPropertyString(string memory traitName, uint256 value) internal pure returns (string memory)
    {
        return string(abi.encodePacked('{"trait_type": "',traitName,'" , "value": "',value.toString(),'"}'));
    }

     
    function getLevelString(string memory traitName, uint256 value) internal pure returns (string memory)
    {
        return string(abi.encodePacked('{"trait_type": "',traitName,'" , "value": ',value.toString(),'}'));
    }

     
    function getSVGString(uint256 tokenId) public view returns (string memory)
    {   
        if(!revealed){
            return "";
        }

        string memory svgPartOne = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" width="420" height="420">',
        string(abi.encodePacked('<rect width="420" height="420" x="0" y="0" fill=',getGrey(10,getSeed(tokenId),100),' />')),
        string(abi.encodePacked('<rect width="280" height="280" x="90" y="90" fill=',getGrey(10,getSeed(tokenId),66),' />')),
        string(abi.encodePacked('<rect width="280" height="280" x="80" y="80" fill=',getGrey(10,getSeed(tokenId),33),' />')),
        string(abi.encodePacked('<rect width="280" height="280" x="70" y="70" fill="#000000" />')),
        string(abi.encodePacked('<rect width="120" height="70" x="150" y="350" fill=',getGrey(11,getSeed(tokenId),100),' />'))));

        string memory svgPartTwo = string(abi.encodePacked(        
        string(abi.encodePacked('<rect width="10" height="50" x="170" y="370" fill="#000000" />')),
        string(abi.encodePacked('<rect width="10" height="50" x="240" y="370" fill="#000000" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="80" y="80" fill="',getColour(1,getSeed(tokenId)),'" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="170" y="80" fill="',getColour(2,getSeed(tokenId)),'" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="260" y="80" fill="',getColour(3,getSeed(tokenId)),'" />'))));

        string memory svgPartThree = string(abi.encodePacked( 
        string(abi.encodePacked('<rect width="80" height="80" x="80" y="170" fill="',getColour(4,getSeed(tokenId)),'" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="170" y="170" fill="',getColour(5,getSeed(tokenId)),'" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="260" y="170" fill="',getColour(6,getSeed(tokenId)),'" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="80" y="260" fill="',getColour(7,getSeed(tokenId)),'" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="170" y="260" fill="',getColour(8,getSeed(tokenId)),'" />')),
        string(abi.encodePacked('<rect width="80" height="80" x="260" y="260" fill="',getColour(9,getSeed(tokenId)),'" />')),
        '</svg>'));

        return string(abi.encodePacked(svgPartOne,svgPartTwo,svgPartThree));
    }

     
    function getColour(uint8 colourIndex, uint256 seed) internal view returns (string memory)
    {
        uint256 expandedVal = expandRandom(seed,colourIndex) % 6;
        return colours[getPaletteIndex(seed)][expandedVal];
    }

     
    function getGrey(uint8 colourIndex, uint256 seed, uint256 percentage) public pure returns (string memory)
    {
        uint256 grey = ((expandRandom(seed,colourIndex) % 256)*percentage)/100;
        return string(abi.encodePacked('"rgb(',grey.toString(),',',grey.toString(),',',grey.toString(),')"'));
    }

     
    function getPaletteIndex(uint256 seed) internal pure returns (uint8)
    {
        if (seed % 10 < 6){
            return 0;
        }
        else if (seed % 10 < 9){
            return 1;
        }
        else{
            return 2;
        }
    }

     
    function scramble(uint256 fee) public onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        return requestRandomness(keyHash, fee);
    }

     
    function getSeed(uint256 tokenId) public view returns (uint256)
    {
        require(totalSupply()>tokenId, "Token Not Found");

        if (baseSeed == 0){
            return 0;
        }
        else{
            return expandRandom(baseSeed, tokenId);
        }
    }
    
     
    function expandRandom(uint256 random, uint256 expansion) internal pure returns (uint256)
    {
        return uint256(keccak256(abi.encode(random, expansion))) % 2000000000;
    }
}