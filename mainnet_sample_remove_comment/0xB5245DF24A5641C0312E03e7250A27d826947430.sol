 
pragma abicoder v2;
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

 

pragma solidity 0.7.6;


 
interface IAMMRouterV1 {
     
    function swapExactAmountIn(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _tokenAmountIn,
        uint256 _minAmountOut,
        address _to,
        uint256 _deadline,
        address _referralRecipient
    ) external returns (uint256 tokenAmountOut);

     
    function swapExactAmountOut(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _maxAmountIn,
        uint256 _tokenAmountOut,
        address _to,
        uint256 _deadline,
        address _referralRecipient
    ) external returns (uint256 tokenAmountIn);

     
    function getSpotPrice(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath
    ) external returns (uint256 spotPrice);

     
    function getAmountIn(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _tokenAmountOut
    ) external returns (uint256 tokenAmountIn);

     
    function getAmountOut(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _tokenAmountIn
    ) external returns (uint256 tokenAmountOut);
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
 

pragma solidity ^0.7.6;











contract AMMRouterV1 is IAMMRouterV1, AccessControlUpgradeable {
    using SafeERC20Upgradeable for IERC20;
    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint256 internal constant UNIT = 10**18;
    uint256 private constant MAX_UINT256 = uint256(-1);
    bytes32 internal constant ADMIN_ROLE = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;
    bytes32 internal constant WHITELIST_ROLE = 0xdc72ed553f2544c34465af23b847953efeb813428162d767f9ba5f4013be6760;

    IAMMRegistry public registry;
    uint256 public GOVERNANCE_FEE;
    mapping(address => uint256) public REFERRAL_FEE;  
    EnumerableSetUpgradeable.AddressSet internal referralAddresses;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "AMMRouterV1: Deadline has expired");
        _;
    }

    modifier isValidAmm(address _ammAddress) {
        require(registry.isRegisteredAMM(_ammAddress), "AMMRouterV1: invalid amm address");
        _;
    }

    event RegistrySet(IAMMRegistry _registry);
    event TokenApproved(IERC20 _token, IAMM _amm);
    event GovernanceFeeUpdated(uint256 _fee);
    event GovernanceFeeCollected(IERC20 _token, uint256 _amount, address _recipient);
    event ReferralRecipientAdded(address _recipient);
    event ReferralRecipientRemoved(address _recipient);
    event ReferralSet(address _recipient, uint256 _fee);
    event ReferralFeePaid(address _recipient, uint256 _feeAmount);

    function initialize(IAMMRegistry _registry, address _admin) public virtual initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        registry = _registry;
        emit RegistrySet(_registry);
    }

     
    function swapExactAmountIn(
        IAMM _amm,
        uint256[] calldata _pairPath,  
        uint256[] calldata _tokenPath,  
        uint256 _tokenAmountIn,
        uint256 _minAmountOut,
        address _to,
        uint256 _deadline,
        address _referralRecipient
    ) public override ensure(_deadline) returns (uint256 tokenAmountOut) {
        uint256 _currentTokenAmountIn = _pushFees(_amm, _pairPath, _tokenPath, _tokenAmountIn, _referralRecipient, false);

        uint256 _pairPathMaxIndex = _pairPath.length;
        require(_pairPathMaxIndex <= 2 && _pairPathMaxIndex > 0, "AMMRouterV1: invalid path length");
        (_currentTokenAmountIn, ) = _amm.swapExactAmountIn(
            _pairPath[0],
            _tokenPath[0],
            _currentTokenAmountIn,
            _tokenPath[1],
            0,  
            _pairPathMaxIndex == 1 ? _to : address(this)  
        );

        if (_pairPathMaxIndex == 2) {
            (_currentTokenAmountIn, ) = _amm.swapExactAmountIn(
                _pairPath[1],
                _tokenPath[2],
                _currentTokenAmountIn,
                _tokenPath[3],
                0,  
                _to  
            );
        }

        require(_currentTokenAmountIn >= _minAmountOut, "AMMRouterV1: Min amount not reached");
        tokenAmountOut = _currentTokenAmountIn;  
    }

    function _pushFeesCalculation(uint256 _tokenAmountIn, bool _isSwappingOut)
        internal
        returns (
            uint256 _currentAmountIn,
            uint256 _feeAmount,
            uint256 _pushAmount
        )
    {
        if (_isSwappingOut) {
            _currentAmountIn = _tokenAmountIn.mul(UNIT).div(UNIT - GOVERNANCE_FEE);  
            _feeAmount = _currentAmountIn.sub(_tokenAmountIn);
            _pushAmount = _currentAmountIn;
        } else {
            _currentAmountIn = _tokenAmountIn.mul(UNIT - GOVERNANCE_FEE) / UNIT;  
            _feeAmount = _tokenAmountIn.sub(_currentAmountIn);
            _pushAmount = _tokenAmountIn;
        }
    }

    function _pushFees(
        IAMM _amm,
        uint256[] calldata _pairPath,  
        uint256[] calldata _tokenPath,  
        uint256 _tokenAmountIn,
        address _referralRecipient,
        bool _isSwappingOut
    ) internal returns (uint256 _currentAmountIn) {
        uint256 _feeAmount;
        uint256 _pushAmount;
        IERC20 tokenIn =
            _tokenPath[0] == 0 ? IERC20(_amm.getPTAddress()) : IERC20(_amm.getPairWithID(_pairPath[0]).tokenAddress);

        (_currentAmountIn, _feeAmount, _pushAmount) = _pushFeesCalculation(_tokenAmountIn, _isSwappingOut);
        tokenIn.safeTransferFrom(msg.sender, address(this), _pushAmount);
        uint256 referralFee = REFERRAL_FEE[_referralRecipient];
        if (referralFee != 0) {
            uint256 referralFeeAmount = _feeAmount.mul(referralFee) / UNIT;
            if (referralFeeAmount > 0) {
                tokenIn.safeTransfer(_referralRecipient, referralFeeAmount);
                emit ReferralFeePaid(_referralRecipient, referralFeeAmount);
            }
        }
    }

    function swapExactAmountOut(
        IAMM _amm,
        uint256[] calldata _pairPath,  
        uint256[] calldata _tokenPath,  
        uint256 _maxAmountIn,
        uint256 _tokenAmountOut,
        address _to,
        uint256 _deadline,
        address _referralRecipient
    ) external override ensure(_deadline) returns (uint256 tokenAmountIn) {
        uint256 _pairPathMaxIndex = _pairPath.length;
        require(_pairPathMaxIndex <= 2 && _pairPathMaxIndex > 0, "AMMRouterswapExactAmountOutV1: invalid path length");

        uint256 currentAmountInWithoutGovernance =
            _getAmountInWithoutGovernance(_amm, _pairPath, _tokenPath, _tokenAmountOut);
        _pushFees(_amm, _pairPath, _tokenPath, currentAmountInWithoutGovernance, _referralRecipient, true);
        require(currentAmountInWithoutGovernance <= _maxAmountIn, "AMMRouterV1: Max amount in reached");
        tokenAmountIn = _executeSwap(_amm, _pairPath, _tokenPath, currentAmountInWithoutGovernance, _tokenAmountOut, _to);
    }

    function _executeSwap(
        IAMM _amm,
        uint256[] memory _pairPath,
        uint256[] memory _tokenPath,
        uint256 amountIn,
        uint256 _tokenAmountOut,
        address _to
    ) private returns (uint256 tokenAmountIn) {
        uint256[] memory pairPath = new uint256[](1);
        uint256[] memory tokenPath = new uint256[](2);
        uint256 firstSwapAmountOut;
        if (_pairPath.length == 2) {
            pairPath[0] = _pairPath[1];
            tokenPath[0] = _tokenPath[2];
            tokenPath[1] = _tokenPath[3];
            firstSwapAmountOut = _getAmountInWithoutGovernance(_amm, pairPath, tokenPath, _tokenAmountOut);

            (tokenAmountIn, ) = _amm.swapExactAmountOut(
                _pairPath[0],
                _tokenPath[0],
                amountIn,
                _tokenPath[1],
                firstSwapAmountOut,
                address(this)
            );
        } else {
            tokenPath[0] = _tokenPath[0];
            tokenPath[1] = _tokenPath[1];
            firstSwapAmountOut = amountIn;
        }

        _amm.swapExactAmountOut(
            _pairPath.length == 2 ? _pairPath[1] : _pairPath[0],
            tokenPath[0],
            firstSwapAmountOut,
            tokenPath[1],
            _tokenAmountOut,
            _to  
        );
    }

     
    function getSpotPrice(
        IAMM _amm,
        uint256[] calldata _pairPath,  
        uint256[] calldata _tokenPath  
    ) external view override returns (uint256 spotPrice) {
        uint256 _pairPathMaxIndex = _pairPath.length;
        if (_pairPathMaxIndex == 0) {
            return spotPrice;
        }
        spotPrice = UNIT;
        for (uint256 i; i < _pairPathMaxIndex; i++) {
            uint256 currentSpotPrice = _amm.getSpotPrice(_pairPath[i], _tokenPath[2 * i], _tokenPath[2 * i + 1]);
            spotPrice = spotPrice.mul(currentSpotPrice) / UNIT;
        }
        return spotPrice;
    }

    function _getAmountInWithoutGovernance(
        IAMM _amm,
        uint256[] memory _pairPath,
        uint256[] memory _tokenPath,
        uint256 _tokenAmountOut
    ) internal view returns (uint256 _currentTokenAmountInWithoutGovernance) {
        _currentTokenAmountInWithoutGovernance = _tokenAmountOut;
        uint256 _pairPathMaxIndex = _pairPath.length;
        for (uint256 i = _pairPathMaxIndex; i > 0; i--) {
            (_currentTokenAmountInWithoutGovernance, ) = _amm.calcInAndSpotGivenOut(
                _pairPath[i - 1],
                _tokenPath[2 * i - 2],
                MAX_UINT256,
                _tokenPath[2 * i - 1],
                _currentTokenAmountInWithoutGovernance
            );
        }
    }

    function getAmountIn(
        IAMM _amm,
        uint256[] memory _pairPath,
        uint256[] memory _tokenPath,
        uint256 _tokenAmountOut
    ) public view override returns (uint256 tokenAmountIn) {
        uint256 _currentTokenAmountIn = _getAmountInWithoutGovernance(_amm, _pairPath, _tokenPath, _tokenAmountOut);
        tokenAmountIn = _currentTokenAmountIn.mul(UNIT).div(UNIT - GOVERNANCE_FEE);
    }

    function getAmountOut(
        IAMM _amm,
        uint256[] calldata _pairPath,
        uint256[] calldata _tokenPath,
        uint256 _tokenAmountIn
    ) external view override returns (uint256 tokenAmountOut) {
        uint256 _currentTokenAmountOut = _tokenAmountIn;
        uint256 _pairPathMaxIndex = _pairPath.length;
        for (uint256 i; i < _pairPathMaxIndex; i++) {
            (_currentTokenAmountOut, ) = _amm.calcOutAndSpotGivenIn(
                _pairPath[i],
                _tokenPath[2 * i],
                _currentTokenAmountOut,
                _tokenPath[2 * i + 1],
                0
            );
        }
        tokenAmountOut = _currentTokenAmountOut.mul(UNIT - GOVERNANCE_FEE) / UNIT;
    }

     
    function setRegistry(IAMMRegistry _registry) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "AMMRouterV1: Caller is not an admin");
        registry = _registry;
        emit RegistrySet(_registry);
    }

    function setGovernanceFee(uint256 _fee) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "AMMRouterV1: Caller is not an admin");
        require(_fee < UNIT, "AMMRouterV1: Invalid fee value");
        GOVERNANCE_FEE = _fee;
        emit GovernanceFeeUpdated(_fee);
    }

    function setReferral(address _recipient, uint256 _fee) external {
        require(hasRole(WHITELIST_ROLE, msg.sender), "AMMRouterV1: Caller cannot doesnt have whitelist role");
        require(_fee <= UNIT, "AMMRouterV1: Invalid referral fee");
        if (_fee == 0) {
            delete REFERRAL_FEE[_recipient];
            referralAddresses.remove(_recipient);
            emit ReferralRecipientRemoved(_recipient);
        } else {
            if (referralAddresses.add(_recipient)) emit ReferralRecipientAdded(_recipient);
            REFERRAL_FEE[_recipient] = _fee;
            emit ReferralSet(_recipient, _fee);
        }
    }

    function collectGovernanceFee(IERC20 _token, address _recipient) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "AMMRouterV1: Caller is not an admin");
        uint256 amount = _token.balanceOf(address(this));
        _token.safeTransfer(_recipient, amount);
        emit GovernanceFeeCollected(_token, amount, _recipient);
    }

    function updateFYTApprovalOf(IAMM _amm) external isValidAmm(address(_amm)) {
        IERC20 fyt = IERC20(_amm.getFYTAddress());
        fyt.safeIncreaseAllowance(address(_amm), MAX_UINT256.sub(fyt.allowance(address(this), address(_amm))));
        emit TokenApproved(fyt, _amm);
    }

    function updateAllTokenApprovalOf(IAMM _amm) external isValidAmm(address(_amm)) {
        IERC20 fyt = IERC20(_amm.getFYTAddress());
        IERC20 pt = IERC20(_amm.getPTAddress());
        IERC20 underlying = IERC20(_amm.getUnderlyingOfIBTAddress());
        fyt.safeIncreaseAllowance(address(_amm), MAX_UINT256.sub(fyt.allowance(address(this), address(_amm))));
        pt.safeIncreaseAllowance(address(_amm), MAX_UINT256.sub(pt.allowance(address(this), address(_amm))));
        underlying.safeIncreaseAllowance(address(_amm), MAX_UINT256.sub(underlying.allowance(address(this), address(_amm))));
        emit TokenApproved(fyt, _amm);
        emit TokenApproved(pt, _amm);
        emit TokenApproved(underlying, _amm);
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

 

pragma solidity 0.7.6;


interface IAMM {
     
    struct Pair {
        address tokenAddress;  
        uint256[2] weights;
        uint256[2] balances;
        bool liquidityIsInitialized;
    }

     
    function finalize() external;

     
    function switchPeriod() external;

     
    function togglePauseAmm() external;

     
    function withdrawExpiredToken(address _user, uint256 _lpTokenId) external;

     
    function getExpiredTokensInfo(address _user, uint256 _lpTokenId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function swapExactAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut,
        address _to
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

    function swapExactAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        address _to
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);

     
    function createLiquidity(uint256 _pairID, uint256[2] memory _tokenAmounts) external;

    function addLiquidity(
        uint256 _pairID,
        uint256 _poolAmountOut,
        uint256[2] memory _maxAmountsIn
    ) external;

    function removeLiquidity(
        uint256 _pairID,
        uint256 _poolAmountIn,
        uint256[2] memory _minAmountsOut
    ) external;

    function joinSwapExternAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _minPoolAmountOut
    ) external returns (uint256 poolAmountOut);

    function joinSwapPoolAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _poolAmountOut,
        uint256 _maxAmountIn
    ) external returns (uint256 tokenAmountIn);

    function exitSwapPoolAmountIn(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _poolAmountIn,
        uint256 _minAmountOut
    ) external returns (uint256 tokenAmountOut);

    function exitSwapExternAmountOut(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        uint256 _maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);

    function setSwappingFees(uint256 _swapFee) external;

     
    function calcOutAndSpotGivenIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut
    ) external view returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

    function calcInAndSpotGivenOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut
    ) external view returns (uint256 tokenAmountIn, uint256 spotPriceAfter);

     
    function getSpotPrice(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenOut
    ) external view returns (uint256);

     
    function getFutureAddress() external view returns (address);

     
    function getPTAddress() external view returns (address);

     
    function getUnderlyingOfIBTAddress() external view returns (address);

     
    function getFYTAddress() external view returns (address);

     
    function getPTWeightInPair() external view returns (uint256);

    function getPairWithID(uint256 _pairID) external view returns (Pair memory);

    function getLPTokenId(
        uint256 _ammId,
        uint256 _periodIndex,
        uint256 _pairID
    ) external pure returns (uint256);

    function ammId() external returns (uint64);
}

 

pragma solidity 0.7.6;


 
interface IAMMRegistry {
     
    function initialize(address _admin) external;

     

     
    function setAMMPoolByFuture(address _futureVaultAddress, address _ammPool) external;

     
    function setAMMPool(address _ammPool) external;

     
    function removeAMMPool(address _ammPool) external;

     
     
    function getFutureAMMPool(address _futureVaultAddress) external view returns (address);

    function isRegisteredAMM(address _ammAddress) external view returns (bool);
}

 

pragma solidity 0.7.6;



interface IERC20 is IERC20Upgradeable {
     
    function name() external returns (string memory);

     
    function symbol() external returns (string memory);

     
    function decimals() external view returns (uint8);

     
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

     
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
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
