 
pragma experimental ABIEncoderV2;


 

 

pragma solidity ^0.6.0;




 


 
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

 
pragma solidity ^0.6.12;


struct LockedNFT {
    uint256 token_id;  
    uint256 liquidity;
    uint256 start_timestamp;
    uint256 ending_timestamp;
    uint256 lock_multiplier;  
    int24 tick_lower;
    int24 tick_upper;
}

struct LockedStake {
    bytes32 kek_id;
    uint256 start_timestamp;
    uint256 liquidity;
    uint256 ending_timestamp;
    uint256 lock_multiplier;  
}

interface IFraxGaugeBase {
    function lockedLiquidityOf(address account) external view returns (uint256);

    function getReward() external returns (uint256);

    function lock_time_min() external returns (uint256);

    function combinedWeightOf(address account) external view returns (uint256);
}
 
pragma solidity ^0.6.7;





interface FeeDistribution {
    function claim(address) external;
}

contract veFXSVault {
    using SafeMath for uint256;

    
    string public constant name = "pickle veFXS Vault";

    
    string public constant symbol = "pveFXS";

    
    uint8 public constant decimals = 18;

    
    uint256 public totalSupply = 0;  

    
    mapping(address => address) public delegates;

    
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    
    mapping(address => uint32) public numCheckpoints;

    mapping(address => mapping(address => uint256)) internal allowances;
    mapping(address => uint256) internal balances;

    
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint chainId,address verifyingContract)");
    bytes32 public immutable DOMAINSEPARATOR;

    
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint nonce,uint expiry)");

    
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint value,uint nonce,uint deadline)");

    
    mapping(address => uint256) public nonces;

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

     
    function delegate(address delegatee) public {
        _delegate(msg.sender, delegatee);
    }

     
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAINSEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "delegateBySig: sig");
        require(nonce == nonces[signatory]++, "delegateBySig: nonce");
        require(block.timestamp <= expiry, "delegateBySig: expired");
        _delegate(signatory, delegatee);
    }

     
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

     
    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "getPriorVotes:");

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

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount, "_moveVotes: underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, "_writeCheckpoint: 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    address public governance;
    address public pendingGovernance;

    IERC20 public constant FXS = IERC20(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);
    address public locker = 0xd639C2eA4eEFfAD39b599410d00252E6c80008DF;
    address public proxy = 0x26B62c5F0bA4eB6a4Aff34141AF43Af7b5454a78;
    address public feeDistribution = 0x26B62c5F0bA4eB6a4Aff34141AF43Af7b5454a78;

    IERC20 public constant rewards = IERC20(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);

    uint256 public index = 0;
    uint256 public bal = 0;

    mapping(address => uint256) public supplyIndex;

    constructor() public {
         
        governance = msg.sender;
        DOMAINSEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), _getChainId(), address(this)));
    }

    function update() external {
        _update();
    }

    function _update() internal {
        if (totalSupply > 0) {
            _claim();
            uint256 _bal = rewards.balanceOf(address(this));
            if (_bal > bal) {
                uint256 _diff = _bal.sub(bal);
                if (_diff > 0) {
                    uint256 _ratio = _diff.mul(1e18).div(totalSupply);
                    if (_ratio > 0) {
                        index = index.add(_ratio);
                        bal = _bal;
                    }
                }
            }
        }
    }

    function _claim() internal {
        if (feeDistribution != address(0x0)) {
            FeeDistribution(feeDistribution).claim(address(this));
        }
    }

    function updateFor(address recipient) public {
        _update();
        uint256 _supplied = balances[recipient];
        if (_supplied > 0) {
            uint256 _supplyIndex = supplyIndex[recipient];
            supplyIndex[recipient] = index;
            uint256 _delta = index.sub(_supplyIndex);
            if (_delta > 0) {
                uint256 _share = _supplied.mul(_delta).div(1e18);
                claimable[recipient] = claimable[recipient].add(_share);
            }
        } else {
            supplyIndex[recipient] = index;
        }
    }

    mapping(address => uint256) public claimable;

    function claim() external {
        _claimFor(msg.sender);
    }

    function claimFor(address recipient) external {
        _claimFor(recipient);
    }

    function _claimFor(address recipient) internal {
        updateFor(recipient);
        rewards.transfer(recipient, claimable[recipient]);
        claimable[recipient] = 0;
        bal = rewards.balanceOf(address(this));
    }

    function _mint(address dst, uint256 amount) internal {
        updateFor(dst);
         
        totalSupply = totalSupply.add(amount);
         
        balances[dst] = balances[dst].add(amount);
        emit Transfer(address(0), dst, amount);

         
        _moveDelegates(address(0), delegates[dst], amount);
    }

    function depositAll() external {
        _deposit(FXS.balanceOf(msg.sender));
    }

    function deposit(uint256 _amount) external {
        _deposit(_amount);
    }

    function _deposit(uint256 _amount) internal {
        FXS.transferFrom(msg.sender, locker, _amount);
        _mint(msg.sender, _amount);
        IStrategyProxy(proxy).lock();
    }

    function setProxy(address _proxy) external {
        require(msg.sender == governance, "setGovernance: !gov");
        proxy = _proxy;
    }

    function setLocker(address _locker) external {
        require(msg.sender == governance, "setGovernance: !gov");
        locker = _locker;
    }

    function setFeeDistribution(address _feeDistribution) external {
        require(msg.sender == governance, "setGovernance: !gov");
        feeDistribution = _feeDistribution;
    }

     
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "setGovernance: !gov");
        pendingGovernance = _governance;
    }

     
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "acceptGovernance: !pendingGov");
        governance = pendingGovernance;
    }

     
    function allowance(address account, address spender) external view returns (uint256) {
        return allowances[account][spender];
    }

     
    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

     
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAINSEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "permit: signature");
        require(signatory == owner, "permit: unauthorized");
        require(block.timestamp <= deadline, "permit: expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

     
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

     
    function transfer(address dst, uint256 amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

     
    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != uint256(-1)) {
            uint256 newAllowance = spenderAllowance.sub(amount);
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(
        address src,
        address dst,
        uint256 amount
    ) internal {
        require(src != address(0), "_transferTokens: zero address");
        require(dst != address(0), "_transferTokens: zero address");

        updateFor(src);
        updateFor(dst);

        balances[src] = balances[src].sub(amount);
        balances[dst] = balances[dst].add(amount);
        emit Transfer(src, dst, amount);
    }

    function _getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

     

    function execute(address _target, bytes memory _data) public payable returns (bytes memory response) {
        require(msg.sender == governance, "!governance");
        require(_target != address(0), "!target");

         
        assembly {
            let succeeded := delegatecall(sub(gas(), 5000), _target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize()

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                 
                revert(add(response, 0x20), size)
            }
        }
    }
}

 

pragma solidity ^0.6.0;

 
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

 
pragma solidity ^0.6.7;



interface IStrategyProxy {
    function withdrawV3(
        address _gauge,
        uint256 _tokenId,
        address[] calldata _rewardTokens
    ) external returns (uint256);

    function withdrawV2(
        address _gauge,
        address _token,
        bytes32 _kek_id,
        address[] calldata _rewardTokens
    ) external returns (uint256);

    function balanceOf(address _gauge) external view returns (uint256);

    function lockedNFTsOf(address _gauge) external view returns (LockedNFT[] memory);

    function lockedStakesOf(address _gauge) external view returns (LockedStake[] memory);

    function withdrawAllV3(
        address _gauge,
        address _token,
        address[] calldata _rewardTokens
    ) external returns (uint256 amount);

    function withdrawAllV2(
        address _gauge,
        address _token,
        address[] calldata _rewardTokens
    ) external returns (uint256 amount);

    function harvest(address _gauge, address[] calldata _tokens) external;

    function depositV2(
        address _gauge,
        address _token,
        uint256 _secs
    ) external;

    function depositV3(
        address _gauge,
        uint256 _tokenId,
        uint256 _secs
    ) external;

    function claim(address recipient) external;

    function lock() external;

    function claimRewards(address _gauge, address _token) external;
}

interface IFraxGaugeUniV3 is IFraxGaugeBase {
    function stakeLocked(uint256 token_id, uint256 secs) external;

    function withdrawLocked(uint256 token_id) external;

    function lockedNFTsOf(address account)
        external
        view
        returns (LockedNFT[] memory);
}

interface IFraxGaugeUniV2 {
    function stakeLocked(uint256 liquidity, uint256 secs) external;

    function lockedStakesOf(address)
        external
        view
        returns (LockedStake[] memory);

    function withdrawLocked(bytes32 kek_id) external;

    function getAllRewardTokens() external view returns (address[] memory);
}
