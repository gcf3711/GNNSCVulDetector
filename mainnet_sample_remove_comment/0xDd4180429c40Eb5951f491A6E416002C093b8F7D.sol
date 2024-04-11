 


 
 

pragma solidity ^0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

 
 

pragma solidity ^0.8.0;



 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor() {
        _transferOwnership(_msgSender());
    }

     
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

     
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

 
 

pragma solidity ^0.8.0;



 
abstract contract Pausable is Context {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    constructor() {
        _paused = false;
    }

     
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

     
    modifier whenPaused() {
        _requirePaused();
        _;
    }

     
    function paused() public view virtual returns (bool) {
        return _paused;
    }

     
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

     
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

     
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

 
pragma solidity 0.8.7;









contract StratManager is Ownable, Pausable {
    using SafeERC20 for IERC20;

    uint256 constant public MAX_FEE = 1000;

     
    address public safeFarm;
    address public unirouter;

    address public want;
    address public output;
    address public wbnb;

    address[] public outputToWbnbRoute;

     
    uint256 public poolFee = 30;  

    uint256 public callFee = 0;
    address public callFeeRecipient;
     

    uint256 public frfiFee = 0;
    address public frfiFeeRecipient;

    address public strategistFeeRecipient;

    uint256 public safeFarmFee = 0;
    address public safeFarmFeeRecipient;

    uint256 public treasuryFee = 0;
    address public treasuryFeeRecipient;

    uint256 public systemFee = 0;
    address public systemFeeRecipient;

     
    event Deposit(uint256 amount);
    event Withdraw(address tokenAddress, address account, uint256 amount);
    event StratHarvest(address indexed harvester);
    event SafeSwap(address indexed tokenAddress, address indexed account, uint256 amount);
    event ChargedFees(uint256 callFees, uint256 frfiFees, uint256 strategistFees);

     
    constructor(
        address _unirouter,
        address _want,
        address _output,
        address _wbnb,

        address _callFeeRecipient,
        address _frfiFeeRecipient,
        address _strategistFeeRecipient,

        address _safeFarmFeeRecipient,

        address _treasuryFeeRecipient,
        address _systemFeeRecipient
    ) {
        unirouter = _unirouter;

        want = _want;
        output = _output;
        wbnb = _wbnb;

        if (output != wbnb) {
            outputToWbnbRoute = [output, wbnb];
        }

        callFeeRecipient = _callFeeRecipient;
        frfiFeeRecipient = _frfiFeeRecipient;
        strategistFeeRecipient = _strategistFeeRecipient;

        safeFarmFeeRecipient = _safeFarmFeeRecipient;

        treasuryFeeRecipient = _treasuryFeeRecipient;
        systemFeeRecipient = _systemFeeRecipient;
    }

     
    modifier onlyEOA() {
        require(
            msg.sender == tx.origin
            || msg.sender == address(safeFarm)
            , "!EOA");
        _;
    }
    modifier onlySafeFarm() {
        require(msg.sender == address(safeFarm), "!safeFarm");
        _;
    }

 

     

    function migrate(address newSafeFarm) external onlySafeFarm {
        safeFarm = newSafeFarm;
    }

    function pause() public onlyOwner {
        _pause();
        _removeAllowances();
    }

    function unpause() external onlyOwner {
        _unpause();
        _giveAllowances();
        deposit();
    }


     
    function setUnirouter(address _unirouter) external onlyOwner {
        _removeAllowances();
        unirouter = _unirouter;
        _giveAllowances();
    }

    function setPoolFee(uint256 _poolFee) external onlyOwner {
        poolFee = _poolFee;
    }

    function setCallFee(uint256 _callFee, address _callFeeRecipient) external onlyOwner {
        callFee = _callFee;
        callFeeRecipient = _callFeeRecipient;
    }

    function setFrfiFee(uint256 _frfiFee, address _frfiFeeRecipient) external onlyOwner {
        frfiFee = _frfiFee;
        frfiFeeRecipient = _frfiFeeRecipient;
    }

    function setWithdrawFees(
        uint256 _systemFee,
        uint256 _treasuryFee,
        address _systemFeeRecipient,
        address _treasuryFeeRecipient
    ) external onlyOwner {
        require(_systemFeeRecipient != address(0), "systemFeeRecipient the zero address");
        require(_treasuryFeeRecipient != address(0), "treasuryFeeRecipient the zero address");

        systemFee = _systemFee;
        systemFeeRecipient = _systemFeeRecipient;
        treasuryFee = _treasuryFee;
        treasuryFeeRecipient = _treasuryFeeRecipient;
    }

    function setSafeFarmFee(
        uint256 _safeFarmFee,
        address _safeFarmFeeRecipient
    ) external onlyOwner {
        require(_safeFarmFeeRecipient != address(0), "safeFarmFeeRecipient the zero address");

        safeFarmFee = _safeFarmFee;
        safeFarmFeeRecipient = _safeFarmFeeRecipient;
    }

     
    function retireStrat() external onlySafeFarm {
        _emergencyWithdraw();

        uint256 wantBal = balanceOfWant();
        if (wantBal > 0) {
            IERC20(want).transfer(safeFarm, wantBal);
        }
    }

     
    function panic() external onlyOwner {
        pause();
        _emergencyWithdraw();
    }

     
    function inCaseTokensGetStuck(address _token) external onlyOwner {
         
         

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }

 
     
    function deposit() public whenNotPaused {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            _poolDeposit(wantBal);

            emit Deposit(wantBal);
        }
    }

 

     
    function calcSharesAmount(
        uint256 share, uint256 totalShares
    ) public view returns (uint256 amount) {
        amount = balanceOf() * share / totalShares;
        return amount;
    }

     
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

     
    function balanceOf() public view returns (uint256) {
        return balanceOfWant() + balanceOfPool();
    }

     
     

     
    function safeFarmFeeAmount(uint256 amount) public view returns (uint256) {
        return (amount * safeFarmFee / MAX_FEE);
    }

 

    function _outputBalance() internal virtual returns (uint256) {
        return IERC20(output).balanceOf(address(this));
    }

    function _chargeFees() internal returns (uint256) {
        uint256 allBal = _outputBalance();
        if (allBal == 0) return 0;

        uint256 toNative = allBal * poolFee / MAX_FEE;
        if (output != wbnb) {
            _swapToken(toNative, outputToWbnbRoute, address(this));
            uint256 nativeBal = IERC20(wbnb).balanceOf(address(this));
            _sendPoolFees(nativeBal);
        }
        else {
            _sendPoolFees(toNative);
        }


        return (allBal - toNative);
    }

    function _sendPoolFees(uint256 nativeBal) internal {
        uint256 callFeeAmount = nativeBal * callFee / MAX_FEE;
        if (callFeeAmount > 0) {
            IERC20(wbnb).safeTransfer(callFeeRecipient, callFeeAmount);
        }

        uint256 frfiFeeAmount = nativeBal * frfiFee / MAX_FEE;
        if (frfiFeeAmount > 0) {
            IERC20(wbnb).safeTransfer(frfiFeeRecipient, frfiFeeAmount);
        }

        uint256 strategistFeeAmount = nativeBal - callFeeAmount - frfiFeeAmount;
        if (strategistFeeAmount > 0) {
            IERC20(wbnb).safeTransfer(strategistFeeRecipient, strategistFeeAmount);
        }

        emit ChargedFees(callFeeAmount, frfiFeeAmount, strategistFeeAmount);
    }

    function _safeSwap(
        address account, uint256 amount, address[] memory route,
        uint256 feeAdd
    ) internal {
        address tokenB = route[route.length - 1];
        uint256 amountB;
        if (route.length == 1 || tokenB == want) {
            amountB = amount;
        }
        else {
            amountB = _swapToken(amount, route, address(this));
        }

        uint256 feeAmount = safeFarmFeeAmount(amountB) + feeAdd;
        require(amountB > feeAmount, "low profit amount");

        uint256 withdrawalAmount = amountB - feeAmount;

        IERC20(tokenB).safeTransfer(account, withdrawalAmount);
        if (feeAmount > 0) {
            IERC20(tokenB).safeTransfer(safeFarmFeeRecipient, feeAmount);
        }

        emit SafeSwap(tokenB, account, withdrawalAmount);
    }

    function _getWantBalance(uint256 amount) internal returns(uint256 wantBal) {
        wantBal = balanceOfWant();

        if (wantBal < amount) {
            _poolWithdraw(amount - wantBal);
            wantBal = balanceOfWant();
        }

        if (wantBal > amount) {
            wantBal = amount;
        }

        return wantBal;
    }

    function _swapToken(
        uint256 _amount,
        address[] memory _path,
        address _to
    ) internal virtual returns (uint256 result) {
        uint256[] memory amounts = IUniswapRouterETH(unirouter).swapExactTokensForTokens(
            _amount,
            1,
            _path,
            _to,
            block.timestamp
        );
        return amounts[amounts.length - 1];
    }

 

    function harvest() public virtual {}

     
    function balanceOfPool() public view virtual returns (uint256) {}
    function pendingReward() public view virtual returns (uint256) {}

    function _poolDeposit(uint256 amount) internal virtual {}
    function _poolWithdraw(uint256 amount) internal virtual {}
    function _emergencyWithdraw() internal virtual {}

    function _giveAllowances() internal virtual {}
    function _removeAllowances() internal virtual {}
}

 
pragma solidity 0.8.7;





contract StrategyFarmLP is StratManager {
    using SafeERC20 for IERC20;

    bytes32 public constant STRATEGY_TYPE = keccak256("FARM_LP");

     
    address public lpToken0;
    address public lpToken1;

     
    address public masterchef;
    uint256 public poolId;

     
    address[] public outputToLp0Route;
    address[] public outputToLp1Route;

    constructor(
        address _unirouter,
        address _want,
        address _output,
        address _wbnb,

        address _callFeeRecipient,
        address _frfiFeeRecipient,
        address _strategistFeeRecipient,

        address _safeFarmFeeRecipient,

        address _treasuryFeeRecipient,
        address _systemFeeRecipient
    ) StratManager(
        _unirouter,
        _want,
        _output,
        _wbnb,

        _callFeeRecipient,
        _frfiFeeRecipient,
        _strategistFeeRecipient,

        _safeFarmFeeRecipient,

        _treasuryFeeRecipient,
        _systemFeeRecipient
    ) {}

     
    function initialize(
        address _safeFarm,
        address _masterchef,
        uint256 _poolId
    ) public virtual onlyOwner {
        safeFarm = _safeFarm;
        masterchef = _masterchef;
        poolId = _poolId;

        lpToken0 = IUniswapV2Pair(want).token0();
        lpToken1 = IUniswapV2Pair(want).token1();

        if (lpToken0 != output) {
            if (output == wbnb || lpToken0 == wbnb) {
                outputToLp0Route = [output, lpToken0];
            }
            else {
                outputToLp0Route = [output, wbnb, lpToken0];
            }
        }

        if (lpToken1 != output) {
            if (output == wbnb || lpToken1 == wbnb) {
                outputToLp1Route = [output, lpToken1];
            }
            else {
                outputToLp1Route = [output, wbnb, lpToken1];
            }
        }

        _giveAllowances();
    }

     
    function withdraw(
        address account, uint256 share, uint256 totalShares
    ) external onlySafeFarm {
        harvest();
        uint256 amount = calcSharesAmount(share, totalShares);
        uint256 wantBal = _getWantBalance(amount);

        uint256 systemFeeAmount = wantBal * systemFee / 100;
        uint256 treasuryFeeAmount = wantBal * treasuryFee / 100;
        uint256 withdrawalAmount = wantBal - systemFeeAmount - treasuryFeeAmount;

        IERC20(want).safeTransfer(account, withdrawalAmount);

        uint256 feeAmount = systemFeeAmount + treasuryFeeAmount;
        if (feeAmount > 0) {
            (uint256 amountToken0, uint256 amountToken1) = _removeLiquidity(feeAmount);

            uint256 systemFeeAmountToken0 = amountToken0 * systemFeeAmount / (feeAmount);
            IERC20(lpToken0).safeTransfer(systemFeeRecipient, systemFeeAmountToken0);
            IERC20(lpToken0).safeTransfer(treasuryFeeRecipient, amountToken0 - systemFeeAmountToken0);

            uint256 systemFeeAmountToken1 = amountToken1 * systemFeeAmount / (feeAmount);
            IERC20(lpToken1).safeTransfer(systemFeeRecipient, systemFeeAmountToken1);
            IERC20(lpToken1).safeTransfer(treasuryFeeRecipient, amountToken1 - systemFeeAmountToken1);
        }

        emit Withdraw(address(want), account, withdrawalAmount);
    }

     
    function safeSwap(
        address account, uint256 share, uint256 totalShares,
        uint256 feeAdd,
        address[] memory route0, address[] memory route1
    ) external onlySafeFarm {
        require(route0[0] == lpToken0, "invalid route0");
        require(route1[0] == lpToken1, "invalid route1");

        harvest();
        uint256 amount = calcSharesAmount(share, totalShares);
        uint256 wantBal = _getWantBalance(amount);

        (uint256 amountToken0, uint256 amountToken1) = _removeLiquidity(wantBal);
        _safeSwap(account, amountToken0, route0, feeAdd);
        _safeSwap(account, amountToken1, route1, 0);
    }

     
    function harvest() public override whenNotPaused onlyEOA {
        _poolDeposit(0);

        uint256 toWant = _chargeFees();
        if (toWant > 0) {
            _addOutputToLiquidity(toWant);
            deposit();
        }

        emit StratHarvest(msg.sender);
    }


     
    function balanceOfPool() public view override virtual returns (uint256) {
        (uint256 _amount, ) = IMasterChef(masterchef).userInfo(poolId, address(this));
        return _amount;
    }

    function pendingReward() public view override virtual returns (uint256 amount) {
        amount = IMasterChef(masterchef).pendingCake(poolId, address(this));
        return amount * (MAX_FEE - poolFee) / MAX_FEE;
    }


 

    function _poolDeposit(uint256 _amount) internal override virtual {
        IMasterChef(masterchef).deposit(poolId, _amount);
    }

    function _poolWithdraw(uint256 _amount) internal override virtual {
        IMasterChef(masterchef).withdraw(poolId, _amount);
    }

    function _emergencyWithdraw() internal override virtual {
        uint256 poolBal = balanceOfPool();
        if (poolBal > 0) {
            IMasterChef(masterchef).emergencyWithdraw(poolId);
        }
    }

    function _giveAllowances() internal override virtual {
        IERC20(want).safeApprove(masterchef, 0);
        IERC20(want).safeApprove(masterchef, type(uint256).max);

        IERC20(want).safeApprove(unirouter, 0);
        IERC20(want).safeApprove(unirouter, type(uint256).max);

        IERC20(output).safeApprove(unirouter, 0);
        IERC20(output).safeApprove(unirouter, type(uint256).max);

        IERC20(lpToken0).safeApprove(unirouter, 0);
        IERC20(lpToken0).safeApprove(unirouter, type(uint256).max);

        IERC20(lpToken1).safeApprove(unirouter, 0);
        IERC20(lpToken1).safeApprove(unirouter, type(uint256).max);
    }

    function _removeAllowances() internal override virtual {
        IERC20(want).safeApprove(masterchef, 0);
        IERC20(want).safeApprove(unirouter, 0);
        IERC20(output).safeApprove(unirouter, 0);
        IERC20(lpToken0).safeApprove(unirouter, 0);
        IERC20(lpToken1).safeApprove(unirouter, 0);
    }

     
    function _addOutputToLiquidity(uint256 toWant) internal {
        uint256 outputHalf = toWant / 2;

        if (lpToken0 != output) {
            _swapToken(outputHalf, outputToLp0Route, address(this));
        }

        if (lpToken1 != output) {
            _swapToken(toWant - outputHalf, outputToLp1Route, address(this));
        }

        uint256 lp0Bal = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Bal = IERC20(lpToken1).balanceOf(address(this));
        _addLiquidity( lp0Bal, lp1Bal);
    }

    function _addLiquidity(uint256 amountToken0, uint256 amountToken1) internal virtual {
        IUniswapRouterETH(unirouter).addLiquidity(
            lpToken0,
            lpToken1,
            amountToken0,
            amountToken1,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    function _removeLiquidity(uint256 amount) internal virtual returns (
        uint256 amountToken0, uint256 amountToken1
    ) {
        return IUniswapRouterETH(unirouter).removeLiquidity(
            lpToken0,
            lpToken1,
            amount,
            1,
            1,
            address(this),
            block.timestamp
        );
    }
}

 
pragma solidity 0.8.7;

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function enterStaking(uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function lpToken(uint256 _pid) external view returns (address);

    function userInfo(uint256 _pid, address _user) external view returns (
         
        uint256, uint256
    );

    function poolInfo(uint256 _pid) external view returns (
         
        address, uint256, uint256, uint256
    );
}
 
pragma solidity 0.8.7;




contract StrategyFarmLPSushiV1 is StrategyFarmLP {
    constructor(
        address _unirouter,
        address _want,
        address _output,
        address _wbnb,

        address _callFeeRecipient,
        address _frfiFeeRecipient,
        address _strategistFeeRecipient,

        address _safeFarmFeeRecipient,

        address _treasuryFeeRecipient,
        address _systemFeeRecipient
    ) StrategyFarmLP(
        _unirouter,
        _want,
        _output,
        _wbnb,

        _callFeeRecipient,
        _frfiFeeRecipient,
        _strategistFeeRecipient,

        _safeFarmFeeRecipient,

        _treasuryFeeRecipient,
        _systemFeeRecipient
    ) {
    }

    function pendingReward() public view override virtual returns (uint256 amount) {
        amount = IMasterChefSushi(masterchef).pendingSushi(poolId, address(this));
        return amount;
    }

     
    function _outputBalance() internal override returns (uint256) {
        uint256 allBal = super._outputBalance();
        uint256 outputHalf = (allBal * (MAX_FEE - poolFee) / MAX_FEE) / 2;

        if (outputHalf == 0) return 0;
        if (_checkLpOutput(lpToken0, outputToLp0Route, outputHalf) == 0) return 0;
        if (_checkLpOutput(lpToken1, outputToLp1Route, outputHalf) == 0) return 0;

        return allBal;
    }

    function _checkLpOutput(
        address lpToken,
        address[] memory route,
        uint256 amount
    ) private view returns (uint256) {
        if (lpToken == output) return amount;

        uint256[] memory amounts = IUniswapRouterETH(unirouter).getAmountsOut(
            amount, route
        );

        return amounts[amounts.length - 1];
    }
}

interface IMasterChefSushi is IMasterChef {
    function pendingSushi(uint256 _pid, address _user) external view returns (uint256);
}

 
pragma solidity 0.8.7;


interface IUniswapRouterETH {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path)
        external view
        returns (uint[] memory amounts);
}


interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint256, uint256);
}

 
 

pragma solidity ^0.8.0;

 
interface IERC20 {
     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address to, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

 
 

pragma solidity ^0.8.0;





 
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
         
         
         
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 
 

pragma solidity ^0.8.1;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        return account.code.length > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

 
 

pragma solidity ^0.8.0;

 
interface IERC20Permit {
     
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

     
    function nonces(address owner) external view returns (uint256);

     
     
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}