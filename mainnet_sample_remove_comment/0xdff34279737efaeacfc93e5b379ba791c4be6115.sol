 


 

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
        require(account != address(0), "ERC1155: balance query for the zero address");
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
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
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
            "ERC1155: transfer caller is not owner nor approved"
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

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

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

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

     
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

     
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
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

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

     
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

     
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
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



 
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}

 

pragma solidity ^0.8.0;



 
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
 

 

pragma solidity ^0.8.2;






abstract contract ClonexCharacterInterface {
    function mintTransfer(address to) public virtual returns(uint256);
}

abstract contract ERC721 {
    function ownerOf(uint256 tokenId) public view virtual returns (address);
}

contract Mintvial is ERC1155, Ownable, ERC1155Burnable {
    using SafeMath for uint256;

    uint256 tokenId = 1;
    uint256 amountMinted = 0;
    uint256 limitAmount = 20000;
    uint256 private tokenPrice = 50000000000000000;  

    address clonexContractAddress;

    mapping (address => mapping (uint256 => bool)) usedToken;
    mapping (address => bool) authorizedContract;
    mapping (address => bool) isErc721;

    event priceChanged(uint256 newPrice);
                                
    bool publicSales = false;
    bool salesStarted = false;
    bool migrationStarted = false;
    
    constructor() ERC1155("ipfs://QmQqMF7izNAaU9CY3qV9ZGs4Aksv6ywjx8261khgzQbReW") {
         
        authorizedContract[0x20fd8d8076538B0b365f2ddd77C8F4339f22B970] = true;  
        authorizedContract[0x25708f5621Ac41171F3AD6D269e422c634b1E96A] = true;  
        authorizedContract[0x50B8740D6a5CD985e2B8119Ca28B481AFa8351d9] = true;  
        authorizedContract[0xc541fC1Aa62384AB7994268883f80Ef92AAc6399] = true;  
        authorizedContract[0xd3f69F10532457D35188895fEaA4C20B730EDe88] = true;  
        authorizedContract[0x2250D7c238392f4B575Bb26c672aFe45F0ADcb75] = true;  
        authorizedContract[0xAE3d8D68B4F6c3Ee784b2b0669885a315BA77C08] = true;  
        authorizedContract[0xDE8350B34b2e6FC79aABCc7030fD9a862562E821] = true;  

         
        authorizedContract[0xCD1DBc840E1222A445be7C1D8ecB900F9D930695] = true;  
        
         
        isErc721[0x20fd8d8076538B0b365f2ddd77C8F4339f22B970] = true;  
        isErc721[0x25708f5621Ac41171F3AD6D269e422c634b1E96A] = true;  
        isErc721[0x50B8740D6a5CD985e2B8119Ca28B481AFa8351d9] = true;  
        isErc721[0xc541fC1Aa62384AB7994268883f80Ef92AAc6399] = true;  
        isErc721[0xd3f69F10532457D35188895fEaA4C20B730EDe88] = true;  
        isErc721[0x2250D7c238392f4B575Bb26c672aFe45F0ADcb75] = true;  
        isErc721[0xAE3d8D68B4F6c3Ee784b2b0669885a315BA77C08] = true;  
        isErc721[0xDE8350B34b2e6FC79aABCc7030fD9a862562E821] = true;  
    }
    
     
    function setClonexContract(address contractAddress) public onlyOwner {
        clonexContractAddress = contractAddress;
    }

     
    function toggleSales() public onlyOwner {
        salesStarted = !salesStarted;
    }

     
    function toggleMigration() public onlyOwner {
        migrationStarted = !migrationStarted;
    }
    
     
    function toggleContractAuthorization(address contractAddress) public onlyOwner {
        authorizedContract[contractAddress] = !authorizedContract[contractAddress];
    }

     
    function toggleContractType(address contractAddress) public onlyOwner {
        isErc721[contractAddress] = !isErc721[contractAddress];
    }
    
     
    function isContractAuthorized(address contractAddress) view public returns(bool) {
        return authorizedContract[contractAddress];
    }

     
    function isContractErc721(address contractAddress) view public returns(bool) {
        return isErc721[contractAddress];
    }

     
    function mint(address[] memory contractIds, uint256[] memory tokenIds, uint256 amountToMint) public payable returns(uint256) {
         
        require(salesStarted == true, "Sales have not started");
        uint256 amount = amountToMint;
        
         
        if(!publicSales) {
            amount = 0;
            for(uint256 i = 0; i < contractIds.length; i++) {
                 
                require(isContractAuthorized(contractIds[i]) == true, "Contract is not authorized");

                 
                if(isErc721[contractIds[i]]) {
                     
                    ERC721 contractAddress = ERC721(contractIds[i]);
                    require(contractAddress.ownerOf(tokenIds[i]) == msg.sender, "Doesn't own the token");
                } else {
                     
                    ERC1155 contractAddress = ERC1155(contractIds[i]);
                    require(contractAddress.balanceOf(msg.sender, tokenIds[i]) > 0, "Doesn't own the token");
                }
                
                require(checkIfRedeemed(contractIds[i], tokenIds[i]) == false, "Token already redeemed");
                
                 
                if(contractIds[i] == 0x20fd8d8076538B0b365f2ddd77C8F4339f22B970) amount += 1; 
                else amount += 3;
            }
        }
        
         
        require(msg.value == tokenPrice.mul(amount), "Not enough money");
        require(amount + amountMinted <= limitAmount, "Limit reached");

        for(uint256 i = 0; i < contractIds.length; i++) {
            usedToken[contractIds[i]][tokenIds[i]] = true;
        }
        
        _mint(msg.sender, tokenId, amount, "");
        
        uint256 prevTokenId = tokenId;
        tokenId++;
        amountMinted = amountMinted + amount;
        return prevTokenId;
    }
    
     
    function airdropGiveaway(address[] memory to, uint256[] memory amountToMint) public onlyOwner {
        for(uint256 i = 0; i < to.length; i++) {
            require(amountToMint[i] + amountMinted <= limitAmount, "Limit reached");
            _mint(msg.sender, tokenId, amountToMint[i], "");
            tokenId++;
            amountMinted = amountMinted + amountToMint[i];
        }
    }
    
     
    function migrateToken(uint256 id) public returns(uint256) {
        require(migrationStarted == true, "Migration has not started");
        require(balanceOf(msg.sender, id) > 0, "Doesn't own the token");  
        burn(msg.sender, id, 1);  
        ClonexCharacterInterface clonexContract = ClonexCharacterInterface(clonexContractAddress);
        uint256 mintedId = clonexContract.mintTransfer(msg.sender);  
        return mintedId;  
    }

     
    function forceMigrateToken(uint256 id) public onlyOwner {
        require(balanceOf(msg.sender, id) > 0, "Doesn't own the token");  
        burn(msg.sender, id, 1);  
        ClonexCharacterInterface clonexContract = ClonexCharacterInterface(clonexContractAddress);
        uint256 mintedId = clonexContract.mintTransfer(msg.sender);  
    }
    
     
    function checkIfRedeemed(address _contractAddress, uint256 _tokenId) view public returns(bool) {
        return usedToken[_contractAddress][_tokenId];
    }
    
     
    function togglePublicSales() public onlyOwner {
        publicSales = !publicSales;
    }
    
     
    function getPrice() view public returns(uint256) { 
        return tokenPrice;
    }
    
     
    function getAmountMinted() view public returns(uint256) {
        return amountMinted;
    }
    
     
    function setPrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
        emit priceChanged(tokenPrice);
    }
    
     
    function withdrawFunds() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
}

 

pragma solidity ^0.8.0;

 
 
 

 
library SafeMath {
     
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

     
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

     
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
             
             
             
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

     
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

     
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

     
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

     
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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
