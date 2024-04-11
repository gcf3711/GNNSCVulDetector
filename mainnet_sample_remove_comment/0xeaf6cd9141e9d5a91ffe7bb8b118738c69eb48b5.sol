 

 

 
pragma solidity 0.8.7;
 
 
 
 
 
 
 
contract Ownable
{

   
  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

   
  address public owner;

   
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

   
  constructor()
  {
    owner = msg.sender;
  }

   
  modifier onlyOwner()
  {
    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

   
  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {
    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}

abstract contract NFTInterface {
    function mint(address _to,uint256 _tokenId,string calldata _uri)  virtual external ;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) virtual external;
    
    function balanceOf(address tokenOwner) virtual public view returns (uint balance);
    
    function ownerOf(uint __artId) virtual public view returns ( address artOwner);
    
    function safeTransferFrom( address _from, address _to, uint256 _tokenId) virtual public;
    
    function tokenURI(uint256 _tokenId) virtual external returns (string memory);
     
    function approveResaleNFT( uint256 _tokenId ) virtual public;
    function approveAuctionNFT( uint256 _tokenId ) virtual public;
    
    function addNftPurchaser(uint __artId,uint __tokenId, address  __buyer) public virtual ; 
    function deleteNftPurchaser(uint __artId, address  seller  )virtual public ;
    function deleteArtworkPurchased(uint __tokenId, address  exOwner  ) virtual public ;
    
    function getArtIdOwners(uint __artId) virtual public view returns (address [] memory);
    
    function getArtworksOwnedBy(address __buyer) virtual public view returns (uint [] memory);
    
    function getNftTokenIds(uint __artId) virtual public view returns (uint [] memory);
 }
 
contract NFTsaleRio is  Ownable{ 
    
    address nftAddress = 0xe0d189176C68F2fc55BE8FeF32E9883b287f739a ; 
    NFTInterface public tokenNFT = NFTInterface(nftAddress);
    
    bool isActive;
    
    mapping(uint => address payable) public artistAddress;
    mapping(uint => uint) public feeArtclub;
    mapping(uint => uint) priceNFT;
    mapping(uint => bool) public isNftForSale;

    event ArtPurchasingDetail(
           string indexed __uri
        );
    constructor()
  {
     owner = msg.sender;
     isActive = true;
  }
    
    function setArtNFTContract( address  _contract)  public  returns (bool success) {
        require(msg.sender == owner,"Only theArtClub can add NFTs");
        nftAddress = _contract ; 
        tokenNFT = NFTInterface(nftAddress);
        return true;
    }
    function setArtNFT(uint256[] memory __artId , address[] memory  __artist, uint[] memory __price, uint[] memory __fee) public {
        require(msg.sender == owner,"Only theArtClub can add NFTs");
        for(uint8 i = 0; i < __artId.length; i++) {
            priceNFT[__artId[i]] = __price[i];
            artistAddress[__artId[i]] = payable(__artist[i]);
            feeArtclub[__artId[i]] = __fee[i];

        }
    }
    function buyArtIdNFT (uint __artId, uint __tokenId, string calldata __uri)  external payable returns (bool success) { 
        require(isActive,"Contract has to be active"); 
        require(artistAddress[__artId]!=address(0),"ADDRESS artist unknown");
         
        uint vendita = priceNFT[__artId];
        if(msg.value>priceNFT[__artId]){ vendita = msg.value; } 
        uint commissione = vendita * feeArtclub[__artId] / 100;
        uint quotaArtista = vendita - commissione ;
        
        payable(address(uint160(owner))).transfer(commissione);
       
            artistAddress[__artId].transfer(quotaArtista);

            tokenNFT.mint(msg.sender,__tokenId,__uri);
       
            tokenNFT.addNftPurchaser(__artId,__tokenId,msg.sender); 
            priceNFT[__tokenId] = vendita;
        
            emit ArtPurchasingDetail( __uri ); 
        
        return true;
    }
    
     function resaleNFT (uint256 _tokenId,uint __price) external returns (bool success){
        require(msg.sender == tokenNFT.ownerOf(_tokenId),"Only NFT owner can act here");
        priceNFT[_tokenId]=__price;
        tokenNFT.approveResaleNFT( _tokenId);
        isNftForSale[_tokenId]=true;
     return true;
    }
     
    function buyResaleNFT (uint __artId, uint __tokenId)  external payable returns (bool success) { 
        require(isActive,"Contract has to be active"); 
        address proprietario = tokenNFT.ownerOf(__tokenId);
         
        uint vendita = priceNFT[__tokenId];  
        uint commissione = vendita * 10 /100;
        uint quotaArtista = vendita * 10 /100;
        uint quotaProprietario = vendita - commissione - quotaArtista;
        
        payable(address(uint160(proprietario))).transfer(quotaProprietario);
        
        payable(address(uint160(owner))).transfer(commissione);
       
        artistAddress[__artId].transfer(quotaArtista);

        tokenNFT.safeTransferFrom(proprietario, msg.sender, __tokenId);
       
            isNftForSale[__tokenId] = false;
            
            tokenNFT.addNftPurchaser(__artId,__tokenId,msg.sender); 

            tokenNFT.deleteNftPurchaser(__artId,proprietario);
            
            tokenNFT.deleteArtworkPurchased(__tokenId,proprietario);
            
        return true;
    }
     
    
    function changeStato(bool stato) public {
        require(msg.sender == owner,"Solo TheArtClub puo disattivare il contratto");
        isActive = stato;
    }
    

   function getArtIdOwners(uint __artId) public view returns (address [] memory) {
  		return tokenNFT.getArtIdOwners(__artId);
	}
    
    function getArtworksOwnedBy(address __buyer) public view returns (uint [] memory) {
  		return tokenNFT.getArtworksOwnedBy(__buyer);
	}
    function getNftTokenIds(uint __artId) public view returns (uint [] memory) {
  		return tokenNFT.getNftTokenIds(__artId);
	}
    function getOwnerOf(uint __artId) public view returns (address) {
  		return tokenNFT.ownerOf(__artId);
	}
    function getPriceNFT(uint __artId) public view  returns (uint){
  		return priceNFT[__artId];
	}
	 

    receive () payable  external {
        revert(); 
    }
}