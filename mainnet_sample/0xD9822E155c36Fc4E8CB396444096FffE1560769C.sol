// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// 

pragma solidity >=0.6.0 <0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
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
}

// 
pragma solidity ^0.7.6;

contract AccessRoleCommon {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER");
    bytes32 public constant PROJECT_ADMIN_ROLE = keccak256("PROJECT_ADMIN_ROLE");
}

// 

pragma solidity >=0.6.0 <0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

//
pragma solidity ^0.7.6;

interface IPublicSaleProxyFactory {

    
    
    
    
    
    
    function create(
        string calldata name,
        address _owner,
        address[3] calldata saleAddresses,
        uint256 _index
    )
        external
        returns (address);

    
    
    function basicSet(
        address[6] calldata _basicAddress
    )
        external;

    
    
    
    function allSet(
        address[3] calldata _addr,
        uint256[7] calldata _value
    ) 
        external;

    
    
    function setUpgradeAdmin(
        address addr
    )   
        external;

    
    
    
    function setMaxMin(
        uint256 _min,
        uint256 _max
    )
        external;

    
    
    function setVault(
        address _vaultFactory
    )
        external;

    
    
    function setEventLog(
        address _addr
    )
        external;

    
    
    
    
    
    function setSTOS(
        uint256 _tier1,
        uint256 _tier2,
        uint256 _tier3,
        uint256 _tier4
    ) 
        external;

    
    
    function setDelay(
        uint256 _delay
    )
        external;

    
    function lastestCreated() external view returns (address contractAddress, string memory name);

    
    function getContracts(uint256 _index) external view returns (address contractAddress, string memory name);


}

// 
pragma solidity ^0.7.6;



contract AccessibleCommon is AccessRoleCommon, AccessControl {
    modifier onlyOwner() {
        require(isAdmin(msg.sender), "Accessible: Caller is not an admin");
        _;
    }

    
    
    function addAdmin(address account) public virtual onlyOwner {
        grantRole(ADMIN_ROLE, account);
    }

    
    
    function removeAdmin(address account) public virtual onlyOwner {
        renounceRole(ADMIN_ROLE, account);
    }

    
    
    function transferAdmin(address newAdmin) external virtual onlyOwner {
        require(newAdmin != address(0), "Accessible: zero address");
        require(msg.sender != newAdmin, "Accessible: same admin");

        grantRole(ADMIN_ROLE, newAdmin);
        renounceRole(ADMIN_ROLE, msg.sender);
    }

    
    
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }
}

//
pragma solidity ^0.7.6;

interface IPublicSaleProxy {
    
    
    function setImplementation(address _impl) external;
    
    
    function setProxyPause(bool _pause) external;

    
    
    function upgradeTo(address _impl) external;

    
    
    function implementation() external view returns (address);

    
    function initialize(
        address _saleTokenAddress,
        address _getTokenOwner,
        address _vaultAddress
    ) external;

    
    function changeBasicSet(
        address _getTokenAddress,
        address _sTOS,
        address _wton,
        address _uniswapRouter,
        address _TOS
    ) external;

    
    
    
    function setMaxMinPercent(
        uint256 _min,
        uint256 _max
    ) external;

    
    
    
    
    
    function setSTOSstandard(
        uint256 _tier1,
        uint256 _tier2,
        uint256 _tier3,
        uint256 _tier4
    ) external;

    
    
    function setDelayTime(
        uint256 _delay
    ) external;
}

// 
pragma solidity ^0.7.6;



contract ProxyAccessCommon is AccessRoleCommon, AccessControl {
    modifier onlyOwner() {
        require(isAdmin(msg.sender) || isProxyAdmin(msg.sender), "Accessible: Caller is not an admin");
        _;
    }

    modifier onlyProxyOwner() {
        require(isProxyAdmin(msg.sender), "Accessible: Caller is not an proxy admin");
        _;
    }

    function addProxyAdmin(address _owner)
        external
        onlyProxyOwner
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    function removeProxyAdmin()
        public virtual onlyProxyOwner
    {
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function transferProxyAdmin(address newAdmin)
        external virtual
        onlyProxyOwner
    {
        require(newAdmin != address(0), "Accessible: zero address");
        require(msg.sender != newAdmin, "Accessible: same admin");

        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    
    
    function addAdmin(address account) public virtual onlyProxyOwner {
        grantRole(PROJECT_ADMIN_ROLE, account);
    }

    
    function removeAdmin() public virtual onlyOwner {
        renounceRole(PROJECT_ADMIN_ROLE, msg.sender);
    }

    
    
    function transferAdmin(address newAdmin) external virtual onlyOwner {
        require(newAdmin != address(0), "Accessible: zero address");
        require(msg.sender != newAdmin, "Accessible: same admin");

        grantRole(PROJECT_ADMIN_ROLE, newAdmin);
        renounceRole(PROJECT_ADMIN_ROLE, msg.sender);
    }

    
    
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(PROJECT_ADMIN_ROLE, account);
    }

    function isProxyAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }
}

//

pragma solidity ^0.7.6;






contract PublicSaleStorage  {
    
    bool public pauseProxy;

    uint256 public snapshot = 0;
    uint256 public deployTime;              //contract 배포된 시간
    uint256 public delayTime;               //contract와 snapshot사이 시간

    uint256 public startAddWhiteTime = 0;
    uint256 public endAddWhiteTime = 0;
    uint256 public startExclusiveTime = 0;
    uint256 public endExclusiveTime = 0;

    uint256 public startDepositTime = 0;        //청약 시작시간
    uint256 public endDepositTime = 0;          //청약 끝시간

    uint256 public startClaimTime = 0;

    uint256 public totalUsers = 0;              //전체 세일 참여자 (라운드1,라운드2 포함, 유니크)
    uint256 public totalRound1Users = 0;         //라운드 1 참여자
    uint256 public totalRound2Users = 0;         //라운드 2 참여자
    uint256 public totalRound2UsersClaim = 0;    //라운드 2 참여자중 claim한사람

    uint256 public totalExSaleAmount = 0;       //총 exclu 실제 판매토큰 양 (exclusive)
    uint256 public totalExPurchasedAmount = 0;  //총 지불토큰 받은 양 (exclusive)

    uint256 public totalDepositAmount;          //총 청약 한 양 (openSale)

    uint256 public totalExpectSaleAmount;       //예정된 판매토큰 양 (exclusive)
    uint256 public totalExpectOpenSaleAmount;   //예정된 판매 토큰량 (opensale)

    uint256 public saleTokenPrice;  //판매하는 토큰(DOC)
    uint256 public payTokenPrice;   //받는 토큰(TON)

    uint256 public claimInterval; //클레임 간격 (epochtime)
    uint256 public claimPeriod;   //클레임 횟수
    uint256 public claimFirst;    //초기 클레임 percents

    uint256 public hardCap;       //hardcap 수량 (ton 기준)
    uint256 public changeTOS;     //ton -> tos로 변경하는 %
    uint256 public minPer;        //변경하는 % min
    uint256 public maxPer;        //변경하는 % max

    uint256 public stanTier1;     //최소 기준 Tier1
    uint256 public stanTier2;     //최소 기준 Tier2
    uint256 public stanTier3;     //최소 기준 Tier3
    uint256 public stanTier4;     //최소 기준 Tier4

    address public liquidityVaultAddress; //liquidityVault의 Address
    ISwapRouter public uniswapRouter;
    uint24 public constant poolFee = 3000;

    address public getTokenOwner;
    address public wton;
    address public getToken;

    IERC20 public saleToken;
    IERC20 public tos;
    ILockTOS public sTOS;

    address[] public depositors;
    address[] public whitelists;

    bool public adminWithdraw; //withdraw 실행여부

    uint256 public totalClaimCounts;
    uint256[] public claimTimes;
    uint256[] public claimPercents; 

    mapping (address => LibPublicSale.UserInfoEx) public usersEx;
    mapping (address => LibPublicSale.UserInfoOpen) public usersOpen;
    mapping (address => LibPublicSale.UserClaim) public usersClaim;

    mapping (uint => uint256) public tiers;         //티어별 가격 설정
    mapping (uint => uint256) public tiersAccount;  //티어별 화이트리스트 참여자 숫자 기록
    mapping (uint => uint256) public tiersExAccount;  //티어별 exclusiveSale 참여자 숫자 기록
    mapping (uint => uint256) public tiersPercents;  //티어별 퍼센트 기록
}

// 
pragma solidity ^0.7.6;



abstract contract ProxyBase {
    // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1))
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    
    
    function _setImplementation(address newImplementation) internal {
        require(
            Address.isContract(newImplementation),
            "ProxyBase: Cannot set a proxy implementation to a non-contract address"
        );

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }

    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}

//
pragma solidity ^0.7.6;



abstract contract OnApprove is ERC165 {
  constructor() {
    _registerInterface(OnApprove(this).onApprove.selector);
  }

  function onApprove(address owner, address spender, uint256 amount, bytes calldata data) external virtual returns (bool);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3SwapCallback {
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// 
pragma solidity ^0.7.6;









contract PublicSaleProxyFactory is AccessibleCommon, IPublicSaleProxyFactory {

    event CreatedPublicSaleProxy(address contractAddress, string name);

    modifier nonZeroAddress(address _addr) {
        require(_addr != address(0), "PublicSaleProxyFactory: zero");
        _;
    }
    struct ContractInfo {
        address contractAddress;
        string name;
    }

    
    uint256 public totalCreatedContracts ;

    uint256 public minTOS;
    uint256 public maxTOS;

    address public tonAddress;
    address public wtonAddress;
    address public sTOSAddress;
    address public tosAddress;
    address public uniRouterAddress;

    address public vaultFactory;
    address public logEventAddress;

    address public publicLogic;    
    address public upgradeAdmin;
    
    uint256 public tier1;
    uint256 public tier2;
    uint256 public tier3;
    uint256 public tier4;

    uint256 public delayTime;

    
    mapping(uint256 => ContractInfo) public createdContracts;

    
    constructor() {
        totalCreatedContracts = 0;

        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, msg.sender);
        upgradeAdmin = msg.sender;
    }

    
    
    /// saleAddress[0] = _saleTokenAddress, saleAddress[1] = getTokenOwner, saleAddress[2] = liquidityVaultAddress
    function create(
        string calldata name,
        address _owner,
        address[3] calldata saleAddresses,
        uint256 _index
    )
        external override
        nonZeroAddress(_owner)
        nonZeroAddress(saleAddresses[0])
        nonZeroAddress(saleAddresses[1])
        nonZeroAddress(saleAddresses[2])
        returns (address)
    {
        require(bytes(name).length > 0,"name is empty");

        PublicSaleProxy proxy = new PublicSaleProxy();

        require(
            address(proxy) != address(0),
            "proxy zero"
        );

        (address initialVault, ) = IVaultFactory(vaultFactory).getContracts(_index);
        require(initialVault == saleAddresses[2], "another liquidityVault");

        proxy.addProxyAdmin(upgradeAdmin);
        proxy.addAdmin(upgradeAdmin);
        proxy.addAdmin(_owner);
        proxy.setImplementation(publicLogic);

        proxy.initialize(
            saleAddresses[0],
            saleAddresses[1],
            saleAddresses[2]
        );

        proxy.changeBasicSet(
            tonAddress,
            sTOSAddress,
            wtonAddress,
            uniRouterAddress,
            tosAddress
        );

        proxy.setMaxMinPercent(
            minTOS,
            maxTOS
        );

        proxy.setSTOSstandard(
            tier1,
            tier2,
            tier3,
            tier4
        );

        proxy.setDelayTime(
            delayTime
        );


        proxy.removeAdmin();

        createdContracts[totalCreatedContracts] = ContractInfo(address(proxy), name);
        totalCreatedContracts++;

        bytes memory abiencode = abi.encode(address(proxy), name);

        IEventLog(logEventAddress).logEvent(
            keccak256("PublicSaleProxyFactory"),
            keccak256("CreatedPublicSaleProxy"),
            address(this),
            abiencode
        );

        emit CreatedPublicSaleProxy(address(proxy), name);

        return address(proxy);
    }

    
    function basicSet(
        address[6] calldata _basicAddress
    )
        external 
        override
        onlyOwner
    {
        tonAddress = _basicAddress[0];
        wtonAddress = _basicAddress[1];
        sTOSAddress = _basicAddress[2];
        tosAddress = _basicAddress[3];
        uniRouterAddress = _basicAddress[4];
        publicLogic = _basicAddress[5];
    }

    function allSet(
        address[3] calldata _addr,
        uint256[7] calldata _value
    ) 
        external
        override
        onlyOwner
    {
        setUpgradeAdmin(_addr[0]);
        setVault(_addr[1]);
        setEventLog(_addr[2]);
        setMaxMin(_value[0],_value[1]);
        setSTOS(_value[2],_value[3],_value[4],_value[5]);
        setDelay(_value[6]);
    }

    function setUpgradeAdmin(
        address addr
    )   
        public
        override 
        onlyOwner
        nonZeroAddress(addr)
    {
        require(addr != upgradeAdmin, "same addrs");
        upgradeAdmin = addr;
    }

    function setVault(
        address _vaultFactory
    )
        public
        override
        onlyOwner
    {
        require(_vaultFactory != vaultFactory, "same addrs");
        vaultFactory = _vaultFactory;
    }

    function setEventLog(
        address _addr
    )
        public
        override
        onlyOwner
    {   
        require(_addr != logEventAddress, "same addrs");
        logEventAddress = _addr;
    }

    function setMaxMin(
        uint256 _min,
        uint256 _max
    )
        public
        override
        onlyOwner
    {
        require(_min < _max, "need min < max");
        minTOS = _min;
        maxTOS = _max;
    }

    function setSTOS(
        uint256 _tier1,
        uint256 _tier2,
        uint256 _tier3,
        uint256 _tier4
    ) 
        public
        override
        onlyOwner
    {
        require(
            (_tier1 < _tier2) &&
            (_tier2 < _tier3) &&
            (_tier3 < _tier4),
            "tier set error"
        );
        tier1 = _tier1;
        tier2 = _tier2;
        tier3 = _tier3;
        tier4 = _tier4;
    }

    function setDelay(
        uint256 _delay
    )
        public
        override
        onlyOwner
    {
        require(delayTime != _delay, "same value");
        delayTime = _delay;
    }
    
    

    
    function lastestCreated() external view override returns (address contractAddress, string memory name){
        if(totalCreatedContracts > 0){
            return (createdContracts[totalCreatedContracts-1].contractAddress, createdContracts[totalCreatedContracts-1].name );
        } else {
            return (address(0), "");
        }
    }

    
    function getContracts(uint256 _index) external view override returns (address contractAddress, string memory name){
        if(_index < totalCreatedContracts){
            return (createdContracts[_index].contractAddress, createdContracts[_index].name);
        } else {
            return (address(0), "");
        }
    }

}

// 

pragma solidity ^0.7.6;











contract PublicSaleProxy is
    PublicSaleStorage,
    ProxyAccessCommon,
    ProxyBase,
    OnApprove,
    IPublicSaleProxy
{
    event Upgraded(address indexed implementation);

    event Pause(address indexed addr, uint256 time);

    
    constructor() {
        assert(
            IMPLEMENTATION_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
        );

        _setRoleAdmin(PROJECT_ADMIN_ROLE, PROJECT_ADMIN_ROLE);
        _setupRole(PROJECT_ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    
    
    function setImplementation(address _impl) external override onlyProxyOwner {
        require(_impl != address(0), "PublicSaleProxy: logic is zero");

        _setImplementation(_impl);
    }

    
    
    function setProxyPause(bool _pause) external override onlyOwner {
        pauseProxy = _pause;
        emit Pause(msg.sender,block.timestamp);
    }

    
    
    function upgradeTo(address impl) external override onlyProxyOwner {
        require(impl != address(0), "PublicSaleProxy: input is zero");
        require(_implementation() != impl, "PublicSaleProxy: same");
        _setImplementation(impl);
        emit Upgraded(impl);
    }

    
    function implementation() public override view returns (address) {
        return _implementation();
    }

    
    receive() external payable {
        revert("cannot receive Ether");
    }

    
    fallback() external payable {
        _fallback();
    }

    
    function _fallback() internal {
        address _impl = _implementation();
        require(
            _impl != address(0) && !pauseProxy,
            "PublicSaleProxy: impl OR proxy is false"
        );

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
                // delegatecall returns 0 on error.
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    
    function initialize(
        address _saleTokenAddress,
        address _getTokenOwner,
        address _vaultAddress
    ) external override onlyProxyOwner {
        require(startAddWhiteTime == 0, "possible to setting the whiteTime before");
        saleToken = IERC20(_saleTokenAddress);
        getTokenOwner = _getTokenOwner;
        liquidityVaultAddress = _vaultAddress;
        deployTime = block.timestamp;
    }

    function changeBasicSet(
        address _getTokenAddress,
        address _sTOS,
        address _wton,
        address _uniswapRouter,
        address _TOS
    ) external override onlyProxyOwner {
        require(startAddWhiteTime == 0, "possible to setting the whiteTime before");
        getToken = _getTokenAddress;
        sTOS = ILockTOS(_sTOS);
        wton = _wton;
        uniswapRouter = ISwapRouter(_uniswapRouter);
        tos = IERC20(_TOS);
        IERC20(wton).approve(
            address(uniswapRouter),
            type(uint256).max
        );
        IERC20(getToken).approve(
            wton,
            type(uint256).max
        );
    }

    function setMaxMinPercent(
        uint256 _min,
        uint256 _max
    ) external override onlyProxyOwner {
        require(_min < _max, "need min < max");
        minPer = _min;
        maxPer = _max;
    }

    function setSTOSstandard(
        uint256 _tier1,
        uint256 _tier2,
        uint256 _tier3,
        uint256 _tier4
    ) external override onlyProxyOwner {
        require(
            (_tier1 < _tier2) &&
            (_tier2 < _tier3) &&
            (_tier3 < _tier4),
            "tier set error"
        );
        stanTier1 = _tier1;
        stanTier2 = _tier2;
        stanTier3 = _tier3;
        stanTier4 = _tier4;
    }

    function setDelayTime(
        uint256 _delay
    ) external override onlyProxyOwner {
        delayTime = _delay;
    }

    function onApprove(
        address sender,
        address spender,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require(msg.sender == address(getToken) || msg.sender == address(IWTON(wton)), "PublicSale: only accept TON and WTON approve callback");
        if(msg.sender == address(getToken)) {
            uint256 wtonAmount = IPublicSale(address(this))._decodeApproveData(data);
            if(wtonAmount == 0){
                if(block.timestamp >= startExclusiveTime && block.timestamp < endExclusiveTime) {
                    IPublicSale(address(this)).exclusiveSale(sender,amount);
                } else {
                    require(block.timestamp >= startDepositTime && block.timestamp < endDepositTime, "PublicSale: not SaleTime");
                    IPublicSale(address(this)).deposit(sender,amount);
                }
            } else {
                uint256 totalAmount = amount + wtonAmount;
                if(block.timestamp >= startExclusiveTime && block.timestamp < endExclusiveTime) {
                    IPublicSale(address(this)).exclusiveSale(sender,totalAmount);
                }
                else {
                    require(block.timestamp >= startDepositTime && block.timestamp < endDepositTime, "PublicSale: not SaleTime");
                    IPublicSale(address(this)).deposit(sender,totalAmount);
                }
            }
        } else if (msg.sender == address(IWTON(wton))) {
            uint256 wtonAmount = IPublicSale(address(this))._toWAD(amount);
            if(block.timestamp >= startExclusiveTime && block.timestamp < endExclusiveTime) {
                IPublicSale(address(this)).exclusiveSale(sender,wtonAmount);
            }
            else {
                require(block.timestamp >= startDepositTime && block.timestamp < endDepositTime, "PublicSale: not SaleTime");
                IPublicSale(address(this)).deposit(sender,wtonAmount);
            }
        }

        return true;
    }
}

//
pragma solidity ^0.7.6;

interface IVaultFactory {

    /// ###### only admin ######

    
    
    function setUpgradeAdmin(
        address addr
    )   external;


    
    
    function setLogic(
        address _logic
    )   external;


    
    
    
    
    
    function upgradeContractLogic(
        address _contract,
        address _logic,
        uint256 _index,
        bool _alive
    )   external;


    
    
    
    
    function upgradeContractFunction(
        address _contract,
        bytes4[] calldata _selectors,
        address _imp
    )   external;


    
    
    function upgradeAdmin() external view returns (address admin);


    
    
    function vaultLogic() external view returns (address logic);


    /// ### anybody can use

    
    
    
    function lastestCreated() external view returns (address contractAddress, string memory name);


    
    
    
    function getContracts(uint256 _index) external view returns (address contractAddress, string memory name);


    
    
    function totalCreatedContracts() external view returns (uint256 total);

}

//
pragma solidity ^0.7.6;



interface IEventLog {

    
    
    
    
    
    function logEvent(
        bytes32 contractNameHash,
        bytes32 eventNameHash,
        address contractAddress,
        bytes memory data
        )
        external;
}

// 
pragma solidity ^0.7.6;

interface IWTON {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function onApprove(
        address owner,
        address spender,
        uint256 tonAmount,
        bytes calldata data
    ) external returns (bool);

    function burnFrom(address account, uint256 amount) external;

    function swapToTON(uint256 wtonAmount) external returns (bool);

    function swapFromTON(uint256 tonAmount) external returns (bool);

    function swapToTONAndTransfer(address to, uint256 wtonAmount)
        external
        returns (bool);

    function swapFromTONAndTransfer(address to, uint256 tonAmount)
        external
        returns (bool);

    function renounceTonMinter() external;

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address sender, address recipient) external returns (uint256);

}

//
pragma solidity ^0.7.6;

interface IPublicSale {
    
    function changeTONOwner(
        address _address
    ) external; 

    
    
    
    
    
    
    function setAllsetting(
        uint256[8] calldata _Tier,
        uint256[6] calldata _amount,
        uint256[8] calldata _time,
        uint256[] calldata _claimTimes,
        uint256[] calldata _claimPercents
    ) external;
    
    
    
    function setSnapshot(uint256 _snapshot) external;

    
    
    
    
    
    function setExclusiveTime(
        uint256 _startAddWhiteTime,
        uint256 _endAddWhiteTime,
        uint256 _startExclusiveTime,
        uint256 _endExclusiveTime
    ) external;

    
    
    
    function setOpenTime(
        uint256 _startDepositTime,
        uint256 _endDepositTime
    ) external;

    
    
    
    
    function setEachClaim(
        uint256 _claimCounts,
        uint256[] calldata _claimTimes,
        uint256[] calldata _claimPercents
    ) external;

    
    
    
    function setAllTier(
        uint256[4] calldata _tier,
        uint256[4] calldata _tierPercent
    ) external;

    
    
    
    
    
    function setTier(
        uint256 _tier1,
        uint256 _tier2,
        uint256 _tier3,
        uint256 _tier4
    ) external;

    
    
    
    
    
    function setTierPercents(
        uint256 _tier1,
        uint256 _tier2,
        uint256 _tier3,
        uint256 _tier4
    ) external;

    
    
    
    function setAllAmount(
        uint256[2] calldata _expectAmount,
        uint256[2] calldata _priceAmount
    ) external;

    
    
    
    function setSaleAmount(
        uint256 _totalExpectSaleAmount,
        uint256 _totalExpectOpenSaleAmount
    ) external;

    
    
    
    function setTokenPrice(uint256 _saleTokenPrice, uint256 _payTokenPrice)
        external;

    
    
    
    function setHardcap (
        uint256 _hardcapAmount,
        uint256 _changePercent
    ) external;

    
    function totalExpectOpenSaleAmountView()
        external
        view
        returns(uint256);

    
    function totalRound1NonSaleAmount() 
        external 
        view 
        returns(uint256);

    
    
    function calculSaleToken(uint256 _amount) external view returns (uint256);

    
    
    function calculPayToken(uint256 _amount) external view returns (uint256);

    
    
    function calculTier(address _address) external view returns (uint256);

    
    
    function calculTierAmount(address _address) external view returns (uint256);

    
    
    
    function calculOpenSaleAmount(address _account, uint256 _amount)
        external
        view
        returns (uint256);

    
    
    function calculClaimAmount(address _account, uint256 _period)
        external
        view
        returns (uint256 _reward, uint256 _totalClaim, uint256 _refundAmount);


    
    function totalSaleUserAmount(address user) 
        external 
        view 
        returns (uint256 _realPayAmount, uint256 _realSaleAmount, uint256 _refundAmount);

    
    function openSaleUserAmount(address user) 
        external 
        view 
        returns (uint256 _realPayAmount, uint256 _realSaleAmount, uint256 _refundAmount);
    
    
    function totalOpenSaleAmount() 
        external 
        view 
        returns (uint256);

    
    function totalOpenPurchasedAmount() 
        external
        view 
        returns (uint256);

    
    function addWhiteList() external;

    
    
    
    function exclusiveSale(address _sender,uint256 _amount) external;

    
    
    
    function deposit(address _sender,uint256 _amount) external;

    
    function claim() external;

    
    function depositWithdraw() external;

    function _decodeApproveData(
        bytes memory data
    ) external pure returns (uint256 approveData);

    function _toWAD(uint256 v) external pure returns (uint256);

}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// 

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
pragma solidity ^0.7.6;





interface ILockTOS {
    
    
    function allHolders() external returns (address[] memory);

    
    function activeHolders() external returns (address[] memory);

    
    function withdrawableLocksOf(address user) external view returns (uint256[] memory);

    
    function locksOf(address _addr) external view returns (uint256[] memory);

    
    function activeLocksOf(address _addr) external view returns (uint256[] memory);

    
    function totalLockedAmountOf(address _addr) external view returns (uint256);

    
    function withdrawableAmountOf(address _addr) external view returns (uint256);

    
    function locksInfo(uint256 _lockId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    
    function pointHistoryOf(uint256 _lockId)
        external
        view
        returns (LibLockTOS.Point[] memory);

    
    function totalSupply() external view returns (uint256);

    
    function totalSupplyAt(uint256 _timestamp) external view returns (uint256);

    
    function balanceOfLockAt(uint256 _lockId, uint256 _timestamp)
        external
        view
        returns (uint256);

    
    function balanceOfLock(uint256 _lockId) external view returns (uint256);

    
    function balanceOfAt(address _addr, uint256 _timestamp)
        external
        view
        returns (uint256 balance);

    
    function balanceOf(address _addr) external view returns (uint256 balance);

    
    function increaseAmount(uint256 _lockId, uint256 _value) external;

    
    function depositFor(
        address _addr,
        uint256 _lockId,
        uint256 _value
    ) external;

    
    function createLockWithPermit(
        uint256 _value,
        uint256 _unlockTime,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint256 lockId);

    
    function createLock(uint256 _value, uint256 _unlockTime)
        external
        returns (uint256 lockId);

    
    function increaseUnlockTime(uint256 _lockId, uint256 unlockTime) external;

    
    function withdrawAll() external;

    
    function withdraw(uint256 _lockId) external;
    
    
    function needCheckpoint() external view returns (bool need);

    
    function globalCheckpoint() external;

    
    function setMaxTime(uint256 _maxTime) external;
}

// 
pragma solidity ^0.7.6;

library LibPublicSale {
    struct UserInfoEx {
        bool join;
        uint tier;
        uint256 payAmount;
        uint256 saleAmount;
    }

    struct UserInfoOpen {
        bool join;
        uint256 depositAmount;
        uint256 payAmount;
    }

    struct UserClaim {
        bool exec;
        uint256 claimAmount;
        uint256 refundAmount;
    }
}

// 
pragma solidity >=0.7.5;






interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

// 
pragma solidity ^0.7.6;

library LibLockTOS {
    struct Point {
        int256 bias;
        int256 slope;
        uint256 timestamp;
    }

    struct LockedBalance {
        uint256 start;
        uint256 end;
        uint256 amount;
        bool withdrawn;
    }

    struct SlopeChange {
        int256 bias;
        int256 slope;
        uint256 changeTime;
    }

    struct LockedBalanceInfo {
        uint256 id;
        uint256 start;
        uint256 end;
        uint256 amount;
        uint256 balance;
    }
}
