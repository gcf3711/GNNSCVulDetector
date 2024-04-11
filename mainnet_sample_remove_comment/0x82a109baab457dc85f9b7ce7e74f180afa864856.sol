 
pragma experimental ABIEncoderV2;

 

 

pragma solidity ^0.6.0;


interface IExchangeProxy {
    struct Swap {
        address pool;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;  
        uint256 limitReturnAmount;  
        uint256 maxPrice;
    }

    function batchSwapExactIn(
        Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut
    ) external payable returns (uint256 totalAmountOut);

    function batchSwapExactOut(
        Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn
    ) external payable returns (uint256 totalAmountIn);

    function multihopBatchSwapExactIn(
        Swap[][] calldata swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut
    ) external payable returns (uint256 totalAmountOut);

    function multihopBatchSwapExactOut(
        Swap[][] calldata swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn
    ) external payable returns (uint256 totalAmountIn);

    function smartSwapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        uint256 nPools
    ) external payable returns (uint256 totalAmountOut);

    function smartSwapExactOut(
        address tokenIn,
        address tokenOut,
        uint256 totalAmountOut,
        uint256 maxTotalAmountIn,
        uint256 nPools
    ) external payable returns (uint256 totalAmountIn);
}

 

 


 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

     
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 


 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

         
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

     
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

     
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

         
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

 


 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

     
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
         
         
         
         
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeERC20: decreased allowance below zero"
            );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
             
             
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

 


interface IERC20Usdt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external;

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

 


contract Config {
     
    bytes4 public constant POSTPROCESS_SIG = 0xc2722916;

     
    uint256 public constant PERCENTAGE_BASE = 1 ether;

     
    enum HandlerType {Token, Custom, Others}
}

 


library LibCache {
    function set(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key,
        bytes32 _value
    ) internal {
        _cache[_key] = _value;
    }

    function setAddress(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key,
        address _value
    ) internal {
        _cache[_key] = bytes32(uint256(uint160(_value)));
    }

    function setUint256(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key,
        uint256 _value
    ) internal {
        _cache[_key] = bytes32(_value);
    }

    function getAddress(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key
    ) internal view returns (address ret) {
        ret = address(uint160(uint256(_cache[_key])));
    }

    function getUint256(
        mapping(bytes32 => bytes32) storage _cache,
        bytes32 _key
    ) internal view returns (uint256 ret) {
        ret = uint256(_cache[_key]);
    }

    function get(mapping(bytes32 => bytes32) storage _cache, bytes32 _key)
        internal
        view
        returns (bytes32 ret)
    {
        ret = _cache[_key];
    }
}

 


library LibStack {
    function setAddress(bytes32[] storage _stack, address _input) internal {
        _stack.push(bytes32(uint256(uint160(_input))));
    }

    function set(bytes32[] storage _stack, bytes32 _input) internal {
        _stack.push(_input);
    }

    function setHandlerType(bytes32[] storage _stack, Config.HandlerType _input)
        internal
    {
        _stack.push(bytes12(uint96(_input)));
    }

    function getAddress(bytes32[] storage _stack)
        internal
        returns (address ret)
    {
        ret = address(uint160(uint256(peek(_stack))));
        _stack.pop();
    }

    function getSig(bytes32[] storage _stack) internal returns (bytes4 ret) {
        ret = bytes4(peek(_stack));
        _stack.pop();
    }

    function get(bytes32[] storage _stack) internal returns (bytes32 ret) {
        ret = peek(_stack);
        _stack.pop();
    }

    function peek(bytes32[] storage _stack)
        internal
        view
        returns (bytes32 ret)
    {
        require(_stack.length > 0, "stack empty");
        ret = _stack[_stack.length - 1];
    }
}

 



contract Storage {
    using LibCache for mapping(bytes32 => bytes32);
    using LibStack for bytes32[];

    bytes32[] public stack;
    mapping(bytes32 => bytes32) public cache;

     
     
    bytes32 public constant MSG_SENDER_KEY = 0xb2f2618cecbbb6e7468cc0f2aa43858ad8d153e0280b22285e28e853bb9d453a;

     
     
    bytes32 public constant CUBE_COUNTER_KEY = 0xf9543f11459ccccd21306c8881aaab675ff49d988c1162fd1dd9bbcdbe4446be;

    modifier isStackEmpty() {
        require(stack.length == 0, "Stack not empty");
        _;
    }

    modifier isCubeCounterZero() {
        require(_getCubeCounter() == 0, "Cube counter not zero");
        _;
    }

    modifier isInitialized() {
        require(_getSender() != address(0), "Sender is not initialized");
        _;
    }

    modifier isNotInitialized() {
        require(_getSender() == address(0), "Sender is initialized");
        _;
    }

    function _setSender() internal isNotInitialized {
        cache.setAddress(MSG_SENDER_KEY, msg.sender);
    }

    function _resetSender() internal {
        cache.setAddress(MSG_SENDER_KEY, address(0));
    }

    function _getSender() internal view returns (address) {
        return cache.getAddress(MSG_SENDER_KEY);
    }

    function _addCubeCounter() internal {
        cache.setUint256(CUBE_COUNTER_KEY, _getCubeCounter() + 1);
    }

    function _resetCubeCounter() internal {
        cache.setUint256(CUBE_COUNTER_KEY, 0);
    }

    function _getCubeCounter() internal view returns (uint256) {
        return cache.getUint256(CUBE_COUNTER_KEY);
    }
}

 


abstract contract HandlerBase is Storage, Config {
    using SafeERC20 for IERC20;

    function postProcess() external payable virtual {
        revert("Invalid post process");
         
    }

    function _updateToken(address token) internal {
        stack.setAddress(token);
         
         
    }

    function _updatePostProcess(bytes32[] memory params) internal {
        for (uint256 i = params.length; i > 0; i--) {
            stack.set(params[i - 1]);
        }
        stack.set(msg.sig);
        stack.setHandlerType(HandlerType.Custom);
    }

    function getContractName() public pure virtual returns (string memory);

    function _revertMsg(string memory functionName, string memory reason)
        internal
        view
    {
        revert(
            string(
                abi.encodePacked(
                    _uint2String(_getCubeCounter()),
                    "_",
                    getContractName(),
                    "_",
                    functionName,
                    ": ",
                    reason
                )
            )
        );
    }

    function _revertMsg(string memory functionName) internal view {
        _revertMsg(functionName, "Unspecified");
    }

    function _uint2String(uint256 n) internal pure returns (string memory) {
        if (n == 0) {
            return "0";
        } else {
            uint256 len = 0;
            for (uint256 temp = n; temp > 0; temp /= 10) {
                len++;
            }
            bytes memory str = new bytes(len);
            for (uint256 i = len; i > 0; i--) {
                str[i - 1] = bytes1(uint8(48 + (n % 10)));
                n /= 10;
            }
            return string(str);
        }
    }

    function _getBalance(address token, uint256 amount)
        internal
        view
        returns (uint256)
    {
        if (amount != uint256(-1)) {
            return amount;
        }

         
        if (
            token == address(0) ||
            token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
        ) {
            return address(this).balance;
        }
         
        return IERC20(token).balanceOf(address(this));
    }

    function _tokenApprove(
        address token,
        address spender,
        uint256 amount
    ) internal {
        try IERC20Usdt(token).approve(spender, amount) {} catch {
            IERC20(token).safeApprove(spender, 0);
            IERC20(token).safeApprove(spender, amount);
        }
    }
}

 


contract HBalancerExchange is HandlerBase {
    using SafeERC20 for IERC20;

     
    address public constant EXCHANGE_PROXY = 0x3E66B66Fd1d0b02fDa6C811Da9E0547970DB2f21;
     
    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function getContractName() public pure override returns (string memory) {
        return "HBalancerExchange";
    }

    function batchSwapExactIn(
        IExchangeProxy.Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut
    ) external payable returns (uint256 totalAmountOut) {
        IExchangeProxy balancer = IExchangeProxy(EXCHANGE_PROXY);
        totalAmountIn = _getBalance(tokenIn, totalAmountIn);

        if (tokenIn == ETH_ADDRESS) {
            try
                balancer.batchSwapExactIn{value: totalAmountIn}(
                    swaps,
                    tokenIn,
                    tokenOut,
                    totalAmountIn,
                    minTotalAmountOut
                )
            returns (uint256 amount) {
                totalAmountOut = amount;
            } catch Error(string memory reason) {
                _revertMsg("batchSwapExactIn", reason);
            } catch {
                _revertMsg("batchSwapExactIn");
            }
        } else {
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, totalAmountIn);
            try
                balancer.batchSwapExactIn(
                    swaps,
                    tokenIn,
                    tokenOut,
                    totalAmountIn,
                    minTotalAmountOut
                )
            returns (uint256 amount) {
                totalAmountOut = amount;
            } catch Error(string memory reason) {
                _revertMsg("batchSwapExactIn", reason);
            } catch {
                _revertMsg("batchSwapExactIn");
            }
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, 0);
        }

        if (tokenOut != ETH_ADDRESS) _updateToken(tokenOut);
    }

    function batchSwapExactOut(
        IExchangeProxy.Swap[] calldata swaps,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn
    ) external payable returns (uint256 totalAmountIn) {
        IExchangeProxy balancer = IExchangeProxy(EXCHANGE_PROXY);
        maxTotalAmountIn = _getBalance(tokenIn, maxTotalAmountIn);

        if (tokenIn == ETH_ADDRESS) {
            try
                balancer.batchSwapExactOut{value: maxTotalAmountIn}(
                    swaps,
                    tokenIn,
                    tokenOut,
                    maxTotalAmountIn
                )
            returns (uint256 amount) {
                totalAmountIn = amount;
            } catch Error(string memory reason) {
                _revertMsg("batchSwapExactOut", reason);
            } catch {
                _revertMsg("batchSwapExactOut");
            }
        } else {
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, maxTotalAmountIn);
            try
                balancer.batchSwapExactOut(
                    swaps,
                    tokenIn,
                    tokenOut,
                    maxTotalAmountIn
                )
            returns (uint256 amount) {
                totalAmountIn = amount;
            } catch Error(string memory reason) {
                _revertMsg("batchSwapExactOut", reason);
            } catch {
                _revertMsg("batchSwapExactOut");
            }
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, 0);
        }

        if (tokenOut != ETH_ADDRESS) _updateToken(tokenOut);
    }

    function multihopBatchSwapExactIn(
        IExchangeProxy.Swap[][] calldata swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut
    ) external payable returns (uint256 totalAmountOut) {
        IExchangeProxy balancer = IExchangeProxy(EXCHANGE_PROXY);
        totalAmountIn = _getBalance(tokenIn, totalAmountIn);
        if (tokenIn == ETH_ADDRESS) {
            try
                balancer.multihopBatchSwapExactIn{value: totalAmountIn}(
                    swapSequences,
                    tokenIn,
                    tokenOut,
                    totalAmountIn,
                    minTotalAmountOut
                )
            returns (uint256 amount) {
                totalAmountOut = amount;
            } catch Error(string memory reason) {
                _revertMsg("multihopBatchSwapExactIn", reason);
            } catch {
                _revertMsg("multihopBatchSwapExactIn");
            }
        } else {
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, totalAmountIn);
            try
                balancer.multihopBatchSwapExactIn(
                    swapSequences,
                    tokenIn,
                    tokenOut,
                    totalAmountIn,
                    minTotalAmountOut
                )
            returns (uint256 amount) {
                totalAmountOut = amount;
            } catch Error(string memory reason) {
                _revertMsg("multihopBatchSwapExactIn", reason);
            } catch {
                _revertMsg("multihopBatchSwapExactIn");
            }
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, 0);
        }

        if (tokenOut != ETH_ADDRESS) _updateToken(tokenOut);
    }

    function multihopBatchSwapExactOut(
        IExchangeProxy.Swap[][] calldata swapSequences,
        address tokenIn,
        address tokenOut,
        uint256 maxTotalAmountIn
    ) external payable returns (uint256 totalAmountIn) {
        IExchangeProxy balancer = IExchangeProxy(EXCHANGE_PROXY);
        maxTotalAmountIn = _getBalance(tokenIn, maxTotalAmountIn);

        if (tokenIn == ETH_ADDRESS) {
            try
                balancer.multihopBatchSwapExactOut{value: maxTotalAmountIn}(
                    swapSequences,
                    tokenIn,
                    tokenOut,
                    maxTotalAmountIn
                )
            returns (uint256 amount) {
                totalAmountIn = amount;
            } catch Error(string memory reason) {
                _revertMsg("multihopBatchSwapExactOut", reason);
            } catch {
                _revertMsg("multihopBatchSwapExactOut");
            }
        } else {
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, maxTotalAmountIn);
            try
                balancer.multihopBatchSwapExactOut(
                    swapSequences,
                    tokenIn,
                    tokenOut,
                    maxTotalAmountIn
                )
            returns (uint256 amount) {
                totalAmountIn = amount;
            } catch Error(string memory reason) {
                _revertMsg("multihopBatchSwapExactOut", reason);
            } catch {
                _revertMsg("multihopBatchSwapExactOut");
            }
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, 0);
        }

        if (tokenOut != ETH_ADDRESS) _updateToken(tokenOut);
    }

    function smartSwapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        uint256 minTotalAmountOut,
        uint256 nPools
    ) external payable returns (uint256 totalAmountOut) {
        IExchangeProxy balancer = IExchangeProxy(EXCHANGE_PROXY);

        totalAmountIn = _getBalance(tokenIn, totalAmountIn);
        if (tokenIn == ETH_ADDRESS) {
            try
                balancer.smartSwapExactIn{value: totalAmountIn}(
                    tokenIn,
                    tokenOut,
                    totalAmountIn,
                    minTotalAmountOut,
                    nPools
                )
            returns (uint256 amount) {
                totalAmountOut = amount;
            } catch Error(string memory reason) {
                _revertMsg("smartSwapExactIn", reason);
            } catch {
                _revertMsg("smartSwapExactIn");
            }
        } else {
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, totalAmountIn);
            try
                balancer.smartSwapExactIn(
                    tokenIn,
                    tokenOut,
                    totalAmountIn,
                    minTotalAmountOut,
                    nPools
                )
            returns (uint256 amount) {
                totalAmountOut = amount;
            } catch Error(string memory reason) {
                _revertMsg("smartSwapExactIn", reason);
            } catch {
                _revertMsg("smartSwapExactIn");
            }
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, 0);
        }

        if (tokenOut != ETH_ADDRESS) _updateToken(tokenOut);
    }

    function smartSwapExactOut(
        address tokenIn,
        address tokenOut,
        uint256 totalAmountOut,
        uint256 maxTotalAmountIn,
        uint256 nPools
    ) external payable returns (uint256 totalAmountIn) {
        IExchangeProxy balancer = IExchangeProxy(EXCHANGE_PROXY);
        maxTotalAmountIn = _getBalance(tokenIn, maxTotalAmountIn);

        if (tokenIn == ETH_ADDRESS) {
            try
                balancer.smartSwapExactOut{value: maxTotalAmountIn}(
                    tokenIn,
                    tokenOut,
                    totalAmountOut,
                    maxTotalAmountIn,
                    nPools
                )
            returns (uint256 amount) {
                totalAmountIn = amount;
            } catch Error(string memory reason) {
                _revertMsg("smartSwapExactOut", reason);
            } catch {
                _revertMsg("smartSwapExactOut");
            }
        } else {
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, maxTotalAmountIn);
            try
                balancer.smartSwapExactOut(
                    tokenIn,
                    tokenOut,
                    totalAmountOut,
                    maxTotalAmountIn,
                    nPools
                )
            returns (uint256 amount) {
                totalAmountIn = amount;
            } catch Error(string memory reason) {
                _revertMsg("smartSwapExactOut", reason);
            } catch {
                _revertMsg("smartSwapExactOut");
            }
            IERC20(tokenIn).safeApprove(EXCHANGE_PROXY, 0);
        }

        if (tokenOut != ETH_ADDRESS) _updateToken(tokenOut);
    }
}