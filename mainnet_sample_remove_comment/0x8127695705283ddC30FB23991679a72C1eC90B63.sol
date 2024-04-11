 


 
 

pragma solidity ^0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
 
 

pragma solidity ^0.8.0;



 
interface IERC1155 is IERC165 {
     
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

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 
 

pragma solidity ^0.8.0;

 
interface IERC20 {
     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
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
}

 
 

pragma solidity ^0.8.0;



 
abstract contract ERC165 is IERC165 {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

 
 

pragma solidity ^0.8.0;



 
interface IERC1155MetadataURI is IERC1155 {
     
    function uri(uint256 id) external view returns (string memory);
}

 
 

pragma solidity ^0.8.0;








 
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

     
    mapping(uint256 => mapping(address => uint256)) private _balances;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
    string private _uri;

     
    constructor(string memory uri_) {
        _setURI(uri_);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

     
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

     
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

     
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
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
        _setApprovalForAll(_msgSender(), operator, approved);
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
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

     
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

     
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

     
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

     
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

     
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

     
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

     
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

     
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

     
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

     
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

     
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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
}

 
 

pragma solidity ^0.8.0;



 
interface IERC20Metadata is IERC20 {
     
    function name() external view returns (string memory);

     
    function symbol() external view returns (string memory);

     
    function decimals() external view returns (uint8);
}

 
 

pragma solidity ^0.8.0;



 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _transferOwnership(_msgSender());
    }

     
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

 
 

pragma solidity ^0.8.0;





 
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

     
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

     
    function name() public view virtual override returns (string memory) {
        return _name;
    }

     
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

     
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

     
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

     
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

     
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

     
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

     
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

     
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

     
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

     
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

     
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

     
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

     
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

     
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

     
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

 
 

pragma solidity ^0.8.0;



 
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

     
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

     
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

     
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}
 
pragma solidity >=0.7.0;










enum Faction {None, Jahjahrion, Breedorok, Foodrak, Pimpmyridian,
        Muskarion, Lamborgardoz, Schumarian, Creatron}

abstract contract Cosmog is ERC20, Ownable
{    
}

contract CosmoGangItems is ERC1155Supply, Ownable {
    string public name = "CosmoGangItems";
    string public symbol = "CGI";
    uint256 public constant PRICE = 0 ether;
    address public main_address;
    address public token_address;
    address public signer_address;
    uint256 public daysBetweenMints = 30;
    uint256 public cosmog_price = 150000000000000000000;
    Cosmog public token_contract;
    bool public isMinting = false;
    mapping(Faction => string) faction_metadata_url_mapping;
    mapping(uint256 => uint256) tokenIdLastMint;
    mapping(address => bool) public approvedAddresses;
    mapping(Faction => uint256) public factionSuccessProbability;

    constructor(address _main_address, address _token_address, address _signer_address) ERC1155("")
    {
        main_address = _main_address;

        token_address = _token_address;
        token_contract = Cosmog(token_address);

        factionSuccessProbability[Faction.None] = 0;
        factionSuccessProbability[Faction.Jahjahrion] = 100;
        factionSuccessProbability[Faction.Breedorok] = 10;
        factionSuccessProbability[Faction.Foodrak] = 100;
        factionSuccessProbability[Faction.Pimpmyridian] = 100;
        factionSuccessProbability[Faction.Muskarion] = 100;
        factionSuccessProbability[Faction.Lamborgardoz] = 100;
        factionSuccessProbability[Faction.Schumarian] = 100;
        factionSuccessProbability[Faction.Creatron] = 100;

        signer_address = _signer_address;
    }

    modifier onlyApproved()
    {
        require(msg.sender == owner() || approvedAddresses[msg.sender], "caller is not approved");
        _;
    }

    function toggleMintState()
        external onlyOwner
    {
        if (isMinting)
        {
            isMinting = false;
        }
        else
        {
            isMinting = true;
        }
    }

    function getFaction(uint256[] calldata tokenIds, uint8 v, bytes32 r, bytes32 s, uint256 deadline)
        private view
        returns (Faction)
    {
        if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.None), deadline)), v, r, s) == signer_address)
        {
            return Faction.None;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Jahjahrion), deadline)), v, r, s) == signer_address)
        {
            return Faction.Jahjahrion;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Breedorok), deadline)), v, r, s) == signer_address)
        {
            return Faction.Breedorok;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Foodrak), deadline)), v, r, s) == signer_address)
        {
            return Faction.Foodrak;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Pimpmyridian), deadline)), v, r, s) == signer_address)
        {
            return Faction.Pimpmyridian;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Muskarion), deadline)), v, r, s) == signer_address)
        {
            return Faction.Muskarion;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Lamborgardoz), deadline)), v, r, s) == signer_address)
        {
            return Faction.Lamborgardoz;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Schumarian), deadline)), v, r, s) == signer_address)
        {
            return Faction.Schumarian;
        }
        else if (ecrecover(sha256(abi.encodePacked(msg.sender, tokenIds, uint(Faction.Creatron), deadline)), v, r, s) == signer_address)
        {
            return Faction.Creatron;
        }
        else
        {
            return Faction.None;
        }
    }

    function canMint(uint256 tokenId)
        public view
        returns (bool)
    {
         
         
         
         
        return block.timestamp >= tokenIdLastMint[tokenId] + 60 * 60 * 24 * daysBetweenMints;
    }

    function canMintBatch(uint256[] calldata tokenIds)
        public view
        returns (bool)
    {
        for (uint256 idx = 0; idx < tokenIds.length; idx++)
        {
            if (!canMint(tokenIds[idx]))
            {
                return false;
            }
        }
        return true;
    }

    function canMintMany(uint256[] calldata tokenIds)
        external view
        returns (bool[] memory)
    {
        bool[] memory canMintArray = new bool[](tokenIds.length);
        for (uint256 idx = 0; idx < tokenIds.length; idx++)
        {
            uint tid = tokenIds[idx];
            bool _canMint = canMint(tid);
            canMintArray[idx] = _canMint;
        }
        return canMintArray;
    }

    function successMint(Faction faction)
        private view
        returns (bool)
    {
        uint256 random;
        random = randomBetween(0, 100);

        if (random > (100 - factionSuccessProbability[faction]))
        {
            return true;
        }
        return false;
    }

     
    function _mintNFT(address recipient, uint8 v, bytes32 r, bytes32 s, uint256[] calldata fromTokenIds, uint256 deadline, bool useProba)
        private
        returns (bool)
    {
        Faction faction = getFaction(fromTokenIds, v, r, s, deadline);
        require(canMintBatch(fromTokenIds), "tokenId already minted his periodic Cosmo Gang Item");
        for (uint256 idx = 0; idx < fromTokenIds.length; idx++)
        {
            uint tokenId = fromTokenIds[idx];
            tokenIdLastMint[tokenId] = block.timestamp;
        } 
        require(faction != Faction.None, "No faction found with these parameters");
        uint256 nMint = fromTokenIds.length;
        if (useProba)
        {
            if (successMint(faction))
            {
                _mint(recipient, uint256(faction), nMint, "");
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            _mint(recipient, uint256(faction), nMint, "");
            return true;
        }
    }

     
    function mintNFT(address recipient, uint8 v, bytes32 r, bytes32 s, uint256[] calldata fromTokenIds, uint256 deadline)
        external payable
        returns (bool)
    {
        uint256 nMint = fromTokenIds.length;

        require(token_contract.allowance(msg.sender, address(this)) >= nMint * cosmog_price, "Inssuficient allowance for CosmoGangItems on your Cosmog");
        require(isMinting, "Mint period have not started yet and you are not Whitelisted");
        require(msg.value >= PRICE * nMint, "Not enough ETH to mint");
        require(token_contract.balanceOf(msg.sender) >= nMint * cosmog_price, "Not enough Cosmogs to mint");
        require(nMint > 0, "You have to mint more than 0");
        
        if (cosmog_price != 0)
        {
            token_contract.transferFrom(msg.sender, address(token_contract), nMint * cosmog_price);
        }
        
       return _mintNFT(recipient, v, r, s, fromTokenIds, deadline, true);
    }

    function giveaway(uint256 nMint, address recipient, Faction faction)
        public onlyApproved
        returns (bool)
    {
        _mint(recipient, uint256(faction), nMint, "");
        return true;
    }

    function burnNFT(address fromAddress, uint256 amount, Faction _faction)
        public
    {   
        require(msg.sender == fromAddress || msg.sender == owner() || approvedAddresses[msg.sender], "Must be called by owner of address or approved of contract");
        require(balanceOf(fromAddress, uint256(_faction)) >= amount, "Not enough balance to burn this amount");
        _burn(fromAddress, uint256(_faction), amount);
    }

    function setTokenAddress(address _token_address)
        external onlyOwner
    {
        token_address = _token_address;
        token_contract =  Cosmog(token_address);
    }

    function setSignerAddress(address _signer_address)
        external onlyOwner
    {
        signer_address =  _signer_address;
    }

    function setMainAddress(address _main_address)
        external onlyOwner
    {
        main_address = _main_address;
    }

    function setDaysBetweenMints(uint256 _days)
        external onlyOwner
    {
        daysBetweenMints = _days;
    }

    function setCosmogPrice(uint256 _days)
        external onlyOwner
    {
        cosmog_price = _days;
    }

    function setFactionMetadata(Faction faction, string memory metadataUri)
        external onlyApproved
    {
        faction_metadata_url_mapping[faction] = metadataUri;
    }

    function setFactionSuccessProbability(Faction faction, uint256 proba)
        external onlyApproved
    {
        factionSuccessProbability[faction] = proba;
    }

    function uri(uint256 tokenId)
        public view
        override
        returns (string memory)
    {
        return faction_metadata_url_mapping[Faction(tokenId)];
    }

    function withdraw()
        external onlyOwner
        payable
    {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw");
        bool success = payable(main_address).send(amount);
        require(success, "Failed to withdraw");
    }

    function transferCosmogs(address addr, uint256 amount)
        external onlyApproved
    {
        require(token_contract.balanceOf(address(this)) > 0, "Not enough Cosmogs in the contract to send");
        token_contract.transfer(addr, amount);
    }

    function addApprovedAddress(address addr)
        external onlyOwner
    {
        approvedAddresses[addr] = true;
    }

    function removeApprovedAddress(address addr)
        external onlyOwner
    {
        approvedAddresses[addr] = false;
    }

    function randomBetween(uint256 min, uint256 max)
        internal view
        returns (uint)
    {
        require (max > min, "max have to be > min");
        string memory difficulty = Strings.toString(block.difficulty);
        string memory timestamp = Strings.toString(block.timestamp);

         
        bytes memory key = abi.encodePacked(difficulty, timestamp, msg.sender);
        uint random = uint(keccak256(key)) % (max - min);
        random += min;
        return random;
    }

    receive()
        external payable
    {
    }

    fallback()
        external
    {
    }
}

 
 

pragma solidity ^0.8.0;

 
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

     
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

     
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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

 
 

pragma solidity ^0.8.0;



 
interface IERC1155Receiver is IERC165 {
     
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

     
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
