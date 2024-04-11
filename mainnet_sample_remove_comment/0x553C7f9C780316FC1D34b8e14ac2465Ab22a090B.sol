 


 
pragma solidity ^0.8.0;

 

interface IERC20 {

     
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

 
pragma solidity ^0.8.0;



interface IRecoverable is IERC20{

    function claimPeriod() external view returns (uint256);
    
    function notifyClaimMade(address target) external;

    function notifyClaimDeleted(address target) external;

    function getCollateralRate(IERC20 collateral) external view returns(uint256);

    function recover(address oldAddress, address newAddress) external;

}

 
 
 
 
 
 
 
 
 
 
 

pragma solidity ^0.8.0;




 

abstract contract ERC20Flaggable is IERC20 {

     
     
    uint256 constant private INFINITE_ALLOWANCE = 2**255;

    uint256 private constant FLAGGING_MASK = 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000;

     
     
     
     
     
     
     

    mapping (address => uint256) private _balances;  

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint8 public override decimals;

    event NameChanged(string name, string symbol);

    constructor(uint8 _decimals) {
        decimals = _decimals;
    }

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
        return uint224 (_balances [account]);
    }

    function hasFlag(address account, uint8 number) external view returns (bool) {
        return hasFlagInternal(account, number);
    }

    function setFlag(address account, uint8 index, bool value) internal {
        uint256 flagMask = 1 << (index + 224);
        uint256 balance = _balances [account];
        if ((balance & flagMask == flagMask) != value) {
            _balances [account] = balance ^ flagMask;
        }
    }

    function hasFlagInternal(address account, uint8 number) internal view returns (bool) {
        uint256 flag = 0x1 << (number + 224);
        return _balances[account] & flag == flag;
    }

     
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance < INFINITE_ALLOWANCE){
             
             
            _allowances[sender][msg.sender] = currentAllowance - amount;
        }
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        _beforeTokenTransfer(sender, recipient, amount);
        decreaseBalance(sender, amount);
        increaseBalance(recipient, amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function transferAndCall(address recipient, uint amount, bytes calldata data) external virtual returns (bool) {
        return transfer (recipient, amount) 
            && IERC677Receiver (recipient).onTokenTransfer (msg.sender, amount, data);
    }

     
    function _mint(address recipient, uint256 amount) internal virtual {
        _beforeTokenTransfer(address(0), recipient, amount);
        _totalSupply += amount;
        increaseBalance(recipient, amount);
        emit Transfer(address(0), recipient, amount);
    }

    function increaseBalance(address recipient, uint256 amount) private {
        require(recipient != address(0x0), "0x0");  
        uint256 oldBalance = _balances[recipient];
        uint256 newBalance = oldBalance + amount;
        require(oldBalance & FLAGGING_MASK == newBalance & FLAGGING_MASK, "overflow");
        _balances[recipient] = newBalance;
    }

      
    function _burn(address account, uint256 amount) internal virtual {
        _beforeTokenTransfer(account, address(0), amount);

        _totalSupply -= amount;
        decreaseBalance(account, amount);
        emit Transfer(account, address(0), amount);
    }

    function decreaseBalance(address sender, uint256 amount) private {
        uint256 oldBalance = _balances[sender];
        uint256 newBalance = oldBalance - amount;
        require(oldBalance & FLAGGING_MASK == newBalance & FLAGGING_MASK, "underflow");
        _balances[sender] = newBalance;
    }

     
    function _approve(address owner, address spender, uint256 value) internal {
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

     
      
    function _beforeTokenTransfer(address from, address to, uint256 amount) virtual internal {
         
    }

}

 
 
 
 
 
 
 
 

pragma solidity ^0.8.0;

 
contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor (address initialOwner) {
        owner = initialOwner;
        emit OwnershipTransferred(address(0), owner);
    }

     
    function transferOwnership(address newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }
}
 

pragma solidity ^0.8.0;




contract ERC20Named is ERC20Flaggable, Ownable {

    string public override name;
    string public override symbol;

    constructor(string memory _symbol, string memory _name, uint8 _decimals, address _admin) ERC20Flaggable(_decimals) Ownable(_admin) {
        setNameInternal(_symbol, _name);
    }

    function setName(string memory _symbol, string memory _name) external onlyOwner {
        setNameInternal(_symbol, _name);
    }

    function setNameInternal(string memory _symbol, string memory _name) internal {
        symbol = _symbol;
        name = _name;
        emit NameChanged(_name, _symbol);
    }

}

 
pragma solidity ^0.8.0;





 
abstract contract ERC20Recoverable is ERC20Flaggable, IRecoverable {

    uint8 private constant FLAG_CLAIM_PRESENT = 10;

     
    IERC20 public customCollateralAddress;
     
    uint256 public customCollateralRate;

    uint256 constant CLAIM_PERIOD = 180 days;

    IRecoveryHub public immutable recovery;

    constructor(IRecoveryHub recoveryHub){
        recovery = recoveryHub;
    }

     
    function getCollateralRate(IERC20 collateralType) public override virtual view returns (uint256) {
        if (address(collateralType) == address(this)) {
            return 1;
        } else if (collateralType == customCollateralAddress) {
            return customCollateralRate;
        } else {
            return 0;
        }
    }

    function claimPeriod() external pure override returns (uint256){
        return CLAIM_PERIOD;
    }

     
    function _setCustomClaimCollateral(IERC20 collateral, uint256 rate) internal {
        customCollateralAddress = collateral;
        if (address(customCollateralAddress) == address(0)) {
            customCollateralRate = 0;  
        } else {
            require(rate > 0, "zero");
            customCollateralRate = rate;
        }
    }

    function getClaimDeleter() virtual public view returns (address);

    function transfer(address recipient, uint256 amount) override(ERC20Flaggable, IERC20) virtual public returns (bool) {
        require(super.transfer(recipient, amount), "transfer");
        if (hasFlagInternal(msg.sender, FLAG_CLAIM_PRESENT)){
            recovery.clearClaimFromToken(msg.sender);
        }
        return true;
    }

    function notifyClaimMade(address target) external override {
        require(msg.sender == address(recovery), "not recovery");
        setFlag(target, FLAG_CLAIM_PRESENT, true);
    }

    function notifyClaimDeleted(address target) external override {
        require(msg.sender == address(recovery), "not recovery");
        setFlag(target, FLAG_CLAIM_PRESENT, false);
    }

    function deleteClaim(address lostAddress) external {
        require(msg.sender == getClaimDeleter(), "not claim deleter");
        recovery.deleteClaim(lostAddress);
    }

    function recover(address oldAddress, address newAddress) external override {
        require(msg.sender == address(recovery), "not recovery");
        _transfer(oldAddress, newAddress, balanceOf(oldAddress));
    }

}

 
pragma solidity ^0.8.0;

interface IShares {
	function burn(uint256) external;

	function totalShares() external view returns (uint256);
}
 
pragma solidity ^0.8.0;





 
abstract contract ERC20Allowlistable is ERC20Flaggable, Ownable {

  uint8 private constant TYPE_DEFAULT = 0x0;
  uint8 private constant TYPE_ALLOWLISTED = 0x1;
  uint8 private constant TYPE_FORBIDDEN = 0x2;
  uint8 private constant TYPE_POWERLISTED = 0x4;
   

  uint8 private constant FLAG_INDEX_ALLOWLIST = 20;
  uint8 private constant FLAG_INDEX_FORBIDDEN = 21;
  uint8 private constant FLAG_INDEX_POWERLIST = 22;

  event AddressTypeUpdate(address indexed account, uint8 addressType);

  bool public restrictTransfers;

  constructor(){
  }

   
  function setApplicable(bool transferRestrictionsApplicable) external onlyOwner {
    setApplicableInternal(transferRestrictionsApplicable);
  }

  function setApplicableInternal(bool transferRestrictionsApplicable) internal {
    restrictTransfers = transferRestrictionsApplicable;
     
     
    if (transferRestrictionsApplicable){
      setTypeInternal(address(0x0), TYPE_POWERLISTED);
    } else {
      setTypeInternal(address(0x0), TYPE_DEFAULT);
    }
  }

  function setType(address account, uint8 typeNumber) public onlyOwner {
    setTypeInternal(account, typeNumber);
  }

   
  function setTypeInternal(address account, uint8 typeNumber) internal {
    setFlag(account, FLAG_INDEX_ALLOWLIST, typeNumber == TYPE_ALLOWLISTED);
    setFlag(account, FLAG_INDEX_FORBIDDEN, typeNumber == TYPE_FORBIDDEN);
    setFlag(account, FLAG_INDEX_POWERLIST, typeNumber == TYPE_POWERLISTED);
    emit AddressTypeUpdate(account, typeNumber);
  }

  function setType(address[] calldata addressesToAdd, uint8 value) public onlyOwner {
    for (uint i=0; i<addressesToAdd.length; i++){
      setType(addressesToAdd[i], value);
    }
  }

   
  function canReceiveFromAnyone(address account) public view returns (bool) {
    return hasFlagInternal(account, FLAG_INDEX_ALLOWLIST) || hasFlagInternal(account, FLAG_INDEX_POWERLIST);
  }

   
  function isForbidden(address account) public view returns (bool){
    return hasFlagInternal(account, FLAG_INDEX_FORBIDDEN);
  }

   
  function isPowerlisted(address account) public view returns (bool) {
    return hasFlagInternal(account, FLAG_INDEX_POWERLIST);
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) override virtual internal {
    super._beforeTokenTransfer(from, to, amount);
     
     
    if (canReceiveFromAnyone(to)){
       
    } else if (isForbidden(to)){
       
      require(!restrictTransfers, "not allowed");
      setFlag(to, FLAG_INDEX_FORBIDDEN, false);
    } else {
      if (isPowerlisted(from)){
         
         
        setFlag(to, FLAG_INDEX_ALLOWLIST, true);
      }
       
      else if (hasFlagInternal(from, FLAG_INDEX_ALLOWLIST)){
         
        require(!restrictTransfers, "not allowed");
        setFlag(from, FLAG_INDEX_ALLOWLIST, false);
      } else if (isForbidden(from)){
        require(!restrictTransfers, "not allowed");
        setFlag(from, FLAG_INDEX_FORBIDDEN, false);
      }
    }
  }

}

 
pragma solidity ^0.8.0;






 
contract Shares is ERC20Recoverable, ERC20Named, IShares{

    string public terms;

    uint256 public override totalShares;  
    uint256 public invalidTokens;

    event Announcement(string message);
    event TokensDeclaredInvalid(address indexed holder, uint256 amount, string message);
    event ChangeTerms(string terms);
    event ChangeTotalShares(uint256 total);

    constructor(
        string memory _symbol,
        string memory _name,
        string memory _terms,
        uint256 _totalShares,
        address _owner,
        IRecoveryHub _recoveryHub
    )
        ERC20Named(_symbol, _name, 0, _owner) 
        ERC20Recoverable(_recoveryHub)
    {
        totalShares = _totalShares;
        terms = _terms;
        invalidTokens = 0;
        _recoveryHub.setRecoverable(false); 
    }

    function setTerms(string memory _terms) external onlyOwner {
        terms = _terms;
        emit ChangeTerms(_terms);
    }

     
    function setTotalShares(uint256 _newTotalShares) external onlyOwner() {
        require(_newTotalShares >= totalValidSupply(), "below supply");
        totalShares = _newTotalShares;
        emit ChangeTotalShares(_newTotalShares);
    }

     
    function announcement(string calldata message) external onlyOwner() {
        emit Announcement(message);
    }

     
    function setCustomClaimCollateral(IERC20 collateral, uint256 rate) external onlyOwner() {
        super._setCustomClaimCollateral(collateral, rate);
    }

    function getClaimDeleter() public override view returns (address) {
        return owner;
    }

     
    function declareInvalid(address holder, uint256 amount, string calldata message) external onlyOwner() {
        uint256 holderBalance = balanceOf(holder);
        require(amount <= holderBalance, "amount too high");
        invalidTokens += amount;
        emit TokensDeclaredInvalid(holder, amount, message);
    }

     
    function totalValidSupply() public view returns (uint256) {
        return totalSupply() - invalidTokens;
    }

     
    function mintAndCall(address shareholder, address callee, uint256 amount, bytes calldata data) external {
        mint(callee, amount);
        require(IERC677Receiver(callee).onTokenTransfer(shareholder, amount, data));
    }

    function mint(address target, uint256 amount) public onlyOwner {
        _mint(target, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(totalValidSupply() + amount <= totalShares, "total");
        super._mint(account, amount);
    }

    function transfer(address to, uint256 value) virtual override(ERC20Recoverable, ERC20Flaggable) public returns (bool) {
        return super.transfer(to, value);
    }

     
    function burn(uint256 _amount) override external {
        _transfer(msg.sender, address(this), _amount);
        _burn(address(this), _amount);
    }

}

 
pragma solidity ^0.8.0;

interface IERC677Receiver {
    
    function onTokenTransfer(address from, uint256 amount, bytes calldata data) external returns (bool);

}

 
pragma solidity ^0.8.0;

interface IRecoveryHub {

    function setRecoverable(bool flag) external;
    
     
    function deleteClaim(address target) external;

     
    function clearClaimFromToken(address holder) external;

}

 
pragma solidity ^0.8.0;





contract AllowlistShares is Shares, ERC20Allowlistable {

  constructor(
    string memory _symbol,
    string memory _name,
    string memory _terms,
    uint256 _totalShares,
    IRecoveryHub _recoveryHub,
    address _owner
  )
    Shares(_symbol, _name, _terms, _totalShares, _owner, _recoveryHub)
    ERC20Allowlistable()
  {
     
  }

  function transfer(address recipient, uint256 amount) override(ERC20Flaggable, Shares) virtual public returns (bool) {
    return super.transfer(recipient, amount); 
  }

  function _mint(address account, uint256 amount) internal override(ERC20Flaggable, Shares) {
      super._mint(account, amount);
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) virtual override(ERC20Flaggable, ERC20Allowlistable) internal {
    super._beforeTokenTransfer(from, to, amount);
  }

}
