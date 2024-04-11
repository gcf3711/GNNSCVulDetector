 
pragma experimental ABIEncoderV2;

 

 


 

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

 

interface GemLike {
    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function deposit() external payable;

    function withdraw(uint256) external;
}

interface DaiJoinLike {
    function vat() external returns (VatLike);

    function dai() external returns (GemLike);

    function join(address, uint256) external payable;

    function exit(address, uint256) external;
}

interface VatLike {
    function can(address, address) external view returns (uint256);

    function ilks(bytes32)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function dai(address) external view returns (uint256);

    function urns(bytes32, address) external view returns (uint256, uint256);

    function frob(
        bytes32,
        address,
        address,
        address,
        int256,
        int256
    ) external;

    function hope(address) external;

    function move(
        address,
        address,
        uint256
    ) external;
}

interface GemJoinLike {
    function dec() external returns (uint256);

    function gem() external returns (GemLike);

    function join(address, uint256) external payable;

    function exit(address, uint256) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint256);
}

interface OasisLike {
    function sellAllAmount(
        address pay_gem,
        uint256 pay_amt,
        address buy_gem,
        uint256 min_fill_amount
    ) external returns (uint256);
}

interface ManagerLike {
    function cdpCan(
        address,
        uint256,
        address
    ) external view returns (uint256);

    function ilks(uint256) external view returns (bytes32);

    function owns(uint256) external view returns (address);

    function urns(uint256) external view returns (address);

    function vat() external view returns (address);

    function open(bytes32, address) external returns (uint256);

    function give(uint256, address) external;

    function cdpAllow(
        uint256,
        address,
        uint256
    ) external;

    function urnAllow(address, uint256) external;

    function frob(
        uint256,
        int256,
        int256
    ) external;

    function flux(
        uint256,
        address,
        uint256
    ) external;

    function move(
        uint256,
        address,
        uint256
    ) external;

    function exit(
        address,
        uint256,
        address,
        uint256
    ) external;

    function quit(uint256, address) external;

    function enter(address, uint256) external;

    function shift(uint256, uint256) external;
}

interface SpotLike {
    function live() external view returns (uint256);

    function par() external view returns (uint256);

    function vat() external view returns (address);

    function ilks(bytes32) external view returns (address, uint256);
}

interface DssAutoLine {
    function exec(bytes32 _ilk) external returns (uint256);
}

interface OracleSecurityModule {
    function peek() external view returns (uint256, bool);

    function peep() external view returns (uint256, bool);

    function users(address) external view returns (bool);

    function bud(address) external view returns (bool);

    function oracle() external view returns (address);
}

 

interface IOSMedianizer {
    function foresight() external view returns (uint256 price, bool osm);

    function read() external view returns (uint256 price, bool osm);

  	function setAuthorized(address _authorized) external;
}

 

 
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

 

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

 

interface GUniPool is IERC20 {

    
    
    
    
    
    
    
     
    function mint(uint256 mintAmount, address receiver)
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityMinted
        );

    
    
    
    
    
    
     
    function burn(uint256 burnAmount, address receiver)
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityBurned
        );

     

    
    
    
    
    
    
    function getMintAmounts(uint256 amount0Max, uint256 amount1Max)
        external
        view
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        );

    
     
     
    
    
    function getUnderlyingBalances()
        external
        view
        returns (uint256 amount0Current, uint256 amount1Current);

}

 

 
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

 

 

interface PSMLike {
    function gemJoin() external view returns (address);
    function sellGem(address usr, uint256 gemAmt) external;
    function buyGem(address usr, uint256 gemAmt) external;
}

interface IERC3156FlashLender {
    function maxFlashLoan(
        address token
    ) external view returns (uint256);
    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);
    function flashLoan(
         
        address receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

interface IERC3156FlashBorrower {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

library MakerDaiDelegateLib {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

     

    enum Action {WIND, UNWIND}

     
     
     
    IERC20 internal constant want = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 internal constant otherToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    uint256 public constant otherTokenTo18Conversion = 10 ** 12;
     
     
     
     

     
     
     
     

     
    GUniPool internal constant yieldBearing = GUniPool(0x50379f632ca68D36E50cfBC8F78fe16bd1499d1e);
    bytes32 internal constant ilk_yieldBearing = 0x47554e49563344414955534443322d4100000000000000000000000000000000;
    address internal constant gemJoinAdapter = 0xA7e4dDde3cBcEf122851A7C8F7A55f23c0Daf335;

    PSMLike public constant psm = PSMLike(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A) ;

    IERC20 internal constant borrowToken = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

     
    IERC3156FlashLender public constant flashmint = IERC3156FlashLender(0x1EB4CF3A948E7D72A198fe073cCb8C7a948cD853);

     
    uint256 internal constant WAD = 10**18;
    uint256 internal constant RAY = 10**27;

     
    uint256 internal constant MIN_MINTABLE = 50000 * WAD;

     
    ManagerLike internal constant manager = ManagerLike(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);

     
    DaiJoinLike internal constant daiJoin = DaiJoinLike(0x9759A6Ac90977b93B58547b4A71c78317f391A28);

     
    SpotLike internal constant spotter = SpotLike(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);

     
    JugLike internal constant jug = JugLike(0x19c0976f590D67707E62397C87829d896Dc0f1F1);

     
    DssAutoLine internal constant autoLine = DssAutoLine(0xC7Bdd1F2B16447dcf3dE045C4a039A60EC2f0ba3);

     

     
     
    function openCdp(bytes32 ilk) public returns (uint256) {
        return manager.open(ilk, address(this));
    }

     
    function shiftCdp(uint256 cdpId, uint256 newCdpId) public {
        manager.shift(cdpId, newCdpId);
    }

     
    function transferCdp(uint256 cdpId, address recipient) public {
        manager.give(cdpId, recipient);
    }

     
    function allowManagingCdp(
        uint256 cdpId,
        address user,
        bool isAccessGranted
    ) public {
        manager.cdpAllow(cdpId, user, isAccessGranted ? 1 : 0);
    }

     
    function lockGemAndDraw(
        address gemJoin,
        uint256 cdpId,
        uint256 collateralAmount,
        uint256 daiToMint,
        uint256 totalDebt
    ) public {
        address urn = manager.urns(cdpId);
        VatLike vat = VatLike(manager.vat());
        bytes32 ilk = manager.ilks(cdpId);

        if (daiToMint > 0) {
            daiToMint = _forceMintWithinLimits(vat, ilk, daiToMint, totalDebt);
        }

         
        if (collateralAmount > 0) {
            GemJoinLike(gemJoin).join(urn, collateralAmount);
        }

         
        manager.frob(
            cdpId,
            int256(convertTo18(gemJoin, collateralAmount)),
            _getDrawDart(vat, urn, ilk, daiToMint)
        );

         
        manager.move(cdpId, address(this), daiToMint.mul(1e27));

         
        vat.hope(address(daiJoin));

         
        daiJoin.exit(address(this), daiToMint);
    }

     
    function wipeAndFreeGem(
        address gemJoin,
        uint256 cdpId,
        uint256 collateralAmount,
        uint256 daiToRepay
    ) public {
        address urn = manager.urns(cdpId);

         
        if (daiToRepay > 0) {
            daiJoin.join(urn, daiToRepay);
        }

        uint256 wadC = convertTo18(gemJoin, collateralAmount);

         
        manager.frob(
            cdpId,
            -int256(wadC),
            _getWipeDart(
                VatLike(manager.vat()),
                VatLike(manager.vat()).dai(urn),
                urn,
                manager.ilks(cdpId)
            )
        );

         
        manager.flux(cdpId, address(this), collateralAmount);

         
        GemJoinLike(gemJoin).exit(address(this), collateralAmount);
    }

    function debtFloor(bytes32 ilk) public view returns (uint256) {
         
         
         
         
         
        (, , , , uint256 dust) = VatLike(manager.vat()).ilks(ilk);
        return dust.div(RAY);
    }

    function debtForCdp(uint256 cdpId, bytes32 ilk)
        public
        view
        returns (uint256)
    {
        address urn = manager.urns(cdpId);
        VatLike vat = VatLike(manager.vat());

         
        (, uint256 art) = vat.urns(ilk, urn);

         
        (, uint256 rate, , , ) = vat.ilks(ilk);

         
        return art.mul(rate).div(RAY);
    }

    function balanceOfCdp(uint256 cdpId, bytes32 ilk)
        public
        view
        returns (uint256)
    {
        address urn = manager.urns(cdpId);
        VatLike vat = VatLike(manager.vat());

        (uint256 ink, ) = vat.urns(ilk, urn);
        return ink;
    }

     
    function getDaiPar() public view returns (uint256) {
         
        return spotter.par();
    }

     
    function getLiquidationRatio(bytes32 ilk) public view returns (uint256) {
        (, uint256 liquidationRatio) = spotter.ilks(ilk);
        return liquidationRatio;
    }

    function getSpotPrice(bytes32 ilk) public view returns (uint256) {
        VatLike vat = VatLike(manager.vat());

         
        (, , uint256 spot, , ) = vat.ilks(ilk);

        uint256 liquidationRatio = getLiquidationRatio(ilk);

         
        return spot.mul(liquidationRatio).div(RAY * 1e9);
    }

    function getPessimisticRatioOfCdpWithExternalPrice(
        uint256 cdpId,
        bytes32 ilk,
        uint256 externalPrice,
        uint256 collateralizationRatioPrecision
    ) public view returns (uint256) {
         
        uint256 price = Math.min(getSpotPrice(ilk), externalPrice);
        require(price > 0);  

        uint256 totalCollateralValue = balanceOfCdp(cdpId, ilk).mul(price).div(WAD);
        uint256 totalDebt = debtForCdp(cdpId, ilk);

         
         
        if (totalDebt == 0) {
            totalDebt = 1;
        }

        return totalCollateralValue.mul(collateralizationRatioPrecision).div(totalDebt);
    }

     
     
    function keepBasicMakerHygiene(bytes32 ilk) public {
         
        jug.drip(ilk);

         
        autoLine.exec(ilk);
    }

    function daiJoinAddress() public view returns (address) {
        return address(daiJoin);
    }

     
    function isDaiAvailableToMint(bytes32 ilk) public view returns (bool) {
        return balanceOfDaiAvailableToMint(ilk) >= MIN_MINTABLE;
    }

     
    function balanceOfDaiAvailableToMint(bytes32 ilk) public view returns (uint256) {
        VatLike vat = VatLike(manager.vat());
        (uint256 Art, uint256 rate, , uint256 line, ) = vat.ilks(ilk);

         
        uint256 vatDebt = Art.mul(rate);

        if (vatDebt >= line) {
            return 0;
        }

        return line.sub(vatDebt).div(RAY);
    }

    function wind(
        uint256 wantAmountInitial,
        uint256 targetCollateralizationRatio,
        uint256 cdpId
    ) public {
        wantAmountInitial = Math.min(wantAmountInitial, balanceOfWant());
         
        uint256 flashloanAmount = wantAmountInitial.mul(RAY).div(targetCollateralizationRatio.mul(1e9).sub(RAY));
        VatLike vat = VatLike(manager.vat());
        uint256 currentDebt = debtForCdp(cdpId, ilk_yieldBearing);
        flashloanAmount = Math.min(flashloanAmount, _forceMintWithinLimits(vat, ilk_yieldBearing, flashloanAmount, currentDebt));
         
        if ( (currentDebt.add(flashloanAmount)) <= debtFloor(ilk_yieldBearing).add(1e15)){
            return;
        }
        bytes memory data = abi.encode(Action.WIND, cdpId, wantAmountInitial, flashloanAmount, targetCollateralizationRatio);
        _initFlashLoan(data, flashloanAmount);
    }

    function unwind(
        uint256 wantAmountRequested,
        uint256 targetCollateralizationRatio,
        uint256 cdpId
    ) public {
        if (balanceOfCdp(cdpId, ilk_yieldBearing) == 0){
            return;
        }
         
        uint256 flashloanAmount = debtForCdp(cdpId, ilk_yieldBearing).add(1);
        bytes memory data = abi.encode(Action.UNWIND, cdpId, wantAmountRequested, flashloanAmount, targetCollateralizationRatio);
         
        _initFlashLoan(data, flashloanAmount);
    }

    function _wind(uint256 cdpId, uint256 flashloanRepayAmount, uint256 wantAmountInitial, uint256) public {
         
        uint256 yieldBearingAmountToLock = _swapWantToYieldBearing(balanceOfWant());
         
        _checkAllowance(gemJoinAdapter, address(yieldBearing), yieldBearingAmountToLock);
         
        lockGemAndDraw(
            gemJoinAdapter,
            cdpId,
            yieldBearingAmountToLock,
            flashloanRepayAmount,
            debtForCdp(cdpId, ilk_yieldBearing)
        );
    }

    function _unwind(uint256 cdpId, uint256 flashloanRepayAmount, uint256 wantAmountRequested, uint256 targetCollateralizationRatio) public {
         
         
        uint256 currentDebtPlusRounding = debtForCdp(cdpId, ilk_yieldBearing).add(1);
        _checkAllowance(daiJoinAddress(), address(borrowToken), currentDebtPlusRounding);
        wipeAndFreeGem(gemJoinAdapter, cdpId, balanceOfCdp(cdpId, ilk_yieldBearing), currentDebtPlusRounding);
         
         
        uint256 leveragePlusOne = (RAY.mul(WAD).div((targetCollateralizationRatio.mul(1e9).sub(RAY)))).add(WAD);
        uint256 totalRequestedInYieldBearing = wantAmountRequested.mul(leveragePlusOne).div(getWantPerYieldBearing());
         
        totalRequestedInYieldBearing = Math.min(totalRequestedInYieldBearing, balanceOfYieldBearing());

        _swapYieldBearingToWant(totalRequestedInYieldBearing);
         

         
        uint256 yieldBearingBalance = balanceOfYieldBearing();
        uint256 borrowTokenAmountToMint = yieldBearingBalance.mul(getWantPerYieldBearing()).div(targetCollateralizationRatio);
         
        if ( borrowTokenAmountToMint <= debtFloor(ilk_yieldBearing).add(1e15)){
            _swapYieldBearingToWant(balanceOfYieldBearing());
            yieldBearingBalance = balanceOfYieldBearing();
            return;
        }
         
        borrowTokenAmountToMint = Math.min(borrowTokenAmountToMint, flashloanRepayAmount);
         
        _checkAllowance(gemJoinAdapter, address(yieldBearing), yieldBearingBalance);
         
        lockGemAndDraw(
            gemJoinAdapter,
            cdpId,
            yieldBearingBalance,
            borrowTokenAmountToMint,
            debtForCdp(cdpId, ilk_yieldBearing)
        );
         
    }

     
    function getWantPerYieldBearing() internal view returns (uint256){
        (uint256 wantUnderlyingBalance, uint256 otherTokenUnderlyingBalance) = yieldBearing.getUnderlyingBalances();
        return (wantUnderlyingBalance.mul(WAD).add(otherTokenUnderlyingBalance.mul(WAD).mul(WAD).div(1e6))).div(yieldBearing.totalSupply());
    }

    function balanceOfWant() internal view returns (uint256) {
        return want.balanceOf(address(this));
    }

    function balanceOfYieldBearing() internal view returns (uint256) {
        return yieldBearing.balanceOf(address(this));
    }

    function balanceOfOtherToken() internal view returns (uint256) {
        return otherToken.balanceOf(address(this));
    }

     

        function _initFlashLoan(bytes memory data, uint256 amount) internal {
         
        _checkAllowance(address(flashmint), address(borrowToken), amount);
        flashmint.flashLoan(address(this), address(borrowToken), amount, data);
    }

    function _checkAllowance(
        address _contract,
        address _token,
        uint256 _amount
    ) internal {
        if (IERC20(_token).allowance(address(this), _contract) < _amount) {
             
            IERC20(_token).safeApprove(_contract, type(uint256).max);
        }
    }

    function _swapWantToYieldBearing(uint256 _amount) internal returns (uint256) {
        if (_amount == 0) {
            return 0;
        }
        _amount = Math.min(_amount, balanceOfWant());
        (uint256 wantRatio, uint256 otherTokenRatio) = yieldBearing.getUnderlyingBalances();
        wantRatio = wantRatio.mul(WAD).div(yieldBearing.totalSupply());
        otherTokenRatio = otherTokenRatio.mul(WAD).mul(otherTokenTo18Conversion).div(yieldBearing.totalSupply());
        uint256 wantAmountForMint = _amount.mul(wantRatio).div(wantRatio + otherTokenRatio);
        uint256 wantAmountToSwapToOtherTokenForMint = _amount.mul(otherTokenRatio).div(wantRatio + otherTokenRatio);
         
        _checkAllowance(address(psm), address(want), wantAmountToSwapToOtherTokenForMint);
        psm.buyGem(address(this), wantAmountToSwapToOtherTokenForMint.div(otherTokenTo18Conversion));

         
        wantAmountForMint = Math.min(wantAmountForMint, balanceOfWant());
        uint256 otherTokenBalance = balanceOfOtherToken();
        _checkAllowance(address(yieldBearing), address(want), wantAmountForMint);
        _checkAllowance(address(yieldBearing), address(otherToken), otherTokenBalance);
        (,,uint256 mintAmount) = yieldBearing.getMintAmounts(wantAmountForMint, otherTokenBalance);
        yieldBearing.mint(mintAmount, address(this));
        return balanceOfYieldBearing();
    }

    function _swapYieldBearingToWant(uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }
         
        yieldBearing.burn(Math.min(_amount, balanceOfYieldBearing()), address(this));

         
        uint256 otherTokenBalance = balanceOfOtherToken();

         
        address psmGemJoin = psm.gemJoin();
        _checkAllowance(psmGemJoin, address(otherToken), otherTokenBalance);
        psm.sellGem(address(this), otherTokenBalance);
    }

     
     
    function _forceMintWithinLimits(
        VatLike vat,
        bytes32 ilk,
        uint256 desiredAmount,
        uint256 debtBalance
    ) internal view returns (uint256) {
         
         
         
         
         
        (uint256 Art, uint256 rate, , uint256 line, uint256 dust) =
            vat.ilks(ilk);

         
        uint256 vatDebt = Art.mul(rate);

         
        if (
            vatDebt >= line || (desiredAmount.add(debtBalance) <= dust.div(RAY))
        ) {
            return 0;
        }

        uint256 maxMintableDAI = line.sub(vatDebt).div(RAY);

         
        if (maxMintableDAI < MIN_MINTABLE) {
            return 0;
        }

         
        if (maxMintableDAI > WAD) {
            maxMintableDAI = maxMintableDAI - WAD;
        }

        return Math.min(maxMintableDAI, desiredAmount);
    }

    function _getDrawDart(
        VatLike vat,
        address urn,
        bytes32 ilk,
        uint256 wad
    ) internal returns (int256 dart) {
         
        uint256 rate = jug.drip(ilk);

         
        uint256 dai = vat.dai(urn);

         
        if (dai < wad.mul(RAY)) {
             
            dart = int256(wad.mul(RAY).sub(dai).div(rate));
             
            dart = uint256(dart).mul(rate) < wad.mul(RAY) ? dart + 1 : dart;
        }
    }

    function _getWipeDart(
        VatLike vat,
        uint256 dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int256 dart) {
         
        (, uint256 rate, , , ) = vat.ilks(ilk);
         
        (, uint256 art) = vat.urns(ilk, urn);

         
        dart = int256(dai / rate);

         
        dart = uint256(dart) <= art ? -dart : -int256(art);
    }

    function convertTo18(address gemJoin, uint256 amt)
        internal
        returns (uint256 wad)
    {
         
         
         
        wad = amt.mul(10**(18 - GemJoinLike(gemJoin).dec()));
    }

}