 

 

 
pragma solidity >=0.4.21 <0.7.0;


 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 
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

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MU_Membership is Ownable{
     
     
     
    receive() payable external {
    }

    struct Gold {
        address payable owner;
        uint price;
        bool sell_approve;
    }
     
    mapping (uint => Gold) public gold_list;
     
    uint public gold_owner_count = 0;
     
    uint constant gold_price = 15e18;
     
    uint constant gold_max = 15;
    event GoldPurchased (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event GoldSell (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event GoldApprove (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event GoldBought (
        address payable owner,
        uint price,
        bool sell_approve
    );

    struct Silver {
        address payable owner;
        uint price;
        bool sell_approve;
    }
     
    mapping (uint => Silver) public silver_list;
     
    uint public silver_owner_count = 0;
     
    uint constant silver_price = 1e18;
     
    uint constant silver_max = 150;
    event SilverPurchased (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event SilverSell (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event SilverApprove (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event SilverBought (
        address payable owner,
        uint price,
        bool sell_approve
    );    

    struct Bronze {
        address payable owner;
        uint price;
        bool sell_approve;
    }
     
    mapping (uint => Bronze) public bronze_list;
     
    uint public bronze_owner_count = 0;
     
    uint constant bronze_price = 25e16;
     
    uint constant bronze_max = 1500;
    event BronzePurchased (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event BronzeSell (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event BronzeApprove (
        address payable owner,
        uint price,
        bool sell_approve
    );
    event BronzeBought (
        address payable owner,
        uint price,
        bool sell_approve
    );        


     
     
     

     
    function gold_buy() public payable {
         
        require( gold_owner_count < gold_max );
         
        require( msg.value == gold_price );
         
        gold_list[gold_owner_count] = Gold(msg.sender, 0, false);
        gold_owner_count++;
        emit GoldPurchased(msg.sender, 0, false);
    }
     
     
    function gold_sell(uint card_id, uint _price) public payable returns(bool) {
         
        require(card_id < gold_owner_count, "Card ID can not be exceed current card owners amount");
         
        require(_price > 0, "Card price need to be set greater than zero.");
        gold_list[card_id].price = _price;
        emit GoldSell(msg.sender, gold_list[card_id].price, gold_list[card_id].sell_approve);
        return true;
    }
     
    function gold_approve (uint card_id) public returns(bool) {
         
        require(card_id < gold_owner_count, "Card id has to be less than card owner amount");
         
        require(msg.sender == gold_list[card_id].owner, "Only card owner can approve the card selling");
        gold_list[card_id].sell_approve = true;
        emit GoldApprove(msg.sender, gold_list[card_id].price, gold_list[card_id].sell_approve);
        return true;
    }
     
    function gold_request_buy (uint card_id) public payable {
         
        require( gold_list[card_id].price > 0 );
         
        require( msg.value == gold_list[card_id].price );
         
        require( gold_list[card_id].sell_approve == true );
         
        gold_list[card_id].owner.transfer(msg.value);
         
        gold_list[card_id].owner = msg.sender;
        gold_list[card_id].sell_approve = false;
        gold_list[card_id].price = 0;
        emit GoldBought(msg.sender, gold_list[card_id].price, gold_list[card_id].sell_approve);
    }
     
     
     
     
    function silver_buy() public payable {
         
        require( silver_owner_count < silver_max );
         
        require( msg.value == silver_price );
         
        silver_list[silver_owner_count] = Silver(msg.sender, 0, false);
        silver_owner_count++;
        emit SilverPurchased(msg.sender, 0, false);
    }
     
     
    function silver_sell(uint card_id, uint _price) public payable returns(bool) {
         
        require(card_id < silver_owner_count, "Card ID can not be exceed current card owners amount");
         
        require(_price > 0, "Card price need to be set greater than zero.");
        silver_list[card_id].price = _price;
        emit SilverSell(msg.sender, silver_list[card_id].price, silver_list[card_id].sell_approve);
        return true;
    }
     
    function silver_approve (uint card_id) public returns(bool) {
         
        require(card_id < silver_owner_count, "Card id has to be less than card owner amount");
         
        require(msg.sender == silver_list[card_id].owner, "Only card owner can approve the card selling");
        silver_list[card_id].sell_approve = true;
        emit SilverApprove(msg.sender, silver_list[card_id].price, silver_list[card_id].sell_approve);
        return true;
    }
     
    function silver_request_buy (uint card_id) public payable {
         
        require( silver_list[card_id].price > 0 );
         
        require( msg.value == silver_list[card_id].price );
         
        require( silver_list[card_id].sell_approve == true );
         
        silver_list[card_id].owner.transfer(msg.value);
         
        silver_list[card_id].owner = msg.sender;
        silver_list[card_id].sell_approve = false;
        silver_list[card_id].price = 0;
        emit SilverBought(msg.sender, silver_list[card_id].price, silver_list[card_id].sell_approve);
    }    
     
     
     
     
    function bronze_buy() public payable {
         
        require( bronze_owner_count < bronze_max );
         
        require( msg.value == bronze_price );
         
        bronze_list[bronze_owner_count] = Bronze(msg.sender, 0, false);
        bronze_owner_count++;
        emit BronzePurchased(msg.sender, 0, false);
    }
     
     
    function bronze_sell(uint card_id, uint _price) public payable returns(bool) {
         
        require(card_id < bronze_owner_count, "Card ID can not be exceed current card owners amount");
         
        require(_price > 0, "Card price need to be set greater than zero.");
        bronze_list[card_id].price = _price;
        emit BronzeSell(msg.sender, bronze_list[card_id].price, bronze_list[card_id].sell_approve);
        return true;
    }
     
    function bronze_approve (uint card_id) public returns(bool) {
         
        require(card_id < bronze_owner_count, "Card id has to be less than card owner amount");
         
        require(msg.sender == bronze_list[card_id].owner, "Only card owner can approve the card selling");
        bronze_list[card_id].sell_approve = true;
        emit BronzeApprove(msg.sender, bronze_list[card_id].price, bronze_list[card_id].sell_approve);
        return true;
    }
     
    function bronze_request_buy (uint card_id) public payable {
         
        require( bronze_list[card_id].price > 0 );
         
        require( msg.value == bronze_list[card_id].price );
         
        require( bronze_list[card_id].sell_approve == true );
         
        bronze_list[card_id].owner.transfer(msg.value);
         
        bronze_list[card_id].owner = msg.sender;
        bronze_list[card_id].sell_approve = false;
        bronze_list[card_id].price = 0;
        emit BronzeBought(msg.sender, bronze_list[card_id].price, bronze_list[card_id].sell_approve);
    }    

    function reclaimETH() external onlyOwner{
        msg.sender.transfer(address(this).balance);
    }
}