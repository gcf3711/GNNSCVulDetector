 

 

pragma solidity 0.6.12;

 

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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
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
}


interface StakedToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IStakeAndYield {
    function getRewardToken() external view returns(address);
    function totalSupply(uint256 stakeType) external view returns(uint256);
    function totalYieldWithdrawed() external view returns(uint256);
    function notifyRewardAmount(uint256 reward, uint256 stakeType) external;
}

interface IController {
    function withdrawETH(uint256 amount) external;
    function depositForStrategy(uint256 amount, address addr) external;
    function buyForStrategy(
        uint256 amount,
        address rewardToken,
        address recipient
    ) external;
}

interface IYearnVault {
    function depositETH() external payable;
}

interface IYearnWETH{
    function balanceOf(address account) external view returns (uint256);
    function withdraw(uint256 amount, address recipient) external returns(uint256);
    function pricePerShare() external view returns(uint256);
    function deposit(uint256 _amount) external returns(uint256);
}

interface IWETH is StakedToken{
    function withdraw(uint256 amount) external returns(uint256);
}


contract YearnStrategy is Ownable {
    using SafeMath for uint256;

     uint256 public lastEpochTime;
     uint256 public lastBalance;
     uint256 public lastYieldWithdrawed;

     uint256 public yearFeesPercent = 2;

     IStakeAndYield public vault;
     StakedToken public token;


    IController public controller;
    
    IYearnWETH public yweth = IYearnWETH(0xa9fE4601811213c340e850ea305481afF02f5b28);
    IWETH public weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public operator;

    modifier onlyOwnerOrOperator(){
        require(
            msg.sender == owner() || msg.sender == operator,
            "!owner"
        );
        _;
    }

    constructor(
        address _vault,
        address _controller
    ) public{
        vault = IStakeAndYield(_vault);
        controller = IController(_controller);
    }

     
     
    function epoch(uint256 ETHPerToken) public onlyOwnerOrOperator{
        uint256 balance = pendingBalance();
         
        harvest(balance.mul(ETHPerToken).div(1 ether));
        lastEpochTime = block.timestamp;
        lastBalance = lastBalance.add(balance);

        uint256 currentWithdrawd = vault.totalYieldWithdrawed();
        uint256 withdrawAmountToken = currentWithdrawd.sub(lastYieldWithdrawed);
        if(withdrawAmountToken > 0){
            lastYieldWithdrawed = currentWithdrawd;
            uint256 ethWithdrawed = withdrawAmountToken.mul(
                ETHPerToken
            ).div(1 ether);
            withdrawFromYearn(ethWithdrawed);            
        }
    }

    function harvest(uint256 ethBalance) private{
        uint256 rewards = calculateRewards();
        if(ethBalance > rewards){
             
            controller.depositForStrategy(ethBalance.sub(rewards), address(this));
        }else{
             
            rewards = withdrawFromYearn(rewards.sub(ethBalance));
        }
         
        if(rewards > 0){
            controller.buyForStrategy(
                rewards,
                vault.getRewardToken(),
                address(vault)
            );
        }
    }

    function withdrawFromYearn(uint256 ethAmount) private returns(uint256){
        uint256 yShares = yweth.balanceOf(address(this));

        uint256 sharesToWithdraw = ethAmount.div(
            yweth.pricePerShare()
        ).mul(1 ether);
        require(yShares >= sharesToWithdraw, "Not enough shares");

        return yweth.withdraw(sharesToWithdraw, address(controller));
    }

    function calculateRewards() public view returns(uint256){
        uint256 yShares = yweth.balanceOf(address(this));
        uint256 yETHBalance = yShares.mul(
            yweth.pricePerShare()
        ).div(1 ether);

        yETHBalance = yETHBalance.mul(100 - yearFeesPercent).div(100);
        if(yETHBalance > lastBalance){
            return yETHBalance - lastBalance;
        }
        return 0;
    }

    function pendingBalance() public view returns(uint256){
        uint256 vaultBalance = vault.totalSupply(2);
        if(vaultBalance < lastBalance){
            return 0;
        }
        return vaultBalance.sub(lastBalance);
    }

    function getLastEpochTime() public view returns(uint256){
        return lastEpochTime;
    }

    function setYearnFeesPercent(uint256 _val) public onlyOwner{
        yearFeesPercent = _val;
    }

    function setOperator(address _addr) public onlyOwner{
        operator = _addr;
    }

    function setController(address _controller, address _vault) public onlyOwner{
        if(_controller != address(0)){
            controller = IController(_controller);
        }
        if(_vault != address(0)){
            vault = IStakeAndYield(_vault);
        }
    }

    function emergencyWithdrawETH(uint256 amount, address addr) public onlyOwner{
        require(addr != address(0));
        payable(addr).transfer(amount);
    }

    function emergencyWithdrawERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        StakedToken(_tokenAddr).transfer(_to, _amount);
    }
}