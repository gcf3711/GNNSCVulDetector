
 

 

 

 

 


 

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

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 


 

pragma solidity ^0.8.0;


 
abstract contract ERC165 is IERC165 {
     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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


 
interface IERC1155MetadataURI is IERC1155 {
     
    function uri(uint256 id) external view returns (string memory);
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







 
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

     
    mapping(uint256 => mapping(address => uint256)) private _balances;

     
    mapping(address => mapping(address => bool)) private _operatorApprovals;

     
    string public _uri;

     
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



contract Music is ERC1155,Ownable{
    using Strings for uint256;
    uint256 max_num;
    uint256 _total;
    uint256 _ask_total;
    uint256 public _brokerage;
    uint256 public _royalty;
	
    mapping(uint256 => Musics) public _token2create;
    mapping(uint256 => Ask) public _id2ask;

    mapping(string =>  uint256) public user_sell;
	mapping(address => uint256) public user_balance;

    struct Ask {
        uint256 id;
        uint256 token_id;
        uint256 num;
        uint256 price;
        uint256 end_time;
        bool is_set; 
        address seller;
    }


    struct Musics {
        address  creater;
        string   name;  
        string   author;
    }


   
    event createAsks(
        uint256 indexed id,
        uint256 indexed token_id,
        uint256 num,
        uint256 price,
        address seller,
		uint256 end_time
    );


   
    event upAsks(
        uint256 indexed id,
        uint256 price
    );
  
    event upAsksTime(
        uint256 indexed id,
        uint256 end_time
    );

    event orderAsks(
        uint256 indexed id,
        uint256 indexed token_id,
        uint256 price,
        uint256 num,
        address buyer
    );

 
    event canceleAsks(
        uint256 indexed id,
        address indexed seller
    );


    constructor() ERC1155("https://muverse.info/game/") {
        _brokerage = 2; 
        _royalty = 8;   
        max_num = 100;   
        _ask_total = 0; 
    }
	
    function mint(
        uint256 amount,
        string memory _name,
        string memory _author
    ) external {
        require(
                amount <= max_num,
                " num must < max_num"
        );



        _token2create[_total] =  Musics({
            creater:msg.sender,
            name:_name,
            author:_author
        });
        _mint(msg.sender, _total, amount, '');
        _total++;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

   
    function createUserOf(uint256 id) public view  returns (address) {
        return _token2create[id].creater;
    }

   
     function userWithdraw() external {
	 
        require(user_balance[msg.sender] > 0 ,"your balance must > 0");
        require( address(this).balance >= user_balance[msg.sender] , "Balance must be positive");
        (bool success, ) = msg.sender.call{value: user_balance[msg.sender]}("");
        require(success == true);
		user_balance[msg.sender] = 0;
    }


    
    function setMaxNum(uint256 _num) public onlyOwner {
        max_num = _num;
    }

   
    function setBrokerage(uint256 _num) public onlyOwner {
        require(_num <100,"_num must < 100");
        require( (_num + _royalty) < 100 , "");
        _brokerage = _num;
    }

   
    function setRoyalty(uint256 _num) public onlyOwner {
        require(_num <100,"_num must < 100");
        require(_num+_brokerage <100,"");
        _royalty = _num;
    }

   
    function withdraw(uint256 _balance) external onlyOwner {
        require(_balance <= address(this).balance,"_balance must < owners");
        address payable _owner = payable(owner());
        _owner.transfer(_balance);
    }

  



   
   function createAsk(
        uint256 token_id,
        uint256 price,
        uint256 num,
    
        uint256 end_time
    ) external {
        require(
                num > 0,
                " num must > 0"
            );

        require(
            balanceOf(msg.sender,token_id) >= (num+user_sell[string(abi.encodePacked(msg.sender, token_id.toString()))]),
            "token_id num is engouh"
        );

        require(price > 1000, "price too low");
        if(end_time > 0){
            require(end_time > block.timestamp, "end_time is must > now");
        }else{
            end_time = 0;
        }


        _id2ask[_ask_total] = Ask({
                id: _ask_total,
                token_id: token_id,
                num: num,
                price: price,
         
                end_time: end_time,
                seller: msg.sender,
                is_set : true
            });
        
        user_sell[string(abi.encodePacked(msg.sender, token_id.toString()))] =   user_sell[string(abi.encodePacked(msg.sender, token_id.toString()))] +num;


        emit createAsks({
            id : _ask_total,
            token_id: token_id,
            num: num,
            price: price,
            seller: msg.sender,
			end_time:end_time
        });
        _ask_total ++;
    }


   
    function cancelAsk(uint256 sell_id)
        external
    {
        require(_id2ask[sell_id].seller == msg.sender, "is not you");
        require(_id2ask[sell_id].is_set == true, "is used");
        user_sell[string(abi.encodePacked(msg.sender, _id2ask[sell_id].token_id.toString()))]  =   user_sell[string(abi.encodePacked(msg.sender, _id2ask[sell_id].token_id.toString()))] - _id2ask[sell_id].num;
        delete _id2ask[sell_id];

        emit canceleAsks({id: sell_id, seller: msg.sender});
    }



  
    function upAsk(uint256 sell_id,uint256 price)
        external
    {
        require(_id2ask[sell_id].seller == msg.sender, "is not you");
        require(_id2ask[sell_id].is_set == true, "is used");

        require(
            balanceOf(msg.sender,_id2ask[sell_id].token_id) >= _id2ask[sell_id].num,
            "token_id num is engouh"
        );

        require(price > 1000, "price too low");

        _id2ask[sell_id].price = price;

        emit upAsks({id: sell_id,price :price});
    }

    

    function upAskTime(uint256 sell_id,uint256 end_time)
        external
    {
        require(_id2ask[sell_id].seller == msg.sender, "is not you");
        require(_id2ask[sell_id].is_set == true, "is used");

        require(
            balanceOf(msg.sender,_id2ask[sell_id].token_id) >= _id2ask[sell_id].num,
            "token_id num is not engouh"
        );
        if(end_time > 0){
            require(end_time > block.timestamp, "end_time is must > now");
        }else{
            end_time = 0;
        }
       

        _id2ask[sell_id].end_time = end_time;

        emit upAsksTime({id: sell_id,end_time :end_time});
    }


   
    function orderAsk(uint256 sell_id,uint256 buy_num)
        external
        payable
    
    {
        require(_id2ask[sell_id].is_set, "is selled");
        require(
            buy_num <= _id2ask[sell_id].num,
            "token_id num is not engouh"
        );
        require(
            balanceOf(_id2ask[sell_id].seller,_id2ask[sell_id].token_id) >= buy_num,
            "token_id num is not engouh"
        );
        uint256 sell_price = _id2ask[sell_id].price * buy_num;
     
        require( msg.value >= sell_price, "price not enghou");

        if(_id2ask[sell_id].end_time  > 0){
            require(_id2ask[sell_id].end_time >= block.timestamp, "order is over ");
        }

        _id2ask[sell_id].num = _id2ask[sell_id].num - buy_num;
        if(_id2ask[sell_id].num < 1){
            _id2ask[sell_id].is_set = false;
        }

        _safeTransferFrom(_id2ask[sell_id].seller,msg.sender,_id2ask[sell_id].token_id,buy_num,'');
        user_sell[string(abi.encodePacked(_id2ask[sell_id].seller,_id2ask[sell_id].token_id.toString()))] =  user_sell[string(abi.encodePacked(_id2ask[sell_id].seller,_id2ask[sell_id].token_id.toString()))]  - buy_num;

        uint256 owner_price = sell_price*(100 - _brokerage - _royalty)/100;
        uint256 create_price = sell_price*_royalty/100;


        address seller = payable(_id2ask[sell_id].seller);
  
        (bool sel_is, ) = seller.call{value: owner_price}("");
        require(sel_is, "failed");
 

		user_balance[_token2create[_id2ask[sell_id].token_id].creater] = user_balance[_token2create[_id2ask[sell_id].token_id].creater]+create_price;
       

        emit orderAsks({id: sell_id,token_id :_id2ask[sell_id].token_id,price:sell_price,num:buy_num,buyer:msg.sender});

        

    } 
   
    function getUserNft(address _adr) public  view returns (uint256[] memory, uint256[] memory) {
        uint256 j = 0;
        uint256 l = 0;

        uint256 is_num = 0;
        for(uint256 i=0;i<_total;i++){
            if(balanceOf(_adr,i)>0){
                j++;   
            }
        }
        if(j > 0){
            uint256[] memory tokenIds =  new uint256[](j);
            uint256[] memory nums =  new uint256[](j);

            for(uint256 t=0;t<_total;t++){
                is_num = balanceOf(_adr,t);
                if(is_num>0){
                    tokenIds[l] =  t;
                    nums[l] = is_num;
                    l++;
                }
                if(l == j){
                    break;
                }
            }

            return (tokenIds,nums);
        }else{
            return (new uint256[](0),new uint256[](0));
        }


    }


 
    function getOrderList() public view returns (uint256[] memory, uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory,address[] memory) {
        uint256 j = 0;
        uint256 l = 0;
        for(uint256 i=0;i<=_ask_total;i++){
            if(_id2ask[i].is_set){
                j++;   
            }
        }
        if(j > 0){
            uint256[] memory order_id =  new uint256[](j);
            uint256[] memory token_id =  new uint256[](j);
            uint256[] memory nums =  new uint256[](j);
            uint256[] memory price =  new uint256[](j);
            uint256[] memory times =  new uint256[](j);
            address[] memory sellers =  new address[](j);

            for(uint256 t=0;t<_total;t++){
                if(_id2ask[t].is_set){
                    order_id[l] = t;
                    token_id[l] = _id2ask[t].token_id;
                    nums[l] = _id2ask[t].num;
                    price[l] =_id2ask[t].price;
                    times[l] = _id2ask[t].end_time;
                    sellers[l] = _id2ask[t].seller;
                }
                if(l == j){
                    break;
                }
            }
            return (order_id,token_id,nums,price,times,sellers);
        }else{
            return (new uint256[](0),new uint256[](0),new uint256[](0),new uint256[](0),new uint256[](0),new address[](0));
        }
    }

    
    function gift(uint256 my_token_id,uint256 num,address friend) public{
        require(
                num > 0,
                " num must > 0"
            );
        require(
            balanceOf(msg.sender,my_token_id) >= num,
            "token_id num is not engouh"
        );

        _safeTransferFrom(msg.sender,friend,my_token_id,num,'');
    }


    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return
        string(
            abi.encodePacked(_uri, tokenId.toString())
        );
    }


}