 
pragma experimental ABIEncoderV2;


pragma solidity ^0.7.0;



contract DSMath {
    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(x, y);
    }

    function sub(uint x, uint y) internal virtual pure returns (uint z) {
        z = SafeMath.sub(x, y);
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.mul(x, y);
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.div(x, y);
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }
}

pragma solidity ^0.7.0;




abstract contract Stores {

     
    address constant internal ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

     
    address constant internal wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

     
    MemoryInterface constant internal instaMemory = MemoryInterface(0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F);

     
    function getUint(uint getId, uint val) internal returns (uint returnVal) {
        returnVal = getId == 0 ? val : instaMemory.getUint(getId);
    }

     
    function setUint(uint setId, uint val) virtual internal {
        if (setId != 0) instaMemory.setUint(setId, val);
    }

}

pragma solidity ^0.7.0;



contract Variables {

     
    struct AaveDataRaw {
        address targetDsa;
        uint[] supplyAmts;
        uint[] variableBorrowAmts;
        uint[] stableBorrowAmts;
        address[] supplyTokens;
        address[] borrowTokens;
    }

    struct AaveData {
        address targetDsa;
        uint[] supplyAmts;
        uint[] borrowAmts;
        address[] supplyTokens;
        address[] borrowTokens;
    }

     

     
    uint16 constant internal referralCode = 3228;
    
     
    address constant internal polygonReceiver = 0x4A090897f47993C2504144419751D6A91D79AbF4;
    
     
    FlashloanInterface constant internal flashloanContract = FlashloanInterface(0xd7e8E6f5deCc5642B77a5dD0e445965B128a585D);
    
     
    address constant internal erc20Predicate = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;

     
    AaveLendingPoolProviderInterface constant internal aaveProvider = AaveLendingPoolProviderInterface(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);

     
    AaveDataProviderInterface constant internal aaveData = AaveDataProviderInterface(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);

     
    AaveOracleInterface constant internal aaveOracle = AaveOracleInterface(0xA50ba011c48153De246E5192C8f9258A2ba79Ca9);

     
    StateSenderInterface constant internal stateSender = StateSenderInterface(0x28e4F3a7f651294B9564800b2D01f35189A5bFbE);

     
    IndexInterface public constant instaIndex = IndexInterface(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);

     
    RootChainManagerInterface public constant rootChainManager = RootChainManagerInterface(0xA0c68C638235ee32657e8f720a23ceC1bFc77C77);
    
    
     
    
     
    uint public safeRatioGap = 800000000000000000;  

     
    uint public fee = 998000000000000000;  

     
    mapping(address => bool) public isSupportedToken;

     
    address[] public supportedTokens;  

}

pragma solidity ^0.7.0;











abstract contract Helpers is DSMath, Stores, Variables {
    using SafeERC20 for IERC20;

    function _paybackBehalfOne(AaveInterface aave, address token, uint amt, uint rateMode, address user) private {
        address _token = token == ethAddr ? wethAddr : token;
        aave.repay(_token, amt, rateMode, user);
    }

    function _PaybackStable(
        uint _length,
        AaveInterface aave,
        address[] memory tokens,
        uint256[] memory amts,
        address user
    ) internal {
        for (uint i = 0; i < _length; i++) {
            if (amts[i] > 0) {
                _paybackBehalfOne(aave, tokens[i], amts[i], 1, user);
            }
        }
    }

    function _PaybackVariable(
        uint _length,
        AaveInterface aave,
        address[] memory tokens,
        uint256[] memory amts,
        address user
    ) internal {
        for (uint i = 0; i < _length; i++) {
            if (amts[i] > 0) {
                _paybackBehalfOne(aave, tokens[i], amts[i], 2, user);
            }
        }
    }

    function _PaybackCalculate(
        AaveInterface aave,
        AaveDataRaw memory _data,
        address sourceDsa
    ) internal returns (
        uint[] memory stableBorrow,
        uint[] memory variableBorrow,
        uint[] memory totalBorrow
    ) {
        uint _len = _data.borrowTokens.length;
        stableBorrow = new uint256[](_len);
        variableBorrow = new uint256[](_len);
        totalBorrow = new uint256[](_len);

        for (uint i = 0; i < _len; i++) {
            require(isSupportedToken[_data.borrowTokens[i]], "token-not-enabled");
            address _token = _data.borrowTokens[i] == ethAddr ? wethAddr : _data.borrowTokens[i];
            _data.borrowTokens[i] = _token;

            (
                ,
                uint stableDebt,
                uint variableDebt,
                ,,,,,
            ) = aaveData.getUserReserveData(_token, sourceDsa);


            stableBorrow[i] = _data.stableBorrowAmts[i] == uint(-1) ? stableDebt : _data.stableBorrowAmts[i];
            variableBorrow[i] = _data.variableBorrowAmts[i] == uint(-1) ? variableDebt : _data.variableBorrowAmts[i];

            totalBorrow[i] = add(stableBorrow[i], variableBorrow[i]);

            if (totalBorrow[i] > 0) {
                IERC20(_token).safeApprove(address(aave), totalBorrow[i]);
            }
            aave.borrow(_token, totalBorrow[i], 2, 3288, address(this));
        }
    }

    function _getAtokens(
        address dsa,
        address[] memory supplyTokens,
        uint[] memory supplyAmts
    ) internal returns (
        uint[] memory finalAmts
    ) {
        finalAmts = new uint256[](supplyTokens.length);
        for (uint i = 0; i < supplyTokens.length; i++) {
            require(isSupportedToken[supplyTokens[i]], "token-not-enabled");
            address _token = supplyTokens[i] == ethAddr ? wethAddr : supplyTokens[i];
            (address _aToken, ,) = aaveData.getReserveTokensAddresses(_token);
            ATokenInterface aTokenContract = ATokenInterface(_aToken);
            uint _finalAmt;
            if (supplyAmts[i] == uint(-1)) {
                _finalAmt = aTokenContract.balanceOf(dsa);
            } else {
                _finalAmt = supplyAmts[i];
            }
            require(aTokenContract.transferFrom(dsa, address(this), _finalAmt), "_getAtokens: atokens transfer failed");

            _finalAmt = wmul(_finalAmt, fee);
            finalAmts[i] = _finalAmt;

        }
    }

    function isPositionSafe() internal view returns (bool isOk) {
        AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());
        (,,,,,uint healthFactor) = aave.getUserAccountData(address(this));
        uint minLimit = wdiv(1e18, safeRatioGap);
        isOk = healthFactor > minLimit;
        require(isOk, "position-at-risk");
    }

    function getTokensPrices(address[] memory tokens) internal view returns(uint[] memory tokenPricesInEth) {
        tokenPricesInEth = AavePriceOracle(aaveProvider.getPriceOracle()).getAssetsPrices(tokens);
    }
    
     
    function getTokenLt(address[] memory tokens) internal view returns (uint[] memory decimals, uint[] memory tokenLts) {
        uint _len = tokens.length;
        decimals = new uint[](_len);
        tokenLts = new uint[](_len);
        for (uint i = 0; i < _len; i++) {
            (decimals[i],,tokenLts[i],,,,,,,) = aaveData.getReserveConfigurationData(tokens[i]);
        }
    }

    function convertTo18(uint amount, uint decimal) internal pure returns (uint) {
        return amount * (10 ** (18 - decimal));
    }

     
    function _checkRatio(AaveData memory data) public view {
        uint[] memory supplyTokenPrices = getTokensPrices(data.supplyTokens);
        (uint[] memory supplyDecimals, uint[] memory supplyLts) = getTokenLt(data.supplyTokens);

        uint[] memory borrowTokenPrices = getTokensPrices(data.borrowTokens);
        (uint[] memory borrowDecimals,) = getTokenLt(data.borrowTokens);
        uint netSupply;
        uint netBorrow;
        uint liquidation;
        for (uint i = 0; i < data.supplyTokens.length; i++) {
            uint _amt = wmul(convertTo18(data.supplyAmts[i], supplyDecimals[i]), supplyTokenPrices[i]);
            netSupply += _amt;
            liquidation += (_amt * supplyLts[i]) / 10000;  
        }
        for (uint i = 0; i < data.borrowTokens.length; i++) {
            uint _amt = wmul(convertTo18(data.borrowAmts[i], borrowDecimals[i]), borrowTokenPrices[i]);
            netBorrow += _amt;
        }
        uint _dif = wmul(netSupply, sub(1e18, safeRatioGap));
        require(netBorrow < sub(liquidation, _dif), "position-is-risky-to-migrate");
    }

}

pragma solidity >=0.7.0;


contract Events {
    event LogSettle(
        address[] tokens,
        uint256[] amts
    );

    event LogAaveV2Migrate(
        address indexed user,
        address indexed targetDsa,
        address[] supplyTokens,
        address[] borrowTokens,
        uint256[] supplyAmts,
        uint256[] variableBorrowAmts,
        uint256[] stableBorrowAmts
    );

    event LogUpdateVariables(
        uint256 oldFee,
        uint256 newFee,
        uint256 oldSafeRatioGap,
        uint256 newSafeRatioGap
    );

    event LogAddSupportedTokens(
        address[] tokens
    );

    event LogVariablesUpdate(uint _safeRatioGap, uint _fee);

}
pragma solidity ^0.7.0;









contract LiquidityResolver is Helpers, Events {
    using SafeERC20 for IERC20;

    function updateVariables(uint _safeRatioGap, uint _fee) public {
        require(msg.sender == instaIndex.master(), "not-master");
        safeRatioGap = _safeRatioGap;
        fee = _fee;
        emit LogVariablesUpdate(safeRatioGap, fee);
    }

    function addTokenSupport(address[] memory _tokens) public {
        require(msg.sender == instaIndex.master(), "not-master");
        for (uint i = 0; i < supportedTokens.length; i++) {
            delete isSupportedToken[supportedTokens[i]];
        }
        delete supportedTokens;
        for (uint i = 0; i < _tokens.length; i++) {
            require(!isSupportedToken[_tokens[i]], "already-added");
            isSupportedToken[_tokens[i]] = true;
            supportedTokens.push(_tokens[i]);
        }
        emit LogAddSupportedTokens(_tokens);
    }

    function spell(address _target, bytes memory _data) external {
        require(msg.sender == instaIndex.master(), "not-master");
        require(_target != address(0), "target-invalid");
        assembly {
            let succeeded := delegatecall(gas(), _target, add(_data, 0x20), mload(_data), 0, 0)

            switch iszero(succeeded)
                case 1 {
                     
                    let size := returndatasize()
                    returndatacopy(0x00, 0x00, size)
                    revert(0x00, size)
                }
        }
    }

     
    function settle(address[] calldata _tokens, uint[] calldata _amts) external {
         
        AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());
        for (uint i = 0; i < supportedTokens.length; i++) {
            address _token = supportedTokens[i];
            if (_token == wethAddr) {
                if (address(this).balance > 0) {
                    TokenInterface(wethAddr).deposit{value: address(this).balance}();
                }
            }
            IERC20 _tokenContract = IERC20(_token);
            uint _tokenBal = _tokenContract.balanceOf(address(this));
            if (_tokenBal > 0) {
                _tokenContract.safeApprove(address(aave), _tokenBal);
                aave.deposit(_token, _tokenBal, address(this), 3288);
            }
            (
                uint supplyBal,,
                uint borrowBal,
                ,,,,,
            ) = aaveData.getUserReserveData(_token, address(this));
            if (supplyBal != 0 && borrowBal != 0) {
                if (supplyBal > borrowBal) {
                    aave.withdraw(_token, borrowBal, address(this));  
                    IERC20(_token).safeApprove(address(aave), borrowBal);
                    aave.repay(_token, borrowBal, 2, address(this));
                } else {
                    aave.withdraw(_token, supplyBal, address(this));  
                    IERC20(_token).safeApprove(address(aave), supplyBal);
                    aave.repay(_token, supplyBal, 2, address(this));
                }
            }
        }
        for (uint i = 0; i < _tokens.length; i++) {
            address _token = _tokens[i] == ethAddr ? wethAddr : _tokens[i];
            aave.withdraw(_token, _amts[i], address(this));
            IERC20(_token).safeApprove(erc20Predicate, _amts[i]);
            rootChainManager.depositFor(polygonReceiver, _token, abi.encode(_amts[i]));

            isPositionSafe();
        }
        emit LogSettle(_tokens, _amts);
    }
}

contract MigrateResolver is LiquidityResolver {
    using SafeERC20 for IERC20;

    function _migrate(
        AaveInterface aave,
        AaveDataRaw memory _data,
        address sourceDsa
    ) internal {
        require(_data.supplyTokens.length > 0, "0-length-not-allowed");
        require(_data.targetDsa != address(0), "invalid-address");
        require(_data.supplyTokens.length == _data.supplyAmts.length, "invalid-length");
        require(
            _data.borrowTokens.length == _data.variableBorrowAmts.length &&
            _data.borrowTokens.length == _data.stableBorrowAmts.length,
            "invalid-length"
        );

        for (uint i = 0; i < _data.supplyTokens.length; i++) {
            address _token = _data.supplyTokens[i];
            for (uint j = 0; j < _data.supplyTokens.length; j++) {
                if (j != i) {
                    require(j != i, "token-repeated");
                }
            }
            require(_token != ethAddr, "should-be-eth-address");
        }

        for (uint i = 0; i < _data.borrowTokens.length; i++) {
            address _token = _data.borrowTokens[i];
            for (uint j = 0; j < _data.borrowTokens.length; j++) {
                if (j != i) {
                    require(j != i, "token-repeated");
                }
            }
            require(_token != ethAddr, "should-be-eth-address");
        }

        (uint[] memory stableBorrows, uint[] memory variableBorrows, uint[] memory totalBorrows) = _PaybackCalculate(aave, _data, sourceDsa);
        _PaybackStable(_data.borrowTokens.length, aave, _data.borrowTokens, stableBorrows, sourceDsa);
        _PaybackVariable(_data.borrowTokens.length, aave, _data.borrowTokens, variableBorrows, sourceDsa);

        (uint[] memory totalSupplies) = _getAtokens(sourceDsa, _data.supplyTokens, _data.supplyAmts);

         
        AaveData memory data;

        data.borrowTokens = _data.borrowTokens;
        data.supplyAmts = totalSupplies;
        data.supplyTokens = _data.supplyTokens;
        data.targetDsa = _data.targetDsa;
        data.borrowAmts = totalBorrows;

         
        _checkRatio(data);

        isPositionSafe();

        stateSender.syncState(polygonReceiver, abi.encode(data));

        emit LogAaveV2Migrate(
            sourceDsa,
            data.targetDsa,
            data.supplyTokens,
            data.borrowTokens,
            totalSupplies,
            variableBorrows,
            stableBorrows
        );
    }
    function migrateFlashCallback(AaveDataRaw calldata _data, address dsa, uint ethAmt) external {
        require(msg.sender == address(flashloanContract), "not-flashloan-contract");
        AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());

        TokenInterface wethContract = TokenInterface(wethAddr);
        wethContract.approve(address(aave), ethAmt);
        aave.deposit(wethAddr, ethAmt, address(this), 3288);
        _migrate(aave, _data, dsa);
        aave.withdraw(wethAddr, ethAmt, address(this));
        require(wethContract.transfer(address(flashloanContract), ethAmt), "migrateFlashCallback: weth transfer failed to Instapool");
    }
}

contract InstaAaveV2MigratorSenderImplementation is MigrateResolver {
    function migrate(AaveDataRaw calldata _data) external {
        AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());
        _migrate(aave, _data, msg.sender);
    }

    function migrateWithFlash(AaveDataRaw calldata _data, uint ethAmt) external {
        bytes memory callbackData = abi.encodeWithSelector(bytes4(this.migrateFlashCallback.selector), _data, msg.sender, ethAmt);
        bytes memory data = abi.encode(callbackData, ethAmt);

        flashloanContract.initiateFlashLoan(data, ethAmt);
    }
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


interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

interface MemoryInterface {
    function getUint(uint id) external returns (uint num);
    function setUint(uint id, uint val) external;
}

interface AccountInterface {
    function enable(address) external;
    function disable(address) external;
    function isAuth(address) external view returns (bool);
    function cast(
        string[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32);
}

pragma solidity >=0.7.0;


interface AaveInterface {
    function deposit(address _asset, uint256 _amount, address _onBehalfOf, uint16 _referralCode) external;
    function withdraw(address _asset, uint256 _amount, address _to) external;
    function borrow(
        address _asset,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode,
        address _onBehalfOf
    ) external;
    function repay(address _asset, uint256 _amount, uint256 _rateMode, address _onBehalfOf) external;
    function setUserUseReserveAsCollateral(address _asset, bool _useAsCollateral) external;
    function getUserAccountData(address user) external view returns (
        uint256 totalCollateralETH,
        uint256 totalDebtETH,
        uint256 availableBorrowsETH,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    );
}

interface AaveLendingPoolProviderInterface {
    function getLendingPool() external view returns (address);
    function getPriceOracle() external view returns (address);
}

 
interface AaveDataProviderInterface {
    function getReserveTokensAddresses(address _asset) external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    );
    function getUserReserveData(address _asset, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentStableDebt,
        uint256 currentVariableDebt,
        uint256 principalStableDebt,
        uint256 scaledVariableDebt,
        uint256 stableBorrowRate,
        uint256 liquidityRate,
        uint40 stableRateLastUpdated,
        bool usageAsCollateralEnabled
    );
    function getReserveConfigurationData(address asset) external view returns (
        uint256 decimals,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        bool usageAsCollateralEnabled,
        bool borrowingEnabled,
        bool stableBorrowRateEnabled,
        bool isActive,
        bool isFrozen
    );
}

interface AaveAddressProviderRegistryInterface {
    function getAddressesProvidersList() external view returns (address[] memory);
}

interface ATokenInterface {
    function scaledBalanceOf(address _user) external view returns (uint256);
    function isTransferAllowed(address _user, uint256 _amount) external view returns (bool);
    function balanceOf(address _user) external view returns(uint256);
    function transferFrom(address, address, uint) external returns (bool);
    function approve(address, uint256) external;
}

interface AaveOracleInterface {
    function getAssetPrice(address _asset) external view returns (uint256);
    function getAssetsPrices(address[] calldata _assets) external view returns(uint256[] memory);
    function getSourceOfAsset(address _asset) external view returns(address);
    function getFallbackOracle() external view returns(address);
}

interface StateSenderInterface {
    function syncState(address receiver, bytes calldata data) external;
    function register(address sender, address receiver) external;
}

interface IndexInterface {
    function master() external view returns (address);
}

interface FlashloanInterface {
    function initiateFlashLoan(bytes memory data, uint ethAmt) external;
}

interface AavePriceOracle {
    function getAssetPrice(address _asset) external view returns(uint256);
    function getAssetsPrices(address[] calldata _assets) external view returns(uint256[] memory);
    function getSourceOfAsset(address _asset) external view returns(uint256);
    function getFallbackOracle() external view returns(uint256);
}

interface ChainLinkInterface {
    function latestAnswer() external view returns (int256);
    function decimals() external view returns (uint256);
}

interface RootChainManagerInterface {
    function depositFor(address user, address token, bytes calldata depositData) external;
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
