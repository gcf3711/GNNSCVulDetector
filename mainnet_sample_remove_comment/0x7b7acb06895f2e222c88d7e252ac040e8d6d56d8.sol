 

 

 

pragma solidity ^0.8.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _setOwner(_msgSender());
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IVersion {
     
    function version() external pure returns (string memory);
}

contract FlexPaymentDivider is Ownable, IVersion {
    using Address for address payable;

    uint256 private _recipientCount;
    mapping(uint256 => address payable) private _recipientsById;
    mapping(address => uint256) private _percentagesByRecipient;
    mapping(address => uint256) private _balancesByRecipient;
    mapping(address => uint256) private _changeByRecipient;
    mapping(address => bool) private _isWithdrawingByAccount;

     
    constructor(
        address payable[] memory recipients_,
        uint256[] memory percentages_
    ) {
        _setupRecipients(recipients_, percentages_);
    }

    function version() external pure override returns (string memory) {
        return "1.1.0";
    }

     
    function recipientCount() external view returns (uint256) {
        return _recipientCount;
    }

     
    function recipientById(uint256 id) external view returns (address) {
        return _recipientsById[id];
    }

     
    function percentage(address recipient) external view returns (uint256) {
        return _percentagesByRecipient[recipient];
    }

     
    function accumulatedBalance(address recipient) external view returns (uint256) {
        return _balancesByRecipient[recipient];
    }

     
    function accumulatedChange(address recipient) external view returns (uint256) {
        return _changeByRecipient[recipient];
    }

     
    function deposit() public payable onlyOwner {
        require(
            msg.value > 0,
            "FlexPaymentDivider: Insufficient message value"
        );
        for (uint256 i = 0; i < _recipientCount; i++) {
            address payable recipient = _recipientsById[i];
            uint256 change = (msg.value * _percentagesByRecipient[recipient]) % 100;
            uint256 amount = (msg.value * _percentagesByRecipient[recipient]) / 100;
            uint256 totalChange = _changeByRecipient[recipient] + change;
            _changeByRecipient[recipient] = totalChange;
            if (totalChange >= 100) {
                _changeByRecipient[recipient] = totalChange % 100;
                amount += (totalChange / 100);
            }
            _balancesByRecipient[recipient] += amount;
        }
    }

     
    function disperse() external onlyOwner {
        for (uint256 i = 0; i < _recipientCount; i++) {
            address payable recipient = _recipientsById[i];
            withdraw(recipient);
        }
    }

     
    function withdraw(address payable recipient) public {
        require(
            !isWithdrawing(_msgSender()),
            "FlexPaymentDivider: Can not reenter"
        );
        _isWithdrawingByAccount[_msgSender()] = true;

        uint256 amount = _balancesByRecipient[recipient];
         
         
        if (amount > 0) {
            _balancesByRecipient[recipient] = 0;
            recipient.sendValue(amount);
        }

        _isWithdrawingByAccount[_msgSender()] = false;
    }

     

     
    function _setupRecipients(
        address payable[] memory recipients_,
        uint256[] memory percentages_
    ) internal {
        require(
            recipients_.length == percentages_.length,
            "FlexPaymentDivider: Unequal input lengths"
        );
        uint256 sum = 0;
        for (uint256 i = 0; i < recipients_.length; i++) {
            require(
                percentages_[i] > 0,
                "FlexPaymentDivider: Percentage must exceed 0"
            );
            require(
                percentages_[i] <= 100,
                "FlexPaymentDivider: Percentage must not exceed 100"
            );
            sum += percentages_[i];
            _recipientCount += 1;
            _recipientsById[i] = recipients_[i];
            _percentagesByRecipient[_recipientsById[i]] = percentages_[i];
        }
        require(sum == 100, "FlexPaymentDivider: Percentages must sum to 100");
    }

    function isWithdrawing(address account) internal view returns (bool) {
        return _isWithdrawingByAccount[account];
    }
}

 
contract PupperNFTRoyaltyReceiver is Ownable {
    using Address for address payable;

    FlexPaymentDivider private immutable _paymentHandler;

    event Received(uint256 indexed amount);

    constructor(
        address payable[] memory payoutAccounts_,
        uint256[] memory payoutPercentages_
    ) {
        _paymentHandler = new FlexPaymentDivider(payoutAccounts_, payoutPercentages_);
    }

    receive() external payable {
        emit Received(msg.value);
    }

    function getPaymentHandler() external view returns (address) {
        return address(_paymentHandler);
    }

    function transfer(bool safeMode) external onlyOwner {
        require(address(this).balance > 0, "HotWallet: No funds to transfer");
        uint256 value = address(this).balance;
        if (safeMode) {
            _depositAsPull(value);
        } else {
            _depositAsPush(value);
        }
    }

    function _depositAsPull(uint256 value) private {
        _paymentHandler.deposit{value: value}();
    }

    function _depositAsPush(uint256 value) private {
        _paymentHandler.deposit{value: value}();
        _paymentHandler.disperse();
    }
}