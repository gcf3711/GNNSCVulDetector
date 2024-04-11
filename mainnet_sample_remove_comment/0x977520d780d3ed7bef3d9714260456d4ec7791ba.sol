 

 

 

 
 

 

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
                 
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                 
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
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

 


 

pragma solidity ^0.8.0;


 
interface IERC721Metadata is IERC721 {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

 



pragma solidity ^0.8.7;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

abstract contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    
    string private _name;
    string private _symbol;

     
    address[] internal _owners;

    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

     
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

     
    function balanceOf(address owner) 
        public 
        view 
        virtual 
        override 
        returns (uint) 
    {
        require(owner != address(0), "ERC721: balance query for the zero address");

        uint count;
        uint length= _owners.length;
        for( uint i; i < length; ++i ){
          if( owner == _owners[i] )
            ++count;
        }
        delete length;
        return count;
    }

     
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
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

     
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
         
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

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
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

     
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < _owners.length && _owners[tokenId] != address(0);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
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
        _owners.push(to);

        emit Transfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        _approve(address(0), tokenId);
        _owners[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

     
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
        _approve(address(0), tokenId);
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
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
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


pragma solidity ^0.8.7;


 
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _owners.length;
    }

     
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < _owners.length, "ERC721Enumerable: global index out of bounds");
        return index;
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256 tokenId) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");

        uint count;
        for(uint i; i < _owners.length; i++){
            if(owner == _owners[i]){
                if(count == index) return i;
                else count++;
            }
        }

        revert("ERC721Enumerable: owner index out of bounds");
    }
}

pragma solidity ^0.8.7;

contract ForceAlphaNftContract is ERC721Enumerable,  Ownable {
    using Strings for uint256;
    string private uriPrefix;
    string private uriSuffix = ".json";
    string private revealURI ="ipfs://QmRABdXqKsWvaNTPcA1AuuZnpVcUcirDjLj4hzLHesGdiJ";

     
    bytes32 public whitelistMerkleRoot;

    uint256 public cost = 0.07 ether;
    uint256 public whiteListCost = 0.05 ether;
    uint256 public constant maxSupply = 3344; 
    uint256 public maxMintAmountPerTx = 20;
    uint256 public maxWLMintAmountPerTx = 5;

    bool public paused = true;
    bool public WLpaused = true;
    bool public reveal = false;
    mapping(address => uint256) public _mintedNfts;

    constructor() ERC721("FORCE ALPHA", "FORC") {}
    
    function mint(uint256 _mintAmount) external payable  {
        uint256 totalSupply = _owners.length;
        require(totalSupply + _mintAmount <= maxSupply, "Exceeds max supply.");
        require(_mintAmount <= maxMintAmountPerTx, "Exceeds max per transaction.");

        require(!paused, "The contract is paused!");
        require(msg.value == cost * _mintAmount, "Insufficient funds!");
        for(uint i; i < _mintAmount; i++) {
        _mint(msg.sender, totalSupply + i);
        }
        delete totalSupply;
        delete _mintAmount;
    }
    
    function adminMint(uint256 _mintAmount, address _receiver) external onlyOwner {
        uint256 totalSupply = _owners.length;
        require(totalSupply + _mintAmount <= maxSupply, "Excedes max supply.");
        for(uint i; i < _mintAmount; i++) {
        _mint(_receiver , totalSupply + i);
        }
        delete _mintAmount;
        delete _receiver;
        delete totalSupply;
    }

    function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot) external onlyOwner {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }

        
    function getLeafNode(address _leaf) internal pure returns (bytes32 temp)
    {
        return keccak256(abi.encodePacked(_leaf));
    }
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        return MerkleProof.verify(proof, whitelistMerkleRoot, leaf);
    }

    function whitelistMint(uint256 _mintAmount, bytes32[] calldata merkleProof) external payable {

        bytes32  leafnode = getLeafNode(msg.sender);
        require(_verify(leafnode ,   merkleProof   ),  "Invalid merkle proof");
        require((_mintedNfts[msg.sender] + _mintAmount) <= maxWLMintAmountPerTx, "Exceeds Max Allowed Minting Token Amount.");

        require(!WLpaused, "Whitelist minting is over!");
        require(msg.value == whiteListCost * _mintAmount, "Insufficient funds!");

        uint256 totalSupply = _owners.length;
        for(uint i; i < _mintAmount; i++) {
            _mint(msg.sender , totalSupply + i);
        }
        _mintedNfts[msg.sender] += _mintAmount;
        delete totalSupply;
        delete _mintAmount;
    
    }
    function tokenURI(uint256 _tokenId)
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

        if(reveal) {
            string memory currentBaseURI = _baseURI();
            return bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
                : "";
        } else {
            return revealURI;
        } 
    }

    function setCost(uint256 _cost) external onlyOwner {
        cost = _cost;
        delete _cost;
    }
    function setWLCost(uint256 _cost) external onlyOwner {
        whiteListCost = _cost;
        delete _cost;
    }
    function changeRevealStatus() external onlyOwner {
        reveal = !reveal;
    }
    function setRevealURI(string memory _revealURI) external onlyOwner {
        revealURI = _revealURI;
        delete _revealURI;
    }


    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) external onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
        delete _maxMintAmountPerTx;
    }
    
    function setMaxWLMintAmountPerTx(uint256 _maxWLMintAmountPerTx) external onlyOwner {
        maxWLMintAmountPerTx = _maxWLMintAmountPerTx;
        delete _maxWLMintAmountPerTx;
    }

    function setUriPrefix(string memory _uriPrefix) external onlyOwner {
        uriPrefix = _uriPrefix;
    }


    function setPaused() external onlyOwner {
        paused = !paused;
    }

    function setWLPaused() external onlyOwner {
        WLpaused = !WLpaused;
    }

    function withdraw() external onlyOwner {
    uint _balance = address(this).balance;
        payable(msg.sender).transfer(_balance ); 
        
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
            _owners.push(to);
            emit Transfer(address(0), to, tokenId);
        }

    function _baseURI() internal view  returns (string memory) {
        return uriPrefix;
    }
}