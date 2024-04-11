 
pragma experimental ABIEncoderV2;

 

 

 
 
pragma solidity 0.6.12;


 
library BoringMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function to128(uint256 a) internal pure returns (uint128 c) {
        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {
        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {
        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}


library BoringMath128 {
    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}


library BoringMath64 {
    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}


library BoringMath32 {
    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

 
 
pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

 
 
pragma solidity 0.6.12;

 

library BoringERC20 {
    bytes4 private constant SIG_SYMBOL = 0x95d89b41;  
    bytes4 private constant SIG_NAME = 0x06fdde03;  
    bytes4 private constant SIG_DECIMALS = 0x313ce567;  
    bytes4 private constant SIG_BALANCE_OF = 0x70a08231;  
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb;  
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd;  

    function returnDataToString(bytes memory data) internal pure returns (string memory) {
        if (data.length >= 64) {
            return abi.decode(data, (string));
        } else if (data.length == 32) {
            uint8 i = 0;
            while (i < 32 && data[i] != 0) {
                i++;
            }
            bytes memory bytesArray = new bytes(i);
            for (i = 0; i < 32 && data[i] != 0; i++) {
                bytesArray[i] = data[i];
            }
            return string(bytesArray);
        } else {
            return "???";
        }
    }

    
    
    
    function safeSymbol(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_SYMBOL));
        return success ? returnDataToString(data) : "???";
    }

    
    
    
    function safeName(IERC20 token) internal view returns (string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_NAME));
        return success ? returnDataToString(data) : "???";
    }

    
    
    
    function safeDecimals(IERC20 token) internal view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_DECIMALS));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    
    
    
    
    function safeBalanceOf(IERC20 token, address to) internal view returns (uint256 amount) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(SIG_BALANCE_OF, to));
        require(success && data.length >= 32, "BoringERC20: BalanceOf failed");
        amount = abi.decode(data, (uint256));
    }

    
     
    
    
    
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    
     
    
    
    
    
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}

 
 
 
 
 
pragma solidity 0.6.12;

 

contract Domain {
    bytes32 private constant DOMAIN_SEPARATOR_SIGNATURE_HASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
     
    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = "\x19\x01";

     
    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 private immutable DOMAIN_SEPARATOR_CHAIN_ID;

    
    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_SEPARATOR_SIGNATURE_HASH, chainId, address(this)));
    }

    constructor() public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = _calculateDomainSeparator(DOMAIN_SEPARATOR_CHAIN_ID = chainId);
    }

    
     
     
     
    function _domainSeparator() internal view returns (bytes32) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId == DOMAIN_SEPARATOR_CHAIN_ID ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId);
    }

    function _getDigest(bytes32 dataHash) internal view returns (bytes32 digest) {
        digest = keccak256(abi.encodePacked(EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA, _domainSeparator(), dataHash));
    }
}

 
 
pragma solidity 0.6.12;


 
 

 
contract ERC20Data {
    
    mapping(address => uint256) public balanceOf;
    
    mapping(address => mapping(address => uint256)) public allowance;
    
    mapping(address => uint256) public nonces;
}

abstract contract ERC20 is IERC20, Domain {
    
    mapping(address => uint256) public override balanceOf;
    
    mapping(address => mapping(address => uint256)) public override allowance;
    
    mapping(address => uint256) public nonces;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    
    
    
    function transfer(address to, uint256 amount) public returns (bool) {
         
        if (amount != 0 || msg.sender == to) {
            uint256 srcBalance = balanceOf[msg.sender];
            require(srcBalance >= amount, "ERC20: balance too low");
            if (msg.sender != to) {
                require(to != address(0), "ERC20: no zero address");  

                balanceOf[msg.sender] = srcBalance - amount;  
                balanceOf[to] += amount;
            }
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    
    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
         
        if (amount != 0) {
            uint256 srcBalance = balanceOf[from];
            require(srcBalance >= amount, "ERC20: balance too low");

            if (from != to) {
                uint256 spenderAllowance = allowance[from][msg.sender];
                 
                if (spenderAllowance != type(uint256).max) {
                    require(spenderAllowance >= amount, "ERC20: allowance too low");
                    allowance[from][msg.sender] = spenderAllowance - amount;  
                }
                require(to != address(0), "ERC20: no zero address");  

                balanceOf[from] = srcBalance - amount;  
                balanceOf[to] += amount;
            }
        }
        emit Transfer(from, to, amount);
        return true;
    }

    
    
    
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

     
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparator();
    }

     
    bytes32 private constant PERMIT_SIGNATURE_HASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    
    
    
    
    
    function permit(
        address owner_,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(owner_ != address(0), "ERC20: Owner cannot be 0");
        require(block.timestamp < deadline, "ERC20: Expired");
        require(
            ecrecover(_getDigest(keccak256(abi.encode(PERMIT_SIGNATURE_HASH, owner_, spender, value, nonces[owner_]++, deadline))), v, r, s) ==
                owner_,
            "ERC20: Invalid Signature"
        );
        allowance[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }
}

contract ERC20WithSupply is IERC20, ERC20 {
    uint256 public override totalSupply;

    function _mint(address user, uint256 amount) internal {
        uint256 newTotalSupply = totalSupply + amount;
        require(newTotalSupply >= totalSupply, "Mint overflow");
        totalSupply = newTotalSupply;
        balanceOf[user] += amount;
        emit Transfer(address(0), user, amount);
    }

    function _burn(address user, uint256 amount) internal {
        require(balanceOf[user] >= amount, "Burn too much");
        totalSupply -= amount;
        balanceOf[user] -= amount;
        emit Transfer(user, address(0), amount);
    }
}

 
 

 
pragma solidity ^0.6.12;

 

library BoringAddress {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

 
 
pragma solidity ^0.6.12;


 

interface ERC721TokenReceiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

abstract contract BoringSingleNFT {
     
    using BoringAddress for address;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

     
     
    address public hodler;
    address public allowed;
    uint256 public constant totalSupply = 1;

     
    mapping(address => mapping(address => bool)) public operators;

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return
            interfaceID == this.supportsInterface.selector ||  
            interfaceID == 0x80ac58cd;  
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "No zero address");
        return _owner == hodler ? 1 : 0;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        require(_tokenId == 0, "Invalid token ID");
        require(hodler != address(0), "No owner");
        return hodler;
    }

    function approve(address _approved, uint256 _tokenId) public payable {
        require(_tokenId == 0, "Invalid token ID");
        require(msg.sender == hodler || operators[hodler][msg.sender], "Not allowed");
        allowed = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        require(_tokenId == 0, "Invalid token ID");
        return allowed;
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operators[_owner][_operator];
    }

    function _transferBase(address to) internal {
        emit Transfer(hodler, to, 0);
        hodler = to;
         
        allowed = address(0);
    }

    function _transfer(
        address from,
        address to,
        uint256 _tokenId
    ) internal {
        require(_tokenId == 0, "Invalid token ID");
        require(from == hodler, "From not owner");
        require(msg.sender == hodler || msg.sender == allowed || operators[hodler][msg.sender], "Transfer not allowed");
        require(to != address(0), "No zero address");
        _transferBase(to);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public payable {
        _transfer(_from, _to, _tokenId);
        if (_to.isContract()) {
            require(
                ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) ==
                    bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")),
                "Wrong return value"
            );
        }
    }

    function tokenURI(uint256 _tokenId) public pure returns (string memory) {
        require(_tokenId == 0, "Invalid token ID");
        return _tokenURI();
    }

    function _tokenURI() internal pure virtual returns (string memory);
}

 
 
 
 
 
 
 
 
 
 
 

 

pragma solidity ^0.6.12;




 

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

interface Pixel is IERC20 {
    function burn(uint256 amount) external;
}

contract Canvas is BoringSingleNFT {
    using BoringMath for uint256;
    using BoringERC20 for Pixel;

    event Buy(address hodler, address buyer, uint256 price, uint256 hodler_share);

    string public constant name = "The Canvas of Pixel Inc";
    string public constant symbol = "CANVAS";

    uint256 public price;
    Pixel public immutable pixel;
    string public info;

    constructor(Pixel _pixel) public {
        pixel = _pixel;
        price = _pixel.totalSupply() / 200000;
        _transferBase(address(_pixel));
    }

    function _tokenURI() internal override pure returns (string memory) {
         
        return string(abi.encodePacked('data:application/json;base64,eyJuYW1lIjogIkNhbnZhcyIsICJkZXNjcmlwdGlvbiI6ICJUaGUgZmluYWwgY2FudmFzIGNyZWF0ZWQgYnkgdGhlIFBpeGVsIEluYyBwcm9qZWN0LCAxMDAweDEwMDAgcGl4ZWxzIHBhaW50ZWQgYnkgbWFueSBkaWZmZXJlbnQgY29sbGFib3JhdG9ycy4gQmUgYXdhcmUsIHRoZSBjYW52YXMgaXMgYWx3YXlzIGZvciBzYWxlIHRocm91Z2ggdGhlIHdlYnNpdGUsIGRvbid0IGxpc3QgdGhpcyBvbiBtYXJrZXRwbGFjZXMhIEFsbCB0aGUgaW1hZ2UgYW5kIGxpbmsgZGF0YSBpcyBzdG9yZWQgZnVsbHkgb24tY2hhaW4gYW5kIGNhbiBiZSByZXRyaWV2ZWQgYnkgcXVlcnlpbmcgdGhlIGNvbnRyYWN0LiBUaGUgamF2YXNjcmlwdCBjb2RlIGZvciB0aGlzIGlzIGluY2x1ZGVkIGluIHRoaXMgY29udHJhY3QuIiwgImltYWdlIjogImlwZnM6Ly9iYWZ5YmVpZGhpZ2JocmNjajI3cXJnbmZzd2ViZmNjaWl5d2E0NnkycGlzYnRsYWQ2dmkyaDVpdTN1NC8ifQ'));
    }

    function buy() external payable {
        require(msg.value == price, "Value != price");

         
        uint256 hodler_share = hodler == address(pixel) ? 0 : price.mul(110) / 150;
        bool success;
        (success, ) = hodler.call{value: hodler_share, gas: 20000}("");

        emit Buy(hodler, msg.sender, price, hodler_share);

        price = price.mul(150) / 100;  
        _transferBase(msg.sender);
    }

    function redeem(uint256 amount) external {
        uint256 share = address(this).balance.mul(amount) / pixel.totalSupply();
        pixel.safeTransferFrom(msg.sender, address(this), amount);
        pixel.burn(amount);
        bool success;
        (success, ) = msg.sender.call{value: share, gas: 20000}("");
        require(success, "Sending of ETH failed");
    }

    function setInfo(string memory info_) external {
        require(msg.sender == hodler, "Canvas: not hodler");
        info = info_;
    }

    function poll(address user) public view returns(address hodler_, address allowed_, uint256 price_, uint256 pool, uint256 share, string memory info_) {
        return (hodler, allowed, price, address(this).balance, address(this).balance.mul(pixel.balanceOf(user)) / pixel.totalSupply(), info);
    }

    function getCanvasImageCode() public pure returns (string memory code) {
        return "if(process.argv[2]){const e=require('ethers'),t=new e.Contract('0x1590ABe3612Be1CB3ab5B0f28874D521576e97Dc',[{inputs:[{internalType:'uint256[]',name:'blockNumbers',type:'uint256[]'}],name:'getBlocks',outputs:[{components:[{internalType:'address',name:'owner',type:'address'},{internalType:'string',name:'url',type:'string'},{internalType:'string',name:'description',type:'string'},{internalType:'bytes',name:'pixels',type:'bytes'},{internalType:'uint128',name:'lastPrice',type:'uint128'},{internalType:'uint32',name:'number',type:'uint32'}],internalType:'struct PixelV2.ExportBlock[]',name:'blocks',type:'tuple[]'}],stateMutability:'view',type:'function'}],new e.providers.JsonRpcProvider(process.argv[2])),{Canvas:a,Image:b}=require('node-canvas');async function main(){const e=new a(1e3,1e3),n=e.getContext('2d');for(let e=0;e<100;e++){console.log(100*e);let a=await t.getBlocks([...Array(100).keys()].map(t=>t+100*e));for(let t in a){let s=parseInt(a[t].pixels.substr(2,2)),r=a[t].pixels.substr(4);if(s<=4){1==s&&(r='89504e470d0a1a0a0000000d494844520000000a0000000a08060000008d32cfbd0000'+r+'0000000049454e44ae426082'),3==s&&(r='ffd8ffe000104a46494600010100000100010000ffdb0043000a07070807060a0808080b0a0a0b0e18100e0d0d0e1d15161118231f2524221f2221262b372f26293429212230413134393b3e3e3e252e4449433c48373d3e3bffdb0043010a0b0b0e0d0e1c10101c3b2822283b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3bffc0001108000a000a03012200021101031101ffc400'+r+'ffd9');const a=new b;a.src=Buffer.from(r,'hex'),n.drawImage(a,10*t,10*e,10,10)}else if(5==s){let a=n.createImageData(10,10);for(let e=0;e<100;e++){let t=parseInt(r.substr(6*e,6),16);a.data.set([Math.floor(t/65536),Math.floor(t%65536/256),t%256,255],4*e)}n.putImageData(a,10*t,10*e)}else 6!=s&&r||(n.fillStyle='#'+(r||'000000'),n.fillRect(10*t,10*e,10,10))}}const s=e.toBuffer('image/png');require('fs').writeFileSync('canvas.png',s)}main()}else console.log('Usage: node getImage.js <RPC URL>');";
    }
}