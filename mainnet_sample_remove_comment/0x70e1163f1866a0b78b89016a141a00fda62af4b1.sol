 


 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

     
    function transferFrom(address from, address to, uint256 tokenId) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

 

pragma solidity >=0.6.0 <0.8.0;



 
abstract contract ERC165 is IERC165 {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
         
         
        _registerInterface(_INTERFACE_ID_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC721Enumerable is IERC721 {

     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC721Metadata is IERC721 {

     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;













 
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

     
     
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

     
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

     
    EnumerableMap.UintToAddressMap private _tokenOwners;

     
    mapping (uint256 => address) private _tokenApprovals;

     
    mapping (address => mapping (address => bool)) private _operatorApprovals;

     
    string private _name;

     
    string private _symbol;

     
    mapping (uint256 => string) private _tokenURIs;

     
    string private _baseURI;

     
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

     
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

     
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

     
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

         
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

     
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

     
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

         
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
         
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
         
        return string(abi.encodePacked(base, tokenId.toString()));
    }

     
    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

     
    function totalSupply() public view virtual override returns (uint256) {
         
        return _tokenOwners.length();
    }

     
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

     
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

     
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);  

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        _approve(address(0), tokenId);

         
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

     
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");  
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

     
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

     
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }

     
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

     
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);  
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}
 
pragma solidity >=0.6.0;





contract EtherWorlds is ERC721, Ownable {
  using Counters for Counters.Counter;

  string public constant md5_win86 = "7f0e66b532c247f3851f690662a02d4c";
  string public constant md5_win64 = "b28c3797224ec93ea6c3e604342737e6";
  string public constant md5_portable = "91498913be6a22fd8b5571231ad19b47";
  
  uint256 public constant SALE_START_TIMESTAMP = 1618070400;
  uint256 public constant CONTEST_SIGNUP_END_TIMESTAMP = SALE_START_TIMESTAMP + (86400 * 3);
  uint256 public constant CONTEST_END_TIMESTAMP = SALE_START_TIMESTAMP + (86400 * 7);
  uint256 public constant REWARD_RELEASE_TIMESTAMP = SALE_START_TIMESTAMP + (86400 * 14);
  uint256 public constant SALE_NFT_SUPPLY = 3072;
  uint256 public constant CONTEST_NFT_SUPPLY = 32;
  uint256 public constant CONTEST_MAX_PARTICIPANTS = 256;
  uint256 public constant ALL_NFT_SUPPLY = SALE_NFT_SUPPLY + CONTEST_NFT_SUPPLY;

  mapping (address => bool) public mintedNft;
  address[] public contestParticipants;
  Counters.Counter public contestNftMinted;
  mapping (address => bool) public claimedReward;
  Counters.Counter public rewardsClaimedByLastPlaceOwners;

  Counters.Counter[] public contestTokens;
   
  mapping (address => uint) public contestShiftedIndexOf;

  constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
    _setBaseURI(baseURI);
  }

  function saleStarted() public view returns (bool) {
    return block.timestamp >= SALE_START_TIMESTAMP;
  }
  function contestSignUpEnded() public view returns (bool) {
    return block.timestamp >= CONTEST_SIGNUP_END_TIMESTAMP;
  }
  function contestEnded() public view returns (bool) {
    return block.timestamp >= CONTEST_END_TIMESTAMP;
  }
  function rewardsReleased() public view returns (bool) {
    return block.timestamp >= REWARD_RELEASE_TIMESTAMP;
  }

  function totalSold() public view returns (uint256) {
    return totalSupply() - contestNftMinted.current();
  }

  function getMaxAmountToMint() public view returns (uint256) {
    uint256 currentSupply = totalSold();

    if (currentSupply >= 320) {
      return 32;
    } 
    else if (currentSupply >= 64) {
      return 16;
    } 
    else {
      return 1;
    }
  }

  function getPrice() public view returns (uint256) {
    uint currentSupply = totalSold();

    if (currentSupply >= 3008) {
      return 5000000000000000000;  
    } else if (currentSupply >= 2880) {
      return 1000000000000000000;  
    } else if (currentSupply >= 2368) {
      return 800000000000000000;  
    } else if (currentSupply >= 1344) {
      return 500000000000000000;  
    } else if (currentSupply >= 832) {
      return 300000000000000000;  
    } else if (currentSupply >= 320) {
      return 200000000000000000;  
    } else if (currentSupply >= 64) {
      return 100000000000000000;  
    } else {
      return 20000000000000000;  
    }
  }

  function mint(uint256 numberOfNft) public payable {
    require(saleStarted(), "Sale has not started yet.");
    require(totalSold() < SALE_NFT_SUPPLY, "Sale has already ended.");
    require(numberOfNft > 0, "Cannot mint less than 1.");
    require(numberOfNft <= getMaxAmountToMint(), "Minting as many NFTs is not permitted.");
    require(SafeMath.add(totalSold(), numberOfNft) <= SALE_NFT_SUPPLY, "Cannot mint as many NFTs as it would exceed the maximum supply.");
    require(SafeMath.mul(getPrice(), numberOfNft) <= msg.value, "Not enough Ether.");

    for (uint i = 0; i < numberOfNft; i++) {
      _safeMint(msg.sender, _generateSeed(false));
    }

    mintedNft[msg.sender] = true;
  }

  function contestBalanceOf(address owner) public view returns (uint256) {
    require(owner != address(0), "Balance query for the zero address.");

    uint index = contestShiftedIndexOf[owner];
    require(index > 0, "You are not signed up.");

    return contestTokens[index - 1].current();
  }

  function signUp() public {
    require(mintedNft[msg.sender], "Only NFT minters may participate.");
    require(contestShiftedIndexOf[msg.sender] == 0, "You are already signed in.");
    require(!contestSignUpEnded(), "Sign up period has ended.");
    require(contestParticipants.length < CONTEST_MAX_PARTICIPANTS, "There is already a maximum number of participants.");

    contestTokens.push(Counters.Counter(balanceOf(msg.sender)));
    contestShiftedIndexOf[msg.sender] = contestTokens.length;
    contestParticipants.push(msg.sender);
  }

  function getNumberOfParticipants() public view returns (uint256) {
    return contestParticipants.length;
  }

  function getPlaceOf(address owner) public view returns (uint _place, uint _howManyWithSamePlace) {
    uint ownerBalance = contestBalanceOf(owner);
    uint length = contestTokens.length;
    uint place = 0;
    uint lastMax = ALL_NFT_SUPPLY;

    for (uint i = 0; i < length; i++) {
      uint currentMax = 0;
      uint currentMaxDuplicates = 0;

      for (uint j = 0; j < length; j++) {
        uint currentValue = contestTokens[j].current();
        if (currentValue == currentMax) {
          currentMaxDuplicates++;
        }
        if (currentValue > currentMax && currentValue < lastMax) {
          currentMax = currentValue;
          currentMaxDuplicates = 0;
        }
      }

      place++;

      if (ownerBalance == currentMax) {
        return (place, currentMaxDuplicates + 1);
      }

      lastMax = currentMax;
      place += currentMaxDuplicates;
    }

    return (place, 0);
  }

  function claimReward() public {
    require(contestEnded(), "It is not permitted to claim the reward yet.");
    require(SafeMath.add(contestNftMinted.current(), 1) <= CONTEST_NFT_SUPPLY, "Cannot mint as many NFTs as it would exceed the maximum supply.");

    if (!rewardsReleased()) {
      (uint place, uint howManyOwners) = getPlaceOf(msg.sender);

      require(place <= CONTEST_NFT_SUPPLY, "You are not permitted to claim the reward.");
      require(!claimedReward[msg.sender], "You already claimed the reward.");

      bool isLastPlace = place + howManyOwners > CONTEST_NFT_SUPPLY;

      if (isLastPlace) {
        require(rewardsClaimedByLastPlaceOwners.current() <= CONTEST_NFT_SUPPLY - place, "Rewards for last qualified place are already claimed :c");
      }

      claimedReward[msg.sender] = true;
      if (isLastPlace) {
        rewardsClaimedByLastPlaceOwners.increment();
      }
    }

    _safeMint(msg.sender, _generateSeed(true));
    contestNftMinted.increment();
  }

  function withdraw() onlyOwner public {
    uint balance = address(this).balance;
    msg.sender.transfer(balance);
  }

  function setBaseURI(string memory baseURI) onlyOwner public {
    _setBaseURI(baseURI);
  }

  function _generateSeed(bool isReward) private view returns (uint256) {
    uint256 seed = uint256(keccak256(abi.encodePacked(msg.sender, totalSupply(), block.timestamp)));
    seed = seed - seed % 10;
    seed += isReward ? 1 : 0;
    return seed;
  }

  function _beforeTokenTransfer(address from, address to, uint256) internal override {
    if (!contestEnded()) {
      uint fromShiftedIndex = contestShiftedIndexOf[from];
      uint toShiftedIndex = contestShiftedIndexOf[to];
      if (from != address(0) && fromShiftedIndex > 0) {
        contestTokens[fromShiftedIndex - 1].decrement();
      }
      if (to != address(0) && toShiftedIndex > 0) {
        contestTokens[toShiftedIndex - 1].increment();
      }
    }
  }

  function renounceOwnership() public view override onlyOwner {
    revert("Action not permitted.");
  }
  function transferOwnership(address) public view override onlyOwner {
    revert("Action not permitted.");
  }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeMath {
     
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

     
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

     
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
         
         
         
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

     
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

     
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

 

pragma solidity >=0.6.2 <0.8.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

         
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

 

pragma solidity >=0.6.0 <0.8.0;



 
library Counters {
    using SafeMath for uint256;

    struct Counter {
         
         
         
        uint256 _value;  
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
         
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableMap {
     
     
     
     
     
     
     
     

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
         
        MapEntry[] _entries;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
         
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) {  
            map._entries.push(MapEntry({ _key: key, _value: value }));
             
             
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

     
    function _remove(Map storage map, bytes32 key) private returns (bool) {
         
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;

             
             

            MapEntry storage lastEntry = map._entries[lastIndex];

             
            map._entries[toDeleteIndex] = lastEntry;
             
            map._indexes[lastEntry._key] = toDeleteIndex + 1;  

             
            map._entries.pop();

             
            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

     
    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

    
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

     
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0);  
        return (true, map._entries[keyIndex - 1]._value);  
    }

     
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key");  
        return map._entries[keyIndex - 1]._value;  
    }

     
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage);  
        return map._entries[keyIndex - 1]._value;  
    }

     

    struct UintToAddressMap {
        Map _inner;
    }

     
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

     
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

     
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

     
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

     
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

     
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

     
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct Bytes32Set {
        Set _inner;
    }

     
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

     
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

     
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

     
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library Strings {
     
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}
