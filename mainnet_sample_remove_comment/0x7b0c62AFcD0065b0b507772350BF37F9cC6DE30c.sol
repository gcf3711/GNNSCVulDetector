
 

pragma solidity ^0.5.16;


 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }
}


 
interface ERC20 {
    function balanceOf(address _address) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
         
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
         
        (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


 
contract BhxManage {
     
    address public owner;
     
    address public owner2;
     
    mapping (bytes32 => bool) public signHash;
     
    address public bhx;
     
    address public usdt;
     
    address public feeAddress;

     
     
     
     
    constructor(address _owner2, address _bhx, address _usdt, address _feeAddress) public {
        owner = msg.sender;
        owner2 = _owner2;
        bhx = _bhx;
        usdt = _usdt;
        feeAddress = _feeAddress;
    }

     
    event BhxRed(address indexed owner, uint256 value);
     
    event UsdtRed(address indexed owner, uint256 value);

     
    modifier onlyOwner() {
        require(owner == msg.sender, "BHXManage: You are not owner");
        _;
    }

     
    function setOwner(address _owner) external onlyOwner {
        require(_owner != address(0), "BHXManage: Zero address error");
        owner = _owner;
    }

     
    function setOwner2(address _owner2) external onlyOwner {
        require(_owner2 != address(0), "BHXManage: Zero address error");
        owner2 = _owner2;
    }

     
    function setFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "BHXManage: Zero address error");
        feeAddress = _feeAddress;
    }

     
    function takeErc20(address _erc20Address) external onlyOwner {
        require(_erc20Address != address(0), "BHXManage: Zero address error");
         
        ERC20 erc20 = ERC20(_erc20Address);
         
        uint256 _value = erc20.balanceOf(address(this));
         
        TransferHelper.safeTransfer(_erc20Address, msg.sender, _value);
    }

     
    function takeETH() external onlyOwner {
        uint256 _value = address(this).balance;
        TransferHelper.safeTransferETH(msg.sender, _value);
    }

     
     
     
     
     
    function backendTransferBhx(uint256 _value, uint256 _feeValue, uint256 _nonce, bytes memory _signature) public payable {
        address _to = msg.sender;
        require(_to != address(0), "BHXManage: Zero address error");
         
        ERC20 bhxErc20 = ERC20(bhx);
         
        uint256 bhxBalance = bhxErc20.balanceOf(address(this));
        require(bhxBalance >= _value && _value > 0, "BHXManage: Insufficient balance or zero amount");
         
         
        bytes32 hash = keccak256(abi.encodePacked(_to, _value, _feeValue, _nonce));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        address signer = recoverSigner(messageHash, _signature);
        require(signer == owner2, "BHXManage: Signer is not owner2");
         
        require(signHash[messageHash] == false, "BHXManage: MessageHash is used");
         
        signHash[messageHash] = true;
         
        require(msg.value == _feeValue, "BHXManage: Value unequal fee value");

         
        TransferHelper.safeTransfer(bhx, _to, _value);
         
        TransferHelper.safeTransferETH(feeAddress, _feeValue);
        emit BhxRed(_to, _value);
    }

     
     
     
     
     
    function backendTransferUsdt(uint256 _value, uint256 _feeValue, uint256 _nonce, bytes memory _signature) public payable {
        address _to = msg.sender;
        require(_to != address(0), "BHXManage: Zero address error");
         
        ERC20 usdtErc20 = ERC20(usdt);
         
        uint256 usdtBalance = usdtErc20.balanceOf(address(this));
        require(usdtBalance >= _value && _value > 0, "BHXManage: Insufficient balance or zero amount");
         
         
        bytes32 hash = keccak256(abi.encodePacked(_to, _value, _feeValue, _nonce));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        address signer = recoverSigner(messageHash, _signature);
        require(signer == owner2, "BHXManage: Signer is not owner2");
         
        require(signHash[messageHash] == false, "BHXManage: MessageHash is used");
         
        signHash[messageHash] = true;
         
        require(msg.value == _feeValue, "BHXManage: Value unequal fee value");

         
        TransferHelper.safeTransfer(usdt, _to, _value);
         
        TransferHelper.safeTransferETH(feeAddress, _feeValue);
        emit UsdtRed(_to, _value);
    }

     
    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

     
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function() payable external {}

}