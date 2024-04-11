 
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
        return !AddressUpgradeable.isContract(address(this));
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

 

pragma solidity 0.7.6;



contract RoleCheckable is AccessControlUpgradeable {
     

     
    bytes32 internal constant ADMIN_ROLE = 0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;
     
    bytes32 internal constant CONTROLLER_ROLE = 0x7b765e0e932d348852a6f810bfa1ab891e259123f02db8cdcde614c570223357;
     
    bytes32 internal constant START_FUTURE = 0xeb5092aab714e6356486bc97f25dd7a5c1dc5c7436a9d30e8d4a527fba24de1c;
     
    bytes32 internal constant FUTURE_ROLE = 0x52d2dbc4d362e84c42bdfb9941433968ba41423559d7559b32db1183b22b148f;
     
    bytes32 internal constant HARVEST_REWARDS = 0xf2683e58e5a2a04c1ed32509bfdbf1e9ebc725c63f4c95425d2afd482bfdb0f8;

     

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "RoleCheckable: Caller should be ADMIN");
        _;
    }

    modifier onlyStartFuture() {
        require(hasRole(START_FUTURE, msg.sender), "RoleCheckable: Caller should have START FUTURE Role");
        _;
    }

    modifier onlyHarvestReward() {
        require(hasRole(HARVEST_REWARDS, msg.sender), "RoleCheckable: Caller should have HARVEST REWARDS Role");
        _;
    }

    modifier onlyController() {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "RoleCheckable: Caller should be CONTROLLER");
        _;
    }
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





contract RegistryStorage is RoleCheckable {
    IRegistry internal registry;

    event RegistryChanged(IRegistry _registry);

     

     
    function setRegistry(IRegistry _registry) external onlyAdmin {
        registry = _registry;
        emit RegistryChanged(_registry);
    }
}

 

pragma solidity 0.7.6;



















 
abstract contract FutureVault is Initializable, RegistryStorage, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeERC20Upgradeable for IERC20;

     
    mapping(uint256 => uint256) internal collectedFYTSByPeriod;
    mapping(uint256 => uint256) internal premiumsTotal;

    mapping(address => uint256) internal lastPeriodClaimed;
    mapping(address => uint256) internal premiumToBeRedeemed;
    mapping(address => uint256) internal FYTsOfUserPremium;

    mapping(address => uint256) internal claimableFYTByUser;
    mapping(uint256 => uint256) internal yieldOfPeriod;
    uint256 internal totalUnderlyingDeposited;

    bool private terminated;
    uint256 internal performanceFeeFactor;

    IFutureYieldToken[] internal fyts;
     
    struct Delegation {
        address receiver;
        uint256 delegatedAmount;
    }

    mapping(address => Delegation[]) internal delegationsByDelegator;
    mapping(address => uint256) internal totalDelegationsReceived;

     
    IFutureWallet internal futureWallet;
    IERC20 internal ibt;
    IPT internal pt;
    IController internal controller;

     
    uint256 public PERIOD_DURATION;
    string public PLATFORM_NAME;

     
    uint256 internal IBT_UNIT;
    uint256 internal IBT_UNITS_MULTIPLIED_VALUE;
    uint256 constant UNIT = 10**18;

     
    event NewPeriodStarted(uint256 _newPeriodIndex);
    event FutureWalletSet(IFutureWallet _futureWallet);
    event FundsDeposited(address _user, uint256 _amount);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PTSet(IPT _pt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();
    event DelegationCreated(address _delegator, address _receiver, uint256 _amount);
    event DelegationRemoved(address _delegator, address _receiver, uint256 _amount);

     
    modifier nextPeriodAvailable() {
        uint256 controllerDelay = controller.STARTING_DELAY();
        require(
            controller.getNextPeriodStart(PERIOD_DURATION) < block.timestamp.add(controllerDelay),
            "FutureVault: ERR_PERIOD_RANGE"
        );
        _;
    }

    modifier periodsActive() {
        require(!terminated, "PERIOD_TERMINATED");
        _;
    }

    modifier withdrawalsEnabled() {
        require(!controller.isWithdrawalsPaused(address(this)), "FutureVault: WITHDRAWALS_DISABLED");
        _;
    }

    modifier depositsEnabled() {
        require(
            !controller.isDepositsPaused(address(this)) && getCurrentPeriodIndex() != 0,
            "FutureVault: DEPOSITS_DISABLED"
        );
        _;
    }

     
     
    function initialize(
        IController _controller,
        IERC20 _ibt,
        uint256 _periodDuration,
        string memory _platformName,
        address _admin
    ) public virtual initializer {
        controller = _controller;
        ibt = _ibt;
        IBT_UNIT = 10**ibt.decimals();
        IBT_UNITS_MULTIPLIED_VALUE = UNIT * IBT_UNIT;
        PERIOD_DURATION = _periodDuration * (1 days);
        PLATFORM_NAME = _platformName;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(CONTROLLER_ROLE, address(_controller));

        fyts.push();

        registry = IRegistry(controller.getRegistryAddress());

        pt = IPT(
            ITokensFactory(IRegistry(controller.getRegistryAddress()).getTokensFactoryAddress()).deployPT(
                ibt.symbol(),
                ibt.decimals(),
                PLATFORM_NAME,
                PERIOD_DURATION
            )
        );

        emit PTSet(pt);
    }

     

     
    function startNewPeriod() public virtual;

    function _switchPeriod() internal periodsActive {
        uint256 nextPeriodID = getNextPeriodIndex();
        uint256 yield = getUnrealisedYieldPerPT().mul(totalUnderlyingDeposited) / IBT_UNIT;

        uint256 reinvestedYield;
        if (yield > 0) {
            uint256 currentPeriodIndex = getCurrentPeriodIndex();
            uint256 premiums = convertUnderlyingtoIBT(premiumsTotal[currentPeriodIndex]);
            uint256 performanceFee = (yield.mul(performanceFeeFactor) / UNIT).sub(premiums);
            uint256 remainingYield = yield.sub(performanceFee);
            yieldOfPeriod[currentPeriodIndex] = convertIBTToUnderlying(
                remainingYield.mul(UNIT).div(totalUnderlyingDeposited)
            );
            uint256 collectedYield = remainingYield.mul(collectedFYTSByPeriod[currentPeriodIndex]).div(
                totalUnderlyingDeposited
            );
            reinvestedYield = remainingYield.sub(collectedYield);
            futureWallet.registerExpiredFuture(collectedYield);  

            if (performanceFee > 0) ibt.safeTransfer(registry.getTreasuryAddress(), performanceFee);
            if (remainingYield > 0) ibt.safeTransfer(address(futureWallet), collectedYield);
        } else {
            futureWallet.registerExpiredFuture(0);
        }

         
        totalUnderlyingDeposited = totalUnderlyingDeposited.add(convertIBTToUnderlying(reinvestedYield));  
        if (!controller.isFutureSetToBeTerminated(address(this))) {
            _deployNewFutureYieldToken(nextPeriodID);
            emit NewPeriodStarted(nextPeriodID);
        } else {
            terminated = true;
        }

        uint256 nextPerformanceFeeFactor = controller.getNextPerformanceFeeFactor(address(this));
        if (nextPerformanceFeeFactor != performanceFeeFactor) performanceFeeFactor = nextPerformanceFeeFactor;
    }

     

     
    function updateUserState(address _user) public {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        uint256 lastPeriodClaimedOfUser = lastPeriodClaimed[_user];
        if (lastPeriodClaimedOfUser < currentPeriodIndex && lastPeriodClaimedOfUser != 0) {
            pt.mint(_user, _preparePTClaim(_user));
        }
        if (lastPeriodClaimedOfUser != currentPeriodIndex) lastPeriodClaimed[_user] = currentPeriodIndex;
    }

    function _preparePTClaim(address _user) internal virtual returns (uint256 claimablePT) {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        if (lastPeriodClaimed[_user] < currentPeriodIndex) {
            claimablePT = getClaimablePT(_user);
            delete premiumToBeRedeemed[_user];
            delete FYTsOfUserPremium[_user];
            lastPeriodClaimed[_user] = currentPeriodIndex;
            claimableFYTByUser[_user] = pt.balanceOf(_user).add(totalDelegationsReceived[_user]).sub(
                getTotalDelegated(_user)
            );
        }
    }

     
    function deposit(address _user, uint256 _amount) external virtual periodsActive depositsEnabled onlyController {
        require((_amount > 0) && (_amount <= ibt.balanceOf(_user)), "FutureVault: ERR_AMOUNT");
        _deposit(_user, _amount);
        emit FundsDeposited(_user, _amount);
    }

    function _deposit(address _user, uint256 _amount) internal {
        uint256 underlyingDeposited = getPTPerAmountDeposited(_amount);
        uint256 ptToMint = _preparePTClaim(_user).add(underlyingDeposited);
        uint256 currentPeriodIndex = getCurrentPeriodIndex();

         
        uint256 redeemable = getPremiumPerUnderlyingDeposited(convertIBTToUnderlying(_amount));
        premiumToBeRedeemed[_user] = premiumToBeRedeemed[_user].add(redeemable);
        FYTsOfUserPremium[_user] = FYTsOfUserPremium[_user].add(ptToMint);
        premiumsTotal[currentPeriodIndex] = premiumsTotal[currentPeriodIndex].add(redeemable);

         
        totalUnderlyingDeposited = totalUnderlyingDeposited.add(underlyingDeposited);
        claimableFYTByUser[_user] = claimableFYTByUser[_user].add(ptToMint);

        pt.mint(_user, ptToMint);
    }

     
    function withdraw(address _user, uint256 _amount) external virtual nonReentrant withdrawalsEnabled onlyController {
        require((_amount > 0) && (_amount <= pt.balanceOf(_user)), "FutureVault: ERR_AMOUNT");
        require(_amount <= fyts[getCurrentPeriodIndex()].balanceOf(_user), "FutureVault: ERR_FYT_AMOUNT");
        _withdraw(_user, _amount);

        uint256 FYTsToBurn;
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        uint256 FYTSMinted = fyts[currentPeriodIndex].recordedBalanceOf(_user);
        if (_amount > FYTSMinted) {
            FYTsToBurn = FYTSMinted;
            uint256 ClaimableFYTsToBurn = _amount - FYTsToBurn;
            claimableFYTByUser[_user] = claimableFYTByUser[_user].sub(ClaimableFYTsToBurn, "FutureVault: ERR_AMOUNT");
            collectedFYTSByPeriod[currentPeriodIndex] = collectedFYTSByPeriod[currentPeriodIndex].add(ClaimableFYTsToBurn);
        } else {
            FYTsToBurn = _amount;
        }

        if (FYTsToBurn > 0) fyts[currentPeriodIndex].burnFrom(_user, FYTsToBurn);

        emit FundsWithdrawn(_user, _amount);
    }

     
    function _withdraw(address _user, uint256 _amount) internal virtual {
        updateUserState(_user);
        uint256 fundsToBeUnlocked = _amount.mul(getUnlockableFunds(_user)).div(pt.balanceOf(_user));
        uint256 yieldToBeUnlocked = _amount.mul(getUnrealisedYieldPerPT()) / IBT_UNIT;

        uint256 premiumToBeUnlocked = _prepareUserEarlyPremiumUnlock(_user, _amount);

        uint256 treasuryFee = (yieldToBeUnlocked.mul(performanceFeeFactor) / UNIT).sub(premiumToBeUnlocked);
        uint256 yieldToBeRedeemed = yieldToBeUnlocked - treasuryFee;
        ibt.safeTransfer(_user, fundsToBeUnlocked.add(yieldToBeRedeemed).add(premiumToBeUnlocked));

        if (treasuryFee > 0) {
            ibt.safeTransfer(registry.getTreasuryAddress(), treasuryFee);
        }
        totalUnderlyingDeposited = totalUnderlyingDeposited.sub(_amount);
        pt.burnFrom(_user, _amount);
    }

    function _prepareUserEarlyPremiumUnlock(address _user, uint256 _ptShares)
        internal
        returns (uint256 premiumToBeUnlocked)
    {
        uint256 unlockablePremium = premiumToBeRedeemed[_user];
        uint256 userFYTsInPremium = FYTsOfUserPremium[_user];
        if (unlockablePremium > 0) {
            if (_ptShares > userFYTsInPremium) {
                premiumToBeUnlocked = convertUnderlyingtoIBT(unlockablePremium);
                delete premiumToBeRedeemed[_user];
                delete FYTsOfUserPremium[_user];
            } else {
                uint256 premiumForAmount = unlockablePremium.mul(_ptShares).div(userFYTsInPremium);
                premiumToBeUnlocked = convertUnderlyingtoIBT(premiumForAmount);
                premiumToBeRedeemed[_user] = unlockablePremium - premiumForAmount;
                FYTsOfUserPremium[_user] = userFYTsInPremium - _ptShares;
            }
        }
    }

     
    function getUserEarlyUnlockablePremium(address _user)
        public
        view
        returns (uint256 premiumLocked, uint256 amountRequired)
    {
        premiumLocked = premiumToBeRedeemed[_user];
        amountRequired = FYTsOfUserPremium[_user];
    }

     

     
    function createFYTDelegationTo(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) public nonReentrant periodsActive {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        updateUserState(_delegator);
        updateUserState(_receiver);
        uint256 totalDelegated = getTotalDelegated(_delegator);
        uint256 numberOfDelegations = delegationsByDelegator[_delegator].length;
        require(_amount > 0 && _amount <= pt.balanceOf(_delegator).sub(totalDelegated), "FutureVault: ERR_AMOUNT");

        bool delegated;
        for (uint256 i = 0; i < numberOfDelegations; i++) {
            if (delegationsByDelegator[_delegator][i].receiver == _receiver) {
                delegationsByDelegator[_delegator][i].delegatedAmount = delegationsByDelegator[_delegator][i]
                    .delegatedAmount
                    .add(_amount);
                delegated = true;
                break;
            }
        }
        if (!delegated) {
            delegationsByDelegator[_delegator].push(Delegation({ receiver: _receiver, delegatedAmount: _amount }));
        }
        totalDelegationsReceived[_receiver] = totalDelegationsReceived[_receiver].add(_amount);
        emit DelegationCreated(_delegator, _receiver, _amount);
    }

     
    function withdrawFYTDelegationFrom(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) public {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        updateUserState(_delegator);
        updateUserState(_receiver);

        uint256 numberOfDelegations = delegationsByDelegator[_delegator].length;
        bool removed;
        for (uint256 i = 0; i < numberOfDelegations; i++) {
            if (delegationsByDelegator[_delegator][i].receiver == _receiver) {
                delegationsByDelegator[_delegator][i].delegatedAmount = delegationsByDelegator[_delegator][i]
                    .delegatedAmount
                    .sub(_amount, "ERR_AMOUNT");
                removed = true;
                break;
            }
        }
        require(_amount > 0 && removed, "FutureVault: ERR_AMOUNT");
        totalDelegationsReceived[_receiver] = totalDelegationsReceived[_receiver].sub(_amount);
        emit DelegationRemoved(_delegator, _receiver, _amount);
    }

     
    function getTotalDelegated(address _delegator) public view returns (uint256 totalDelegated) {
        uint256 numberOfDelegations = delegationsByDelegator[_delegator].length;
        for (uint256 i = 0; i < numberOfDelegations; i++) {
            totalDelegated = totalDelegated.add(delegationsByDelegator[_delegator][i].delegatedAmount);
        }
    }

     

     
    function claimFYT(address _user, uint256 _amount) external virtual nonReentrant {
        require(msg.sender == address(fyts[getCurrentPeriodIndex()]), "FutureVault: ERR_CALLER");
        updateUserState(_user);
        _claimFYT(_user, _amount);
    }

    function _claimFYT(address _user, uint256 _amount) internal virtual {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        claimableFYTByUser[_user] = claimableFYTByUser[_user].sub(_amount, "ERR_CLAIMED_FYT_AMOUNT");
        fyts[currentPeriodIndex].mint(_user, _amount);
        collectedFYTSByPeriod[currentPeriodIndex] = collectedFYTSByPeriod[currentPeriodIndex].add(_amount);
    }

     

     
    function exitTerminatedFuture(address _user) external nonReentrant onlyController {
        require(terminated, "FutureVault: ERR_NOT_TERMINATED");
        uint256 amount = pt.balanceOf(_user);
        require(amount > 0, "FutureVault: ERR_PT_BALANCE");
        _withdraw(_user, amount);
        emit FundsWithdrawn(_user, amount);
    }

     

    function convertIBTToUnderlying(uint256 _amount) public view virtual returns (uint256);

    function convertUnderlyingtoIBT(uint256 _amount) public view virtual returns (uint256);

    function _deployNewFutureYieldToken(uint256 newPeriodIndex) internal {
        IFutureYieldToken newToken = IFutureYieldToken(
            ITokensFactory(registry.getTokensFactoryAddress()).deployNextFutureYieldToken(newPeriodIndex)
        );
        fyts.push(newToken);
    }

     

     
    function getClaimablePT(address _user) public view virtual returns (uint256) {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();

        if (lastPeriodClaimed[_user] < currentPeriodIndex) {
            uint256 recordedBalance = pt.recordedBalanceOf(_user);
            uint256 mintablePT = (recordedBalance).add(premiumToBeRedeemed[_user]);  
            mintablePT = mintablePT.add(totalDelegationsReceived[_user]).sub(getTotalDelegated(_user));  
            uint256 userStackingGrowthFactor = yieldOfPeriod[lastPeriodClaimed[_user]];
            if (userStackingGrowthFactor > 0) {
                mintablePT = mintablePT.add(claimableFYTByUser[_user].mul(userStackingGrowthFactor) / IBT_UNIT);  
            }
            for (uint256 i = lastPeriodClaimed[_user] + 1; i < currentPeriodIndex; i++) {
                mintablePT = mintablePT.add(yieldOfPeriod[i].mul(mintablePT) / IBT_UNIT);
            }
            return mintablePT.add(getTotalDelegated(_user)).sub(recordedBalance).sub(totalDelegationsReceived[_user]);
        } else {
            return 0;
        }
    }

     
    function getUnlockableFunds(address _user) public view virtual returns (uint256) {
        return pt.balanceOf(_user);
    }

     
    function getClaimableFYTForPeriod(address _user, uint256 _periodIndex) external view virtual returns (uint256) {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();

        if (_periodIndex != currentPeriodIndex || _user == address(this)) {
            return 0;
        } else if (_periodIndex == currentPeriodIndex && lastPeriodClaimed[_user] == currentPeriodIndex) {
            return claimableFYTByUser[_user];
        } else {
            return pt.balanceOf(_user).add(totalDelegationsReceived[_user]).sub(getTotalDelegated(_user));
        }
    }

     
    function getUnrealisedYieldPerPT() public view virtual returns (uint256);

     
    function getPTPerAmountDeposited(uint256 _amount) public view virtual returns (uint256);

     
    function getPremiumPerUnderlyingDeposited(uint256 _amount) public view virtual returns (uint256) {
        if (totalUnderlyingDeposited == 0) {
            return 0;
        }
        uint256 yieldPerFYT = getUnrealisedYieldPerPT();
        uint256 premiumToRefundInIBT = _amount.mul(yieldPerFYT).mul(performanceFeeFactor) / IBT_UNITS_MULTIPLIED_VALUE;
        return convertIBTToUnderlying(premiumToRefundInIBT);
    }

     
    function getUnlockablePremium(address _user) public view returns (uint256) {
        if (lastPeriodClaimed[_user] != getCurrentPeriodIndex()) {
            return 0;
        } else {
            return premiumToBeRedeemed[_user];
        }
    }

     
    function getYieldOfPeriod(uint256 _periodID) external view returns (uint256) {
        require(getCurrentPeriodIndex() > _periodID, "FutureVault: Invalid period ID");
        return yieldOfPeriod[_periodID];
    }

     
    function getNextPeriodIndex() public view virtual returns (uint256) {
        return fyts.length;
    }

     
    function getCurrentPeriodIndex() public view virtual returns (uint256) {
        return fyts.length - 1;
    }

     
    function getTotalUnderlyingDeposited() external view returns (uint256) {
        return totalUnderlyingDeposited;
    }

     
    function getControllerAddress() public view returns (address) {
        return address(controller);
    }

     
    function getFutureWalletAddress() public view returns (address) {
        return address(futureWallet);
    }

     
    function getIBTAddress() public view returns (address) {
        return address(ibt);
    }

     
    function getPTAddress() public view returns (address) {
        return address(pt);
    }

     
    function getFYTofPeriod(uint256 _periodIndex) public view returns (address) {
        return address(fyts[_periodIndex]);
    }

     
    function isTerminated() public view returns (bool) {
        return terminated;
    }

     
    function getPerformanceFeeFactor() external view returns (uint256) {
        return performanceFeeFactor;
    }

     
     
    function setFutureWallet(IFutureWallet _futureWallet) external onlyAdmin {
        futureWallet = _futureWallet;
        emit FutureWalletSet(_futureWallet);
    }

     
    function pauseLiquidityTransfers() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        pt.pause();
        emit LiquidityTransfersPaused();
    }

     
    function resumeLiquidityTransfers() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        pt.unpause();
        emit LiquidityTransfersResumed();
    }
}

 

pragma solidity 0.7.6;



 
abstract contract RewardsFutureVault is FutureVault {
    using SafeERC20Upgradeable for IERC20;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

     
    EnumerableSetUpgradeable.AddressSet internal rewardTokens;

     
    address internal rewardsRecipient;

     
    event RewardsHarvested();
    event RewardTokenAdded(address _token);
    event RewardTokenRedeemed(IERC20 _token, uint256 _amount);
    event RewardsRecipientUpdated(address _recipient);

     

     
    function harvestRewards() public virtual {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        _harvestRewards();
        emit RewardsHarvested();
    }

     
    function _harvestRewards() internal virtual {}

     
    function redeemAllVaultRewards() external virtual onlyController {
        require(rewardsRecipient != address(0), "RewardsFutureVault: ERR_RECIPIENT");
        uint256 numberOfRewardTokens = rewardTokens.length();
        for (uint256 i; i < numberOfRewardTokens; i++) {
            IERC20 rewardToken = IERC20(rewardTokens.at(i));
            uint256 rewardTokenBalance = rewardToken.balanceOf(address(this));
            rewardToken.safeTransfer(rewardsRecipient, rewardTokenBalance);
            emit RewardTokenRedeemed(rewardToken, rewardTokenBalance);
        }
    }

     
    function redeemVaultRewards(IERC20 _rewardToken) external virtual onlyController {
        require(rewardsRecipient != address(0), "RewardsFutureVault: ERR_RECIPIENT");
        require(rewardTokens.contains(address(_rewardToken)), "RewardsFutureVault: ERR_TOKEN_ADDRESS");
        uint256 rewardTokenBalance = _rewardToken.balanceOf(address(this));
        _rewardToken.safeTransfer(rewardsRecipient, rewardTokenBalance);
        emit RewardTokenRedeemed(_rewardToken, rewardTokenBalance);
    }

     
    function addRewardsToken(address _token) external onlyAdmin {
        require(_token != address(ibt), "RewardsFutureVault: ERR_TOKEN_ADDRESS");
        rewardTokens.add(_token);
        emit RewardTokenAdded(_token);
    }

     
    function setRewardRecipient(address _recipient) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        rewardsRecipient = _recipient;
        emit RewardsRecipientUpdated(_recipient);
    }

     
    function isRewardToken(IERC20 _token) external view returns (bool) {
        return rewardTokens.contains(address(_token));
    }

     
    function getRewardTokenAt(uint256 _index) external view returns (address) {
        return rewardTokens.at(_index);
    }

     
    function getRewardTokensCount() external view returns (uint256) {
        return rewardTokens.length();
    }

     
    function getRewardsRecipient() external view returns (address) {
        return rewardsRecipient;
    }
}

 

pragma solidity 0.7.6;



 
abstract contract RateFutureVault is RewardsFutureVault {
    using SafeMathUpgradeable for uint256;

    mapping(uint256 => uint256) internal IBTRates;

     
    function initialize(
        IController _controller,
        IERC20 _ibt,
        uint256 _periodDuration,
        string memory _platformName,
        address _admin
    ) public virtual override initializer {
        super.initialize(_controller, _ibt, _periodDuration, _platformName, _admin);
        IBTRates[getCurrentPeriodIndex()] = getIBTRate();
    }

     
    function startNewPeriod() public virtual override nextPeriodAvailable periodsActive nonReentrant {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        _switchPeriod();
        IBTRates[getCurrentPeriodIndex()] = getIBTRate();
    }

    function convertIBTToUnderlying(uint256 _amount) public view virtual override returns (uint256) {
        return _convertIBTToUnderlyingAtRate(_amount, getIBTRate());
    }

    function _convertIBTToUnderlyingAtRate(uint256 _amount, uint256 _rate) internal view virtual returns (uint256) {
        return (_amount.mul(_rate) / IBT_UNIT);
    }

    function convertUnderlyingtoIBT(uint256 _amount) public view virtual override returns (uint256) {
        return _convertUnderlyingtoIBTAtRate(_amount, getIBTRate());
    }

    function _convertUnderlyingtoIBTAtRate(uint256 _amount, uint256 _rate) internal view virtual returns (uint256) {
        return _amount.mul(IBT_UNIT).div(_rate);
    }

     
    function getUnlockableFunds(address _user) public view virtual override returns (uint256) {
        return convertUnderlyingtoIBT(super.getUnlockableFunds(_user));
    }

     
    function getUnrealisedYieldPerPT() public view virtual override returns (uint256) {
        uint256 currRate = getIBTRate();
        uint256 currPeriodStartRate = IBTRates[getCurrentPeriodIndex()];
        if (currRate == currPeriodStartRate) return 0;
        uint256 amountOfIBTsAtStart = _convertUnderlyingtoIBTAtRate(IBT_UNIT, currPeriodStartRate);
        uint256 amountOfIBTsNow = _convertUnderlyingtoIBTAtRate(IBT_UNIT, currRate);
        return amountOfIBTsAtStart.sub(amountOfIBTsNow);
    }

     
    function getIBTRate() public view virtual returns (uint256);

     
    function getPTPerAmountDeposited(uint256 _amount) public view virtual override returns (uint256) {
        return _convertIBTToUnderlyingAtRate(_amount, IBTRates[getCurrentPeriodIndex()]);
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



 
abstract contract HybridFutureVault is RateFutureVault {
    using SafeMathUpgradeable for uint256;

    mapping(uint256 => uint256) internal scaledTotals;  

     
    function deposit(address _user, uint256 _amount) external virtual override periodsActive depositsEnabled onlyController {
        require((_amount > 0) && (_amount <= ibt.balanceOf(_user)), "HybridFutureVault: ERR_AMOUNT");
        _deposit(_user, _amount);
        uint256 currScaledTotals = scaledTotals[getCurrentPeriodIndex()];
        if (currScaledTotals == 0) {
            require(_amount > IBT_UNIT, "HybridFutureVault: ERR_FUTURE_INIT");  
            scaledTotals[getCurrentPeriodIndex()] = _amount;
        } else {
            scaledTotals[getCurrentPeriodIndex()] = currScaledTotals.add(
                convertUnderlyingtoIBT(getPTPerAmountDeposited(_amount))
            );
        }
        emit FundsDeposited(_user, _amount);
    }

     
    function _withdraw(address _user, uint256 _amount) internal virtual override {
        uint256 scaledAmountToRemove = convertUnderlyingtoIBT(getPTPerAmountDeposited(_amount));
        super._withdraw(_user, _amount);
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        scaledTotals[currentPeriodIndex] = scaledTotals[currentPeriodIndex].sub(scaledAmountToRemove);
    }

     
    function startNewPeriod() public virtual override nextPeriodAvailable periodsActive nonReentrant {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        _switchPeriod();
         
        IBTRates[getCurrentPeriodIndex()] = getIBTRate();
         
        scaledTotals[getCurrentPeriodIndex()] = ibt.balanceOf(address(this));
    }

     
    function getUnrealisedYieldPerPT() public view override returns (uint256) {
        uint256 totalUnderlyingAtStart = totalUnderlyingDeposited;
        if (totalUnderlyingAtStart == 0) return 0;
        uint256 totalUnderlyingNow = convertIBTToUnderlying(ibt.balanceOf(address(this)));
        uint256 yieldForAllPT = convertUnderlyingtoIBT(totalUnderlyingNow.sub(totalUnderlyingAtStart));
        return yieldForAllPT.mul(IBT_UNIT).div(totalUnderlyingAtStart);
    }

     
    function getPTPerAmountDeposited(uint256 _amount) public view override returns (uint256) {
        uint256 scaledAmount = APWineMaths.getScaledInput(
            _amount,
            scaledTotals[getCurrentPeriodIndex()],
            ibt.balanceOf(address(this))
        );
        return _convertIBTToUnderlyingAtRate(scaledAmount, IBTRates[getCurrentPeriodIndex()]);
    }
}

 

pragma solidity 0.7.6;



interface IERC20 is IERC20Upgradeable {
     
    function name() external returns (string memory);

     
    function symbol() external returns (string memory);

     
    function decimals() external view returns (uint8);

     
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

     
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}
 

pragma solidity 0.7.6;



 
contract PaladinFutureVault is HybridFutureVault {
    IpalStTokenPool public constant POOL_CONTRACT = IpalStTokenPool(0xCDc3DD86C99b58749de0F697dfc1ABE4bE22216d);

     
    function getIBTRate() public view virtual override returns (uint256) {
        return POOL_CONTRACT.exchangeRateStored();
    }
}

 

pragma solidity 0.7.6;

interface IpalStTokenPool {
    function exchangeRateStored() external view returns (uint256);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeMathUpgradeable {
     
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





 
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity 0.7.6;



interface IFutureYieldToken is IERC20 {
     
    function burn(uint256 amount) external;

     
    function burnFrom(address account, uint256 amount) external;

     
    function mint(address to, uint256 amount) external;

     
    function recordedBalanceOf(address account) external view returns (uint256);

     
    function balanceOf(address account) external view override returns (uint256);

     
    function futureVault() external view returns (address);

     
    function internalPeriodID() external view returns (uint256);
}

 

pragma solidity 0.7.6;



interface IPT is IERC20 {
     
    function burn(uint256 amount) external;

     
    function mint(address to, uint256 amount) external;

     
    function burnFrom(address account, uint256 amount) external;

     
    function pause() external;

     
    function unpause() external;

     
    function recordedBalanceOf(address account) external view returns (uint256);

     
    function balanceOf(address account) external view override returns (uint256);

     
    function futureVault() external view returns (address);
}

 

pragma solidity 0.7.6;

interface IFutureWallet {
     

    event YieldRedeemed(address _user, uint256 _periodIndex);
    event WithdrawalsPaused();
    event WithdrawalsResumed();

     
    function registerExpiredFuture(uint256 _amount) external;

     
    function redeemYield(uint256 _periodIndex) external;

     
    function getRedeemableYield(uint256 _periodIndex, address _user) external view returns (uint256);

     
    function getFutureVaultAddress() external view returns (address);

     
    function getIBTAddress() external view returns (address);

     

     
    function harvestRewards() external;

     
    function redeemAllWalletRewards() external;

     
    function redeemWalletRewards(address _rewardToken) external;

     
    function getRewardsRecipient() external view returns (address);

     
    function setRewardRecipient(address _recipient) external;
}

 

pragma solidity 0.7.6;



interface IController {
     

    event NextPeriodSwitchSet(uint256 _periodDuration, uint256 _nextSwitchTimestamp);
    event NewPeriodDurationIndexSet(uint256 _periodIndex);
    event FutureRegistered(IFutureVault _futureVault);
    event FutureUnregistered(IFutureVault _futureVault);
    event StartingDelaySet(uint256 _startingDelay);
    event NewPerformanceFeeFactor(IFutureVault _futureVault, uint256 _feeFactor);
    event FutureTerminated(IFutureVault _futureVault);
    event DepositsPaused(IFutureVault _futureVault);
    event DepositsResumed(IFutureVault _futureVault);
    event WithdrawalsPaused(IFutureVault _futureVault);
    event WithdrawalsResumed(IFutureVault _futureVault);
    event RegistryChanged(IRegistry _registry);
    event FutureSetToBeTerminated(IFutureVault _futureVault);

     

    function STARTING_DELAY() external view returns (uint256);

     

     
    function deposit(address _futureVault, uint256 _amount) external;

     
    function withdraw(address _futureVault, uint256 _amount) external;

     
    function exitTerminatedFuture(address _futureVault, address _user) external;

     
    function createFYTDelegationTo(
        address _futureVault,
        address _receiver,
        uint256 _amount
    ) external;

     
    function withdrawFYTDelegationFrom(
        address _futureVault,
        address _receiver,
        uint256 _amount
    ) external;

     

     
    function getRegistryAddress() external view returns (address);

     
    function getPeriodIndex(uint256 _periodDuration) external view returns (uint256);

     
    function getNextPeriodStart(uint256 _periodDuration) external view returns (uint256);

     
    function getNextPerformanceFeeFactor(address _futureVault) external view returns (uint256);

     
    function getCurrentPerformanceFeeFactor(address _futureVault) external view returns (uint256);

     
    function getDurations() external view returns (uint256[] memory durationsList);

     
    function getFuturesWithDuration(uint256 _periodDuration) external view returns (address[] memory filteredFutures);

     
    function isFutureTerminated(address _futureVault) external view returns (bool);

     
    function isFutureSetToBeTerminated(address _futureVault) external view returns (bool);

     
    function isWithdrawalsPaused(address _futureVault) external view returns (bool);

     
    function isDepositsPaused(address _futureVault) external view returns (bool);
}

 

pragma solidity 0.7.6;


interface IRegistry {
     
     
    function setTreasury(address _newTreasury) external;

     
    function setController(address _newController) external;

     
    function setPTLogic(address _PTLogic) external;

     
    function setFYTLogic(address _FYTLogic) external;

     
    function getControllerAddress() external view returns (address);

     
    function getTreasuryAddress() external view returns (address);

     
    function getTokensFactoryAddress() external view returns (address);

     
    function getPTLogicAddress() external view returns (address);

     
    function getFYTLogicAddress() external view returns (address);

     
     
    function addFutureVault(address _future) external;

     
    function removeFutureVault(address _future) external;

     
    function isRegisteredFutureVault(address _future) external view returns (bool);

     
    function getFutureVaultAt(uint256 _index) external view returns (address);

     
    function futureVaultCount() external view returns (uint256);
}

 

pragma solidity 0.7.6;

interface ITokensFactory {
    function deployNextFutureYieldToken(uint256 nextPeriodIndex) external returns (address newToken);

    function deployPT(
        string memory _ibtSymbol,
        uint256 _ibtDecimals,
        string memory _platformName,
        uint256 _perioDuration
    ) external returns (address newToken);
}

 

pragma solidity 0.7.6;



library APWineMaths {
    using SafeMathUpgradeable for uint256;

     
    function getScaledInput(
        uint256 _actualValue,
        uint256 _initialSum,
        uint256 _actualSum
    ) internal pure returns (uint256) {
        if (_initialSum == 0 || _actualSum == 0) return _actualValue;
        return (_actualValue.mul(_initialSum)).div(_actualSum);
    }

     
    function getActualOutput(
        uint256 _scaledOutput,
        uint256 _initialSum,
        uint256 _actualSum
    ) internal pure returns (uint256) {
        if (_initialSum == 0 || _actualSum == 0) return 0;
        return (_scaledOutput.mul(_actualSum)).div(_initialSum);
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





interface IFutureVault {
     
    event NewPeriodStarted(uint256 _newPeriodIndex);
    event FutureWalletSet(address _futureWallet);
    event RegistrySet(IRegistry _registry);
    event FundsDeposited(address _user, uint256 _amount);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PTSet(IPT _pt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();
    event DelegationCreated(address _delegator, address _receiver, uint256 _amount);
    event DelegationRemoved(address _delegator, address _receiver, uint256 _amount);

     
     
    function PERIOD_DURATION() external view returns (uint256);

     
    function PLATFORM_NAME() external view returns (string memory);

     
    function startNewPeriod() external;

     
    function exitTerminatedFuture(address _user) external;

     
    function updateUserState(address _user) external;

     
    function claimFYT(address _user, uint256 _amount) external;

     
    function deposit(address _user, uint256 _amount) external;

     
    function withdraw(address _user, uint256 _amount) external;

     
    function createFYTDelegationTo(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;

     
    function withdrawFYTDelegationFrom(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;

     

     
    function getTotalDelegated(address _delegator) external view returns (uint256 totalDelegated);

     
    function getNextPeriodIndex() external view returns (uint256);

     
    function getCurrentPeriodIndex() external view returns (uint256);

     
    function getClaimablePT(address _user) external view returns (uint256);

     
    function getUserEarlyUnlockablePremium(address _user)
        external
        view
        returns (uint256 premiumLocked, uint256 amountRequired);

     
    function getUnlockableFunds(address _user) external view returns (uint256);

     
    function getClaimableFYTForPeriod(address _user, uint256 _periodIndex) external view returns (uint256);

     
    function getUnrealisedYieldPerPT() external view returns (uint256);

     
    function getPTPerAmountDeposited(uint256 _amount) external view returns (uint256);

     
    function getPremiumPerUnderlyingDeposited(uint256 _amount) external view returns (uint256);

     
    function getTotalUnderlyingDeposited() external view returns (uint256);

     
    function getYieldOfPeriod(uint256 _periodID) external view returns (uint256);

     
    function getControllerAddress() external view returns (address);

     
    function getFutureWalletAddress() external view returns (address);

     
    function getIBTAddress() external view returns (address);

     
    function getPTAddress() external view returns (address);

     
    function getFYTofPeriod(uint256 _periodIndex) external view returns (address);

     
    function isTerminated() external view returns (bool);

     
    function getPerformanceFeeFactor() external view returns (uint256);

     

     
    function harvestRewards() external;

     
    function redeemAllVaultRewards() external;

     
    function redeemVaultRewards(address _rewardToken) external;

     
    function addRewardsToken(address _token) external;

     
    function isRewardToken(address _token) external view returns (bool);

     
    function getRewardTokenAt(uint256 _index) external view returns (address);

     
    function getRewardTokensCount() external view returns (uint256);

     
    function getRewardsRecipient() external view returns (address);

     
    function setRewardRecipient(address _recipient) external;

     

     
    function setFutureWallet(IFutureWallet _futureWallet) external;

     
    function setRegistry(IRegistry _registry) external;

     
    function pauseLiquidityTransfers() external;

     
    function resumeLiquidityTransfers() external;

     
    function convertIBTToUnderlying(uint256 _amount) external view returns (uint256);

     
    function convertUnderlyingtoIBT(uint256 _amount) external view returns (uint256);
}
