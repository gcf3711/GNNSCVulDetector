 
pragma abicoder v2;


 

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

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
 

pragma solidity >=0.6.0 <0.8.0;





 
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
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
}

 
pragma solidity ^0.7.6;

contract AccessRoleCommon {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER");
    bytes32 public constant PROJECT_ADMIN_ROLE = keccak256("PROJECT_ADMIN_ROLE");
}

 

pragma solidity >=0.6.0 <0.8.0;



 
abstract contract ERC165 is IERC165 {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
         
         
        _registerInterface(_INTERFACE_ID_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

 
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

 

pragma solidity ^0.7.6;






contract PublicSaleStorage  {
    
    bool public pauseProxy;

    uint256 public snapshot = 0;
    uint256 public deployTime;               
    uint256 public delayTime;                

    uint256 public startAddWhiteTime = 0;
    uint256 public endAddWhiteTime = 0;
    uint256 public startExclusiveTime = 0;
    uint256 public endExclusiveTime = 0;

    uint256 public startDepositTime = 0;         
    uint256 public endDepositTime = 0;           

    uint256 public startClaimTime = 0;

    uint256 public totalUsers = 0;               
    uint256 public totalRound1Users = 0;          
    uint256 public totalRound2Users = 0;          
    uint256 public totalRound2UsersClaim = 0;     

    uint256 public totalExSaleAmount = 0;        
    uint256 public totalExPurchasedAmount = 0;   

    uint256 public totalDepositAmount;           

    uint256 public totalExpectSaleAmount;        
    uint256 public totalExpectOpenSaleAmount;    

    uint256 public saleTokenPrice;   
    uint256 public payTokenPrice;    

    uint256 public claimInterval;  
    uint256 public claimPeriod;    
    uint256 public claimFirst;     

    uint256 public hardCap;        
    uint256 public changeTOS;      
    uint256 public minPer;         
    uint256 public maxPer;         

    uint256 public stanTier1;      
    uint256 public stanTier2;      
    uint256 public stanTier3;      
    uint256 public stanTier4;      

    address public liquidityVaultAddress;  
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

    bool public adminWithdraw;  

    uint256 public totalClaimCounts;
    uint256[] public claimTimes;
    uint256[] public claimPercents; 

    mapping (address => LibPublicSale.UserInfoEx) public usersEx;
    mapping (address => LibPublicSale.UserInfoOpen) public usersOpen;
    mapping (address => LibPublicSale.UserClaim) public usersClaim;

    mapping (uint => uint256) public tiers;          
    mapping (uint => uint256) public tiersAccount;   
    mapping (uint => uint256) public tiersExAccount;   
    mapping (uint => uint256) public tiersPercents;   
}

 
pragma solidity ^0.7.6;



abstract contract ProxyBase {
     
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

 
pragma solidity ^0.7.6;



abstract contract OnApprove is ERC165 {
  constructor() {
    _registerInterface(OnApprove(this).onApprove.selector);
  }

  function onApprove(address owner, address spender, uint256 amount, bytes calldata data) external virtual returns (bool);
}

 
pragma solidity >=0.5.0;



interface IUniswapV3SwapCallback {
    
    
     
     
    
     
    
     
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
 
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
             
             
             
            calldatacopy(0, 0, calldatasize())

             
             
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

             
            returndatacopy(0, 0, returndatasize())

            switch result
                 
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

 
pragma solidity ^0.7.6;

interface IVaultFactory {

     

    
    
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


     

    
    
    
    function lastestCreated() external view returns (address contractAddress, string memory name);


    
    
    
    function getContracts(uint256 _index) external view returns (address contractAddress, string memory name);


    
    
    function totalCreatedContracts() external view returns (uint256 total);

}

 
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
