 
pragma experimental ABIEncoderV2;

 
pragma solidity ^0.6.12;










contract LockPosition {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

     
    uint8 public periodCount;

     
    address public owner;
     
    address public recipient;
     
    address public target;

    
    address[] public funds;

     
    mapping(uint256 => SalesPeriod) public salesPeriods;
     
    mapping(address => mapping(uint256 => LockedInfo)) public investList;

     
    event Invest(address indexed investor, uint256 period, uint256 number, uint256 amount);
     
    event unLocked(address indexed investor, uint256 period, uint256 number);

    
    struct LockedInfo {
        uint256 purchased;
        uint256 lockedAmount;
        uint256 unlockedAmount;
    }

    
    struct SalesPeriod {
        uint256 period;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
        uint256 maximumSales;
        uint256 maximumPurchase;
        uint256 salesVolume;
        uint256 lockTime;
        uint256 fundLimit;
        address pay;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    
    modifier onlyFundInvestor(uint256 period) {
        require(isAllowInvest(msg.sender,period), "not fund investor");
        _;
    }

    
    
    
    constructor (address _target, address _recipient) public {
        init(_target, _recipient);
    }

    
    function init(address _target, address _recipient) public {
        require(owner == address(0), 'already init');
        owner = msg.sender;
        target = _target;
        recipient = _recipient;
    }


    
    
    function calcDecimal(address token) public view returns (uint256){
        IERC20Metadata ioToken = IERC20Metadata(token);
        return 10 ** uint256(ioToken.decimals());
    }

    
    function isAllowInvest(address account,uint256 period)public view returns(bool){
        SalesPeriod memory salesPeriod = salesPeriods[period];
        bool isFundInvestor = false;
        for (uint256 i = 0; i < funds.length; i++) {
            IFund fund = IFund(funds[i]);
            uint256 balance = fund.balanceOf(account);
            uint256 amount = fund.convertToCash(balance);
            uint256 assets = salesPeriod.fundLimit.mul(calcDecimal(fund.ioToken()));
            if (amount >= assets) {
                isFundInvestor = true;
                break;
            }
        }
        return isFundInvestor;
    }

    
    function updateRecipient(address _recipient) external onlyOwner {
        recipient = _recipient;
    }

    
    
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    
    
    function bindFund(address[] memory _funds) external onlyOwner {
        funds = _funds;
    }

    
    
    function saveSalesPeriod(SalesPeriod memory salesPeriod) external onlyOwner {
        require(salesPeriods[salesPeriod.period].pay == address(0)
            || salesPeriods[salesPeriod.period].startTime >= block.timestamp, 'already active');
        if (salesPeriods[salesPeriod.period].period == 0) {
            periodCount++;
        }
        salesPeriods[salesPeriod.period] = salesPeriod;
    }

    
    
    
    function invest(uint256 period, uint256 amount) external onlyFundInvestor(period) {
        require(amount > 0, 'minimumSales');
        SalesPeriod storage salesPeriod = salesPeriods[period];
        require(salesPeriod.startTime <= block.timestamp
            && salesPeriod.endTime >= block.timestamp, 'not active');
        LockedInfo storage lockedInfo = investList[msg.sender][period];
        uint256 surplusAmount = salesPeriod.maximumPurchase.sub(lockedInfo.purchased);
        require(surplusAmount >= amount, 'maximumPurchase');
        uint256 number = amount.mul(calcDecimal(target)).div(salesPeriod.price);
        uint256 surplusVolume = salesPeriod.maximumSales.sub(salesPeriod.salesVolume);
        require(surplusVolume >= number, 'maximumSales');
        IERC20(salesPeriod.pay).safeTransferFrom(msg.sender, recipient, amount);
        salesPeriod.salesVolume = salesPeriod.salesVolume.add(number);
        lockedInfo.lockedAmount = lockedInfo.lockedAmount.add(number);
        lockedInfo.purchased = lockedInfo.purchased.add(amount);
        emit Invest(msg.sender, period, number, amount);
    }

    
    
    function unlock(uint256 period) external {
        SalesPeriod memory salesPeriod = salesPeriods[period];
        require(salesPeriod.pay != address(0), 'non-existent');
        require(block.timestamp >= salesPeriod.endTime, 'not complete');
        require(block.timestamp.sub(salesPeriod.endTime) >= salesPeriod.lockTime, 'locked');
        LockedInfo storage lockedInfo = investList[msg.sender][period];
        uint256 unlockAmount = lockedInfo.lockedAmount;
        IGovToken(target).mint(msg.sender, unlockAmount);
        lockedInfo.unlockedAmount = lockedInfo.unlockedAmount.add(unlockAmount);
        lockedInfo.lockedAmount = 0;
        emit unLocked(msg.sender, period, unlockAmount);
    }
}

 
pragma solidity ^0.6.12;

interface IGovToken{


    
   function decimals() external view returns (uint8);


   function mint(address to,uint256 amount) external;

}

 
pragma solidity ^0.6.12;



interface IFund {


    
    
    
    
    function convertToCash(uint256 fundAmount) external view returns (uint256);

    
    
    
    function ioToken() external view returns (address);

     
    function balanceOf(address account) external view returns (uint256);


}

 
pragma solidity ^0.6.12;

interface IERC20Metadata {

     
    function decimals() external view returns (uint8);
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

