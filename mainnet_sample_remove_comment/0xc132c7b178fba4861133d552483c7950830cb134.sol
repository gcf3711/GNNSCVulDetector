
 

pragma solidity ^0.5.12;


 
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

 
interface IDPR {
    function transferFrom(address _spender, address _to, uint256 _amount) external returns(bool);
    function transfer(address _to, uint256 _amount) external returns(bool);
    function balanceOf(address _owner) external view returns(uint256);
}

contract MerkleClaim {
    using SafeMath for uint256;

    bytes32 public root;
    IDPR public dpr;
     
    address public owner;
    uint256 public total_release_periods = 90;
    uint256 public start_time = 1631548800;  
     
    mapping(address=>uint256) public total_lock_amount;
    mapping(address=>uint256) public release_per_period;
    mapping(address=>uint256) public user_released;
    mapping(bytes32=>bool) public claimMap;
    mapping(address=>bool) public userMap;
     
    event claim(address _addr, uint256 _amount);
    event distribute(address _addr, uint256 _amount);
    event OwnerTransfer(address _newOwner);

     
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    constructor(bytes32 _root, address _token) public{
        root = _root;
        dpr = IDPR(_token);
        owner = msg.sender;
    }

    function transferOwnerShip(address _newOwner) onlyOwner external {
        require(_newOwner != address(0), "MerkleClaim: Wrong owner");
        owner = _newOwner;
        emit OwnerTransfer(_newOwner);
    }

    function setClaim(bytes32 node) private {
        claimMap[node] = true;
    }

    function distributeAndLock(address _addr, uint256 _amount, bytes32[]  memory proof) public{
        require(!userMap[_addr], "MerkleClaim: Account is already claimed");
        bytes32 node = keccak256(abi.encodePacked(_addr, _amount));
        require(!claimMap[node], "MerkleClaim: Account is already claimed");
        require(MerkleProof.verify(proof, root, node), "MerkleClaim: Verify failed");
         
        setClaim(node);
        uint256 half_amount = _amount.div(2);
        dpr.transfer(_addr, half_amount);
        lockTokens(_addr, _amount.sub(half_amount));
        userMap[_addr] = true;
        emit distribute(_addr, _amount);
    }

    function lockTokens(address _addr, uint256 _amount) private{
        total_lock_amount[_addr] = _amount;
        release_per_period[_addr] = _amount.div(total_release_periods);
    }

    function claimTokens() external {
        require(total_lock_amount[msg.sender] != 0, "User does not have lock record");
        require(total_lock_amount[msg.sender].sub(user_released[msg.sender]) > 0, "all token has been claimed");
        uint256 periods = block.timestamp.sub(start_time).div(1 days);
        uint256 total_release_amount = release_per_period[msg.sender].mul(periods);
        
        if(total_release_amount >= total_lock_amount[msg.sender]){
            total_release_amount = total_lock_amount[msg.sender];
        }

        uint256 release_amount = total_release_amount.sub(user_released[msg.sender]);
         
        user_released[msg.sender] = total_release_amount;
        require(dpr.balanceOf(address(this)) >= release_amount, "MerkleClaim: Balance not enough");
        require(dpr.transfer(msg.sender, release_amount), "MerkleClaim: Transfer Failed");    
        emit claim(msg.sender, release_amount);
    }

    function unreleased() external view returns(uint256){
        return total_lock_amount[msg.sender].sub(user_released[msg.sender]);
    }

    function withdraw(address _to) external onlyOwner{
        require(dpr.transfer(_to, dpr.balanceOf(address(this))), "MerkleClaim: Transfer Failed");
    }

    function pullTokens(uint256 _amount) external onlyOwner{
        require(dpr.transferFrom(owner, address(this), _amount), "MerkleClaim: TransferFrom failed");
    }
}