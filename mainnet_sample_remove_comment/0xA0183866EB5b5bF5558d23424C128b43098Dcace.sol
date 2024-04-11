 


 
 

pragma solidity ^0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
 
 

pragma solidity ^0.8.0;



 
interface IERC1155 is IERC165 {
     
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

     
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

     
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

     
    event URI(string value, uint256 indexed id);

     
    function balanceOf(address account, uint256 id) external view returns (uint256);

     
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

     
    function setApprovalForAll(address operator, bool approved) external;

     
    function isApprovedForAll(address account, address operator) external view returns (bool);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

     
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

 
 

pragma solidity ^0.8.0;



 
interface IERC1155MetadataURI is IERC1155 {
     
    function uri(uint256 id) external view returns (string memory);
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



 
abstract contract ERC165 is IERC165 {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




 
 
 

 
 

pragma solidity ^0.8.0;








 
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

     
    mapping(uint256 => mapping(address => uint256)) private _balances;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
    string private _uri;

     
    constructor(string memory uri_) {
        _setURI(uri_);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

     
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

     
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

     
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

     
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

     
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

     
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

     
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

     
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

     
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

     
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

     
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

     
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

     
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
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
 
pragma solidity ^0.8.7;








 
 
 

contract PROPERTYDEED is ERC1155, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    Counters.Counter public _tokenIdCounter;

    string public name = "METAVATARS - PROPERTY DEED";
    string public description = "METAVATARS PROPERTY DEED allow you to receive what is rightfully yours on P403. When you first enter the Metavatars world, you will be able to automatically synchronize your wallet with your inventory. The magic of the blockchain will do the rest.";

    uint256 public MAX_MINT_PER_WALLET = 1;
    uint256 public price = 0 ether;

    enum currentStatus {
        Before,
        PrivateMint,
        Pause
    }

    currentStatus public status;

    uint256 public constant LOOTBOX = 1;
    uint256 public constant PET = 2;
    uint256 public constant MOUNT = 3;
    uint256 public constant RESIDENCE = 4;
    uint256 public constant LAND = 5;

    mapping(address => uint256) public LootBoxTokensPerWallet;
    mapping(address => uint256) public PetTokensPerWallet;
    mapping(address => uint256) public MountTokensPerWallet;
    mapping(address => uint256) public ResidenceTokensPerWallet;
    mapping(address => uint256) public LandTokensPerWallet;

    bytes32 public LootBoxRootTree;
    bytes32 public PetRootTree;
    bytes32 public MountRootTree;
    bytes32 public ResidenceRootTree;
    bytes32 public LandRootTree;

    constructor(
        string memory _uri,
        bytes32 _lootMerkleRoot,
        bytes32 _petMerkleRoot,
        bytes32 _mountMerkleRoot,
        bytes32 _residenceMerkleRoot,
        bytes32 _landMerkleRoot
    ) ERC1155(_uri) {
        LootBoxRootTree = _lootMerkleRoot;
        PetRootTree = _petMerkleRoot;
        MountRootTree = _mountMerkleRoot;
        ResidenceRootTree = _residenceMerkleRoot;
        LandRootTree = _landMerkleRoot;
    }

    function getCurrentStatus() public view returns(currentStatus) {
        return status;
    }

    function setInPause() external onlyOwner {
        status = currentStatus.Pause;
    }

    function startPrivateMint() external onlyOwner {
        status = currentStatus.PrivateMint;
    }

    function setMaxMintPerWallet(uint256 maxMintPerWallet_) external onlyOwner {
        MAX_MINT_PER_WALLET = maxMintPerWallet_;
    }

    function setLootMerkleTree(bytes32 lootMerkleTree_) public onlyOwner{
        LootBoxRootTree = lootMerkleTree_;
    }

    function setPetMerkleTree(bytes32 petMerkleTree_) public onlyOwner{
        PetRootTree = petMerkleTree_;
    }

    function setMountMerkleTree(bytes32 mountMerkleTree_) public onlyOwner{
        MountRootTree = mountMerkleTree_;
    }

    function setResidenceMerkleTree(bytes32 residenceMerkleTree_) public onlyOwner{
        ResidenceRootTree = residenceMerkleTree_;
    }

    function setLandMerkleTree(bytes32 landMerkleTree_) public onlyOwner{
        LandRootTree = landMerkleTree_;
    }

    function lootMint(bytes32[] calldata merkleProof, uint32 amount) external {
        require(status == currentStatus.PrivateMint, "METAVATARS PROPERTY DEED: Loot Mint Is Not OPEN !");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, LootBoxRootTree, leaf), "METAVATARS PROPERTY DEED: You're not Eligible for the Loot Mint !");
        require(LootBoxTokensPerWallet[msg.sender] + amount <= MAX_MINT_PER_WALLET, "METAVATARS PROPERTY DEED: Max Loot Mint per Wallet !");

        LootBoxTokensPerWallet[msg.sender] += amount;
        _mint(msg.sender, LOOTBOX,  amount, "");
    }

    function petMint(bytes32[] calldata merkleProof, uint32 amount) external {
        require(status == currentStatus.PrivateMint, "METAVATARS PROPERTY DEED: Pet Mint Is Not OPEN !");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, PetRootTree, leaf), "METAVATARS PROPERTY DEED: You're not Eligible for the Loot Mint !");
        require(PetTokensPerWallet[msg.sender] + amount <= MAX_MINT_PER_WALLET, "METAVATARS PROPERTY DEED: Max Loot Mint per Wallet !");

        PetTokensPerWallet[msg.sender] += amount;
        _mint(msg.sender, PET,  amount, "");
    }

    function mountMint(bytes32[] calldata merkleProof, uint32 amount) external {
        require(status == currentStatus.PrivateMint, "METAVATARS PROPERTY DEED: Mount Mint Is Not OPEN !");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, MountRootTree, leaf), "METAVATARS PROPERTY DEED: You're not Eligible for the Loot Mint !");
        require(MountTokensPerWallet[msg.sender] + amount <= MAX_MINT_PER_WALLET, "METAVATARS PROPERTY DEED: Max Loot Mint per Wallet !");

        MountTokensPerWallet[msg.sender] += amount;
        _mint(msg.sender, MOUNT,  amount, "");
    }

    function residenceMint(bytes32[] calldata merkleProof, uint32 amount) external {
        require(status == currentStatus.PrivateMint, "METAVATARS PROPERTY DEED: Residence Mint Is Not OPEN !");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, ResidenceRootTree, leaf), "METAVATARS PROPERTY DEED: You're not Eligible for the Loot Mint !");
        require(ResidenceTokensPerWallet[msg.sender] + amount <= MAX_MINT_PER_WALLET, "METAVATARS PROPERTY DEED: Max Loot Mint per Wallet !");

        ResidenceTokensPerWallet[msg.sender] += amount;
        _mint(msg.sender, RESIDENCE,  amount, "");
    }

    function landMint(bytes32[] calldata merkleProof, uint32 amount) external {
        require(status == currentStatus.PrivateMint, "METAVATARS PROPERTY DEED: Land Mint Is Not OPEN !");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, LandRootTree, leaf), "METAVATARS PROPERTY DEED: You're not Eligible for the Loot Mint !");
        require(LandTokensPerWallet[msg.sender] + amount <= MAX_MINT_PER_WALLET, "METAVATARS PROPERTY DEED: Max Loot Mint per Wallet !");

        LandTokensPerWallet[msg.sender] += amount;
        _mint(msg.sender, LAND,  amount, "");
    }

    function gift(uint256 amount, uint256 tokenId, address giveawayAddress) public onlyOwner {
        require(amount > 0, "METAVATARS PROPERTY DEED: Need to gift 1 min !");
        _mint(giveawayAddress, tokenId, amount, "");
    }

    function uri(uint256 _id) public view override returns (string memory) {
            require(_id > 0 && _id < 6, "URI: nonexistent token");
            return string(abi.encodePacked(super.uri(_id), Strings.toString(_id)));
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



 
interface IERC1155Receiver is IERC165 {
     
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

     
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
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
