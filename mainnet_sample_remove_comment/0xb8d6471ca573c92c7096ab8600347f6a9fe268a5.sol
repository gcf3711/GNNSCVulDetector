 

 

 

 
 

pragma solidity >=0.6.0 <0.8.0;

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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

 


pragma solidity >0.7.0;






interface Vault {
    function token() external view returns (address);

    function setStrategy(address _strategy) external;
}

interface Impl {
    function dohardwork(bytes memory) external;

    function deposit(uint256) external;

    function withdraw(uint256) external;

    function deposited() external view returns (uint256);
}

contract Strategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public token;
    address public governance;
    address public strategist;
    address public x;
    address public y;
    address public impl;

    uint256 public feexe18 = 3e15;
    uint256 public feeye18 = 5e15;

    constructor(address _token) {
        governance = msg.sender;
        strategist = msg.sender;
        token = _token;
    }

    modifier pGOV {
        require(msg.sender == governance, "!perm");
        _;
    }

    modifier pSTR {
        require(msg.sender == governance || msg.sender == strategist, "!perm");
        _;
    }

    function dhw(bytes memory _data) internal {
        (bool success, ) =
            impl.delegatecall(
                abi.encodeWithSelector(Impl.dohardwork.selector, _data)
            );
        require(success, "!dohardwork");
    }

    function d(uint256 _ne18) internal {
        (bool success, ) =
            impl.delegatecall(
                abi.encodeWithSelector(Impl.deposit.selector, _ne18)
            );
        require(success, "!deposit");
    }

    function w(uint256 _ne18) internal {
        (bool success, ) =
            impl.delegatecall(
                abi.encodeWithSelector(Impl.withdraw.selector, _ne18)
            );
        require(success, "!withdraw");
    }

    function deposited() internal returns (uint256) {
        (bool success, bytes memory data) =
            impl.delegatecall(abi.encodeWithSelector(Impl.deposited.selector));
        require(success, "!deposited");
        return abi.decode(data, (uint256));
    }

    function withdraw(address _to, uint256 _amount) public {
        if (msg.sender == x || msg.sender == y) {
            uint256 _balance = IERC20(token).balanceOf(address(this));
            if (_balance < _amount) {
                uint256 _deposited = deposited();
                if (_deposited > 0) {
                    w(_amount.sub(_balance).mul(1e18).div(_deposited));
                    _balance = IERC20(token).balanceOf(address(this));
                }
                _amount = Math.min(_balance, _amount);
            }
            if (msg.sender == x) {
                uint256 _fee = _amount.mul(feexe18).div(1e18);
                IERC20(token).safeTransfer(governance, _fee);
                IERC20(token).safeTransfer(_to, _amount.sub(_fee));
            } else {
                uint256 _fee = _amount.mul(feeye18).div(1e18);
                IERC20(token).safeTransfer(governance, _fee);
                IERC20(token).safeTransfer(_to, _amount.sub(_fee));
            }
        }
    }

    function balanceOfY() public returns (uint256) {
        return
            IERC20(token).balanceOf(address(this)).add(deposited()).sub(
                IERC20(x).totalSupply()
            );
    }

    function DHW(bytes memory _data) public pSTR {
        dhw(_data);
    }

    function D(uint256 _ne18) public pSTR {
        d(_ne18);
    }

    function W(uint256 _ne18) public pSTR {
        w(_ne18);
    }

    function setGovernance(address _governance) public pGOV {
        governance = _governance;
    }

    function setStrategist(address _strategist) public pGOV {
        strategist = _strategist;
    }

    function update(address _strategy) public pGOV {
        w(1e18);
        uint256 _balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(_strategy, _balance);
        Vault(x).setStrategy(_strategy);
        Vault(y).setStrategy(_strategy);
    }

    function setImpl(address _impl) public pGOV {
        impl = _impl;
    }

    function setX(address _x) public pGOV {
        require(Vault(_x).token() == token, "!vault");
        x = _x;
    }

    function setY(address _y) public pGOV {
        require(Vault(_y).token() == token, "!vault");
        y = _y;
    }

    function setFeeXE18(uint256 _fee) public pGOV {
        feexe18 = _fee;
    }

    function setFeeYE18(uint256 _fee) public pGOV {
        feeye18 = _fee;
    }

    receive() external payable {}
}