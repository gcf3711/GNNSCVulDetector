 

 

 
 
pragma solidity ^0.6.0;

 
 
 
 
 
 
 

 
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


 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


 
interface IHolyValor {
     
    function safeReclaimAmount() external view returns(uint256);
     
    function totalReclaimAmount() external view returns(uint256);
     
    function reclaimFunds(uint256 amount, bool _safeExecution) external returns(uint256);
}


 
interface IHolyPool {
    function getBaseAsset() external view returns(address);

     
    function depositOnBehalf(address beneficiary, uint256 amount) external;
    function withdraw(address beneficiary, uint256 amount) external;

     
     
    function borrowToInvest(uint256 amount) external returns(uint256);
     
    function returnInvested(uint256 amountCapitalBody) external;

     
    function harvestYield(uint256 amount) external;  
}


 
interface IYearnVaultUSDCv2 {
     
    function token() external view returns (address);

     
    function pricePerShare() external view returns (uint);

     
    function availableDepositLimit() external view returns (uint);

     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
    function deposit(uint _amount, address _recipient) external returns (uint);

     
     
     
    function withdraw(uint _shares, address _recipient, uint _maxloss) external returns (uint);

     
    function totalAssets() external view returns (uint);
}


 
contract MoverValorYearnUSDCv2Vault is AccessControlUpgradeable, IHolyValor {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant ALLOWANCE_SIZE = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 private constant lpPrecision = 1e3;   

     
    bytes32 public constant FINMGMT_ROLE = keccak256("FINMGMT_ROLE");

     
    address private emergencyTransferToken;
    address private emergencyTransferDestination;
    uint256 private emergencyTransferTimestamp;
    uint256 private emergencyTransferAmount;
    event EmergencyTransferSet(address indexed token, address indexed destination, uint256 amount);
    event EmergencyTransferExecute(address indexed token, address indexed destination, uint256 amount);

     
    IERC20 public baseAsset;          
    IHolyPool public moverPool;       
    address public yieldDistributor;  

    uint256 public amountInvested;    
    uint256 public lpTokensBalance;   

    event FundsInvested(uint256 amountRequested, uint256 amountActual, uint256 lpTokensReceived, uint256 lpTokensBalance);
    event FundsDivested(uint256 lpWithdrawn, uint256 baseAssetExpected, uint256 baseAssetReceived, uint256 lpTokensBalance);
    event HarvestYield(uint256 lpWithdrawn, uint256 baseAssetExpected, uint256 baseAssetReceived, uint256 lpTokensBalance);
    event WithdrawReclaim(uint256 lpWithdrawn, uint256 baseAssetExpected, uint256 baseAssetReceived, uint256 lpTokensBalance);

     
    IYearnVaultUSDCv2 public vaultContract;  
    uint256 public inceptionLPPriceUSDC;   
    uint256 public inceptionTimestamp;     

    function initialize(address _baseAsset, address _vaultAddress, address _poolAddress) public initializer {
	    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FINMGMT_ROLE, _msgSender());

        baseAsset = IERC20(_baseAsset);  
        
        vaultContract = IYearnVaultUSDCv2(_vaultAddress);  
        inceptionLPPriceUSDC = vaultContract.pricePerShare();
        inceptionTimestamp = block.timestamp;

        connectPool(_poolAddress);

        amountInvested = 0;
        lpTokensBalance = 0;
    }

     
    function connectPool(address _poolAddress) internal {
        moverPool = IHolyPool(_poolAddress);
        baseAsset.approve(_poolAddress, ALLOWANCE_SIZE);
    }

     
     
    function setPool(address _poolAddress) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        connectPool(_poolAddress);
    }

     
     
     
    function setYieldDistributor(address _distributorAddress) public {
	    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        yieldDistributor = _distributorAddress;
         
         
        baseAsset.approve(_distributorAddress, ALLOWANCE_SIZE);
    }

     

     
    function investInVault(uint256 _amount, uint256 _minimumAmount) public {
        require(hasRole(FINMGMT_ROLE, msg.sender), "Finmgmt only");
        
         
         
         
        uint256 amountBefore = baseAsset.balanceOf(address(this));
        uint256 amountReceived = moverPool.borrowToInvest(_amount);
        uint256 amountAfter = baseAsset.balanceOf(address(this));
        require(amountReceived == amountAfter.sub(amountBefore), "reported/actual amount mismatch");
        require(amountReceived >= _minimumAmount, "minimum amount not available");

         
        if(baseAsset.allowance(address(this), address(vaultContract)) < amountReceived) {
            baseAsset.approve(address(vaultContract), ALLOWANCE_SIZE);
        }

         
        uint256 lpTokensBefore = IERC20(address(vaultContract)).balanceOf(address(this));
        vaultContract.deposit(amountReceived, address(this));
        uint256 lpTokensAfter = IERC20(address(vaultContract)).balanceOf(address(this));
        uint256 lpReceived = lpTokensAfter.sub(lpTokensBefore);
        require(lpReceived > 0, "lp tokens not received");

         
        lpTokensBalance = lpTokensBalance.add(lpReceived);
        amountInvested = amountInvested.add(amountReceived);

        emit FundsInvested(_amount, amountReceived, lpReceived, lpTokensBalance);
    }

     
     
     
     
     
     
     
     
     
    function divestFromVault(uint256 _amount, bool _safeExecution) public {
        require(hasRole(FINMGMT_ROLE, msg.sender), "Finmgmt only");

        uint256 safeWithdrawAmountUSDC = IERC20(vaultContract.token()).balanceOf(address(vaultContract));
        if (_safeExecution && _amount > safeWithdrawAmountUSDC) {
            revert("insufficient safe withdraw balance");
        }

         
        uint256 lpPriceUSDC = vaultContract.pricePerShare();

         
        uint256 lpTokensToWithdraw = _amount.mul(1e18).div(lpPriceUSDC);
        
        if (lpTokensToWithdraw > IERC20(address(vaultContract)).balanceOf(address(this))) {
            revert("insufficient lp tokens");
        }

         
        if (IERC20(address(vaultContract)).allowance(address(this), address(vaultContract)) < lpTokensToWithdraw) {
            IERC20(address(vaultContract)).approve(address(vaultContract), ALLOWANCE_SIZE);
        }

        uint256 baseAssetTokensBefore = baseAsset.balanceOf(address(this));
        vaultContract.withdraw(lpTokensToWithdraw, address(this), 50);  
        uint256 baseAssetTokensAfter = baseAsset.balanceOf(address(this));
        uint256 USDCReceived = baseAssetTokensAfter.sub(baseAssetTokensBefore);
         
        lpTokensBalance = lpTokensBalance.sub(lpTokensToWithdraw);

         
         
         
         
         

         
        moverPool.returnInvested(USDCReceived);

         
        amountInvested = amountInvested.sub(_amount);

        emit FundsDivested(lpTokensToWithdraw, _amount, USDCReceived, lpTokensBalance);
    }

     
     
     
     
     
     
    function reclaimFunds(uint256 _amount, bool _safeExecution) external override returns(uint256) {
        require(msg.sender == address(moverPool), "Pool only");

        uint256 safeWithdrawAmountUSDC = IERC20(vaultContract.token()).balanceOf(address(vaultContract));
        if (_safeExecution && _amount > safeWithdrawAmountUSDC) {
            revert("insufficient safe withdraw balance");
        }

         
        uint256 lpPriceUSDC = vaultContract.pricePerShare();

         
        uint256 lpTokensToWithdraw = _amount.mul(1e18).div(lpPriceUSDC);
        
         
        if (IERC20(address(vaultContract)).allowance(address(this), address(vaultContract)) < lpTokensToWithdraw) {
            IERC20(address(vaultContract)).approve(address(vaultContract), ALLOWANCE_SIZE);
        }

        uint256 baseAssetTokensBefore = baseAsset.balanceOf(address(this));
        vaultContract.withdraw(lpTokensToWithdraw, address(this), 50);
        uint256 baseAssetTokensAfter = baseAsset.balanceOf(address(this));
        uint256 USDCReceived = baseAssetTokensAfter.sub(baseAssetTokensBefore);
         
        lpTokensBalance = lpTokensBalance.sub(lpTokensToWithdraw);

         
         
         
         
         
         

         
        baseAsset.transfer(address(moverPool), USDCReceived);

         
        amountInvested = amountInvested.sub(_amount);

        emit WithdrawReclaim(lpTokensToWithdraw, _amount, USDCReceived, lpTokensBalance);

        return USDCReceived;
    }

     
     
     
     
     
     
     
     
     
    function harvestYield(uint256 minExpectedAmount, uint256 maxAmount) public {
        require(hasRole(FINMGMT_ROLE, msg.sender), "Finmgmt only");

         
        uint256 lpPriceUSDC = vaultContract.pricePerShare();

         
         
        uint256 accruedYieldUSDC = lpTokensBalance.mul(lpPriceUSDC).div(1e18).sub(amountInvested);
        require(accruedYieldUSDC >= minExpectedAmount, "yield to harvest less than min");
        
         
        if (accruedYieldUSDC > maxAmount) {
            accruedYieldUSDC = maxAmount;
        }

         
        uint256 lpTokensToWithdraw = accruedYieldUSDC.mul(1e18).div(lpPriceUSDC);

         
        if (IERC20(address(vaultContract)).allowance(address(this), address(vaultContract)) < lpTokensToWithdraw) {
            IERC20(address(vaultContract)).approve(address(vaultContract), ALLOWANCE_SIZE);
        }

        uint256 baseAssetTokensBefore = baseAsset.balanceOf(address(this));
        vaultContract.withdraw(lpTokensToWithdraw, address(this), 0);
        uint256 baseAssetTokensAfter = baseAsset.balanceOf(address(this));
        uint256 USDCReceived = baseAssetTokensAfter.sub(baseAssetTokensBefore);
         
        lpTokensBalance = lpTokensBalance.sub(lpTokensToWithdraw);

         

        emit HarvestYield(lpTokensToWithdraw, accruedYieldUSDC, USDCReceived, lpTokensBalance);
         
         
    }

     
    function safeReclaimAmount() external override view returns(uint256) {
         
         
         
        uint256 safeAmount = IERC20(vaultContract.token()).balanceOf(address(vaultContract));
        if (safeAmount >= lpPrecision) {
            return safeAmount.sub(lpPrecision);
        }
        return 0;  
    }

    function totalReclaimAmount() external override view returns(uint256) {
        return amountInvested;
    }

     
     
    function getAssetsUnderManagement() public view returns(uint256) {
         
        uint256 lpPriceUSDC = vaultContract.pricePerShare();

        return lpTokensBalance.mul(lpPriceUSDC).div(1e18);
    }

     
    function getAPYInception() public view returns(uint256) {
         
        uint256 lpPriceUSDC = vaultContract.pricePerShare();

        return lpPriceUSDC.mul(1e18).div(inceptionLPPriceUSDC);
    }

     
     
     
     
	function emergencyTransferTimelockSet(address _token, address _destination, uint256 _amount) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        emergencyTransferTimestamp = block.timestamp;
        emergencyTransferToken = _token;
        emergencyTransferDestination = _destination;
        emergencyTransferAmount = _amount;

        emit EmergencyTransferSet(_token, _destination, _amount);
	}

	function emergencyTransferExecute() public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin only");
        require(block.timestamp > emergencyTransferTimestamp + 24 * 3600, "timelock too early");
        require(block.timestamp < emergencyTransferTimestamp + 72 * 3600, "timelock too late");

        IERC20(emergencyTransferToken).safeTransfer(emergencyTransferDestination, emergencyTransferAmount);

        emit EmergencyTransferExecute(emergencyTransferToken, emergencyTransferDestination, emergencyTransferAmount);
         
        emergencyTransferTimestamp = 0;
        emergencyTransferToken = address(0);
        emergencyTransferDestination = address(0);
        emergencyTransferAmount = 0;
    }
}