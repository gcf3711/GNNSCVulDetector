 
pragma experimental ABIEncoderV2;

 

 

pragma solidity 0.6.12;


 



struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

 

interface IERC3156FlashBorrower {

     
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

 

interface IUniswapAnchoredView {
    function price(string memory) external returns (uint256);
}

 

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

 



interface IUniswapV3SwapCallback {
    
    
     
     
    
     
    
     
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

 

interface InterestRateModel {
     
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256, uint256);

     
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);
}

 

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

 

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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

 

interface HealthCheck {
    function check(
        uint256 profit,
        uint256 loss,
        uint256 debtPayment,
        uint256 debtOutstanding,
        uint256 totalDebt
    ) external view returns (bool);
}

 

interface CTokenI {
     

     
    event AccrueInterest(uint256 cashPrior, uint256 interestAccumulated, uint256 borrowIndex, uint256 totalBorrows);

     
    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);

     
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

     
    event Borrow(address borrower, uint256 borrowAmount, uint256 accountBorrows, uint256 totalBorrows);

     
    event RepayBorrow(address payer, address borrower, uint256 repayAmount, uint256 accountBorrows, uint256 totalBorrows);

     
    event LiquidateBorrow(address liquidator, address borrower, uint256 repayAmount, address cTokenCollateral, uint256 seizeTokens);

     

     
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

     
    event NewAdmin(address oldAdmin, address newAdmin);

     
    event NewReserveFactor(uint256 oldReserveFactorMantissa, uint256 newReserveFactorMantissa);

     
    event ReservesAdded(address benefactor, uint256 addAmount, uint256 newTotalReserves);

     
    event ReservesReduced(address admin, uint256 reduceAmount, uint256 newTotalReserves);

     
    event Transfer(address indexed from, address indexed to, uint256 amount);

     
    event Approval(address indexed owner, address indexed spender, uint256 amount);

     
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

    function borrowBalanceStored(address account) external view returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function accrualBlockNumber() external view returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function getCash() external view returns (uint256);

    function accrueInterest() external returns (uint256);

    function interestRateModel() external view returns (InterestRateModel);

    function totalReserves() external view returns (uint256);

    function reserveFactorMantissa() external view returns (uint256);

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function totalBorrows() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

 

interface IERC20Extended is IERC20 {
    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}

 

interface IERC3156FlashLender {

     
    function maxFlashLoan(
        address token
    ) external view returns (uint256);

     
    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);

     
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

 

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

 



interface IUniswapV3Router is IUniswapV3SwapCallback {
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

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

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

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
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

 

interface VaultAPI is IERC20 {
    function name() external view returns (string calldata);

    function symbol() external view returns (string calldata);

    function decimals() external view returns (uint256);

    function apiVersion() external pure returns (string memory);

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        bytes calldata signature
    ) external returns (bool);

     
    function deposit() external returns (uint256);

    function deposit(uint256 amount) external returns (uint256);

    function deposit(uint256 amount, address recipient) external returns (uint256);

     
    function withdraw() external returns (uint256);

    function withdraw(uint256 maxShares) external returns (uint256);

    function withdraw(uint256 maxShares, address recipient) external returns (uint256);

    function token() external view returns (address);

    function strategies(address _strategy) external view returns (StrategyParams memory);

    function pricePerShare() external view returns (uint256);

    function totalAssets() external view returns (uint256);

    function depositLimit() external view returns (uint256);

    function maxAvailableShares() external view returns (uint256);

     
    function creditAvailable() external view returns (uint256);

     
    function debtOutstanding() external view returns (uint256);

     
    function expectedReturn() external view returns (uint256);

     
    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);

     
    function revokeStrategy() external;

     
    function governance() external view returns (address);

     
    function management() external view returns (address);

     
    function guardian() external view returns (address);
}

 

interface CErc20I is CTokenI {
    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        CTokenI cTokenCollateral
    ) external returns (uint256);

    function underlying() external view returns (address);

    function comptroller() external view returns (address);
}

 

interface ComptrollerI {
    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

     

    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);

    function mintVerify(
        address cToken,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;

    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;

    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;

    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);

    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;

     

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

     
    function claimComp(address holder) external;

    function claimComp(address holder, CTokenI[] memory cTokens) external;

    function markets(address ctoken)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );

    function compSpeeds(address ctoken) external view returns (uint256);  
    function compSupplySpeeds(address ctoken) external view returns (uint256);
    function compBorrowSpeeds(address ctoken) external view returns (uint256);

    function oracle() external view returns (address);
}

 

 

abstract contract BaseStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string public metadataURI;

     
    bool public doHealthCheck;
    address public healthCheck;

     
    function apiVersion() public pure returns (string memory) {
        return "0.4.3";
    }

     
    function name() external view virtual returns (string memory);

     
    function delegatedAssets() external view virtual returns (uint256) {
        return 0;
    }

    VaultAPI public vault;
    address public strategist;
    address public rewards;
    address public keeper;

    IERC20 public want;

     
    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);

    event UpdatedStrategist(address newStrategist);

    event UpdatedKeeper(address newKeeper);

    event UpdatedRewards(address rewards);

    event UpdatedMinReportDelay(uint256 delay);

    event UpdatedMaxReportDelay(uint256 delay);

    event UpdatedProfitFactor(uint256 profitFactor);

    event UpdatedDebtThreshold(uint256 debtThreshold);

    event EmergencyExitEnabled();

    event UpdatedMetadataURI(string metadataURI);

     
     
    uint256 public minReportDelay;

     
     
    uint256 public maxReportDelay;

     
     
    uint256 public profitFactor;

     
     
    uint256 public debtThreshold;

     
    bool public emergencyExit;

     
    modifier onlyAuthorized() {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyEmergencyAuthorized() {
        require(
            msg.sender == strategist || msg.sender == governance() || msg.sender == vault.guardian() || msg.sender == vault.management(),
            "!authorized"
        );
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "!strategist");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyKeepers() {
        require(
            msg.sender == keeper ||
                msg.sender == strategist ||
                msg.sender == governance() ||
                msg.sender == vault.guardian() ||
                msg.sender == vault.management(),
            "!authorized"
        );
        _;
    }

    modifier onlyVaultManagers() {
        require(msg.sender == vault.management() || msg.sender == governance(), "!authorized");
        _;
    }

    constructor(address _vault) public {
        _initialize(_vault, msg.sender, msg.sender, msg.sender);
    }

     
    function _initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) internal {
        require(address(want) == address(0), "Strategy already initialized");

        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.safeApprove(_vault, uint256(-1));  
        strategist = _strategist;
        rewards = _rewards;
        keeper = _keeper;

         
        minReportDelay = 0;
        maxReportDelay = 86400;
        profitFactor = 100;
        debtThreshold = 0;

        vault.approve(rewards, uint256(-1));  
    }

    function setHealthCheck(address _healthCheck) external onlyVaultManagers {
        healthCheck = _healthCheck;
    }

    function setDoHealthCheck(bool _doHealthCheck) external onlyVaultManagers {
        doHealthCheck = _doHealthCheck;
    }

     
    function setStrategist(address _strategist) external onlyAuthorized {
        require(_strategist != address(0));
        strategist = _strategist;
        emit UpdatedStrategist(_strategist);
    }

     
    function setKeeper(address _keeper) external onlyAuthorized {
        require(_keeper != address(0));
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

     
    function setRewards(address _rewards) external onlyStrategist {
        require(_rewards != address(0));
        vault.approve(rewards, 0);
        rewards = _rewards;
        vault.approve(rewards, uint256(-1));
        emit UpdatedRewards(_rewards);
    }

     
    function setMinReportDelay(uint256 _delay) external onlyAuthorized {
        minReportDelay = _delay;
        emit UpdatedMinReportDelay(_delay);
    }

     
    function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
        maxReportDelay = _delay;
        emit UpdatedMaxReportDelay(_delay);
    }

     
    function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
        profitFactor = _profitFactor;
        emit UpdatedProfitFactor(_profitFactor);
    }

     
    function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
        debtThreshold = _debtThreshold;
        emit UpdatedDebtThreshold(_debtThreshold);
    }

     
    function setMetadataURI(string calldata _metadataURI) external onlyAuthorized {
        metadataURI = _metadataURI;
        emit UpdatedMetadataURI(_metadataURI);
    }

     
    function governance() internal view returns (address) {
        return vault.governance();
    }

     
    function ethToWant(uint256 _amtInWei) public view virtual returns (uint256);

     
    function estimatedTotalAssets() public view virtual returns (uint256);

     
    function isActive() public view returns (bool) {
        return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
    }

     
    function prepareReturn(uint256 _debtOutstanding)
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        );

     
    function adjustPosition(uint256 _debtOutstanding) internal virtual;

     
    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

     

    function liquidateAllPositions() internal virtual returns (uint256 _amountFreed);

     
    function tendTrigger(uint256 callCostInWei) public view virtual returns (bool) {
         
         
         
         
         

        return false;
    }

     
    function tend() external onlyKeepers {
         
        adjustPosition(vault.debtOutstanding());
    }

     
    function harvestTrigger(uint256 callCostInWei) public view virtual returns (bool) {
        uint256 callCost = ethToWant(callCostInWei);
        StrategyParams memory params = vault.strategies(address(this));

         
        if (params.activation == 0) return false;

         
        if (block.timestamp.sub(params.lastReport) < minReportDelay) return false;

         
        if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

         
         
         
         
         
        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

         
        uint256 total = estimatedTotalAssets();
         
        if (total.add(debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total.sub(params.totalDebt);  

         
         
        uint256 credit = vault.creditAvailable();
        return (profitFactor.mul(callCost) < credit.add(profit));
    }

     
    function harvest() external onlyKeepers {
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = vault.debtOutstanding();
        uint256 debtPayment = 0;
        if (emergencyExit) {
             
            uint256 amountFreed = liquidateAllPositions();
            if (amountFreed < debtOutstanding) {
                loss = debtOutstanding.sub(amountFreed);
            } else if (amountFreed > debtOutstanding) {
                profit = amountFreed.sub(debtOutstanding);
            }
            debtPayment = debtOutstanding.sub(loss);
        } else {
             
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }

         
         
         
        uint256 totalDebt = vault.strategies(address(this)).totalDebt;
        debtOutstanding = vault.report(profit, loss, debtPayment);

         
        adjustPosition(debtOutstanding);

         
        if (doHealthCheck && healthCheck != address(0)) {
            require(HealthCheck(healthCheck).check(profit, loss, debtPayment, debtOutstanding, totalDebt), "!healthcheck");
        } else {
            doHealthCheck = true;
        }

        emit Harvested(profit, loss, debtPayment, debtOutstanding);
    }

     
    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
         
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
         
        want.safeTransfer(msg.sender, amountFreed);
         
    }

     
    function prepareMigration(address _newStrategy) internal virtual;

     
    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault));
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

     
    function setEmergencyExit() external onlyEmergencyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

     
    function protectedTokens() internal view virtual returns (address[] memory);

     
    function sweep(address _token) external onlyGovernance {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(governance(), IERC20(_token).balanceOf(address(this)));
    }
}

 

library FlashMintLib {
    using SafeMath for uint256;
    event Leverage(uint256 amountRequested, uint256 requiredDAI, bool deficit, address flashLoan);

    uint256 private constant PRICE_DECIMALS = 1e6;
    uint256 private constant DAI_DECIMALS = 1e18;
    uint256 private constant COLLAT_DECIMALS = 1e18;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant CDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    ComptrollerI private constant COMPTROLLER = ComptrollerI(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    address public constant LENDER = 0x1EB4CF3A948E7D72A198fe073cCb8C7a948cD853;
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    function doFlashMint(
        bool deficit,
        uint256 amountDesired,
        address want,
        uint256 collatRatioDAI
    ) public returns (uint256) {
        if (amountDesired == 0) {
            return 0;
        }

         
        (uint256 requiredDAI, uint256 amountWant) = getFlashLoanParams(want, amountDesired, collatRatioDAI);

        bytes memory data = abi.encode(deficit, amountWant);
        uint256 _fee = IERC3156FlashLender(LENDER).flashFee(DAI, amountWant);
         
        require(_fee == 0);
        uint256 _allowance = IERC20(DAI).allowance(address(this), address(LENDER));
        if (_allowance < requiredDAI) {
            IERC20(DAI).approve(address(LENDER), 0);
            IERC20(DAI).approve(address(LENDER), type(uint256).max);
        }
        IERC3156FlashLender(LENDER).flashLoan(IERC3156FlashBorrower(address(this)), DAI, requiredDAI, data);

        emit Leverage(amountDesired, requiredDAI, deficit, address(LENDER));

        return amountWant;
    }

    function maxLiquidity() public view returns (uint256) {
        return IERC3156FlashLender(LENDER).maxFlashLoan(DAI);
    }

    function getFlashLoanParams(
        address want,
        uint256 amountDesired,
        uint256 collatRatioDAI
    ) internal returns (uint256 requiredDAI, uint256 amountWant) {
        uint256 priceDAIWant;
        uint256 decimalsDifference;
        (priceDAIWant, decimalsDifference, requiredDAI) = getPriceDAIWant(want, amountDesired, collatRatioDAI);
        amountWant = amountDesired;

         
        uint256 _maxFlashLoan = maxLiquidity();
        if (requiredDAI > _maxFlashLoan) {
            requiredDAI = _maxFlashLoan.mul(9800).div(10_000);  
            if (address(want) == address(DAI)) {
                amountWant = requiredDAI;
            } else {
                amountWant = requiredDAI.mul(collatRatioDAI).mul(PRICE_DECIMALS).div(priceDAIWant).div(COLLAT_DECIMALS).div(decimalsDifference);
            }
        }
    }

    function getPriceDAIWant(
        address want,
        uint256 amountDesired,
        uint256 collatRatioDAI
    )
        internal
        returns (
            uint256 priceDAIWant,
            uint256 decimalsDifference,
            uint256 requiredDAI
        )
    {
        if (want == DAI) {
            requiredDAI = amountDesired;
            priceDAIWant = PRICE_DECIMALS;  
            decimalsDifference = 1;  
        } else {
             
            uint256 wantDecimals = 10**uint256(IERC20Extended(want).decimals());
            decimalsDifference = DAI_DECIMALS.div(wantDecimals);
            priceDAIWant = getOraclePrice(DAI).mul(PRICE_DECIMALS).div(getOraclePrice(want));
             
             
             
            requiredDAI = amountDesired.mul(PRICE_DECIMALS).mul(COLLAT_DECIMALS).mul(decimalsDifference).div(priceDAIWant).div(collatRatioDAI);
        }
    }

    function getOraclePrice(address token) internal returns (uint256) {
        string memory symbol;
         
        if (token == WBTC) {
            symbol = "BTC";
        } else if (token == WETH) {
            symbol = "ETH";
        } else {
            symbol = IERC20Extended(token).symbol();
        }
        IUniswapAnchoredView oracle = IUniswapAnchoredView(COMPTROLLER.oracle());
        return oracle.price(symbol);
    }

    function loanLogic(
        bool deficit,
        uint256 amountDAI,
        uint256 amount,
        CErc20I cToken
    ) public returns (bytes32) {
         
         
        bool isDai;
         
        if (address(cToken) == address(CDAI)) {
            isDai = true;
            require(amountDAI == amount, "!amounts");
        }
        uint256 daiBal = IERC20(DAI).balanceOf(address(this));
        if (deficit) {
            if (!isDai) {
                require(CErc20I(CDAI).mint(daiBal) == 0, "!mint_flash");
                require(cToken.redeemUnderlying(amount) == 0, "!redeem_down");
            }
             
            uint256 repayAmount = Math.min(IERC20(cToken.underlying()).balanceOf(address(this)), cToken.borrowBalanceCurrent(address(this)));
            require(cToken.repayBorrow(repayAmount) == 0, "!repay_down");
            require(CErc20I(CDAI).redeemUnderlying(amountDAI) == 0, "!redeem");
        } else {
             
            require(CErc20I(CDAI).mint(daiBal) == 0, "!mint_flash");
            require(cToken.borrow(amount) == 0, "!borrow_up");
            if (!isDai) {
                require(cToken.mint(IERC20(cToken.underlying()).balanceOf(address(this))) == 0, "!mint_up");
                require(CErc20I(CDAI).redeemUnderlying(amountDAI) == 0, "!redeem");
            }
        }
        return CALLBACK_SUCCESS;
    }
}

 

contract Strategy is BaseStrategy, IERC3156FlashBorrower {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

     
    event Leverage(uint256 amountRequested, uint256 amountGiven, bool deficit, address flashLoan);

     
    ComptrollerI private constant compound = ComptrollerI(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

     
    address private constant comp = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address private constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    CErc20I public cToken;

    bool public useUniV3;
     
    uint24 public compToWethSwapFee;
    uint24 public wethToWantSwapFee;
    IUniswapV2Router02 public currentV2Router;
    IUniswapV2Router02 private constant UNI_V2_ROUTER = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private constant SUSHI_V2_ROUTER = IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    IUniswapV3Router private constant UNI_V3_ROUTER = IUniswapV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    uint256 public collatRatioDAI;
    uint256 public collateralTarget;  
    uint256 private blocksToLiquidationDangerZone;  

    uint256 public minWant;  

     
    bool public dontClaimComp;  
    uint256 public minCompToSell;  

    bool public flashMintActive;  
    bool public forceMigrate;
    bool public fourThreeProtection;

    constructor(address _vault, address _cToken) public BaseStrategy(_vault) {
        _initializeThis(_cToken);
    }

    function approveTokenMax(address token, address spender) internal {
        IERC20(token).safeApprove(spender, type(uint256).max);
    }

    function name() external view override returns (string memory) {
        return "GenLevCompV3";
    }

    function initialize(address _vault, address _cToken) external {
        _initialize(_vault, msg.sender, msg.sender, msg.sender);
        _initializeThis(_cToken);
    }

    function _initializeThis(address _cToken) internal {
        cToken = CErc20I(address(_cToken));
        require(IERC20Extended(address(want)).decimals() <= 18);  
        currentV2Router = SUSHI_V2_ROUTER;

         
        approveTokenMax(comp, address(UNI_V2_ROUTER));
        approveTokenMax(comp, address(SUSHI_V2_ROUTER));
        approveTokenMax(comp, address(UNI_V3_ROUTER));
        approveTokenMax(address(want), address(cToken));
        approveTokenMax(FlashMintLib.DAI, address(FlashMintLib.LENDER));
         
        address[] memory markets;
        if (address(cToken) != address(FlashMintLib.CDAI)) {
            markets = new address[](2);
            markets[0] = address(FlashMintLib.CDAI);
            markets[1] = address(cToken);
             
            approveTokenMax(FlashMintLib.DAI, address(FlashMintLib.CDAI));
        } else {
            markets = new address[](1);
            markets[0] = address(FlashMintLib.CDAI);
        }
        compound.enterMarkets(markets);
         
        compToWethSwapFee = 3000;
        wethToWantSwapFee = 3000;
         
        maxReportDelay = 86400;  
        profitFactor = 100;  
        debtThreshold = 1e30;
         
        minWant = uint256(uint256(10)**uint256((IERC20Extended(address(want))).decimals())).div(1e5);
        minCompToSell = 0.1 ether;
        collateralTarget = 0.63 ether;
        collatRatioDAI = 0.73 ether;
        blocksToLiquidationDangerZone = 46500;
        flashMintActive = true;
    }

     

    function setFourThreeProtection(bool _fourThreeProtection) external management {
        fourThreeProtection = _fourThreeProtection;
    }

    function setUniV3PathFees(uint24 _compToWethSwapFee, uint24 _wethToWantSwapFee) external management {
        compToWethSwapFee = _compToWethSwapFee;
        wethToWantSwapFee = _wethToWantSwapFee;
    }

    function setDontClaimComp(bool _dontClaimComp) external management {
        dontClaimComp = _dontClaimComp;
    }

    function setUseUniV3(bool _useUniV3) external management {
        useUniV3 = _useUniV3;
    }

    function setToggleV2Router() external management {
        currentV2Router = currentV2Router == SUSHI_V2_ROUTER ? UNI_V2_ROUTER : SUSHI_V2_ROUTER;
    }

    function setFlashMintActive(bool _flashMintActive) external management {
        flashMintActive = _flashMintActive;
    }

    function setForceMigrate(bool _force) external onlyGovernance {
        forceMigrate = _force;
    }

    function setMinCompToSell(uint256 _minCompToSell) external management {
        minCompToSell = _minCompToSell;
    }

    function setMinWant(uint256 _minWant) external management {
        minWant = _minWant;
    }

    function setCollateralTarget(uint256 _collateralTarget) external management {
        (, uint256 collateralFactorMantissa, ) = compound.markets(address(cToken));
        require(collateralFactorMantissa > _collateralTarget);
        collateralTarget = _collateralTarget;
    }

    function setCollatRatioDAI(uint256 _collatRatioDAI) external management {
        collatRatioDAI = _collatRatioDAI;
    }

     
     
    function estimatedTotalAssets() public view override returns (uint256) {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();

        uint256 _claimableComp = predictCompAccrued();
        uint256 currentComp = balanceOfToken(comp);

         
        uint256 estimatedWant = priceCheck(comp, address(want), _claimableComp.add(currentComp));
        uint256 conservativeWant = estimatedWant.mul(9).div(10);  

        return balanceOfToken(address(want)).add(deposits).add(conservativeWant).sub(borrows);
    }

    function balanceOfToken(address token) internal view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

     
    function expectedReturn() public view returns (uint256) {
        uint256 estimateAssets = estimatedTotalAssets();

        uint256 debt = vault.strategies(address(this)).totalDebt;
        if (debt > estimateAssets) {
            return 0;
        } else {
            return estimateAssets.sub(debt);
        }
    }

     
    function tendTrigger(uint256 gasCost) public view override returns (bool) {
        if (harvestTrigger(gasCost)) {
             
            return false;
        }

        return getblocksUntilLiquidation() <= blocksToLiquidationDangerZone;
    }

     
    function priceCheck(
        address start,
        address end,
        uint256 _amount
    ) public view returns (uint256) {
        if (_amount == 0) {
            return 0;
        }

        uint256[] memory amounts = currentV2Router.getAmountsOut(_amount, getTokenOutPathV2(start, end));

        return amounts[amounts.length - 1];
    }

     

     
     
     
     
    function getblocksUntilLiquidation() public view returns (uint256) {
        (, uint256 collateralFactorMantissa, ) = compound.markets(address(cToken));

        (uint256 deposits, uint256 borrows) = getCurrentPosition();

        uint256 borrrowRate = cToken.borrowRatePerBlock();

        uint256 supplyRate = cToken.supplyRatePerBlock();

        uint256 collateralisedDeposit1 = deposits.mul(collateralFactorMantissa).div(1e18);
        uint256 collateralisedDeposit = collateralisedDeposit1;

        uint256 denom1 = borrows.mul(borrrowRate);
        uint256 denom2 = collateralisedDeposit.mul(supplyRate);

        if (denom2 >= denom1) {
            return type(uint256).max;
        } else {
            uint256 numer = collateralisedDeposit.sub(borrows);
            uint256 denom = denom1.sub(denom2);
             
            return numer.mul(1e18).div(denom);
        }
    }

     
     
    function predictCompAccrued() public view returns (uint256) {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();
        if (deposits == 0) {
            return 0;  
        }

        uint256 distributionPerBlockSupply = compound.compSupplySpeeds(address(cToken));
        uint256 distributionPerBlockBorrow = compound.compBorrowSpeeds(address(cToken));
        uint256 totalBorrow = cToken.totalBorrows();

         
        uint256 totalSupplyCtoken = cToken.totalSupply();
        uint256 totalSupply = totalSupplyCtoken.mul(cToken.exchangeRateStored()).div(1e18);

        uint256 blockShareSupply = 0;
        if (totalSupply > 0) {
            blockShareSupply = deposits.mul(distributionPerBlockSupply).div(totalSupply);
        }

        uint256 blockShareBorrow = 0;
        if (totalBorrow > 0) {
            blockShareBorrow = borrows.mul(distributionPerBlockBorrow).div(totalBorrow);
        }

         
        uint256 blockShare = blockShareSupply.add(blockShareBorrow);

         
        uint256 lastReport = vault.strategies(address(this)).lastReport;
        uint256 blocksSinceLast = (block.timestamp.sub(lastReport)).div(13);  

        return blocksSinceLast.mul(blockShare);
    }

     
     
     
    function getCurrentPosition() public view returns (uint256 deposits, uint256 borrows) {
        (, uint256 ctokenBalance, uint256 borrowBalance, uint256 exchangeRate) = cToken.getAccountSnapshot(address(this));
        borrows = borrowBalance;

        deposits = ctokenBalance.mul(exchangeRate).div(1e18);
    }

     
    function getLivePosition() public returns (uint256 deposits, uint256 borrows) {
        deposits = cToken.balanceOfUnderlying(address(this));

         
        borrows = cToken.borrowBalanceStored(address(this));
    }

     
    function netBalanceLent() public view returns (uint256) {
        (uint256 deposits, uint256 borrows) = getCurrentPosition();
        return deposits.sub(borrows);
    }

     
     
    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {
        _profit = 0;
        _loss = 0;  

        if (balanceOfToken(address(cToken)) == 0) {
            uint256 wantBalance = balanceOfToken(address(want));
             
             
             
            _debtPayment = Math.min(wantBalance, _debtOutstanding);
            return (_profit, _loss, _debtPayment);
        }

        (uint256 deposits, uint256 borrows) = getLivePosition();

         
        _claimComp();
         
        _disposeOfComp();

        uint256 wantBalance = balanceOfToken(address(want));

        uint256 investedBalance = deposits.sub(borrows);
        uint256 balance = investedBalance.add(wantBalance);

        uint256 debt = vault.strategies(address(this)).totalDebt;

         
        if (balance > debt) {
            _profit = balance.sub(debt);
            if (wantBalance < _profit) {
                 
                _profit = wantBalance;
            } else if (wantBalance > _profit.add(_debtOutstanding)) {
                _debtPayment = _debtOutstanding;
            } else {
                _debtPayment = wantBalance.sub(_profit);
            }
        } else {
             
             
            _loss = debt.sub(balance);
            _debtPayment = Math.min(wantBalance, _debtOutstanding);
        }
    }

     

    function adjustPosition(uint256 _debtOutstanding) internal override {
         
        if (emergencyExit) {
            return;
        }

         
        uint256 _wantBal = balanceOfToken(address(want));
        if (_wantBal < _debtOutstanding) {
             
             
            if (balanceOfToken(address(cToken)) > 1) {
                _withdrawSome(_debtOutstanding.sub(_wantBal));
            }

            return;
        }

        (uint256 position, bool deficit) = _calculateDesiredPosition(_wantBal.sub(_debtOutstanding), true);

         
         
        if (position > minWant) {
             
            if (!flashMintActive) {
                uint256 i = 0;
                while (position > 0) {
                    position = position.sub(_noFlashLoan(position, deficit));
                    if (i >= 6) {
                        break;
                    }
                    i++;
                }
            } else {
                 
                if (position > FlashMintLib.maxLiquidity()) {
                    position = position.sub(_noFlashLoan(position, deficit));
                }

                 
                if (position > minWant) {
                    doFlashMint(deficit, position);
                }
            }
        }
    }

     
    function _withdrawSome(uint256 _amount) internal returns (bool notAll) {
        (uint256 position, bool deficit) = _calculateDesiredPosition(_amount, false);

         
         
        if (deficit && position > minWant) {
             
            if (flashMintActive) {
                position = position.sub(doFlashMint(deficit, position));
            }
            uint8 i = 0;
             
             
            while (position > minWant.add(100)) {
                position = position.sub(_noFlashLoan(position, true));
                i++;
                 
                if (i >= 5) {
                    notAll = true;
                    break;
                }
            }
        }
         
         

         
        (uint256 depositBalance, uint256 borrowBalance) = getCurrentPosition();

        uint256 tempColla = collateralTarget;

        uint256 reservedAmount = 0;
        if (tempColla == 0) {
            tempColla = 1e15;  
        }

        reservedAmount = borrowBalance.mul(1e18).div(tempColla);
        if (depositBalance >= reservedAmount) {
            uint256 redeemable = depositBalance.sub(reservedAmount);
            uint256 balan = cToken.balanceOf(address(this));
            if (balan > 1) {
                if (redeemable < _amount) {
                    cToken.redeemUnderlying(redeemable);
                } else {
                    cToken.redeemUnderlying(_amount);
                }
            }
        }

        if (collateralTarget == 0 && balanceOfToken(address(want)) > borrowBalance) {
            cToken.repayBorrow(borrowBalance);
        }
    }

     
    function _calculateDesiredPosition(uint256 balance, bool dep) internal returns (uint256 position, bool deficit) {
         
        (uint256 deposits, uint256 borrows) = getLivePosition();

         
        uint256 unwoundDeposit = deposits.sub(borrows);

         
         
         

        uint256 desiredSupply = 0;
        if (dep) {
            desiredSupply = unwoundDeposit.add(balance);
        } else {
            if (balance > unwoundDeposit) {
                balance = unwoundDeposit;
            }
            desiredSupply = unwoundDeposit.sub(balance);
        }

         
        uint256 num = desiredSupply.mul(collateralTarget);
        uint256 den = uint256(1e18).sub(collateralTarget);

        uint256 desiredBorrow = num.div(den);
        if (desiredBorrow > 1e5) {
             
            desiredBorrow = desiredBorrow.sub(1e5);
        }

         
         
        if (desiredBorrow < borrows) {
            deficit = true;
            position = borrows.sub(desiredBorrow);  
        } else {
             
            deficit = false;
            position = desiredBorrow.sub(borrows);
        }
    }

     
    function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _amountFreed, uint256 _loss) {
        uint256 _balance = balanceOfToken(address(want));
        uint256 assets = netBalanceLent().add(_balance);

        uint256 debtOutstanding = vault.debtOutstanding();

        if (debtOutstanding > assets) {
            _loss = debtOutstanding.sub(assets);
        }

        (uint256 deposits, uint256 borrows) = getLivePosition();
        if (assets < _amountNeeded) {
             
             

             
            if (balanceOfToken(address(cToken)) > 1) {
                _withdrawSome(deposits.sub(borrows));
            }

            _amountFreed = Math.min(_amountNeeded, balanceOfToken(address(want)));
        } else {
            if (_balance < _amountNeeded) {
                _withdrawSome(_amountNeeded.sub(_balance));

                 
                _amountFreed = Math.min(_amountNeeded, balanceOfToken(address(want)));
            } else {
                _amountFreed = _amountNeeded;
            }
        }

         
         
        if (_amountFreed < _amountNeeded) {
            uint256 diff = _amountNeeded.sub(_amountFreed);
            if (diff <= minWant) {
                _loss = diff;
            }
        }

        if (fourThreeProtection) {
            require(_amountNeeded == _amountFreed.add(_loss));  
        }
    }

    function _claimComp() internal {
        if (dontClaimComp) {
            return;
        }
        CTokenI[] memory tokens = new CTokenI[](1);
        tokens[0] = cToken;

        compound.claimComp(address(this), tokens);
    }

     
    function _disposeOfComp() internal {
        uint256 _comp = balanceOfToken(comp);
        if (_comp < minCompToSell) {
            return;
        }

        if (useUniV3) {
            UNI_V3_ROUTER.exactInput(IUniswapV3Router.ExactInputParams(getTokenOutPathV3(comp, address(want)), address(this), now, _comp, 0));
        } else {
            currentV2Router.swapExactTokensForTokens(_comp, 0, getTokenOutPathV2(comp, address(want)), address(this), now);
        }
    }

    function getTokenOutPathV2(address _tokenIn, address _tokenOut) internal pure returns (address[] memory _path) {
        bool isWeth = _tokenIn == address(weth) || _tokenOut == address(weth);
        _path = new address[](isWeth ? 2 : 3);
        _path[0] = _tokenIn;

        if (isWeth) {
            _path[1] = _tokenOut;
        } else {
            _path[1] = address(weth);
            _path[2] = _tokenOut;
        }
    }

    function getTokenOutPathV3(address _tokenIn, address _tokenOut) internal view returns (bytes memory _path) {
        if (address(want) == weth) {
            _path = abi.encodePacked(address(_tokenIn), compToWethSwapFee, address(weth));
        } else {
            _path = abi.encodePacked(address(_tokenIn), compToWethSwapFee, address(weth), wethToWantSwapFee, address(_tokenOut));
        }
    }

     
     
    function prepareMigration(address _newStrategy) internal override {
        if (!forceMigrate) {
            (uint256 deposits, uint256 borrows) = getLivePosition();
            _withdrawSome(deposits.sub(borrows));

            (, , uint256 borrowBalance, ) = cToken.getAccountSnapshot(address(this));

            require(borrowBalance < 10_000);

            IERC20 _comp = IERC20(comp);
            uint256 _compB = balanceOfToken(address(_comp));
            if (_compB > 0) {
                _comp.safeTransfer(_newStrategy, _compB);
            }
        }
    }

     
     
     
    function _noFlashLoan(uint256 max, bool deficit) internal returns (uint256 amount) {
         
        (uint256 lent, uint256 borrowed) = getCurrentPosition();

         
        if (borrowed == 0 && deficit) {
            return 0;
        }

        (, uint256 collateralFactorMantissa, ) = compound.markets(address(cToken));

        if (deficit) {
            amount = _normalDeleverage(max, lent, borrowed, collateralFactorMantissa);
        } else {
            amount = _normalLeverage(max, lent, borrowed, collateralFactorMantissa);
        }

        emit Leverage(max, amount, deficit, address(0));
    }

     
    function _normalDeleverage(
        uint256 maxDeleverage,
        uint256 lent,
        uint256 borrowed,
        uint256 collatRatio
    ) internal returns (uint256 deleveragedAmount) {
        uint256 theoreticalLent = 0;

         
        if (collatRatio != 0) {
            theoreticalLent = borrowed.mul(1e18).div(collatRatio);
        }
        deleveragedAmount = lent.sub(theoreticalLent);

        if (deleveragedAmount >= borrowed) {
            deleveragedAmount = borrowed;
        }
        if (deleveragedAmount >= maxDeleverage) {
            deleveragedAmount = maxDeleverage;
        }
        uint256 exchangeRateStored = cToken.exchangeRateStored();
         
         
        if (deleveragedAmount.mul(1e18) >= exchangeRateStored && deleveragedAmount > 10) {
            deleveragedAmount = deleveragedAmount.sub(uint256(10));
            cToken.redeemUnderlying(deleveragedAmount);

             
            cToken.repayBorrow(deleveragedAmount);
        }
    }

     
    function _normalLeverage(
        uint256 maxLeverage,
        uint256 lent,
        uint256 borrowed,
        uint256 collatRatio
    ) internal returns (uint256 leveragedAmount) {
        uint256 theoreticalBorrow = lent.mul(collatRatio).div(1e18);

        leveragedAmount = theoreticalBorrow.sub(borrowed);

        if (leveragedAmount >= maxLeverage) {
            leveragedAmount = maxLeverage;
        }
        if (leveragedAmount > 10) {
            leveragedAmount = leveragedAmount.sub(uint256(10));
            cToken.borrow(leveragedAmount);
            cToken.mint(balanceOfToken(address(want)));
        }
    }

     
    function manualDeleverage(uint256 amount) external management {
        require(cToken.redeemUnderlying(amount) == 0);
        require(cToken.repayBorrow(amount) == 0);
    }

     
    function manualReleaseWant(uint256 amount) external onlyGovernance {
        require(cToken.redeemUnderlying(amount) == 0);  
    }

    function protectedTokens() internal view override returns (address[] memory) {}

     

     
     
    function doFlashMint(bool deficit, uint256 amountDesired) internal returns (uint256) {
        return FlashMintLib.doFlashMint(deficit, amountDesired, address(want), collatRatioDAI);
    }

     
    function storedCollateralisation() public view returns (uint256 collat) {
        (uint256 lend, uint256 borrow) = getCurrentPosition();
        if (lend == 0) {
            return 0;
        }
        collat = uint256(1e18).mul(borrow).div(lend);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        require(msg.sender == FlashMintLib.LENDER);
        require(initiator == address(this));
        (bool deficit, uint256 amountWant) = abi.decode(data, (bool, uint256));

        return FlashMintLib.loanLogic(deficit, amount, amountWant, cToken);
    }

     

    function ethToWant(uint256 _amtInWei) public view override returns (uint256) {
        return priceCheck(weth, address(want), _amtInWei);
    }

    function liquidateAllPositions() internal override returns (uint256 _amountFreed) {
        (_amountFreed, ) = liquidatePosition(vault.debtOutstanding());
        (uint256 deposits, uint256 borrows) = getCurrentPosition();

        uint256 position = deposits.sub(borrows);

         
        if (!forceMigrate) {
            require(position < minWant);
        }
    }

    function mgtm_check() internal view {
        require(msg.sender == governance() || msg.sender == vault.management() || msg.sender == strategist, "!authorized");
    }

    modifier management() {
        mgtm_check();
        _;
    }
}

 

contract LevCompFactory {
    address public immutable original;

    event Cloned(address indexed clone);
    event Deployed(address indexed original);

    constructor(
        address _vault,
        address _cToken
    ) public {
        Strategy _original = new Strategy(_vault, _cToken);
        emit Deployed(address(_original));

        original = address(_original);
        _original.setStrategist(msg.sender);
    }

    function name() external view returns (string memory) {
        return string(abi.encodePacked("Factory", Strategy(payable(original)).name(), "@", Strategy(payable(original)).apiVersion()));
    }

    function cloneLevComp(
        address _vault,
        address _cToken
    ) external returns (address payable newStrategy) {
         
        bytes20 addressBytes = bytes20(original);
        assembly {
             
            let clone_code := mload(0x40)
            mstore(
                clone_code,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(
                add(clone_code, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            newStrategy := create(0, clone_code, 0x37)
        }

        Strategy(newStrategy).initialize(_vault, _cToken);
        Strategy(newStrategy).setStrategist(msg.sender);

        emit Cloned(newStrategy);
    }
}