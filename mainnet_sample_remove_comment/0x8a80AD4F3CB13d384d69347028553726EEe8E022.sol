 
pragma experimental ABIEncoderV2;


 

 
pragma solidity >=0.4.24 <0.8.0;


 
abstract contract Initializable {

     
    bool private _initialized;

     
    bool private _initializing;

     
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    
    function _isConstructor() private view returns (bool) {
         
         
         
         
         
        address self = address(this);
        uint256 cs;
         
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
    uint256[50] private __gap;
}

 

pragma solidity >=0.6.0 <0.8.0;






 
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

     
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

     
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

     
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

     
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

     
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

     
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

     
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

     
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

     
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

     
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

     
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

     
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract ReentrancyGuardUpgradeable is Initializable {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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

pragma solidity 0.7.6;


















 
abstract contract Future is Initializable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;

     
    struct Registration {
        uint256 startIndex;
        uint256 scaledBalance;
    }

    uint256[] internal registrationsTotals;

     
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant FUTURE_DEPLOYER = keccak256("FUTURE_DEPLOYER");

     
    mapping(address => uint256) internal lastPeriodClaimed;
    mapping(address => Registration) internal registrations;
    IFutureYieldToken[] public fyts;

     
    IFutureVault internal futureVault;
    IFutureWallet internal futureWallet;
    ILiquidityGauge internal liquidityGauge;
    ERC20 internal ibt;
    IAPWineIBT internal apwibt;
    IController internal controller;

     
    uint256 public PERIOD_DURATION;
    string public PLATFORM_NAME;

    bool public PAUSED;
    bool public WITHRAWALS_PAUSED;
    bool public DEPOSITS_PAUSED;

     
    event UserRegistered(address _userAddress, uint256 _amount, uint256 _periodIndex);
    event NewPeriodStarted(uint256 _newPeriodIndex, address _fytAddress);
    event FutureVaultSet(address _futureVault);
    event FutureWalletSet(address _futureWallet);
    event LiquidityGaugeSet(address _liquidityGauge);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PeriodsPaused();
    event PeriodsResumed();
    event DepositsPaused();
    event DepositsResumed();
    event WithdrawalsPaused();
    event WithdrawalsResumed();
    event APWIBTSet(address _apwibt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();

     
    modifier nextPeriodAvailable() {
        uint256 controllerDelay = controller.STARTING_DELAY();
        require(
            controller.getNextPeriodStart(PERIOD_DURATION) < block.timestamp.add(controllerDelay),
            "Next period start range not reached yet"
        );
        _;
    }

    modifier periodsActive() {
        require(!PAUSED, "New periods are currently paused");
        _;
    }

    modifier withdrawalsEnabled() {
        require(!WITHRAWALS_PAUSED, "withdrawals are disabled");
        _;
    }

    modifier depositsEnabled() {
        require(!DEPOSITS_PAUSED, "desposits are disabled");
        _;
    }

     
     
    function initialize(
        address _controller,
        address _ibt,
        uint256 _periodDuration,
        string memory _platformName,
        address _deployerAddress,
        address _admin
    ) public virtual initializer {
        controller = IController(_controller);
        ibt = ERC20(_ibt);
        PERIOD_DURATION = _periodDuration * (1 days);
        PLATFORM_NAME = _platformName;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(CONTROLLER_ROLE, _controller);
        _setupRole(FUTURE_DEPLOYER, _deployerAddress);

        registrationsTotals.push();
        registrationsTotals.push();
        fyts.push();

        IRegistry registry = IRegistry(controller.getRegistryAddress());

        string memory ibtSymbol = controller.getFutureIBTSymbol(ibt.symbol(), _platformName, PERIOD_DURATION);
        bytes memory payload =
            abi.encodeWithSignature(
                "initialize(string,string,uint8,address)",
                ibtSymbol,
                ibtSymbol,
                ibt.decimals(),
                address(this)
            );
        apwibt = IAPWineIBT(
            IProxyFactory(registry.getProxyFactoryAddress()).deployMinimal(registry.getAPWineIBTLogicAddress(), payload)
        );
        emit APWIBTSet(address(apwibt));
    }

     

     
    function startNewPeriod() public virtual;

     
    function register(address _user, uint256 _amount) public virtual periodsActive depositsEnabled periodsActive {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "Caller is not allowed to register");
        require(_amount > 0, "err_amount");
        uint256 nextIndex = getNextPeriodIndex();
        if (registrations[_user].scaledBalance == 0) {
             
            _register(_user, _amount);
        } else {
            if (registrations[_user].startIndex == nextIndex) {
                 
                registrations[_user].scaledBalance = registrations[_user].scaledBalance.add(_amount);
            } else {
                 
                _claimAPWIBT(_user);
                _register(_user, _amount);
            }
        }
        emit UserRegistered(_user, _amount, nextIndex);
    }

    function _register(address _user, uint256 _initialScaledBalance) internal virtual {
        registrations[_user] = Registration({startIndex: getNextPeriodIndex(), scaledBalance: _initialScaledBalance});
    }

     
    function unregister(address _user, uint256 _amount) public virtual;

     

     
    function claimFYT(address _user) public virtual nonReentrant {
        require(hasClaimableFYT(_user), "No FYT claimable for this address");
        if (hasClaimableAPWIBT(_user)) _claimAPWIBT(_user);
        else _claimFYT(_user);
    }

    function _claimFYT(address _user) internal virtual {
        uint256 nextIndex = getNextPeriodIndex();
        for (uint256 i = lastPeriodClaimed[_user] + 1; i < nextIndex; i++) {
            claimFYTforPeriod(_user, i);
        }
    }

    function claimFYTforPeriod(address _user, uint256 _periodIndex) internal virtual {
        assert((lastPeriodClaimed[_user] + 1) == _periodIndex);
        assert(_periodIndex < getNextPeriodIndex());
        assert(_periodIndex != 0);
        lastPeriodClaimed[_user] = _periodIndex;
        fyts[_periodIndex].transfer(_user, apwibt.balanceOf(_user));
    }

    function _claimAPWIBT(address _user) internal virtual {
        uint256 nextIndex = getNextPeriodIndex();
        uint256 claimableAPWIBT = getClaimableAPWIBT(_user);

        if (_hasOnlyClaimableFYT(_user)) _claimFYT(_user);
        apwibt.transfer(_user, claimableAPWIBT);

        for (uint256 i = registrations[_user].startIndex; i < nextIndex; i++) {
             
            fyts[i].transfer(_user, claimableAPWIBT);
        }

        lastPeriodClaimed[_user] = nextIndex - 1;
        delete registrations[_user];
    }

     
    function withdrawLockFunds(address _user, uint256 _amount) public virtual nonReentrant withdrawalsEnabled {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        require((_amount > 0) && (_amount <= apwibt.balanceOf(_user)), "Invalid amount");
        if (hasClaimableAPWIBT(_user)) {
            _claimAPWIBT(_user);
        } else if (hasClaimableFYT(_user)) {
            _claimFYT(_user);
        }

        uint256 unlockableFunds = getUnlockableFunds(_user);
        uint256 unrealisedYield = getUnrealisedYield(_user);

        uint256 fundsToBeUnlocked = _amount.mul(unlockableFunds).div(apwibt.balanceOf(_user));
        uint256 yieldToBeUnlocked = _amount.mul(unrealisedYield).div(apwibt.balanceOf(_user));

        uint256 yieldToBeRedeemed;
        if (PAUSED) {
            yieldToBeRedeemed = yieldToBeUnlocked;
        } else {
            yieldToBeRedeemed = (yieldToBeUnlocked.mul(controller.getUnlockYieldFactor(PERIOD_DURATION))).div(1000);
        }

        ibt.transferFrom(address(futureVault), _user, fundsToBeUnlocked.add(yieldToBeRedeemed));

        uint256 treasuryFee = yieldToBeUnlocked.sub(yieldToBeRedeemed);
        if (treasuryFee > 0) {
            ibt.transferFrom(
                address(futureVault),
                IRegistry(controller.getRegistryAddress()).getTreasuryAddress(),
                treasuryFee
            );
        }

        apwibt.burnFrom(_user, _amount);
        fyts[getNextPeriodIndex() - 1].burnFrom(_user, _amount);
        emit FundsWithdrawn(_user, _amount);
    }

     

    function deployFutureYieldToken(uint256 _internalPeriodID) internal returns (address) {
        IRegistry registry = IRegistry(controller.getRegistryAddress());
        string memory tokenDenomination = controller.getFYTSymbol(apwibt.symbol(), PERIOD_DURATION);
        bytes memory payload =
            abi.encodeWithSignature(
                "initialize(string,string,uint8,uint256,address)",
                tokenDenomination,
                tokenDenomination,
                ibt.decimals(),
                _internalPeriodID,
                address(this)
            );
        IFutureYieldToken newToken =
            IFutureYieldToken(
                IProxyFactory(registry.getProxyFactoryAddress()).deployMinimal(registry.getFYTLogicAddress(), payload)
            );
        fyts.push(newToken);
        newToken.mint(address(this), apwibt.totalSupply());
        return address(newToken);
    }

     

     
    function hasClaimableFYT(address _user) public view returns (bool) {
        return hasClaimableAPWIBT(_user) || _hasOnlyClaimableFYT(_user);
    }

    function _hasOnlyClaimableFYT(address _user) internal view returns (bool) {
        return lastPeriodClaimed[_user] != 0 && lastPeriodClaimed[_user] < getNextPeriodIndex() - 1;
    }

     
    function hasClaimableAPWIBT(address _user) public view returns (bool) {
        return (registrations[_user].startIndex < getNextPeriodIndex()) && (registrations[_user].scaledBalance > 0);
    }

     
    function getNextPeriodIndex() public view virtual returns (uint256) {
        return registrationsTotals.length - 1;
    }

     
    function getClaimableAPWIBT(address _user) public view virtual returns (uint256);

     
    function getClaimableFYTForPeriod(address _user, uint256 _periodID) public view virtual returns (uint256) {
        if (
            _periodID >= getNextPeriodIndex() ||
             
             
            registrations[_user].startIndex > _periodID ||
            lastPeriodClaimed[_user] >= _periodID
        ) {
            return 0;
        } else {
            return apwibt.balanceOf(_user);
        }
    }

     
    function getUnlockableFunds(address _user) public view virtual returns (uint256) {
        return apwibt.balanceOf(_user);
    }

     
    function getRegisteredAmount(address _user) public view virtual returns (uint256);

     
    function getUnrealisedYield(address _user) public view virtual returns (uint256);

     
    function getControllerAddress() public view returns (address) {
        return address(controller);
    }

     
    function getFutureVaultAddress() public view returns (address) {
        return address(futureVault);
    }

     
    function getFutureWalletAddress() public view returns (address) {
        return address(futureWallet);
    }

     
    function getLiquidityGaugeAddress() public view returns (address) {
        return address(liquidityGauge);
    }

     
    function getIBTAddress() public view returns (address) {
        return address(ibt);
    }

     
    function getAPWIBTAddress() public view returns (address) {
        return address(apwibt);
    }

     
    function getFYTofPeriod(uint256 _periodIndex) public view returns (address) {
        require(_periodIndex < getNextPeriodIndex(), "No FYT for this period yet");
        return address(fyts[_periodIndex]);
    }

     

     
    function pausePeriods() public {
        require(
            (hasRole(ADMIN_ROLE, msg.sender) || hasRole(CONTROLLER_ROLE, msg.sender)),
            "Caller is not allowed to pause future"
        );
        PAUSED = true;
        emit PeriodsPaused();
    }

     
    function resumePeriods() public {
        require(
            (hasRole(ADMIN_ROLE, msg.sender) || hasRole(CONTROLLER_ROLE, msg.sender)),
            "Caller is not allowed to resume future"
        );
        PAUSED = false;
        emit PeriodsResumed();
    }

     
    function pauseWithdrawals() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        WITHRAWALS_PAUSED = true;
        emit WithdrawalsPaused();
    }

     
    function resumeWithdrawals() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        WITHRAWALS_PAUSED = false;
        emit WithdrawalsResumed();
    }

     
    function pauseDeposits() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        DEPOSITS_PAUSED = true;
        emit DepositsPaused();
    }

     
    function resumeDeposits() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        DEPOSITS_PAUSED = false;
        emit DepositsResumed();
    }

     
    function pauseLiquidityTransfers() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        apwibt.pause();
        emit LiquidityTransfersPaused();
    }

     
    function resumeLiquidityTransfers() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        apwibt.unpause();
        emit LiquidityTransfersResumed();
    }

     
    function setFutureVault(address _futureVault) public {
        require(hasRole(FUTURE_DEPLOYER, msg.sender), "ERR_CALLER");
        futureVault = IFutureVault(_futureVault);
        emit FutureVaultSet(_futureVault);
    }

     
    function setFutureWallet(address _futureWallet) public {
        require(hasRole(FUTURE_DEPLOYER, msg.sender), "ERR_CALLER");
        futureWallet = IFutureWallet(_futureWallet);
        emit FutureWalletSet(_futureWallet);
    }

     
    function setLiquidityGauge(address _liquidityGauge) public {
        require(hasRole(FUTURE_DEPLOYER, msg.sender), "ERR_CALLER");
        liquidityGauge = ILiquidityGauge(_liquidityGauge);
        emit LiquidityGaugeSet(_liquidityGauge);
    }

     
    function setAPWIBT(address _apwibt) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        apwibt = IAPWineIBT(_apwibt);
        emit APWIBTSet(_apwibt);
    }

    function hasNoRecord(address _user) public view returns (bool) {
        return (lastPeriodClaimed[_user] == 0);
    }

    function createRecord(address _user) public {
        require(msg.sender == address(apwibt), "ERR_CALLER");
        lastPeriodClaimed[_user] = getNextPeriodIndex() - 1;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC20Upgradeable {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity 0.7.6;







 
abstract contract RateFuture is Future {
    using SafeMathUpgradeable for uint256;

    uint256[] private IBTRates;

     
    function initialize(
        address _controller,
        address _ibt,
        uint256 _periodDuration,
        string memory _platformName,
        address _deployerAddress,
        address _admin
    ) public virtual override initializer {
        super.initialize(_controller, _ibt, _periodDuration, _platformName, _deployerAddress, _admin);
        IBTRates.push(getIBTRate());
        IBTRates.push();
    }

     
    function unregister(address _user, uint256 _amount) public virtual override nonReentrant withdrawalsEnabled {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "Caller is not allowed to unregister");

        uint256 nextIndex = getNextPeriodIndex();
        require(registrations[_user].startIndex == nextIndex, "The is not ongoing registration for the next period");

        uint256 currentRegistered = registrations[_user].scaledBalance;
        uint256 toRefund;

        if (_amount == 0) {
            delete registrations[_user];
            toRefund = currentRegistered;
        } else {
            require(currentRegistered >= _amount, "Invalid amount to unregister");
            registrations[_user].scaledBalance = registrations[_user].scaledBalance.sub(_amount);
            toRefund = _amount;
        }

        ibt.transfer(_user, toRefund);
    }

     
    function startNewPeriod() public virtual override nextPeriodAvailable periodsActive nonReentrant {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "Caller is not allowed to start the next period");

        uint256 nextPeriodID = getNextPeriodIndex();
        uint256 currentRate = getIBTRate();

        IBTRates[nextPeriodID] = currentRate;
        registrationsTotals[nextPeriodID] = ibt.balanceOf(address(this));

         
        uint256 oldIBTBalanceForUnderlying = (10**ibt.decimals()).mul(apwibt.totalSupply()).div(IBTRates[nextPeriodID - 1]);
        uint256 newIBTBalanceForUnderlying = (10**ibt.decimals()).mul(apwibt.totalSupply()).div(currentRate);
        uint256 yield = oldIBTBalanceForUnderlying.sub(newIBTBalanceForUnderlying);
        futureWallet.registerExpiredFuture(yield);  
        if (yield > 0) assert(ibt.transferFrom(address(futureVault), address(futureWallet), yield));

         
        if (registrationsTotals[nextPeriodID] > 0) {
            apwibt.mint(
                address(this),
                registrationsTotals[nextPeriodID].mul(IBTRates[nextPeriodID]).div(10**ibt.decimals())
            );  
            ibt.transfer(address(futureVault), registrationsTotals[nextPeriodID]);  
        }

        registrationsTotals.push();
        IBTRates.push();

         
        address fytAddress = deployFutureYieldToken(nextPeriodID);
        emit NewPeriodStarted(nextPeriodID, fytAddress);
    }

     
    function getRegisteredAmount(address _user) public view override returns (uint256) {
        uint256 periodID = registrations[_user].startIndex;
        if (periodID == getNextPeriodIndex()) {
            return registrations[_user].scaledBalance;
        } else {
            return 0;
        }
    }

     
    function getClaimableAPWIBT(address _user) public view override returns (uint256) {
        if (!hasClaimableAPWIBT(_user)) return 0;
        return registrations[_user].scaledBalance.mul(IBTRates[registrations[_user].startIndex]).div(10**ibt.decimals());
    }

     
    function getUnlockableFunds(address _user) public view override returns (uint256) {
        return super.getUnlockableFunds(_user).mul(10**ibt.decimals()).div(getIBTRate());
    }

     
    function getUnrealisedYield(address _user) public view override returns (uint256) {
        uint256 initialTotalUserDeposit =
            (apwibt.balanceOf(_user)).mul(10**ibt.decimals()).div(IBTRates[getNextPeriodIndex() - 1]);
        return initialTotalUserDeposit.sub(getUnlockableFunds(_user));
    }

     
    function getIBTRate() public view virtual returns (uint256);

    function forceSetRegisteredBalance(address _user, uint256 _amount) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not allowed to fix");
        registrations[_user].scaledBalance = _amount;
    }
}

 
pragma solidity 0.7.6;



interface ERC20 is IERC20Upgradeable {
     
    function name() external returns (string memory);

     
    function symbol() external returns (string memory);

     
    function decimals() external view returns (uint8);

     
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

     
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}
pragma solidity 0.7.6;




 
contract HarvestFuture is RateFuture {
     
    function getIBTRate() public view override returns (uint256) {
        return iFarm(address(ibt)).getPricePerFullShare();
    }
}

pragma solidity 0.7.6;



interface iFarm is ERC20 {
    function getPricePerFullShare() external view returns (uint256);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeMathUpgradeable {
     
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

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableSetUpgradeable {
     
     
     
     
     
     
     
     

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
        return _add(set._inner, bytes32(uint256(value)));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
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

 

pragma solidity >=0.6.2 <0.8.0;

 
library AddressUpgradeable {
     
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

pragma solidity 0.7.6;

interface IProxyFactory {
    function deployMinimal(address _logic, bytes memory _data) external returns (address proxy);
}

pragma solidity 0.7.6;



interface IFutureYieldToken is ERC20 {
     
    function burn(uint256 amount) external;

     
    function burnFrom(address account, uint256 amount) external;

     
    function mint(address to, uint256 amount) external;

    function internalPeriodID() external view returns (uint256);
}

pragma solidity 0.7.6;

interface IAPWineMaths {
     
    function getScaledInput(
        uint256 _actualValue,
        uint256 _initialSum,
        uint256 _actualSum
    ) external pure returns (uint256);

     
    function getActualOutput(
        uint256 _scaledOutput,
        uint256 _initialSum,
        uint256 _actualSum
    ) external pure returns (uint256);
}

pragma solidity 0.7.6;



interface IAPWineIBT is ERC20 {
     
    function burn(uint256 amount) external;

     
    function mint(address to, uint256 amount) external;

     
    function burnFrom(address account, uint256 amount) external;

     
    function pause() external;

     
    function unpause() external;
}

pragma solidity 0.7.6;

interface IFutureWallet {
     
    function initialize(address _futureAddress, address _adminAddress) external;

     
    function registerExpiredFuture(uint256 _amount) external;

     
    function redeemYield(uint256 _periodIndex) external;

     
    function getRedeemableYield(uint256 _periodIndex, address _tokenHolder) external view returns (uint256);

     
    function getFutureAddress() external view returns (address);

     
    function getIBTAddress() external view returns (address);
}

pragma solidity 0.7.6;

interface IController {
     

    function STARTING_DELAY() external view returns (uint256);

     

     
    function initialize(address _admin) external;

     

     
    function setPeriodStartingDelay(uint256 _startingDelay) external;

     
    function setNextPeriodSwitchTimestamp(uint256 _periodDuration, uint256 _nextPeriodTimestamp) external;

     
    function setUnlockClaimableFactor(uint256 _periodDuration, uint256 _claimableYieldFactor) external;

     

     
    function register(address _future, uint256 _amount) external;

     
    function unregister(address _future, uint256 _amount) external;

     
    function withdrawLockFunds(address _future, uint256 _amount) external;

     
    function claimFYT(address _future) external;

     
    function getFuturesWithClaimableFYT(address _user) external view returns (address[] memory);

     
    function getRegistryAddress() external view returns (address);

     
    function getFutureIBTSymbol(
        string memory _ibtSymbol,
        string memory _platform,
        uint256 _periodDuration
    ) external pure returns (string memory);

     
    function getFYTSymbol(string memory _apwibtSymbol, uint256 _periodDuration) external view returns (string memory);

     
    function getPeriodIndex(uint256 _periodDuration) external view returns (uint256);

     
    function getNextPeriodStart(uint256 _periodDuration) external view returns (uint256);

     
    function getUnlockYieldFactor(uint256 _periodDuration) external view returns (uint256);

     
    function getDurations() external view returns (uint256[] memory);

     
    function registerNewFuture(address _newFuture) external;

     
    function unregisterFuture(address _future) external;

     
    function startFuturesByPeriodDuration(uint256 _periodDuration) external;

     
    function getFuturesWithDuration(uint256 _periodDuration) external view returns (address[] memory);

     
    function claimSelectedYield(address _user, address[] memory _futureAddress) external;

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);  

     
    function pauseFuture(address _future) external;

     
    function resumeFuture(address _future) external;
}

pragma solidity 0.7.6;

interface IFutureVault {
     
    function initialize(address _futureAddress, address _adminAddress) external;

     
    function getFutureAddress() external view returns (address);

     
    function approveAdditionalToken(address _tokenAddress) external;
}

pragma solidity 0.7.6;

interface ILiquidityGauge {
     
    function initialize(address _gaugeController, address _future) external;

     
    function registerNewFutureLiquidity(uint256 _amount) external;

     
    function unregisterFutureLiquidity(uint256 _amount) external;

     
    function updateAndGetRedeemable(address _user) external returns (uint256);

     
    function updateInflatedVolume() external;

     
    function getLastInflatedAmount() external view returns (uint256);

     
    function getUserRedeemable(address _user) external view returns (uint256);

     
    function registerUserLiquidity(address _user) external;

     
    function deleteUserLiquidityRegistration(address _user) external;

     
    function transferUserLiquidty(
        address _sender,
        address _receiver,
        uint256 _amount
    ) external;

     
    function updateUserLiquidity(address _user) external;

     
    function removeUserLiquidity(address _user, uint256 _amount) external;
}

pragma solidity 0.7.6;


interface IRegistry {
     
    function initialize(address _admin) external;

     

     
    function setTreasury(address _newTreasury) external;

     
    function setGaugeController(address _newGaugeController) external;

     
    function setController(address _newController) external;

     
    function setAPW(address _newAPW) external;

     
    function setProxyFactory(address _proxyFactory) external;

     
    function setLiquidityGaugeLogic(address _liquidityGaugeLogic) external;

     
    function setAPWineIBTLogic(address _APWineIBTLogic) external;

     
    function setFYTLogic(address _FYTLogic) external;

     
    function setMathsUtils(address _mathsUtils) external;

     
    function setNamingUtils(address _namingUtils) external;

     
    function getControllerAddress() external view returns (address);

     
    function getTreasuryAddress() external view returns (address);

     
    function getGaugeControllerAddress() external view returns (address);

     
    function getDAOAddress() external returns (address);

     
    function getAPWAddress() external view returns (address);

     
    function getVestingAddress() external view returns (address);

     
    function getProxyFactoryAddress() external view returns (address);

     
    function getLiquidityGaugeLogicAddress() external view returns (address);

     
    function getAPWineIBTLogicAddress() external view returns (address);

     
    function getFYTLogicAddress() external view returns (address);

     
    function getMathsUtils() external view returns (address);

     
    function getNamingUtils() external view returns (address);

     

     
    function addFutureFactory(address _futureFactory, string memory _futureFactoryName) external;

     
    function isRegisteredFutureFactory(address _futureFactory) external view returns (bool);

     
    function getFutureFactoryAt(uint256 _index) external view returns (address);

     
    function futureFactoryCount() external view returns (uint256);

     
    function getFutureFactoryName(address _futureFactory) external view returns (string memory);

     
     
    function addFuturePlatform(
        address _futureFactory,
        string memory _futurePlatformName,
        address _future,
        address _futureWallet,
        address _futureVault
    ) external;

     
    function isRegisteredFuturePlatform(string memory _futurePlatformName) external view returns (bool);

     
    function getFuturePlatform(string memory _futurePlatformName) external view returns (address[3] memory);

     
    function futurePlatformsCount() external view returns (uint256);

     
    function getFuturePlatformNames() external view returns (string[] memory);

     
    function removeFuturePlatform(string memory _futurePlatformName) external;

     
     
    function addFuture(address _future) external;

     
    function removeFuture(address _future) external;

     
    function isRegisteredFuture(address _future) external view returns (bool);

     
    function getFutureAt(uint256 _index) external view returns (address);

     
    function futureCount() external view returns (uint256);
}
