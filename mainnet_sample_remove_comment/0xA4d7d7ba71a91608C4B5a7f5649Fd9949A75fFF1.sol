 
pragma experimental ABIEncoderV2;

 

pragma solidity 0.6.12;

 

 
 
contract Context {
     
     
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 
interface IBEP20 {
     
    function totalSupply() external view returns (uint256);

     
    function decimals() external view returns (uint8);

     
    function symbol() external view returns (string memory);

     
    function name() external view returns (string memory);

     
    function getOwner() external view returns (address);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address _owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IBEP20Mintable {

    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address _to, uint256 _amount) external returns (bool);
    function burnFrom(address who, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

 
 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

     
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

     
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

     
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

 

 
contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
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

contract StakingPoolGIFTGoldYield is Ownable, ReentrancyGuard{
    
    using SafeMath for uint256;
    bool public fundsAreSafu = true;  
    uint256 public minInvestment = 1000000000000000000;
    IBEP20 public poolToken;
    IBEP20 public returnPoolToken;
    uint256 public totalStaked;  
    uint256 public totalWithdrawn;  

    event Deposit(uint256 _amount, uint256 _time);
    event BoosterDeposit(uint256 _amount, uint256 _time);
    event WithdrawalRequest(address indexed user, uint256 _amount, uint256 _time);

    struct Account {
        uint256 balance;
        uint256 timestampDeposited;
        uint256 blockWithdrawal;
    }

    struct HistoricalDeposit{
        address user;
        uint256 depositAmount;
        uint256 depositTime;
    }
    struct HistoricalWithdrawal{
        address user;
        uint256 withdrawalAmount;
        uint256 withdrawalTime;
    }

    mapping(address => Account) public deposits;
    HistoricalDeposit[] public historicalDeposits;
    HistoricalWithdrawal[] public historicalWithdrawals;


    mapping(address => bool) public whitelist;
    mapping(address => uint256) public requests;
    mapping(address => uint256) public requestTime;

    address[] public kycdAccounts;
    address[] public requestList; 
    address public secondAdmin;
    address public fireblocksWallet; 

    constructor(IBEP20 _usdc, IBEP20 _yieldUSDC, address _secondAdmin, address _fireblocksWallet) public {
        poolToken = _usdc;
        returnPoolToken = _yieldUSDC;
        secondAdmin = _secondAdmin;
        fireblocksWallet = _fireblocksWallet;
    }


    function changeFireblocksWallet(address _newallet) public onlyAdmins {
        fireblocksWallet = _newallet; 
    }

     
    modifier onlyAdmins() {
        require(msg.sender == owner() || msg.sender == secondAdmin, 'Admins: caller is not the admin');
        _;
    }

    function changeSecondAdmin(address _newadmin) public {
        require(msg.sender == secondAdmin, 'invalid address');
        secondAdmin = _newadmin;
    }

    function whitelistBlacklist(address _addr, bool _status) public onlyAdmins{
        whitelist[_addr] = _status;
        if(_status == true){
            kycdAccounts.push(_addr);
        }
    }

    function getKycdWithPagination(uint256 cursor, uint256 howMany) public view returns(address[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > kycdAccounts.length - cursor) {
            length = kycdAccounts.length - cursor;
        }

        values = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = kycdAccounts[cursor + i];
        }

        return (values, cursor + length);
    }

    function getRequestsOpenWithPagination(uint256 cursor, uint256 howMany) public view returns(address[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > requestList.length - cursor) {
            length = requestList.length - cursor;
        }
        values = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = requestList[cursor + i];
        }

        return (values, cursor + length);
    }

    function getHistoricalDeposits(uint256 cursor, uint256 howMany) public view returns(HistoricalDeposit[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > historicalDeposits.length - cursor) {
            length = historicalDeposits.length - cursor;
        }
        values = new HistoricalDeposit[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = historicalDeposits[cursor + i];
        }

        return (values, cursor + length);
    }

    function getHistoricalWithdrawals(uint256 cursor, uint256 howMany) public view returns(HistoricalWithdrawal[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > historicalWithdrawals.length - cursor) {
            length = historicalWithdrawals.length - cursor;
        }
        values = new HistoricalWithdrawal[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = historicalWithdrawals[cursor + i];
        }

        return (values, cursor + length);
    }


    function remove(uint index) internal  returns(bool) {
        if (index >= requestList.length) return false;
        delete requestList[index];
        return true;
    }


    function changeMinInvestment(uint256 _newAmount) public onlyAdmins {
        minInvestment = _newAmount;
    }

    function deposit(uint256 _amount) public nonReentrant {
        require(whitelist[msg.sender] == true, "GoldYield: not whitelisted. If you KYCd, contact us");
        require(poolToken.allowance(msg.sender, address(this)) >= _amount, "erc20 not allowed");
        require(_amount >= minInvestment, "min investment not met");
        require(deposits[msg.sender].blockWithdrawal == 0, 'you have already deposited, withdraw first');
        deposits[msg.sender].timestampDeposited = block.timestamp;

        deposits[msg.sender].blockWithdrawal = block.timestamp.add(31560000);  
        poolToken.transferFrom(msg.sender, fireblocksWallet, _amount); 
        deposits[msg.sender].balance = deposits[msg.sender].balance.add(_amount);
        returnPoolToken.transfer(msg.sender, _amount);
        totalStaked = totalStaked.add(_amount);
        HistoricalDeposit memory info; 
        info.user = msg.sender;
        info.depositAmount = _amount;
        info.depositTime = block.timestamp;
        historicalDeposits.push(info);

        emit Deposit(_amount, block.timestamp);
    }


     
     
     
     
     

    function satisfyRequest(address _user, uint256 _usdcReturn, uint256 _afiAmount, uint256 _requestId) public onlyAdmins {
        uint256 _amount = requests[_user];
         
        requests[_user] = 0;
        requestTime[_user] = 0;
        poolToken.transferFrom(msg.sender, _user, _usdcReturn);
         
        deposits[_user].blockWithdrawal = 0;
         
        totalWithdrawn = totalWithdrawn.add(_usdcReturn);
        if(deposits[_user].balance <= _usdcReturn){
            deposits[_user].balance = 0;
        } else {
            deposits[_user].balance = deposits[_user].balance.sub(_amount);
        }

        HistoricalWithdrawal memory info; 
        info.user = _user;
        info.withdrawalAmount = _usdcReturn;
        info.withdrawalTime = block.timestamp;
        historicalWithdrawals.push(info);

        remove(_requestId);
    }

    function satisfyRequestAndReturnRebase(address _user, uint256 _usdcReturn, uint256 _afiAmount, uint256 _requestId) public onlyAdmins {
        uint256 _amount = requests[_user];
        require(_usdcReturn <= _amount, 'invalid');
        uint256 difference = _amount - _usdcReturn;
         
        requests[_user] = 0;
        requestTime[_user] = 0;
        poolToken.transferFrom(msg.sender, _user, _usdcReturn);
        returnPoolToken.transfer(_user, difference);
         
        deposits[_user].blockWithdrawal = 0;
         
        totalWithdrawn = totalWithdrawn.add(_usdcReturn);
        if(deposits[_user].balance <= _usdcReturn){
            deposits[_user].balance = 0;
        } else {
            deposits[_user].balance = deposits[_user].balance.sub(_amount);
        }

        HistoricalWithdrawal memory info; 
        info.user = _user;
        info.withdrawalAmount = _usdcReturn;
        info.withdrawalTime = block.timestamp;
        historicalWithdrawals.push(info);

        remove(_requestId);
    }

    function withdraw(uint256 _amount) public nonReentrant {
        require(requests[msg.sender] == 0, "GoldYield: request in progress");
        require(whitelist[msg.sender] == true, "GoldYield: not whitelisted. If you KYCd contact us");
        require(returnPoolToken.allowance(msg.sender, address(this)) >= _amount, "not allowed");
        require(returnPoolToken.balanceOf(msg.sender) >= _amount, 'you do not have enough jytUSDT balance');
        returnPoolToken.transferFrom(msg.sender, address(this), _amount);
        requests[msg.sender] = requests[msg.sender].add(_amount);
        requestTime[msg.sender] = block.timestamp;
        requestList.push(msg.sender);
        emit WithdrawalRequest(msg.sender, _amount, block.timestamp);

    }

    function adminWithdrawAnyLostFunds(uint256 _amount) public onlyOwner {
        poolToken.transfer(msg.sender, _amount);
    }




}