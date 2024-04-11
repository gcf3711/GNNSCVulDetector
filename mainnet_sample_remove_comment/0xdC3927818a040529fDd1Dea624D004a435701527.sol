 
pragma experimental ABIEncoderV2;

 

 

pragma solidity 0.6.12;


 



struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 rateLimit;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

 

interface IIdleTokenV3_1 {
     
     
    function tokenPrice() external view returns (uint256 price);

     
     
    function userAvgPrices(address user) external view returns (uint256 price);


     
     
    function fee() external view returns (uint256 fee);

     
    function token() external view returns (address underlying);

     
    function getAPRs() external view returns (address[] memory addresses, uint256[] memory aprs);

     
     

     
    function mintIdleToken(uint256 _amount, bool _skipRebalance, address _referral) external returns (uint256 mintedTokens);

     
    function redeemIdleToken(uint256 _amount) external returns (uint256 redeemedTokens);
     
    function redeemInterestBearingTokens(uint256 _amount) external;

     
    function rebalance() external returns (bool);


     
    function symbol() external view returns (string memory);
}

 

interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
}

 

interface IdleReservoir {
  function drip() external returns (uint256);
}

 

 
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

 

interface VaultAPI is IERC20 {
    function apiVersion() external pure returns (string memory);

    function withdraw(uint256 shares, address recipient) external returns (uint256);

    function token() external view returns (address);

    function strategies(address _strategy) external view returns (StrategyParams memory);

     
    function creditAvailable() external view returns (uint256);

     
    function debtOutstanding() external view returns (uint256);

     
    function expectedReturn() external view returns (uint256);

     
    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);

     
    function revokeStrategy() external;

     
    function governance() external view returns (address);

     
    function management() external view returns (address);
}

 

 
abstract contract BaseStrategyInitializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string public metadataURI;

     
    function apiVersion() public pure returns (string memory) {
        return "0.3.1";
    }

     
    function name() external virtual view returns (string memory);

     
    function delegatedAssets() external virtual view returns (uint256) {
        return 0;
    }

    VaultAPI public vault;
    address public strategist;
    address public rewards;
    address public keeper;

    IERC20 public want;

     
    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);

    event UpdatedStrategist(address newStrategist);

    event UpdatedKeeper(address newKeeper);

    event UpdatedRewards(address rewards);

    event UpdatedReportDelay(uint256 delay);

    event UpdatedProfitFactor(uint256 profitFactor);

    event UpdatedDebtThreshold(uint256 debtThreshold);

    event EmergencyExitEnabled();

    event UpdatedMetadataURI(string metadataURI);

     
     
    uint256 public maxReportDelay = 86400;  

     
     
    uint256 public profitFactor = 100;

     
     
    uint256 public debtThreshold = 0;

     
    bool public emergencyExit;

    bool public initialized;

     
    modifier onlyAuthorized() {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "!strategist");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyKeepers() {
        require(msg.sender == keeper || msg.sender == strategist || msg.sender == governance(), "!authorized");
        _;
    }

     
    constructor(address _vault, bool _initialize) public {
        if(_initialize) {
            _init(_vault, msg.sender);
        }
    }

     
    function init(address _vault, address _onBehalfOf) external {
        _init(_vault, _onBehalfOf);
    }

     
    function _init(address _vault, address _onBehalfOf) internal {
        require(!initialized, "You can only initialize once");

        initialized = true;

        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.safeApprove(_vault, uint256(-1));  

        strategist = _onBehalfOf;
        rewards = _onBehalfOf;
        keeper = _onBehalfOf;

        vault.approve(rewards, uint256(-1));  
    }

     
    function setStrategist(address _strategist) external onlyAuthorized {
        require(_strategist != address(0));
        strategist = _strategist;
        emit UpdatedStrategist(_strategist);
    }

     
    function setKeeper(address _keeper) external onlyAuthorized {
        require(_keeper != address(0));
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

     
    function setRewards(address _rewards) external onlyStrategist {
        require(_rewards != address(0));
        vault.approve(rewards, 0);
        rewards = _rewards;
        vault.approve(rewards, uint256(-1));
        emit UpdatedRewards(_rewards);
    }

     
    function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
        maxReportDelay = _delay;
        emit UpdatedReportDelay(_delay);
    }

     
    function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
        profitFactor = _profitFactor;
        emit UpdatedProfitFactor(_profitFactor);
    }

     
    function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
        debtThreshold = _debtThreshold;
        emit UpdatedDebtThreshold(_debtThreshold);
    }

     
    function setMetadataURI(string calldata _metadataURI) external onlyAuthorized {
        metadataURI = _metadataURI;
        emit UpdatedMetadataURI(_metadataURI);
    }

     
    function governance() internal view returns (address) {
        return vault.governance();
    }

     
    function estimatedTotalAssets() public virtual view returns (uint256);

     
    function isActive() public view returns (bool) {
        return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
    }

     
    function prepareReturn(uint256 _debtOutstanding)
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        );

     
    function adjustPosition(uint256 _debtOutstanding) internal virtual;

     
    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

     
    function tendTrigger(uint256 callCost) public virtual view returns (bool) {
         
         
         
        return false;
    }

     
    function tend() external onlyKeepers {
         
        adjustPosition(vault.debtOutstanding());
    }

     
    function harvestTrigger(uint256 callCost) public virtual view returns (bool) {
        StrategyParams memory params = vault.strategies(address(this));

         
        if (params.activation == 0) return false;

         
        if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

         
         
         
         
         
        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

         
        uint256 total = estimatedTotalAssets();
         
        if (total.add(debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total.sub(params.totalDebt);  

         
         
        uint256 credit = vault.creditAvailable();
        return (profitFactor.mul(callCost) < credit.add(profit));
    }

     
    function harvest() external onlyKeepers {
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = vault.debtOutstanding();
        uint256 debtPayment = 0;
        if (emergencyExit) {
             
            uint256 totalAssets = estimatedTotalAssets();
             
            (debtPayment, loss) = liquidatePosition(totalAssets > debtOutstanding ? totalAssets : debtOutstanding);
             
            if (debtPayment > debtOutstanding) {
                profit = debtPayment.sub(debtOutstanding);
                debtPayment = debtOutstanding;
            }
        } else {
             
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }

         
         
         
        debtOutstanding = vault.report(profit, loss, debtPayment);

         
        adjustPosition(debtOutstanding);

        emit Harvested(profit, loss, debtPayment, debtOutstanding);
    }

     
    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
         
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
         
        want.safeTransfer(msg.sender, amountFreed);
         
    }

     
    function prepareMigration(address _newStrategy) internal virtual;

     
    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault) || msg.sender == governance());
        require(BaseStrategyInitializable(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

     
    function setEmergencyExit() external onlyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

     
    function protectedTokens() internal virtual view returns (address[] memory);

     
    function sweep(address _token) external onlyGovernance {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(governance(), IERC20(_token).balanceOf(address(this)));
    }
}

 

contract StrategyIdle is BaseStrategyInitializable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 constant public MAX_GOV_TOKENS_LENGTH = 5;

    uint256 constant public FULL_ALLOC = 100000;

    address public uniswapRouterV2;
    address public weth;
    address public idleReservoir;
    address public idleYieldToken;
    address public referral;

    bool public checkVirtualPrice;
    uint256 public lastVirtualPrice;

    bool public checkRedeemedAmount;

    bool public alreadyRedeemed;

    address[] public govTokens;
    mapping(address => address[]) public paths;

    uint256 public redeemThreshold;

    modifier updateVirtualPrice() {
        uint256 currentTokenPrice = _getTokenPrice();
        if (checkVirtualPrice) {
            require(lastVirtualPrice <= currentTokenPrice, "Virtual price is decreasing from the last time, potential losses");
        }
        lastVirtualPrice = currentTokenPrice;
        _;
    }

    modifier onlyGovernanceOrManagement() {
        require(msg.sender == governance() || msg.sender == vault.management(), "!authorized");
        _;
    }

    constructor() public BaseStrategyInitializable(address(0), false) {}

    function init(
        address _vault,
        address _onBehalfOf,
        address[] memory _govTokens,
        address _weth,
        address _idleReservoir,
        address _idleYieldToken,
        address _referral,
        address _uniswapRouterV2
    ) external {
        _init(
            _vault,
            _onBehalfOf,
            _govTokens,
            _weth,
            _idleReservoir,
            _idleYieldToken,
            _referral,
            _uniswapRouterV2
        );
    }

    function _init(
        address _vault,
        address _onBehalfOf,
        address[] memory _govTokens,
        address _weth,
        address _idleReservoir,
        address _idleYieldToken,
        address _referral,
        address _uniswapRouterV2
    ) internal {
        _init(_vault, _onBehalfOf);

        require(address(want) == IIdleTokenV3_1(_idleYieldToken).token(), "Vault want is different from Idle token underlying");

        weth = _weth;
        idleReservoir = _idleReservoir;
        idleYieldToken = _idleYieldToken;
        referral = _referral;

        uniswapRouterV2 = _uniswapRouterV2;
        _setGovTokens(_govTokens);

        checkVirtualPrice = true;
        lastVirtualPrice = IIdleTokenV3_1(_idleYieldToken).tokenPrice();

        alreadyRedeemed = false;

        checkRedeemedAmount = true;

        redeemThreshold = 1;

        want.safeApprove(_idleYieldToken, type(uint256).max);
    }

    function setCheckVirtualPrice(bool _checkVirtualPrice) external onlyGovernance {
        checkVirtualPrice = _checkVirtualPrice;
    }

    function setCheckRedeemedAmount(bool _checkRedeemedAmount) external onlyGovernanceOrManagement {
        checkRedeemedAmount = _checkRedeemedAmount;
    }

    function enableAllChecks() external onlyGovernance {
        checkVirtualPrice = true;
        checkRedeemedAmount = true;
    }

    function disableAllChecks() external onlyGovernance {
        checkVirtualPrice = false;
        checkRedeemedAmount = false;
    }

    function setGovTokens(address[] memory _govTokens) external onlyGovernance {
        _setGovTokens(_govTokens);
    }

    function setRedeemThreshold(uint256 _redeemThreshold) external onlyGovernanceOrManagement {
        redeemThreshold = _redeemThreshold;
    }

     

    function name() external override view returns (string memory) {
        return string(abi.encodePacked("StrategyIdle", IIdleTokenV3_1(idleYieldToken).symbol()));
    }

    function estimatedTotalAssets() public override view returns (uint256) {
         
        return want.balanceOf(address(this))
                   .add(balanceOnIdle())  
        ;
    }

     
    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {
         
        if(alreadyRedeemed) {
            alreadyRedeemed = false;
        }

         
        IdleReservoir(idleReservoir).drip();

         
        uint256 debt = vault.strategies(address(this)).totalDebt;
        uint256 currentValue = estimatedTotalAssets();
        uint256 wantBalance = balanceOfWant();

         
        if (debt < currentValue){
            _profit = currentValue.sub(debt);
        } else {
            _loss = debt.sub(currentValue);
        }

         
        uint256 toFree = _debtOutstanding.add(_profit);

         
        if (toFree > wantBalance) {
             
            toFree = toFree.sub(wantBalance);
            uint256 freedAmount = freeAmount(toFree);

             
            uint256 withdrawalLoss = freedAmount < toFree ? toFree.sub(freedAmount) : 0;

             
            if (withdrawalLoss < _profit) {
                _profit = _profit.sub(withdrawalLoss);
            } else {
                _loss = _loss.add(withdrawalLoss.sub(_profit));
                _profit = 0;
            }
        }

         
        if (!alreadyRedeemed) {
            IIdleTokenV3_1(idleYieldToken).redeemIdleToken(0);
        } else {
            alreadyRedeemed = false;
        }

         
         
         
        uint256 liquidated = _liquidateGovTokens();

         
        _profit = _profit.add(liquidated);

         
        wantBalance = want.balanceOf(address(this));

        if (wantBalance < _profit) {
            _profit = wantBalance;
            _debtPayment = 0;
        } else if (wantBalance < _debtPayment.add(_profit)){
            _debtPayment = wantBalance.sub(_profit);
        } else {
            _debtPayment = _debtOutstanding;
        }
    }

     
    function adjustPosition(uint256 _debtOutstanding) internal override updateVirtualPrice {
         
         

         
        if (emergencyExit) {
            return;
        }

        uint256 balanceOfWant = balanceOfWant();
        if (balanceOfWant > _debtOutstanding) {
            IIdleTokenV3_1(idleYieldToken).mintIdleToken(balanceOfWant.sub(_debtOutstanding), true, referral);
        }
    }

     
    function freeAmount(uint256 _amount)
        internal
        updateVirtualPrice
        returns (uint256 freedAmount)
    {
        uint256 valueToRedeemApprox = _amount.mul(1e18).div(lastVirtualPrice) + 1;
        uint256 valueToRedeem = Math.min(
            valueToRedeemApprox,
            IERC20(idleYieldToken).balanceOf(address(this))
        );

        alreadyRedeemed = true;
        
        uint256 preBalanceOfWant = balanceOfWant();
        IIdleTokenV3_1(idleYieldToken).redeemIdleToken(valueToRedeem);
        freedAmount = balanceOfWant().sub(preBalanceOfWant);

        if (checkRedeemedAmount) {
             
             
            require(
                freedAmount.add(redeemThreshold) >= _amount,
                'Redeemed amount must be >= amountToRedeem');
        }


        return freedAmount;
    }

     
    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        updateVirtualPrice
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
         

        if (balanceOfWant() < _amountNeeded) {
             
            uint256 amountToRedeem = _amountNeeded.sub(balanceOfWant());
            freeAmount(amountToRedeem);
        }

         
        uint256 balanceOfWant = balanceOfWant();

        if (balanceOfWant >= _amountNeeded) {
            _liquidatedAmount = _amountNeeded;
        } else {
            _liquidatedAmount = balanceOfWant;
            _loss = _amountNeeded.sub(balanceOfWant);
        }
    }

     

    function harvestTrigger(uint256 callCost) public view override returns (bool) {
        return super.harvestTrigger(ethToWant(callCost));
    }

    function prepareMigration(address _newStrategy) internal override {
         
         

         
        IIdleTokenV3_1(idleYieldToken).redeemIdleToken(IERC20(idleYieldToken).balanceOf(address(this)));

         
        for (uint256 i = 0; i < govTokens.length; i++) {
            IERC20 govToken = IERC20(govTokens[i]);
            govToken.safeTransfer(_newStrategy, govToken.balanceOf(address(this)));
        }
    }

    function protectedTokens()
        internal
        override
        view
        returns (address[] memory)
    {
        address[] memory protected = new address[](1+govTokens.length);

        for (uint256 i = 0; i < govTokens.length; i++) {
            protected[i] = govTokens[i];
        }
        protected[govTokens.length] = idleYieldToken;

        return protected;
    }

    function balanceOnIdle() public view returns (uint256) {
        uint256 idleTokenBalance = IERC20(idleYieldToken).balanceOf(address(this));

         
        return idleTokenBalance > 0 ?
            idleTokenBalance.mul(_getTokenPrice()).div(1e18).add(1) : 0
        ;
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function ethToWant(uint256 _amount) public view returns (uint256) {
        if (_amount == 0) {
            return 0;
        }

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(want);
        uint256[] memory amounts = IUniswapRouter(uniswapRouterV2).getAmountsOut(_amount, path);

        return amounts[amounts.length - 1];
    }

    function getTokenPrice() view public returns (uint256) {
        return _getTokenPrice();
    }

    function _liquidateGovTokens() internal returns (uint256 liquidated) {
        for (uint256 i = 0; i < govTokens.length; i++) {
            address govTokenAddress = govTokens[i];
            uint256 balance = IERC20(govTokenAddress).balanceOf(address(this));
            if (balance > 0) {
                address[] memory path = paths[govTokenAddress];
                uint[] memory amounts = IUniswapRouter(uniswapRouterV2).swapExactTokensForTokens(
                    balance, 1, path, address(this), now.add(1800)
                );

                 
                liquidated.add(amounts[path.length-1]);
            }
        }
    }

    function _setGovTokens(address[] memory _govTokens) internal {
        require(_govTokens.length <= MAX_GOV_TOKENS_LENGTH , 'GovTokens too long');

         
        for (uint256 i = 0; i < govTokens.length; i++) {
            address govTokenAddress = govTokens[i];
            IERC20(govTokenAddress).safeTransfer(uniswapRouterV2, 0);
            delete paths[govTokenAddress];
        }

         
        govTokens = _govTokens;

         
        for (uint256 i = 0; i < _govTokens.length; i++) {
            address govTokenAddress = _govTokens[i];
            IERC20(govTokenAddress).safeApprove(uniswapRouterV2, type(uint256).max);

            address[] memory _path = new address[](3);
            _path[0] = address(govTokenAddress);
            _path[1] = weth;
            _path[2] = address(want);

            paths[_govTokens[i]] = _path;
        }
    }

    function _getTokenPrice() view internal returns (uint256) {
         

        IIdleTokenV3_1 iyt = IIdleTokenV3_1(idleYieldToken);

        uint256 userAvgPrice = iyt.userAvgPrices(address(this));
        uint256 currentPrice = iyt.tokenPrice();

        uint256 tokenPrice;

         
         
        if (userAvgPrice == 0 || currentPrice < userAvgPrice) {
            tokenPrice = currentPrice;
        } else {
            uint256 fee = iyt.fee();

            tokenPrice = ((currentPrice.mul(FULL_ALLOC))
                .sub(
                    fee.mul(
                         currentPrice.sub(userAvgPrice)
                    )
                )).div(FULL_ALLOC);
        }

        return tokenPrice;
    }
}