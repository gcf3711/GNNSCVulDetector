 


 
pragma solidity ^0.7.6;

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

 

pragma solidity >=0.6.0 <0.8.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

 
pragma solidity ^0.7.6;



interface IUniswapV2Pair is IUniswapV2ERC20 {
     
     

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

     
     
     
     
     
     

     
     
     

     
     
     

     

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

 
pragma solidity ^0.7.6;




contract UniswapV2ERC20 is IUniswapV2ERC20 {
    using SafeMath for uint;

    string internal constant _name = 'Uniswap V2';
    string private constant _symbol = 'UNI-V2';
    uint8 internal constant _decimals = 18;
    uint  internal _totalSupply;
    mapping(address => uint) internal _balanceOf;
    mapping(address => mapping(address => uint)) internal _allowance;

    bytes32 internal _DOMAIN_SEPARATOR;
     
    bytes32 internal constant _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) internal _nonces;

     
     

    constructor() {
        uint chainId;
         
         
         
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    function PERMIT_TYPEHASH() external pure override returns (bytes32) {
        return _PERMIT_TYPEHASH;
    }

    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowance[owner][spender];
    }

    function balanceOf(address owner) external view override returns (uint) {
        return _balanceOf[owner];
    }
    
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function nonces(address owner) external view override returns (uint) {
        return _nonces[owner];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    function _mint(address to, uint value) internal {
        _totalSupply = _totalSupply.add(value);
        _balanceOf[to] = _balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        _balanceOf[from] = _balanceOf[from].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        _allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        _balanceOf[from] = _balanceOf[from].sub(value);
        _balanceOf[to] = _balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (_allowance[from][msg.sender] != uint(-1)) {
            _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(deadline >= block.timestamp, 'UniswapV2: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                _DOMAIN_SEPARATOR,
                keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'UniswapV2: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

 

pragma solidity >=0.6.0 <0.8.0;



 
interface IERC1155Receiver is IERC165 {

     
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

     
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

 

pragma solidity >=0.6.0 <0.8.0;



 
abstract contract ERC165 is IERC165 {
     
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

     
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
         
         
        _registerInterface(_INTERFACE_ID_ERC165);
    }

     
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

     
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

 
pragma solidity ^0.7.6;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

 
pragma solidity ^0.7.6;









contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

     

    uint internal constant _MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address internal _factory;
    address internal _token0;
    address internal _token1;

    uint112 private reserve0;            
    uint112 private reserve1;            
    uint32  private blockTimestampLast;  

    uint internal _price0CumulativeLast;
    uint internal _price1CumulativeLast;
    uint internal _kLast;  

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        _factory = msg.sender;
    }

    function MINIMUM_LIQUIDITY() external pure override returns (uint) {
        return _MINIMUM_LIQUIDITY;
    }

    function factory() external view override returns (address) {
        return _factory;
    }

    function token0() external view override returns (address) {
        return _token0;
    }
    function token1() external view override returns (address) {
        return _token1;
    }

    function price0CumulativeLast() external view override returns (uint) {
        return _price0CumulativeLast;
    }

    function price1CumulativeLast() external view override returns (uint) {
        return _price1CumulativeLast;
    }

    function kLast() external view override returns (uint) {
        return _kLast;
    }

    function getReserves() public view override returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }

     
     
     
     
     
     
     
     
     
     

     
    function initialize(address token0_, address token1_) external override {
        require(msg.sender == _factory, 'UniswapV2: FORBIDDEN');  
        _token0 = token0_;
        _token1 = token1_;
    }

     
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;  
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
             
            _price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            _price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

     
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(_factory).feeTo();
        feeOn = feeTo != address(0);
        uint kLast_ = _kLast;  
        if (feeOn) {
            if (kLast_ != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(kLast_);
                if (rootK > rootKLast) {
                    uint numerator = _totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (kLast_ != 0) {
            kLast_ = 0;
        }
    }

     
    function mint(address to) external lock override returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();  
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint totalSupply_ = _totalSupply;  
        if ( totalSupply_ == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(_MINIMUM_LIQUIDITY);
           _mint(address(0), _MINIMUM_LIQUIDITY);  
        } else {
            liquidity = Math.min(amount0.mul(totalSupply_) / _reserve0, amount1.mul(totalSupply_) / _reserve1);
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) _kLast = uint(reserve0).mul(reserve1);  
        emit Mint(msg.sender, amount0, amount1);
    }

     
    function burn(address to) external lock override returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();  
        address token0_ = _token0;                                 
        address token1_ = _token1;                                 
        uint balance0 = IERC20(token0_).balanceOf(address(this));
        uint balance1 = IERC20(token1_).balanceOf(address(this));
        uint liquidity = _balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint totalSupply_ = _totalSupply;  
        amount0 = liquidity.mul(balance0) / totalSupply_;  
        amount1 = liquidity.mul(balance1) / totalSupply_;  
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(token0_, to, amount0);
        _safeTransfer(token1_, to, amount1);
        balance0 = IERC20(token0_).balanceOf(address(this));
        balance1 = IERC20(token1_).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) _kLast = uint(reserve0).mul(reserve1);  
        emit Burn(msg.sender, amount0, amount1, to);
    }

     
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external override lock {
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();  
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        {  
        address token0_ = _token0;
        address token1_ = _token1;
        require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(token0_, to, amount0Out);  
        if (amount1Out > 0) _safeTransfer(token1_, to, amount1Out);  
        if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(token0_).balanceOf(address(this));
        balance1 = IERC20(token1_).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
        {  
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

     
    function skim(address to) external override lock {
        address token0_ = _token0;  
        address token1_ = _token1;  
        _safeTransfer(token0_, to, IERC20(token0_).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(token1_, to, IERC20(token1_).balanceOf(address(this)).sub(reserve1));
    }

     
    function sync() external override lock {
        _update(IERC20(_token0).balanceOf(address(this)), IERC20(_token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

 

pragma solidity >=0.6.0 <0.8.0;




 
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}
 
pragma solidity ^0.7.6;






 
contract RenaswapV1Factory is IUniswapV2Factory {

    
    address public override feeTo;
    
    address public override feeToSetter;
    
    mapping(address => mapping(address => address)) public override getPair;
    
    address[] public override allPairs;
    
    IRenaswapV1Wrapper public wrapper;

     
    constructor(address _feeToSetter, IRenaswapV1Wrapper _wrapper) {
        wrapper = _wrapper;
        feeToSetter = _feeToSetter;
    }

     
    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tx.origin == feeToSetter, 'RenaswapV1: FORBIDDEN');
        require(tokenA != tokenB, 'RenaswapV1: IDENTICAL_ADDRESSES');
        require(tokenA != address(0) && tokenB != address(0), 'RenaswapV1: ZERO_ADDRESS');
        require(getPair[tokenA][tokenB] == address(0), 'RenaswapV1: PAIR_EXISTS');  
        bytes memory bytecode = type(RenaswapV1Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(tokenA, address(wrapper));
        getPair[tokenA][tokenB] = pair;
        allPairs.push(pair);
        
        wrapper.addWrappedToken(tokenB, pair);
        emit PairCreated(tokenA, tokenB, pair, allPairs.length);
    }
    
    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view override returns (uint) {
        return allPairs.length;
    }
}

 
pragma solidity ^0.7.6;

interface IRenaswapV1Wrapper {
    function addWrappedToken(address token, address pair) external returns (uint256 id);
    function balanceFor(address token, address account) external view returns (uint256);
    function rBurn(address token, uint256 burnDivisor) external;
}

 
pragma solidity ^0.7.6;




 
contract RenaswapV1Pair is UniswapV2Pair, ERC1155Receiver {

    constructor() UniswapV2Pair() ERC1155Receiver() {
    }

    function onERC1155Received(
        address  ,
        address  ,
        uint256  ,
        uint256  ,
        bytes calldata  
    )
        external override pure
        returns(bytes4) {
            return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
        }

    function onERC1155BatchReceived(
        address  ,
        address  ,
        uint256[] calldata  ,
        uint256[] calldata  ,
        bytes calldata  
    )
        external override pure
        returns(bytes4) {
        }
}

 
pragma solidity ^0.7.6;

 

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

     
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

 
pragma solidity ^0.7.6;

 

 
 

library UQ112x112 {
    uint224 constant Q112 = 2**112;

     
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112;  
    }

     
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

 
pragma solidity ^0.7.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

 
pragma solidity ^0.7.6;

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

 
pragma solidity ^0.7.6;

 

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}
