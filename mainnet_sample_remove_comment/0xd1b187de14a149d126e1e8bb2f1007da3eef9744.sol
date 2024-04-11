 
pragma abicoder v2;


 

pragma solidity ^0.7.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity ^0.7.0;



 
abstract contract ERC165 is IERC165 {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
         
         
        _registerInterface(_INTERFACE_ID_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

 

 
pragma solidity >=0.4.24 <0.8.0;



 
abstract contract Initializable {

     
    bool private _initialized;

     
    bool private _initializing;

     
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

 

pragma solidity ^0.7.0;

 
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

 

pragma solidity ^0.7.0;



 
interface IERC1155Receiver is IERC165 {

     
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

     
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
pragma solidity >=0.7.0;

interface IMiningPool {
    event Allocated(uint256 amount);
    event Dispatched(address indexed user, uint256 numOfMiners);
    event Withdrawn(address indexed user, uint256 numOfMiners);
    event Mined(address indexed user, uint256 amount);

    function initialize(address _tokenEmitter, address _baseToken) external;

    function allocate(uint256 amount) external;

    function token() external view returns (address);

    function tokenEmitter() external view returns (address);

    function baseToken() external view returns (address);

    function miningEnds() external view returns (uint256);

    function miningRate() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function lastTimeMiningApplicable() external view returns (uint256);

    function tokenPerMiner() external view returns (uint256);

    function mined(address account) external view returns (uint256);

    function getMineableForPeriod() external view returns (uint256);

    function paidTokenPerMiner(address account) external view returns (uint256);

    function dispatchedMiners(address account) external view returns (uint256);

    function totalMiners() external view returns (uint256);
}

 
pragma solidity >=0.7.0;





contract ERC20Recoverer is Initializable {
    using SafeERC20 for IERC20;

    mapping(address => bool) public permanentlyNonRecoverable;
    mapping(address => bool) public nonRecoverable;

    event Recovered(address token, uint256 amount);

    address public recoverer;

    constructor() {}

    modifier onlyRecoverer() {
        require(msg.sender == recoverer, "Only allowed to recoverer");
        _;
    }

    function initialize(address _recoverer, address[] memory disableList)
        public
        initializer
    {
        for (uint256 i = 0; i < disableList.length; i++) {
            permanentlyNonRecoverable[disableList[i]] = true;
        }
        recoverer = _recoverer;
    }

    function setRecoverer(address _recoverer) public onlyRecoverer {
        recoverer = _recoverer;
    }

     
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyRecoverer
    {
        require(nonRecoverable[tokenAddress] == false, "Non-recoverable ERC20");
        require(
            permanentlyNonRecoverable[tokenAddress] == false,
            "Non-recoverable ERC20"
        );
        IERC20(tokenAddress).safeTransfer(recoverer, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function disable(address _contract) public onlyRecoverer {
        nonRecoverable[_contract] = true;
    }

    function disablePermanently(address _contract) public onlyRecoverer {
        permanentlyNonRecoverable[_contract] = true;
    }

    function enable(address _contract) public onlyRecoverer {
        permanentlyNonRecoverable[_contract] = true;
    }
}

 

pragma solidity ^0.7.0;




 
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}

 

pragma solidity ^0.7.0;

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

 

pragma solidity ^0.7.0;



 
abstract contract Pausable is Context {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    constructor () {
        _paused = false;
    }

     
    function paused() public view virtual returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

     
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

 

pragma solidity ^0.7.0;





 
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

 
 
pragma solidity >=0.7.0;













abstract contract MiningPool is
    ReentrancyGuard,
    Pausable,
    ERC20Recoverer,
    ERC165,
    IMiningPool
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _baseToken;
    address private _token;
    address private _tokenEmitter;

    uint256 private _miningEnds = 0;
    uint256 private _miningRate = 0;
    uint256 private _lastUpdateTime;
    uint256 private _tokenPerMiner;
    uint256 private _totalMiners;

    mapping(address => uint256) private _paidTokenPerMiner;
    mapping(address => uint256) private _mined;
    mapping(address => uint256) private _dispatchedMiners;

    modifier onlyTokenEmitter() {
        require(
            msg.sender == address(_tokenEmitter),
            "Only the token emitter can call this function"
        );
        _;
    }

    modifier recordMining(address account) {
        _tokenPerMiner = tokenPerMiner();
        _lastUpdateTime = lastTimeMiningApplicable();
        if (account != address(0)) {
            _mined[account] = mined(account);
            _paidTokenPerMiner[account] = _tokenPerMiner;
        }
        _;
    }

    function initialize(address tokenEmitter_, address baseToken_)
        public
        virtual
        override
    {
        address token_ = ITokenEmitter(tokenEmitter_).token();

        require(address(_token) == address(0), "Already initialized");
        require(token_ != address(0), "Token is zero address");
        require(tokenEmitter_ != address(0), "Token emitter is zero address");
        require(baseToken_ != address(0), "Base token is zero address");
        _token = token_;
        _tokenEmitter = tokenEmitter_;
        _baseToken = baseToken_;
         
        address[] memory disable = new address[](2);
        disable[0] = token_;
        disable[1] = baseToken_;
        ERC20Recoverer.initialize(msg.sender, disable);
         
        bytes4 _INTERFACE_ID_ERC165 = 0x01ffc9a7;
        _registerInterface(_INTERFACE_ID_ERC165);
        _registerInterface(MiningPool(0).allocate.selector);
    }

    function allocate(uint256 amount)
        public
        override
        onlyTokenEmitter
        recordMining(address(0))
    {
        uint256 miningPeriod = ITokenEmitter(_tokenEmitter).EMISSION_PERIOD();
        if (block.timestamp >= _miningEnds) {
            _miningRate = amount.div(miningPeriod);
        } else {
            uint256 remaining = _miningEnds.sub(block.timestamp);
            uint256 leftover = remaining.mul(_miningRate);
            _miningRate = amount.add(leftover).div(miningPeriod);
        }

         
         
         
         
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(_miningRate <= balance.div(miningPeriod), "not enough balance");

        _lastUpdateTime = block.timestamp;
        _miningEnds = block.timestamp.add(miningPeriod);
        emit Allocated(amount);
    }

    function token() public view override returns (address) {
        return _token;
    }

    function tokenEmitter() public view override returns (address) {
        return _tokenEmitter;
    }

    function baseToken() public view override returns (address) {
        return _baseToken;
    }

    function miningEnds() public view override returns (uint256) {
        return _miningEnds;
    }

    function miningRate() public view override returns (uint256) {
        return _miningRate;
    }

    function lastUpdateTime() public view override returns (uint256) {
        return _lastUpdateTime;
    }

    function lastTimeMiningApplicable() public view override returns (uint256) {
        return Math.min(block.timestamp, _miningEnds);
    }

    function tokenPerMiner() public view override returns (uint256) {
        if (_totalMiners == 0) {
            return _tokenPerMiner;
        }
        return
            _tokenPerMiner.add(
                lastTimeMiningApplicable()
                    .sub(_lastUpdateTime)
                    .mul(_miningRate)
                    .mul(1e18)
                    .div(_totalMiners)
            );
    }

    function mined(address account) public view override returns (uint256) {
         
        return
            _dispatchedMiners[account]
                .mul(tokenPerMiner().sub(_paidTokenPerMiner[account]))
                .div(1e18)
                .add(_mined[account]);
    }

    function getMineableForPeriod() public view override returns (uint256) {
        uint256 miningPeriod = ITokenEmitter(_tokenEmitter).EMISSION_PERIOD();
        return _miningRate.mul(miningPeriod);
    }

    function paidTokenPerMiner(address account)
        public
        view
        override
        returns (uint256)
    {
        return _paidTokenPerMiner[account];
    }

    function dispatchedMiners(address account)
        public
        view
        override
        returns (uint256)
    {
        return _dispatchedMiners[account];
    }

    function totalMiners() public view override returns (uint256) {
        return _totalMiners;
    }

    function _dispatchMiners(uint256 miners) internal {
        _dispatchMiners(msg.sender, miners);
    }

    function _dispatchMiners(address account, uint256 miners)
        internal
        nonReentrant
        whenNotPaused
        recordMining(account)
    {
        require(miners > 0, "Cannot stake 0");
        _totalMiners = _totalMiners.add(miners);
        _dispatchedMiners[account] = _dispatchedMiners[account].add(miners);
        emit Dispatched(account, miners);
    }

    function _withdrawMiners(uint256 miners) internal {
        _withdrawMiners(msg.sender, miners);
    }

    function _withdrawMiners(address account, uint256 miners)
        internal
        nonReentrant
        recordMining(account)
    {
        require(miners > 0, "Cannot withdraw 0");
        _totalMiners = _totalMiners.sub(miners);
        _dispatchedMiners[account] = _dispatchedMiners[account].sub(miners);
        emit Withdrawn(account, miners);
    }

    function _mine() internal {
        _mine(msg.sender);
    }

    function _mine(address account)
        internal
        nonReentrant
        recordMining(account)
    {
        uint256 amount = _mined[account];
        if (amount > 0) {
            _mined[account] = 0;
            IERC20(_token).safeTransfer(account, amount);
            emit Mined(account, amount);
        }
    }
}

 

pragma solidity ^0.7.0;



 
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

 

pragma solidity ^0.7.0;




 
abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

     
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

     
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}
 
pragma solidity >=0.7.0;







contract ERC1155StakeMiningV1 is MiningPool, ERC1155Holder {
    using SafeMath for uint256;

    mapping(address => mapping(uint256 => uint256)) private _staking;

    function initialize(address tokenEmitter_, address baseToken_)
        public
        override
    {
        super.initialize(tokenEmitter_, baseToken_);
        _registerInterface(ERC1155StakeMiningV1(0).stake.selector);
        _registerInterface(ERC1155StakeMiningV1(0).mine.selector);
        _registerInterface(ERC1155StakeMiningV1(0).withdraw.selector);
        _registerInterface(ERC1155StakeMiningV1(0).exit.selector);
        _registerInterface(ERC1155StakeMiningV1(0).dispatchableMiners.selector);
        _registerInterface(
            ERC1155StakeMiningV1(0).erc1155StakeMiningV1.selector
        );
    }

    function stake(uint256 id, uint256 amount) public {
        bytes memory zero;
        IERC1155(baseToken()).safeTransferFrom(
            msg.sender,
            address(this),
            id,
            amount,
            zero
        );
    }

    function withdraw(uint256 tokenId, uint256 amount) public {
        uint256 staked = _staking[msg.sender][tokenId];
        require(staked >= amount, "Withdrawing more than staked.");
        _staking[msg.sender][tokenId] = staked - amount;
        uint256 miners = dispatchableMiners(tokenId).mul(amount);
        _withdrawMiners(miners);
        bytes memory zero;
        IERC1155(baseToken()).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId,
            amount,
            zero
        );
    }

    function mine() public {
        _mine();
    }

    function exit(uint256 tokenId) public {
        mine();
        withdraw(tokenId, _staking[msg.sender][tokenId]);
    }

    function _stake(
        address account,
        uint256 tokenId,
        uint256 amount
    ) internal {
        _staking[account][tokenId] = _staking[account][tokenId].add(amount);
        uint256 miners = dispatchableMiners(tokenId).mul(amount);
        _dispatchMiners(account, miners);
    }

    function onERC1155Received(
        address,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata
    ) public virtual override returns (bytes4) {
        _stake(from, id, value);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata
    ) public virtual override returns (bytes4) {
        require(ids.length == values.length, "Not a valid input");
        for (uint256 i = 0; i < ids.length; i++) {
            _stake(from, ids[i], values[i]);
        }
        return this.onERC1155BatchReceived.selector;
    }

     
    function dispatchableMiners(uint256)
        public
        view
        virtual
        returns (uint256 numOfMiner)
    {
        return 1;
    }

    function erc1155StakeMiningV1() external pure returns (bool) {
        return true;
    }
}

 
pragma solidity >=0.7.0;




 
contract COMMIT is ERC20Burnable, Initializable {
    using SafeMath for uint256;

    address private _minter;
    uint256 private _totalBurned;
    string private _name;
    string private _symbol;

    constructor() ERC20("", "") {
         
         
    }

    modifier onlyMinter {
        require(msg.sender == _minter, "Not a minter");
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        address minter_
    ) public initializer {
        _name = name_;
        _symbol = symbol_;
        _minter = minter_;
    }

    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }

    function setMinter(address minter_) public onlyMinter {
        _setMinter(minter_);
    }

    function _setMinter(address minter_) internal {
        _minter = minter_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function minter() public view returns (address) {
        return _minter;
    }

    function totalBurned() public view returns (uint256) {
        return _totalBurned;
    }

    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
        _totalBurned = _totalBurned.add(amount);
    }
}

 
pragma solidity >=0.7.0;




struct EmissionWeight {
    address[] pools;
    uint256[] weights;
    uint256 treasury;
    uint256 caller;
    uint256 protocol;
    uint256 dev;
    uint256 sum;
}

struct EmitterConfig {
    uint256 projId;
    uint256 initialEmission;
    uint256 minEmissionRatePerWeek;
    uint256 emissionCutRate;
    uint256 founderShareRate;
    uint256 startDelay;
    address treasury;
    address gov;
    address token;
    address protocolPool;
    address contributionBoard;
    address erc20BurnMiningFactory;
    address erc20StakeMiningFactory;
    address erc721StakeMiningFactory;
    address erc1155StakeMiningFactory;
    address erc1155BurnMiningFactory;
    address initialContributorShareFactory;
}

struct MiningPoolConfig {
    uint256 weight;
    bytes4 poolType;
    address baseToken;
}

struct MiningConfig {
    MiningPoolConfig[] pools;
    uint256 treasuryWeight;
    uint256 callerWeight;
}

interface ITokenEmitter {
    event Start();
    event TokenEmission(uint256 amount);
    event EmissionCutRateUpdated(uint256 rate);
    event EmissionRateUpdated(uint256 rate);
    event EmissionWeightUpdated(uint256 numberOfPools);
    event NewMiningPool(bytes4 poolTypes, address baseToken, address pool);

    function start() external;

    function distribute() external;

    function token() external view returns (address);

    function projId() external view returns (uint256);

    function poolTypes(address pool) external view returns (bytes4);

    function factories(bytes4 poolType) external view returns (address);

    function minEmissionRatePerWeek() external view returns (uint256);

    function emissionCutRate() external view returns (uint256);

    function emission() external view returns (uint256);

    function initialContributorPool() external view returns (address);

    function initialContributorShare() external view returns (address);

    function treasury() external view returns (address);

    function protocolPool() external view returns (address);

    function pools(uint256 index) external view returns (address);

    function emissionWeight() external view returns (EmissionWeight memory);

    function emissionStarted() external view returns (uint256);

    function emissionWeekNum() external view returns (uint256);

    function INITIAL_EMISSION() external view returns (uint256);

    function FOUNDER_SHARE_DENOMINATOR() external view returns (uint256);

    function EMISSION_PERIOD() external pure returns (uint256);

    function DENOMINATOR() external pure returns (uint256);
}

 

pragma solidity ^0.7.0;

 
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

 

pragma solidity ^0.7.0;





 
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

 

pragma solidity ^0.7.0;

 
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

 

pragma solidity ^0.7.0;



 
interface IERC1155 is IERC165 {
     
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

     
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

     
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

     
    event URI(string value, uint256 indexed id);

     
    function balanceOf(address account, uint256 id) external view returns (uint256);

     
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

     
    function setApprovalForAll(address operator, bool approved) external;

     
    function isApprovedForAll(address account, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

     
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

 

pragma solidity ^0.7.0;

 
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
