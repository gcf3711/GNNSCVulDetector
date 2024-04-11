 


 

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





contract FeeManager is Ownable {
    using SafeMath for uint256;

    
    struct FactoryFeeInfo {
        bool isFeeDistributor;
        address feeToken;
        uint256 feeAmount;
        uint256 totalFeesAcquired;
    }

    mapping(address => FactoryFeeInfo) public factoryFeeInfos;

    address payable public feeBeneficiary;

    event FeesUpdated(
        address indexed factoryAddress,
        uint256 indexed feeAmount,
        address indexed feeToken
    );

    event FetchedFees(
        address indexed factoryAddress,
        uint256 indexed feeAmount,
        address indexed feeToken
    );

    constructor(address payable _beneficiary) {
        feeBeneficiary = _beneficiary;
    }

     
    function fetchFees() external payable returns (uint256 fetchedFees) {
        fetchedFees = _fetchFees(false, 0);
    }

     
    function _fetchFees(bool _exactFees, uint256 _feeAmount)
        private
        returns (uint256 fetchedFees)
    {
        FactoryFeeInfo storage feeInfo = factoryFeeInfos[msg.sender];
        require(feeInfo.isFeeDistributor, "Invalid Fee Distributor");

        fetchedFees = _exactFees ? _feeAmount : feeInfo.feeAmount;

        if (feeInfo.feeToken == address(0)) {
            require(msg.value == fetchedFees, "Invalid Fee Amount");
        } else {
            TransferHelper.safeTransferFrom(
                feeInfo.feeToken,
                msg.sender,
                address(this),
                fetchedFees
            );
        }
        feeInfo.totalFeesAcquired = feeInfo.totalFeesAcquired.add(fetchedFees);

        emit FetchedFees(msg.sender, fetchedFees, feeInfo.feeToken);
    }

     
    function fetchExactFees(uint256 _feeAmount)
        external
        payable
        returns (uint256 fetchedFees)
    {
        fetchedFees = _fetchFees(true, _feeAmount);
    }

     
    function updateFactoryFeesInfo(
        address _factory,
        uint256 _feeAmount,
        address _feeToken
    ) external onlyOwner {
        require(_factory != address(0), "Factory cant be zero address");
        FactoryFeeInfo storage feeInfo = factoryFeeInfos[_factory];
        feeInfo.feeAmount = _feeAmount;
        feeInfo.feeToken = _feeToken;
        feeInfo.isFeeDistributor = true;
        emit FeesUpdated(_factory, _feeAmount, _feeToken);
    }

    function setFeeBeneficiary(address payable _beneficiary)
        external
        onlyOwner
    {
        require(_beneficiary != address(0), "Beneficiary cant be zero address");
        feeBeneficiary = _beneficiary;
    }

    function withdrawAcquiredFees(address _token, uint256 _amount)
        external
        onlyOwner
    {
        if (_token == address(0)) {
            TransferHelper.safeTransferETH(feeBeneficiary, _amount);
        } else {
            TransferHelper.safeTransfer(_token, feeBeneficiary, _amount);
        }
    }

    function getFactoryFeeInfo(address _factory)
        external
        view
        returns (uint256 _feeAmount, address _feeToken)
    {
        FactoryFeeInfo memory feeInfo = factoryFeeInfos[_factory];
        return (feeInfo.feeAmount, feeInfo.feeToken);
    }
}

 

pragma solidity 0.7.6;

 
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

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH transfer failed');
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
