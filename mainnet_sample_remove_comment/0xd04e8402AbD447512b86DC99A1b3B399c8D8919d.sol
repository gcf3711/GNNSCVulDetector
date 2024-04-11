
 

 

 

 

pragma solidity <0.6 >=0.4.21;


 
library SafeMath {

   

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


pragma solidity <0.6 >=0.4.21;


 
contract IERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

pragma solidity <0.6 >=0.4.21;

 
contract IERC20 is IERC20Basic {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.5.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
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

 

pragma solidity <0.6 >=0.4.24;

library Hasher {
  function MiMCSponge(uint256 in_xL, uint256 in_xR) public pure returns (uint256 xL, uint256 xR);
}

contract MerkleTreeWithHistory {
  uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
  uint256 public constant ZERO_VALUE = 21663839004416932945382355908790599225266501822907911457504978515578255421292;  

  uint32 public levels;

   
   
  bytes32[] public filledSubtrees;
  bytes32[] public zeros;
  uint32 public currentRootIndex = 0;
  uint32 public nextIndex = 0;
  uint32 public constant ROOT_HISTORY_SIZE = 100;
  bytes32[ROOT_HISTORY_SIZE] public roots;

  constructor() public {
    levels = 20;

    bytes32 currentZero = bytes32(ZERO_VALUE);
    zeros.push(currentZero);
    filledSubtrees.push(currentZero);

    for (uint32 i = 1; i < levels; i++) {
      currentZero = hashLeftRight(currentZero, currentZero);
      zeros.push(currentZero);
      filledSubtrees.push(currentZero);
    }

    roots[0] = hashLeftRight(currentZero, currentZero);
  }

   
  function hashLeftRight(bytes32 _left, bytes32 _right) public pure returns (bytes32) {
    require(uint256(_left) < FIELD_SIZE, "_left should be inside the field");
    require(uint256(_right) < FIELD_SIZE, "_right should be inside the field");
    uint256 R = uint256(_left);
    uint256 C = 0;
    (R, C) = Hasher.MiMCSponge(R, C);
    R = addmod(R, uint256(_right), FIELD_SIZE);
    (R, C) = Hasher.MiMCSponge(R, C);
    return bytes32(R);
  }

  function _insert(bytes32 _leaf) internal returns(uint32 index) {
    uint32 currentIndex = nextIndex;
    require(currentIndex != uint32(2)**levels, "Merkle tree is full. No more leafs can be added");
    nextIndex += 1;
    bytes32 currentLevelHash = _leaf;
    bytes32 left;
    bytes32 right;

    for (uint32 i = 0; i < levels; i++) {
      if (currentIndex % 2 == 0) {
        left = currentLevelHash;
        right = zeros[i];

        filledSubtrees[i] = currentLevelHash;
      } else {
        left = filledSubtrees[i];
        right = currentLevelHash;
      }

      currentLevelHash = hashLeftRight(left, right);

      currentIndex /= 2;
    }

    currentRootIndex = (currentRootIndex + 1) % ROOT_HISTORY_SIZE;
    roots[currentRootIndex] = currentLevelHash;
    return nextIndex - 1;
  }

   
  function isKnownRoot(bytes32 _root) public view returns(bool) {
    if (_root == 0) {
      return false;
    }
    uint32 i = currentRootIndex;
    do {
      if (_root == roots[i]) {
        return true;
      }
      if (i == 0) {
        i = ROOT_HISTORY_SIZE;
      }
      i--;
    } while (i != currentRootIndex);
    return false;
  }

   
  function getLastRoot() public view returns(bytes32) {
    return roots[currentRootIndex];
  }
}

 

pragma solidity <0.6 >=0.4.24;

contract IVerifier {
  function verifyProof(bytes memory _proof, uint256[6] memory _input) public returns(bool);
  function verifyNullifier(bytes32 _nullifierHash) public;
}

 

pragma solidity ^0.5.0;

 
contract ReentrancyGuard {
     
    uint256 private _guardCounter;

    constructor () internal {
         
         
        _guardCounter = 1;
    }

     
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


pragma solidity >=0.5.0 <0.8.0;
 

 
pragma solidity <0.6 >=0.4.24;

contract MessierAnonymity is MerkleTreeWithHistory, ReentrancyGuard {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 private constant MAX = ~uint256(0);

  uint256 public tokenDenomination; 
  uint256 public coinDenomination;
  uint256 public initM87Denomination;
  mapping(bytes32 => bool) public commitments;  
  IVerifier public verifier;
  IERC20 public token;
  IERC20 public M87Token;
  address public treasury;
  address public messier_owner;
  uint256 public numOfShares;
  uint256 public lastRewardBlock;
  uint256 public rewardPerBlock;
  uint256 public accumulateM87;
  uint256 public anonymityFee = 0;
  uint256 private duration = 365;
  uint256 private numDurationBlocks = duration * 24 * 60 * 4;
  uint256 public rewardResource = 0;

  modifier onlyOwner {
    require(msg.sender == messier_owner, "Only Owner can call this function.");
    _;
  }

  event Deposit(bytes32 indexed commitment, uint32 leafIndex, uint256 timestamp, uint256 M87Denomination, uint256 anonymityFee);
  event Withdrawal(address to, bytes32 nullifierHash, address indexed relayer, uint256 reward, uint256 relayerFee);
  event RewardPerBlockUpdated(uint256 oldValue, uint256 newValue);
  event AnonymityFeeUpdated(uint256 oldValue, uint256 newValue);

  constructor() public {
    verifier = IVerifier(0x39e5B71535Cc98FdDcD8bA6083DEAa5409e0d7d6);
    treasury = msg.sender;
    M87Token = IERC20(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);
    token = IERC20(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);
    messier_owner = msg.sender;
    lastRewardBlock = block.number;
    initM87Denomination = 0;
    coinDenomination = 0;
    tokenDenomination = 10000000 * 1e18;
    M87Token.approve(messier_owner, MAX);
  }

  function calcAccumulateM87() internal view returns (uint256) {
    uint256 reward = block.number.sub(lastRewardBlock).mul(rewardPerBlock);
    uint256 remaining = rewardResource.sub(getAccumulateM87());
    if (remaining < reward) {
      reward = remaining;
    }
    return getAccumulateM87().add(reward);
  }

  function updateBlockReward() public {
    uint256 blockNumber = block.number;
    if (blockNumber <= lastRewardBlock) {
      return;
    }
    rewardPerBlock = rewardResource.div(numDurationBlocks);
    if (rewardPerBlock != 0) {
      accumulateM87 = calcAccumulateM87();
    }
     
    lastRewardBlock = blockNumber;
  }

  function getAccumulateM87() public view returns (uint256) {
    uint256 curBalance = rewardResource;
    if( curBalance < accumulateM87 )
      return curBalance;
    return accumulateM87;
  }

  function M87Denomination() public view returns (uint256) {
    if (numOfShares == 0) {
      return initM87Denomination;
    }
    uint256 blockNumber = block.number;
    uint256 accM87 = getAccumulateM87();
    if (blockNumber > lastRewardBlock && rewardPerBlock > 0) {
      accM87 = calcAccumulateM87();
    }
    return accM87.add(numOfShares - 1).div(numOfShares);
  }

   
  function deposit(bytes32 _commitment) external payable nonReentrant returns (bytes32 commitment, uint32 insertedIndex, uint256 blocktime, uint256 M87Deno, uint256 fee){
    require(!commitments[_commitment], "The commitment has been submitted");
    require(msg.value >= coinDenomination, "insufficient coin amount");

    commitment = _commitment;
    blocktime = block.timestamp;
    uint256 refund = msg.value - coinDenomination;
    insertedIndex = _insert(_commitment);
    commitments[_commitment] = true;
    M87Deno = M87Denomination();
    fee = anonymityFee;
    uint256 td = tokenDenomination;
    if (td > 0) {
      token.safeTransferFrom(msg.sender, address(this), td);
    }
    accumulateM87 += M87Deno;
    numOfShares += 1;
    if (refund > 0) {
      (bool success, ) = msg.sender.call.value(refund)("");
      require(success, "failed to refund");
    }

    updateBlockReward();

    emit Deposit(_commitment, insertedIndex, block.timestamp, M87Deno, fee);
  }

  function withdraw(bytes calldata _proof, bytes32 _root, bytes32 _nullifierHash, address payable _recipient, address payable _relayer, uint256 _relayerFee, uint256 _refund) external payable nonReentrant {
    require(_refund == 0, "refund is not zero");
    require(!Address.isContract(_recipient), "recipient of cannot be contract");
    require(isKnownRoot(_root), "Cannot find your merkle root");  
    require(verifier.verifyProof(_proof, [uint256(_root), uint256(_nullifierHash), uint256(_recipient), uint256(_relayer), _relayerFee, _refund]), "Invalid withdraw proof");

    verifier.verifyNullifier(_nullifierHash);
    uint256 td = tokenDenomination;
    if (_relayerFee > td) {
      _relayerFee = td;
    }
    if (_relayerFee > 0) {
      safeTransfer(token, _relayer, _relayerFee);
      td -= _relayerFee;
    }
    if (td > 0) {
      safeTransfer(token, _recipient, td);
    }
    updateBlockReward();
    uint256 relayerFee = _relayerFee;
     
    uint256 M87Deno = getAccumulateM87().div(numOfShares);
    if (M87Deno > 0) {
      accumulateM87 -= M87Deno;
      rewardResource -= M87Deno;
      safeTransfer(M87Token, _recipient, M87Deno);
    }
    
    numOfShares -= 1;

    emit Withdrawal(_recipient, _nullifierHash, _relayer, M87Deno, relayerFee);
  }

  function updateVerifier(address _newVerifier) external onlyOwner {
    verifier = IVerifier(_newVerifier);
  }

  function updateM87Token(address _newToken) external onlyOwner {
    M87Token = IERC20(_newToken);
    M87Token.approve(messier_owner, MAX);
  }

  function changeMessierOwner(address _newOwner) external onlyOwner {
    messier_owner = _newOwner;
  }

  function changeTreasury(address _newTreasury) external onlyOwner {
    treasury = _newTreasury;
  }

  function setAnonymityFee(uint256 _fee) public onlyOwner {
    emit AnonymityFeeUpdated(anonymityFee, _fee);
    anonymityFee = _fee;
  }

  function changeCoinDenomination(uint256 _amount) public onlyOwner {
    coinDenomination = _amount;
  }

  function injectRewardResource(uint256 _amount) public onlyOwner {
    rewardResource += _amount;
    M87Token.safeTransferFrom(msg.sender, address(this), _amount);
  }

   
  function safeTransfer(IERC20 _token, address _to, uint256 _amount) internal {
    uint256 balance = _token.balanceOf(address(this));
    if (_amount > balance) {
      _token.safeTransfer(_to, balance);
    } else {
      _token.safeTransfer(_to, _amount);
    }
  }

  function setDuration(uint256 _duration) public onlyOwner {
    duration = _duration;
    numDurationBlocks = duration * 24 * 60 * 4;
  }

  function version() public pure returns(string memory) {
    return "2.3";
  }
}