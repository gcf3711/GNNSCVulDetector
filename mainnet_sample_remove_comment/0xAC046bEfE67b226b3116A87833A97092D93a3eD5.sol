 


 

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

 

pragma solidity >=0.6.0 <0.8.0;



 
abstract contract Pausable is Context {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    constructor () internal {
        _paused = false;
    }

     
    function paused() public view virtual returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

     
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

 

pragma solidity ^0.7.6;



contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;
    address[] public whitelistedAddresses;
    bool public hasWhitelisting = false;

    event AddedToWhitelist(address[] accounts);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {
        if (hasWhitelisting) {
            require(isWhitelisted(msg.sender), "Must be in the whitelist");
        }
        _;
    }

    constructor(bool _hasWhitelisting) {
        hasWhitelisting = _hasWhitelisting;
    }

    function add(address[] memory _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            require(whitelist[_addresses[i]] != true);
            whitelist[_addresses[i]] = true;
            whitelistedAddresses.push(_addresses[i]);
        }
        emit AddedToWhitelist(_addresses);
    }

    function remove(address _address, uint256 _index) public onlyOwner {
        require(_address == whitelistedAddresses[_index]);
        whitelist[_address] = false;
        delete whitelistedAddresses[_index];
        emit RemovedFromWhitelist(_address);
    }

    function getWhitelistedAddresses() public view returns (address[] memory) {
        return whitelistedAddresses;
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }
}
 

pragma solidity ^0.7.6;








contract FixedSwap is Pausable, Whitelist {
    using SafeMath for uint256;
    uint256 increment = 0;

    mapping(uint256 => Purchase) public purchases;  
    address[] public buyers;  
    uint256[] public purchaseIds;  
    mapping(address => uint256[]) public myPurchases;  

    IERC20 public erc20;
    bool public isSaleFunded = false;
    uint public decimals = 0;
    bool public unsoldTokensRedeemed = false;
    uint256 public tradeValue;  
    uint256 public startDate;  
    uint256 public endDate;  
    uint256 public individualMinimumAmount = 0;  
    uint256 public individualMaximumAmount = 0;  
    uint256 public minimumRaise = 0;  
    uint256 public tokensAllocated = 0;  
    uint256 public tokensForSale = 0;  
    bool public isTokenSwapAtomic;  
    address payable public feeAddress;  
    uint256 public feePercentage = 1;  
    bool private locked;

    struct Purchase {
        uint256 amount;
        address purchaser;
        uint256 ethAmount;
        uint256 timestamp;
        bool wasFinalized;  
        bool reverted;  
    }

    event PurchaseEvent(
        uint256 indexed purchaseId,
        uint256 amount,
        address indexed purchaser,
        uint256 ethAmount,
        uint256 timestamp,
        bool wasFinalized
    );
    event FundEvent(address indexed funder, uint256 amount, address indexed contractAddress, uint256 timestamp);
    event RedeemTokenEvent(
        uint256 indexed purchaseId,
        uint256 amount,
        address indexed purchaser,
        uint256 ethAmount,
        bool wasFinalized,
        bool reverted
    );

    constructor(
        address _tokenAddress,
        address payable _feeAddress,
        uint256 _tradeValue,
        uint256 _tokensForSale,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _individualMinimumAmount,
        uint256 _individualMaximumAmount,
        bool _isTokenSwapAtomic,
        uint256 _minimumRaise,
        uint256 _feeAmount,
        bool _hasWhitelisting
    ) Whitelist(_hasWhitelisting) {
         
        require(block.timestamp < _endDate, "End Date should be further than current date");
        require(block.timestamp < _startDate, "Start Date should be further than current date");
        require(_startDate < _endDate, "End Date higher than Start Date");
        require(_tokensForSale > 0, "Tokens for Sale should be > 0");
        require(_tokensForSale > _individualMinimumAmount, "Tokens for Sale should be > Individual Minimum Amount");
        require(_individualMaximumAmount >= _individualMinimumAmount, "Individual Maximum Amount should be > Individual Minimum Amount");
        require(_minimumRaise <= _tokensForSale, "Minimum Raise should be < Tokens For Sale");
        require(_feeAmount >= feePercentage, "Fee Percentage has to be >= 1");
        require(_feeAmount <= 99, "Fee Percentage has to be < 100");
        require(_feeAddress != address(0), "Fee Address has to be not ZERO");
        require(_tokenAddress != address(0), "Token Address has to be not ZERO");

        startDate = _startDate;
        endDate = _endDate;
        tokensForSale = _tokensForSale;
        tradeValue = _tradeValue;

        individualMinimumAmount = _individualMinimumAmount;
        individualMaximumAmount = _individualMaximumAmount;
        isTokenSwapAtomic = _isTokenSwapAtomic;

        if (!_isTokenSwapAtomic) {
             
            minimumRaise = _minimumRaise;
        }

        erc20 = IERC20(_tokenAddress);
        decimals = IERC20Detailed(_tokenAddress).decimals();
        feePercentage = _feeAmount;
        feeAddress = _feeAddress;
    }

     
    modifier isNotAtomicSwap() {
        require(!isTokenSwapAtomic, "Has to be non Atomic swap");
        _;
    }

     
    modifier isSaleFinalized() {
        require(hasFinalized(), "Has to be finalized");
        _;
    }

     
    modifier isSaleOpen() {
        require(isOpen(), "Has to be open");
        _;
    }

     
    modifier isSalePreStarted() {
        require(isPreStart(), "Has to be pre-started");
        _;
    }

     
    modifier isFunded() {
        require(isSaleFunded, "Has to be funded");
        _;
    }

     
    modifier blockReentrancy {
        require(!locked, "Reentrancy is blocked");
        locked = true;
        _;
        locked = false;
    } 

     
    function isBuyer(uint256 purchase_id) public view returns (bool) {
        return (msg.sender == purchases[purchase_id].purchaser);
    }

     
    function totalRaiseCost() public view returns (uint256) {
        return (cost(tokensForSale));
    }

    function availableTokens() public view returns (uint256) {
        return erc20.balanceOf(address(this));
    }

    function tokensLeft() public view returns (uint256) {
        return tokensForSale - tokensAllocated;
    }

    function hasMinimumRaise() public view returns (bool) {
        return (minimumRaise != 0);
    }

     
    function minimumRaiseNotAchieved() public view returns (bool) {
        require(cost(tokensAllocated) < cost(minimumRaise), "TotalRaise is bigger than minimum raise amount");
        return true;
    }

     
    function minimumRaiseAchieved() public view returns (bool) {
        if (hasMinimumRaise()) {
            require(cost(tokensAllocated) >= cost(minimumRaise), "TotalRaise is less than minimum raise amount");
        }
        return true;
    }

    function hasFinalized() public view returns (bool) {
        return block.timestamp > endDate;
    }

    function hasStarted() public view returns (bool) {
        return block.timestamp >= startDate;
    }

    function isPreStart() public view returns (bool) {
        return block.timestamp < startDate;
    }

    function isOpen() public view returns (bool) {
        return hasStarted() && !hasFinalized();
    }

    function hasMinimumAmount() public view returns (bool) {
        return (individualMinimumAmount != 0);
    }

    function cost(uint256 _amount) public view returns (uint256) {
        return _amount.mul(tradeValue).div(10**decimals);
    }

    function getPurchase(uint256 _purchase_id)
        external
        view
        returns (
            uint256,
            address,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        Purchase memory purchase = purchases[_purchase_id];
        return (purchase.amount, purchase.purchaser, purchase.ethAmount, purchase.timestamp, purchase.wasFinalized, purchase.reverted);
    }

    function getPurchaseIds() public view returns (uint256[] memory) {
        return purchaseIds;
    }

    function getBuyers() public view returns (address[] memory) {
        return buyers;
    }

    function getMyPurchases(address _address) public view returns (uint256[] memory) {
        return myPurchases[_address];
    }

     
    function fund(uint256 _amount) public isSalePreStarted {
         
        require(availableTokens().add(_amount) <= tokensForSale, "Transferred tokens have to be equal or less than proposed");

         
        TransferHelper.safeTransferFrom(address(erc20), msg.sender, address(this), _amount);
         
        if (availableTokens() == tokensForSale) {
            isSaleFunded = true;
        }
        emit FundEvent(msg.sender, _amount, address(this), block.timestamp);
    }

     
    function swap(uint256 _amount) external payable whenNotPaused isFunded isSaleOpen onlyWhitelisted blockReentrancy {
         
        require(_amount > 0, "Amount has to be positive");

         
        require(_amount <= tokensLeft(), "Amount is less than tokens available");

         
        require(msg.value == cost(_amount), "User swap amount has to equal to cost of token in ETH");

         
        require(_amount >= individualMinimumAmount, "Amount is bigger than minimum amount");

         
        require(_amount <= individualMaximumAmount, "Amount is smaller than maximum amount");

         
        uint256[] memory _purchases = getMyPurchases(msg.sender);
        uint256 purchaserTotalAmountPurchased = 0;
        for (uint i = 0; i < _purchases.length; i++) {
            Purchase memory _purchase = purchases[_purchases[i]];
            purchaserTotalAmountPurchased = purchaserTotalAmountPurchased.add(_purchase.amount);
        }
        require(purchaserTotalAmountPurchased.add(_amount) <= individualMaximumAmount, "Address has already passed the max amount of swap");

        if (isTokenSwapAtomic) {
             
            TransferHelper.safeTransfer(address(erc20), msg.sender, _amount);
        }

        uint256 purchase_id = increment;
        increment = increment.add(1);

         
        Purchase memory purchase =
            Purchase(
                _amount,
                msg.sender,
                msg.value,
                block.timestamp,
                isTokenSwapAtomic,  
                false
            );
        purchases[purchase_id] = purchase;
        purchaseIds.push(purchase_id);
        myPurchases[msg.sender].push(purchase_id);
        buyers.push(msg.sender);
        tokensAllocated = tokensAllocated.add(_amount);
        emit PurchaseEvent(purchase_id, _amount, msg.sender, msg.value, block.timestamp, isTokenSwapAtomic);
    }

     
    function redeemTokens(uint256 purchase_id) external isNotAtomicSwap isSaleFinalized whenNotPaused blockReentrancy {
         
        require((purchases[purchase_id].amount != 0) && !purchases[purchase_id].wasFinalized, "Purchase is either 0 or finalized");
        require(isBuyer(purchase_id), "Address is not buyer");
        purchases[purchase_id].wasFinalized = true;
        TransferHelper.safeTransfer(address(erc20), msg.sender, purchases[purchase_id].amount);
        emit RedeemTokenEvent(purchase_id, purchases[purchase_id].amount, msg.sender, 0, purchases[purchase_id].wasFinalized, false);
    }

     
    function redeemGivenMinimumGoalNotAchieved(uint256 purchase_id) external isSaleFinalized isNotAtomicSwap whenNotPaused blockReentrancy {
        require(hasMinimumRaise(), "Minimum raise has to exist");
        require(minimumRaiseNotAchieved(), "Minimum raise has to be reached");
         
        require((purchases[purchase_id].amount != 0) && !purchases[purchase_id].wasFinalized, "Purchase is either 0 or finalized");
        require(isBuyer(purchase_id), "Address is not buyer");
        purchases[purchase_id].wasFinalized = true;
        purchases[purchase_id].reverted = true;
        msg.sender.transfer(purchases[purchase_id].ethAmount);
        emit RedeemTokenEvent(
            purchase_id,
            0,
            msg.sender,
            purchases[purchase_id].ethAmount,
            purchases[purchase_id].wasFinalized,
            purchases[purchase_id].reverted
        );
    }

     
    function withdrawFunds() external onlyOwner whenNotPaused isSaleFinalized {
        require(minimumRaiseAchieved(), "Minimum raise has to be reached");
        uint256 fee = address(this).balance.mul(feePercentage).div(100);
        feeAddress.transfer(fee);  
        uint256 funds = address(this).balance;
        msg.sender.transfer(funds);
    }

    function withdrawUnsoldTokens() external onlyOwner isSaleFinalized {
        require(!unsoldTokensRedeemed);
        uint256 unsoldTokens;
        if (hasMinimumRaise() && (cost(tokensAllocated) < cost(minimumRaise))) {
             
            unsoldTokens = tokensForSale;
        } else {
             
            unsoldTokens = tokensForSale.sub(tokensAllocated);
        }

        if (unsoldTokens > 0) {
            unsoldTokensRedeemed = true;
            TransferHelper.safeTransfer(address(erc20), msg.sender, unsoldTokens);
        }
    }

    function removeOtherERC20Tokens(address _tokenAddress, address _to) external onlyOwner isSaleFinalized {
        require(_tokenAddress != address(erc20), "Token Address has to be diff than the erc20 subject to sale");  
        IERC20Detailed erc20Token = IERC20Detailed(_tokenAddress);
        TransferHelper.safeTransfer(address(erc20Token), _to, erc20Token.balanceOf(address(this)));
    }

    function pause() external onlyOwner {
        _pause();
    }

     
    function safePull() external payable onlyOwner whenPaused {
        msg.sender.transfer(address(this).balance);
        TransferHelper.safeTransfer(address(erc20), msg.sender, erc20.balanceOf(address(this)));
    }
}

 

pragma solidity ^0.7.6;



interface IERC20Detailed is IERC20 {

    function decimals() external view returns (uint8);

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

 
pragma solidity ^0.7.6;

 
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
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
