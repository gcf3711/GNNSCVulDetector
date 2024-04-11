pragma experimental ABIEncoderV2;

 


 

pragma solidity >=0.6.0 <0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint256);
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

struct VestingTransaction {
    uint256 amount;
    uint256 fullVestingTimestamp;
}

struct WalletTotals {
    uint256 mature;
    uint256 immature;
    uint256 total;
}

struct UserInformation {
     
    uint256 mostMatureTxIndex;
    uint256 lastInTxIndex;
    uint256 maturedBalance;
    uint256 maxBalance;
    bool fullSenderWhitelisted;
     
    bool immatureReceiverWhitelisted;
    bool noVestingWhitelisted;
}

struct UserInformationLite {
    uint256 maturedBalance;
    uint256 maxBalance;
    uint256 mostMatureTxIndex;
    uint256 lastInTxIndex;
}

struct VestingTransactionDetailed {
    uint256 amount;
    uint256 fullVestingTimestamp;
     
    uint256 mature;
    uint256 immature;
}


uint256 constant QTY_EPOCHS = 7;

uint256 constant SECONDS_PER_EPOCH = 172800;  

uint256 constant FULL_EPOCH_TIME = SECONDS_PER_EPOCH * QTY_EPOCHS;

 
uint256 constant PM = 1e23;

 

pragma solidity ^0.7.6;



interface IDeltaToken is IERC20 {
    function vestingTransactions(address, uint256) external view returns (VestingTransaction memory);
    function getUserInfo(address) external view returns (UserInformationLite memory);
    function getMatureBalance(address, uint256) external view returns (uint256);
    function liquidityRebasingPermitted() external view returns (bool);
    function lpTokensInPair() external view returns (uint256);
    function governance() external view returns (address);
    function performLiquidityRebasing() external;
    function distributor() external view returns (address);
    function totalsForWallet(address ) external view returns (WalletTotals memory totals);
    function adjustBalanceOfNoVestingAccount(address, uint256,bool) external;
    function userInformation(address user) external view returns (UserInformation memory);
     
    function setTokenTransferHandler(address) external;
    function setBalanceCalculator(address) external;
    function setPendingGovernance(address) external;
    function acceptGovernance() external;
}

 

pragma solidity ^0.7.0;

 
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

interface IRebasingLiquidityToken is IERC20Upgradeable {
    function tokenCaller() external;
    function reserveCaller(uint256,uint256) external;
    function wrapWithReturn() external returns (uint256);
    function wrap() external;
    function rlpPerLP() external view returns (uint256);
}

 

pragma solidity >=0.5.0;

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

 

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

 

pragma solidity ^0.7.6;

 

library SafeMathUniswap {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

 

pragma solidity ^0.7.6;




library UniswapV2Library {
    using SafeMathUniswap for uint;

     
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

     
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'  
            ))));
    }

     
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

     
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

     
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

     
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

     
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

     
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

 

pragma solidity ^0.7.0;

 
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

 

pragma solidity ^0.7.0;

 
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

 

pragma solidity ^0.7.0;





 
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

     
    function name() public view virtual returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    uint256[44] private __gap;
}

 

interface IRESERVE_VAULT {
    function flashBorrowEverything() external;
}

interface IDELTA_LSW {
    function totalWETHEarmarkedForReferrers() external view returns (uint256);
}

interface IUNILIKE_FACTORY {
    function getPair(address,address) external view returns(address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IBAL_CALC {
    function SUSHI_DELTA_X_WETH_PAIR() external view returns (address);
    function TRANSFER_HANDLER() external view returns (address);
}

interface ITRANSFER_HANDLER {
    function SUSHI_DELTA_WETH_PAIR() external view returns(address);
}

contract DELTA_Rebasing_Liquidity_Token is IRebasingLiquidityToken, ERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    struct AddressCache {
        address deltaxWethPairAddress;
        IDeltaToken deltaToken;
        IUniswapV2Pair deltaxWethPair;
    }

    uint256 public override rlpPerLP;
    uint256 public _dailyVolumeTargetETH;
    uint256 private lastTargetUpdate;
    uint256 public ethVolumeRemaining;

     
    IUniswapV2Pair public constant UNI_DELTA_WETH_PAIR = IUniswapV2Pair(0x7D7E813082eF6c143277c71786e5bE626ec77b20);  
    IDeltaToken public constant DELTA = IDeltaToken(0x9EA3b5b4EC044b70375236A281986106457b20EF);  
    address constant internal DEAD_BEEF = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
    address public constant LSW = 0xdaFCE5670d3F67da9A3A44FE6bc36992e5E2beaB;
    address public constant RESERVE_VAULT = 0x6B29A3f9a1E378A57410dC480c1b19F4f89dE848;  
    IWETH public constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint256 constant public _DAILY_PERCENTAGE_COST_INCREASE_TO_MINT_LP = 10;

     
     
     

     
    address constant public SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    IUniswapV2Pair public constant SUSHI_DELTA_WETH_PAIR = IUniswapV2Pair(0x1498bd576454159Bb81B5Ce532692a8752D163e8);  
    address immutable private NEW_TRANSFER_HANDLER;
    address immutable private NEW_BALANCE_CALCULATOR;
    address constant private DELTA_MULTISIG = 0xB2d834dd31816993EF53507Eb1325430e67beefa;


     
    bool public migratedToSushi;

    constructor (address newTransferHandler, address newBalanceCalculator) public {
        
         
        require(ITRANSFER_HANDLER(newTransferHandler).SUSHI_DELTA_WETH_PAIR() == address(SUSHI_DELTA_WETH_PAIR), "Wrong config for transfer handler");
        require(IBAL_CALC(newBalanceCalculator).SUSHI_DELTA_X_WETH_PAIR() == address(SUSHI_DELTA_WETH_PAIR), "Wrong config to balcalc");
        require(IBAL_CALC(newBalanceCalculator).TRANSFER_HANDLER() == newTransferHandler, "Wrong transfer handler in bal calculator");


        NEW_TRANSFER_HANDLER = newTransferHandler;
        NEW_BALANCE_CALCULATOR = newBalanceCalculator;
    }


    function _migrateToSushi() private {
        bool sushiPairAlreadyExists = IUNILIKE_FACTORY(SUSHI_FACTORY).getPair(address(DELTA), address(WETH)) !=  address(0);
        require(!sushiPairAlreadyExists, "Pair is already created this is unsupported");

        address createdPairAddress = IUNILIKE_FACTORY(SUSHI_FACTORY).createPair(address(DELTA), address(WETH));
        require(createdPairAddress == address(SUSHI_DELTA_WETH_PAIR), "Created pair does not match calculated pair");
       
         
         
        uint256 balanceUNILP = UNI_DELTA_WETH_PAIR.balanceOf(address(this));
        UNI_DELTA_WETH_PAIR.transfer(address(UNI_DELTA_WETH_PAIR), balanceUNILP);
        UNI_DELTA_WETH_PAIR.burn(address(this));
         
             
        uint256 wethBalance = WETH.balanceOf(address(this));
        uint256 deltaBalance = DELTA.balanceOf(address(this));

        DELTA.transfer(address(SUSHI_DELTA_WETH_PAIR), deltaBalance); 
        WETH.transfer(address(SUSHI_DELTA_WETH_PAIR), wethBalance);
        uint256 mintedSLP = SUSHI_DELTA_WETH_PAIR.mint(address(this));
         
        (uint256 reserveSushiDELTA,uint256 reserveSushiWETH,) = SUSHI_DELTA_WETH_PAIR.getReserves();

        {  
             
             
            uint256 upperBound = balanceUNILP.mul(102).div(100);
            uint256 lowerBound = balanceUNILP.mul(98).div(100);

            require(mintedSLP <= upperBound, "We minted too much SLP");
            require(mintedSLP >= lowerBound, "We minted too little SLP - Is the new pair noVesting?");

        }
         
        migratedToSushi = true;
         
         
         
        DELTA.acceptGovernance();
         
        DELTA.setTokenTransferHandler(NEW_TRANSFER_HANDLER);
        DELTA.setBalanceCalculator(NEW_BALANCE_CALCULATOR);
        DELTA.setPendingGovernance(DELTA_MULTISIG);

         
         
         
    }

    function migrateToSushi() public {
        onlyMultisig();
         
        DELTA.performLiquidityRebasing();
    }


     
     
    function wrap() public override {
        _performWrap();  
    }

    function wrapWithReturn() external override returns (uint256) {
        return _performWrap();
    }

    function _performWrap() internal returns (uint256) {
         
        uint256 callerBalanceOfSLP = SUSHI_DELTA_WETH_PAIR.balanceOf(msg.sender);
        require(callerBalanceOfSLP > 0, "No tokens to wrap");

        if(callerBalanceOfSLP > 0) {
            safeTransferFrom(address(SUSHI_DELTA_WETH_PAIR), msg.sender, address(this), callerBalanceOfSLP);
        }

        uint256 garnishedBalance = callerBalanceOfSLP.mul(rlpPerLP).div(1e18);
        _mint(msg.sender, garnishedBalance);
        return garnishedBalance;
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }


    function rebase() public {
        require(msg.sender == tx.origin, "Smart wallets cannot call this function");

         
        revert("No rebasing until sushi migration is complete");

        uint256 deltaBalance = DELTA.balanceOf(address(this));
        if(deltaBalance > 0) {  
            DELTA.transfer(RESERVE_VAULT, deltaBalance); 
        }

         
        (uint256 preVolumeDELTAReserve, uint256 preVolumeWETHReserve,) = UNI_DELTA_WETH_PAIR.getReserves();
        uint256 preVolumeLPSupply = UNI_DELTA_WETH_PAIR.totalSupply();
        uint256 preVolumeLPBalance = UNI_DELTA_WETH_PAIR.balanceOf(address(this));

         
         
         
        DELTA.performLiquidityRebasing();
         

         
        (uint256 postVolumeDELTAReserve, uint256 postVolumeWETHReserve,) = UNI_DELTA_WETH_PAIR.getReserves();
        uint256 postVolumeLPSupply = UNI_DELTA_WETH_PAIR.totalSupply();
        uint256 postVolumeLPBalance = UNI_DELTA_WETH_PAIR.balanceOf(address(this));

         
         
        require(postVolumeDELTAReserve == preVolumeDELTAReserve, "Delta reserve has changed");
        require(preVolumeWETHReserve + 10 > postVolumeWETHReserve && postVolumeWETHReserve >= preVolumeWETHReserve , "WETH reserve out of bounds");
        require(preVolumeLPBalance + 1e4 >= postVolumeLPBalance && postVolumeLPBalance + 1e5 > preVolumeLPBalance , "LP balance change not within bounds"); 
        require(preVolumeLPSupply + 1e4 >= postVolumeLPSupply && postVolumeLPSupply + 1e5 > preVolumeLPSupply, "LP Supply change not within bounds");
    }

     
    function tokenCaller() override public {
        require(msg.sender == address(DELTA));

        if(!migratedToSushi ) {
            _migrateToSushi();
        } else {
            revert("Unimplemented for Sushi");
             
             
        }
    }

    function volumeGeneratingTrades( IDeltaToken _delta, IUniswapV2Pair _pair, uint256 ethTradeVolumeNeededToHitTarget) internal returns (uint256 newVolumeETHRemaining) {
        uint256 balanceWETH = WETH.balanceOf(address(this));
        (uint256 unsiwapReserveDelta, uint256 uniswapReserveWETH, ) = _pair.getReserves();

        uint256 amount0In = unsiwapReserveDelta.mul(1e12).div(uniswapReserveWETH).mul(balanceWETH).div(1e12);   
        uint256 amount0Out = amount0In * 10000/10161;  

        address addressPair = address(_pair);
        uint256 loops;
        while(loops < 50) {
            WETH.transfer(addressPair, balanceWETH);
            _delta.adjustBalanceOfNoVestingAccount(addressPair, amount0In, true);  

             
             
            _pair.swap(amount0Out, balanceWETH, address(this), "");

            _delta.adjustBalanceOfNoVestingAccount(addressPair, unsiwapReserveDelta, false);  
            
            _pair.sync();  
             

            if(balanceWETH > ethTradeVolumeNeededToHitTarget) {
                return 0;
            } else {
                ethTradeVolumeNeededToHitTarget -= balanceWETH;
                loops++;
            }
        }

         
        newVolumeETHRemaining = ethTradeVolumeNeededToHitTarget;
    }



    function setUpDailyVolumeTarget(uint256 ethWholeUnits, bool hourlyRebaseRightAway) public {
        onlyMultisig();
        _dailyVolumeTargetETH = ethWholeUnits * 1 ether;
        lastTargetUpdate = hourlyRebaseRightAway ? block.timestamp - 1 hours : block.timestamp;  
    }


    function getRemainingETHInVolumeTarget() public view returns (uint256 remainingVolumeInETH, uint256 secondsSinceLastUpdate) {
        secondsSinceLastUpdate = (block.timestamp - lastTargetUpdate);
        uint256 hoursSinceLastUpdate = secondsSinceLastUpdate / 1 hours;
        remainingVolumeInETH = (_dailyVolumeTargetETH / 24).mul(hoursSinceLastUpdate).add(ethVolumeRemaining);  
    }

    function updateRemainingETH() private returns (uint256) {
        (uint256 remainingVolumeInETH, uint256 secondsSinceLastUpdate) = getRemainingETHInVolumeTarget();
        lastTargetUpdate = block.timestamp - (secondsSinceLastUpdate % 1 hours);  
        return remainingVolumeInETH;
    }


    function reduceLpRatio(uint256 percentReductionE12) private {
        uint256 ratio = rlpPerLP;
        rlpPerLP = ratio.sub( ratio.mul(percentReductionE12).div(1e14) );
    }

     
    function reserveCaller(uint256 borrowedDELTA, uint256 borrowedWETH) public override {
         
         
         
             
         
         
         
             
         
         
         
             
        require(msg.sender == RESERVE_VAULT);

         
        uint256 ethTradeVolumeNeededToHitTarget = updateRemainingETH();
        require(ethTradeVolumeNeededToHitTarget > 0, "Can't generate volume, wait until a full hour still last targetUpdate is up");

        
        uint256 balanceLPBeforeMintingAndRebasing = UNI_DELTA_WETH_PAIR.balanceOf(address(this));
         
         
        (uint256 unsiwapReserveDelta, uint256 uniswapReserveWETH,) = UNI_DELTA_WETH_PAIR.getReserves();

         
        if(borrowedWETH > 0) {
            uint256 balanceWETHWithLoan = WETH.balanceOf(address(this));
            uint256 optimalDELTAToMatchAllWETH = UniswapV2Library.quote(balanceWETHWithLoan, uniswapReserveWETH, unsiwapReserveDelta);
             
            DELTA.adjustBalanceOfNoVestingAccount(address(UNI_DELTA_WETH_PAIR), optimalDELTAToMatchAllWETH, true);
            WETH.transfer(address(UNI_DELTA_WETH_PAIR), balanceWETHWithLoan);
            UNI_DELTA_WETH_PAIR.mint(address(this));
        }
        
         
         
         
        UNI_DELTA_WETH_PAIR.transfer(address(UNI_DELTA_WETH_PAIR), UNI_DELTA_WETH_PAIR.balanceOf(address(this)) / 2);
        UNI_DELTA_WETH_PAIR.burn(address(this));

         
        {  
            uint256 unfilledEthVolumeRemaining = volumeGeneratingTrades(DELTA, UNI_DELTA_WETH_PAIR, ethTradeVolumeNeededToHitTarget);
            uint256 volumeFulfilled = ethTradeVolumeNeededToHitTarget.sub(unfilledEthVolumeRemaining);
            uint256 lpRatioPercentReductionE12 = volumeFulfilled.mul(1e12).div(_dailyVolumeTargetETH).mul(_DAILY_PERCENTAGE_COST_INCREASE_TO_MINT_LP);
             
             
            reduceLpRatio(lpRatioPercentReductionE12);
            ethVolumeRemaining = unfilledEthVolumeRemaining;
        }

         
         
         
         
        uint256 balanceLPNow = UNI_DELTA_WETH_PAIR.balanceOf(address(this));

        if(balanceLPNow > balanceLPBeforeMintingAndRebasing) {  
             
            uint256 difference = balanceLPNow - balanceLPBeforeMintingAndRebasing;
            UNI_DELTA_WETH_PAIR.transfer(address(UNI_DELTA_WETH_PAIR), difference);
            UNI_DELTA_WETH_PAIR.burn(address(this));
            DELTA.adjustBalanceOfNoVestingAccount(address(UNI_DELTA_WETH_PAIR), unsiwapReserveDelta, false);
        } else {  
                 
                 
            (, uint256 currentUniswapReserveWETH,) = UNI_DELTA_WETH_PAIR.getReserves();
             
             
             
             
            uint256 ethNeeded = uniswapReserveWETH.sub(currentUniswapReserveWETH);
            if(ethNeeded > 0) {
                WETH.transfer(address(UNI_DELTA_WETH_PAIR), ethNeeded);
                DELTA.adjustBalanceOfNoVestingAccount(address(UNI_DELTA_WETH_PAIR), unsiwapReserveDelta, false);
                UNI_DELTA_WETH_PAIR.mint(address(this));
            }
             
        }

        if(borrowedWETH > 0) { 
             
             
            WETH.transfer(RESERVE_VAULT, WETH.balanceOf(address(this)));  
            DELTA.adjustBalanceOfNoVestingAccount(RESERVE_VAULT, borrowedDELTA, true);
        }

        UNI_DELTA_WETH_PAIR.sync();
         
        DELTA.adjustBalanceOfNoVestingAccount(address(this), 0, false); 
    }


    function onlyMultisig() private view {
        require(msg.sender == DELTA.governance(), "!governance");
    }





}