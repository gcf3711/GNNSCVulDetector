
 

 

 

pragma solidity >=0.6.12;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

interface TinlakeRootLike {
    function relyContract(address, address) external;
    function denyContract(address, address) external;
}

interface FileLike {
    function file(bytes32, uint) external;
    function file(bytes32, address) external;
}

interface NAVFeedLike {
    function file(bytes32 name, uint value) external;
    function file(bytes32 name, uint risk_, uint thresholdRatio_, uint ceilingRatio_, uint rate_, uint recoveryRatePD_) external;
    function discountRate() external returns(uint);
}

 
 
contract TinlakeSpell {

    bool public done;
    string constant public description = "Tinlake CF4 Mainnet Spell - 3";

     
     
     

    address constant public ROOT = 0x4cA805cE8EcE2E63FfC1F9f8F2731D3F48DF89Df;
    address constant public NAV_FEED = 0xdB9A84e5214e03a4e5DD14cFB3782e0bcD7567a7;
                                                             
    uint256 constant ONE = 10**27;
    address self;
    
    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        execute();
    }

    function execute() internal {
       TinlakeRootLike root = TinlakeRootLike(address(ROOT));
       NAVFeedLike navFeed = NAVFeedLike(address(NAV_FEED));
       self = address(this);
         
        root.relyContract(NAV_FEED, self);  


         
        navFeed.file("riskGroup", 41, ONE, ONE, uint(1000000001585490000000000000), 99.95*10**25);
         
        navFeed.file("riskGroup", 42, ONE, ONE, uint(1000000001664760000000000000), 99.93*10**25);
         
        navFeed.file("riskGroup", 43, ONE, ONE, uint(1000000001744040000000000000), 99.91*10**25);
         
        navFeed.file("riskGroup", 44, ONE, ONE, uint(1000000001823310000000000000), 99.9*10**25);
         
        navFeed.file("riskGroup", 45, ONE, ONE, uint(1000000001902590000000000000), 99.88*10**25);
         
        navFeed.file("riskGroup", 46, ONE, ONE, uint(1000000001981860000000000000), 99.87*10**25);
         
        navFeed.file("riskGroup", 47, ONE, ONE, uint(1000000002061140000000000000), 99.85*10**25);
         
        navFeed.file("riskGroup", 48, ONE, ONE, uint(1000000002140410000000000000), 99.84*10**25);
         
        navFeed.file("riskGroup", 49, ONE, ONE, uint(1000000002219690000000000000), 99.82*10**25);
         
        navFeed.file("riskGroup", 50, ONE, ONE, uint(1000000002298960000000000000), 99.81*10**25);
         
        navFeed.file("riskGroup", 51, ONE, ONE, uint(1000000002378230000000000000), 99.79*10**25);
         
        navFeed.file("riskGroup", 52, ONE, ONE, uint(1000000002457510000000000000), 99.78*10**25);
         
        navFeed.file("riskGroup", 53, ONE, ONE, uint(1000000002536780000000000000), 99.76*10**25);
         
        navFeed.file("riskGroup", 54, ONE, ONE, uint(1000000002616060000000000000), 99.74*10**25);
         
        navFeed.file("riskGroup", 55, ONE, ONE, uint(1000000002695330000000000000), 99.73*10**25);
         
        navFeed.file("riskGroup", 56, ONE, ONE, uint(1000000002774610000000000000), 99.71*10**25);
         
        navFeed.file("riskGroup", 57, ONE, ONE, uint(1000000002853880000000000000), 99.7*10**25);
         
        navFeed.file("riskGroup", 58, ONE, ONE, uint(1000000002933160000000000000), 99.68*10**25);
         
        navFeed.file("riskGroup", 59, ONE, ONE, uint(1000000003012430000000000000), 99.67*10**25);
         
        navFeed.file("riskGroup", 60, ONE, ONE, uint(1000000003091700000000000000), 99.65*10**25);
         
        navFeed.file("riskGroup", 61, ONE, ONE, uint(1000000003170980000000000000), 99.64*10**25);
         
        navFeed.file("riskGroup", 62, ONE, ONE, uint(1000000003250250000000000000), 99.62*10**25);
         
        navFeed.file("riskGroup", 63, ONE, ONE, uint(1000000003329530000000000000), 99.61*10**25);
         
        navFeed.file("riskGroup", 64, ONE, ONE, uint(1000000003408800000000000000), 99.59*10**25);
         
        navFeed.file("riskGroup", 65, ONE, ONE, uint(1000000003488080000000000000), 99.58*10**25);
         
        navFeed.file("riskGroup", 66, ONE, ONE, uint(1000000003567350000000000000), 99.56*10**25);
         
        navFeed.file("riskGroup", 67, ONE, ONE, uint(1000000003646630000000000000), 99.54*10**25);
         
        navFeed.file("riskGroup", 68, ONE, ONE, uint(1000000003725900000000000000), 99.53*10**25);
         
        navFeed.file("riskGroup", 69, ONE, ONE, uint(1000000003805180000000000000), 99.51*10**25);
         
        navFeed.file("riskGroup", 70, ONE, ONE, uint(1000000003884450000000000000), 99.5*10**25);
         
        navFeed.file("riskGroup", 71, ONE, ONE, uint(1000000003963720000000000000), 99.48*10**25);
         
        navFeed.file("riskGroup", 72, ONE, ONE, uint(1000000004043000000000000000), 99.47*10**25);
         
        navFeed.file("riskGroup", 73, ONE, ONE, uint(1000000004122270000000000000), 99.45*10**25);
     }   
}