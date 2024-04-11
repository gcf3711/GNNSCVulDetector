 

 

 

 

 
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

 
interface IERC721Enumerable is IERC721 {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 
interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;
         
         
        mapping(bytes32 => uint256) _indexes;
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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                 
                set._values[toDeleteIndex] = lastvalue;
                 
                set._indexes[lastvalue] = valueIndex;  
            }

             
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
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


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

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a & b) + (a ^ b) / 2;
    }

     
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return a / b + (a % b == 0 ? 0 : 1);
    }
}


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

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
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

contract Dogface2ndStaking is Ownable, IERC721Receiver, ReentrancyGuard, Pausable {
    using EnumerableSet for EnumerableSet.UintSet; 

     
    address public stakingToken;  
    address public rewardToken;  
    uint256 public rate = 0.001735 ether;  
    uint256 public expiration;
    uint256 private dailyBonusTime ;
  
     
    mapping(address => EnumerableSet.UintSet) private _deposits;
    mapping(address => mapping(uint256 => uint256)) public _depositBlocks;
    mapping(address => StakingData) public _stakeData;
    mapping(address => bool) public _isMintbonus;
    
    uint256[] bounsRate = [350 ether , 900 ether , 1500 ether , 1900 ether, 2500 ether, 4000 ether];
     
    struct StakingData{
        address owner;
        uint256 lastStakeTime;
        uint256 firstStakingTime;
        uint256 stakedCounts;
        uint256[] stakedTokenIds;
        uint256 totalRewards;
    }

     
    event UnStake(address owner, uint256[] tokenIds, uint256 time);
    event Stake(address owner, uint256[] tokenIds, uint256 time);
    event Claim(address owner, uint256 amount, uint256 time);

    constructor(address _stakingToken,  address _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        dailyBonusTime = block.timestamp;
        _pause();
    }

    function setStakingToken(address _stakingToken) public onlyOwner() {
        stakingToken = _stakingToken;
    }

    function setRewardToken(address _rewardToken) public onlyOwner() {
        rewardToken = _rewardToken;
    }
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

     
    function setRate(uint256 _rate) public onlyOwner() {
      rate = _rate;
    }

     
    function setExpiration(uint256 _expiration) public onlyOwner() {
      expiration = block.number + _expiration;
    }

    function _removeItemFromArray(uint256[] storage arr, uint256 item) private {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == item) {
                for (uint256 j = i; j < arr.length - 1; j++) {
                    arr[j] = arr[j+1];
                }

                delete arr[arr.length - 1];
                arr.pop();

                break;
            }
        }
    }

    function isStakeable(uint256[] calldata tokenIds) private view returns(bool status) {
        status = true;
        for(uint i = 0; i < tokenIds.length; i++){
            if(IERC721(stakingToken).ownerOf(tokenIds[i]) != msg.sender){
                status = false;
            }
        }
        return status;
    }

    function indexOf(uint256[] memory arr, uint256 searchFor) private pure returns (bool) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == searchFor) {
            return true;
            }
        }
        return false;
    }
    
    function isUnstakeable(uint256[] calldata tokenIds) private view returns(bool status) {
        status = true;
        for(uint i = 0; i < tokenIds.length; i++){
            if(!indexOf(_stakeData[msg.sender].stakedTokenIds , tokenIds[i])){
                status = false;
            }
        }
        return status;
    }

     
    function stake(uint256[] calldata tokenIds) external whenNotPaused {
        require(msg.sender != stakingToken, "Staking token and sender is same.");
        require(tokenIds.length > 0, "Token number is not correct.");
        require(isStakeable(tokenIds) , "Token id is not correct.");

        if(_isMintbonus[msg.sender] != true){
            IERC20(rewardToken).transfer(msg.sender , tokenIds.length * 1000 ether);
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            IERC721(stakingToken).safeTransferFrom(msg.sender, address(this), tokenIds[i], "");
            _stakeData[msg.sender].stakedTokenIds.push(tokenIds[i]);
        }

        uint256 _totalRewards = computeRewards() ;
        _isMintbonus[msg.sender] = true;
        _stakeData[msg.sender] = StakingData(
            msg.sender ,
            _stakeData[msg.sender].firstStakingTime > 0 ? _stakeData[msg.sender].firstStakingTime : block.timestamp ,
            block.timestamp , 
            (_stakeData[msg.sender].stakedCounts + tokenIds.length),
            _stakeData[msg.sender].stakedTokenIds,
            _totalRewards
        );

        emit Stake(msg.sender , tokenIds , block.timestamp);
    }

     

    function getStakeData(address account) public view returns(StakingData memory){
        return _stakeData[account];
    }

     
    function unstake(uint256[] calldata tokenIds) external whenNotPaused {
        require(msg.sender != stakingToken, "Staking token and sender is same.");
        require(tokenIds.length > 0, "Token number is not correct.");
        require(isUnstakeable(tokenIds) , "Token id is not correct.");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            IERC721(stakingToken).safeTransferFrom(address(this), msg.sender, tokenIds[i], "");
            _removeItemFromArray(_stakeData[msg.sender].stakedTokenIds , tokenIds[i]);
        }

        uint256 _totalRewards = computeRewards();

        _stakeData[msg.sender] = StakingData(
            msg.sender ,
            _stakeData[msg.sender].firstStakingTime,
            block.timestamp , 
            (_stakeData[msg.sender].stakedCounts - tokenIds.length),
            _stakeData[msg.sender].stakedTokenIds,
            _totalRewards
        );

        emit UnStake(msg.sender , tokenIds , block.timestamp);
    }

     
    function unstakeAll() external whenNotPaused {
        require(msg.sender != stakingToken, "Staking token and sender is same.");
        
        for (uint256 i = 0; i < _stakeData[msg.sender].stakedTokenIds.length; i++) {
            IERC721(stakingToken).safeTransferFrom(address(this), msg.sender, _stakeData[msg.sender].stakedTokenIds[i], "");
        }

        uint256 _totalRewards = computeRewards();
        uint256[] memory empty;
        _stakeData[msg.sender] = StakingData(
            msg.sender ,
            _stakeData[msg.sender].firstStakingTime,
            block.timestamp , 
            0,
            empty,
            _totalRewards
        );

        emit UnStake(msg.sender , _stakeData[msg.sender].stakedTokenIds , block.timestamp);
    }
     
    function computeRewards() private view returns (uint256 rewards) {
        require(msg.sender != address(0), "Address is invalid");
        StakingData memory stakeData = _stakeData[msg.sender];
        if(stakeData.owner != address(0)){
            uint256 _count = stakeData.stakedCounts;
            uint256 _bounsRate = _count >= 4 && _count <= 9 ? bounsRate[0] : _count >= 10 && _count <= 14? bounsRate[1] : _count >= 15 && _count <= 19 ? bounsRate[2] : _count >= 20 && _count <= 24 ? bounsRate[3] : _count >= 25 && _count <=29 ? bounsRate[4] : _count >= 30 ? bounsRate[5] : 0 ether;
            uint256 _bouns = (uint((block.timestamp - dailyBonusTime) / 86400) - uint((stakeData.lastStakeTime - dailyBonusTime) / 86400)) * _bounsRate;
            rewards = stakeData.totalRewards + stakeData.stakedCounts * rate * (block.timestamp - stakeData.lastStakeTime);
            return (rewards + _bouns);
        } else{
            return 0;
        }
    }

     
    function calculateRewards(address account) public view returns (uint256 rewards) {
        require(account != address(0), "Address is invalid");
        StakingData memory stakeData = _stakeData[account];
        uint256 _count = stakeData.stakedCounts;
        uint256 _bounsRate = _count >= 4 && _count <= 9 ? bounsRate[0] : _count >= 10 && _count <= 14? bounsRate[1] : _count >= 15 && _count <= 19 ? bounsRate[2] : _count >= 20 && _count <= 24 ? bounsRate[3] : _count >= 25 && _count <=29 ? bounsRate[4] : _count >= 30 ? bounsRate[5] : 0 ether;
        uint256 _bouns = (uint((block.timestamp - dailyBonusTime) / 86400) - uint((stakeData.lastStakeTime - dailyBonusTime) / 86400)) * _bounsRate;
        rewards = stakeData.totalRewards + stakeData.stakedCounts * rate * (block.timestamp - stakeData.lastStakeTime);
        return rewards + _bouns;
    }

     
    function claimRewards() public whenNotPaused {
        require(msg.sender != address(0), "Address is invalid");
        uint256 _totalRewards = computeRewards();
        require(_totalRewards > 0, "You have no rewards.");
        
        if(_totalRewards > 0){
            IERC20(rewardToken).transfer(msg.sender, _totalRewards);
            _stakeData[msg.sender].totalRewards = 0 ;
            _stakeData[msg.sender].lastStakeTime = block.timestamp;

            emit Claim(msg.sender , _totalRewards , block.timestamp);
        }
    }

     
    function depositsOf(address account) external view returns (uint256[] memory) {
      EnumerableSet.UintSet storage depositSet = _deposits[account];
      uint256[] memory tokenIds = new uint256[] (depositSet.length());

      for (uint256 i; i < depositSet.length(); i++) {
        tokenIds[i] = depositSet.at(i);
      }

      return tokenIds;
    }

     
    function withdrawTokens() external onlyOwner {
        uint256 _totalTokens = IERC20(rewardToken).balanceOf(address(this));
        IERC20(rewardToken).transfer(msg.sender, _totalTokens);
    }

    function onERC721Received(address,address,uint256,bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}