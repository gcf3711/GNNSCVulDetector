 


 

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

 

pragma solidity >=0.6.0 <0.8.0;

 
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
 

pragma solidity ^0.7.6;








contract PrivateSale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    
    struct UserInfoAmount {
        uint256 inputamount;
        uint256 totaloutputamount;
        uint256 inputTime;
        uint256 monthlyReward;
        uint256 firstReward;
    }

    struct UserInfoClaim {
        uint256 claimTime;
        uint256 claimAmount;
        uint256 firstClaimAmount;
        uint256 firstClaimTime;
        bool first;
    }

    struct WhiteList {
        uint256 amount;
    }

    event addList(
        address account,
        uint256 amount
    );

    event delList(
        address account,
        uint256 amount
    );

    event Buyinfo(
        address user,
        uint256 inputAmount,
        uint256 totalOutPutamount,
        uint256 inputTime,
        uint256 monthlyReward,
        uint256 firstReward
    );

    event FirstClaiminfo(
        address user,
        uint256 claimAmount,
        uint256 claimTime
    );

    event Claiminfo(
        address user,
        uint256 claimAmount,
        uint256 claimTime
    );

    event Withdrawinfo(
        address user,
        uint256 withdrawAmount
    );
    
    address public getTokenOwner;        
    uint256 public totalGetAmount;       
    uint256 public totalSaleAmount;      

    uint256 public saleStartTime;            
    uint256 public saleEndTime;              

    uint256 public firstClaimTime;            

    uint256 public claimStartTime;   
    uint256 public claimEndTime;     

    uint256 public saleTokenPrice;   
    uint256 public getTokenPrice;    

    IERC20 public saleToken;         
    IERC20 public getToken;          

    address public wton;              

    mapping (address => UserInfoAmount) public usersAmount;
    mapping (address => UserInfoClaim) public usersClaim;
    mapping (address => WhiteList) public usersWhite;


    
    
    constructor(address _wton) {
        wton = _wton;
    }

    
    
    function calculSaleToken(uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 tokenSaleAmount = _amount.mul(getTokenPrice).div(saleTokenPrice);
        return tokenSaleAmount;
    }

    
    
    function calculGetToken(uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 tokenGetAmount = _amount.mul(saleTokenPrice).div(getTokenPrice);
        return tokenGetAmount;
    }

    
    
    
    
    function addressSetting(
        address _saleToken,
        address _getToken,
        address _ownerToken
    ) external onlyOwner {
        changeTokenAddress(_saleToken,_getToken);
        changeGetAddress(_ownerToken);
    }

    function changeWTONAddress(address _wton) external onlyOwner {
        wton = _wton;
    }

    function changeTokenAddress(address _saleToken, address _getToken) public onlyOwner {
        saleToken = IERC20(_saleToken);
        getToken = IERC20(_getToken);
    }

    function changeGetAddress(address _address) public onlyOwner {
        getTokenOwner = _address;
    }

    function settingAll(
        uint256[4] calldata _time,
        uint256 _saleTokenPrice,
        uint256 _getTokenPrice
    ) external onlyOwner {
        settingPrivateTime(_time[0],_time[1],_time[2],_time[3]);
        setTokenPrice(_saleTokenPrice,_getTokenPrice);
    }

    function settingPrivateTime(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _firstTime,
        uint256 _claimTime
    ) public onlyOwner {
        settingSaleTime(_startTime,_endTime);
        settingFirstClaimTime(_firstTime);
        settingClaimTime(_claimTime);
    }

    function settingSaleTime(uint256 _startTime,uint256 _endTime) public onlyOwner {
        saleStartTime = _startTime;
        saleEndTime = _endTime;
    }

    function settingFirstClaimTime(uint256 _claimTime) public onlyOwner {
        firstClaimTime = _claimTime;
    }

    function settingClaimTime(uint256 _time) public onlyOwner {
        claimStartTime = _time;
        claimEndTime = _time.add(360 days);
    }

    function setTokenPrice(uint256 _saleTokenPrice, uint256 _getTokenPrice)
        public
        onlyOwner
    {
        saleTokenPrice = _saleTokenPrice;
        getTokenPrice = _getTokenPrice;
    }

    function claimAmount(
        address _account
    ) external view returns (uint256) {
        UserInfoAmount memory user = usersAmount[_account];

        require(user.inputamount > 0, "user isn't buy");
        require(block.timestamp > claimStartTime, "need to time for claim");
        
        UserInfoClaim memory userclaim = usersClaim[msg.sender];

        uint difftime = block.timestamp.sub(claimStartTime);
        uint monthTime = 30 days;

        if (difftime < monthTime) {
            uint period = 1;
            uint256 reward = (user.monthlyReward.mul(period)).sub(userclaim.claimAmount);
            return reward;
        } else {
            uint period = (difftime.div(monthTime)).add(1);
            if (period >= 12) {
                uint256 reward = user.totaloutputamount.sub(userclaim.claimAmount).sub(userclaim.firstClaimAmount);
                return reward; 
            } else {
                uint256 reward = (user.monthlyReward.mul(period)).sub(userclaim.claimAmount);
                return reward;
            }
        }
    }
    
    function calculClaimAmount(
        uint256 _nowtime, 
        uint256 _preclaimamount,
        uint256 _monthlyReward,
        uint256 _usertotaloutput,
        uint256 _firstReward
    ) internal view returns (uint256) {
        uint difftime = _nowtime.sub(claimStartTime);
        uint monthTime = 30 days;

        if (difftime < monthTime) {
            uint period = 1;
            uint256 reward = (_monthlyReward.mul(period)).sub(_preclaimamount);
            return reward;
        } else {
            uint period = (difftime.div(monthTime)).add(1);
            if (period >= 12) {
                uint256 reward = _usertotaloutput.sub(_preclaimamount).sub(_firstReward);
                return reward; 
            } else {
                uint256 reward = (_monthlyReward.mul(period)).sub(_preclaimamount);
                return reward;
            }
        }
    }

    function _toRAY(uint256 v) internal pure returns (uint256) {
        return v * 10 ** 9;
    }
    
    function addWhiteList(address _account,uint256 _amount) external onlyOwner {
        WhiteList storage userwhite = usersWhite[_account];
        userwhite.amount = userwhite.amount.add(_amount);

        emit addList(_account, _amount);
    }

    function addWhiteListArray(address[] calldata _account, uint256[] calldata _amount) external onlyOwner {
        for(uint i = 0; i < _account.length; i++) {
            WhiteList storage userwhite = usersWhite[_account[i]];
            userwhite.amount = userwhite.amount.add(_amount[i]);

            emit addList(_account[i], _amount[i]);
        }
    }

    function delWhiteList(address _account, uint256 _amount) external onlyOwner {
        WhiteList storage userwhite = usersWhite[_account];
        userwhite.amount = userwhite.amount.sub(_amount);

        emit delList(_account, _amount);
    }

    function buy(
        uint256 _amount
    ) external {
        require(saleStartTime != 0 && saleEndTime != 0, "need to setting saleTime");
        require(block.timestamp >= saleStartTime && block.timestamp <= saleEndTime, "privaSale period end");
        WhiteList storage userwhite = usersWhite[msg.sender];
        require(userwhite.amount >= _amount, "need to add whiteList amount");
        _buy(_amount);
        userwhite.amount = userwhite.amount.sub(_amount);
    }

    function _buy(
        uint256 _amount
    )
        internal
    {
        UserInfoAmount storage user = usersAmount[msg.sender];

        uint256 tokenSaleAmount = calculSaleToken(_amount);
        uint256 Saledtoken = totalSaleAmount.add(tokenSaleAmount);
        uint256 tokenBalance = saleToken.balanceOf(address(this));

        require(
            tokenBalance >= Saledtoken,
            "don't have token amount"
        );

        uint256 tonAllowance = getToken.allowance(msg.sender, address(this));
        uint256 tonBalance = getToken.balanceOf(msg.sender);

        if(tonBalance < _amount) {
            uint256 needUserWton;
            uint256 needWton = _amount.sub(tonBalance);
            needUserWton = _toRAY(needWton);
            require(IWTON(wton).allowance(msg.sender, address(this)) >= needUserWton, "privateSale: wton amount exceeds allowance");
            require(IWTON(wton).balanceOf(msg.sender) >= needUserWton, "need more wton");
            IERC20(wton).safeTransferFrom(msg.sender,address(this),needUserWton);
            IWTON(wton).swapToTON(needUserWton);
            require(tonAllowance >= _amount.sub(needWton), "privateSale: ton amount exceeds allowance");
            if(_amount.sub(needWton) > 0) {
                getToken.safeTransferFrom(msg.sender, address(this), _amount.sub(needWton));   
            }
            getToken.safeTransfer(getTokenOwner, _amount);
        } else {
            require(tonAllowance >= _amount, "privateSale: ton amount exceeds allowance");

            getToken.safeTransferFrom(msg.sender, address(this), _amount);
            getToken.safeTransfer(getTokenOwner, _amount);
        }

        user.inputamount = user.inputamount.add(_amount);
        user.totaloutputamount = user.totaloutputamount.add(tokenSaleAmount);
        user.firstReward = user.totaloutputamount.mul(5).div(100);
        user.monthlyReward = (user.totaloutputamount.sub(user.firstReward)).div(12);
        user.inputTime = block.timestamp;

        totalGetAmount = totalGetAmount.add(_amount);
        totalSaleAmount = totalSaleAmount.add(tokenSaleAmount);

        emit Buyinfo(
            msg.sender, 
            user.inputamount, 
            user.totaloutputamount,
            user.inputTime,
            user.monthlyReward,
            user.firstReward
        );
    }

    function claim() external {
        require(firstClaimTime != 0 && saleEndTime != 0, "need to setting Time");
        require(block.timestamp > saleEndTime && block.timestamp > firstClaimTime, "need the fisrClaimtime");
        if(block.timestamp < claimStartTime) {
            firstClaim();
        } else if(claimStartTime < block.timestamp){
            _claim();
        }
    }


    function firstClaim() public {
        UserInfoAmount storage user = usersAmount[msg.sender];
        UserInfoClaim storage userclaim = usersClaim[msg.sender];

        require(user.inputamount > 0, "need to buy the token");
        require(userclaim.firstClaimAmount == 0, "already getFirstreward");

        userclaim.firstClaimAmount = userclaim.firstClaimAmount.add(user.firstReward);
        userclaim.firstClaimTime = block.timestamp;

        saleToken.safeTransfer(msg.sender, user.firstReward);

        emit FirstClaiminfo(msg.sender, userclaim.firstClaimAmount, userclaim.firstClaimTime);
    }

    function _claim() public {
        require(block.timestamp >= claimStartTime, "need the time for claim");

        UserInfoAmount storage user = usersAmount[msg.sender];
        UserInfoClaim storage userclaim = usersClaim[msg.sender];

        require(user.inputamount > 0, "need to buy the token");
        require(!(user.totaloutputamount == (userclaim.claimAmount.add(userclaim.firstClaimAmount))), "already getAllreward");

        if(userclaim.firstClaimAmount == 0) {
            firstClaim();
        }

        uint256 giveTokenAmount = calculClaimAmount(block.timestamp, userclaim.claimAmount, user.monthlyReward, user.totaloutputamount, userclaim.firstClaimAmount);
    
        require(user.totaloutputamount.sub(userclaim.claimAmount) >= giveTokenAmount, "user is already getAllreward");
        require(saleToken.balanceOf(address(this)) >= giveTokenAmount, "dont have saleToken in pool");

        userclaim.claimAmount = userclaim.claimAmount.add(giveTokenAmount);
        userclaim.claimTime = block.timestamp;

        saleToken.safeTransfer(msg.sender, giveTokenAmount);

        emit Claiminfo(msg.sender, userclaim.claimAmount, userclaim.claimTime);
    }


    function withdraw(uint256 _amount) external onlyOwner {
        require(
            saleToken.balanceOf(address(this)) >= _amount,
            "dont have token amount"
        );
        saleToken.safeTransfer(msg.sender, _amount);

        emit Withdrawinfo(msg.sender, _amount);
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

 
pragma solidity ^0.7.6;

interface IWTON {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function onApprove(
        address owner,
        address spender,
        uint256 tonAmount,
        bytes calldata data
    ) external returns (bool);

    function burnFrom(address account, uint256 amount) external;

    function swapToTON(uint256 wtonAmount) external returns (bool);

    function swapFromTON(uint256 tonAmount) external returns (bool);

    function swapToTONAndTransfer(address to, uint256 wtonAmount)
        external
        returns (bool);

    function swapFromTONAndTransfer(address to, uint256 tonAmount)
        external
        returns (bool);

    function renounceTonMinter() external;

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address sender, address recipient) external returns (uint256);
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