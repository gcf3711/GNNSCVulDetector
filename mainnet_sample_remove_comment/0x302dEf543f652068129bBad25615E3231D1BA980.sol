 
pragma experimental ABIEncoderV2;


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









contract StakingConstantsV2 {
    address internal constant ZERO_ADDRESS = address(0);

    address public constant BZRX = 0x56d811088235F11C8920698a204A5010a788f4b3;
    address public constant OOKI = 0x0De05F6447ab4D22c8827449EE4bA2D5C288379B;
    address public constant vBZRX = 0xB72B31907C1C95F3650b64b2469e08EdACeE5e8F;
    address public constant iOOKI = 0x05d5160cbc6714533ef44CEd6dd32112d56Ad7da;
    address public constant OOKI_ETH_LP = 0xEaaddE1E14C587a7Fb4Ba78eA78109BB32975f1e;  

    uint256 internal constant cliffDuration = 15768000;  
    uint256 internal constant vestingDuration = 126144000;  
    uint256 internal constant vestingDurationAfterCliff = 110376000;  
    uint256 internal constant vestingStartTimestamp = 1594648800;  
    uint256 internal constant vestingCliffTimestamp = vestingStartTimestamp + cliffDuration;
    uint256 internal constant vestingEndTimestamp = vestingStartTimestamp + vestingDuration;

     
    uint256 internal constant _startingVBZRXBalance = 8893899330e18;
     

    address internal constant SUSHI_MASTERCHEF = 0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd;
    uint256 internal constant OOKI_ETH_SUSHI_MASTERCHEF_PID = 335;
    address public constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;

    ICurve3Pool public constant curve3pool = ICurve3Pool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    IERC20 public constant curve3Crv = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    ICurveMinter public constant curveMinter = ICurveMinter(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);

    IBZRXv2Converter public constant CONVERTER = IBZRXv2Converter(0x6BE9B7406260B6B6db79a1D4997e7f8f5c9D7400);

    event Stake(address indexed user, address indexed token, address indexed delegate, uint256 amount);

    event Unstake(address indexed user, address indexed token, address indexed delegate, uint256 amount);

    event Claim(address indexed user, uint256 ookiAmount, uint256 stableCoinAmount);

    event AddAltRewards(address indexed sender, address indexed token, uint256 amount);

    event ClaimAltRewards(address indexed user, address indexed token, uint256 amount);

    event AddRewards(address indexed sender, uint256 ookiAmount, uint256 stableCoinAmount);
}

 

pragma solidity 0.5.17;








contract StakingStateV2 is StakingConstantsV2, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    mapping(bytes4 => address) public logicTargets;
    EnumerableBytes32Set.Bytes32Set internal logicTargetsSet;

    mapping(address => uint256) public _totalSupplyPerToken;  
    mapping(address => mapping(address => uint256)) internal _balancesPerToken;  

    uint256 public ookiPerTokenStored;
    mapping(address => uint256) public ookiRewardsPerTokenPaid;  
    mapping(address => uint256) public ookiRewards;  
    mapping(address => uint256) public bzrxVesting;  

    uint256 public stableCoinPerTokenStored;
    mapping(address => uint256) public stableCoinRewardsPerTokenPaid;  
    mapping(address => uint256) public stableCoinRewards;  
    mapping(address => uint256) public stableCoinVesting;  

    uint256 public vBZRXWeightStored;
    uint256 public iOOKIWeightStored;
    uint256 public LPTokenWeightStored;

    uint256 public lastRewardsAddTime;
    mapping(address => uint256) public vestingLastSync;

    struct ProposalState {
        uint256 proposalTime;
        uint256 iOOKIWeight;
        uint256 lpOOKIBalance;
        uint256 lpTotalSupply;
    }
    address public governor;
    mapping(uint256 => ProposalState) internal _proposalState;

    mapping(address => uint256[]) public altRewardsRounds;  
    mapping(address => uint256) public altRewardsPerShare;  

     
    mapping(address => mapping(address => IStakingV2.AltRewardsUserInfo)) public userAltRewardsPerShare;

    address public voteDelegator;

    function _setTarget(bytes4 sig, address target) internal {
        logicTargets[sig] = target;

        if (target != address(0)) {
            logicTargetsSet.addBytes32(bytes32(sig));
        } else {
            logicTargetsSet.removeBytes32(bytes32(sig));
        }
    }
}

 

pragma solidity 0.5.17;




contract PausableGuardian is Ownable {

     
    bytes32 internal constant Pausable_FunctionPause = 0xa7143c84d793a15503da6f19bf9119a2dac94448ca45d77c8bf08f57b2e91047;

     
    bytes32 internal constant Pausable_GuardianAddress = 0x80e6706973d0c59541550537fd6a33b971efad732635e6c3b99fb01006803cdf;

    modifier pausable {
        require(!_isPaused(msg.sig), "paused");
        _;
    }

    function _isPaused(bytes4 sig) public view returns (bool isPaused) {
        bytes32 slot = keccak256(abi.encodePacked(sig, Pausable_FunctionPause));
        assembly {
            isPaused := sload(slot)
        }
    }

    function toggleFunctionPause(bytes4 sig) public {
        require(msg.sender == getGuardian() || msg.sender == owner(), "unauthorized");
        bytes32 slot = keccak256(abi.encodePacked(sig, Pausable_FunctionPause));
        assembly {
            sstore(slot, 1)
        }
    }

    function toggleFunctionUnPause(bytes4 sig) public {
         
        require(msg.sender == getGuardian() || msg.sender == owner(), "unauthorized");
        bytes32 slot = keccak256(abi.encodePacked(sig, Pausable_FunctionPause));
        assembly {
            sstore(slot, 0)
        }
    }

    function changeGuardian(address newGuardian) public {
        require(msg.sender == getGuardian() || msg.sender == owner(), "unauthorized");
        assembly {
            sstore(Pausable_GuardianAddress, newGuardian)
        }
    }

    function getGuardian() public view returns (address guardian) {
        assembly {
            guardian := sload(Pausable_GuardianAddress)
        }
    }
}

contract GovernorBravoDelegatorStorage {
    
    address public admin;

    
    address public pendingAdmin;

    
    address public implementation;

    
    address public guardian;
}

 

pragma solidity 0.5.17;




contract VoteDelegationUpgradeable is Ownable {
    address public implementation;
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

pragma solidity ^0.5.16;



contract GovernorBravoEvents {
    
    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock, string description);

    
    
    
    
    
    
    event VoteCast(address indexed voter, uint proposalId, uint8 support, uint votes, string reason);

    
    event ProposalCanceled(uint id);

    
    event ProposalQueued(uint id, uint eta);

    
    event ProposalExecuted(uint id);

    
    event VotingDelaySet(uint oldVotingDelay, uint newVotingDelay);

    
    event VotingPeriodSet(uint oldVotingPeriod, uint newVotingPeriod);

    
    event NewImplementation(address oldImplementation, address newImplementation);

    
    event QuorumPercentageSet(uint oldQuorumPercentage, uint newQuorumPercentage);

    
    event StakingAddressSet(address oldStaking, address newStaking);

    
    event ProposalThresholdSet(uint oldProposalThreshold, uint newProposalThreshold);

    
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    
    event NewAdmin(address oldAdmin, address newAdmin);
}


 
contract GovernorBravoDelegateStorageV1 is GovernorBravoDelegatorStorage {

    
    uint public votingDelay;

    
    uint public votingPeriod;

    
    uint public proposalThresholdPercentage;

    
    uint public initialProposalId;

    
    uint public proposalCount;

    
    TimelockInterface public timelock;

    
    StakingInterface public staking;

    
    uint public quorumPercentage;


    
    mapping (uint => Proposal) public proposals;

    
    mapping (address => uint) public latestProposalIds;

    
    mapping (uint => uint) public quorumVotesForProposal;


    struct Proposal {
        
        uint id;

        
        address proposer;

        
        uint eta;

        
        address[] targets;

        
        uint[] values;

        
        string[] signatures;

        
        bytes[] calldatas;

        
        uint startBlock;

        
        uint endBlock;

        
        uint forVotes;

        
        uint againstVotes;

        
        uint abstainVotes;

        
        bool canceled;

        
        bool executed;

        
        mapping (address => Receipt) receipts;
    }

    
    struct Receipt {
        
        bool hasVoted;

        
        uint8 support;

        
        uint96 votes;
    }

    
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
}

 

pragma solidity 0.5.17;








contract VoteDelegatorState is VoteDelegationUpgradeable {

     
     
    mapping (address => address) internal _delegates;

    
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    
    mapping (address => uint32) public numCheckpoints;

    
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    
    mapping (address => uint) public nonces;

    mapping (address => uint256) public totalDelegators;

    IStakingV2 staking;
}

 

pragma solidity 0.5.17;

contract VoteDelegatorConstants {
    address internal constant ZERO_ADDRESS = address(0);

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
}

 

pragma solidity 0.5.17;






contract Common is StakingStateV2, PausableGuardian {
    using MathUtil for uint256;

    function _getProposalState() internal view returns (ProposalState memory) {
        return
            ProposalState({
                proposalTime: block.timestamp - 1,
                iOOKIWeight: _calcIOOKIWeight(),
                lpOOKIBalance: 0,  
                lpTotalSupply: 0  
            });
    }

    function _calcIOOKIWeight() internal view returns (uint256) {
        uint256 total = IERC20(iOOKI).totalSupply();
        if(total != 0)
            return IERC20(OOKI).balanceOf(iOOKI).mul(1e50).div(total);
        return 0;
    }
 
    function vestedBalanceForAmount(
        uint256 tokenBalance,
        uint256 lastUpdate,
        uint256 vestingEndTime
    ) public view returns (uint256 vested) {
        vestingEndTime = vestingEndTime.min256(block.timestamp);
        if (vestingEndTime > lastUpdate) {
            if (vestingEndTime <= vestingCliffTimestamp || lastUpdate >= vestingEndTimestamp) {
                 
                 
                return 0;
            }
            if (lastUpdate < vestingCliffTimestamp) {
                 
                lastUpdate = vestingCliffTimestamp;
            }
            if (vestingEndTime > vestingEndTimestamp) {
                 
                vestingEndTime = vestingEndTimestamp;
            }

            uint256 timeSinceClaim = vestingEndTime.sub(lastUpdate);
            vested = tokenBalance.mul(timeSinceClaim) / vestingDurationAfterCliff;  
        }
    }

     
    function _votingFromStakedBalanceOf(
        address account,
        ProposalState memory proposal,
        bool skipVestingLastSyncCheck
    ) internal view returns (uint256 totalVotes) {
        uint256 _vestingLastSync = vestingLastSync[account];
        if (proposal.proposalTime == 0 || (!skipVestingLastSyncCheck && _vestingLastSync > proposal.proposalTime - 1)) {
            return 0;
        }

        uint256 _vOOKIBalance = _balancesPerToken[vBZRX][account] * 10;  
        if (_vOOKIBalance != 0) {
            if (vestingEndTimestamp > proposal.proposalTime && vestingCliffTimestamp < proposal.proposalTime) {
                 
                totalVotes = _vOOKIBalance * (vestingEndTimestamp - proposal.proposalTime) / vestingDurationAfterCliff;
            }

             
            totalVotes = vestedBalanceForAmount(
                _vOOKIBalance,
                _vestingLastSync,
                proposal.proposalTime
            ).add(totalVotes);
        }

        totalVotes = _balancesPerToken[OOKI][account].add(ookiRewards[account]).add(totalVotes);  

        totalVotes = _balancesPerToken[iOOKI][account].mul(proposal.iOOKIWeight).div(1e50).add(totalVotes);

         
         
    }
}
 

pragma solidity 0.5.17;









contract StakeUnstake is Common {
    function initialize(address target) external onlyOwner {
        _setTarget(this.totalSupplyByAsset.selector, target);
        _setTarget(this.stake.selector, target);
        _setTarget(this.unstake.selector, target);
        _setTarget(this.claim.selector, target);
        _setTarget(this.claimAltRewards.selector, target);
        _setTarget(this.claimBzrx.selector, target);
        _setTarget(this.claim3Crv.selector, target);
        _setTarget(this.claimSushi.selector, target);
        _setTarget(this.earned.selector, target);
        _setTarget(this.addAltRewards.selector, target);
        _setTarget(this.balanceOfByAsset.selector, target);
        _setTarget(this.balanceOfByAssets.selector, target);
        _setTarget(this.balanceOfStored.selector, target);
        _setTarget(this.vestedBalanceForAmount.selector, target);
        _setTarget(this.exit.selector, target);
    }


    function totalSupplyByAsset(
        address token)
    external
    view
    returns (uint256)
    {
        return _totalSupplyPerToken[token];
    }

    function _pendingSushiRewards(address _user) internal view returns (uint256) {
        uint256 pendingSushi = IMasterChefSushi(SUSHI_MASTERCHEF).pendingSushi(OOKI_ETH_SUSHI_MASTERCHEF_PID, address(this));

        uint256 totalSupply = _totalSupplyPerToken[OOKI_ETH_LP];
        return _pendingAltRewards(SUSHI, _user, balanceOfByAsset(OOKI_ETH_LP, _user), totalSupply != 0 ? pendingSushi.mul(1e12).div(totalSupply) : 0);
    }


    function _pendingAltRewards(
        address token,
        address _user,
        uint256 userSupply,
        uint256 extraRewardsPerShare
    ) internal view returns (uint256) {
        uint256 _altRewardsPerShare = altRewardsPerShare[token].add(extraRewardsPerShare);
        if (_altRewardsPerShare == 0) return 0;

        IStakingV2.AltRewardsUserInfo memory altRewardsUserInfo = userAltRewardsPerShare[_user][token];
        return altRewardsUserInfo.pendingRewards.add((_altRewardsPerShare.sub(altRewardsUserInfo.rewardsPerShare)).mul(userSupply).div(1e12));
    }

    function _depositToSushiMasterchef(uint256 amount) internal {
        uint256 sushiBalanceBefore = IERC20(SUSHI).balanceOf(address(this));
        IMasterChefSushi(SUSHI_MASTERCHEF).deposit(OOKI_ETH_SUSHI_MASTERCHEF_PID, amount);
        uint256 sushiRewards = IERC20(SUSHI).balanceOf(address(this)) - sushiBalanceBefore;
        if (sushiRewards != 0) {
            _addAltRewards(SUSHI, sushiRewards);
        }
    }

    function _withdrawFromSushiMasterchef(uint256 amount) internal {
        uint256 sushiBalanceBefore = IERC20(SUSHI).balanceOf(address(this));
        IMasterChefSushi(SUSHI_MASTERCHEF).withdraw(OOKI_ETH_SUSHI_MASTERCHEF_PID, amount);
        uint256 sushiRewards = IERC20(SUSHI).balanceOf(address(this)) - sushiBalanceBefore;
        if (sushiRewards != 0) {
            _addAltRewards(SUSHI, sushiRewards);
        }
    }

    function stake(address[] memory tokens, uint256[] memory values) public pausable updateRewards(msg.sender) {
        require(tokens.length == values.length, "count mismatch");
        VoteDelegator _voteDelegator = VoteDelegator(voteDelegator);
        address currentDelegate = _voteDelegator.delegates(msg.sender);

        ProposalState memory _proposalState = _getProposalState();
        uint256 votingBalanceBefore = _votingFromStakedBalanceOf(msg.sender, _proposalState, true);
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            require(token == OOKI || token == vBZRX || token == iOOKI || token == OOKI_ETH_LP, "invalid token");

            uint256 stakeAmount = values[i];
            if (stakeAmount == 0) {
                continue;
            }
            uint256 pendingBefore = (token == OOKI_ETH_LP) ? _pendingSushiRewards(msg.sender) : 0;
            _balancesPerToken[token][msg.sender] = _balancesPerToken[token][msg.sender].add(stakeAmount);
            _totalSupplyPerToken[token] = _totalSupplyPerToken[token].add(stakeAmount);

            IERC20(token).safeTransferFrom(msg.sender, address(this), stakeAmount);
             
            if (token == OOKI_ETH_LP) {
                _depositToSushiMasterchef(IERC20(OOKI_ETH_LP).balanceOf(address(this)));

                userAltRewardsPerShare[msg.sender][SUSHI] = IStakingV2.AltRewardsUserInfo({rewardsPerShare: altRewardsPerShare[SUSHI], pendingRewards: pendingBefore});
            }

            emit Stake(msg.sender, token, currentDelegate, stakeAmount);
        }

        _voteDelegator.moveDelegatesByVotingBalance(votingBalanceBefore, _votingFromStakedBalanceOf(msg.sender, _proposalState, true), msg.sender);
    }

    function unstake(address[] memory tokens, uint256[] memory values) public pausable updateRewards(msg.sender) {
        require(tokens.length == values.length, "count mismatch");

        VoteDelegator _voteDelegator = VoteDelegator(voteDelegator);
        address currentDelegate = _voteDelegator.delegates(msg.sender);

        ProposalState memory _proposalState = _getProposalState();
        uint256 votingBalanceBefore = _votingFromStakedBalanceOf(msg.sender, _proposalState, true);

        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            require(token == OOKI || token == vBZRX || token == iOOKI || token == OOKI_ETH_LP, "invalid token");

            uint256 unstakeAmount = values[i];
            uint256 stakedAmount = _balancesPerToken[token][msg.sender];
            if (unstakeAmount == 0 || stakedAmount == 0) {
                continue;
            }
            if (unstakeAmount > stakedAmount) {
                unstakeAmount = stakedAmount;
            }

             
            if (token == OOKI_ETH_LP) {
                _withdrawFromSushiMasterchef(unstakeAmount);
                userAltRewardsPerShare[msg.sender][SUSHI] = IStakingV2.AltRewardsUserInfo({rewardsPerShare: altRewardsPerShare[SUSHI], pendingRewards: _pendingSushiRewards(msg.sender)});
            }

            _balancesPerToken[token][msg.sender] = stakedAmount - unstakeAmount;  
            _totalSupplyPerToken[token] = _totalSupplyPerToken[token] - unstakeAmount;  

            if (token == OOKI && IERC20(OOKI).balanceOf(address(this)) < unstakeAmount) {
                 
                IVestingToken(vBZRX).claim();
                CONVERTER.convert(address(this), IERC20(BZRX).balanceOf(address(this)));
            }

            IERC20(token).safeTransfer(msg.sender, unstakeAmount);
            emit Unstake(msg.sender, token, currentDelegate, unstakeAmount);
        }
        _voteDelegator.moveDelegatesByVotingBalance(votingBalanceBefore, _votingFromStakedBalanceOf(msg.sender, _proposalState, true), msg.sender);
    }

    function claim(bool restake) external pausable updateRewards(msg.sender) returns (uint256 ookiRewardsEarned, uint256 stableCoinRewardsEarned) {
        return _claim(restake);
    }

    function claimAltRewards() external pausable returns (uint256 sushiRewardsEarned, uint256 crvRewardsEarned) {
        sushiRewardsEarned = _claimSushi();

        if (sushiRewardsEarned != 0) {
            emit ClaimAltRewards(msg.sender, SUSHI, sushiRewardsEarned);
        }
    }

    function claimBzrx() external pausable updateRewards(msg.sender) returns (uint256 ookiRewardsEarned) {
        ookiRewardsEarned = _claimBzrx(false);

        emit Claim(msg.sender, ookiRewardsEarned, 0);
    }

    function claim3Crv() external pausable updateRewards(msg.sender) returns (uint256 stableCoinRewardsEarned) {
        stableCoinRewardsEarned = _claim3Crv();

        emit Claim(msg.sender, 0, stableCoinRewardsEarned);
    }

    function claimSushi() external pausable returns (uint256 sushiRewardsEarned) {
        sushiRewardsEarned = _claimSushi();
        if (sushiRewardsEarned != 0) {
            emit ClaimAltRewards(msg.sender, SUSHI, sushiRewardsEarned);
        }
    }

    function _claim(bool restake) internal returns (uint256 ookiRewardsEarned, uint256 stableCoinRewardsEarned) {
        ookiRewardsEarned = _claimBzrx(restake);
        stableCoinRewardsEarned = _claim3Crv();

        emit Claim(msg.sender, ookiRewardsEarned, stableCoinRewardsEarned);
    }

    function _claimBzrx(bool restake) internal returns (uint256 ookiRewardsEarned) {
        ProposalState memory _proposalState = _getProposalState();
        uint256 votingBalanceBefore = _votingFromStakedBalanceOf(msg.sender, _proposalState, true);

        ookiRewardsEarned = ookiRewards[msg.sender];
        if (ookiRewardsEarned != 0) {
            ookiRewards[msg.sender] = 0;
            if (restake) {
                _restakeBZRX(msg.sender, ookiRewardsEarned);
            } else {
                if (IERC20(OOKI).balanceOf(address(this)) < ookiRewardsEarned) {
                     
                    IVestingToken(vBZRX).claim();
                    CONVERTER.convert(address(this), IERC20(BZRX).balanceOf(address(this)));
                }

                IERC20(OOKI).transfer(msg.sender, ookiRewardsEarned);
            }
        }
        VoteDelegator(voteDelegator).moveDelegatesByVotingBalance(votingBalanceBefore, _votingFromStakedBalanceOf(msg.sender, _proposalState, true), msg.sender);
    }

    function _claim3Crv() internal returns (uint256 stableCoinRewardsEarned) {
        stableCoinRewardsEarned = stableCoinRewards[msg.sender];
        if (stableCoinRewardsEarned != 0) {
            uint256 curve3CrvBalance = curve3Crv.balanceOf(address(this));
            stableCoinRewards[msg.sender] = 0;
            curve3Crv.transfer(msg.sender, stableCoinRewardsEarned);
        }
    }

    function _claimSushi() internal returns (uint256) {
        address _user = msg.sender;
        uint256 lptUserSupply = balanceOfByAsset(OOKI_ETH_LP, _user);

         
        _depositToSushiMasterchef(IERC20(OOKI_ETH_LP).balanceOf(address(this)));

        uint256 pendingSushi = _pendingAltRewards(SUSHI, _user, lptUserSupply, 0);

        userAltRewardsPerShare[_user][SUSHI] = IStakingV2.AltRewardsUserInfo({rewardsPerShare: altRewardsPerShare[SUSHI], pendingRewards: 0});
        if (pendingSushi != 0) {
            IERC20(SUSHI).safeTransfer(_user, pendingSushi);
        }

        return pendingSushi;
    }

    function _restakeBZRX(address account, uint256 amount) internal {
        _balancesPerToken[OOKI][account] = _balancesPerToken[OOKI][account].add(amount);

        _totalSupplyPerToken[OOKI] = _totalSupplyPerToken[OOKI].add(amount);

        emit Stake(
            account,
            OOKI,
            account,  
            amount
        );
    }

    modifier updateRewards(address account) {
        uint256 _ookiPerTokenStored = ookiPerTokenStored;
        uint256 _stableCoinPerTokenStored = stableCoinPerTokenStored;

        (uint256 ookiRewardsEarned, uint256 stableCoinRewardsEarned, uint256 ookiRewardsVesting, uint256 stableCoinRewardsVesting) = _earned(
            account,
            _ookiPerTokenStored,
            _stableCoinPerTokenStored
        );
        ookiRewardsPerTokenPaid[account] = _ookiPerTokenStored;
        stableCoinRewardsPerTokenPaid[account] = _stableCoinPerTokenStored;

         
        bzrxVesting[account] = ookiRewardsVesting;
        stableCoinVesting[account] = stableCoinRewardsVesting;

        (ookiRewards[account], stableCoinRewards[account]) = _syncVesting(account, ookiRewardsEarned, stableCoinRewardsEarned, ookiRewardsVesting, stableCoinRewardsVesting);

        vestingLastSync[account] = block.timestamp;

        _;
    }

    function earned(address account)
        external
         
        returns (
            uint256 ookiRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 ookiRewardsVesting,
            uint256 stableCoinRewardsVesting,
            uint256 sushiRewardsEarned
        )
    {
        (ookiRewardsEarned, stableCoinRewardsEarned, ookiRewardsVesting, stableCoinRewardsVesting) = _earned(account, ookiPerTokenStored, stableCoinPerTokenStored);

        (ookiRewardsEarned, stableCoinRewardsEarned) = _syncVesting(account, ookiRewardsEarned, stableCoinRewardsEarned, ookiRewardsVesting, stableCoinRewardsVesting);

         
        uint256 multiplier = vestedBalanceForAmount(1e36, 0, block.timestamp);
        ookiRewardsVesting = ookiRewardsVesting.sub(ookiRewardsVesting.mul(multiplier).div(1e36));
        stableCoinRewardsVesting = stableCoinRewardsVesting.sub(stableCoinRewardsVesting.mul(multiplier).div(1e36));

        uint256 pendingSushi = IMasterChefSushi(SUSHI_MASTERCHEF).pendingSushi(OOKI_ETH_SUSHI_MASTERCHEF_PID, address(this));

        sushiRewardsEarned = _pendingAltRewards(
            SUSHI,
            account,
            balanceOfByAsset(OOKI_ETH_LP, account),
            (_totalSupplyPerToken[OOKI_ETH_LP] != 0) ? pendingSushi.mul(1e12).div(_totalSupplyPerToken[OOKI_ETH_LP]) : 0
        );
    }

    function _earned(
        address account,
        uint256 _ookiPerToken,
        uint256 _stableCoinPerToken
    )
        internal
        
        returns (
            uint256 ookiRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 ookiRewardsVesting,
            uint256 stableCoinRewardsVesting
        )
    {
        uint256 ookiPerTokenUnpaid = _ookiPerToken.sub(ookiRewardsPerTokenPaid[account]);
        uint256 stableCoinPerTokenUnpaid = _stableCoinPerToken.sub(stableCoinRewardsPerTokenPaid[account]);

        ookiRewardsEarned = ookiRewards[account];
        stableCoinRewardsEarned = stableCoinRewards[account];
        ookiRewardsVesting = bzrxVesting[account];
        stableCoinRewardsVesting = stableCoinVesting[account];

        if (ookiPerTokenUnpaid != 0 || stableCoinPerTokenUnpaid != 0) {
            uint256 value;
            uint256 multiplier;
            uint256 lastSync;

            (uint256 vestedBalance, uint256 vestingBalance) = balanceOfStored(account);
            value = vestedBalance.mul(ookiPerTokenUnpaid);
            value /= 1e36;
            ookiRewardsEarned = value.add(ookiRewardsEarned);
            value = vestedBalance.mul(stableCoinPerTokenUnpaid);
            value /= 1e36;
            stableCoinRewardsEarned = value.add(stableCoinRewardsEarned);

            if (vestingBalance != 0 && ookiPerTokenUnpaid != 0) {
                 
                value = vestingBalance.mul(ookiPerTokenUnpaid);
                value /= 1e36;
                ookiRewardsVesting = ookiRewardsVesting.add(value);
                 
                lastSync = vestingLastSync[account];
                multiplier = vestedBalanceForAmount(1e36, 0, lastSync);
                value = value.mul(multiplier);
                value /= 1e36;
                ookiRewardsEarned = ookiRewardsEarned.add(value);
            }
            if (vestingBalance != 0 && stableCoinPerTokenUnpaid != 0) {
                
                 
                value = vestingBalance.mul(stableCoinPerTokenUnpaid);
                value /= 1e36;
                stableCoinRewardsVesting = stableCoinRewardsVesting.add(value);

                 
                if (lastSync == 0) {
                    lastSync = vestingLastSync[account];
                    multiplier = vestedBalanceForAmount(1e36, 0, lastSync);
                }
                value = value.mul(multiplier);
                value /= 1e36;
                stableCoinRewardsEarned = stableCoinRewardsEarned.add(value);
            }
        }
    }

    function _syncVesting(
        address account,
        uint256 ookiRewardsEarned,
        uint256 stableCoinRewardsEarned,
        uint256 ookiRewardsVesting,
        uint256 stableCoinRewardsVesting
    ) internal view returns (uint256, uint256) {
        uint256 lastVestingSync = vestingLastSync[account];

        if (lastVestingSync != block.timestamp) {
            uint256 rewardsVested;
            uint256 multiplier = vestedBalanceForAmount(1e36, lastVestingSync, block.timestamp);

            if (ookiRewardsVesting != 0) {
                rewardsVested = ookiRewardsVesting.mul(multiplier).div(1e36);
                ookiRewardsEarned += rewardsVested;
            }

            if (stableCoinRewardsVesting != 0) {
                rewardsVested = stableCoinRewardsVesting.mul(multiplier).div(1e36);
                stableCoinRewardsEarned += rewardsVested;
            }

             
            uint256 vBZRXBalance = _balancesPerToken[vBZRX][account];
            if (vBZRXBalance != 0) {
                 
                rewardsVested = vBZRXBalance.mul(multiplier)
                    .div(1e35);   
                ookiRewardsEarned += rewardsVested;
            }
        }

        return (ookiRewardsEarned, stableCoinRewardsEarned);
    }

    function addAltRewards(address token, uint256 amount) public {
        if (amount != 0) {
            _addAltRewards(token, amount);
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }
    }

    function _addAltRewards(address token, uint256 amount) internal {
        address poolAddress = token == SUSHI ? OOKI_ETH_LP : token;

        uint256 totalSupply = _totalSupplyPerToken[poolAddress];
        require(totalSupply != 0, "no deposits");

        altRewardsPerShare[token] = altRewardsPerShare[token].add(amount.mul(1e12).div(totalSupply));

        emit AddAltRewards(msg.sender, token, amount);
    }

    function balanceOfByAsset(address token, address account) public view returns (uint256 balance) {
        balance = _balancesPerToken[token][account];
    }

    function balanceOfByAssets(address account)
        external
        view
        returns (
            uint256 ookiBalance,
            uint256 iBZRXBalance,
            uint256 vBZRXBalance,
            uint256 LPTokenBalance
        )
    {
        return (balanceOfByAsset(OOKI, account), balanceOfByAsset(iOOKI, account), balanceOfByAsset(vBZRX, account), balanceOfByAsset(OOKI_ETH_LP, account));
    }

    function balanceOfStored(address account) public view returns (uint256 vestedBalance, uint256 vestingBalance) {
        uint256 balance = _balancesPerToken[vBZRX][account];
        if (balance != 0) {
            vestingBalance = balance.mul(vBZRXWeightStored)
                .div(1e17);  
        }

        vestedBalance = _balancesPerToken[OOKI][account];

        balance = _balancesPerToken[iOOKI][account];
        if (balance != 0) {
            vestedBalance = balance.mul(iOOKIWeightStored).div(1e50).add(vestedBalance);
        }

        balance = _balancesPerToken[OOKI_ETH_LP][account];
        if (balance != 0) {
            vestedBalance = balance.mul(LPTokenWeightStored).div(1e18).add(vestedBalance);
        }
    }


    function exit()
        public
         
    {
        address[] memory tokens = new address[](4);
        uint256[] memory values = new uint256[](4);
        tokens[0] = iOOKI;
        tokens[1] = OOKI_ETH_LP;
        tokens[2] = vBZRX;
        tokens[3] = OOKI;
        values[0] = uint256(-1);
        values[1] = uint256(-1);
        values[2] = uint256(-1);
        values[3] = uint256(-1);
        
        unstake(tokens, values);  
        _claim(false);
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

 

pragma solidity 0.5.17;

 
library EnumerableBytes32Set {

    struct Bytes32Set {
         
         
        mapping (bytes32 => uint256) index;
        bytes32[] values;
    }

     
    function addAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return addBytes32(set, value);
    }

     
    function addBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        if (!contains(set, value)){
            set.index[value] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

     
    function removeAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return removeBytes32(set, value);
    }

     
    function removeBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

             
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set.values[lastIndex];

                 
                set.values[toDeleteIndex] = lastValue;
                 
                set.index[lastValue] = toDeleteIndex + 1;  
            }

             
            delete set.index[value];

             
            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

     
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return set.index[value] != 0;
    }

     
    function containsAddress(Bytes32Set storage set, address addrvalue)
        internal
        view
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return set.index[value] != 0;
    }

     
    function enumerate(Bytes32Set storage set, uint256 start, uint256 count)
        internal
        view
        returns (bytes32[] memory output)
    {
        uint256 end = start + count;
        require(end >= start, "addition overflow");
        end = set.values.length < end ? set.values.length : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new bytes32[](end-start);
        for (uint256 i = start; i < end; i++) {
            output[i-start] = set.values[i];
        }
        return output;
    }

     
    function length(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {
        return set.values.length;
    }

    
    function get(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return set.values[index];
    }

    
    function getAddress(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (address)
    {
        bytes32 value = set.values[index];
        address addrvalue;
        assembly {
            addrvalue := value
        }
        return addrvalue;
    }
}

 

pragma solidity >=0.5.0 <=0.8.4;


interface IStakingV2 {
    struct ProposalState {
        uint256 proposalTime;
        uint256 iOOKIWeight;
        uint256 lpOOKIBalance;
        uint256 lpTotalSupply;
    }

    struct AltRewardsUserInfo {
        uint256 rewardsPerShare;
        uint256 pendingRewards;
    }

    function getCurrentFeeTokens() external view returns (address[] memory);

    function maxUniswapDisagreement() external view returns (uint256);

    function fundsWallet() external view returns (address);

    function callerRewardDivisor() external view returns (uint256);

    function maxCurveDisagreement() external view returns (uint256);

    function rewardPercent() external view returns (uint256);

    function addRewards(uint256 newOOKI, uint256 newStableCoin) external;

    function stake(address[] calldata tokens, uint256[] calldata values) external;

    function unstake(address[] calldata tokens, uint256[] calldata values) external;

    function earned(address account)
        external
        view
        returns (
            uint256 bzrxRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 bzrxRewardsVesting,
            uint256 stableCoinRewardsVesting,
            uint256 sushiRewardsEarned
        );

    function pendingCrvRewards(address account)
        external
        view
        returns (
            uint256 bzrxRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 bzrxRewardsVesting,
            uint256 stableCoinRewardsVesting,
            uint256 sushiRewardsEarned
        );

    function getVariableWeights()
        external
        view
        returns (
            uint256 vBZRXWeight,
            uint256 iOOKIWeight,
            uint256 LPTokenWeight
        );

    function balanceOfByAsset(address token, address account) external view returns (uint256 balance);

    function balanceOfByAssets(address account)
        external
        view
        returns (
            uint256 bzrxBalance,
            uint256 iOOKIBalance,
            uint256 vBZRXBalance,
            uint256 LPTokenBalance
        );

    function balanceOfStored(address account) external view returns (uint256 vestedBalance, uint256 vestingBalance);

    function totalSupplyStored() external view returns (uint256 supply);

    function vestedBalanceForAmount(
        uint256 tokenBalance,
        uint256 lastUpdate,
        uint256 vestingEndTime
    ) external view returns (uint256 vested);

    function votingBalanceOf(address account, uint256 proposalId) external view returns (uint256 totalVotes);

    function votingBalanceOfNow(address account) external view returns (uint256 totalVotes);

    function votingFromStakedBalanceOf(address account) external view returns (uint256 totalVotes);

    function _setProposalVals(address account, uint256 proposalId) external returns (uint256);

    function exit() external;

    function addAltRewards(address token, uint256 amount) external;

    function governor() external view returns (address);

    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;

    function claim(bool restake) external;

    function claimAltRewards() external;

    function _totalSupplyPerToken(address) external view returns(uint256);
    

     

    function _isPaused(bytes4 sig) external view returns (bool isPaused);

    function toggleFunctionPause(bytes4 sig) external;

    function toggleFunctionUnPause(bytes4 sig) external;

    function changeGuardian(address newGuardian) external;

    function getGuardian() external view returns (address guardian);

     

     
    function exitSushi() external;

    function setGovernor(address _governor) external;

    function setApprovals(
        address _token,
        address _spender,
        uint256 _value
    ) external;

    function setVoteDelegator(address stakingGovernance) external;

    function updateSettings(address settingsTarget, bytes calldata callData) external;

    function claimSushi() external returns (uint256 sushiRewardsEarned);

    function totalSupplyByAsset(address token)
        external
        view
        returns (uint256);
}

 

pragma solidity 0.5.17;


interface IUniswapV2Router {
     
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline)
        external
        returns (uint256[] memory amounts);

     
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline)
        external
        returns (uint256[] memory amounts);

     
    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

     
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

 

pragma solidity >=0.5.0 <=0.8.4;

interface ICurve3Pool {
    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount)
        external;

    function get_virtual_price()
        external
        view
        returns (uint256);
}

 

pragma solidity >=0.5.0 <=0.8.4;


 
interface ICurveMinter {

    function mint(
        address _addr
    )
    external;
}

 

pragma solidity >=0.5.0 <=0.8.4;


 
interface ICurve3PoolGauge {
    function balanceOf(
        address _addr
    )
        external
        view
        returns (uint256);

    function working_balances(address)
        external view
        returns (uint256);

    function claimable_tokens(address)
        external
        returns (uint256);

    function deposit(
        uint256 _amount
    )
        external;

    function deposit(
        uint256 _amount,
        address _addr
    )
    external;

    function withdraw(
        uint256 _amount
    )
        external;

    function set_approve_deposit(
        address _addr,
        bool can_deposit
    )
        external;
}

 
 
pragma solidity >=0.5.0 <=0.8.4;






interface IBZx {
     

    
    
    function replaceContract(address target) external;

    
     
    
    
    function setTargets(
        string[] calldata sigsArr,
        address[] calldata targetsArr
    ) external;

    
    
    function getTarget(string calldata sig) external view returns (address);

     

    
    
    function setPriceFeedContract(address newContract) external;

    
    
    function setSwapsImplContract(address newContract) external;

    
    
    
    function setLoanPool(address[] calldata pools, address[] calldata assets)
        external;

    
    
    
    
    function setSupportedTokens(
        address[] calldata addrs,
        bool[] calldata toggles,
        bool withApprovals
    ) external;

    
    
    function setLendingFeePercent(uint256 newValue) external;

    
    
    function setTradingFeePercent(uint256 newValue) external;

    
    
    function setBorrowingFeePercent(uint256 newValue) external;

    
    
    function setAffiliateFeePercent(uint256 newValue) external;

    
     
    
    
    
    function setLiquidationIncentivePercent(
        address[] calldata loanTokens,
        address[] calldata collateralTokens,
        uint256[] calldata amounts
    ) external;

    
    
    function setMaxDisagreement(uint256 newAmount) external;

     
    function setSourceBufferPercent(uint256 newAmount) external;

    
    
    function setMaxSwapSize(uint256 newAmount) external;

    
    
    function setFeesController(address newController) external;

    
    
    
    
    function withdrawFees(
        address[] calldata tokens,
        address receiver,
        FeeClaimType feeType
    ) external returns (uint256[] memory amounts);

    
    
    
    
    
    function withdrawProtocolToken(address receiver, uint256 amount)
        external
        returns (address rewardToken, uint256 withdrawAmount);

    
    
    function depositProtocolToken(uint256 amount) external;

    function grantRewards(address[] calldata users, uint256[] calldata amounts)
        external
        returns (uint256 totalAmount);

     
    function queryFees(address[] calldata tokens, FeeClaimType feeType)
        external
        view
        returns (uint256[] memory amountsHeld, uint256[] memory amountsPaid);

    function priceFeeds() external view returns (address);

    function swapsImpl() external view returns (address);

    function logicTargets(bytes4) external view returns (address);

    function loans(bytes32) external view returns (Loan memory);

    function loanParams(bytes32) external view returns (LoanParams memory);

     
     
     

    function delegatedManagers(bytes32, address) external view returns (bool);

    function lenderInterest(address, address)
        external
        view
        returns (LenderInterest memory);

    function loanInterest(bytes32) external view returns (LoanInterest memory);

    function feesController() external view returns (address);

    function lendingFeePercent() external view returns (uint256);

    function lendingFeeTokensHeld(address) external view returns (uint256);

    function lendingFeeTokensPaid(address) external view returns (uint256);

    function borrowingFeePercent() external view returns (uint256);

    function borrowingFeeTokensHeld(address) external view returns (uint256);

    function borrowingFeeTokensPaid(address) external view returns (uint256);

    function protocolTokenHeld() external view returns (uint256);

    function protocolTokenPaid() external view returns (uint256);

    function affiliateFeePercent() external view returns (uint256);

    function liquidationIncentivePercent(address, address)
        external
        view
        returns (uint256);

    function loanPoolToUnderlying(address) external view returns (address);

    function underlyingToLoanPool(address) external view returns (address);

    function supportedTokens(address) external view returns (bool);

    function maxDisagreement() external view returns (uint256);

    function sourceBufferPercent() external view returns (uint256);

    function maxSwapSize() external view returns (uint256);

    
    
    
    
    function getLoanPoolsList(uint256 start, uint256 count)
        external
        view
        returns (address[] memory loanPoolsList);

    
    
    function isLoanPool(address loanPool) external view returns (bool);

     

    
    
    
    function setupLoanParams(LoanParams[] calldata loanParamsList)
        external
        returns (bytes32[] memory loanParamsIdList);

    
    
    function disableLoanParams(bytes32[] calldata loanParamsIdList) external;

    
    
    
    function getLoanParams(bytes32[] calldata loanParamsIdList)
        external
        view
        returns (LoanParams[] memory loanParamsList);

    
    
    
    
    
    function getLoanParamsList(
        address owner,
        uint256 start,
        uint256 count
    ) external view returns (bytes32[] memory loanParamsList);

    
    
    
    
    function getTotalPrincipal(address lender, address loanToken)
        external
        view
        returns (uint256);

     

    
    
    
    
    
    
     
     
     
     
    
     
     
     
     
     
    
    
    function borrowOrTradeFromPool(
        bytes32 loanParamsId,
        bytes32 loanId,
        bool isTorqueLoan,
        uint256 initialMargin,
        address[4] calldata sentAddresses,
        uint256[5] calldata sentValues,
        bytes calldata loanDataBytes
    ) external payable returns (LoanOpenData memory);

    
    
    
    
    function setDelegatedManager(
        bytes32 loanId,
        address delegated,
        bool toggle
    ) external;

    
    
    
    
    
    
    
    
    function getEstimatedMarginExposure(
        address loanToken,
        address collateralToken,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        uint256 interestRate,
        uint256 newPrincipal
    ) external view returns (uint256);

    
    
    
    
    
    
    
    function getRequiredCollateral(
        address loanToken,
        address collateralToken,
        uint256 newPrincipal,
        uint256 marginAmount,
        bool isTorqueLoan
    ) external view returns (uint256 collateralAmountRequired);

    function getRequiredCollateralByParams(
        bytes32 loanParamsId,
        uint256 newPrincipal
    ) external view returns (uint256 collateralAmountRequired);

    
    
    
    
    
    
    
    function getBorrowAmount(
        address loanToken,
        address collateralToken,
        uint256 collateralTokenAmount,
        uint256 marginAmount,
        bool isTorqueLoan
    ) external view returns (uint256 borrowAmount);

    function getBorrowAmountByParams(
        bytes32 loanParamsId,
        uint256 collateralTokenAmount
    ) external view returns (uint256 borrowAmount);

     

    
    
    
    
    
    
    
    function liquidate(
        bytes32 loanId,
        address receiver,
        uint256 closeAmount
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        );

    
    
    
    function rollover(bytes32 loanId, bytes calldata loanDataBytes)
        external
        returns (address rebateToken, uint256 gasRebate);

    
    
    
    
    
    
    
    function closeWithDeposit(
        bytes32 loanId,
        address receiver,
        uint256 depositAmount  
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );

    
    
    
    
    
    
    
    
    
    function closeWithSwap(
        bytes32 loanId,
        address receiver,
        uint256 swapAmount,  
        bool returnTokenIsCollateral,  
        bytes calldata loanDataBytes
    )
        external
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );

     

    
    
    
    
    
    
    
    
    function liquidateWithGasToken(
        bytes32 loanId,
        address receiver,
        address gasTokenUser,
        uint256 closeAmount  
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        );

    
    
    
    function rolloverWithGasToken(
        bytes32 loanId,
        address gasTokenUser,
        bytes calldata  
    ) external returns (address rebateToken, uint256 gasRebate);

    
    
    
    
    
    
    
    
    function closeWithDepositWithGasToken(
        bytes32 loanId,
        address receiver,
        address gasTokenUser,
        uint256 depositAmount
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );

    
    
    
    
    
    
    
    
    
    function closeWithSwapWithGasToken(
        bytes32 loanId,
        address receiver,
        address gasTokenUser,
        uint256 swapAmount,
        bool returnTokenIsCollateral,
        bytes calldata loanDataBytes
    )
        external
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );

     

    
    
    
    function depositCollateral(bytes32 loanId, uint256 depositAmount)
        external
        payable;

    
    
    
    
    
    function withdrawCollateral(
        bytes32 loanId,
        address receiver,
        uint256 withdrawAmount
    ) external returns (uint256 actualWithdrawAmount);

    
    
    function withdrawAccruedInterest(address loanToken) external;

    
    
    
    
    
    function extendLoanDuration(
        bytes32 loanId,
        uint256 depositAmount,
        bool useCollateral,
        bytes calldata  
    ) external payable returns (uint256 secondsExtended);

    
    
    
    
    
    function reduceLoanDuration(
        bytes32 loanId,
        address receiver,
        uint256 withdrawAmount
    ) external returns (uint256 secondsReduced);

    function setDepositAmount(
        bytes32 loanId,
        uint256 depositValueAsLoanToken,
        uint256 depositValueAsCollateralToken
    ) external;

    function claimRewards(address receiver)
        external
        returns (uint256 claimAmount);

    function transferLoan(bytes32 loanId, address newOwner) external;

    function rewardsBalanceOf(address user)
        external
        view
        returns (uint256 rewardsBalance);

    
    
    
    
    
    
    
    
    
    function getLenderInterestData(address lender, address loanToken)
        external
        view
        returns (
            uint256 interestPaid,
            uint256 interestPaidDate,
            uint256 interestOwedPerDay,
            uint256 interestUnPaid,
            uint256 interestFeePercent,
            uint256 principalTotal
        );

    
    
    
    
    
    
    function getLoanInterestData(bytes32 loanId)
        external
        view
        returns (
            address loanToken,
            uint256 interestOwedPerDay,
            uint256 interestDepositTotal,
            uint256 interestDepositRemaining
        );

    
    
    
    
    
    
    
    
    function getUserLoans(
        address user,
        uint256 start,
        uint256 count,
        LoanType loanType,
        bool isLender,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);

    function getUserLoansCount(address user, bool isLender)
        external
        view
        returns (uint256);

    
    
    
    function getLoan(bytes32 loanId)
        external
        view
        returns (LoanReturnData memory loanData);

    
    
    
    
    function getActiveLoans(
        uint256 start,
        uint256 count,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);

    
    
    
    
    
    function getActiveLoansAdvanced(
        uint256 start,
        uint256 count,
        bool unsafeOnly,
        bool isLiquidatable
    ) external view returns (LoanReturnData[] memory loansData);

    function getActiveLoansCount() external view returns (uint256);

     

    
    
    
    
    
    
    
    
    
    
    function swapExternal(
        address sourceToken,
        address destToken,
        address receiver,
        address returnToSender,
        uint256 sourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes calldata swapData
    )
        external
        payable
        returns (
            uint256 destTokenAmountReceived,
            uint256 sourceTokenAmountUsed
        );

    
    
    
    
    
    
    
    
    
    
    
    function swapExternalWithGasToken(
        address sourceToken,
        address destToken,
        address receiver,
        address returnToSender,
        address gasTokenUser,
        uint256 sourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes calldata swapData
    )
        external
        payable
        returns (
            uint256 destTokenAmountReceived,
            uint256 sourceTokenAmountUsed
        );

    
    
    
    
    
    function getSwapExpectedReturn(
        address sourceToken,
        address destToken,
        uint256 sourceTokenAmount
    ) external view returns (uint256);

    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;


     

    function _isPaused(bytes4 sig) external view returns (bool isPaused);

    function toggleFunctionPause(bytes4 sig) external;

    function toggleFunctionUnPause(bytes4 sig) external;

    function changeGuardian(address newGuardian) external;

    function getGuardian() external view returns (address guardian);

     

    function cleanupLoans(
        address loanToken,
        bytes32[] calldata loanIds)
        external
        payable
        returns (uint256 totalPrincipalIn);

    struct LoanParams {
        bytes32 id;
        bool active;
        address owner;
        address loanToken;
        address collateralToken;
        uint256 minInitialMargin;
        uint256 maintenanceMargin;
        uint256 maxLoanTerm;
    }

    struct LoanOpenData {
        bytes32 loanId;
        uint256 principal;
        uint256 collateral;
    }

    enum LoanType {
        All,
        Margin,
        NonMargin
    }

    struct LoanReturnData {
        bytes32 loanId;
        uint96 endTimestamp;
        address loanToken;
        address collateralToken;
        uint256 principal;
        uint256 collateral;
        uint256 interestOwedPerDay;
        uint256 interestDepositRemaining;
        uint256 startRate;
        uint256 startMargin;
        uint256 maintenanceMargin;
        uint256 currentMargin;
        uint256 maxLoanTerm;
        uint256 maxLiquidatable;
        uint256 maxSeizable;
        uint256 depositValueAsLoanToken;
        uint256 depositValueAsCollateralToken;
    }

    enum FeeClaimType {
        All,
        Lending,
        Trading,
        Borrowing
    }

    struct Loan {
        bytes32 id;  
        bytes32 loanParamsId;  
        bytes32 pendingTradesId;  
        uint256 principal;  
        uint256 collateral;  
        uint256 startTimestamp;  
        uint256 endTimestamp;  
        uint256 startMargin;  
        uint256 startRate;  
        address borrower;  
        address lender;  
        bool active;  
    }

    struct LenderInterest {
        uint256 principalTotal;  
        uint256 owedPerDay;  
        uint256 owedTotal;  
        uint256 paidTotal;  
        uint256 updatedTimestamp;  
    }

    struct LoanInterest {
        uint256 owedPerDay;  
        uint256 depositTotal;  
        uint256 updatedTimestamp;  
    }
}

 
 
pragma solidity >=0.5.0 <=0.8.4;


interface IBZRXv2Converter {
    function convert(address receiver, uint256 _tokenAmount) external;
}

 

pragma solidity 0.5.17;






contract StakingPausableGuardian is StakingStateV2, PausableGuardian {

    function initialize(
        address target)
        external
        onlyOwner
    {
        _setTarget(this._isPaused.selector, target);
        _setTarget(this.toggleFunctionPause.selector, target);
        _setTarget(this.toggleFunctionUnPause.selector, target);
        _setTarget(this.changeGuardian.selector, target);
        _setTarget(this.getGuardian.selector, target);
    }
}

 

pragma solidity >=0.5.0 <=0.8.4;


interface IMasterChefSushi {

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    function deposit(uint256 _pid, uint256 _amount)
        external;

    function withdraw(uint256 _pid, uint256 _amount)
        external;

     
    function userInfo(uint256, address)
        external
        view
        returns (UserInfo memory);


    function pendingSushi(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate)
        external;

    function updatePool(uint256 _pid)
        external;

    function owner()
        external
        view
        returns (address);
}

 

pragma solidity 0.5.17;













contract VoteDelegator is VoteDelegatorState, VoteDelegatorConstants, PausableGuardian {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

     
    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

     
    function delegate(address delegatee) pausable external {
        if(delegatee == msg.sender){
            delegatee = ZERO_ADDRESS;
        }
        return _delegate(msg.sender, delegatee);
    }

     
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) pausable external {
        if(delegatee == msg.sender){
            delegatee = ZERO_ADDRESS;
        }

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes("STAKING")),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != ZERO_ADDRESS, "Staking::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "Staking::delegateBySig: invalid nonce");
        require(now <= expiry, "Staking::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

     
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }


     
    function getPriorVotes(address account, uint blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "Staking::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

         
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

         
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2;  
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        if(delegatee == delegator || delegator == ZERO_ADDRESS)
            return;

        address oldDelegate = _delegates[delegator];

        uint256 delegatorBalance = staking.votingFromStakedBalanceOf(delegator);
        _delegates[delegator] = delegatee;

         
        if(delegatee == ZERO_ADDRESS && oldDelegate != ZERO_ADDRESS){
            if(totalDelegators[oldDelegate] > 0)
                totalDelegators[oldDelegate]--;

            if(totalDelegators[oldDelegate] == 0 && oldDelegate != ZERO_ADDRESS){
                uint32 dstRepNum = numCheckpoints[oldDelegate];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[oldDelegate][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = 0;
                _writeCheckpoint(oldDelegate, dstRepNum, dstRepOld, dstRepNew);
                return;
            }
        }
        else if(delegatee != ZERO_ADDRESS){
            totalDelegators[delegatee]++;
            if(totalDelegators[oldDelegate] > 0)
                totalDelegators[oldDelegate]--;
        }

        emit DelegateChanged(delegator, oldDelegate, delegatee);
        _moveDelegates(oldDelegate, delegatee, delegatorBalance);
    }

    function moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) public {
        require(msg.sender == address(staking), "unauthorized");
        _moveDelegates(srcRep, dstRep, amount);
    }

    function moveDelegatesByVotingBalance(
        uint256 votingBalanceBefore,
        uint256 votingBalanceAfter,
        address account
    )
    public
    {
        require(msg.sender == address(staking), "unauthorized");
        address currentDelegate = _delegates[account];
        if(currentDelegate == ZERO_ADDRESS)
            return;

        if(votingBalanceBefore > votingBalanceAfter){
            _moveDelegates(currentDelegate, ZERO_ADDRESS,
                votingBalanceBefore.sub(votingBalanceAfter)
            );
        }
        else{
            _moveDelegates(ZERO_ADDRESS, currentDelegate,
                votingBalanceAfter.sub(votingBalanceBefore)
            );
        }
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != ZERO_ADDRESS) {
                 
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub((amount > srcRepOld)? srcRepOld : amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != ZERO_ADDRESS) {
                 
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
        uint32 blockNumber = safe32(block.number, "Staking::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function setStaking(address _staking) public onlyOwner {
        staking = IStakingV2(_staking);
    }

}

pragma solidity ^0.5.16;





contract GovernorBravoDelegate is GovernorBravoDelegateStorageV1, GovernorBravoEvents {

    
    string public constant name = "Ooki Governor Bravo";

    
    uint public constant MIN_PROPOSAL_THRESHOLD = 0.5e18;  

    
    uint public constant MAX_PROPOSAL_THRESHOLD = 2e18;  

    
    uint public constant MIN_VOTING_PERIOD = 5760;  

    
    uint public constant MAX_VOTING_PERIOD = 80640;  

    
    uint public constant MIN_VOTING_DELAY = 1;

    
    uint public constant MAX_VOTING_DELAY = 40320;  

    
    uint public constant MIN_QUORUM_PERCENTAGE = 2e18;  

    
    uint public constant MAX_QUORUM_PERCENTAGE = 6e18;  

    
    uint public constant proposalMaxOperations = 100;  

    
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");


     
    function initialize(address timelock_, address staking_, uint votingPeriod_, uint votingDelay_, uint proposalThresholdPercentage_, uint quorumPercentage_) public {
        require(address(timelock) == address(0), "GovernorBravo::initialize: can only initialize once");
        require(msg.sender == admin, "GovernorBravo::initialize: admin only");
        require(timelock_ != address(0), "GovernorBravo::initialize: invalid timelock address");
        require(staking_ != address(0), "GovernorBravo::initialize: invalid STAKING address");
        require(votingPeriod_ >= MIN_VOTING_PERIOD && votingPeriod_ <= MAX_VOTING_PERIOD, "GovernorBravo::initialize: invalid voting period");
        require(votingDelay_ >= MIN_VOTING_DELAY && votingDelay_ <= MAX_VOTING_DELAY, "GovernorBravo::initialize: invalid voting delay");
        require(proposalThresholdPercentage_ >= MIN_PROPOSAL_THRESHOLD && proposalThresholdPercentage_ <= MAX_PROPOSAL_THRESHOLD, "GovernorBravo::initialize: invalid proposal threshold");
        require(quorumPercentage_ >= MIN_QUORUM_PERCENTAGE && quorumPercentage_ <= MAX_QUORUM_PERCENTAGE, "GovernorBravo::initialize: invalid quorum percentage");

        timelock = TimelockInterface(timelock_);
        staking = StakingInterface(staking_);
        votingPeriod = votingPeriod_;
        votingDelay = votingDelay_;
        proposalThresholdPercentage = proposalThresholdPercentage_;
        quorumPercentage = quorumPercentage_;

        guardian = msg.sender;
    }

     
    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) public returns (uint) {
        require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "GovernorBravo::propose: proposal function information arity mismatch");
        require(targets.length != 0, "GovernorBravo::propose: must provide actions");
        require(targets.length <= proposalMaxOperations, "GovernorBravo::propose: too many actions");

        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            ProposalState proposersLatestProposalState = state(latestProposalId);
            require(proposersLatestProposalState != ProposalState.Active, "GovernorBravo::propose: one live proposal per proposer, found an already active proposal");
            require(proposersLatestProposalState != ProposalState.Pending, "GovernorBravo::propose: one live proposal per proposer, found an already pending proposal");
        }

        uint proposalId = proposalCount + 1;
        require(staking._setProposalVals(msg.sender, proposalId) > proposalThreshold(), "GovernorBravo::propose: proposer votes below proposal threshold");
        proposalCount = proposalId;

        uint startBlock = add256(block.number, votingDelay);
        uint endBlock = add256(startBlock, votingPeriod);

        Proposal memory newProposal = Proposal({
            id: proposalId,
            proposer: msg.sender,
            eta: 0,
            targets: targets,
            values: values,
            signatures: signatures,
            calldatas: calldatas,
            startBlock: startBlock,
            endBlock: endBlock,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            canceled: false,
            executed: false
        });

        proposals[proposalId] = newProposal;
        latestProposalIds[msg.sender] = proposalId;
        quorumVotesForProposal[proposalId] = quorumVotes();

        emit ProposalCreated(proposalId, msg.sender, targets, values, signatures, calldatas, startBlock, endBlock, description);
        return proposalId;
    }

     
    function queue(uint proposalId) external {
        require(state(proposalId) == ProposalState.Succeeded, "GovernorBravo::queue: proposal can only be queued if it is succeeded");
        Proposal storage proposal = proposals[proposalId];
        uint eta = add256(block.timestamp, timelock.delay());
        for (uint i = 0; i < proposal.targets.length; i++) {
            queueOrRevertInternal(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], eta);
        }
        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

    function queueOrRevertInternal(address target, uint value, string memory signature, bytes memory data, uint eta) internal {
        require(!timelock.queuedTransactions(keccak256(abi.encode(target, value, signature, data, eta))), "GovernorBravo::queueOrRevertInternal: identical proposal action already queued at eta");
        timelock.queueTransaction(target, value, signature, data, eta);
    }

     
    function execute(uint proposalId) external payable {
        require(state(proposalId) == ProposalState.Queued, "GovernorBravo::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.executeTransaction.value(proposal.values[i])(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }
        emit ProposalExecuted(proposalId);
    }

     
    function cancel(uint proposalId) external {
        require(state(proposalId) != ProposalState.Executed, "GovernorBravo::cancel: cannot cancel executed proposal");

        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer || staking.votingBalanceOfNow(proposal.proposer) < proposalThreshold() || msg.sender == guardian, "GovernorBravo::cancel: proposer above threshold");

        proposal.canceled = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.cancelTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }

        emit ProposalCanceled(proposalId);
    }

     
    function quorumVotes() public view returns (uint256) {
        uint256 totalSupply = IERC20(0x0De05F6447ab4D22c8827449EE4bA2D5C288379B)  
            .totalSupply();
        return totalSupply * quorumPercentage / 1e20;
    }

     
    function proposalThreshold() public view returns (uint256) {
        uint256 totalSupply = IERC20(0x0De05F6447ab4D22c8827449EE4bA2D5C288379B)  
            .totalSupply();
        return totalSupply * proposalThresholdPercentage / 1e20;
    }

     
    function getActions(uint proposalId) external view returns (address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas) {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

     
    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory) {
        return proposals[proposalId].receipts[voter];
    }

     
    function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > initialProposalId, "GovernorBravo::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorumVotesForProposal[proposalId]) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.timestamp >= add256(proposal.eta, timelock.GRACE_PERIOD())) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

     
    function castVote(uint proposalId, uint8 support) external {
        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), "");
    }

     
    function castVoteWithReason(uint proposalId, uint8 support, string calldata reason) external {
        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), reason);
    }

     
    function castVoteBySig(uint proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainIdInternal(), address(this)));
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GovernorBravo::castVoteBySig: invalid signature");
        emit VoteCast(signatory, proposalId, support, castVoteInternal(signatory, proposalId, support), "");
    }


     
    function castVotes(uint[] calldata proposalIds, uint8[] calldata supportVals) external {
        require(proposalIds.length == supportVals.length, "count mismatch");
        for (uint256 i = 0; i < proposalIds.length; i++) {
            emit VoteCast(msg.sender, proposalIds[i], supportVals[i], castVoteInternal(msg.sender, proposalIds[i], supportVals[i]), "");
        }
    }

     
    function castVotesWithReason(uint[] calldata proposalIds, uint8[] calldata supportVals, string[] calldata reasons) external {
        require(proposalIds.length == supportVals.length && proposalIds.length == reasons.length, "count mismatch");
        for (uint256 i = 0; i < proposalIds.length; i++) {
            emit VoteCast(msg.sender, proposalIds[i], supportVals[i], castVoteInternal(msg.sender, proposalIds[i], supportVals[i]), reasons[i]);
        }
    }

     
    function castVotesBySig(uint[] calldata proposalIds, uint8[] calldata supportVals, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
        require(proposalIds.length == supportVals.length && proposalIds.length == vs.length && proposalIds.length == rs.length && proposalIds.length == ss.length, "count mismatch");
        for (uint256 i = 0; i < proposalIds.length; i++) {
            castVoteBySig(proposalIds[i], supportVals[i], vs[i], rs[i], ss[i]);
        }
    }

     
    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint96) {
        require(state(proposalId) == ProposalState.Active, "GovernorBravo::castVoteInternal: voting is closed");
        require(support <= 2, "GovernorBravo::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "GovernorBravo::castVoteInternal: voter already voted");
         
        uint96 votes = uint96(staking.votingBalanceOf(voter, proposalId));

        if (support == 0) {
            proposal.againstVotes = add256(proposal.againstVotes, votes);
        } else if (support == 1) {
            proposal.forVotes = add256(proposal.forVotes, votes);
        } else if (support == 2) {
            proposal.abstainVotes = add256(proposal.abstainVotes, votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }

     
    function __setVotingDelay(uint newVotingDelay) external {
        require(msg.sender == admin, "GovernorBravo::__setVotingDelay: admin only");
        require(newVotingDelay >= MIN_VOTING_DELAY && newVotingDelay <= MAX_VOTING_DELAY, "GovernorBravo::__setVotingDelay: invalid voting delay");
        uint oldVotingDelay = votingDelay;
        votingDelay = newVotingDelay;

        emit VotingDelaySet(oldVotingDelay, votingDelay);
    }

     
    function __setVotingPeriod(uint newVotingPeriod) external {
        require(msg.sender == admin, "GovernorBravo::__setVotingPeriod: admin only");
        require(newVotingPeriod >= MIN_VOTING_PERIOD && newVotingPeriod <= MAX_VOTING_PERIOD, "GovernorBravo::__setVotingPeriod: invalid voting period");
        uint oldVotingPeriod = votingPeriod;
        votingPeriod = newVotingPeriod;

        emit VotingPeriodSet(oldVotingPeriod, votingPeriod);
    }

     
    function __setQuorumPercentage(uint newQuorumPercentage) external {
        require(msg.sender == admin, "GovernorBravo::__setQuorumPercentage: admin only");
        require(newQuorumPercentage >= MIN_QUORUM_PERCENTAGE && newQuorumPercentage <= MAX_QUORUM_PERCENTAGE, "GovernorBravo::__setQuorumPercentage: invalid quorum percentage");
        uint oldQuorumPercentage = quorumPercentage;
        quorumPercentage = newQuorumPercentage;

        emit QuorumPercentageSet(oldQuorumPercentage, newQuorumPercentage);
    }

     
    function __setStaking(address newStaking) external {
        require(msg.sender == admin, "GovernorBravo::__setStaking: admin only");
        require(newStaking != address(0) , "GovernorBravo::__setStaking: invalid address");
        address oldStaking = address(staking);
        staking = StakingInterface(newStaking);

        emit StakingAddressSet(oldStaking, newStaking);
    }

     
    function __setProposalThresholdPercentage(uint newProposalThresholdPercentage) external {
        require(msg.sender == admin, "GovernorBravo::__setProposalThreshold: admin only");
        require(newProposalThresholdPercentage >= MIN_PROPOSAL_THRESHOLD && newProposalThresholdPercentage <= MAX_PROPOSAL_THRESHOLD, "GovernorBravo::__setProposalThreshold: invalid proposal threshold");
        uint oldProposalThresholdPercentage = proposalThresholdPercentage;
        proposalThresholdPercentage = newProposalThresholdPercentage;

        emit ProposalThresholdSet(oldProposalThresholdPercentage, proposalThresholdPercentage);
    }

     
    function __setPendingLocalAdmin(address newPendingAdmin) external {
         
        require(msg.sender == admin, "GovernorBravo:__setPendingLocalAdmin: admin only");

         
        address oldPendingAdmin = pendingAdmin;

         
        pendingAdmin = newPendingAdmin;

         
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

     
    function __acceptLocalAdmin() external {
         
        require(msg.sender == pendingAdmin && msg.sender != address(0), "GovernorBravo:__acceptLocalAdmin: pending admin only");

         
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

         
        admin = pendingAdmin;

         
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function __changeGuardian(address guardian_) public {
        require(msg.sender == guardian, "GovernorBravo::__changeGuardian: sender must be gov guardian");
        require(guardian_ != address(0), "GovernorBravo::__changeGuardian: not allowed");
        guardian = guardian_;
    }

    function __acceptAdmin() public {
        require(msg.sender == guardian, "GovernorBravo::__acceptAdmin: sender must be gov guardian");
        timelock.acceptAdmin();
    }

    function __abdicate() public {
        require(msg.sender == guardian, "GovernorBravo::__abdicate: sender must be gov guardian");
        guardian = address(0);
    }

    function __queueSetTimelockPendingAdmin(address newPendingAdmin, uint eta) public {
        require(msg.sender == guardian, "GovernorBravo::__queueSetTimelockPendingAdmin: sender must be gov guardian");
        timelock.queueTransaction(address(timelock), 0, "setPendingAdmin(address)", abi.encode(newPendingAdmin), eta);
    }

    function __executeSetTimelockPendingAdmin(address newPendingAdmin, uint eta) public {
        require(msg.sender == guardian, "GovernorBravo::__executeSetTimelockPendingAdmin: sender must be gov guardian");
        timelock.executeTransaction(address(timelock), 0, "setPendingAdmin(address)", abi.encode(newPendingAdmin), eta);
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }

    function getChainIdInternal() internal pure returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

interface TimelockInterface {
    function delay() external view returns (uint);
    function GRACE_PERIOD() external view returns (uint);
    function acceptAdmin() external;
    function queuedTransactions(bytes32 hash) external view returns (bool);
    function queueTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external returns (bytes32);
    function cancelTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external;
    function executeTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external payable returns (bytes memory);
}


interface StakingInterface {
    function votingBalanceOf(
        address account,
        uint proposalCount)
        external
        view
        returns (uint totalVotes);

    function votingBalanceOfNow(
        address account)
        external
        view
        returns (uint totalVotes);

    function _setProposalVals(
        address account,
        uint proposalCount)
        external
        returns (uint);
}


interface GovernorAlpha {
    
    function proposalCount() external returns (uint);
}

 

pragma solidity >=0.5.0 <0.6.0;




contract IVestingToken is IERC20 {
    function claim()
        external;

    function vestedBalanceOf(
        address _owner)
        external
        view
        returns (uint256);

    function claimedBalanceOf(
        address _owner)
        external
        view
        returns (uint256);
}

 

pragma solidity >=0.5.0 <0.8.0;

library MathUtil {

     
    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        return divCeil(a, b, "SafeMath: division by zero");
    }

     
    function divCeil(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
         
        require(b != 0, errorMessage);

        if (a == 0) {
            return 0;
        }
        uint256 c = ((a - 1) / b) + 1;

        return c;
    }

    function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
}