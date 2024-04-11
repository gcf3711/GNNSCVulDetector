 


 

 
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


 
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
    uint256[50] private __gap;
}

 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity >=0.6.0 <0.8.0;



 
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract ReentrancyGuardUpgradeable is Initializable {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}
 

pragma solidity 0.6.12;












interface IPiAddressRegistry {
    function auction() external view returns (address);

    function marketplace() external view returns (address);

    function tokenRegistry() external view returns (address);
}

interface IPiMarketplace {
    function validateItemSold(
        address,
        uint256,
        address,
        address
    ) external;

    function getPrice(address) external view returns (int256);
}

interface IPiTokenRegistry {
    function enabled(address) external returns (bool);
}

contract PiBundleMarketplace is
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;
    using AddressUpgradeable for address payable;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    
    event ItemListed(
        address indexed owner,
        string bundleID,
        address payToken,
        uint256 price,
        uint256 startingTime
    );
    event ItemSold(
        address indexed seller,
        address indexed buyer,
        string bundleID,
        address payToken,
        int256 unitPrice,
        uint256 price
    );
    event ItemUpdated(
        address indexed owner,
        string bundleID,
        address[] nft,
        uint256[] tokenId,
        uint256[] quantity,
        address payToken,
        uint256 newPrice
    );
    event ItemCanceled(address indexed owner, string bundleID);
    event OfferCreated(
        address indexed creator,
        string bundleID,
        address payToken,
        uint256 price,
        uint256 deadline
    );
    event OfferCanceled(address indexed creator, string bundleID);
    event UpdatePlatformFee(uint256 platformFee);
    event UpdatePlatformFeeRecipient(address payable platformFeeRecipient);

    
    struct Listing {
        address[] nfts;
        uint256[] tokenIds;
        uint256[] quantities;
        address payToken;
        uint256 price;
        uint256 startingTime;
    }

    
    struct Offer {
        IERC20 payToken;
        uint256 price;
        uint256 deadline;
    }

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;

    
    mapping(address => mapping(bytes32 => Listing)) public listings;

    
    mapping(bytes32 => address) public owners;

    mapping(address => mapping(uint256 => EnumerableSet.Bytes32Set)) bundleIdsPerItem;

    mapping(bytes32 => mapping(address => mapping(uint256 => uint256))) nftIndexes;

    mapping(bytes32 => string) bundleIds;

    
    mapping(bytes32 => mapping(address => Offer)) public offers;

    
    uint256 public platformFee;

    
    address payable public feeReceipient;

    
    IPiAddressRegistry public addressRegistry;

    modifier onlyContract() {
        require(
            addressRegistry.auction() == _msgSender() ||
                addressRegistry.marketplace() == _msgSender(),
            "sender must be auction or marketplace"
        );
        _;
    }

    
    function initialize(address payable _feeRecipient, uint256 _platformFee)
        public
        initializer
    {
        platformFee = _platformFee;
        feeReceipient = _feeRecipient;

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    
    
    
    function getListing(address _owner, string memory _bundleID)
        external
        view
        returns (
            address[] memory nfts,
            uint256[] memory tokenIds,
            uint256[] memory quantities,
            uint256 price,
            uint256 startingTime
        )
    {
        bytes32 bundleID = _getBundleID(_bundleID);
        nfts = listings[_owner][bundleID].nfts;
        tokenIds = listings[_owner][bundleID].tokenIds;
        quantities = listings[_owner][bundleID].quantities;
        price = listings[_owner][bundleID].price;
        startingTime = listings[_owner][bundleID].startingTime;
    }

    
    
    
    
    
    
    
    function listItem(
        string memory _bundleID,
        address[] calldata _nftAddresses,
        uint256[] calldata _tokenIds,
        uint256[] calldata _quantities,
        address _payToken,
        uint256 _price,
        uint256 _startingTime
    ) external {
        bytes32 bundleID = _getBundleID(_bundleID);
        bundleIds[bundleID] = _bundleID;
        require(
            _nftAddresses.length == _tokenIds.length &&
                _tokenIds.length == _quantities.length,
            "invalid data"
        );
        require(
            owners[bundleID] == address(0) ||
                (owners[bundleID] == _msgSender() &&
                    listings[_msgSender()][bundleID].price == 0),
            "already listed"
        );

        address tokenRegistry = addressRegistry.tokenRegistry();
        require(
            _payToken == address(0) ||
                (tokenRegistry != address(0) &&
                    IPiTokenRegistry(tokenRegistry).enabled(_payToken)),
            "invalid pay token"
        );

        Listing storage listing = listings[_msgSender()][bundleID];
        delete listing.nfts;
        delete listing.tokenIds;
        delete listing.quantities;
        for (uint256 i; i < _nftAddresses.length; i++) {
            if (_supportsInterface(_nftAddresses[i], INTERFACE_ID_ERC721)) {
                IERC721 nft = IERC721(_nftAddresses[i]);
                _check721Owning(_nftAddresses[i], _tokenIds[i], _msgSender());
                require(
                    nft.isApprovedForAll(_msgSender(), address(this)),
                    "item not approved"
                );

                listing.quantities.push(uint256(1));
            } else if (
                _supportsInterface(_nftAddresses[i], INTERFACE_ID_ERC1155)
            ) {
                IERC1155 nft = IERC1155(_nftAddresses[i]);
                _check1155Owning(
                    _nftAddresses[i],
                    _tokenIds[i],
                    _quantities[i],
                    _msgSender()
                );
                require(
                    nft.isApprovedForAll(_msgSender(), address(this)),
                    "item not approved"
                );

                listing.quantities.push(_quantities[i]);
            } else {
                revert("invalid nft address");
            }
            address _nft = _nftAddresses[i];
            listing.nfts.push(_nft);
            listing.tokenIds.push(_tokenIds[i]);
            bundleIdsPerItem[_nft][_tokenIds[i]].add(bundleID);
            nftIndexes[bundleID][_nft][_tokenIds[i]] = i;
        }

        listing.payToken = _payToken;
        listing.price = _price;
        listing.startingTime = _startingTime;

        owners[bundleID] = _msgSender();

        emit ItemListed(
            _msgSender(),
            _bundleID,
            _payToken,
            _price,
            _startingTime
        );
    }

    
    function cancelListing(string memory _bundleID) external nonReentrant {
        bytes32 bundleID = _getBundleID(_bundleID);
        require(listings[_msgSender()][bundleID].price > 0, "not listed");
        _cancelListing(_msgSender(), _bundleID);
    }

    
    
    
    function updateListing(
        string memory _bundleID,
        address _payToken,
        uint256 _newPrice
    ) external nonReentrant {
        bytes32 bundleID = _getBundleID(_bundleID);
        Listing storage listing = listings[_msgSender()][bundleID];
        require(listing.price > 0, "not listed");

        address tokenRegistry = addressRegistry.tokenRegistry();
        require(
            _payToken == address(0) ||
                (tokenRegistry != address(0) &&
                    IPiTokenRegistry(tokenRegistry).enabled(_payToken)),
            "invalid pay token"
        );

        listing.payToken = _payToken;
        listing.price = _newPrice;
        emit ItemUpdated(
            _msgSender(),
            _bundleID,
            listing.nfts,
            listing.tokenIds,
            listing.quantities,
            _payToken,
            _newPrice
        );
    }

    
    
     

    
    
    function buyItem(string memory _bundleID, address _payToken)
        external
        nonReentrant
    {
        bytes32 bundleID = _getBundleID(_bundleID);
        address owner = owners[bundleID];
        require(owner != address(0), "invalid id");

        Listing memory listing = listings[owner][bundleID];
        require(listing.payToken == _payToken, "invalid pay token");

        _buyItem(_bundleID, _payToken);
    }

    function _buyItem(string memory _bundleID, address _payToken) private {
        bytes32 bundleID = _getBundleID(_bundleID);
        address owner = owners[bundleID];
        Listing memory listing = listings[owner][bundleID];

        require(listing.price > 0, "not listed");
        for (uint256 i; i < listing.nfts.length; i++) {
            if (_supportsInterface(listing.nfts[i], INTERFACE_ID_ERC721)) {
                _check721Owning(listing.nfts[i], listing.tokenIds[i], owner);
            } else if (
                _supportsInterface(listing.nfts[i], INTERFACE_ID_ERC1155)
            ) {
                _check1155Owning(
                    listing.nfts[i],
                    listing.tokenIds[i],
                    listing.quantities[i],
                    owner
                );
            }
        }
        require(_getNow() >= listing.startingTime, "not buyable");

        uint256 price = listing.price;
        uint256 feeAmount = price.mul(platformFee).div(1e3);
        if (_payToken == address(0)) {
            (bool feeTransferSuccess, ) = feeReceipient.call{value: feeAmount}(
                ""
            );
            require(
                feeTransferSuccess,
                "PiMarketplace: Fee transfer failed"
            );
            (bool ownerTransferSuccess, ) = owner.call{
                value: price.sub(feeAmount)
            }("");
            require(
                ownerTransferSuccess,
                "PiMarketplace: Owner transfer failed"
            );
        } else {
            IERC20(_payToken).safeTransferFrom(
                _msgSender(),
                feeReceipient,
                feeAmount
            );
            IERC20(_payToken).safeTransferFrom(
                _msgSender(),
                owner,
                price.sub(feeAmount)
            );
        }

         
        for (uint256 i; i < listing.nfts.length; i++) {
            if (_supportsInterface(listing.nfts[i], INTERFACE_ID_ERC721)) {
                IERC721(listing.nfts[i]).safeTransferFrom(
                    owner,
                    _msgSender(),
                    listing.tokenIds[i]
                );
            } else {
                IERC1155(listing.nfts[i]).safeTransferFrom(
                    owner,
                    _msgSender(),
                    listing.tokenIds[i],
                    listing.quantities[i],
                    bytes("")
                );
            }
            IPiMarketplace(addressRegistry.marketplace()).validateItemSold(
                listing.nfts[i],
                listing.tokenIds[i],
                owner,
                _msgSender()
            );
        }
        delete (listings[owner][bundleID]);
        listing.price = 0;
        listings[_msgSender()][bundleID] = listing;
        owners[bundleID] = _msgSender();
        delete (offers[bundleID][_msgSender()]);

        emit ItemSold(
            owner,
            _msgSender(),
            _bundleID,
            _payToken,
            IPiMarketplace(addressRegistry.marketplace()).getPrice(_payToken),
            price
        );
        emit OfferCanceled(_msgSender(), _bundleID);
    }

    
    
    
    
    
    function createOffer(
        string memory _bundleID,
        IERC20 _payToken,
        uint256 _price,
        uint256 _deadline
    ) external {
        bytes32 bundleID = _getBundleID(_bundleID);
        require(owners[bundleID] != address(0), "invalid id");
        require(_deadline > _getNow(), "invalid expiration");
        require(_price > 0, "invalid price");

        Offer memory offer = offers[bundleID][_msgSender()];
        require(offer.deadline <= _getNow(), "offer exists");

        offers[bundleID][_msgSender()] = Offer(_payToken, _price, _deadline);

        emit OfferCreated(
            _msgSender(),
            _bundleID,
            address(_payToken),
            _price,
            _deadline
        );
    }

    
    
    function cancelOffer(string memory _bundleID) external {
        bytes32 bundleID = _getBundleID(_bundleID);
        Offer memory offer = offers[bundleID][_msgSender()];
        require(offer.deadline > _getNow(), "offer not exists or expired");
        delete (offers[bundleID][_msgSender()]);
        emit OfferCanceled(_msgSender(), _bundleID);
    }

    
    function acceptOffer(string memory _bundleID, address _creator)
        external
        nonReentrant
    {
        bytes32 bundleID = _getBundleID(_bundleID);
        require(owners[bundleID] == _msgSender(), "not owning item");

        Offer memory offer = offers[bundleID][_creator];
        require(offer.deadline > _getNow(), "offer not exists or expired");

        uint256 price = offer.price;
        uint256 feeAmount = price.mul(platformFee).div(1e3);

        offer.payToken.safeTransferFrom(_creator, feeReceipient, feeAmount);
        offer.payToken.safeTransferFrom(
            _creator,
            _msgSender(),
            price.sub(feeAmount)
        );

         
        Listing memory listing = listings[_msgSender()][bundleID];
        for (uint256 i; i < listing.nfts.length; i++) {
            if (_supportsInterface(listing.nfts[i], INTERFACE_ID_ERC721)) {
                IERC721(listing.nfts[i]).safeTransferFrom(
                    _msgSender(),
                    _creator,
                    listing.tokenIds[i]
                );
            } else {
                IERC1155(listing.nfts[i]).safeTransferFrom(
                    _msgSender(),
                    _creator,
                    listing.tokenIds[i],
                    listing.quantities[i],
                    bytes("")
                );
            }
            IPiMarketplace(addressRegistry.marketplace()).validateItemSold(
                listing.nfts[i],
                listing.tokenIds[i],
                owners[bundleID],
                _creator
            );
        }
        delete (listings[_msgSender()][bundleID]);
        listing.price = 0;
        listings[_creator][bundleID] = listing;
        owners[bundleID] = _creator;
        delete (offers[bundleID][_creator]);

        emit ItemSold(
            _msgSender(),
            _creator,
            _bundleID,
            address(offer.payToken),
            IPiMarketplace(addressRegistry.marketplace()).getPrice(address(offer.payToken)),
            offer.price
        );
        emit OfferCanceled(_creator, _bundleID);
    }

     
    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
        emit UpdatePlatformFee(_platformFee);
    }

     
    function updatePlatformFeeRecipient(address payable _platformFeeRecipient)
        external
        onlyOwner
    {
        feeReceipient = _platformFeeRecipient;
        emit UpdatePlatformFeeRecipient(_platformFeeRecipient);
    }

     
    function updateAddressRegistry(address _registry) external onlyOwner {
        addressRegistry = IPiAddressRegistry(_registry);
    }

     
    function validateItemSold(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _quantity
    ) external onlyContract {
        uint256 length = bundleIdsPerItem[_nftAddress][_tokenId].length();
        for (uint256 i; i < length; i++) {
            bytes32 bundleID = bundleIdsPerItem[_nftAddress][_tokenId].at(i);
            address _owner = owners[bundleID];
            if (_owner != address(0)) {
                Listing storage listing = listings[_owner][bundleID];
                string memory _bundleID = bundleIds[bundleID];
                uint256 index = nftIndexes[bundleID][_nftAddress][_tokenId];
                if (listing.quantities[index] > _quantity) {
                    listing.quantities[index] = listing.quantities[index].sub(
                        _quantity
                    );
                } else {
                    delete (nftIndexes[bundleID][_nftAddress][_tokenId]);
                    if (listing.nfts.length == 1) {
                        delete (listings[_owner][bundleID]);
                        delete (owners[bundleID]);
                        delete (bundleIds[bundleID]);
                        emit ItemUpdated(
                            _owner,
                            _bundleID,
                            new address[](0),
                            new uint256[](0),
                            new uint256[](0),
                            address(0),
                            0
                        );
                        continue;
                    } else {
                        if (index < listing.nfts.length - 1) {
                            listing.nfts[index] = listing.nfts[
                                listing.nfts.length - 1
                            ];
                            listing.tokenIds[index] = listing.tokenIds[
                                listing.tokenIds.length - 1
                            ];
                            listing.quantities[index] = listing.quantities[
                                listing.quantities.length - 1
                            ];
                            nftIndexes[bundleID][listing.nfts[index]][
                                listing.tokenIds[index]
                            ] = index;
                        }
                        listing.nfts.pop();
                        listing.tokenIds.pop();
                        listing.quantities.pop();
                    }
                }

                emit ItemUpdated(
                    _owner,
                    _bundleID,
                    listing.nfts,
                    listing.tokenIds,
                    listing.quantities,
                    listing.payToken,
                    listing.price
                );
            }
        }

        delete (bundleIdsPerItem[_nftAddress][_tokenId]);
    }

     
     
     
    function _supportsInterface(address _addr, bytes4 iface)
        internal
        view
        returns (bool)
    {
        return IERC165(_addr).supportsInterface(iface);
    }

    function _check721Owning(
        address _nft,
        uint256 _tokenId,
        address _owner
    ) internal view {
        require(IERC721(_nft).ownerOf(_tokenId) == _owner, "not owning item");
    }

    function _check1155Owning(
        address _nft,
        uint256 _tokenId,
        uint256 _quantity,
        address _owner
    ) internal view {
        require(
            IERC1155(_nft).balanceOf(_owner, _tokenId) >= _quantity,
            "not owning item"
        );
    }

    function _getNow() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    function _cancelListing(address _owner, string memory _bundleID) private {
        bytes32 bundleID = _getBundleID(_bundleID);
        Listing memory listing = listings[_owner][bundleID];
        for (uint256 i; i < listing.nfts.length; i++) {
            bundleIdsPerItem[listing.nfts[i]][listing.tokenIds[i]].remove(
                bundleID
            );
            delete (nftIndexes[bundleID][listing.nfts[i]][listing.tokenIds[i]]);
        }
        delete (listings[_owner][bundleID]);
        delete (owners[bundleID]);
        delete (bundleIds[bundleID]);
        emit ItemCanceled(_owner, _bundleID);
    }

    function _getBundleID(string memory _bundleID)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_bundleID));
    }
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

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

     
    function transferFrom(address from, address to, uint256 tokenId) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
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

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct Bytes32Set {
        Set _inner;
    }

     
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

     
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

     
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

     
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
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
