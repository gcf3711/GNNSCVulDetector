
 

 

pragma solidity ^0.5.0;

 
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity ^0.5.16;


 
contract DAONFT is Ownable {
     
    event Mint(uint256 indexed tokenId, address to);
     
    event Burn(uint256 indexed tokenId);
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
     
    event TokenURISet(uint256 tokenId, string tokenURI);

     
    uint256[] public tokens;
     
    mapping(address => uint256) public tokenOwned;
     
    mapping(uint256 => address) public ownerOf;
     
    mapping(uint256 => string) private tokenURIs;
     
    string public name;
     
    string public symbol;

     
    constructor(string memory _name, string memory _symbol) public {
        name = _name;
        symbol = _symbol;
    }

     
    modifier isValidAddress(address to) {
        require(to != address(0), "Method called with the zero address");
        _;
    }

     
    function balanceOf(address owner) public view isValidAddress(owner) returns (uint256) {
        return tokenOwned[owner] > 0 ? 1 : 0;
    }

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public isValidAddress(to) isValidAddress(from) onlyOwner {
        require(tokenOwned[to] == 0, "Destination address already owns a token");
        require(ownerOf[tokenId] == from, "From address does not own token");

        tokenOwned[from] = 0;
        tokenOwned[to] = tokenId;

        ownerOf[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

     
    function mint(address to, uint256 tokenId) public onlyOwner isValidAddress(to) {
        _mint(to, tokenId);
    }

     
    function mintWithTokenURI(
        address to,
        uint256 tokenId,
        string memory uri
    ) public onlyOwner isValidAddress(to) {
        require(bytes(uri).length > 0, "URI must be supplied");

        _mint(to, tokenId);

        tokenURIs[tokenId] = uri;
        emit TokenURISet(tokenId, uri);
    }

    function _mint(address to, uint256 tokenId) private {
        require(tokenOwned[to] == 0, "Destination address already owns a token");
        require(ownerOf[tokenId] == address(0), "ERC721: token already minted");
        require(tokenId != 0, "Token ID must be greater than 0");

        tokens.push(tokenId);
        tokenOwned[to] = tokenId;
        ownerOf[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
        emit Mint(tokenId, to);
    }

     
    function burn(uint256 tokenId) public onlyOwner {
        address previousOwner = ownerOf[tokenId];
        require(previousOwner != address(0), "ERC721: token does not exist");

        delete tokenOwned[previousOwner];
        delete ownerOf[tokenId];

        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                break;
            }
        }

        tokens.pop();

        if (bytes(tokenURIs[tokenId]).length != 0) {
            delete tokenURIs[tokenId];
        }

        emit Burn(tokenId);
    }

     
    function totalSupply() public view returns (uint256) {
        return tokens.length;
    }

     
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(ownerOf[tokenId] != address(0), "ERC721: token does not exist");
        string memory _tokenURI = tokenURIs[tokenId];
        return _tokenURI;
    }

     
    function setTokenURI(uint256 tokenId, string memory uri) public onlyOwner {
        require(ownerOf[tokenId] != address(0), "ERC721: token does not exist");
        tokenURIs[tokenId] = uri;
        emit TokenURISet(tokenId, uri);
    }
}