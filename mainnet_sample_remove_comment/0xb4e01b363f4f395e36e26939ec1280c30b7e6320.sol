 

 

 

 


 

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





pragma solidity ^0.8.0;


interface IMain {
   
function transferFrom( address from,   address to, uint256 tokenId) external;
function ownerOf( uint _tokenid) external view returns (address);
}

interface IRewardtoken{
function burn(address holder, uint amount) external;
function mint(address _address , uint amount) external;
function balanceOf(address _address) external returns (uint);
function transferFrom( address from,   address to, uint256 amount) external;
}


contract WobblesStaking is Ownable{
     

  
  

   uint16 public totalNFTStaked ;
  

   
   struct stakeOwner{
     
      uint16[] tokens ;  
      
      uint rewards;
   }
   
    
  struct tokenInfo{
     
      uint64 stakingstartingtime ;
      uint64 rewardstartingtime ;
      uint8 period;
       
       
       
       
    
   
   }
    
   mapping(address => stakeOwner) public stakeOwners ;
   mapping(uint16 => tokenInfo) public tokensInfo ;
 

 uint dailyRewardforFS = 1 ether; 
  uint dailyRewardforLS1 = 2 ether;
  uint dailyRewardforLS3 = 4 ether;  
  uint dailyRewardforLS6 = 6 ether;  

   
address public mainAddress = 0x1CdC0F5F615431d2FBDABd76E0Ac88F2419d1541; 

address public rewardtokencontract = 0x32D552205B4E40fB5Cf090bEca0941D980d8b232;




IMain Main = IMain(mainAddress) ;

IRewardtoken rewardtoken = IRewardtoken(rewardtokencontract);



 constructor() {
  
 }

  function buyMerch(uint amount) external {
      require(rewardtoken.balanceOf(msg.sender) >= amount , " Insufficient balance");
      rewardtoken.burn(msg.sender , amount);
  }



 
  function checkTime (uint16 _tokenID) public view returns (uint64) {
     return uint64(block.timestamp) - tokensInfo[_tokenID].rewardstartingtime;
  }

 
 

 function stake(uint16 [] calldata data , uint8 _period) external {
   
    uint16 _number= uint16(data.length );
    require(_number > 0 , "No NFTs selected to stake");
   
    
 
      totalNFTStaked += _number;
      storeTokens( data , _period);
    
      for(uint16 i ; i< _number ; i++)
    {  
       require(Main.ownerOf(data[i]) == msg.sender, "Not the owner");
    Main.transferFrom( msg.sender, address(this),data[i]);
    }
   

 }

  
 function storeTokens( uint16 [] calldata data , uint8 _period ) internal {
    uint16 tokenID;
    for(uint16 i; i< data.length ; i++)
    {
     tokenID=data[i];
      stakeOwners[ msg.sender].tokens.push(tokenID);
      tokensInfo[tokenID].rewardstartingtime = uint64(block.timestamp);
      tokensInfo[tokenID].stakingstartingtime= uint64(block.timestamp);
      tokensInfo[tokenID].period = _period;
    }

 delete tokenID;
 }


   
 






  function getFulltokenOf(address _address) external view returns(uint16 [] memory)
 {
    return stakeOwners[_address].tokens;
   
 }

 

  function checkIfStaked(address _address) external view returns (bool){
     if(stakeOwners[_address].tokens.length > 0){
     return  true;
     }
     else
      return false;
  }
 
  


 
   

   
   


 
  function checkHowManyStaked(address _address) external view returns(uint){
  return stakeOwners[_address].tokens.length;
  }

 
  
  
 
  function getStakingEndTime(uint16 _tokenID) public view returns(uint64){
     if(tokensInfo[_tokenID].period == 1)
     {
         return tokensInfo[_tokenID].stakingstartingtime + 30 days ;
     }
     else if(tokensInfo[_tokenID].period == 3)
     {
         return tokensInfo[_tokenID].stakingstartingtime + 90 days;
     }
     else if(tokensInfo[_tokenID].period == 6)
     {
         return tokensInfo[_tokenID].stakingstartingtime + 180 days;
     }
     else
     {
         return 0;
     }
     
 }

 



 function calculateReward(address _address) public view returns (uint){
     
   uint _reward;
    for( uint i ; i < stakeOwners[_address].tokens.length ; i++)
    {

       uint16 _tokenID = stakeOwners[_address].tokens[i];
       if (tokensInfo[_tokenID].period == 0)
        {
         _reward = _reward + ( (dailyRewardforFS/86400) * checkTime(_tokenID));
        }
         else if (tokensInfo[_tokenID].period == 1)
        {
         _reward = _reward + ( (dailyRewardforLS1/86400) * checkTime(_tokenID));
        }
         else if (tokensInfo[_tokenID].period == 3)
        {
         _reward = _reward + ( (dailyRewardforLS3/86400) * checkTime(_tokenID));
        }
         else if (tokensInfo[_tokenID].period == 6)
        {
         _reward = _reward + ( (dailyRewardforLS6/86400) * checkTime(_tokenID));
        }
    }
    
    return _reward;
  
 }
 function calculateRewardfortoken(uint16 _tokenID) public view returns (uint){
   uint _reward;
    
    
       
            if (tokensInfo[_tokenID].period == 0)
        {
         _reward = _reward + ( (dailyRewardforFS/86400) * checkTime(_tokenID));
        }
         else if (tokensInfo[_tokenID].period == 1)
        {
         _reward = _reward + ( (dailyRewardforLS1/86400) * checkTime(_tokenID));
        }
         else if (tokensInfo[_tokenID].period == 3)
        {
         _reward = _reward + ( (dailyRewardforLS3/86400) * checkTime(_tokenID));
        }
         else if (tokensInfo[_tokenID].period == 6)
        {
         _reward = _reward + ( (dailyRewardforLS6/86400) * checkTime(_tokenID));
        }
    
    
    return _reward ;
  
 }

 

 function checkStakingPeriod(uint8 _tokenID) public view returns (uint8){
     if(tokensInfo[_tokenID].period == 1)
     {
         return 1;
     }
     else if(tokensInfo[_tokenID].period == 3)
     {
         return 3;
     }
     else if(tokensInfo[_tokenID].period == 6)
     {
         return 6;
     }
     else
     {
         return 0;
     }
 }
 
 


 
 function claimtoken(uint16 _tokenID) external {
     require(stakeOwners[ msg.sender].tokens.length> 0, "You have not staked any NFTs"); 
    uint _reward = calculateRewardfortoken(_tokenID);
    require(_reward > 0 , "No balance to claim");
    tokensInfo[_tokenID].rewardstartingtime = uint64 (block.timestamp);
    
    rewardtoken.mint(msg.sender, _reward );
 }
 function claimAlltokens(address _address) external {
     require(stakeOwners[_address].tokens.length> 0, "You have not staked any NFTs"); 
    uint _reward = calculateReward(_address);
    require(_reward > 0 , "No balance to claim");

    toggleRewardStartingTime(_address);
    
    rewardtoken.mint(_address, _reward );
 }

function toggleRewardStartingTime(address _address) internal  {
     
    for( uint i ; i < stakeOwners[_address].tokens.length ; i++)
    {

       uint16 _tokenID = stakeOwners[_address].tokens[i];
       tokensInfo[_tokenID].rewardstartingtime = uint64 (block.timestamp);
    }
    
  
  
 }


 function getRewardforUnstaking(address _address) internal {

  
   uint _reward = calculateReward(_address);
    require(_reward > 0 , "No balance to claim");
    rewardtoken.mint(msg.sender, _reward);

 }





 function checkIfPeriodOver(uint16 [] calldata data) public view returns (bool)
 {
     uint64 currenttime = uint64(block.timestamp);
     bool period = true;
     for (uint i ; i < data.length ; i ++)
      {
          uint16 _token= data[i];
           if(tokensInfo[_token].period == 0)
          {
              period = true;  
             
          }
         else if(tokensInfo[_token].period == 1)
          {
          uint64 endtime =tokensInfo[_token].stakingstartingtime + 30 days;
          if(endtime >=  currenttime )
          {
              period = false;
              break;
          }
          }
           else if(tokensInfo[_token].period == 2)
          {
          uint64 endtime =tokensInfo[_token].stakingstartingtime + 90 days;
          if(endtime >=  currenttime )
          {
              period =false;
              break;
          }
          }
          
           else if(tokensInfo[_token].period == 2)
          {
          uint64 endtime =tokensInfo[_token].stakingstartingtime + 180 days;
          if(endtime >=  currenttime )
          {
              period = false;
              break;
          }
          }
        

      }
      return period;
 }

 function unstake(uint16 [] calldata data) external {
    require(stakeOwners[ msg.sender].tokens.length> 0, "You have not staked any NFTs");
    
    uint16 tokens =uint16(data.length);
     require(tokens > 0 , "No NFTs selected to unstake");
    bool periodOver = checkIfPeriodOver(data);
    require( periodOver , "Staking Period is still not over");
   getRewardforUnstaking(msg.sender);
  
    
    uint16 tokenID;
    for(uint16 i; i<tokens; i++)
    {
    tokenID=data[i];
    Main.transferFrom(address(this),msg.sender,tokenID);
    removeToken(tokenID);
     delete tokensInfo[tokenID];
    }
   
   totalNFTStaked -= tokens;
  
    
    delete tokenID;
 }
 


   function removeToken(uint16 token) internal {
   uint x=   stakeOwners[ msg.sender].tokens.length  ;
   if (token == stakeOwners[ msg.sender].tokens[x-1])
   {
        stakeOwners[ msg.sender].tokens.pop();
   }
   else{
    for (uint i ; i < stakeOwners[ msg.sender].tokens.length ; i ++)
    {

      if(token == stakeOwners[ msg.sender].tokens[i] )
      {
        uint16 temp = stakeOwners[ msg.sender].tokens[x-1];
        stakeOwners[ msg.sender].tokens[x-1]   =  stakeOwners[ msg.sender].tokens[i];
        stakeOwners[ msg.sender].tokens[i] = temp;
        stakeOwners[ msg.sender].tokens.pop();
      }
    }
   }
   }

	function setMainAddress(address contractAddr) external onlyOwner {
		mainAddress = contractAddr;
        Main= IMain(mainAddress);
	}  
    function setRewardTokenAddress (address contractAddr) external onlyOwner {
	
         
       rewardtoken= IRewardtoken(contractAddr) ; 
	}  

}