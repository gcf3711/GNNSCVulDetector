 


 

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
 

pragma solidity ^0.7.0;










contract PremiaBondingCurve is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

     
    IERC20 public premia;
     
    address payable public treasury;

     
    uint256 internal immutable k;
     
    uint256 internal immutable startPrice;
     
    uint256 public soldAmount;

     
    IPremiaBondingCurveUpgrade public newContract;
     
    uint256 public upgradeETA;
     
    uint256 public immutable upgradeDelay = 7 days;

     
     
    bool public isUpgradeDone;

     
     
     

    event Bought(address indexed account, address indexed sentTo, uint256 amount, uint256 ethAmount);
    event Sold(address indexed account, uint256 amount, uint256 ethAmount, uint256 comission);

    event UpgradeStarted(address newContract, uint256 eta);
    event UpgradeCancelled(address newContract, uint256 eta);
    event UpgradePerformed(address newContract, uint256 premiaBalance, uint256 ethBalance, uint256 soldAmount);

     
     
     

    
    
    
    
    constructor(IERC20 _premia, address payable _treasury, uint256 _startPrice, uint256 _k) {
        premia = _premia;
        treasury = _treasury;
        startPrice = _startPrice;
        k = _k;
    }

     
     
     

     
     
     

    modifier notUpgraded() {
        require(!isUpgradeDone, "Contract has been upgraded");
        _;
    }

     

     
     
     

    
    
    function startUpgrade(IPremiaBondingCurveUpgrade _newContract) external onlyOwner notUpgraded {
        newContract = _newContract;
        upgradeETA = block.timestamp.add(upgradeDelay);
        emit UpgradeStarted(address(newContract), upgradeETA);
    }

    
    function doUpgrade() external onlyOwner notUpgraded {
        require(address(newContract) != address(0), "No new contract set");
        require(block.timestamp > upgradeETA, "Upgrade still timelocked");

        uint256 premiaBalance = premia.balanceOf(address(this));
        uint256 ethBalance = address(this).balance;
        premia.safeTransfer(address(newContract), premiaBalance);

        newContract.initialize{value: ethBalance}(premiaBalance, ethBalance, soldAmount);
        isUpgradeDone = true;
        emit UpgradePerformed(address(newContract), premiaBalance, ethBalance, soldAmount);
    }

    
    function cancelUpgrade() external onlyOwner notUpgraded {
        address _newContract = address(newContract);
        uint256 _upgradeETA = upgradeETA;

        delete newContract;
        delete upgradeETA;

        emit UpgradeCancelled(address(_newContract), _upgradeETA);
    }

     

     
     
     

    
    
    function buyExactTokenAmount(uint256 _tokenAmount) external payable notUpgraded {
        uint256 nextSold = soldAmount.add(_tokenAmount);
        uint256 ethAmount = getEthCost(soldAmount, nextSold);
        soldAmount = nextSold;
        require(msg.value >= ethAmount, "Value is too small");
        premia.safeTransfer(msg.sender, _tokenAmount);
        if (msg.value > ethAmount)
            msg.sender.transfer(msg.value.sub(ethAmount));
        emit Bought(msg.sender, msg.sender, _tokenAmount, ethAmount);
    }

    
    
    
    
    function buyTokenWithExactEthAmount(uint256 _minToken, address _sendTo) external payable notUpgraded returns(uint256) {
        uint256 ethAmount = msg.value;
        uint256 tokenAmount = getTokensPurchasable(ethAmount);
        require(tokenAmount >= _minToken, "< _minToken");
        soldAmount = soldAmount.add(tokenAmount);
        premia.safeTransfer(_sendTo, tokenAmount);
        emit Bought(msg.sender, _sendTo, tokenAmount, ethAmount);

        return tokenAmount;
    }

    
    
    
    
    
    
    
    function sellWithPermit(uint256 _tokenAmount, uint256 _minEth, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external {
        IERC2612Permit(address(premia)).permit(msg.sender, address(this), _tokenAmount, _deadline, _v, _r, _s);
        sell(_tokenAmount, _minEth);
    }

    
    
    
    function sell(uint256 _tokenAmount, uint256 _minEth) public notUpgraded {
        uint256 nextSold = soldAmount.sub(_tokenAmount);
        uint256 ethAmount = getEthCost(nextSold, soldAmount);
        require(ethAmount >= _minEth, "< _minEth");
        uint256 commission = ethAmount.div(10);
        uint256 refund = ethAmount.sub(commission);
        require(commission > 0);

        soldAmount = nextSold;
        premia.safeTransferFrom(msg.sender, address(this), _tokenAmount);
        treasury.transfer(commission);
        msg.sender.transfer(refund);
        emit Sold(msg.sender, _tokenAmount, refund, commission);
    }

     

     
     
     

    
    
    
    
    function getEthCost(uint256 _x0, uint256 _x1) public view returns (uint256) {
        require(_x1 > _x0);
        return _x1.add(_x0).mul(_x1.sub(_x0))
        .div(2).div(k)
        .add(startPrice.mul(_x1.sub(_x0)))
        .div(1e18);
    }

    
    
    
    function getTokensPurchasable(uint256 _ethAmount) public view returns(uint256) {
         
        uint256 x1 = _sqrt(
            _ethAmount.mul(2e18).mul(k)
            .add(k.mul(k).mul(startPrice).mul(startPrice))
            .add(k.mul(2).mul(startPrice).mul(soldAmount))
            .add(soldAmount.mul(soldAmount)))
        .sub(k.mul(startPrice));

        return x1 - soldAmount;
    }

     

     
     
     

    
     
    function _sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
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

interface IPremiaBondingCurveUpgrade {
    function initialize(uint256 _premiaBalance, uint256 _ethBalance, uint256 _soldAmount) external payable;
}

 
pragma solidity ^0.7.0;

 
interface IERC2612Permit {
     
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

     
    function nonces(address owner) external view returns (uint256);
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
