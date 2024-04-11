pragma experimental ABIEncoderV2;

 

pragma solidity ^0.5.17;



 
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

 
contract IDollar is IERC20 {
    function burn(uint256 amount) public;
    function burnFrom(address account, uint256 amount) public;
    function mint(address account, uint256 amount) public returns (bool);
}

 
 
library Decimal {
    using SafeMath for uint256;

     

    uint256 constant BASE = 10**18;

     


    struct D256 {
        uint256 value;
    }

     

    function zero()
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: 0 });
    }

    function one()
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: BASE });
    }

    function from(
        uint256 a
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: a.mul(BASE) });
    }

    function ratio(
        uint256 a,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: getPartial(a, BASE, b) });
    }

     

    function add(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.add(b.mul(BASE)) });
    }

    function sub(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.mul(BASE)) });
    }

    function sub(
        D256 memory self,
        uint256 b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.mul(BASE), reason) });
    }

    function mul(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.mul(b) });
    }

    function div(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.div(b) });
    }

    function pow(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        if (b == 0) {
            return from(1);
        }

        D256 memory temp = D256({ value: self.value });
        for (uint256 i = 1; i < b; i++) {
            temp = mul(temp, self);
        }

        return temp;
    }

    function add(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.add(b.value) });
    }

    function sub(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.value) });
    }

    function sub(
        D256 memory self,
        D256 memory b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.value, reason) });
    }

    function mul(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: getPartial(self.value, b.value, BASE) });
    }

    function div(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: getPartial(self.value, BASE, b.value) });
    }

    function equals(D256 memory self, D256 memory b) internal pure returns (bool) {
        return self.value == b.value;
    }

    function greaterThan(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) == 2;
    }

    function lessThan(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) == 0;
    }

    function greaterThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) > 0;
    }

    function lessThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) < 2;
    }

    function isZero(D256 memory self) internal pure returns (bool) {
        return self.value == 0;
    }

    function asUint256(D256 memory self) internal pure returns (uint256) {
        return self.value.div(BASE);
    }

     

    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
    private
    pure
    returns (uint256)
    {
        return target.mul(numerator).div(denominator);
    }

    function compareTo(
        D256 memory a,
        D256 memory b
    )
    private
    pure
    returns (uint256)
    {
        if (a.value == b.value) {
            return 1;
        }
        return a.value > b.value ? 2 : 0;
    }
}

 
contract IOracle {
    function setup() public;
    function capture() public returns (Decimal.D256 memory, bool);
    function pair() external view returns (address);
}

 
contract Account {
    enum Status { Frozen, Fluid, Locked }

    struct State {
        uint256 staged;
        uint256 balance;
        mapping(uint256 => uint256) coupons;
        mapping(address => uint256) couponAllowances;
        uint256 fluidUntil;
        uint256 lockedUntil;
    }

    struct State10 {
        uint256 depositedCDSD;
        uint256 interestMultiplierEntry;
        uint256 earnableCDSD;
        uint256 earnedCDSD;
        uint256 redeemedCDSD;
        uint256 redeemedThisExpansion;
        uint256 lastRedeemedExpansionStart;
    }
}

contract Epoch {
    struct Global {
        uint256 start;
        uint256 period;
        uint256 current;
    }

    struct Coupons {
        uint256 outstanding;
        uint256 expiration;
        uint256[] expiring;
    }

    struct State {
        uint256 bonded;
        Coupons coupons;
    }
}

contract Candidate {
    enum Vote { UNDECIDED, APPROVE, REJECT }

    struct State {
        uint256 start;
        uint256 period;
        uint256 approve;
        uint256 reject;
        mapping(address => Vote) votes;
        bool initialized;
    }
}

contract Storage {
    struct Provider {
        IDollar dollar;
        IOracle oracle;
        address pool;
    }

    struct Balance {
        uint256 supply;
        uint256 bonded;
        uint256 staged;
        uint256 redeemable;
        uint256 debt;
        uint256 coupons;
    }

    struct State {
        Epoch.Global epoch;
        Balance balance;
        Provider provider;
        mapping(address => Account.State) accounts;
        mapping(uint256 => Epoch.State) epochs;
        mapping(address => Candidate.State) candidates;
    }

    struct State13 {
        mapping(address => mapping(uint256 => uint256)) couponUnderlyingByAccount;
        uint256 couponUnderlying;
        Decimal.D256 price;
    }

    struct State16 {
        IOracle legacyOracle;
        uint256 epochStartForSushiswapPool;
    }

    struct State10 {
        mapping(address => Account.State10) accounts;

        uint256 globalInterestMultiplier;

        uint256 totalCDSDDeposited;
        uint256 totalCDSDEarnable;
        uint256 totalCDSDEarned;

        uint256 expansionStartEpoch;
        uint256 totalCDSDRedeemable;
        uint256 totalCDSDRedeemed;
    }
}

contract State {
    Storage.State _state;

     
    Storage.State13 _state13;

     
    Storage.State16 _state16;

     
    Storage.State10 _state10;
}

 
library Constants {
     
    uint256 private constant CHAIN_ID = 1;  

     
    uint256 private constant BOOTSTRAPPING_PERIOD = 150;  
    uint256 private constant BOOTSTRAPPING_PRICE = 154e16;  

     
    address private constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    uint256 private constant ORACLE_RESERVE_MINIMUM = 1e10;  

     
    uint256 private constant INITIAL_STAKE_MULTIPLE = 1e6;  

     
    struct EpochStrategy {
        uint256 offset;
        uint256 start;
        uint256 period;
    }

    uint256 private constant EPOCH_OFFSET = 0;
    uint256 private constant EPOCH_START = 1606348800;
    uint256 private constant EPOCH_PERIOD = 7200;

     
    uint256 private constant GOVERNANCE_PERIOD = 36;
    uint256 private constant GOVERNANCE_QUORUM = 20e16;  
    uint256 private constant GOVERNANCE_PROPOSAL_THRESHOLD = 5e15;  
    uint256 private constant GOVERNANCE_SUPER_MAJORITY = 66e16;  
    uint256 private constant GOVERNANCE_EMERGENCY_DELAY = 6;  

     
    uint256 private constant ADVANCE_INCENTIVE_PREMIUM = 125e16;  
    uint256 private constant DAO_EXIT_LOCKUP_EPOCHS = 36;  

     
    uint256 private constant POOL_EXIT_LOCKUP_EPOCHS = 12;  
    address private constant POOL_ADDRESS = address(0xf929fc6eC25850ce00e457c4F28cDE88A94415D8);
    address private constant CONTRACTION_POOL_ADDRESS = address(0x170cec2070399B85363b788Af2FB059DB8Ef8aeD);
    uint256 private constant CONTRACTION_POOL_TARGET_SUPPLY = 10e16;  
    uint256 private constant CONTRACTION_POOL_TARGET_REWARD = 29e13;  


     
    uint256 private constant SUPPLY_CHANGE_LIMIT = 2e16;  
    uint256 private constant SUPPLY_CHANGE_DIVISOR = 25e18;  
    uint256 private constant ORACLE_POOL_RATIO = 35;  
    uint256 private constant TREASURY_RATIO = 3;  

     
    address private constant DAO_ADDRESS = address(0x6Bf977ED1A09214E6209F4EA5f525261f1A2690a);
    address private constant DOLLAR_ADDRESS = address(0xBD2F0Cd039E0BFcf88901C98c0bFAc5ab27566e3);
    address private constant CONTRACTION_DOLLAR_ADDRESS = address(0xDe25486CCb4588Ce5D9fB188fb6Af72E768a466a);
    address private constant PAIR_ADDRESS = address(0x26d8151e631608570F3c28bec769C3AfEE0d73a3);  
    address private constant CONTRACTION_PAIR_ADDRESS = address(0x4a4572D92Daf14D29C3b8d001A2d965c6A2b1515);
    address private constant TREASURY_ADDRESS = address(0xC7DA8087b8BA11f0892f1B0BFacfD44C116B303e);

     
    uint256 private constant EARNABLE_FACTOR = 1e18;  
    uint256 private constant CDSD_REDEMPTION_RATIO = 50;  
    uint256 private constant CONTRACTION_BONDING_REWARDS = 51000000000000;  
    uint256 private constant MAX_CDSD_BONDING_REWARDS = 2750000000000000;  
    uint256 private constant MAX_CDSD_REWARDS_THRESHOLD = 75e16;  


     
    function getUsdcAddress() internal pure returns (address) {
        return USDC;
    }

    function getOracleReserveMinimum() internal pure returns (uint256) {
        return ORACLE_RESERVE_MINIMUM;
    }

    function getEpochStrategy() internal pure returns (EpochStrategy memory) {
        return EpochStrategy({ offset: EPOCH_OFFSET, start: EPOCH_START, period: EPOCH_PERIOD });
    }

    function getInitialStakeMultiple() internal pure returns (uint256) {
        return INITIAL_STAKE_MULTIPLE;
    }

    function getBootstrappingPeriod() internal pure returns (uint256) {
        return BOOTSTRAPPING_PERIOD;
    }

    function getBootstrappingPrice() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({ value: BOOTSTRAPPING_PRICE });
    }

    function getGovernancePeriod() internal pure returns (uint256) {
        return GOVERNANCE_PERIOD;
    }

    function getGovernanceQuorum() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({ value: GOVERNANCE_QUORUM });
    }

    function getGovernanceProposalThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({ value: GOVERNANCE_PROPOSAL_THRESHOLD });
    }

    function getGovernanceSuperMajority() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({ value: GOVERNANCE_SUPER_MAJORITY });
    }

    function getGovernanceEmergencyDelay() internal pure returns (uint256) {
        return GOVERNANCE_EMERGENCY_DELAY;
    }

    function getAdvanceIncentivePremium() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({ value: ADVANCE_INCENTIVE_PREMIUM });
    }

    function getDAOExitLockupEpochs() internal pure returns (uint256) {
        return DAO_EXIT_LOCKUP_EPOCHS;
    }

    function getPoolExitLockupEpochs() internal pure returns (uint256) {
        return POOL_EXIT_LOCKUP_EPOCHS;
    }

    function getPoolAddress() internal pure returns (address) {
        return POOL_ADDRESS;
    }

    function getContractionPoolAddress() internal pure returns (address) {
        return CONTRACTION_POOL_ADDRESS;
    }

    function getContractionPoolTargetSupply() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: CONTRACTION_POOL_TARGET_SUPPLY});
    }

    function getContractionPoolTargetReward() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: CONTRACTION_POOL_TARGET_REWARD});
    }

    function getSupplyChangeLimit() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({ value: SUPPLY_CHANGE_LIMIT });
    }

    function getSupplyChangeDivisor() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({ value: SUPPLY_CHANGE_DIVISOR });
    }

    function getOraclePoolRatio() internal pure returns (uint256) {
        return ORACLE_POOL_RATIO;
    }

    function getTreasuryRatio() internal pure returns (uint256) {
        return TREASURY_RATIO;
    }

    function getChainId() internal pure returns (uint256) {
        return CHAIN_ID;
    }

    function getDaoAddress() internal pure returns (address) {
        return DAO_ADDRESS;
    }

    function getDollarAddress() internal pure returns (address) {
        return DOLLAR_ADDRESS;
    }

    function getContractionDollarAddress() internal pure returns (address) {
        return CONTRACTION_DOLLAR_ADDRESS;
    }

    function getPairAddress() internal pure returns (address) {
        return PAIR_ADDRESS;
    }

    function getContractionPairAddress() internal pure returns (address) {
        return CONTRACTION_PAIR_ADDRESS;
    }

    function getTreasuryAddress() internal pure returns (address) {
        return TREASURY_ADDRESS;
    }

    function getEarnableFactor() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: EARNABLE_FACTOR});
    }

    function getCDSDRedemptionRatio() internal pure returns (uint256) {
        return CDSD_REDEMPTION_RATIO;
    }

    function getContractionBondingRewards() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: CONTRACTION_BONDING_REWARDS});
    }

    function maxCDSDBondingRewards() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: MAX_CDSD_BONDING_REWARDS});
    }

    function maxCDSDRewardsThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: MAX_CDSD_REWARDS_THRESHOLD});
    }
}

 
contract Getters is State {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

     

    function name() public view returns (string memory) {
        return "Dynamic Set Dollar Stake";
    }

    function symbol() public view returns (string memory) {
        return "DSDS";
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _state.accounts[account].balance;
    }

    function totalSupply() public view returns (uint256) {
        return _state.balance.supply;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return 0;
    }

     

    function dollar() public view returns (IDollar) {
        return _state.provider.dollar;
    }

    function oracle() public view returns (IOracle) {
        if (epoch() < _state16.epochStartForSushiswapPool) {
            return _state16.legacyOracle;
        } else {
            return _state.provider.oracle;
        }
    }

    function pool() public view returns (address) {
        return Constants.getPoolAddress();
    }

    function cpool() public view returns (address) {
        return Constants.getContractionPoolAddress();
    }

    function totalBonded() public view returns (uint256) {
        return _state.balance.bonded;
    }

    function totalStaged() public view returns (uint256) {
        return _state.balance.staged;
    }

    function totalDebt() public view returns (uint256) {
        return _state.balance.debt;
    }

    function totalRedeemable() public view returns (uint256) {
        return _state.balance.redeemable;
    }

    function totalCouponUnderlying() public view returns (uint256) {
        return _state13.couponUnderlying;
    }

    function totalCoupons() public view returns (uint256) {
        return _state.balance.coupons;
    }

    function treasury() public view returns (address) {
        return Constants.getTreasuryAddress();
    }

     
    function totalCDSDBonded() public view returns (uint256) {
        return cdsd().balanceOf(address(this));
    }

    function globalInterestMultiplier() public view returns (uint256) {
        return _state10.globalInterestMultiplier;
    }

    function expansionStartEpoch() public view returns (uint256) {
        return _state10.expansionStartEpoch;
    }

    function totalCDSD() public view returns (uint256) {
        return cdsd().totalSupply();
    }

    function cdsd() public view returns (IDollar) {
        return IDollar(Constants.getContractionDollarAddress());
    }

     

    function getPrice() public view returns (Decimal.D256 memory price) {
        return _state13.price;
    }

     

    function balanceOfStaged(address account) public view returns (uint256) {
        return _state.accounts[account].staged;
    }

    function balanceOfBonded(address account) public view returns (uint256) {
        uint256 totalSupplyAmount = totalSupply();
        if (totalSupplyAmount == 0) {
            return 0;
        }
        return totalBonded().mul(balanceOf(account)).div(totalSupplyAmount);
    }

    function balanceOfCoupons(address account, uint256 epoch) public view returns (uint256) {
        if (outstandingCoupons(epoch) == 0) {
            return 0;
        }
        return _state.accounts[account].coupons[epoch];
    }

    function balanceOfCouponUnderlying(address account, uint256 epoch) public view returns (uint256) {
        uint256 underlying = _state13.couponUnderlyingByAccount[account][epoch];

         
        if (underlying == 0 && outstandingCoupons(epoch) == 0) {
            return _state.accounts[account].coupons[epoch].div(2);
        }

        return underlying;
    }

    function statusOf(address account) public view returns (Account.Status) {
        if (_state.accounts[account].lockedUntil > epoch()) {
            return Account.Status.Locked;
        }

        return epoch() >= _state.accounts[account].fluidUntil ? Account.Status.Frozen : Account.Status.Fluid;
    }

    function fluidUntil(address account) public view returns (uint256) {
        return _state.accounts[account].fluidUntil;
    }

    function lockedUntil(address account) public view returns (uint256) {
        return _state.accounts[account].lockedUntil;
    }

    function allowanceCoupons(address owner, address spender) public view returns (uint256) {
        return _state.accounts[owner].couponAllowances[spender];
    }

     
    function balanceOfCDSDBonded(address account) public view returns (uint256) {
        uint256 entry = interestMultiplierEntryByAccount(account);
        if (entry == 0) {
            return 0;
        }

        uint256 amount = depositedCDSDByAccount(account).mul(_state10.globalInterestMultiplier).div(entry);

        uint256 cappedAmount = cDSDBondedCap(account);

        return amount > cappedAmount ? cappedAmount : amount;
    }

    function cDSDBondedCap(address account) public view returns (uint256) {
        return depositedCDSDByAccount(account).add(earnableCDSDByAccount(account)).sub(earnedCDSDByAccount(account));
    }

    function depositedCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].depositedCDSD;
    }

    function interestMultiplierEntryByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].interestMultiplierEntry;
    }

    function earnableCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].earnableCDSD;
    }

    function earnedCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].earnedCDSD;
    }

    function redeemedCDSDByAccount(address account) public view returns (uint256) {
        return _state10.accounts[account].redeemedCDSD;
    }

    function getRedeemedThisExpansion(address account) public view returns (uint256) {
        uint256 currentExpansion = _state10.expansionStartEpoch;
        uint256 accountExpansion = _state10.accounts[account].lastRedeemedExpansionStart;

        if (currentExpansion != accountExpansion) {
            return 0;
        } else {
            return _state10.accounts[account].redeemedThisExpansion;
        }
    }

    function getCurrentRedeemableCDSDByAccount(address account) public view returns (uint256) {
        uint256 total = totalCDSDBonded();
        if (total == 0) {
            return 0;
        }
        return
            totalCDSDRedeemable().mul(balanceOfCDSDBonded(account)).div(total).sub(getRedeemedThisExpansion(account));
    }

    function totalCDSDDeposited() public view returns (uint256) {
        return _state10.totalCDSDDeposited;
    }

    function totalCDSDEarnable() public view returns (uint256) {
        return _state10.totalCDSDEarnable;
    }

    function totalCDSDEarned() public view returns (uint256) {
        return _state10.totalCDSDEarned;
    }

    function totalCDSDRedeemed() public view returns (uint256) {
        return _state10.totalCDSDRedeemed;
    }

    function totalCDSDRedeemable() public view returns (uint256) {
        return _state10.totalCDSDRedeemable;
    }

    function maxCDSDOutstanding() public view returns (uint256) {
        return totalCDSDDeposited().add(totalCDSDEarnable()).sub(totalCDSDEarned());
    }

     

     

    function epoch() public view returns (uint256) {
        return _state.epoch.current;
    }

    function epochTime() public view returns (uint256) {
        Constants.EpochStrategy memory current = Constants.getEpochStrategy();

        return epochTimeWithStrategy(current);
    }

    function epochTimeWithStrategy(Constants.EpochStrategy memory strategy) private view returns (uint256) {
        return blockTimestamp().sub(strategy.start).div(strategy.period).add(strategy.offset);
    }

     
    function blockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    function outstandingCoupons(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].coupons.outstanding;
    }

    function couponsExpiration(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].coupons.expiration;
    }

    function expiringCoupons(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].coupons.expiring.length;
    }

    function expiringCouponsAtIndex(uint256 epoch, uint256 i) public view returns (uint256) {
        return _state.epochs[epoch].coupons.expiring[i];
    }

    function totalBondedAt(uint256 epoch) public view returns (uint256) {
        return _state.epochs[epoch].bonded;
    }

    function bootstrappingAt(uint256 epoch) public view returns (bool) {
        return epoch <= Constants.getBootstrappingPeriod();
    }

     

    function recordedVote(address account, address candidate) public view returns (Candidate.Vote) {
        return _state.candidates[candidate].votes[account];
    }

    function startFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].start;
    }

    function periodFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].period;
    }

    function approveFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].approve;
    }

    function rejectFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].reject;
    }

    function votesFor(address candidate) public view returns (uint256) {
        return approveFor(candidate).add(rejectFor(candidate));
    }

    function isNominated(address candidate) public view returns (bool) {
        return _state.candidates[candidate].start > 0;
    }

    function isInitialized(address candidate) public view returns (bool) {
        return _state.candidates[candidate].initialized;
    }

    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}

 
contract Setters is State, Getters {
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

     

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return false;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        return false;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        return false;
    }

     

    function incrementTotalBonded(uint256 amount) internal {
        _state.balance.bonded = _state.balance.bonded.add(amount);
    }

    function decrementTotalBonded(uint256 amount, string memory reason) internal {
        _state.balance.bonded = _state.balance.bonded.sub(amount, reason);
    }

    function incrementTotalDebt(uint256 amount) internal {
        _state.balance.debt = _state.balance.debt.add(amount);
    }

    function decrementTotalDebt(uint256 amount, string memory reason) internal {
        _state.balance.debt = _state.balance.debt.sub(amount, reason);
    }

    function setDebtToZero() internal {
        _state.balance.debt = 0;
    }

    function incrementTotalRedeemable(uint256 amount) internal {
        _state.balance.redeemable = _state.balance.redeemable.add(amount);
    }

    function decrementTotalRedeemable(uint256 amount, string memory reason) internal {
        _state.balance.redeemable = _state.balance.redeemable.sub(amount, reason);
    }

     

    function setGlobalInterestMultiplier(uint256 multiplier) internal {
        _state10.globalInterestMultiplier = multiplier;
    }

    function setExpansionStartEpoch(uint256 epoch) internal {
        _state10.expansionStartEpoch = epoch;
    }

    function incrementTotalCDSDRedeemable(uint256 amount) internal {
        _state10.totalCDSDRedeemable = _state10.totalCDSDRedeemable.add(amount);
    }

    function decrementTotalCDSDRedeemable(uint256 amount, string memory reason) internal {
        _state10.totalCDSDRedeemable = _state10.totalCDSDRedeemable.sub(amount, reason);
    }

    function incrementTotalCDSDRedeemed(uint256 amount) internal {
        _state10.totalCDSDRedeemed = _state10.totalCDSDRedeemed.add(amount);
    }

    function decrementTotalCDSDRedeemed(uint256 amount, string memory reason) internal {
        _state10.totalCDSDRedeemed = _state10.totalCDSDRedeemed.sub(amount, reason);
    }

    function clearCDSDRedeemable() internal {
        _state10.totalCDSDRedeemable = 0;
        _state10.totalCDSDRedeemed = 0;
    }

    function incrementTotalCDSDDeposited(uint256 amount) internal {
        _state10.totalCDSDDeposited = _state10.totalCDSDDeposited.add(amount);
    }

    function decrementTotalCDSDDeposited(uint256 amount, string memory reason) internal {
        _state10.totalCDSDDeposited = _state10.totalCDSDDeposited.sub(amount, reason);
    }

    function incrementTotalCDSDEarnable(uint256 amount) internal {
        _state10.totalCDSDEarnable = _state10.totalCDSDEarnable.add(amount);
    }

    function decrementTotalCDSDEarnable(uint256 amount, string memory reason) internal {
        _state10.totalCDSDEarnable = _state10.totalCDSDEarnable.sub(amount, reason);
    }

    function incrementTotalCDSDEarned(uint256 amount) internal {
        _state10.totalCDSDEarned = _state10.totalCDSDEarned.add(amount);
    }

    function decrementTotalCDSDEarned(uint256 amount, string memory reason) internal {
        _state10.totalCDSDEarned = _state10.totalCDSDEarned.sub(amount, reason);
    }

     

     

    function incrementBalanceOf(address account, uint256 amount) internal {
        _state.accounts[account].balance = _state.accounts[account].balance.add(amount);
        _state.balance.supply = _state.balance.supply.add(amount);

        emit Transfer(address(0), account, amount);
    }

    function decrementBalanceOf(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].balance = _state.accounts[account].balance.sub(amount, reason);
        _state.balance.supply = _state.balance.supply.sub(amount, reason);

        emit Transfer(account, address(0), amount);
    }

    function incrementBalanceOfStaged(address account, uint256 amount) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.add(amount);
        _state.balance.staged = _state.balance.staged.add(amount);
    }

    function decrementBalanceOfStaged(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.sub(amount, reason);
        _state.balance.staged = _state.balance.staged.sub(amount, reason);
    }

    function incrementBalanceOfCoupons(
        address account,
        uint256 epoch,
        uint256 amount
    ) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].add(amount);
        _state.epochs[epoch].coupons.outstanding = _state.epochs[epoch].coupons.outstanding.add(amount);
        _state.balance.coupons = _state.balance.coupons.add(amount);
    }

    function incrementBalanceOfCouponUnderlying(
        address account,
        uint256 epoch,
        uint256 amount
    ) internal {
        _state13.couponUnderlyingByAccount[account][epoch] = _state13.couponUnderlyingByAccount[account][epoch].add(
            amount
        );
        _state13.couponUnderlying = _state13.couponUnderlying.add(amount);
    }

    function decrementBalanceOfCoupons(
        address account,
        uint256 epoch,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].sub(amount, reason);
        _state.epochs[epoch].coupons.outstanding = _state.epochs[epoch].coupons.outstanding.sub(amount, reason);
        _state.balance.coupons = _state.balance.coupons.sub(amount, reason);
    }

    function decrementBalanceOfCouponUnderlying(
        address account,
        uint256 epoch,
        uint256 amount,
        string memory reason
    ) internal {
        _state13.couponUnderlyingByAccount[account][epoch] = _state13.couponUnderlyingByAccount[account][epoch].sub(
            amount,
            reason
        );
        _state13.couponUnderlying = _state13.couponUnderlying.sub(amount, reason);
    }

    function unfreeze(address account) internal {
        _state.accounts[account].fluidUntil = epoch().add(Constants.getDAOExitLockupEpochs());
    }

    function updateAllowanceCoupons(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        _state.accounts[owner].couponAllowances[spender] = amount;
    }

    function decrementAllowanceCoupons(
        address owner,
        address spender,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[owner].couponAllowances[spender] = _state.accounts[owner].couponAllowances[spender].sub(
            amount,
            reason
        );
    }

     
    function incrementBalanceOfDepositedCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].depositedCDSD = _state10.accounts[account].depositedCDSD.add(amount);
    }

    function decrementBalanceOfDepositedCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].depositedCDSD = _state10.accounts[account].depositedCDSD.sub(amount, reason);
    }

    function incrementBalanceOfEarnableCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].earnableCDSD = _state10.accounts[account].earnableCDSD.add(amount);
    }

    function decrementBalanceOfEarnableCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].earnableCDSD = _state10.accounts[account].earnableCDSD.sub(amount, reason);
    }

    function incrementBalanceOfEarnedCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].earnedCDSD = _state10.accounts[account].earnedCDSD.add(amount);
    }

    function decrementBalanceOfEarnedCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].earnedCDSD = _state10.accounts[account].earnedCDSD.sub(amount, reason);
    }

    function incrementBalanceOfRedeemedCDSD(address account, uint256 amount) internal {
        _state10.accounts[account].redeemedCDSD = _state10.accounts[account].redeemedCDSD.add(amount);
    }

    function decrementBalanceOfRedeemedCDSD(address account, uint256 amount, string memory reason) internal {
        _state10.accounts[account].redeemedCDSD = _state10.accounts[account].redeemedCDSD.sub(amount, reason);
    }
    
    function addRedeemedThisExpansion(address account, uint256 amount) internal returns (uint256) {
        uint256 currentExpansion = _state10.expansionStartEpoch;
        uint256 accountExpansion = _state10.accounts[account].lastRedeemedExpansionStart;

        if (currentExpansion != accountExpansion) {
            _state10.accounts[account].redeemedThisExpansion = amount;
            _state10.accounts[account].lastRedeemedExpansionStart = currentExpansion;
        }else{
            _state10.accounts[account].redeemedThisExpansion = _state10.accounts[account].redeemedThisExpansion.add(amount);
        }
    }

    function setCurrentInterestMultiplier(address account) internal returns (uint256) {
        _state10.accounts[account].interestMultiplierEntry = _state10.globalInterestMultiplier;
    }

    function setDepositedCDSDAmount(address account, uint256 amount) internal returns (uint256) {
        _state10.accounts[account].depositedCDSD = amount;
    }


     

     

    function incrementEpoch() internal {
        _state.epoch.current = _state.epoch.current.add(1);
    }

    function snapshotTotalBonded() internal {
        _state.epochs[epoch()].bonded = totalSupply();
    }

    function initializeCouponsExpiration(uint256 epoch, uint256 expiration) internal {
        _state.epochs[epoch].coupons.expiration = expiration;
        _state.epochs[expiration].coupons.expiring.push(epoch);
    }

     

    function createCandidate(address candidate, uint256 period) internal {
        _state.candidates[candidate].start = epoch();
        _state.candidates[candidate].period = period;
    }

    function recordVote(
        address account,
        address candidate,
        Candidate.Vote vote
    ) internal {
        _state.candidates[candidate].votes[account] = vote;
    }

    function incrementApproveFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.add(amount);
    }

    function decrementApproveFor(
        address candidate,
        uint256 amount,
        string memory reason
    ) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.sub(amount, reason);
    }

    function incrementRejectFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].reject = _state.candidates[candidate].reject.add(amount);
    }

    function decrementRejectFor(
        address candidate,
        uint256 amount,
        string memory reason
    ) internal {
        _state.candidates[candidate].reject = _state.candidates[candidate].reject.sub(amount, reason);
    }

    function placeLock(address account, address candidate) internal {
        uint256 currentLock = _state.accounts[account].lockedUntil;
        uint256 newLock = startFor(candidate).add(periodFor(candidate));
        if (newLock > currentLock) {
            _state.accounts[account].lockedUntil = newLock;
        }
    }

    function initialized(address candidate) internal {
        _state.candidates[candidate].initialized = true;
    }
}

 
 
library Require {

     

    uint256 constant ASCII_ZERO = 48;  
    uint256 constant ASCII_RELATIVE_ZERO = 87;  
    uint256 constant ASCII_LOWER_EX = 120;  
    bytes2 constant COLON = 0x3a20;  
    bytes2 constant COMMA = 0x2c20;  
    bytes2 constant LPAREN = 0x203c;  
    byte constant RPAREN = 0x3e;  
    uint256 constant FOUR_BIT_MASK = 0xf;

     

    function that(
        bool must,
        bytes32 file,
        bytes32 reason
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason)
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA,
        uint256 payloadB
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
    internal
    pure
    {
        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

     

    function stringifyTruncated(
        bytes32 input
    )
    private
    pure
    returns (bytes memory)
    {
         
        bytes memory result = abi.encodePacked(input);

         
        for (uint256 i = 32; i > 0; ) {
             
             
            i--;

             
            if (result[i] != 0) {
                uint256 length = i + 1;

                 
                assembly {
                    mstore(result, length)  
                }

                return result;
            }
        }

         
        return new bytes(0);
    }

    function stringify(
        uint256 input
    )
    private
    pure
    returns (bytes memory)
    {
        if (input == 0) {
            return "0";
        }

         
        uint256 j = input;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

         
        bytes memory bstr = new bytes(length);

         
        j = input;
        for (uint256 i = length; i > 0; ) {
             
             
            i--;

             
            bstr[i] = byte(uint8(ASCII_ZERO + (j % 10)));

             
            j /= 10;
        }

        return bstr;
    }

    function stringify(
        address input
    )
    private
    pure
    returns (bytes memory)
    {
        uint256 z = uint256(input);

         
        bytes memory result = new bytes(42);

         
        result[0] = byte(uint8(ASCII_ZERO));
        result[1] = byte(uint8(ASCII_LOWER_EX));

         
        for (uint256 i = 0; i < 20; i++) {
             
            uint256 shift = i * 2;

             
            result[41 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

             
            result[40 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function stringify(
        bytes32 input
    )
    private
    pure
    returns (bytes memory)
    {
        uint256 z = uint256(input);

         
        bytes memory result = new bytes(66);

         
        result[0] = byte(uint8(ASCII_ZERO));
        result[1] = byte(uint8(ASCII_LOWER_EX));

         
        for (uint256 i = 0; i < 32; i++) {
             
            uint256 shift = i * 2;

             
            result[65 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

             
            result[64 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function char(
        uint256 input
    )
    private
    pure
    returns (byte)
    {
         
        if (input < 10) {
            return byte(uint8(input + ASCII_ZERO));
        }

         
        return byte(uint8(input + ASCII_RELATIVE_ZERO));
    }
}

 
contract Comptroller is Setters {
    using SafeMath for uint256;

    bytes32 private constant FILE = "Comptroller";

    function setPrice(Decimal.D256 memory price) internal {
        _state13.price = price;

         
        if (price.greaterThan(Decimal.one())) {
            if(_state10.expansionStartEpoch == 0){
                _state10.expansionStartEpoch = epoch();
            }
        } else {
            _state10.expansionStartEpoch = 0;
        }
    }

    function mintToAccount(address account, uint256 amount) internal {
        dollar().mint(account, amount);

        balanceCheck();
    }

    function burnFromAccount(address account, uint256 amount) internal {
        dollar().transferFrom(account, address(this), amount);
        dollar().burn(amount);

        balanceCheck();
    }

    function burnRedeemable(uint256 amount) internal {
        dollar().burn(amount);
        decrementTotalRedeemable(amount, "Comptroller: not enough redeemable balance");

        balanceCheck();
    }

    function contractionIncentives(Decimal.D256 memory price) internal returns (uint256) {
         
        uint256 redeemable = totalCDSDRedeemable();
        if (redeemable != 0) {
            clearCDSDRedeemable();
        }

         
        uint256 currentMultiplier = globalInterestMultiplier();
        Decimal.D256 memory interest = Constants.maxCDSDBondingRewards();
        if (price.greaterThan(Constants.maxCDSDRewardsThreshold())) {
            Decimal.D256 memory maxDelta = Decimal.one().sub(Constants.maxCDSDRewardsThreshold());
            interest = interest
                .mul(
                    maxDelta.sub(price.sub(Constants.maxCDSDRewardsThreshold()))
                )
                .div(maxDelta);
        }
        uint256 newMultiplier = Decimal.D256({value:currentMultiplier}).mul(Decimal.one().add(interest)).value;
        setGlobalInterestMultiplier(newMultiplier);

         
        Decimal.D256 memory cPoolReward = Decimal.D256({value:cdsd().totalSupply()})
            .mul(Constants.getContractionPoolTargetSupply())
            .mul(Constants.getContractionPoolTargetReward());
        cdsd().mint(Constants.getContractionPoolAddress(), cPoolReward.value);

         
        uint256 daoBondingRewards;
        if (totalBonded() != 0) {
            daoBondingRewards = Decimal.D256(totalBonded()).mul(Constants.getContractionBondingRewards()).value;
            mintToDAO(daoBondingRewards);
        }

        balanceCheck();

        return daoBondingRewards;
    }

    function increaseSupply(uint256 newSupply) internal returns (uint256, uint256) {
         
        uint256 poolReward = newSupply.mul(Constants.getOraclePoolRatio()).div(100);
        mintToPool(poolReward);

         
        uint256 treasuryReward = newSupply.mul(Constants.getTreasuryRatio()).div(100);
        mintToTreasury(treasuryReward);

         
        uint256 newCDSDRedeemable = 0;
        uint256 outstanding = maxCDSDOutstanding();
        uint256 redeemable = totalCDSDRedeemable().sub(totalCDSDRedeemed());
        if (redeemable < outstanding ) {
            uint256 newRedeemable = newSupply.mul(Constants.getCDSDRedemptionRatio()).div(100);
            uint256 newRedeemableCap = outstanding.sub(redeemable);

            newCDSDRedeemable = newRedeemableCap > newRedeemable ? newRedeemableCap : newRedeemable;

            incrementTotalCDSDRedeemable(newCDSDRedeemable);
        }

         
        uint256 rewards = poolReward.add(treasuryReward).add(newCDSDRedeemable);
        uint256 amount = newSupply > rewards ? newSupply.sub(rewards) : 0;

         
        if (totalBonded() == 0) {
            amount = 0;
        }
        if (amount > 0) {
            mintToDAO(amount);
        }

        balanceCheck();

        return (newCDSDRedeemable, amount.add(rewards));
    }

    function balanceCheck() internal view {
        Require.that(
            dollar().balanceOf(address(this)) >= totalBonded().add(totalStaged()).add(totalRedeemable()),
            FILE,
            "Inconsistent balances"
        );
    }

    function mintToDAO(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(address(this), amount);
            incrementTotalBonded(amount);
        }
    }

    function mintToTreasury(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(Constants.getTreasuryAddress(), amount);
        }
    }

    function mintToPool(uint256 amount) private {
        if (amount > 0) {
            dollar().mint(pool(), amount);
        }
    }
}

 
contract CDSDMarket is Comptroller {
    using SafeMath for uint256;

    event DSDBurned(address indexed account, uint256 amount);
    event CDSDMinted(address indexed account, uint256 amount);
    event CDSDRedeemed(address indexed account, uint256 amount);
    event BondCDSD(address indexed account, uint256 start, uint256 amount);
    event UnbondCDSD(address indexed account, uint256 start, uint256 amount);

    function burnDSDForCDSD(uint256 amount) public {
        require(_state13.price.lessThan(Decimal.one()), "Market: not in contraction");

         
        dollar().transferFrom(msg.sender, address(this), amount);
        dollar().burn(amount);
        balanceCheck();

         
        cdsd().mint(msg.sender, amount);

         
        uint256 earnable = Decimal.D256({value: amount}).mul(Constants.getEarnableFactor()).value;
        incrementBalanceOfEarnableCDSD(msg.sender,  earnable);
        incrementTotalCDSDEarnable(earnable);

        emit DSDBurned(msg.sender, amount);
        emit CDSDMinted(msg.sender, amount);
    }

    function migrateCouponsToCDSD(uint256 couponEpoch) public returns (uint256) {
        uint256 couponAmount = balanceOfCoupons(msg.sender, couponEpoch);
        uint256 couponUnderlyingAmount = balanceOfCouponUnderlying(msg.sender, couponEpoch);

         
        if (couponAmount == 0 && couponUnderlyingAmount == 0 && outstandingCoupons(couponEpoch) == 0){
            couponUnderlyingAmount = _state.accounts[msg.sender].coupons[couponEpoch].div(2);
        }

         
        _state13.couponUnderlyingByAccount[msg.sender][couponEpoch] = 0;
        _state.accounts[msg.sender].coupons[couponEpoch] = 0;

         
        uint256 totalAmount = couponAmount.add(couponUnderlyingAmount);
        cdsd().mint(msg.sender, totalAmount);

        emit CDSDMinted(msg.sender, totalAmount);

        return totalAmount;
    }

    function burnDSDForCDSDAndBond(uint256 amount) external {
        burnDSDForCDSD(amount);

        bondCDSD(amount);
    }

    function migrateCouponsToCDSDAndBond(uint256 couponEpoch) external {
        uint256 amountToBond = migrateCouponsToCDSD(couponEpoch);

        bondCDSD(amountToBond);
    }

    function bondCDSD(uint256 amount) public {
        require(amount > 0, "Market: bound must be greater than 0");

         
        (uint256 userBonded, uint256 userDeposited,) = updateUserEarned(msg.sender);

         
        cdsd().transferFrom(msg.sender, address(this), amount);

        uint256 totalAmount = userBonded.add(amount);
        setDepositedCDSDAmount(msg.sender, totalAmount);

        decrementTotalCDSDDeposited(userDeposited, "Market: insufficient total deposited");
        incrementTotalCDSDDeposited(totalAmount);

        emit BondCDSD(msg.sender, epoch().add(1), amount);
    }

    function unbondCDSD(uint256 amount) external {
         
        require(_state13.price.lessThan(Decimal.one()), "Market: not in contraction");

        _unbondCDSD(amount);

         
        cdsd().transfer(msg.sender, amount);

        emit UnbondCDSD(msg.sender, epoch().add(1), amount);
    }

    function _unbondCDSD(uint256 amount) internal {
         
        (uint256 userBonded, uint256 userDeposited,) = updateUserEarned(msg.sender);

        require(amount > 0 && userBonded > 0, "Market: amounts > 0!");
        require(amount <= userBonded, "Market: insufficient amount to unbound");

         
        uint256 userTotalAmount = userBonded.sub(amount);
        setDepositedCDSDAmount(msg.sender, userTotalAmount);

        decrementTotalCDSDDeposited(userDeposited, "Market: insufficient deposited");
        incrementTotalCDSDDeposited(userTotalAmount);
    }

    function redeemBondedCDSDForDSD(uint256 amount) external {
        require(_state13.price.greaterThan(Decimal.one()), "Market: not in expansion");
        require(amount > 0, "Market: amounts > 0!");

         
        require(amount <= getCurrentRedeemableCDSDByAccount(msg.sender), "Market: not enough redeemable");

         
        _unbondCDSD(amount);

         
        cdsd().burn(amount);
         
        mintToAccount(msg.sender, amount);

        addRedeemedThisExpansion(msg.sender, amount);
        incrementTotalCDSDRedeemed(amount);

        emit CDSDRedeemed(msg.sender, amount);
    }

    function updateUserEarned(address account) internal returns (uint256 userBonded, uint256 userDeposited, uint256 userEarned) {
        userBonded = balanceOfCDSDBonded(account);
        userDeposited = depositedCDSDByAccount(account);
        userEarned = userBonded.sub(userDeposited);
        
        if (userEarned > 0) {
            incrementBalanceOfEarnedCDSD(account, userEarned);
             
            cdsd().mint(address(this), userEarned);
            incrementTotalCDSDEarned(userEarned);
        }

         
        setCurrentInterestMultiplier(account);
    }
}

 
contract Regulator is Comptroller {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    event SupplyIncrease(uint256 indexed epoch, uint256 price, uint256 newRedeemable, uint256 newBonded);
    event ContractionIncentives(uint256 indexed epoch, uint256 price, uint256 delta);
    event SupplyNeutral(uint256 indexed epoch);

    function step() internal {
        Decimal.D256 memory price = oracleCapture();

        setPrice(price);

        if (price.greaterThan(Decimal.one())) {
            expansion(price);
            return;
        }

        if (price.lessThan(Decimal.one())) {
            contraction(price);
            return;
        }

        emit SupplyNeutral(epoch());
    }

    function expansion(Decimal.D256 memory price) private {
        Decimal.D256 memory delta = 
            limit(price.sub(Decimal.one()).div(Constants.getSupplyChangeDivisor()), price);
            
        uint256 newSupply = delta.mul(dollar().totalSupply()).asUint256();
        (uint256 newRedeemable, uint256 newBonded) = increaseSupply(newSupply);

        emit SupplyIncrease(epoch(), price.value, newRedeemable, newBonded);
    }

    function contraction(Decimal.D256 memory price) private {
        (uint256 newDSDSupply) = contractionIncentives(price);

        emit ContractionIncentives(epoch(), price.value, newDSDSupply);
    }

    function limit(Decimal.D256 memory delta, Decimal.D256 memory price) private view returns (Decimal.D256 memory) {
        Decimal.D256 memory supplyChangeLimit = Constants.getSupplyChangeLimit();

        return delta.greaterThan(supplyChangeLimit) ? supplyChangeLimit : delta;
    }

    function oracleCapture() private returns (Decimal.D256 memory) {
        (Decimal.D256 memory price, bool valid) = oracle().capture();

        if (bootstrappingAt(epoch().sub(1))) {
            return Constants.getBootstrappingPrice();
        }
        if (!valid) {
            return Decimal.one();
        }

        return price;
    }
}

 
contract Permission is Setters {

    bytes32 private constant FILE = "Permission";

     
    modifier onlyFrozenOrFluid(address account) {
        Require.that(
            statusOf(account) != Account.Status.Locked,
            FILE,
            "Not frozen or fluid"
        );

        _;
    }

     
    modifier onlyFrozenOrLocked(address account) {
        Require.that(
            statusOf(account) != Account.Status.Fluid,
            FILE,
            "Not frozen or locked"
        );

        _;
    }

    modifier initializer() {
        Require.that(
            !isInitialized(implementation()),
            FILE,
            "Already initialized"
        );

        initialized(implementation());

        _;
    }
}

 
contract Bonding is Setters, Permission {
    using SafeMath for uint256;

    bytes32 private constant FILE = "Bonding";

    event Deposit(address indexed account, uint256 value);
    event Withdraw(address indexed account, uint256 value);
    event Bond(address indexed account, uint256 start, uint256 value, uint256 valueUnderlying);
    event Unbond(address indexed account, uint256 start, uint256 value, uint256 valueUnderlying);

    function step() internal {
        Require.that(
            epochTime() > epoch(),
            FILE,
            "Still current epoch"
        );

        snapshotTotalBonded();
        incrementEpoch();
    }

    function deposit(uint256 value) external {
        dollar().transferFrom(msg.sender, address(this), value);
        incrementBalanceOfStaged(msg.sender, value);

        emit Deposit(msg.sender, value);
    }

    function withdraw(uint256 value) external onlyFrozenOrLocked(msg.sender) {
        dollar().transfer(msg.sender, value);
        decrementBalanceOfStaged(msg.sender, value, "Bonding: insufficient staged balance");

        emit Withdraw(msg.sender, value);
    }

    function bond(uint256 value) external onlyFrozenOrFluid(msg.sender) {
        unfreeze(msg.sender);

        uint256 balance = totalBonded() == 0 ?
            value.mul(Constants.getInitialStakeMultiple()) :
            value.mul(totalSupply()).div(totalBonded());
        incrementBalanceOf(msg.sender, balance);
        incrementTotalBonded(value);
        decrementBalanceOfStaged(msg.sender, value, "Bonding: insufficient staged balance");

        emit Bond(msg.sender, epoch().add(1), balance, value);
    }

    function unbond(uint256 value) external onlyFrozenOrFluid(msg.sender) {
        unfreeze(msg.sender);

        uint256 staged = value.mul(balanceOfBonded(msg.sender)).div(balanceOf(msg.sender));
        incrementBalanceOfStaged(msg.sender, staged);
        decrementTotalBonded(staged, "Bonding: insufficient total bonded");
        decrementBalanceOf(msg.sender, value, "Bonding: insufficient balance");

        emit Unbond(msg.sender, epoch().add(1), value, staged);
    }

    function unbondUnderlying(uint256 value) external onlyFrozenOrFluid(msg.sender) {
        unfreeze(msg.sender);

        uint256 balance = value.mul(totalSupply()).div(totalBonded());
        incrementBalanceOfStaged(msg.sender, value);
        decrementTotalBonded(value, "Bonding: insufficient total bonded");
        decrementBalanceOf(msg.sender, balance, "Bonding: insufficient balance");

        emit Unbond(msg.sender, epoch().add(1), balance, value);
    }
}

 
library OpenZeppelinUpgradesAddress {
     
    function isContract(address account) internal view returns (bool) {
        uint256 size;
         
         
         
         
         
         
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

 
 
contract Upgradeable is State {
     
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

     
    event Upgraded(address indexed implementation);

    function initialize() public;

     
    function upgradeTo(address newImplementation) internal {
        setImplementation(newImplementation);

        (bool success, bytes memory reason) = newImplementation.delegatecall(abi.encodeWithSignature("initialize()"));
        require(success, string(reason));

        emit Upgraded(newImplementation);
    }

     
    function setImplementation(address newImplementation) private {
        require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

 
contract Govern is Setters, Permission, Upgradeable {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    bytes32 private constant FILE = "Govern";

    event Proposal(address indexed candidate, address indexed account, uint256 indexed start, uint256 period);
    event Vote(address indexed account, address indexed candidate, Candidate.Vote vote, uint256 bonded);
    event Commit(address indexed account, address indexed candidate);

    function vote(address candidate, Candidate.Vote vote) external onlyFrozenOrLocked(msg.sender) {
        Require.that(
            balanceOf(msg.sender) > 0,
            FILE,
            "Must have stake"
        );

        if (!isNominated(candidate)) {
            Require.that(
                canPropose(msg.sender),
                FILE,
                "Not enough stake to propose"
            );

            createCandidate(candidate, Constants.getGovernancePeriod());
            emit Proposal(candidate, msg.sender, epoch(), Constants.getGovernancePeriod());
        }

        Require.that(
            epoch() < startFor(candidate).add(periodFor(candidate)),
            FILE,
            "Ended"
        );

        uint256 bonded = balanceOf(msg.sender);
        Candidate.Vote recordedVote = recordedVote(msg.sender, candidate);
        if (vote == recordedVote) {
            return;
        }

        if (recordedVote == Candidate.Vote.REJECT) {
            decrementRejectFor(candidate, bonded, "Govern: Insufficient reject");
        }
        if (recordedVote == Candidate.Vote.APPROVE) {
            decrementApproveFor(candidate, bonded, "Govern: Insufficient approve");
        }
        if (vote == Candidate.Vote.REJECT) {
            incrementRejectFor(candidate, bonded);
        }
        if (vote == Candidate.Vote.APPROVE) {
            incrementApproveFor(candidate, bonded);
        }

        recordVote(msg.sender, candidate, vote);
        placeLock(msg.sender, candidate);

        emit Vote(msg.sender, candidate, vote, bonded);
    }

    function commit(address candidate) external {
        Require.that(
            isNominated(candidate),
            FILE,
            "Not nominated"
        );

        uint256 endsAfter = startFor(candidate).add(periodFor(candidate)).sub(1);

        Require.that(
            epoch() > endsAfter,
            FILE,
            "Not ended"
        );

        Require.that(
            Decimal.ratio(votesFor(candidate), totalBondedAt(endsAfter)).greaterThan(Constants.getGovernanceQuorum()),
            FILE,
            "Must have quorum"
        );

        Require.that(
            approveFor(candidate) > rejectFor(candidate),
            FILE,
            "Not approved"
        );

        upgradeTo(candidate);

        emit Commit(msg.sender, candidate);
    }

    function emergencyCommit(address candidate) external {
        Require.that(
            isNominated(candidate),
            FILE,
            "Not nominated"
        );

        Require.that(
            epochTime() > epoch().add(Constants.getGovernanceEmergencyDelay()),
            FILE,
            "Epoch synced"
        );

        Require.that(
            Decimal.ratio(approveFor(candidate), totalSupply()).greaterThan(Constants.getGovernanceSuperMajority()),
            FILE,
            "Must have super majority"
        );

        Require.that(
            approveFor(candidate) > rejectFor(candidate),
            FILE,
            "Not approved"
        );

        upgradeTo(candidate);

        emit Commit(msg.sender, candidate);
    }

    function canPropose(address account) private view returns (bool) {
        if (totalBonded() == 0) {
            return false;
        }

        Decimal.D256 memory stake = Decimal.ratio(balanceOf(account), totalSupply());
        return stake.greaterThan(Constants.getGovernanceProposalThreshold());
    }
}

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

 
contract ERC20Burnable is Context, ERC20 {
     
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

     
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

 
library LibEIP712 {

     
     
     
     
     
     
     
     
     
    bytes32 constant internal _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    
    
    
    
    
    function hashEIP712Domain(
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract
    )
    internal
    pure
    returns (bytes32 result)
    {
        bytes32 schemaHash = _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH;

         
         
         
         
         
         
         
         

        assembly {
         
            let nameHash := keccak256(add(name, 32), mload(name))
            let versionHash := keccak256(add(version, 32), mload(version))

         
            let memPtr := mload(64)

         
            mstore(memPtr, schemaHash)
            mstore(add(memPtr, 32), nameHash)
            mstore(add(memPtr, 64), versionHash)
            mstore(add(memPtr, 96), chainId)
            mstore(add(memPtr, 128), verifyingContract)

         
            result := keccak256(memPtr, 160)
        }
        return result;
    }

    
    
     
    
    
    function hashEIP712Message(bytes32 eip712DomainHash, bytes32 hashStruct)
    internal
    pure
    returns (bytes32 result)
    {
         
         
         
         
         
         

        assembly {
         
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)   
            mstore(add(memPtr, 2), eip712DomainHash)                                             
            mstore(add(memPtr, 34), hashStruct)                                                  

         
            result := keccak256(memPtr, 66)
        }
        return result;
    }
}

 
contract Permittable is ERC20Detailed, ERC20 {
    bytes32 constant FILE = "Permittable";

     
    bytes32 public constant EIP712_PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    string private constant EIP712_VERSION = "1";

    bytes32 public EIP712_DOMAIN_SEPARATOR;

    mapping(address => uint256) nonces;

    constructor() public {
        EIP712_DOMAIN_SEPARATOR = LibEIP712.hashEIP712Domain(name(), EIP712_VERSION, Constants.getChainId(), address(this));
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = LibEIP712.hashEIP712Message(
            EIP712_DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                EIP712_PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            ))
        );

        address recovered = ecrecover(digest, v, r, s);
        Require.that(
            recovered == owner,
            FILE,
            "Invalid signature"
        );

        Require.that(
            recovered != address(0),
            FILE,
            "Zero address"
        );

        Require.that(
            now <= deadline,
            FILE,
            "Expired"
        );

        _approve(owner, spender, value);
    }
}

 
contract ContractionDollar is IDollar, ERC20Detailed, Permittable, ERC20Burnable {
    constructor() public ERC20Detailed("Contraction Dynamic Set Dollar", "CDSD", 18) Permittable() {}

    function mint(address account, uint256 amount) public returns (bool) {
        require(_msgSender() == Constants.getDaoAddress(), "CDSD: only DAO is allowed to mint");
        _mint(account, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        if (
            _msgSender() != Constants.getDaoAddress() &&  
            allowance(sender, _msgSender()) != uint256(-1)
        ) {
            _approve(
                sender,
                _msgSender(),
                allowance(sender, _msgSender()).sub(amount, "CDSD: transfer amount exceeds allowance")
            );
        }
        return true;
    }
}

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

   
   
   
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

 
contract Implementation is State, Bonding, CDSDMarket, Regulator, Govern {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() public initializer {
         
        mintToAccount(msg.sender, 1000e18);  

         
        mintToAccount(0xF414CFf71eCC35320Df0BB577E3Bc9B69c9E1f07, 5000e18);  
    }

    function advance() external incentivized {
        Bonding.step();
        Regulator.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }

    modifier incentivized {
         
        uint256 startGas = gasleft();
        _;
         
        (, int256 ethPrice, , , ) = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).latestRoundData();
        (, int256 fastGasPrice, , , ) =
            AggregatorV3Interface(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C).latestRoundData();

         
        Decimal.D256 memory ethSpent =
            Decimal.D256({
                value: (startGas - gasleft() + 41000).mul(uint256(fastGasPrice))  
            });
        Decimal.D256 memory usdCost =
            ethSpent.mul(
                Decimal.D256({
                    value: uint256(ethPrice).mul(1e10)  
                })
            );
        Decimal.D256 memory dsdCost = usdCost.div(getPrice());

         
        Decimal.D256 memory incentive = dsdCost.mul(Constants.getAdvanceIncentivePremium());

         
        mintToAccount(msg.sender, incentive.value);
        emit Incentivization(msg.sender, incentive.value);
    }
}