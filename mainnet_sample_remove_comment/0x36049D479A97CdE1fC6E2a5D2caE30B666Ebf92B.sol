 


 

contract Order {
    address public constant ETH_ADDRESS =
        address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
}

 

 
abstract contract PineCore is Order {
    using SafeMath for uint256;
    using Fabric for bytes32;

     
    mapping(bytes32 => uint256) public ethDeposits;

     
    event DepositETH(
        bytes32 indexed _key,
        address indexed _caller,
        uint256 _amount,
        bytes _data
    );

    event OrderExecuted(
        bytes32 indexed _key,
        address _inputToken,
        address _owner,
        address _witness,
        bytes _data,
        bytes _auxData,
        uint256 _amount,
        uint256 _bought
    );

    event OrderCancelled(
        bytes32 indexed _key,
        address _inputToken,
        address _owner,
        address _witness,
        bytes _data,
        uint256 _amount
    );

     
    receive() external payable {
        require(
            msg.sender != tx.origin,
            "PineCore#receive: NO_SEND_ETH_PLEASE"
        );
    }

     
    function depositEth(bytes calldata _data) external payable {
        require(msg.value > 0, "PineCore#depositEth: VALUE_IS_0");

        (
            address module,
            address inputToken,
            address payable owner,
            address witness,
            bytes memory data,

        ) = decodeOrder(_data);

        require(
            inputToken == ETH_ADDRESS,
            "PineCore#depositEth: WRONG_INPUT_TOKEN"
        );

        bytes32 key =
            keyOf(
                IModule(uint160(module)),
                IERC20(inputToken),
                owner,
                witness,
                data
            );

        ethDeposits[key] = ethDeposits[key].add(msg.value);
        emit DepositETH(key, msg.sender, msg.value, _data);
    }

     
    function cancelOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        address _witness,
        bytes calldata _data
    ) external {
        require(msg.sender == _owner, "PineCore#cancelOrder: INVALID_OWNER");
        bytes32 key = keyOf(_module, _inputToken, _owner, _witness, _data);

        uint256 amount = _pullOrder(_inputToken, key, msg.sender);

        emit OrderCancelled(
            key,
            address(_inputToken),
            _owner,
            _witness,
            _data,
            amount
        );
    }

     
    function encodeTokenOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        address _witness,
        bytes calldata _data,
        bytes32 _secret,
        uint256 _amount
    ) external view returns (bytes memory) {
        return
            abi.encodeWithSelector(
                _inputToken.transfer.selector,
                vaultOfOrder(_module, _inputToken, _owner, _witness, _data),
                _amount,
                abi.encode(
                    _module,
                    _inputToken,
                    _owner,
                    _witness,
                    _data,
                    _secret
                )
            );
    }

     
    function encodeEthOrder(
        address _module,
        address _inputToken,
        address payable _owner,
        address _witness,
        bytes calldata _data,
        bytes32 _secret
    ) external pure returns (bytes memory) {
        return
            abi.encode(_module, _inputToken, _owner, _witness, _data, _secret);
    }

     
    function decodeOrder(bytes memory _data)
        public
        pure
        returns (
            address module,
            address inputToken,
            address payable owner,
            address witness,
            bytes memory data,
            bytes32 secret
        )
    {
        (module, inputToken, owner, witness, data, secret) = abi.decode(
            _data,
            (address, address, address, address, bytes, bytes32)
        );
    }

     
    function vaultOfOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        address _witness,
        bytes memory _data
    ) public view returns (address) {
        return keyOf(_module, _inputToken, _owner, _witness, _data).getVault();
    }

     
    function executeOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        bytes calldata _data,
        bytes calldata _signature,
        bytes calldata _auxData
    ) public virtual {
         
        address witness =
            ECDSA.recover(keccak256(abi.encodePacked(msg.sender)), _signature);

        bytes32 key = keyOf(_module, _inputToken, _owner, witness, _data);

         
        uint256 amount = _pullOrder(_inputToken, key, address(_module));
        require(amount > 0, "PineCore#executeOrder: INVALID_ORDER");

        uint256 bought =
            _module.execute(_inputToken, amount, _owner, _data, _auxData);

        emit OrderExecuted(
            key,
            address(_inputToken),
            _owner,
            witness,
            _data,
            _auxData,
            amount,
            bought
        );
    }

     
    function existOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        address _witness,
        bytes calldata _data
    ) external view returns (bool) {
        bytes32 key = keyOf(_module, _inputToken, _owner, _witness, _data);

        if (address(_inputToken) == ETH_ADDRESS) {
            return ethDeposits[key] != 0;
        } else {
            return _inputToken.balanceOf(key.getVault()) != 0;
        }
    }

     
    function canExecuteOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        address _witness,
        bytes calldata _data,
        bytes calldata _auxData
    ) external view returns (bool) {
        bytes32 key = keyOf(_module, _inputToken, _owner, _witness, _data);

         
        uint256 amount;
        if (address(_inputToken) == ETH_ADDRESS) {
            amount = ethDeposits[key];
        } else {
            amount = _inputToken.balanceOf(key.getVault());
        }

        return _module.canExecute(_inputToken, amount, _data, _auxData);
    }

     
    function _pullOrder(
        IERC20 _inputToken,
        bytes32 _key,
        address payable _to
    ) private returns (uint256 amount) {
        if (address(_inputToken) == ETH_ADDRESS) {
            amount = ethDeposits[_key];
            ethDeposits[_key] = 0;
            (bool success, ) = _to.call{value: amount}("");
            require(success, "PineCore#_pullOrder: PULL_ETHER_FAILED");
        } else {
            amount = _key.executeVault(_inputToken, _to);
        }
    }

     
    function keyOf(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        address _witness,
        bytes memory _data
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(_module, _inputToken, _owner, _witness, _data)
            );
    }
}
 

 
 
 
 
 
 
 

 
pragma solidity 0.6.12;



contract GelatoPineCore is PineCore {
    modifier onlyGelato {
        require(
            address(0x3CACa7b48D0573D793d3b0279b5F0029180E83b6) == msg.sender,
            "GelatoPineCore: onlyGelato"
        );
        _;
    }

    function executeOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        bytes calldata _data,
        bytes calldata _signature,
        bytes calldata _auxData
    ) public override onlyGelato {
        super.executeOrder(
            _module,
            _inputToken,
            _owner,
            _data,
            _signature,
            _auxData
        );
    }
}

 

 

 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

pragma solidity 0.6.12;

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

 
library ECDSA {
     
    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
         
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

         
        bytes32 r;
        bytes32 s;
        uint8 v;

         
         
         
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

         
         
         
         
         
         
         
         
         
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

         
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

     
    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
         
         
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
}

 

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

     
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

 

 
library Fabric {
     
    bytes public constant code =
        hex"6012600081600A8239F360008060448082803781806038355AF132FF";
    bytes32 public constant vaultCodeHash =
        bytes32(
            0xfa3da1081bc86587310fce8f3a5309785fc567b9b20875900cb289302d6bfa97
        );

     
    function getVault(bytes32 _key) internal view returns (address) {
        return
            address(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            _key,
                            vaultCodeHash
                        )
                    )
                )
            );
    }

     
    function executeVault(
        bytes32 _key,
        IERC20 _token,
        address _to
    ) internal returns (uint256 value) {
        address addr;
        bytes memory slotcode = code;

         
        assembly {
             
            addr := create2(0, add(slotcode, 0x20), mload(slotcode), _key)
        }

        value = _token.balanceOf(addr);
         
        (bool success, ) =
            addr.call(
                abi.encodePacked(
                    abi.encodeWithSelector(
                        _token.transfer.selector,
                        _to,
                        value
                    ),
                    address(_token)
                )
            );

        require(success, "Error pulling tokens");
    }
}

 

 
interface IModule {
    
    receive() external payable;

     
    function execute(
        IERC20 _inputToken,
        uint256 _inputAmount,
        address payable _owner,
        bytes calldata _data,
        bytes calldata _auxData
    ) external returns (uint256 bought);

     
    function canExecute(
        IERC20 _inputToken,
        uint256 _inputAmount,
        bytes calldata _data,
        bytes calldata _auxData
    ) external view returns (bool);
}
