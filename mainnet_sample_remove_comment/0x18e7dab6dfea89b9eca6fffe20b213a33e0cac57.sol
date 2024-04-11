 

 

 

 


 

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


 
interface IERC721Metadata is IERC721 {
     
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

 



 



pragma solidity ^0.8.4;










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



 

contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {

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

         

         

         

        uint64 aux;

    }



     

    uint256 internal _currentIndex;



     

    uint256 internal _burnCounter;



     

    string private _name;



     

    string private _symbol;



     

     

    mapping(uint256 => TokenOwnership) internal _ownerships;



     

    mapping(address => AddressData) private _addressData;



     

    mapping(uint256 => address) private _tokenApprovals;



     

    mapping(address => mapping(address => bool)) private _operatorApprovals;



    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

        _currentIndex = _startTokenId();

    }



     

    function _startTokenId() internal view virtual returns (uint256) {

        return 1;

    }



     

    function totalSupply() public view returns (uint256) {

         

         

        unchecked {

            return _currentIndex - _burnCounter - _startTokenId();

        }

    }



     

    function _totalMinted() internal view returns (uint256) {

         

         

        unchecked {

            return _currentIndex - _startTokenId();

        }

    }



     

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            super.supportsInterface(interfaceId);

    }



     

    function balanceOf(address owner) public view override returns (uint256) {

        if (owner == address(0)) revert BalanceQueryForZeroAddress();

        return uint256(_addressData[owner].balance);

    }



     

    function _numberMinted(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberMinted);

    }



     

    function _numberBurned(address owner) internal view returns (uint256) {

        return uint256(_addressData[owner].numberBurned);

    }



     

    function _getAux(address owner) internal view returns (uint64) {

        return _addressData[owner].aux;

    }



     

    function _setAux(address owner, uint64 aux) internal {

        _addressData[owner].aux = aux;

    }



     

    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {

        uint256 curr = tokenId;



        unchecked {

            if (_startTokenId() <= curr && curr < _currentIndex) {

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

        return _ownershipOf(tokenId).addr;

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



     

    function setApprovalForAll(address operator, bool approved) public virtual override {

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

        if (to.isContract() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {

            revert TransferToNonERC721ReceiverImplementer();

        }

    }



     

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _startTokenId() <= tokenId && tokenId < _currentIndex &&

            !_ownerships[tokenId].burned;

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

            uint256 end = updatedIndex + quantity;



            if (safe && to.isContract()) {

                do {

                    emit Transfer(address(0), to, updatedIndex);

                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {

                        revert TransferToNonERC721ReceiverImplementer();

                    }

                } while (updatedIndex != end);

                 

                if (_currentIndex != startTokenId) revert();

            } else {

                do {

                    emit Transfer(address(0), to, updatedIndex++);

                } while (updatedIndex != end);

            }

            _currentIndex = updatedIndex;

        }

        _afterTokenTransfers(address(0), to, startTokenId, quantity);

    }



     

    function _transfer(

        address from,

        address to,

        uint256 tokenId

    ) private {

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);



        if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();



        bool isApprovedOrOwner = (_msgSender() == from ||

            isApprovedForAll(from, _msgSender()) ||

            getApproved(tokenId) == _msgSender());



        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        if (to == address(0)) revert TransferToZeroAddress();



        _beforeTokenTransfers(from, to, tokenId, 1);



         

        _approve(address(0), tokenId, from);



         

         

         

        unchecked {

            _addressData[from].balance -= 1;

            _addressData[to].balance += 1;



            TokenOwnership storage currSlot = _ownerships[tokenId];

            currSlot.addr = to;

            currSlot.startTimestamp = uint64(block.timestamp);



             

             

            uint256 nextTokenId = tokenId + 1;

            TokenOwnership storage nextSlot = _ownerships[nextTokenId];

            if (nextSlot.addr == address(0)) {

                 

                 

                if (nextTokenId != _currentIndex) {

                    nextSlot.addr = from;

                    nextSlot.startTimestamp = prevOwnership.startTimestamp;

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

        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);



        address from = prevOwnership.addr;



        if (approvalCheck) {

            bool isApprovedOrOwner = (_msgSender() == from ||

                isApprovedForAll(from, _msgSender()) ||

                getApproved(tokenId) == _msgSender());



            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();

        }



        _beforeTokenTransfers(from, address(0), tokenId, 1);



         

        _approve(address(0), tokenId, from);



         

         

         

        unchecked {

            AddressData storage addressData = _addressData[from];

            addressData.balance -= 1;

            addressData.numberBurned += 1;



             

            TokenOwnership storage currSlot = _ownerships[tokenId];

            currSlot.addr = from;

            currSlot.startTimestamp = uint64(block.timestamp);

            currSlot.burned = true;



             

             

            uint256 nextTokenId = tokenId + 1;

            TokenOwnership storage nextSlot = _ownerships[nextTokenId];

            if (nextSlot.addr == address(0)) {

                 

                 

                if (nextTokenId != _currentIndex) {

                    nextSlot.addr = from;

                    nextSlot.startTimestamp = prevOwnership.startTimestamp;

                }

            }

        }



        emit Transfer(from, address(0), tokenId);

        _afterTokenTransfers(from, address(0), tokenId, 1);



         

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



     

    function _checkContractOnERC721Received(

        address from,

        address to,

        uint256 tokenId,

        bytes memory _data

    ) private returns (bool) {

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


contract MidnightRacingClub is Ownable, ERC721A  {

    using Strings for uint256;

    string private _baseTokenURI;

    uint256 public presaleCost = 1 ether;
    uint256 public publicSaleCost = 1 ether;
    uint256 public maxSupply = 5000;

    uint256 public maxMintAmountPerPresaleAccount = 3;
    uint256 public maxMintAmountPerPublicAccount = 3;
    

    bool public paused = true;
    bool public presaleActive = true;
    bool public publicSaleActive =true;

    bytes32 public merkleRoot ;

    constructor() ERC721A("Midnight Racing Club", "Midnight Racing Club") {}

    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 , "Invalid mint amount!");
        require(totalMinted() + _mintAmount <= maxSupply, "Max supply exceeded!");
        _;
    }

    function mint(bytes32[] calldata _merkleProof, uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
        require(!paused, "The contract is paused!");
        if(presaleActive==true){
            require(msg.value >= presaleCost * _mintAmount, "Insufficient funds!");
            require(balanceOf(msg.sender) + _mintAmount <= maxMintAmountPerPresaleAccount, "Mint limit exceeded." );
             
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Not part of the Presale whitelist.");
        }
        else if(publicSaleActive==true){
            require(msg.value >= publicSaleCost * _mintAmount, "Insufficient funds!");
            require(balanceOf(msg.sender) + _mintAmount <= maxMintAmountPerPublicAccount, "Mint limit exceeded." );
        }
        _safeMint(msg.sender, _mintAmount);
    }

    function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
        _safeMint(_receiver, _mintAmount);
    }

    function airdrop(address[] memory __receivers, uint256 _mintAmount) public onlyOwner {
        require(totalSupply() + (__receivers.length * _mintAmount) <= maxSupply, "Max supply exceeded!");

        for(uint256 i = 0; i < __receivers.length; i++){
            _safeMint(__receivers[i], _mintAmount);
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
        address currentTokenOwner = ownerOf(currentTokenId);

        if (currentTokenOwner == _owner) {
            ownedTokenIds[ownedTokenIndex] = currentTokenId;
            ownedTokenIndex++;
        }

        currentTokenId++;
        }

        return ownedTokenIds;
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

        string memory currentBaseURI = _baseURI();

        return bytes(currentBaseURI).length > 0

            ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), ".json"))

            : "";
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function burn(uint256 tokenId, bool approvalCheck) public onlyOwner {
        _burn(tokenId, approvalCheck);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function setPublicSaleCost(uint256 _publicSaleCost) public onlyOwner {
        publicSaleCost = _publicSaleCost;
    }

    function setPresaleCost(uint256 _presaleCost) public onlyOwner {
        presaleCost = _presaleCost;
    }

    function setMaxMintPerPresaleAccount(uint256 _maxMintPerPresaleAccount) public onlyOwner {
        maxMintAmountPerPresaleAccount = _maxMintPerPresaleAccount;
    }
   
    function setMaxMintPerPublicAccount(uint256 _maxMintAmountPerPublicAccount) public onlyOwner {
        maxMintAmountPerPublicAccount = _maxMintAmountPerPublicAccount;
    }
    
    function setPresaleActive(bool _state) public onlyOwner {
        presaleActive = _state;
    }

    function setPublicActive(bool _state) public onlyOwner {
        require(presaleActive == false);
        publicSaleActive = _state;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function withdraw() public onlyOwner {
        
        uint256 initialBalance = address(this).balance;

        (bool hs, ) = payable(0x645566b79f765C61b8EBF7F4122753D0A01BE728).call{value: initialBalance * 10 / 100}("");
        require(hs);
        
        (bool ts, ) = payable(0x8ba8ab5539C842F3429Dc686F409D16b54590239).call{value: initialBalance * 10 / 100}("");
        require(ts);

        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

}