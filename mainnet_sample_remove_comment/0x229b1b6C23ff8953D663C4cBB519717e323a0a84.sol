 


 

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
 
pragma solidity 0.7.6;







contract BaseVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    struct Investor {
        uint256 paidAmount;
        uint256 timeRewardPaid;
    }

    uint256 constant PERIOD = 1 days;
    uint256 constant PERCENTAGE = 1e20;

    IERC20  public immutable token;
    uint256 public immutable startDate;
    uint256 public immutable totalAllocatedAmount;
    uint256 public immutable vestingDuration;
    uint256 public immutable tokensForLP;
    uint256 public immutable tokensForNative;

    uint256 public vestingTimeEnd;
    uint256 public everyDayReleasePercentage;

    event RewardPaid(address indexed investor, uint256 amount);

    mapping(address => Counters.Counter) public nonces;
    mapping(address => bool) public trustedSigner;
    mapping(address => Investor) public investorInfo;

    constructor(
        address signer_,
        address token_,
        uint256 startDate_,
        uint256 vestingDuration_,
        uint256 totalAllocatedAmount_
    ) {
        require(signer_ != address(0), "Invalid signer address");
        require(token_ != address(0), "Invalid reward token address");
        require(
            startDate_ > block.timestamp,
            "TGE timestamp can't be less than block timestamp"
        );
        require(vestingDuration_ > 0, "The vesting duration cannot be 0");
        require(
            totalAllocatedAmount_ > 0,
            "The number of tokens for distribution cannot be 0"
        );
        token = IERC20(token_);
        startDate = startDate_;
        vestingDuration = vestingDuration_;
        vestingTimeEnd = startDate_.add(vestingDuration_);
        uint256 periods = vestingDuration_.div(PERIOD);
        everyDayReleasePercentage = PERCENTAGE.div(periods);
        totalAllocatedAmount = totalAllocatedAmount_;
        uint256 nativeTokens = totalAllocatedAmount_.div(3);
        tokensForNative = nativeTokens;
        tokensForLP = totalAllocatedAmount_.sub(nativeTokens);
        trustedSigner[signer_] = true;
    }

     
    function changeSignerList(address signer, bool permission)
        public
        onlyOwner
    {
        changePermission(signer, permission);
    }

     
    function emergencyTokenWithdraw(address tokenAddress_, uint256 amount)
        external
        onlyOwner
    {
        require(block.timestamp > vestingTimeEnd, "Vesting is still running");
        IERC20 tokenAddress = IERC20(tokenAddress_);
        require(
            tokenAddress.balanceOf(address(this)) >= amount,
            "Insufficient tokens balance"
        );
        tokenAddress.safeTransfer(msg.sender, amount);
    }

     
    function isValidData(
        address addr,
        uint256 portionLP,
        uint256 portionNative,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public returns (bool) {
        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");
        bytes32 message = keccak256(
            abi.encodePacked(
                address(this),
                addr,
                portionLP,
                portionNative,
                nonces[addr].current(),
                deadline
            )
        );

        address sender = ecrecover(message, v, r, s);
        if (trustedSigner[sender]) {
            nonces[addr].increment();
            return true;
        } else {
            return false;
        }
    }

     
    function withdrawReward(
        uint256 portionLP,
        uint256 portionNative,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(
            portionLP <= PERCENTAGE && portionNative <= PERCENTAGE,
            "The percentage cannot be greater than 100"
        );
        require(deadline >= block.timestamp, "Expired");
        bool access = isValidData(
            msg.sender,
            portionLP,
            portionNative,
            deadline,
            v,
            r,
            s
        );
        require(access, "Permission not granted");
        _withdrawReward(msg.sender, portionLP, portionNative);
    }

     
    function getRewardBalance(
        address beneficiary,
        uint256 percentageLP,
        uint256 percentageNative
    ) public view returns (uint256 amount) {
        uint256 reward = _getRewardBalance(percentageLP, percentageNative);
        Investor storage investor = investorInfo[beneficiary];
        uint256 balance = token.balanceOf(address(this));
        if (reward <= investor.paidAmount) {
            return 0;
        } else {
            uint256 amountToPay = reward.sub(investor.paidAmount);
            if (amountToPay >= balance) {
                return balance;
            }
            return amountToPay;
        }
    }

    function _withdrawReward(
        address beneficiary,
        uint256 percentageLP,
        uint256 percentageNative
    ) private {
        uint256 reward = _getRewardBalance(percentageLP, percentageNative);
        Investor storage investor = investorInfo[beneficiary];
        uint256 balance = token.balanceOf(address(this));
        require(reward > investor.paidAmount, "No rewards available");
        uint256 amountToPay = reward.sub(investor.paidAmount);
        if (amountToPay >= balance) {
            amountToPay = balance;
        }
        investor.paidAmount = reward;
        investor.timeRewardPaid = block.timestamp;
        token.safeTransfer(beneficiary, amountToPay);
        emit RewardPaid(beneficiary, amountToPay);
    }

    function _getRewardBalance(uint256 lpPercentage, uint256 nativePercentage)
        private
        view
        returns (uint256)
    {
        uint256 vestingAvailablePercentage = _calculateAvailablePercentage();
        uint256 amountAvailableForLP = tokensForLP
        .mul(vestingAvailablePercentage)
        .div(PERCENTAGE);
        uint256 amountAvailableForNative = tokensForNative
        .mul(vestingAvailablePercentage)
        .div(PERCENTAGE);
        uint256 rewardToPayLP = amountAvailableForLP.mul(lpPercentage).div(
            PERCENTAGE
        );
        uint256 rewardToPayNative = amountAvailableForNative
        .mul(nativePercentage)
        .div(PERCENTAGE);
        return rewardToPayLP.add(rewardToPayNative);
    }

    function _calculateAvailablePercentage()
        internal
        view
        virtual
        returns (uint256)
    {
        uint256 currentTimeStamp = block.timestamp;
        if (currentTimeStamp < vestingTimeEnd) {
            uint256 noOfDays = currentTimeStamp.sub(startDate).div(PERIOD);
            uint256 currentUnlockedPercentage = noOfDays.mul(
                everyDayReleasePercentage
            );
            return currentUnlockedPercentage;
        } else {
            return PERCENTAGE;
        }
    }

    function changePermission(address signer, bool permission) internal {
        require(signer != address(0), "Invalid signer address");
        trustedSigner[signer] = permission;
    }
}

 
pragma solidity 0.7.6;



contract RoyaleFinance is BaseVesting {
    constructor(
        address signer_,
        address token_,
        uint256 startDate_,
        uint256 vestingDuration_,
        uint256 totalAllocatedAmount_
    )
        BaseVesting(
            signer_,
            token_,
            startDate_,
            vestingDuration_,
            totalAllocatedAmount_
        )
    {}
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



 
library Counters {
    using SafeMath for uint256;

    struct Counter {
         
         
         
        uint256 _value;  
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
         
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}
