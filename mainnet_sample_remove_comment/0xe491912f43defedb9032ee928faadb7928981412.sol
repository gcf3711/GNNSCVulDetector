 

 

 

 
pragma solidity ^0.6.6;

 
contract Ownable {
    address private _owner;
    address private _pendingOwner;
    
     
    address private _secondOwner;
    address private _pendingSecond;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecondOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    function initializeOwnable() internal {
        require(_owner == address(0), "already initialized");
        _owner = msg.sender;
        _secondOwner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
        emit SecondOwnershipTransferred(address(0), msg.sender);
    }


     
    function owner() public view returns (address) {
        return _owner;
    }

     
    function secondOwner() public view returns (address) {
        return _secondOwner;
    }

     
    modifier onlyOwner() {
        require(isOwner(), "msg.sender is not owner");
        _;
    }
    
    modifier onlyFirstOwner() {
        require(msg.sender == _owner, "msg.sender is not owner");
        _;
    }
    
    modifier onlySecondOwner() {
        require(msg.sender == _secondOwner, "msg.sender is not owner");
        _;
    }

     
    function isOwner() public view returns (bool) {
        return msg.sender == _owner || msg.sender == _secondOwner;

    }

     
    function transferOwnership(address newOwner) public onlyFirstOwner {
        _pendingOwner = newOwner;
    }

    function receiveOwnership() public {
        require(msg.sender == _pendingOwner, "only pending owner can call this function");
        _transferOwnership(_pendingOwner);
        _pendingOwner = address(0);
    }

     
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

     
    function transferSecondOwnership(address newOwner) public onlySecondOwner {
        _pendingSecond = newOwner;
    }

    function receiveSecondOwnership() public {
        require(msg.sender == _pendingSecond, "only pending owner can call this function");
        _transferSecondOwnership(_pendingSecond);
        _pendingSecond = address(0);
    }

     
    function _transferSecondOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit SecondOwnershipTransferred(_secondOwner, newOwner);
        _secondOwner = newOwner;
    }

    uint256[50] private __gap;
}


 

pragma solidity ^0.6.6;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


 

pragma solidity ^0.6.6;

 
library SafeMath {
     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         
        require(b > 0);
        uint256 c = a / b;
         

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


 
pragma solidity ^0.6.6;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address to, uint256 amount) external returns (bool);
    
    function burn(address from, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 

pragma solidity ^0.6.6;

 
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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
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


 
pragma solidity ^0.6.6;

 
interface IWNXM {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address to, uint256 amount) external returns (bool);
    
    function burn(address from, uint256 amount) external returns (bool);

    function wrap(uint256 amount) external;
    
    function unwrap(uint256 amount) external;

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 

pragma solidity ^0.6.6;

 

 
interface INxmMaster {
    function tokenAddress() external view returns(address);
    function owner() external view returns(address);
    function pauseTime() external view returns(uint);
    function masterInitialized() external view returns(bool);
    function isPause() external view returns(bool check);
    function isMember(address _add) external view returns(bool);
    function getLatestAddress(bytes2 _contractName) external view returns(address payable contractAddress);
}
interface IPooledStaking {
    function unstakeRequests(uint256 id) external view returns(uint256 amount, uint256 unstakeAt, address contractAddress, address stakerAddress, uint256 next);
    function processPendingActions(uint256 iterations) external returns(bool success);
    function MAX_EXPOSURE() external view returns(uint256);
    function lastUnstakeRequestId() external view returns(uint256);
    function stakerDeposit(address user) external view returns (uint256);
    function stakerMaxWithdrawable(address user) external view returns (uint256);
    function withdrawReward(address user) external;
    function requestUnstake(address[] calldata protocols, uint256[] calldata amounts, uint256 insertAfter) external;
    function depositAndStake(uint256 deposit, address[] calldata protocols, uint256[] calldata amounts) external;
    function stakerContractCount(address staker) external view returns(uint256);
    function stakerContractAtIndex(address staker, uint contractIndex) external view returns (address);
    function stakerContractStake(address staker, address protocol) external view returns (uint256);
    function stakerContractsArray(address staker) external view returns (address[] memory);
    function stakerContractPendingUnstakeTotal(address staker, address protocol) external view returns(uint256);
    function withdraw(uint256 amount) external;
    function stakerReward(address staker) external view returns (uint256);
}

interface IClaimsData {
    function getClaimStatusNumber(uint256 claimId) external view returns (uint256, uint256);
    function getClaimDateUpd(uint256 claimId) external view returns (uint256);
}

interface INXMPool {
    function buyNXM(uint minTokensOut) external payable;
}

interface IGovernance {
    function submitVote(uint256 _proposalId, uint256 _solution) external;
}

interface IQuotation {
    function getWithdrawableCoverNoteCoverIds(address owner) external view returns(uint256[] memory, bytes32[] memory);
}


 
pragma solidity ^0.6.6;

interface IRewardDistributionRecipient {
    function notifyRewardAmount(uint256 reward) payable external;
}


 
pragma solidity ^0.6.6;

interface IRewardManager is IRewardDistributionRecipient {
  function initialize(address _rewardToken, address _stakeController) external;
  function stake(address _user, address _referral, uint256 _coverPrice) external;
  function withdraw(address _user, address _referral, uint256 _coverPrice) external;
  function getReward(address payable _user) external;
}


 
pragma solidity ^0.6.0;

interface IShieldMining {
  function claimRewards(
    address[] calldata stakedContracts,
    address[] calldata sponsors,
    address[] calldata tokenAddresses
  ) external returns (uint[] memory tokensRewarded);
}


 

pragma solidity ^0.6.6;
 

contract arNXMVault is Ownable {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    uint256 constant private DENOMINATOR = 1000;

     
    uint256 private ____deprecated____0;

     
    uint256 public rewardDuration;

     
     
    uint256 private ____deprecated____1;

     
     
    uint256 public reserveAmount;

     
    uint256 public withdrawalsPaused;

     
    uint256 public pauseDuration;

     
    address public beneficiary;

     
    uint256 public adminPercent;

     
    uint256 public referPercent;

     
    uint256 public lastRestake;

     
    uint256 public lastReward;

     
    address[] public protocols;

     
    uint256[] private amounts;

     
    address[] private activeProtocols;

    struct WithdrawalRequest {
        uint48 requestTime;
        uint104 nAmount;
        uint104 arAmount;
    }

     
    IERC20 public wNxm;
    IERC20 public nxm;
    IERC20 public arNxm;

     
    INxmMaster public nxmMaster;

     
    IRewardManager public rewardManager;

     
    mapping (address => address) public referrers;

    event Deposit(address indexed user, uint256 nAmount, uint256 arAmount, uint256 timestamp);
    event WithdrawRequested(address indexed user, uint256 arAmount, uint256 nAmount, uint256 requestTime, uint256 withdrawTime);
    event Withdrawal(address indexed user, uint256 nAmount, uint256 arAmount, uint256 timestamp);
    event Restake(uint256 withdrawn, uint256 unstaked, uint256 staked, uint256 totalAum, uint256 timestamp);
    event NxmReward(uint256 reward, uint256 timestamp, uint256 totalAum);

     
    modifier notContract {
        require(msg.sender == tx.origin, "Sender must be an EOA.");
        _;
    }

     
     
    modifier oncePerTx {
        require(block.timestamp > lastCall[tx.origin], "May only call this contract once per transaction.");
        lastCall[tx.origin] = block.timestamp;
        _;
    }

     
    function initialize(
        address _wNxm,
        address _arNxm,
        address _nxm,
        address _nxmMaster,
        address _rewardManager
    )
      public
    {
        require(address(arNxm) == address(0), "Contract has already been initialized.");

        Ownable.initializeOwnable();
        wNxm = IERC20(_wNxm);
        nxm = IERC20(_nxm);
        arNxm = IERC20(_arNxm);
        nxmMaster = INxmMaster(_nxmMaster);
        rewardManager = IRewardManager(_rewardManager);
         
        adminPercent = 0;
        referPercent = 25;
        reserveAmount = 30 ether;
        pauseDuration = 10 days;
        beneficiary = msg.sender;
         
        rewardDuration = 9 days;

         
        arNxm.approve( _rewardManager, uint256(-1) );
    }

     
    function deposit(uint256 _nAmount, address _referrer, bool _isNxm)
      external
      oncePerTx
    {
        if ( referrers[msg.sender] == address(0) ) {
            referrers[msg.sender] = _referrer != address(0) ? _referrer : beneficiary;
            address refToSet = _referrer != address(0) ? _referrer : beneficiary;
            referrers[msg.sender] = refToSet;

             
            uint256 prevBal = arNxm.balanceOf(msg.sender);
            if (prevBal > 0) rewardManager.stake(refToSet, msg.sender, prevBal);
        }

         
        uint256 arAmount = arNxmValue(_nAmount);

        if (_isNxm) {
            nxm.safeTransferFrom(msg.sender, address(this), _nAmount);
        } else {
            wNxm.safeTransferFrom(msg.sender, address(this), _nAmount);
            _unwrapWnxm(_nAmount);
        }

         
        arNxm.mint(msg.sender, arAmount);

        emit Deposit(msg.sender, _nAmount, arAmount, block.timestamp);
    }

     
    function withdraw(uint256 _arAmount, bool _payFee)
      external
      oncePerTx
    {
        require(block.timestamp.sub(withdrawalsPaused) > pauseDuration, "Withdrawals are temporarily paused.");

         
        uint256 nAmount = nxmValue(_arAmount);
        require(totalPending.add(nAmount) <= nxm.balanceOf(address(this)), "Not enough NXM available for witthdrawal.");

        if (_payFee) {
            uint256 fee = nAmount.mul(withdrawFee).div(1000);
            uint256 disbursement = nAmount.sub(fee);

             
            arNxm.burn(msg.sender, _arAmount);
            _wrapNxm(disbursement);
            wNxm.safeTransfer(msg.sender, disbursement);

            emit Withdrawal(msg.sender, nAmount, _arAmount, block.timestamp);
        } else {
            totalPending = totalPending.add(nAmount);
            arNxm.safeTransferFrom(msg.sender, address(this), _arAmount);
            WithdrawalRequest memory prevWithdrawal = withdrawals[msg.sender];
            withdrawals[msg.sender] = WithdrawalRequest(
                uint48(block.timestamp),
                prevWithdrawal.nAmount + uint104(nAmount),
                prevWithdrawal.arAmount + uint104(_arAmount)
            );

            emit WithdrawRequested(msg.sender, _arAmount, nAmount, block.timestamp, block.timestamp.add(withdrawDelay));
        }
    }

     
    function withdrawFinalize()
      external
      oncePerTx
    {
        WithdrawalRequest memory withdrawal = withdrawals[msg.sender];
        uint256 nAmount = uint256(withdrawal.nAmount);
        uint256 arAmount = uint256(withdrawal.arAmount);
        uint256 requestTime = uint256(withdrawal.requestTime);

        require(block.timestamp.sub(withdrawalsPaused) > pauseDuration, "Withdrawals are temporarily paused.");
        require(requestTime.add(withdrawDelay) <= block.timestamp, "Not ready to withdraw");
        require(nAmount > 0, "No pending amount to withdraw");

         
        arNxm.burn(address(this), arAmount);
        _wrapNxm(nAmount);
        wNxm.safeTransfer(msg.sender, nAmount);
        delete withdrawals[msg.sender];
        totalPending = totalPending.sub(nAmount);

        emit Withdrawal(msg.sender, nAmount, arAmount, block.timestamp);
    }

     
    function getRewardNxm()
      external
      notContract
    {
        uint256 prevAum = aum();
        uint256 rewards = _getRewardsNxm();

        if (rewards > 0) {
            lastRewardTimestamp = block.timestamp;
            emit NxmReward(rewards, block.timestamp, prevAum);
        } else if(lastRewardTimestamp == 0) {
            lastRewardTimestamp = block.timestamp;
        }
    }

     
    function getShieldMiningRewards(address _shieldMining, address[] calldata _protocols, address[] calldata _sponsors, address[] calldata _tokens)
      external
      notContract
    {
        IShieldMining(_shieldMining).claimRewards(_protocols, _sponsors, _tokens);
    }

     
    function arNxmValue(uint256 _nAmount)
      public
      view
    returns (uint256 arAmount)
    {
         
        uint256 reward = _currentReward();

         
         
        uint256 totalN = aum().add(reward).sub(lastReward);
        uint256 totalAr = arNxm.totalSupply();

         
        if (totalN == 0) {
            arAmount = _nAmount;
        } else {
            uint256 oneAmount = ( totalAr.mul(1e18) ).div(totalN);
            arAmount = _nAmount.mul(oneAmount).div(1e18);
        }
    }

     
    function nxmValue(uint256 _arAmount)
      public
      view
    returns (uint256 nAmount)
    {
         
        uint256 reward = _currentReward();

         
         
        uint256 totalN = aum().add(reward).sub(lastReward);
        uint256 totalAr = arNxm.totalSupply();

         
        uint256 oneAmount = ( totalN.mul(1e18) ).div(totalAr);
        nAmount = _arAmount.mul(oneAmount).div(1e18);
    }

     
    function aum()
      public
      view
    returns (uint256 aumTotal)
    {
        IPooledStaking pool = IPooledStaking( _getPool() );
        uint256 balance = nxm.balanceOf( address(this) );
        uint256 stakeDeposit = pool.stakerDeposit( address(this) );
        aumTotal = balance.add(stakeDeposit);
    }

     
    function stakedNxm()
      public
      view
    returns (uint256 staked)
    {
        IPooledStaking pool = IPooledStaking( _getPool() );
        staked = pool.stakerDeposit( address(this) );
    }

     
    function currentReward()
      external
      view
    returns (uint256 reward)
    {
        reward = _currentReward();
    }

     
    function pauseWithdrawals(uint256 _claimId)
      external
    {
        IClaimsData claimsData = IClaimsData( _getClaimsData() );

        ( , uint256 status) = claimsData.getClaimStatusNumber(_claimId);
        uint256 dateUpdate = claimsData.getClaimDateUpd(_claimId);

         
        if (status == 14 && block.timestamp.sub(dateUpdate) <= 7 days) {
            withdrawalsPaused = block.timestamp;
        }
    }

     
    function alertTransfer(address _from, address _to, uint256 _amount)
      external
    {
        require(msg.sender == address(arNxm), "Sender must be the token contract.");

         
        if ( referrers[_from] != address(0) ) rewardManager.withdraw(referrers[_from], _from, _amount);
        if ( referrers[_to] != address(0) ) rewardManager.stake(referrers[_to], _to, _amount);
    }

     
    function _getRewardsNxm()
      internal
      returns (uint256 finalReward)
    {
        IPooledStaking pool = IPooledStaking( _getPool() );

         
        uint256 fullReward = pool.stakerReward( address(this) );
        finalReward = _feeRewardsNxm(fullReward);

        pool.withdrawReward( address(this) );
        lastReward = finalReward;
    }

     
    function _feeRewardsNxm(uint256 reward)
      internal
    returns (uint256 userReward)
    {
         
        uint256 adminReward = arNxmValue( reward.mul(adminPercent).div(DENOMINATOR) );
        uint256 referReward = arNxmValue( reward.mul(referPercent).div(DENOMINATOR) );

         
        if (adminReward > 0) {
            arNxm.mint(beneficiary, adminReward);
        }
        if (referReward > 0) {
            arNxm.mint(address(this), referReward);
            rewardManager.notifyRewardAmount(referReward);
        }

        userReward = reward.sub(adminReward).sub(referReward);
    }

     
    function withdrawNxm()
      external
      onlyOwner
    {
        _withdrawNxm();
    }

     
    function unwrapWnxm()
      external
    {
        uint256 balance = wNxm.balanceOf(address(this));
        _unwrapWnxm(balance);
    }

     
    function stakeNxm(address[] calldata _protocols, uint256[] calldata _stakeAmounts) external onlyOwner{
        _stakeNxm(_protocols, _stakeAmounts);
    }

     
    function unstakeNxm(uint256 _lastId, address[] calldata _protocols, uint256[] calldata _unstakeAmounts) external onlyOwner{
        _unstakeNxm(_lastId, _protocols, _unstakeAmounts);
    }
    
     
    function _withdrawNxm()
      internal
      returns (uint256 amount)
    {
        IPooledStaking pool = IPooledStaking( _getPool() );
        amount = pool.stakerMaxWithdrawable( address(this) );
        pool.withdraw(amount);
    }

     
    function _stakeNxm(address[] memory _protocols, uint256[] memory _stakeAmounts)
      internal
      returns (uint256 toStake)
    {
        IPooledStaking pool = IPooledStaking( _getPool() );
        uint256 balance = nxm.balanceOf( address(this) );
         
         
        if (reserveAmount.add(totalPending) > balance) {
            toStake = 0;
        } else {
            toStake = balance.sub(reserveAmount.add(totalPending));
            _approveNxm(_getTokenController(), toStake);
        }

         
        address[] memory currentProtocols = pool.stakerContractsArray(address(this));
         
        for (uint256 i = 0; i < currentProtocols.length; i++) {
            amounts.push(pool.stakerContractStake(address(this), currentProtocols[i]));
            activeProtocols.push(currentProtocols[i]);
        }

         
        for(uint256 i = 0; i < _protocols.length; i++) {
            address protocol = _protocols[i];
            uint256 curIndex = _addressArrayFind(currentProtocols, protocol);
            if(curIndex == type(uint256).max) {
                activeProtocols.push(protocol);
                amounts.push(_stakeAmounts[i]);
            } else {
                amounts[curIndex] += _stakeAmounts[i];
            }
        }
         
        pool.depositAndStake(toStake, activeProtocols, amounts);
        delete activeProtocols;
        delete amounts;
    }

     
    function _unstakeNxm(uint256 _lastId, address[] memory _protocols, uint256[] memory _amounts)
      internal
    {
        IPooledStaking pool = IPooledStaking( _getPool() );
        pool.requestUnstake(_protocols, _amounts, _lastId);
    }

     
    function _protocolUnstakeable(address _protocol, uint256 _unstakeAmount)
      internal
      view
    returns (uint256) {
        IPooledStaking pool = IPooledStaking( _getPool() );
        uint256 stake = pool.stakerContractStake(address(this), _protocol);
        uint256 requested = pool.stakerContractPendingUnstakeTotal(address(this), _protocol);

         
        if (requested >= stake) {
            return 0;
        }

        uint256 available = stake - requested;

        return _unstakeAmount <= available ? _unstakeAmount : available;
    }

     
    function _currentReward()
      internal
      view
    returns (uint256 reward)
    {
        uint256 duration = rewardDuration;
        uint256 timeElapsed = block.timestamp.sub(lastRewardTimestamp);
        if(timeElapsed == 0){
            return 0;
        }

         
        if (timeElapsed >= duration) {
            reward = lastReward;
         
        } else {
             
            uint256 portion = ( duration.mul(1e18) ).div(timeElapsed);
            reward = ( lastReward.mul(1e18) ).div(portion);
        }
    }

     
    function _wrapNxm(uint256 _amount)
      internal
    {
        _approveNxm(address(wNxm), _amount);
        IWNXM(address(wNxm)).wrap(_amount);
    }

     
    function _unwrapWnxm(uint256 _amount)
      internal
    {
        IWNXM(address(wNxm)).unwrap(_amount);
    }

     
    function _approveNxm(address _to, uint256 _amount)
      internal
    {
        nxm.approve( _to, _amount );
    }

     
    function _getPool()
      internal
      view
    returns (address pool)
    {
        pool = nxmMaster.getLatestAddress("PS");
    }

     
    function _getTokenController()
      internal
      view
    returns(address controller)
    {
        controller = nxmMaster.getLatestAddress("TC");
    }

     
    function _getClaimsData()
      internal
      view
    returns (address claimsData)
    {
        claimsData = nxmMaster.getLatestAddress("CD");
    }

    function _addressArrayFind(address[] memory arr, address elem) internal pure returns(uint256 index) {
        for(uint256 i = 0; i<arr.length; i++) {
            if(arr[i] == elem) {
                return i;
            }
        }
        return type(uint256).max;
    }

     

     
    function pullNXM(address _from, uint256 _amount, address _to)
      external
      onlyOwner
    {
        nxm.transferFrom(_from, address(this), _amount);
        _wrapNxm(_amount);
        wNxm.transfer(_to, _amount);
    }

     
    function buyNxmWithEther(uint256 _minNxm)
      external
      payable
    {
        require(msg.sender == 0x1337DEF157EfdeF167a81B3baB95385Ce5A14477, "Sender must be ExchangeManager.");
        INXMPool pool = INXMPool(nxmMaster.getLatestAddress("P1"));
        pool.buyNXM{value:address(this).balance}(_minNxm);
    }

     
    function submitVote(uint256 _proposalId, uint256 _solutionChosen)
      external
      onlyOwner
    {
        address gov = nxmMaster.getLatestAddress("GV");
        IGovernance(gov).submitVote(_proposalId, _solutionChosen);
    }

     
    function rescueToken(address token)
      external
      onlyOwner
    {
        require(token != address(nxm) && token != address(wNxm) && token != address(arNxm), "Cannot rescue NXM-based tokens");
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(msg.sender, balance);
    }

     

     
    function changeReserveAmount(uint256 _reserveAmount)
      external
      onlyOwner
    {
        reserveAmount = _reserveAmount;
    }

     
    function changeReferPercent(uint256 _referPercent)
      external
      onlyOwner
    {
        require(_referPercent <= 500, "Cannot give referrer more than 50% of rewards.");
        referPercent = _referPercent;
    }

     
    function changeWithdrawFee(uint256 _withdrawFee)
      external
      onlyOwner
    {
        require(_withdrawFee <= DENOMINATOR, "Cannot take more than 100% of withdraw");
        withdrawFee = _withdrawFee;
    }

     
    function changeWithdrawDelay(uint256 _withdrawDelay)
      external
      onlyOwner
    {
        withdrawDelay = _withdrawDelay;
    }

     
    function changeAdminPercent(uint256 _adminPercent)
      external
      onlyOwner
    {
        require(_adminPercent <= 500, "Cannot give admin more than 50% of rewards.");
        adminPercent = _adminPercent;
    }

     
    function changeRewardDuration(uint256 _rewardDuration)
      external
      onlyOwner
    {
        require(_rewardDuration <= 30 days, "Reward duration cannot be more than 30 days.");
        rewardDuration = _rewardDuration;
    }

     
    function changePauseDuration(uint256 _pauseDuration)
      external
      onlyOwner
    {
        require(_pauseDuration <= 30 days, "Pause duration cannot be more than 30 days.");
        pauseDuration = _pauseDuration;
    }

     
    function changeBeneficiary(address _newBeneficiary)
      external
      onlyOwner
    {
        beneficiary = _newBeneficiary;
    }

     

    uint256 public lastRewardTimestamp;

     

     
    uint256 private ____deprecated____2;

     
     
    uint256 private ____deprecated____3;

     
    uint256 private ____deprecated____4;

     
    uint256[] private ____deprecated____5;

     
    mapping (address => uint256) public lastCall;

     

     
    uint256 public withdrawFee;

     
    uint256 public withdrawDelay;

     
    uint256 public totalPending;

    mapping (address => WithdrawalRequest) public withdrawals;

}