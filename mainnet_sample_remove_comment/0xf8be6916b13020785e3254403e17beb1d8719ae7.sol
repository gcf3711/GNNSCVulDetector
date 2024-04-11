
 

 

pragma solidity 0.5.17;

contract XConst {
    uint256 public constant BONE = 10**18;

    uint256 public constant MIN_BOUND_TOKENS = 2;
    uint256 public constant MAX_BOUND_TOKENS = 8;

    uint256 public constant EXIT_ZERO_FEE = 0;

    uint256 public constant MIN_WEIGHT = BONE;
    uint256 public constant MAX_WEIGHT = BONE * 50;
    uint256 public constant MAX_TOTAL_WEIGHT = BONE * 50;

     
    uint256 public constant MIN_BALANCE = 10**6;

     
    uint256 public constant MIN_POOL_AMOUNT = 10**8;

    uint256 public constant INIT_POOL_SUPPLY = BONE * 100;

    uint256 public constant MAX_IN_RATIO = BONE / 2;
    uint256 public constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;
}

 

pragma solidity 0.5.17;

interface IXPool {
     
    event Approval(address indexed src, address indexed dst, uint256 amt);
    event Transfer(address indexed src, address indexed dst, uint256 amt);

    function totalSupply() external view returns (uint256);

    function balanceOf(address whom) external view returns (uint256);

    function allowance(address src, address dst)
        external
        view
        returns (uint256);

    function approve(address dst, uint256 amt) external returns (bool);

    function transfer(address dst, uint256 amt) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external returns (bool);

     
    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);

     
    function swapExactAmountInRefer(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice,
        address referrer
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);

    function swapExactAmountOutRefer(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice,
        address referrer
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);

     
    function isBound(address token) external view returns (bool);

    function getFinalTokens() external view returns (address[] memory tokens);

    function getBalance(address token) external view returns (uint256);

    function swapFee() external view returns (uint256);

    function exitFee() external view returns (uint256);

    function finalized() external view returns (uint256);

    function controller() external view returns (uint256);

    function xconfig() external view returns (uint256);

    function getDenormalizedWeight(address) external view returns (uint256);

    function getTotalDenormalizedWeight() external view returns (uint256);

    function getVersion() external view returns (bytes32);

    function calcInGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut,
        uint256 _swapFee
    ) external pure returns (uint256 tokenAmountIn);

    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 _swapFee
    ) external pure returns (uint256 tokenAmountOut);

     
    function setController(address _controller) external;

    function setExitFee(uint256 newFee) external;

    function finalize(uint256 _swapFee) external;

    function bind(address token, uint256 denorm) external;

    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn)
        external;

    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut)
        external;

    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);

    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);

     
    function updateSafu(address safu, uint256 fee) external;

    function updateFarm(bool isFarm) external;
}

 

pragma solidity 0.5.17;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

 

pragma solidity 0.5.17;

 

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash =
            0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

         
        (bool success, ) = recipient.call.value(amount).gas(9100)("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

 

pragma solidity 0.5.17;



 

 
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
         
         
         
         
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
             
             
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

 

pragma solidity 0.5.17;

library XNum {
    uint256 public constant BONE = 10**18;
    uint256 public constant MIN_BPOW_BASE = 1 wei;
    uint256 public constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;
    uint256 public constant BPOW_PRECISION = BONE / 10**10;

    function btoi(uint256 a) internal pure returns (uint256) {
        return a / BONE;
    }

    function bfloor(uint256 a) internal pure returns (uint256) {
        return btoi(a) * BONE;
    }

    function badd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint256 a, uint256 b) internal pure returns (uint256) {
        (uint256 c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint256 a, uint256 b)
        internal
        pure
        returns (uint256, bool)
    {
        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint256 c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint256 c2 = c1 / BONE;
        return c2;
    }

    function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL");  
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL");  
        uint256 c2 = c1 / b;
        return c2;
    }

     
    function bpowi(uint256 a, uint256 n) internal pure returns (uint256) {
        uint256 z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

     
     
     
    function bpow(uint256 base, uint256 exp) internal pure returns (uint256) {
        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint256 whole = bfloor(exp);
        uint256 remain = bsub(exp, whole);

        uint256 wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint256 partialResult = bpowApprox(base, remain, BPOW_PRECISION);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(
        uint256 base,
        uint256 exp,
        uint256 precision
    ) internal pure returns (uint256) {
         
        uint256 a = exp;
        (uint256 x, bool xneg) = bsubSign(base, BONE);
        uint256 term = BONE;
        uint256 sum = term;
        bool negative = false;

         
         
         
         
        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * BONE;
            (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
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

 

pragma solidity 0.5.17;







 
contract XConfig is XConst {
    using XNum for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    address private core;

     
    address private safu;
    uint256 public SAFU_FEE = (5 * BONE) / 10000;  

     
    address private swapProxy;

     
    mapping(address => bool) internal farmPools;

     
     
    mapping(bytes32 => bool) internal poolSigs;
    uint256 public poolSigCount;

    uint256 public maxExitFee = BONE / 1000;  

    event INIT_SAFU(address indexed addr);
    event SET_CORE(address indexed core, address indexed coreNew);

    event SET_SAFU(address indexed safu, address indexed safuNew);
    event SET_SAFU_FEE(uint256 indexed fee, uint256 indexed feeNew);

    event SET_PROXY(address indexed proxy, address indexed proxyNew);

    event ADD_POOL_SIG(address indexed caller, bytes32 sig);
    event RM_POOL_SIG(address indexed caller, bytes32 sig);

    event ADD_FARM_POOL(address indexed pool);
    event RM_FARM_POOL(address indexed pool);

    event COLLECT(address indexed token, uint256 amount);

    modifier onlyCore() {
        require(msg.sender == core, "ERR_CORE_AUTH");
        _;
    }

    constructor() public {
        core = msg.sender;
        safu = address(this);
        emit INIT_SAFU(address(this));
    }

    function getCore() external view returns (address) {
        return core;
    }

    function getSAFU() external view returns (address) {
        return safu;
    }

    function getMaxExitFee() external view returns (uint256) {
        return maxExitFee;
    }

    function getSafuFee() external view returns (uint256) {
        return SAFU_FEE;
    }

    function getSwapProxy() external view returns (address) {
        return swapProxy;
    }

     
    function ethAddress() external pure returns (address) {
        return address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    }

     
     
    function hasPool(address[] calldata tokens, uint256[] calldata denorms)
        external
        view
        returns (bool exist, bytes32 sig)
    {
        require(tokens.length == denorms.length, "ERR_LENGTH_MISMATCH");
        require(tokens.length >= MIN_BOUND_TOKENS, "ERR_MIN_TOKENS");
        require(tokens.length <= MAX_BOUND_TOKENS, "ERR_MAX_TOKENS");

        uint256 totalWeight = 0;
        for (uint8 i = 0; i < tokens.length; i++) {
            totalWeight = totalWeight.badd(denorms[i]);
        }

        bytes memory poolInfo;
        for (uint8 i = 0; i < tokens.length; i++) {
            if (i > 0) {
                require(tokens[i] > tokens[i - 1], "ERR_TOKENS_NOT_SORTED");
            }
             
            uint256 nWeight = denorms[i].bmul(100).bdiv(totalWeight);
            poolInfo = abi.encodePacked(poolInfo, tokens[i], nWeight);
        }
        sig = keccak256(poolInfo);

        exist = poolSigs[sig];
    }

    function setCore(address _core) external onlyCore {
        require(_core != address(0), "ERR_ZERO_ADDR");
        emit SET_CORE(core, _core);
        core = _core;
    }

    function setSAFU(address _safu) external onlyCore {
        emit SET_SAFU(safu, _safu);
        safu = _safu;
    }

    function setMaxExitFee(uint256 _fee) external onlyCore {
        require(_fee <= (BONE / 10), "INVALID_EXIT_FEE");
        maxExitFee = _fee;
    }

    function setSafuFee(uint256 _fee) external onlyCore {
        require(_fee <= (BONE / 10), "INVALID_SAFU_FEE");
        emit SET_SAFU_FEE(SAFU_FEE, _fee);
        SAFU_FEE = _fee;
    }

    function setSwapProxy(address _proxy) external onlyCore {
        require(_proxy != address(0), "ERR_ZERO_ADDR");
        emit SET_PROXY(swapProxy, _proxy);
        swapProxy = _proxy;
    }

     
     
    function addPoolSig(bytes32 sig) external {
        require(msg.sender == swapProxy, "ERR_NOT_SWAPPROXY");
        require(sig != 0, "ERR_NOT_SIG");
        poolSigs[sig] = true;
        poolSigCount = poolSigCount.badd(1);

        emit ADD_POOL_SIG(msg.sender, sig);
    }

     
     
    function removePoolSig(bytes32 sig) external {
        require(msg.sender == swapProxy, "ERR_NOT_SWAPPROXY");
        require(sig != 0, "ERR_NOT_SIG");
        poolSigs[sig] = false;
        poolSigCount = poolSigCount.bsub(1);

        emit RM_POOL_SIG(msg.sender, sig);
    }

    function isFarmPool(address pool) external view returns (bool) {
        return farmPools[pool];
    }

     
    function addFarmPool(address pool) external onlyCore {
        require(pool != address(0), "ERR_ZERO_ADDR");
        require(!farmPools[pool], "ERR_IS_FARMPOOL");
        farmPools[pool] = true;

        emit ADD_FARM_POOL(pool);
    }

     
    function removeFarmPool(address pool) external onlyCore {
        require(pool != address(0), "ERR_ZERO_ADDR");
        require(farmPools[pool], "ERR_NOT_FARMPOOL");
        farmPools[pool] = false;

        emit RM_FARM_POOL(pool);
    }

     
    function updateSafu(address[] calldata pools) external onlyCore {
        require(pools.length > 0 && pools.length <= 30, "ERR_BATCH_COUNT");

        for (uint256 i = 0; i < pools.length; i++) {
            require(Address.isContract(pools[i]), "ERR_NOT_CONTRACT");

            IXPool pool = IXPool(pools[i]);
            pool.updateSafu(safu, SAFU_FEE);
        }
    }

     
    function updateFarm(address[] calldata pools, bool isFarm)
        external
        onlyCore
    {
        require(pools.length > 0 && pools.length <= 30, "ERR_BATCH_COUNT");

        for (uint256 i = 0; i < pools.length; i++) {
            require(Address.isContract(pools[i]), "ERR_NOT_CONTRACT");

            IXPool pool = IXPool(pools[i]);
            pool.updateFarm(isFarm);
        }
    }

     
    function collect(address token) external onlyCore {
        IERC20 TI = IERC20(token);

        uint256 collected = TI.balanceOf(address(this));
        TI.safeTransfer(safu, collected);

        emit COLLECT(token, collected);
    }
}