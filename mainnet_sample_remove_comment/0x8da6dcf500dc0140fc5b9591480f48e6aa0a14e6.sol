 
pragma abicoder v2;

 

 
pragma solidity =0.7.6;


 

 
abstract contract Token {
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
}

abstract contract pToken {
    function redeem(uint256 _value, string memory destinationAddress, bytes4 destinationChainId) public virtual returns (bool _success);
}

interface Curve {
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy, address receiver) external returns (uint256);
}

abstract contract WETH {
    function deposit() external virtual payable;
    function withdraw(uint256 amount) external virtual;    
    function approve(address guy, uint256 wad) external virtual;
}

 
 
 
 
 
 
 
 
 
 
 

 
 
 


interface ISwapRouter {
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

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

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

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

interface IUniswapRouter is ISwapRouter {    
    function wrapETH(uint256 value) external payable;
    function refundETH() external payable;
}



 

contract BTCETHSwap {

    fallback() external {
        revert();
    }

     
    address public PBTC_ADDRESS = address(0x62199B909FB8B8cf870f97BEf2cE6783493c4908); 
    address public WBTC_ADDRESS = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); 
    address public WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public CURVE_PBTC_POOL  = address(0xC9467E453620f16b57a34a770C6bceBECe002587);

    int128 public CURVE_WBTC_INDEX = 2;
    int128 public CURVE_PBTC_INDEX = 0;
    
    bytes4 public PTOKENS_BTC_CHAINID = 0x01ec97de;


     
    IUniswapRouter public constant uniswapRouter = IUniswapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);

     
    constructor() {}

     
    function swapBTCforETH (uint256 amount, address payable recipient) public payable 
    {
        Token(PBTC_ADDRESS).transferFrom(msg.sender, address(this), amount);

         
        uint256 amount_wbtc = CurveSwap(
            false,
            amount
        );

         
        uint256 amountETH = Uniswap(
            WBTC_ADDRESS,
            WETH_ADDRESS,
            amount_wbtc,
            recipient,
            3000
        );

        WETH(WETH_ADDRESS).withdraw(amountETH);
    }

     
    function swapETHforBTC (string memory recipientBtcAddress) external payable 
    {
        uint256 amountETH = msg.value;

         
        uint256 amount_WBTC = Uniswap(
            WETH_ADDRESS,
            WBTC_ADDRESS,
            amountETH,
            address(this),
            3000
        );

         

         
         
         
         
         

         
         
         
         
         
         
    }



     
    function Uniswap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address recipient,
        uint24 fee) internal returns (uint256)
    {

         
         
         
         
         
         
         
         
         
         
         

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            recipient,  
            block.timestamp + 15,
            amountIn,
            1,
            uint160(0)
        );

        uint256 amountOut = uniswapRouter.exactInputSingle{value: amountIn}(params);
        uniswapRouter.refundETH();
    
         
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");

        return amountOut;
    }

     
    function CurveSwap(bool wtop, uint256 amountSell) internal returns (uint256)
    {
        int128 i;
        int128 j;

        if (wtop)
        {
            i = CURVE_WBTC_INDEX;
            j = CURVE_PBTC_INDEX;
        }
        else
        {
            i = CURVE_PBTC_INDEX;
            j = CURVE_WBTC_INDEX;
        }
        
        Curve(CURVE_PBTC_POOL).exchange_underlying(i, j, amountSell, 0, address(this));
    }    

     
    receive() payable external {}
}