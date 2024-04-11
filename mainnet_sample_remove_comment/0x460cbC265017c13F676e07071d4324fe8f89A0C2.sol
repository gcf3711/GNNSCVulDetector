 


 

pragma solidity ^0.8.0;

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

pragma solidity =0.8.7;





interface IAuction {
    struct Bounty {
        address token;
        uint256 amount;
        bool active;
    }

    function startAuction() external;
    function bondForRebalance() external;
    function settleAuctionWithBond(
        uint256[] calldata,
        address[] calldata,
        uint256[] calldata,
        address[] calldata,
        uint256[] calldata
    ) external;
    function settleAuctionWithoutBond(
        uint256[] calldata,
        address[] calldata,
        uint256[] calldata,
        address[] calldata,
        uint256[] calldata
    ) external;
    function bondBurn() external;
    function killAuction() external;
    function endAuction() external;
    function addBounty(IERC20, uint256) external returns (uint256);
    function initialize(address, address) external;
    function initialized() external view returns (bool);
    function calcIbRatio(uint256 blockNum) external view returns (uint256);
    function getCurrentNewIbRatio() external view returns(uint256);

    function auctionOngoing() external view returns (bool);
    function auctionStart() external view returns (uint256);
    function hasBonded() external view returns (bool);
    function bondAmount() external view returns (uint256);
    function bondTimestamp() external view returns (uint256);
    function bondBlock() external view returns (uint256);

    function basket() external view returns (IBasket);
    function factory() external view returns (IFactory);
    function auctionBonder() external view returns (address);

    event AuctionStarted();
    event Bonded(address _bonder, uint256 _amount);
    event AuctionSettled(address _settler);
    event BondBurned(address _burned, address _burnee, uint256 _amount);
    event BountyAdded(IERC20 _token, uint256 _amount, uint256 _id);
    event BountyClaimed(address _claimer, address _token, uint256 _amount, uint256 _id);
}
pragma solidity =0.8.7;







contract Auction is IAuction, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 private constant BASE = 1e18;
    uint256 private constant ONE_DAY = 1 days;
    
    bool public override auctionOngoing;
    uint256 public override auctionStart;
    bool public override hasBonded;
    uint256 public override bondAmount;
    uint256 public override bondTimestamp;
    uint256 public override bondBlock;

    IBasket public override basket;
    IFactory public override factory;
    address public override auctionBonder;

    Bounty[] private _bounties;

    bool public override initialized;

    modifier onlyBasket() {
        require(msg.sender == address(basket));
        _;
    }

    function startAuction() onlyBasket public override {
        require(auctionOngoing == false);

        auctionOngoing = true;
        auctionStart = block.number;

        emit AuctionStarted();
    }

    function killAuction() onlyBasket public override {
        auctionOngoing = false;
    }

    function endAuction() public override {
        require(msg.sender == basket.publisher());
        require(auctionOngoing);
        require(!hasBonded);

        auctionOngoing = false;
    }

    function initialize(address basket_, address factory_) public override {
        require(address(factory) == address(0));
        require(!initialized);

        basket = IBasket(basket_);
        factory = IFactory(factory_);
        initialized = true;
    }

    function bondForRebalance() public override {
        require(auctionOngoing);
        require(!hasBonded);

        bondTimestamp = block.timestamp;
        bondBlock = block.number;

        uint256 newRatio = calcIbRatio(bondBlock);
        (,, uint256 minIbRatio) = basket.getPendingWeights();
        require(newRatio >= minIbRatio);

        IERC20 basketToken = IERC20(address(basket));
        bondAmount = basketToken.totalSupply() / factory.bondPercentDiv();
        basketToken.safeTransferFrom(msg.sender, address(this), bondAmount);
        hasBonded = true;
        auctionBonder = msg.sender;

        emit Bonded(msg.sender, bondAmount);
    }

    function calcIbRatio(uint256 blockNum) public view override returns (uint256) {
        uint256 a = factory.auctionMultiplier() * basket.ibRatio();
        uint256 b = (blockNum - auctionStart) * BASE / factory.auctionDecrement();
        uint256 newRatio = a - b;
        return newRatio;
    }

    function getCurrentNewIbRatio() public view override returns(uint256) {
        return calcIbRatio(block.number);
    }

    function settleAuctionWithBond(
        uint256[] memory bountyIDs,
        address[] memory inputTokens,
        uint256[] memory inputAmounts,
        address[] memory outputTokens,
        uint256[] memory outputAmounts
    ) public nonReentrant override {
        require(auctionOngoing);
        require(hasBonded);
        require(bondTimestamp + ONE_DAY > block.timestamp);
        require(msg.sender == auctionBonder);
        require(inputTokens.length == inputAmounts.length);
        require(outputTokens.length == outputAmounts.length);

       uint256 newIbRatio = calcIbRatio(bondBlock);

       _settleAuction(bountyIDs, inputTokens, inputAmounts, outputTokens, outputAmounts, newIbRatio);

        IERC20 basketAsERC20 = IERC20(address(basket));
        basketAsERC20.safeTransfer(msg.sender, bondAmount);
    }
    
    function settleAuctionWithoutBond(
        uint256[] memory bountyIDs,
        address[] memory inputTokens,
        uint256[] memory inputAmounts,
        address[] memory outputTokens,
        uint256[] memory outputAmounts
    ) public nonReentrant override {
        require(auctionOngoing);
        require(!hasBonded);
        require(inputTokens.length == inputAmounts.length);
        require(outputTokens.length == outputAmounts.length);

       uint256 newIbRatio = getCurrentNewIbRatio();

       _settleAuction(bountyIDs, inputTokens, inputAmounts, outputTokens, outputAmounts, newIbRatio);
    }
      function _settleAuction(
        uint256[] memory bountyIDs,
        address[] memory inputTokens,
        uint256[] memory inputAmounts,
        address[] memory outputTokens,
        uint256[] memory outputAmounts,
        uint256 newIbRatio
    ) internal {
        for (uint256 i = 0; i < inputTokens.length; i++) {
            IERC20(inputTokens[i]).safeTransferFrom(msg.sender, address(basket), inputAmounts[i]);
        }

        for (uint256 i = 0; i < outputTokens.length; i++) {
            IERC20(outputTokens[i]).safeTransferFrom(address(basket), msg.sender, outputAmounts[i]);
        }

        (address[] memory pendingTokens, uint256[] memory pendingWeights, uint256 minIbRatio) = basket.getPendingWeights();
        require(newIbRatio >= minIbRatio);
        IERC20 basketAsERC20 = IERC20(address(basket));

        for (uint256 i = 0; i < pendingWeights.length; i++) {
            uint256 tokensNeeded = basketAsERC20.totalSupply() * pendingWeights[i] * newIbRatio / BASE / BASE;
            require(IERC20(pendingTokens[i]).balanceOf(address(basket)) >= tokensNeeded);
        }

        basket.setNewWeights();
        basket.updateIBRatio(newIbRatio);
        auctionOngoing = false;
        hasBonded = false;

        withdrawBounty(bountyIDs);

        emit AuctionSettled(msg.sender);
    }

    function bondBurn() external override {
        require(auctionOngoing);
        require(hasBonded);
        require(bondTimestamp + ONE_DAY <= block.timestamp);

        basket.auctionBurn(bondAmount);
        hasBonded = false;
        auctionOngoing = false;
        basket.deleteNewIndex();

        emit BondBurned(msg.sender, auctionBonder, bondAmount);

        auctionBonder = address(0);
    }

    function addBounty(IERC20 token, uint256 amount) public nonReentrant override returns (uint256) {
         
        _bounties.push(Bounty({
            token: address(token),
            amount: amount,
            active: true
        }));
        token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 id = _bounties.length - 1;
        emit BountyAdded(token, amount, id);
        return id;
    }

    function withdrawBounty(uint256[] memory bountyIds) internal {
         
        for (uint256 i = 0; i < bountyIds.length; i++) {
            Bounty storage bounty = _bounties[bountyIds[i]];
            require(bounty.active);
            bounty.active = false;

            IERC20(bounty.token).safeTransfer(msg.sender, bounty.amount);

            emit BountyClaimed(msg.sender, bounty.token, bounty.amount, bountyIds[i]);
        }
    }
 }

 

pragma solidity ^0.8.0;




 
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity =0.8.7;



interface IFactory {
    struct Proposal {
        uint256 licenseFee;
        string tokenName;
        string tokenSymbol;
        address proposer;
        address[] tokens;
        uint256[] weights;
        address basket;
        uint256 maxSupply;
    }

    struct PendingChange{
        uint256 change;
        uint256 timestamp;
    }


    function proposal(uint256) external view returns (Proposal memory);
    function proposals(uint256[] memory _ids) external view returns (Proposal[] memory); 
    function proposalsLength() external view returns (uint256);
    function minLicenseFee() external view returns (uint256);
    function auctionDecrement() external view returns (uint256);
    function auctionMultiplier() external view returns (uint256);
    function bondPercentDiv() external view returns (uint256);
    function ownerSplit() external view returns (uint256);
    function auctionImpl() external view returns (IAuction);
    function basketImpl() external view returns (IBasket);
    function getProposalWeights(uint256 id) external view returns (address[] memory, uint256[] memory);

    function createBasket(uint256) external returns (IBasket);
    function proposeBasketLicense(uint256, string calldata, string calldata, address[] memory tokens, uint256[] memory weights, uint256) external returns (uint256);
    function setMinLicenseFee(uint256) external;
    function setAuctionDecrement(uint256) external;
    function setAuctionMultiplier(uint256) external;
    function setBondPercentDiv(uint256) external;
    function setOwnerSplit(uint256) external;

    event BasketCreated(address indexed basket, uint256 id);
    event BasketLicenseProposed(address indexed proposer, string tokenName, uint256 indexed id);

    event NewMinLicenseFeeSubmitted(uint256);
    event ChangedMinLicenseFee(uint256);
    event NewAuctionDecrementSubmitted(uint256);
    event ChangedAuctionDecrement(uint256);
    event NewAuctionMultiplierSubmitted(uint256);
    event ChangedAuctionMultipler(uint256);
    event NewBondPercentDivSubmitted(uint256);
    event ChangedBondPercentDiv(uint256);
    event NewOwnerSplitSubmitted(uint256);
    event ChangedOwnerSplit(uint256);
}

pragma solidity =0.8.7;



interface IBasket {
    struct PendingPublisher {
        address publisher;
        uint256 timestamp;
    }

    struct PendingLicenseFee {
        uint256 licenseFee;
        uint256 timestamp;
    }

    struct PendingMaxSupply {
        uint256 maxSupply;
        uint256 timestamp;
    }

    struct PendingWeights {
        address[] tokens;
        uint256[] weights;
        uint256 timestamp;
        bool pending;
        uint256 minIbRatio;
    }

    function initialize(IFactory.Proposal memory, IAuction) external;
    function mint(uint256) external;
    function mintTo(uint256, address) external;
    function burn(uint256) external;
    function changePublisher(address) external;
    function changeLicenseFee(uint256) external;
    function setNewMaxSupply(uint256) external;
    function publishNewIndex(address[] calldata, uint256[] calldata, uint256) external;
    function deleteNewIndex() external;
    function auctionBurn(uint256) external;
    function updateIBRatio(uint256) external returns (uint256);
    function setNewWeights() external;
    function validateWeights(address[] memory, uint256[] memory) external pure;
    function initialized() external view returns (bool);

    function ibRatio() external view returns (uint256);
    function getPendingWeights() external view returns (address[] memory, uint256[] memory, uint256);
    function factory() external view returns (IFactory);
    function auction() external view returns (IAuction);
    function lastFee() external view returns (uint256);
    function publisher() external view returns (address);

    event Minted(address indexed _to, uint256 _amount);
    event Burned(address indexed _from, uint256 _amount);
    event ChangedPublisher(address indexed _newPublisher);
    event ChangedLicenseFee(uint256 _newLicenseFee);
    event NewPublisherSubmitted(address indexed _newPublisher);
    event NewLicenseFeeSubmitted(uint256 _newLicenseFee);
    event NewIndexSubmitted();
    event PublishedNewIndex(address _publisher);
    event DeletedNewIndex(address _sender);
    event WeightsSet();
    event NewIBRatio(uint256);
    event NewMaxSupplySubmitted(uint256 _newMaxSupply);
    event ChangedMaxSupply(uint256 _newMaxSupply);

}

 

pragma solidity ^0.8.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

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