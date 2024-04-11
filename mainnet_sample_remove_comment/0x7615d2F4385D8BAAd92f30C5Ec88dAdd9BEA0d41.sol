 


 

pragma solidity ^0.8.4;






interface ICedarDeployerEventsV0 {
    event CedarInterfaceDeployed(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        string interfaceName
    );

     
    event CedarImplementationDeployed(
        address indexed implementationAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        string contractName
    );

    event CedarERC721PremintV0Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address adminAddress,
        string name,
        string symbol,
        uint256 maxLimit,
        string userAgreement,
        string baseURI
    );

    event CedarERC721DropV0Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address defaultAdmin,
        string name,
        string symbol,
        string contractURI,
        address[] trustedForwarders,
        address saleRecipient,
        address royaltyRecipient,
        uint128 royaltyBps,
        string userAgreement,
        address signatureVerifier,
        address greenlistManager
    );
}

 
 
interface ICedarDeployerEventsV1 is ICedarDeployerEventsV0 {
    event CedarERC1155DropV0Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address defaultAdmin,
        string name,
        string symbol,
        string contractURI,
        address[] trustedForwarders,
        address saleRecipient,
        address royaltyRecipient,
        uint128 royaltyBps,
        uint128 platformFeeBps,
        address platformFeeRecipient
    );
}

 
 

pragma solidity ^0.8.0;

 
interface IERC165Upgradeable {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 
 

pragma solidity ^0.8.0;



 
abstract contract Initializable {
     
    bool private _initialized;

     
    bool private _initializing;

     
    modifier initializer() {
         
         
         
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

     
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

 
pragma solidity ^0.8.0;



 

interface IDropClaimConditionV0 {
     
    struct ClaimCondition {
        uint256 startTimestamp;
        uint256 maxClaimableSupply;
        uint256 supplyClaimed;
        uint256 quantityLimitPerTransaction;
        uint256 waitTimeInSecondsBetweenClaims;
        bytes32 merkleRoot;
        uint256 pricePerToken;
        address currency;
    }

     
    struct ClaimConditionList {
        uint256 currentStartId;
        uint256 count;
        mapping(uint256 => ClaimCondition) phases;
        mapping(uint256 => mapping(address => uint256)) limitLastClaimTimestamp;
        mapping(uint256 => BitMapsUpgradeable.BitMap) limitMerkleProofClaim;
    }
}

interface ICedarDeployerEventsV2 is ICedarDeployerEventsV1 {
    event CedarERC721PremintV1Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address adminAddress,
        string name,
        string symbol,
        uint256 maxLimit,
        string userAgreement,
        string baseURI
    );
}

 
 

pragma solidity ^0.8.0;



 
interface IERC721Upgradeable is IERC165Upgradeable {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface ICedarImplementationVersionedV0 {
     
    function implementationVersion()
    external
    view
    returns (
        uint256 major,
        uint256 minor,
        uint256 patch
    );
}

 
pragma solidity ^0.8.4;

 


 

interface ICedarNFTIssuanceV0 is IDropClaimConditionV0 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        address indexed claimer,
        address indexed receiver,
        uint256 startTokenId,
        uint256 quantityClaimed
    );

    
    event ClaimConditionsUpdated(ClaimCondition[] claimConditions);

     
    function setClaimConditions(ClaimCondition[] calldata phases, bool resetClaimEligibility) external;

     
    function claim(
        address receiver,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;
}

 
 

pragma solidity ^0.8.0;


 
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

     
    uint256[50] private __gap;
}

 

pragma solidity ^0.8.4;



interface ICedarMinorVersionedV0 {
    function minorVersion() external view returns (uint256 minor, uint256 patch);
}

 

pragma solidity ^0.8.4;

interface ICedarAgreementV0 {
     
    function acceptTerms() external;

    function userAgreement() external view returns (string memory);

    function termsActivated() external view returns (bool);

    function setTermsStatus(bool _status) external;

    function getAgreementStatus(address _address) external view returns (bool sig);

    function storeTermsAccepted(address _acceptor, bytes calldata _signature) external;
}

interface ICedarDeployerEventsV3 is ICedarDeployerEventsV2 {
    event CedarPaymentSplitterDeployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address[] payees,
        uint256[] shares
    );
}

 

pragma solidity ^0.8.0;



interface ICedarFeaturesV0 is IERC165Upgradeable {
     
    function isICedarFeaturesV0() external pure returns (bool);

     
    function supportedFeatures() external pure returns (string[] memory features);
}

 

pragma solidity ^0.8.4;

 
interface IMulticallableV0 {
    function multicall(bytes[] calldata data) external returns (bytes[] memory results);
}

interface ICedarVersionedV0 is ICedarImplementationVersionedV0, ICedarMinorVersionedV0, IERC165Upgradeable {
}

interface ICedarNFTIssuanceV1 is ICedarNFTIssuanceV0 {
    
    function getActiveClaimConditions() external view returns (ClaimCondition memory condition, uint256 conditionId, uint256 walletMaxClaimCount, uint256 remainingSupply);

    
    function getUserClaimConditions(address _claimer) external view returns (uint256 conditionId, uint256 walletClaimedCount, uint256 lastClaimTimestamp, uint256 nextValidClaimTimestamp);

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface ICedarNFTLazyMintV1 {
    
    event TokensLazyMinted(uint256 startTokenId, uint256 endTokenId, string baseURI);

     
    function lazyMint(
        uint256 amount,
        string calldata baseURIForTokens
    ) external;
}

 

pragma solidity ^0.8.4;



interface IERC721V0 is IERC721Upgradeable {}

 
pragma solidity ^0.8.0;

interface IRoyaltyV0 {
    struct RoyaltyInfo {
        address recipient;
        uint256 bps;
    }

    
    function getDefaultRoyaltyInfo() external view returns (address, uint16);

    
    function setDefaultRoyaltyInfo(address _royaltyRecipient, uint256 _royaltyBps) external;

    
    function setRoyaltyInfoForToken(
        uint256 tokenId,
        address recipient,
        uint256 bps
    ) external;

    
    function getRoyaltyInfoForToken(uint256 tokenId) external view returns (address, uint16);

     
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    
    event DefaultRoyalty(address newRoyaltyRecipient, uint256 newRoyaltyBps);

    
    event RoyaltyForToken(uint256 indexed tokenId, address royaltyRecipient, uint256 royaltyBps);
}

 

pragma solidity ^0.8.4;

interface ICedarUpdateBaseURIV0 {
    
    event BaseURIUpdated(uint256 baseURIIndex, string baseURI);

     
    function updateBaseURI(
        uint256 baseURIIndex, string calldata _baseURIForTokens
    ) external;

     
    function getBaseURIIndices() external view returns(uint256[] memory);
}

 
pragma solidity ^0.8.0;

interface ICedarMetadataV0 {
    
    function contractURI() external view returns (string memory);

     
    function setContractURI(string calldata _uri) external;
}

 
 

pragma solidity ^0.8.0;



 
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

 
 

pragma solidity ^0.8.0;




 
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

     
    uint256[50] private __gap;
}

 
 

pragma solidity ^0.8.0;

 
interface IAccessControlUpgradeable {
     
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

     
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

     
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

     
    function hasRole(bytes32 role, address account) external view returns (bool);

     
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

     
    function grantRole(bytes32 role, address account) external;

     
    function revokeRole(bytes32 role, address account) external;

     
    function renounceRole(bytes32 role, address account) external;
}

interface ICedarNFTMetadataV1 {
    
    function tokenURI(uint256 _tokenId) view external returns (string memory);
}

 
pragma solidity ^0.8.4;



 

interface ICedarSFTIssuanceV0 is IDropClaimConditionV0 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        uint256 indexed tokenId,
        address indexed claimer,
        address receiver,
        uint256 quantityClaimed
    );

    
    event TokensIssued(
        uint256 indexed tokenId,
        address indexed claimer,
        address receiver,
        uint256 quantityClaimed
    );

    
    event ClaimConditionsUpdated(uint256 indexed tokenId, ClaimCondition[] claimConditions);

     
    function setClaimConditions(
        uint256 tokenId,
        ClaimCondition[] calldata phases,
        bool resetClaimEligibility
    ) external;

     
    function claim(
        address receiver,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;

     
    function issue(
        address receiver,
        uint256 tokenId,
        uint256 quantity
    ) external;
}

interface ICedarDeployerEventsV4 is ICedarDeployerEventsV3 {
    event CedarERC721DropV1Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address defaultAdmin,
        string name,
        string symbol,
        string contractURI,
        address[] trustedForwarders,
        address saleRecipient,
        address royaltyRecipient,
        uint128 royaltyBps,
        string userAgreement,
        address signatureVerifier,
        address greenlistManager
    );

    event CedarERC1155DropV1Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address defaultAdmin,
        string name,
        string symbol,
        string contractURI,
        address[] trustedForwarders,
        address saleRecipient,
        address royaltyRecipient,
        uint128 royaltyBps,
        uint128 platformFeeBps,
        address platformFeeRecipient
    );
}

 
 

pragma solidity ^0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 
 

pragma solidity ^0.8.0;










 
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

     
    string private _name;

     
    string private _symbol;

     
    mapping(uint256 => address) private _owners;

     
    mapping(address => uint256) private _balances;

     
    mapping(uint256 => address) private _tokenApprovals;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

     
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

     
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

     
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

     
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

     
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
         
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

     
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

     
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

     
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

     
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

     
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

     
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

     
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

         
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

     
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

         
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

     
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

     
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

     
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

     
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

     
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

     
    uint256[44] private __gap;
}

 
 

pragma solidity ^0.8.0;



 
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
     
    function totalSupply() external view returns (uint256);

     
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

     
    function tokenByIndex(uint256 index) external view returns (uint256);
}

 
 

pragma solidity ^0.8.0;



 
 

pragma solidity ^0.8.0;



 
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
     
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

     
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

 
 

pragma solidity ^0.8.0;







 
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

     
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

     
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

     
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

     
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

     
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

     
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

     
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

     
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

     
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

     
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

     
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

     
    uint256[49] private __gap;
}

interface ICedarERC721DropV3 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    IMulticallableV0,
    ICedarAgreementV0,
    ICedarNFTIssuanceV1,
    ICedarNFTLazyMintV1,
    IERC721V0,
    IRoyaltyV0,
    ICedarUpdateBaseURIV0,
    ICedarNFTMetadataV1,
    ICedarMetadataV0
{}

 
 

pragma solidity ^0.8.0;

 
interface IERC1822ProxiableUpgradeable {
     
    function proxiableUUID() external view returns (bytes32);
}

 
 

pragma solidity ^0.8.2;







 
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
     
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

     
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

     
    event Upgraded(address indexed implementation);

     
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

     
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

     
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

     
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

     
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
         
         
         
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

     
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

     
    event AdminChanged(address previousAdmin, address newAdmin);

     
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

     
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

     
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

     
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

     
    event BeaconUpgraded(address indexed beacon);

     
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

     
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

     
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

     
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

     
    uint256[50] private __gap;
}

 
 

pragma solidity ^0.8.0;



 
interface IERC1155Upgradeable is IERC165Upgradeable {
     
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

     
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

     
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

     
    event URI(string value, uint256 indexed id);

     
    function balanceOf(address account, uint256 id) external view returns (uint256);

     
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

     
    function setApprovalForAll(address operator, bool approved) external;

     
    function isApprovedForAll(address account, address operator) external view returns (bool);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

     
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

 
 

pragma solidity ^0.8.0;



 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _transferOwnership(_msgSender());
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface ICedarDeployerEventsV5 is ICedarDeployerEventsV4 {
    event CedarERC721DropV2Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion
    );
}

 
 
interface ICedarDeployerV0 is ICedarVersionedV0, ICedarDeployerEventsV0 {
    function deployCedarERC721PremintV0(
        address adminAddress,
        string memory _name,
        string memory _symbol,
        uint256 _maxLimit,
        string memory _userAgreement,
        string memory baseURI_
    ) external returns (ICedarERC721PremintV0);

    function deployCedarERC721DropV0(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement
    ) external returns (ICedarERC721DropV0);

    function cedarERC721PremintVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function cedarERC721DropVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );
}

interface ICedarDeployerAddedV1 {
    function deployCedarERC1155DropV0(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external returns (ICedarERC1155DropV0);

    function cedarERC1155DropVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function cedarERC721PremintFeatures() external view returns (string[] memory features);

    function cedarERC721DropFeatures() external view returns (string[] memory features);

    function cedarERC1155DropFeatures() external view returns (string[] memory features);
}

interface ICedarDeployerAddedV2 {
    function deployCedarERC721PremintV1(
        address adminAddress,
        string memory _name,
        string memory _symbol,
        uint256 _maxLimit,
        string memory _userAgreement,
        string memory baseURI_
    ) external returns (ICedarERC721PremintV1);
}

interface ICedarDeployerAddedV3 {
    function deployCedarPaymentSplitterV0(address[] memory payees, uint256[] memory shares_)
        external
        returns (ICedarPaymentSplitterV0);

    function cedarPaymentSplitterVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function cedarPaymentSplitterFeatures() external view returns (string[] memory features);
}

interface ICedarDeployerIntrospectionV0 is ICedarVersionedV0 {
    function cedarERC721PremintVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function cedarERC721DropVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function cedarERC1155DropVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function cedarERC721PremintFeatures() external view returns (string[] memory features);

    function cedarERC721DropFeatures() external view returns (string[] memory features);

    function cedarERC1155DropFeatures() external view returns (string[] memory features);
}

interface ICedarDeployerAddedV4 {
    function deployCedarERC1155DropV1(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external returns (ICedarERC1155DropV1);

    function deployCedarERC721DropV1(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement
    ) external returns (ICedarERC721DropV1);
}

interface ICedarDeployerAddedV5 {
    function deployCedarERC1155DropV1(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external returns (ICedarERC1155DropV1);

    function deployCedarERC721DropV2(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement
    ) external returns (ICedarERC721DropV2);
}

interface ICedarDeployerAddedV7 {
    function deployCedarERC1155DropV1(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external returns (ICedarERC1155DropV1);

    function deployCedarERC721DropV3(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external returns (ICedarERC721DropV3);
}

 
 

pragma solidity ^0.8.0;





 
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
     
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

     
    mapping(uint256 => uint256) private _ownedTokensIndex;

     
    uint256[] private _allTokens;

     
    mapping(uint256 => uint256) private _allTokensIndex;

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

     
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

     
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

     
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

     
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

     
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

     
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
         
         

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

         
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId;  
            _ownedTokensIndex[lastTokenId] = tokenIndex;  
        }

         
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

     
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
         
         

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

         
         
         
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;  
        _allTokensIndex[lastTokenId] = tokenIndex;  

         
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

     
    uint256[46] private __gap;
}

 
 

pragma solidity ^0.8.0;






 
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

     
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

     
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

     
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

     
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

     
    uint256[49] private __gap;
}

 
 

pragma solidity ^0.8.0;


 
abstract contract ReentrancyGuardUpgradeable is Initializable {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

 
 

pragma solidity ^0.8.0;




 
abstract contract MulticallUpgradeable is Initializable {
    function __Multicall_init() internal onlyInitializing {
    }

    function __Multicall_init_unchained() internal onlyInitializing {
    }
     
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = _functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

     
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

     
    uint256[50] private __gap;
}

 
pragma solidity ^0.8.4;

interface IThirdwebContract {
    
    function contractType() external pure returns (bytes32);

    
    function contractVersion() external pure returns (uint8);

    
    function contractURI() external view returns (string memory);

     
    function setContractURI(string calldata _uri) external;
}

 
pragma solidity ^0.8.0;

interface IPlatformFee {
    
    function getPlatformFeeInfo() external view returns (address, uint16);

    
    function setPlatformFeeInfo(address _platformFeeRecipient, uint256 _platformFeeBps) external;

    
    event PlatformFeeInfoUpdated(address platformFeeRecipient, uint256 platformFeeBps);
}

 
pragma solidity ^0.8.0;

interface IPrimarySale {
    
    function primarySaleRecipient() external view returns (address);

    
    function setPrimarySaleRecipient(address _saleRecipient) external;

    
    event PrimarySaleRecipientUpdated(address indexed recipient);
}

 
pragma solidity ^0.8.0;

interface IOwnable {
    
    function owner() external view returns (address);

    
    function setOwner(address _newOwner) external;

    
    event OwnerUpdated(address prevOwner, address newOwner);
}

 
 

pragma solidity ^0.8.4;




 
abstract contract ERC2771ContextUpgradeable is Initializable, ContextUpgradeable {
    mapping(address => bool) private _trustedForwarder;

    function __ERC2771Context_init(address[] memory trustedForwarder) internal onlyInitializing {
        __Context_init_unchained();
        __ERC2771Context_init_unchained(trustedForwarder);
    }

    function __ERC2771Context_init_unchained(address[] memory trustedForwarder) internal onlyInitializing {
        for (uint256 i = 0; i < trustedForwarder.length; i++) {
            _trustedForwarder[trustedForwarder[i]] = true;
        }
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return _trustedForwarder[forwarder];
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
             
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    uint256[49] private __gap;
}

 

 
 

pragma solidity ^0.8.4;



 
abstract contract BaseCedarERC721DropV3 is ICedarERC721DropV3 {
    function supportedFeatures() override public pure returns (string[] memory features) {
        features = new string[](11);
        features[0] = "ICedarFeatures.sol:ICedarFeaturesV0";
        features[1] = "ICedarVersioned.sol:ICedarVersionedV0";
        features[2] = "IMulticallable.sol:IMulticallableV0";
        features[3] = "agreement/ICedarAgreement.sol:ICedarAgreementV0";
        features[4] = "issuance/ICedarNFTIssuance.sol:ICedarNFTIssuanceV1";
        features[5] = "lazymint/ICedarNFTLazyMint.sol:ICedarNFTLazyMintV1";
        features[6] = "standard/IERC721.sol:IERC721V0";
        features[7] = "royalties/IRoyalty.sol:IRoyaltyV0";
        features[8] = "baseURI/ICedarUpdateBaseURI.sol:ICedarUpdateBaseURIV0";
        features[9] = "metadata/ICedarNFTMetadata.sol:ICedarNFTMetadataV1";
        features[10] = "metadata/IContractMetadata.sol:ICedarMetadataV0";
    }

     
    function minorVersion() virtual override public pure returns (uint256 minor, uint256 patch);

    function implementationVersion() override public pure returns (uint256 major, uint256 minor, uint256 patch) {
        (minor, patch) = minorVersion();
        major = 3;
    }

    function supportsInterface(bytes4 interfaceID) virtual override public view returns (bool) {
        return (interfaceID == type(IERC165Upgradeable).interfaceId) || ((interfaceID == type(ICedarFeaturesV0).interfaceId) || ((interfaceID == type(ICedarVersionedV0).interfaceId) || ((interfaceID == type(IMulticallableV0).interfaceId) || ((interfaceID == type(ICedarAgreementV0).interfaceId) || ((interfaceID == type(ICedarNFTIssuanceV1).interfaceId) || ((interfaceID == type(ICedarNFTLazyMintV1).interfaceId) || ((interfaceID == type(IERC721V0).interfaceId) || ((interfaceID == type(IRoyaltyV0).interfaceId) || ((interfaceID == type(ICedarUpdateBaseURIV0).interfaceId) || ((interfaceID == type(ICedarNFTMetadataV1).interfaceId) || (interfaceID == type(ICedarMetadataV0).interfaceId)))))))))));
    }

    function isICedarFeaturesV0() override public pure returns (bool) {
        return true;
    }
}

 

pragma solidity ^0.8.7;





abstract contract Agreement is Initializable, ICedarAgreementV0 {
    string public override userAgreement;
    mapping(address => bool) termsAccepted;
    bool public override termsActivated;
    SignatureVerifier public verifier;
    string public ownerDomain;

    event TermsActive(bool status);
    event AcceptTerms(string userAgreement, address user);

    function __Agreement_init(string memory _userAgreement, address _signatureVerifier) internal onlyInitializing {
        userAgreement = _userAgreement;
        verifier = SignatureVerifier(_signatureVerifier);
    }

    
    
    function _setTermsStatus(bool _status) internal virtual {
        termsActivated = _status;
        emit TermsActive(_status);
    }

    
    
    function acceptTerms() override external {
        require(termsActivated, "ERC721Cedar: terms not activated");
        termsAccepted[msg.sender] = true;
        emit AcceptTerms(userAgreement, msg.sender);
    }

    
    
    function _storeTermsAccepted(address _acceptor, bytes calldata _signature) internal virtual {
        require(termsActivated, "ERC721Cedar: terms not activated");
        require(verifier.verifySignature(_acceptor, _signature), "ERC721Cedar: signature cannot be verified");
        termsAccepted[_acceptor] = true;
        emit AcceptTerms(userAgreement, _acceptor);
    }

    
    
    function checkSignature(address _account, bytes calldata _signature) external view returns (bool) {
        return verifier.verifySignature(_account, _signature);
    }

    
    
    function getAgreementStatus(address _address) external override view returns (bool sig) {
        return termsAccepted[_address];
    }

    function _setOwnerDomain(string calldata _ownerDomain) internal virtual {
        ownerDomain = _ownerDomain;
    }
}

 

pragma solidity ^0.8.4;





contract Greenlist {
    using Address for address;
    bool greenlistStatus;

    GreenlistManager greenlistManager;

    event GreenlistStatus(bool _status);

    function __Greenlist_init(address _greenlistManagerAddress) internal {
        greenlistManager = GreenlistManager(_greenlistManagerAddress);
    }

    
    
    function _setGreenlistStatus(bool _status) internal {
        greenlistStatus = _status;
        emit GreenlistStatus(_status);
    }

    
    
    function isGreenlistOn() public view returns (bool) {
        return greenlistStatus;
    }

    
    function checkGreenlist(address _operator) internal view {
        if (Address.isContract(_operator) && isGreenlistOn()) {
            require(greenlistManager.isGreenlisted(_operator), "ERC721Cedar: operator is not greenlisted");
        }
    }
}

 

pragma solidity ^0.8.4;

interface ICedarNFTLazyMintV0 {
    
    event TokensLazyMinted(uint256 startTokenId, uint256 endTokenId, string baseURI, bytes encryptedBaseURI);

     
    function lazyMint(
        uint256 amount,
        string calldata baseURIForTokens,
        bytes calldata encryptedBaseURI
    ) external;
} 

 
pragma solidity ^0.8.0;

interface ICedarNFTMetadataV0 {
    
    function tokenURI(uint256 _tokenId) external returns (string memory);
}

 
 

pragma solidity ^0.8.0;



 
abstract contract EIP712 {
     
     
     
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

     

     
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

     
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

     
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

 
 

pragma solidity ^0.8.0;




 
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

     
    uint256[49] private __gap;
}

 
 

pragma solidity ^0.8.0;





 
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    
    address private immutable __self = address(this);

     
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

     
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

     
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

     
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

     
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

     
    function _authorizeUpgrade(address newImplementation) internal virtual;

     
    uint256[50] private __gap;
}

 

pragma solidity ^0.8.4;

 
interface ICedarPremintV0 {
    struct TransferRequest {
        address to;
        uint256 tokenId;
    }

    function mintBatch(uint256 _quantity, address _to) external;

    function transferFromBatch(TransferRequest[] calldata transferRequests) external;
}

 

pragma solidity ^0.8.4;

interface ICedarUpgradeBaseURIV0 {
     
    function upgradeBaseURI(string calldata baseURI_) external;
}

interface ICedarSFTIssuanceV1 is ICedarSFTIssuanceV0 {
    
    function getActiveClaimConditions(uint256 _tokenId) external view returns (ClaimCondition memory condition, uint256 conditionId, uint256 walletMaxClaimCount, uint256 remainingSupply);

    
    function getUserClaimConditions(uint256 _tokenId, address _claimer) external view returns (uint256 conditionId, uint256 walletClaimedCount, uint256 lastClaimTimestamp, uint256 nextValidClaimTimestamp);

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

 

pragma solidity ^0.8.4;

interface ICedarSFTLazyMintV0 {
    
    event TokensLazyMinted(uint256 startTokenId, uint256 endTokenId, string baseURI);
    
     
    function lazyMint(uint256 amount, string calldata baseURIForTokens) external;
}

 

pragma solidity ^0.8.4;



interface IERC1155V0 is IERC1155Upgradeable {}

 

pragma solidity ^0.8.4;



interface ICedarSplitPaymentV0 {
    function getTotalReleased() external view returns (uint256);
    function getTotalReleased(IERC20Upgradeable token) external view returns (uint256);
    function getReleased(address account) external view returns (uint256);
    function getReleased(IERC20Upgradeable token, address account) external view returns (uint256);
    function releasePayment(address payable account) external;
    function releasePayment(IERC20Upgradeable token, address account) external;
} 

pragma solidity ^0.8.4;







contract CedarERC721DropFactory is Ownable, ICedarDeployerEventsV5, ICedarImplementationVersionedV0 {
    CedarERC721Drop public implementation;
    address public greenlistManagerAddress;

    struct EventParams {
        address contractAddress;
        uint256 majorVersion;
        uint256 minorVersion;
        uint256 patchVersion;
    }

    constructor(address _greenlistManagerAddress) {
        greenlistManagerAddress = _greenlistManagerAddress;

        implementation = new CedarERC721Drop();

        implementation.initialize(_msgSender(), "default", "default", "", new address[](0), address(0), address(0), 0, CedarERC721Drop.FeaturesInput("0", address(0), address(0)), 0, address(0));
        (uint256 major, uint256 minor, uint256 patch) = implementation.implementationVersion();
        emit CedarImplementationDeployed(address(implementation), major, minor, patch, "ICedarERC721DropV3");
    }

    function emitEvent(
        EventParams memory params
    ) private {
        emit CedarERC721DropV2Deployment(
            params.contractAddress, 
            params.majorVersion,
            params.minorVersion,
            params.patchVersion
        );
    }

    function deploy(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external onlyOwner returns (CedarERC721Drop newClone) {
        newClone = CedarERC721Drop(Clones.clone(address(implementation)));
        SignatureVerifier signatureVerifier = new SignatureVerifier(_userAgreement, "_", "_");
        CedarERC721Drop.FeaturesInput memory input = CedarERC721Drop.FeaturesInput(_userAgreement, address(signatureVerifier), greenlistManagerAddress);

        newClone.initialize(
            _defaultAdmin, 
            _name, 
            _symbol, 
            _contractURI, 
            _trustedForwarders, 
            _saleRecipient, 
            _royaltyRecipient, 
            _royaltyBps, 
            input,
            _platformFeeBps, 
            _platformFeeRecipient
        );

        (uint major, uint minor, uint patch) = newClone.implementationVersion();

        EventParams memory params;
        params.contractAddress = address(newClone);
        params.majorVersion = major;
        params.minorVersion = minor;
        params.patchVersion = patch;

        emitEvent(params);
    }

    function implementationVersion()
    external override
    view
    returns (
        uint256 major,
        uint256 minor,
        uint256 patch
    ) {
        return implementation.implementationVersion();
    }

}

 
 

pragma solidity ^0.8.0;

 
library Clones {
     
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

     
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

     
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

     
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

 
pragma solidity ^0.8.7;

 









 



 



















 
contract CedarERC721Drop is
    Initializable,
    IThirdwebContract,
    IOwnable,
    IPrimarySale,
    ReentrancyGuardUpgradeable,
    ERC2771ContextUpgradeable,
    MulticallUpgradeable,
    AccessControlEnumerableUpgradeable,
    ERC721EnumerableUpgradeable,
    Agreement,
    Greenlist,
    IPlatformFee,
    BaseCedarERC721DropV3
{
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;
    using StringsUpgradeable for uint256;

    using CedarDropERC721ClaimLogicV0 for DataTypes.ClaimData;

    
    event MaxTotalSupplyUpdated(uint256 maxTotalSupply);

    
    event WalletClaimCountUpdated(address indexed wallet, uint256 count);

    
    event MaxWalletClaimCountUpdated(uint256 count);

     
    mapping(uint256 => string) private baseURI;

    
    mapping(uint256 => RoyaltyInfo) private royaltyInfoForToken;

    struct FeaturesInput {
        string userAgreement;
        address signatureVerifier;
        address greenlistManagerAddress;
    }

     
    function owner() public view override returns (address) {
        return hasRole(DEFAULT_ADMIN_ROLE, _owner) ? _owner : address(0);
    }

     
    function lazyMint(
        uint256 _amount,
        string calldata _baseURIForTokens
    ) external override onlyRole(MINTER_ROLE) {
        uint256 startId = claimData.nextTokenIdToMint;
        uint256 baseURIIndex = startId + _amount;

        claimData.nextTokenIdToMint = baseURIIndex;
        baseURI[baseURIIndex] = _baseURIForTokens;
        baseURIIndices.push(baseURIIndex);

        emit TokensLazyMinted(startId, startId + _amount - 1, _baseURIForTokens);
    }

     
     

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            AccessControlEnumerableUpgradeable,
            ERC721EnumerableUpgradeable,
            BaseCedarERC721DropV3
        )
        returns (bool)
    {
        return ERC721EnumerableUpgradeable.supportsInterface(interfaceId);
    }

     
    function minorVersion() public pure override returns (uint256 minor, uint256 patch) {
        minor = 0;
        patch = 0;
    }

    function multicall(bytes[] calldata data)
        external
        override(IMulticallableV0, MulticallUpgradeable)
        returns (bytes[] memory results)
    {
        return MulticallUpgradeable(this).multicall(data);
    }

     
    function updateBaseURI(uint256 baseURIIndex, string calldata _baseURIForTokens) override external onlyRole(MINTER_ROLE) {
        baseURI[baseURIIndex] = _baseURIForTokens;
        emit BaseURIUpdated(baseURIIndex, _baseURIForTokens);
    }

     
    function getBaseURIIndices() external override view returns(uint256[] memory) {
        return baseURIIndices;
    }

    
    function getPlatformFeeInfo() override external view returns (address, uint16) {
        return (claimData.platformFeeRecipient, uint16(claimData.platformFeeBps));
    }

    
    function setPlatformFeeInfo(address _platformFeeRecipient, uint256 _platformFeeBps)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_platformFeeBps <= MAX_BPS, "> MAX_BPS.");

        claimData.platformFeeBps = uint16(_platformFeeBps);
        claimData.platformFeeRecipient = _platformFeeRecipient;

        emit PlatformFeeInfoUpdated(_platformFeeRecipient, _platformFeeBps);
    }
}

interface ICedarDeployerV1 is ICedarDeployerAddedV1, ICedarDeployerV0 {}

interface ICedarDeployerV2 is ICedarDeployerAddedV2, ICedarDeployerAddedV1, ICedarDeployerV0 {}

interface ICedarDeployerV3 is ICedarDeployerAddedV3, ICedarDeployerAddedV2, ICedarDeployerAddedV1, ICedarDeployerV0 {}

interface ICedarDeployerV4 is
    ICedarDeployerEventsV4,
    ICedarDeployerAddedV4,
    ICedarDeployerAddedV3,
    ICedarDeployerAddedV2,
    ICedarDeployerIntrospectionV0
{}

interface ICedarDeployerAddedV6 {
    function deployCedarERC1155DropV1(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external returns (ICedarERC1155DropV1);

    function deployCedarERC721DropV2(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external returns (ICedarERC721DropV2);
}

interface ICedarDeployerV5 is
    ICedarDeployerEventsV4,
    ICedarDeployerAddedV5,
    ICedarDeployerAddedV3,
    ICedarDeployerAddedV2,
    ICedarDeployerIntrospectionV0
{}

interface ICedarDeployerV6 is
    ICedarDeployerEventsV5,
    ICedarDeployerAddedV7,
    ICedarDeployerAddedV3,
    ICedarDeployerAddedV2,
    ICedarDeployerIntrospectionV0
{}

 

pragma solidity ^0.8.4;




 
contract SignatureVerifier is EIP712, Ownable {
     

    bytes32 public constant MESSSAGE_HASH = keccak256("AgreeTerms(string url,string message)");

     

    struct AgreeTerms {
        string url;
        string message;
    }

    AgreeTerms public terms;

     

    
    constructor(
        string memory _url,
        string memory _message,
        string memory _name
    ) EIP712(_name, "1.0.0") {
        require(bytes(_url).length != 0 && bytes(_message).length != 0, "Signature Verifier: invalid url and message");
        terms.url = _url;
        terms.message = _message;
    }

    
    
    function verifySignature(address _to, bytes memory _signature) external view returns (bool) {
        if (_signature.length == 0) return false;
        bytes32 hash = _hashMessage();
        address signer = ECDSA.recover(hash, _signature);
        return signer == _to;
    }

    
    function _hashMessage() private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(abi.encode(MESSSAGE_HASH, keccak256(bytes(terms.url)), keccak256(bytes(terms.message))))
            );
    }
}

 
 

pragma solidity ^0.8.0;



 
interface IERC2981Upgradeable is IERC165Upgradeable {
     
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

 
 
pragma solidity ^0.8.0;

 
library BitMapsUpgradeable {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

     
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

     
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

     
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

     
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}

 
 

pragma solidity ^0.8.0;

 
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

     
    function toString(uint256 value) internal pure returns (string memory) {
         
         

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

     
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

     
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

 
pragma solidity ^0.8.4;

library FeeType {
    uint256 internal constant PRIMARY_SALE = 0;
    uint256 internal constant MARKET_SALE = 1;
    uint256 internal constant SPLIT = 2;
}

 
 
 

pragma solidity ^0.8.4;

 
library MerkleProof {
     
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool, uint256) {
        bytes32 computedHash = leaf;
        uint256 index = 0;

        for (uint256 i = 0; i < proof.length; i++) {
            index *= 2;
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                 
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                 
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
                index += 1;
            }
        }

         
        return (computedHash == root, index);
    }
}

 
pragma solidity ^0.8.4;

error InvalidPermission();
error InvalidIndex();
error NothingToReveal();
error Bot();
error ST();
error CrossedLimit();
error InvalidPrice();
error InvalidQuantity();
error InvalidTime();
error InvalidProof();
error MaxBps();

 
pragma solidity ^0.8.7;



interface DataTypes {
  struct ClaimData {
    
    IDropClaimConditionV0.ClaimConditionList claimCondition;

    
    uint256 nextTokenIdToClaim;

    
    mapping(address => uint256) walletClaimCount;

    
    uint256 nextTokenIdToMint;

    
    uint256 maxTotalSupply;

    
    uint256 maxWalletClaimCount;

     
    address primarySaleRecipient;

    
    address platformFeeRecipient;

    
    uint16 platformFeeBps;
  }
}

 
pragma solidity ^0.8.7;







library CedarDropERC721ClaimLogicV0 {
    using CedarDropERC721ClaimLogicV0 for DataTypes.ClaimData;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    struct InternalClaim {
        bool validMerkleProof;
        uint256 merkleProofIndex;
        bool toVerifyMaxQuantityPerTransaction;
        uint256 activeConditionId;
        uint256 tokenIdToClaim;
    }

    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        address indexed claimer,
        address indexed receiver,
        uint256 startTokenId,
        uint256 quantityClaimed
    );

    event ClaimConditionsUpdated(IDropClaimConditionV0.ClaimCondition[] claimConditions);

    function transferClaimedTokens(
        DataTypes.ClaimData storage claimData,
        uint256 _conditionId,
        uint256 _quantityBeingClaimed,
        address msgSender
    ) public returns (uint256[] memory tokens) {
         
        claimData.claimCondition.phases[_conditionId].supplyClaimed += _quantityBeingClaimed;

         
         
        claimData.claimCondition.limitLastClaimTimestamp[_conditionId][msgSender] = block.timestamp;
        claimData.walletClaimCount[msgSender] += _quantityBeingClaimed;

        uint256 tokenIdToClaim = claimData.nextTokenIdToClaim;

        tokens = new uint256[](_quantityBeingClaimed);

        for (uint256 i = 0; i < _quantityBeingClaimed; i += 1) {
            tokens[i] = tokenIdToClaim;
            tokenIdToClaim += 1;
        }

        claimData.nextTokenIdToClaim = tokenIdToClaim;
    }

    function executeClaim(
        DataTypes.ClaimData storage claimData,
        address _receiver,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bytes32[] calldata _proofs,
        uint256 _proofMaxQuantityPerTransaction,
        address msgSender
    ) public returns (uint256[] memory) {
        InternalClaim memory internalData;

        internalData.tokenIdToClaim = claimData.nextTokenIdToClaim;

         
        internalData.activeConditionId = getActiveClaimConditionId(claimData);

         

         
        (internalData.validMerkleProof, internalData.merkleProofIndex) = verifyClaimMerkleProof(
            claimData,
            internalData.activeConditionId,
            msgSender,
            _quantity,
            _proofs,
            _proofMaxQuantityPerTransaction
        );

         
         
         
        internalData.toVerifyMaxQuantityPerTransaction =
            _proofMaxQuantityPerTransaction == 0 ||
            claimData.claimCondition.phases[internalData.activeConditionId].merkleRoot == bytes32(0);
        verifyClaim(
            claimData,
            internalData.activeConditionId,
            msgSender,
            _quantity,
            _currency,
            _pricePerToken,
            internalData.toVerifyMaxQuantityPerTransaction
        );

        if (internalData.validMerkleProof && _proofMaxQuantityPerTransaction > 0) {
             
            claimData.claimCondition.limitMerkleProofClaim[internalData.activeConditionId].set(
                internalData.merkleProofIndex
            );
        }

         
        claimData.collectClaimPrice(_quantity, _currency, _pricePerToken, msgSender);

         
        uint256[] memory tokens = transferClaimedTokens(
            claimData,
            internalData.activeConditionId,
            _quantity,
            msgSender
        );

        emit TokensClaimed(
            internalData.activeConditionId,
            msgSender,
            _receiver,
            internalData.tokenIdToClaim,
            _quantity
        );

        return tokens;
    }

    function verifyClaimMerkleProof(
        DataTypes.ClaimData storage claimData,
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        bytes32[] calldata _proofs,
        uint256 _proofMaxQuantityPerTransaction
    ) public view returns (bool validMerkleProof, uint256 merkleProofIndex) {
        IDropClaimConditionV0.ClaimCondition memory currentClaimPhase = claimData.claimCondition.phases[_conditionId];

        if (currentClaimPhase.merkleRoot != bytes32(0)) {
            (validMerkleProof, merkleProofIndex) = MerkleProof.verify(
                _proofs,
                currentClaimPhase.merkleRoot,
                keccak256(abi.encodePacked(_claimer, _proofMaxQuantityPerTransaction))
            );

            if (!validMerkleProof) revert InvalidProof();
            if (!(!claimData.claimCondition.limitMerkleProofClaim[_conditionId].get(merkleProofIndex)))
                revert InvalidProof();
            if (!(_proofMaxQuantityPerTransaction == 0 || _quantity <= _proofMaxQuantityPerTransaction))
                revert InvalidProof();
        }
    }

    function getActiveClaimConditionId(DataTypes.ClaimData storage claimData) public view returns (uint256) {
        for (
            uint256 i = claimData.claimCondition.currentStartId + claimData.claimCondition.count;
            i > claimData.claimCondition.currentStartId;
            i--
        ) {
            if (block.timestamp >= claimData.claimCondition.phases[i - 1].startTimestamp) {
                return i - 1;
            }
        }

        revert("!CONDITION.");
    }

    function verifyClaim(
        DataTypes.ClaimData storage claimData,
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) public view {
        IDropClaimConditionV0.ClaimCondition memory currentClaimPhase = claimData.claimCondition.phases[_conditionId];

        if (!(_currency == currentClaimPhase.currency && _pricePerToken == currentClaimPhase.pricePerToken))
            revert InvalidPrice();
         
        if (
            !(_quantity > 0 &&
                (!verifyMaxQuantityPerTransaction || _quantity <= currentClaimPhase.quantityLimitPerTransaction))
        ) revert InvalidQuantity();
        if (!(currentClaimPhase.supplyClaimed + _quantity <= currentClaimPhase.maxClaimableSupply))
            revert CrossedLimit();
        if (!(claimData.nextTokenIdToClaim + _quantity <= claimData.nextTokenIdToMint)) revert CrossedLimit();
        if (!(claimData.maxTotalSupply == 0 || claimData.nextTokenIdToClaim + _quantity <= claimData.maxTotalSupply))
            revert CrossedLimit();
        if (
            !(claimData.maxWalletClaimCount == 0 ||
                claimData.walletClaimCount[_claimer] + _quantity <= claimData.maxWalletClaimCount)
        ) revert CrossedLimit();
        (uint256 lastClaimTimestamp, uint256 nextValidClaimTimestamp) = getClaimTimestamp(
            claimData,
            _conditionId,
            _claimer
        );
        if (!(lastClaimTimestamp == 0 || block.timestamp >= nextValidClaimTimestamp)) revert InvalidTime();
    }

    
    function getClaimTimestamp(
        DataTypes.ClaimData storage claimData,
        uint256 _conditionId,
        address _claimer
    ) public view returns (uint256 lastClaimTimestamp, uint256 nextValidClaimTimestamp) {
        lastClaimTimestamp = claimData.claimCondition.limitLastClaimTimestamp[_conditionId][_claimer];

        unchecked {
            nextValidClaimTimestamp =
                lastClaimTimestamp +
                claimData.claimCondition.phases[_conditionId].waitTimeInSecondsBetweenClaims;

            if (nextValidClaimTimestamp < lastClaimTimestamp) {
                nextValidClaimTimestamp = type(uint256).max;
            }
        }
    }

    
    function collectClaimPrice(
        DataTypes.ClaimData storage claimData,
        uint256 _quantityToClaim,
        address _currency,
        uint256 _pricePerToken,
        address msgSender
    ) internal {
        if (_pricePerToken == 0) {
            return;
        }

        uint256 MAX_BPS = 10_000;

        uint256 totalPrice = _quantityToClaim * _pricePerToken;
        uint256 platformFees = (totalPrice * claimData.platformFeeBps) / MAX_BPS;

        if(_currency == CurrencyTransferLib.NATIVE_TOKEN && !(msg.value == totalPrice)) revert InvalidPrice();

        CurrencyTransferLib.transferCurrency(_currency, msgSender, claimData.platformFeeRecipient, platformFees);
        CurrencyTransferLib.transferCurrency(_currency, msgSender, claimData.primarySaleRecipient, totalPrice - platformFees);
    }

    
    function setClaimConditions(
        DataTypes.ClaimData storage claimData,
        IDropClaimConditionV0.ClaimCondition[] calldata _phases,
        bool _resetClaimEligibility
    ) public {
        uint256 existingStartIndex = claimData.claimCondition.currentStartId;
        uint256 existingPhaseCount = claimData.claimCondition.count;

         
        uint256 newStartIndex = existingStartIndex;
        if (_resetClaimEligibility) {
            newStartIndex = existingStartIndex + existingPhaseCount;
        }

        claimData.claimCondition.count = _phases.length;
        claimData.claimCondition.currentStartId = newStartIndex;

        uint256 lastConditionStartTimestamp;
        for (uint256 i = 0; i < _phases.length; i++) {
            if (!(i == 0 || lastConditionStartTimestamp < _phases[i].startTimestamp)) revert ST();

            uint256 supplyClaimedAlready = claimData.claimCondition.phases[newStartIndex + i].supplyClaimed;

            if (!(supplyClaimedAlready <= _phases[i].maxClaimableSupply)) revert CrossedLimit();

            claimData.claimCondition.phases[newStartIndex + i] = _phases[i];
            claimData.claimCondition.phases[newStartIndex + i].supplyClaimed = supplyClaimedAlready;

            lastConditionStartTimestamp = _phases[i].startTimestamp;
        }

         
        if (_resetClaimEligibility) {
            for (uint256 i = existingStartIndex; i < newStartIndex; i++) {
                delete claimData.claimCondition.phases[i];
                delete claimData.claimCondition.limitMerkleProofClaim[i];
            }
        } else {
            if (existingPhaseCount > _phases.length) {
                for (uint256 i = _phases.length; i < existingPhaseCount; i++) {
                    delete claimData.claimCondition.phases[newStartIndex + i];
                    delete claimData.claimCondition.limitMerkleProofClaim[newStartIndex + i];
                }
            }
        }

        emit ClaimConditionsUpdated(_phases);
    }

    function getActiveClaimConditions(DataTypes.ClaimData storage claimData)
        public
        view
        returns (
            IDropClaimConditionV0.ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 remainingSupply
        )
    {
        conditionId = getActiveClaimConditionId(claimData);
        condition = claimData.claimCondition.phases[conditionId];
        walletMaxClaimCount = claimData.maxWalletClaimCount;
        remainingSupply = 0;  
    }

    function getUserClaimConditions(DataTypes.ClaimData storage claimData, address _claimer)
        public
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        )
    {
        conditionId = getActiveClaimConditionId(claimData);
        (lastClaimTimestamp, nextValidClaimTimestamp) = getClaimTimestamp(claimData, conditionId, _claimer);
        walletClaimedCount = claimData.walletClaimCount[_claimer];
    }
}

 
 

pragma solidity ^0.8.0;

 
interface IERC721ReceiverUpgradeable {
     
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 
 

pragma solidity ^0.8.1;

 
library AddressUpgradeable {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        return account.code.length > 0;
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

 
 

pragma solidity ^0.8.0;

 
library EnumerableSetUpgradeable {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;
         
         
        mapping(bytes32 => uint256) _indexes;
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

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                 
                set._values[toDeleteIndex] = lastvalue;
                 
                set._indexes[lastvalue] = valueIndex;  
            }

             
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
        return set._values[index];
    }

     
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

     
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

     
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

     
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

 

pragma solidity ^0.8.4;













 
 
interface ICedarERC721DropV0 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    ICedarNFTIssuanceV0,
    ICedarNFTLazyMintV0,
    IMulticallableV0,
    IERC721V0
{
}

interface ICedarERC721DropV1 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    IMulticallableV0,
    ICedarAgreementV0,
    ICedarNFTIssuanceV1,
    ICedarNFTLazyMintV0,
    IERC721V0,
    IRoyaltyV0
{}

interface ICedarERC721DropV2 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    IMulticallableV0,
    ICedarAgreementV0,
    ICedarNFTIssuanceV1,
    ICedarNFTLazyMintV1,
    IERC721V0,
    IRoyaltyV0,
    ICedarUpdateBaseURIV0,
    ICedarNFTMetadataV0,
    ICedarMetadataV0
{}

 
 

pragma solidity ^0.8.0;



 
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return;  
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

     
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
         
         
         
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
             
             
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
             
             
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

     
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

     
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

     
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

     
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
         
         
         
         
         
         
         
         
         
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

         
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

     
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

     
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
         
         
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

     
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

     
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

 
 

pragma solidity ^0.8.0;

 
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

     
    function toString(uint256 value) internal pure returns (string memory) {
         
         

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

     
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

     
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

 
 

pragma solidity ^0.8.1;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        return account.code.length > 0;
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

 

pragma solidity ^0.8.4;




 

contract GreenlistManager is OwnableUpgradeable, UUPSUpgradeable {
     

    address public operator;

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    event OperatorAdded(address _address);
    event OperatorDeleted(address _address);

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    
    
    function setAspenOperator(address _operator) external onlyOwner {
        operator = _operator;
        emit OperatorAdded(_operator);
    }

    
    
    function deleteAspenOperator(address _address) external onlyOwner {
        delete operator;
        emit OperatorDeleted(_address);
    }

    
    
    function isGreenlisted(address _address) public view returns (bool) {
        return (operator == _address);
    }
}

 
 

pragma solidity ^0.8.0;

 
interface IBeaconUpgradeable {
     
    function implementation() external view returns (address);
}

 
 

pragma solidity ^0.8.0;

 
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

     
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

 
pragma solidity ^0.8.4;

 




library CurrencyTransferLib {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    function transferCurrency(
        address _currency,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_amount == 0) {
            return;
        }

        if (_currency == NATIVE_TOKEN) {
            safeTransferNativeToken(_to, _amount);
        } else {
            safeTransferERC20(_currency, _from, _to, _amount);
        }
    }

    
    function transferCurrencyWithWrapper(
        address _currency,
        address _from,
        address _to,
        uint256 _amount,
        address _nativeTokenWrapper
    ) internal {
        if (_amount == 0) {
            return;
        }

        if (_currency == NATIVE_TOKEN) {
            if (_from == address(this)) {
                 
                IWETH(_nativeTokenWrapper).withdraw(_amount);
                safeTransferNativeTokenWithWrapper(_to, _amount, _nativeTokenWrapper);
            } else if (_to == address(this)) {
                 
                require(_amount == msg.value, "msg.value != amount");
                IWETH(_nativeTokenWrapper).deposit{ value: _amount }();
            } else {
                safeTransferNativeTokenWithWrapper(_to, _amount, _nativeTokenWrapper);
            }
        } else {
            safeTransferERC20(_currency, _from, _to, _amount);
        }
    }

    
    function safeTransferERC20(
        address _currency,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_from == _to) {
            return;
        }

        if (_from == address(this)) {
            IERC20Upgradeable(_currency).safeTransfer(_to, _amount);
        } else {
            IERC20Upgradeable(_currency).safeTransferFrom(_from, _to, _amount);
        }
    }

    
    function safeTransferNativeToken(address to, uint256 value) internal {
         
         
        (bool success, ) = to.call{ value: value }("");
        require(success, "native token transfer failed");
    }

    
    function safeTransferNativeTokenWithWrapper(
        address to,
        uint256 value,
        address _nativeTokenWrapper
    ) internal {
         
         
        (bool success, ) = to.call{ value: value }("");
        if (!success) {
            IWETH(_nativeTokenWrapper).deposit{ value: value }();
            IERC20Upgradeable(_nativeTokenWrapper).safeTransfer(to, value);
        }
    }
}

 
pragma solidity ^0.8.4;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function transfer(address to, uint256 value) external returns (bool);
}

 
 

pragma solidity ^0.8.0;

 
interface IERC20Upgradeable {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address to, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
 

pragma solidity ^0.8.0;




 
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

     
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity ^0.8.4;














 
 
interface ICedarERC721PremintV0 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    ICedarPremintV0,
    ICedarAgreementV0,
    IMulticallableV0
{
}

interface ICedarERC721PremintV1 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    ICedarPremintV0,
    ICedarAgreementV0,
    IMulticallableV0,
    ICedarUpgradeBaseURIV0
{
}

 

pragma solidity ^0.8.4;












interface ICedarERC1155DropV0 is
    ICedarFeaturesV0,
    IMulticallableV0,
    ICedarVersionedV0,
    ICedarSFTIssuanceV0,
    ICedarSFTLazyMintV0,
    ICedarUpdateBaseURIV0,
    IERC1155V0
{

}

 
interface ICedarERC1155DropV1 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    IMulticallableV0,
    ICedarSFTIssuanceV1,
    ICedarSFTLazyMintV0,
    ICedarUpdateBaseURIV0,
    IERC1155V0,
    IRoyaltyV0
{

}

 

pragma solidity ^0.8.4;





interface ICedarPaymentSplitterV0 is
    ICedarFeaturesV0,
    ICedarVersionedV0,
    ICedarSplitPaymentV0
{

}

 

pragma solidity ^0.8.4;

 
interface ICedarIssuerV0 {
     
    function issue(address recipient, uint256 tokenId) external;
}

 

pragma solidity ^0.8.4;



interface ICedarClaimableV0 {
     
     
    function claim(
        uint256 quantity,
        address recipient,
        bytes32[] calldata proof
    ) external;

    struct ClaimRequest {
        ICedarIssuanceV0.AuthType authType;
        uint256 quantity;
        address recipient;
        address erc20TokenContract;
        bytes32[] proof;
    }

    function claim(ClaimRequest calldata claimRequest, bytes calldata signature) external;
}

 

pragma solidity ^0.8.4;




interface ICedarOrderFillerV0 {
     
    function fillOrder(IOrderV0.Order calldata order, bytes calldata signature) external;
}

 

pragma solidity ^0.8.4;

 
interface ICedarNativePayableV0 {

    function buy(
        uint256 quantity,
        address recipient,
        uint256 tokenId
    ) external payable;
}

 

pragma solidity ^0.8.4;

 
 
interface ICedarERC20PayableV0 {
    function buy(
        address recipient,
        address erc20TokenContract,
        uint256 tokenId
    ) external;

    function buyAny(
        address recipient,
        address erc20TokenContract,
        uint256 quantity
    ) external;
}

 

pragma solidity ^0.8.0;

 
 
 
interface ICedarIssuanceV0 {
    enum IssuanceMode {
        SpecificToken,
        AnyToken
    }

    enum PaymentType {
        None,
        Native,
        ERC20
    }

    enum AuthType {
        TrustedSender,
        Merkle,
        Signature
    }

    function issuanceModes() external view returns (IssuanceMode[] calldata);

    function paymentTypes() external view returns (PaymentType[] calldata);

    function authTypes() external view returns (AuthType[] calldata);
}

interface ICedarIssuanceV1 {
    function foo() external view returns (uint256);
}

 

pragma solidity ^0.8.4;

interface IOrderV0 {
    struct Order {
        address maker;
        address taker;
    }
}

 
pragma solidity ^0.8.0;

interface ICedarSFTMetadataV0 {
    
    function uri(uint256 _tokenId) external returns (string memory);
}

interface ICedarSFTMetadataV1 {
    
    function uri(uint256 _tokenId) view external returns (string memory);
}
