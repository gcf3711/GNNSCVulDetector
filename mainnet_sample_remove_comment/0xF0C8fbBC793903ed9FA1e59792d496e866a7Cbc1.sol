 

 

 

 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

pragma solidity >=0.6.12;

interface VatLike {
    function slip(bytes32, address, int256) external;
}

interface GemLike {
    function decimals() external view returns (uint8);
    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function erc20Impl() external view returns (address);
}

 
 

contract AuthGemJoin8 {
     
    mapping (address => uint256) public wards;
    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }
    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }
    modifier auth { require(wards[msg.sender] == 1); _; }

    VatLike public immutable vat;
    bytes32 public immutable ilk;
    GemLike public immutable gem;
    uint256 public immutable dec;
    uint256 public live;   

     
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Join(address indexed usr, uint256 wad, address indexed msgSender);
    event Exit(address indexed usr, uint256 wad);
    event Cage();

    mapping (address => uint256) public implementations;

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        gem = GemLike(gem_);
        dec = GemLike(gem_).decimals();
        require(GemLike(gem_).decimals() < 18, "AuthGemJoin8/decimals-18-or-higher");
        wards[msg.sender] = 1;
        live = 1;
        setImplementation(GemLike(gem_).erc20Impl(), 1);
        vat = VatLike(vat_);
        ilk = ilk_;
        emit Rely(msg.sender);
    }

    function cage() external auth {
        live = 0;
        emit Cage();
    }

    function setImplementation(address implementation, uint256 permitted) public auth {
        implementations[implementation] = permitted;   
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "AuthGemJoin8/overflow");
    }

    function join(address usr, uint256 amt, address msgSender) external auth {
        require(live == 1, "AuthGemJoin8/not-live");
        uint256 wad = mul(amt, 10 ** (18 - dec));
        require(int256(wad) >= 0, "AuthGemJoin8/overflow");
        require(implementations[gem.erc20Impl()] == 1, "AuthGemJoin8/implementation-invalid");
        vat.slip(ilk, usr, int256(wad));
        require(gem.transferFrom(msg.sender, address(this), amt), "AuthGemJoin8/failed-transfer");
        emit Join(usr, amt, msgSender);
    }

    function exit(address usr, uint256 amt) external {
        uint256 wad = mul(amt, 10 ** (18 - dec));
        require(int256(wad) >= 0, "AuthGemJoin8/overflow");
        require(implementations[gem.erc20Impl()] == 1, "AuthGemJoin8/implementation-invalid");
        vat.slip(ilk, msg.sender, -int256(wad));
        require(gem.transfer(usr, amt), "AuthGemJoin8/failed-transfer");
        emit Exit(usr, amt);
    }
}