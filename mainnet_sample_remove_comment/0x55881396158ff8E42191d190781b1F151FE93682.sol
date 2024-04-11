 

 

 

pragma solidity 0.6.12;



 

interface IController {
    function mint(address, uint256) external;
    function withdraw(address, uint256) external;
    function withdrawVote(address, uint256) external;
    function deposit(address, uint256) external;
    function depositVote(address, uint256) external;
    function totalAssets(address) external view returns (uint256);
    function rewards() external view returns (address);
    function strategies(address) external view returns (address);
    function vaults(address) external view returns (address);
    function setHarvestInfo(address _token, uint256 _harvestReward) external;
}

 

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

 

contract DToken {
    
    string public name;

    
    string public symbol;

    
    uint8 public decimals;

    
    uint256 public totalSupply;

    
    mapping (address => mapping (address => uint256)) internal allowances;

    
    mapping (address => uint256) internal balances;

    address public governance;
    address public pendingGovernance;
    address public convController;
    address public vault;

    
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    
    mapping (address => uint32) public numCheckpoints;

    
    event AccountVotesChanged(address indexed account, uint256 previousBalance, uint256 newBalance);

    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    function initialize(address _governance, uint8  _decimals, bytes calldata _name, bytes calldata _symbol) external {
        require(governance == address(0), 'initialize: can only initialize once');
        require(_governance != address(0), 'initialize: invalid governance address');
        governance = _governance;
        convController = msg.sender;
        name = string(_name);
        symbol = string(_symbol);
        decimals = _decimals;
    }

    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = sub256(spenderAllowance, amount, "transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

     
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

     
    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

         
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

         
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2;  
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _transferTokens(address src, address dst, uint256 amount) internal {
        require(src != address(0), "_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "_transferTokens: cannot transfer to the zero address");

        balances[src] = sub256(balances[src], amount, "_transferTokens: transfer amount exceeds balance");
        balances[dst] = add256(balances[dst], amount, "_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);

        _moveVotes(src);
        _moveVotes(dst);
    }

    function _moveVotes(address account) internal {
        uint32 repNum = numCheckpoints[account];
        uint256 oldBalance = repNum > 0 ? checkpoints[account][repNum - 1].votes : 0;
        _writeCheckpoint(account, repNum, oldBalance, balances[account]);
    }

    function _writeCheckpoint(address account, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
        uint32 blockNumber = safe32(block.number, "_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[account][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[account][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[account][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[account] = nCheckpoints + 1;
        }

        emit AccountVotesChanged(account, oldVotes, newVotes);
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "!pendingGovernance");
        governance = msg.sender;
        pendingGovernance = address(0);
    }

    function setPendingGovernance(address _pendingGovernance) external {
        require(msg.sender == governance, "!governance");
        pendingGovernance = _pendingGovernance;
    }

    function setConvController(address _convController) external {
        require(msg.sender == governance, "!governance");
        convController = _convController;
    }

    function setVault(address _vault) external {
        require(msg.sender == governance, "!governance");
        vault = _vault;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == convController || msg.sender == vault, "NOT OPERATOR");
        _mint(account,amount);
        emit Mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(msg.sender == convController || msg.sender == vault, "NOT OPERATOR");
        _burn(account,amount);
        emit Burn(account, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply = add256(totalSupply, amount, "ERC20: mint amount overflows");
        balances[account] = add256(balances[account], amount, "ERC20: mint amount overflows");

        emit Transfer(address(0), account, amount);
        _moveVotes(account);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        balances[account] = sub256(balances[account], amount, "ERC20: burn amount exceeds balance");
        totalSupply = sub256(totalSupply, amount, "ERC20: burn amount exceeds balance");

        emit Transfer(account, address(0), amount);
        _moveVotes(account);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add256(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub256(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function sweep(address _token) external {
        require(msg.sender == governance, "!governance");

        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(governance, _balance);
    }
}

 

contract EToken {
    
    string public name;

    
    string public symbol;

    
    uint8 public decimals;

    
    uint256 public totalSupply;

    
    mapping (address => mapping (address => uint256)) internal allowances;

    
    mapping (address => uint256) internal balances;

    address public governance;
    address public pendingGovernance;
    address public convController;
    address public vault;

    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    function initialize(address _governance, uint8  _decimals, bytes calldata _name, bytes calldata _symbol) external {
        require(governance == address(0), 'initialize: can only initialize once');
        require(_governance != address(0), 'initialize: invalid governance address');
        governance = _governance;
        convController = msg.sender;
        name = string(_name);
        symbol = string(_symbol);
        decimals = _decimals;
    }

    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = sub256(spenderAllowance, amount, "transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(address src, address dst, uint256 amount) internal {
        require(src != address(0), "_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "_transferTokens: cannot transfer to the zero address");

        balances[src] = sub256(balances[src], amount, "_transferTokens: transfer amount exceeds balance");
        balances[dst] = add256(balances[dst], amount, "_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "!pendingGovernance");
        governance = msg.sender;
        pendingGovernance = address(0);
    }

    function setPendingGovernance(address _pendingGovernance) external {
        require(msg.sender == governance, "!governance");
        pendingGovernance = _pendingGovernance;
    }

    function setConvController(address _convController) external {
        require(msg.sender == governance, "!governance");
        convController = _convController;
    }

    function setVault(address _vault) external {
        require(msg.sender == governance, "!governance");
        vault = _vault;
    }

    function mint(address account, uint256 amount) external {
       require(msg.sender == convController || msg.sender == vault, "NOT OPERATOR");
       _mint(account,amount);
       emit Mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(msg.sender == convController || msg.sender == vault, "NOT OPERATOR");
        _burn(account,amount);
        emit Burn(account, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply = add256(totalSupply, amount, "ERC20: mint amount overflows");
        balances[account] = add256(balances[account], amount, "ERC20: mint amount overflows");

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        balances[account] = sub256(balances[account], amount, "ERC20: burn amount exceeds balance");
        totalSupply = sub256(totalSupply, amount, "ERC20: burn amount exceeds balance");

        emit Transfer(account, address(0), amount);
    }

    function add256(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub256(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function sweep(address _token) external {
        require(msg.sender == governance, "!governance");

        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(governance, _balance);
    }
}

 

 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view override returns (uint256) {
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

     
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

     
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

 

 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

contract ConvController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public governance;
    address public pendingGovernance;
    address public controller;
    address public reward;
    bool public unlocked;

    uint256 public withdrawalFee = 10;
    uint256 constant public withdrawalMax = 10000;

    address public operator;
    mapping(address => bool) public locks;

    mapping(address => address) public dtokens;
    mapping(address => address) public etokens;
    address[] public tokens;
    mapping(address => mapping(address => uint256)) public convertAt;

    event PairCreated(address indexed token, address indexed dtoken, address indexed etoken);
    event Convert(address indexed account, address indexed token, uint256 amount);
    event Redeem(address indexed account, address indexed token, uint256 amount, uint256 fee);

    constructor(address _controller, address _reward, address _operator) public {
        governance = msg.sender;
        controller = _controller;
        reward = _reward;
        operator = _operator;
        unlocked = true;
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "!pendingGovernance");
        governance = msg.sender;
        pendingGovernance = address(0);
    }
    function setPendingGovernance(address _pendingGovernance) external {
        require(msg.sender == governance, "!governance");
        pendingGovernance = _pendingGovernance;
    }
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
    function setReward(address _reward) external {
        require(msg.sender == governance, "!governance");
        reward = _reward;
    }

    function setOperator(address _operator) external {
        require(msg.sender == governance, "!governance");
        operator = _operator;
    }
    function setWithdrawalFee(uint256 _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        require(_withdrawalFee <= withdrawalMax, "!_withdrawalFee");
        withdrawalFee = _withdrawalFee;
    }

    function locking(address _token) external {
        require(msg.sender == operator || msg.sender == governance, "!operator");
        locks[_token] = true;
    }
    function unlocking(address _token) external {
        require(msg.sender == operator || msg.sender == governance, "!operator");
        locks[_token] = false;
    }

    function convertAll(address _token) external {
        convert(_token, IERC20(_token).balanceOf(msg.sender));
    }

    function convert(address _token, uint256 _amount) public {
        require(unlocked, "!unlock");
        unlocked = false;
        require(dtokens[_token] != address(0), "address(0)");

        convertAt[_token][msg.sender] = block.number;

        if (IController(controller).strategies(_token) != address(0)) {
            IERC20(_token).safeTransferFrom(msg.sender, controller, _amount);
            IController(controller).deposit(_token, _amount);
        } else {
            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        }
        _mint(_token, msg.sender, _amount);

        emit Convert(msg.sender, _token, _amount);
        unlocked = true;
    }

    function mint(address _token, address _minter, uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        require(dtokens[_token] != address(0), "address(0)");

        _mint(_token, _minter, _amount);
        emit Convert(_minter, _token, _amount);
    }

    function _mint(address _token, address _minter, uint256 _amount) internal {
        DToken(dtokens[_token]).mint(_minter, _amount);
        EToken(etokens[_token]).mint(_minter, _amount);
    }

    function redeemAll(address _token) external {
        uint256 _amount = maxRedeemAmount(_token);
        redeem(_token, _amount);
    }

    function redeem(address _token, uint256 _amount) public {
        require(unlocked, "!unlock");
        unlocked = false;
        require(!locks[_token], "locking");
        require(dtokens[_token] != address(0), "address(0)");
        require(convertAt[_token][msg.sender] < block.number, "!convertAt");

        DToken(dtokens[_token]).burn(msg.sender, _amount);
        EToken(etokens[_token]).burn(msg.sender, _amount);

        uint256 _balance = IERC20(_token).balanceOf(address(this));
        if (_balance < _amount) {
            if (IController(controller).strategies(_token) != address(0)) {
                uint256 _withdraw = _amount.sub(_balance);
                IController(controller).withdraw(_token, _withdraw);
                _balance = IERC20(_token).balanceOf(address(this));
            }
            if (_balance < _amount) {
                _amount = _balance;
            }
        }

        uint256 _fee = _amount.mul(withdrawalFee).div(withdrawalMax);
        IERC20(_token).safeTransfer(reward, _fee);
        IERC20(_token).safeTransfer(msg.sender, _amount.sub(_fee));
        emit Redeem(msg.sender, _token, _amount, _fee);
        unlocked = true;
    }

    function createPair(address _token) external returns (address _dtoken, address _etoken) {
        require(unlocked, "!unlock");
        unlocked = false;
        require(dtokens[_token] == address(0), "!address(0)");

        bytes memory _nameD = abi.encodePacked(ERC20(_token).symbol(), " dToken");
        bytes memory _symbolD = abi.encodePacked("d", ERC20(_token).symbol());
        bytes memory _nameE = abi.encodePacked(ERC20(_token).symbol(), " eToken");
        bytes memory _symbolE = abi.encodePacked("e", ERC20(_token).symbol());
        uint8 _decimals = ERC20(_token).decimals();

        bytes memory _bytecodeD = type(DToken).creationCode;
        bytes32 _saltD = keccak256(abi.encodePacked(_token, _nameD, _symbolD));
        assembly {
            _dtoken := create2(0, add(_bytecodeD, 32), mload(_bytecodeD), _saltD)
        }
        DToken(_dtoken).initialize(governance, _decimals, _nameD, _symbolD);

        bytes memory _bytecodeE = type(EToken).creationCode;
        bytes32 _saltE = keccak256(abi.encodePacked(_token, _nameE, _symbolE));
        assembly {
            _etoken := create2(0, add(_bytecodeE, 32), mload(_bytecodeE), _saltE)
        }
        EToken(_etoken).initialize(governance, _decimals, _nameE, _symbolE);

        dtokens[_token] = _dtoken;
        etokens[_token] = _etoken;
        tokens.push(_token);

        emit PairCreated(_token, _dtoken, _etoken);
        unlocked = true;
    }

    function maxRedeemAmount(address _token) public view returns (uint256) {
        uint256 _dbalance = IERC20(dtokens[_token]).balanceOf(msg.sender);
        uint256 _ebalance = IERC20(etokens[_token]).balanceOf(msg.sender);
        if (_dbalance > _ebalance) {
            return _ebalance;
        } else {
            return _dbalance;
        }
    }

    function tokenBalance(address _token) public view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function dTokenEToken(address _token) public view returns (address _dtoken, address _etoken) {
        _dtoken = dtokens[_token];
        _etoken = etokens[_token];
        return (_dtoken, _etoken);
    }

    function tokensInfo() public view returns (address[] memory _tokens){
        uint256 length = tokens.length;
        _tokens = new address[](tokens.length);
        for (uint256 i = 0; i < length; ++i) {
            _tokens[i] = tokens[i];
        }
    }

    function tokenLength() public view returns (uint256) {
        return tokens.length;
    }

    function deposit(address _token) external {
        uint256 _balance = tokenBalance(_token);
        IERC20(_token).safeTransfer(controller, _balance);
        IController(controller).deposit(_token, _balance);
    }

    function sweep(address _token) external {
        require(msg.sender == governance, "!governance");
        require(dtokens[_token] == address(0), "!address(0)");

        uint256 _balance = tokenBalance(_token);
        IERC20(_token).safeTransfer(reward, _balance);
    }
}