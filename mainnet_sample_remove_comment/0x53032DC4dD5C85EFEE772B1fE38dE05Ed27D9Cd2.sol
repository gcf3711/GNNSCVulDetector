 
pragma experimental ABIEncoderV2;


 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity >=0.6.12;


interface IVault {
   

   
  event Deposit(address indexed userAddrs, address indexed asset, uint256 amount);
   
  event Withdraw(address indexed userAddrs, address indexed asset, uint256 amount);
   
  event Borrow(address indexed userAddrs, address indexed asset, uint256 amount);
   
  event Payback(address indexed userAddrs, address indexed asset, uint256 amount);

   
  event SetActiveProvider(address providerAddr);
   
  event Switch(
    address vault,
    address fromProviderAddrs,
    address toProviderAddr,
    uint256 debtamount,
    uint256 collattamount
  );

   

  function deposit(uint256 _collateralAmount) external payable;

  function withdraw(int256 _withdrawAmount) external;

  function borrow(uint256 _borrowAmount) external;

  function payback(int256 _repayAmount) external payable;

  function executeSwitch(
    address _newProvider,
    uint256 _flashLoanDebt,
    uint256 _fee
  ) external;

   

  function activeProvider() external view returns (address);

  function borrowBalance(address _provider) external view returns (uint256);

  function depositBalance(address _provider) external view returns (uint256);

  function getNeededCollateralFor(uint256 _amount, bool _withFactors)
    external
    view
    returns (uint256);

  function getLiquidationBonusFor(uint256 _amount, bool _flash) external view returns (uint256);

  function getProviders() external view returns (address[] memory);

  function fujiERC1155() external view returns (address);

   

  function setActiveProvider(address _provider) external;

  function updateF1155Balances() external;
}

 

pragma solidity >=0.6.12;


interface IFujiERC1155 {
   
  enum AssetType {
     
    collateralToken,
     
    debtToken
  }

   

  function getAssetID(AssetType _type, address _assetAddr) external view returns (uint256);

  function qtyOfManagedAssets() external view returns (uint64);

  function balanceOf(address _account, uint256 _id) external view returns (uint256);

   

   

   
  function mint(
    address _account,
    uint256 _id,
    uint256 _amount,
    bytes memory _data
  ) external;

  function burn(
    address _account,
    uint256 _id,
    uint256 _amount
  ) external;

  function updateState(uint256 _assetID, uint256 _newBalance) external;

  function addInitializeAsset(AssetType _type, address _addr) external returns (uint64);
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

 

pragma solidity >=0.4.25 <0.7.5;

interface IFlashLoanReceiver {
  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool);
}

 
interface ICallee {
   
  function callFunction(
    address sender,
    Account.Info memory accountInfo,
    bytes memory data
  ) external;
}

contract DyDxFlashloanBase {
   

  function _getMarketIdFromTokenAddress(ISoloMargin solo, address token)
    internal
    view
    returns (uint256)
  {
    uint256 numMarkets = solo.getNumMarkets();

    address curToken;
    for (uint256 i = 0; i < numMarkets; i++) {
      curToken = solo.getMarketTokenAddress(i);

      if (curToken == token) {
        return i;
      }
    }

    revert("No marketId found");
  }

  function _getAccountInfo(address receiver) internal pure returns (Account.Info memory) {
    return Account.Info({ owner: receiver, number: 1 });
  }

  function _getWithdrawAction(uint256 marketId, uint256 amount)
    internal
    view
    returns (Actions.ActionArgs memory)
  {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Withdraw,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: false,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: amount
        }),
        primaryMarketId: marketId,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: ""
      });
  }

  function _getCallAction(bytes memory data) internal view returns (Actions.ActionArgs memory) {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Call,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: false,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: 0
        }),
        primaryMarketId: 0,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: data
      });
  }

  function _getDepositAction(uint256 marketId, uint256 amount)
    internal
    view
    returns (Actions.ActionArgs memory)
  {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Deposit,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: true,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: amount
        }),
        primaryMarketId: marketId,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: ""
      });
  }
}

 

pragma solidity >=0.4.25 <0.7.5;

interface ICFlashloanReceiver {
  function executeOperation(
    address sender,
    address underlying,
    uint256 amount,
    uint256 fee,
    bytes calldata params
  ) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
 

pragma solidity >=0.6.12;















interface IVaultExt is IVault {
   
  struct VaultAssets {
    address collateralAsset;
    address borrowAsset;
    uint64 collateralID;
    uint64 borrowID;
  }

  function vAssets() external view returns (VaultAssets memory);
}

interface IFujiERC1155Ext is IFujiERC1155 {
  function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
    external
    view
    returns (uint256[] memory);
}

contract Fliquidator is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using LibUniversalERC20 for IERC20;

  struct Factor {
    uint64 a;
    uint64 b;
  }

   
  Factor public flashCloseF;

  IFujiAdmin private _fujiAdmin;
  IUniswapV2Router02 public swapper;

   
  event Liquidate(
    address indexed userAddr,
    address liquidator,
    address indexed asset,
    uint256 amount
  );
   
  event FlashClose(address indexed userAddr, address indexed asset, uint256 amount);
   
  event FlashLiquidate(address userAddr, address liquidator, address indexed asset, uint256 amount);

  modifier isAuthorized() {
    require(msg.sender == owner(), Errors.VL_NOT_AUTHORIZED);
    _;
  }

  modifier onlyFlash() {
    require(msg.sender == _fujiAdmin.getFlasher(), Errors.VL_NOT_AUTHORIZED);
    _;
  }

  modifier isValidVault(address _vaultAddr) {
    require(_fujiAdmin.validVault(_vaultAddr), "Invalid vault!");
    _;
  }

  constructor() public {
     
    flashCloseF.a = 1013;
    flashCloseF.b = 1000;
  }

  receive() external payable {}

   

   
  function batchLiquidate(address[] calldata _userAddrs, address _vault)
    external
    nonReentrant
    isValidVault(_vault)
  {
     
    IVault(_vault).updateF1155Balances();

     
    IFujiERC1155Ext f1155 = IFujiERC1155Ext(IVault(_vault).fujiERC1155());

     
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

    address[] memory formattedUserAddrs = new address[](2 * _userAddrs.length);
    uint256[] memory formattedIds = new uint256[](2 * _userAddrs.length);

     
    for (uint256 i = 0; i < _userAddrs.length; i++) {
      formattedUserAddrs[2 * i] = _userAddrs[i];
      formattedUserAddrs[2 * i + 1] = _userAddrs[i];
      formattedIds[2 * i] = vAssets.collateralID;
      formattedIds[2 * i + 1] = vAssets.borrowID;
    }

     
    uint256[] memory usrsBals = f1155.balanceOfBatch(formattedUserAddrs, formattedIds);

    uint256 neededCollateral;
    uint256 debtBalanceTotal;

    for (uint256 i = 0; i < formattedUserAddrs.length; i += 2) {
       
      neededCollateral = IVault(_vault).getNeededCollateralFor(usrsBals[i + 1], true);

       
      if (usrsBals[i] < neededCollateral) {
         
        debtBalanceTotal = debtBalanceTotal.add(usrsBals[i + 1]);
      } else {
         
        formattedUserAddrs[i] = address(0);
        formattedUserAddrs[i + 1] = address(0);
      }
    }

     
    require(debtBalanceTotal > 0, Errors.VL_USER_NOT_LIQUIDATABLE);

     
    require(
      IERC20(vAssets.borrowAsset).allowance(msg.sender, address(this)) >= debtBalanceTotal,
      Errors.VL_MISSING_ERC20_ALLOWANCE
    );

     
    IERC20(vAssets.borrowAsset).transferFrom(msg.sender, address(this), debtBalanceTotal);

     
    IERC20(vAssets.borrowAsset).univTransfer(payable(_vault), debtBalanceTotal);

     

     
    IVault(_vault).payback(int256(debtBalanceTotal));

     

     
    uint256 globalBonus = IVault(_vault).getLiquidationBonusFor(debtBalanceTotal, false);
     
    uint256 globalCollateralInPlay =
      _getCollateralInPlay(vAssets.borrowAsset, debtBalanceTotal.add(globalBonus));

     
    _burnMultiLoop(formattedUserAddrs, usrsBals, IVault(_vault), f1155, vAssets);

     
    IVault(_vault).withdraw(int256(globalCollateralInPlay));

     
    _swap(vAssets.borrowAsset, debtBalanceTotal.add(globalBonus), globalCollateralInPlay);

     
    IERC20(vAssets.borrowAsset).univTransfer(msg.sender, debtBalanceTotal.add(globalBonus));

     
    for (uint256 i = 0; i < formattedUserAddrs.length; i += 2) {
      if (formattedUserAddrs[i] != address(0)) {
        f1155.burn(formattedUserAddrs[i], vAssets.borrowID, usrsBals[i + 1]);
        emit Liquidate(formattedUserAddrs[i], msg.sender, vAssets.borrowAsset, usrsBals[i + 1]);
      }
    }
  }

   
  function flashClose(
    int256 _amount,
    address _vault,
    uint8 _flashnum
  ) external nonReentrant isValidVault(_vault) {
    Flasher flasher = Flasher(payable(_fujiAdmin.getFlasher()));

     
    IVault(_vault).updateF1155Balances();

     
    IFujiERC1155Ext f1155 = IFujiERC1155Ext(IVault(_vault).fujiERC1155());

     
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

     
    uint256 userCollateral = f1155.balanceOf(msg.sender, vAssets.collateralID);
    uint256 userDebtBalance = f1155.balanceOf(msg.sender, vAssets.borrowID);

     
    require(userDebtBalance > 0, Errors.VL_NO_DEBT_TO_PAYBACK);

    uint256 amount = _amount < 0 ? userDebtBalance : uint256(_amount);

    uint256 neededCollateral = IVault(_vault).getNeededCollateralFor(amount, false);
    require(userCollateral >= neededCollateral, Errors.VL_UNDERCOLLATERIZED_ERROR);

    address[] memory userAddressArray = new address[](1);
    userAddressArray[0] = msg.sender;

    FlashLoan.Info memory info =
      FlashLoan.Info({
        callType: FlashLoan.CallType.Close,
        asset: vAssets.borrowAsset,
        amount: amount,
        vault: _vault,
        newProvider: address(0),
        userAddrs: userAddressArray,
        userBalances: new uint256[](0),
        userliquidator: address(0),
        fliquidator: address(this)
      });

    flasher.initiateFlashloan(info, _flashnum);
  }

   
  function executeFlashClose(
    address payable _userAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanFee
  ) external onlyFlash {
     
    IFujiERC1155 f1155 = IFujiERC1155(IVault(_vault).fujiERC1155());

     
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

     
    uint256 userCollateral = f1155.balanceOf(_userAddr, vAssets.collateralID);
    uint256 userDebtBalance = f1155.balanceOf(_userAddr, vAssets.borrowID);

     
    uint256 userCollateralInPlay =
      IVault(_vault)
        .getNeededCollateralFor(_amount.add(_flashloanFee), false)
        .mul(flashCloseF.a)
        .div(flashCloseF.b);

     

     
    IVault(_vault).payback(int256(_amount));

     

     
    if (_amount == userDebtBalance) {
      f1155.burn(_userAddr, vAssets.collateralID, userCollateral);

       
      IVault(_vault).withdraw(int256(userCollateral));

       
      IERC20(vAssets.collateralAsset).univTransfer(
        _userAddr,
        userCollateral.sub(userCollateralInPlay)
      );
    } else {
      f1155.burn(_userAddr, vAssets.collateralID, userCollateralInPlay);

       
      IVault(_vault).withdraw(int256(userCollateralInPlay));
    }

     
    uint256 remaining =
      _swap(vAssets.borrowAsset, _amount.add(_flashloanFee), userCollateralInPlay);

     
    IERC20(vAssets.collateralAsset).univTransfer(_fujiAdmin.getTreasury(), remaining);

     
    IERC20(vAssets.borrowAsset).univTransfer(
      payable(_fujiAdmin.getFlasher()),
      _amount.add(_flashloanFee)
    );

     
    f1155.burn(_userAddr, vAssets.borrowID, _amount);

    emit FlashClose(_userAddr, vAssets.borrowAsset, userDebtBalance);
  }

   
  function flashBatchLiquidate(
    address[] calldata _userAddrs,
    address _vault,
    uint8 _flashnum
  ) external isValidVault(_vault) nonReentrant {
     
    IVault(_vault).updateF1155Balances();

     
    IFujiERC1155Ext f1155 = IFujiERC1155Ext(IVault(_vault).fujiERC1155());

     
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

    address[] memory formattedUserAddrs = new address[](2 * _userAddrs.length);
    uint256[] memory formattedIds = new uint256[](2 * _userAddrs.length);

     
    for (uint256 i = 0; i < _userAddrs.length; i++) {
      formattedUserAddrs[2 * i] = _userAddrs[i];
      formattedUserAddrs[2 * i + 1] = _userAddrs[i];
      formattedIds[2 * i] = vAssets.collateralID;
      formattedIds[2 * i + 1] = vAssets.borrowID;
    }

     
    uint256[] memory usrsBals = f1155.balanceOfBatch(formattedUserAddrs, formattedIds);

    uint256 neededCollateral;
    uint256 debtBalanceTotal;

    for (uint256 i = 0; i < formattedUserAddrs.length; i += 2) {
       
      neededCollateral = IVault(_vault).getNeededCollateralFor(usrsBals[i + 1], true);

       
      if (usrsBals[i] < neededCollateral) {
         
        debtBalanceTotal = debtBalanceTotal.add(usrsBals[i + 1]);
      } else {
         
        formattedUserAddrs[i] = address(0);
        formattedUserAddrs[i + 1] = address(0);
      }
    }

     
    require(debtBalanceTotal > 0, Errors.VL_USER_NOT_LIQUIDATABLE);

    Flasher flasher = Flasher(payable(_fujiAdmin.getFlasher()));

    FlashLoan.Info memory info =
      FlashLoan.Info({
        callType: FlashLoan.CallType.BatchLiquidate,
        asset: vAssets.borrowAsset,
        amount: debtBalanceTotal,
        vault: _vault,
        newProvider: address(0),
        userAddrs: formattedUserAddrs,
        userBalances: usrsBals,
        userliquidator: msg.sender,
        fliquidator: address(this)
      });

    flasher.initiateFlashloan(info, _flashnum);
  }

   
  function executeFlashBatchLiquidation(
    address[] calldata _userAddrs,
    uint256[] calldata _usrsBals,
    address _liquidatorAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanFee
  ) external onlyFlash {
     
    IFujiERC1155 f1155 = IFujiERC1155(IVault(_vault).fujiERC1155());

     
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

     
     

     
    IVault(_vault).payback(int256(_amount));

     
    uint256 globalBonus = IVault(_vault).getLiquidationBonusFor(_amount, true);

     
    uint256 globalCollateralInPlay =
      _getCollateralInPlay(vAssets.borrowAsset, _amount.add(_flashloanFee).add(globalBonus));

     
    _burnMultiLoop(_userAddrs, _usrsBals, IVault(_vault), f1155, vAssets);

     
    IVault(_vault).withdraw(int256(globalCollateralInPlay));

    _swap(vAssets.borrowAsset, _amount.add(_flashloanFee).add(globalBonus), globalCollateralInPlay);

     
    IERC20(vAssets.borrowAsset).univTransfer(
      payable(_fujiAdmin.getFlasher()),
      _amount.add(_flashloanFee)
    );

     
    IERC20(vAssets.borrowAsset).univTransfer(
      payable(_liquidatorAddr),
      globalBonus.sub(_flashloanFee)
    );

     
    for (uint256 i = 0; i < _userAddrs.length; i += 2) {
      if (_userAddrs[i] != address(0)) {
        f1155.burn(_userAddrs[i], vAssets.borrowID, _usrsBals[i + 1]);
        emit FlashLiquidate(_userAddrs[i], _liquidatorAddr, vAssets.borrowAsset, _usrsBals[i + 1]);
      }
    }
  }

   
  function _swap(
    address _borrowAsset,
    uint256 _amountToReceive,
    uint256 _collateralAmount
  ) internal returns (uint256) {
     
    address[] memory path = new address[](2);
    path[0] = swapper.WETH();
    path[1] = _borrowAsset;
    uint256[] memory swapperAmounts =
      swapper.swapETHForExactTokens{ value: _collateralAmount }(
        _amountToReceive,
        path,
        address(this),
         
        block.timestamp
      );

    return _collateralAmount.sub(swapperAmounts[0]);
  }

   
  function _getCollateralInPlay(address _borrowAsset, uint256 _amountToReceive)
    internal
    view
    returns (uint256)
  {
    address[] memory path = new address[](2);
    path[0] = swapper.WETH();
    path[1] = _borrowAsset;
    uint256[] memory amounts = swapper.getAmountsIn(_amountToReceive, path);

    return amounts[0];
  }

   
  function _burnMultiLoop(
    address[] memory _userAddrs,
    uint256[] memory _usrsBals,
    IVault _vault,
    IFujiERC1155 _f1155,
    IVaultExt.VaultAssets memory _vAssets
  ) internal {
    uint256 bonusPerUser;
    uint256 collateralInPlayPerUser;

    for (uint256 i = 0; i < _userAddrs.length; i += 2) {
      if (_userAddrs[i] != address(0)) {
        bonusPerUser = _vault.getLiquidationBonusFor(_usrsBals[i + 1], true);

        collateralInPlayPerUser = _getCollateralInPlay(
          _vAssets.borrowAsset,
          _usrsBals[i + 1].add(bonusPerUser)
        );

        _f1155.burn(_userAddrs[i], _vAssets.collateralID, collateralInPlayPerUser);
      }
    }
  }

   

   
  function setFlashCloseFee(uint64 _newFactorA, uint64 _newFactorB) external isAuthorized {
    flashCloseF.a = _newFactorA;
    flashCloseF.b = _newFactorB;
  }

   
  function setFujiAdmin(address _newFujiAdmin) external isAuthorized {
    _fujiAdmin = IFujiAdmin(_newFujiAdmin);
  }

   
  function setSwapper(address _newSwapper) external isAuthorized {
    swapper = IUniswapV2Router02(_newSwapper);
  }
}

 

pragma solidity >=0.6.12 <0.8.0;

interface IFujiAdmin {
  function validVault(address _vaultAddr) external view returns (bool);

  function getFlasher() external view returns (address);

  function getFliquidator() external view returns (address);

  function getController() external view returns (address);

  function getTreasury() external view returns (address payable);

  function getaWhiteList() external view returns (address);

  function getVaultHarvester() external view returns (address);

  function getBonusFlashL() external view returns (uint64, uint64);

  function getBonusLiq() external view returns (uint64, uint64);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
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

 

pragma solidity >=0.6.12 <0.8.0;















interface IFliquidator {
  function executeFlashClose(
    address _userAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanfee
  ) external;

  function executeFlashBatchLiquidation(
    address[] calldata _userAddrs,
    uint256[] calldata _usrsBals,
    address _liquidatorAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanFee
  ) external;
}

interface IFujiMappings {
  function addressMapping(address) external view returns (address);
}

contract Flasher is DyDxFlashloanBase, IFlashLoanReceiver, ICFlashloanReceiver, ICallee, Ownable {
  using SafeMath for uint256;
  using UniERC20 for IERC20;

  IFujiAdmin private _fujiAdmin;

  address private immutable _aaveLendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
  address private immutable _dydxSoloMargin = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
  IFujiMappings private immutable _crMappings =
    IFujiMappings(0x03BD587Fe413D59A20F32Fc75f31bDE1dD1CD6c9);

  receive() external payable {}

  modifier isAuthorized() {
    require(
      msg.sender == _fujiAdmin.getController() ||
        msg.sender == _fujiAdmin.getFliquidator() ||
        msg.sender == owner(),
      Errors.VL_NOT_AUTHORIZED
    );
    _;
  }

   
  function setFujiAdmin(address _newFujiAdmin) public onlyOwner {
    _fujiAdmin = IFujiAdmin(_newFujiAdmin);
  }

   
  function initiateFlashloan(FlashLoan.Info calldata info, uint8 _flashnum) external isAuthorized {
    if (_flashnum == 0) {
      _initiateAaveFlashLoan(info);
    } else if (_flashnum == 1) {
      _initiateDyDxFlashLoan(info);
    } else if (_flashnum == 2) {
      _initiateCreamFlashLoan(info);
    }
  }

   

   
  function _initiateDyDxFlashLoan(FlashLoan.Info calldata info) internal {
    ISoloMargin solo = ISoloMargin(_dydxSoloMargin);

     
    uint256 marketId = _getMarketIdFromTokenAddress(solo, info.asset);

     
     
     
    Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

    operations[0] = _getWithdrawAction(marketId, info.amount);
     
    operations[1] = _getCallAction(abi.encode(info));
     
    operations[2] = _getDepositAction(marketId, info.amount.add(2));

    Account.Info[] memory accountInfos = new Account.Info[](1);
    accountInfos[0] = _getAccountInfo(address(this));

    solo.operate(accountInfos, operations);
  }

   
  function callFunction(
    address sender,
    Account.Info calldata account,
    bytes calldata data
  ) external override {
    require(msg.sender == _dydxSoloMargin && sender == address(this), Errors.VL_NOT_AUTHORIZED);
    account;

    FlashLoan.Info memory info = abi.decode(data, (FlashLoan.Info));

     
    uint256 amountOwing = info.amount.add(2);

     
    IERC20(info.asset).uniTransfer(payable(info.vault), info.amount);

    if (info.callType == FlashLoan.CallType.Switch) {
      IVault(info.vault).executeSwitch(info.newProvider, info.amount, 2);
    } else if (info.callType == FlashLoan.CallType.Close) {
      IFliquidator(info.fliquidator).executeFlashClose(
        info.userAddrs[0],
        info.vault,
        info.amount,
        2
      );
    } else {
      IFliquidator(info.fliquidator).executeFlashBatchLiquidation(
        info.userAddrs,
        info.userBalances,
        info.userliquidator,
        info.vault,
        info.amount,
        2
      );
    }

     
    IERC20(info.asset).approve(_dydxSoloMargin, amountOwing);
  }

   

   
  function _initiateAaveFlashLoan(FlashLoan.Info calldata info) internal {
     
    ILendingPool aaveLp = ILendingPool(_aaveLendingPool);

     
    address receiverAddress = address(this);
    address[] memory assets = new address[](1);
    assets[0] = address(info.asset);
    uint256[] memory amounts = new uint256[](1);
    amounts[0] = info.amount;

     
    uint256[] memory modes = new uint256[](1);
     

     
     
     

     
    aaveLp.flashLoan(receiverAddress, assets, amounts, modes, address(this), abi.encode(info), 0);
  }

   
  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external override returns (bool) {
    require(msg.sender == _aaveLendingPool && initiator == address(this), Errors.VL_NOT_AUTHORIZED);

    FlashLoan.Info memory info = abi.decode(params, (FlashLoan.Info));

     
    uint256 amountOwing = amounts[0].add(premiums[0]);

     
    IERC20(assets[0]).uniTransfer(payable(info.vault), amounts[0]);

    if (info.callType == FlashLoan.CallType.Switch) {
      IVault(info.vault).executeSwitch(info.newProvider, amounts[0], premiums[0]);
    } else if (info.callType == FlashLoan.CallType.Close) {
      IFliquidator(info.fliquidator).executeFlashClose(
        info.userAddrs[0],
        info.vault,
        amounts[0],
        premiums[0]
      );
    } else {
      IFliquidator(info.fliquidator).executeFlashBatchLiquidation(
        info.userAddrs,
        info.userBalances,
        info.userliquidator,
        info.vault,
        amounts[0],
        premiums[0]
      );
    }

     
    IERC20(assets[0]).uniApprove(payable(_aaveLendingPool), amountOwing);

    return true;
  }

   

   
  function _initiateCreamFlashLoan(FlashLoan.Info calldata info) internal {
     
    address crToken = _crMappings.addressMapping(info.asset);

     
    bytes memory params = abi.encode(info);

     
    ICTokenFlashloan(crToken).flashLoan(address(this), info.amount, params);
  }

   
  function executeOperation(
    address sender,
    address underlying,
    uint256 amount,
    uint256 fee,
    bytes calldata params
  ) external override {
     
    address crToken = _crMappings.addressMapping(underlying);

    require(msg.sender == crToken && address(this) == sender, Errors.VL_NOT_AUTHORIZED);
    require(IERC20(underlying).balanceOf(address(this)) >= amount, Errors.VL_FLASHLOAN_FAILED);

    FlashLoan.Info memory info = abi.decode(params, (FlashLoan.Info));

     
    uint256 amountOwing = amount.add(fee);

     
    IERC20(underlying).uniTransfer(payable(info.vault), amount);

     
    if (info.callType == FlashLoan.CallType.Switch) {
      IVault(info.vault).executeSwitch(info.newProvider, amount, fee);
    } else if (info.callType == FlashLoan.CallType.Close) {
      IFliquidator(info.fliquidator).executeFlashClose(info.userAddrs[0], info.vault, amount, fee);
    } else {
      IFliquidator(info.fliquidator).executeFlashBatchLiquidation(
        info.userAddrs,
        info.userBalances,
        info.userliquidator,
        info.vault,
        amount,
        fee
      );
    }

     
    IERC20(underlying).uniTransfer(payable(crToken), amountOwing);
  }
}

 

pragma solidity >=0.4.25 <0.7.5;

library FlashLoan {
   
  enum CallType { Switch, Close, BatchLiquidate }

   
  struct Info {
    CallType callType;
    address asset;
    uint256 amount;
    address vault;
    address newProvider;
    address[] userAddrs;
    uint256[] userBalances;
    address userliquidator;
    address fliquidator;
  }
}

 
pragma solidity <0.8.0;

 
library Errors {
   
  string public constant VL_INDEX_OVERFLOW = "100";  
  string public constant VL_INVALID_MINT_AMOUNT = "101";  
  string public constant VL_INVALID_BURN_AMOUNT = "102";  
  string public constant VL_AMOUNT_ERROR = "103";  
  string public constant VL_INVALID_WITHDRAW_AMOUNT = "104";  
  string public constant VL_INVALID_BORROW_AMOUNT = "105";  
  string public constant VL_NO_DEBT_TO_PAYBACK = "106";  
  string public constant VL_MISSING_ERC20_ALLOWANCE = "107";  
  string public constant VL_USER_NOT_LIQUIDATABLE = "108";  
  string public constant VL_DEBT_LESS_THAN_AMOUNT = "109";  
  string public constant VL_PROVIDER_ALREADY_ADDED = "110";  
  string public constant VL_NOT_AUTHORIZED = "111";  
  string public constant VL_INVALID_COLLATERAL = "112";  
  string public constant VL_NO_ERC20_BALANCE = "113";  
  string public constant VL_INPUT_ERROR = "114";  
  string public constant VL_ASSET_EXISTS = "115";  
  string public constant VL_ZERO_ADDR_1155 = "116";  
  string public constant VL_NOT_A_CONTRACT = "117";  
  string public constant VL_INVALID_ASSETID_1155 = "118";  
  string public constant VL_NO_ERC1155_BALANCE = "119";  
  string public constant VL_MISSING_ERC1155_APPROVAL = "120";  
  string public constant VL_RECEIVER_REJECT_1155 = "121";  
  string public constant VL_RECEIVER_CONTRACT_NON_1155 = "122";  
  string public constant VL_OPTIMIZER_FEE_SMALL = "123";  
  string public constant VL_UNDERCOLLATERIZED_ERROR = "124";  
  string public constant VL_MINIMUM_PAYBACK_ERROR = "125";  
  string public constant VL_HARVESTING_FAILED = "126";  
  string public constant VL_FLASHLOAN_FAILED = "127";  

  string public constant MATH_DIVISION_BY_ZERO = "201";
  string public constant MATH_ADDITION_OVERFLOW = "202";
  string public constant MATH_MULTIPLICATION_OVERFLOW = "203";

  string public constant RF_NO_GREENLIGHT = "300";  
  string public constant RF_INVALID_RATIO_VALUES = "301";  
  string public constant RF_CHECK_RATES_FALSE = "302";  

  string public constant VLT_CALLER_MUST_BE_VAULT = "401";  

  string public constant SP_ALPHA_WHITELIST = "901";  
}

 

pragma solidity >=0.6.0 <0.8.0;

 
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

 

pragma solidity ^0.6.12;




library LibUniversalERC20 {
  using SafeERC20 for IERC20;

  IERC20 private constant _ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  IERC20 private constant _ZERO_ADDRESS = IERC20(0);

  function isETH(IERC20 token) internal pure returns (bool) {
    return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
  }

  function univBalanceOf(IERC20 token, address account) internal view returns (uint256) {
    if (isETH(token)) {
      return account.balance;
    } else {
      return token.balanceOf(account);
    }
  }

  function univTransfer(
    IERC20 token,
    address payable to,
    uint256 amount
  ) internal {
    if (amount > 0) {
      if (isETH(token)) {
        (bool sent, ) = to.call{ value: amount }("");
        require(sent, "Failed to send Ether");
      } else {
        token.safeTransfer(to, amount);
      }
    }
  }

  function univApprove(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    require(!isETH(token), "Approve called on ETH");

    if (amount == 0) {
      token.safeApprove(to, 0);
    } else {
      uint256 allowance = token.allowance(address(this), to);
      if (allowance < amount) {
        if (allowance > 0) {
          token.safeApprove(to, 0);
        }
        token.safeApprove(to, amount);
      }
    }
  }
}

pragma solidity >=0.6.2;



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

 

pragma solidity ^0.6.12;




library UniERC20 {
  using SafeERC20 for IERC20;

  IERC20 private constant _ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  IERC20 private constant _ZERO_ADDRESS = IERC20(0);

  function isETH(IERC20 token) internal pure returns (bool) {
    return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
  }

  function uniBalanceOf(IERC20 token, address account) internal view returns (uint256) {
    if (isETH(token)) {
      return account.balance;
    } else {
      return token.balanceOf(account);
    }
  }

  function uniTransfer(
    IERC20 token,
    address payable to,
    uint256 amount
  ) internal {
    if (amount > 0) {
      if (isETH(token)) {
        to.transfer(amount);
      } else {
        token.safeTransfer(to, amount);
      }
    }
  }

  function uniApprove(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    require(!isETH(token), "Approve called on ETH");

    if (amount == 0) {
      token.safeApprove(to, 0);
    } else {
      uint256 allowance = token.allowance(address(this), to);
      if (allowance < amount) {
        if (allowance > 0) {
          token.safeApprove(to, 0);
        }
        token.safeApprove(to, amount);
      }
    }
  }
}

interface ILendingPool {
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;
}

 

pragma solidity >=0.4.25 <0.7.5;


library Account {
  enum Status { Normal, Liquid, Vapor }
  struct Info {
    address owner;  
    uint256 number;  
  }
}

library Actions {
  enum ActionType {
    Deposit,  
    Withdraw,  
    Transfer,  
    Buy,  
    Sell,  
    Trade,  
    Liquidate,  
    Vaporize,  
    Call  
  }

  struct ActionArgs {
    ActionType actionType;
    uint256 accountId;
    Types.AssetAmount amount;
    uint256 primaryMarketId;
    uint256 secondaryMarketId;
    address otherAddress;
    uint256 otherAccountId;
    bytes data;
  }
}

library Types {
  enum AssetDenomination {
    Wei,  
    Par  
  }

  enum AssetReference {
    Delta,  
    Target  
  }

  struct AssetAmount {
    bool sign;  
    AssetDenomination denomination;
    AssetReference ref;
    uint256 value;
  }
}

interface ISoloMargin {
  function getNumMarkets() external view returns (uint256);

  function getMarketTokenAddress(uint256 marketId) external view returns (address);

  function operate(Account.Info[] memory accounts, Actions.ActionArgs[] memory actions) external;
}

interface ICTokenFlashloan {
  function flashLoan(
    address receiver,
    uint256 amount,
    bytes calldata params
  ) external;
}

 

pragma solidity >=0.6.0 <0.8.0;





 
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

 

pragma solidity >=0.6.2 <0.8.0;

 
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
