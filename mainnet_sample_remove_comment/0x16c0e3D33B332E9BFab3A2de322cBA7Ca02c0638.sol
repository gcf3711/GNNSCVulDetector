 

 

 
 

pragma solidity ^0.8.0;


 



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
        require(newOwner != address(0), "Ownable: new owner is 0x address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


abstract contract Functional {
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
    
    bool private _reentryKey = false;
    modifier reentryLock {
        require(!_reentryKey, "attempt reenter locked function");
        _reentryKey = true;
        _;
        _reentryKey = false;
    }
}

contract PANDEMIC {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance){}
    function ownerOf(uint256 tokenId) external view returns (address owner){}
    function safeTransferFrom(address from,address to,uint256 tokenId) external{}
    function transferFrom(address from, address to, uint256 tokenId) external{}
    function approve(address to, uint256 tokenId) external{}
    function getApproved(uint256 tokenId) external view returns (address operator){}
    function setApprovalForAll(address operator, bool _approved) external{}
    function isApprovedForAll(address owner, address operator) external view returns (bool){}
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external{}


     

    function totalSupply() external view returns (uint256) {}

     
    function proxyMint(address to, uint256 tokenId) external {
    }
    
    function proxyBurn(uint256 tokenId) external {
    }
}

contract ProxyMint is Ownable, Functional {

    uint256 maxSupply = 6666;
    uint256 maxPerWallet = 100;

    bool mintActive;

    PANDEMIC proxy = PANDEMIC(0x4Ad8A7406Caac3457981A1B3C88B8aAB00D6e13d);

    mapping (address => uint256) _mintTracker;

    function mint(uint256 qty) public reentryLock {
        require(mintActive, "Closed");
        uint256 totalSupply = proxy.totalSupply();
        require(totalSupply + qty <= maxSupply, "Sold Out");
        require(qty <= 20, "20 at a time max");
        require((_mintTracker[_msgSender()] + qty) <= maxPerWallet, "Mint: Max tkn per wallet exceeded");

        _mintTracker[_msgSender()] += qty;

        for (uint256 i=0; i < qty; i++){
            proxy.proxyMint(_msgSender(), (i + totalSupply));
        }
    }

    function activateProxyMint() external onlyOwner {
        mintActive=true;
    }

    function deactivateProxyMint() external onlyOwner {
        mintActive=false;
    }
}