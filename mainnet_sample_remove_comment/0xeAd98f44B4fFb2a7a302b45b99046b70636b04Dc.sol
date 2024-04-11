

pragma solidity ^0.5.0;

 
contract Context {
     
     
    constructor () internal { }
     

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;  
        return msg.data;
    }
}

pragma solidity ^0.5.0;


 
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

     
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.5.17;

 
contract ReentrancyGuard {
    bool private _notEntered;

    function __initReentrancyGuard() internal {
         
         
         
         
         
         
        _notEntered = true;
    }

     
    modifier nonReentrant() {
         
        require(_notEntered, "ReentrancyGuard: reentrant call");

         
        _notEntered = false;

        _;

         
         
        _notEntered = true;
    }
}

pragma solidity 0.5.17;


interface IProtectionStaking {
    function calculateCompensating(address _investor, uint256 _peakPriceInUsdc) external view returns (uint256);

    function claimCompensation() external;

    function requestProtection(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function protectShares(uint256 _amount) external;

    function withdrawShares(uint256 _amount) external;

    function setPeakMintCap(uint256 _amount) external;
}

pragma solidity ^0.5.0;

 
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
pragma solidity 0.5.17;












contract ProtectionStaking is IProtectionStaking, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafePeakToken for IPeakToken;

    address public sharesToken;

    IPeakDeFiFund public fund;
    IPeakToken public peakToken;
    IUniswapOracle public uniswapOracle;

    uint256 public mintedPeakTokens;
    uint256 public peakMintCap = 5000000 * PEAK_PRECISION;  
    uint256 internal constant PEAK_PRECISION = 10**8;
    uint256 internal constant USDC_PRECISION = 10**6;
    uint256 internal constant PERCENTS_DECIMALS = 10**20;

    mapping(address => uint256) public peaks;
    mapping(address => uint256) public shares;
    mapping(address => uint256) public startProtectTimestamp;
    mapping(address => uint256) internal _lastClaimTimestamp;
    mapping(address => uint256) public lastClaimAmount;

    event ClaimCompensation(
        address investor,
        uint256 amount,
        uint256 timestamp
    );
    event RequestProtection(
        address investor,
        uint256 amount,
        uint256 timestamp
    );
    event Withdraw(address investor, uint256 amount, uint256 timestamp);
    event ProtectShares(address investor, uint256 amount, uint256 timestamp);
    event WithdrawShares(address investor, uint256 amount, uint256 timestamp);
    event ChangePeakMintCap(uint256 newAmmount);

    modifier during(IPeakDeFiFund.CyclePhase phase) {
        require(fund.cyclePhase() == phase, "wrong phase");
        if (fund.cyclePhase() == IPeakDeFiFund.CyclePhase.Intermission) {
            require(fund.isInitialized(), "fund not initialized");
        }
        _;
    }

    modifier ifNoCompensation() {
        uint256 peakPriceInUsdc = _getPeakPriceInUsdc();
        uint256 compensationAmount = _calculateCompensating(
            msg.sender,
            peakPriceInUsdc
        );
        require(compensationAmount == 0, "have compensation");
        _;
    }

    constructor(
        address payable _fundAddr,
        address _peakTokenAddr,
        address _sharesTokenAddr,
        address _uniswapOracle
    ) public {
        __initReentrancyGuard();
        require(_fundAddr != address(0));
        require(_peakTokenAddr != address(0));

        fund = IPeakDeFiFund(_fundAddr);
        peakToken = IPeakToken(_peakTokenAddr);
        uniswapOracle = IUniswapOracle(_uniswapOracle);
        sharesToken = _sharesTokenAddr;
    }

    function() external {}

    function _lostFundAmount(address _investor)
        internal
        view
        returns (uint256 lostFundAmount)
    {
        uint256 totalLostFundAmount = fund.totalLostFundAmount();
        uint256 investorLostFundAmount = lastClaimAmount[_investor];
        lostFundAmount = totalLostFundAmount.sub(investorLostFundAmount);
    }

    function _calculateCompensating(address _investor, uint256 _peakPriceInUsdc)
        internal
        view
        returns (uint256)
    {
        uint256 totalFundsAtManagePhaseStart = fund
        .totalFundsAtManagePhaseStart();
        uint256 totalShares = fund.totalSharesAtLastManagePhaseStart();
        uint256 managePhaseStartTime = fund.startTimeOfLastManagementPhase();
        uint256 lostFundAmount = _lostFundAmount(_investor);
        uint256 sharesAmount = shares[_investor];
        if (
            fund.cyclePhase() != IPeakDeFiFund.CyclePhase.Intermission ||
            managePhaseStartTime < _lastClaimTimestamp[_investor] ||
            managePhaseStartTime < startProtectTimestamp[_investor] ||
            mintedPeakTokens >= peakMintCap ||
            peaks[_investor] == 0 ||
            lostFundAmount == 0 ||
            totalShares == 0 ||
            _peakPriceInUsdc == 0 ||
            sharesAmount == 0
        ) {
            return 0;
        }
        uint256 sharesInUsdcAmount = sharesAmount
        .mul(totalFundsAtManagePhaseStart)
        .div(totalShares);
        uint256 peaksInUsdcAmount = peaks[_investor].mul(_peakPriceInUsdc).div(
            PEAK_PRECISION
        );
        uint256 protectedPercent = PERCENTS_DECIMALS;
        if (peaksInUsdcAmount < sharesInUsdcAmount) {
            protectedPercent = peaksInUsdcAmount.mul(PERCENTS_DECIMALS).div(
                sharesInUsdcAmount
            );
        }
        uint256 ownLostFundInUsd = lostFundAmount.mul(sharesAmount).div(
            totalShares
        );
        uint256 compensationInUSDC = ownLostFundInUsd.mul(protectedPercent).div(
            PERCENTS_DECIMALS
        );
        uint256 compensationInPeak = compensationInUSDC.mul(PEAK_PRECISION).div(
            _peakPriceInUsdc
        );
        if (peakMintCap - mintedPeakTokens < compensationInPeak) {
            compensationInPeak = peakMintCap - mintedPeakTokens;
        }
        return compensationInPeak;
    }

    function calculateCompensating(address _investor, uint256 _peakPriceInUsdc)
        public
        view
        returns (uint256)
    {
        return _calculateCompensating(_investor, _peakPriceInUsdc);
    }

    function updateLastClaimAmount() internal {
        lastClaimAmount[msg.sender] = fund.totalLostFundAmount();
    }

    function claimCompensation()
        external
        during(IPeakDeFiFund.CyclePhase.Intermission)
        nonReentrant
    {
        uint256 peakPriceInUsdc = _getPeakPriceInUsdc();
        uint256 compensationAmount = _calculateCompensating(
            msg.sender,
            peakPriceInUsdc
        );
        require(compensationAmount > 0, "not have compensation");
        _lastClaimTimestamp[msg.sender] = block.timestamp;
        peakToken.mint(msg.sender, compensationAmount);
        mintedPeakTokens = mintedPeakTokens.add(compensationAmount);
        require(
            mintedPeakTokens <= peakMintCap,
            "ProtectionStaking: reached cap"
        );
        updateLastClaimAmount();
        emit ClaimCompensation(msg.sender, compensationAmount, block.timestamp);
    }

    function requestProtection(uint256 _amount)
        external
        during(IPeakDeFiFund.CyclePhase.Intermission)
        nonReentrant
        ifNoCompensation
    {
        require(_amount > 0, "amount is 0");
        peakToken.safeTransferFrom(msg.sender, address(this), _amount);
        peaks[msg.sender] = peaks[msg.sender].add(_amount);
        startProtectTimestamp[msg.sender] = block.timestamp;
        updateLastClaimAmount();
        emit RequestProtection(msg.sender, _amount, block.timestamp);
    }

    function withdraw(uint256 _amount) external ifNoCompensation {
        require(
            peaks[msg.sender] >= _amount,
            "insufficient fund in Peak Token"
        );
        require(_amount > 0, "amount is 0");
        peaks[msg.sender] = peaks[msg.sender].sub(_amount);
        peakToken.safeTransfer(msg.sender, _amount);
        updateLastClaimAmount();
        emit Withdraw(msg.sender, _amount, block.timestamp);
    }

    function protectShares(uint256 _amount)
        external
        nonReentrant
        during(IPeakDeFiFund.CyclePhase.Intermission)
        ifNoCompensation
    {
        require(_amount > 0, "amount is 0");
        IERC20(sharesToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        startProtectTimestamp[msg.sender] = block.timestamp;
        shares[msg.sender] = shares[msg.sender].add(_amount);
        updateLastClaimAmount();
        emit ProtectShares(msg.sender, _amount, block.timestamp);
    }

    function withdrawShares(uint256 _amount)
        external
        nonReentrant
        ifNoCompensation
    {
        require(
            shares[msg.sender] >= _amount,
            "insufficient fund in Share Token"
        );
        require(_amount > 0, "amount is 0");
        shares[msg.sender] = shares[msg.sender].sub(_amount);
        IERC20(sharesToken).safeTransfer(msg.sender, _amount);
        emit WithdrawShares(msg.sender, _amount, block.timestamp);
    }

    function setPeakMintCap(uint256 _amount) external onlyOwner {
        peakMintCap = _amount;
        emit ChangePeakMintCap(_amount);
    }

    function _getPeakPriceInUsdc() internal returns (uint256) {
        uniswapOracle.update();
        uint256 priceInUSDC = uniswapOracle.consult(
            address(peakToken),
            PEAK_PRECISION
        );
        if (priceInUSDC == 0) {
            return USDC_PRECISION.mul(3).div(10);
        }
        return priceInUSDC;
    }
}

pragma solidity ^0.5.0;

 
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

pragma solidity 0.5.17;






 
contract Utils {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Detailed;

     
    modifier isValidToken(address _token) {
        require(_token != address(0));
        if (_token != address(ETH_TOKEN_ADDRESS)) {
            require(isContract(_token));
        }
        _;
    }

    address public USDC_ADDR;
    address payable public KYBER_ADDR;
    address payable public ONEINCH_ADDR;

    bytes public constant PERM_HINT = "PERM";

     
    ERC20Detailed internal constant ETH_TOKEN_ADDRESS =
        ERC20Detailed(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    ERC20Detailed internal usdc;
    IKyberNetwork internal kyber;

    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28);  
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant MAX_DECIMALS = 18;

    constructor(
        address _usdcAddr,
        address payable _kyberAddr,
        address payable _oneInchAddr
    ) public {
        USDC_ADDR = _usdcAddr;
        KYBER_ADDR = _kyberAddr;
        ONEINCH_ADDR = _oneInchAddr;

        usdc = ERC20Detailed(_usdcAddr);
        kyber = IKyberNetwork(_kyberAddr);
    }

     
    function getDecimals(ERC20Detailed _token) internal view returns (uint256) {
        if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
            return uint256(ETH_DECIMALS);
        }
        return uint256(_token.decimals());
    }

     
    function getBalance(ERC20Detailed _token, address _addr)
        internal
        view
        returns (uint256)
    {
        if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
            return uint256(_addr.balance);
        }
        return uint256(_token.balanceOf(_addr));
    }

     
    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return ((destAmount * PRECISION) /
                ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return ((destAmount *
                PRECISION *
                (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

     
    function __kyberTrade(
        ERC20Detailed _srcToken,
        uint256 _srcAmount,
        ERC20Detailed _destToken
    )
        internal
        returns (
            uint256 _destPriceInSrc,
            uint256 _srcPriceInDest,
            uint256 _actualDestAmount,
            uint256 _actualSrcAmount
        )
    {
        require(_srcToken != _destToken);

        uint256 beforeSrcBalance = getBalance(_srcToken, address(this));
        uint256 msgValue;
        if (_srcToken != ETH_TOKEN_ADDRESS) {
            msgValue = 0;
            _srcToken.safeApprove(KYBER_ADDR, 0);
            _srcToken.safeApprove(KYBER_ADDR, _srcAmount);
        } else {
            msgValue = _srcAmount;
        }
        _actualDestAmount = kyber.tradeWithHint.value(msgValue)(
            _srcToken,
            _srcAmount,
            _destToken,
            toPayableAddr(address(this)),
            MAX_QTY,
            1,
            address(0),
            PERM_HINT
        );
        _actualSrcAmount = beforeSrcBalance.sub(
            getBalance(_srcToken, address(this))
        );
        require(_actualDestAmount > 0 && _actualSrcAmount > 0);
        _destPriceInSrc = calcRateFromQty(
            _actualDestAmount,
            _actualSrcAmount,
            getDecimals(_destToken),
            getDecimals(_srcToken)
        );
        _srcPriceInDest = calcRateFromQty(
            _actualSrcAmount,
            _actualDestAmount,
            getDecimals(_srcToken),
            getDecimals(_destToken)
        );
    }

     
    function __oneInchTrade(
        ERC20Detailed _srcToken,
        uint256 _srcAmount,
        ERC20Detailed _destToken,
        bytes memory _calldata
    )
        internal
        returns (
            uint256 _destPriceInSrc,
            uint256 _srcPriceInDest,
            uint256 _actualDestAmount,
            uint256 _actualSrcAmount
        )
    {
        require(_srcToken != _destToken);

        uint256 beforeSrcBalance = getBalance(_srcToken, address(this));
        uint256 beforeDestBalance = getBalance(_destToken, address(this));
         
        if (_srcToken != ETH_TOKEN_ADDRESS) {
            _actualSrcAmount = 0;
            _srcToken.safeApprove(ONEINCH_ADDR, 0);
            _srcToken.safeApprove(ONEINCH_ADDR, _srcAmount);
        } else {
            _actualSrcAmount = _srcAmount;
        }

         
        (bool success, ) = ONEINCH_ADDR.call.value(_actualSrcAmount)(_calldata);
        require(success);

         
        _actualDestAmount = getBalance(_destToken, address(this)).sub(
            beforeDestBalance
        );
        _actualSrcAmount = beforeSrcBalance.sub(
            getBalance(_srcToken, address(this))
        );
        require(_actualDestAmount > 0 && _actualSrcAmount > 0);
        _destPriceInSrc = calcRateFromQty(
            _actualDestAmount,
            _actualSrcAmount,
            getDecimals(_destToken),
            getDecimals(_srcToken)
        );
        _srcPriceInDest = calcRateFromQty(
            _actualSrcAmount,
            _actualDestAmount,
            getDecimals(_srcToken),
            getDecimals(_destToken)
        );
    }

     
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        if (_addr == address(0)) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function toPayableAddr(address _addr)
        internal
        pure
        returns (address payable)
    {
        return address(uint160(_addr));
    }
}

pragma solidity ^0.5.0;





 
library SafePeakToken {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IPeakToken token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IPeakToken token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IPeakToken token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IPeakToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IPeakToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function callOptionalReturn(IPeakToken token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity 0.5.17;


interface IPeakToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address recipient, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

pragma solidity 0.5.17;

interface IPeakDeFiFund {
    enum CyclePhase {
        Intermission,
        Manage
    }

    enum VoteDirection {
        Empty,
        For,
        Against
    }

    enum Subchunk {
        Propose,
        Vote
    }

    function initParams(
        address payable _devFundingAccount,
        uint256[2] calldata _phaseLengths,
        uint256 _devFundingRate,
        address payable _previousVersion,
        address _usdcAddr,
        address payable _kyberAddr,
        address _compoundFactoryAddr,
        address _peakdefiLogic,
        address _peakdefiLogic2,
        address _peakdefiLogic3,
        uint256 _startCycleNumber,
        address payable _oneInchAddr,
        address _peakRewardAddr,
        address _peakStakingAddr
    ) external;

    function initOwner() external;

    function cyclePhase() external view returns (CyclePhase phase);

    function isInitialized() external view returns (bool);

    function devFundingAccount() external view returns (uint256);

    function previousVersion() external view returns (uint256);

    function cycleNumber() external view returns (uint256);

    function totalFundsInUSDC() external view returns (uint256);

    function totalFundsAtManagePhaseStart() external view returns (uint256);

    function totalLostFundAmount() external view returns (uint256);

    function totalFundsAtManagePhaseEnd() external view returns (uint256);

    function startTimeOfCyclePhase() external view returns (uint256);

    function startTimeOfLastManagementPhase() external view returns (uint256);

    function devFundingRate() external view returns (uint256);

    function totalCommissionLeft() external view returns (uint256);

    function totalSharesAtLastManagePhaseStart() external view returns (uint256);

    function peakReferralTotalCommissionLeft() external view returns (uint256);

    function peakManagerStakeRequired() external view returns (uint256);

    function peakReferralToken() external view returns (uint256);

    function peakReward() external view returns (address);

    function peakStaking() external view returns (address);

    function isPermissioned() external view returns (bool);

    function initInternalTokens(
        address _repAddr,
        address _sTokenAddr,
        address _peakReferralTokenAddr
    ) external;

    function initRegistration(
        uint256 _newManagerRepToken,
        uint256 _maxNewManagersPerCycle,
        uint256 _reptokenPrice,
        uint256 _peakManagerStakeRequired,
        bool _isPermissioned
    ) external;

    function initTokenListings(
        address[] calldata _kyberTokens,
        address[] calldata _compoundTokens
    ) external;

    function setProxy(address payable proxyAddr) external;

    function developerInitiateUpgrade(address payable _candidate) external returns (bool _success);

    function migrateOwnedContractsToNextVersion() external;

    function transferAssetToNextVersion(address _assetAddress) external;

    function investmentsCount(address _userAddr)
        external
        view
        returns (uint256 _count);

    function nextVersion()
        external
        view
        returns (address payable);

    function transferOwnership(address newOwner) external;

    function compoundOrdersCount(address _userAddr)
        external
        view
        returns (uint256 _count);

    function getPhaseLengths()
        external
        view
        returns (uint256[2] memory _phaseLengths);

    function commissionBalanceOf(address _manager)
        external
        returns (uint256 _commission, uint256 _penalty);

    function commissionOfAt(address _manager, uint256 _cycle)
        external
        returns (uint256 _commission, uint256 _penalty);

    function changeDeveloperFeeAccount(address payable _newAddr) external;

    function changeDeveloperFeeRate(uint256 _newProp) external;

    function listKyberToken(address _token) external;

    function listCompoundToken(address _token) external;

    function nextPhase() external;

    function registerWithUSDC() external;

    function registerWithETH() external payable;

    function registerWithToken(address _token, uint256 _donationInTokens) external;

    function depositEther(address _referrer) external payable;

    function depositEtherAdvanced(
        bool _useKyber,
        bytes calldata _calldata,
        address _referrer
    ) external payable;

    function depositUSDC(uint256 _usdcAmount, address _referrer) external;

    function depositToken(
        address _tokenAddr,
        uint256 _tokenAmount,
        address _referrer
    ) external;

    function depositTokenAdvanced(
        address _tokenAddr,
        uint256 _tokenAmount,
        bool _useKyber,
        bytes calldata _calldata,
        address _referrer
    ) external;

    function withdrawEther(uint256 _amountInUSDC) external;

    function withdrawEtherAdvanced(
        uint256 _amountInUSDC,
        bool _useKyber,
        bytes calldata _calldata
    ) external;

    function withdrawUSDC(uint256 _amountInUSDC) external;

    function withdrawToken(address _tokenAddr, uint256 _amountInUSDC) external;

    function withdrawTokenAdvanced(
        address _tokenAddr,
        uint256 _amountInUSDC,
        bool _useKyber,
        bytes calldata _calldata
    ) external;

    function redeemCommission(bool _inShares) external;

    function redeemCommissionForCycle(bool _inShares, uint256 _cycle) external;

    function sellLeftoverToken(address _tokenAddr, bytes calldata _calldata)
        external;

    function sellLeftoverCompoundOrder(address payable _orderAddress) external;

    function burnDeadman(address _deadman) external;

    function createInvestment(
        address _tokenAddress,
        uint256 _stake,
        uint256 _maxPrice
    ) external;

    function createInvestmentV2(
        address _sender,
        address _tokenAddress,
        uint256 _stake,
        uint256 _maxPrice,
        bytes calldata _calldata,
        bool _useKyber
    ) external;

    function sellInvestmentAsset(
        uint256 _investmentId,
        uint256 _tokenAmount,
        uint256 _minPrice
    ) external;

    function sellInvestmentAssetV2(
        address _sender,
        uint256 _investmentId,
        uint256 _tokenAmount,
        uint256 _minPrice,
        bytes calldata _calldata,
        bool _useKyber
    ) external;

    function createCompoundOrder(
        address _sender,
        bool _orderType,
        address _tokenAddress,
        uint256 _stake,
        uint256 _minPrice,
        uint256 _maxPrice
    ) external;

    function sellCompoundOrder(
        address _sender,
        uint256 _orderId,
        uint256 _minPrice,
        uint256 _maxPrice
    ) external;

    function repayCompoundOrder(
        address _sender,
        uint256 _orderId,
        uint256 _repayAmountInUSDC
    ) external;

    function emergencyExitCompoundTokens(
        address _sender,
        uint256 _orderId,
        address _tokenAddr,
        address _receiver
    ) external;

    function peakReferralCommissionBalanceOf(address _referrer) external returns (uint256 _commission);

    function peakReferralCommissionOfAt(address _referrer, uint256 _cycle) external returns (uint256 _commission);

    function peakReferralRedeemCommission() external;

    function peakReferralRedeemCommissionForCycle(uint256 _cycle) external;

    function peakChangeManagerStakeRequired(uint256 _newValue) external;
}

pragma solidity 0.5.17;

 
interface IUniswapOracle {
    function update() external returns (bool success);

    function consult(address token, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);
}

pragma solidity ^0.5.0;



 
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

     
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

     
    function name() public view returns (string memory) {
        return _name;
    }

     
    function symbol() public view returns (string memory) {
        return _symbol;
    }

     
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

pragma solidity ^0.5.0;





 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity 0.5.17;



 
interface IKyberNetwork {
    function getExpectedRate(
        ERC20Detailed src,
        ERC20Detailed dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 slippageRate);

    function tradeWithHint(
        ERC20Detailed src,
        uint256 srcAmount,
        ERC20Detailed dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId,
        bytes calldata hint
    ) external payable returns (uint256);
}

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
