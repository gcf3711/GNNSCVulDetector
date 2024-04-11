
 

 

 


pragma solidity ^0.6.12;

 
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


 

pragma solidity ^0.6.12;

 
interface IMaintainersRegistry {
    function isMaintainer(address _address) external view returns (bool);
}


 


pragma solidity ^0.6.12;

 
contract HordUpgradable {

    address public hordCongress;
    IMaintainersRegistry public maintainersRegistry;

     
    modifier onlyMaintainer {
        require(maintainersRegistry.isMaintainer(msg.sender), "HordUpgradable: Restricted only to Maintainer");
        _;
    }

     
    modifier onlyHordCongress {
        require(msg.sender == hordCongress, "HordUpgradable: Restricted only to HordCongress");
        _;
    }

    function setCongressAndMaintainers(
        address _hordCongress,
        address _maintainersRegistry
    )
    internal
    {
        hordCongress = _hordCongress;
        maintainersRegistry = IMaintainersRegistry(_maintainersRegistry);
    }

    function setMaintainersRegistry(
        address _maintainersRegistry
    )
    public
    onlyHordCongress
    {
        maintainersRegistry = IMaintainersRegistry(_maintainersRegistry);
    }
}


 


pragma solidity >=0.6.0 <0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


 


pragma solidity >=0.6.2 <0.8.0;

 
interface IERC1155 is IERC165 {
     
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

     
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

     
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

     
    event URI(string value, uint256 indexed id);

     
    function balanceOf(address account, uint256 id) external view returns (uint256);

     
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

     
    function setApprovalForAll(address operator, bool approved) external;

     
    function isApprovedForAll(address account, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

     
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}


 

pragma solidity ^0.6.12;

 
interface IHordTicketFactory is IERC1155 {
    function getTokenSupply(uint tokenId) external view returns (uint256);
}


 


pragma solidity >=0.6.0 <0.8.0;

 
interface IERC165Upgradeable {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


 


pragma solidity >=0.6.0 <0.8.0;

 
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

     
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

     
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}


 


pragma solidity >=0.6.2 <0.8.0;

 
library AddressUpgradeable {
     
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


 


 
pragma solidity >=0.4.24 <0.8.0;

 
abstract contract Initializable {

     
    bool private _initialized;

     
    bool private _initializing;

     
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


 


pragma solidity >=0.6.0 <0.8.0;


 
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
         
         
        _registerInterface(_INTERFACE_ID_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}


 


pragma solidity >=0.6.0 <0.8.0;



 
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal initializer {
        _registerInterface(
            ERC1155ReceiverUpgradeable(address(0)).onERC1155Received.selector ^
            ERC1155ReceiverUpgradeable(address(0)).onERC1155BatchReceived.selector
        );
    }
    uint256[50] private __gap;
}


 


pragma solidity >=0.6.0 <0.8.0;


 
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal initializer {
    }
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
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


 

pragma solidity 0.6.12;





 
contract HordTicketManager is HordUpgradable, ERC1155HolderUpgradeable {
    using SafeMath for *;
     
    uint256 public minTimeToStake;
     
    uint256 public minAmountToStake;
     
    IERC20 public stakingToken;
     
    IHordTicketFactory public hordTicketFactory;
     
    mapping (uint256 => uint256[]) internal championIdToMintedTokensIds;

     
    struct UserStake {
        uint256 amountStaked;
        uint256 amountOfTicketsGetting;
        uint256 unlockingTime;
        bool isWithdrawn;
    }

    
    mapping(address => mapping(uint => UserStake[])) public addressToTokenIdToStakes;

     
    mapping(uint256 => uint256) internal tokenIdToNumberOfTicketsReserved;

    event TokensStaked(
        address user,
        uint amountStaked,
        uint inFavorOfTokenId,
        uint numberOfTicketsReserved,
        uint unlockingTime
    );

    event NFTsClaimed(
        address beneficiary,
        uint256 amountUnstaked,
        uint256 amountTicketsClaimed,
        uint tokenId
    );

    function initialize(
        address _hordCongress,
        address _maintainersRegistry,
        address _stakingToken,
        uint256 _minTimeToStake,
        uint256 _minAmountToStake
    )
    public
    initializer
    {
         
        setCongressAndMaintainers(_hordCongress, _maintainersRegistry);
         
        stakingToken = IERC20(_stakingToken);
         
        minTimeToStake = _minTimeToStake;
         
        minAmountToStake = _minAmountToStake;
    }

     
    function setHordTicketFactory(address _hordTicketFactory) public {
         
        if(address(hordTicketFactory) != address(0)) {
            require(msg.sender == hordCongress);
        }
         
        hordTicketFactory = IHordTicketFactory(_hordTicketFactory);
    }

     
    function setMinTimeToStake(
        uint256 _minimalTimeToStake
    )
    onlyHordCongress
    external
    {
        minTimeToStake = _minimalTimeToStake;
    }

     
    function setMinAmountToStake(
        uint256 _minimalAmountToStake
    )
    onlyHordCongress
    external
    {
        minAmountToStake = _minimalAmountToStake;
    }

     
    function addNewTokenIdForChampion(
        uint tokenId,
        uint championId
    )
    external
    {
        require(msg.sender == address(hordTicketFactory), "Only Hord Ticket factory can issue a call to this function");
         
        championIdToMintedTokensIds[championId].push(tokenId);
    }

     
    function stakeAndReserveNFTs(
        uint tokenId,
        uint numberOfTickets
    )
    public
    {
         
        uint256 numberOfTicketsReserved = tokenIdToNumberOfTicketsReserved[tokenId];
         
        require(numberOfTicketsReserved.add(numberOfTickets)<= hordTicketFactory.getTokenSupply(tokenId),
            "Not enough tickets to sell.");

         
        uint amountOfTokensToStake = minAmountToStake.mul(numberOfTickets);

         
        stakingToken.transferFrom(
            msg.sender,
            address(this),
            amountOfTokensToStake
        );

        UserStake memory userStake = UserStake({
            amountStaked: amountOfTokensToStake,
            amountOfTicketsGetting: numberOfTickets,
            unlockingTime: minTimeToStake.add(block.timestamp),
            isWithdrawn: false
        });

        addressToTokenIdToStakes[msg.sender][tokenId].push(userStake);

         
        tokenIdToNumberOfTicketsReserved[tokenId] = numberOfTicketsReserved.add(numberOfTickets);

        emit TokensStaked(
            msg.sender,
            amountOfTokensToStake,
            tokenId,
            numberOfTickets,
            userStake.unlockingTime
        );
    }

     
    function claimNFTs(
        uint tokenId,
        uint startIndex,
        uint endIndex
    )
    public
    {
        UserStake [] storage userStakesForNft = addressToTokenIdToStakes[msg.sender][tokenId];

        uint256 totalStakeToWithdraw;
        uint256 ticketsToWithdraw;

        uint256 i = startIndex;
        while (i < userStakesForNft.length && i < endIndex) {
            UserStake storage stake = userStakesForNft[i];

            if(stake.isWithdrawn || stake.unlockingTime > block.timestamp) {
                i++;
                continue;
            }

            totalStakeToWithdraw = totalStakeToWithdraw.add(stake.amountStaked);
            ticketsToWithdraw = ticketsToWithdraw.add(stake.amountOfTicketsGetting);

            stake.isWithdrawn = true;
            i++;
        }

        if(totalStakeToWithdraw > 0 && ticketsToWithdraw > 0) {

             
            stakingToken.transfer(msg.sender, totalStakeToWithdraw);

             
            hordTicketFactory.safeTransferFrom(
                address(this),
                msg.sender,
                tokenId,
                ticketsToWithdraw,
                "0x0"
            );

             
            emit NFTsClaimed(
                msg.sender,
                totalStakeToWithdraw,
                ticketsToWithdraw,
                tokenId
            );
        }
    }

     
    function getAmountOfTokensClaimed(uint tokenId)
    external
    view
    returns (uint256)
    {
        uint mintedSupply = hordTicketFactory.getTokenSupply(tokenId);
        return mintedSupply.sub(hordTicketFactory.balanceOf(address(this), tokenId));
    }

     
    function getAmountOfTicketsReserved(
        uint tokenId
    )
    external
    view
    returns (uint256)
    {
        return tokenIdToNumberOfTicketsReserved[tokenId];
    }

     
    function getUserStakesForTokenId(
        address account,
        uint tokenId
    )
    external
    view
    returns (
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        bool[] memory
    )
    {
        UserStake [] memory userStakes = addressToTokenIdToStakes[account][tokenId];

        uint numberOfStakes = userStakes.length;

        uint256[] memory amountsStaked = new uint256[](numberOfStakes);
        uint256[] memory ticketsBought = new uint256[](numberOfStakes);
        uint256[] memory unlockingTimes = new uint256[](numberOfStakes);
        bool[] memory isWithdrawn = new bool[](numberOfStakes);

        for(uint i = 0; i < numberOfStakes; i++) {
             
            amountsStaked[i] = userStakes[i].amountStaked;
            ticketsBought[i] = userStakes[i].amountOfTicketsGetting;
            unlockingTimes[i] = userStakes[i].unlockingTime;
            isWithdrawn[i] = userStakes[i].isWithdrawn;
        }

        return (amountsStaked, ticketsBought, unlockingTimes, isWithdrawn);
    }

     
    function getCurrentAmountStakedForTokenId(
        address account,
        uint tokenId
    )
    external
    view
    returns (uint256)
    {
        UserStake [] memory userStakes = addressToTokenIdToStakes[account][tokenId];

        uint numberOfStakes = userStakes.length;
        uint amountCurrentlyStaking = 0;

        for(uint i = 0; i < numberOfStakes; i++) {
            if(userStakes[i].isWithdrawn == false) {
                amountCurrentlyStaking = amountCurrentlyStaking.add(userStakes[i].amountStaked);
            }
        }

        return amountCurrentlyStaking;
    }

     
    function getChampionTokenIds(
        uint championId
    )
    external
    view
    returns (uint[] memory)
    {
        return championIdToMintedTokensIds[championId];
    }

     
    function getNumberOfStakesForUserAndToken(
        address user,
        uint tokenId
    )
    external
    view
    returns (uint256)
    {
        return addressToTokenIdToStakes[user][tokenId].length;
    }
}