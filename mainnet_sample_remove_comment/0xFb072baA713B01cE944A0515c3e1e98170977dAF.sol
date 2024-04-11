 

 

pragma solidity ^0.5.17;


 
 
library Uint256Helpers {
    uint256 private constant MAX_UINT8 = uint8(-1);
    uint256 private constant MAX_UINT64 = uint64(-1);

    string private constant ERROR_UINT8_NUMBER_TOO_BIG = "UINT8_NUMBER_TOO_BIG";
    string private constant ERROR_UINT64_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";

    function toUint8(uint256 a) internal pure returns (uint8) {
        require(a <= MAX_UINT8, ERROR_UINT8_NUMBER_TOO_BIG);
        return uint8(a);
    }

    function toUint64(uint256 a) internal pure returns (uint64) {
        require(a <= MAX_UINT64, ERROR_UINT64_NUMBER_TOO_BIG);
        return uint64(a);
    }
}

 
 
contract IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _who) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

 
interface IArbitrator {
     
    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external returns (uint256);

     
    function submitEvidence(uint256 _disputeId, address _submitter, bytes calldata _evidence) external;

     
    function closeEvidencePeriod(uint256 _disputeId) external;

     
    function rule(uint256 _disputeId) external returns (address subject, uint256 ruling);

     
    function getDisputeFees() external view returns (address recipient, IERC20 feeToken, uint256 feeAmount);

     
    function getPaymentsRecipient() external view returns (address);
}

 
 
contract IArbitrable {
     
    event Ruled(IArbitrator indexed arbitrator, uint256 indexed disputeId, uint256 ruling);
}

 
 
contract IsContract {
     
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}

contract ACL {
    string private constant ERROR_BAD_FREEZE = "ACL_BAD_FREEZE";
    string private constant ERROR_ROLE_ALREADY_FROZEN = "ACL_ROLE_ALREADY_FROZEN";
    string private constant ERROR_INVALID_BULK_INPUT = "ACL_INVALID_BULK_INPUT";

    enum BulkOp { Grant, Revoke, Freeze }

    address internal constant FREEZE_FLAG = address(1);
    address internal constant ANY_ADDR = address(-1);

     
    mapping (bytes32 => mapping (address => bool)) public roles;

    event Granted(bytes32 indexed id, address indexed who);
    event Revoked(bytes32 indexed id, address indexed who);
    event Frozen(bytes32 indexed id);

     
    function hasRole(address _who, bytes32 _id) public view returns (bool) {
        return roles[_id][_who] || roles[_id][ANY_ADDR];
    }

     
    function isRoleFrozen(bytes32 _id) public view returns (bool) {
        return roles[_id][FREEZE_FLAG];
    }

     
    function _grant(bytes32 _id, address _who) internal {
        require(!isRoleFrozen(_id), ERROR_ROLE_ALREADY_FROZEN);
        require(_who != FREEZE_FLAG, ERROR_BAD_FREEZE);

        if (!hasRole(_who, _id)) {
            roles[_id][_who] = true;
            emit Granted(_id, _who);
        }
    }

     
    function _revoke(bytes32 _id, address _who) internal {
        require(!isRoleFrozen(_id), ERROR_ROLE_ALREADY_FROZEN);

        if (hasRole(_who, _id)) {
            roles[_id][_who] = false;
            emit Revoked(_id, _who);
        }
    }

     
    function _freeze(bytes32 _id) internal {
        require(!isRoleFrozen(_id), ERROR_ROLE_ALREADY_FROZEN);
        roles[_id][FREEZE_FLAG] = true;
        emit Frozen(_id);
    }

     
    function _bulk(BulkOp[] memory _op, bytes32[] memory _id, address[] memory _who) internal {
        require(_op.length == _id.length && _op.length == _who.length, ERROR_INVALID_BULK_INPUT);

        for (uint256 i = 0; i < _op.length; i++) {
            BulkOp op = _op[i];
            if (op == BulkOp.Grant) {
                _grant(_id[i], _who[i]);
            } else if (op == BulkOp.Revoke) {
                _revoke(_id[i], _who[i]);
            } else if (op == BulkOp.Freeze) {
                _freeze(_id[i]);
            }
        }
    }
}

contract ModuleIds {
     
    bytes32 internal constant MODULE_ID_DISPUTE_MANAGER = 0x14a6c70f0f6d449c014c7bbc9e68e31e79e8474fb03b7194df83109a2d888ae6;

     
    bytes32 internal constant MODULE_ID_GUARDIANS_REGISTRY = 0x8af7b7118de65da3b974a3fd4b0c702b66442f74b9dff6eaed1037254c0b79fe;

     
    bytes32 internal constant MODULE_ID_VOTING = 0x7cbb12e82a6d63ff16fe43977f43e3e2b247ecd4e62c0e340da8800a48c67346;

     
    bytes32 internal constant MODULE_ID_PAYMENTS_BOOK = 0xfa275b1417437a2a2ea8e91e9fe73c28eaf0a28532a250541da5ac0d1892b418;

     
    bytes32 internal constant MODULE_ID_TREASURY = 0x06aa03964db1f7257357ef09714a5f0ca3633723df419e97015e0c7a3e83edb7;
}

interface IModulesLinker {
     
    function linkModules(bytes32[] calldata _ids, address[] calldata _addresses) external;
}

 
 
 
library SafeMath64 {
    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";

     
    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {
        uint256 c = uint256(_a) * uint256(_b);
        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW);  

        return uint64(c);
    }

     
    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {
        require(_b > 0, ERROR_DIV_ZERO);  
        uint64 c = _a / _b;
         

        return c;
    }

     
    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint64 c = _a - _b;

        return c;
    }

     
    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {
        uint64 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

     
    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}

 
 
contract TimeHelpers {
    using Uint256Helpers for uint256;

     
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

     
    function getBlockNumber64() internal view returns (uint64) {
        return getBlockNumber().toUint64();
    }

     
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp;  
    }

     
    function getTimestamp64() internal view returns (uint64) {
        return getTimestamp().toUint64();
    }
}

interface IClock {
     
    function ensureCurrentTerm() external returns (uint64);

     
    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64);

     
    function ensureCurrentTermRandomness() external returns (bytes32);

     
    function getLastEnsuredTermId() external view returns (uint64);

     
    function getCurrentTermId() external view returns (uint64);

     
    function getNeededTermTransitions() external view returns (uint64);

     
    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness);

     
    function getTermRandomness(uint64 _termId) external view returns (bytes32);
}

contract CourtClock is IClock, TimeHelpers {
    using SafeMath64 for uint64;

    string private constant ERROR_TERM_DOES_NOT_EXIST = "CLK_TERM_DOES_NOT_EXIST";
    string private constant ERROR_TERM_DURATION_TOO_LONG = "CLK_TERM_DURATION_TOO_LONG";
    string private constant ERROR_TERM_RANDOMNESS_NOT_YET = "CLK_TERM_RANDOMNESS_NOT_YET";
    string private constant ERROR_TERM_RANDOMNESS_UNAVAILABLE = "CLK_TERM_RANDOMNESS_UNAVAILABLE";
    string private constant ERROR_BAD_FIRST_TERM_START_TIME = "CLK_BAD_FIRST_TERM_START_TIME";
    string private constant ERROR_TOO_MANY_TRANSITIONS = "CLK_TOO_MANY_TRANSITIONS";
    string private constant ERROR_INVALID_TRANSITION_TERMS = "CLK_INVALID_TRANSITION_TERMS";
    string private constant ERROR_CANNOT_DELAY_STARTED_COURT = "CLK_CANNOT_DELAY_STARTED_PROT";
    string private constant ERROR_CANNOT_DELAY_PAST_START_TIME = "CLK_CANNOT_DELAY_PAST_START_TIME";

     
    uint64 internal constant MAX_AUTO_TERM_TRANSITIONS_ALLOWED = 1;

     
    uint64 internal constant MAX_TERM_DURATION = 365 days;

     
    uint64 internal constant MAX_FIRST_TERM_DELAY_PERIOD = 2 * MAX_TERM_DURATION;

    struct Term {
        uint64 startTime;               
        uint64 randomnessBN;            
        bytes32 randomness;             
    }

     
    uint64 private termDuration;

     
    uint64 private termId;

     
    mapping (uint64 => Term) private terms;

    event Heartbeat(uint64 previousTermId, uint64 currentTermId);
    event StartTimeDelayed(uint64 previousStartTime, uint64 currentStartTime);

     
    modifier termExists(uint64 _termId) {
        require(_termId <= termId, ERROR_TERM_DOES_NOT_EXIST);
        _;
    }

     
    constructor(uint64[2] memory _termParams) public {
        uint64 _termDuration = _termParams[0];
        uint64 _firstTermStartTime = _termParams[1];

        require(_termDuration < MAX_TERM_DURATION, ERROR_TERM_DURATION_TOO_LONG);
        require(_firstTermStartTime >= getTimestamp64() + _termDuration, ERROR_BAD_FIRST_TERM_START_TIME);
        require(_firstTermStartTime <= getTimestamp64() + MAX_FIRST_TERM_DELAY_PERIOD, ERROR_BAD_FIRST_TERM_START_TIME);

        termDuration = _termDuration;

         
        terms[0].startTime = _firstTermStartTime - _termDuration;
    }

     
    function ensureCurrentTerm() external returns (uint64) {
        return _ensureCurrentTerm();
    }

     
    function heartbeat(uint64 _maxRequestedTransitions) external returns (uint64) {
        return _heartbeat(_maxRequestedTransitions);
    }

     
    function ensureCurrentTermRandomness() external returns (bytes32) {
         
        uint64 currentTermId = termId;
        Term storage term = terms[currentTermId];
        bytes32 termRandomness = term.randomness;
        if (termRandomness != bytes32(0)) {
            return termRandomness;
        }

         
        bytes32 newRandomness = _computeTermRandomness(currentTermId);
        require(newRandomness != bytes32(0), ERROR_TERM_RANDOMNESS_UNAVAILABLE);
        term.randomness = newRandomness;
        return newRandomness;
    }

     
    function getTermDuration() external view returns (uint64) {
        return termDuration;
    }

     
    function getLastEnsuredTermId() external view returns (uint64) {
        return _lastEnsuredTermId();
    }

     
    function getCurrentTermId() external view returns (uint64) {
        return _currentTermId();
    }

     
    function getNeededTermTransitions() external view returns (uint64) {
        return _neededTermTransitions();
    }

     
    function getTerm(uint64 _termId) external view returns (uint64 startTime, uint64 randomnessBN, bytes32 randomness) {
        Term storage term = terms[_termId];
        return (term.startTime, term.randomnessBN, term.randomness);
    }

     
    function getTermRandomness(uint64 _termId) external view termExists(_termId) returns (bytes32) {
        return _computeTermRandomness(_termId);
    }

     
    function _ensureCurrentTerm() internal returns (uint64) {
         
        uint64 requiredTransitions = _neededTermTransitions();
        require(requiredTransitions <= MAX_AUTO_TERM_TRANSITIONS_ALLOWED, ERROR_TOO_MANY_TRANSITIONS);

         
        if (uint256(requiredTransitions) == 0) {
            return termId;
        }

         
        return _heartbeat(requiredTransitions);
    }

     
    function _heartbeat(uint64 _maxRequestedTransitions) internal returns (uint64) {
         
        uint64 neededTransitions = _neededTermTransitions();
        uint256 transitions = uint256(_maxRequestedTransitions < neededTransitions ? _maxRequestedTransitions : neededTransitions);
        require(transitions > 0, ERROR_INVALID_TRANSITION_TERMS);

        uint64 blockNumber = getBlockNumber64();
        uint64 previousTermId = termId;
        uint64 currentTermId = previousTermId;
        for (uint256 transition = 1; transition <= transitions; transition++) {
             
             
             
            Term storage previousTerm = terms[currentTermId++];
            Term storage currentTerm = terms[currentTermId];
            _onTermTransitioned(currentTermId);

             
             
            currentTerm.startTime = previousTerm.startTime.add(termDuration);

             
             
            currentTerm.randomnessBN = blockNumber + 1;
        }

        termId = currentTermId;
        emit Heartbeat(previousTermId, currentTermId);
        return currentTermId;
    }

     
    function _delayStartTime(uint64 _newFirstTermStartTime) internal {
        require(_currentTermId() == 0, ERROR_CANNOT_DELAY_STARTED_COURT);

        Term storage term = terms[0];
        uint64 currentFirstTermStartTime = term.startTime.add(termDuration);
        require(_newFirstTermStartTime > currentFirstTermStartTime, ERROR_CANNOT_DELAY_PAST_START_TIME);

         
        term.startTime = _newFirstTermStartTime - termDuration;
        emit StartTimeDelayed(currentFirstTermStartTime, _newFirstTermStartTime);
    }

     
    function _onTermTransitioned(uint64 _termId) internal;

     
    function _lastEnsuredTermId() internal view returns (uint64) {
        return termId;
    }

     
    function _currentTermId() internal view returns (uint64) {
        return termId.add(_neededTermTransitions());
    }

     
    function _neededTermTransitions() internal view returns (uint64) {
         
         
        uint64 currentTermStartTime = terms[termId].startTime;
        if (getTimestamp64() < currentTermStartTime) {
            return uint64(0);
        }

         
        return (getTimestamp64() - currentTermStartTime) / termDuration;
    }

     
    function _computeTermRandomness(uint64 _termId) internal view returns (bytes32) {
        Term storage term = terms[_termId];
        require(getBlockNumber64() > term.randomnessBN, ERROR_TERM_RANDOMNESS_NOT_YET);
        return blockhash(term.randomnessBN);
    }
}

 
 
 
library SafeMath {
    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

     
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
         
         
         
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

     
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, ERROR_DIV_ZERO);  
        uint256 c = _a / _b;
         

        return c;
    }

     
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

     
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}

library PctHelpers {
    using SafeMath for uint256;

    uint256 internal constant PCT_BASE = 10000;  

    function isValid(uint16 _pct) internal pure returns (bool) {
        return _pct <= PCT_BASE;
    }

    function pct(uint256 self, uint16 _pct) internal pure returns (uint256) {
        return self.mul(uint256(_pct)) / PCT_BASE;
    }

    function pct256(uint256 self, uint256 _pct) internal pure returns (uint256) {
        return self.mul(_pct) / PCT_BASE;
    }

    function pctIncrease(uint256 self, uint16 _pct) internal pure returns (uint256) {
         
        return self.mul(PCT_BASE + uint256(_pct)) / PCT_BASE;
    }
}

interface IConfig {

     
    function getConfig(uint64 _termId) external view
        returns (
            IERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        );

     
    function getDraftConfig(uint64 _termId) external view returns (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct);

     
    function getMinActiveBalance(uint64 _termId) external view returns (uint256);
}

contract CourtConfigData {
    struct Config {
        FeesConfig fees;                         
        DisputesConfig disputes;                 
        uint256 minActiveBalance;                
    }

    struct FeesConfig {
        IERC20 token;                            
        uint16 finalRoundReduction;              
        uint256 guardianFee;                     
        uint256 draftFee;                        
        uint256 settleFee;                       
    }

    struct DisputesConfig {
        uint64 evidenceTerms;                    
        uint64 commitTerms;                      
        uint64 revealTerms;                      
        uint64 appealTerms;                      
        uint64 appealConfirmTerms;               
        uint16 penaltyPct;                       
        uint64 firstRoundGuardiansNumber;        
        uint64 appealStepFactor;                 
        uint64 finalRoundLockTerms;              
        uint256 maxRegularAppealRounds;          
        uint256 appealCollateralFactor;          
        uint256 appealConfirmCollateralFactor;   
    }

    struct DraftConfig {
        IERC20 feeToken;                          
        uint16 penaltyPct;                       
        uint256 draftFee;                        
    }
}

contract CourtConfig is IConfig, CourtConfigData {
    using SafeMath64 for uint64;
    using PctHelpers for uint256;

    string private constant ERROR_TOO_OLD_TERM = "CONF_TOO_OLD_TERM";
    string private constant ERROR_INVALID_PENALTY_PCT = "CONF_INVALID_PENALTY_PCT";
    string private constant ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT = "CONF_INVALID_FINAL_ROUND_RED_PCT";
    string private constant ERROR_INVALID_MAX_APPEAL_ROUNDS = "CONF_INVALID_MAX_APPEAL_ROUNDS";
    string private constant ERROR_LARGE_ROUND_PHASE_DURATION = "CONF_LARGE_ROUND_PHASE_DURATION";
    string private constant ERROR_BAD_INITIAL_GUARDIANS_NUMBER = "CONF_BAD_INITIAL_GUARDIAN_NUMBER";
    string private constant ERROR_BAD_APPEAL_STEP_FACTOR = "CONF_BAD_APPEAL_STEP_FACTOR";
    string private constant ERROR_ZERO_COLLATERAL_FACTOR = "CONF_ZERO_COLLATERAL_FACTOR";
    string private constant ERROR_ZERO_MIN_ACTIVE_BALANCE = "CONF_ZERO_MIN_ACTIVE_BALANCE";

     
    uint64 internal constant MAX_ADJ_STATE_DURATION = 8670;

     
    uint256 internal constant MAX_REGULAR_APPEAL_ROUNDS_LIMIT = 10;

     
    uint64 private configChangeTermId;

     
    Config[] private configs;

     
    mapping (uint64 => uint256) private configIdByTerm;

    event NewConfig(uint64 fromTermId, uint64 courtConfigId);

     
    constructor(
        IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
    {
         
        configs.length = 1;
        _setConfig(
            0,
            0,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

     
    function getConfig(uint64 _termId) external view
        returns (
            IERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        );

     
    function getDraftConfig(uint64 _termId) external view returns (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct);

     
    function getMinActiveBalance(uint64 _termId) external view returns (uint256);

     
    function getConfigChangeTermId() external view returns (uint64) {
        return configChangeTermId;
    }

     
    function _ensureTermConfig(uint64 _termId) internal {
         
        uint256 currentConfigId = configIdByTerm[_termId];
        if (currentConfigId == 0) {
            uint256 previousConfigId = configIdByTerm[_termId.sub(1)];
            configIdByTerm[_termId] = previousConfigId;
        }
    }

     
    function _setConfig(
        uint64 _termId,
        uint64 _fromTermId,
        IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        internal
    {
         
         
        require(_termId == 0 || _fromTermId > _termId, ERROR_TOO_OLD_TERM);

         
        require(_appealCollateralParams[0] > 0 && _appealCollateralParams[1] > 0, ERROR_ZERO_COLLATERAL_FACTOR);

         
        require(PctHelpers.isValid(_pcts[0]), ERROR_INVALID_PENALTY_PCT);
        require(PctHelpers.isValid(_pcts[1]), ERROR_INVALID_FINAL_ROUND_REDUCTION_PCT);

         
        require(_roundParams[0] > 0, ERROR_BAD_INITIAL_GUARDIANS_NUMBER);

         
        require(_roundParams[1] > 0, ERROR_BAD_APPEAL_STEP_FACTOR);

         
        uint256 _maxRegularAppealRounds = _roundParams[2];
        bool isMaxAppealRoundsValid = _maxRegularAppealRounds > 0 && _maxRegularAppealRounds <= MAX_REGULAR_APPEAL_ROUNDS_LIMIT;
        require(isMaxAppealRoundsValid, ERROR_INVALID_MAX_APPEAL_ROUNDS);

         
        for (uint i = 0; i < _roundStateDurations.length; i++) {
            require(_roundStateDurations[i] > 0 && _roundStateDurations[i] < MAX_ADJ_STATE_DURATION, ERROR_LARGE_ROUND_PHASE_DURATION);
        }

         
        require(_minActiveBalance > 0, ERROR_ZERO_MIN_ACTIVE_BALANCE);

         
         
        if (configChangeTermId > _termId) {
            configIdByTerm[configChangeTermId] = 0;
        } else {
            configs.length++;
        }

        uint64 courtConfigId = uint64(configs.length - 1);
        Config storage config = configs[courtConfigId];

        config.fees = FeesConfig({
            token: _feeToken,
            guardianFee: _fees[0],
            draftFee: _fees[1],
            settleFee: _fees[2],
            finalRoundReduction: _pcts[1]
        });

        config.disputes = DisputesConfig({
            evidenceTerms: _roundStateDurations[0],
            commitTerms: _roundStateDurations[1],
            revealTerms: _roundStateDurations[2],
            appealTerms: _roundStateDurations[3],
            appealConfirmTerms: _roundStateDurations[4],
            penaltyPct: _pcts[0],
            firstRoundGuardiansNumber: _roundParams[0],
            appealStepFactor: _roundParams[1],
            maxRegularAppealRounds: _maxRegularAppealRounds,
            finalRoundLockTerms: _roundParams[3],
            appealCollateralFactor: _appealCollateralParams[0],
            appealConfirmCollateralFactor: _appealCollateralParams[1]
        });

        config.minActiveBalance = _minActiveBalance;

        configIdByTerm[_fromTermId] = courtConfigId;
        configChangeTermId = _fromTermId;

        emit NewConfig(_fromTermId, courtConfigId);
    }

     
    function _getConfigAt(uint64 _termId, uint64 _lastEnsuredTermId) internal view
        returns (
            IERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {
        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);

        FeesConfig storage feesConfig = config.fees;
        feeToken = feesConfig.token;
        fees = [feesConfig.guardianFee, feesConfig.draftFee, feesConfig.settleFee];

        DisputesConfig storage disputesConfig = config.disputes;
        roundStateDurations = [
            disputesConfig.evidenceTerms,
            disputesConfig.commitTerms,
            disputesConfig.revealTerms,
            disputesConfig.appealTerms,
            disputesConfig.appealConfirmTerms
        ];
        pcts = [disputesConfig.penaltyPct, feesConfig.finalRoundReduction];
        roundParams = [
            disputesConfig.firstRoundGuardiansNumber,
            disputesConfig.appealStepFactor,
            uint64(disputesConfig.maxRegularAppealRounds),
            disputesConfig.finalRoundLockTerms
        ];
        appealCollateralParams = [disputesConfig.appealCollateralFactor, disputesConfig.appealConfirmCollateralFactor];

        minActiveBalance = config.minActiveBalance;
    }

     
    function _getDraftConfig(uint64 _termId,  uint64 _lastEnsuredTermId) internal view
        returns (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct)
    {
        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return (config.fees.token, config.fees.draftFee, config.disputes.penaltyPct);
    }

     
    function _getMinActiveBalance(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {
        Config storage config = _getConfigFor(_termId, _lastEnsuredTermId);
        return config.minActiveBalance;
    }

     
    function _getConfigFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (Config storage) {
        uint256 id = _getConfigIdFor(_termId, _lastEnsuredTermId);
        return configs[id];
    }

     
    function _getConfigIdFor(uint64 _termId, uint64 _lastEnsuredTermId) internal view returns (uint256) {
         
        if (_termId <= _lastEnsuredTermId) {
            return configIdByTerm[_termId];
        }

         
        uint64 scheduledChangeTermId = configChangeTermId;
        if (scheduledChangeTermId <= _termId) {
            return configIdByTerm[scheduledChangeTermId];
        }

         
        return configIdByTerm[_lastEnsuredTermId];
    }
}

interface IDisputeManager {
    enum DisputeState {
        PreDraft,
        Adjudicating,
        Ruled
    }

    enum AdjudicationState {
        Invalid,
        Committing,
        Revealing,
        Appealing,
        ConfirmingAppeal,
        Ended
    }

     
    function createDispute(IArbitrable _subject, uint8 _possibleRulings, bytes calldata _metadata) external returns (uint256);

     
    function submitEvidence(IArbitrable _subject, uint256 _disputeId, address _submitter, bytes calldata _evidence) external;

     
    function closeEvidencePeriod(IArbitrable _subject, uint256 _disputeId) external;

     
    function draft(uint256 _disputeId) external;

     
    function createAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;

     
    function confirmAppeal(uint256 _disputeId, uint256 _roundId, uint8 _ruling) external;

     
    function computeRuling(uint256 _disputeId) external returns (IArbitrable subject, uint8 finalRuling);

     
    function settlePenalties(uint256 _disputeId, uint256 _roundId, uint256 _guardiansToSettle) external;

     
    function settleReward(uint256 _disputeId, uint256 _roundId, address _guardian) external;

     
    function settleAppealDeposit(uint256 _disputeId, uint256 _roundId) external;

     
    function getDisputeFees() external view returns (IERC20 feeToken, uint256 feeAmount);

     
    function getDispute(uint256 _disputeId) external view
        returns (IArbitrable subject, uint8 possibleRulings, DisputeState state, uint8 finalRuling, uint256 lastRoundId, uint64 createTermId);

     
    function getRound(uint256 _disputeId, uint256 _roundId) external view
        returns (
            uint64 draftTerm,
            uint64 delayedTerms,
            uint64 guardiansNumber,
            uint64 selectedGuardians,
            uint256 guardianFees,
            bool settledPenalties,
            uint256 collectedTokens,
            uint64 coherentGuardians,
            AdjudicationState state
        );

     
    function getAppeal(uint256 _disputeId, uint256 _roundId) external view
        returns (address maker, uint64 appealedRuling, address taker, uint64 opposedRuling);

     
    function getNextRoundDetails(uint256 _disputeId, uint256 _roundId) external view
        returns (
            uint64 nextRoundStartTerm,
            uint64 nextRoundGuardiansNumber,
            DisputeState newDisputeState,
            IERC20 feeToken,
            uint256 totalFees,
            uint256 guardianFees,
            uint256 appealDeposit,
            uint256 confirmAppealDeposit
        );

     
    function getGuardian(uint256 _disputeId, uint256 _roundId, address _guardian) external view returns (uint64 weight, bool rewarded);
}

contract Controller is IsContract, ModuleIds, CourtClock, CourtConfig, ACL {
    string private constant ERROR_SENDER_NOT_GOVERNOR = "CTR_SENDER_NOT_GOVERNOR";
    string private constant ERROR_INVALID_GOVERNOR_ADDRESS = "CTR_INVALID_GOVERNOR_ADDRESS";
    string private constant ERROR_MODULE_NOT_SET = "CTR_MODULE_NOT_SET";
    string private constant ERROR_MODULE_ALREADY_ENABLED = "CTR_MODULE_ALREADY_ENABLED";
    string private constant ERROR_MODULE_ALREADY_DISABLED = "CTR_MODULE_ALREADY_DISABLED";
    string private constant ERROR_DISPUTE_MANAGER_NOT_ACTIVE = "CTR_DISPUTE_MANAGER_NOT_ACTIVE";
    string private constant ERROR_CUSTOM_FUNCTION_NOT_SET = "CTR_CUSTOM_FUNCTION_NOT_SET";
    string private constant ERROR_IMPLEMENTATION_NOT_CONTRACT = "CTR_IMPLEMENTATION_NOT_CONTRACT";
    string private constant ERROR_INVALID_IMPLS_INPUT_LENGTH = "CTR_INVALID_IMPLS_INPUT_LENGTH";

    address private constant ZERO_ADDRESS = address(0);

     
    struct Governor {
        address funds;       
        address config;      
        address modules;     
    }

     
    struct Module {
        bytes32 id;          
        bool disabled;       
    }

     
    Governor private governor;

     
    mapping (bytes32 => address) internal currentModules;

     
    mapping (address => Module) internal allModules;

     
    mapping (bytes4 => address) internal customFunctions;

    event ModuleSet(bytes32 id, address addr);
    event ModuleEnabled(bytes32 id, address addr);
    event ModuleDisabled(bytes32 id, address addr);
    event CustomFunctionSet(bytes4 signature, address target);
    event FundsGovernorChanged(address previousGovernor, address currentGovernor);
    event ConfigGovernorChanged(address previousGovernor, address currentGovernor);
    event ModulesGovernorChanged(address previousGovernor, address currentGovernor);

     
    modifier onlyFundsGovernor {
        require(msg.sender == governor.funds, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

     
    modifier onlyConfigGovernor {
        require(msg.sender == governor.config, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

     
    modifier onlyModulesGovernor {
        require(msg.sender == governor.modules, ERROR_SENDER_NOT_GOVERNOR);
        _;
    }

     
    modifier onlyActiveDisputeManager(IDisputeManager _disputeManager) {
        require(!_isModuleDisabled(address(_disputeManager)), ERROR_DISPUTE_MANAGER_NOT_ACTIVE);
        _;
    }

     
    constructor(
        uint64[2] memory _termParams,
        address[3] memory _governors,
        IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
        CourtClock(_termParams)
        CourtConfig(_feeToken, _fees, _roundStateDurations, _pcts, _roundParams, _appealCollateralParams, _minActiveBalance)
    {
        _setFundsGovernor(_governors[0]);
        _setConfigGovernor(_governors[1]);
        _setModulesGovernor(_governors[2]);
    }

     
    function () external payable {
        address target = customFunctions[msg.sig];
        require(target != address(0), ERROR_CUSTOM_FUNCTION_NOT_SET);

         
        (bool success,) = address(target).call.value(msg.value)(msg.data);
        assembly {
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            let result := success
            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

     
    function setConfig(
        uint64 _fromTermId,
        IERC20 _feeToken,
        uint256[3] calldata _fees,
        uint64[5] calldata _roundStateDurations,
        uint16[2] calldata _pcts,
        uint64[4] calldata _roundParams,
        uint256[2] calldata _appealCollateralParams,
        uint256 _minActiveBalance
    )
        external
        onlyConfigGovernor
    {
        uint64 currentTermId = _ensureCurrentTerm();
        _setConfig(
            currentTermId,
            _fromTermId,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        );
    }

     
    function delayStartTime(uint64 _newFirstTermStartTime) external onlyConfigGovernor {
        _delayStartTime(_newFirstTermStartTime);
    }

     
    function changeFundsGovernor(address _newFundsGovernor) external onlyFundsGovernor {
        require(_newFundsGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setFundsGovernor(_newFundsGovernor);
    }

     
    function changeConfigGovernor(address _newConfigGovernor) external onlyConfigGovernor {
        require(_newConfigGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setConfigGovernor(_newConfigGovernor);
    }

     
    function changeModulesGovernor(address _newModulesGovernor) external onlyModulesGovernor {
        require(_newModulesGovernor != ZERO_ADDRESS, ERROR_INVALID_GOVERNOR_ADDRESS);
        _setModulesGovernor(_newModulesGovernor);
    }

     
    function ejectFundsGovernor() external onlyFundsGovernor {
        _setFundsGovernor(ZERO_ADDRESS);
    }

     
    function ejectModulesGovernor() external onlyModulesGovernor {
        _setModulesGovernor(ZERO_ADDRESS);
    }

     
    function grant(bytes32 _id, address _who) external onlyConfigGovernor {
        _grant(_id, _who);
    }

     
    function revoke(bytes32 _id, address _who) external onlyConfigGovernor {
        _revoke(_id, _who);
    }

     
    function freeze(bytes32 _id) external onlyConfigGovernor {
        _freeze(_id);
    }

     
    function bulk(BulkOp[] calldata _op, bytes32[] calldata _id, address[] calldata _who) external onlyConfigGovernor {
        _bulk(_op, _id, _who);
    }

     
    function setModule(bytes32 _id, address _addr) external onlyModulesGovernor {
        _setModule(_id, _addr);
    }

     
    function setModules(
        bytes32[] calldata _newModuleIds,
        address[] calldata _newModuleAddresses,
        bytes32[] calldata _newModuleLinks,
        address[] calldata _currentModulesToBeSynced
    )
        external
        onlyModulesGovernor
    {
         
        require(_newModuleIds.length == _newModuleAddresses.length, ERROR_INVALID_IMPLS_INPUT_LENGTH);

         
        for (uint256 i = 0; i < _newModuleIds.length; i++) {
            _setModule(_newModuleIds[i], _newModuleAddresses[i]);
        }

         
        _syncModuleLinks(_newModuleAddresses, _newModuleLinks);

         
        _syncModuleLinks(_currentModulesToBeSynced, _newModuleIds);
    }

     
    function syncModuleLinks(address[] calldata _modulesToBeSynced, bytes32[] calldata _idsToBeSet)
        external
        onlyModulesGovernor
    {
        require(_idsToBeSet.length > 0 && _modulesToBeSynced.length > 0, ERROR_INVALID_IMPLS_INPUT_LENGTH);
        _syncModuleLinks(_modulesToBeSynced, _idsToBeSet);
    }

     
    function disableModule(address _addr) external onlyModulesGovernor {
        Module storage module = allModules[_addr];
        _ensureModuleExists(module);
        require(!module.disabled, ERROR_MODULE_ALREADY_DISABLED);

        module.disabled = true;
        emit ModuleDisabled(module.id, _addr);
    }

     
    function enableModule(address _addr) external onlyModulesGovernor {
        Module storage module = allModules[_addr];
        _ensureModuleExists(module);
        require(module.disabled, ERROR_MODULE_ALREADY_ENABLED);

        module.disabled = false;
        emit ModuleEnabled(module.id, _addr);
    }

     
    function setCustomFunction(bytes4 _sig, address _target) external onlyModulesGovernor {
        customFunctions[_sig] = _target;
        emit CustomFunctionSet(_sig, _target);
    }

     
    function getConfig(uint64 _termId) external view
        returns (
            IERC20 feeToken,
            uint256[3] memory fees,
            uint64[5] memory roundStateDurations,
            uint16[2] memory pcts,
            uint64[4] memory roundParams,
            uint256[2] memory appealCollateralParams,
            uint256 minActiveBalance
        )
    {
        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getConfigAt(_termId, lastEnsuredTermId);
    }

     
    function getDraftConfig(uint64 _termId) external view returns (IERC20 feeToken, uint256 draftFee, uint16 penaltyPct) {
        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getDraftConfig(_termId, lastEnsuredTermId);
    }

     
    function getMinActiveBalance(uint64 _termId) external view returns (uint256) {
        uint64 lastEnsuredTermId = _lastEnsuredTermId();
        return _getMinActiveBalance(_termId, lastEnsuredTermId);
    }

     
    function getFundsGovernor() external view returns (address) {
        return governor.funds;
    }

     
    function getConfigGovernor() external view returns (address) {
        return governor.config;
    }

     
    function getModulesGovernor() external view returns (address) {
        return governor.modules;
    }

     
    function isActive(bytes32 _id, address _addr) external view returns (bool) {
        Module storage module = allModules[_addr];
        return module.id == _id && !module.disabled;
    }

     
    function getModuleByAddress(address _addr) external view returns (bytes32 id, bool disabled) {
        Module storage module = allModules[_addr];
        id = module.id;
        disabled = module.disabled;
    }

     
    function getModule(bytes32 _id) external view returns (address addr, bool disabled) {
        return _getModule(_id);
    }

     
    function getDisputeManager() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_DISPUTE_MANAGER);
    }

     
    function getGuardiansRegistry() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_GUARDIANS_REGISTRY);
    }

     
    function getVoting() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_VOTING);
    }

     
    function getPaymentsBook() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_PAYMENTS_BOOK);
    }

     
    function getTreasury() external view returns (address addr, bool disabled) {
        return _getModule(MODULE_ID_TREASURY);
    }

     
    function getCustomFunction(bytes4 _sig) external view returns (address) {
        return customFunctions[_sig];
    }

     
    function _setFundsGovernor(address _newFundsGovernor) internal {
        emit FundsGovernorChanged(governor.funds, _newFundsGovernor);
        governor.funds = _newFundsGovernor;
    }

     
    function _setConfigGovernor(address _newConfigGovernor) internal {
        emit ConfigGovernorChanged(governor.config, _newConfigGovernor);
        governor.config = _newConfigGovernor;
    }

     
    function _setModulesGovernor(address _newModulesGovernor) internal {
        emit ModulesGovernorChanged(governor.modules, _newModulesGovernor);
        governor.modules = _newModulesGovernor;
    }

     
    function _setModule(bytes32 _id, address _addr) internal {
        require(isContract(_addr), ERROR_IMPLEMENTATION_NOT_CONTRACT);

        currentModules[_id] = _addr;
        allModules[_addr].id = _id;
        emit ModuleSet(_id, _addr);
    }

     
    function _syncModuleLinks(address[] memory _modulesToBeSynced, bytes32[] memory _idsToBeSet) internal {
        address[] memory addressesToBeSet = new address[](_idsToBeSet.length);

         
        for (uint256 i = 0; i < _idsToBeSet.length; i++) {
            address moduleAddress = _getModuleAddress(_idsToBeSet[i]);
            Module storage module = allModules[moduleAddress];
            _ensureModuleExists(module);
            addressesToBeSet[i] = moduleAddress;
        }

         
        for (uint256 j = 0; j < _modulesToBeSynced.length; j++) {
            IModulesLinker(_modulesToBeSynced[j]).linkModules(_idsToBeSet, addressesToBeSet);
        }
    }

     
    function _onTermTransitioned(uint64 _termId) internal {
        _ensureTermConfig(_termId);
    }

     
    function _ensureModuleExists(Module storage _module) internal view {
        require(_module.id != bytes32(0), ERROR_MODULE_NOT_SET);
    }

     
    function _getModule(bytes32 _id) internal view returns (address addr, bool disabled) {
        addr = _getModuleAddress(_id);
        disabled = _isModuleDisabled(addr);
    }

     
    function _getModuleAddress(bytes32 _id) internal view returns (address) {
        return currentModules[_id];
    }

     
    function _isModuleDisabled(address _addr) internal view returns (bool) {
        return allModules[_addr].disabled;
    }
}

contract AragonCourt is IArbitrator, Controller {
    using Uint256Helpers for uint256;

     
    constructor(
        uint64[2] memory _termParams,
        address[3] memory _governors,
        IERC20 _feeToken,
        uint256[3] memory _fees,
        uint64[5] memory _roundStateDurations,
        uint16[2] memory _pcts,
        uint64[4] memory _roundParams,
        uint256[2] memory _appealCollateralParams,
        uint256 _minActiveBalance
    )
        public
        Controller(
            _termParams,
            _governors,
            _feeToken,
            _fees,
            _roundStateDurations,
            _pcts,
            _roundParams,
            _appealCollateralParams,
            _minActiveBalance
        )
    {
         
    }

     
    function createDispute(uint256 _possibleRulings, bytes calldata _metadata) external returns (uint256) {
        IArbitrable subject = IArbitrable(msg.sender);
        return _disputeManager().createDispute(subject, _possibleRulings.toUint8(), _metadata);
    }

     
    function submitEvidence(uint256 _disputeId, address _submitter, bytes calldata _evidence) external {
        _submitEvidence(_disputeManager(), _disputeId, _submitter, _evidence);
    }

     
    function submitEvidenceForModule(IDisputeManager _disputeManager, uint256 _disputeId, address _submitter, bytes calldata _evidence)
        external
        onlyActiveDisputeManager(_disputeManager)
    {
        _submitEvidence(_disputeManager, _disputeId, _submitter, _evidence);
    }

     
    function closeEvidencePeriod(uint256 _disputeId) external {
        _closeEvidencePeriod(_disputeManager(), _disputeId);
    }

     
    function closeEvidencePeriodForModule(IDisputeManager _disputeManager, uint256 _disputeId)
        external
        onlyActiveDisputeManager(_disputeManager)
    {
        _closeEvidencePeriod(_disputeManager, _disputeId);
    }

     
    function rule(uint256 _disputeId) external returns (address subject, uint256 ruling) {
        return _rule(_disputeManager(), _disputeId);
    }

     
    function ruleForModule(IDisputeManager _disputeManager, uint256 _disputeId)
        external
        onlyActiveDisputeManager(_disputeManager)
        returns (address subject, uint256 ruling)
    {
        return _rule(_disputeManager, _disputeId);
    }

     
    function getDisputeFees() external view returns (address recipient, IERC20 feeToken, uint256 feeAmount) {
        IDisputeManager disputeManager = _disputeManager();
        recipient = address(disputeManager);
        (feeToken, feeAmount) = disputeManager.getDisputeFees();
    }

     
    function getPaymentsRecipient() external view returns (address) {
        return currentModules[MODULE_ID_PAYMENTS_BOOK];
    }

     
    function _submitEvidence(IDisputeManager _disputeManager, uint256 _disputeId, address _submitter, bytes memory _evidence) internal {
        IArbitrable subject = IArbitrable(msg.sender);
        _disputeManager.submitEvidence(subject, _disputeId, _submitter, _evidence);
    }

     
    function _closeEvidencePeriod(IDisputeManager _disputeManager, uint256 _disputeId) internal {
        IArbitrable subject = IArbitrable(msg.sender);
        _disputeManager.closeEvidencePeriod(subject, _disputeId);
    }

     
    function _rule(IDisputeManager _disputeManager, uint256 _disputeId) internal returns (address subject, uint256 ruling) {
        (IArbitrable _subject, uint8 _ruling) = _disputeManager.computeRuling(_disputeId);
        return (address(_subject), uint256(_ruling));
    }

     
    function _disputeManager() internal view returns (IDisputeManager) {
        return IDisputeManager(_getModuleAddress(MODULE_ID_DISPUTE_MANAGER));
    }
}