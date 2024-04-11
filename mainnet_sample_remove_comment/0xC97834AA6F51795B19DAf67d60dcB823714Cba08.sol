 


 

 
 
 
 
 
 
 
 

pragma solidity >=0.7.0;



interface IAnteTest {
    
    
    
    function testAuthor() external view returns (address);

    
    
    
    function protocolName() external view returns (string memory);

    
    
    
    
    function testedContracts(uint256 i) external view returns (address);

    
    
    
    function testName() external view returns (string memory);

    
    
    
    function checkTestPasses() external returns (bool);
}
 

 
 
 
 
 
 
 
 

pragma solidity >=0.7.0;






abstract contract AnteTest is IAnteTest {
    
    address public override testAuthor;
    
    string public override testName;
    
    string public override protocolName;
    
    address[] public override testedContracts;

    
     
    
    constructor(string memory _testName) {
        testAuthor = msg.sender;
        testName = _testName;
    }

    
    
    function getTestedContracts() external view returns (address[] memory) {
        return testedContracts;
    }

    
    function checkTestPasses() external virtual override returns (bool) {}
}
 

pragma solidity ^0.7.0;







contract AnteAcrossOptimisticBridgeTest is AnteTest("Across Bridge does not rug 70% of its top 3 tokens") {
     
     
     
    address public constant hubPoolAddr = 0xc186fA914353c44b2E33eBE05f21846F1048bEda;

     

     
     
    address public constant wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
     
    address public constant wbtcAddr = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
     
    address public constant usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint256 public constant THRESHOLD = 30;

    IERC20 private constant WETH = IERC20(wethAddr);
    IERC20 private constant WBTC = IERC20(wbtcAddr);
    IERC20 private constant USDC = IERC20(usdcAddr);

    uint256 public immutable wethThreshold;
    uint256 public immutable wbtcThreshold;
    uint256 public immutable usdcThreshold;

    constructor() {
        protocolName = "Across";
        testedContracts = [hubPoolAddr];

        wethThreshold = (WETH.balanceOf(hubPoolAddr) * THRESHOLD) / 100;
        wbtcThreshold = (WBTC.balanceOf(hubPoolAddr) * THRESHOLD) / 100;
        usdcThreshold = (USDC.balanceOf(hubPoolAddr) * THRESHOLD) / 100;
    }

    
    
    function checkTestPasses() external view override returns (bool) {
        return
            wethThreshold < WETH.balanceOf(hubPoolAddr) &&
            wbtcThreshold < WBTC.balanceOf(hubPoolAddr) &&
            usdcThreshold < USDC.balanceOf(hubPoolAddr);
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
