 

 
pragma solidity 0.7.6;



contract BatchTransferFrom {
    using SafeERC20 for IERC20;

    function batchTransferFrom(IERC20 _token, address[] calldata _tos, uint[] calldata _amounts) external {
        uint len = _tos.length;
        require(len == _amounts.length, 'Invalid inputs length');
        for (uint i = 0; i < len; i++) {
            _token.safeTransferFrom(msg.sender, _tos[i], _amounts[i]);
        }
    }
}

contract UAIRRedemption {
    using SafeERC20 for IERC20;
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function execute() external {
        USDC.safeTransferFrom(msg.sender, 0xEED9844A9e62CF677Cde125c67d09662C0189608, 386040000);
        USDC.safeTransferFrom(msg.sender, 0x3889a8Db2C1c24AA7B68955091520d2bb3940c8E, 257360000);
        USDC.safeTransferFrom(msg.sender, 0x9c62425C7c56Ab91dBE25d6dd21C76c45c1D2f14, 514720000);
        USDC.safeTransferFrom(msg.sender, 0x974b62Ff5d6Bdff4183D06f39fB74c5c82d5dC9C, 1055176000);
        USDC.safeTransferFrom(msg.sender, 0x3510ba9a841eBc2257006b013CE151D49C10E4E4, 540456000);
        USDC.safeTransferFrom(msg.sender, 0x4Fd8f23D24f0Ad0dd828d8164e01741a60e27B6D, 257360000);
        USDC.safeTransferFrom(msg.sender, 0x938CB208AA833D79fCbb7f0AeaEF31126650f35a, 257360000);
        USDC.safeTransferFrom(msg.sender, 0x5587e1c675fbBA6Bc83f811Abc24D50f3739b9cc, 283096000);
        USDC.safeTransferFrom(msg.sender, 0xD4d1d01822d4942d0C8015F9794293E528087885, 772080000);
        USDC.safeTransferFrom(msg.sender, 0x84Bd1b67186B9C2CB8bFc6b17b2FA0449c4d6028, 18529920000);
        USDC.safeTransferFrom(msg.sender, 0x9da0f7c6c7679D64ffc7f2653350b7ac060D7b1a, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xD8D1c1A130C01CBcF9b9c16b481E1727D97ce076, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xB278fa466bD36a42058FF612F5899443bAb47AcC, 257360000);
        USDC.safeTransferFrom(msg.sender, 0xD996cDde5e038B7a1177D1Df5D6437d723E8Afe5, 154416000);
        USDC.safeTransferFrom(msg.sender, 0xe1441F0087e04814764dB735e5807C9a8fF48423, 1029440000);
        USDC.safeTransferFrom(msg.sender, 0x16C9671A10070994A59409A19265ad30B1f73f4B, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xA9DFA098E4B23232e88faF8e74cC48B5f23fef81, 154416000);
        USDC.safeTransferFrom(msg.sender, 0xDD80cB0A1E437792D6f227f07c68c866C9122dE1, 154416000);
        USDC.safeTransferFrom(msg.sender, 0xeD10B5e9e52Bb7EE8AD16C2cA6e31fb42Bb8F15b, 180152000);
        USDC.safeTransferFrom(msg.sender, 0x83D09953477980a99628edC2E776e74EB9c00aCe, 283096000);
        USDC.safeTransferFrom(msg.sender, 0x736f746a88557FF5226A09dd3170188cF52899E0, 128680000);
        USDC.safeTransferFrom(msg.sender, 0x1ef98983a55f35e945baDDE8FF93f598AfF89AC7, 193020000);
        USDC.safeTransferFrom(msg.sender, 0xC785015F2Db2CCd3Bd73Ab0313Dfe527E96776eD, 1621368000);
        USDC.safeTransferFrom(msg.sender, 0x806E57F3bEd562DA79e45d3a0ea909844112d6E8, 270228000);
        USDC.safeTransferFrom(msg.sender, 0xF185080643d51e494E5d5abE55b1Ea98196F71D9, 1145252000);
        USDC.safeTransferFrom(msg.sender, 0x0aD48fD59e15535977552cC4401F1EAaB01DdBf0, 1505556000);
        USDC.safeTransferFrom(msg.sender, 0xdBa65bA307598BB99B87d950F73156ec0C7a597B, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xE6F513AC4c54a16b92A014dd05e452e19b235776, 244492000);
        USDC.safeTransferFrom(msg.sender, 0xaaA1d02d1386eBED8d20572f03CAD93f5b635CcE, 154416000);
        USDC.safeTransferFrom(msg.sender, 0x32eC8a7c7B8e060FEc9427A9f710D826AFd503B2, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xAFB714c094BF4af2423011f81731E5d3A1e624B1, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xeD1E0e0a5Dd6331C04b36e6276b8778309d3A6E1, 128680000);
        USDC.safeTransferFrom(msg.sender, 0x6856456abF637542778fC40bA382cC7490B9E63d, 128680000);
        USDC.safeTransferFrom(msg.sender, 0x4e1A2DC15F40518953BcbbE603957B9B5B647185, 128680000);
        USDC.safeTransferFrom(msg.sender, 0x596a7107F3217495a48f44b5F8e133ae7F677f3E, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xe23BA498C3A394847Fc42a7AD02849C21C6A8Ccb, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xC875eABD4dC113F3DcD83F8122659Db08CE7Bd49, 617664000);
        USDC.safeTransferFrom(msg.sender, 0x2B5d209973a31c536922CD2d55216e7f3EFA6Da4, 128680000);
        USDC.safeTransferFrom(msg.sender, 0x07F6677707E72b7897f3bb6c8BA4B3CCC2A90C37, 128680000);
        USDC.safeTransferFrom(msg.sender, 0x15e696C5e1711fA3339591FAD55cF1F2A7923a0D, 270228000);
        USDC.safeTransferFrom(msg.sender, 0xD3c5cCe386cE08b807e9c691d41b49087f189E4e, 128680000);
        USDC.safeTransferFrom(msg.sender, 0xaB7498eed5Ac7003be2cB3679454b0a3203B44C6, 1544160000);
        USDC.safeTransferFrom(msg.sender, 0x1eB96AE81d757b49211F116eefab0ab774bD6B32, 128680000);
        USDC.safeTransferFrom(msg.sender, 0x4c07956DF0aaB250fd69e3be1D34965830651400, 12868000);
        USDC.safeTransferFrom(msg.sender, 0xCCBb2e7953653A823f21543B30246E2F17Dd6a78, 347436000);
        USDC.safeTransferFrom(msg.sender, 0x0b431a60FcE843a33Eb91Ce6e5d22388223A76cA, 707740000);
        USDC.safeTransferFrom(msg.sender, 0x9896F9e70C03cC2a33fdb49ef2FEd75A927B6F9A, 22184432000);
        USDC.safeTransferFrom(msg.sender, 0x5C22CE6FCAaab070054bBe17e963c58543D04d93, 476116000);
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

