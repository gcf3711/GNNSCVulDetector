pragma experimental ABIEncoderV2;


contract GovernorBravoDelegatorStorage {
  
  address public admin;

  
  address public pendingAdmin;

  
  address public implementation;
}

pragma solidity ^0.5.16;


// https://etherscan.io/address/0xeF3B6E9e13706A8F01fe98fdCf66335dc5CfdEED#code

// TODO: check the difference between this file and the one located here: 0xc0Da02939E1441F497fd74F78cE7Decb17B66529

contract GovernorBravoEvents {
  
  event ProposalCreated(
    uint id,
    address proposer,
    address[] targets,
    uint[] values,
    string[] signatures,
    bytes[] calldatas,
    uint startBlock,
    uint endBlock,
    string description
  );

  
  
  
  
  
  
  event VoteCast(
    address indexed voter,
    uint proposalId,
    uint8 support,
    uint votes,
    string reason
  );

  
  event ProposalCanceled(uint id);

  
  event ProposalQueued(uint id, uint eta);

  
  event ProposalExecuted(uint id);

  
  event VotingDelaySet(uint oldVotingDelay, uint newVotingDelay);

  
  event VotingPeriodSet(uint oldVotingPeriod, uint newVotingPeriod);

  
  event NewImplementation(address oldImplementation, address newImplementation);

  
  event ProposalThresholdSet(
    uint oldProposalThreshold,
    uint newProposalThreshold
  );

  
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

  
  event NewAdmin(address oldAdmin, address newAdmin);

  
  event WhitelistAccountExpirationSet(address account, uint expiration);

  
  event WhitelistGuardianSet(address oldGuardian, address newGuardian);
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change GovernorBravoDelegateStorageV1. Create a new
 * contract which implements GovernorBravoDelegateStorageV1 and following the naming convention
 * GovernorBravoDelegateStorageVX.
 */
contract GovernorBravoDelegateStorageV1 is GovernorBravoDelegatorStorage {
  
  uint public votingDelay;

  
  uint public votingPeriod;

  
  uint public proposalThreshold;

  
  uint public initialProposalId;

  
  uint public proposalCount;

  
  TimelockInterface public timelock;

  
  CompInterface public comp;

  
  mapping(uint => Proposal) public proposals;

  
  mapping(address => uint) public latestProposalIds;

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
    
    mapping(address => Receipt) receipts;
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
pragma solidity ^0.5.16;




// https://etherscan.io/address/0xc0Da02939E1441F497fd74F78cE7Decb17B66529#code

contract GovernorBravoDelegator is
  GovernorBravoDelegatorStorage,
  GovernorBravoEvents
{
  constructor(
    address timelock_,
    address comp_,
    address admin_,
    address implementation_,
    uint votingPeriod_,
    uint votingDelay_,
    uint proposalThreshold_
  ) public {
    // Admin set to msg.sender for initialization
    admin = msg.sender;

    delegateTo(
      implementation_,
      abi.encodeWithSignature(
        "initialize(address,address,uint256,uint256,uint256)",
        timelock_,
        comp_,
        votingPeriod_,
        votingDelay_,
        proposalThreshold_
      )
    );

    _setImplementation(implementation_);

    admin = admin_;
  }

  /**
   * @notice Called by the admin to update the implementation of the delegator
   * @param implementation_ The address of the new implementation for delegation
   */
  function _setImplementation(address implementation_) public {
    require(
      msg.sender == admin,
      "GovernorBravoDelegator::_setImplementation: admin only"
    );
    require(
      implementation_ != address(0),
      "GovernorBravoDelegator::_setImplementation: invalid implementation address"
    );

    address oldImplementation = implementation;
    implementation = implementation_;

    emit NewImplementation(oldImplementation, implementation);
  }

  /**
   * @notice Internal method to delegate execution to another contract
   * @dev It returns to the external caller whatever the implementation returns or forwards reverts
   * @param callee The contract to delegatecall
   * @param data The raw data to delegatecall
   */
  function delegateTo(address callee, bytes memory data) internal {
    (bool success, bytes memory returnData) = callee.delegatecall(data);
    assembly {
      if eq(success, 0) {
        revert(add(returnData, 0x20), returndatasize)
      }
    }
  }

  /**
   * @dev Delegates execution to an implementation contract.
   * It returns to the external caller whatever the implementation returns
   * or forwards reverts.
   */
  function() external payable {
    // delegate all other functions to current implementation
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
}

contract GovernorBravoDelegateStorageV2 is GovernorBravoDelegateStorageV1 {
  
  mapping(address => uint) public whitelistAccountExpirations;

  
  address public whitelistGuardian;
}

interface TimelockInterface {
  function delay() external view returns (uint);

  function GRACE_PERIOD() external view returns (uint);

  function acceptAdmin() external;

  function queuedTransactions(bytes32 hash) external view returns (bool);

  function queueTransaction(
    address target,
    uint value,
    string calldata signature,
    bytes calldata data,
    uint eta
  ) external returns (bytes32);

  function cancelTransaction(
    address target,
    uint value,
    string calldata signature,
    bytes calldata data,
    uint eta
  ) external;

  function executeTransaction(
    address target,
    uint value,
    string calldata signature,
    bytes calldata data,
    uint eta
  ) external payable returns (bytes memory);
}

interface CompInterface {
  function getPriorVotes(
    address account,
    uint blockNumber
  ) external view returns (uint96);
}

interface GovernorAlpha {
  
  function proposalCount() external returns (uint);
}