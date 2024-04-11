 
pragma experimental ABIEncoderV2;


 

 
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

 
interface IERC165Upgradeable {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 

pragma solidity >=0.6.0 <0.8.0;






 
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

     
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

     
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

     
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

     
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

     
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

     
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

     
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

     
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

     
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

     
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

     
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

     
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC1155Upgradeable is IERC165Upgradeable {
     
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
 
pragma solidity >=0.6.0 <0.8.0;



abstract contract OwnerOperatorControl is AccessControlUpgradeable {
    bytes32 public constant OPERATOR_ROLE = keccak256('OPERATOR_ROLE');

    function __OwnerOperatorControl_init() internal {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Role: not Admin');
        _;
    }

    modifier onlyOperator() {
        require(isOperator(_msgSender()), 'Role: not Operator');
        _;
    }

    function isOperator(address _address) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, _address);
    }
}

 
pragma solidity >=0.6.0 <0.8.0;



 
interface IERCWithRoyalties is IERC165Upgradeable {
     
    function getRoyalties(uint256 id) external view returns (uint256);

     
    function onRoyaltiesReceived(uint256 id) external payable returns (bytes4);
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

 

pragma solidity >=0.6.2 <0.8.0;



 
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
     
    function uri(uint256 id) external view returns (string memory);
}

 
pragma solidity >=0.6.0 <0.8.0;




abstract contract ERCWithRoyalties is ERC165Upgradeable, IERCWithRoyalties {
    event RoyaltiesDefined(
        uint256 indexed id,
        address indexed recipient,
        uint256 value
    );

    event RoyaltiesReceived(
        uint256 indexed id,
        address indexed recipient,
        uint256 value
    );

    uint256 private _maxRoyalty;

     
    bytes4 private constant _INTERFACE_ID_ROYALTIES = 0xbebd9614;

    struct Royalty {
        address recipient;
        uint256 value;
    }

    mapping(uint256 => Royalty) internal _royalties;

    function __ERCWithRoyalties_init() internal initializer {
        _registerInterface(_INTERFACE_ID_ROYALTIES);
        _maxRoyalty = 10000;
    }

     
    function maxRoyalty() public view returns (uint256) {
        return _maxRoyalty;
    }

     
    function _setMaxRoyalty(uint256 maxAllowedRoyalty) internal {
        require(
            maxAllowedRoyalty <= 10000,
            'Royalties: max royalty can not be more than 100%'
        );

        _maxRoyalty = maxAllowedRoyalty;
    }

     
    function _setRoyalties(
        uint256 id,
        address recipient,
        uint256 value
    ) internal {
        require(
            recipient != address(0),
            'Royalties: Royalties recipient can not be null address'
        );

        require(
            value <= _maxRoyalty,
            'Royalties: Royalties can not be more than the defined max royalty'
        );

        _royalties[id] = Royalty(recipient, value);

        emit RoyaltiesDefined(id, recipient, value);
    }
}

 

pragma solidity >=0.6.0 <0.8.0;










 
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

     
    mapping (uint256 => mapping(address => uint256)) private _balances;

     
    mapping (address => mapping(address => bool)) private _operatorApprovals;

     
    string private _uri;

     
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

     
    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

     
    function __ERC1155_init(string memory uri_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal initializer {
        _setURI(uri_);

         
        _registerInterface(_INTERFACE_ID_ERC1155);

         
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

     
    function uri(uint256) external view virtual override returns (string memory) {
        return _uri;
    }

     
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

     
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

     
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

     
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

     
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

     
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

     
    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

     
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

     
    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

     
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

     
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
    uint256[47] private __gap;
}

 
pragma solidity >=0.6.0 <0.8.0;



abstract contract OwnerOperatorControlWithSignature is OwnerOperatorControl {
     
    function requireOperatorSignature(
        bytes32 message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view {
        require(isOperator(recoverSigner(message, v, r, s)), 'Wrong Signature');
    }

     
    function recoverSigner(
        bytes32 message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address) {
        if (v < 27) {
            v += 27;
        }

        return
            ecrecover(
                keccak256(
                    abi.encodePacked(
                        '\x19Ethereum Signed Message:\n32',
                        message
                    )
                ),
                v,
                r,
                s
            );
    }
}

 
pragma solidity >=0.6.0 <0.8.0;

 
contract GroupedURI {
    event GroupURIBatchUpdate(uint256[] groupIds);
    event TokenGroupBatchUpdate(uint256[] tokenIds, uint256[] groupIds);

    uint256 public currentGroupId;
    mapping(uint256 => string) public tokenGroupsURIs;
    mapping(uint256 => uint256) public tokenIdToGroupId;

    function __GroupedURI_init(string memory firstGroupURI) internal {
        require(bytes(firstGroupURI).length > 0, 'Invalid URI');

         
        currentGroupId = 1;
        tokenGroupsURIs[1] = firstGroupURI;
    }

     
    function _addIdToCurrentGroup(uint256 id) internal {
        tokenIdToGroupId[id] = currentGroupId;
    }

     
    function _getIdGroupURI(uint256 id) internal view returns (string memory) {
        return tokenGroupsURIs[tokenIdToGroupId[id]];
    }

     
    function _setNnextGroup(
        string memory currentGroupNewURI,
        string memory nextGroupBaseURI
    ) internal {
        require(bytes(nextGroupBaseURI).length > 0, 'Invalid URI');

        uint256 currentGroupId_ = currentGroupId;

        if (bytes(currentGroupNewURI).length > 0) {
            tokenGroupsURIs[currentGroupId_] = currentGroupNewURI;
        }

         
        currentGroupId_++;
        tokenGroupsURIs[currentGroupId_] = nextGroupBaseURI;

         
        currentGroupId = currentGroupId_;
    }

     
    function _setIdGroupIdBatch(uint256[] memory ids, uint256[] memory groupIds)
        internal
    {
        require(ids.length == groupIds.length, 'Length mismatch');
        for (uint256 i; i < ids.length; i++) {
            tokenIdToGroupId[ids[i]] = groupIds[i];
        }

        emit TokenGroupBatchUpdate(ids, groupIds);
    }

     
    function _setGroupURIBatch(uint256[] memory groupIds, string[] memory uris)
        internal
    {
        require(groupIds.length == uris.length, 'Length mismatch');
        for (uint256 i; i < groupIds.length; i++) {
            tokenGroupsURIs[groupIds[i]] = uris[i];
        }

        emit GroupURIBatchUpdate(groupIds);
    }
}

 
pragma solidity >=0.6.0 <0.8.0;

abstract contract ERC1155Configurable {
     
    event ConfigurationURI(
        uint256 indexed tokenId,
        address indexed owner,
        string configurationURI
    );

     
    mapping(uint256 => mapping(address => string)) private _interactiveConfURIs;

    function _setInteractiveConfURI(
        uint256 tokenId,
        address owner,
        string calldata interactiveConfURI_
    ) internal virtual {
        _interactiveConfURIs[tokenId][owner] = interactiveConfURI_;
        emit ConfigurationURI(tokenId, owner, interactiveConfURI_);
    }

     
    function interactiveConfURI(uint256 tokenId, address owner)
        public
        view
        virtual
        returns (string memory)
    {
        return _interactiveConfURIs[tokenId][owner];
    }
}

 
pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC1155WithMetadata is ERC1155Upgradeable {
     
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address) private _creators;

    function __ERC1155WithMetadata_init(string memory uri_)
        internal
        initializer
    {
        __ERC1155_init_unchained(uri_);
    }

     
    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return _tokenURIs[id];
    }

     
    function minted(uint256 id) public view returns (bool) {
        return _creators[id] != address(0);
    }

     
    function creator(uint256 id) public view returns (address creatorFromId) {
        address _creator = _creators[id];
        require(_creator != address(0), 'ERC1155: Not Minted');
        return _creator;
    }

     
    function _setMetadata(
        uint256 id,
        string memory tokenURI,
        address _creator
    ) internal {
        if (bytes(tokenURI).length > 0) {
            _tokenURIs[id] = tokenURI;
            emit URI(tokenURI, id);
        }
        _creators[id] = _creator;
    }

     
    function _removeMetadata(uint256 id) internal {
        delete _tokenURIs[id];
        delete _creators[id];
    }
}

 
pragma solidity >=0.6.0 <0.8.0;





abstract contract ERC1155WithRoyalties is ERCWithRoyalties {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) public claimableRoyalties;

    function __ERC1155WithRoyalties_init() internal initializer {
        __ERCWithRoyalties_init();
    }

     
    function getRoyalties(uint256 id) public view override returns (uint256) {
        return _royalties[id].value;
    }

     
    function onRoyaltiesReceived(uint256 id)
        external
        payable
        override
        returns (bytes4)
    {
         
         
        address recipient = _royalties[id].recipient;
        require(recipient != address(0), 'No royalties for id');

         
        payable(recipient).transfer(msg.value);

        emit RoyaltiesReceived(id, recipient, msg.value);

        return this.onRoyaltiesReceived.selector;
    }

     
    function claimRoyalties(address recipient) external {
        uint256 value = claimableRoyalties[recipient];
        require(value > 0, 'Royalties: Nothing to claim');

         
        claimableRoyalties[recipient] = 0;

        (bool sent, ) = payable(recipient).call{value: value}('');

        require(sent, 'Failed to send Ether');
    }

     
    function royaltyInfo(
        uint256 tokenId,
        uint256 value,
        bytes calldata
    )
        external
        view
        returns (
            address receiver,
            uint256 royaltyAmount,
            bytes memory royaltyPaymentData
        )
    {
        Royalty memory royalty = _royalties[tokenId];

        if (royalty.recipient == address(0)) {
            return (address(0), 0, '');
        }

        return (royalty.recipient, (value * royalty.value) / 10000, '');
    }
}

 
pragma solidity >=0.6.0 <0.8.0;








contract BeyondNFT1155V2 is
    OwnerOperatorControlWithSignature,
    ERC1155Configurable,
    ERC1155WithRoyalties,
    ERC1155WithMetadata,
    GroupedURI
{
     
     

     
     
     

     
     

    receive() external payable {
        revert('No value accepted');
    }

    function mint(
        uint256 id,
        uint256 supply,
        string memory uri_,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 royalties,
        address royaltiesRecipient
    ) external {
        require(!minted(id), 'ERC1155: Already minted');

        address sender = _msgSender();
        requireOperatorSignature(
            prepareMessage(sender, id, supply, uri_),
            v,
            r,
            s
        );

        _mint(sender, id, supply, bytes(''));
        _setMetadata(id, uri_, sender);

        if (royalties > 0) {
            _setRoyalties(id, royaltiesRecipient, royalties);
        }
    }

    function burn(
        address owner,
        uint256 id,
        uint256 amount
    ) external {
        require(
            owner == _msgSender() || isApprovedForAll(owner, _msgSender()),
            'ERC1155: caller is not owner nor approved'
        );

        _burn(owner, id, amount);
    }

    function burnBatch(
        address owner,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external {
        require(
            owner == _msgSender() || isApprovedForAll(owner, _msgSender()),
            'ERC1155: caller is not owner nor approved'
        );

        _burnBatch(owner, ids, amounts);
    }

     
    function safeBatchTransferIdFrom(
        address from,
        address[] memory tos,
        uint256 id,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        require(tos.length == amounts.length, 'ERC1155: length mismatch');

        for (uint256 i = 0; i < tos.length; i++) {
            safeTransferFrom(from, tos[i], id, amounts[i], data);
        }
    }

     
    function setInteractiveConfURI(
        uint256 tokenId,
        address owner,
        string calldata interactiveConfURI
    ) public {
        require(
            owner == _msgSender() || isApprovedForAll(owner, _msgSender()),
            'ERC1155: caller is not owner nor approved'
        );
        _setInteractiveConfURI(tokenId, owner, interactiveConfURI);
    }

    function prepareMessage(
        address sender,
        uint256 id,
        uint256 supply,
        string memory uri_
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(sender, id, supply, uri_));
    }

    function setBatchTokenMetadata(
        uint256[] memory ids,
        string[] memory uris,
        address[] memory creators
    ) external onlyOwner {
        for (uint256 i; i < ids.length; i++) {
            _setMetadata(ids[i], uris[i], creators[i]);
        }
    }

    function registerERC2981Interface() external onlyOwner {
        _registerInterface(0xc155531d);
    }

    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
         
        string memory groupUri = _getIdGroupURI(id);
         
        return bytes(groupUri).length > 0 ? groupUri : super.uri(id);
    }

     
     
     
    function setNextGroup(
        string memory currentGroupNewURI,
        string memory nextGroupBaseURI
    ) external onlyOwner {
        _setNnextGroup(currentGroupNewURI, nextGroupBaseURI);
    }

     
    function setIdGroupIdBatch(uint256[] memory ids, uint256[] memory groupIds)
        external
        onlyOwner
    {
        _setIdGroupIdBatch(ids, groupIds);
    }

     
    function setGroupURIBatch(uint256[] memory groupIds, string[] memory uris)
        external
        onlyOwner
    {
        _setGroupURIBatch(groupIds, uris);
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeMathUpgradeable {
     
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

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableSetUpgradeable {
     
     
     
     
     
     
     
     

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
