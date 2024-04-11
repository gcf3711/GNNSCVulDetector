 
pragma experimental ABIEncoderV2;

 

 

 

 

pragma solidity ^0.6.12;


interface IPowerPoke {
   
  function authorizeReporter(uint256 userId_, address pokerKey_) external view;

  function authorizeNonReporter(uint256 userId_, address pokerKey_) external view;

  function authorizeNonReporterWithDeposit(
    uint256 userId_,
    address pokerKey_,
    uint256 overrideMinDeposit_
  ) external view;

  function authorizePoker(uint256 userId_, address pokerKey_) external view;

  function authorizePokerWithDeposit(
    uint256 userId_,
    address pokerKey_,
    uint256 overrideMinStake_
  ) external view;

  function slashReporter(uint256 slasherId_, uint256 times_) external;

  function reward(
    uint256 userId_,
    uint256 gasUsed_,
    uint256 compensationPlan_,
    bytes calldata pokeOptions_
  ) external;

   
  function transferClientOwnership(address client_, address to_) external;

  function addCredit(address client_, uint256 amount_) external;

  function withdrawCredit(
    address client_,
    address to_,
    uint256 amount_
  ) external;

  function setReportIntervals(
    address client_,
    uint256 minReportInterval_,
    uint256 maxReportInterval_
  ) external;

  function setSlasherHeartbeat(address client_, uint256 slasherHeartbeat_) external;

  function setGasPriceLimit(address client_, uint256 gasPriceLimit_) external;

  function setFixedCompensations(
    address client_,
    uint256 eth_,
    uint256 cvp_
  ) external;

  function setBonusPlan(
    address client_,
    uint256 planId_,
    bool active_,
    uint64 bonusNominator_,
    uint64 bonusDenominator_,
    uint64 perGas_
  ) external;

  function setMinimalDeposit(address client_, uint256 defaultMinDeposit_) external;

   
  function withdrawRewards(uint256 userId_, address to_) external;

  function setPokerKeyRewardWithdrawAllowance(uint256 userId_, bool allow_) external;

   
  function addClient(
    address client_,
    address owner_,
    bool canSlash_,
    uint256 gasPriceLimit_,
    uint256 minReportInterval_,
    uint256 maxReportInterval_
  ) external;

  function setClientActiveFlag(address client_, bool active_) external;

  function setCanSlashFlag(address client_, bool canSlash) external;

  function setOracle(address oracle_) external;

  function pause() external;

  function unpause() external;

   
  function creditOf(address client_) external view returns (uint256);

  function ownerOf(address client_) external view returns (address);

  function getMinMaxReportIntervals(address client_) external view returns (uint256 min, uint256 max);

  function getSlasherHeartbeat(address client_) external view returns (uint256);

  function getGasPriceLimit(address client_) external view returns (uint256);

  function getPokerBonus(
    address client_,
    uint256 bonusPlanId_,
    uint256 gasUsed_,
    uint256 userDeposit_
  ) external view returns (uint256);

  function getGasPriceFor(address client_) external view returns (uint256);
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

 

pragma solidity ^0.6.0;

interface IYearnVaultV2 {
  function token() external view returns (address);

  function totalAssets() external view returns (uint256);

  function pricePerShare() external view returns (uint256);

  function deposit(uint256 amount) external;

  function deposit(uint256 amount, address recipient) external;

  function withdraw(uint256 maxShares) external;

  function withdraw(uint256 maxShares, address recipient) external;

  function withdraw(
    uint256 maxShares,
    address recipient,
    uint256 maxLoss
  ) external;

  function report(
    uint256 gain,
    uint256 loss,
    uint256 debtPayment
  ) external returns (uint256);
}

 

pragma solidity 0.6.12;

interface PowerIndexPoolControllerInterface {
  function rebindByStrategyAdd(
    address token,
    uint256 balance,
    uint256 denorm,
    uint256 deposit
  ) external;

  function rebindByStrategyRemove(
    address token,
    uint256 balance,
    uint256 denorm
  ) external;

  function bindByStrategy(
    address token,
    uint256 balance,
    uint256 denorm
  ) external;

  function unbindByStrategy(address token) external;
}

 

pragma solidity 0.6.12;

interface ICurveDepositor {
  function calc_withdraw_one_coin(uint256 _tokenAmount, int128 _index) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 _i,
    uint256 _min_amount
  ) external;
}

 

pragma solidity 0.6.12;

interface ICurveDepositor2 {
  function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external;

  function calc_token_amount(uint256[2] memory _amounts, bool _deposit) external view returns (uint256);
}

 

pragma solidity 0.6.12;

interface ICurveDepositor3 {
  function add_liquidity(uint256[3] memory _amounts, uint256 _min_mint_amount) external;

  function calc_token_amount(uint256[3] memory _amounts, bool _deposit) external view returns (uint256);
}

 

pragma solidity 0.6.12;

interface ICurveDepositor4 {
  function add_liquidity(uint256[4] memory _amounts, uint256 _min_mint_amount) external;

  function calc_token_amount(uint256[4] memory _amounts, bool _deposit) external view returns (uint256);
}

 

pragma solidity 0.6.12;

interface ICurveZapDepositor {
  function calc_withdraw_one_coin(
    address _pool,
    uint256 _tokenAmount,
    int128 _index
  ) external view returns (uint256);

  function remove_liquidity_one_coin(
    address _pool,
    uint256 _token_amount,
    int128 _i,
    uint256 _min_amount
  ) external;
}

 

pragma solidity 0.6.12;

interface ICurveZapDepositor2 {
  function add_liquidity(
    address _pool,
    uint256[2] memory _amounts,
    uint256 _min_mint_amount
  ) external;

  function calc_token_amount(
    address _pool,
    uint256[2] memory _amounts,
    bool _deposit
  ) external view returns (uint256);
}

 

pragma solidity 0.6.12;

interface ICurveZapDepositor3 {
  function add_liquidity(
    address _pool,
    uint256[3] memory _amounts,
    uint256 _min_mint_amount
  ) external;

  function calc_token_amount(
    address _pool,
    uint256[3] memory _amounts,
    bool _deposit
  ) external view returns (uint256);
}

 

pragma solidity 0.6.12;

interface ICurveZapDepositor4 {
  function add_liquidity(
    address _pool,
    uint256[4] memory _amounts,
    uint256 _min_mint_amount
  ) external;

  function calc_token_amount(
    address _pool,
    uint256[4] memory _amounts,
    bool _deposit
  ) external view returns (uint256);
}

 

pragma solidity 0.6.12;

interface ICurvePoolRegistry {
  function get_virtual_price_from_lp_token(address _token) external view returns (uint256);
}

 

pragma solidity >=0.4.24 <0.7.0;

 
contract Initializable {

   
  bool private initialized;

   
  bool private initializing;

   
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
     
     
     
     
     
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

   
  uint256[50] private ______gap;
}

 

pragma solidity ^0.6.0;


 
contract ContextUpgradeSafe is Initializable {
     
     

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

 

pragma solidity ^0.6.0;


 
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

 

pragma solidity 0.6.12;

abstract contract SinglePoolManagement is OwnableUpgradeSafe {
  address public immutable pool;
  address public poolController;

  constructor(address _pool) public {
    pool = _pool;
  }

  function __SinglePoolManagement_init(address _poolController) internal {
    poolController = _poolController;
  }
}

 

 
 
 
 

 
 
 
 

 
 

pragma solidity 0.6.12;

contract BConst {
    uint public constant BONE              = 10**18;
     
    uint public constant MIN_BOUND_TOKENS  = 2;
     
    uint public constant MAX_BOUND_TOKENS  = 21;
     
    uint public constant MIN_FEE           = BONE / 10**6;
     
    uint public constant MAX_FEE           = BONE / 10;
     
    uint public constant MIN_WEIGHT        = 1000000000;
     
    uint public constant MAX_WEIGHT        = BONE * 50;
     
    uint public constant MAX_TOTAL_WEIGHT  = BONE * 50;
     
    uint public constant MIN_BALANCE       = BONE / 10**12;
     
    uint public constant INIT_POOL_SUPPLY  = BONE * 100;

    uint public constant MIN_BPOW_BASE     = 1 wei;
    uint public constant MAX_BPOW_BASE     = (2 * BONE) - 1 wei;
    uint public constant BPOW_PRECISION    = BONE / 10**10;
     
    uint public constant MAX_IN_RATIO      = BONE / 2;
     
    uint public constant MAX_OUT_RATIO     = (BONE / 3) + 1 wei;
}

 

 
 
 
 

 
 
 
 

 
 

pragma solidity 0.6.12;


contract BNum is BConst {

    function btoi(uint a)
        internal pure
        returns (uint)
    {
        return a / BONE;
    }

    function bfloor(uint a)
        internal pure
        returns (uint)
    {
        return btoi(a) * BONE;
    }

    function badd(uint a, uint b)
        internal pure
        returns (uint)
    {
        uint c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint a, uint b)
        internal pure
        returns (uint)
    {
        (uint c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint a, uint b)
        internal pure
        returns (uint, bool)
    {
        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint a, uint b)
        internal pure
        returns (uint)
    {
        uint c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint c2 = c1 / BONE;
        return c2;
    }

    function bdiv(uint a, uint b)
        internal pure
        returns (uint)
    {
        require(b != 0, "ERR_DIV_ZERO");
        uint c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL");  
        uint c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL");  
        uint c2 = c1 / b;
        return c2;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b > 0, "ERR_DIV_ZERO");
      return a / b;
    }

     
    function bpowi(uint a, uint n)
        internal pure
        returns (uint)
    {
        uint z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

     
     
     
    function bpow(uint base, uint exp)
        internal pure
        returns (uint)
    {
        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint whole  = bfloor(exp);
        uint remain = bsub(exp, whole);

        uint wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint partialResult = bpowApprox(base, remain, BPOW_PRECISION);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(uint base, uint exp, uint precision)
        internal pure
        returns (uint)
    {
         
        uint a     = exp;
        (uint x, bool xneg)  = bsubSign(base, BONE);
        uint term = BONE;
        uint sum   = term;
        bool negative = false;


         
         
         
         
        for (uint i = 1; term >= precision; i++) {
            uint bigK = i * BONE;
            (uint c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }

}

 

pragma solidity 0.6.12;

interface BMathInterface {
  function calcInGivenOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);

  function calcSingleInGivenPoolOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);
}

 

pragma solidity 0.6.12;

interface BPoolInterface is IERC20, BMathInterface {
  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;

  function swapExactAmountIn(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);

  function swapExactAmountOut(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);

  function joinswapExternAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function joinswapPoolAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function exitswapPoolAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function exitswapExternAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);

  function getDenormalizedWeight(address) external view returns (uint256);

  function getBalance(address) external view returns (uint256);

  function getSwapFee() external view returns (uint256);

  function getTotalDenormalizedWeight() external view returns (uint256);

  function getCommunityFee()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      address
    );

  function calcAmountWithCommunityFee(
    uint256,
    uint256,
    address
  ) external view returns (uint256, uint256);

  function getRestrictions() external view returns (address);

  function isSwapsDisabled() external view returns (bool);

  function isFinalized() external view returns (bool);

  function isBound(address t) external view returns (bool);

  function getCurrentTokens() external view returns (address[] memory tokens);

  function getFinalTokens() external view returns (address[] memory tokens);

  function setSwapFee(uint256) external;

  function setCommunityFeeAndReceiver(
    uint256,
    uint256,
    uint256,
    address
  ) external;

  function setController(address) external;

  function setSwapsDisabled(bool) external;

  function finalize() external;

  function bind(
    address,
    uint256,
    uint256
  ) external;

  function rebind(
    address,
    uint256,
    uint256
  ) external;

  function unbind(address) external;

  function gulp(address) external;

  function callVoting(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;

  function getMinWeight() external view returns (uint256);

  function getMaxBoundTokens() external view returns (uint256);
}

 

pragma solidity 0.6.12;

interface PowerIndexPoolInterface is BPoolInterface {
  function initialize(
    string calldata name,
    string calldata symbol,
    uint256 minWeightPerSecond,
    uint256 maxWeightPerSecond
  ) external;

  function bind(
    address,
    uint256,
    uint256,
    uint256,
    uint256
  ) external;

  function setDynamicWeight(
    address token,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) external;

  function getDynamicWeightSettings(address token)
    external
    view
    returns (
      uint256 fromTimestamp,
      uint256 targetTimestamp,
      uint256 fromDenorm,
      uint256 targetDenorm
    );

  function getMinWeight() external view override returns (uint256);

  function getWeightPerSecondBounds() external view returns (uint256, uint256);

  function setWeightPerSecondBounds(uint256, uint256) external;

  function setWrapper(address, bool) external;

  function getWrapperMode() external view returns (bool);
}

 

pragma solidity 0.6.12;

interface IPowerOracle {
  function assetPrices(address _token) external view returns (uint256);
}

 

pragma solidity 0.6.12;

abstract contract WeightValueAbstract is BNum, OwnableUpgradeSafe {
  event UpdatePoolWeights(
    address indexed pool,
    uint256 indexed timestamp,
    address[] tokens,
    uint256[3][] weightsChange,
    uint256[] newTokenValues
  );

  event SetTotalWeight(uint256 totalWeight);

  struct TokenConfigItem {
    address token;
    address[] excludeTokenBalances;
  }

  IPowerOracle public oracle;
  uint256 public totalWeight;

  function getTokenValue(PowerIndexPoolInterface _pool, address _token) public view virtual returns (uint256) {
    return getTVL(_pool, _token);
  }

  function getTVL(PowerIndexPoolInterface _pool, address _token) public view returns (uint256) {
    uint256 balance = _pool.getBalance(_token);
    return bdiv(bmul(balance, oracle.assetPrices(_token)), 1 ether);
  }

  function setTotalWeight(uint256 _totalWeight) external onlyOwner {
    totalWeight = _totalWeight;
    emit SetTotalWeight(_totalWeight);
  }

  function _computeWeightsChangeWithEvent(
    PowerIndexPoolInterface _pool,
    address[] memory _tokens,
    address[] memory _piTokens,
    uint256 _minWPS,
    uint256 fromTimestamp,
    uint256 toTimestamp
  )
    internal
    returns (
      uint256[3][] memory weightsChange,
      uint256 lenToPush,
      uint256[] memory newTokensValues
    )
  {
    (weightsChange, lenToPush, newTokensValues, ) = computeWeightsChange(
      _pool,
      _tokens,
      _piTokens,
      _minWPS,
      fromTimestamp,
      toTimestamp
    );
    emit UpdatePoolWeights(address(_pool), block.timestamp, _tokens, weightsChange, newTokensValues);
  }

  function computeWeightsChange(
    PowerIndexPoolInterface _pool,
    address[] memory _tokens,
    address[] memory _piTokens,
    uint256 _minWPS,
    uint256 fromTimestamp,
    uint256 toTimestamp
  )
    public
    view
    returns (
      uint256[3][] memory weightsChange,
      uint256 lenToPush,
      uint256[] memory newTokenValues,
      uint256 newTokenValueSum
    )
  {
    uint256 len = _tokens.length;
    newTokenValues = new uint256[](len);

    for (uint256 i = 0; i < len; i++) {
      uint256 value = getTokenValue(_pool, _tokens[i]);
      newTokenValues[i] = value;
      newTokenValueSum = badd(newTokenValueSum, value);
    }

    weightsChange = new uint256[3][](len);
    for (uint256 i = 0; i < len; i++) {
      uint256 oldWeight;
      if (_piTokens.length == _tokens.length) {
        try _pool.getDenormalizedWeight(_piTokens[i]) returns (uint256 _weight) {
          oldWeight = _weight;
        } catch {
          oldWeight = 0;
        }
      } else {
        try _pool.getDenormalizedWeight(_tokens[i]) returns (uint256 _weight) {
          oldWeight = _weight;
        } catch {
          oldWeight = 0;
        }
      }
      uint256 newWeight = bmul(bdiv(newTokenValues[i], newTokenValueSum), totalWeight);
      weightsChange[i] = [i, oldWeight, newWeight];
    }

    for (uint256 i = 0; i < len; i++) {
      uint256 wps = getWeightPerSecond(weightsChange[i][1], weightsChange[i][2], fromTimestamp, toTimestamp);
      if (wps >= _minWPS) {
        lenToPush++;
      }
    }

    if (lenToPush > 1) {
      _sort(weightsChange);
    }
  }

  function getWeightPerSecond(
    uint256 fromDenorm,
    uint256 targetDenorm,
    uint256 fromTimestamp,
    uint256 targetTimestamp
  ) public pure returns (uint256) {
    uint256 delta = targetDenorm > fromDenorm ? bsub(targetDenorm, fromDenorm) : bsub(fromDenorm, targetDenorm);
    return div(delta, bsub(targetTimestamp, fromTimestamp));
  }

  function _quickSort(
    uint256[3][] memory wightsChange,
    int256 left,
    int256 right
  ) internal pure {
    int256 i = left;
    int256 j = right;
    if (i == j) return;
    uint256[3] memory pivot = wightsChange[uint256(left + (right - left) / 2)];
    int256 pDiff = int256(pivot[2]) - int256(pivot[1]);
    while (i <= j) {
      while (int256(wightsChange[uint256(i)][2]) - int256(wightsChange[uint256(i)][1]) < pDiff) i++;
      while (pDiff < int256(wightsChange[uint256(j)][2]) - int256(wightsChange[uint256(j)][1])) j--;
      if (i <= j) {
        (wightsChange[uint256(i)], wightsChange[uint256(j)]) = (wightsChange[uint256(j)], wightsChange[uint256(i)]);
        i++;
        j--;
      }
    }
    if (left < j) _quickSort(wightsChange, left, j);
    if (i < right) _quickSort(wightsChange, i, right);
  }

  function _sort(uint256[3][] memory weightsChange) internal pure {
    _quickSort(weightsChange, int256(0), int256(weightsChange.length - 1));
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }
}

 

pragma solidity 0.6.12;

abstract contract WeightValueChangeRateAbstract is WeightValueAbstract {
  mapping(address => uint256) public lastValue;
  mapping(address => uint256) public valueChangeRate;

  bool public rateChangeDisabled;

  event UpdatePoolTokenValue(
    address indexed token,
    uint256 oldTokenValue,
    uint256 newTokenValue,
    uint256 lastChangeRate,
    uint256 newChangeRate
  );
  event SetValueChangeRate(address indexed token, uint256 oldRate, uint256 newRate);
  event SetRateChangeDisabled(bool rateChangeDisabled);

  constructor() public WeightValueAbstract() {}

  function _updatePoolByPoke(
    address _pool,
    address[] memory _tokens,
    uint256[] memory _newTokenValues
  ) internal {
    uint256 len = _tokens.length;
    for (uint256 i = 0; i < len; i++) {
      uint256 oldValue = lastValue[_tokens[i]];
      lastValue[_tokens[i]] = _newTokenValues[i];

      uint256 lastChangeRate;
      (lastChangeRate, valueChangeRate[_tokens[i]]) = getValueChangeRate(_tokens[i], oldValue, _newTokenValues[i]);

      emit UpdatePoolTokenValue(_tokens[i], oldValue, _newTokenValues[i], lastChangeRate, valueChangeRate[_tokens[i]]);
    }
  }

  function getValueChangeRate(
    address _token,
    uint256 oldTokenValue,
    uint256 newTokenValue
  ) public view returns (uint256 lastChangeRate, uint256 newChangeRate) {
    lastChangeRate = valueChangeRate[_token] == 0 ? 1 ether : valueChangeRate[_token];
    if (oldTokenValue == 0) {
      newChangeRate = lastChangeRate;
      return (lastChangeRate, newChangeRate);
    }
    newChangeRate = rateChangeDisabled ? lastChangeRate : bmul(bdiv(newTokenValue, oldTokenValue), lastChangeRate);
  }

  function getTokenValue(PowerIndexPoolInterface _pool, address _token)
    public
    view
    virtual
    override
    returns (uint256 value)
  {
    value = getTVL(_pool, _token);
    if (valueChangeRate[_token] != 0) {
      value = bmul(value, valueChangeRate[_token]);
    }
  }

  function setValueChangeRates(address[] memory _tokens, uint256[] memory _newTokenRates) public onlyOwner {
    uint256 len = _tokens.length;
    require(len == _newTokenRates.length, "LENGTHS_MISMATCH");
    for (uint256 i = 0; i < len; i++) {
      emit SetValueChangeRate(_tokens[i], valueChangeRate[_tokens[i]], _newTokenRates[i]);

      valueChangeRate[_tokens[i]] = _newTokenRates[i];
    }
  }

  function setRateUpdateDisabled(bool _disabled) public onlyOwner {
    rateChangeDisabled = _disabled;
    emit SetRateChangeDisabled(rateChangeDisabled);
  }
}

 

pragma solidity 0.6.12;

contract YearnVaultInstantRebindStrategy is SinglePoolManagement, WeightValueChangeRateAbstract {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 internal constant COMPENSATION_PLAN_1_ID = 1;

  event ChangePoolTokens(address[] poolTokensBefore, address[] poolTokensAfter);
  event InstantRebind(uint256 poolCurrentTokensCount, uint256 usdcPulled, uint256 usdcRemainder);
  event UpdatePool(address[] poolTokensBefore, address[] poolTokensAfter);
  event VaultWithdrawFee(address indexed vaultToken, uint256 crvAmount);
  event SeizeERC20(address indexed token, address indexed to, uint256 amount);
  event SetMaxWithdrawalLoss(uint256 maxWithdrawalLoss);

  event PullLiquidity(
    address indexed vaultToken,
    address crvToken,
    uint256 vaultAmount,
    uint256 crvAmountExpected,
    uint256 crvAmountActual,
    uint256 usdcAmount,
    uint256 vaultReserve
  );

  event PushLiquidity(
    address indexed vaultToken,
    address crvToken,
    uint256 vaultAmount,
    uint256 crvAmount,
    uint256 usdcAmount
  );

  event SetPoolController(address indexed poolController);

  event SetCurvePoolRegistry(address curvePoolRegistry);

  event SetVaultConfig(
    address indexed vault,
    address indexed depositor,
    uint8 depositorType,
    uint8 depositorTokenLength,
    int8 usdcIndex
  );

  event SetStrategyConstraints(uint256 minUSDCRemainder, bool useVirtualPriceEstimation);

  struct RebindConfig {
    address token;
    uint256 newWeight;
    uint256 oldBalance;
    uint256 newBalance;
  }

  struct VaultConfig {
    address depositor;
    uint8 depositorType;
    uint8 depositorTokenLength;
    int8 usdcIndex;
  }

  struct StrategyConstraints {
    uint256 minUSDCRemainder;
    bool useVirtualPriceEstimation;
  }

  struct PullDataHelper {
    address crvToken;
    uint256 yDiff;
    uint256 ycrvBalance;
    uint256 crvExpected;
    uint256 crvActual;
    uint256 usdcBefore;
    uint256 vaultReserve;
  }

  IERC20 public immutable USDC;

  IPowerPoke public powerPoke;
  ICurvePoolRegistry public curvePoolRegistry;
  uint256 public lastUpdate;
  uint256 public maxWithdrawalLoss;

  StrategyConstraints public constraints;

  address[] internal poolTokens;
  mapping(address => VaultConfig) public vaultConfig;

  modifier onlyEOA() {
    require(msg.sender == tx.origin, "ONLY_EOA");
    _;
  }

  modifier onlyReporter(uint256 _reporterId, bytes calldata _rewardOpts) {
    uint256 gasStart = gasleft();
    powerPoke.authorizeReporter(_reporterId, msg.sender);
    _;
    _reward(_reporterId, gasStart, COMPENSATION_PLAN_1_ID, _rewardOpts);
  }

  modifier onlyNonReporter(uint256 _reporterId, bytes calldata _rewardOpts) {
    uint256 gasStart = gasleft();
    powerPoke.authorizeNonReporter(_reporterId, msg.sender);
    _;
    _reward(_reporterId, gasStart, COMPENSATION_PLAN_1_ID, _rewardOpts);
  }

  constructor(address _pool, address _usdc) public SinglePoolManagement(_pool) OwnableUpgradeSafe() {
    USDC = IERC20(_usdc);
  }

  function initialize(
    address _powerPoke,
    address _curvePoolRegistry,
    address _poolController,
    uint256 _maxWithdrawalLoss,
    StrategyConstraints memory _constraints
  ) external initializer {
    __Ownable_init();

    __SinglePoolManagement_init(_poolController);

    maxWithdrawalLoss = _maxWithdrawalLoss;
    powerPoke = IPowerPoke(_powerPoke);
    curvePoolRegistry = ICurvePoolRegistry(_curvePoolRegistry);
    constraints = _constraints;
    totalWeight = 25 * BONE;
  }

   
  function getTokenValue(PowerIndexPoolInterface, address _token) public view override returns (uint256 value) {
    value = getVaultVirtualPriceEstimation(_token, IYearnVaultV2(_token).totalAssets());
    (, uint256 newValueChangeRate) = getValueChangeRate(_token, lastValue[_token], value);
    if (newValueChangeRate != 0) {
      value = bmul(value, newValueChangeRate);
    }
  }

  function getVaultVirtualPriceEstimation(address _token, uint256 _amount) public view returns (uint256) {
    return
      ICurvePoolRegistry(curvePoolRegistry).get_virtual_price_from_lp_token(IYearnVaultV2(_token).token()).mul(
        _amount
      ) / 1e18;
  }

  function getVaultUsdcEstimation(
    address _token,
    address _crvToken,
    uint256 _amount
  ) public returns (uint256) {
    VaultConfig memory vc = vaultConfig[_token];
    if (vc.depositorType == 2) {
      return ICurveZapDepositor(vc.depositor).calc_withdraw_one_coin(_crvToken, _amount, int128(vc.usdcIndex));
    } else {
      return ICurveDepositor(vc.depositor).calc_withdraw_one_coin(_amount, int128(vc.usdcIndex));
    }
  }

  function getPoolTokens() public view returns (address[] memory) {
    return poolTokens;
  }

   
  function setCurvePoolRegistry(address _curvePoolRegistry) external onlyOwner {
    curvePoolRegistry = ICurvePoolRegistry(_curvePoolRegistry);
    emit SetCurvePoolRegistry(_curvePoolRegistry);
  }

  function setVaultConfig(
    address _vault,
    address _depositor,
    uint8 _depositorType,
    uint8 _depositorTokenLength,
    int8 _usdcIndex
  ) external onlyOwner {
    vaultConfig[_vault] = VaultConfig(_depositor, _depositorType, _depositorTokenLength, _usdcIndex);
    IERC20 crvToken = IERC20(IYearnVaultV2(_vault).token());
    _checkApprove(USDC.approve(_depositor, uint256(-1)));
    _checkApprove(crvToken.approve(_vault, uint256(-1)));
    _checkApprove(crvToken.approve(_depositor, uint256(-1)));
    emit SetVaultConfig(_vault, _depositor, _depositorType, _depositorTokenLength, _usdcIndex);
  }

  function setPoolController(address _poolController) public onlyOwner {
    poolController = _poolController;
    _updatePool(poolController, _poolController);
    emit SetPoolController(_poolController);
  }

  function syncPoolTokens() external onlyOwner {
    address controller = poolController;
    _updatePool(controller, controller);
  }

  function setMaxWithdrawalLoss(uint256 _maxWithdrawalLoss) external onlyOwner {
    maxWithdrawalLoss = _maxWithdrawalLoss;
    emit SetMaxWithdrawalLoss(_maxWithdrawalLoss);
  }

  function removeApprovals(IERC20[] calldata _tokens, address[] calldata _tos) external onlyOwner {
    uint256 len = _tokens.length;

    for (uint256 i = 0; i < len; i++) {
      _checkApprove(_tokens[i].approve(_tos[i], uint256(0)));
    }
  }

  function seizeERC20(
    address[] calldata _tokens,
    address[] calldata _tos,
    uint256[] calldata _amounts
  ) external onlyOwner {
    uint256 len = _tokens.length;
    require(len == _tos.length && len == _amounts.length, "LENGTHS");

    for (uint256 i = 0; i < len; i++) {
      IERC20(_tokens[i]).safeTransfer(_tos[i], _amounts[i]);
      emit SeizeERC20(_tokens[i], _tos[i], _amounts[i]);
    }
  }

  function setStrategyConstraints(StrategyConstraints memory _constraints) external onlyOwner {
    constraints = _constraints;
    emit SetStrategyConstraints(_constraints.minUSDCRemainder, _constraints.useVirtualPriceEstimation);
  }

  function _checkApprove(bool _result) internal {
    require(_result, "APPROVE_FAILED");
  }

  function _updatePool(address _oldController, address _newController) internal {
    address[] memory poolTokensBefore = poolTokens;
    uint256 len = poolTokensBefore.length;

    if (_oldController != address(0)) {
       
      for (uint256 i = 0; i < len; i++) {
        _removeApprovalVault(poolTokensBefore[i], address(_oldController));
      }
    }

    address[] memory poolTokensAfter = PowerIndexPoolInterface(pool).getCurrentTokens();
    poolTokens = poolTokensAfter;

     
    len = poolTokensAfter.length;
    for (uint256 i = 0; i < len; i++) {
      _approveVault(poolTokensAfter[i], address(_newController));
    }

    emit UpdatePool(poolTokensBefore, poolTokensAfter);
  }

  function _approveVault(address _vaultToken, address _controller) internal {
    IERC20 vaultToken = IERC20(_vaultToken);
    _checkApprove(vaultToken.approve(pool, uint256(-1)));
    _checkApprove(vaultToken.approve(_controller, uint256(-1)));
  }

  function _removeApprovalVault(address _vaultToken, address _controller) internal {
    IERC20 vaultToken = IERC20(_vaultToken);
    _checkApprove(vaultToken.approve(pool, uint256(0)));
    _checkApprove(vaultToken.approve(_controller, uint256(0)));
  }

  function changePoolTokens(address[] memory _newTokens) external onlyOwner {
    address[] memory _currentTokens = BPoolInterface(pool).getCurrentTokens();
    uint256 cLen = _currentTokens.length;
    uint256 nLen = _newTokens.length;
    for (uint256 i = 0; i < cLen; i++) {
      bool existsInNewTokens = false;
      for (uint256 j = 0; j < nLen; j++) {
        if (_currentTokens[i] == _newTokens[j]) {
          existsInNewTokens = true;
        }
      }
      if (!existsInNewTokens) {
        PowerIndexPoolControllerInterface(poolController).unbindByStrategy(_currentTokens[i]);
        _vaultToUsdc(_currentTokens[i], IYearnVaultV2(_currentTokens[i]).token(), vaultConfig[_currentTokens[i]]);
        _removeApprovalVault(_currentTokens[i], address(poolController));
      }
    }

    for (uint256 j = 0; j < nLen; j++) {
      if (!BPoolInterface(pool).isBound(_newTokens[j])) {
        _approveVault(_newTokens[j], address(poolController));
      }
    }

    _instantRebind(_newTokens, true);

    emit ChangePoolTokens(_currentTokens, _newTokens);
  }

   
  function pokeFromReporter(uint256 _reporterId, bytes calldata _rewardOpts)
    external
    onlyReporter(_reporterId, _rewardOpts)
    onlyEOA
  {
    _poke(false);
  }

  function pokeFromSlasher(uint256 _reporterId, bytes calldata _rewardOpts)
    external
    onlyNonReporter(_reporterId, _rewardOpts)
    onlyEOA
  {
    _poke(true);
  }

  function _poke(bool _bySlasher) internal {
    (uint256 minInterval, uint256 maxInterval) = _getMinMaxReportInterval();
    require(lastUpdate + minInterval < block.timestamp, "MIN_INTERVAL_NOT_REACHED");
    if (_bySlasher) {
      require(lastUpdate + maxInterval < block.timestamp, "MAX_INTERVAL_NOT_REACHED");
    }
    lastUpdate = block.timestamp;

    _instantRebind(BPoolInterface(pool).getCurrentTokens(), false);
  }

  function _vaultToUsdc(
    address _token,
    address _crvToken,
    VaultConfig memory _vc
  )
    internal
    returns (
      uint256 crvBalance,
      uint256 crvReceived,
      uint256 usdcBefore
    )
  {
    crvBalance = IERC20(_token).balanceOf(address(this));
    uint256 crvBefore = IERC20(_crvToken).balanceOf(address(this));

    IYearnVaultV2(_token).withdraw(crvBalance, address(this), maxWithdrawalLoss);
    crvReceived = IERC20(_crvToken).balanceOf(address(this)).sub(crvBefore);

    usdcBefore = USDC.balanceOf(address(this));
    if (_vc.depositorType == 2) {
      ICurveZapDepositor(_vc.depositor).remove_liquidity_one_coin(_crvToken, crvReceived, _vc.usdcIndex, 0);
    } else {
      ICurveDepositor(_vc.depositor).remove_liquidity_one_coin(crvReceived, _vc.usdcIndex, 0);
    }
  }

  function _usdcToVault(
    address _token,
    VaultConfig memory _vc,
    uint256 _usdcAmount
  )
    internal
    returns (
      uint256 crvBalance,
      uint256 vaultBalance,
      address crvToken
    )
  {
    crvToken = IYearnVaultV2(_token).token();

    _addUSDC2CurvePool(crvToken, _vc, _usdcAmount);

     
    crvBalance = IERC20(crvToken).balanceOf(address(this));
    IYearnVaultV2(_token).deposit(crvBalance);

     
    vaultBalance = IERC20(_token).balanceOf(address(this));
  }

  function _instantRebind(address[] memory _tokens, bool _allowNotBound) internal {
    address poolController_ = poolController;
    require(poolController_ != address(0), "CFG_NOT_SET");

    RebindConfig[] memory configs = fetchRebindConfigs(PowerIndexPoolInterface(pool), _tokens, _allowNotBound);

    uint256 toPushUSDCTotal;
    uint256 len = configs.length;
    uint256[] memory toPushUSDC = new uint256[](len);
    VaultConfig[] memory vaultConfigs = new VaultConfig[](len);

    for (uint256 si = 0; si < len; si++) {
      RebindConfig memory cfg = configs[si];
      VaultConfig memory vc = vaultConfig[cfg.token];
      vaultConfigs[si] = vc;
      require(vc.depositor != address(0), "DEPOSIT_CONTRACT_NOT_SET");

      if (cfg.newBalance <= cfg.oldBalance) {
        PullDataHelper memory mem;
        mem.crvToken = IYearnVaultV2(cfg.token).token();
        mem.vaultReserve = IERC20(mem.crvToken).balanceOf(cfg.token);

        mem.yDiff = (cfg.oldBalance - cfg.newBalance);

         
        PowerIndexPoolControllerInterface(poolController_).rebindByStrategyRemove(
          cfg.token,
          cfg.newBalance,
          cfg.newWeight
        );

         
        (mem.ycrvBalance, mem.crvActual, mem.usdcBefore) = _vaultToUsdc(cfg.token, mem.crvToken, vc);

         
        mem.crvExpected = (mem.ycrvBalance * IYearnVaultV2(cfg.token).pricePerShare()) / 1e18;

        emit PullLiquidity(
          cfg.token,
          mem.crvToken,
          mem.yDiff,
          mem.crvExpected,
          mem.crvActual,
          USDC.balanceOf(address(this)) - mem.usdcBefore,
          mem.vaultReserve
        );
      } else {
        uint256 yDiff = cfg.newBalance - cfg.oldBalance;
        uint256 crvAmount = IYearnVaultV2(cfg.token).pricePerShare().mul(yDiff) / 1e18;
        uint256 usdcIn;

        address crvToken = IYearnVaultV2(cfg.token).token();
        if (constraints.useVirtualPriceEstimation) {
          uint256 virtualPrice = ICurvePoolRegistry(curvePoolRegistry).get_virtual_price_from_lp_token(crvToken);
           
          usdcIn = bmul(virtualPrice, crvAmount);
        } else {
          usdcIn = getVaultUsdcEstimation(cfg.token, crvToken, crvAmount);
        }

         
        toPushUSDCTotal = toPushUSDCTotal.add(usdcIn);
        toPushUSDC[si] = usdcIn;
      }
    }

    uint256 usdcPulled = USDC.balanceOf(address(this));
    require(usdcPulled > 0, "USDC_PULLED_NULL");

    for (uint256 si = 0; si < len; si++) {
      if (toPushUSDC[si] > 0) {
        RebindConfig memory cfg = configs[si];

         
         
        uint256 usdcAmount = (usdcPulled.mul(toPushUSDC[si])) / toPushUSDCTotal;

        (uint256 crvBalance, uint256 vaultBalance, address crvToken) =
          _usdcToVault(cfg.token, vaultConfigs[si], usdcAmount);

         
        uint256 newBalance;
        try BPoolInterface(pool).getBalance(cfg.token) returns (uint256 _poolBalance) {
          newBalance = IERC20(cfg.token).balanceOf(address(this)).add(_poolBalance);
        } catch {
          newBalance = IERC20(cfg.token).balanceOf(address(this));
        }
        if (cfg.oldBalance == 0) {
          require(_allowNotBound, "BIND_NOT_ALLOW");
          PowerIndexPoolControllerInterface(poolController_).bindByStrategy(cfg.token, newBalance, cfg.newWeight);
        } else {
          PowerIndexPoolControllerInterface(poolController_).rebindByStrategyAdd(
            cfg.token,
            newBalance,
            cfg.newWeight,
            vaultBalance
          );
        }
        emit PushLiquidity(cfg.token, crvToken, vaultBalance, crvBalance, usdcAmount);
      }
    }

    uint256 usdcRemainder = USDC.balanceOf(address(this));
    require(usdcRemainder <= constraints.minUSDCRemainder, "USDC_REMAINDER");

    emit InstantRebind(len, usdcPulled, usdcRemainder);
  }

  function fetchRebindConfigs(
    PowerIndexPoolInterface _pool,
    address[] memory _tokens,
    bool _allowNotBound
  ) internal returns (RebindConfig[] memory configs) {
    uint256 len = _tokens.length;
    (uint256[] memory oldBalances, uint256[] memory poolUSDCBalances, uint256 totalUSDCPool) =
      getRebindConfigBalances(_pool, _tokens);

    (uint256[3][] memory weightsChange, , uint256[] memory newTokenValuesUSDC, uint256 totalValueUSDC) =
      computeWeightsChange(_pool, _tokens, new address[](0), 0, block.timestamp, block.timestamp + 1);

    configs = new RebindConfig[](len);

    for (uint256 si = 0; si < len; si++) {
      uint256[3] memory wc = weightsChange[si];
      require(wc[1] != 0 || _allowNotBound, "TOKEN_NOT_BOUND");

      configs[si] = RebindConfig(
        _tokens[wc[0]],
         
        wc[2],
        oldBalances[wc[0]],
         
        getNewTokenBalance(_tokens, wc, poolUSDCBalances, newTokenValuesUSDC, totalUSDCPool, totalValueUSDC)
      );
    }

    _updatePoolByPoke(pool, _tokens, newTokenValuesUSDC);
  }

  function getNewTokenBalance(
    address[] memory _tokens,
    uint256[3] memory wc,
    uint256[] memory poolUSDCBalances,
    uint256[] memory newTokenValuesUSDC,
    uint256 totalUSDCPool,
    uint256 totalValueUSDC
  ) internal view returns (uint256) {
    return
      bdiv(
        bdiv(bmul(wc[2], totalUSDCPool), totalWeight),
        bdiv(poolUSDCBalances[wc[0]], IERC20(_tokens[wc[0]]).totalSupply())
      ) * 1e12;
  }

  function getRebindConfigBalances(PowerIndexPoolInterface _pool, address[] memory _tokens)
    internal
    returns (
      uint256[] memory oldBalances,
      uint256[] memory poolUSDCBalances,
      uint256 totalUSDCPool
    )
  {
    uint256 len = _tokens.length;
    oldBalances = new uint256[](len);
    poolUSDCBalances = new uint256[](len);
    totalUSDCPool = USDC.balanceOf(address(this));

    for (uint256 oi = 0; oi < len; oi++) {
      try PowerIndexPoolInterface(address(_pool)).getBalance(_tokens[oi]) returns (uint256 _balance) {
        oldBalances[oi] = _balance;
        totalUSDCPool = totalUSDCPool.add(
          getVaultUsdcEstimation(_tokens[oi], IYearnVaultV2(_tokens[oi]).token(), oldBalances[oi])
        );
      } catch {
        oldBalances[oi] = 0;
      }
      uint256 poolUSDCBalance = getVaultVirtualPriceEstimation(_tokens[oi], IYearnVaultV2(_tokens[oi]).totalAssets());
      poolUSDCBalances[oi] = poolUSDCBalance;
    }
  }

  function _addUSDC2CurvePool(
    address _crvToken,
    VaultConfig memory _vc,
    uint256 _usdcAmount
  ) internal {
    if (_vc.depositorTokenLength == 2) {
      uint256[2] memory amounts;
      amounts[uint256(_vc.usdcIndex)] = _usdcAmount;
      if (_vc.depositorType == 2) {
        ICurveZapDepositor2(_vc.depositor).add_liquidity(_crvToken, amounts, 1);
      } else {
        ICurveDepositor2(_vc.depositor).add_liquidity(amounts, 1);
      }
    }

    if (_vc.depositorTokenLength == 3) {
      uint256[3] memory amounts;
      amounts[uint256(_vc.usdcIndex)] = _usdcAmount;
      if (_vc.depositorType == 2) {
        ICurveZapDepositor3(_vc.depositor).add_liquidity(_crvToken, amounts, 1);
      } else {
        ICurveDepositor3(_vc.depositor).add_liquidity(amounts, 1);
      }
    }

    if (_vc.depositorTokenLength == 4) {
      uint256[4] memory amounts;
      amounts[uint256(_vc.usdcIndex)] = _usdcAmount;
      if (_vc.depositorType == 2) {
        ICurveZapDepositor4(_vc.depositor).add_liquidity(_crvToken, amounts, 1);
      } else {
        ICurveDepositor4(_vc.depositor).add_liquidity(amounts, 1);
      }
    }
  }

  function _reward(
    uint256 _reporterId,
    uint256 _gasStart,
    uint256 _compensationPlan,
    bytes calldata _rewardOpts
  ) internal {
    powerPoke.reward(_reporterId, bsub(_gasStart, gasleft()), _compensationPlan, _rewardOpts);
  }

  function _getMinMaxReportInterval() internal view returns (uint256 min, uint256 max) {
    (uint256 minInterval, uint256 maxInterval) = powerPoke.getMinMaxReportIntervals(address(this));
    require(minInterval > 0 && maxInterval > 0, "INTERVALS_ARE_0");
    return (minInterval, maxInterval);
  }
}