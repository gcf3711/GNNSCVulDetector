 

 

 

 

 

pragma solidity >=0.6.0 <0.8.0;

 
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


 

pragma solidity ^0.6.0;

 
library MerkleProof {
     
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                 
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                 
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

         
        return computedHash == root;
    }
}


 

pragma solidity >=0.5.0;

 
interface IMerkleDistributor {
     
    function token() external view returns (address);
     
    function merkleRoot() external view returns (bytes32);
     
    function isClaimed(uint256 index) external view returns (bool);
     
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;

     
    event Claimed(uint256 index, address account, uint256 amount);
}


 

pragma solidity =0.6.12;



contract MerkleDistributor is IMerkleDistributor {
    address public immutable override token;
    bytes32 public immutable override merkleRoot;

     
    mapping(uint256 => uint256) private claimedBitMap;
    uint256 public distributeDate;

    address public governance;

    address public pendingGovernance;

    bool public pause;

    event PendingGovernanceUpdated(
      address pendingGovernance
    );

    event GovernanceUpdated(
      address governance
    );

    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address token_, bytes32 merkleRoot_, uint256 distributeDate_, address governance_) public {

      require(governance_ != address(0), "MerkleDistributor: governance address cannot be 0x0");
      governance = governance_;
      pause = true;

      token = token_;
      merkleRoot = merkleRoot_;
      distributeDate = distributeDate_;
    }

    modifier onlyGovernance() {
      require(msg.sender == governance, "MerkleDistributor: only governance");
      _;
    }

    function setPendingGovernance(address _pendingGovernance) external onlyGovernance {
      require(_pendingGovernance != address(0), "MerkleDistributor: pending governance address cannot be 0x0");
      pendingGovernance = _pendingGovernance;

      emit PendingGovernanceUpdated(_pendingGovernance);
    }

    function acceptGovernance() external {
      require(msg.sender == pendingGovernance, "MerkleDistributor: only pending governance");

      address _pendingGovernance = pendingGovernance;
      governance = _pendingGovernance;

      emit GovernanceUpdated(_pendingGovernance);
    }

    function setPause(bool _pause) external onlyGovernance {
      pause = _pause;
    }

    function emergencyWithdraw(address transferTo) external onlyGovernance {
        require(pause == true, "MerkleDistributor: not paused");
        uint256 rewardAmount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(transferTo, rewardAmount);
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        require(
            pause == false,
            "MerkleDistributor: withdraw paused"
        );

        require(
            block.timestamp >= distributeDate,
            "MerkleDistributor: not start yet"
        );

         
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

         
        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(index, account, amount);
    }
}