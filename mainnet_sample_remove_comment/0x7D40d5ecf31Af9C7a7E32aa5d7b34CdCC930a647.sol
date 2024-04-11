 
pragma experimental ABIEncoderV2;

 

 

 

 

 
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


 


 

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}


 

 

contract UpgradableProduct {
    address public impl;

    event ImplChanged(address indexed _oldImpl, address indexed _newImpl);

    constructor() public {
        impl = msg.sender;
    }

    modifier requireImpl() {
        require(msg.sender == impl, "FORBIDDEN");
        _;
    }

    function upgradeImpl(address _newImpl) public requireImpl {
        require(_newImpl != address(0), "INVALID_ADDRESS");
        require(_newImpl != impl, "NO_CHANGE");
        address lastImpl = impl;
        impl = _newImpl;
        emit ImplChanged(lastImpl, _newImpl);
    }
}

contract UpgradableGovernance {
    address public governor;

    event GovernorChanged(
        address indexed _oldGovernor,
        address indexed _newGovernor
    );

    constructor() public {
        governor = msg.sender;
    }

    modifier requireGovernor() {
        require(msg.sender == governor, "FORBIDDEN");
        _;
    }

    function upgradeGovernance(address _newGovernor) public requireGovernor {
        require(_newGovernor != address(0), "INVALID_ADDRESS");
        require(_newGovernor != governor, "NO_CHANGE");
        address lastGovernor = governor;
        governor = _newGovernor;
        emit GovernorChanged(lastGovernor, _newGovernor);
    }
}


 

 

library ConfigNames {
    bytes32 public constant FRYER_LTV = bytes32("FRYER_LTV");
    bytes32 public constant FRYER_HARVEST_FEE = bytes32("FRYER_HARVEST_FEE");
    bytes32 public constant FRYER_VAULT_PERCENTAGE =
        bytes32("FRYER_VAULT_PERCENTAGE");

    bytes32 public constant FRYER_FLASH_FEE_PROPORTION =
        bytes32("FRYER_FLASH_FEE_PROPORTION");

    bytes32 public constant PRIVATE = bytes32("PRIVATE");
    bytes32 public constant STAKE = bytes32("STAKE");
}


 

 



 

contract WhiteList is UpgradableProduct {
    event SetWhitelist(address indexed user, bool state);

    mapping(address => bool) public whiteList;

     
     
    
    
    function setWhitelist(address _toWhitelist, bool _state)
        external
        requireImpl
    {
        whiteList[_toWhitelist] = _state;
        emit SetWhitelist(_toWhitelist, _state);
    }

    
    modifier onlyWhitelisted() {
        require(whiteList[msg.sender], "!whitelisted");
        _;
    }
}


 

 

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
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


 


 

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}


 


 

 
 
 

 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name_, string memory symbol_) public {
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


 

 

 
 
 
 

contract CheeseToken is ERC20, UpgradableProduct {
	using SafeMath for uint256;

	mapping(address => bool) public whiteList;

	constructor(string memory _symbol, string memory _name) public ERC20(_name, _symbol) {
		_mint(msg.sender, uint256(2328300).mul(1e18));
	}

	modifier onlyWhitelisted() {
		require(whiteList[msg.sender], '!whitelisted');
		_;
	}

	function setWhitelist(address _toWhitelist, bool _state) external requireImpl {
		whiteList[_toWhitelist] = _state;
	}

	function mint(address account, uint256 amount) external virtual onlyWhitelisted {
		require(totalSupply().add(amount) <= cap(), 'ERC20Capped: cap exceeded');
		_mint(account, amount);
	}

	function cap() public pure virtual returns (uint256) {
		return 9313200 * 1e18;
	}

	function burnFrom(address account, uint256 amount) public virtual {
		uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
			amount,
			'ERC20: burn amount exceeds allowance'
		);
		_approve(account, _msgSender(), decreasedAllowance);
		_burn(account, amount);
	}

	function burn(uint256 amount) external virtual {
		_burn(_msgSender(), amount);
	}
}


 

 

 
 
 
 
 

 
 
 
contract CheeseFactory is UpgradableProduct, ReentrancyGuard {
	using SafeMath for uint256;

	uint256 public constant MAX_WEEK = 156;
	uint256 public constant d = 390 * 10**18;
	uint256 public constant a1 = 75000 * 10**18;
	uint256 public constant TOTAL_WEIGHT = 10000;

	uint256 public startTimestamp;
	uint256 public lastTimestamp;
	uint256 public weekTimestamp;
	uint256 public totalMintAmount;
	CheeseToken public token;
	bool public initialized;

	struct Pool {
		address pool;
		uint256 weight;
		uint256 minted;
	}

	mapping(bytes32 => Pool) public poolInfo;

	constructor(address token_, uint256 weekTimestamp_) public {
		weekTimestamp = weekTimestamp_;
		token = CheeseToken(token_);
	}

	function setCheeseToken(address token_) external requireImpl {
		token = CheeseToken(token_);
	}

	function setPool(bytes32 poolName_, address poolAddress_) external requireImpl {
		require(poolName_ == ConfigNames.PRIVATE || poolName_ == ConfigNames.STAKE, 'name error');
		Pool storage pool = poolInfo[poolName_];
		pool.pool = poolAddress_;
	}

	modifier expectInitialized() {
		require(initialized, 'not initialized.');
		_;
	}

	function initialize(
		address private_,
		address stake_,
		uint256 startTimestamp_
	) external requireImpl {
		require(!initialized, 'already initialized');
		require(startTimestamp_ >= block.timestamp, '!startTime');
		 
		poolInfo[ConfigNames.PRIVATE] = Pool(private_, 1066, 0);
		poolInfo[ConfigNames.STAKE] = Pool(stake_, 8934, 0);
		initialized = true;
		startTimestamp = startTimestamp_;
		lastTimestamp = startTimestamp_;
	}

	function preMint() public view returns (uint256) {
		if (block.timestamp <= startTimestamp) {
			return uint256(0);
		}

		if (block.timestamp <= lastTimestamp) {
			return uint256(0);
		}
		uint256 time = block.timestamp.sub(startTimestamp);
		uint256 max_week_time = MAX_WEEK.mul(weekTimestamp);
		 
		if (time > max_week_time) {
			time = max_week_time;
		}

		 
		if (time >= weekTimestamp) {
			uint256 n = time.div(weekTimestamp);

			 
			 
			uint256 an = a1.sub(n.mul(d));

			 
			uint256 otherTimestamp = time.mod(weekTimestamp);
			uint256 other = an.mul(otherTimestamp).div(weekTimestamp);

			 
			 

			 
			uint256 first = n.mul(a1);
			 
			uint256 last = n.mul(n.sub(1)).mul(d).div(2);
			uint256 sn = first.sub(last);
			return other.add(sn).sub(totalMintAmount);
		} else {
			return a1.mul(time).div(weekTimestamp).sub(totalMintAmount);
		}
	}

	function _updateTotalAmount() internal returns (uint256) {
		uint256 preMintAmount = preMint();
		totalMintAmount = totalMintAmount.add(preMintAmount);
		lastTimestamp = block.timestamp;
		return preMintAmount;
	}

	function prePoolMint(bytes32 poolName_) public view returns (uint256) {
		uint256 preMintAmount = preMint();
		Pool memory pool = poolInfo[poolName_];
		uint256 poolTotal = totalMintAmount.add(preMintAmount).mul(pool.weight).div(TOTAL_WEIGHT);
		return poolTotal.sub(pool.minted);
	}

	function poolMint(bytes32 poolName_) external nonReentrant expectInitialized returns (uint256) {
		Pool storage pool = poolInfo[poolName_];
		require(msg.sender == pool.pool, 'Permission denied');
		_updateTotalAmount();
		uint256 poolTotal = totalMintAmount.mul(pool.weight).div(TOTAL_WEIGHT);
		uint256 amount = poolTotal.sub(pool.minted);
		if (amount > 0) {
			token.mint(msg.sender, amount);
			pool.minted = pool.minted.add(amount);
		}
		return amount;
	}
}


 

pragma solidity >=0.6.5 <0.8.0;
 


contract CheesePrivateStakePool is WhiteList, ReentrancyGuard {
    event Stake(address indexed user, uint256 indexed amount);
    event Withdraw(address indexed user, uint256 indexed amount);
    event Claimed(address indexed user, uint256 indexed amount);
    event SetCheeseFactory(address indexed factory);
    event SetCheeseToken(address indexed token);

    using TransferHelper for address;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 debt;
        uint256 reward;
        uint256 totalIncome;
    }

    CheeseToken public token;
    CheeseFactory public cheeseFactory;

    uint256 public lastBlockTimeStamp;
    uint256 public rewardPerShare;
    uint256 public totalStake;

    mapping(address => UserInfo) public userInfos;

    constructor(address cheeseFactory_, address token_) public {
        cheeseFactory = CheeseFactory(cheeseFactory_);
        token = CheeseToken(token_);
    }

    function setCheeseFactory(address cheeseFactory_) external requireImpl {
        cheeseFactory = CheeseFactory(cheeseFactory_);
        emit SetCheeseFactory(cheeseFactory_);
    }

    function setCheeseToken(address token_) external requireImpl {
        token = CheeseToken(token_);
        emit SetCheeseToken(token_);
    }

    function getUserInfo(address userAddress)
        external
        view
        virtual
        returns (
            uint256 amount,
            uint256 debt,
            uint256 reward,
            uint256 totalIncome
        )
    {
        UserInfo memory userInfo = userInfos[userAddress];
        return (
            userInfo.amount,
            userInfo.debt,
            userInfo.reward,
            userInfo.totalIncome
        );
    }

    function currentRewardShare()
        public
        view
        virtual
        returns (uint256 _reward, uint256 _perShare)
    {
        _reward = cheeseFactory.prePoolMint(ConfigNames.PRIVATE);
        _perShare = rewardPerShare;

        if (totalStake > 0) {
            _perShare = _perShare.add(_reward.mul(1e18).div(totalStake));
        }
        return (_reward, _perShare);
    }

    modifier updateRewardPerShare() {
        if (totalStake > 0 && block.timestamp > lastBlockTimeStamp) {
            (uint256 _reward, uint256 _perShare) = currentRewardShare();
            rewardPerShare = _perShare;
            lastBlockTimeStamp = block.timestamp;
            require(
                _reward == cheeseFactory.poolMint(ConfigNames.PRIVATE),
                "pool mint error"
            );
        }
        _;
    }

    modifier updateUserReward(address user) {
        UserInfo storage userInfo = userInfos[user];
        if (userInfo.amount > 0) {
            uint256 debt = userInfo.amount.mul(rewardPerShare).div(1e18);
            uint256 userReward = debt.sub(userInfo.debt);
            userInfo.reward = userInfo.reward.add(userReward);
            userInfo.debt = debt;
        }
        _;
    }

    function stake(uint256 amount)
        external
        virtual
        onlyWhitelisted
        nonReentrant
        updateRewardPerShare()
        updateUserReward(msg.sender)
    {
        if (amount > 0) {
            UserInfo storage userInfo = userInfos[msg.sender];
            userInfo.amount = userInfo.amount.add(amount);
            userInfo.debt = userInfo.amount.mul(rewardPerShare).div(1e18);
            totalStake = totalStake.add(amount);
            address(token).safeTransferFrom(msg.sender, address(this), amount);
            emit Stake(msg.sender, amount);
        }
    }

    function withdraw(uint256 amount)
        external
        virtual
        nonReentrant
        updateRewardPerShare()
        updateUserReward(msg.sender)
    {
        if (amount > 0) {
            UserInfo storage userInfo = userInfos[msg.sender];
            require(userInfo.amount >= amount, "Insufficient balance");
            userInfo.amount = userInfo.amount.sub(amount);
            userInfo.debt = userInfo.amount.mul(rewardPerShare).div(1e18);
            totalStake = totalStake.sub(amount);
            address(token).safeTransfer(msg.sender, amount);
            emit Withdraw(msg.sender, amount);
        }
    }

    function claim()
        external
        virtual
        nonReentrant
        updateRewardPerShare()
        updateUserReward(msg.sender)
    {
        UserInfo storage userInfo = userInfos[msg.sender];
        if (userInfo.reward > 0) {
            uint256 amount = userInfo.reward;
            userInfo.reward = 0;
            userInfo.totalIncome = userInfo.totalIncome.add(amount);
            address(token).safeTransfer(msg.sender, amount);
            emit Claimed(msg.sender, amount);
        }
    }

    function calculateIncome(address user)
        external
        view
        virtual
        returns (uint256)
    {
        UserInfo storage userInfo = userInfos[user];
        uint256 _rewardPerShare = rewardPerShare;

        if (block.timestamp > lastBlockTimeStamp && totalStake > 0) {
            (, _rewardPerShare) = currentRewardShare();
        }
        uint256 userReward = userInfo.amount.mul(_rewardPerShare).div(1e18).sub(userInfo.debt);
        return userInfo.reward.add(userReward);
    }
}