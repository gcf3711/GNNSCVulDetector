 

 

 
pragma solidity ^0.7.6;

library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

 
interface ERC20Interface {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20Base is ERC20Interface {

    using SafeMath for uint256;

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    uint256 public _totalSupply;

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        if (_balances[msg.sender] >= _value && _balances[_to].add(_value) > _balances[_to]) {
            _balances[msg.sender] = _balances[msg.sender].sub(_value);
            _balances[_to] = _balances[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        if (_balances[_from] >= _value && _allowances[_from][msg.sender] >= _value && _balances[_to].add(_value) > _balances[_to]) {
            _balances[_to] = _balances[_to].add(_value);
            _balances[_from] = _balances[_from].sub(_value);
            _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return _balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
      return _allowances[_owner][_spender];
    }
    
    function totalSupply() public override view returns (uint256 total) {
        return _totalSupply;
    }
}

contract WurstcoinNG is ERC20Base {
    
    using SafeMath for uint256;
    
    uint256 constant SUPPLY = 10000000;
    address immutable owner = msg.sender;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor () payable {
        require(SUPPLY > 0, "SUPPLY has to be greater than 0");
        
        _name = "Wurstcoin";
        _symbol = "WURST";
        _decimals = uint8(18);
        _totalSupply = SUPPLY.mul(10 ** uint256(decimals()));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(0x0000000000000000000000000000000000000000, msg.sender, _totalSupply);
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