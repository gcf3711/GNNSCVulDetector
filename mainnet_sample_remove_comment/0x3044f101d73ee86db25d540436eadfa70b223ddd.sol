 

 

 
pragma solidity ^0.8.6;

 
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

contract Ownable {
    address public _owner;

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
}

 

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
         
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20 is IERC20,Ownable{
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    uint256 private _originExchangeRate = 1000000000;
    uint256 private _exchangeRate = 1000000000; 
    uint256 private _tokenRaised = 0;
    uint256 private _allPresale = formatDecimals(1000000000000);

    event IssueToken(address indexed _to, uint256 _value);

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

     
    function tokenRaised() internal view returns (uint256) {
        return _tokenRaised;
    }

    function currentExchageRate() internal returns (uint256) {
        uint256 rate = _tokenRaised.mul(100).div(_allPresale);
        uint256 percent = rate.div(25);
        if(percent>3){
            percent = 3;
        }

         _exchangeRate = _originExchangeRate.sub(_originExchangeRate.mul(25).mul(percent).div(100));
     
        return _exchangeRate;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

      
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

     
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

     
    function formatDecimals(uint256 value) internal pure returns (uint256 ) {
        return value * 10 ** 18;
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

     
    receive() external payable {
        _exchangeRate = currentExchageRate();
        uint256 tokens = msg.value.mul(_exchangeRate);
        if(tokens + _tokenRaised >= _allPresale){
            tokens = _allPresale.sub(_tokenRaised);
        }
        require(tokens + _tokenRaised <= _totalSupply);
         _tokenRaised = _tokenRaised.add(tokens);
        require(_balances[_owner] >= tokens);
        _balances[_owner] -= tokens;
        _balances[msg.sender] += tokens;

        emit IssueToken(msg.sender, tokens); 
    }

}

 

 
contract LoserDoge is ERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;

     
    constructor(string memory tokenName, string memory tokenSymbol, uint256 totalSupply, address payable feeReceiver, address tokenOwnerAddress) payable {
      _name = tokenName;
      _symbol = tokenSymbol;
      totalSupply = formatDecimals(totalSupply);
       
      _owner = tokenOwnerAddress;
      _mint(tokenOwnerAddress, totalSupply);

       
      feeReceiver.transfer(msg.value);
    }

     
    function burn(uint256 value) public {
      _burn(msg.sender, value);
    }

     

     
    function name() public view returns (string memory) {
      return _name;
    }

     
    function symbol() public view returns (string memory) {
      return _symbol;
    }

     
    function decimals() public view returns (uint8) {
      return _decimals;
    }

}