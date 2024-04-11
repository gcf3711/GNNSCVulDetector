 


 
 

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



 
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function decimals() external view returns (uint8);
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






 
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

     
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

     
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

     
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

     
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

     
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

     
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

     
    uint256[45] private __gap;
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

 
pragma solidity 0.8.7;







interface IMaticX is IERC20Upgradeable {
	struct WithdrawalRequest {
		uint256 validatorNonce;
		uint256 requestEpoch;
		address validatorAddress;
	}

	struct FeeDistribution {
		uint8 treasury;
		uint8 insurance;
	}

	function validatorRegistry() external returns (IValidatorRegistry);

	function entityFees() external returns (uint8, uint8);

	function version() external view returns (string memory);

	function insurance() external view returns (address);

	function token() external view returns (address);

	function feePercent() external view returns (uint8);

	function initialize(
		address _validatorRegistry,
		address _stakeManager,
		address _token,
		address _manager,
		address _instant_pool_manager,
		address _treasury,
		address _insurance
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

	function setFees(uint8 _treasuryFee, uint8 _insuranceFee) external;

	function setFeePercent(uint8 _feePercent) external;

	function setInstantPoolOwner(address _address) external;

	function setInsuranceAddress(address _address) external;

	function setValidatorRegistryAddress(address _address) external;

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

	function getInstantPoolMatic() external view returns (uint256);

	function getInstantPoolMaticX() external view returns (uint256);

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
	event SetFees(uint8 _treasuryFee, uint8 _insuranceFee);
	event SetFeePercent(uint8 _feePercent);
	event SetInstantPoolOwner(address _address);
	event SetTreasuryAddress(address _address);
	event SetInsuranceAddress(address _address);
	event SetValidatorRegistryAddress(address _address);
	event SetVersion(string _version);
}
 
pragma solidity 0.8.7;












contract MaticX is
	IMaticX,
	ERC20Upgradeable,
	AccessControlUpgradeable,
	PausableUpgradeable
{
	 
	using SafeERC20Upgradeable for IERC20Upgradeable;

	IValidatorRegistry public override validatorRegistry;
	IStakeManager public stakeManager;
	FeeDistribution public override entityFees;

	string public override version;
	 
	address public treasury;
	 
	address public override insurance;
	address public override token;
	address public proposed_manager;
	address public manager;

	
	mapping(address => WithdrawalRequest[]) private userWithdrawalRequests;

	bytes32 public constant INSTANT_POOL_OWNER = keccak256("IPO");

	uint8 public override feePercent;
	address public instantPoolOwner;
	uint256 public instantPoolMatic;
	uint256 public instantPoolMaticX;

	 
	function initialize(
		address _validatorRegistry,
		address _stakeManager,
		address _token,
		address _manager,
		address _instantPoolOwner,
		address _treasury,
		address _insurance
	) external override initializer {
		__AccessControl_init();
		__Pausable_init();
		__ERC20_init("Liquid Staking Matic Test", "tMaticX");

		_setupRole(DEFAULT_ADMIN_ROLE, _manager);
		manager = _manager;
		_setupRole(INSTANT_POOL_OWNER, _instantPoolOwner);
		instantPoolOwner = _instantPoolOwner;

		validatorRegistry = IValidatorRegistry(_validatorRegistry);
		stakeManager = IStakeManager(_stakeManager);
		treasury = _treasury;
		token = _token;
		insurance = _insurance;

		entityFees = FeeDistribution(100, 0);
		feePercent = 5;
	}

	 
	 
	 
	 
	 

	 
	function provideInstantPoolMatic(uint256 _amount)
		external
		override
		whenNotPaused
		onlyRole(INSTANT_POOL_OWNER)
	{
		require(_amount > 0, "Invalid amount");
		IERC20Upgradeable(token).safeTransferFrom(
			msg.sender,
			address(this),
			_amount
		);

		instantPoolMatic += _amount;
	}

	function provideInstantPoolMaticX(uint256 _amount)
		external
		override
		whenNotPaused
		onlyRole(INSTANT_POOL_OWNER)
	{
		require(_amount > 0, "Invalid amount");
		IERC20Upgradeable(address(this)).safeTransferFrom(
			msg.sender,
			address(this),
			_amount
		);

		instantPoolMaticX += _amount;
	}

	function withdrawInstantPoolMaticX(uint256 _amount)
		external
		override
		whenNotPaused
		onlyRole(INSTANT_POOL_OWNER)
	{
		require(
			instantPoolMaticX >= _amount,
			"Withdraw amount cannot exceed maticX in instant pool"
		);

		instantPoolMaticX -= _amount;
		IERC20Upgradeable(address(this)).safeTransfer(
			instantPoolOwner,
			_amount
		);
	}

	function withdrawInstantPoolMatic(uint256 _amount)
		external
		override
		whenNotPaused
		onlyRole(INSTANT_POOL_OWNER)
	{
		require(
			instantPoolMatic >= _amount,
			"Withdraw amount cannot exceed matic in instant pool"
		);

		instantPoolMatic -= _amount;
		IERC20Upgradeable(token).safeTransfer(instantPoolOwner, _amount);
	}

	 
	function mintMaticXToInstantPool()
		external
		override
		whenNotPaused
		onlyRole(INSTANT_POOL_OWNER)
	{
		require(instantPoolMatic > 0, "Matic amount cannot be 0");

		uint256 maticxMinted = helper_delegate_to_mint(
			address(this),
			instantPoolMatic
		);
		instantPoolMaticX += maticxMinted;
		instantPoolMatic = 0;
	}

	function swapMaticForMaticXViaInstantPool(uint256 _amount)
		external
		override
		whenNotPaused
	{
		require(_amount > 0, "Invalid amount");
		IERC20Upgradeable(token).safeTransferFrom(
			msg.sender,
			address(this),
			_amount
		);

		(uint256 amountToMint, , ) = convertMaticToMaticX(_amount);
		require(
			instantPoolMaticX >= amountToMint,
			"Not enough maticX to instant swap"
		);

		IERC20Upgradeable(address(this)).safeTransfer(msg.sender, amountToMint);
		instantPoolMatic += _amount;
		instantPoolMaticX -= amountToMint;
	}

	 
	 
	 
	 
	 

	 
	function submit(uint256 _amount)
		external
		override
		whenNotPaused
		returns (uint256)
	{
		require(_amount > 0, "Invalid amount");

		IERC20Upgradeable(token).safeTransferFrom(
			msg.sender,
			address(this),
			_amount
		);

		return helper_delegate_to_mint(msg.sender, _amount);
	}

	 
	function safeApprove() external {
		IERC20Upgradeable(token).safeApprove(
			address(stakeManager),
			type(uint256).max
		);
	}

	 
	function requestWithdraw(uint256 _amount) external override whenNotPaused {
		require(_amount > 0, "Invalid amount");

		(uint256 totalAmount2WithdrawInMatic, , ) = convertMaticXToMatic(
			_amount
		);

		_burn(msg.sender, _amount);

		uint256 leftAmount2WithdrawInMatic = totalAmount2WithdrawInMatic;
		uint256 totalDelegated = getTotalStakeAcrossAllValidators();

		require(
			totalDelegated >= totalAmount2WithdrawInMatic,
			"Too much to withdraw"
		);

		uint256[] memory validators = validatorRegistry.getValidators();
		uint256 preferredValidatorId = validatorRegistry
			.getPreferredWithdrawalValidatorId();
		uint256 currentIdx = 0;
		for (; currentIdx < validators.length; ++currentIdx) {
			if (preferredValidatorId == validators[currentIdx]) break;
		}

		while (leftAmount2WithdrawInMatic > 0) {
			uint256 validatorId = validators[currentIdx];

			address validatorShare = stakeManager.getValidatorContract(
				validatorId
			);
			(uint256 validatorBalance, ) = getTotalStake(
				IValidatorShare(validatorShare)
			);

			uint256 amount2WithdrawFromValidator = (validatorBalance <=
				leftAmount2WithdrawInMatic)
				? validatorBalance
				: leftAmount2WithdrawInMatic;

			IValidatorShare(validatorShare).sellVoucher_new(
				amount2WithdrawFromValidator,
				type(uint256).max
			);

			userWithdrawalRequests[msg.sender].push(
				WithdrawalRequest(
					IValidatorShare(validatorShare).unbondNonces(address(this)),
					stakeManager.epoch() + stakeManager.withdrawalDelay(),
					validatorShare
				)
			);

			leftAmount2WithdrawInMatic -= amount2WithdrawFromValidator;
			currentIdx = currentIdx + 1 < validators.length
				? currentIdx + 1
				: 0;
		}

		emit RequestWithdraw(msg.sender, _amount, totalAmount2WithdrawInMatic);
	}

	 
	function claimWithdrawal(uint256 _idx) external override whenNotPaused {
		_claimWithdrawal(msg.sender, _idx);
	}

	function withdrawRewards(uint256 _validatorId)
		public
		override
		whenNotPaused
		returns (uint256)
	{
		address validatorShare = stakeManager.getValidatorContract(
			_validatorId
		);

		uint256 balanceBeforeRewards = IERC20Upgradeable(token).balanceOf(
			address(this)
		);
		IValidatorShare(validatorShare).withdrawRewards();
		uint256 rewards = IERC20Upgradeable(token).balanceOf(address(this)) -
			balanceBeforeRewards;

		emit WithdrawRewards(_validatorId, rewards);

		return rewards;
	}

	function stakeRewardsAndDistributeFees(uint256 _validatorId)
		external
		override
		whenNotPaused
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		require(
			validatorRegistry.isRegisteredValidatorId(_validatorId),
			"Doesn't exist in validator registry"
		);

		address validatorShare = stakeManager.getValidatorContract(
			_validatorId
		);

		uint256 rewards = IERC20Upgradeable(token).balanceOf(address(this)) -
			instantPoolMatic;

		require(rewards > 0, "Reward is zero");

		uint256 treasuryFees = (rewards * feePercent * entityFees.treasury) /
			10000;
		uint256 insuranceFees = (rewards * feePercent * entityFees.insurance) /
			10000;

		if (treasuryFees > 0) {
			IERC20Upgradeable(token).safeTransfer(treasury, treasuryFees);
			emit DistributeFees(treasury, treasuryFees);
		}

		if (insuranceFees > 0) {
			IERC20Upgradeable(token).safeTransfer(insurance, insuranceFees);
			emit DistributeFees(insurance, insuranceFees);
		}

		uint256 amountStaked = rewards - treasuryFees - insuranceFees;
		IValidatorShare(validatorShare).buyVoucher(amountStaked, 0);

		emit StakeRewards(_validatorId, amountStaked);
	}

	 
	function migrateDelegation(
		uint256 _fromValidatorId,
		uint256 _toValidatorId,
		uint256 _amount
	) external override whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
		require(
			validatorRegistry.isRegisteredValidatorId(_fromValidatorId),
			"From validator id does not exist in our registry"
		);
		require(
			validatorRegistry.isRegisteredValidatorId(_toValidatorId),
			"To validator id does not exist in our registry"
		);

		stakeManager.migrateDelegation(
			_fromValidatorId,
			_toValidatorId,
			_amount
		);

		emit MigrateDelegation(_fromValidatorId, _toValidatorId, _amount);
	}

	 
	function togglePause() external override onlyRole(DEFAULT_ADMIN_ROLE) {
		paused() ? _unpause() : _pause();
	}

	 
	function getTotalStake(IValidatorShare _validatorShare)
		public
		view
		override
		returns (uint256, uint256)
	{
		return _validatorShare.getTotalStake(address(this));
	}

	 
	 
	 
	 
	 

	function helper_delegate_to_mint(address deposit_sender, uint256 _amount)
		internal
		whenNotPaused
		returns (uint256)
	{
		(uint256 amountToMint, , ) = convertMaticToMaticX(_amount);

		_mint(deposit_sender, amountToMint);
		emit Submit(deposit_sender, _amount);

		uint256 preferredValidatorId = validatorRegistry
			.getPreferredDepositValidatorId();
		address validatorShare = stakeManager.getValidatorContract(
			preferredValidatorId
		);
		IValidatorShare(validatorShare).buyVoucher(_amount, 0);

		emit Delegate(preferredValidatorId, _amount);
		return amountToMint;
	}

	 
	function _claimWithdrawal(address _to, uint256 _idx)
		internal
		returns (uint256)
	{
		uint256 amountToClaim = 0;
		uint256 balanceBeforeClaim = IERC20Upgradeable(token).balanceOf(
			address(this)
		);
		WithdrawalRequest[] storage userRequests = userWithdrawalRequests[_to];
		WithdrawalRequest memory userRequest = userRequests[_idx];
		require(
			stakeManager.epoch() >= userRequest.requestEpoch,
			"Not able to claim yet"
		);

		IValidatorShare(userRequest.validatorAddress).unstakeClaimTokens_new(
			userRequest.validatorNonce
		);

		 
		userRequests[_idx] = userRequests[userRequests.length - 1];
		userRequests.pop();

		amountToClaim =
			IERC20Upgradeable(token).balanceOf(address(this)) -
			balanceBeforeClaim;

		IERC20Upgradeable(token).safeTransfer(_to, amountToClaim);

		emit ClaimWithdrawal(_to, _idx, amountToClaim);

		return amountToClaim;
	}

	 
	function convertMaticXToMatic(uint256 _balance)
		public
		view
		override
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		uint256 totalShares = totalSupply();
		totalShares = totalShares == 0 ? 1 : totalShares;

		uint256 totalPooledMATIC = getTotalPooledMatic();
		totalPooledMATIC = totalPooledMATIC == 0 ? 1 : totalPooledMATIC;

		uint256 balanceInMATIC = (_balance * (totalPooledMATIC)) / totalShares;

		return (balanceInMATIC, totalShares, totalPooledMATIC);
	}

	 
	function convertMaticToMaticX(uint256 _balance)
		public
		view
		override
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		uint256 totalShares = totalSupply();
		totalShares = totalShares == 0 ? 1 : totalShares;

		uint256 totalPooledMatic = getTotalPooledMatic();
		totalPooledMatic = totalPooledMatic == 0 ? 1 : totalPooledMatic;

		uint256 balanceInMaticX = (_balance * totalShares) / totalPooledMatic;

		return (balanceInMaticX, totalShares, totalPooledMatic);
	}

	 
	 
	 
	 
	 

	 
	function setFees(uint8 _treasuryFee, uint8 _insuranceFee)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		require(
			_treasuryFee + _insuranceFee == 100,
			"sum(fee) is not equal to 100"
		);
		entityFees.treasury = _treasuryFee;
		entityFees.insurance = _insuranceFee;

		emit SetFees(_treasuryFee, _insuranceFee);
	}

	 
	function setFeePercent(uint8 _feePercent)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		require(_feePercent <= 100, "_feePercent must not exceed 100");

		feePercent = _feePercent;

		emit SetFeePercent(_feePercent);
	}

	function setInstantPoolOwner(address _address)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		instantPoolOwner = _address;
		_setupRole(INSTANT_POOL_OWNER, _address);

		emit SetInstantPoolOwner(_address);
	}

	 
	function setTreasuryAddress(address _address)
		external
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		treasury = _address;

		emit SetTreasuryAddress(_address);
	}

	 
	function setInsuranceAddress(address _address)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		insurance = _address;

		emit SetInsuranceAddress(_address);
	}

	 
	function setValidatorRegistryAddress(address _address)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		validatorRegistry = IValidatorRegistry(_address);

		emit SetValidatorRegistryAddress(_address);
	}

	 
	function setVersion(string calldata _version)
		external
		override
		onlyRole(DEFAULT_ADMIN_ROLE)
	{
		version = _version;

		emit SetVersion(_version);
	}

	 
	 
	 
	 
	 

	 
	function getTotalStakeAcrossAllValidators()
		public
		view
		override
		returns (uint256)
	{
		uint256 totalStake;
		uint256[] memory validators = validatorRegistry.getValidators();
		for (uint256 i = 0; i < validators.length; ++i) {
			address validatorShare = stakeManager.getValidatorContract(
				validators[i]
			);
			(uint256 currValidatorShare, ) = getTotalStake(
				IValidatorShare(validatorShare)
			);

			totalStake += currValidatorShare;
		}

		return totalStake;
	}

	 
	function getTotalPooledMatic() public view override returns (uint256) {
		uint256 totalStaked = getTotalStakeAcrossAllValidators();
		return totalStaked;
	}

	 
	function getUserWithdrawalRequests(address _address)
		external
		view
		override
		returns (WithdrawalRequest[] memory)
	{
		return userWithdrawalRequests[_address];
	}

	 
	function getSharesAmountOfUserWithdrawalRequest(
		address _address,
		uint256 _idx
	) external view override returns (uint256) {
		WithdrawalRequest memory userRequest = userWithdrawalRequests[_address][
			_idx
		];
		IValidatorShare validatorShare = IValidatorShare(
			userRequest.validatorAddress
		);
		IValidatorShare.DelegatorUnbond memory unbond = validatorShare
			.unbonds_new(address(this), userRequest.validatorNonce);

		return unbond.shares;
	}

	function getInstantPoolMatic() external view override returns (uint256) {
		return instantPoolMatic;
	}

	function getInstantPoolMaticX() external view override returns (uint256) {
		return instantPoolMaticX;
	}
}

 
 

pragma solidity ^0.8.0;




 
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
         
         
         
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

     
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

 
pragma solidity 0.8.7;



interface IValidatorRegistry {
	function addValidator(uint256 _validatorId) external;

	function removeValidator(uint256 _validatorId) external;

	function setPreferredDepositValidatorId(uint256 _validatorId) external;

	function setPreferredWithdrawalValidatorId(uint256 _validatorId) external;

	function setMaticX(address _maticX) external;

	function setVersion(string memory _version) external;

	function togglePause() external;

	function getContracts()
		external
		view
		returns (
			address _stakeManager,
			address _polygonERC20,
			address _maticX
		);

	function getValidators() external view returns (uint256[] memory);

	function getValidatorId(uint256 _index) external view returns (uint256);

	function getPreferredDepositValidatorId() external view returns (uint256);

	function getPreferredWithdrawalValidatorId()
		external
		view
		returns (uint256);

	function isRegisteredValidatorId(uint256 _validatorId)
		external
		returns (bool);

	event AddValidator(uint256 indexed _validatorId);
	event RemoveValidator(uint256 indexed _validatorId);
	event SetPreferredDepositValidatorId(uint256 indexed _validatorId);
	event SetPreferredWithdrawalValidatorId(uint256 indexed _validatorId);
	event SetMaticX(address _address);
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
