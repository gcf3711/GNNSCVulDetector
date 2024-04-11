 

 

 

 
pragma solidity >=0.6.2 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

interface IERC777 {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function granularity() external view returns (uint256);

     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address owner) external view returns (uint256);

     
    function send(address recipient, uint256 amount, bytes calldata data) external;

     
    function burn(uint256 amount, bytes calldata data) external;

     
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

     
    function authorizeOperator(address operator) external;

     
    function revokeOperator(address operator) external;

     
    function defaultOperators() external view returns (address[] memory);

     
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

     
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

interface IERC777Recipient {
     
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

interface IERC777Sender {
     
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

         
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

interface IERC1820Registry {
     
    function setManager(address account, address newManager) external;

     
    function getManager(address account) external view returns (address);

     
    function setInterfaceImplementer(address account, bytes32 _interfaceHash, address implementer) external;

     
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

     
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

     
    function updateERC165Cache(address account, bytes4 interfaceId) external;

     
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

     
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

contract CRFI is Context, IERC777, IERC20,IERC777Recipient {
  
   
  using SafeMath for uint256;
  using Address for address;

   
  IERC1820Registry constant internal _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
  
   
   

   
  bytes32 constant private _TOKENS_SENDER_INTERFACE_HASH =
    0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

   
  bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
    0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

   
  address public superAdmin;
  mapping(address => uint256) public admins;

   
   
   
   
   
   
  enum Erc777ModeType {disabled, whitelist, blacklist, enabled}
  Erc777ModeType public erc777Mode;
  mapping(address=>bool) public blacklist;
  mapping(address=>bool) public whitelist;
  
   
  mapping(address => uint256) private _balances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

   
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping(address=>bool) private _freezeAddress;

   
   
  address[] private _defaultOperatorsArray;

   
  mapping(address => bool) private _defaultOperators;

   
  mapping(address => mapping(address => bool)) private _operators;
  mapping(address => mapping(address => bool)) private _revokedDefaultOperators;


   
   
  constructor(address[] memory defaultOperators_
              )
      {
        _name = "Crossfi";
        _symbol = "CRFI";

        _defaultOperatorsArray = defaultOperators_;
        for (uint256 i = 0; i < _defaultOperatorsArray.length; i++) {
          _defaultOperators[_defaultOperatorsArray[i]] = true;
        }

         
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));

        superAdmin = msg.sender;

         
        ChangeMode(Erc777ModeType.disabled);

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));

        _mint(msg.sender, 1e26, "", "");
      }

   
  modifier IsAdmin() {
    require(msg.sender == superAdmin || admins[msg.sender] == 1, "only admin");
    _;
  }

  modifier IsSuperAdmin() {
    require(superAdmin == msg.sender, "only super admin");
    _;
  }

  modifier CheckFreeze(address addr){
    require(_freezeAddress[addr] == false, "account is freeze");
    _;
  }

   
  function AddAdmin(address adminAddr)
    public
    IsSuperAdmin(){
    require(admins[adminAddr] == 0, "already add this admin");
    admins[adminAddr] = 1;
  }

  function DelAdmin(address adminAddr)
    public
    IsSuperAdmin(){
    require(admins[adminAddr] == 1, "this addr is not admin");
    admins[adminAddr] = 0;
  }

  function ChangeSuperAdmin(address suAdminAddr)
    public
    IsSuperAdmin(){
    require(suAdminAddr != address(0x0), "empty new super admin");

    superAdmin = suAdminAddr;
  }

   
  function AddBlackList(address[] memory addrs)
    public
    IsAdmin(){

    for(uint256 i = 0; i < addrs.length; i++){
      address addr = addrs[i];
      if(blacklist[addr]){
        continue;
      }
      blacklist[addr] = true;
    }
  }

  function DelBlackList(address[] memory addrs)
    public
    IsAdmin(){

    for(uint256 i = 0; i < addrs.length; i++){
      address addr = addrs[i];
      if(!blacklist[addr]){
        continue;
      }
      blacklist[addr] = false;
    }
  }

  function AddWhiteList(address[] memory addrs)
    public
    IsAdmin(){

    for(uint256 i = 0; i < addrs.length; i++){
      address addr = addrs[i];
      if(whitelist[addr]){
        continue;
      }
      whitelist[addr] = true;
    }
  }

  function DelWhiteList(address[] memory addrs)
    public
    IsAdmin(){

    for(uint256 i = 0; i < addrs.length; i++){
      address addr = addrs[i];
      if(!whitelist[addr] ){
        continue;
      }
      whitelist[addr] = false;
    }
  }

  function ChangeMode(Erc777ModeType mode)
    public
    IsAdmin(){

    erc777Mode = mode;
  }

  function FreezeAddr(address[] memory addrs)
    public
    IsAdmin(){
    for(uint256 i = 0; i < addrs.length; i++){
      address addr = addrs[i];
      if(_freezeAddress[addr] == true){
        continue;
      }
      _freezeAddress[addr] = true;
    }
  }

  function UnfreezeAddr(address[] memory addrs)
    public
    IsAdmin(){
    for(uint256 i = 0; i < addrs.length; i++){
      address addr = addrs[i];
      if(_freezeAddress[addr] == false){
        continue;
      }
      _freezeAddress[addr] = false;
    }
  }
  
  
   
  function name() public view virtual override returns (string memory) {
    return _name;
  }

   
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

   
  function decimals() public pure virtual returns (uint8) {
    return 18;
  }

   
  function granularity() public view virtual override returns (uint256) {
    return 1;
  }

   
  function totalSupply() public view virtual override(IERC20, IERC777) returns (uint256) {
    return _totalSupply;
  }

   
  function balanceOf(address tokenHolder) public view virtual override(IERC20, IERC777) returns (uint256) {
    return _balances[tokenHolder];
  }

  function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData)
    public
    pure
    override{
    revert("can't receive any coin");
  }

   
  function send(address recipient, uint256 amount, bytes memory data) public virtual override  CheckFreeze(_msgSender()){
    _send(_msgSender(), recipient, amount, data, "", true);
  }

   
  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    CheckFreeze(_msgSender())
    returns (bool) {
    require(recipient != address(0), "ERC777: transfer to the zero address");

    address from = _msgSender();

    bool erc777Enable = _enableERC777(from, recipient);

    if(erc777Enable){
      _callTokensToSend(from, from, recipient, amount, "", "");
    }

    _move(from, from, recipient, amount, "", "", erc777Enable);

    if(erc777Enable){
      _callTokensReceived(from, from, recipient, amount, "", "", false);
    }

    return true;
  }

   
  function burn(uint256 amount, bytes memory data) public virtual override  CheckFreeze(_msgSender()){
    _burn(_msgSender(), amount, data, "");
  }

   
  function isOperatorFor(address operator, address tokenHolder) public view virtual override returns (bool) {
    return operator == tokenHolder ||
      (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
      _operators[tokenHolder][operator];
  }

   
  function authorizeOperator(address operator) public virtual override  {
    require(_msgSender() != operator, "ERC777: authorizing self as operator");

    if (_defaultOperators[operator]) {
      delete _revokedDefaultOperators[_msgSender()][operator];
    } else {
      _operators[_msgSender()][operator] = true;
    }

    emit AuthorizedOperator(operator, _msgSender());
  }

   
  function revokeOperator(address operator) public virtual override  {
    require(operator != _msgSender(), "ERC777: revoking self as operator");

    if (_defaultOperators[operator]) {
      _revokedDefaultOperators[_msgSender()][operator] = true;
    } else {
      delete _operators[_msgSender()][operator];
    }

    emit RevokedOperator(operator, _msgSender());
  }

   
  function defaultOperators() public view virtual override returns (address[] memory) {
    return _defaultOperatorsArray;
  }

   
  function operatorSend(
                        address sender,
                        address recipient,
                        uint256 amount,
                        bytes memory data,
                        bytes memory operatorData
                        )
    public
    virtual
    override
    CheckFreeze(sender)
  {
    require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
    _send(sender, recipient, amount, data, operatorData, true);
  }

   
  function operatorBurn(address account, uint256 amount, bytes memory data, bytes memory operatorData) public virtual override CheckFreeze(account){
    require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
    _burn(account, amount, data, operatorData);
  }

   
  function allowance(address holder, address spender) public view virtual override returns (uint256) {
    return _allowances[holder][spender];
  }

   
  function approve(address spender, uint256 value) public virtual override returns (bool) {
    address holder = _msgSender();
    _approve(holder, spender, value);
    return true;
  }

   
  function transferFrom(address holder, address recipient, uint256 amount) public virtual override CheckFreeze(holder) returns (bool) {
    require(recipient != address(0), "ERC777: transfer to the zero address");
    require(holder != address(0), "ERC777: transfer from the zero address");

    address spender = _msgSender();

    bool erc777Enable = _enableERC777(holder, recipient);

    if(erc777Enable){
      _callTokensToSend(spender, holder, recipient, amount, "", "");
    }

    _move(spender, holder, recipient, amount, "", "", erc777Enable);
    _approve(holder, spender, _allowances[holder][spender].sub(amount, "ERC777: transfer amount exceeds allowance"));

    if(erc777Enable){
      _callTokensReceived(spender, holder, recipient, amount, "", "", false);
    }

    return true;
  }
  
   
  function _mint(
                 address account,
                 uint256 amount,
                 bytes memory userData,
                 bytes memory operatorData
                 )
    internal
    virtual
  {
    require(account != address(0), "ERC777: mint to the zero address");

    address operator = _msgSender();

    _beforeTokenTransfer(operator, address(0), account, amount);

     
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);

    _callTokensReceived(operator, address(0), account, amount, userData, operatorData, true);

    emit Minted(operator, account, amount, userData, operatorData);
    emit Transfer(address(0), account, amount);
  }

   
  function _send(
                 address from,
                 address to,
                 uint256 amount,
                 bytes memory userData,
                 bytes memory operatorData,
                 bool requireReceptionAck
                 )
    internal
    virtual
  {
    require(from != address(0), "ERC777: send from the zero address");
    require(to != address(0), "ERC777: send to the zero address");

    address operator = _msgSender();

    _callTokensToSend(operator, from, to, amount, userData, operatorData);

    _move(operator, from, to, amount, userData, operatorData, true);

    _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
  }

   
  function _burn(
                 address from,
                 uint256 amount,
                 bytes memory data,
                 bytes memory operatorData
                 )
    internal
    virtual
  {
    require(from != address(0), "ERC777: burn from the zero address");

    address operator = _msgSender();

    _callTokensToSend(operator, from, address(0), amount, data, operatorData);

    _beforeTokenTransfer(operator, from, address(0), amount);

     
    _balances[from] = _balances[from].sub(amount, "ERC777: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);

    emit Burned(operator, from, amount, data, operatorData);
    emit Transfer(from, address(0), amount);
  }

  function _move(
                 address operator,
                 address from,
                 address to,
                 uint256 amount,
                 bytes memory userData,
                 bytes memory operatorData,
                 bool erc777Enable
                 )
    private
  {
    if(erc777Enable){
      _beforeTokenTransfer(operator, from, to, amount);
    }

    _balances[from] = _balances[from].sub(amount, "ERC777: transfer amount exceeds balance");
    _balances[to] = _balances[to].add(amount);

    emit Sent(operator, from, to, amount, userData, operatorData);
    emit Transfer(from, to, amount);
  }

   
  function _approve(address holder, address spender, uint256 value) internal {
    require(holder != address(0), "ERC777: approve from the zero address");
    require(spender != address(0), "ERC777: approve to the zero address");

    _allowances[holder][spender] = value;
    emit Approval(holder, spender, value);
  }

   
  function _callTokensToSend(
                             address operator,
                             address from,
                             address to,
                             uint256 amount,
                             bytes memory userData,
                             bytes memory operatorData
                             )
    private
  {
    address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
    if (implementer != address(0)) {
      IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
    }
  }

   
  function _callTokensReceived(
                               address operator,
                               address from,
                               address to,
                               uint256 amount,
                               bytes memory userData,
                               bytes memory operatorData,
                               bool requireReceptionAck
                               )
    private
  {
    address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
    if (implementer != address(0)) {
      IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
    } else if (requireReceptionAck) {
      require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
    }
  }

   
  function _beforeTokenTransfer(address operator, address from, address to, uint256 amount) internal virtual { }

  
  function _enableERC777(address from, address to)
    internal
    view
    returns(bool){

    if(erc777Mode == Erc777ModeType.disabled){
      return false;
    }

    if(erc777Mode == Erc777ModeType.enabled){
      return true;
    }

    if(erc777Mode == Erc777ModeType.whitelist){
      return whitelist[from] || whitelist[to];
    }

    if(erc777Mode == Erc777ModeType.blacklist){
      return (!blacklist[from]) && (!blacklist[to]);
    }

    return false;
  }
}