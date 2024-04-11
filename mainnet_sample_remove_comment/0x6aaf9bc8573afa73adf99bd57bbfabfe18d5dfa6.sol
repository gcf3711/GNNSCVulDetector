 

 

 
pragma solidity ^0.8.3;

 
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
        _setOwner(_msgSender());
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 
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

contract NFTAirdropper is Ownable {
    struct Airdrop {
        address nft;
        uint id;
    }

    uint public nextAirdropId;
    uint public claimedAirdropId;
    mapping(uint => Airdrop) public airdrops;
    mapping(address => bool) public recipients;

    constructor() {}

    function sendAirdrops(Airdrop[] memory _airdrops, address[] memory _recipients) external onlyOwner() {
        require(_airdrops.length == _recipients.length, "Invalid input lengths");
        for(uint i = 0; i < _airdrops.length; i++) {
            IERC721(_airdrops[i].nft).transferFrom(msg.sender,  _recipients[i],  _airdrops[i].id);
        }
    }

    function addAirdrops(Airdrop[] memory _airdrops) external onlyOwner() {
        uint _nextAirdropId = nextAirdropId;
        for(uint i = 0; i < _airdrops.length; i++) {
            airdrops[_nextAirdropId] = _airdrops[i];
            IERC721(_airdrops[i].nft).transferFrom(msg.sender,  address(this),  _airdrops[i].id);
            _nextAirdropId++;
        }
        nextAirdropId = _nextAirdropId;
    }

    function addRecipients(address[] memory _recipients) external onlyOwner() {
        for(uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = true;
        }
    }

    function removeRecipients(address[] memory _recipients) external onlyOwner() {
        for(uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = false;
        }
    }

    function claim() external {
        require(recipients[msg.sender] == true, 'PKNAirdropNFT: recipient not added');
        recipients[msg.sender] = false;
        Airdrop storage airdrop = airdrops[claimedAirdropId];
        IERC721(airdrop.nft).transferFrom(address(this), msg.sender, airdrop.id);
        claimedAirdropId++;
    }
}