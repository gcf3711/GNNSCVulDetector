 


 

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

 
pragma solidity 0.7.6;





contract EthGatewayWithFee is Ownable {
    IERC20 public immutable token;
    IEthGateway public immutable gateway;
    uint256 public fee;

    event TransferredToSmartChain(address from, uint256 amount, uint256 fee);
    event FeeUpdated(uint256 newFee);

    constructor(IERC20 _token, IEthGateway _gateway, uint256 _fee) {
        token = _token;
        gateway = _gateway;
        fee = _fee;
    }

    function transferToSmartChain(uint256 amount) payable public {
         
        require(msg.value == fee, "EthGatewayWithFee: Wrong fee value");
        payable(owner()).transfer(msg.value);

         
        token.transferFrom(msg.sender, address(this), amount);
        token.approve(address(gateway), amount);
        gateway.transferToSmartChain(amount);

         
        emit TransferredToSmartChain(msg.sender, amount, fee);
    }

    function updateFee(uint256 _fee) public onlyOwner {
        fee = _fee;
        emit FeeUpdated(fee);
    }
}

 
pragma solidity 0.7.6;

interface IEthGateway {
    function transferToSmartChain(uint256 amount) external;
}
