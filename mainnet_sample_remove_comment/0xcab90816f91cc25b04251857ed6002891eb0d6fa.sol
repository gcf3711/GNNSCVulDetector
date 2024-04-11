
 

pragma solidity ^0.5.16;

interface ERC3156FlashBorrowerInterface {
     
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}


contract ComptrollerInterface {
    
    bool public constant isComptroller = true;

     

    function enterMarkets(address[] calldata apeTokens) external;

    function exitMarket(address apeToken) external;

     

    function mintAllowed(
        address payer,
        address apeToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);

    function mintVerify(
        address apeToken,
        address payer,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;

    function redeemAllowed(
        address apeToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);

    function redeemVerify(
        address apeToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;

    function borrowAllowed(
        address apeToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function borrowVerify(
        address apeToken,
        address borrower,
        uint256 borrowAmount
    ) external;

    function repayBorrowAllowed(
        address apeToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowVerify(
        address apeToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;

    function liquidateBorrowAllowed(
        address apeTokenBorrowed,
        address apeTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function liquidateBorrowVerify(
        address apeTokenBorrowed,
        address apeTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;

    function seizeAllowed(
        address apeTokenCollateral,
        address apeTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function seizeVerify(
        address apeTokenCollateral,
        address apeTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;

     

    function liquidateCalculateSeizeTokens(
        address apeTokenBorrowed,
        address apeTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);
}

interface ComptrollerInterfaceExtension {
    function checkMembership(address account, address apeToken) external view returns (bool);

    function flashloanAllowed(
        address apeToken,
        address receiver,
        uint256 amount,
        bytes calldata params
    ) external view returns (bool);

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function supplyCaps(address market) external view returns (uint256);
}

 
contract InterestRateModel {
    
    bool public constant isInterestRateModel = true;

     
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);

     
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);
}


contract ApeTokenStorage {
     
    bool internal _notEntered;

    enum Version {
        VANILLA,
        COLLATERALCAP,
        WRAPPEDNATIVE
    }

     
    Version public version;

     
    string public name;

     
    string public symbol;

     
    uint8 public decimals;

     

    uint256 internal constant borrowRateMaxMantissa = 0.0005e16;

     
    uint256 internal constant reserveFactorMaxMantissa = 1e18;

     
    address payable public admin;

     
    address payable public pendingAdmin;

     
    ComptrollerInterface public comptroller;

     
    InterestRateModel public interestRateModel;

     
    uint256 internal initialExchangeRateMantissa;

     
    uint256 public reserveFactorMantissa;

     
    uint256 public accrualBlockNumber;

     
    uint256 public borrowIndex;

     
    uint256 public totalBorrows;

     
    uint256 public totalReserves;

     
    uint256 public totalSupply;

     
    mapping(address => uint256) internal accountTokens;

     
    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

     
    mapping(address => BorrowSnapshot) internal accountBorrows;

     
    uint256 public borrowFee;

     
    address public helper;
}

contract ApeErc20Storage {
     
    address public underlying;

     
    address public implementation;
}

contract CSupplyCapStorage {
     
    uint256 public internalCash;
}

contract CCollateralCapStorage {
     
    uint256 public totalCollateralTokens;

     
    mapping(address => uint256) public accountCollateralTokens;

     
    uint256 public collateralCap;
}

 

contract ApeTokenInterface is ApeTokenStorage {
     
    bool public constant isApeToken = true;

     

     
    event AccrueInterest(uint256 cashPrior, uint256 interestAccumulated, uint256 borrowIndex, uint256 totalBorrows);

     
    event Mint(address payer, address minter, uint256 mintAmount, uint256 mintTokens);

     
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

     
    event Borrow(address borrower, uint256 borrowAmount, uint256 accountBorrows, uint256 totalBorrows);

     
    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

     
    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address apeTokenCollateral,
        uint256 seizeTokens
    );

     

     
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

     
    event NewAdmin(address oldAdmin, address newAdmin);

     
    event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);

     
    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

     
    event NewReserveFactor(uint256 oldReserveFactorMantissa, uint256 newReserveFactorMantissa);

     
    event ReservesAdded(address benefactor, uint256 addAmount, uint256 newTotalReserves);

     
    event ReservesReduced(address admin, uint256 reduceAmount, uint256 newTotalReserves);

     
    event Failure(uint256 error, uint256 info, uint256 detail);

     
    event BorrowFee(uint256 oldBorrowFee, uint256 newBorrowFee);

     
    event HelperSet(address oldHelper, address newHelper);

     

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function borrowRatePerBlock() external view returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account) public view returns (uint256);

    function exchangeRateCurrent() public returns (uint256);

    function exchangeRateStored() public view returns (uint256);

    function getCash() external view returns (uint256);

    function accrueInterest() public returns (uint256);

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens,
        uint256 feeTokens
    ) external returns (uint256);

     

    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256);

    function _acceptAdmin() external returns (uint256);

    function _setComptroller(ComptrollerInterface newComptroller) public returns (uint256);

    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);

    function _reduceReserves(uint256 reduceAmount) external returns (uint256);

    function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint256);

    function _setBorrowFee(uint256 newBorrowFee) public;

    function _setHelper(address newHelper) public;

    function _setDelegate(
        address delegateContract,
        bytes32 id,
        address delegate
    ) external;
}

contract ApeErc20Interface is ApeErc20Storage {
     

    function mint(address minter, uint256 mintAmount) external returns (uint256);

    function redeem(
        address payable redeemer,
        uint256 redeemTokens,
        uint256 redeemAmount
    ) external returns (uint256);

    function borrow(address payable borrower, uint256 borrowAmount) external returns (uint256);

    function repayBorrow(address borrower, uint256 repayAmount) external returns (uint256);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        ApeTokenInterface apeTokenCollateral
    ) external returns (uint256);

    function _addReserves(uint256 addAmount) external returns (uint256);
}

contract ApeWrappedNativeInterface is ApeErc20Interface {
     
    uint256 public constant flashFeeBips = 3;

     

     
    event Flashloan(address indexed receiver, uint256 amount, uint256 totalFee, uint256 reservesFee);

     

    function mintNative(address minter) external payable returns (uint256);

    function redeemNative(
        address payable redeemer,
        uint256 redeemTokens,
        uint256 redeemAmount
    ) external returns (uint256);

    function borrowNative(address payable borrower, uint256 borrowAmount) external returns (uint256);

    function repayBorrowNative(address borrower) external payable returns (uint256);

    function liquidateBorrowNative(address borrower, ApeTokenInterface apeTokenCollateral)
        external
        payable
        returns (uint256);

    function flashLoan(
        ERC3156FlashBorrowerInterface receiver,
        address initiator,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    function _addReservesNative() external payable returns (uint256);

    function collateralCap() external view returns (uint256);

    function totalCollateralTokens() external view returns (uint256);
}

contract CCapableErc20Interface is ApeErc20Interface, CSupplyCapStorage {
     
    uint256 public constant flashFeeBips = 3;

     

     
    event Flashloan(address indexed receiver, uint256 amount, uint256 totalFee, uint256 reservesFee);

     

    function gulp() external;
}

contract ApeCollateralCapErc20Interface is CCapableErc20Interface, CCollateralCapStorage {
     

     
    event NewCollateralCap(address token, uint256 newCap);

     
    event UserCollateralChanged(address account, uint256 newCollateralTokens);

     

    function registerCollateral(address account) external returns (uint256);

    function unregisterCollateral(address account) external;

    function flashLoan(
        ERC3156FlashBorrowerInterface receiver,
        address initiator,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

     

    function _setCollateralCap(uint256 newCollateralCap) external;
}

contract CDelegatorInterface {
     
    event NewImplementation(address oldImplementation, address newImplementation);

     
    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public;
}

contract CDelegateInterface {
     
    function _becomeImplementation(bytes memory data) public;

     
    function _resignImplementation() public;
}

 

 
interface IFlashloanReceiver {
    function executeOperation(
        address sender,
        address underlying,
        uint256 amount,
        uint256 fee,
        bytes calldata params
    ) external;
}

 
contract ApeErc20Delegator is ApeTokenInterface, ApeErc20Interface, CDelegatorInterface {
     
    constructor(
        address underlying_,
        ComptrollerInterface comptroller_,
        InterestRateModel interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address payable admin_,
        address implementation_,
        bytes memory becomeImplementationData
    ) public {
         
        admin = msg.sender;

         
        delegateTo(
            implementation_,
            abi.encodeWithSignature(
                "initialize(address,address,address,uint256,string,string,uint8)",
                underlying_,
                comptroller_,
                interestRateModel_,
                initialExchangeRateMantissa_,
                name_,
                symbol_,
                decimals_
            )
        );

         
        _setImplementation(implementation_, false, becomeImplementationData);

         
        admin = admin_;
    }

     
    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public {
        require(msg.sender == admin, "ApeErc20Delegator::_setImplementation: Caller must be admin");

        if (allowResign) {
            delegateToImplementation(abi.encodeWithSignature("_resignImplementation()"));
        }

        address oldImplementation = implementation;
        implementation = implementation_;

        delegateToImplementation(abi.encodeWithSignature("_becomeImplementation(bytes)", becomeImplementationData));

        emit NewImplementation(oldImplementation, implementation);
    }

     
    function mint(address minter, uint256 mintAmount) external returns (uint256) {
        minter;
        mintAmount;  
        delegateAndReturn();
    }

     
    function redeem(
        address payable redeemer,
        uint256 redeemTokens,
        uint256 redeemAmount
    ) external returns (uint256) {
        redeemer;
        redeemTokens;
        redeemAmount;  
        delegateAndReturn();
    }

     
    function borrow(address payable borrower, uint256 borrowAmount) external returns (uint256) {
        borrower;
        borrowAmount;  
        delegateAndReturn();
    }

     
    function repayBorrow(address borrower, uint256 repayAmount) external returns (uint256) {
        borrower;
        repayAmount;  
        delegateAndReturn();
    }

     
    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        ApeTokenInterface apeTokenCollateral
    ) external returns (uint256) {
        borrower;
        repayAmount;
        apeTokenCollateral;  
        delegateAndReturn();
    }

     
    function balanceOf(address owner) external view returns (uint256) {
        owner;  
        delegateToViewAndReturn();
    }

     
    function balanceOfUnderlying(address owner) external returns (uint256) {
        owner;  
        delegateAndReturn();
    }

     
    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        account;  
        delegateToViewAndReturn();
    }

     
    function borrowRatePerBlock() external view returns (uint256) {
        delegateToViewAndReturn();
    }

     
    function supplyRatePerBlock() external view returns (uint256) {
        delegateToViewAndReturn();
    }

     
    function totalBorrowsCurrent() external returns (uint256) {
        delegateAndReturn();
    }

     
    function borrowBalanceCurrent(address account) external returns (uint256) {
        account;  
        delegateAndReturn();
    }

     
    function borrowBalanceStored(address account) public view returns (uint256) {
        account;  
        delegateToViewAndReturn();
    }

     
    function exchangeRateCurrent() public returns (uint256) {
        delegateAndReturn();
    }

     
    function exchangeRateStored() public view returns (uint256) {
        delegateToViewAndReturn();
    }

     
    function getCash() external view returns (uint256) {
        delegateToViewAndReturn();
    }

     
    function accrueInterest() public returns (uint256) {
        delegateAndReturn();
    }

     
    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens,
        uint256 feeTokens
    ) external returns (uint256) {
        liquidator;
        borrower;
        seizeTokens;
        feeTokens;  
        delegateAndReturn();
    }

     

     
    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256) {
        newPendingAdmin;  
        delegateAndReturn();
    }

     
    function _setComptroller(ComptrollerInterface newComptroller) public returns (uint256) {
        newComptroller;  
        delegateAndReturn();
    }

     
    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256) {
        newReserveFactorMantissa;  
        delegateAndReturn();
    }

     
    function _acceptAdmin() external returns (uint256) {
        delegateAndReturn();
    }

     
    function _addReserves(uint256 addAmount) external returns (uint256) {
        addAmount;  
        delegateAndReturn();
    }

     
    function _reduceReserves(uint256 reduceAmount) external returns (uint256) {
        reduceAmount;  
        delegateAndReturn();
    }

     
    function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint256) {
        newInterestRateModel;  
        delegateAndReturn();
    }

     
    function _setBorrowFee(uint256 newBorrowFee) public {
        newBorrowFee;  
        delegateAndReturn();
    }

     
    function _setHelper(address newHelper) public {
        newHelper;  
        delegateAndReturn();
    }

     
    function _setDelegate(
        address delegateContract,
        bytes32 id,
        address delegate
    ) external {
        delegateContract;
        id;
        delegate;  
        delegateAndReturn();
    }

     
    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }

     
    function delegateToImplementation(bytes memory data) public returns (bytes memory) {
        return delegateTo(implementation, data);
    }

     
    function delegateToViewImplementation(bytes memory data) public view returns (bytes memory) {
        (bool success, bytes memory returnData) = address(this).staticcall(
            abi.encodeWithSignature("delegateToImplementation(bytes)", data)
        );
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return abi.decode(returnData, (bytes));
    }

    function delegateToViewAndReturn() private view returns (bytes memory) {
        (bool success, ) = address(this).staticcall(
            abi.encodeWithSignature("delegateToImplementation(bytes)", msg.data)
        );

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize)
            }
            default {
                return(add(free_mem_ptr, 0x40), returndatasize)
            }
        }
    }

    function delegateAndReturn() private returns (bytes memory) {
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize)
            }
            default {
                return(free_mem_ptr, returndatasize)
            }
        }
    }

     
    function() external payable {
        require(msg.value == 0, "ApeErc20Delegator:fallback: cannot send value to fallback");

         
        delegateAndReturn();
    }
}