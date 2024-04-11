 


pragma solidity 0.5.17;




contract CTokenStorage {
   
  bool internal _notEntered;

   
  string public name;

   
  string public symbol;

   
  uint8 public decimals;

   
  address public underlying;

   

  uint256 internal constant borrowRateMaxMantissa = 0.0005e16;

   
  uint256 internal constant reserveFactorMaxMantissa = 1e18;

   
  address payable public admin;

   
  address payable public pendingAdmin;

   
  ComptrollerInterface public comptroller;

   
  InterestRateModel public interestRateModel;

   
  uint256 internal initialExchangeRateMantissa;

   
  uint256 public reserveFactorMantissa;

   
  uint256 public accrualBlockNumber;

   
  uint256 public borrowIndex;

   
  uint256 public totalBorrows;

   
  uint256 public totalReserves;

   
  uint256 public totalSupply;

   
  mapping(address => uint256) internal accountTokens;

   
  mapping(address => mapping(address => uint256)) internal transferAllowances;

   
  struct BorrowSnapshot {
    uint256 principal;
    uint256 interestIndex;
  }

   
  mapping(address => BorrowSnapshot) internal accountBorrows;

   
  address public trigger;

   
  uint256 public totalSupplyWhenTriggered;
}

pragma solidity 0.5.17;

 
contract CarefulMath {
   
  enum MathError {NO_ERROR, DIVISION_BY_ZERO, INTEGER_OVERFLOW, INTEGER_UNDERFLOW}

   
  function mulUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    if (a == 0) {
      return (MathError.NO_ERROR, 0);
    }

    uint256 c = a * b;

    if (c / a != b) {
      return (MathError.INTEGER_OVERFLOW, 0);
    } else {
      return (MathError.NO_ERROR, c);
    }
  }

   
  function divUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    if (b == 0) {
      return (MathError.DIVISION_BY_ZERO, 0);
    }

    return (MathError.NO_ERROR, a / b);
  }

   
  function subUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    if (b <= a) {
      return (MathError.NO_ERROR, a - b);
    } else {
      return (MathError.INTEGER_UNDERFLOW, 0);
    }
  }

   
  function addUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
    uint256 c = a + b;

    if (c >= a) {
      return (MathError.NO_ERROR, c);
    } else {
      return (MathError.INTEGER_OVERFLOW, 0);
    }
  }

   
  function addThenSubUInt(
    uint256 a,
    uint256 b,
    uint256 c
  ) internal pure returns (MathError, uint256) {
    (MathError err0, uint256 sum) = addUInt(a, b);

    if (err0 != MathError.NO_ERROR) {
      return (err0, 0);
    }

    return subUInt(sum, c);
  }
}

pragma solidity 0.5.17;

 
contract ExponentialNoError {
  uint256 constant expScale = 1e18;
  uint256 constant doubleScale = 1e36;
  uint256 constant halfExpScale = expScale / 2;
  uint256 constant mantissaOne = expScale;

  struct Exp {
    uint256 mantissa;
  }

  struct Double {
    uint256 mantissa;
  }

   
  function truncate(Exp memory exp) internal pure returns (uint256) {
     
    return exp.mantissa / expScale;
  }

   
  function mul_ScalarTruncate(Exp memory a, uint256 scalar) internal pure returns (uint256) {
    Exp memory product = mul_(a, scalar);
    return truncate(product);
  }

   
  function mul_ScalarTruncateAddUInt(
    Exp memory a,
    uint256 scalar,
    uint256 addend
  ) internal pure returns (uint256) {
    Exp memory product = mul_(a, scalar);
    return add_(truncate(product), addend);
  }

   
  function lessThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
    return left.mantissa < right.mantissa;
  }

   
  function lessThanOrEqualExp(Exp memory left, Exp memory right) internal pure returns (bool) {
    return left.mantissa <= right.mantissa;
  }

   
  function greaterThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {
    return left.mantissa > right.mantissa;
  }

   
  function isZeroExp(Exp memory value) internal pure returns (bool) {
    return value.mantissa == 0;
  }

  function safe224(uint256 n, string memory errorMessage) internal pure returns (uint224) {
    require(n < 2**224, errorMessage);
    return uint224(n);
  }

  function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
    require(n < 2**32, errorMessage);
    return uint32(n);
  }

  function add_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({mantissa: add_(a.mantissa, b.mantissa)});
  }

  function add_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({mantissa: add_(a.mantissa, b.mantissa)});
  }

  function add_(uint256 a, uint256 b) internal pure returns (uint256) {
    return add_(a, b, "addition overflow");
  }

  function add_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, errorMessage);
    return c;
  }

  function sub_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
  }

  function sub_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({mantissa: sub_(a.mantissa, b.mantissa)});
  }

  function sub_(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub_(a, b, "subtraction underflow");
  }

  function sub_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function mul_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
  }

  function mul_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
    return Exp({mantissa: mul_(a.mantissa, b)});
  }

  function mul_(uint256 a, Exp memory b) internal pure returns (uint256) {
    return mul_(a, b.mantissa) / expScale;
  }

  function mul_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
  }

  function mul_(Double memory a, uint256 b) internal pure returns (Double memory) {
    return Double({mantissa: mul_(a.mantissa, b)});
  }

  function mul_(uint256 a, Double memory b) internal pure returns (uint256) {
    return mul_(a, b.mantissa) / doubleScale;
  }

  function mul_(uint256 a, uint256 b) internal pure returns (uint256) {
    return mul_(a, b, "multiplication overflow");
  }

  function mul_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, errorMessage);
    return c;
  }

  function div_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {
    return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
  }

  function div_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
    return Exp({mantissa: div_(a.mantissa, b)});
  }

  function div_(uint256 a, Exp memory b) internal pure returns (uint256) {
    return div_(mul_(a, expScale), b.mantissa);
  }

  function div_(Double memory a, Double memory b) internal pure returns (Double memory) {
    return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
  }

  function div_(Double memory a, uint256 b) internal pure returns (Double memory) {
    return Double({mantissa: div_(a.mantissa, b)});
  }

  function div_(uint256 a, Double memory b) internal pure returns (uint256) {
    return div_(mul_(a, doubleScale), b.mantissa);
  }

  function div_(uint256 a, uint256 b) internal pure returns (uint256) {
    return div_(a, b, "divide by zero");
  }

  function div_(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  function fraction(uint256 a, uint256 b) internal pure returns (Double memory) {
    return Double({mantissa: div_(mul_(a, doubleScale), b)});
  }
}

contract TokenErrorReporter {
  enum Error {
    NO_ERROR,
    UNAUTHORIZED,
    BAD_INPUT,
    COMPTROLLER_REJECTION,
    COMPTROLLER_CALCULATION_ERROR,
    INTEREST_RATE_MODEL_ERROR,
    INVALID_ACCOUNT_PAIR,
    INVALID_CLOSE_AMOUNT_REQUESTED,
    INVALID_COLLATERAL_FACTOR,
    MATH_ERROR,
    MARKET_NOT_FRESH,
    MARKET_NOT_LISTED,
    TOKEN_INSUFFICIENT_ALLOWANCE,
    TOKEN_INSUFFICIENT_BALANCE,
    TOKEN_INSUFFICIENT_CASH,
    TOKEN_TRANSFER_IN_FAILED,
    TOKEN_TRANSFER_OUT_FAILED,
    INVALID_GUARDIAN,
    MARKET_TRIGGERED
  }

  enum FailureInfo {
    ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
    ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
    ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
    ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
    ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
    BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
    BORROW_ACCRUE_INTEREST_FAILED,
    BORROW_CASH_NOT_AVAILABLE,
    BORROW_FRESHNESS_CHECK,
    BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
    BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
    BORROW_MARKET_NOT_LISTED,
    BORROW_COMPTROLLER_REJECTION,
    LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
    LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
    LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
    LIQUIDATE_COMPTROLLER_REJECTION,
    LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
    LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
    LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
    LIQUIDATE_FRESHNESS_CHECK,
    LIQUIDATE_LIQUIDATOR_IS_BORROWER,
    LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
    LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
    LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
    LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
    LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
    LIQUIDATE_SEIZE_TOO_MUCH,
    MINT_ACCRUE_INTEREST_FAILED,
    MINT_COMPTROLLER_REJECTION,
    MINT_EXCHANGE_CALCULATION_FAILED,
    MINT_EXCHANGE_RATE_READ_FAILED,
    MINT_FRESHNESS_CHECK,
    MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
    MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
    MINT_TRANSFER_IN_FAILED,
    MINT_TRANSFER_IN_NOT_POSSIBLE,
    REDEEM_ACCRUE_INTEREST_FAILED,
    REDEEM_COMPTROLLER_REJECTION,
    REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
    REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
    REDEEM_EXCHANGE_RATE_READ_FAILED,
    REDEEM_FRESHNESS_CHECK,
    REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
    REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
    REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
    REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
    REDUCE_RESERVES_ADMIN_CHECK,
    REDUCE_RESERVES_CASH_NOT_AVAILABLE,
    REDUCE_RESERVES_FRESH_CHECK,
    REDUCE_RESERVES_VALIDATION,
    REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
    REPAY_BORROW_ACCRUE_INTEREST_FAILED,
    REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
    REPAY_BORROW_COMPTROLLER_REJECTION,
    REPAY_BORROW_FRESHNESS_CHECK,
    REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
    REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
    REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
    SET_COLLATERAL_FACTOR_OWNER_CHECK,
    SET_COLLATERAL_FACTOR_VALIDATION,
    SET_COMPTROLLER_OWNER_CHECK,
    SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
    SET_INTEREST_RATE_MODEL_FRESH_CHECK,
    SET_INTEREST_RATE_MODEL_OWNER_CHECK,
    SET_MAX_ASSETS_OWNER_CHECK,
    SET_ORACLE_MARKET_NOT_LISTED,
    SET_PENDING_ADMIN_OWNER_CHECK,
    SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
    SET_RESERVE_FACTOR_ADMIN_CHECK,
    SET_RESERVE_FACTOR_FRESH_CHECK,
    SET_RESERVE_FACTOR_BOUNDS_CHECK,
    TRANSFER_COMPTROLLER_REJECTION,
    TRANSFER_NOT_ALLOWED,
    TRANSFER_NOT_ENOUGH,
    TRANSFER_TOO_MUCH,
    ADD_RESERVES_ACCRUE_INTEREST_FAILED,
    ADD_RESERVES_FRESH_CHECK,
    ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE,
    REDUCE_RESERVES_GUARDIAN_NOT_SET,
    TRIGGER_ACTIVATED_BEFORE_REDEEM_OR_BORROW
  }

   
  event Failure(uint256 error, uint256 info, uint256 detail);

   
  function fail(Error err, FailureInfo info) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), 0);

    return uint256(err);
  }

   
  function failOpaque(
    Error err,
    FailureInfo info,
    uint256 opaqueError
  ) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), opaqueError);

    return uint256(err);
  }
}

contract CTokenInterface is CTokenStorage {
   
  bool public constant isCToken = true;

   
  bool public isTriggered = false;

   

   
  event AccrueInterest(uint256 cashPrior, uint256 interestAccumulated, uint256 borrowIndex, uint256 totalBorrows);

   
  event Mint(address minter, uint256 mintAmount, uint256 mintTokens);

   
  event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

   
  event Borrow(address borrower, uint256 borrowAmount, uint256 accountBorrows, uint256 totalBorrows);

   
  event RepayBorrow(address payer, address borrower, uint256 repayAmount, uint256 accountBorrows, uint256 totalBorrows);

   
  event LiquidateBorrow(
    address liquidator,
    address borrower,
    uint256 repayAmount,
    address cTokenCollateral,
    uint256 seizeTokens
  );

   

   
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

   
  event NewAdmin(address oldAdmin, address newAdmin);

   
  event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);

   
  event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

   
  event NewReserveFactor(uint256 oldReserveFactorMantissa, uint256 newReserveFactorMantissa);

   
  event ReservesAdded(address benefactor, uint256 addAmount, uint256 newTotalReserves);

   
  event ReservesReduced(address admin, uint256 reduceAmount, uint256 newTotalReserves);

   
  event Transfer(address indexed from, address indexed to, uint256 amount);

   
  event Approval(address indexed owner, address indexed spender, uint256 amount);

   
  event TriggerSet(bool isTriggered);

   
  event Failure(uint256 error, uint256 info, uint256 detail);

   

  function transfer(address dst, uint256 amount) external returns (bool);

  function transferFrom(
    address src,
    address dst,
    uint256 amount
  ) external returns (bool);

  function approve(address spender, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function balanceOfUnderlying(address owner) external returns (uint256);

  function getAccountSnapshot(address account)
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    );

  function borrowRatePerBlock() external view returns (uint256);

  function supplyRatePerBlock() external view returns (uint256);

  function totalBorrowsCurrent() external returns (uint256);

  function borrowBalanceCurrent(address account) external returns (uint256);

  function borrowBalanceStored(address account) public view returns (uint256);

  function exchangeRateCurrent() public returns (uint256);

  function exchangeRateStored() public view returns (uint256);

  function getCash() external view returns (uint256);

  function accrueInterest() public returns (uint256);

  function seize(
    address liquidator,
    address borrower,
    uint256 seizeTokens
  ) external returns (uint256);

   

  function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256);

  function _acceptAdmin() external returns (uint256);

  function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);

  function _reduceReserves(uint256 reduceAmount) external returns (uint256);

  function _setInterestRateModel(InterestRateModel newInterestRateModel) external returns (uint256);
}

pragma solidity 0.5.17;




 
contract Exponential is CarefulMath, ExponentialNoError {
   
  function getExp(uint256 num, uint256 denom) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 scaledNumerator) = mulUInt(num, expScale);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({mantissa: 0}));
    }

    (MathError err1, uint256 rational) = divUInt(scaledNumerator, denom);
    if (err1 != MathError.NO_ERROR) {
      return (err1, Exp({mantissa: 0}));
    }

    return (MathError.NO_ERROR, Exp({mantissa: rational}));
  }

   
  function addExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    (MathError error, uint256 result) = addUInt(a.mantissa, b.mantissa);

    return (error, Exp({mantissa: result}));
  }

   
  function subExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    (MathError error, uint256 result) = subUInt(a.mantissa, b.mantissa);

    return (error, Exp({mantissa: result}));
  }

   
  function mulScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 scaledMantissa) = mulUInt(a.mantissa, scalar);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({mantissa: 0}));
    }

    return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
  }

   
  function mulScalarTruncate(Exp memory a, uint256 scalar) internal pure returns (MathError, uint256) {
    (MathError err, Exp memory product) = mulScalar(a, scalar);
    if (err != MathError.NO_ERROR) {
      return (err, 0);
    }

    return (MathError.NO_ERROR, truncate(product));
  }

   
  function mulScalarTruncateAddUInt(
    Exp memory a,
    uint256 scalar,
    uint256 addend
  ) internal pure returns (MathError, uint256) {
    (MathError err, Exp memory product) = mulScalar(a, scalar);
    if (err != MathError.NO_ERROR) {
      return (err, 0);
    }

    return addUInt(truncate(product), addend);
  }

   
  function divScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 descaledMantissa) = divUInt(a.mantissa, scalar);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({mantissa: 0}));
    }

    return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
  }

   
  function divScalarByExp(uint256 scalar, Exp memory divisor) internal pure returns (MathError, Exp memory) {
     
    (MathError err0, uint256 numerator) = mulUInt(expScale, scalar);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({mantissa: 0}));
    }
    return getExp(numerator, divisor.mantissa);
  }

   
  function divScalarByExpTruncate(uint256 scalar, Exp memory divisor) internal pure returns (MathError, uint256) {
    (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
    if (err != MathError.NO_ERROR) {
      return (err, 0);
    }

    return (MathError.NO_ERROR, truncate(fraction));
  }

   
  function mulExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    (MathError err0, uint256 doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
    if (err0 != MathError.NO_ERROR) {
      return (err0, Exp({mantissa: 0}));
    }

     
     
     
    (MathError err1, uint256 doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
    if (err1 != MathError.NO_ERROR) {
      return (err1, Exp({mantissa: 0}));
    }

    (MathError err2, uint256 product) = divUInt(doubleScaledProductWithHalfScale, expScale);
     
    assert(err2 == MathError.NO_ERROR);

    return (MathError.NO_ERROR, Exp({mantissa: product}));
  }

   
  function mulExp(uint256 a, uint256 b) internal pure returns (MathError, Exp memory) {
    return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
  }

   
  function mulExp3(
    Exp memory a,
    Exp memory b,
    Exp memory c
  ) internal pure returns (MathError, Exp memory) {
    (MathError err, Exp memory ab) = mulExp(a, b);
    if (err != MathError.NO_ERROR) {
      return (err, ab);
    }
    return mulExp(ab, c);
  }

   
  function divExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
    return getExp(a.mantissa, b.mantissa);
  }
}

pragma solidity 0.5.17;










 
contract CToken is CTokenInterface, Exponential, TokenErrorReporter {
  
  
   

  
   
   

  
  mapping(address => uint256) public nonces;

   
  function initialize(
    ComptrollerInterface comptroller_,
    InterestRateModel interestRateModel_,
    uint256 initialExchangeRateMantissa_,
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    address trigger_
  ) public {
    require(msg.sender == admin, "only admin may initialize market");
    require(accrualBlockNumber == 0 && borrowIndex == 0, "market already initialized");

     
    initialExchangeRateMantissa = initialExchangeRateMantissa_;
    require(initialExchangeRateMantissa > 0, "initial exchange rate must be above zero");

     
     
    require(comptroller_.isComptroller(), "marker method returned false");
     
    emit NewComptroller(comptroller, comptroller_);
    comptroller = comptroller_;

     
    accrualBlockNumber = getBlockNumber();
    borrowIndex = mantissaOne;

     
    uint256 err = _setInterestRateModelFresh(interestRateModel_);
    require(err == uint256(Error.NO_ERROR), "setting interest rate model failed");

    name = name_;
    symbol = symbol_;
    decimals = decimals_;

     
    _notEntered = true;

     
    trigger = trigger_;
    emit TriggerSet(false);
  }

   
  function transferTokens(
    address spender,
    address src,
    address dst,
    uint256 tokens
  ) internal returns (uint256) {
     
    uint256 allowed = comptroller.transferAllowed(address(this), src, dst, tokens);
    if (allowed != 0) {
      return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
    }

     
    if (src == dst) {
      return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
    }

     
    uint256 startingAllowance = 0;
    if (spender == src) {
      startingAllowance = uint256(-1);
    } else {
      startingAllowance = transferAllowances[src][spender];
    }

     
    MathError mathErr;
    uint256 allowanceNew;
    uint256 srcTokensNew;
    uint256 dstTokensNew;

    (mathErr, allowanceNew) = subUInt(startingAllowance, tokens);
    if (mathErr != MathError.NO_ERROR) {
      return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ALLOWED);
    }

    (mathErr, srcTokensNew) = subUInt(accountTokens[src], tokens);
    if (mathErr != MathError.NO_ERROR) {
      return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ENOUGH);
    }

    (mathErr, dstTokensNew) = addUInt(accountTokens[dst], tokens);
    if (mathErr != MathError.NO_ERROR) {
      return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_TOO_MUCH);
    }

     
     
     

    accountTokens[src] = srcTokensNew;
    accountTokens[dst] = dstTokensNew;

     
    if (startingAllowance != uint256(-1)) {
      transferAllowances[src][spender] = allowanceNew;
    }

     
    emit Transfer(src, dst, tokens);

    return uint256(Error.NO_ERROR);
  }

   
  function transfer(address dst, uint256 amount) external nonReentrant returns (bool) {
    return transferTokens(msg.sender, msg.sender, dst, amount) == uint256(Error.NO_ERROR);
  }

   
  function transferFrom(
    address src,
    address dst,
    uint256 amount
  ) external nonReentrant returns (bool) {
    return transferTokens(msg.sender, src, dst, amount) == uint256(Error.NO_ERROR);
  }

   
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) private returns (bool) {
    transferAllowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
    return true;
  }

   
  function approve(address spender, uint256 amount) external returns (bool) {
    return _approve(msg.sender, spender, amount);
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
    require(deadline >= block.timestamp, "Permit expired");

     
     
     
     
     

     
    address recoveredAddress =
      ecrecover(
        keccak256(
          abi.encodePacked(
            "\x19\x01",
            keccak256(
              abi.encode(
                keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                getChainId(),
                address(this)
              )
            ),
            keccak256(
              abi.encode(
                0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9,
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
              )
            )
          )
        ),
        v,
        r,
        s
      );

    require(recoveredAddress != address(0) && recoveredAddress == owner, "Invalid signature");
    _approve(owner, spender, value);
  }

   
  function getChainId() internal pure returns (uint256) {
    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    return chainId;
  }

   
  function allowance(address owner, address spender) external view returns (uint256) {
    return transferAllowances[owner][spender];
  }

   
  function balanceOf(address owner) external view returns (uint256) {
    return accountTokens[owner];
  }

   
  function balanceOfUnderlying(address owner) external returns (uint256) {
    Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
    (MathError mErr, uint256 balance) = mulScalarTruncate(exchangeRate, accountTokens[owner]);
    require(mErr == MathError.NO_ERROR, "could not calculate balance");
    return balance;
  }

   
  function getAccountSnapshot(address account)
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    uint256 cTokenBalance = accountTokens[account];
    uint256 borrowBalance;
    uint256 exchangeRateMantissa;

    MathError mErr;

    (mErr, borrowBalance) = borrowBalanceStoredInternal(account);
    if (mErr != MathError.NO_ERROR) {
      return (uint256(Error.MATH_ERROR), 0, 0, 0);
    }

    (mErr, exchangeRateMantissa) = exchangeRateStoredInternal();
    if (mErr != MathError.NO_ERROR) {
      return (uint256(Error.MATH_ERROR), 0, 0, 0);
    }

    return (uint256(Error.NO_ERROR), cTokenBalance, borrowBalance, exchangeRateMantissa);
  }

   
  function getBlockNumber() internal view returns (uint256) {
    return block.number;
  }

   
  function borrowRatePerBlock() external view returns (uint256) {
    if (isTriggered) {
      return 0;
    }
    return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalReserves);
  }

   
  function supplyRatePerBlock() external view returns (uint256) {
    if (isTriggered) {
      return 0;
    }
    return interestRateModel.getSupplyRate(getCashPrior(), totalBorrows, totalReserves, reserveFactorMantissa);
  }

   
  function totalBorrowsCurrent() external nonReentrant returns (uint256) {
    require(accrueInterest() == uint256(Error.NO_ERROR), "accrue interest failed");
    return totalBorrows;
  }

   
  function borrowBalanceCurrent(address account) external nonReentrant returns (uint256) {
    require(accrueInterest() == uint256(Error.NO_ERROR), "accrue interest failed");
    return borrowBalanceStored(account);
  }

   
  function borrowBalanceStored(address account) public view returns (uint256) {
    (MathError err, uint256 result) = borrowBalanceStoredInternal(account);
    require(err == MathError.NO_ERROR, "borrowBalanceStoredInternal failed");
    return result;
  }

   
  function borrowBalanceStoredInternal(address account) internal view returns (MathError, uint256) {
    if (isTriggered) {
      return (MathError.NO_ERROR, 0);
    }

     
    MathError mathErr;
    uint256 principalTimesIndex;
    uint256 result;

     
    BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

     
    if (borrowSnapshot.principal == 0) {
      return (MathError.NO_ERROR, 0);
    }

     
    (mathErr, principalTimesIndex) = mulUInt(borrowSnapshot.principal, borrowIndex);
    if (mathErr != MathError.NO_ERROR) {
      return (mathErr, 0);
    }

    (mathErr, result) = divUInt(principalTimesIndex, borrowSnapshot.interestIndex);
    if (mathErr != MathError.NO_ERROR) {
      return (mathErr, 0);
    }

    return (MathError.NO_ERROR, result);
  }

   
  function exchangeRateCurrent() public nonReentrant returns (uint256) {
    require(accrueInterest() == uint256(Error.NO_ERROR), "accrue interest failed");
    return exchangeRateStored();
  }

   
  function exchangeRateStored() public view returns (uint256) {
    (MathError err, uint256 result) = exchangeRateStoredInternal();
    require(err == MathError.NO_ERROR, "exchangeRateStoredInternal failed");
    return result;
  }

   
  function exchangeRateStoredInternal() internal view returns (MathError, uint256) {
    uint256 _totalSupply = totalSupply;
    if (_totalSupply == 0) {
       
      return (MathError.NO_ERROR, initialExchangeRateMantissa);
    } else {
       
      uint256 totalCash = getCashPrior();
      uint256 cashPlusBorrowsMinusReserves;
      Exp memory exchangeRate;
      MathError mathErr;

      (mathErr, cashPlusBorrowsMinusReserves) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
      if (mathErr != MathError.NO_ERROR) {
        return (mathErr, 0);
      }

      (mathErr, exchangeRate) = getExp(cashPlusBorrowsMinusReserves, _totalSupply);
      if (mathErr != MathError.NO_ERROR) {
        return (mathErr, 0);
      }

      return (MathError.NO_ERROR, exchangeRate.mantissa);
    }
  }

   
  function getCash() external view returns (uint256) {
    return getCashPrior();
  }

   
  function accrueInterest() public returns (uint256) {
     
    if (isTriggered) {
      accrualBlockNumber = getBlockNumber();  
      return uint256(Error.NO_ERROR);
    }

     
    uint256 currentBlockNumber = getBlockNumber();
    uint256 accrualBlockNumberPrior = accrualBlockNumber;

     
    if (accrualBlockNumberPrior == currentBlockNumber) {
      return uint256(Error.NO_ERROR);
    }

     
    uint256 cashPrior = getCashPrior();
    uint256 borrowsPrior = totalBorrows;
    uint256 reservesPrior = totalReserves;
    uint256 borrowIndexPrior = borrowIndex;

     
    uint256 borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior);
    require(borrowRateMantissa <= borrowRateMaxMantissa, "borrow rate too high");

     
    (MathError mathErr, uint256 blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);
    require(mathErr == MathError.NO_ERROR, "could not calculate block delta");

     

    Exp memory simpleInterestFactor;
    uint256 interestAccumulated;
    uint256 totalBorrowsNew;
    uint256 totalReservesNew;
    uint256 borrowIndexNew;

    (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa: borrowRateMantissa}), blockDelta);
    if (mathErr != MathError.NO_ERROR) {
      return
        failOpaque(
          Error.MATH_ERROR,
          FailureInfo.ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
          uint256(mathErr)
        );
    }

    (mathErr, interestAccumulated) = mulScalarTruncate(simpleInterestFactor, borrowsPrior);
    if (mathErr != MathError.NO_ERROR) {
      return
        failOpaque(
          Error.MATH_ERROR,
          FailureInfo.ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
          uint256(mathErr)
        );
    }

    (mathErr, totalBorrowsNew) = addUInt(interestAccumulated, borrowsPrior);
    if (mathErr != MathError.NO_ERROR) {
      return
        failOpaque(
          Error.MATH_ERROR,
          FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
          uint256(mathErr)
        );
    }

    (mathErr, totalReservesNew) = mulScalarTruncateAddUInt(
      Exp({mantissa: reserveFactorMantissa}),
      interestAccumulated,
      reservesPrior
    );
    if (mathErr != MathError.NO_ERROR) {
      return
        failOpaque(
          Error.MATH_ERROR,
          FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
          uint256(mathErr)
        );
    }

    (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
    if (mathErr != MathError.NO_ERROR) {
      return
        failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED, uint256(mathErr));
    }

     
     
     

     
    accrualBlockNumber = currentBlockNumber;
    borrowIndex = borrowIndexNew;
    totalBorrows = totalBorrowsNew;
    totalReserves = totalReservesNew;

     
    emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);

    return uint256(Error.NO_ERROR);
  }

   
  function mintInternal(uint256 mintAmount) internal nonReentrant returns (uint256, uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return (fail(Error(error), FailureInfo.MINT_ACCRUE_INTEREST_FAILED), 0);
    }
     
    return mintFresh(msg.sender, mintAmount);
  }

  struct MintLocalVars {
    Error err;
    MathError mathErr;
    uint256 exchangeRateMantissa;
    uint256 mintTokens;
    uint256 totalSupplyNew;
    uint256 accountTokensNew;
    uint256 actualMintAmount;
  }

   
  function mintFresh(address minter, uint256 mintAmount) internal whenNotTriggered returns (uint256, uint256) {
     
    uint256 allowed = comptroller.mintAllowed(address(this), minter, mintAmount);
    if (allowed != 0) {
      return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.MINT_COMPTROLLER_REJECTION, allowed), 0);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return (fail(Error.MARKET_NOT_FRESH, FailureInfo.MINT_FRESHNESS_CHECK), 0);
    }

    MintLocalVars memory vars;

    (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
    if (vars.mathErr != MathError.NO_ERROR) {
      return (failOpaque(Error.MATH_ERROR, FailureInfo.MINT_EXCHANGE_RATE_READ_FAILED, uint256(vars.mathErr)), 0);
    }

     
     
     

     
    vars.actualMintAmount = doTransferIn(minter, mintAmount);

     

    (vars.mathErr, vars.mintTokens) = divScalarByExpTruncate(
      vars.actualMintAmount,
      Exp({mantissa: vars.exchangeRateMantissa})
    );
    require(vars.mathErr == MathError.NO_ERROR, "MINT_EXCHANGE_CALCULATION_FAILED");

     
    (vars.mathErr, vars.totalSupplyNew) = addUInt(totalSupply, vars.mintTokens);
    require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED");

    (vars.mathErr, vars.accountTokensNew) = addUInt(accountTokens[minter], vars.mintTokens);
    require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED");

     
    totalSupply = vars.totalSupplyNew;
    accountTokens[minter] = vars.accountTokensNew;

     
    emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
    emit Transfer(address(this), minter, vars.mintTokens);

    return (uint256(Error.NO_ERROR), vars.actualMintAmount);
  }

   
  function redeemInternal(uint256 redeemTokens) internal nonReentrant returns (uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
    }
     
    return redeemFresh(msg.sender, redeemTokens, 0);
  }

   
  function redeemUnderlyingInternal(uint256 redeemAmount) internal nonReentrant returns (uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
    }
     
    return redeemFresh(msg.sender, 0, redeemAmount);
  }

  struct RedeemLocalVars {
    Error err;
    MathError mathErr;
    uint256 exchangeRateMantissa;
    uint256 redeemTokens;
    uint256 redeemAmount;
    uint256 totalSupplyNew;
    uint256 accountTokensNew;
  }

   
  function redeemFresh(
    address payable redeemer,
    uint256 redeemTokensIn,
    uint256 redeemAmountIn
  ) internal returns (uint256) {
     
     
     
     
     
    if (!isTriggered && checkAndToggleTriggerInternal()) {
      return fail(Error.MARKET_TRIGGERED, FailureInfo.TRIGGER_ACTIVATED_BEFORE_REDEEM_OR_BORROW);
    }

    require(redeemTokensIn == 0 || redeemAmountIn == 0, "one of redeemTokensIn or redeemAmountIn must be zero");

    RedeemLocalVars memory vars;

     
    (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
    if (vars.mathErr != MathError.NO_ERROR) {
      return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_RATE_READ_FAILED, uint256(vars.mathErr));
    }

     
    if (redeemTokensIn > 0) {
       
      vars.redeemTokens = redeemTokensIn;

      (vars.mathErr, vars.redeemAmount) = mulScalarTruncate(Exp({mantissa: vars.exchangeRateMantissa}), redeemTokensIn);
      if (vars.mathErr != MathError.NO_ERROR) {
        return
          failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED, uint256(vars.mathErr));
      }
    } else {
       

      (vars.mathErr, vars.redeemTokens) = divScalarByExpTruncate(
        redeemAmountIn,
        Exp({mantissa: vars.exchangeRateMantissa})
      );
      if (vars.mathErr != MathError.NO_ERROR) {
        return
          failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED, uint256(vars.mathErr));
      }

      vars.redeemAmount = redeemAmountIn;
    }

     
    uint256 allowed = comptroller.redeemAllowed(address(this), redeemer, vars.redeemTokens);
    if (allowed != 0) {
      return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REDEEM_COMPTROLLER_REJECTION, allowed);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDEEM_FRESHNESS_CHECK);
    }

     
    (vars.mathErr, vars.totalSupplyNew) = subUInt(totalSupply, vars.redeemTokens);
    if (vars.mathErr != MathError.NO_ERROR) {
      return
        failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED, uint256(vars.mathErr));
    }

    (vars.mathErr, vars.accountTokensNew) = subUInt(accountTokens[redeemer], vars.redeemTokens);
    if (vars.mathErr != MathError.NO_ERROR) {
      return
        failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED, uint256(vars.mathErr));
    }

     
    if (getCashPrior() < vars.redeemAmount) {
      return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDEEM_TRANSFER_OUT_NOT_POSSIBLE);
    }

     
     
     

     
    doTransferOut(redeemer, vars.redeemAmount);

     
    totalSupply = vars.totalSupplyNew;
    accountTokens[redeemer] = vars.accountTokensNew;

     
    emit Transfer(redeemer, address(this), vars.redeemTokens);
    emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);

     
    if (vars.redeemTokens == 0 && vars.redeemAmount > 0) {
      revert("redeemTokens zero");
    }

    return uint256(Error.NO_ERROR);
  }

   
  function borrowInternal(uint256 borrowAmount) internal nonReentrant returns (uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
    }
     
    return borrowFresh(msg.sender, borrowAmount);
  }

  struct BorrowLocalVars {
    MathError mathErr;
    uint256 accountBorrows;
    uint256 accountBorrowsNew;
    uint256 totalBorrowsNew;
  }

   
  function borrowFresh(address payable borrower, uint256 borrowAmount) internal whenNotTriggered returns (uint256) {
     
    if (checkAndToggleTriggerInternal()) {
      return fail(Error.MARKET_TRIGGERED, FailureInfo.TRIGGER_ACTIVATED_BEFORE_REDEEM_OR_BORROW);
    }

     
    uint256 allowed = comptroller.borrowAllowed(address(this), borrower, borrowAmount);
    if (allowed != 0) {
      return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.BORROW_COMPTROLLER_REJECTION, allowed);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return fail(Error.MARKET_NOT_FRESH, FailureInfo.BORROW_FRESHNESS_CHECK);
    }

     
    if (getCashPrior() < borrowAmount) {
      return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.BORROW_CASH_NOT_AVAILABLE);
    }

    BorrowLocalVars memory vars;

     
    (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
    if (vars.mathErr != MathError.NO_ERROR) {
      return
        failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, uint256(vars.mathErr));
    }

    (vars.mathErr, vars.accountBorrowsNew) = addUInt(vars.accountBorrows, borrowAmount);
    if (vars.mathErr != MathError.NO_ERROR) {
      return
        failOpaque(
          Error.MATH_ERROR,
          FailureInfo.BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
          uint256(vars.mathErr)
        );
    }

    (vars.mathErr, vars.totalBorrowsNew) = addUInt(totalBorrows, borrowAmount);
    if (vars.mathErr != MathError.NO_ERROR) {
      return
        failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED, uint256(vars.mathErr));
    }

     
     
     

     
    doTransferOut(borrower, borrowAmount);

     
    accountBorrows[borrower].principal = vars.accountBorrowsNew;
    accountBorrows[borrower].interestIndex = borrowIndex;
    totalBorrows = vars.totalBorrowsNew;

     
    emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

    return uint256(Error.NO_ERROR);
  }

   
  function repayBorrowInternal(uint256 repayAmount) internal nonReentrant returns (uint256, uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return (fail(Error(error), FailureInfo.REPAY_BORROW_ACCRUE_INTEREST_FAILED), 0);
    }
     
    return repayBorrowFresh(msg.sender, msg.sender, repayAmount);
  }

   
  function repayBorrowBehalfInternal(address borrower, uint256 repayAmount)
    internal
    nonReentrant
    returns (uint256, uint256)
  {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return (fail(Error(error), FailureInfo.REPAY_BEHALF_ACCRUE_INTEREST_FAILED), 0);
    }
     
    return repayBorrowFresh(msg.sender, borrower, repayAmount);
  }

  struct RepayBorrowLocalVars {
    Error err;
    MathError mathErr;
    uint256 repayAmount;
    uint256 borrowerIndex;
    uint256 accountBorrows;
    uint256 accountBorrowsNew;
    uint256 totalBorrowsNew;
    uint256 actualRepayAmount;
  }

   
  function repayBorrowFresh(
    address payer,
    address borrower,
    uint256 repayAmount
  ) internal whenNotTriggered returns (uint256, uint256) {
     
    uint256 allowed = comptroller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
    if (allowed != 0) {
      return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REPAY_BORROW_COMPTROLLER_REJECTION, allowed), 0);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return (fail(Error.MARKET_NOT_FRESH, FailureInfo.REPAY_BORROW_FRESHNESS_CHECK), 0);
    }

    RepayBorrowLocalVars memory vars;

     
    vars.borrowerIndex = accountBorrows[borrower].interestIndex;

     
    (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
    if (vars.mathErr != MathError.NO_ERROR) {
      return (
        failOpaque(
          Error.MATH_ERROR,
          FailureInfo.REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
          uint256(vars.mathErr)
        ),
        0
      );
    }

     
    if (repayAmount == uint256(-1)) {
      vars.repayAmount = vars.accountBorrows;
    } else {
      vars.repayAmount = repayAmount;
    }

     
     
     

     
    vars.actualRepayAmount = doTransferIn(payer, vars.repayAmount);

     
    (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, vars.actualRepayAmount);
    require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED");

    (vars.mathErr, vars.totalBorrowsNew) = subUInt(totalBorrows, vars.actualRepayAmount);
    require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED");

     
    accountBorrows[borrower].principal = vars.accountBorrowsNew;
    accountBorrows[borrower].interestIndex = borrowIndex;
    totalBorrows = vars.totalBorrowsNew;

     
    emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

    return (uint256(Error.NO_ERROR), vars.actualRepayAmount);
  }

   
  function liquidateBorrowInternal(
    address borrower,
    uint256 repayAmount,
    CTokenInterface cTokenCollateral
  ) internal nonReentrant returns (uint256, uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED), 0);
    }

    error = cTokenCollateral.accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED), 0);
    }

     
    return liquidateBorrowFresh(msg.sender, borrower, repayAmount, cTokenCollateral);
  }

   
  function liquidateBorrowFresh(
    address liquidator,
    address borrower,
    uint256 repayAmount,
    CTokenInterface cTokenCollateral
  ) internal whenNotTriggered returns (uint256, uint256) {
     
    uint256 allowed =
      comptroller.liquidateBorrowAllowed(address(this), address(cTokenCollateral), liquidator, borrower, repayAmount);
    if (allowed != 0) {
      return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_COMPTROLLER_REJECTION, allowed), 0);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_FRESHNESS_CHECK), 0);
    }

     
    if (cTokenCollateral.accrualBlockNumber() != getBlockNumber()) {
      return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_COLLATERAL_FRESHNESS_CHECK), 0);
    }

     
    if (borrower == liquidator) {
      return (fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_LIQUIDATOR_IS_BORROWER), 0);
    }

     
    if (repayAmount == 0) {
      return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_ZERO), 0);
    }

     
    if (repayAmount == uint256(-1)) {
      return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX), 0);
    }

     
    (uint256 repayBorrowError, uint256 actualRepayAmount) = repayBorrowFresh(liquidator, borrower, repayAmount);
    if (repayBorrowError != uint256(Error.NO_ERROR)) {
      return (fail(Error(repayBorrowError), FailureInfo.LIQUIDATE_REPAY_BORROW_FRESH_FAILED), 0);
    }

     
     
     

     
    (uint256 amountSeizeError, uint256 seizeTokens) =
      comptroller.liquidateCalculateSeizeTokens(address(this), address(cTokenCollateral), actualRepayAmount);
    require(amountSeizeError == uint256(Error.NO_ERROR), "LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED");

     
    require(cTokenCollateral.balanceOf(borrower) >= seizeTokens, "LIQUIDATE_SEIZE_TOO_MUCH");

     
    uint256 seizeError;
    if (address(cTokenCollateral) == address(this)) {
      seizeError = seizeInternal(address(this), liquidator, borrower, seizeTokens);
    } else {
      seizeError = cTokenCollateral.seize(liquidator, borrower, seizeTokens);
    }

     
    require(seizeError == uint256(Error.NO_ERROR), "token seizure failed");

     
    emit LiquidateBorrow(liquidator, borrower, actualRepayAmount, address(cTokenCollateral), seizeTokens);

    return (uint256(Error.NO_ERROR), actualRepayAmount);
  }

   
  function seize(
    address liquidator,
    address borrower,
    uint256 seizeTokens
  ) external nonReentrant returns (uint256) {
    return seizeInternal(msg.sender, liquidator, borrower, seizeTokens);
  }

   
  function seizeInternal(
    address seizerToken,
    address liquidator,
    address borrower,
    uint256 seizeTokens
  ) internal returns (uint256) {
     
    uint256 allowed = comptroller.seizeAllowed(address(this), seizerToken, liquidator, borrower, seizeTokens);
    if (allowed != 0) {
      return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, allowed);
    }

     
    if (borrower == liquidator) {
      return fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER);
    }

    MathError mathErr;
    uint256 borrowerTokensNew;
    uint256 liquidatorTokensNew;

     
    (mathErr, borrowerTokensNew) = subUInt(accountTokens[borrower], seizeTokens);
    if (mathErr != MathError.NO_ERROR) {
      return failOpaque(Error.MATH_ERROR, FailureInfo.LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED, uint256(mathErr));
    }

    (mathErr, liquidatorTokensNew) = addUInt(accountTokens[liquidator], seizeTokens);
    if (mathErr != MathError.NO_ERROR) {
      return failOpaque(Error.MATH_ERROR, FailureInfo.LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED, uint256(mathErr));
    }

     
     
     

     
    accountTokens[borrower] = borrowerTokensNew;
    accountTokens[liquidator] = liquidatorTokensNew;

     
    emit Transfer(borrower, liquidator, seizeTokens);

    return uint256(Error.NO_ERROR);
  }

   
  function checkAndToggleTrigger() external whenNotTriggered returns (bool) {
    borrowInternal(0);  
    return isTriggered;
  }

   
  function checkAndToggleTriggerInternal() internal returns (bool) {
     
    if (trigger == address(0)) return false;

     
    isTriggered = TriggerInterface(trigger).checkAndToggleTrigger();

    if (isTriggered) {
       
      totalBorrows = 0;
      emit TriggerSet(isTriggered);

       
      comptroller._zeroOutCozySpeeds(address(this));
    }
    return isTriggered;
  }

   

   
  function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256) {
     
    if (msg.sender != admin) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
    }
    emit NewPendingAdmin(pendingAdmin, newPendingAdmin);

     
    pendingAdmin = newPendingAdmin;

    return uint256(Error.NO_ERROR);
  }

   
  function _acceptAdmin() external returns (uint256) {
     
    if (msg.sender != pendingAdmin || msg.sender == address(0)) {
      return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
    }

     
    address oldAdmin = admin;
    address oldPendingAdmin = pendingAdmin;

     
    admin = pendingAdmin;

     
    pendingAdmin = address(0);

    emit NewAdmin(oldAdmin, admin);
    emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

    return uint256(Error.NO_ERROR);
  }

   
  function _setReserveFactor(uint256 newReserveFactorMantissa) external nonReentrant returns (uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return fail(Error(error), FailureInfo.SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED);
    }
     
    return _setReserveFactorFresh(newReserveFactorMantissa);
  }

   
  function _setReserveFactorFresh(uint256 newReserveFactorMantissa) internal returns (uint256) {
     
    if (msg.sender != admin) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_RESERVE_FACTOR_ADMIN_CHECK);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_RESERVE_FACTOR_FRESH_CHECK);
    }

     
    if (newReserveFactorMantissa > reserveFactorMaxMantissa) {
      return fail(Error.BAD_INPUT, FailureInfo.SET_RESERVE_FACTOR_BOUNDS_CHECK);
    }

    emit NewReserveFactor(reserveFactorMantissa, newReserveFactorMantissa);
    reserveFactorMantissa = newReserveFactorMantissa;

    return uint256(Error.NO_ERROR);
  }

   
  function _addReservesInternal(uint256 addAmount) internal nonReentrant returns (uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return fail(Error(error), FailureInfo.ADD_RESERVES_ACCRUE_INTEREST_FAILED);
    }

     
    (error, ) = _addReservesFresh(addAmount);
    return error;
  }

   
  function _addReservesFresh(uint256 addAmount) internal returns (uint256, uint256) {
     
    uint256 totalReservesNew;
    uint256 actualAddAmount;

     
    if (accrualBlockNumber != getBlockNumber()) {
      return (fail(Error.MARKET_NOT_FRESH, FailureInfo.ADD_RESERVES_FRESH_CHECK), actualAddAmount);
    }

     
     
     

     

    actualAddAmount = doTransferIn(msg.sender, addAmount);

    totalReservesNew = totalReserves + actualAddAmount;

     
    require(totalReservesNew >= totalReserves, "add reserves overflow");

     
    totalReserves = totalReservesNew;

     
    emit ReservesAdded(msg.sender, actualAddAmount, totalReservesNew);

     
    return (uint256(Error.NO_ERROR), actualAddAmount);
  }

   
  function _reduceReserves(uint256 reduceAmount) external nonReentrant returns (uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return fail(Error(error), FailureInfo.REDUCE_RESERVES_ACCRUE_INTEREST_FAILED);
    }
     
    return _reduceReservesFresh(reduceAmount);
  }

   
  function _reduceReservesFresh(uint256 reduceAmount) internal returns (uint256) {
     
    uint256 totalReservesNew;

     
    if (msg.sender != comptroller.reserveGuardian() && msg.sender != admin) {
      return fail(Error.UNAUTHORIZED, FailureInfo.REDUCE_RESERVES_ADMIN_CHECK);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDUCE_RESERVES_FRESH_CHECK);
    }

     
    if (getCashPrior() < reduceAmount) {
      return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDUCE_RESERVES_CASH_NOT_AVAILABLE);
    }

     
    if (reduceAmount > totalReserves) {
      return fail(Error.BAD_INPUT, FailureInfo.REDUCE_RESERVES_VALIDATION);
    }

     
    if (comptroller.reserveGuardian() == address(0)) {
      return fail(Error.INVALID_GUARDIAN, FailureInfo.REDUCE_RESERVES_GUARDIAN_NOT_SET);
    }

     
     
     

    totalReservesNew = totalReserves - reduceAmount;
     
    require(totalReservesNew <= totalReserves, "reduce reserves underflow");

     
    totalReserves = totalReservesNew;

     
    doTransferOut(comptroller.reserveGuardian(), reduceAmount);

    emit ReservesReduced(comptroller.reserveGuardian(), reduceAmount, totalReservesNew);

    return uint256(Error.NO_ERROR);
  }

   
  function _setInterestRateModel(InterestRateModel newInterestRateModel) external returns (uint256) {
    uint256 error = accrueInterest();
    if (error != uint256(Error.NO_ERROR)) {
       
      return fail(Error(error), FailureInfo.SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED);
    }
     
    return _setInterestRateModelFresh(newInterestRateModel);
  }

   
  function _setInterestRateModelFresh(InterestRateModel newInterestRateModel) internal returns (uint256) {
     
    if (msg.sender != admin) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_INTEREST_RATE_MODEL_OWNER_CHECK);
    }

     
    if (accrualBlockNumber != getBlockNumber()) {
      return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_INTEREST_RATE_MODEL_FRESH_CHECK);
    }

     
    require(newInterestRateModel.isInterestRateModel(), "marker method returned false");

     
    emit NewMarketInterestRateModel(interestRateModel, newInterestRateModel);
    interestRateModel = newInterestRateModel;

    return uint256(Error.NO_ERROR);
  }

   

   
  function getCashPrior() internal view returns (uint256);

   
  function doTransferIn(address from, uint256 amount) internal returns (uint256);

   
  function doTransferOut(address payable to, uint256 amount) internal;

   

   
  modifier nonReentrant() {
    require(_notEntered, "re-entered");
    _notEntered = false;
    _;
    _notEntered = true;  
  }

   
  modifier whenNotTriggered() {
    require(!isTriggered, "Not allowed once triggered");
    _;
  }
}

contract CErc20Storage {}

contract CErc20Interface is CErc20Storage {
   

  function mint(uint256 mintAmount) external returns (uint256);

  function redeem(uint256 redeemTokens) external returns (uint256);

  function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

  function borrow(uint256 borrowAmount) external returns (uint256);

  function repayBorrow(uint256 repayAmount) external returns (uint256);

  function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

  function liquidateBorrow(
    address borrower,
    uint256 repayAmount,
    CTokenInterface cTokenCollateral
  ) external returns (uint256);

   

  function _addReserves(uint256 addAmount) external returns (uint256);
}

contract ProtectionMarketFactoryErrorReporter {
  enum Error {NO_ERROR, UNAUTHORIZED, INTEREST_RATE_MODEL_ERROR}

  enum FailureInfo {SET_DEFAULT_INTEREST_RATE_MODEL_OWNER_CHECK, SET_DEFAULT_INTEREST_RATE_MODEL_VALIDITY_CHECK}

   
  event Failure(uint256 error, uint256 info, uint256 detail);

   
  function fail(Error err, FailureInfo info) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), 0);

    return uint256(err);
  }

   
  function failOpaque(
    Error err,
    FailureInfo info,
    uint256 opaqueError
  ) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), opaqueError);

    return uint256(err);
  }
}

pragma solidity 0.5.17;



 
contract CErc20 is CToken, CErc20Interface {
   
  function initialize(
    address underlying_,
    ComptrollerInterface comptroller_,
    InterestRateModel interestRateModel_,
    uint256 initialExchangeRateMantissa_,
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    address trigger_
  ) public {
     
    super.initialize(
      comptroller_,
      interestRateModel_,
      initialExchangeRateMantissa_,
      name_,
      symbol_,
      decimals_,
      trigger_
    );

     
    underlying = underlying_;
    EIP20Interface(underlying).totalSupply();
  }

   

   
  function mint(uint256 mintAmount) external returns (uint256) {
    (uint256 err, ) = mintInternal(mintAmount);
    return err;
  }

   
  function redeem(uint256 redeemTokens) external returns (uint256) {
    return redeemInternal(redeemTokens);
  }

   
  function redeemUnderlying(uint256 redeemAmount) external returns (uint256) {
    return redeemUnderlyingInternal(redeemAmount);
  }

   
  function borrow(uint256 borrowAmount) external returns (uint256) {
    return borrowInternal(borrowAmount);
  }

   
  function repayBorrow(uint256 repayAmount) external returns (uint256) {
    (uint256 err, ) = repayBorrowInternal(repayAmount);
    return err;
  }

   
  function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256) {
    (uint256 err, ) = repayBorrowBehalfInternal(borrower, repayAmount);
    return err;
  }

   
  function liquidateBorrow(
    address borrower,
    uint256 repayAmount,
    CTokenInterface cTokenCollateral
  ) external returns (uint256) {
    (uint256 err, ) = liquidateBorrowInternal(borrower, repayAmount, cTokenCollateral);
    return err;
  }

   
  function _addReserves(uint256 addAmount) external returns (uint256) {
    return _addReservesInternal(addAmount);
  }

   

   
  function getCashPrior() internal view returns (uint256) {
    EIP20Interface token = EIP20Interface(underlying);
    return token.balanceOf(address(this));
  }

   
  function doTransferIn(address from, uint256 amount) internal returns (uint256) {
    EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
    uint256 balanceBefore = EIP20Interface(underlying).balanceOf(address(this));
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

     
    uint256 balanceAfter = EIP20Interface(underlying).balanceOf(address(this));
    require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
    return balanceAfter - balanceBefore;  
  }

   
  function doTransferOut(address payable to, uint256 amount) internal {
    EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
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

contract CDelegationStorage {
   
  address public implementation;
}
pragma solidity 0.5.17;








 
interface ComptrollerAdmin {
  function admin() external view returns (address);
}

 
contract ProtectionMarketFactory is ProtectionMarketFactoryErrorReporter {
  
  ComptrollerInterface public comptroller;

  
  CEtherFactory public cEtherFactory;

  
  CErc20Factory public cErc20Factory;

  
  mapping(address => uint256) public tokenIndices;

  
  InterestRateModel public defaultInterestRateModel;

  
  address internal constant ethUnderlyingAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  
  uint8 internal constant decimals = 8;

  
  string internal constant tokenSymbolPrefix = "Cozy";

  
  string internal constant tokenSymbolSeparator = "-";

  
  bool public constant isProtectionMarketFactory = true;

  
  event NewDefaultInterestRateModel(InterestRateModel oldModel, InterestRateModel newModel);

   
  constructor(
    CEtherFactory cEtherFactory_,
    CErc20Factory cErc20Factory_,
    ComptrollerInterface comptroller_,
    InterestRateModel defaultInterestRateModel_
  ) public {
    cEtherFactory = cEtherFactory_;
    cErc20Factory = cErc20Factory_;
    comptroller = comptroller_;
    require(_setDefaultInterestRateModel(defaultInterestRateModel_) == 0, "Set interest rate model failed");
  }

   
  function deployProtectionMarket(
    address _underlying,
    ComptrollerInterface _comptroller,
    address payable _admin,
    TriggerInterface _trigger,
    address interestRateModel_
  ) external returns (address) {
    require(msg.sender == address(_comptroller), "Caller not authorized");

     
    (string memory symbol, string memory name) = createTokenSymbolAndName(_trigger, _underlying);
    uint256 initialExchangeRateMantissa;
    {
       
      uint256 underlyingDecimals = _underlying == ethUnderlyingAddress ? 18 : EIP20Interface(_underlying).decimals();
      uint256 scale = 18 + underlyingDecimals - decimals;
      initialExchangeRateMantissa = 2 * 10**(scale - 2);  
    }

     
    if (_underlying == ethUnderlyingAddress) {
      return
        cEtherFactory.deployCEther(
          _comptroller,
          getInterestRateModel(interestRateModel_),  
          initialExchangeRateMantissa,
          name,
          symbol,
          decimals,
          _admin,
          address(_trigger)
        );
    } else {
      return
        cErc20Factory.deployCErc20(
          _underlying,
          _comptroller,
          getInterestRateModel(interestRateModel_),  
          initialExchangeRateMantissa,
          name,
          symbol,
          decimals,
          _admin,
          address(_trigger)
        );
    }
  }

   
  function getInterestRateModel(address _interestRateModel) internal returns (InterestRateModel) {
    return _interestRateModel == address(0) ? defaultInterestRateModel : InterestRateModel(_interestRateModel);
  }

   
  function createTokenSymbolAndName(TriggerInterface _trigger, address _underlying)
    internal
    returns (string memory symbol, string memory name)
  {
     
    uint256 nextIndex = tokenIndices[_underlying] + 1;
    string memory indexString = Strings.toString(nextIndex);

     
    tokenIndices[_underlying] = nextIndex;

     
    string memory underlyingSymbol;
    if (_underlying == ethUnderlyingAddress) {
      underlyingSymbol = "ETH";
    } else {
      EIP20Interface underlyingToken = EIP20Interface(_underlying);
      underlyingSymbol = underlyingToken.symbol();
    }

     
    string memory tokenSymbol =
      string(
        abi.encodePacked(tokenSymbolPrefix, tokenSymbolSeparator, underlyingSymbol, tokenSymbolSeparator, indexString)
      );

     
    string memory tokenName = string(abi.encodePacked(tokenSymbol, tokenSymbolSeparator, _trigger.name()));

    return (tokenSymbol, tokenName);
  }

   
  function _setDefaultInterestRateModel(InterestRateModel _newModel) public returns (uint256) {
     
    if (msg.sender != ComptrollerAdmin(address(comptroller)).admin()) {
      return fail(Error.UNAUTHORIZED, FailureInfo.SET_DEFAULT_INTEREST_RATE_MODEL_OWNER_CHECK);
    }

     
    if (!_newModel.isInterestRateModel()) {
      return fail(Error.INTEREST_RATE_MODEL_ERROR, FailureInfo.SET_DEFAULT_INTEREST_RATE_MODEL_VALIDITY_CHECK);
    }

     
    emit NewDefaultInterestRateModel(defaultInterestRateModel, _newModel);

     
    defaultInterestRateModel = _newModel;

    return uint256(Error.NO_ERROR);
  }
}

 
contract CEtherFactory {
   
  function deployCEther(
    ComptrollerInterface comptroller,
    InterestRateModel interestRateModel,
    uint256 initialExchangeRateMantissa,
    string calldata name,
    string calldata symbol,
    uint8 decimals,
    address payable admin,
    address trigger
  ) external returns (address) {
    CEther cToken =
      new CEther(comptroller, interestRateModel, initialExchangeRateMantissa, name, symbol, decimals, admin, trigger);

    return address(cToken);
  }
}

 
contract CErc20Factory {
   
  function deployCErc20(
    address underlying,
    ComptrollerInterface comptroller,
    InterestRateModel interestRateModel,
    uint256 initialExchangeRateMantissa,
    string calldata name,
    string calldata symbol,
    uint8 decimals,
    address payable admin,
    address trigger
  ) external returns (address) {
    CErc20Immutable cToken =
      new CErc20Immutable(
        underlying,
        comptroller,
        interestRateModel,
        initialExchangeRateMantissa,
        name,
        symbol,
        decimals,
        admin,
        trigger
      );

    return address(cToken);
  }
}

pragma solidity 0.5.17;



 
contract CErc20Immutable is CErc20 {
   
  constructor(
    address underlying_,
    ComptrollerInterface comptroller_,
    InterestRateModel interestRateModel_,
    uint256 initialExchangeRateMantissa_,
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    address payable admin_,
    address trigger_
  ) public {
     
    admin = msg.sender;

     
    initialize(
      underlying_,
      comptroller_,
      interestRateModel_,
      initialExchangeRateMantissa_,
      name_,
      symbol_,
      decimals_,
      trigger_
    );

     
    admin = admin_;
  }
}

pragma solidity 0.5.17;



 
contract CEther is CToken {
   
  constructor(
    ComptrollerInterface comptroller_,
    InterestRateModel interestRateModel_,
    uint256 initialExchangeRateMantissa_,
    string memory name_,
    string memory symbol_,
    uint8 decimals_,
    address payable admin_,
    address trigger_
  ) public {
     
    admin = msg.sender;

    initialize(comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_, trigger_);

     
    admin = admin_;

     
    underlying = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  }

   

   
  function mint() external payable {
    (uint256 err, ) = mintInternal(msg.value);
    requireNoError(err, "mint failed");
  }

   
  function redeem(uint256 redeemTokens) external returns (uint256) {
    return redeemInternal(redeemTokens);
  }

   
  function redeemUnderlying(uint256 redeemAmount) external returns (uint256) {
    return redeemUnderlyingInternal(redeemAmount);
  }

   
  function borrow(uint256 borrowAmount) external returns (uint256) {
    return borrowInternal(borrowAmount);
  }

   
  function repayBorrow() external payable {
    (uint256 err, ) = repayBorrowInternal(msg.value);
    requireNoError(err, "repayBorrow failed");
  }

   
  function repayBorrowBehalf(address borrower) external payable {
    (uint256 err, ) = repayBorrowBehalfInternal(borrower, msg.value);
    requireNoError(err, "repayBorrowBehalf failed");
  }

   
  function liquidateBorrow(address borrower, CToken cTokenCollateral) external payable {
    (uint256 err, ) = liquidateBorrowInternal(borrower, msg.value, cTokenCollateral);
    requireNoError(err, "liquidateBorrow failed");
  }

   
  function() external payable {
    (uint256 err, ) = mintInternal(msg.value);
    requireNoError(err, "mint failed");
  }

   

   
  function getCashPrior() internal view returns (uint256) {
    (MathError err, uint256 startingBalance) = subUInt(address(this).balance, msg.value);
    require(err == MathError.NO_ERROR);
    return startingBalance;
  }

   
  function doTransferIn(address from, uint256 amount) internal returns (uint256) {
     
    require(msg.sender == from, "sender mismatch");
    require(msg.value == amount, "value mismatch");
    return amount;
  }

  function doTransferOut(address payable to, uint256 amount) internal {
     
    to.transfer(amount);
  }

  function requireNoError(uint256 errCode, string memory message) internal pure {
    if (errCode == uint256(Error.NO_ERROR)) {
      return;
    }

    bytes memory fullMessage = new bytes(bytes(message).length + 5);
    uint256 i;

    for (i = 0; i < bytes(message).length; i++) {
      fullMessage[i] = bytes(message)[i];
    }

    fullMessage[i + 0] = bytes1(uint8(32));
    fullMessage[i + 1] = bytes1(uint8(40));
    fullMessage[i + 2] = bytes1(uint8(48 + (errCode / 10)));
    fullMessage[i + 3] = bytes1(uint8(48 + (errCode % 10)));
    fullMessage[i + 4] = bytes1(uint8(41));

    require(errCode == uint256(Error.NO_ERROR), string(fullMessage));
  }
}

pragma solidity 0.5.17;

contract ComptrollerErrorReporter {
  enum Error {
    NO_ERROR,
    UNAUTHORIZED,
    COMPTROLLER_MISMATCH,
    INSUFFICIENT_SHORTFALL,
    INSUFFICIENT_LIQUIDITY,
    INVALID_CLOSE_FACTOR,
    INVALID_COLLATERAL_FACTOR,
    INVALID_LIQUIDATION_INCENTIVE,
    MARKET_NOT_ENTERED,  
    MARKET_NOT_LISTED,
    MARKET_ALREADY_LISTED,
    MATH_ERROR,
    NONZERO_BORROW_BALANCE,
    PRICE_ERROR,
    REJECTION,
    SNAPSHOT_ERROR,
    TOO_MANY_ASSETS,
    TOO_MUCH_REPAY,
    INVALID_TRIGGER,
    PROTECTION_MARKET_FACTORY_ERROR
  }

  enum FailureInfo {
    ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
    ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
    EXIT_MARKET_BALANCE_OWED,
    EXIT_MARKET_REJECTION,
    SET_CLOSE_FACTOR_OWNER_CHECK,
    SET_CLOSE_FACTOR_VALIDATION,
    SET_COLLATERAL_FACTOR_OWNER_CHECK,
    SET_COLLATERAL_FACTOR_NO_EXISTS,
    SET_COLLATERAL_FACTOR_VALIDATION,
    SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
    SET_IMPLEMENTATION_OWNER_CHECK,
    SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
    SET_LIQUIDATION_INCENTIVE_VALIDATION,
    SET_MAX_ASSETS_OWNER_CHECK,
    SET_PENDING_ADMIN_OWNER_CHECK,
    SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
    SET_PRICE_ORACLE_OWNER_CHECK,
    SUPPORT_MARKET_EXISTS,
    SUPPORT_MARKET_OWNER_CHECK,
    SET_PAUSE_GUARDIAN_OWNER_CHECK,
    SET_TRIGGER_CHECK,
    SET_PROTECTION_WITH_INVALID_UNDERLYING,
    SET_PROTECTION_UNDERLYING_WITHOUT_PRICE,
    SET_PROTECTION_MARKET_FACTORY_OWNER_CHECK,
    SET_PROTECTION_MARKET_FACTORY_VALIDITY_CHECK,
    SET_RESERVE_GUARDIAN_OWNER_CHECK
  }

   
  event Failure(uint256 error, uint256 info, uint256 detail);

   
  function fail(Error err, FailureInfo info) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), 0);

    return uint256(err);
  }

   
  function failOpaque(
    Error err,
    FailureInfo info,
    uint256 opaqueError
  ) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), opaqueError);

    return uint256(err);
  }
}

contract OracleErrorReporter {
  enum Error {NO_ERROR, UNAUTHORIZED}

  enum FailureInfo {ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ADD_OR_UPDATE_ORACLES_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK}

   
  event Failure(uint256 error, uint256 info, uint256 detail);

   
  function fail(Error err, FailureInfo info) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), 0);

    return uint256(err);
  }

   
  function failOpaque(
    Error err,
    FailureInfo info,
    uint256 opaqueError
  ) internal returns (uint256) {
    emit Failure(uint256(err), uint256(info), opaqueError);

    return uint256(err);
  }
}

pragma solidity 0.5.17;

 
interface EIP20Interface {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

   
  function totalSupply() external view returns (uint256);

   
  function balanceOf(address owner) external view returns (uint256 balance);

   
  function transfer(address dst, uint256 amount) external returns (bool success);

   
  function transferFrom(
    address src,
    address dst,
    uint256 amount
  ) external returns (bool success);

   
  function approve(address spender, uint256 amount) external returns (bool success);

   
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  event Transfer(address indexed from, address indexed to, uint256 amount);
  event Approval(address indexed owner, address indexed spender, uint256 amount);
}

 
pragma solidity 0.5.17;

 
library Strings {
   
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
    uint256 index = digits - 1;
    temp = value;
    while (temp != 0) {
      buffer[index--] = bytes1(uint8(48 + (temp % 10)));
      temp /= 10;
    }
    return string(buffer);
  }
}

 
pragma solidity 0.5.17;

 
contract TriggerInterface {
  
  function name() external view returns (string memory);

  
  function symbol() external view returns (string memory);

  
  function description() external view returns (string memory);

  
  
  function getPlatformIds() external view returns (uint256[] memory);

  
  function recipient() external view returns (address);

  
  function isTriggered() external view returns (bool);

  
  function checkAndToggleTrigger() external returns (bool);
}

pragma solidity 0.5.17;

 
contract ComptrollerInterface {
  
  bool public constant isComptroller = true;

  
  address payable public reserveGuardian;

   

  function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

  function exitMarket(address cToken) external returns (uint256);

   

  function mintAllowed(
    address cToken,
    address minter,
    uint256 mintAmount
  ) external returns (uint256);

  function redeemAllowed(
    address cToken,
    address redeemer,
    uint256 redeemTokens
  ) external returns (uint256);

  function borrowAllowed(
    address cToken,
    address borrower,
    uint256 borrowAmount
  ) external returns (uint256);

  function repayBorrowAllowed(
    address cToken,
    address payer,
    address borrower,
    uint256 repayAmount
  ) external returns (uint256);

  function liquidateBorrowAllowed(
    address cTokenBorrowed,
    address cTokenCollateral,
    address liquidator,
    address borrower,
    uint256 repayAmount
  ) external returns (uint256);

  function seizeAllowed(
    address cTokenCollateral,
    address cTokenBorrowed,
    address liquidator,
    address borrower,
    uint256 seizeTokens
  ) external returns (uint256);

  function transferAllowed(
    address cToken,
    address src,
    address dst,
    uint256 transferTokens
  ) external returns (uint256);

   

  function liquidateCalculateSeizeTokens(
    address cTokenBorrowed,
    address cTokenCollateral,
    uint256 repayAmount
  ) external view returns (uint256, uint256);

   

  
  function _zeroOutCozySpeeds(address cToken) external;
}

contract CDelegatorInterface is CDelegationStorage {
   
  event NewImplementation(address oldImplementation, address newImplementation);

   
  function _setImplementation(
    address implementation_,
    bool allowResign,
    bytes memory becomeImplementationData
  ) public;
}

contract CDelegateInterface is CDelegationStorage {
   
  function _becomeImplementation(bytes memory data) public;

   
  function _resignImplementation() public;
}

pragma solidity 0.5.17;

 
interface EIP20NonStandardInterface {
   
  function totalSupply() external view returns (uint256);

   
  function balanceOf(address owner) external view returns (uint256 balance);

   
   
   
   
   

   
  function transfer(address dst, uint256 amount) external;

   
   
   
   
   

   
  function transferFrom(
    address src,
    address dst,
    uint256 amount
  ) external;

   
  function approve(address spender, uint256 amount) external returns (bool success);

   
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  event Transfer(address indexed from, address indexed to, uint256 amount);
  event Approval(address indexed owner, address indexed spender, uint256 amount);
}

pragma solidity 0.5.17;

 
contract InterestRateModel {
  
  bool public constant isInterestRateModel = true;

   
  function getBorrowRate(
    uint256 cash,
    uint256 borrows,
    uint256 reserves
  ) external view returns (uint256);

   
  function getSupplyRate(
    uint256 cash,
    uint256 borrows,
    uint256 reserves,
    uint256 reserveFactorMantissa
  ) external view returns (uint256);
}
