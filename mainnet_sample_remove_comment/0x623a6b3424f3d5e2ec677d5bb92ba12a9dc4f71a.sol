 
pragma abicoder v2;


 
pragma solidity >=0.7.0;






interface ILimitOrder {
    event OperatorNominated(address indexed newOperator);
    event OperatorChanged(address indexed oldOperator, address indexed newOperator);
    event UpgradeSpender(address newSpender);
    event UpgradeCoordinator(address newCoordinator);
    event AllowTransfer(address spender);
    event DisallowTransfer(address spender);
    event DepositETH(uint256 ethBalance);
    event FactorsUpdated(uint16 makerFeeFactor, uint16 takerFeeFactor, uint16 profitFeeFactor);
    event SetFeeCollector(address newFeeCollector);
    event LimitOrderFilledByTrader(
        bytes32 indexed orderHash,
        address indexed maker,
        address indexed taker,
        bytes32 allowFillHash,
        address recipient,
        FillReceipt fillReceipt
    );
    event LimitOrderFilledByProtocol(
        bytes32 indexed orderHash,
        address indexed maker,
        address indexed taker,
        bytes32 allowFillHash,
        address relayer,
        address profitRecipient,
        FillReceipt fillReceipt,
        uint256 relayerTakerTokenProfit,
        uint256 relayerTakerTokenProfitFee
    );
    event OrderCancelled(bytes32 orderHash, address maker);

    struct FillReceipt {
        address makerToken;
        address takerToken;
        uint256 makerTokenFilledAmount;
        uint256 takerTokenFilledAmount;
        uint256 remainingAmount;
        uint256 makerTokenFee;
        uint256 takerTokenFee;
    }

    struct CoordinatorParams {
        bytes sig;
        uint256 salt;
        uint64 expiry;
    }

    struct TraderParams {
        address taker;
        address recipient;
        uint256 takerTokenAmount;
        uint256 salt;
        uint64 expiry;
        bytes takerSig;
    }

     
    function fillLimitOrderByTrader(
        LimitOrderLibEIP712.Order calldata _order,
        bytes calldata _orderMakerSig,
        TraderParams calldata _params,
        CoordinatorParams calldata _crdParams
    ) external returns (uint256, uint256);

    enum Protocol {
        UniswapV3,
        Sushiswap
    }

    struct ProtocolParams {
        Protocol protocol;
        bytes data;
        address profitRecipient;
        uint256 takerTokenAmount;
        uint256 protocolOutMinimum;
        uint64 expiry;
    }

     
    function fillLimitOrderByProtocol(
        LimitOrderLibEIP712.Order calldata _order,
        bytes calldata _orderMakerSig,
        ProtocolParams calldata _params,
        CoordinatorParams calldata _crdParams
    ) external returns (uint256);

     
    function cancelLimitOrder(LimitOrderLibEIP712.Order calldata _order, bytes calldata _cancelMakerSig) external;
}

 
pragma solidity >=0.7.0;



interface IUniswapV3SwapCallback {
    
    
     
     
    
     
    
     
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

 
pragma solidity ^0.7.6;

abstract contract BaseLibEIP712 {
     

     
    string public constant EIP191_HEADER = "\x19\x01";

     
    string public constant EIP712_DOMAIN_NAME = "Tokenlon";
    string public constant EIP712_DOMAIN_VERSION = "v5";

     
    bytes32 public immutable EIP712_DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(EIP712_DOMAIN_NAME)),
                keccak256(bytes(EIP712_DOMAIN_VERSION)),
                getChainID(),
                address(this)
            )
        );

     
    function getChainID() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function getEIP712Hash(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(EIP191_HEADER, EIP712_DOMAIN_SEPARATOR, structHash));
    }
}

 
contract SignatureValidator {
    using LibBytes for bytes;

     

     
    bytes4 internal constant ERC1271_MAGICVALUE = 0x20c13b0b;

     
    bytes4 internal constant ERC1271_MAGICVALUE_BYTES32 = 0x1626ba7e;

     
    bytes4 internal constant ERC1271_FALLBACK_MAGICVALUE_BYTES32 = 0xb0671381;

     
    enum SignatureType {
        Illegal,  
        Invalid,  
        EIP712,  
        EthSign,  
        WalletBytes,  
        WalletBytes32,  
        Wallet,  
        NSignatureTypes  
    }

     

     
    function isValidSignature(
        address _signerAddress,
        bytes32 _hash,
        bytes memory _data,
        bytes memory _sig
    ) public view returns (bool isValid) {
        require(_sig.length > 0, "SignatureValidator#isValidSignature: length greater than 0 required");

        require(_signerAddress != address(0x0), "SignatureValidator#isValidSignature: invalid signer");

         
        uint8 signatureTypeRaw = uint8(_sig.popLastByte());

         
        require(signatureTypeRaw < uint8(SignatureType.NSignatureTypes), "SignatureValidator#isValidSignature: unsupported signature");

         
        SignatureType signatureType = SignatureType(signatureTypeRaw);

         
        uint8 v;
        bytes32 r;
        bytes32 s;
        address recovered;

         
         
         
         
         
        if (signatureType == SignatureType.Illegal) {
            revert("SignatureValidator#isValidSignature: illegal signature");

             
        } else if (signatureType == SignatureType.EIP712) {
            require(_sig.length == 97, "SignatureValidator#isValidSignature: length 97 required");
            r = _sig.readBytes32(0);
            s = _sig.readBytes32(32);
            v = uint8(_sig[64]);
            recovered = ecrecover(_hash, v, r, s);
            isValid = _signerAddress == recovered;
            return isValid;

             
        } else if (signatureType == SignatureType.EthSign) {
            require(_sig.length == 97, "SignatureValidator#isValidSignature: length 97 required");
            r = _sig.readBytes32(0);
            s = _sig.readBytes32(32);
            v = uint8(_sig[64]);
            recovered = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)), v, r, s);
            isValid = _signerAddress == recovered;
            return isValid;

             
        } else if (signatureType == SignatureType.WalletBytes) {
            isValid = ERC1271_MAGICVALUE == IERC1271Wallet(_signerAddress).isValidSignature(_data, _sig);
            return isValid;

             
        } else if (signatureType == SignatureType.WalletBytes32) {
            isValid = ERC1271_MAGICVALUE_BYTES32 == IERC1271Wallet(_signerAddress).isValidSignature(_hash, _sig);
            return isValid;
        } else if (signatureType == SignatureType.Wallet) {
            isValid = isValidWalletSignature(_hash, _signerAddress, _sig);
            return isValid;
        }

         
         
         
         
         
        revert("SignatureValidator#isValidSignature: unsupported signature");
    }

    
    
    
     
    
    
    function isValidWalletSignature(
        bytes32 hash,
        address walletAddress,
        bytes memory signature
    ) internal view returns (bool isValid) {
        bytes memory _calldata = abi.encodeWithSelector(IWallet(walletAddress).isValidSignature.selector, hash, signature);
        bytes32 magic_salt = bytes32(bytes4(keccak256("isValidWalletSignature(bytes32,address,bytes)")));
        assembly {
            if iszero(extcodesize(walletAddress)) {
                 
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000c57414c4c45545f4552524f5200000000000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }

            let cdStart := add(_calldata, 32)
            let success := staticcall(
                gas(),  
                walletAddress,  
                cdStart,  
                mload(_calldata),  
                cdStart,  
                32  
            )

            if iszero(eq(returndatasize(), 32)) {
                 
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000c57414c4c45545f4552524f5200000000000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }

            switch success
            case 0 {
                 
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(64, 0x0000000c57414c4c45545f4552524f5200000000000000000000000000000000)
                mstore(96, 0)
                revert(0, 100)
            }
            case 1 {
                 
                isValid := eq(
                    and(mload(cdStart), 0xffffffff00000000000000000000000000000000000000000000000000000000),
                    and(magic_salt, 0xffffffff00000000000000000000000000000000000000000000000000000000)
                )
            }
        }
        return isValid;
    }
}

 

pragma solidity ^0.7.0;

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
} 
pragma solidity 0.7.6;




















contract LimitOrder is ILimitOrder, BaseLibEIP712, SignatureValidator, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public constant version = "1.0.0";
    uint256 public immutable factorActivateDelay;
    IPermanentStorage public immutable permStorage;
    address public immutable userProxy;
    IWETH public immutable weth;

     
    address public immutable uniswapV3RouterAddress;
    address public immutable sushiswapRouterAddress;

     
    address public operator;
    address public coordinator;
    ISpender public spender;
    address public feeCollector;
    address private nominatedOperator;

     
    uint256 public factorsTimeLock;
    uint16 public makerFeeFactor = 0;
    uint16 public pendingMakerFeeFactor;
    uint16 public takerFeeFactor = 0;
    uint16 public pendingTakerFeeFactor;
    uint16 public profitFeeFactor = 0;
    uint16 public pendingProfitFeeFactor;

    constructor(
        address _operator,
        address _coordinator,
        address _userProxy,
        ISpender _spender,
        IPermanentStorage _permStorage,
        IWETH _weth,
        uint256 _factorActivateDelay,
        address _uniswapV3RouterAddress,
        address _sushiswapRouterAddress,
        address _feeCollector
    ) {
        operator = _operator;
        coordinator = _coordinator;
        userProxy = _userProxy;
        spender = _spender;
        permStorage = _permStorage;
        weth = _weth;
        factorActivateDelay = _factorActivateDelay;
        uniswapV3RouterAddress = _uniswapV3RouterAddress;
        sushiswapRouterAddress = _sushiswapRouterAddress;
        feeCollector = _feeCollector;
    }

    receive() external payable {}

    modifier onlyOperator() {
        require(operator == msg.sender, "LimitOrder: not operator");
        _;
    }

    modifier onlyUserProxy() {
        require(address(userProxy) == msg.sender, "LimitOrder: not the UserProxy contract");
        _;
    }

    function nominateNewOperator(address _newOperator) external onlyOperator {
        require(_newOperator != address(0), "LimitOrder: operator can not be zero address");
        nominatedOperator = _newOperator;

        emit OperatorNominated(_newOperator);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOperator, "LimitOrder: not nominated");
        emit OperatorChanged(operator, nominatedOperator);

        operator = nominatedOperator;
        nominatedOperator = address(0);
    }

    function upgradeSpender(address _newSpender) external onlyOperator {
        require(_newSpender != address(0), "LimitOrder: spender can not be zero address");
        spender = ISpender(_newSpender);

        emit UpgradeSpender(_newSpender);
    }

    function upgradeCoordinator(address _newCoordinator) external onlyOperator {
        require(_newCoordinator != address(0), "LimitOrder: coordinator can not be zero address");
        coordinator = _newCoordinator;

        emit UpgradeCoordinator(_newCoordinator);
    }

     
    function setAllowance(address[] calldata _tokenList, address _spender) external onlyOperator {
        for (uint256 i = 0; i < _tokenList.length; ++i) {
            IERC20(_tokenList[i]).safeApprove(_spender, LibConstant.MAX_UINT);

            emit AllowTransfer(_spender);
        }
    }

    function closeAllowance(address[] calldata _tokenList, address _spender) external onlyOperator {
        for (uint256 i = 0; i < _tokenList.length; ++i) {
            IERC20(_tokenList[i]).safeApprove(_spender, 0);

            emit DisallowTransfer(_spender);
        }
    }

     
    function depositETH() external onlyOperator {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            weth.deposit{ value: balance }();

            emit DepositETH(balance);
        }
    }

    function proposeFactors(
        uint16 _makerFeeFactor,
        uint16 _takerFeeFactor,
        uint16 _profitFeeFactor
    ) external onlyOperator {
        require(_makerFeeFactor <= LibConstant.BPS_MAX, "LimitOrder: Invalid maker fee factor");
        require(_takerFeeFactor <= LibConstant.BPS_MAX, "LimitOrder: Invalid taker fee factor");
        require(_profitFeeFactor <= LibConstant.BPS_MAX, "LimitOrder: Invalid profit fee factor");

        pendingMakerFeeFactor = _makerFeeFactor;
        pendingTakerFeeFactor = _takerFeeFactor;
        pendingProfitFeeFactor = _profitFeeFactor;

        factorsTimeLock = block.timestamp + factorActivateDelay;
    }

    function activateFactors() external {
        require(factorsTimeLock != 0, "LimitOrder: no pending fee factors");
        require(block.timestamp >= factorsTimeLock, "LimitOrder: fee factors timelocked");
        factorsTimeLock = 0;
        makerFeeFactor = pendingMakerFeeFactor;
        takerFeeFactor = pendingTakerFeeFactor;
        profitFeeFactor = pendingProfitFeeFactor;
        pendingMakerFeeFactor = 0;
        pendingTakerFeeFactor = 0;
        pendingProfitFeeFactor = 0;

        emit FactorsUpdated(makerFeeFactor, takerFeeFactor, profitFeeFactor);
    }

     
    function setFeeCollector(address _newFeeCollector) external onlyOperator {
        require(_newFeeCollector != address(0), "LimitOrder: fee collector can not be zero address");
        feeCollector = _newFeeCollector;

        emit SetFeeCollector(_newFeeCollector);
    }

     
    function fillLimitOrderByTrader(
        LimitOrderLibEIP712.Order calldata _order,
        bytes calldata _orderMakerSig,
        TraderParams calldata _params,
        CoordinatorParams calldata _crdParams
    ) external override onlyUserProxy nonReentrant returns (uint256, uint256) {
        bytes32 orderHash = getEIP712Hash(LimitOrderLibEIP712._getOrderStructHash(_order));

        _validateOrder(_order, orderHash, _orderMakerSig);
        bytes32 allowFillHash = _validateFillPermission(orderHash, _params.takerTokenAmount, _params.taker, _crdParams);
        _validateOrderTaker(_order, _params.taker);

        {
            LimitOrderLibEIP712.Fill memory fill = LimitOrderLibEIP712.Fill({
                orderHash: orderHash,
                taker: _params.taker,
                recipient: _params.recipient,
                takerTokenAmount: _params.takerTokenAmount,
                takerSalt: _params.salt,
                expiry: _params.expiry
            });
            _validateTraderFill(fill, _params.takerSig);
        }

        (uint256 makerTokenAmount, uint256 takerTokenAmount, uint256 remainingAmount) = _quoteOrder(_order, orderHash, _params.takerTokenAmount);

        uint256 makerTokenOut = _settleForTrader(
            TraderSettlement({
                orderHash: orderHash,
                allowFillHash: allowFillHash,
                trader: _params.taker,
                recipient: _params.recipient,
                maker: _order.maker,
                taker: _order.taker,
                makerToken: _order.makerToken,
                takerToken: _order.takerToken,
                makerTokenAmount: makerTokenAmount,
                takerTokenAmount: takerTokenAmount,
                remainingAmount: remainingAmount
            })
        );

        _recordOrderFilled(orderHash, takerTokenAmount);

        return (takerTokenAmount, makerTokenOut);
    }

    function _validateTraderFill(LimitOrderLibEIP712.Fill memory _fill, bytes memory _fillTakerSig) internal {
        require(_fill.expiry > uint64(block.timestamp), "LimitOrder: Fill request is expired");
        require(_fill.recipient != address(0), "LimitOrder: recipient can not be zero address");

        bytes32 fillHash = getEIP712Hash(LimitOrderLibEIP712._getFillStructHash(_fill));
        require(isValidSignature(_fill.taker, fillHash, bytes(""), _fillTakerSig), "LimitOrder: Fill is not signed by taker");

         
         
        permStorage.setLimitOrderTransactionSeen(fillHash);
    }

    function _validateFillPermission(
        bytes32 _orderHash,
        uint256 _fillAmount,
        address _executor,
        CoordinatorParams memory _crdParams
    ) internal returns (bytes32) {
        require(_crdParams.expiry > uint64(block.timestamp), "LimitOrder: Fill permission is expired");

        bytes32 allowFillHash = getEIP712Hash(
            LimitOrderLibEIP712._getAllowFillStructHash(
                LimitOrderLibEIP712.AllowFill({
                    orderHash: _orderHash,
                    executor: _executor,
                    fillAmount: _fillAmount,
                    salt: _crdParams.salt,
                    expiry: _crdParams.expiry
                })
            )
        );
        require(isValidSignature(coordinator, allowFillHash, bytes(""), _crdParams.sig), "LimitOrder: AllowFill is not signed by coordinator");

         
         
        permStorage.setLimitOrderAllowFillSeen(allowFillHash);

        return allowFillHash;
    }

    struct TraderSettlement {
        bytes32 orderHash;
        bytes32 allowFillHash;
        address trader;
        address recipient;
        address maker;
        address taker;
        IERC20 makerToken;
        IERC20 takerToken;
        uint256 makerTokenAmount;
        uint256 takerTokenAmount;
        uint256 remainingAmount;
    }

    function _settleForTrader(TraderSettlement memory _settlement) internal returns (uint256) {
         
        ISpender _spender = spender;
        address _feeCollector = feeCollector;

         
        uint256 takerTokenFee = _mulFactor(_settlement.takerTokenAmount, makerFeeFactor);
        uint256 takerTokenForMaker = _settlement.takerTokenAmount.sub(takerTokenFee);

         
        uint256 makerTokenFee = _mulFactor(_settlement.makerTokenAmount, takerFeeFactor);
        uint256 makerTokenForTrader = _settlement.makerTokenAmount.sub(makerTokenFee);

         
        _spender.spendFromUser(_settlement.trader, address(_settlement.takerToken), _settlement.takerTokenAmount);
        _settlement.takerToken.safeTransfer(_settlement.maker, takerTokenForMaker);
         
        if (takerTokenFee > 0) {
            _settlement.takerToken.safeTransfer(_feeCollector, takerTokenFee);
        }

         
        _spender.spendFromUser(_settlement.maker, address(_settlement.makerToken), _settlement.makerTokenAmount);
        _settlement.makerToken.safeTransfer(_settlement.recipient, makerTokenForTrader);
         
        if (makerTokenFee > 0) {
            _settlement.makerToken.safeTransfer(_feeCollector, makerTokenFee);
        }

         
        _emitLimitOrderFilledByTrader(
            LimitOrderFilledByTraderParams({
                orderHash: _settlement.orderHash,
                maker: _settlement.maker,
                taker: _settlement.trader,
                allowFillHash: _settlement.allowFillHash,
                recipient: _settlement.recipient,
                makerToken: address(_settlement.makerToken),
                takerToken: address(_settlement.takerToken),
                makerTokenFilledAmount: _settlement.makerTokenAmount,
                takerTokenFilledAmount: _settlement.takerTokenAmount,
                remainingAmount: _settlement.remainingAmount,
                makerTokenFee: makerTokenFee,
                takerTokenFee: takerTokenFee
            })
        );

        return makerTokenForTrader;
    }

     
    function fillLimitOrderByProtocol(
        LimitOrderLibEIP712.Order calldata _order,
        bytes calldata _orderMakerSig,
        ProtocolParams calldata _params,
        CoordinatorParams calldata _crdParams
    ) external override onlyUserProxy nonReentrant returns (uint256) {
        bytes32 orderHash = getEIP712Hash(LimitOrderLibEIP712._getOrderStructHash(_order));

        _validateOrder(_order, orderHash, _orderMakerSig);
        bytes32 allowFillHash = _validateFillPermission(orderHash, _params.takerTokenAmount, tx.origin, _crdParams);

        address protocolAddress = _getProtocolAddress(_params.protocol);
        _validateOrderTaker(_order, protocolAddress);

        (uint256 makerTokenAmount, uint256 takerTokenAmount, uint256 remainingAmount) = _quoteOrder(_order, orderHash, _params.takerTokenAmount);

        uint256 relayerTakerTokenProfit = _settleForProtocol(
            ProtocolSettlement({
                orderHash: orderHash,
                allowFillHash: allowFillHash,
                protocolAddress: protocolAddress,
                protocol: _params.protocol,
                data: _params.data,
                relayer: tx.origin,
                profitRecipient: _params.profitRecipient,
                maker: _order.maker,
                taker: _order.taker,
                makerToken: _order.makerToken,
                takerToken: _order.takerToken,
                makerTokenAmount: makerTokenAmount,
                takerTokenAmount: takerTokenAmount,
                remainingAmount: remainingAmount,
                protocolOutMinimum: _params.protocolOutMinimum,
                expiry: _params.expiry
            })
        );

        _recordOrderFilled(orderHash, takerTokenAmount);

        return relayerTakerTokenProfit;
    }

    function _getProtocolAddress(Protocol protocol) internal view returns (address) {
        if (protocol == Protocol.UniswapV3) {
            return uniswapV3RouterAddress;
        }
        if (protocol == Protocol.Sushiswap) {
            return sushiswapRouterAddress;
        }
        revert("LimitOrder: Unknown protocol");
    }

    struct ProtocolSettlement {
        bytes32 orderHash;
        bytes32 allowFillHash;
        address protocolAddress;
        Protocol protocol;
        bytes data;
        address relayer;
        address profitRecipient;
        address maker;
        address taker;
        IERC20 makerToken;
        IERC20 takerToken;
        uint256 makerTokenAmount;
        uint256 takerTokenAmount;
        uint256 remainingAmount;
        uint256 protocolOutMinimum;
        uint64 expiry;
    }

    function _settleForProtocol(ProtocolSettlement memory _settlement) internal returns (uint256) {
        require(_settlement.profitRecipient != address(0), "LimitOrder: profitRecipient can not be zero address");

         
        spender.spendFromUser(_settlement.maker, address(_settlement.makerToken), _settlement.makerTokenAmount);

        uint256 takerTokenOut = _swapByProtocol(_settlement);

        require(takerTokenOut >= _settlement.takerTokenAmount, "LimitOrder: Insufficient token amount out from protocol");

        uint256 ammOutputExtra = takerTokenOut.sub(_settlement.takerTokenAmount);
        uint256 relayerTakerTokenProfitFee = _mulFactor(ammOutputExtra, profitFeeFactor);
        uint256 relayerTakerTokenProfit = ammOutputExtra.sub(relayerTakerTokenProfitFee);
         
        _settlement.takerToken.safeTransfer(_settlement.profitRecipient, relayerTakerTokenProfit);

         
        uint256 takerTokenFee = _mulFactor(_settlement.takerTokenAmount, makerFeeFactor);
        uint256 takerTokenForMaker = _settlement.takerTokenAmount.sub(takerTokenFee);

         
        _settlement.takerToken.safeTransfer(_settlement.maker, takerTokenForMaker);

         
        uint256 feeTotal = takerTokenFee.add(relayerTakerTokenProfitFee);
        if (feeTotal > 0) {
            _settlement.takerToken.safeTransfer(feeCollector, feeTotal);
        }

         
        _emitLimitOrderFilledByProtocol(
            LimitOrderFilledByProtocolParams({
                orderHash: _settlement.orderHash,
                maker: _settlement.maker,
                taker: _settlement.protocolAddress,
                allowFillHash: _settlement.allowFillHash,
                relayer: _settlement.relayer,
                profitRecipient: _settlement.profitRecipient,
                makerToken: address(_settlement.makerToken),
                takerToken: address(_settlement.takerToken),
                makerTokenFilledAmount: _settlement.makerTokenAmount,
                takerTokenFilledAmount: _settlement.takerTokenAmount,
                remainingAmount: _settlement.remainingAmount,
                makerTokenFee: 0,
                takerTokenFee: takerTokenFee,
                relayerTakerTokenProfit: relayerTakerTokenProfit,
                relayerTakerTokenProfitFee: relayerTakerTokenProfitFee
            })
        );

        return relayerTakerTokenProfit;
    }

    function _swapByProtocol(ProtocolSettlement memory _settlement) internal returns (uint256 amountOut) {
        _settlement.makerToken.safeApprove(_settlement.protocolAddress, _settlement.makerTokenAmount);

         
        if (_settlement.protocol == Protocol.UniswapV3) {
            amountOut = LibUniswapV3.exactInput(
                _settlement.protocolAddress,
                LibUniswapV3.ExactInputParams({
                    tokenIn: address(_settlement.makerToken),
                    tokenOut: address(_settlement.takerToken),
                    path: _settlement.data,
                    recipient: address(this),
                    deadline: _settlement.expiry,
                    amountIn: _settlement.makerTokenAmount,
                    amountOutMinimum: _settlement.protocolOutMinimum
                })
            );
        } else {
             
            address[] memory path = abi.decode(_settlement.data, (address[]));
            amountOut = LibUniswapV2.swapExactTokensForTokens(
                _settlement.protocolAddress,
                LibUniswapV2.SwapExactTokensForTokensParams({
                    tokenIn: address(_settlement.makerToken),
                    tokenInAmount: _settlement.makerTokenAmount,
                    tokenOut: address(_settlement.takerToken),
                    tokenOutAmountMin: _settlement.protocolOutMinimum,
                    path: path,
                    to: address(this),
                    deadline: _settlement.expiry
                })
            );
        }

        _settlement.makerToken.safeApprove(_settlement.protocolAddress, 0);
    }

     
    function cancelLimitOrder(LimitOrderLibEIP712.Order calldata _order, bytes calldata _cancelOrderMakerSig) external override onlyUserProxy nonReentrant {
        require(_order.expiry > uint64(block.timestamp), "LimitOrder: Order is expired");
        bytes32 orderHash = getEIP712Hash(LimitOrderLibEIP712._getOrderStructHash(_order));
        bool isCancelled = LibOrderStorage.getStorage().orderHashToCancelled[orderHash];
        require(!isCancelled, "LimitOrder: Order is cancelled already");
        {
            LimitOrderLibEIP712.Order memory cancelledOrder = _order;
            cancelledOrder.takerTokenAmount = 0;

            bytes32 cancelledOrderHash = getEIP712Hash(LimitOrderLibEIP712._getOrderStructHash(cancelledOrder));
            require(isValidSignature(_order.maker, cancelledOrderHash, bytes(""), _cancelOrderMakerSig), "LimitOrder: Cancel request is not signed by maker");
        }

         
        LibOrderStorage.getStorage().orderHashToCancelled[orderHash] = true;
        emit OrderCancelled(orderHash, _order.maker);
    }

     

    function _validateOrder(
        LimitOrderLibEIP712.Order memory _order,
        bytes32 _orderHash,
        bytes memory _orderMakerSig
    ) internal view {
        require(_order.expiry > uint64(block.timestamp), "LimitOrder: Order is expired");
        bool isCancelled = LibOrderStorage.getStorage().orderHashToCancelled[_orderHash];
        require(!isCancelled, "LimitOrder: Order is cancelled");

        require(isValidSignature(_order.maker, _orderHash, bytes(""), _orderMakerSig), "LimitOrder: Order is not signed by maker");
    }

    function _validateOrderTaker(LimitOrderLibEIP712.Order memory _order, address _taker) internal pure {
        if (_order.taker != address(0)) {
            require(_order.taker == _taker, "LimitOrder: Order cannot be filled by this taker");
        }
    }

    function _quoteOrder(
        LimitOrderLibEIP712.Order memory _order,
        bytes32 _orderHash,
        uint256 _takerTokenAmount
    )
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 takerTokenFilledAmount = LibOrderStorage.getStorage().orderHashToTakerTokenFilledAmount[_orderHash];

        require(takerTokenFilledAmount < _order.takerTokenAmount, "LimitOrder: Order is filled");

        uint256 takerTokenFillableAmount = _order.takerTokenAmount.sub(takerTokenFilledAmount);
        uint256 takerTokenQuota = Math.min(_takerTokenAmount, takerTokenFillableAmount);
        uint256 makerTokenQuota = takerTokenQuota.mul(_order.makerTokenAmount).div(_order.takerTokenAmount);
        uint256 remainingAfterFill = takerTokenFillableAmount.sub(takerTokenQuota);

        require(makerTokenQuota != 0 && takerTokenQuota != 0, "LimitOrder: zero token amount");
        return (makerTokenQuota, takerTokenQuota, remainingAfterFill);
    }

    function _recordOrderFilled(bytes32 _orderHash, uint256 _takerTokenAmount) internal {
        LibOrderStorage.Storage storage stor = LibOrderStorage.getStorage();
        uint256 takerTokenFilledAmount = stor.orderHashToTakerTokenFilledAmount[_orderHash];
        stor.orderHashToTakerTokenFilledAmount[_orderHash] = takerTokenFilledAmount.add(_takerTokenAmount);
    }

     

    function _mulFactor(uint256 amount, uint256 factor) internal returns (uint256) {
        return amount.mul(factor).div(LibConstant.BPS_MAX);
    }

     

    struct LimitOrderFilledByTraderParams {
        bytes32 orderHash;
        address maker;
        address taker;
        bytes32 allowFillHash;
        address recipient;
        address makerToken;
        address takerToken;
        uint256 makerTokenFilledAmount;
        uint256 takerTokenFilledAmount;
        uint256 remainingAmount;
        uint256 makerTokenFee;
        uint256 takerTokenFee;
    }

    function _emitLimitOrderFilledByTrader(LimitOrderFilledByTraderParams memory _params) internal {
        emit LimitOrderFilledByTrader(
            _params.orderHash,
            _params.maker,
            _params.taker,
            _params.allowFillHash,
            _params.recipient,
            FillReceipt({
                makerToken: _params.makerToken,
                takerToken: _params.takerToken,
                makerTokenFilledAmount: _params.makerTokenFilledAmount,
                takerTokenFilledAmount: _params.takerTokenFilledAmount,
                remainingAmount: _params.remainingAmount,
                makerTokenFee: _params.makerTokenFee,
                takerTokenFee: _params.takerTokenFee
            })
        );
    }

    struct LimitOrderFilledByProtocolParams {
        bytes32 orderHash;
        address maker;
        address taker;
        bytes32 allowFillHash;
        address relayer;
        address profitRecipient;
        address makerToken;
        address takerToken;
        uint256 makerTokenFilledAmount;
        uint256 takerTokenFilledAmount;
        uint256 remainingAmount;
        uint256 makerTokenFee;
        uint256 takerTokenFee;
        uint256 relayerTakerTokenProfit;
        uint256 relayerTakerTokenProfitFee;
    }

    function _emitLimitOrderFilledByProtocol(LimitOrderFilledByProtocolParams memory _params) internal {
        emit LimitOrderFilledByProtocol(
            _params.orderHash,
            _params.maker,
            _params.taker,
            _params.allowFillHash,
            _params.relayer,
            _params.profitRecipient,
            FillReceipt({
                makerToken: _params.makerToken,
                takerToken: _params.takerToken,
                makerTokenFilledAmount: _params.makerTokenFilledAmount,
                takerTokenFilledAmount: _params.takerTokenFilledAmount,
                remainingAmount: _params.remainingAmount,
                makerTokenFee: _params.makerTokenFee,
                takerTokenFee: _params.takerTokenFee
            }),
            _params.relayerTakerTokenProfit,
            _params.relayerTakerTokenProfitFee
        );
    }
}

pragma solidity >=0.7.0;

interface IERC1271Wallet {
     
    function isValidSignature(bytes calldata _data, bytes calldata _signature) external view returns (bytes4 magicValue);

     
    function isValidSignature(bytes32 _hash, bytes calldata _signature) external view returns (bytes4 magicValue);
}

pragma solidity >=0.7.0;

interface IPermanentStorage {
    function wethAddr() external view returns (address);

    function getCurvePoolInfo(
        address _makerAddr,
        address _takerAssetAddr,
        address _makerAssetAddr
    )
        external
        view
        returns (
            int128 takerAssetIndex,
            int128 makerAssetIndex,
            uint16 swapMethod,
            bool supportGetDx
        );

    function setCurvePoolInfo(
        address _makerAddr,
        address[] calldata _underlyingCoins,
        address[] calldata _coins,
        bool _supportGetDx
    ) external;

    function isTransactionSeen(bytes32 _transactionHash) external view returns (bool);  

    function isAMMTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isRFQTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isLimitOrderTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isLimitOrderAllowFillSeen(bytes32 _allowFillHash) external view returns (bool);

    function isRelayerValid(address _relayer) external view returns (bool);

    function setTransactionSeen(bytes32 _transactionHash) external;  

    function setAMMTransactionSeen(bytes32 _transactionHash) external;

    function setRFQTransactionSeen(bytes32 _transactionHash) external;

    function setLimitOrderTransactionSeen(bytes32 _transactionHash) external;

    function setLimitOrderAllowFillSeen(bytes32 _allowFillHash) external;

    function setRelayersValid(address[] memory _relayers, bool[] memory _isValids) external;
}

pragma solidity >=0.7.0;

interface ISpender {
    function spendFromUser(
        address _user,
        address _tokenAddr,
        uint256 _amount
    ) external;

    function spendFromUserTo(
        address _user,
        address _tokenAddr,
        address _receiverAddr,
        uint256 _amount
    ) external;
}

 
pragma solidity >=0.7.0;

interface IUniswapRouterV2 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

 
pragma solidity >=0.7.0;






interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

pragma solidity >=0.7.0;

interface IWETH {
    function balanceOf(address account) external view returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}

 

pragma solidity ^0.7.6;

library LibBytes {
    using LibBytes for bytes;

     

     
    function popLastByte(bytes memory b) internal pure returns (bytes1 result) {
        require(b.length > 0, "LibBytes#popLastByte: greater than zero length required");

         
        result = b[b.length - 1];

        assembly {
             
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    
    
    
    
    function readAddress(bytes memory b, uint256 index) internal pure returns (address result) {
        require(
            b.length >= index + 20,  
            "LibBytes#readAddress greater or equal to 20 length required"
        );

         
         
         
        index += 20;

         
        assembly {
             
             
             
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

     

     
    function readBytes32(bytes memory b, uint256 index) internal pure returns (bytes32 result) {
        require(b.length >= index + 32, "LibBytes#readBytes32 greater or equal to 32 length required");

         
        index += 32;

         
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    
    
    
    
    function readBytes4(bytes memory b, uint256 index) internal pure returns (bytes4 result) {
        require(b.length >= index + 4, "LibBytes#readBytes4 greater or equal to 4 length required");

         
        index += 32;

         
        assembly {
            result := mload(add(b, index))
             
             
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    function readBytes2(bytes memory b, uint256 index) internal pure returns (bytes2 result) {
        require(b.length >= index + 2, "LibBytes#readBytes2 greater or equal to 2 length required");

         
        index += 32;

         
        assembly {
            result := mload(add(b, index))
             
             
            result := and(result, 0xFFFF000000000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }
}

pragma solidity ^0.7.6;

library LibConstant {
    int256 internal constant MAX_INT = 2**255 - 1;
    uint256 internal constant MAX_UINT = 2**256 - 1;
    uint16 internal constant BPS_MAX = 10000;
}

pragma solidity ^0.7.6;

library LibOrderStorage {
    bytes32 private constant STORAGE_SLOT = 0x341a85fd45142738553ca9f88acd66d751d05662e7332a1dd940f22830435fb4;
    
    struct Storage {
         
        mapping(bytes32 => uint256) orderHashToTakerTokenFilledAmount;
         
        mapping(bytes32 => bool) orderHashToCancelled;
    }

    
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("limitorder.order.storage")) - 1));

         
         
         
        assembly {
            stor.slot := STORAGE_SLOT
        }
    }
}

 
pragma solidity ^0.7.6;




library LibUniswapV2 {
    struct SwapExactTokensForTokensParams {
        address tokenIn;
        uint256 tokenInAmount;
        address tokenOut;
        uint256 tokenOutAmountMin;
        address[] path;
        address to;
        uint256 deadline;
    }

    function swapExactTokensForTokens(address _uniswapV2Router, SwapExactTokensForTokensParams memory _params) internal returns (uint256 amount) {
        _validatePath(_params.path, _params.tokenIn, _params.tokenOut);

        uint256[] memory amounts = IUniswapRouterV2(_uniswapV2Router).swapExactTokensForTokens(
            _params.tokenInAmount,
            _params.tokenOutAmountMin,
            _params.path,
            _params.to,
            _params.deadline
        );

        return amounts[amounts.length - 1];
    }

    function _validatePath(
        address[] memory _path,
        address _tokenIn,
        address _tokenOut
    ) internal {
        require(_path.length >= 2, "UniswapV2: Path length must be at least two");
        require(_path[0] == _tokenIn, "UniswapV2: First element of path must match token in");
        require(_path[_path.length - 1] == _tokenOut, "UniswapV2: Last element of path must match token out");
    }
}

 
pragma solidity ^0.7.6;






library LibUniswapV3 {
    using Path for bytes;

    enum SwapType {
        None,
        ExactInputSingle,
        ExactInput
    }

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInputSingle(address _uniswapV3Router, ExactInputSingleParams memory _params) internal returns (uint256 amount) {
        return
            ISwapRouter(_uniswapV3Router).exactInputSingle(
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: _params.tokenIn,
                    tokenOut: _params.tokenOut,
                    fee: _params.fee,
                    recipient: _params.recipient,
                    deadline: _params.deadline,
                    amountIn: _params.amountIn,
                    amountOutMinimum: _params.amountOutMinimum,
                    sqrtPriceLimitX96: 0
                })
            );
    }

    struct ExactInputParams {
        address tokenIn;
        address tokenOut;
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(address _uniswapV3Router, ExactInputParams memory _params) internal returns (uint256 amount) {
        _validatePath(_params.path, _params.tokenIn, _params.tokenOut);
        return
            ISwapRouter(_uniswapV3Router).exactInput(
                ISwapRouter.ExactInputParams({
                    path: _params.path,
                    recipient: _params.recipient,
                    deadline: _params.deadline,
                    amountIn: _params.amountIn,
                    amountOutMinimum: _params.amountOutMinimum
                })
            );
    }

    function _validatePath(
        bytes memory _path,
        address _tokenIn,
        address _tokenOut
    ) internal {
        (address tokenA, address tokenB, ) = _path.decodeFirstPool();

        if (_path.hasMultiplePools()) {
            _path = _path.skipToken();
            while (_path.hasMultiplePools()) {
                _path = _path.skipToken();
            }
            (, tokenB, ) = _path.decodeFirstPool();
        }

        require(tokenA == _tokenIn, "UniswapV3: first element of path must match token in");
        require(tokenB == _tokenOut, "UniswapV3: last element of path must match token out");
    }
}

 
pragma solidity ^0.7.6;





library LimitOrderLibEIP712 {
    struct Order {
        IERC20 makerToken;
        IERC20 takerToken;
        uint256 makerTokenAmount;
        uint256 takerTokenAmount;
        address maker;
        address taker;
        uint256 salt;
        uint64 expiry;
    }

     
    uint256 private constant ORDER_TYPEHASH = 0x025174f0ee45736f4e018e96c368bd4baf3dce8d278860936559209f568c8ecb;

    function _getOrderStructHash(Order memory _order) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    ORDER_TYPEHASH,
                    address(_order.makerToken),
                    address(_order.takerToken),
                    _order.makerTokenAmount,
                    _order.takerTokenAmount,
                    _order.maker,
                    _order.taker,
                    _order.salt,
                    _order.expiry
                )
            );
    }

    struct Fill {
        bytes32 orderHash;  
        address taker;
        address recipient;
        uint256 takerTokenAmount;
        uint256 takerSalt;
        uint64 expiry;
    }

     
    uint256 private constant FILL_TYPEHASH = 0x4ef294060cea2f973f7fe2a6d78624328586118efb1c4d640855aac3ba70e9c9;

    function _getFillStructHash(Fill memory _fill) internal pure returns (bytes32) {
        return keccak256(abi.encode(FILL_TYPEHASH, _fill.orderHash, _fill.taker, _fill.recipient, _fill.takerTokenAmount, _fill.takerSalt, _fill.expiry));
    }

    struct AllowFill {
        bytes32 orderHash;  
        address executor;
        uint256 fillAmount;
        uint256 salt;
        uint64 expiry;
    }

     
    uint256 private constant ALLOW_FILL_TYPEHASH = 0xa471a3189b88889758f25ee2ce05f58964c40b03edc9cc9066079fd2b547f074;

    function _getAllowFillStructHash(AllowFill memory _allowFill) internal pure returns (bytes32) {
        return keccak256(abi.encode(ALLOW_FILL_TYPEHASH, _allowFill.orderHash, _allowFill.executor, _allowFill.fillAmount, _allowFill.salt, _allowFill.expiry));
    }
}

pragma solidity 0.7.6;




interface IWallet {
    
    
    
    
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bool isValid);
}

 
pragma solidity >=0.7.0;

library BytesLib {
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                 
                 
                tempBytes := mload(0x40)

                 
                 
                 
                 
                 
                 
                 
                 
                let lengthmod := and(_length, 31)

                 
                 
                 
                 
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                     
                     
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                 
                 
                mstore(0x40, and(add(mc, 31), not(31)))
            }
             
            default {
                tempBytes := mload(0x40)
                 
                 
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, "toUint24_overflow");
        require(_bytes.length >= _start + 3, "toUint24_outOfBounds");
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}


library Path {
    using BytesLib for bytes;

    
    uint256 private constant ADDR_SIZE = 20;
    
    uint256 private constant FEE_SIZE = 3;

    
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    
    
    
    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    
    
    
    
    
    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {
        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    
    
    
    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}

 

pragma solidity ^0.7.0;

 
library Math {
     
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

     
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

     
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
         
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

 

pragma solidity ^0.7.0;

 
library SafeMath {
     
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

     
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

     
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
         
         
         
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

     
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

     
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

 

pragma solidity ^0.7.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.7.0;





 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 

pragma solidity ^0.7.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

         
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
