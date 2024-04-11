 


 

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
 

pragma solidity ^0.7.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () {
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

 

pragma solidity 0.7.6;

interface ITokenRegistry {
     
    function setTokenLimit(address _tokenAddress, uint256 _newLimit) external;

     
    function getTokenLimit(address _tokenAddress)
        external
        view
        returns (uint256);

     
    function setETHLimit(uint256 _newLimit) external;

     
    function getETHLimit() external view returns (uint256);

     
    function setTokenWrapperAddress(
        address _tokenAddress,
        address _wrapperAddress
    ) external;

     
    function getTokenWrapperAddress(address _tokenAddress)
        external
        view
        returns (address);
}
 
pragma solidity 0.7.6;




 

contract TokenRegistry is Ownable, ITokenRegistry {
    uint256 private ethLimit;
    mapping(address => uint256) private tokenLimits;
    mapping(address => address) private tokenWrappers;

    event LogETHLimitChanged(uint256 _newLimit, address indexed _triggeredBy);
    event LogTokenLimitChanged(uint256 _newLimit, address indexed _triggeredBy);
    event LogTokenWrapperChanged(address indexed _newWrapperAddress, address indexed _triggeredBy);

    modifier notZeroAddress(address _tokenAddress) {
        require(_tokenAddress != address(0), "INVALID_TOKEN_ADDRESS");
        _;
    }

    constructor() {
        ethLimit = 1 ether;
        emit LogETHLimitChanged(ethLimit, msg.sender);
    }

     
    function setETHLimit(uint256 _newLimit) external override onlyOwner {
        ethLimit = _newLimit;
        emit LogETHLimitChanged(_newLimit, msg.sender);
    }

     
    function setTokenLimit(address _tokenAddress, uint256 _newLimit)
        external
        override
        onlyOwner
        notZeroAddress(_tokenAddress)
    {
        tokenLimits[_tokenAddress] = _newLimit;
        emit LogTokenLimitChanged(_newLimit, msg.sender);
    }

     
     
     

     
    function getETHLimit() external view override returns (uint256) {
        return ethLimit;
    }

     
    function getTokenLimit(address _tokenAddress)
        external
        view
        override
        returns (uint256)
    {
        return tokenLimits[_tokenAddress];
    }

      
    function setTokenWrapperAddress(address _tokenAddress, address _wrapperAddress) 
        external
        override
        onlyOwner
        notZeroAddress(_tokenAddress)
    {
        tokenWrappers[_tokenAddress] = _wrapperAddress;
        emit LogTokenWrapperChanged(_wrapperAddress, msg.sender);
    }

     
    function getTokenWrapperAddress(address _tokenAddress) 
        external
        view 
        override
        returns (address)
    {
        return tokenWrappers[_tokenAddress];
    }
}
