
 

 

pragma solidity ^0.5.16;


contract RewardPoolDelegationStorage {
     
    address public filstAddress;

     
    address public efilAddress;

     
    address public admin;

     
    address public pendingAdmin;

     
    address public implementation;

     
    address public pendingImplementation;
}

interface IRewardCalculator {
    function calculate(uint filstAmount, uint fromBlockNumber) external view returns (uint);
}

interface IRewardStrategy {
     
    function allocate(address staking, uint rewardAmount) external view returns (uint stakingPart, address[] memory others, uint[] memory othersParts);
}

interface IFilstManagement {
    function getTotalMintedAmount() external view returns (uint);
    function getMintedAmount(string calldata miner) external view returns (uint);
}

contract RewardPoolStorage is RewardPoolDelegationStorage {
     
    IFilstManagement public management;

     
    IRewardStrategy public strategy;

     
    IRewardCalculator public calculator;

     
    address public staking;

     
    uint public accrualBlockNumber;

     
    mapping(address => uint) public accruedRewards;

    struct Debt {
         
        uint accruedIndex;

         
        uint accruedAmount;

         
        uint lastRepaymentBlock;
    }

     
    uint public debtAccruedIndex;

     
     
    mapping(string => Debt) public minerDebts;
}

contract RewardPoolDelegator is RewardPoolDelegationStorage {
     
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

     
    event NewImplementation(address oldImplementation, address newImplementation);

     
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

     
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor(address filstAddress_, address efilAddress_) public {
        filstAddress = filstAddress_;
        efilAddress = efilAddress_;

         
        admin = msg.sender;
    }

     
    function _setPendingImplementation(address newPendingImplementation) external {
        require(msg.sender == admin, "admin check");

        address oldPendingImplementation = pendingImplementation;
        pendingImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingImplementation);
    }

     
    function _acceptImplementation() external {
         
        require(msg.sender == pendingImplementation && pendingImplementation != address(0), "pendingImplementation check");

         
        address oldImplementation = implementation;
        address oldPendingImplementation = pendingImplementation;

        implementation = pendingImplementation;
        pendingImplementation = address(0);

        emit NewImplementation(oldImplementation, implementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingImplementation);
    }

     
    function _setPendingAdmin(address newPendingAdmin) external {
        require(msg.sender == admin, "admin check");

         
        address oldPendingAdmin = pendingAdmin;
         
        pendingAdmin = newPendingAdmin;

         
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

     
    function _acceptAdmin() external {
         
        require(msg.sender == pendingAdmin && pendingAdmin != address(0), "pendingAdmin check");

         
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

         
        admin = pendingAdmin;
         
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }


     
    function () payable external {
         
        (bool success, ) = implementation.delegatecall(msg.data);

         
        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize)

              switch success
              case 0 { revert(free_mem_ptr, returndatasize) }
              default { return(free_mem_ptr, returndatasize) }
        }
    }
}

 
 
contract ExponentialNoError {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

     
    function truncate(Exp memory exp) pure internal returns (uint) {
         
        return exp.mantissa / expScale;
    }

     
    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

     
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

     
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

     
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

     
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

     
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

interface Distributor {
     
    function asset() external view returns (address);

     
    function accruedStored(address account) external view returns (uint);

     
     
    function accrue() external returns (uint);

     
    function claim(address receiver, uint amount) external returns (uint);
}

 
 
interface EIP20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function transfer(address dst, uint256 amount) external returns (bool success);

     
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);

     
    function approve(address spender, uint256 amount) external returns (bool success);

     
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

 
 
interface EIP20NonStandardInterface {

     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
     
     
     
     

     
    function transfer(address dst, uint256 amount) external;

     
     
     
     
     

     
    function transferFrom(address src, address dst, uint256 amount) external;

     
    function approve(address spender, uint256 amount) external returns (bool success);

     
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

contract Redistributor is Distributor, ExponentialNoError {
     
    Distributor public superior;

     
    uint public superiorAccruedAmount;

     
    uint internal constant initialAccruedIndex = 1e36;

     
    uint public accrualBlockNumber;

     
    uint public globalAccruedIndex;

     
    uint internal totalShares;

    struct AccountState {
        
        uint share;
         
        uint accruedIndex;
        
        uint accruedAmount;
    }

     
    mapping(address => AccountState) internal accountStates;

     
     
    event Accrued(uint amount, uint globalAccruedIndex);

     
    event Distributed(address account, uint amount, uint accruedIndex);

     
    event Claimed(address account, address receiver, uint amount);

     
    event Transferred(address from, address to, uint amount);

    constructor(Distributor superior_) public {
         
        superior = superior_;
         
        globalAccruedIndex = initialAccruedIndex;
    }

    function asset() external view returns (address) {
        return superior.asset();
    }

     
    function accruedStored(address account) external view returns(uint) {
        uint storedGlobalAccruedIndex;
        if (totalShares == 0) {
            storedGlobalAccruedIndex = globalAccruedIndex;
        } else {
            uint superiorAccruedStored = superior.accruedStored(address(this));
            uint delta = sub_(superiorAccruedStored, superiorAccruedAmount);

            Double memory ratio = fraction(delta, totalShares);
            Double memory doubleGlobalAccruedIndex = add_(Double({mantissa: globalAccruedIndex}), ratio);
            storedGlobalAccruedIndex = doubleGlobalAccruedIndex.mantissa;
        }

        (, uint instantAccountAccruedAmount) = accruedStoredInternal(account, storedGlobalAccruedIndex);
        return instantAccountAccruedAmount;
    }

     
    function accruedStoredInternal(address account, uint withGlobalAccruedIndex) internal view returns(uint, uint) {
        AccountState memory state = accountStates[account];

        Double memory doubleGlobalAccruedIndex = Double({mantissa: withGlobalAccruedIndex});
        Double memory doubleAccountAccruedIndex = Double({mantissa: state.accruedIndex});
        if (doubleAccountAccruedIndex.mantissa == 0 && doubleGlobalAccruedIndex.mantissa > 0) {
            doubleAccountAccruedIndex.mantissa = initialAccruedIndex;
        }

        Double memory deltaIndex = sub_(doubleGlobalAccruedIndex, doubleAccountAccruedIndex);
        uint delta = mul_(state.share, deltaIndex);

        return (delta, add_(state.accruedAmount, delta));
    }

    function accrueInternal() internal {
        uint blockNumber = getBlockNumber();
        if (accrualBlockNumber == blockNumber) {
            return;
        }

        uint newSuperiorAccruedAmount = superior.accrue();
        if (totalShares == 0) {
            accrualBlockNumber = blockNumber;
            return;
        }

        uint delta = sub_(newSuperiorAccruedAmount, superiorAccruedAmount);

        Double memory ratio = fraction(delta, totalShares);
        Double memory doubleAccruedIndex = add_(Double({mantissa: globalAccruedIndex}), ratio);

         
        globalAccruedIndex = doubleAccruedIndex.mantissa;
        superiorAccruedAmount = newSuperiorAccruedAmount;
        accrualBlockNumber = blockNumber;

        emit Accrued(delta, doubleAccruedIndex.mantissa);
    }

     
    function accrue() external returns (uint) {
        accrueInternal();

        (, uint instantAccountAccruedAmount) = accruedStoredInternal(msg.sender, globalAccruedIndex);
        return instantAccountAccruedAmount;
    }

    function distributeInternal(address account) internal {
        (uint delta, uint instantAccruedAmount) = accruedStoredInternal(account, globalAccruedIndex);

        AccountState storage state = accountStates[account];
        state.accruedIndex = globalAccruedIndex;
        state.accruedAmount = instantAccruedAmount;

         
        emit Distributed(account, delta, globalAccruedIndex);
    }

    function claim(address receiver, uint amount) external returns (uint) {
        address account = msg.sender;

         
        accrueInternal();
        distributeInternal(account);

        AccountState storage state = accountStates[account];
        require(amount <= state.accruedAmount, "claim: insufficient value");

         
        require(superior.claim(receiver, amount) == amount, "claim: amount mismatch");

         
        state.accruedAmount = sub_(state.accruedAmount, amount);
        superiorAccruedAmount = sub_(superiorAccruedAmount, amount);

        emit Claimed(account, receiver, amount);

        return amount;
    }

    function claimAll() external {
        address account = msg.sender;

         
        accrueInternal();
        distributeInternal(account);

        AccountState storage state = accountStates[account];
        uint amount = state.accruedAmount;

         
        require(superior.claim(account, amount) == amount, "claim: amount mismatch");

         
        state.accruedAmount = 0;
        superiorAccruedAmount = sub_(superiorAccruedAmount, amount);

        emit Claimed(account, account, amount);
    }

    function transfer(address to, uint amount) external {
        address from = msg.sender;

         
        accrueInternal();
        distributeInternal(from);

        AccountState storage fromState = accountStates[from];
        uint actualAmount = amount;
        if (actualAmount == 0) {
            actualAmount = fromState.accruedAmount;
        }
        require(fromState.accruedAmount >= actualAmount, "transfer: insufficient value");

        AccountState storage toState = accountStates[to];

         
        fromState.accruedAmount = sub_(fromState.accruedAmount, actualAmount);
        toState.accruedAmount = add_(toState.accruedAmount, actualAmount);

        emit Transferred(from, to, actualAmount);
    }

    function getBlockNumber() public view returns (uint) {
        return block.number;
    }
}

contract Staking is Redistributor {
     
    address public property;

     
     
    event Deposit(address account, uint amount);

     
    event Withdraw(address account, uint amount);

    constructor(address property_, Distributor superior_) Redistributor(superior_) public {
        property = property_;
    }

    function totalDeposits() external view returns (uint) {
        return totalShares;
    }

    function accountState(address account) external view returns (uint, uint, uint) {
        AccountState memory state = accountStates[account];
        return (state.share, state.accruedIndex, state.accruedAmount);
    }

     
    function deposit(uint amount) external returns (uint) {
        address account = msg.sender;

         
        accrueInternal();
        distributeInternal(account);

         
        uint actualAmount = doTransferIn(account, amount);

         
        AccountState storage state = accountStates[account];
        totalShares = add_(totalShares, actualAmount);
        state.share = add_(state.share, actualAmount);

        emit Deposit(account, actualAmount);

        return actualAmount;
    }

     
    function withdraw(uint amount) external returns (uint) {
        address account = msg.sender;
        AccountState storage state = accountStates[account];
        require(state.share >= amount, "withdraw: insufficient value");

         
        accrueInternal();
        distributeInternal(account);

         
        totalShares = sub_(totalShares, amount);
        state.share = sub_(state.share, amount);

         
        doTransferOut(account, amount);

        emit Withdraw(account, amount);

        return amount;
    }

     

     
    function doTransferIn(address from, uint amount) internal returns (uint) {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(property);
        uint balanceBefore = EIP20Interface(property).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                        
                    success := not(0)           
                }
                case 32 {                       
                    returndatacopy(0, 0, 32)
                    success := mload(0)         
                }
                default {                       
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");

         
        uint balanceAfter = EIP20Interface(property).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore;    
    }

     
    function doTransferOut(address to, uint amount) internal {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(property);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       
                    success := not(0)           
                }
                case 32 {                      
                    returndatacopy(0, 0, 32)
                    success := mload(0)         
                }
                default {                      
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }
}

contract RewardPool is RewardPoolStorage, Distributor, ExponentialNoError {
     
    uint internal constant initialAccruedIndex = 1e36;

     

     
    event Accrued(uint stakingPart, address[] others, uint[] othersParts, uint debtAccruedIndex);

     
    event Claimed(address account, address receiver, uint amount);

     
    event DistributedDebt(string miner, uint debtDelta, uint accruedIndex);

     
    event Repayment(string miner, address repayer, uint amount);

     
    event Transferred(address from, address to, uint amount);

     
    event StrategyChanged(IRewardStrategy oldStrategy, IRewardStrategy newStrategy);

     
    event CalculatorChanged(IRewardCalculator oldCalculator, IRewardCalculator newCalculator);

     
    event StakingChanged(address oldStaking, address newStaking);

     
    event ManagementChanged(IFilstManagement oldManagement, IFilstManagement newManagement);

     
    event LiqudityAdded(address benefactor, address admin, uint addAmount);

    constructor() public { }
    
    function getEfilAddress() internal view returns (address) {
        return 0x2a2cB9bA73289D4D068BD57D3c26165DaD5Cb628;
    }

    function asset() external view returns (address) {
        address efilAddr = getEfilAddress();
        return efilAddr;
    }

     
    function accruedStored(address account) external view returns (uint) {
        if (accrualBlockNumber == getBlockNumber() || Staking(staking).totalDeposits() == 0) {
            return accruedRewards[account];
        }

        uint totalFilst = management.getTotalMintedAmount();
         
        uint deltaRewards = calculator.calculate(totalFilst, accrualBlockNumber);

         
        (uint stakingPart, address[] memory others, uint[] memory othersParts) = strategy.allocate(staking, deltaRewards);
        require(others.length == othersParts.length, "IRewardStrategy.allocalte: others length mismatch");

        if (staking == account) {
            return add_(accruedRewards[staking], stakingPart);
        } else {
             
            uint sumAllocation = stakingPart;
            uint accountAccruedReward = accruedRewards[account];

            for (uint i = 0; i < others.length; i ++) {
                sumAllocation = add_(sumAllocation, othersParts[i]);
                if (others[i] == account) {
                    accountAccruedReward = add_(accountAccruedReward, othersParts[i]);
                }
            }
            require(sumAllocation == deltaRewards, "sumAllocation mismatch");

            return accountAccruedReward;
        }
    }

     
     
    function accrue() public returns (uint) {
        uint blockNumber = getBlockNumber();
        if (accrualBlockNumber == blockNumber) {
            return accruedRewards[msg.sender];
        }

        if (Staking(staking).totalDeposits() == 0) {
            accrualBlockNumber = blockNumber;
            return accruedRewards[msg.sender];
        }

         
        uint totalFilst = management.getTotalMintedAmount();
         
        uint deltaRewards = calculator.calculate(totalFilst, accrualBlockNumber);
         
        (uint stakingPart, address[] memory others, uint[] memory othersParts) = strategy.allocate(staking, deltaRewards);
        require(others.length == othersParts.length, "IRewardStrategy.allocalte: others length mismatch");

         
        accruedRewards[staking] = add_(accruedRewards[staking], stakingPart);

         
        uint sumAllocation = stakingPart;
        for (uint i = 0; i < others.length; i ++) {
            sumAllocation = add_(sumAllocation, othersParts[i]);
            accruedRewards[others[i]] = add_(accruedRewards[others[i]], othersParts[i]);
        }
        require(sumAllocation == deltaRewards, "sumAllocation mismatch");

         
        accureDebtInternal(deltaRewards);

         
        accrualBlockNumber = blockNumber;

         
        emit Accrued(stakingPart, others, othersParts, debtAccruedIndex);

        return accruedRewards[msg.sender];
    }

    function accureDebtInternal(uint deltaDebts) internal {
         

        uint totalFilst = management.getTotalMintedAmount();
        Double memory ratio = fraction(deltaDebts, totalFilst);
        Double memory doubleAccruedIndex = add_(Double({mantissa: debtAccruedIndex}), ratio);

         
        debtAccruedIndex = doubleAccruedIndex.mantissa;
    }


     
    function accruedDebtStored(string calldata miner) external view returns(uint) {
        uint storedGlobalAccruedIndex;
        if (accrualBlockNumber == getBlockNumber() || Staking(staking).totalDeposits() == 0) {
            storedGlobalAccruedIndex = debtAccruedIndex;
        } else {
            uint totalFilst = management.getTotalMintedAmount();
            uint deltaDebts = calculator.calculate(totalFilst, accrualBlockNumber);
            
            Double memory ratio = fraction(deltaDebts, totalFilst);
            Double memory doubleAccruedIndex = add_(Double({mantissa: debtAccruedIndex}), ratio);
            storedGlobalAccruedIndex = doubleAccruedIndex.mantissa;
        }

        (, uint instantAccruedAmount) = accruedDebtStoredInternal(miner, storedGlobalAccruedIndex);
        return instantAccruedAmount;
    }

     
    function accruedDebtStoredInternal(string memory miner, uint withDebtAccruedIndex) internal view returns(uint, uint) {
        Debt memory debt = minerDebts[miner];

        Double memory doubleDebtAccruedIndex = Double({mantissa: withDebtAccruedIndex});
        Double memory doubleMinerAccruedIndex = Double({mantissa: debt.accruedIndex});
        if (doubleMinerAccruedIndex.mantissa == 0 && doubleDebtAccruedIndex.mantissa > 0) {
            doubleMinerAccruedIndex.mantissa = initialAccruedIndex;
        }

        uint minerMintedAmount = management.getMintedAmount(miner);

        Double memory deltaIndex = sub_(doubleDebtAccruedIndex, doubleMinerAccruedIndex);
        uint delta = mul_(minerMintedAmount, deltaIndex);

        return (delta, add_(debt.accruedAmount, delta));
    }

     
    function accrue(string memory miner) public {
        accrue();
        distributeDebtInternal(miner);
    }

    function distributeDebtInternal(string memory miner) internal {
        (uint delta, uint instantAccruedAmount) = accruedDebtStoredInternal(miner, debtAccruedIndex);

        Debt storage debt = minerDebts[miner];
        debt.accruedIndex = debtAccruedIndex;
        debt.accruedAmount = instantAccruedAmount;

         
        emit DistributedDebt(miner, delta, debtAccruedIndex);
    }

     
    function claim(address receiver, uint amount) external returns (uint) {
        address account = msg.sender;

         
        accrue();

        uint accruedReward = accruedRewards[account];
        require(accruedReward >= amount, "Insufficient value");

         
        transferRewardOut(receiver, amount);

         
        accruedRewards[account] = sub_(accruedReward, amount);

        emit Claimed(account, receiver, amount);

        return amount;
    }

     
    function claimAll() external returns (uint) {
        address account = msg.sender;

         
        accrue();

        uint accruedReward = accruedRewards[account];

         
        transferRewardOut(account, accruedReward);

         
        accruedRewards[account] = 0;

        emit Claimed(account, account, accruedReward);
    }

    function transferRewardOut(address account, uint amount) internal {
        address efilAddr = getEfilAddress();
        EIP20Interface efil = EIP20Interface(efilAddr);
        uint remaining = efil.balanceOf(address(this));
        require(remaining >= amount, "Insufficient cash");

        efil.transfer(account, amount);
    }

     
    function repayDebt(string calldata miner, uint amount) external {
        address repayer = msg.sender;

         
        accrue(miner);

         
        Debt storage debt = minerDebts[miner];

        uint actualAmount = amount;
        if (actualAmount > debt.accruedAmount) {
            actualAmount = debt.accruedAmount;
        }

        address efilAddr = getEfilAddress();
        EIP20Interface efil = EIP20Interface(efilAddr);
        require(efil.transferFrom(repayer, address(this), actualAmount), "transferFrom failed");

        debt.accruedAmount = sub_(debt.accruedAmount, actualAmount);
        debt.lastRepaymentBlock = getBlockNumber();

        emit Repayment(miner, repayer, actualAmount);
    }

    function transfer(address to, uint amount) external {
        address from = msg.sender;

         
        accrue();

        uint actualAmount = amount;
        if (actualAmount == 0) {
            actualAmount = accruedRewards[from];
        }
        require(accruedRewards[from] >= actualAmount, "Insufficient value");

         
        accruedRewards[from] = sub_(accruedRewards[from], actualAmount);
        accruedRewards[to] = add_(accruedRewards[to], actualAmount);

        emit Transferred(from, to, actualAmount);
    }
    
     

     
    function setManagement(IFilstManagement newManagement) external {
        require(msg.sender == admin, "admin check");
        require(address(newManagement) != address(0), "Invalid newManagement");

        if (debtAccruedIndex == 0) {
            debtAccruedIndex = initialAccruedIndex;
        }

         
        IFilstManagement oldManagement = management;
         
        management = newManagement;

        emit ManagementChanged(oldManagement, newManagement);
    }

     
    function setStrategy(IRewardStrategy newStrategy) external {
        require(msg.sender == admin, "admin check");
        require(address(newStrategy) != address(0), "Invalid newStrategy");

         
        IRewardStrategy oldStrategy = strategy;
         
        strategy = newStrategy;

        emit StrategyChanged(oldStrategy, newStrategy);
    }

     
    function setCalculator(IRewardCalculator newCalculator) external {
        require(msg.sender == admin, "admin check");
        require(address(newCalculator) != address(0), "Invalid newCalculator");

         
        IRewardCalculator oldCalculator = calculator;
         
        calculator = newCalculator;

        emit CalculatorChanged(oldCalculator, newCalculator);
    }

     
    function setStaking(address newStaking) external {
        require(msg.sender == admin, "admin check");
        require(address(Staking(newStaking).superior()) == address(this), "Staking superior mismatch");
        require(Staking(newStaking).property() == filstAddress, "Staking property mismatch");
        address efilAddr = getEfilAddress();
        require(Staking(newStaking).asset() == efilAddr, "Staking asset mismatch");

         
        address oldStaking = staking;
         
        staking = newStaking;

        emit StakingChanged(oldStaking, newStaking);
    }

     
    function addLiqudity(uint amount) external {
         
        address efilAddr = getEfilAddress();
        require(EIP20Interface(efilAddr).transferFrom(msg.sender, address(this), amount), "transfer in failed");
         
        accruedRewards[admin] = add_(accruedRewards[admin], amount);

        emit LiqudityAdded(msg.sender, admin, amount);
    }

    function getBlockNumber() public view returns (uint) {
        return block.number;
    }

    function _become(RewardPoolDelegator delegator) public {
        require(msg.sender == delegator.admin(), "only delegator admin can change implementation");
        delegator._acceptImplementation();
    }
}