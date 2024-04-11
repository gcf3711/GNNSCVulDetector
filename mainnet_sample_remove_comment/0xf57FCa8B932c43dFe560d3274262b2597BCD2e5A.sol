 


 
pragma solidity ^0.7.0;

 
contract Owned {

  address payable public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
    address indexed from,
    address indexed to
  );

  constructor() {
    owner = msg.sender;
  }

   
  function transferOwnership(address _to)
    external
    onlyOwner()
  {
    pendingOwner = _to;

    emit OwnershipTransferRequested(owner, _to);
  }

   
  function acceptOwnership()
    external
  {
    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

   
  modifier onlyOwner() {
    require(msg.sender == owner, "Only callable by owner");
    _;
  }

}

 
pragma solidity ^0.7.0;

interface AccessControllerInterface {
  function hasAccess(address user, bytes calldata data) external view returns (bool);
}

 
pragma solidity ^0.7.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

 
pragma solidity ^0.7.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

   
   
   
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

 
pragma solidity ^0.7.0;




interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{
}

 
pragma solidity ^0.7.0;





 
contract OffchainAggregatorBilling is Owned {

   
  uint256 constant internal maxNumOracles = 31;

   
  struct Billing {

     
    uint32 maximumGasPrice;

     
    uint32 reasonableGasPrice;

     
     
    uint32 microLinkPerEth;

     
    uint32 linkGweiPerObservation;

     
    uint32 linkGweiPerTransmission;
  }
  Billing internal s_billing;

   
  LinkTokenInterface immutable public LINK;

  AccessControllerInterface internal s_billingAccessController;

   
   
   
   
   
   
   
   
   
  uint16[maxNumOracles] internal s_oracleObservationsCounts;

   
  mapping (address   => address  )
    internal
    s_payees;

   
  mapping (address   => address  )
    internal
    s_proposedPayees;

   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
  uint256[maxNumOracles] internal s_gasReimbursementsLinkWei;

   
   
  enum Role {
     
    Unset,
     
     
    Signer,
     
     
     
    Transmitter
  }

  struct Oracle {
    uint8 index;  
    Role role;    
  }

  mapping (address   => Oracle)
    internal s_oracles;

   
  address[] internal s_signers;

   
   
  address[] internal s_transmitters;

  uint256 constant private  maxUint16 = (1 << 16) - 1;
  uint256 constant internal maxUint128 = (1 << 128) - 1;

  constructor(
    uint32 _maximumGasPrice,
    uint32 _reasonableGasPrice,
    uint32 _microLinkPerEth,
    uint32 _linkGweiPerObservation,
    uint32 _linkGweiPerTransmission,
    address _link,
    AccessControllerInterface _billingAccessController
  )
  {
    setBillingInternal(_maximumGasPrice, _reasonableGasPrice, _microLinkPerEth,
      _linkGweiPerObservation, _linkGweiPerTransmission);
    setBillingAccessControllerInternal(_billingAccessController);
    LINK = LinkTokenInterface(_link);
    uint16[maxNumOracles] memory counts;  
    uint256[maxNumOracles] memory gas;  
    for (uint8 i = 0; i < maxNumOracles; i++) {
      counts[i] = 1;
      gas[i] = 1;
    }
    s_oracleObservationsCounts = counts;
    s_gasReimbursementsLinkWei = gas;

  }

   
  event BillingSet(
    uint32 maximumGasPrice,
    uint32 reasonableGasPrice,
    uint32 microLinkPerEth,
    uint32 linkGweiPerObservation,
    uint32 linkGweiPerTransmission
  );

  function setBillingInternal(
    uint32 _maximumGasPrice,
    uint32 _reasonableGasPrice,
    uint32 _microLinkPerEth,
    uint32 _linkGweiPerObservation,
    uint32 _linkGweiPerTransmission
  )
    internal
  {
    s_billing = Billing(_maximumGasPrice, _reasonableGasPrice, _microLinkPerEth,
      _linkGweiPerObservation, _linkGweiPerTransmission);
    emit BillingSet(_maximumGasPrice, _reasonableGasPrice, _microLinkPerEth,
      _linkGweiPerObservation, _linkGweiPerTransmission);
  }

   
  function setBilling(
    uint32 _maximumGasPrice,
    uint32 _reasonableGasPrice,
    uint32 _microLinkPerEth,
    uint32 _linkGweiPerObservation,
    uint32 _linkGweiPerTransmission
  )
    external
  {
    AccessControllerInterface access = s_billingAccessController;
    require(msg.sender == owner || access.hasAccess(msg.sender, msg.data),
      "Only owner&billingAdmin can call");
    payOracles();
    setBillingInternal(_maximumGasPrice, _reasonableGasPrice, _microLinkPerEth,
      _linkGweiPerObservation, _linkGweiPerTransmission);
  }

   
  function getBilling()
    external
    view
    returns (
      uint32 maximumGasPrice,
      uint32 reasonableGasPrice,
      uint32 microLinkPerEth,
      uint32 linkGweiPerObservation,
      uint32 linkGweiPerTransmission
    )
  {
    Billing memory billing = s_billing;
    return (
      billing.maximumGasPrice,
      billing.reasonableGasPrice,
      billing.microLinkPerEth,
      billing.linkGweiPerObservation,
      billing.linkGweiPerTransmission
    );
  }

   
  event BillingAccessControllerSet(AccessControllerInterface old, AccessControllerInterface current);

  function setBillingAccessControllerInternal(AccessControllerInterface _billingAccessController)
    internal
  {
    AccessControllerInterface oldController = s_billingAccessController;
    if (_billingAccessController != oldController) {
      s_billingAccessController = _billingAccessController;
      emit BillingAccessControllerSet(
        oldController,
        _billingAccessController
      );
    }
  }

   
  function setBillingAccessController(AccessControllerInterface _billingAccessController)
    external
    onlyOwner
  {
    setBillingAccessControllerInternal(_billingAccessController);
  }

   
  function billingAccessController()
    external
    view
    returns (AccessControllerInterface)
  {
    return s_billingAccessController;
  }

   
  function withdrawPayment(address _transmitter)
    external
  {
    require(msg.sender == s_payees[_transmitter], "Only payee can withdraw");
    payOracle(_transmitter);
  }

   
  function owedPayment(address _transmitter)
    public
    view
    returns (uint256)
  {
    Oracle memory oracle = s_oracles[_transmitter];
    if (oracle.role == Role.Unset) { return 0; }
    Billing memory billing = s_billing;
    uint256 linkWeiAmount =
      uint256(s_oracleObservationsCounts[oracle.index] - 1) *
      uint256(billing.linkGweiPerObservation) *
      (1 gwei);
    linkWeiAmount += s_gasReimbursementsLinkWei[oracle.index] - 1;
    return linkWeiAmount;
  }

   
  event OraclePaid(address transmitter, address payee, uint256 amount);

   
  function payOracle(address _transmitter)
    internal
  {
    Oracle memory oracle = s_oracles[_transmitter];
    uint256 linkWeiAmount = owedPayment(_transmitter);
    if (linkWeiAmount > 0) {
      address payee = s_payees[_transmitter];
       
       
      require(LINK.transfer(payee, linkWeiAmount), "insufficient funds");
      s_oracleObservationsCounts[oracle.index] = 1;  
      s_gasReimbursementsLinkWei[oracle.index] = 1;  
      emit OraclePaid(_transmitter, payee, linkWeiAmount);
    }
  }

   
   
   
   
  function payOracles()
    internal
  {
    Billing memory billing = s_billing;
    uint16[maxNumOracles] memory observationsCounts = s_oracleObservationsCounts;
    uint256[maxNumOracles] memory gasReimbursementsLinkWei =
      s_gasReimbursementsLinkWei;
    address[] memory transmitters = s_transmitters;
    for (uint transmitteridx = 0; transmitteridx < transmitters.length; transmitteridx++) {
      uint256 reimbursementAmountLinkWei = gasReimbursementsLinkWei[transmitteridx] - 1;
      uint256 obsCount = observationsCounts[transmitteridx] - 1;
      uint256 linkWeiAmount =
        obsCount * uint256(billing.linkGweiPerObservation) * (1 gwei) + reimbursementAmountLinkWei;
      if (linkWeiAmount > 0) {
          address payee = s_payees[transmitters[transmitteridx]];
           
           
          require(LINK.transfer(payee, linkWeiAmount), "insufficient funds");
          observationsCounts[transmitteridx] = 1;        
          gasReimbursementsLinkWei[transmitteridx] = 1;  
          emit OraclePaid(transmitters[transmitteridx], payee, linkWeiAmount);
        }
    }
     
    s_oracleObservationsCounts = observationsCounts;
    s_gasReimbursementsLinkWei = gasReimbursementsLinkWei;
  }

  function oracleRewards(
    bytes memory observers,
    uint16[maxNumOracles] memory observations
  )
    internal
    pure
    returns (uint16[maxNumOracles] memory)
  {
     
    for (uint obsIdx = 0; obsIdx < observers.length; obsIdx++) {
      uint8 observer = uint8(observers[obsIdx]);
      observations[observer] = saturatingAddUint16(observations[observer], 1);
    }
    return observations;
  }

   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
  uint256 internal constant accountingGasCost = 6035;

   
   
   
   
   

   
  function impliedGasPrice(
    uint256 txGasPrice,          
    uint256 reasonableGasPrice,  
    uint256 maximumGasPrice      
  )
    internal
    pure
    returns (uint256)
  {
     
     
     
     
    uint256 gasPrice = txGasPrice;
    if (txGasPrice < reasonableGasPrice) {
       
      gasPrice += (reasonableGasPrice - txGasPrice) / 2;
    }
     
    return min(gasPrice, maximumGasPrice);
  }

   
   
   
   
  function transmitterGasCostEthWei(
    uint256 initialGas,
    uint256 gasPrice,  
    uint256 callDataCost,  
    uint256 gasLeft
  )
    internal
    pure
    returns (uint128 gasCostEthWei)
  {
    require(initialGas >= gasLeft, "gasLeft cannot exceed initialGas");
    uint256 gasUsed =  
      initialGas - gasLeft +  
      callDataCost + accountingGasCost;  
     
    uint256 fullGasCostEthWei = gasUsed * gasPrice * (1 gwei);
    assert(fullGasCostEthWei < maxUint128);  
    return uint128(fullGasCostEthWei);
  }

   
  function withdrawFunds(address _recipient, uint256 _amount)
    external
  {
    require(msg.sender == owner || s_billingAccessController.hasAccess(msg.sender, msg.data),
      "Only owner&billingAdmin can call");
    uint256 linkDue = totalLINKDue();
    uint256 linkBalance = LINK.balanceOf(address(this));
    require(linkBalance >= linkDue, "insufficient balance");
    require(LINK.transfer(_recipient, min(linkBalance - linkDue, _amount)), "insufficient funds");
  }

   
  function totalLINKDue()
    internal
    view
    returns (uint256 linkDue)
  {
     
     
     
     
     
     
     
     
     
    uint16[maxNumOracles] memory observationCounts = s_oracleObservationsCounts;
    for (uint i = 0; i < maxNumOracles; i++) {
      linkDue += observationCounts[i] - 1;  
    }
    Billing memory billing = s_billing;
     
    linkDue *= uint256(billing.linkGweiPerObservation) * (1 gwei);
    address[] memory transmitters = s_transmitters;
    uint256[maxNumOracles] memory gasReimbursementsLinkWei =
      s_gasReimbursementsLinkWei;
    for (uint i = 0; i < transmitters.length; i++) {
      linkDue += uint256(gasReimbursementsLinkWei[i]-1);  
    }
  }

   
  function linkAvailableForPayment()
    external
    view
    returns (int256 availableBalance)
  {
     
    int256 balance = int256(LINK.balanceOf(address(this)));
     
     
    int256 due = int256(totalLINKDue());
     
    return int256(balance) - int256(due);
  }

   
  function oracleObservationCount(address _signerOrTransmitter)
    external
    view
    returns (uint16)
  {
    Oracle memory oracle = s_oracles[_signerOrTransmitter];
    if (oracle.role == Role.Unset) { return 0; }
    return s_oracleObservationsCounts[oracle.index] - 1;
  }


  function reimburseAndRewardOracles(
    uint32 initialGas,
    bytes memory observers
  )
    internal
  {
    Oracle memory txOracle = s_oracles[msg.sender];
    Billing memory billing = s_billing;
     
     
    s_oracleObservationsCounts =
      oracleRewards(observers, s_oracleObservationsCounts);
     
    require(txOracle.role == Role.Transmitter,
      "sent by undesignated transmitter"
    );
    uint256 gasPrice = impliedGasPrice(
      tx.gasprice / (1 gwei),  
      billing.reasonableGasPrice,
      billing.maximumGasPrice
    );
     
     
    uint256 callDataGasCost = 16 * msg.data.length;
     
     
    uint256 gasLeft = gasleft();
    uint256 gasCostEthWei = transmitterGasCostEthWei(
      uint256(initialGas),
      gasPrice,
      callDataGasCost,
      gasLeft
    );

     
     
     
     
     
     
    uint256 gasCostLinkWei = (gasCostEthWei * billing.microLinkPerEth)/ 1e6;

     
     
     
    s_gasReimbursementsLinkWei[txOracle.index] =
      s_gasReimbursementsLinkWei[txOracle.index] + gasCostLinkWei +
      uint256(billing.linkGweiPerTransmission) * (1 gwei);  

     
     
     
     
  }

   

   
  event PayeeshipTransferRequested(
    address indexed transmitter,
    address indexed current,
    address indexed proposed
  );

   
  event PayeeshipTransferred(
    address indexed transmitter,
    address indexed previous,
    address indexed current
  );

   
  function setPayees(
    address[] calldata _transmitters,
    address[] calldata _payees
  )
    external
    onlyOwner()
  {
    require(_transmitters.length == _payees.length, "transmitters.size != payees.size");

    for (uint i = 0; i < _transmitters.length; i++) {
      address transmitter = _transmitters[i];
      address payee = _payees[i];
      address currentPayee = s_payees[transmitter];
      bool zeroedOut = currentPayee == address(0);
      require(zeroedOut || currentPayee == payee, "payee already set");
      s_payees[transmitter] = payee;

      if (currentPayee != payee) {
        emit PayeeshipTransferred(transmitter, currentPayee, payee);
      }
    }
  }

   
  function transferPayeeship(
    address _transmitter,
    address _proposed
  )
    external
  {
      require(msg.sender == s_payees[_transmitter], "only current payee can update");
      require(msg.sender != _proposed, "cannot transfer to self");

      address previousProposed = s_proposedPayees[_transmitter];
      s_proposedPayees[_transmitter] = _proposed;

      if (previousProposed != _proposed) {
        emit PayeeshipTransferRequested(_transmitter, msg.sender, _proposed);
      }
  }

   
  function acceptPayeeship(
    address _transmitter
  )
    external
  {
    require(msg.sender == s_proposedPayees[_transmitter], "only proposed payees can accept");

    address currentPayee = s_payees[_transmitter];
    s_payees[_transmitter] = msg.sender;
    s_proposedPayees[_transmitter] = address(0);

    emit PayeeshipTransferred(_transmitter, currentPayee, msg.sender);
  }

   

  function saturatingAddUint16(uint16 _x, uint16 _y)
    internal
    pure
    returns (uint16)
  {
    return uint16(min(uint256(_x)+uint256(_y), maxUint16));
  }

  function min(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
  {
    if (a < b) { return a; }
    return b;
  }
}

 
pragma solidity ^0.7.0;




 
contract SimpleWriteAccessController is AccessControllerInterface, Owned {

  bool public checkEnabled;
  mapping(address => bool) internal accessList;

  event AddedAccess(address user);
  event RemovedAccess(address user);
  event CheckAccessEnabled();
  event CheckAccessDisabled();

  constructor()
  {
    checkEnabled = true;
  }

   
  function hasAccess(
    address _user,
    bytes memory
  )
    public
    view
    virtual
    override
    returns (bool)
  {
    return accessList[_user] || !checkEnabled;
  }

   
  function addAccess(address _user) external onlyOwner() {
    addAccessInternal(_user);
  }

  function addAccessInternal(address _user) internal {
    if (!accessList[_user]) {
      accessList[_user] = true;
      emit AddedAccess(_user);
    }
  }

   
  function removeAccess(address _user)
    external
    onlyOwner()
  {
    if (accessList[_user]) {
      accessList[_user] = false;

      emit RemovedAccess(_user);
    }
  }

   
  function enableAccessCheck()
    external
    onlyOwner()
  {
    if (!checkEnabled) {
      checkEnabled = true;

      emit CheckAccessEnabled();
    }
  }

   
  function disableAccessCheck()
    external
    onlyOwner()
  {
    if (checkEnabled) {
      checkEnabled = false;

      emit CheckAccessDisabled();
    }
  }

   
  modifier checkAccess() {
    require(hasAccess(msg.sender, msg.data), "No access");
    _;
  }
}
 
pragma solidity ^0.7.0;








 
contract OffchainAggregator is Owned, OffchainAggregatorBilling, AggregatorV2V3Interface {

  uint256 constant private maxUint32 = (1 << 32) - 1;

   
   
   
  struct HotVars {
     
     
     
    bytes16 latestConfigDigest;
    uint40 latestEpochAndRound;  
     
     
    uint8 threshold;
     
     
     
     
    uint32 latestAggregatorRoundId;
  }
  HotVars internal s_hotVars;

   
   
  struct Transmission {
    int192 answer;  
    uint64 timestamp;
  }
  mapping(uint32   => Transmission) internal s_transmissions;

   
   
  uint32 internal s_configCount;
  uint32 internal s_latestConfigBlockNumber;  
                                              

   
  int192 immutable public minAnswer;
   
  int192 immutable public maxAnswer;

   
  constructor(
    uint32 _maximumGasPrice,
    uint32 _reasonableGasPrice,
    uint32 _microLinkPerEth,
    uint32 _linkGweiPerObservation,
    uint32 _linkGweiPerTransmission,
    address _link,
    address _validator,
    int192 _minAnswer,
    int192 _maxAnswer,
    AccessControllerInterface _billingAccessController,
    AccessControllerInterface _requesterAccessController,
    uint8 _decimals,
    string memory _description
  )
    OffchainAggregatorBilling(_maximumGasPrice, _reasonableGasPrice, _microLinkPerEth,
      _linkGweiPerObservation, _linkGweiPerTransmission, _link,
      _billingAccessController
    )
  {
    decimals = _decimals;
    s_description = _description;
    setRequesterAccessController(_requesterAccessController);
    setValidator(_validator);
    minAnswer = _minAnswer;
    maxAnswer = _maxAnswer;
  }

   

   
  event ConfigSet(
    uint32 previousConfigBlockNumber,
    uint64 configCount,
    address[] signers,
    address[] transmitters,
    uint8 threshold,
    uint64 encodedConfigVersion,
    bytes encoded
  );

   
  modifier checkConfigValid (
    uint256 _numSigners, uint256 _numTransmitters, uint256 _threshold
  ) {
    require(_numSigners <= maxNumOracles, "too many signers");
    require(_threshold > 0, "threshold must be positive");
    require(
      _numSigners == _numTransmitters,
      "oracle addresses out of registration"
    );
    require(_numSigners > 3*_threshold, "faulty-oracle threshold too high");
    _;
  }

   
  function setConfig(
    address[] calldata _signers,
    address[] calldata _transmitters,
    uint8 _threshold,
    uint64 _encodedConfigVersion,
    bytes calldata _encoded
  )
    external
    checkConfigValid(_signers.length, _transmitters.length, _threshold)
    onlyOwner()
  {
    while (s_signers.length != 0) {  
      uint lastIdx = s_signers.length - 1;
      address signer = s_signers[lastIdx];
      address transmitter = s_transmitters[lastIdx];
      payOracle(transmitter);
      delete s_oracles[signer];
      delete s_oracles[transmitter];
      s_signers.pop();
      s_transmitters.pop();
    }

    for (uint i = 0; i < _signers.length; i++) {  
      require(
        s_oracles[_signers[i]].role == Role.Unset,
        "repeated signer address"
      );
      s_oracles[_signers[i]] = Oracle(uint8(i), Role.Signer);
      require(s_payees[_transmitters[i]] != address(0), "payee must be set");
      require(
        s_oracles[_transmitters[i]].role == Role.Unset,
        "repeated transmitter address"
      );
      s_oracles[_transmitters[i]] = Oracle(uint8(i), Role.Transmitter);
      s_signers.push(_signers[i]);
      s_transmitters.push(_transmitters[i]);
    }
    s_hotVars.threshold = _threshold;
    uint32 previousConfigBlockNumber = s_latestConfigBlockNumber;
    s_latestConfigBlockNumber = uint32(block.number);
    s_configCount += 1;
    uint64 configCount = s_configCount;
    {
      s_hotVars.latestConfigDigest = configDigestFromConfigData(
        address(this),
        configCount,
        _signers,
        _transmitters,
        _threshold,
        _encodedConfigVersion,
        _encoded
      );
      s_hotVars.latestEpochAndRound = 0;
    }
    emit ConfigSet(
      previousConfigBlockNumber,
      configCount,
      _signers,
      _transmitters,
      _threshold,
      _encodedConfigVersion,
      _encoded
    );
  }

  function configDigestFromConfigData(
    address _contractAddress,
    uint64 _configCount,
    address[] calldata _signers,
    address[] calldata _transmitters,
    uint8 _threshold,
    uint64 _encodedConfigVersion,
    bytes calldata _encodedConfig
  ) internal pure returns (bytes16) {
    return bytes16(keccak256(abi.encode(_contractAddress, _configCount,
      _signers, _transmitters, _threshold, _encodedConfigVersion, _encodedConfig
    )));
  }

   
  function latestConfigDetails()
    external
    view
    returns (
      uint32 configCount,
      uint32 blockNumber,
      bytes16 configDigest
    )
  {
    return (s_configCount, s_latestConfigBlockNumber, s_hotVars.latestConfigDigest);
  }

   
  function transmitters()
    external
    view
    returns(address[] memory)
  {
      return s_transmitters;
  }

   

   
  uint256 private constant VALIDATOR_GAS_LIMIT = 100000;

   
  AggregatorValidatorInterface private s_validator;

   
  event ValidatorUpdated(
    address indexed previous,
    address indexed current
  );

   
  function validator()
    external
    view
    returns (AggregatorValidatorInterface)
  {
    return s_validator;
  }

   
  function setValidator(address _newValidator)
    public
    onlyOwner()
  {
    address previous = address(s_validator);

    if (previous != _newValidator) {
      s_validator = AggregatorValidatorInterface(_newValidator);

      emit ValidatorUpdated(previous, _newValidator);
    }
  }

  function validateAnswer(
    uint32 _aggregatorRoundId,
    int256 _answer
  )
    private
  {
    AggregatorValidatorInterface av = s_validator;  
    if (address(av) == address(0)) return;

    uint32 prevAggregatorRoundId = _aggregatorRoundId - 1;
    int256 prevAggregatorRoundAnswer = s_transmissions[prevAggregatorRoundId].answer;
     
     
    try av.validate{gas: VALIDATOR_GAS_LIMIT}(
      prevAggregatorRoundId,
      prevAggregatorRoundAnswer,
      _aggregatorRoundId,
      _answer
    ) {} catch {}
  }

   

  AccessControllerInterface internal s_requesterAccessController;

   
  event RequesterAccessControllerSet(AccessControllerInterface old, AccessControllerInterface current);

   
  event RoundRequested(address indexed requester, bytes16 configDigest, uint32 epoch, uint8 round);

   
  function requesterAccessController()
    external
    view
    returns (AccessControllerInterface)
  {
    return s_requesterAccessController;
  }

   
  function setRequesterAccessController(AccessControllerInterface _requesterAccessController)
    public
    onlyOwner()
  {
    AccessControllerInterface oldController = s_requesterAccessController;
    if (_requesterAccessController != oldController) {
      s_requesterAccessController = AccessControllerInterface(_requesterAccessController);
      emit RequesterAccessControllerSet(oldController, _requesterAccessController);
    }
  }

   
  function requestNewRound() external returns (uint80) {
    require(msg.sender == owner || s_requesterAccessController.hasAccess(msg.sender, msg.data),
      "Only owner&requester can call");

    HotVars memory hotVars = s_hotVars;

    emit RoundRequested(
      msg.sender,
      hotVars.latestConfigDigest,
      uint32(s_hotVars.latestEpochAndRound >> 8),
      uint8(s_hotVars.latestEpochAndRound)
    );
    return hotVars.latestAggregatorRoundId + 1;
  }

   

   
  event NewTransmission(
    uint32 indexed aggregatorRoundId,
    int192 answer,
    address transmitter,
    int192[] observations,
    bytes observers,
    bytes32 rawReportContext
  );

   
   
  function decodeReport(bytes memory _report)
    internal
    pure
    returns (
      bytes32 rawReportContext,
      bytes32 rawObservers,
      int192[] memory observations
    )
  {
    (rawReportContext, rawObservers, observations) = abi.decode(_report,
      (bytes32, bytes32, int192[]));
  }

   
  struct ReportData {
    HotVars hotVars;  
    bytes observers;  
    int192[] observations;  
    bytes vs;  
    bytes32 rawReportContext;
  }

   
  function latestTransmissionDetails()
    external
    view
    returns (
      bytes16 configDigest,
      uint32 epoch,
      uint8 round,
      int192 latestAnswer,
      uint64 latestTimestamp
    )
  {
    require(msg.sender == tx.origin, "Only callable by EOA");
    return (
      s_hotVars.latestConfigDigest,
      uint32(s_hotVars.latestEpochAndRound >> 8),
      uint8(s_hotVars.latestEpochAndRound),
      s_transmissions[s_hotVars.latestAggregatorRoundId].answer,
      s_transmissions[s_hotVars.latestAggregatorRoundId].timestamp
    );
  }

   
   
   
  uint16 private constant TRANSMIT_MSGDATA_CONSTANT_LENGTH_COMPONENT =
    4 +  
    32 +  
    32 +  
    32 +  
    32 +  
    32 +  
    32 +  
    32 +  
    0;  

  function expectedMsgDataLength(
    bytes calldata _report, bytes32[] calldata _rs, bytes32[] calldata _ss
  ) private pure returns (uint256 length)
  {
     
    return uint256(TRANSMIT_MSGDATA_CONSTANT_LENGTH_COMPONENT) +
      _report.length +  
      _rs.length * 32 +  
      _ss.length * 32 +  
      0;  
  }

   
  function transmit(
     
     
    bytes calldata _report,
    bytes32[] calldata _rs, bytes32[] calldata _ss, bytes32 _rawVs  
  )
    external
  {
    uint256 initialGas = gasleft();  
     
     
     
     
     
     
     
    require(msg.data.length == expectedMsgDataLength(_report, _rs, _ss),
      "transmit message too long");
    ReportData memory r;  
    {
      r.hotVars = s_hotVars;  

      bytes32 rawObservers;
      (r.rawReportContext, rawObservers, r.observations) = abi.decode(
        _report, (bytes32, bytes32, int192[])
      );

       
       
       
       
       

      bytes16 configDigest = bytes16(r.rawReportContext << 88);
      require(
        r.hotVars.latestConfigDigest == configDigest,
        "configDigest mismatch"
      );

      uint40 epochAndRound = uint40(uint256(r.rawReportContext));

       
       
       
       
       
       
      require(r.hotVars.latestEpochAndRound < epochAndRound, "stale report");

      require(_rs.length > r.hotVars.threshold, "not enough signatures");
      require(_rs.length <= maxNumOracles, "too many signatures");
      require(_ss.length == _rs.length, "signatures out of registration");
      require(r.observations.length <= maxNumOracles,
              "num observations out of bounds");
      require(r.observations.length > 2 * r.hotVars.threshold,
              "too few values to trust median");

       
      r.vs = new bytes(_rs.length);
      for (uint8 i = 0; i < _rs.length; i++) {
        r.vs[i] = _rawVs[i];
      }

       
      r.observers = new bytes(r.observations.length);
      bool[maxNumOracles] memory seen;
      for (uint8 i = 0; i < r.observations.length; i++) {
        uint8 observerIdx = uint8(rawObservers[i]);
        require(!seen[observerIdx], "observer index repeated");
        seen[observerIdx] = true;
        r.observers[i] = rawObservers[i];
      }

      Oracle memory transmitter = s_oracles[msg.sender];
      require(  
        transmitter.role == Role.Transmitter &&
        msg.sender == s_transmitters[transmitter.index],
        "unauthorized transmitter"
      );
       
       
      r.hotVars.latestEpochAndRound = epochAndRound;
    }

    {  
      bytes32 h = keccak256(_report);
      bool[maxNumOracles] memory signed;

      Oracle memory o;
      for (uint i = 0; i < _rs.length; i++) {
        address signer = ecrecover(h, uint8(r.vs[i])+27, _rs[i], _ss[i]);
        o = s_oracles[signer];
        require(o.role == Role.Signer, "address not authorized to sign");
        require(!signed[o.index], "non-unique signature");
        signed[o.index] = true;
      }
    }

    {  
      for (uint i = 0; i < r.observations.length - 1; i++) {
        bool inOrder = r.observations[i] <= r.observations[i+1];
        require(inOrder, "observations not sorted");
      }

      int192 median = r.observations[r.observations.length/2];
      require(minAnswer <= median && median <= maxAnswer, "median is out of min-max range");
      r.hotVars.latestAggregatorRoundId++;
      s_transmissions[r.hotVars.latestAggregatorRoundId] =
        Transmission(median, uint64(block.timestamp));

      emit NewTransmission(
        r.hotVars.latestAggregatorRoundId,
        median,
        msg.sender,
        r.observations,
        r.observers,
        r.rawReportContext
      );
       
       
      emit NewRound(
        r.hotVars.latestAggregatorRoundId,
        address(0x0),  
        block.timestamp
      );
      emit AnswerUpdated(
        median,
        r.hotVars.latestAggregatorRoundId,
        block.timestamp
      );

      validateAnswer(r.hotVars.latestAggregatorRoundId, median);
    }
    s_hotVars = r.hotVars;
    assert(initialGas < maxUint32);
    reimburseAndRewardOracles(uint32(initialGas), r.observers);
  }

   

   
  function latestAnswer()
    public
    override
    view
    virtual
    returns (int256)
  {
    return s_transmissions[s_hotVars.latestAggregatorRoundId].answer;
  }

   
  function latestTimestamp()
    public
    override
    view
    virtual
    returns (uint256)
  {
    return s_transmissions[s_hotVars.latestAggregatorRoundId].timestamp;
  }

   
  function latestRound()
    public
    override
    view
    virtual
    returns (uint256)
  {
    return s_hotVars.latestAggregatorRoundId;
  }

   
  function getAnswer(uint256 _roundId)
    public
    override
    view
    virtual
    returns (int256)
  {
    if (_roundId > 0xFFFFFFFF) { return 0; }
    return s_transmissions[uint32(_roundId)].answer;
  }

   
  function getTimestamp(uint256 _roundId)
    public
    override
    view
    virtual
    returns (uint256)
  {
    if (_roundId > 0xFFFFFFFF) { return 0; }
    return s_transmissions[uint32(_roundId)].timestamp;
  }

   

  string constant private V3_NO_DATA_ERROR = "No data present";

   
  uint8 immutable public override decimals;

   
  uint256 constant public override version = 4;

  string internal s_description;

   
  function description()
    public
    override
    view
    virtual
    returns (string memory)
  {
    return s_description;
  }

   
  function getRoundData(uint80 _roundId)
    public
    override
    view
    virtual
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    require(_roundId <= 0xFFFFFFFF, V3_NO_DATA_ERROR);
    Transmission memory transmission = s_transmissions[uint32(_roundId)];
    return (
      _roundId,
      transmission.answer,
      transmission.timestamp,
      transmission.timestamp,
      _roundId
    );
  }

   
  function latestRoundData()
    public
    override
    view
    virtual
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    roundId = s_hotVars.latestAggregatorRoundId;

     
     

    Transmission memory transmission = s_transmissions[uint32(roundId)];
    return (
      roundId,
      transmission.answer,
      transmission.timestamp,
      transmission.timestamp,
      roundId
    );
  }
}

 
pragma solidity ^0.7.1;



 
contract SimpleReadAccessController is SimpleWriteAccessController {

   
  function hasAccess(
    address _user,
    bytes memory _calldata
  )
    public
    view
    virtual
    override
    returns (bool)
  {
    return super.hasAccess(_user, _calldata) || _user == tx.origin;
  }

}
 
pragma solidity ^0.7.1;




 
contract AccessControlledOffchainAggregator is OffchainAggregator, SimpleReadAccessController {

  constructor(
    uint32 _maximumGasPrice,
    uint32 _reasonableGasPrice,
    uint32 _microLinkPerEth,
    uint32 _linkGweiPerObservation,
    uint32 _linkGweiPerTransmission,
    address _link,
    address _validator,
    int192 _minAnswer,
    int192 _maxAnswer,
    AccessControllerInterface _billingAccessController,
    AccessControllerInterface _requesterAccessController,
    uint8 _decimals,
    string memory description
  )
    OffchainAggregator(
      _maximumGasPrice,
      _reasonableGasPrice,
      _microLinkPerEth,
      _linkGweiPerObservation,
      _linkGweiPerTransmission,
      _link,
      _validator,
      _minAnswer,
      _maxAnswer,
      _billingAccessController,
      _requesterAccessController,
      _decimals,
      description
    ) {
    }

   

  
  function latestAnswer()
    public
    override
    view
    checkAccess()
    returns (int256)
  {
    return super.latestAnswer();
  }

  
  function latestTimestamp()
    public
    override
    view
    checkAccess()
    returns (uint256)
  {
    return super.latestTimestamp();
  }

  
  function latestRound()
    public
    override
    view
    checkAccess()
    returns (uint256)
  {
    return super.latestRound();
  }

  
  function getAnswer(uint256 _roundId)
    public
    override
    view
    checkAccess()
    returns (int256)
  {
    return super.getAnswer(_roundId);
  }

  
  function getTimestamp(uint256 _roundId)
    public
    override
    view
    checkAccess()
    returns (uint256)
  {
    return super.getTimestamp(_roundId);
  }

   

  
  function description()
    public
    override
    view
    checkAccess()
    returns (string memory)
  {
    return super.description();
  }

  
  function getRoundData(uint80 _roundId)
    public
    override
    view
    checkAccess()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    return super.getRoundData(_roundId);
  }

  
  function latestRoundData()
    public
    override
    view
    checkAccess()
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    return super.latestRoundData();
  }

}

 
pragma solidity ^0.7.0;

interface AggregatorValidatorInterface {
  function validate(
    uint256 previousRoundId,
    int256 previousAnswer,
    uint256 currentRoundId,
    int256 currentAnswer
  ) external returns (bool);
}

 
pragma solidity ^0.7.1;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);
  function approve(address spender, uint256 value) external returns (bool success);
  function balanceOf(address owner) external view returns (uint256 balance);
  function decimals() external view returns (uint8 decimalPlaces);
  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);
  function increaseApproval(address spender, uint256 subtractedValue) external;
  function name() external view returns (string memory tokenName);
  function symbol() external view returns (string memory tokenSymbol);
  function totalSupply() external view returns (uint256 totalTokensIssued);
  function transfer(address to, uint256 value) external returns (bool success);
  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}
