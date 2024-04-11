 
pragma experimental ABIEncoderV2;


 

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
 

pragma solidity ^0.6.12;









contract BurningStore is Ownable {
    using SafeMath for uint256;

    struct CollectionData {
        mapping (uint256 => uint256) pricePerOptionId;
        mapping (uint256 => uint256) availableQtyPerOptionId;
        address saleBeneficiary;
        uint256 collectionFee;
    }

    IERC20 public acceptedToken;
    address storeFeeAddresses;

    uint256 constant FEE_PRECISION = 10000;

    mapping (address => CollectionData) collectionsData;

    event Bought(address indexed _collectionAddress, uint256[] _optionIds, address _beneficiary, uint256 _price);
    event SetCollectionData(address indexed _collectionAddress, uint256[] _optionIds, uint256[] _availableQtys, uint256[] _prices);

     
    constructor(
        IERC20 _acceptedToken,
        address _storeFeeAddresses,
        address[] memory _collectionAddresses,
        address[] memory _saleBeneficiaryAddresses,
        uint256[] memory _collectionFee,
        uint256[][] memory _collectionOptionIds,
        uint256[][] memory _collectionAvailableQtys,
        uint256[][] memory _collectionPrices
      )
      public {
        acceptedToken = _acceptedToken;
        storeFeeAddresses = _storeFeeAddresses;

        for (uint256 i = 0; i < _collectionAddresses.length; i++) {
            _setCollectionData(_collectionAddresses[i], _saleBeneficiaryAddresses[i], _collectionFee[i], _collectionOptionIds[i], _collectionAvailableQtys[i], _collectionPrices[i]);
        }
    }

     
    function buy(address _collectionAddress, uint256[] calldata _optionIds, address _beneficiary) external {
        CollectionData storage collection = collectionsData[_collectionAddress];

        uint256 amount = _optionIds.length;
        uint256 finalPrice = 0;
        address[] memory beneficiaries = new address[](amount);
        bytes32[] memory items = new bytes32[](amount);

        for (uint256 i = 0; i < amount; i++) {
            uint256 optionId = _optionIds[i];
            require(collection.availableQtyPerOptionId[optionId] > 0, "Sold out item");

             
            uint256 itemPrice = collection.pricePerOptionId[optionId];
            finalPrice = finalPrice.add(itemPrice);

             
            beneficiaries[i] = _beneficiary;

             
            string memory item = itemByOptionId(_collectionAddress, optionId);
            bytes32 itemAsBytes32;
             
            assembly {
                itemAsBytes32 := mload(add(item, 32))
            }
            items[i] = itemAsBytes32;
            collection.availableQtyPerOptionId[optionId] = collection.availableQtyPerOptionId[optionId].sub(1);
        }

         
        _requireBalance(msg.sender, finalPrice);

        uint256 fee = finalPrice / FEE_PRECISION * collection.collectionFee;

         
        require(
            acceptedToken.transferFrom(msg.sender, collection.saleBeneficiary, finalPrice-fee),
            "Transfering finalPrice to sale beneficiary failed"
        );
        require(
            acceptedToken.transferFrom(msg.sender, storeFeeAddresses, fee),
            "Transfering fee failed"
        );

         
 

         
        IERC721Collection(_collectionAddress).issueTokens(beneficiaries, items);

        emit Bought(_collectionAddress, _optionIds, _beneficiary, finalPrice);
    }

     
    function canMint(address _collectionAddress, uint256 _optionId, uint256 _amount) public view returns (bool) {
        CollectionData storage collection = collectionsData[_collectionAddress];

        return collection.availableQtyPerOptionId[_optionId] >= _amount;
    }

     
    function balanceOf(address _collectionAddress, uint256 _optionId) public view returns (uint256) {
        CollectionData storage collection = collectionsData[_collectionAddress];

        return collection.availableQtyPerOptionId[_optionId];
    }

     
    function itemByOptionId(address _collectionAddress, uint256 _optionId) public view returns (string memory) {
        
        (bool success, bytes memory data) = address(_collectionAddress).staticcall(
            abi.encodeWithSelector(
                IERC721Collection(_collectionAddress).wearables.selector,
                _optionId
            )
        );

        require(success, "Invalid wearable");

        return abi.decode(data, (string));
    }

     
    function collectionData(address _collectionAddress, uint256 _optionId) external view returns (
        uint256 availableQty, uint256 price
    ) {
        availableQty = collectionsData[_collectionAddress].availableQtyPerOptionId[_optionId];
        price = collectionsData[_collectionAddress].pricePerOptionId[_optionId];
    }

     
    function setCollectionData(
        address _collectionAddress,
        address _saleBeneficiaryAddress,
        uint256 _collectionFee,
        uint256[] calldata _collectionOptionIds,
        uint256[] calldata _collectionAvailableQtys,
        uint256[] calldata _collectionPrices
    ) external onlyOwner {
        _setCollectionData(_collectionAddress, _saleBeneficiaryAddress, _collectionFee, _collectionOptionIds, _collectionAvailableQtys, _collectionPrices);
    }

     
    function _setCollectionData(
        address _collectionAddress,
        address _saleBeneficiaryAddress,
        uint256 _collectionFee,
        uint256[] memory _collectionOptionIds,
        uint256[] memory _collectionAvailableQtys,
        uint256[] memory _collectionPrices
    ) internal {
         
        CollectionData storage collection = collectionsData[_collectionAddress];

        collection.saleBeneficiary = _saleBeneficiaryAddress;
        collection.collectionFee = _collectionFee;

        for (uint256 i = 0; i < _collectionOptionIds.length; i++) {
            collection.availableQtyPerOptionId[_collectionOptionIds[i]] = _collectionAvailableQtys[i];
            collection.pricePerOptionId[_collectionOptionIds[i]] = _collectionPrices[i];
        }

        emit SetCollectionData(_collectionAddress, _collectionOptionIds, _collectionAvailableQtys, _collectionPrices);
    }

     
    function _requireBalance(address _user, uint256 _price) internal view {
        require(
            acceptedToken.balanceOf(_user) >= _price,
            "Insufficient funds"
        );
        require(
            acceptedToken.allowance(_user, address(this)) >= _price,
            "The contract is not authorized to use the accepted token on sender behalf"
        );
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

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

 

pragma solidity >=0.6.12;


interface IERC20 {
    function balanceOf(address from) external view returns (uint256);
    function transferFrom(address from, address to, uint tokens) external returns (bool);
    function transfer(address to, uint tokens) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function burn(uint256 amount) external;
}

 

pragma solidity ^0.6.12;


interface IERC721Collection {
    function issueToken(address _beneficiary, string calldata _wearableId) external;
    function getWearableKey(string calldata _wearableId) external view returns (bytes32);
    function issued(bytes32 _wearableKey) external view returns (uint256);
    function maxIssuance(bytes32 _wearableKey) external view returns (uint256);
    function issueTokens(address[] calldata _beneficiaries, bytes32[] calldata _wearableIds) external;
    function owner() external view returns (address);
    function wearables(uint256 _index) external view returns (string memory);
    function wearablesCount() external view returns (uint256);
}
