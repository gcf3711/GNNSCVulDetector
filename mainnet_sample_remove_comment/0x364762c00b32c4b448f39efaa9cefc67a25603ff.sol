 

 

 

pragma solidity 0.6.12;


interface ISushiBarEnter { 
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function enter(uint256 amount) external;
}


interface IAaveDeposit {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}


contract Saave {
    ISushiBarEnter constant sushiToken = ISushiBarEnter(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);  
    ISushiBarEnter constant sushiBar = ISushiBarEnter(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);  
    IAaveDeposit constant aave = IAaveDeposit(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);  
    
    constructor() public {
        sushiToken.approve(address(sushiBar), type(uint256).max);  
        sushiBar.approve(address(aave), type(uint256).max);  
    }
    
    
    function saave(uint256 amount) external {
        sushiToken.transferFrom(msg.sender, address(this), amount);  
        sushiBar.enter(amount);  
        aave.deposit(address(sushiBar), sushiBar.balanceOf(address(this)), msg.sender, 0);  
    }
    
    
    function saaveTo(address to, uint256 amount) external {
        sushiToken.transferFrom(msg.sender, address(this), amount);  
        sushiBar.enter(amount);  
        aave.deposit(address(sushiBar), sushiBar.balanceOf(address(this)), to, 0);  
    }
}