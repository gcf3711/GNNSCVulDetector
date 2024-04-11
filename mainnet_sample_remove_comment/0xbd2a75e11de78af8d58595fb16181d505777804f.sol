 

 

 

pragma solidity ^0.5.0;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity ^0.5.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity ^0.5.0;


 
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) public view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) public view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
     
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

 

pragma solidity ^0.5.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

 
pragma solidity >=0.5.17;

interface ISTokensManager {
	 
	event Minted(
		uint256 tokenId,
		address owner,
		address property,
		uint256 amount,
		uint256 price
	);

	 
	event Updated(
		uint256 tokenId,
		uint256 amount,
		uint256 price,
		uint256 cumulativeReward,
		uint256 pendingReward
	);

	 
	function initialize(address _config) external;

	 
	function mint(
		address _owner,
		address _property,
		uint256 _amount,
		uint256 _price
	) external returns (uint256);

	 
	function update(
		uint256 _tokenId,
		uint256 _amount,
		uint256 _price,
		uint256 _cumulativeReward,
		uint256 _pendingReward
	) external returns (bool);

	 
	function positions(uint256 _tokenId)
		external
		view
		returns (
			address,
			uint256,
			uint256,
			uint256,
			uint256
		);

	 
	function rewards(uint256 _tokenId)
		external
		view
		returns (
			uint256,
			uint256,
			uint256
		);

	 
	function positionsOfProperty(address _property)
		external
		view
		returns (uint256[] memory);

	 
	function positionsOfOwner(address _owner)
		external
		view
		returns (uint256[] memory);
}

 

pragma solidity 0.5.17;


 
library Decimals {
	using SafeMath for uint256;
	uint120 private constant BASIS_VAKUE = 1000000000000000000;

	 
	function outOf(uint256 _a, uint256 _b)
		internal
		pure
		returns (uint256 result)
	{
		if (_a == 0) {
			return 0;
		}
		uint256 a = _a.mul(BASIS_VAKUE);
		if (a < _b) {
			return 0;
		}
		return (a.div(_b));
	}

	 
	function mulBasis(uint256 _a) internal pure returns (uint256) {
		return _a.mul(BASIS_VAKUE);
	}

	 
	function divBasis(uint256 _a) internal pure returns (uint256) {
		return _a.div(BASIS_VAKUE);
	}
}

 

 
pragma solidity >=0.5.17;

interface IAddressConfig {
	function token() external view returns (address);

	function allocator() external view returns (address);

	function allocatorStorage() external view returns (address);

	function withdraw() external view returns (address);

	function withdrawStorage() external view returns (address);

	function marketFactory() external view returns (address);

	function marketGroup() external view returns (address);

	function propertyFactory() external view returns (address);

	function propertyGroup() external view returns (address);

	function metricsGroup() external view returns (address);

	function metricsFactory() external view returns (address);

	function policy() external view returns (address);

	function policyFactory() external view returns (address);

	function policySet() external view returns (address);

	function policyGroup() external view returns (address);

	function lockup() external view returns (address);

	function lockupStorage() external view returns (address);

	function voteTimes() external view returns (address);

	function voteTimesStorage() external view returns (address);

	function voteCounter() external view returns (address);

	function voteCounterStorage() external view returns (address);

	function setAllocator(address _addr) external;

	function setAllocatorStorage(address _addr) external;

	function setWithdraw(address _addr) external;

	function setWithdrawStorage(address _addr) external;

	function setMarketFactory(address _addr) external;

	function setMarketGroup(address _addr) external;

	function setPropertyFactory(address _addr) external;

	function setPropertyGroup(address _addr) external;

	function setMetricsFactory(address _addr) external;

	function setMetricsGroup(address _addr) external;

	function setPolicyFactory(address _addr) external;

	function setPolicyGroup(address _addr) external;

	function setPolicySet(address _addr) external;

	function setPolicy(address _addr) external;

	function setToken(address _addr) external;

	function setLockup(address _addr) external;

	function setLockupStorage(address _addr) external;

	function setVoteTimes(address _addr) external;

	function setVoteTimesStorage(address _addr) external;

	function setVoteCounter(address _addr) external;

	function setVoteCounterStorage(address _addr) external;
}

 

pragma solidity 0.5.17;


 
contract UsingConfig {
	address private _config;

	 
	constructor(address _addressConfig) public {
		_config = _addressConfig;
	}

	 
	function config() internal view returns (IAddressConfig) {
		return IAddressConfig(_config);
	}

	 
	function configAddress() external view returns (address) {
		return _config;
	}
}

 

 
pragma solidity >=0.5.17;

interface IUsingStorage {
	function getStorageAddress() external view returns (address);

	function createStorage() external;

	function setStorage(address _storageAddress) external;

	function changeOwner(address newOwner) external;
}

 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.5.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

 

pragma solidity 0.5.17;

 
contract EternalStorage {
	address private currentOwner = msg.sender;

	mapping(bytes32 => uint256) private uIntStorage;
	mapping(bytes32 => string) private stringStorage;
	mapping(bytes32 => address) private addressStorage;
	mapping(bytes32 => bytes32) private bytesStorage;
	mapping(bytes32 => bool) private boolStorage;
	mapping(bytes32 => int256) private intStorage;

	 
	modifier onlyCurrentOwner() {
		require(msg.sender == currentOwner, "not current owner");
		_;
	}

	 
	function changeOwner(address _newOwner) external {
		require(msg.sender == currentOwner, "not current owner");
		currentOwner = _newOwner;
	}

	 

	 
	function getUint(bytes32 _key) external view returns (uint256) {
		return uIntStorage[_key];
	}

	 
	function getString(bytes32 _key) external view returns (string memory) {
		return stringStorage[_key];
	}

	 
	function getAddress(bytes32 _key) external view returns (address) {
		return addressStorage[_key];
	}

	 
	function getBytes(bytes32 _key) external view returns (bytes32) {
		return bytesStorage[_key];
	}

	 
	function getBool(bytes32 _key) external view returns (bool) {
		return boolStorage[_key];
	}

	 
	function getInt(bytes32 _key) external view returns (int256) {
		return intStorage[_key];
	}

	 

	 
	function setUint(bytes32 _key, uint256 _value) external onlyCurrentOwner {
		uIntStorage[_key] = _value;
	}

	 
	function setString(bytes32 _key, string calldata _value)
		external
		onlyCurrentOwner
	{
		stringStorage[_key] = _value;
	}

	 
	function setAddress(bytes32 _key, address _value)
		external
		onlyCurrentOwner
	{
		addressStorage[_key] = _value;
	}

	 
	function setBytes(bytes32 _key, bytes32 _value) external onlyCurrentOwner {
		bytesStorage[_key] = _value;
	}

	 
	function setBool(bytes32 _key, bool _value) external onlyCurrentOwner {
		boolStorage[_key] = _value;
	}

	 
	function setInt(bytes32 _key, int256 _value) external onlyCurrentOwner {
		intStorage[_key] = _value;
	}

	 

	 
	function deleteUint(bytes32 _key) external onlyCurrentOwner {
		delete uIntStorage[_key];
	}

	 
	function deleteString(bytes32 _key) external onlyCurrentOwner {
		delete stringStorage[_key];
	}

	 
	function deleteAddress(bytes32 _key) external onlyCurrentOwner {
		delete addressStorage[_key];
	}

	 
	function deleteBytes(bytes32 _key) external onlyCurrentOwner {
		delete bytesStorage[_key];
	}

	 
	function deleteBool(bytes32 _key) external onlyCurrentOwner {
		delete boolStorage[_key];
	}

	 
	function deleteInt(bytes32 _key) external onlyCurrentOwner {
		delete intStorage[_key];
	}
}

 

pragma solidity 0.5.17;




 
contract UsingStorage is Ownable, IUsingStorage {
	address private _storage;

	 
	modifier hasStorage() {
		require(_storage != address(0), "storage is not set");
		_;
	}

	 
	function eternalStorage()
		internal
		view
		hasStorage
		returns (EternalStorage)
	{
		return EternalStorage(_storage);
	}

	 
	function getStorageAddress() external view hasStorage returns (address) {
		return _storage;
	}

	 
	function createStorage() external onlyOwner {
		require(_storage == address(0), "storage is set");
		EternalStorage tmp = new EternalStorage();
		_storage = address(tmp);
	}

	 
	function setStorage(address _storageAddress) external onlyOwner {
		_storage = _storageAddress;
	}

	 
	function changeOwner(address newOwner) external onlyOwner {
		EternalStorage(_storage).changeOwner(newOwner);
	}
}

 

pragma solidity 0.5.17;



contract LockupStorage is UsingStorage {
	using SafeMath for uint256;

	uint256 private constant BASIS = 100000000000000000000000000000000;

	 
	function setStorageAllValue(uint256 _value) internal {
		bytes32 key = getStorageAllValueKey();
		eternalStorage().setUint(key, _value);
	}

	function getStorageAllValue() public view returns (uint256) {
		bytes32 key = getStorageAllValueKey();
		return eternalStorage().getUint(key);
	}

	function getStorageAllValueKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_allValue"));
	}

	 
	function setStorageValue(
		address _property,
		address _sender,
		uint256 _value
	) internal {
		bytes32 key = getStorageValueKey(_property, _sender);
		eternalStorage().setUint(key, _value);
	}

	function getStorageValue(address _property, address _sender)
		public
		view
		returns (uint256)
	{
		bytes32 key = getStorageValueKey(_property, _sender);
		return eternalStorage().getUint(key);
	}

	function getStorageValueKey(address _property, address _sender)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_value", _property, _sender));
	}

	 
	function setStoragePropertyValue(address _property, uint256 _value)
		internal
	{
		bytes32 key = getStoragePropertyValueKey(_property);
		eternalStorage().setUint(key, _value);
	}

	function getStoragePropertyValue(address _property)
		public
		view
		returns (uint256)
	{
		bytes32 key = getStoragePropertyValueKey(_property);
		return eternalStorage().getUint(key);
	}

	function getStoragePropertyValueKey(address _property)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_propertyValue", _property));
	}

	 
	function setStorageInterestPrice(address _property, uint256 _value)
		internal
	{
		 
		 
		eternalStorage().setUint(getStorageInterestPriceKey(_property), _value);
	}

	function getStorageInterestPrice(address _property)
		public
		view
		returns (uint256)
	{
		return eternalStorage().getUint(getStorageInterestPriceKey(_property));
	}

	function getStorageInterestPriceKey(address _property)
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_interestTotals", _property));
	}

	 
	function setStorageLastInterestPrice(
		address _property,
		address _user,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageLastInterestPriceKey(_property, _user),
			_value
		);
	}

	function getStorageLastInterestPrice(address _property, address _user)
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastInterestPriceKey(_property, _user)
			);
	}

	function getStorageLastInterestPriceKey(address _property, address _user)
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(
				abi.encodePacked("_lastLastInterestPrice", _property, _user)
			);
	}

	 
	function setStorageLastSameRewardsAmountAndBlock(
		uint256 _amount,
		uint256 _block
	) internal {
		uint256 record = _amount.mul(BASIS).add(_block);
		eternalStorage().setUint(
			getStorageLastSameRewardsAmountAndBlockKey(),
			record
		);
	}

	function getStorageLastSameRewardsAmountAndBlock()
		public
		view
		returns (uint256 _amount, uint256 _block)
	{
		uint256 record = eternalStorage().getUint(
			getStorageLastSameRewardsAmountAndBlockKey()
		);
		uint256 amount = record.div(BASIS);
		uint256 blockNumber = record.sub(amount.mul(BASIS));
		return (amount, blockNumber);
	}

	function getStorageLastSameRewardsAmountAndBlockKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_LastSameRewardsAmountAndBlock"));
	}

	 
	function setStorageCumulativeGlobalRewards(uint256 _value) internal {
		eternalStorage().setUint(
			getStorageCumulativeGlobalRewardsKey(),
			_value
		);
	}

	function getStorageCumulativeGlobalRewards() public view returns (uint256) {
		return eternalStorage().getUint(getStorageCumulativeGlobalRewardsKey());
	}

	function getStorageCumulativeGlobalRewardsKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_cumulativeGlobalRewards"));
	}

	 
	function setStoragePendingInterestWithdrawal(
		address _property,
		address _user,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStoragePendingInterestWithdrawalKey(_property, _user),
			_value
		);
	}

	function getStoragePendingInterestWithdrawal(
		address _property,
		address _user
	) public view returns (uint256) {
		return
			eternalStorage().getUint(
				getStoragePendingInterestWithdrawalKey(_property, _user)
			);
	}

	function getStoragePendingInterestWithdrawalKey(
		address _property,
		address _user
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked("_pendingInterestWithdrawal", _property, _user)
			);
	}

	 
	function setStorageDIP4GenesisBlock(uint256 _block) internal {
		eternalStorage().setUint(getStorageDIP4GenesisBlockKey(), _block);
	}

	function getStorageDIP4GenesisBlock() public view returns (uint256) {
		return eternalStorage().getUint(getStorageDIP4GenesisBlockKey());
	}

	function getStorageDIP4GenesisBlockKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_dip4GenesisBlock"));
	}

	 
	function setStorageLastStakedInterestPrice(
		address _property,
		address _user,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageLastStakedInterestPriceKey(_property, _user),
			_value
		);
	}

	function getStorageLastStakedInterestPrice(address _property, address _user)
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastStakedInterestPriceKey(_property, _user)
			);
	}

	function getStorageLastStakedInterestPriceKey(
		address _property,
		address _user
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked("_lastStakedInterestPrice", _property, _user)
			);
	}

	 
	function setStorageLastStakesChangedCumulativeReward(uint256 _value)
		internal
	{
		eternalStorage().setUint(
			getStorageLastStakesChangedCumulativeRewardKey(),
			_value
		);
	}

	function getStorageLastStakesChangedCumulativeReward()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastStakesChangedCumulativeRewardKey()
			);
	}

	function getStorageLastStakesChangedCumulativeRewardKey()
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(abi.encodePacked("_lastStakesChangedCumulativeReward"));
	}

	 
	function setStorageLastCumulativeHoldersRewardPrice(uint256 _holders)
		internal
	{
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardPriceKey(),
			_holders
		);
	}

	function getStorageLastCumulativeHoldersRewardPrice()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardPriceKey()
			);
	}

	function getStorageLastCumulativeHoldersRewardPriceKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("0lastCumulativeHoldersRewardPrice"));
	}

	 
	function setStorageLastCumulativeInterestPrice(uint256 _interest) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeInterestPriceKey(),
			_interest
		);
	}

	function getStorageLastCumulativeInterestPrice()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastCumulativeInterestPriceKey()
			);
	}

	function getStorageLastCumulativeInterestPriceKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("0lastCumulativeInterestPrice"));
	}

	 
	function setStorageLastCumulativeHoldersRewardAmountPerProperty(
		address _property,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
				_property
			),
			_value
		);
	}

	function getStorageLastCumulativeHoldersRewardAmountPerProperty(
		address _property
	) public view returns (uint256) {
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
					_property
				)
			);
	}

	function getStorageLastCumulativeHoldersRewardAmountPerPropertyKey(
		address _property
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked(
					"0lastCumulativeHoldersRewardAmountPerProperty",
					_property
				)
			);
	}

	 
	function setStorageLastCumulativeHoldersRewardPricePerProperty(
		address _property,
		uint256 _price
	) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersRewardPricePerPropertyKey(_property),
			_price
		);
	}

	function getStorageLastCumulativeHoldersRewardPricePerProperty(
		address _property
	) public view returns (uint256) {
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersRewardPricePerPropertyKey(
					_property
				)
			);
	}

	function getStorageLastCumulativeHoldersRewardPricePerPropertyKey(
		address _property
	) private pure returns (bytes32) {
		return
			keccak256(
				abi.encodePacked(
					"0lastCumulativeHoldersRewardPricePerProperty",
					_property
				)
			);
	}

	 
	function setStorageCap(uint256 _cap) internal {
		eternalStorage().setUint(getStorageCapKey(), _cap);
	}

	function getStorageCap() public view returns (uint256) {
		return eternalStorage().getUint(getStorageCapKey());
	}

	function getStorageCapKey() private pure returns (bytes32) {
		return keccak256(abi.encodePacked("_cap"));
	}

	 
	function setStorageCumulativeHoldersRewardCap(uint256 _value) internal {
		eternalStorage().setUint(
			getStorageCumulativeHoldersRewardCapKey(),
			_value
		);
	}

	function getStorageCumulativeHoldersRewardCap()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(getStorageCumulativeHoldersRewardCapKey());
	}

	function getStorageCumulativeHoldersRewardCapKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_cumulativeHoldersRewardCap"));
	}

	 
	function setStorageLastCumulativeHoldersPriceCap(uint256 _value) internal {
		eternalStorage().setUint(
			getStorageLastCumulativeHoldersPriceCapKey(),
			_value
		);
	}

	function getStorageLastCumulativeHoldersPriceCap()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageLastCumulativeHoldersPriceCapKey()
			);
	}

	function getStorageLastCumulativeHoldersPriceCapKey()
		private
		pure
		returns (bytes32)
	{
		return keccak256(abi.encodePacked("_lastCumulativeHoldersPriceCap"));
	}

	 
	function setStorageInitialCumulativeHoldersRewardCap(
		address _property,
		uint256 _value
	) internal {
		eternalStorage().setUint(
			getStorageInitialCumulativeHoldersRewardCapKey(_property),
			_value
		);
	}

	function getStorageInitialCumulativeHoldersRewardCap(address _property)
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageInitialCumulativeHoldersRewardCapKey(_property)
			);
	}

	function getStorageInitialCumulativeHoldersRewardCapKey(address _property)
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(
				abi.encodePacked(
					"_initialCumulativeHoldersRewardCap",
					_property
				)
			);
	}

	 
	function setStorageFallbackInitialCumulativeHoldersRewardCap(uint256 _value)
		internal
	{
		eternalStorage().setUint(
			getStorageFallbackInitialCumulativeHoldersRewardCapKey(),
			_value
		);
	}

	function getStorageFallbackInitialCumulativeHoldersRewardCap()
		public
		view
		returns (uint256)
	{
		return
			eternalStorage().getUint(
				getStorageFallbackInitialCumulativeHoldersRewardCapKey()
			);
	}

	function getStorageFallbackInitialCumulativeHoldersRewardCapKey()
		private
		pure
		returns (bytes32)
	{
		return
			keccak256(
				abi.encodePacked("_fallbackInitialCumulativeHoldersRewardCap")
			);
	}
}

 

 
pragma solidity >=0.5.17;

interface IDev {
	function deposit(address _to, uint256 _amount) external returns (bool);

	function depositFrom(
		address _from,
		address _to,
		uint256 _amount
	) external returns (bool);

	function fee(address _from, uint256 _amount) external returns (bool);
}

 

 
pragma solidity >=0.5.17;

interface IDevMinter {
	function mint(address account, uint256 amount) external returns (bool);

	function renounceMinter() external;
}

 

 
pragma solidity >=0.5.17;

interface IProperty {
	function author() external view returns (address);

	function changeAuthor(address _nextAuthor) external;

	function changeName(string calldata _name) external;

	function changeSymbol(string calldata _symbol) external;

	function withdraw(address _sender, uint256 _value) external;
}

 

 
pragma solidity >=0.5.17;

interface IPolicy {
	function rewards(uint256 _lockups, uint256 _assets)
		external
		view
		returns (uint256);

	function holdersShare(uint256 _amount, uint256 _lockups)
		external
		view
		returns (uint256);

	function authenticationFee(uint256 _assets, uint256 _propertyAssets)
		external
		view
		returns (uint256);

	function marketVotingBlocks() external view returns (uint256);

	function policyVotingBlocks() external view returns (uint256);

	function shareOfTreasury(uint256 _supply) external view returns (uint256);

	function treasury() external view returns (address);

	function capSetter() external view returns (address);
}

 

 
pragma solidity >=0.5.17;

interface IAllocator {
	function beforeBalanceChange(
		address _property,
		address _from,
		address _to
	) external;

	function calculateMaxRewardsPerBlock() external view returns (uint256);
}

 

 
pragma solidity >=0.5.17;

interface ILockup {
	function depositToProperty(address _property, uint256 _amount)
		external
		returns (uint256);

	function depositToPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);

	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external;

	function update() external;

	function withdraw(address _property, uint256 _amount) external;

	function withdrawByPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);

	function calculateCumulativeRewardPrices()
		external
		view
		returns (
			uint256 _reward,
			uint256 _holders,
			uint256 _interest,
			uint256 _holdersCap
		);

	function calculateRewardAmount(address _property)
		external
		view
		returns (uint256, uint256);

	 
	function calculateCumulativeHoldersRewardAmount(address _property)
		external
		view
		returns (uint256);

	function getPropertyValue(address _property)
		external
		view
		returns (uint256);

	function getAllValue() external view returns (uint256);

	function getValue(address _property, address _sender)
		external
		view
		returns (uint256);

	function calculateWithdrawableInterestAmount(
		address _property,
		address _user
	) external view returns (uint256);

	function calculateWithdrawableInterestAmountByPosition(uint256 _tokenId)
		external
		view
		returns (uint256);

	function cap() external view returns (uint256);

	function updateCap(uint256 _cap) external;

	function devMinter() external view returns (address);

	function sTokensManager() external view returns (address);

	function migrateToSTokens(address _property) external returns (uint256);
}

 

 
pragma solidity >=0.5.17;

interface IMetricsGroup {
	function addGroup(address _addr) external;

	function removeGroup(address _addr) external;

	function isGroup(address _addr) external view returns (bool);

	function totalIssuedMetrics() external view returns (uint256);

	function hasAssets(address _property) external view returns (bool);

	function getMetricsCountPerProperty(address _property)
		external
		view
		returns (uint256);

	function totalAuthenticatedProperties() external view returns (uint256);
}

 

pragma solidity 0.5.17;

 















 
contract Lockup is ILockup, UsingConfig, LockupStorage {
	using SafeMath for uint256;
	using Decimals for uint256;
	address public devMinter;
	address public sTokensManager;
	struct RewardPrices {
		uint256 reward;
		uint256 holders;
		uint256 interest;
		uint256 holdersCap;
	}
	event Lockedup(address _from, address _property, uint256 _value);
	event UpdateCap(uint256 _cap);

	 
	constructor(
		address _config,
		address _devMinter,
		address _sTokensManager
	) public UsingConfig(_config) {
		devMinter = _devMinter;
		sTokensManager = _sTokensManager;
	}

	 
	modifier onlyAuthenticatedProperty(address _property) {
		require(
			IMetricsGroup(config().metricsGroup()).hasAssets(_property),
			"unable to stake to unauthenticated property"
		);
		_;
	}

	 
	modifier onlyPositionOwner(uint256 _tokenId) {
		require(
			IERC721(sTokensManager).ownerOf(_tokenId) == msg.sender,
			"illegal sender"
		);
		_;
	}

	 
	function depositToProperty(address _property, uint256 _amount)
		external
		onlyAuthenticatedProperty(_property)
		returns (uint256)
	{
		 
		require(_amount != 0, "illegal deposit amount");
		 
		(
			uint256 reward,
			uint256 holders,
			uint256 interest,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();
		 
		updateValues(
			true,
			_property,
			_amount,
			RewardPrices(reward, holders, interest, holdersCap)
		);
		 
		require(
			IERC20(config().token()).transferFrom(
				msg.sender,
				_property,
				_amount
			),
			"dev transfer failed"
		);
		 
		uint256 tokenId = ISTokensManager(sTokensManager).mint(
			msg.sender,
			_property,
			_amount,
			interest
		);
		emit Lockedup(msg.sender, _property, _amount);
		return tokenId;
	}

	 
	function depositToPosition(uint256 _tokenId, uint256 _amount)
		external
		onlyPositionOwner(_tokenId)
		returns (bool)
	{
		 
		require(_amount != 0, "illegal deposit amount");
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		 
		(
			address property,
			uint256 amount,
			uint256 price,
			uint256 cumulativeReward,
			uint256 pendingReward
		) = sTokenManagerInstance.positions(_tokenId);
		 
		(
			uint256 withdrawable,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount(
				property,
				amount,
				price,
				pendingReward
			);
		 
		updateValues(true, property, _amount, prices);
		 
		require(
			IERC20(config().token()).transferFrom(
				msg.sender,
				property,
				_amount
			),
			"dev transfer failed"
		);
		 
		bool result = sTokenManagerInstance.update(
			_tokenId,
			amount.add(_amount),
			prices.interest,
			cumulativeReward.add(withdrawable),
			pendingReward.add(withdrawable)
		);
		require(result, "failed to update");
		 
		emit Lockedup(msg.sender, property, _amount);
		return true;
	}

	 
	function lockup(
		address _from,
		address _property,
		uint256 _value
	) external onlyAuthenticatedProperty(_property) {
		 
		require(msg.sender == config().token(), "this is illegal address");

		 
		require(_value != 0, "illegal lockup value");

		 
		RewardPrices memory prices = updatePendingInterestWithdrawal(
			_property,
			_from
		);

		 
		updateValues4Legacy(true, _from, _property, _value, prices);

		emit Lockedup(_from, _property, _value);
	}

	 
	function withdrawByPosition(uint256 _tokenId, uint256 _amount)
		external
		onlyPositionOwner(_tokenId)
		returns (bool)
	{
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		 
		(
			address property,
			uint256 amount,
			uint256 price,
			uint256 cumulativeReward,
			uint256 pendingReward
		) = sTokenManagerInstance.positions(_tokenId);
		 
		require(amount >= _amount, "insufficient tokens staked");
		 
		(uint256 value, RewardPrices memory prices) = _withdrawInterest(
			property,
			amount,
			price,
			pendingReward
		);
		 
		if (_amount != 0) {
			IProperty(property).withdraw(msg.sender, _amount);
		}
		 
		updateValues(false, property, _amount, prices);
		uint256 cumulative = cumulativeReward.add(value);
		 
		return
			sTokenManagerInstance.update(
				_tokenId,
				amount.sub(_amount),
				prices.interest,
				cumulative,
				0
			);
	}

	 
	function withdraw(address _property, uint256 _amount) external {
		 
		require(
			hasValue(_property, msg.sender, _amount),
			"insufficient tokens staked"
		);

		 
		RewardPrices memory prices = _withdrawInterest4Legacy(_property);

		 
		if (_amount != 0) {
			IProperty(_property).withdraw(msg.sender, _amount);
		}

		 
		updateValues4Legacy(false, msg.sender, _property, _amount, prices);
	}

	 
	function cap() external view returns (uint256) {
		return getStorageCap();
	}

	 
	function updateCap(uint256 _cap) external {
		address setter = IPolicy(config().policy()).capSetter();
		require(setter == msg.sender, "illegal access");

		 
		(
			,
			uint256 holdersPrice,
			,
			uint256 cCap
		) = calculateCumulativeRewardPrices();

		 
		setStorageCumulativeHoldersRewardCap(cCap);
		setStorageLastCumulativeHoldersPriceCap(holdersPrice);
		setStorageCap(_cap);
		emit UpdateCap(_cap);
	}

	 
	function _calculateLatestCap(uint256 _holdersPrice)
		private
		view
		returns (uint256)
	{
		uint256 cCap = getStorageCumulativeHoldersRewardCap();
		uint256 lastHoldersPrice = getStorageLastCumulativeHoldersPriceCap();
		uint256 additionalCap = _holdersPrice.sub(lastHoldersPrice).mul(
			getStorageCap()
		);
		return cCap.add(additionalCap);
	}

	 
	function beforeStakesChanged(address _property, RewardPrices memory _prices)
		private
	{
		 
		uint256 cHoldersReward = _calculateCumulativeHoldersRewardAmount(
			_prices.holders,
			_property
		);

		 
		if (
			getStorageLastCumulativeHoldersRewardPricePerProperty(_property) ==
			0 &&
			getStorageInitialCumulativeHoldersRewardCap(_property) == 0 &&
			getStoragePropertyValue(_property) == 0
		) {
			setStorageInitialCumulativeHoldersRewardCap(
				_property,
				_prices.holdersCap
			);
		}

		 
		setStorageLastStakesChangedCumulativeReward(_prices.reward);
		setStorageLastCumulativeHoldersRewardPrice(_prices.holders);
		setStorageLastCumulativeInterestPrice(_prices.interest);
		setStorageLastCumulativeHoldersRewardAmountPerProperty(
			_property,
			cHoldersReward
		);
		setStorageLastCumulativeHoldersRewardPricePerProperty(
			_property,
			_prices.holders
		);
		setStorageCumulativeHoldersRewardCap(_prices.holdersCap);
		setStorageLastCumulativeHoldersPriceCap(_prices.holders);
	}

	 
	function calculateCumulativeRewardPrices()
		public
		view
		returns (
			uint256 _reward,
			uint256 _holders,
			uint256 _interest,
			uint256 _holdersCap
		)
	{
		uint256 lastReward = getStorageLastStakesChangedCumulativeReward();
		uint256 lastHoldersPrice = getStorageLastCumulativeHoldersRewardPrice();
		uint256 lastInterestPrice = getStorageLastCumulativeInterestPrice();
		uint256 allStakes = getStorageAllValue();

		 
		(uint256 reward, ) = dry();
		uint256 mReward = reward.mulBasis();

		 
		uint256 price = allStakes > 0
			? mReward.sub(lastReward).div(allStakes)
			: 0;

		 
		uint256 holdersShare = IPolicy(config().policy()).holdersShare(
			price,
			allStakes
		);

		 
		uint256 holdersPrice = holdersShare.add(lastHoldersPrice);
		uint256 interestPrice = price.sub(holdersShare).add(lastInterestPrice);
		uint256 cCap = _calculateLatestCap(holdersPrice);
		return (mReward, holdersPrice, interestPrice, cCap);
	}

	 
	function _calculateCumulativeHoldersRewardAmount(
		uint256 _holdersPrice,
		address _property
	) private view returns (uint256) {
		(uint256 cHoldersReward, uint256 lastReward) = (
			getStorageLastCumulativeHoldersRewardAmountPerProperty(_property),
			getStorageLastCumulativeHoldersRewardPricePerProperty(_property)
		);

		 
		uint256 additionalHoldersReward = _holdersPrice.sub(lastReward).mul(
			getStoragePropertyValue(_property)
		);

		 
		return cHoldersReward.add(additionalHoldersReward);
	}

	 
	function calculateCumulativeHoldersRewardAmount(address _property)
		external
		view
		returns (uint256)
	{
		(, uint256 holders, , ) = calculateCumulativeRewardPrices();
		return _calculateCumulativeHoldersRewardAmount(holders, _property);
	}

	 
	function calculateRewardAmount(address _property)
		external
		view
		returns (uint256, uint256)
	{
		(
			,
			uint256 holders,
			,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();
		uint256 initialCap = _getInitialCap(_property);

		 
		uint256 capValue = holdersCap.sub(initialCap);
		return (
			_calculateCumulativeHoldersRewardAmount(holders, _property),
			capValue
		);
	}

	function _getInitialCap(address _property) private view returns (uint256) {
		uint256 initialCap = getStorageInitialCumulativeHoldersRewardCap(
			_property
		);
		if (initialCap > 0) {
			return initialCap;
		}

		 
		if (
			getStorageLastCumulativeHoldersRewardPricePerProperty(_property) >
			0 ||
			getStoragePropertyValue(_property) > 0
		) {
			return getStorageFallbackInitialCumulativeHoldersRewardCap();
		}
		return 0;
	}

	 
	function update() public {
		 
		(uint256 _nextRewards, uint256 _amount) = dry();

		 
		setStorageCumulativeGlobalRewards(_nextRewards);
		setStorageLastSameRewardsAmountAndBlock(_amount, block.number);
	}

	 
	function dry()
		private
		view
		returns (uint256 _nextRewards, uint256 _amount)
	{
		 
		uint256 rewardsAmount = IAllocator(config().allocator())
			.calculateMaxRewardsPerBlock();

		 
		(
			uint256 lastAmount,
			uint256 lastBlock
		) = getStorageLastSameRewardsAmountAndBlock();

		 
		uint256 lastMaxRewards = lastAmount == rewardsAmount
			? rewardsAmount
			: lastAmount;

		 
		uint256 blocks = lastBlock > 0 ? block.number.sub(lastBlock) : 0;

		 
		uint256 additionalRewards = lastMaxRewards.mul(blocks);
		uint256 nextRewards = getStorageCumulativeGlobalRewards().add(
			additionalRewards
		);

		 
		return (nextRewards, rewardsAmount);
	}

	 
	function _calculateInterestAmount(uint256 _amount, uint256 _price)
		private
		view
		returns (
			uint256 amount_,
			uint256 interestPrice_,
			RewardPrices memory prices_
		)
	{
		 
		(
			uint256 reward,
			uint256 holders,
			uint256 interest,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();

		 
		uint256 result = interest >= _price
			? interest.sub(_price).mul(_amount).divBasis()
			: 0;
		return (
			result,
			interest,
			RewardPrices(reward, holders, interest, holdersCap)
		);
	}

	 
	function _calculateInterestAmount4Legacy(address _property, address _user)
		private
		view
		returns (
			uint256 _amount,
			uint256 _interestPrice,
			RewardPrices memory _prices
		)
	{
		 
		uint256 lockedUpPerAccount = getStorageValue(_property, _user);

		 
		uint256 lastInterest = getStorageLastStakedInterestPrice(
			_property,
			_user
		);

		 
		(
			uint256 reward,
			uint256 holders,
			uint256 interest,
			uint256 holdersCap
		) = calculateCumulativeRewardPrices();

		 
		uint256 result = interest >= lastInterest
			? interest.sub(lastInterest).mul(lockedUpPerAccount).divBasis()
			: 0;
		return (
			result,
			interest,
			RewardPrices(reward, holders, interest, holdersCap)
		);
	}

	 
	function _calculateWithdrawableInterestAmount(
		address _property,
		uint256 _amount,
		uint256 _price,
		uint256 _pendingReward
	) private view returns (uint256 amount_, RewardPrices memory prices_) {
		 
		if (
			IMetricsGroup(config().metricsGroup()).hasAssets(_property) == false
		) {
			return (0, RewardPrices(0, 0, 0, 0));
		}

		 
		(
			uint256 amount,
			,
			RewardPrices memory prices
		) = _calculateInterestAmount(_amount, _price);

		 
		uint256 withdrawableAmount = amount.add(_pendingReward);
		return (withdrawableAmount, prices);
	}

	 
	function _calculateWithdrawableInterestAmount4Legacy(
		address _property,
		address _user
	) private view returns (uint256 _amount, RewardPrices memory _prices) {
		 
		if (
			IMetricsGroup(config().metricsGroup()).hasAssets(_property) == false
		) {
			return (0, RewardPrices(0, 0, 0, 0));
		}

		 
		uint256 pending = getStoragePendingInterestWithdrawal(_property, _user);

		 
		uint256 legacy = __legacyWithdrawableInterestAmount(_property, _user);

		 
		(
			uint256 amount,
			,
			RewardPrices memory prices
		) = _calculateInterestAmount4Legacy(_property, _user);

		 
		uint256 withdrawableAmount = amount.add(pending).add(legacy);
		return (withdrawableAmount, prices);
	}

	 
	function calculateWithdrawableInterestAmount(
		address _property,
		address _user
	) external view returns (uint256) {
		(uint256 amount, ) = _calculateWithdrawableInterestAmount4Legacy(
			_property,
			_user
		);
		return amount;
	}

	 
	function calculateWithdrawableInterestAmountByPosition(uint256 _tokenId)
		external
		view
		returns (uint256)
	{
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		(
			address property,
			uint256 amount,
			uint256 price,
			,
			uint256 pendingReward
		) = sTokenManagerInstance.positions(_tokenId);
		(uint256 result, ) = _calculateWithdrawableInterestAmount(
			property,
			amount,
			price,
			pendingReward
		);
		return result;
	}

	 
	function _withdrawInterest(
		address _property,
		uint256 _amount,
		uint256 _price,
		uint256 _pendingReward
	) private returns (uint256 value_, RewardPrices memory prices_) {
		 
		(
			uint256 value,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount(
				_property,
				_amount,
				_price,
				_pendingReward
			);

		 
		require(
			IDevMinter(devMinter).mint(msg.sender, value),
			"dev mint failed"
		);

		 
		update();

		return (value, prices);
	}

	 
	function _withdrawInterest4Legacy(address _property)
		private
		returns (RewardPrices memory _prices)
	{
		 
		(
			uint256 value,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount4Legacy(_property, msg.sender);

		 
		setStoragePendingInterestWithdrawal(_property, msg.sender, 0);

		 
		setStorageLastStakedInterestPrice(
			_property,
			msg.sender,
			prices.interest
		);
		__updateLegacyWithdrawableInterestAmount(_property, msg.sender);

		 
		require(
			IDevMinter(devMinter).mint(msg.sender, value),
			"dev mint failed"
		);

		 
		update();

		return prices;
	}

	 
	function updateValues4Legacy(
		bool _addition,
		address _account,
		address _property,
		uint256 _value,
		RewardPrices memory _prices
	) private {
		 
		setStorageLastStakedInterestPrice(
			_property,
			_account,
			_prices.interest
		);
		updateValues(_addition, _property, _value, _prices);
		 
		if (_addition) {
			addValue(_property, _account, _value);
		} else {
			subValue(_property, _account, _value);
		}
	}

	 
	function updateValues(
		bool _addition,
		address _property,
		uint256 _value,
		RewardPrices memory _prices
	) private {
		beforeStakesChanged(_property, _prices);
		 
		if (_addition) {
			 
			addAllValue(_value);

			 
			addPropertyValue(_property, _value);
			 
		} else {
			 
			subAllValue(_value);

			 
			subPropertyValue(_property, _value);
		}

		 
		update();
	}

	 
	function getAllValue() external view returns (uint256) {
		return getStorageAllValue();
	}

	 
	function addAllValue(uint256 _value) private {
		uint256 value = getStorageAllValue();
		value = value.add(_value);
		setStorageAllValue(value);
	}

	 
	function subAllValue(uint256 _value) private {
		uint256 value = getStorageAllValue();
		value = value.sub(_value);
		setStorageAllValue(value);
	}

	 
	function getValue(address _property, address _sender)
		external
		view
		returns (uint256)
	{
		return getStorageValue(_property, _sender);
	}

	 
	function addValue(
		address _property,
		address _sender,
		uint256 _value
	) private {
		uint256 value = getStorageValue(_property, _sender);
		value = value.add(_value);
		setStorageValue(_property, _sender, value);
	}

	 
	function subValue(
		address _property,
		address _sender,
		uint256 _value
	) private {
		uint256 value = getStorageValue(_property, _sender);
		value = value.sub(_value);
		setStorageValue(_property, _sender, value);
	}

	 
	function hasValue(
		address _property,
		address _sender,
		uint256 _amount
	) private view returns (bool) {
		uint256 value = getStorageValue(_property, _sender);
		return value >= _amount;
	}

	 
	function getPropertyValue(address _property)
		external
		view
		returns (uint256)
	{
		return getStoragePropertyValue(_property);
	}

	 
	function addPropertyValue(address _property, uint256 _value) private {
		uint256 value = getStoragePropertyValue(_property);
		value = value.add(_value);
		setStoragePropertyValue(_property, value);
	}

	 
	function subPropertyValue(address _property, uint256 _value) private {
		uint256 value = getStoragePropertyValue(_property);
		uint256 nextValue = value.sub(_value);
		setStoragePropertyValue(_property, nextValue);
	}

	 
	function updatePendingInterestWithdrawal(address _property, address _user)
		private
		returns (RewardPrices memory _prices)
	{
		 
		(
			uint256 withdrawableAmount,
			RewardPrices memory prices
		) = _calculateWithdrawableInterestAmount4Legacy(_property, _user);

		 
		setStoragePendingInterestWithdrawal(
			_property,
			_user,
			withdrawableAmount
		);

		 
		__updateLegacyWithdrawableInterestAmount(_property, _user);

		return prices;
	}

	 
	function __legacyWithdrawableInterestAmount(
		address _property,
		address _user
	) private view returns (uint256) {
		uint256 _last = getStorageLastInterestPrice(_property, _user);
		uint256 price = getStorageInterestPrice(_property);
		uint256 priceGap = price.sub(_last);
		uint256 lockedUpValue = getStorageValue(_property, _user);
		uint256 value = priceGap.mul(lockedUpValue);
		return value.divBasis();
	}

	 
	function __updateLegacyWithdrawableInterestAmount(
		address _property,
		address _user
	) private {
		uint256 interestPrice = getStorageInterestPrice(_property);
		if (getStorageLastInterestPrice(_property, _user) != interestPrice) {
			setStorageLastInterestPrice(_property, _user, interestPrice);
		}
	}

	function ___setFallbackInitialCumulativeHoldersRewardCap(uint256 _value)
		external
		onlyOwner
	{
		setStorageFallbackInitialCumulativeHoldersRewardCap(_value);
	}

	 
	function migrateToSTokens(address _property)
		external
		returns (uint256 tokenId_)
	{
		 
		uint256 amount = getStorageValue(_property, msg.sender);
		require(amount > 0, "not staked");
		 
		uint256 price = getStorageLastStakedInterestPrice(
			_property,
			msg.sender
		);
		 
		uint256 pending = getStoragePendingInterestWithdrawal(
			_property,
			msg.sender
		);
		 
		setStoragePendingInterestWithdrawal(_property, msg.sender, 0);
		 
		setStorageValue(_property, msg.sender, 0);
		ISTokensManager sTokenManagerInstance = ISTokensManager(sTokensManager);
		 
		uint256 tokenId = sTokenManagerInstance.mint(
			msg.sender,
			_property,
			amount,
			price
		);
		 
		bool result = sTokenManagerInstance.update(
			tokenId,
			amount,
			price,
			0,
			pending
		);
		require(result, "failed to update");
		return tokenId;
	}
}