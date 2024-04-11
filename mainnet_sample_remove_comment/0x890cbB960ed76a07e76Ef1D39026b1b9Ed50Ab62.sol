 

 

 
pragma solidity >=0.7.0;

 
library SafeMath {
     
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

 
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

     
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

         
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

     
    function div(int256 a, int256 b) internal pure returns (int256) {
         
        require(b != -1 || a != MIN_INT256);

         
        return a / b;
    }

     
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

     
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

     
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
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

 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name_, string memory symbol_) {
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
}


interface IOracle{
    function quote() external returns (uint256 amountB);
    function sync() external;
}

contract RapidGainz is ERC20 {
  using SafeMath for uint256;
  using SafeMathInt for int256;
  event LogRebase(
    uint256 epoch,
    uint256 baseRate, 
    uint256 exchangeRate, 
    uint256 targetRate, 
    int256 supplyDelta,
    uint256 time
  );

  event GetRebaseValues(
      uint256 exchangeRate,
      uint256 targetRate,
      int256 supplyDelta
  );

  address private controller;
  mapping (address => uint256) private _gonsPerOwner;
  mapping (address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint256 private _gonsPerFragment;
  uint256 private MAX_UINT256 = ~uint256(0);
  uint256 private MAX_ALLOWED_SUPPLY = ~uint128(0);
  uint256 private DECIMALS = 18;
  uint256 private INITIAL_FRAGMENTS_SUPPLY = 100000000 * 10**DECIMALS;
  uint256 private TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

   
  uint256 private targetRateMultiplier = 1050;
  uint256 private targetRateDivisor = 1000;

   
  uint256 public maxTransferAmountInPercentage = 1000;
  int256 public dampener = 1;

  IOracle oracle;
  bool isOracleInitialized = false;
  bool public isLaunchFinished = false;
  bool public isInCommunityStage = false;

  uint256 public rebaseCooldown = 3 hours;
  uint256 public lastRebaseTimestampSec;
  uint256 public epoch;
  uint256 public baseRate;
  
  constructor(address _issuer, address _controller) ERC20("RapidGainz", "GAINZ"){
    controller = _controller;
    _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    _gonsPerOwner[_issuer] = TOTAL_GONS;
    lastRebaseTimestampSec = block.timestamp;
    epoch = 0;
    emit Transfer(address(0x0), _issuer, _totalSupply);
  }

  modifier onlyController{
    require(msg.sender == controller, "Not the trusted controller");
    _;
  }

  modifier managedFunction{
      require(msg.sender == controller || isInCommunityStage == true);
      _;
  }

  function setRebaseCooldown(uint256 _newRebaseCooldown) onlyController public{
      rebaseCooldown = _newRebaseCooldown;
  }

  function setIsLaunchFinished(bool _newIsLaunchFinishedValue) onlyController public{
      isLaunchFinished = _newIsLaunchFinishedValue;
  }

  function setIsInCommunityStage(bool _isInCommunityStage) onlyController public{
    isInCommunityStage = _isInCommunityStage;
  }

  function setDampener(int256 _newDampeningFactor) onlyController public {
      dampener = _newDampeningFactor;
  }

  function setMaxTransferAmountInPercentage(uint256 _maxTransferAmountInPercentage) onlyController public{
      maxTransferAmountInPercentage = _maxTransferAmountInPercentage;
  }

  function setBaseRate(uint256 _newBaseRate) onlyController public{
      baseRate = _newBaseRate;
  }

  function setTargetRatePercentage(uint256 _rateMultiplier) onlyController public{
    targetRateMultiplier = _rateMultiplier;
  }

  function setOracle(address _oracleAddress) onlyController public{
    oracle = IOracle(_oracleAddress);
    baseRate = oracle.quote();
    baseRate = (baseRate * targetRateDivisor) / targetRateMultiplier;
    isOracleInitialized = true;
  }

  function setController(address _newControllerAddress) onlyController public{
    controller = _newControllerAddress;
  }

  function totalSupply() override public view returns(uint256){
    return _totalSupply;
  }

  function balanceOf(address who) override public view returns (uint256){
    return _gonsPerOwner[who].div(_gonsPerFragment);
  }

  function _transfer(address sender, address recipient, uint256 amount) override internal virtual {
    if(isLaunchFinished){
        require(_totalSupply.div(maxTransferAmountInPercentage) >= amount , "Cannot transfer more then certain percent of total supply.");
    }
    uint256 valueInGons = amount.mul(_gonsPerFragment);
    _gonsPerOwner[sender] = _gonsPerOwner[sender].sub(valueInGons);
    _gonsPerOwner[recipient] = _gonsPerOwner[recipient].add(valueInGons);
    emit Transfer(sender, recipient, amount);
  }

  function getRebaseValues() public returns (uint256, uint256, int256){
    uint256 exchangeRate = oracle.quote();
    uint256 targetRate = baseRate;
    int256 supplyDelta = 0;
    int256 diff = 100 - (
        (int256(exchangeRate) * int256(100)) 
        / 
        int256(targetRate)
    );
    if(diff > 0 || diff < 0 ){
		supplyDelta = (int256(_totalSupply) * 10 * diff) / 1000;
	}

    emit GetRebaseValues(
      exchangeRate, 
      targetRate, 
      supplyDelta.div(dampener) 
    );

    return (
      exchangeRate, 
      targetRate, 
      supplyDelta.div(dampener)
    );
  }

  function rebase() managedFunction external returns(uint256){
    require(isOracleInitialized);
    require(lastRebaseTimestampSec.add(rebaseCooldown) < block.timestamp, "Rebase requested too soon");
    lastRebaseTimestampSec = block.timestamp;
    epoch = epoch.add(1);
    (
      uint256 exchangeRate, 
      uint256 targetRate, 
      int256 supplyDelta
    ) = getRebaseValues();

    if(supplyDelta == 0){
      emit LogRebase(
        epoch, 
        baseRate,
        exchangeRate, 
        baseRate,
        supplyDelta,
        block.timestamp
      );
      return _totalSupply;      
    }

    if(supplyDelta < 0){
      assert(_totalSupply.sub(uint256(supplyDelta.abs())) <= MAX_ALLOWED_SUPPLY);
      _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
    }else{
      assert(_totalSupply.add(uint256(supplyDelta.abs())) <= MAX_ALLOWED_SUPPLY);
      _totalSupply = _totalSupply.add(uint256(supplyDelta.abs()));
    }

    _gonsPerFragment = TOTAL_GONS.div(_totalSupply, "Failed at gons per fragment total supply division"); 

    assert(_totalSupply <= MAX_ALLOWED_SUPPLY);

    baseRate = targetRate.mul(targetRateDivisor).div(targetRateMultiplier, "Failed at new base rate setting");

    emit LogRebase(
      epoch, 
      baseRate,
      exchangeRate, 
      targetRate,
      supplyDelta,
      block.timestamp
    );

    oracle.sync();
    return _totalSupply;
  }

  function manualRebase(bool isPositive) onlyController public{
    if(isPositive){
        _totalSupply = _totalSupply.mul(targetRateMultiplier).div(targetRateDivisor);
    }else{
        _totalSupply = _totalSupply.mul(targetRateDivisor).div(targetRateMultiplier);
    }
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply, "Failed at gons per fragment total supply division");
    oracle.sync();
  }
}