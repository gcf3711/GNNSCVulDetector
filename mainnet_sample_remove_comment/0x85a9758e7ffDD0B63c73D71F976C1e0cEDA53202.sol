 


 

pragma solidity 0.7.6;

interface ISubscriber {
    function registry() external view returns (address);

    function governance() external view returns (address);

    function manager() external view returns (address);
}

 

pragma solidity 0.7.6;

interface IManager {
    function token() external view returns (address);

    function buybackFee() external view returns (uint256);

    function managementFee() external view returns (uint256);

    function liquidators(address from, address to) external view returns (address);

    function whitelisted(address _contract) external view returns (bool);

    function banks(uint256 i) external view returns (address);

    function totalBanks() external view returns (uint256);

    function strategies(address bank, uint256 i) external view returns (address);

    function totalStrategies(address bank) external view returns (uint256);

    function withdrawIndex(address bank) external view returns (uint256);

    function setWithdrawIndex(uint256 i) external;

    function rebalance(address bank) external;

    function finance(address bank) external;

    function financeAll(address bank) external;

    function buyback(address from) external;

    function accrueRevenue(
        address bank,
        address underlying,
        uint256 amount
    ) external;

    function exitAll(address bank) external;
}

 

pragma solidity 0.7.6;

interface IBankStorage {
    function paused() external view returns (bool);

    function underlying() external view returns (address);
}

 

pragma solidity 0.7.6;







abstract contract OhSubscriber is ISubscriber {
    address internal _registry;

    
    modifier onlyAuthorized {
        require(msg.sender == governance() || msg.sender == manager(), "Subscriber: Only Authorized");
        _;
    }

    
    modifier onlyGovernance {
        require(msg.sender == governance(), "Subscriber: Only Governance");
        _;
    }

    
    
    constructor(address registry_) {
        require(Address.isContract(registry_), "Subscriber: Invalid Registry");
        _registry = registry_;
    }

    
    
    function governance() public view override returns (address) {
        return IRegistry(registry()).governance();
    }

    
    
    function manager() public view override returns (address) {
        return IRegistry(registry()).manager();
    }

    
    
    function registry() public view override returns (address) {
        return _registry;
    }

    
    
    
    
    function setRegistry(address registry_) external onlyGovernance {
        require(Address.isContract(registry_), "Subscriber: Invalid Registry");

        _registry = registry_;
        require(msg.sender == governance(), "Subscriber: Bad Governance");
    }
} 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeMath {
     
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

 

pragma solidity >=0.6.0 <0.8.0;





 
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

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
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

interface ILiquidator {
    function liquidate(
        address recipient,
        address from,
        address to,
        uint256 amount,
        uint256 minOut
    ) external returns (uint256);

    function getSwapInfo(address from, address to) external view returns (address router, address[] memory path);

    function sushiswapRouter() external view returns (address);

    function uniswapRouter() external view returns (address);

    function weth() external view returns (address);
}

 

pragma solidity 0.7.6;

interface IRegistry {
    function governance() external view returns (address);

    function manager() external view returns (address);
}

 

pragma solidity 0.7.6;

interface IToken {
    function delegate(address delegatee) external;

    function delegateBySig(
        address delegator,
        address delegatee,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function burn(uint256 amount) external;

    function mint(address recipient, uint256 amount) external;

    function getCurrentVotes(address account) external view returns (uint256);

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);
}

 

pragma solidity 0.7.6;



interface IBank is IBankStorage {
    function strategies(uint256 i) external view returns (address);

    function totalStrategies() external view returns (uint256);

    function underlyingBalance() external view returns (uint256);

    function strategyBalance(uint256 i) external view returns (uint256);

    function investedBalance() external view returns (uint256);

    function virtualBalance() external view returns (uint256);

    function virtualPrice() external view returns (uint256);

    function pause() external;

    function unpause() external;

    function invest(address strategy, uint256 amount) external;

    function investAll(address strategy) external;

    function exit(address strategy, uint256 amount) external;

    function exitAll(address strategy) external;

    function deposit(uint256 amount) external;

    function depositFor(uint256 amount, address recipient) external;

    function withdraw(uint256 amount) external;
}

 

pragma solidity 0.7.6;




library TransferHelper {
    using SafeERC20 for IERC20;

     
    function safeTokenTransfer(
        address recipient,
        address token,
        uint256 amount
    ) internal returns (uint256) {
        if (amount == 0) {
            return 0;
        }

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance < amount) {
            IERC20(token).safeTransfer(recipient, balance);
            return balance;
        } else {
            IERC20(token).safeTransfer(recipient, amount);
            return amount;
        }
    }
}

 

pragma solidity 0.7.6;
















contract OhManager is OhSubscriber, IManager {
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    
    uint256 public constant FEE_DENOMINATOR = 1000;

    
    uint256 public constant MAX_BUYBACK_FEE = 500;

    
    uint256 public constant MIN_BUYBACK_FEE = 100;

    
    uint256 public constant MAX_MANAGEMENT_FEE = 100;

    
    uint256 public constant MIN_MANAGEMENT_FEE = 0;

    
    address public override token;

    
    uint256 public override buybackFee;

    
    uint256 public override managementFee;

    
    mapping(address => mapping(address => address)) public override liquidators;

    
    mapping(address => bool) public override whitelisted;

    
    EnumerableSet.AddressSet internal _banks;

    
    mapping(address => EnumerableSet.AddressSet) internal _strategies;

    
    mapping(address => uint8) internal _depositQueue;

    
    mapping(address => uint8) internal _withdrawQueue;

    
    event Rebalance(address indexed bank);

    
    event Finance(address indexed bank, address indexed strategy);

    
    event FinanceAll(address indexed bank);

    
    event Buyback(address indexed from, uint256 amount, uint256 buybackAmount);

    
    event AccrueRevenue(
        address indexed bank,
        address indexed strategy,
        uint256 profitAmount,
        uint256 buybackAmount,
        uint256 managementAmount
    );

    
    
    modifier onlyBank(address sender) {
        require(_banks.contains(sender), "Manager: Only Bank");
        _;
    }
    
    
    
    
    modifier onlyStrategy(address bank, address sender) {
        require(_strategies[bank].contains(sender), "Manager: Only Strategy");
        _;
    }

    
    
    modifier defense {
        require(msg.sender == tx.origin || whitelisted[msg.sender], "Manager: Only EOA or Whitelist");
        _;
    }

    
    
    
    
    constructor(address registry_, address token_) OhSubscriber(registry_) {
        token = token_;
        buybackFee = 200;  
        managementFee = 20;  
    }

    
    function banks(uint256 i) external view override returns (address) {
        return _banks.at(i);
    }

    function totalBanks() external view override returns (uint256) {
        return _banks.length();
    }

    
    
    
    function strategies(address bank, uint256 i) external view override returns (address) {
        return _strategies[bank].at(i);
    }

    
    
    
    function totalStrategies(address bank) external view override returns (uint256) {
        return _strategies[bank].length();
    }

    
    
    
    function withdrawIndex(address bank) external view override returns (uint256) {
        return _withdrawQueue[bank];
    }

    
    
    function setWithdrawIndex(uint256 i) external override onlyBank(msg.sender) {
        _withdrawQueue[msg.sender] = uint8(i);
    }

    
    
    function rebalance(address bank) external override defense onlyBank(bank) {
         
        uint256 length = _strategies[bank].length();
        for (uint256 i; i < length; i++) {
            IBank(bank).exitAll(_strategies[bank].at(i));
        }

         
        uint256 toInvest = IBank(bank).underlyingBalance();
        for (uint256 i; i < length; i++) {
            uint256 amount = toInvest / length;
            IBank(bank).invest(_strategies[bank].at(i), amount);
        }

        emit Rebalance(bank);
    }

    
    
    
    function finance(address bank) external override defense onlyBank(bank) {
        uint256 length = _strategies[bank].length();
        require(length > 0, "Manager: No Strategies");

         
        uint8 i;
        uint8 queued = _depositQueue[bank];
        if (queued < length) {
            i = queued;
        } else {
            i = 0;
        }
        address strategy = _strategies[bank].at(i);

         
        IBank(bank).investAll(strategy);
        _depositQueue[bank] = i + 1;

        emit Finance(bank, strategy);
    }

    
    
    
    
    function financeAll(address bank) external override defense onlyBank(bank) {
        uint256 length = _strategies[bank].length();
        require(length > 0, "Manager: No Strategies");

        uint256 toInvest = IBank(bank).underlyingBalance();
        for (uint256 i; i < length; i++) {
            uint256 amount = toInvest / length;
            IBank(bank).invest(_strategies[bank].at(i), amount);
        }

        emit FinanceAll(bank);
    }

    
    
    
    function buyback(address from) external override defense {
         
        address _token = token;
        address liquidator = liquidators[from][_token];
        uint256 amount = IERC20(from).balanceOf(address(this));

         
        TransferHelper.safeTokenTransfer(liquidator, from, amount);
        uint256 received = ILiquidator(liquidator).liquidate(address(this), from, _token, amount, 1);
        IToken(_token).burn(received);

        emit Buyback(from, amount, received);
    }

    
    
    
    
    function accrueRevenue(
        address bank,
        address underlying,
        uint256 amount
    ) external override onlyStrategy(bank, msg.sender) {
         
        uint256 fee = amount.mul(buybackFee).div(FEE_DENOMINATOR);
        uint256 reward = amount.mul(managementFee).div(FEE_DENOMINATOR);
        uint256 remaining = amount.sub(fee).sub(reward);

         
        TransferHelper.safeTokenTransfer(tx.origin, underlying, reward);
        TransferHelper.safeTokenTransfer(msg.sender, underlying, remaining);

        emit AccrueRevenue(bank, msg.sender, remaining, fee, reward);
    }

    
    
    
    function exit(address bank, address strategy) public onlyGovernance {
        IBank(bank).exitAll(strategy);
    }

    
    
    function exitAll(address bank) public override onlyGovernance {
        uint256 length = _strategies[bank].length();
        for (uint256 i = 0; i < length; i++) {
            IBank(bank).exitAll(_strategies[bank].at(i));
        }
    }

    
    
    
    
    function setBank(address _bank, bool _approved) external onlyGovernance {
        require(_bank.isContract(), "Manager: Not Contract");
        bool approved = _banks.contains(_bank);
        require(approved != _approved, "Manager: No Change");

         
        if (approved) {
            exitAll(_bank);
            _banks.remove(_bank);
        } else {
            _banks.add(_bank);
        }
    }

    
    
    
    
    
    function setStrategy(address _bank, address _strategy, bool _approved) external onlyGovernance {
        require(_strategy.isContract() && _bank.isContract(), "Manager: Not Contract");
        bool approved = _strategies[_bank].contains(_strategy);
        require(approved != _approved, "Manager: No Change");

         
        if (approved) {
            exit(_bank, _strategy);
            _strategies[_bank].remove(_strategy);
        } else {
            _strategies[_bank].add(_strategy);
        }
    }

    
    
    
    
    
    function setLiquidator(
        address _liquidator,
        address _from,
        address _to
    ) external onlyGovernance {
        require(_liquidator.isContract(), "Manager: Not Contract");
        liquidators[_from][_to] = _liquidator;
    }

    
    
    
    
    function setWhitelisted(address _contract, bool _whitelisted) external onlyGovernance {
        require(_contract.isContract(), "Registry: Not Contract");
        whitelisted[_contract] = _whitelisted;
    }

    
    
    
    function setBuybackFee(uint256 _buybackFee) external onlyGovernance {
        require(_buybackFee > MIN_BUYBACK_FEE, "Registry: Invalid Buyback");
        require(_buybackFee < MAX_BUYBACK_FEE, "Registry: Buyback Too High");
        buybackFee = _buybackFee;
    }

    
    
    
    function setManagementFee(uint256 _managementFee) external onlyGovernance {
        require(_managementFee > MIN_MANAGEMENT_FEE, "Registry: Invalid Mgmt");
        require(_managementFee < MAX_MANAGEMENT_FEE, "Registry: Mgmt Too High");
        managementFee = _managementFee;
    }
}
