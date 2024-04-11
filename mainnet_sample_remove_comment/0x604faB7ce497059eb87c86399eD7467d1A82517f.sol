 
pragma experimental ABIEncoderV2;

 

 

pragma solidity ^0.6.12;

 
interface IHordCongressMembersRegistry {
    function isMember(address _address) external view returns (bool);
    function getMinimalQuorum() external view returns (uint256);
}


 

 

pragma solidity >=0.6.0 <0.8.0;

 
library SafeMath {
     
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

     
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

     
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
         
         
         
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

     
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

     
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

     
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

     
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

     
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

     
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


 

pragma solidity ^0.6.12;



 
contract HordCongress {
     
    using SafeMath for *;

    
    string public constant name = "HordCongress";

     
    IHordCongressMembersRegistry membersRegistry;

    
    uint public proposalCount;

    struct Proposal {
         
        uint id;

         
        address proposer;

         
        address[] targets;

         
        uint[] values;

         
        string[] signatures;

         
        bytes[] calldatas;

         
        uint forVotes;

         
        uint againstVotes;

         
        bool canceled;

         
        bool executed;

         
        uint timestamp;

         
        mapping (address => Receipt) receipts;
    }

    
    struct Receipt {
         
        bool hasVoted;

         
        bool support;
    }

    
    mapping (uint => Proposal) public proposals;

    
    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, string description);

    
    event VoteCast(address voter, uint proposalId, bool support);

    
    event ProposalCanceled(uint id);

    
    event ProposalExecuted(uint id);

    
    event ReceivedEther(address sender, uint amount);

    
    event ExecuteTransaction(address indexed target, uint value, string signature,  bytes data);

    modifier onlyMember {
        require(membersRegistry.isMember(msg.sender) == true, "Only HordCongress member can call this function");
        _;
    }

     
    function setMembersRegistry(
        address _membersRegistry
    )
    external
    {
        require(address(membersRegistry) == address(0x0));
        membersRegistry = IHordCongressMembersRegistry(_membersRegistry);
    }

    function propose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    )
    external
    onlyMember
    returns (uint)
    {
        require(
            targets.length == values.length &&
            targets.length == signatures.length &&
            targets.length == calldatas.length,
            "HordCongress::propose: proposal function information arity mismatch"
        );

        require(targets.length != 0, "HordCongress::propose: must provide actions");

        proposalCount++;

        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            targets: targets,
            values: values,
            signatures: signatures,
            calldatas: calldatas,
            forVotes: 0,
            againstVotes: 0,
            canceled: false,
            executed: false,
            timestamp: block.timestamp
        });

        proposals[newProposal.id] = newProposal;

        emit ProposalCreated(newProposal.id, msg.sender, targets, values, signatures, calldatas, description);
        return newProposal.id;
    }


    function castVote(
        uint proposalId,
        bool support
    )
    external
    onlyMember
    {
        return _castVote(msg.sender, proposalId, support);
    }


    function execute(
        uint proposalId
    )
    external
    onlyMember
    payable
    {
         
        Proposal storage proposal = proposals[proposalId];
         
        require(proposal.executed == false && proposal.canceled == false);
         
        proposal.executed = true;
         
        require(proposal.forVotes >= membersRegistry.getMinimalQuorum());

        for (uint i = 0; i < proposal.targets.length; i++) {
            bytes memory callData;

            if (bytes(proposal.signatures[i]).length == 0) {
                callData = proposal.calldatas[i];
            } else {
                callData = abi.encodePacked(bytes4(keccak256(bytes(proposal.signatures[i]))), proposal.calldatas[i]);
            }

             
            (bool success,) = proposal.targets[i].call.value(proposal.values[i])(callData);

             
            require(success, "HordCongress::executeTransaction: Transaction execution reverted.");

             
            emit ExecuteTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i]);
        }

         
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint proposalId) external onlyMember {
        Proposal storage proposal = proposals[proposalId];
         
        require(proposal.executed == false && proposal.canceled == false);
         
        require(block.timestamp >= proposal.timestamp + 259200);
         
        require(proposal.forVotes < membersRegistry.getMinimalQuorum(), "HordCongress:cancel: Proposal already reached quorum");
         
        proposal.canceled = true;
         
        emit ProposalCanceled(proposalId);
    }

    function _castVote(address voter, uint proposalId, bool support) internal {
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "HordCongress::_castVote: voter already voted");

        if (support) {
            proposal.forVotes = proposal.forVotes.add(1);
        } else {
            proposal.againstVotes = proposal.againstVotes.sub(1);
        }

        receipt.hasVoted = true;
        receipt.support = support;

        emit VoteCast(voter, proposalId, support);
    }

    function getActions(uint proposalId) external view returns (address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas) {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    function getMembersRegistry()
    external
    view
    returns (address)
    {
        return address(membersRegistry);
    }

    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }
}