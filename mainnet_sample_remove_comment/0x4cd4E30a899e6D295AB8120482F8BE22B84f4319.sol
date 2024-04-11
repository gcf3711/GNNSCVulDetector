 

 

 



pragma solidity ^0.8.0;

 
interface IERC721Receiver {
     
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

 



pragma solidity ^0.8.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 



pragma solidity ^0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 



pragma solidity ^0.8.0;


 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

     
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

 

pragma solidity 0.8.7;
 




contract PrayerStake is IERC721Receiver {
     IERC721 public nft_address;
     IERC20 public ft_address;

    uint256 public blocks_per_day = 6500;
    uint256 public rewards_per_day = 11 * 10**18;
    struct NFTData {
        uint256 id;
        uint256 stakingBlock;  
    }

    mapping(uint256 => address) NftIdToOwner;
    mapping(address => uint256[]) NftOwnerToIds;
    mapping(uint256 => NFTData) NftIdToData;
    mapping(uint256 => uint256) redeemedFtBalancePerNft;

    mapping(address => uint256) redeemedFtBalance;

    address[] stakers;

    uint numStakers = 0;

    constructor(address nft, address ft) {
        nft_address = IERC721(nft);
        ft_address = IERC20(ft);
    }

    function stake(uint256 id) public {
        require(nft_address.ownerOf(id) == msg.sender);
        nft_address.safeTransferFrom(msg.sender, address(this), id, "");
        require(nft_address.ownerOf(id) == address(this), "Staking contract must own the NFT");

        NFTData memory data;
        data.id = id;
        data.stakingBlock = block.number;
        NftIdToData[id] = data;

        NftIdToOwner[id] = msg.sender;
        NftOwnerToIds[msg.sender].push(id);

        stakers.push(msg.sender);

        numStakers += 1;
    }

    function unstake(uint256 id) public {
        require(nft_address.ownerOf(id) == address(this));
        require(NftIdToOwner[id] == msg.sender);
        require(NftOwnerToIds[msg.sender].length > 0);

        this.withdrawTokens(id);

        for (uint i =0; i < NftOwnerToIds[msg.sender].length; i++){
            if (NftOwnerToIds[msg.sender][i] == id){
                delete NftOwnerToIds[msg.sender][i];
            }
        }

        delete NftIdToOwner[id];
        delete NftIdToData[id];
        
        nft_address.safeTransferFrom(address(this), msg.sender, id, "");

        numStakers -= 1;

        redeemedFtBalance[tx.origin] -= redeemedFtBalancePerNft[id];
        redeemedFtBalancePerNft[id] = 0;
    }

    function getStakedNfts(address owner) public view returns( uint256[] memory ) {

        return NftOwnerToIds[owner];
    }

    function getRedeemedFtBalance(address owner) public view returns(uint256) {

        return redeemedFtBalance[owner];
    }

    function getStakingBlock(uint256 id) public view returns(uint256) {

        return NftIdToData[id].stakingBlock;
    }
    
    function getStakers() public view returns(address[] memory) {
        return stakers;
    }

    function getNumStakers() public view returns(uint256) {
        
        return numStakers;
    }

    event withdrew(address indexed _from, uint _value);

    function withdrawTokens(uint256 id) public {
        require(NftIdToOwner[id] == tx.origin, "origin doesnt own nft");

        uint256 totalStakedBlocks = block.number - NftIdToData[id].stakingBlock;

        uint256 rewardAmount = (totalStakedBlocks * rewards_per_day) / blocks_per_day - redeemedFtBalancePerNft[id];
                
        redeemedFtBalance[tx.origin] += rewardAmount;
        redeemedFtBalancePerNft[id] += rewardAmount;

        require(ft_address.balanceOf(address(this)) >= rewardAmount, "contract doesn't own enough rewards");
        
        emit withdrew(tx.origin, rewardAmount);

        ft_address.transfer(tx.origin, rewardAmount);

    }

    function  onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) override external returns (bytes4){
        return this.onERC721Received.selector;
    }
}