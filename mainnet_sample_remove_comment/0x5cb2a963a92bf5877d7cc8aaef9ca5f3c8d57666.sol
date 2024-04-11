 


 
 

pragma solidity ^0.8.0;



 
abstract contract Initializable {
     
    bool private _initialized;

     
    bool private _initializing;

     
    modifier initializer() {
         
         
         
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

     
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

 
 

pragma solidity ^0.8.0;

 
interface IERC165Upgradeable {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 
 

pragma solidity ^0.8.0;


 
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

     
    uint256[50] private __gap;
}

 
 

pragma solidity ^0.8.0;

 
interface IAccessControlUpgradeable {
     
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

     
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

     
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

     
    function hasRole(bytes32 role, address account) external view returns (bool);

     
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

     
    function grantRole(bytes32 role, address account) external;

     
    function revokeRole(bytes32 role, address account) external;

     
    function renounceRole(bytes32 role, address account) external;
}

 
 

pragma solidity ^0.8.0;




 
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

     
    uint256[50] private __gap;
}

 
 

pragma solidity ^0.8.0;




 
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

     
    uint256[49] private __gap;
}

 
 

pragma solidity ^0.8.0;







 
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

     
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

     
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

     
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

     
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

     
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

     
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

     
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

     
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

     
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

     
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

     
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

     
    uint256[49] private __gap;
}

 
 

pragma solidity ^0.8.0;


 
abstract contract ReentrancyGuardUpgradeable is Initializable {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }

     
    uint256[49] private __gap;
}

 
pragma solidity 0.8.7;



interface IValidatorRegistry {
	function addValidator(uint256 _validatorId) external;

	function removeValidator(uint256 _validatorId) external;

	function setPreferredDepositValidatorId(uint256 _validatorId) external;

	function setPreferredWithdrawalValidatorId(uint256 _validatorId) external;

	function setMaticX(address _maticX) external;

	function setVersion(string memory _version) external;

	function togglePause() external;

	function version() external view returns (string memory);

	function preferredDepositValidatorId() external view returns (uint256);

	function preferredWithdrawalValidatorId() external view returns (uint256);

	function validatorIdExists(uint256 _validatorId)
		external
		view
		returns (bool);

	function getContracts()
		external
		view
		returns (
			address _stakeManager,
			address _polygonERC20,
			address _maticX
		);

	function getValidatorId(uint256 _index) external view returns (uint256);

	function getValidators() external view returns (uint256[] memory);

	event AddValidator(uint256 indexed _validatorId);
	event RemoveValidator(uint256 indexed _validatorId);
	event SetPreferredDepositValidatorId(uint256 indexed _validatorId);
	event SetPreferredWithdrawalValidatorId(uint256 indexed _validatorId);
	event SetMaticX(address _address);
	event SetVersion(string _version);
}

 
 

pragma solidity ^0.8.0;

 
interface IERC20Upgradeable {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address to, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
pragma solidity 0.8.7;












contract ValidatorRegistry is
	IValidatorRegistry,
	PausableUpgradeable,
	AccessControlUpgradeable,
	ReentrancyGuardUpgradeable
{
	address private stakeManager;
	address private polygonERC20;
	address private maticX;

	string public override version;
	uint256 public override preferredDepositValidatorId;
	uint256 public override preferredWithdrawalValidatorId;
	mapping(uint256 => bool) public override validatorIdExists;

	uint256[] private validators;

	 

	
	function initialize(
		address _stakeManager,
		address _polygonERC20,
		address _maticX,
		address _manager
	) external initializer {
		__AccessControl_init();
		__Pausable_init();

		stakeManager = _stakeManager;
		polygonERC20 = _polygonERC20;
		maticX = _maticX;

		_setupRole(DEFAULT_ADMIN_ROLE, _manager);
	}

	 

	
	 
	
	function addValidator(uint256 _validatorId)
		external
		override
		whenNotPaused
		whenValidatorIdDoesNotExist(_validatorId)
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		IStakeManager.Validator memory smValidator = IStakeManager(stakeManager)
			.validators(_validatorId);

		require(
			smValidator.contractAddress != address(0),
			"Validator has no ValidatorShare"
		);
		require(
			(smValidator.status == IStakeManager.Status.Active) &&
				smValidator.deactivationEpoch == 0,
			"Validator isn't ACTIVE"
		);

		validators.push(_validatorId);
		validatorIdExists[_validatorId] = true;

		emit AddValidator(_validatorId);
	}

	
	
	function removeValidator(uint256 _validatorId)
		external
		override
		whenNotPaused
		whenValidatorIdExists(_validatorId)
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		require(
			preferredDepositValidatorId != _validatorId,
			"Can't remove a preferred validator for deposits"
		);
		require(
			preferredWithdrawalValidatorId != _validatorId,
			"Can't remove a preferred validator for withdrawals"
		);

		address validatorShare = IStakeManager(stakeManager)
			.getValidatorContract(_validatorId);
		(uint256 validatorBalance, ) = IValidatorShare(validatorShare)
			.getTotalStake(address(this));
		require(validatorBalance == 0, "Validator has some shares left");

		 
		uint256 validatorsLength = validators.length;
		for (uint256 idx = 0; idx < validatorsLength - 1; ++idx) {
			if (_validatorId == validators[idx]) {
				validators[idx] = validators[validatorsLength - 1];
				break;
			}
		}
		validators.pop();

		delete validatorIdExists[_validatorId];

		emit RemoveValidator(_validatorId);
	}

	 

	
	
	function setPreferredDepositValidatorId(uint256 _validatorId)
		external
		override
		whenNotPaused
		whenValidatorIdExists(_validatorId)
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		preferredDepositValidatorId = _validatorId;

		emit SetPreferredDepositValidatorId(_validatorId);
	}

	
	
	function setPreferredWithdrawalValidatorId(uint256 _validatorId)
		external
		override
		whenNotPaused
		whenValidatorIdExists(_validatorId)
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		preferredWithdrawalValidatorId = _validatorId;

		emit SetPreferredWithdrawalValidatorId(_validatorId);
	}

	
	function setMaticX(address _maticX)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		maticX = _maticX;

		emit SetMaticX(_maticX);
	}

	
	
	function setVersion(string memory _version)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		version = _version;

		emit SetVersion(_version);
	}

	
	function togglePause() external override onlyRole(DEFAULT_ADMIN_ROLE) {
		paused() ? _unpause() : _pause();
	}

	 

	
	function getContracts()
		external
		view
		override
		returns (
			address _stakeManager,
			address _polygonERC20,
			address _maticX
		)
	{
		_stakeManager = stakeManager;
		_polygonERC20 = polygonERC20;
		_maticX = maticX;
	}

	
	
	function getValidatorId(uint256 _index)
		external
		view
		override
		returns (uint256)
	{
		return validators[_index];
	}

	
	function getValidators() external view override returns (uint256[] memory) {
		return validators;
	}

	 

	 
	modifier whenValidatorIdExists(uint256 _validatorId) {
		require(
			validatorIdExists[_validatorId] == true,
			"Validator id doesn't exist in our registry"
		);
		_;
	}

	 
	modifier whenValidatorIdDoesNotExist(uint256 _validatorId) {
		require(
			validatorIdExists[_validatorId] == false,
			"Validator id already exists in our registry"
		);
		_;
	}
}

 
pragma solidity 0.8.7;







interface IMaticX is IERC20Upgradeable {
	struct WithdrawalRequest {
		uint256 validatorNonce;
		uint256 requestEpoch;
		address validatorAddress;
	}

	function version() external view returns (string memory);

	function treasury() external view returns (address);

	function feePercent() external view returns (uint8);

	function instantPoolOwner() external view returns (address);

	function instantPoolMatic() external view returns (uint256);

	function instantPoolMaticX() external view returns (uint256);

	function initialize(
		address _validatorRegistry,
		address _stakeManager,
		address _token,
		address _manager,
		address _instant_pool_manager,
		address _treasury
	) external;

	function provideInstantPoolMatic(uint256 _amount) external;

	function provideInstantPoolMaticX(uint256 _amount) external;

	function withdrawInstantPoolMaticX(uint256 _amount) external;

	function withdrawInstantPoolMatic(uint256 _amount) external;

	function mintMaticXToInstantPool() external;

	function swapMaticForMaticXViaInstantPool(uint256 _amount) external;

	function submit(uint256 _amount) external returns (uint256);

	function requestWithdraw(uint256 _amount) external;

	function claimWithdrawal(uint256 _idx) external;

	function withdrawRewards(uint256 _validatorId) external returns (uint256);

	function stakeRewardsAndDistributeFees(uint256 _validatorId) external;

	function migrateDelegation(
		uint256 _fromValidatorId,
		uint256 _toValidatorId,
		uint256 _amount
	) external;

	function togglePause() external;

	function convertMaticXToMatic(uint256 _balance)
		external
		view
		returns (
			uint256,
			uint256,
			uint256
		);

	function convertMaticToMaticX(uint256 _balance)
		external
		view
		returns (
			uint256,
			uint256,
			uint256
		);

	function setFeePercent(uint8 _feePercent) external;

	function setInstantPoolOwner(address _address) external;

	function setValidatorRegistry(address _address) external;

	function setTreasury(address _address) external;

	function setVersion(string calldata _version) external;

	function getUserWithdrawalRequests(address _address)
		external
		view
		returns (WithdrawalRequest[] memory);

	function getSharesAmountOfUserWithdrawalRequest(
		address _address,
		uint256 _idx
	) external view returns (uint256);

	function getTotalStake(IValidatorShare _validatorShare)
		external
		view
		returns (uint256, uint256);

	function getTotalStakeAcrossAllValidators() external view returns (uint256);

	function getTotalPooledMatic() external view returns (uint256);

	function getContracts()
		external
		view
		returns (
			address _stakeManager,
			address _polygonERC20,
			address _validatorRegistry
		);

	event Submit(address indexed _from, uint256 _amount);
	event Delegate(uint256 indexed _validatorId, uint256 _amountDelegated);
	event RequestWithdraw(
		address indexed _from,
		uint256 _amountMaticX,
		uint256 _amountMatic
	);
	event ClaimWithdrawal(
		address indexed _from,
		uint256 indexed _idx,
		uint256 _amountClaimed
	);
	event WithdrawRewards(uint256 indexed _validatorId, uint256 _rewards);
	event StakeRewards(uint256 indexed _validatorId, uint256 _amountStaked);
	event DistributeFees(address indexed _address, uint256 _amount);
	event MigrateDelegation(
		uint256 indexed _fromValidatorId,
		uint256 indexed _toValidatorId,
		uint256 _amount
	);
	event SetFeePercent(uint8 _feePercent);
	event SetInstantPoolOwner(address _address);
	event SetTreasury(address _address);
	event SetValidatorRegistry(address _address);
	event SetVersion(string _version);
}

 
pragma solidity 0.8.7;



interface IStakeManager {
	
	
	function unstake(uint256 validatorId) external;

	
	
	
	function getValidatorId(address user) external view returns (uint256);

	
	
	
	function getValidatorContract(uint256 validatorId)
		external
		view
		returns (address);

	
	
	function withdrawRewards(uint256 validatorId) external;

	
	
	function validatorStake(uint256 validatorId)
		external
		view
		returns (uint256);

	
	
	function unstakeClaim(uint256 validatorId) external;

	
	
	
	
	function migrateDelegation(
		uint256 fromValidatorId,
		uint256 toValidatorId,
		uint256 amount
	) external;

	
	function withdrawalDelay() external view returns (uint256);

	
	function delegationDeposit(
		uint256 validatorId,
		uint256 amount,
		address delegator
	) external returns (bool);

	function epoch() external view returns (uint256);

	enum Status {
		Inactive,
		Active,
		Locked,
		Unstaked
	}

	struct Validator {
		uint256 amount;
		uint256 reward;
		uint256 activationEpoch;
		uint256 deactivationEpoch;
		uint256 jailTime;
		address signer;
		address contractAddress;
		Status status;
		uint256 commissionRate;
		uint256 lastCommissionUpdate;
		uint256 delegatorsReward;
		uint256 delegatedAmount;
		uint256 initialRewardPerStake;
	}

	function validators(uint256 _index)
		external
		view
		returns (Validator memory);

	 
	function createValidator(uint256 _validatorId) external;
}

 
 

pragma solidity ^0.8.1;

 
library AddressUpgradeable {
     
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

 
library StringsUpgradeable {
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

 
pragma solidity 0.8.7;

interface IValidatorShare {
	struct DelegatorUnbond {
		uint256 shares;
		uint256 withdrawEpoch;
	}

	function minAmount() external view returns (uint256);

	function unbondNonces(address _address) external view returns (uint256);

	function validatorId() external view returns (uint256);

	function delegation() external view returns (bool);

	function buyVoucher(uint256 _amount, uint256 _minSharesToMint)
		external
		returns (uint256);

	function sellVoucher_new(uint256 claimAmount, uint256 maximumSharesToBurn)
		external;

	function unstakeClaimTokens_new(uint256 unbondNonce) external;

	function restake() external returns (uint256, uint256);

	function withdrawRewards() external;

	function getTotalStake(address user)
		external
		view
		returns (uint256, uint256);

	function unbonds_new(address _address, uint256 _unbondNonce)
		external
		view
		returns (DelegatorUnbond memory);
}