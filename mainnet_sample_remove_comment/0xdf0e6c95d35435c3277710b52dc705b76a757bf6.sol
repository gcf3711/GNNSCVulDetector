 

 

 

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


 
interface IERC20MetaData {
     
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract BabylonSwapFarm {
    using SafeMath for uint256;
     
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt0;
        uint256 rewardDebt1;
    }
     
    struct PoolInfo {
        IERC20MetaData lpToken;  
        uint256 accPerShare0;
        uint256 accPerShare1;
        IERC20MetaData rewardToken0;
        IERC20MetaData rewardToken1;
    }

    address private feeto;
    bool public paused;
     
    PoolInfo[] public poolInfo;
     
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
     
    mapping(address => uint256) public lpIndex;
    mapping(address => bool) public lpStatus;
     
    mapping(address => bool) public operator;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AddReward(
        address lp,
        address rewardToken0,
        address rewardToken1,
        uint256 reward0,
        uint256 reward1
    );
    event Claim(
        address indexed user,
        uint256 indexed pid,
        uint256 reward0,
        uint256 reward1
    );
    event Paused();
    event UnPaused();
    event AddOperator(address _operator);
    event RemoveOperator(address _operator);
    event AddLpInfo(
        IERC20MetaData _lpToken,
        IERC20MetaData _rewardToken0,
        IERC20MetaData _rewardToken1
    );
    event AddLpInfo(IERC20MetaData _lpToken);

    modifier isPaused() {
        require(!paused, "contract Locked");
        _;
    }

    modifier isPoolExist(uint256 poolId) {
        require(poolId < poolLength(), "pool not exist");
        _;
    }

    modifier isOperator() {
        require(operator[msg.sender], "only operator");
        _;
    }

    constructor(address _factory) public {
        operator[_factory] = true;
        feeto = msg.sender;
        emit AddOperator(_factory);
    }

    function addLPInfo(
        IERC20MetaData _lpToken,
        IERC20MetaData _rewardToken0,
        IERC20MetaData _rewardToken1
    ) public isOperator {
        if (!lpStatus[address(_lpToken)]) {
            uint256 currentIndex = poolLength();
            poolInfo.push(
                PoolInfo({
                    lpToken: _lpToken,
                    accPerShare0: 0,
                    accPerShare1: 0,
                    rewardToken0: _rewardToken0,
                    rewardToken1: _rewardToken1
                })
            );
            lpIndex[address(_lpToken)] = currentIndex;
            lpStatus[address(_lpToken)] = true;
            emit AddLpInfo(_lpToken, _rewardToken0, _rewardToken1);
        }
    }

    function addrewardtoken(
        address _lp,
        address token,
        uint256 amount
    ) public {
        uint256 _pid = lpIndex[_lp];
        PoolInfo storage pool = poolInfo[_pid];

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (lpSupply == 0) {
            IERC20MetaData(token).transferFrom(
                    msg.sender,
                    feeto,
                    amount
                );
            return;
        }

        if (amount > 0) {
            if (token == address(pool.rewardToken0)) {
                pool.rewardToken0.transferFrom(
                    msg.sender,
                    address(this),
                    amount
                );
                pool.accPerShare0 = pool.accPerShare0.add(
                    amount.mul(1e12).div(lpSupply)
                );

            } else if (token == address(pool.rewardToken1)) {
                pool.rewardToken1.transferFrom(
                    msg.sender,
                    address(this),
                    amount
                );
                pool.accPerShare1 = pool.accPerShare1.add(
                    amount.mul(1e12).div(lpSupply)
                );
            }
        }
        emit AddReward(address(pool.lpToken), token, address(0x000), amount, 0);
    }

     
    function addReward(
        address _lp,
        address token0,
        uint256 amount0,
        uint256 amount1
    ) public {
        uint256 _pid = lpIndex[_lp];
        PoolInfo storage pool = poolInfo[_pid];

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 reward0;
        uint256 reward1;
        if (address(pool.rewardToken0) == token0) {
            reward0 = amount0;
            reward1 = amount1;
        } else {
            reward0 = amount1;
            reward1 = amount0;
        }

        if (lpSupply == 0) {
            return;
        }

        if (reward0 > 0) {
            pool.rewardToken0.transferFrom(msg.sender, address(this), reward0);
            pool.accPerShare0 = pool.accPerShare0.add(
                reward0.mul(1e12).div(lpSupply)
            );
        }
        if (reward1 > 0) {
            pool.rewardToken1.transferFrom(msg.sender, address(this), reward1);
            pool.accPerShare1 = pool.accPerShare1.add(
                reward1.mul(1e12).div(lpSupply)
            );
        }
        emit AddReward(
            address(pool.lpToken),
            address(pool.rewardToken0),
            address(pool.rewardToken1),
            reward0,
            reward1
        );
    }

    function deposit(uint256 _pid, uint256 _amount)
        public
        isPaused
        isPoolExist(_pid)
    {
        require(_amount > 0, "zero amount");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (user.amount > 0) {
            claimReward(_pid);
        }
        pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt0 = user.amount.mul(pool.accPerShare0).div(1e12);
        user.rewardDebt1 = user.amount.mul(pool.accPerShare1).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function claimReward(uint256 _pid) public isPaused isPoolExist(_pid) {
        address _userAddr = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_userAddr];
        uint256 pendingReward0;
        uint256 pendingReward1;

        if (user.amount > 0) {
            pendingReward0 = user.amount.mul(pool.accPerShare0).div(1e12).sub(
                user.rewardDebt0
            );
            safeRewardTransfer(pool.rewardToken0, _userAddr, pendingReward0);
            pendingReward1 = user.amount.mul(pool.accPerShare1).div(1e12).sub(
                user.rewardDebt1
            );
            safeRewardTransfer(pool.rewardToken1, _userAddr, pendingReward1);
        }
        user.rewardDebt0 = user.amount.mul(pool.accPerShare0).div(1e12);
        user.rewardDebt1 = user.amount.mul(pool.accPerShare1).div(1e12);
        emit Claim(_userAddr, _pid, pendingReward0, pendingReward1);
    }

    function withdraw(uint256 _pid, uint256 _amount)
        public
        isPaused
        isPoolExist(_pid)
    {
        require(_amount > 0, "zero amount");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        if (user.amount > 0) {
            claimReward(_pid);
        }

        user.amount = user.amount.sub(_amount);
        user.rewardDebt0 = user.amount.mul(pool.accPerShare0).div(1e12);
        user.rewardDebt1 = user.amount.mul(pool.accPerShare1).div(1e12);
        pool.lpToken.transfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

     
    function emergencyWithdraw(uint256 _pid) public isPoolExist(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.transfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt0 = 0;
        user.rewardDebt1 = 0;
    }

     
    function safeRewardTransfer(
        IERC20MetaData _reward,
        address _to,
        uint256 _amount
    ) internal {
        uint256 _rewardBal = _reward.balanceOf(address(this));
        if (_amount > _rewardBal) {
            _reward.transfer(_to, _rewardBal);
        } else {
            _reward.transfer(_to, _amount);
        }
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }
}