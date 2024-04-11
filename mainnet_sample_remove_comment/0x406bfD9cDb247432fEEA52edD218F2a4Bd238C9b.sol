
 

 

pragma solidity 0.5.17;

interface IntVoteInterface {
     
     
    modifier votable(bytes32 _proposalId) {revert("proposal is not votable"); _;}

    event NewProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _numOfChoices,
        address _proposer,
        bytes32 _paramsHash
    );

    event ExecuteProposal(bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _decision,
        uint256 _totalReputation
    );

    event VoteProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _voter,
        uint256 _vote,
        uint256 _reputation
    );

    event CancelProposal(bytes32 indexed _proposalId, address indexed _organization );
    event CancelVoting(bytes32 indexed _proposalId, address indexed _organization, address indexed _voter);

     
    function propose(
        uint256 _numOfChoices,
        bytes32 _proposalParameters,
        address _proposer,
        address _organization
        ) external returns(bytes32);

    function vote(
        bytes32 _proposalId,
        uint256 _vote,
        uint256 _rep,
        address _voter
    )
    external
    returns(bool);

    function cancelVote(bytes32 _proposalId) external;

    function getNumberOfChoices(bytes32 _proposalId) external view returns(uint256);

    function isVotable(bytes32 _proposalId) external view returns(bool);

     
    function voteStatus(bytes32 _proposalId, uint256 _choice) external view returns(uint256);

     
    function isAbstainAllow() external pure returns(bool);

     
    function getAllowedRangeOfChoices() external pure returns(uint256 min, uint256 max);
}

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity 0.5.17;


interface VotingMachineCallbacksInterface {
    function mintReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId) external returns(bool);
    function burnReputation(uint256 _amount, address _owner, bytes32 _proposalId) external returns(bool);

    function stakingTokenTransfer(IERC20 _stakingToken, address _beneficiary, uint256 _amount, bytes32 _proposalId)
    external
    returns(bool);

    function getTotalReputationSupply(bytes32 _proposalId) external view returns(uint256);
    function reputationOf(address _owner, bytes32 _proposalId) external view returns(uint256);
    function balanceOfStakingToken(IERC20 _stakingToken, bytes32 _proposalId) external view returns(uint256);
}

 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity ^0.5.0;

 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity 0.5.17;



 
contract Reputation is Ownable {

    uint8 public decimals = 18;              
     
    event Mint(address indexed _to, uint256 _amount);
     
    event Burn(address indexed _from, uint256 _amount);

      
       
       
    struct Checkpoint {

     
        uint128 fromBlock;

           
        uint128 value;
    }

       
       
       
    mapping (address => Checkpoint[]) private balances;

       
    Checkpoint[] private totalSupplyHistory;

      
      
      
      
    function mint(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply, "total supply overflow");  
        uint256 previousBalanceTo = balanceOf(_user);
        require(previousBalanceTo + _amount >= previousBalanceTo, "balace overflow");  
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_user], previousBalanceTo + _amount);
        emit Mint(_user, _amount);
        return true;
    }

      
      
      
      
    function burn(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        uint256 amountBurned = _amount;
        uint256 previousBalanceFrom = balanceOf(_user);
        if (previousBalanceFrom < amountBurned) {
            amountBurned = previousBalanceFrom;
        }
        updateValueAtNow(totalSupplyHistory, curTotalSupply - amountBurned);
        updateValueAtNow(balances[_user], previousBalanceFrom - amountBurned);
        emit Burn(_user, amountBurned);
        return true;
    }

    
    
    function totalSupply() public view returns (uint256) {
        return totalSupplyAt(block.number);
    }

     
     
     
     
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    
    
    
    function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            return 0;
           
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

  
  
  
  
    function balanceOfAt(address _owner, uint256 _blockNumber)
    public view returns (uint256)
    {
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            return 0;
         
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }
   
   
   

      
      
      
      
    function getValueAt(Checkpoint[] storage checkpoints, uint256 _block) internal view returns (uint256) {
        if (checkpoints.length == 0) {
            return 0;
        }

           
        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

           
        uint256 min = 0;
        uint256 max = checkpoints.length-1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

      
       
      
      
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {
        require(uint128(_value) == _value, "reputation overflow");  
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }
}

 

pragma solidity ^0.5.0;

 
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

 

pragma solidity ^0.5.0;




 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

     
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

     
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

     
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

      
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

 

pragma solidity ^0.5.0;



 
contract ERC20Burnable is Context, ERC20 {
     
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

     
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

 

pragma solidity 0.5.17;





 

contract DAOToken is ERC20, ERC20Burnable, Ownable {

    string public name;
    string public symbol;
     
    uint8 public constant decimals = 18;
    uint256 public cap;

     
    constructor(string memory _name, string memory _symbol, uint256 _cap)
    public {
        name = _name;
        symbol = _symbol;
        cap = _cap;
    }

     
    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        if (cap > 0)
            require(totalSupply().add(_amount) <= cap);
        _mint(_to, _amount);
        return true;
    }
}

 

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 

 
pragma solidity 0.5.17;



library SafeERC20 {
    using Address for address;

    bytes4 constant private TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 constant private TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    bytes4 constant private APPROVE_SELECTOR = bytes4(keccak256(bytes("approve(address,uint256)")));

    function safeTransfer(address _erc20Addr, address _to, uint256 _value) internal {

         
        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
         
        _erc20Addr.call(abi.encodeWithSelector(TRANSFER_SELECTOR, _to, _value));
         
        require(success);
         
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeTransferFrom(address _erc20Addr, address _from, address _to, uint256 _value) internal {

         
        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
         
        _erc20Addr.call(abi.encodeWithSelector(TRANSFERFROM_SELECTOR, _from, _to, _value));
         
        require(success);
         
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeApprove(address _erc20Addr, address _spender, uint256 _value) internal {

         
        require(_erc20Addr.isContract());

         
         
        require((_value == 0) || (IERC20(_erc20Addr).allowance(address(this), _spender) == 0));

        (bool success, bytes memory returnValue) =
         
        _erc20Addr.call(abi.encodeWithSelector(APPROVE_SELECTOR, _spender, _value));
         
        require(success);
         
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }
}

 

pragma solidity 0.5.17;







 
contract Avatar is Ownable {
    using SafeERC20 for address;

    string public orgName;
    DAOToken public nativeToken;
    Reputation public nativeReputation;

    event GenericCall(address indexed _contract, bytes _data, uint _value, bool _success);
    event SendEther(uint256 _amountInWei, address indexed _to);
    event ExternalTokenTransfer(address indexed _externalToken, address indexed _to, uint256 _value);
    event ExternalTokenTransferFrom(address indexed _externalToken, address _from, address _to, uint256 _value);
    event ExternalTokenApproval(address indexed _externalToken, address _spender, uint256 _value);
    event ReceiveEther(address indexed _sender, uint256 _value);
    event MetaData(string _metaData);

     
    constructor(string memory _orgName, DAOToken _nativeToken, Reputation _nativeReputation) public {
        orgName = _orgName;
        nativeToken = _nativeToken;
        nativeReputation = _nativeReputation;
    }

     
    function() external payable {
        emit ReceiveEther(msg.sender, msg.value);
    }

     
    function genericCall(address _contract, bytes memory _data, uint256 _value)
    public
    onlyOwner
    returns(bool success, bytes memory returnValue) {
       
        (success, returnValue) = _contract.call.value(_value)(_data);
        emit GenericCall(_contract, _data, _value, success);
    }

     
    function sendEther(uint256 _amountInWei, address payable _to) public onlyOwner returns(bool) {
        _to.transfer(_amountInWei);
        emit SendEther(_amountInWei, _to);
        return true;
    }

     
    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value)
    public onlyOwner returns(bool)
    {
        address(_externalToken).safeTransfer(_to, _value);
        emit ExternalTokenTransfer(address(_externalToken), _to, _value);
        return true;
    }

     
    function externalTokenTransferFrom(
        IERC20 _externalToken,
        address _from,
        address _to,
        uint256 _value
    )
    public onlyOwner returns(bool)
    {
        address(_externalToken).safeTransferFrom(_from, _to, _value);
        emit ExternalTokenTransferFrom(address(_externalToken), _from, _to, _value);
        return true;
    }

     
    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value)
    public onlyOwner returns(bool)
    {
        address(_externalToken).safeApprove(_spender, _value);
        emit ExternalTokenApproval(address(_externalToken), _spender, _value);
        return true;
    }

     
    function metaData(string memory _metaData) public onlyOwner returns(bool) {
        emit MetaData(_metaData);
        return true;
    }


}

 

pragma solidity 0.5.17;


contract UniversalSchemeInterface {

    function getParametersFromController(Avatar _avatar) internal view returns(bytes32);
    
}

 

pragma solidity 0.5.17;


contract GlobalConstraintInterface {

    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
     
    function when() public returns(CallPhase);
}

 

pragma solidity 0.5.17;



 
contract Controller {

    struct Scheme {
        bytes32 paramsHash;   
        bytes4  permissions;  
                              
                              
                              
                              
                              
                              
                              
    }

    struct GlobalConstraint {
        address gcAddress;
        bytes32 params;
    }

    struct GlobalConstraintRegister {
        bool isRegistered;  
        uint256 index;     
    }

    mapping(address=>Scheme) public schemes;

    Avatar public avatar;
    DAOToken public nativeToken;
    Reputation public nativeReputation;
   
    address public newController;
   

    GlobalConstraint[] public globalConstraintsPre;
   
    GlobalConstraint[] public globalConstraintsPost;
   
    mapping(address=>GlobalConstraintRegister) public globalConstraintsRegisterPre;
   
    mapping(address=>GlobalConstraintRegister) public globalConstraintsRegisterPost;

    event MintReputation (address indexed _sender, address indexed _to, uint256 _amount);
    event BurnReputation (address indexed _sender, address indexed _from, uint256 _amount);
    event MintTokens (address indexed _sender, address indexed _beneficiary, uint256 _amount);
    event RegisterScheme (address indexed _sender, address indexed _scheme);
    event UnregisterScheme (address indexed _sender, address indexed _scheme);
    event UpgradeController(address indexed _oldController, address _newController);

    event AddGlobalConstraint(
        address indexed _globalConstraint,
        bytes32 _params,
        GlobalConstraintInterface.CallPhase _when);

    event RemoveGlobalConstraint(address indexed _globalConstraint, uint256 _index, bool _isPre);

    constructor( Avatar _avatar) public {
        avatar = _avatar;
        nativeToken = avatar.nativeToken();
        nativeReputation = avatar.nativeReputation();
        schemes[msg.sender] = Scheme({paramsHash: bytes32(0), permissions: bytes4(0x0000001F)});
        emit RegisterScheme (msg.sender, msg.sender);
    }

   
    
    function() external {
        revert();
    }

   
    modifier onlyRegisteredScheme() {
        require(schemes[msg.sender].permissions&bytes4(0x00000001) == bytes4(0x00000001));
        _;
    }

    modifier onlyRegisteringSchemes() {
        require(schemes[msg.sender].permissions&bytes4(0x00000002) == bytes4(0x00000002));
        _;
    }

    modifier onlyGlobalConstraintsScheme() {
        require(schemes[msg.sender].permissions&bytes4(0x00000004) == bytes4(0x00000004));
        _;
    }

    modifier onlyUpgradingScheme() {
        require(schemes[msg.sender].permissions&bytes4(0x00000008) == bytes4(0x00000008));
        _;
    }

    modifier onlyGenericCallScheme() {
        require(schemes[msg.sender].permissions&bytes4(0x00000010) == bytes4(0x00000010));
        _;
    }

    modifier onlyMetaDataScheme() {
        require(schemes[msg.sender].permissions&bytes4(0x00000010) == bytes4(0x00000010));
        _;
    }

    modifier onlySubjectToConstraint(bytes32 func) {
        uint256 idx;
        for (idx = 0; idx < globalConstraintsPre.length; idx++) {
            require(
            (GlobalConstraintInterface(globalConstraintsPre[idx].gcAddress))
            .pre(msg.sender, globalConstraintsPre[idx].params, func));
        }
        _;
        for (idx = 0; idx < globalConstraintsPost.length; idx++) {
            require(
            (GlobalConstraintInterface(globalConstraintsPost[idx].gcAddress))
            .post(msg.sender, globalConstraintsPost[idx].params, func));
        }
    }

    modifier isAvatarValid(address _avatar) {
        require(_avatar == address(avatar));
        _;
    }

     
    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("mintReputation")
    isAvatarValid(_avatar)
    returns(bool)
    {
        emit MintReputation(msg.sender, _to, _amount);
        return nativeReputation.mint(_to, _amount);
    }

     
    function burnReputation(uint256 _amount, address _from, address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("burnReputation")
    isAvatarValid(_avatar)
    returns(bool)
    {
        emit BurnReputation(msg.sender, _from, _amount);
        return nativeReputation.burn(_from, _amount);
    }

     
    function mintTokens(uint256 _amount, address _beneficiary, address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("mintTokens")
    isAvatarValid(_avatar)
    returns(bool)
    {
        emit MintTokens(msg.sender, _beneficiary, _amount);
        return nativeToken.mint(_beneficiary, _amount);
    }

   
    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions, address _avatar)
    external
    onlyRegisteringSchemes
    onlySubjectToConstraint("registerScheme")
    isAvatarValid(_avatar)
    returns(bool)
    {

        Scheme memory scheme = schemes[_scheme];

     
     

     
        require(bytes4(0x0000001f)&(_permissions^scheme.permissions)&(~schemes[msg.sender].permissions) == bytes4(0));

     
        require(bytes4(0x0000001f)&(scheme.permissions&(~schemes[msg.sender].permissions)) == bytes4(0));

     
        schemes[_scheme].paramsHash = _paramsHash;
        schemes[_scheme].permissions = _permissions|bytes4(0x00000001);
        emit RegisterScheme(msg.sender, _scheme);
        return true;
    }

     
    function unregisterScheme( address _scheme, address _avatar)
    external
    onlyRegisteringSchemes
    onlySubjectToConstraint("unregisterScheme")
    isAvatarValid(_avatar)
    returns(bool)
    {
     
        if (_isSchemeRegistered(_scheme) == false) {
            return false;
        }
     
        require(bytes4(0x0000001f)&(schemes[_scheme].permissions&(~schemes[msg.sender].permissions)) == bytes4(0));

     
        emit UnregisterScheme(msg.sender, _scheme);
        delete schemes[_scheme];
        return true;
    }

     
    function unregisterSelf(address _avatar) external isAvatarValid(_avatar) returns(bool) {
        if (_isSchemeRegistered(msg.sender) == false) {
            return false;
        }
        delete schemes[msg.sender];
        emit UnregisterScheme(msg.sender, msg.sender);
        return true;
    }

     
    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external
    onlyGlobalConstraintsScheme
    isAvatarValid(_avatar)
    returns(bool)
    {
        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        if ((when == GlobalConstraintInterface.CallPhase.Pre)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!globalConstraintsRegisterPre[_globalConstraint].isRegistered) {
                globalConstraintsPre.push(GlobalConstraint(_globalConstraint, _params));
                globalConstraintsRegisterPre[_globalConstraint] =
                GlobalConstraintRegister(true, globalConstraintsPre.length-1);
            }else {
                globalConstraintsPre[globalConstraintsRegisterPre[_globalConstraint].index].params = _params;
            }
        }
        if ((when == GlobalConstraintInterface.CallPhase.Post)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!globalConstraintsRegisterPost[_globalConstraint].isRegistered) {
                globalConstraintsPost.push(GlobalConstraint(_globalConstraint, _params));
                globalConstraintsRegisterPost[_globalConstraint] =
                GlobalConstraintRegister(true, globalConstraintsPost.length-1);
            }else {
                globalConstraintsPost[globalConstraintsRegisterPost[_globalConstraint].index].params = _params;
            }
        }
        emit AddGlobalConstraint(_globalConstraint, _params, when);
        return true;
    }

     
      
    function removeGlobalConstraint (address _globalConstraint, address _avatar)
    external
    onlyGlobalConstraintsScheme
    isAvatarValid(_avatar)
    returns(bool)
    {
        GlobalConstraintRegister memory globalConstraintRegister;
        GlobalConstraint memory globalConstraint;
        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        bool retVal = false;

        if ((when == GlobalConstraintInterface.CallPhase.Pre)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            globalConstraintRegister = globalConstraintsRegisterPre[_globalConstraint];
            if (globalConstraintRegister.isRegistered) {
                if (globalConstraintRegister.index < globalConstraintsPre.length-1) {
                    globalConstraint = globalConstraintsPre[globalConstraintsPre.length-1];
                    globalConstraintsPre[globalConstraintRegister.index] = globalConstraint;
                    globalConstraintsRegisterPre[globalConstraint.gcAddress].index = globalConstraintRegister.index;
                }
                globalConstraintsPre.length--;
                delete globalConstraintsRegisterPre[_globalConstraint];
                retVal = true;
            }
        }
        if ((when == GlobalConstraintInterface.CallPhase.Post)||
            (when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            globalConstraintRegister = globalConstraintsRegisterPost[_globalConstraint];
            if (globalConstraintRegister.isRegistered) {
                if (globalConstraintRegister.index < globalConstraintsPost.length-1) {
                    globalConstraint = globalConstraintsPost[globalConstraintsPost.length-1];
                    globalConstraintsPost[globalConstraintRegister.index] = globalConstraint;
                    globalConstraintsRegisterPost[globalConstraint.gcAddress].index = globalConstraintRegister.index;
                }
                globalConstraintsPost.length--;
                delete globalConstraintsRegisterPost[_globalConstraint];
                retVal = true;
            }
        }
        if (retVal) {
            emit RemoveGlobalConstraint(
            _globalConstraint,
            globalConstraintRegister.index,
            when == GlobalConstraintInterface.CallPhase.Pre
            );
        }
        return retVal;
    }

   
    function upgradeController(address _newController, Avatar _avatar)
    external
    onlyUpgradingScheme
    isAvatarValid(address(_avatar))
    returns(bool)
    {
        require(newController == address(0));    
        require(_newController != address(0));
        newController = _newController;
        avatar.transferOwnership(_newController);
        require(avatar.owner() == _newController);
        if (nativeToken.owner() == address(this)) {
            nativeToken.transferOwnership(_newController);
            require(nativeToken.owner() == _newController);
        }
        if (nativeReputation.owner() == address(this)) {
            nativeReputation.transferOwnership(_newController);
            require(nativeReputation.owner() == _newController);
        }
        emit UpgradeController(address(this), newController);
        return true;
    }

     
    function genericCall(address _contract, bytes calldata _data, Avatar _avatar, uint256 _value)
    external
    onlyGenericCallScheme
    onlySubjectToConstraint("genericCall")
    isAvatarValid(address(_avatar))
    returns (bool, bytes memory)
    {
        return avatar.genericCall(_contract, _data, _value);
    }

   
    function sendEther(uint256 _amountInWei, address payable _to, Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("sendEther")
    isAvatarValid(address(_avatar))
    returns(bool)
    {
        return avatar.sendEther(_amountInWei, _to);
    }

     
    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value, Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenTransfer")
    isAvatarValid(address(_avatar))
    returns(bool)
    {
        return avatar.externalTokenTransfer(_externalToken, _to, _value);
    }

     
    function externalTokenTransferFrom(
    IERC20 _externalToken,
    address _from,
    address _to,
    uint256 _value,
    Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenTransferFrom")
    isAvatarValid(address(_avatar))
    returns(bool)
    {
        return avatar.externalTokenTransferFrom(_externalToken, _from, _to, _value);
    }

     
    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value, Avatar _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenIncreaseApproval")
    isAvatarValid(address(_avatar))
    returns(bool)
    {
        return avatar.externalTokenApproval(_externalToken, _spender, _value);
    }

     
    function metaData(string calldata _metaData, Avatar _avatar)
        external
        onlyMetaDataScheme
        isAvatarValid(address(_avatar))
        returns(bool)
        {
        return avatar.metaData(_metaData);
    }

     
    function getNativeReputation(address _avatar) external isAvatarValid(_avatar) view returns(address) {
        return address(nativeReputation);
    }

    function isSchemeRegistered(address _scheme, address _avatar) external isAvatarValid(_avatar) view returns(bool) {
        return _isSchemeRegistered(_scheme);
    }

    function getSchemeParameters(address _scheme, address _avatar)
    external
    isAvatarValid(_avatar)
    view
    returns(bytes32)
    {
        return schemes[_scheme].paramsHash;
    }

    function getSchemePermissions(address _scheme, address _avatar)
    external
    isAvatarValid(_avatar)
    view
    returns(bytes4)
    {
        return schemes[_scheme].permissions;
    }

    function getGlobalConstraintParameters(address _globalConstraint, address) external view returns(bytes32) {

        GlobalConstraintRegister memory register = globalConstraintsRegisterPre[_globalConstraint];

        if (register.isRegistered) {
            return globalConstraintsPre[register.index].params;
        }

        register = globalConstraintsRegisterPost[_globalConstraint];

        if (register.isRegistered) {
            return globalConstraintsPost[register.index].params;
        }
    }

    
    function globalConstraintsCount(address _avatar)
        external
        isAvatarValid(_avatar)
        view
        returns(uint, uint)
        {
        return (globalConstraintsPre.length, globalConstraintsPost.length);
    }

    function isGlobalConstraintRegistered(address _globalConstraint, address _avatar)
        external
        isAvatarValid(_avatar)
        view
        returns(bool)
        {
        return (globalConstraintsRegisterPre[_globalConstraint].isRegistered ||
                globalConstraintsRegisterPost[_globalConstraint].isRegistered);
    }

    function _isSchemeRegistered(address _scheme) private view returns(bool) {
        return (schemes[_scheme].permissions&bytes4(0x00000001) != bytes4(0));
    }
}

 

pragma solidity 0.5.17;





contract UniversalScheme is UniversalSchemeInterface {
     
    function getParametersFromController(Avatar _avatar) internal view returns(bytes32) {
        require(Controller(_avatar.owner()).isSchemeRegistered(address(this), address(_avatar)),
        "scheme is not registered");
        return Controller(_avatar.owner()).getSchemeParameters(address(this), address(_avatar));
    }
}

 

pragma solidity ^0.5.0;

 
library ECDSA {
     
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
         
        if (signature.length != 65) {
            return (address(0));
        }

         
        bytes32 r;
        bytes32 s;
        uint8 v;

         
         
         
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

         
         
         
         
         
         
         
         
         
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

         
        return ecrecover(hash, v, r, s);
    }

     
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
         
         
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

 

pragma solidity 0.5.17;

 


library RealMath {

     
    uint256 constant private REAL_BITS = 256;

     
    uint256 constant private REAL_FBITS = 40;

     
    uint256 constant private REAL_ONE = uint256(1) << REAL_FBITS;

     
    function pow(uint256 realBase, uint256 exponent) internal pure returns (uint256) {

        uint256 tempRealBase = realBase;
        uint256 tempExponent = exponent;

         
        uint256 realResult = REAL_ONE;
        while (tempExponent != 0) {
             
            if ((tempExponent & 0x1) == 0x1) {
                 
                realResult = mul(realResult, tempRealBase);
            }
                 
            tempExponent = tempExponent >> 1;
            if (tempExponent != 0) {
                 
                tempRealBase = mul(tempRealBase, tempRealBase);
            }
        }

         
        return realResult;
    }

     
    function fraction(uint216 numerator, uint216 denominator) internal pure returns (uint256) {
        return div(uint256(numerator) * REAL_ONE, uint256(denominator) * REAL_ONE);
    }

     
    function mul(uint256 realA, uint256 realB) private pure returns (uint256) {
         
         
        uint256 res = realA * realB;
        require(res/realA == realB, "RealMath mul overflow");
        return (res >> REAL_FBITS);
    }

     
    function div(uint256 realNumerator, uint256 realDenominator) private pure returns (uint256) {
         
         
        return uint256((uint256(realNumerator) * REAL_ONE) / uint256(realDenominator));
    }

}

 

pragma solidity 0.5.17;

interface ProposalExecuteInterface {
    function executeProposal(bytes32 _proposalId, int _decision) external returns(bool);
}

 

pragma solidity ^0.5.0;

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

 

pragma solidity 0.5.17;











 
contract GenesisProtocolLogic is IntVoteInterface {
    using SafeMath for uint256;
    using Math for uint256;
    using RealMath for uint216;
    using RealMath for uint256;
    using Address for address;

    enum ProposalState { None, ExpiredInQueue, Executed, Queued, PreBoosted, Boosted, QuietEndingPeriod}
    enum ExecutionState { None, QueueBarCrossed, QueueTimeOut, PreBoostedBarCrossed, BoostedTimeOut, BoostedBarCrossed}

     
    struct Parameters {
        uint256 queuedVoteRequiredPercentage;  
        uint256 queuedVotePeriodLimit;  
        uint256 boostedVotePeriodLimit;  
        uint256 preBoostedVotePeriodLimit;  
                                           
        uint256 thresholdConst;  
                                 
        uint256 limitExponentValue; 
                                    
        uint256 quietEndingPeriod;  
        uint256 proposingRepReward; 
        uint256 votersReputationLossRatio; 
                                           
        uint256 minimumDaoBounty;
        uint256 daoBountyConst; 
                                
        uint256 activationTime; 
         
        address voteOnBehalf;
    }

    struct Voter {
        uint256 vote;  
        uint256 reputation;  
        bool preBoosted;
    }

    struct Staker {
        uint256 vote;  
        uint256 amount;  
        uint256 amount4Bounty; 
    }

    struct Proposal {
        bytes32 organizationId;  
        address callbacks;     
        ProposalState state;
        uint256 winningVote;  
        address proposer;
         
        uint256 currentBoostedVotePeriodLimit;
        bytes32 paramsHash;
        uint256 daoBountyRemain;  
        uint256 daoBounty;
        uint256 totalStakes; 
        uint256 confidenceThreshold;
        uint256 secondsFromTimeOutTillExecuteBoosted;
        uint[3] times;  
                        
                        
        bool daoRedeemItsWinnings;
         
        mapping(uint256   =>  uint256    ) votes;
         
        mapping(uint256   =>  uint256    ) preBoostedVotes;
         
        mapping(address =>  Voter    ) voters;
         
        mapping(uint256   =>  uint256    ) stakes;
         
        mapping(address  => Staker   ) stakers;
    }

    event Stake(bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _staker,
        uint256 _vote,
        uint256 _amount
    );

    event Redeem(bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _beneficiary,
        uint256 _amount
    );

    event RedeemDaoBounty(bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _beneficiary,
        uint256 _amount
    );

    event RedeemReputation(bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _beneficiary,
        uint256 _amount
    );

    event StateChange(bytes32 indexed _proposalId, ProposalState _proposalState);
    event GPExecuteProposal(bytes32 indexed _proposalId, ExecutionState _executionState);
    event ExpirationCallBounty(bytes32 indexed _proposalId, address indexed _beneficiary, uint256 _amount);
    event ConfidenceLevelChange(bytes32 indexed _proposalId, uint256 _confidenceThreshold);

    mapping(bytes32=>Parameters) public parameters;   
    mapping(bytes32=>Proposal) public proposals;  
    mapping(bytes32=>uint) public orgBoostedProposalsCnt;
            
    mapping(bytes32        => address     ) public organizations;
           
    mapping(bytes32           => uint256              ) public averagesDownstakesOfBoosted;
    uint256 constant public NUM_OF_CHOICES = 2;
    uint256 constant public NO = 2;
    uint256 constant public YES = 1;
    uint256 public proposalsCnt;  
    IERC20 public stakingToken;
    address constant private GEN_TOKEN_ADDRESS = 0x543Ff227F64Aa17eA132Bf9886cAb5DB55DCAddf;
    uint256 constant private MAX_BOOSTED_PROPOSALS = 4096;

     
    constructor(IERC20 _stakingToken) public {
       
       
       
       
       
        if (address(GEN_TOKEN_ADDRESS).isContract()) {
            stakingToken = IERC20(GEN_TOKEN_ADDRESS);
        } else {
            stakingToken = _stakingToken;
        }
    }

   
    modifier votable(bytes32 _proposalId) {
        require(_isVotable(_proposalId), "proposal is not votable");
        _;
    }

     
    function propose(uint256, bytes32 _paramsHash, address _proposer, address _organization)
        external
        returns(bytes32)
    {
       
        require(now > parameters[_paramsHash].activationTime, "not active yet");
         
        require(parameters[_paramsHash].queuedVoteRequiredPercentage >= 50, "no parameters exist");
         
        bytes32 proposalId = keccak256(abi.encodePacked(this, proposalsCnt));
        proposalsCnt = proposalsCnt.add(1);
          
        Proposal memory proposal;
        proposal.callbacks = msg.sender;
        proposal.organizationId = keccak256(abi.encodePacked(msg.sender, _organization));

        proposal.state = ProposalState.Queued;
         
        proposal.times[0] = now; 
        proposal.currentBoostedVotePeriodLimit = parameters[_paramsHash].boostedVotePeriodLimit;
        proposal.proposer = _proposer;
        proposal.winningVote = NO;
        proposal.paramsHash = _paramsHash;
        if (organizations[proposal.organizationId] == address(0)) {
            if (_organization == address(0)) {
                organizations[proposal.organizationId] = msg.sender;
            } else {
                organizations[proposal.organizationId] = _organization;
            }
        }
         
        uint256 daoBounty =
        parameters[_paramsHash].daoBountyConst.mul(averagesDownstakesOfBoosted[proposal.organizationId]).div(100);
        proposal.daoBountyRemain = daoBounty.max(parameters[_paramsHash].minimumDaoBounty);
        proposals[proposalId] = proposal;
        proposals[proposalId].stakes[NO] = proposal.daoBountyRemain; 

        emit NewProposal(proposalId, organizations[proposal.organizationId], NUM_OF_CHOICES, _proposer, _paramsHash);
        return proposalId;
    }

     
    function executeBoosted(bytes32 _proposalId) external returns(uint256 expirationCallBounty) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.state == ProposalState.Boosted || proposal.state == ProposalState.QuietEndingPeriod,
        "proposal state in not Boosted nor QuietEndingPeriod");
        require(_execute(_proposalId), "proposal need to expire");

        proposal.secondsFromTimeOutTillExecuteBoosted =
         
        now.sub(proposal.currentBoostedVotePeriodLimit.add(proposal.times[1]));

        expirationCallBounty = calcExecuteCallBounty(_proposalId);
        proposal.totalStakes = proposal.totalStakes.sub(expirationCallBounty);
        require(stakingToken.transfer(msg.sender, expirationCallBounty), "transfer to msg.sender failed");
        emit ExpirationCallBounty(_proposalId, msg.sender, expirationCallBounty);
    }

     
    function setParameters(
        uint[11] calldata _params,  
        address _voteOnBehalf
    )
    external
    returns(bytes32)
    {
        require(_params[0] <= 100 && _params[0] >= 50, "50 <= queuedVoteRequiredPercentage <= 100");
        require(_params[4] <= 16000 && _params[4] > 1000, "1000 < thresholdConst <= 16000");
        require(_params[7] <= 100, "votersReputationLossRatio <= 100");
        require(_params[2] >= _params[5], "boostedVotePeriodLimit >= quietEndingPeriod");
        require(_params[8] > 0, "minimumDaoBounty should be > 0");
        require(_params[9] > 0, "daoBountyConst should be > 0");

        bytes32 paramsHash = getParametersHash(_params, _voteOnBehalf);

        if (parameters[paramsHash].queuedVoteRequiredPercentage > 0) {
             
            return paramsHash;
        }

         
        uint256 limitExponent = 172; 
        uint256 j = 2;
        for (uint256 i = 2000; i < 16000; i = i*2) {
            if ((_params[4] > i) && (_params[4] <= i*2)) {
                limitExponent = limitExponent/j;
                break;
            }
            j++;
        }

        parameters[paramsHash] = Parameters({
            queuedVoteRequiredPercentage: _params[0],
            queuedVotePeriodLimit: _params[1],
            boostedVotePeriodLimit: _params[2],
            preBoostedVotePeriodLimit: _params[3],
            thresholdConst:uint216(_params[4]).fraction(uint216(1000)),
            limitExponentValue:limitExponent,
            quietEndingPeriod: _params[5],
            proposingRepReward: _params[6],
            votersReputationLossRatio:_params[7],
            minimumDaoBounty:_params[8],
            daoBountyConst:_params[9],
            activationTime:_params[10],
            voteOnBehalf:_voteOnBehalf
        });
        return paramsHash;
    }

     
      
    function redeem(bytes32 _proposalId, address _beneficiary) public returns (uint[3] memory rewards) {
        Proposal storage proposal = proposals[_proposalId];
        require((proposal.state == ProposalState.Executed)||(proposal.state == ProposalState.ExpiredInQueue),
        "Proposal should be Executed or ExpiredInQueue");
        Parameters memory params = parameters[proposal.paramsHash];
         
        Staker storage staker = proposal.stakers[_beneficiary];
        uint256 totalWinningStakes = proposal.stakes[proposal.winningVote];
        uint256 totalStakesLeftAfterCallBounty =
        proposal.stakes[NO].add(proposal.stakes[YES]).sub(calcExecuteCallBounty(_proposalId));
        if (staker.amount > 0) {

            if (proposal.state == ProposalState.ExpiredInQueue) {
                 
                rewards[0] = staker.amount;
            } else if (staker.vote == proposal.winningVote) {
                if (staker.vote == YES) {
                    if (proposal.daoBounty < totalStakesLeftAfterCallBounty) {
                        uint256 _totalStakes = totalStakesLeftAfterCallBounty.sub(proposal.daoBounty);
                        rewards[0] = (staker.amount.mul(_totalStakes))/totalWinningStakes;
                    }
                } else {
                    rewards[0] = (staker.amount.mul(totalStakesLeftAfterCallBounty))/totalWinningStakes;
                }
            }
            staker.amount = 0;
        }
             
        if (proposal.daoRedeemItsWinnings == false &&
            _beneficiary == organizations[proposal.organizationId] &&
            proposal.state != ProposalState.ExpiredInQueue &&
            proposal.winningVote == NO) {
            rewards[0] =
            rewards[0]
            .add((proposal.daoBounty.mul(totalStakesLeftAfterCallBounty))/totalWinningStakes)
            .sub(proposal.daoBounty);
            proposal.daoRedeemItsWinnings = true;
        }

         
        Voter storage voter = proposal.voters[_beneficiary];
        if ((voter.reputation != 0) && (voter.preBoosted)) {
            if (proposal.state == ProposalState.ExpiredInQueue) {
               
                rewards[1] = ((voter.reputation.mul(params.votersReputationLossRatio))/100);
            } else if (proposal.winningVote == voter.vote) {
                uint256 lostReputation;
                if (proposal.winningVote == YES) {
                    lostReputation = proposal.preBoostedVotes[NO];
                } else {
                    lostReputation = proposal.preBoostedVotes[YES];
                }
                lostReputation = (lostReputation.mul(params.votersReputationLossRatio))/100;
                rewards[1] = ((voter.reputation.mul(params.votersReputationLossRatio))/100)
                .add((voter.reputation.mul(lostReputation))/proposal.preBoostedVotes[proposal.winningVote]);
            }
            voter.reputation = 0;
        }
         
        if ((proposal.proposer == _beneficiary)&&(proposal.winningVote == YES)&&(proposal.proposer != address(0))) {
            rewards[2] = params.proposingRepReward;
            proposal.proposer = address(0);
        }
        if (rewards[0] != 0) {
            proposal.totalStakes = proposal.totalStakes.sub(rewards[0]);
            require(stakingToken.transfer(_beneficiary, rewards[0]), "transfer to beneficiary failed");
            emit Redeem(_proposalId, organizations[proposal.organizationId], _beneficiary, rewards[0]);
        }
        if (rewards[1].add(rewards[2]) != 0) {
            VotingMachineCallbacksInterface(proposal.callbacks)
            .mintReputation(rewards[1].add(rewards[2]), _beneficiary, _proposalId);
            emit RedeemReputation(
            _proposalId,
            organizations[proposal.organizationId],
            _beneficiary,
            rewards[1].add(rewards[2])
            );
        }
    }

     
    function redeemDaoBounty(bytes32 _proposalId, address _beneficiary)
    public
    returns(uint256 redeemedAmount, uint256 potentialAmount) {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.state == ProposalState.Executed, "proposal state must be executed");
        uint256 totalWinningStakes = proposal.stakes[proposal.winningVote];
        Staker storage staker = proposal.stakers[_beneficiary];
        if (
            (staker.amount4Bounty > 0)&&
            (staker.vote == proposal.winningVote)&&
            (proposal.winningVote == YES)&&
            (totalWinningStakes != 0)) {
             
                potentialAmount = (staker.amount4Bounty * proposal.daoBounty)/totalWinningStakes;
            }
        if ((potentialAmount != 0)&&
            (VotingMachineCallbacksInterface(proposal.callbacks)
            .balanceOfStakingToken(stakingToken, _proposalId) >= potentialAmount)) {
            staker.amount4Bounty = 0;
            proposal.daoBountyRemain = proposal.daoBountyRemain.sub(potentialAmount);
            require(
            VotingMachineCallbacksInterface(proposal.callbacks)
            .stakingTokenTransfer(stakingToken, _beneficiary, potentialAmount, _proposalId),
            "failed at stakingTokenTransfer");
            redeemedAmount = potentialAmount;
            emit RedeemDaoBounty(_proposalId, organizations[proposal.organizationId], _beneficiary, redeemedAmount);
        }
    }

     
    function calcExecuteCallBounty(bytes32 _proposalId) public view returns(uint256) {
        uint maxRewardSeconds = 1500;
        uint rewardSeconds =
        uint256(maxRewardSeconds).min(proposals[_proposalId].secondsFromTimeOutTillExecuteBoosted);
        return rewardSeconds.mul(proposals[_proposalId].stakes[YES]).div(maxRewardSeconds*10);
    }

     
    function shouldBoost(bytes32 _proposalId) public view returns(bool) {
        Proposal memory proposal = proposals[_proposalId];
        return (_score(_proposalId) > threshold(proposal.paramsHash, proposal.organizationId));
    }

     
    function threshold(bytes32 _paramsHash, bytes32 _organizationId) public view returns(uint256) {
        uint256 power = orgBoostedProposalsCnt[_organizationId];
        Parameters storage params = parameters[_paramsHash];

        if (power > params.limitExponentValue) {
            power = params.limitExponentValue;
        }

        return params.thresholdConst.pow(power);
    }

   
    function getParametersHash(
        uint[11] memory _params, 
        address _voteOnBehalf
    )
        public
        pure
        returns(bytes32)
        {
         
        return keccak256(
            abi.encodePacked(
            keccak256(
            abi.encodePacked(
                _params[0],
                _params[1],
                _params[2],
                _params[3],
                _params[4],
                _params[5],
                _params[6],
                _params[7],
                _params[8],
                _params[9],
                _params[10])
            ),
            _voteOnBehalf
        ));
    }

     
      
    function _execute(bytes32 _proposalId) internal votable(_proposalId) returns(bool) {
        Proposal storage proposal = proposals[_proposalId];
        Parameters memory params = parameters[proposal.paramsHash];
        Proposal memory tmpProposal = proposal;
        uint256 totalReputation =
        VotingMachineCallbacksInterface(proposal.callbacks).getTotalReputationSupply(_proposalId);
         
        uint256 executionBar = (totalReputation/100) * params.queuedVoteRequiredPercentage;
        ExecutionState executionState = ExecutionState.None;
        uint256 averageDownstakesOfBoosted;
        uint256 confidenceThreshold;

        if (proposal.votes[proposal.winningVote] > executionBar) {
          
            if (proposal.state == ProposalState.Queued) {
                executionState = ExecutionState.QueueBarCrossed;
            } else if (proposal.state == ProposalState.PreBoosted) {
                executionState = ExecutionState.PreBoostedBarCrossed;
            } else {
                executionState = ExecutionState.BoostedBarCrossed;
            }
            proposal.state = ProposalState.Executed;
        } else {
            if (proposal.state == ProposalState.Queued) {
                 
                if ((now - proposal.times[0]) >= params.queuedVotePeriodLimit) {
                    proposal.state = ProposalState.ExpiredInQueue;
                    proposal.winningVote = NO;
                    executionState = ExecutionState.QueueTimeOut;
                } else {
                    confidenceThreshold = threshold(proposal.paramsHash, proposal.organizationId);
                    if (_score(_proposalId) > confidenceThreshold) {
                         
                        proposal.state = ProposalState.PreBoosted;
                         
                        proposal.times[2] = now;
                        proposal.confidenceThreshold = confidenceThreshold;
                    }
                }
            }

            if (proposal.state == ProposalState.PreBoosted) {
                confidenceThreshold = threshold(proposal.paramsHash, proposal.organizationId);
               
                if ((now - proposal.times[2]) >= params.preBoostedVotePeriodLimit) {
                    if (_score(_proposalId) > confidenceThreshold) {
                        if (orgBoostedProposalsCnt[proposal.organizationId] < MAX_BOOSTED_PROPOSALS) {
                          
                            proposal.state = ProposalState.Boosted;
                          
                            proposal.times[1] = now;
                            orgBoostedProposalsCnt[proposal.organizationId]++;
                          
                            averageDownstakesOfBoosted = averagesDownstakesOfBoosted[proposal.organizationId];
                           
                            averagesDownstakesOfBoosted[proposal.organizationId] =
                                uint256(int256(averageDownstakesOfBoosted) +
                                ((int256(proposal.stakes[NO])-int256(averageDownstakesOfBoosted))/
                                int256(orgBoostedProposalsCnt[proposal.organizationId])));
                        }
                    } else {
                        proposal.state = ProposalState.Queued;
                    }
                } else {  
                    uint256 proposalScore = _score(_proposalId);
                    if (proposalScore <= proposal.confidenceThreshold.min(confidenceThreshold)) {
                        proposal.state = ProposalState.Queued;
                    } else if (proposal.confidenceThreshold > proposalScore) {
                        proposal.confidenceThreshold = confidenceThreshold;
                        emit ConfidenceLevelChange(_proposalId, confidenceThreshold);
                    }
                }
            }
        }

        if ((proposal.state == ProposalState.Boosted) ||
            (proposal.state == ProposalState.QuietEndingPeriod)) {
             
            if ((now - proposal.times[1]) >= proposal.currentBoostedVotePeriodLimit) {
                proposal.state = ProposalState.Executed;
                executionState = ExecutionState.BoostedTimeOut;
            }
        }

        if (executionState != ExecutionState.None) {
            if ((executionState == ExecutionState.BoostedTimeOut) ||
                (executionState == ExecutionState.BoostedBarCrossed)) {
                orgBoostedProposalsCnt[tmpProposal.organizationId] =
                orgBoostedProposalsCnt[tmpProposal.organizationId].sub(1);
                 
                uint256 boostedProposals = orgBoostedProposalsCnt[tmpProposal.organizationId];
                if (boostedProposals == 0) {
                    averagesDownstakesOfBoosted[proposal.organizationId] = 0;
                } else {
                    averageDownstakesOfBoosted = averagesDownstakesOfBoosted[proposal.organizationId];
                    averagesDownstakesOfBoosted[proposal.organizationId] =
                    (averageDownstakesOfBoosted.mul(boostedProposals+1).sub(proposal.stakes[NO]))/boostedProposals;
                }
            }
            emit ExecuteProposal(
            _proposalId,
            organizations[proposal.organizationId],
            proposal.winningVote,
            totalReputation
            );
            emit GPExecuteProposal(_proposalId, executionState);
            proposal.daoBounty = proposal.daoBountyRemain;
            ProposalExecuteInterface(proposal.callbacks).executeProposal(_proposalId, int(proposal.winningVote));
        }
        if (tmpProposal.state != proposal.state) {
            emit StateChange(_proposalId, proposal.state);
        }
        return (executionState != ExecutionState.None);
    }

     
    function _stake(bytes32 _proposalId, uint256 _vote, uint256 _amount, address _staker) internal returns(bool) {
         
        require(_vote <= NUM_OF_CHOICES && _vote > 0, "wrong vote value");
        require(_amount > 0, "staking amount should be >0");

        if (_execute(_proposalId)) {
            return true;
        }
        Proposal storage proposal = proposals[_proposalId];

        if ((proposal.state != ProposalState.PreBoosted) &&
            (proposal.state != ProposalState.Queued)) {
            return false;
        }

         
        Staker storage staker = proposal.stakers[_staker];
        if ((staker.amount > 0) && (staker.vote != _vote)) {
            return false;
        }

        uint256 amount = _amount;
        require(stakingToken.transferFrom(_staker, address(this), amount), "fail transfer from staker");
        proposal.totalStakes = proposal.totalStakes.add(amount);  
        staker.amount = staker.amount.add(amount);
         
         
        require(staker.amount <= 0x100000000000000000000000000000000, "staking amount is too high");
        require(proposal.totalStakes <= uint256(0x100000000000000000000000000000000).sub(proposal.daoBountyRemain),
                "total stakes is too high");

        if (_vote == YES) {
            staker.amount4Bounty = staker.amount4Bounty.add(amount);
        }
        staker.vote = _vote;

        proposal.stakes[_vote] = amount.add(proposal.stakes[_vote]);
        emit Stake(_proposalId, organizations[proposal.organizationId], _staker, _vote, _amount);
        return _execute(_proposalId);
    }

     
      
    function internalVote(bytes32 _proposalId, address _voter, uint256 _vote, uint256 _rep) internal returns(bool) {
        require(_vote <= NUM_OF_CHOICES && _vote > 0, "0 < _vote <= 2");
        if (_execute(_proposalId)) {
            return true;
        }

        Parameters memory params = parameters[proposals[_proposalId].paramsHash];
        Proposal storage proposal = proposals[_proposalId];

         
        uint256 reputation = VotingMachineCallbacksInterface(proposal.callbacks).reputationOf(_voter, _proposalId);
        require(reputation > 0, "_voter must have reputation");
        require(reputation >= _rep, "reputation >= _rep");
        uint256 rep = _rep;
        if (rep == 0) {
            rep = reputation;
        }
         
        if (proposal.voters[_voter].reputation != 0) {
            return false;
        }
         
        proposal.votes[_vote] = rep.add(proposal.votes[_vote]);
         
         
        if ((proposal.votes[_vote] > proposal.votes[proposal.winningVote]) ||
            ((proposal.votes[NO] == proposal.votes[proposal.winningVote]) &&
            proposal.winningVote == YES)) {
            if (proposal.state == ProposalState.Boosted &&
             
                ((now - proposal.times[1]) >= (params.boostedVotePeriodLimit - params.quietEndingPeriod))||
                proposal.state == ProposalState.QuietEndingPeriod) {
                 
                if (proposal.state != ProposalState.QuietEndingPeriod) {
                    proposal.currentBoostedVotePeriodLimit = params.quietEndingPeriod;
                    proposal.state = ProposalState.QuietEndingPeriod;
                    emit StateChange(_proposalId, proposal.state);
                }
                 
                proposal.times[1] = now;
            }
            proposal.winningVote = _vote;
        }
        proposal.voters[_voter] = Voter({
            reputation: rep,
            vote: _vote,
            preBoosted:((proposal.state == ProposalState.PreBoosted) || (proposal.state == ProposalState.Queued))
        });
        if ((proposal.state == ProposalState.PreBoosted) || (proposal.state == ProposalState.Queued)) {
            proposal.preBoostedVotes[_vote] = rep.add(proposal.preBoostedVotes[_vote]);
            uint256 reputationDeposit = (params.votersReputationLossRatio.mul(rep))/100;
            VotingMachineCallbacksInterface(proposal.callbacks).burnReputation(reputationDeposit, _voter, _proposalId);
        }
        emit VoteProposal(_proposalId, organizations[proposal.organizationId], _voter, _vote, rep);
        return _execute(_proposalId);
    }

     
    function _score(bytes32 _proposalId) internal view returns(uint256) {
        Proposal storage proposal = proposals[_proposalId];
         
        return uint216(proposal.stakes[YES]).fraction(uint216(proposal.stakes[NO]));
    }

     
    function _isVotable(bytes32 _proposalId) internal view returns(bool) {
        ProposalState pState = proposals[_proposalId].state;
        return ((pState == ProposalState.PreBoosted)||
                (pState == ProposalState.Boosted)||
                (pState == ProposalState.QuietEndingPeriod)||
                (pState == ProposalState.Queued)
        );
    }
}

 

pragma solidity 0.5.17;




 
contract GenesisProtocol is IntVoteInterface, GenesisProtocolLogic {
    using ECDSA for bytes32;

     
     
    bytes32 public constant DELEGATION_HASH_EIP712 =
    keccak256(abi.encodePacked(
    "address GenesisProtocolAddress",
    "bytes32 ProposalId",
    "uint256 Vote",
    "uint256 AmountToStake",
    "uint256 Nonce"
    ));

    mapping(address=>uint256) public stakesNonce;  

     
    constructor(IERC20 _stakingToken)
    public
     
    GenesisProtocolLogic(_stakingToken) {
    }

     
    function stake(bytes32 _proposalId, uint256 _vote, uint256 _amount) external returns(bool) {
        return _stake(_proposalId, _vote, _amount, msg.sender);
    }

     
    function stakeWithSignature(
        bytes32 _proposalId,
        uint256 _vote,
        uint256 _amount,
        uint256 _nonce,
        uint256 _signatureType,
        bytes calldata _signature
        )
        external
        returns(bool)
        {
         
        bytes32 delegationDigest;
        if (_signatureType == 2) {
            delegationDigest = keccak256(
                abi.encodePacked(
                    DELEGATION_HASH_EIP712, keccak256(
                        abi.encodePacked(
                        address(this),
                        _proposalId,
                        _vote,
                        _amount,
                        _nonce)
                    )
                )
            );
        } else {
            delegationDigest = keccak256(
                        abi.encodePacked(
                        address(this),
                        _proposalId,
                        _vote,
                        _amount,
                        _nonce)
                    ).toEthSignedMessageHash();
        }
        address staker = delegationDigest.recover(_signature);
         
        require(staker != address(0), "staker address cannot be 0");
        require(stakesNonce[staker] == _nonce, "wrong nonce");
        stakesNonce[staker] = stakesNonce[staker].add(1);
        return _stake(_proposalId, _vote, _amount, staker);
    }

     
    function vote(bytes32 _proposalId, uint256 _vote, uint256 _amount, address _voter)
    external
    votable(_proposalId)
    returns(bool) {
        Proposal storage proposal = proposals[_proposalId];
        Parameters memory params = parameters[proposal.paramsHash];
        address voter;
        if (params.voteOnBehalf != address(0)) {
            require(msg.sender == params.voteOnBehalf, "msg.sender is not authorized to vote");
            voter = _voter;
        } else {
            voter = msg.sender;
        }
        return internalVote(_proposalId, voter, _vote, _amount);
    }

   
    function cancelVote(bytes32 _proposalId) external votable(_proposalId) {
        
        return;
    }

     
    function execute(bytes32 _proposalId) external votable(_proposalId) returns(bool) {
        return _execute(_proposalId);
    }

   
    function getNumberOfChoices(bytes32) external view returns(uint256) {
        return NUM_OF_CHOICES;
    }

     
    function getProposalTimes(bytes32 _proposalId) external view returns(uint[3] memory times) {
        return proposals[_proposalId].times;
    }

     
    function voteInfo(bytes32 _proposalId, address _voter) external view returns(uint, uint) {
        Voter memory voter = proposals[_proposalId].voters[_voter];
        return (voter.vote, voter.reputation);
    }

     
    function voteStatus(bytes32 _proposalId, uint256 _choice) external view returns(uint256) {
        return proposals[_proposalId].votes[_choice];
    }

     
    function isVotable(bytes32 _proposalId) external view returns(bool) {
        return _isVotable(_proposalId);
    }

     
    function proposalStatus(bytes32 _proposalId) external view returns(uint256, uint256, uint256, uint256) {
        return (
                proposals[_proposalId].preBoostedVotes[YES],
                proposals[_proposalId].preBoostedVotes[NO],
                proposals[_proposalId].stakes[YES],
                proposals[_proposalId].stakes[NO]
        );
    }

   
    function getProposalOrganization(bytes32 _proposalId) external view returns(bytes32) {
        return (proposals[_proposalId].organizationId);
    }

     
    function getStaker(bytes32 _proposalId, address _staker) external view returns(uint256, uint256) {
        return (proposals[_proposalId].stakers[_staker].vote, proposals[_proposalId].stakers[_staker].amount);
    }

     
    function voteStake(bytes32 _proposalId, uint256 _vote) external view returns(uint256) {
        return proposals[_proposalId].stakes[_vote];
    }

   
    function winningVote(bytes32 _proposalId) external view returns(uint256) {
        return proposals[_proposalId].winningVote;
    }

     
    function state(bytes32 _proposalId) external view returns(ProposalState) {
        return proposals[_proposalId].state;
    }

    
    function isAbstainAllow() external pure returns(bool) {
        return false;
    }

     
    function getAllowedRangeOfChoices() external pure returns(uint256 min, uint256 max) {
        return (YES, NO);
    }

     
    function score(bytes32 _proposalId) public view returns(uint256) {
        return  _score(_proposalId);
    }
}

 

pragma solidity 0.5.17;




contract VotingMachineCallbacks is VotingMachineCallbacksInterface {

    struct ProposalInfo {
        uint256 blockNumber;  
        Avatar avatar;  
    }

    modifier onlyVotingMachine(bytes32 _proposalId) {
        require(proposalsInfo[msg.sender][_proposalId].avatar != Avatar(address(0)), "only VotingMachine");
        _;
    }

     
    mapping(address => mapping(bytes32 => ProposalInfo)) public proposalsInfo;

    function mintReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {
        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return Controller(avatar.owner()).mintReputation(_amount, _beneficiary, address(avatar));
    }

    function burnReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {
        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return Controller(avatar.owner()).burnReputation(_amount, _beneficiary, address(avatar));
    }

    function stakingTokenTransfer(
        IERC20 _stakingToken,
        address _beneficiary,
        uint256 _amount,
        bytes32 _proposalId)
    external
    onlyVotingMachine(_proposalId)
    returns(bool)
    {
        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (avatar == Avatar(0)) {
            return false;
        }
        return Controller(avatar.owner()).externalTokenTransfer(_stakingToken, _beneficiary, _amount, avatar);
    }

    function balanceOfStakingToken(IERC20 _stakingToken, bytes32 _proposalId) external view returns(uint256) {
        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        if (proposalsInfo[msg.sender][_proposalId].avatar == Avatar(0)) {
            return 0;
        }
        return _stakingToken.balanceOf(address(avatar));
    }

    function getTotalReputationSupply(bytes32 _proposalId) external view returns(uint256) {
        ProposalInfo memory proposal = proposalsInfo[msg.sender][_proposalId];
        if (proposal.avatar == Avatar(0)) {
            return 0;
        }
        return proposal.avatar.nativeReputation().totalSupplyAt(proposal.blockNumber);
    }

    function reputationOf(address _owner, bytes32 _proposalId) external view returns(uint256) {
        ProposalInfo memory proposal = proposalsInfo[msg.sender][_proposalId];
        if (proposal.avatar == Avatar(0)) {
            return 0;
        }
        return proposal.avatar.nativeReputation().balanceOfAt(_owner, proposal.blockNumber);
    }
}

 

pragma solidity 0.5.17;






 

contract ContributionReward is UniversalScheme, VotingMachineCallbacks, ProposalExecuteInterface {
    using SafeMath for uint;

    event NewContributionProposal(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _intVoteInterface,
        string _descriptionHash,
        int256 _reputationChange,
        uint[5]  _rewards,
        IERC20 _externalToken,
        address _beneficiary
    );

    event ProposalExecuted(address indexed _avatar, bytes32 indexed _proposalId, int256 _param);

    event RedeemReputation(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        int256 _amount);

    event RedeemEther(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

    event RedeemNativeToken(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

    event RedeemExternalToken(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

     
    struct ContributionProposal {
        uint256 nativeTokenReward;  
        int256 reputationChange;  
        uint256 ethReward;
        IERC20 externalToken;
        uint256 externalTokenReward;
        address payable beneficiary;
        uint256 periodLength;
        uint256 numberOfPeriods;
        uint256 executionTime;
        uint[4] redeemedPeriods;
    }

     
    mapping(address=>mapping(bytes32=>ContributionProposal)) public organizationsProposals;

     
    struct Parameters {
        bytes32 voteApproveParams;
        IntVoteInterface intVote;
    }

     
    mapping(bytes32=>Parameters) public parameters;

     
    function executeProposal(bytes32 _proposalId, int256 _param) external onlyVotingMachine(_proposalId) returns(bool) {
        ProposalInfo memory proposal = proposalsInfo[msg.sender][_proposalId];
        require(organizationsProposals[address(proposal.avatar)][_proposalId].executionTime == 0);
        require(organizationsProposals[address(proposal.avatar)][_proposalId].beneficiary != address(0));
         
        if (_param == 1) {
           
            organizationsProposals[address(proposal.avatar)][_proposalId].executionTime = now;
        }
        emit ProposalExecuted(address(proposal.avatar), _proposalId, _param);
        return true;
    }

     
    function setParameters(
        bytes32 _voteApproveParams,
        IntVoteInterface _intVote
    ) public returns(bytes32)
    {
        bytes32 paramsHash = getParametersHash(
            _voteApproveParams,
            _intVote
        );
        parameters[paramsHash].voteApproveParams = _voteApproveParams;
        parameters[paramsHash].intVote = _intVote;
        return paramsHash;
    }

     
    function proposeContributionReward(
        Avatar _avatar,
        string memory _descriptionHash,
        int256 _reputationChange,
        uint[5] memory _rewards,
        IERC20 _externalToken,
        address payable _beneficiary
    )
    public
    returns(bytes32)
    {
        validateProposalParams(_reputationChange, _rewards);
        Parameters memory controllerParams = parameters[getParametersFromController(_avatar)];

        bytes32 contributionId = controllerParams.intVote.propose(
        2,
        controllerParams.voteApproveParams,
        msg.sender,
        address(_avatar)
        );

        address payable beneficiary = _beneficiary;
        if (beneficiary == address(0)) {
            beneficiary = msg.sender;
        }

        ContributionProposal memory proposal = ContributionProposal({
            nativeTokenReward: _rewards[0],
            reputationChange: _reputationChange,
            ethReward: _rewards[1],
            externalToken: _externalToken,
            externalTokenReward: _rewards[2],
            beneficiary: beneficiary,
            periodLength: _rewards[3],
            numberOfPeriods: _rewards[4],
            executionTime: 0,
            redeemedPeriods:[uint(0), uint(0), uint(0), uint(0)]
        });
        organizationsProposals[address(_avatar)][contributionId] = proposal;

        emit NewContributionProposal(
            address(_avatar),
            contributionId,
            address(controllerParams.intVote),
            _descriptionHash,
            _reputationChange,
            _rewards,
            _externalToken,
            beneficiary
        );

        proposalsInfo[address(controllerParams.intVote)][contributionId] = ProposalInfo({
            blockNumber:block.number,
            avatar:_avatar
        });
        return contributionId;
    }

     
    function redeemReputation(bytes32 _proposalId, Avatar _avatar) public returns(int256 reputation) {

        ContributionProposal memory _proposal = organizationsProposals[address(_avatar)][_proposalId];
        ContributionProposal storage proposal = organizationsProposals[address(_avatar)][_proposalId];
        require(proposal.executionTime != 0);
        uint256 periodsToPay = getPeriodsToPay(_proposalId, address(_avatar), 0);

         
        proposal.reputationChange = 0;
        reputation = int(periodsToPay) * _proposal.reputationChange;
        if (reputation > 0) {
            require(
            Controller(
            _avatar.owner()).mintReputation(uint(reputation), _proposal.beneficiary, address(_avatar)));
        } else if (reputation < 0) {
            require(
            Controller(
            _avatar.owner()).burnReputation(uint(reputation*(-1)), _proposal.beneficiary, address(_avatar)));
        }
        if (reputation != 0) {
            proposal.redeemedPeriods[0] = proposal.redeemedPeriods[0].add(periodsToPay);
            emit RedeemReputation(address(_avatar), _proposalId, _proposal.beneficiary, reputation);
        }
         
        proposal.reputationChange = _proposal.reputationChange;
    }

     
    function redeemNativeToken(bytes32 _proposalId, Avatar _avatar) public returns(uint256 amount) {

        ContributionProposal memory _proposal = organizationsProposals[address(_avatar)][_proposalId];
        ContributionProposal storage proposal = organizationsProposals[address(_avatar)][_proposalId];
        require(proposal.executionTime != 0);
        uint256 periodsToPay = getPeriodsToPay(_proposalId, address(_avatar), 1);
         
        proposal.nativeTokenReward = 0;

        amount = periodsToPay.mul(_proposal.nativeTokenReward);
        if (amount > 0) {
            require(Controller(_avatar.owner()).mintTokens(amount, _proposal.beneficiary, address(_avatar)));
            proposal.redeemedPeriods[1] = proposal.redeemedPeriods[1].add(periodsToPay);
            emit RedeemNativeToken(address(_avatar), _proposalId, _proposal.beneficiary, amount);
        }

         
        proposal.nativeTokenReward = _proposal.nativeTokenReward;
    }

     
    function redeemEther(bytes32 _proposalId, Avatar _avatar) public returns(uint256 amount) {

        ContributionProposal memory _proposal = organizationsProposals[address(_avatar)][_proposalId];
        ContributionProposal storage proposal = organizationsProposals[address(_avatar)][_proposalId];
        require(proposal.executionTime != 0);
        uint256 periodsToPay = getPeriodsToPay(_proposalId, address(_avatar), 2);
         
        proposal.ethReward = 0;
        amount = periodsToPay.mul(_proposal.ethReward);

        if (amount > 0) {
            require(Controller(_avatar.owner()).sendEther(amount, _proposal.beneficiary, _avatar));
            proposal.redeemedPeriods[2] = proposal.redeemedPeriods[2].add(periodsToPay);
            emit RedeemEther(address(_avatar), _proposalId, _proposal.beneficiary, amount);
        }

         
        proposal.ethReward = _proposal.ethReward;
    }

     
    function redeemExternalToken(bytes32 _proposalId, Avatar _avatar) public returns(uint256 amount) {

        ContributionProposal memory _proposal = organizationsProposals[address(_avatar)][_proposalId];
        ContributionProposal storage proposal = organizationsProposals[address(_avatar)][_proposalId];
        require(proposal.executionTime != 0);
        uint256 periodsToPay = getPeriodsToPay(_proposalId, address(_avatar), 3);
         
        proposal.externalTokenReward = 0;

        if (proposal.externalToken != IERC20(0) && _proposal.externalTokenReward > 0) {
            amount = periodsToPay.mul(_proposal.externalTokenReward);
            if (amount > 0) {
                require(
                Controller(
                _avatar.owner())
                .externalTokenTransfer(_proposal.externalToken, _proposal.beneficiary, amount, _avatar));
                proposal.redeemedPeriods[3] = proposal.redeemedPeriods[3].add(periodsToPay);
                emit RedeemExternalToken(address(_avatar), _proposalId, _proposal.beneficiary, amount);
            }
        }
         
        proposal.externalTokenReward = _proposal.externalTokenReward;
    }

     
    function redeem(bytes32 _proposalId, Avatar _avatar, bool[4] memory _whatToRedeem)
    public
    returns(int256 reputationReward, uint256 nativeTokenReward, uint256 etherReward, uint256 externalTokenReward)
    {

        if (_whatToRedeem[0]) {
            reputationReward = redeemReputation(_proposalId, _avatar);
        }

        if (_whatToRedeem[1]) {
            nativeTokenReward = redeemNativeToken(_proposalId, _avatar);
        }

        if (_whatToRedeem[2]) {
            etherReward = redeemEther(_proposalId, _avatar);
        }

        if (_whatToRedeem[3]) {
            externalTokenReward = redeemExternalToken(_proposalId, _avatar);
        }
    }

     
    function getPeriodsToPay(bytes32 _proposalId, address _avatar, uint256 _redeemType) public view returns (uint256) {
        require(_redeemType <= 3, "should be in the redeemedPeriods range");
        ContributionProposal memory _proposal = organizationsProposals[_avatar][_proposalId];
        if (_proposal.executionTime == 0)
            return 0;
        uint256 periodsFromExecution;
        if (_proposal.periodLength > 0) {
           
            periodsFromExecution = (now.sub(_proposal.executionTime))/(_proposal.periodLength);
        }
        uint256 periodsToPay;
        if ((_proposal.periodLength == 0) || (periodsFromExecution >= _proposal.numberOfPeriods)) {
            periodsToPay = _proposal.numberOfPeriods.sub(_proposal.redeemedPeriods[_redeemType]);
        } else {
            periodsToPay = periodsFromExecution.sub(_proposal.redeemedPeriods[_redeemType]);
        }
        return periodsToPay;
    }

     
    function getRedeemedPeriods(bytes32 _proposalId, address _avatar, uint256 _redeemType)
    public
    view
    returns (uint256) {
        return organizationsProposals[_avatar][_proposalId].redeemedPeriods[_redeemType];
    }

    function getProposalEthReward(bytes32 _proposalId, address _avatar) public view returns (uint256) {
        return organizationsProposals[_avatar][_proposalId].ethReward;
    }

    function getProposalExternalTokenReward(bytes32 _proposalId, address _avatar) public view returns (uint256) {
        return organizationsProposals[_avatar][_proposalId].externalTokenReward;
    }

    function getProposalExternalToken(bytes32 _proposalId, address _avatar) public view returns (address) {
        return address(organizationsProposals[_avatar][_proposalId].externalToken);
    }

    function getProposalExecutionTime(bytes32 _proposalId, address _avatar) public view returns (uint256) {
        return organizationsProposals[_avatar][_proposalId].executionTime;
    }

     
    function getParametersHash(
        bytes32 _voteApproveParams,
        IntVoteInterface _intVote
    ) public pure returns(bytes32)
    {
        return (keccak256(abi.encodePacked(_voteApproveParams, _intVote)));
    }

     
    function validateProposalParams(int256 _reputationChange, uint[5] memory _rewards) private pure {
        require(((_rewards[3] > 0) || (_rewards[4] == 1)), "periodLength equal 0 require numberOfPeriods to be 1");
        if (_rewards[4] > 0) {
             
            require(!(int(_rewards[4]) == -1 && _reputationChange == (-2**255)),
            "numberOfPeriods * _reputationChange will overflow");
            
            require((int(_rewards[4]) * _reputationChange) / int(_rewards[4]) == _reputationChange,
            "numberOfPeriods * reputationChange will overflow");
             
            require((_rewards[4] * _rewards[0]) / _rewards[4] == _rewards[0],
            "numberOfPeriods * tokenReward will overflow");
             
            require((_rewards[4] * _rewards[1]) / _rewards[4] == _rewards[1],
            "numberOfPeriods * ethReward will overflow");
             
            require((_rewards[4] * _rewards[2]) / _rewards[4] == _rewards[2],
            "numberOfPeriods * texternalTokenReward will overflow");
        }
    }

}

 

pragma solidity 0.5.17;






 
contract ContributionRewardExt is VotingMachineCallbacks, ProposalExecuteInterface {
    using SafeMath for uint;
    using SafeERC20 for address;

    event NewContributionProposal(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _intVoteInterface,
        string _descriptionHash,
        int256 _reputationChange,
        uint[3]  _rewards,
        IERC20 _externalToken,
        address _beneficiary,
        address _proposer
    );

    event ProposalExecuted(address indexed _avatar, bytes32 indexed _proposalId, int256 _param);

    event RedeemReputation(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        int256 _amount);

    event RedeemEther(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

    event RedeemNativeToken(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

    event RedeemExternalToken(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _beneficiary,
        uint256 _amount);

     
    struct ContributionProposal {
        uint256 nativeTokenReward;  
        int256 reputationChange;  
        uint256 ethReward;
        IERC20 externalToken;
        uint256 externalTokenReward;
        address payable beneficiary;
        uint256 nativeTokenRewardLeft;
        uint256 reputationChangeLeft;
        uint256 ethRewardLeft;
        uint256 externalTokenRewardLeft;
        bool acceptedByVotingMachine;
    }

    modifier onlyRewarder() {
        require(msg.sender == rewarder, "msg.sender is not authorized");
        _;
    }

    mapping(bytes32=>ContributionProposal) public organizationProposals;

    IntVoteInterface public votingMachine;
    bytes32 public voteParams;
    Avatar public avatar;
    address public rewarder;

     
    function() external payable {
    }

     
    function initialize(
        Avatar _avatar,
        IntVoteInterface _votingMachine,
        bytes32 _voteParams,
        address _rewarder
    )
    external
    {
        require(avatar == Avatar(0), "can be called only one time");
        require(_avatar != Avatar(0), "avatar cannot be zero");
        require(_votingMachine != IntVoteInterface(0), "votingMachine cannot be zero");
        avatar = _avatar;
        votingMachine = _votingMachine;
        voteParams = _voteParams;
        rewarder = _rewarder;
    }

     
    function executeProposal(bytes32 _proposalId, int256 _decision)
    external
    onlyVotingMachine(_proposalId)
    returns(bool) {
        require(organizationProposals[_proposalId].acceptedByVotingMachine == false);
        require(organizationProposals[_proposalId].beneficiary != address(0));
        if (_decision == 1) {
            organizationProposals[_proposalId].acceptedByVotingMachine = true;
        }
        emit ProposalExecuted(address(avatar), _proposalId, _decision);
        return true;
    }

     
    function proposeContributionReward(
        string memory _descriptionHash,
        int256 _reputationChange,
        uint[3] memory _rewards,
        IERC20 _externalToken,
        address payable _beneficiary,
        address _proposer
    )
    public
    returns(bytes32 proposalId)
    {
        address proposer = _proposer;
        if (proposer == address(0)) {
            proposer = msg.sender;
        }
        proposalId = votingMachine.propose(2, voteParams, proposer, address(avatar));
        address payable beneficiary = _beneficiary;
        if (beneficiary == address(0)) {
            beneficiary = msg.sender;
        }
        if (beneficiary == address(this)) {
            require(_reputationChange >= 0, "negative rep change not allowed for this case");
        }

        ContributionProposal memory proposal = ContributionProposal({
            nativeTokenReward: _rewards[0],
            reputationChange: _reputationChange,
            ethReward: _rewards[1],
            externalToken: _externalToken,
            externalTokenReward: _rewards[2],
            beneficiary: beneficiary,
            nativeTokenRewardLeft: 0,
            reputationChangeLeft: 0,
            ethRewardLeft: 0,
            externalTokenRewardLeft: 0,
            acceptedByVotingMachine: false
        });
        organizationProposals[proposalId] = proposal;

        emit NewContributionProposal(
            address(avatar),
            proposalId,
            address(votingMachine),
            _descriptionHash,
            _reputationChange,
            _rewards,
            _externalToken,
            beneficiary,
            proposer
        );

        proposalsInfo[address(votingMachine)][proposalId] = ProposalInfo({
            blockNumber:block.number,
            avatar:avatar
        });
    }

     
    function redeemReputation(bytes32 _proposalId) public returns(int256 reputation) {
        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");

         
         
         
        if (proposal.beneficiary == address(this)) {
            if (proposal.reputationChangeLeft == 0) { 
                proposal.reputationChangeLeft = uint256(proposal.reputationChange);
                proposal.reputationChange = 0;
            }
        } else {
            reputation = proposal.reputationChange;
             
            proposal.reputationChange = 0;

            if (reputation > 0) {
                require(
                Controller(
                avatar.owner()).mintReputation(uint(reputation), proposal.beneficiary, address(avatar)));
            } else if (reputation < 0) {
                require(
                Controller(
                avatar.owner()).burnReputation(uint(reputation*(-1)), proposal.beneficiary, address(avatar)));
            }
            if (reputation != 0) {
                emit RedeemReputation(address(avatar), _proposalId, proposal.beneficiary, reputation);
            }
        }
    }

     
    function redeemNativeToken(bytes32 _proposalId) public returns(uint256 amount) {

        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");

        if (proposal.beneficiary == address(this)) {
             
            if (proposal.nativeTokenRewardLeft == 0) {
                proposal.nativeTokenRewardLeft = proposal.nativeTokenReward;
            }
        }
        amount = proposal.nativeTokenReward;
         
        proposal.nativeTokenReward = 0;
        if (amount > 0) {
            require(Controller(avatar.owner()).mintTokens(amount, proposal.beneficiary, address(avatar)));
            emit RedeemNativeToken(address(avatar), _proposalId, proposal.beneficiary, amount);
        }
    }

     
    function redeemEther(bytes32 _proposalId) public returns(uint256 amount) {
        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");

        if (proposal.beneficiary == address(this)) {
            if (proposal.ethRewardLeft == 0) {
                proposal.ethRewardLeft = proposal.ethReward;
            }
        }
        amount = proposal.ethReward;
         
        proposal.ethReward = 0;
        if (amount > 0) {
            require(Controller(avatar.owner()).sendEther(amount, proposal.beneficiary, avatar));
            emit RedeemEther(address(avatar), _proposalId, proposal.beneficiary, amount);
        }
    }

     
    function redeemExternalToken(bytes32 _proposalId) public returns(uint256 amount) {
        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");


        if (proposal.beneficiary == address(this)) {
            if (proposal.externalTokenRewardLeft == 0) {
                proposal.externalTokenRewardLeft = proposal.externalTokenReward;
            }
        }

        if (proposal.externalToken != IERC20(0) && proposal.externalTokenReward > 0) {
            amount = proposal.externalTokenReward;
             
            proposal.externalTokenReward = 0;
            require(
            Controller(
            avatar.owner())
            .externalTokenTransfer(proposal.externalToken, proposal.beneficiary, amount, avatar));
            emit RedeemExternalToken(address(avatar), _proposalId, proposal.beneficiary, amount);
        }
    }

     
    function redeemReputationByRewarder(bytes32 _proposalId, address _beneficiary, uint256 _reputation)
    public
    onlyRewarder
    {
        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
         
         
        proposal.reputationChangeLeft =
        proposal.reputationChangeLeft.sub(_reputation,
        "cannot redeem more reputation than allocated for this proposal or no redeemReputation was called");
        require(
        Controller(
        avatar.owner()).mintReputation(_reputation, _beneficiary, address(avatar)));
        if (_reputation != 0) {
            emit RedeemReputation(address(avatar), _proposalId, _beneficiary, int256(_reputation));
        }
    }

     
    function redeemNativeTokenByRewarder(bytes32 _proposalId, address _beneficiary, uint256 _amount)
    public
    onlyRewarder
    {
        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
         
         
        proposal.nativeTokenRewardLeft =
        proposal.nativeTokenRewardLeft.sub(_amount,
        "cannot redeem more tokens than allocated for this proposal or no redeemNativeToken was called");

        if (_amount > 0) {
            address(avatar.nativeToken()).safeTransfer(_beneficiary, _amount);
            emit RedeemNativeToken(address(avatar), _proposalId, _beneficiary, _amount);
        }
    }

     
    function redeemEtherByRewarder(bytes32 _proposalId, address payable _beneficiary, uint256 _amount)
    public
    onlyRewarder
    {
        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
         
         
        proposal.ethRewardLeft = proposal.ethRewardLeft.sub(_amount,
        "cannot redeem more Ether than allocated for this proposal or no redeemEther was called");

        if (_amount > 0) {
            _beneficiary.transfer(_amount);
            emit RedeemEther(address(avatar), _proposalId, _beneficiary, _amount);
        }
    }

     
    function redeemExternalTokenByRewarder(bytes32 _proposalId, address _beneficiary, uint256 _amount)
    public
    onlyRewarder {
        ContributionProposal storage proposal = organizationProposals[_proposalId];
        require(proposal.acceptedByVotingMachine, "proposal was not accepted by the voting machine");
         
         
        proposal.externalTokenRewardLeft =
        proposal.externalTokenRewardLeft.sub(_amount,
        "cannot redeem more tokens than allocated for this proposal or no redeemExternalToken was called");

        if (proposal.externalToken != IERC20(0)) {
            if (_amount > 0) {
                address(proposal.externalToken).safeTransfer(_beneficiary, _amount);
                emit RedeemExternalToken(address(avatar), _proposalId, _beneficiary, _amount);
            }
        }
    }

     
    function redeem(bytes32 _proposalId, bool[4] memory _whatToRedeem)
    public
    returns(int256 reputationReward, uint256 nativeTokenReward, uint256 etherReward, uint256 externalTokenReward)
    {

        if (_whatToRedeem[0]) {
            reputationReward = redeemReputation(_proposalId);
        }

        if (_whatToRedeem[1]) {
            nativeTokenReward = redeemNativeToken(_proposalId);
        }

        if (_whatToRedeem[2]) {
            etherReward = redeemEther(_proposalId);
        }

        if (_whatToRedeem[3]) {
            externalTokenReward = redeemExternalToken(_proposalId);
        }
    }

    function getProposalEthReward(bytes32 _proposalId) public view returns (uint256) {
        return organizationProposals[_proposalId].ethReward;
    }

    function getProposalExternalTokenReward(bytes32 _proposalId) public view returns (uint256) {
        return organizationProposals[_proposalId].externalTokenReward;
    }

    function getProposalExternalToken(bytes32 _proposalId) public view returns (address) {
        return address(organizationProposals[_proposalId].externalToken);
    }

    function getProposalReputationReward(bytes32 _proposalId) public view returns (int256) {
        return organizationProposals[_proposalId].reputationChange;
    }

    function getProposalNativeTokenReward(bytes32 _proposalId) public view returns (uint256) {
        return organizationProposals[_proposalId].nativeTokenReward;
    }

    function getProposalAcceptedByVotingMachine(bytes32 _proposalId) public view returns (bool) {
        return organizationProposals[_proposalId].acceptedByVotingMachine;
    }

}

 

pragma solidity 0.5.17;






contract Redeemer {
    using SafeMath for uint;

    
    function redeem(ContributionReward _contributionReward,
                    GenesisProtocol _genesisProtocol,
                    bytes32 _proposalId,
                    Avatar _avatar,
                    address _beneficiary)
    external
    returns(uint[3] memory gpRewards,
            uint[2] memory gpDaoBountyReward,
            bool executed,
            uint256 winningVote,
            int256 crReputationReward,
            uint256 crNativeTokenReward,
            uint256 crEthReward,
            uint256 crExternalTokenReward)
    {
        bool callContributionReward;
        (gpRewards, gpDaoBountyReward, executed, winningVote, callContributionReward) =
        genesisProtocolRedeem(_genesisProtocol, _proposalId, _beneficiary);
        if (callContributionReward) {
             
            if (_contributionReward.getProposalExecutionTime(_proposalId, address(_avatar)) > 0) {
                (crReputationReward, crNativeTokenReward, crEthReward, crExternalTokenReward) =
                contributionRewardRedeem(_contributionReward, _proposalId, _avatar);
            }
        }
    }

     
    function redeemFromCRExt(ContributionRewardExt _contributionRewardExt,
                            GenesisProtocol _genesisProtocol,
                            bytes32 _proposalId,
                            address _beneficiary)
        external
        returns(uint[3] memory gpRewards,
                uint[2] memory gpDaoBountyReward,
                bool executed,
                uint256 winningVote,
                int256 crReputationReward,
                uint256 crNativeTokenReward,
                uint256 crEthReward,
                uint256 crExternalTokenReward)
    {
        bool callContributionReward;
        (gpRewards, gpDaoBountyReward, executed, winningVote, callContributionReward) =
        genesisProtocolRedeem(_genesisProtocol, _proposalId, _beneficiary);
        if (callContributionReward) {
                
            if (_contributionRewardExt.getProposalAcceptedByVotingMachine(_proposalId)) {
                (crReputationReward, crNativeTokenReward, crEthReward, crExternalTokenReward) =
                contributionRewardExtRedeem(_contributionRewardExt, _proposalId);
            }
        }
    }

    function genesisProtocolRedeem(GenesisProtocol _genesisProtocol,
                                    bytes32 _proposalId,
                                    address _beneficiary)
    private
    returns(uint[3] memory gpRewards,
            uint[2] memory gpDaoBountyReward,
            bool executed,
            uint256 winningVote,
            bool callContributionReward) {
        GenesisProtocol.ProposalState pState = _genesisProtocol.state(_proposalId);

        if ((pState == GenesisProtocolLogic.ProposalState.Queued)||
            (pState == GenesisProtocolLogic.ProposalState.PreBoosted)||
            (pState == GenesisProtocolLogic.ProposalState.Boosted)||
            (pState == GenesisProtocolLogic.ProposalState.QuietEndingPeriod)) {
            executed = _genesisProtocol.execute(_proposalId);
        }
        pState = _genesisProtocol.state(_proposalId);
        if ((pState == GenesisProtocolLogic.ProposalState.Executed) ||
            (pState == GenesisProtocolLogic.ProposalState.ExpiredInQueue)) {
            gpRewards = _genesisProtocol.redeem(_proposalId, _beneficiary);
            if (pState == GenesisProtocolLogic.ProposalState.Executed) {
                (gpDaoBountyReward[0], gpDaoBountyReward[1]) =
                _genesisProtocol.redeemDaoBounty(_proposalId, _beneficiary);
            }
            winningVote = _genesisProtocol.winningVote(_proposalId);
            callContributionReward = true;
        }
    }

    function contributionRewardRedeem(ContributionReward _contributionReward, bytes32 _proposalId, Avatar _avatar)
    private
    returns (int256 reputation, uint256 nativeToken, uint256 eth, uint256 externalToken)
    {
        bool[4] memory whatToRedeem;
        whatToRedeem[0] = true;  
        whatToRedeem[1] = true;  
        uint256 periodsToPay = _contributionReward.getPeriodsToPay(_proposalId, address(_avatar), 2);
        uint256 ethReward = _contributionReward.getProposalEthReward(_proposalId, address(_avatar));
        uint256 externalTokenReward = _contributionReward.getProposalExternalTokenReward(_proposalId, address(_avatar));
        address externalTokenAddress = _contributionReward.getProposalExternalToken(_proposalId, address(_avatar));
        ethReward = periodsToPay.mul(ethReward);
        if ((ethReward == 0) || (address(_avatar).balance < ethReward)) {
            whatToRedeem[2] = false;
        } else {
            whatToRedeem[2] = true;
        }
        periodsToPay = _contributionReward.getPeriodsToPay(_proposalId, address(_avatar), 3);
        externalTokenReward = periodsToPay.mul(externalTokenReward);
        if ((externalTokenReward == 0) ||
            (IERC20(externalTokenAddress).balanceOf(address(_avatar)) < externalTokenReward)) {
            whatToRedeem[3] = false;
        } else {
            whatToRedeem[3] = true;
        }
        (reputation, nativeToken, eth, externalToken) = _contributionReward.redeem(_proposalId, _avatar, whatToRedeem);
    }

    function contributionRewardExtRedeem(ContributionRewardExt _contributionRewardExt, bytes32 _proposalId)
    private
    returns (int256 reputation, uint256 nativeToken, uint256 eth, uint256 externalToken)
    {
        bool[4] memory whatToRedeem;
        whatToRedeem[0] = true;  
        whatToRedeem[1] = true;  
        uint256 ethReward = _contributionRewardExt.getProposalEthReward(_proposalId);
        uint256 externalTokenReward = _contributionRewardExt.getProposalExternalTokenReward(_proposalId);
        address externalTokenAddress = _contributionRewardExt.getProposalExternalToken(_proposalId);
        if ((ethReward == 0) || (address(_contributionRewardExt.avatar()).balance < ethReward)) {
            whatToRedeem[2] = false;
        } else {
            whatToRedeem[2] = true;
        }
        if ((externalTokenReward == 0) ||
            (IERC20(externalTokenAddress).balanceOf(address(_contributionRewardExt.avatar())) < externalTokenReward)) {
            whatToRedeem[3] = false;
        } else {
            whatToRedeem[3] = true;
        }
        (reputation, nativeToken, eth, externalToken) = _contributionRewardExt.redeem(_proposalId, whatToRedeem);
    }
}