 


 

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

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
 

pragma solidity 0.6.12;








contract BagRadiation is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;  
        uint256 rewardDebt;  
    }

    struct PoolInfo {
        address stakingToken;  
        uint256 allocPoint;  
        uint256 lastRewardBlock;  
        uint256 accRewardPerShare;  
        uint16 earlyWithdrawalFeeBP;  
    }

    IERC20 public rewardToken;
    IBagBang public bagBang;
    address public feeAddress;  

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
     
    uint256 public totalAllocPoint = 0;

    uint256 public rewardStartBlock;
    uint256 public rewardNumBlocks;
    uint256 public rewardEndBlock;
    uint256 public rewardPerBlock;
    uint256 public feeEndBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IBagBang _bagBang,
        IERC20 _rewardToken,
        address _feeAddress,
        uint256 _feeEndBlock,
        uint256 _rewardStartBlock,
        uint256 _rewardNumBlocks,
        uint256 _totalRewards
    ) public {
        require(_rewardNumBlocks > 0, "constructor: invalid reward blocks");
        bagBang = _bagBang;
        rewardToken = _rewardToken;
        feeAddress = _feeAddress;
        feeEndBlock = _feeEndBlock;
        rewardStartBlock = _rewardStartBlock;
        rewardNumBlocks = _rewardNumBlocks;
        rewardEndBlock = _rewardStartBlock.add(_rewardNumBlocks).sub(1);
        rewardPerBlock = _totalRewards.div(rewardNumBlocks);
    }

    function isDuplicatedPool(address _stakingToken) public view returns (bool) {
        uint256 length = poolInfo.length;
        for (uint256 _pid = 0; _pid < length; _pid++) {
            if (poolInfo[_pid].stakingToken == _stakingToken) return true;
        }
        return false;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function addPool(
        uint256 _allocPoint,
        address _stakingToken,
        uint16 _earlyWithdrawalFeeBP,
        bool _withUpdate
    ) public onlyOwner {
        require(_earlyWithdrawalFeeBP <= 10000, "addPool: invalid early withdrawal fee");
        require(!isDuplicatedPool(_stakingToken), "addPool: stakingToken dup");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > rewardStartBlock ? block.number : rewardStartBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                stakingToken: _stakingToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0,
                earlyWithdrawalFeeBP: _earlyWithdrawalFeeBP
            })
        );
    }

     
    function setPool(
        uint256 _pid,
        uint256 _allocPoint,
        uint16 _earlyWithdrawalFeeBP
    ) public onlyOwner {
        require(_earlyWithdrawalFeeBP <= 10000, "setPool: invalid early withdrawal fee");
        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

     
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

     
    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = IERC20(pool.stakingToken).balanceOf(address(this)); 
        if (block.number > pool.lastRewardBlock &&
            lpSupply > 0 &&
            pool.lastRewardBlock < rewardEndBlock
        ) {
            uint256 updatedRewardBlock = block.number >= rewardEndBlock ? rewardEndBlock : block.number;
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, updatedRewardBlock);
            uint256 reward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRewardPerShare = accRewardPerShare.add(reward.mul(1e24).div(lpSupply));
        }
        return user.amount.mul(accRewardPerShare).div(1e24).sub(user.rewardDebt);
    }

     
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

     
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lastRewardBlock >= rewardEndBlock) {
            return;
        }
        uint256 updatedRewardBlock = block.number >= rewardEndBlock ? rewardEndBlock : block.number;
        uint256 lpSupply = IERC20(pool.stakingToken).balanceOf(address(this));  
        if (lpSupply == 0) {
            pool.lastRewardBlock = updatedRewardBlock;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, updatedRewardBlock);
        uint256 reward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        bagBang.mintPool(address(this), reward);
        pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(1e24).div(lpSupply));
        pool.lastRewardBlock = updatedRewardBlock;
    }

     
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e24).sub(user.rewardDebt);
            safeRewardTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            IERC20(pool.stakingToken).safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e24);
        emit Deposit(msg.sender, _pid, _amount);
    }

     
    function withdraw(uint256 _pid, uint256 _amount) public {
        _withdraw(_pid, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function withdrawAll(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        _withdraw(_pid, user.amount);
        emit Withdraw(msg.sender, _pid, user.amount);
    }

    function _withdraw(uint256 _pid, uint256 _amount) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e24).sub(user.rewardDebt);
        if (pending > 0) {
            user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e24);
            safeRewardTransfer(msg.sender, pending);
        }

        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e24);
        uint256 returnAmount = _amount;
        if (pool.earlyWithdrawalFeeBP > 0 && block.number < feeEndBlock) {
            uint256 withdrawalFee = _amount.mul(pool.earlyWithdrawalFeeBP).div(10000);
            returnAmount = returnAmount.sub(withdrawalFee);
            IERC20(pool.stakingToken).safeTransfer(feeAddress, withdrawalFee);
        }
        IERC20(pool.stakingToken).safeTransfer(address(msg.sender), returnAmount);
    }

     
    function harvest(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e24).sub(user.rewardDebt);
        require(pending > 0, "harvest: no reward owed");
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e24);
        safeRewardTransfer(msg.sender, pending);
        emit Harvest(msg.sender, _pid, pending);
    }

     
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        IERC20(pool.stakingToken).safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

     
    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 bagBal = rewardToken.balanceOf(address(this));
        if (_amount > bagBal) {
            rewardToken.transfer(_to, bagBal);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }

     
    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: not authorized");
        feeAddress = _feeAddress;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
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

 

pragma solidity >=0.6.0 <0.8.0;





 
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

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct Bytes32Set {
        Set _inner;
    }

     
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

     
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

     
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

     
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
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

 
pragma solidity 0.6.12;

interface IBagBang {
    function mintAirdrop(address _to, uint256 _amount) external;
    function mintTreasury(address _to, uint256 _amount) external;
    function mintAdvisors(address _to, uint256 _amount) external;
    function mintDev(address _to, uint256 _amount) external;
    function mintPool(address _to, uint256 _amount) external;
}

 

pragma solidity >=0.6.2 <0.8.0;

 
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