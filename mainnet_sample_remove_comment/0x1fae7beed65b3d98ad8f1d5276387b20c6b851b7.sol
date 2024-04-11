
 

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface INEC {

    function burningEnabled() external returns(bool);

    function controller() external returns(address);

    function enableBurning(bool _burningEnabled) external;

    function burnAndRetrieve(uint256 _tokensToBurn) external returns (bool success);

    function totalPledgedFees() external view returns (uint);

    function totalSupply() external view returns (uint);

    function destroyTokens(address _owner, uint _amount
      ) external returns (bool);

    function generateTokens(address _owner, uint _amount
      ) external returns (bool);

    function changeController(address _newController) external;

    function balanceOf(address owner) external returns(uint256);

    function transfer(address owner, uint amount) external returns(bool);
}

contract TokenController {

    function proxyPayment(address _owner) public payable returns(bool);

    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);

    function onBurn(address payable _owner, uint _amount) public returns(bool);
}


contract NectarController is TokenController, Ownable {

    INEC public tokenContract;    
    
    event UpgradedController (address newAddress);

    
    

    constructor (
        address _tokenAddress
    ) public {
        tokenContract = INEC(_tokenAddress);  
    }

 
 
 

    
     
    
    function proxyPayment(address _owner) public payable returns(bool) {
        require(false);
        return false;
    }


    
     
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
        return true;
    }

    
     
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool)
    {
        return true;
    }

    
     
    
    
    
    function onBurn(address payable _owner, uint _tokensToBurn) public
        returns(bool)
    {
         
        require(msg.sender == address(tokenContract));

        require (tokenContract.destroyTokens(_owner, _tokensToBurn));

        return true;
    }

    
    
    function upgradeController(address _newControllerAddress) public onlyOwner {
        tokenContract.changeController(_newControllerAddress);
        emit UpgradedController(_newControllerAddress);
    }
    
    
    function deleteAndReplaceTokens(address _currentOwner, address _newOwner) public onlyOwner returns(bool) {
        
        uint256 tokenBalance = tokenContract.balanceOf(_currentOwner);
        
        require(tokenContract.destroyTokens(_currentOwner, tokenBalance));
        require(tokenContract.generateTokens(_newOwner, tokenBalance));
        
        return true;
    }

}