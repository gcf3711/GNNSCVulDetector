// SPDX-License-Identifier: AGPL-3.0-only
pragma abicoder v2;
pragma experimental ABIEncoderV2;


// 
pragma solidity >=0.7.0;



abstract contract Auth {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event AuthorityUpdated(Authority indexed authority);

    event OwnerUpdated(address indexed owner);

    /*///////////////////////////////////////////////////////////////
                       OWNER AND AUTHORITY STORAGE
    //////////////////////////////////////////////////////////////*/

    Authority public authority;

    address public owner;

    constructor() {
        owner = msg.sender;

        emit OwnerUpdated(msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                  OWNER AND AUTHORITY SETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) external requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(owner);
    }

    function setAuthority(Authority newAuthority) external requiresAuth {
        authority = newAuthority;

        emit AuthorityUpdated(authority);
    }

    /*///////////////////////////////////////////////////////////////
                        AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        }

        if (src == owner) {
            return true;
        }

        Authority _authority = authority;

        if (_authority == Authority(address(0))) {
            return false;
        }

        return _authority.canCall(src, address(this), sig);
    }
}

// 
pragma solidity 0.7.6;





abstract contract CrossDomainEnabled {
    
    iOVM_CrossDomainMessenger public immutable CROSS_DOMAIN_MESSENGER;

    
    constructor(iOVM_CrossDomainMessenger _CROSS_DOMAIN_MESSENGER) {
        CROSS_DOMAIN_MESSENGER = _CROSS_DOMAIN_MESSENGER;
    }

    
    
    modifier onlyFromCrossDomainAccount(address sourceDomainAccount) {
        require(msg.sender == address(CROSS_DOMAIN_MESSENGER), "NOT_CROSS_DOMAIN_MESSENGER");

        require(CROSS_DOMAIN_MESSENGER.xDomainMessageSender() == sourceDomainAccount, "WRONG_CROSS_DOMAIN_SENDER");

        _;
    }
}
// @unsupported: ovm
// 
pragma solidity 0.7.6;














contract L1_NovaExecutionManager is Auth, CrossDomainEnabled {
    using SafeMath for uint256;

    /*///////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    
    
    string public constant HARD_REVERT_TEXT = "__NOVA__HARD__REVERT__";

    
    
    bytes32 public constant HARD_REVERT_HASH = keccak256(abi.encodeWithSignature("Error(string)", HARD_REVERT_TEXT));

    
    
    bytes32 public constant DEFAULT_EXECHASH = 0xFEEDFACECAFEBEEFFEEDFACECAFEBEEFFEEDFACECAFEBEEFFEEDFACECAFEBEEF;

    /*///////////////////////////////////////////////////////////////
                              IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    
    
    /// deployed on L2. We can only communicate with this address using cross domain messages.
    address public immutable L2_NOVA_REGISTRY_ADDRESS;

    
    
    /// only the execution manager can transfer them. If relayers approved tokens directly to the execution manager, another relayer
    /// could steal them by calling exec with the token set as the strategy and transferFrom or pull (used by DAI/MKR) used as calldata.
    L1_NovaApprovalEscrow public immutable L1_NOVA_APPROVAL_ESCROW;

    
    
    constructor(address _L2_NOVA_REGISTRY_ADDRESS, iOVM_CrossDomainMessenger _CROSS_DOMAIN_MESSENGER)
        CrossDomainEnabled(_CROSS_DOMAIN_MESSENGER)
    {
        L2_NOVA_REGISTRY_ADDRESS = _L2_NOVA_REGISTRY_ADDRESS;

        // Create an approval escrow which implicitly becomes
        // owned by the execution manager in its constructor.
        L1_NOVA_APPROVAL_ESCROW = new L1_NovaApprovalEscrow();
    }

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    
    
    event GasConfigUpdated(GasConfig newGasConfig);

    
    
    event StrategyRegistered(StrategyRiskLevel strategyRiskLevel);

    
    
    
    
    event Exec(bytes32 indexed execHash, address relayer, bool reverted, uint256 gasUsed);

    /*///////////////////////////////////////////////////////////////
                   GAS LIMIT/ESTIMATION CONFIGURATION
    //////////////////////////////////////////////////////////////*/

    
    
    
    
    
    struct GasConfig {
        // This needs to factor in raw calldata costs, along with the hidden
        // cost of abi decoding and copying the calldata into an Solidity function.
        uint32 calldataByteGasEstimate;
        // This needs to factor in the base transaction gas (currently 21000), along
        // with the gas cost of sending the cross domain message and emitting the Exec event.
        uint96 missingGasEstimate;
        // This needs to factor in the max amount of gas consumed after the strategy call, up
        // until the cross domain message is sent (as this is not accounted for in missingGasEstimate).
        uint96 strategyCallGasBuffer;
        // This needs to factor in the overhead of relaying the message on L2 (currently ~800k),
        // along with the actual L2 gas cost of calling the L2_NovaRegistry's execCompleted function.
        uint32 execCompletedMessageGasLimit;
    }

    
    GasConfig public gasConfig =
        GasConfig({
            calldataByteGasEstimate: 13, // OpenGSN uses 13 to estimate gas per calldata byte too.
            missingGasEstimate: 200000, // Rough estimate for missing gas. Tune this in production.
            strategyCallGasBuffer: 5000, // Overly cautious gas buffer. Can likely be safely reduced.
            execCompletedMessageGasLimit: 1500000 // If the limit is too low, relayers won't get paid.
        });

    
    
    function updateGasConfig(GasConfig calldata newGasConfig) external requiresAuth {
        gasConfig = newGasConfig;

        emit GasConfigUpdated(newGasConfig);
    }

    /*///////////////////////////////////////////////////////////////
                      STRATEGY RISK LEVEL STORAGE
    //////////////////////////////////////////////////////////////*/

    
    enum StrategyRiskLevel {
        // The strategy has not been assigned a risk level.
        // It has the equivalent abilities of a SAFE strategy,
        // but could upgrade itself to an UNSAFE strategy at any time.
        UNKNOWN,
        // The strategy has registered itself as a safe strategy,
        // meaning it cannot use transferFromRelayer or trigger a hard
        // revert. A SAFE strategy cannot upgrade itself to become UNSAFE.
        SAFE,
        // The strategy has registered itself as an unsafe strategy,
        // meaning it has access to all the functionality the execution
        // manager provides like transferFromRelayer and the ability to hard
        // revert. An UNSAFE strategy cannot downgrade itself to become SAFE.
        UNSAFE
    }

    
    
    mapping(address => StrategyRiskLevel) public getStrategyRiskLevel;

    
    
    
    function registerSelfAsStrategy(StrategyRiskLevel strategyRiskLevel) external requiresAuth {
        // Ensure the strategy has not already registered itself, as if strategies could change their risk level arbitrarily
        // they would be able to trick relayers into executing them believing they were safe, and then use unsafe functionality.
        require(getStrategyRiskLevel[msg.sender] == StrategyRiskLevel.UNKNOWN, "ALREADY_REGISTERED");

        // Strategies can't register as UNKNOWN because it would emit an unhelpful StrategyRegistered event and confuse relayers.
        require(strategyRiskLevel != StrategyRiskLevel.UNKNOWN, "INVALID_RISK_LEVEL");

        // Set the strategy's risk level.
        getStrategyRiskLevel[msg.sender] = strategyRiskLevel;

        emit StrategyRegistered(strategyRiskLevel);
    }

    /*///////////////////////////////////////////////////////////////
                        EXECUTION CONTEXT STORAGE
    //////////////////////////////////////////////////////////////*/

    
    
    address public currentRelayer;

    
    
    address public currentlyExecutingStrategy;

    
    
    bytes32 public currentExecHash = DEFAULT_EXECHASH;

    /*///////////////////////////////////////////////////////////////
                            EXECUTION LOGIC
    //////////////////////////////////////////////////////////////*/

    
    
    
    
    
    
    function exec(
        uint256 nonce,
        address strategy,
        bytes calldata l1Calldata,
        uint256 gasLimit,
        address l2Recipient,
        uint256 deadline
    ) external {
        // Measure gas left at the start of execution.
        uint256 startGas = gasleft();

        // Check that the deadline has not already passed.
        require(block.timestamp <= deadline, "PAST_DEADLINE");

        // Substitute for Auth's requiresAuth modifier.
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        // Prevent the strategy or another contract from trying
        // to frontrun a relayer's execution and take their payment.
        require(currentExecHash == DEFAULT_EXECHASH, "ALREADY_EXECUTING");

        // We cannot allow calling cross domain messenger directly, as a
        // malicious relayer could use it to trigger the registry's execCompleted
        // function and claim bounties without actually executing the proper request(s).
        require(strategy != address(CROSS_DOMAIN_MESSENGER), "UNSAFE_STRATEGY");

        // We cannot allow calling the approval escrow directly, as a malicious
        // relayer could call its transferTokenToStrategy function and access tokens
        // from other relayers outside of a proper call to the transferFromRelayer function.
        require(strategy != address(L1_NOVA_APPROVAL_ESCROW), "UNSAFE_STRATEGY");

        // We cannot allow calling the execution manager itself, as any malicious
        // relayer could exploit Auth inherited functions to change ownership, blacklist
        // other relayers, or freeze the contract entirely, without being properly authorized.
        require(strategy != address(this), "UNSAFE_STRATEGY");

        // Compute the relevant execHash.
        bytes32 execHash = NovaExecHashLib.compute({
            nonce: nonce,
            strategy: strategy,
            l1Calldata: l1Calldata,
            gasLimit: gasLimit,
            gasPrice: tx.gasprice
        });

        // Initialize execution context.
        currentExecHash = execHash;
        currentRelayer = msg.sender;
        currentlyExecutingStrategy = strategy;

        // Call the strategy with a safe gas limit.
        (bool success, bytes memory returnData) = strategy.call{
            gas: gasLimit
                .sub(msg.data.length.mul(gasConfig.calldataByteGasEstimate))
                .sub(gasConfig.strategyCallGasBuffer)
                .sub(gasConfig.missingGasEstimate)
                .sub(startGas - gasleft())
        }(l1Calldata);

        // Revert if a valid hard revert was triggered. A hard revert is only valid if the strategy had a risk level of UNSAFE.
        require(
            success || keccak256(returnData) != HARD_REVERT_HASH || getStrategyRiskLevel[strategy] != StrategyRiskLevel.UNSAFE,
            "HARD_REVERT"
        );

        // Reset currentExecHash to default so transferFromRelayer becomes uncallable again.
        currentExecHash = DEFAULT_EXECHASH;

        // Estimate how much gas this tx will have consumed in total (not accounting for refunds).
        uint256 gasUsedEstimate = msg.data.length.mul(gasConfig.calldataByteGasEstimate).add(gasConfig.missingGasEstimate).add(
            startGas - gasleft()
        );

        // Send message to unlock the bounty on L2.
        CROSS_DOMAIN_MESSENGER.sendMessage(
            L2_NOVA_REGISTRY_ADDRESS,
            abi.encodeWithSelector(
                L2_NovaRegistry.execCompleted.selector,
                // Computed execHash:
                execHash,
                // The reward recipient on L2:
                l2Recipient,
                // Did the call revert:
                !success,
                // Estimated gas used in total:
                gasUsedEstimate
            ),
            gasConfig.execCompletedMessageGasLimit
        );

        emit Exec(execHash, msg.sender, !success, gasUsedEstimate);
    }

    /*///////////////////////////////////////////////////////////////
                          STRATEGY UTILITIES
    //////////////////////////////////////////////////////////////*/

    
    /// approved to the L1_NOVA_APPROVAL_ESCROW to currently executing strategy.
    
    
    
    
    
    function transferFromRelayer(address token, uint256 amount) external requiresAuth {
        // Only the currently executing strategy is allowed to call this function.
        // Since msg.sender is inexpensive, from here on it's used to access the strategy.
        require(msg.sender == currentlyExecutingStrategy, "NOT_CURRENT_STRATEGY");

        // Ensure currentExecHash is not set to DEFAULT_EXECHASH as otherwise a
        // malicious strategy could transfer tokens outside of an active execution.
        require(currentExecHash != DEFAULT_EXECHASH, "NO_ACTIVE_EXECUTION");

        // Ensure the strategy has registered itself as UNSAFE so relayers can
        // avoid strategies that use transferFromRelayer if they want to be cautious.
        require(getStrategyRiskLevel[msg.sender] == StrategyRiskLevel.UNSAFE, "UNSUPPORTED_RISK_LEVEL");

        // Transfer tokens from the relayer to the strategy.
        require(
            L1_NOVA_APPROVAL_ESCROW.transferApprovedToken({
                token: token,
                amount: amount,
                sender: currentRelayer,
                recipient: msg.sender
            }),
            HARD_REVERT_TEXT // Hard revert if the transfer fails.
        );
    }

    
    
    /// they are triggered by a strategy not registered as UNSAFE.
    function hardRevert() external pure {
        // Call revert with the hard revert text.
        revert(HARD_REVERT_TEXT);
    }
}


interface Authority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) external view returns (bool);
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
pragma solidity 0.7.6;



library NovaExecHashLib {
    
    
    
    function compute(
        uint256 nonce,
        address strategy,
        bytes memory l1Calldata,
        uint256 gasPrice,
        uint256 gasLimit
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(nonce, strategy, l1Calldata, gasPrice, gasLimit));
    }
}

// 
pragma solidity 0.7.6;














contract L2_NovaRegistry is Auth, CrossDomainEnabled {
    using SafeTransferLib for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /*///////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    
    uint256 public constant MAX_INPUT_TOKENS = 5;

    
    uint256 public constant MIN_UNLOCK_DELAY_SECONDS = 300;

    
    constructor(iOVM_CrossDomainMessenger _CROSS_DOMAIN_MESSENGER) CrossDomainEnabled(_CROSS_DOMAIN_MESSENGER) {}

    /*///////////////////////////////////////////////////////////////
                    EXECUTION MANAGER ADDRESS STORAGE
    //////////////////////////////////////////////////////////////*/

    
    address public L1_NovaExecutionManagerAddress;

    
    
    function connectExecutionManager(address newExecutionManagerAddress) external requiresAuth {
        L1_NovaExecutionManagerAddress = newExecutionManagerAddress;

        emit ExecutionManagerConnected(newExecutionManagerAddress);
    }

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    
    
    event ExecutionManagerConnected(address newExecutionManagerAddress);

    
    
    
    event RequestExec(bytes32 indexed execHash, address indexed strategy);

    
    
    
    
    
    event ExecCompleted(bytes32 indexed execHash, address indexed rewardRecipient, bool reverted, uint256 gasUsed);

    
    
    event ClaimInputTokens(bytes32 indexed execHash);

    
    
    event WithdrawTokens(bytes32 indexed execHash);

    
    
    
    event UnlockTokens(bytes32 indexed execHash, uint256 unlockTimestamp);

    
    
    event RelockTokens(bytes32 indexed execHash);

    
    
    
    
    
    event SpeedUpRequest(bytes32 indexed execHash, bytes32 indexed newExecHash, uint256 newNonce, uint256 switchTimestamp);

    /*///////////////////////////////////////////////////////////////
                       GLOBAL NONCE COUNTER STORAGE
    //////////////////////////////////////////////////////////////*/

    
    uint256 public systemNonce;

    /*///////////////////////////////////////////////////////////////
                           PER REQUEST STORAGE
    //////////////////////////////////////////////////////////////*/

    
    mapping(bytes32 => address) public getRequestCreator;

    
    mapping(bytes32 => address) public getRequestStrategy;

    
    mapping(bytes32 => bytes) public getRequestCalldata;

    
    mapping(bytes32 => uint256) public getRequestGasLimit;

    
    mapping(bytes32 => uint256) public getRequestGasPrice;

    
    mapping(bytes32 => uint256) public getRequestTip;

    
    mapping(bytes32 => uint256) public getRequestNonce;

    
    
    
    
    
    struct InputToken {
        IERC20 l2Token;
        uint256 amount;
    }

    
    mapping(bytes32 => InputToken[]) internal requestInputTokens;

    
    
    function getRequestInputTokens(bytes32 execHash) external view returns (InputToken[] memory) {
        return requestInputTokens[execHash];
    }

    /*///////////////////////////////////////////////////////////////
                       INPUT TOKEN RECIPIENT STORAGE
    //////////////////////////////////////////////////////////////*/

    
    
    /// If recipient is not address(0), this means the request is no longer executable.
    
    struct InputTokenRecipientData {
        address recipient;
        bool isClaimed;
    }

    
    mapping(bytes32 => InputTokenRecipientData) public getRequestInputTokenRecipientData;

    /*///////////////////////////////////////////////////////////////
                              UNLOCK STORAGE
    //////////////////////////////////////////////////////////////*/

    
    /// its tokens unlocked, meaning the creator can withdraw tokens from the request.
    
    mapping(bytes32 => uint256) public getRequestUnlockTimestamp;

    /*///////////////////////////////////////////////////////////////
                              UNCLE STORAGE
    //////////////////////////////////////////////////////////////*/

    
    /// via speedUpRequest to their corresponding "uncled" request's execHash.
    
    /// speedUpRequest in favor of a resubmitted request generated in the transaction.
    
    mapping(bytes32 => bytes32) public getRequestUncle;

    
    /// speedUpRequest to their corresponding "resubmitted" request's execHash.
    
    /// uncle after MIN_UNLOCK_DELAY_SECONDS from the time speedUpRequest was called.
    
    mapping(bytes32 => bytes32) public getResubmittedRequest;

    
    /// and replaced by a re-submitted request with a higher gas price (via speedUpRequest).
    
    mapping(bytes32 => uint256) public getRequestDeathTimestamp;

    /*///////////////////////////////////////////////////////////////
                           STATEFUL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    
    
    
    
    
    
    
    /// If the relayer executes the request and the strategy reverts, the creator will be refunded the tip.
    
    /// need to execute the request on L1. Input tokens are refunded to the relayer on L2 after a successful execution.
    
    function requestExec(
        address strategy,
        bytes calldata l1Calldata,
        uint256 gasLimit,
        uint256 gasPrice,
        uint256 tip,
        InputToken[] calldata inputTokens
    ) public payable requiresAuth returns (bytes32 execHash) {
        // Do not allow more than MAX_INPUT_TOKENS input tokens as it could use too much gas.
        require(inputTokens.length <= MAX_INPUT_TOKENS, "TOO_MANY_INPUTS");

        // Ensure enough ETH was sent along with the call to cover gas and the tip.
        require(msg.value == gasLimit.mul(gasPrice).add(tip), "BAD_ETH_VALUE");

        // Increment the global nonce.
        systemNonce += 1;

        // Compute the execHash for this request.
        execHash = NovaExecHashLib.compute({
            nonce: systemNonce,
            strategy: strategy,
            l1Calldata: l1Calldata,
            gasPrice: gasPrice,
            gasLimit: gasLimit
        });

        // Store all critical request data.
        getRequestCreator[execHash] = msg.sender;
        getRequestStrategy[execHash] = strategy;
        getRequestCalldata[execHash] = l1Calldata;
        getRequestGasLimit[execHash] = gasLimit;
        getRequestGasPrice[execHash] = gasPrice;
        getRequestTip[execHash] = tip;
        getRequestNonce[execHash] = systemNonce;

        emit RequestExec(execHash, strategy);

        // Transfer input tokens in that the request creator has approved.
        for (uint256 i = 0; i < inputTokens.length; i++) {
            inputTokens[i].l2Token.safeTransferFrom(msg.sender, address(this), inputTokens[i].amount);

            // We can't just put a calldata/memory array directly into storage so we have to go index by index.
            requestInputTokens[execHash].push(inputTokens[i]);
        }
    }

    
    
    function requestExecWithTimeout(
        address strategy,
        bytes calldata l1Calldata,
        uint256 gasLimit,
        uint256 gasPrice,
        uint256 tip,
        InputToken[] calldata inputTokens,
        uint256 autoUnlockDelaySeconds
    ) external payable returns (bytes32 execHash) {
        // Create a request and get its execHash.
        execHash = requestExec(strategy, l1Calldata, gasLimit, gasPrice, tip, inputTokens);

        // Schedule an unlock set to complete autoUnlockDelay seconds from now.
        unlockTokens(execHash, autoUnlockDelaySeconds);
    }

    
    
    /// reverted (as input tokens are not sent to relayers if the request reverts).
    
    /// which is either the l2Recipient passed to execCompleted or the request creator if the request reverted.
    
    function claimInputTokens(bytes32 execHash) external requiresAuth {
        // Get a pointer to the input token recipient data.
        InputTokenRecipientData storage inputTokenRecipientData = getRequestInputTokenRecipientData[execHash];

        // Ensure input tokens for this request are ready to be sent to a recipient.
        require(inputTokenRecipientData.recipient != address(0), "NO_RECIPIENT");

        // Ensure that the tokens have not already been claimed.
        require(!inputTokenRecipientData.isClaimed, "ALREADY_CLAIMED");

        // Mark the input tokens as claimed.
        inputTokenRecipientData.isClaimed = true;

        emit ClaimInputTokens(execHash);

        // Loop over each input token to transfer it to the recipient.
        InputToken[] memory inputTokens = requestInputTokens[execHash];
        for (uint256 i = 0; i < inputTokens.length; i++) {
            inputTokens[i].l2Token.safeTransfer(inputTokenRecipientData.recipient, inputTokens[i].amount);
        }
    }

    
    /// anyone can call withdrawTokens on behalf of the creator to refund their tokens.
    
    
    
    
    function unlockTokens(bytes32 execHash, uint256 unlockDelaySeconds) public requiresAuth {
        // Ensure the request currently has tokens.
        (bool requestHasTokens, ) = hasTokens(execHash);
        require(requestHasTokens, "REQUEST_HAS_NO_TOKENS");

        // Ensure an unlock is not already scheduled.
        require(getRequestUnlockTimestamp[execHash] == 0, "UNLOCK_ALREADY_SCHEDULED");

        // Ensure the caller is the creator of the request.
        require(getRequestCreator[execHash] == msg.sender, "NOT_CREATOR");

        // Ensure the delay is greater than the minimum.
        require(unlockDelaySeconds >= MIN_UNLOCK_DELAY_SECONDS, "DELAY_TOO_SMALL");

        // Set the unlock timestamp to block.timestamp + unlockDelaySeconds.
        uint256 unlockTimestamp = block.timestamp.add(unlockDelaySeconds);
        getRequestUnlockTimestamp[execHash] = unlockTimestamp;

        emit UnlockTokens(execHash, unlockTimestamp);
    }

    
    /// to call unlockTokens again if they wish to unlock the request's tokens another time.
    
    
    function relockTokens(bytes32 execHash) external requiresAuth {
        // Ensure the request currently has tokens.
        (bool requestHasTokens, ) = hasTokens(execHash);
        require(requestHasTokens, "REQUEST_HAS_NO_TOKENS");

        // Ensure that the request has had its tokens unlocked.
        (bool tokensUnlocked, ) = areTokensUnlocked(execHash);
        require(tokensUnlocked, "NOT_UNLOCKED");

        // Ensure the caller is the creator of the request.
        require(getRequestCreator[execHash] == msg.sender, "NOT_CREATOR");

        // Reset the unlock timestamp to 0.
        delete getRequestUnlockTimestamp[execHash];

        emit RelockTokens(execHash);
    }

    
    
    /// wait the unlockDelaySeconds they specified before tokens may be withdrawn from their request.
    
    
    function withdrawTokens(bytes32 execHash) external requiresAuth {
        // Ensure that the tokens are unlocked.
        (bool tokensUnlocked, ) = areTokensUnlocked(execHash);
        require(tokensUnlocked, "NOT_UNLOCKED");

        // Ensure that the tokens have not already been removed.
        (bool requestHasTokens, ) = hasTokens(execHash);
        require(requestHasTokens, "REQUEST_HAS_NO_TOKENS");

        // Get the request creator.
        address creator = getRequestCreator[execHash];

        // Store that the request has had its input tokens withdrawn.
        // isClaimed is set to true so the creator cannot call claimInputTokens to claim their tokens twice!
        getRequestInputTokenRecipientData[execHash] = InputTokenRecipientData({recipient: creator, isClaimed: true});

        emit WithdrawTokens(execHash);

        // Transfer the ETH which would have been used for (gas + tip) back to the creator.
        creator.safeTransferETH(getRequestGasPrice[execHash].mul(getRequestGasLimit[execHash]).add(getRequestTip[execHash]));

        // Transfer input tokens back to the creator.
        InputToken[] memory inputTokens = requestInputTokens[execHash];
        for (uint256 i = 0; i < inputTokens.length; i++) {
            inputTokens[i].l2Token.safeTransfer(creator, inputTokens[i].amount);
        }
    }

    
    
    
    
    
    
    function speedUpRequest(bytes32 execHash, uint256 gasPrice) external payable requiresAuth returns (bytes32 newExecHash) {
        // Ensure the request currently has tokens.
        (bool requestHasTokens, ) = hasTokens(execHash);
        require(requestHasTokens, "REQUEST_HAS_NO_TOKENS");

        // Ensure that the caller is the creator of the request.
        require(getRequestCreator[execHash] == msg.sender, "NOT_CREATOR");

        // Ensure the request has not already been sped up.
        require(getRequestDeathTimestamp[execHash] == 0, "ALREADY_SPED_UP");

        // Get the previous gas price.
        uint256 previousGasPrice = getRequestGasPrice[execHash];

        // Ensure that the new gas price is greater than the previous.
        require(gasPrice > previousGasPrice, "GAS_PRICE_MUST_BE_HIGHER");

        // Compute the timestamp when the request would become uncled.
        uint256 switchTimestamp = MIN_UNLOCK_DELAY_SECONDS.add(block.timestamp);

        // Ensure that if there is a token unlock scheduled it would be after the switch.
        // Tokens cannot be withdrawn after the switch, which is why it's safe if they unlock after.
        uint256 tokenUnlockTimestamp = getRequestUnlockTimestamp[execHash];
        require(tokenUnlockTimestamp == 0 || tokenUnlockTimestamp > switchTimestamp, "UNLOCK_BEFORE_SWITCH");

        // Get more data about the previous request.
        address previousStrategy = getRequestStrategy[execHash];
        bytes memory previousCalldata = getRequestCalldata[execHash];
        uint256 previousGasLimit = getRequestGasLimit[execHash];

        // Ensure enough ETH was sent along with the call to cover the increased gas price.
        require(msg.value == gasPrice.sub(previousGasPrice).mul(previousGasLimit), "BAD_ETH_VALUE");

        // Generate a new execHash for the resubmitted request.
        systemNonce += 1;
        newExecHash = NovaExecHashLib.compute({
            nonce: systemNonce,
            strategy: previousStrategy,
            l1Calldata: previousCalldata,
            gasLimit: previousGasLimit,
            gasPrice: gasPrice
        });

        // Fill out data for the resubmitted request.
        getRequestCreator[newExecHash] = msg.sender;
        getRequestStrategy[newExecHash] = previousStrategy;
        getRequestCalldata[newExecHash] = previousCalldata;
        getRequestGasLimit[newExecHash] = previousGasLimit;
        getRequestGasPrice[newExecHash] = gasPrice;
        getRequestTip[newExecHash] = getRequestTip[execHash];
        getRequestNonce[execHash] = systemNonce;

        // Map the resubmitted request to its uncle.
        getRequestUncle[newExecHash] = execHash;
        getResubmittedRequest[execHash] = newExecHash;

        // Set the uncled request to die in MIN_UNLOCK_DELAY_SECONDS.
        getRequestDeathTimestamp[execHash] = switchTimestamp;

        emit SpeedUpRequest(execHash, newExecHash, systemNonce, switchTimestamp);
    }

    /*///////////////////////////////////////////////////////////////
                  CROSS DOMAIN MESSENGER ONLY FUNCTION
    //////////////////////////////////////////////////////////////*/

    
    
    
    
    
    
    function execCompleted(
        bytes32 execHash,
        address rewardRecipient,
        bool reverted,
        uint256 gasUsed
    ) external onlyFromCrossDomainAccount(L1_NovaExecutionManagerAddress) {
        // Ensure the request still has tokens.
        (bool requestHasTokens, ) = hasTokens(execHash);
        require(requestHasTokens, "REQUEST_HAS_NO_TOKENS");

        // We cannot allow providing address(0) for rewardRecipient, as we
        // use address(0) to indicate a request has not its tokens removed.
        require(rewardRecipient != address(0), "INVALID_RECIPIENT");

        // Get relevant request data.
        uint256 tip = getRequestTip[execHash];
        uint256 gasLimit = getRequestGasLimit[execHash];
        uint256 gasPrice = getRequestGasPrice[execHash];
        address requestCreator = getRequestCreator[execHash];
        bytes32 resubmittedRequest = getResubmittedRequest[execHash];

        // The amount of ETH to pay for the gas consumed, capped at the gas limit.
        uint256 gasPayment = gasPrice.mul(gasUsed > gasLimit ? gasLimit : gasUsed);

        // Give the proper input token recipient the ability to claim the tokens.
        // isClaimed is implicitly kept as false, so the recipient can claim the tokens with claimInputTokens.
        getRequestInputTokenRecipientData[execHash].recipient = reverted ? requestCreator : rewardRecipient;

        emit ExecCompleted(execHash, rewardRecipient, reverted, gasUsed);

        // Pay the reward recipient for gas consumed and the tip if execution did not revert.
        rewardRecipient.safeTransferETH(gasPayment.add(reverted ? 0 : tip));

        // Refund any unused gas, the tip if execution reverted, and extra ETH from the resubmitted request if necessary.
        requestCreator.safeTransferETH(
            gasLimit.mul(gasPrice).sub(gasPayment).add(reverted ? tip : 0).add(
                // Refund the ETH attached to the request's resubmitted copy if necessary.
                // The hasTokens call above ensures that this request isn't a dead uncle.
                resubmittedRequest != bytes32(0) ? getRequestGasPrice[resubmittedRequest].sub(gasPrice).mul(gasLimit) : 0
            )
        );
    }

    /*///////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    
    
    
    
    
    /// Will be 0 if there is no removal/addition expected.
    /// Will also be 0 if the request has had its tokens withdrawn or was executed.
    /// Will be a timestamp if the request will have its tokens added soon (it's a resubmitted copy of an uncled request)
    /// or if the request will have its tokens removed soon (it's an uncled request scheduled to die soon).
    function hasTokens(bytes32 execHash) public view returns (bool requestHasTokens, uint256 changeTimestamp) {
        if (getRequestInputTokenRecipientData[execHash].recipient != address(0)) {
            // The request has been executed or had its tokens withdrawn,
            // so we know its tokens are removed and won't be added back.
            return (false, 0);
        }

        uint256 deathTimestamp = getRequestDeathTimestamp[execHash];
        if (deathTimestamp != 0) {
            if (block.timestamp >= deathTimestamp) {
                // This request is an uncle which has died, meaning its
                // tokens have been removed and sent to a resubmitted request.
                return (false, 0);
            } else {
                // This request is an uncle which has not died yet, so we know
                // it has tokens that will be removed on its deathTimestamp.
                return (true, deathTimestamp);
            }
        }

        bytes32 uncleExecHash = getRequestUncle[execHash];
        if (uncleExecHash == bytes32(0)) {
            if (getRequestCreator[execHash] == address(0)) {
                // The request passed all the previous removal checks but
                // doesn't actually exist, so we know it does not have tokens.
                return (false, 0);
            } else {
                // This request does not have an uncle and has passed all
                // the previous removal checks, so we know it has tokens.
                return (true, 0);
            }
        }

        if (getRequestInputTokenRecipientData[uncleExecHash].recipient != address(0)) {
            // This request is a resubmitted version of its uncle
            // which was executed before it could "die" and switch its
            // tokens to this request, so we know it does not have tokens.
            return (false, 0);
        }

        uint256 uncleDeathTimestamp = getRequestDeathTimestamp[uncleExecHash];
        if (uncleDeathTimestamp > block.timestamp) {
            // This request is a resubmitted version of its uncle
            // which has not "died" yet, so we know it does not have its
            // tokens yet, but will receive them after the uncleDeathTimestamp.
            return (false, uncleDeathTimestamp);
        }

        // This is a resubmitted request with an uncle that died properly
        // without being executed early, so we know it has its tokens.
        return (true, 0);
    }

    
    
    
    
    /// Will be 0 if there is no unlock scheduled or the request has already completed an unlock.
    /// It will be a timestamp if an unlock has been scheduled but not completed.
    function areTokensUnlocked(bytes32 execHash) public view returns (bool unlocked, uint256 changeTimestamp) {
        uint256 tokenUnlockTimestamp = getRequestUnlockTimestamp[execHash];

        if (tokenUnlockTimestamp == 0) {
            // There is no unlock scheduled.
            unlocked = false;
            changeTimestamp = 0;
        } else {
            // There has been an unlock scheduled/completed.
            unlocked = block.timestamp >= tokenUnlockTimestamp;
            changeTimestamp = unlocked ? 0 : tokenUnlockTimestamp;
        }
    }
}

// 
pragma solidity 0.7.6;





contract L1_NovaApprovalEscrow {
    
    
    address public immutable ESCROW_ADMIN = msg.sender;

    
    
    
    
    
    
    
    function transferApprovedToken(
        address token,
        uint256 amount,
        address sender,
        address recipient
    ) external returns (bool) {
        // Ensure the caller is the escrow admin.
        require(ESCROW_ADMIN == msg.sender, "UNAUTHORIZED");

        // Transfer tokens from the sender to the recipient.
        (bool success, bytes memory returnData) = address(token).call(
            abi.encodeWithSelector(
                // The token to transfer:
                IERC20(token).transferFrom.selector,
                // The address who approved tokens to the escrow:
                sender,
                // The address who should receive the tokens:
                recipient,
                // The amount of tokens to transfer to the recipient:
                amount
            )
        );

        if (!success) {
            // If it reverted, return false
            // to indicate the transfer failed.
            return false;
        }

        if (returnData.length > 0) {
            // An abi-encoded bool takes up 32 bytes.
            if (returnData.length == 32) {
                // Return false to indicate failure if
                // the return data was not a positive bool.
                return abi.decode(returnData, (bool));
            } else {
                // It returned some data that was not a bool,
                // return false to indicate the transfer failed.
                return false;
            }
        }

        // If there was no failure,
        // return true to indicate success.
        return true;
    }
}

// 
pragma solidity >0.5.0 <0.8.0;


/**
 * @title iOVM_CrossDomainMessenger
 */
interface iOVM_CrossDomainMessenger {

    /**********
     * Events *
     **********/

    event SentMessage(bytes message);
    event RelayedMessage(bytes32 msgHash);
    event FailedRelayedMessage(bytes32 msgHash);


    /*************
     * Variables *
     *************/

    function xDomainMessageSender() external view returns (address);


    /********************
     * Public Functions *
     ********************/

    /**
     * Sends a cross domain message to the target messenger.
     * @param _target Target contract address.
     * @param _message Message to send to the target.
     * @param _gasLimit Gas limit for the provided message.
     */
    function sendMessage(
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external;
}

// 

pragma solidity >=0.6.0 <0.8.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
pragma solidity 0.7.6;



library SafeTransferLib {
    
    
    
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "ETH_TRANSFER_FAILED");
    }
}

// 

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
