 

 

 

 

pragma solidity ^0.6.0;


 
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
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

 
 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    
    
    mapping (address => uint256) private _balances;
    mapping(address => bool) public feeExcludedAddress;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint private _decimals = 18;
    uint private _lockTime;
    address public _Owner;
    address public _previousOwner;
    address public _teamAddress = address(0x849558453B35c0f7a939100243ebC834418043a8);
    address public _stakingAddress = address(0xfc8124422d586Eeb68ab4aBAF404e8aC049D5975);
    address public _liquidityPoolAddress = address(0x58BB0c43eF9f4A34410adfbbB32D3Fc5b14d1cA7);
    address public liquidityPair;
    uint public stakingFee = 40;  
    uint public liquidityFee = 40;  
    uint public teamFee = 20;  
    bool public sellLimiter;  
    uint public sellLimit = 50000 * 10 ** 18;  
    
    uint256 public _maxTxAmount = 1000000 * 10**18;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
     
    constructor (string memory _nm, string memory _sym) public {
        _name = _nm;
        _symbol = _sym;
        _Owner = msg.sender;
        feeExcludedAddress[msg.sender] = true;
    }
    
    modifier onlyOwner{
        require(msg.sender == _Owner, 'Only Owner Can Call This Function');
        _;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint) {
        return _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function calculateLiquidityFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(liquidityFee).div(
            10**4
        );
    }
    
    function calculateStakeFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(stakingFee).div(
            10**4
        );
    }
    
    function calculateTeamFee(uint256 _amount) public view returns (uint256) {
        return _amount.mul(teamFee).div(
            10**4
        );
    }
    
    function setStakeFee(uint256 STfee) public onlyOwner{
        stakingFee = STfee;
    }
    
    function setLiquidityFee(uint256 LPfee) public onlyOwner{
        liquidityFee = LPfee;
    }
    
    function setTeamFee(uint256 Tfee) public onlyOwner{
        teamFee = Tfee;
    }
    
    function toggleSellLimit() external onlyOwner() {
        sellLimiter = !sellLimiter;
    }
    
    function setLiquidityPairAddress(address liquidityPairAddress) public onlyOwner{
        liquidityPair = liquidityPairAddress;
    }
    
    function changeStakingAddress(address stakeAddress) public onlyOwner{
        _stakingAddress = stakeAddress;
    }
    
    function changeLPAddress(address LPaddress) public onlyOwner{
        _liquidityPoolAddress = LPaddress;
    }
    
    function changeSellLimit(uint256 _sellLimit) public onlyOwner{
        sellLimit = _sellLimit;
    }
    
    function changeMaxtx(uint256 _maxtx) public onlyOwner{
        _maxTxAmount = _maxtx;
    }
    
    function changeTeamAddress(address Taddress) public onlyOwner{
        _teamAddress = Taddress;
    }
    
    function addExcludedAddress(address excludedA) public onlyOwner{
        feeExcludedAddress[excludedA] = true;
    }
    
    function removeExcludedAddress(address excludedA) public onlyOwner{
        feeExcludedAddress[excludedA] = false;
    }
    
     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_Owner, newOwner);
        _Owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

     
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _Owner;
        _Owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_Owner, address(0));
    }
    
     
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_Owner, _previousOwner);
        _Owner = _previousOwner;
    }
    
    function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
        require(receivers.length != 0, 'Cannot Proccess Null Transaction');
        require(receivers.length == amounts.length, 'Address and Amount array length must be same');
        for (uint256 i = 0; i < receivers.length; i++) {
            transfer(receivers[i], amounts[i]);
        }
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if(feeExcludedAddress[recipient] || feeExcludedAddress[_msgSender()]){
            _transferExcluded(_msgSender(), recipient, amount);
        }else{
            _transfer(_msgSender(), recipient, amount);    
        }
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        if(feeExcludedAddress[recipient] || feeExcludedAddress[sender]){
            _transferExcluded(_msgSender(), recipient, amount);
        }else{
            _transfer(sender, recipient, amount);
        }
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

     
    function _transferExcluded(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(sender != _Owner && recipient != _Owner)
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            
        if(recipient == liquidityPair && balanceOf(liquidityPair) > 0 && sellLimiter){
            require(amount < sellLimit, 'Cannot sell more than sellLimit');
        }

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(sender != _Owner && recipient != _Owner)
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        if(recipient == liquidityPair && balanceOf(liquidityPair) > 0 && sellLimiter){
            require(amount < sellLimit, 'Cannot sell more than sellLimit');
        }
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        uint256 tokenToTransfer = amount.sub(calculateLiquidityFee(amount)).sub(calculateStakeFee(amount)).sub(calculateTeamFee(amount));
        _balances[recipient] += tokenToTransfer;
        _balances[_teamAddress] += calculateTeamFee(amount); 
        _balances[_stakingAddress] += calculateStakeFee(amount);
        _balances[liquidityPair] += calculateLiquidityFee(amount);
        
        emit Transfer(sender, recipient, tokenToTransfer);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) public virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[msg.sender] >= amount,'insufficient balance!');

        _beforeTokenTransfer(account, address(0x000000000000000000000000000000000000dEaD), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0x000000000000000000000000000000000000dEaD), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract Tenup is ERC20 {
    constructor() public ERC20("Tenup", "TUP") {
        _mint(msg.sender, 200000000 ether);  
    }
}