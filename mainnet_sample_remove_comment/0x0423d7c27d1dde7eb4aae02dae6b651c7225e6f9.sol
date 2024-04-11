 

 

 

 


 
 
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


pragma solidity ^0.6.12;

contract WSGov {
    
    string public constant name = "WhiteSwap";

    
    string public constant symbol = "WSD";

    
    uint8 public constant decimals = 18;

    
    uint public totalSupply = 21_000_000e18;  

    
    address public minter;

    
    mapping (address => mapping (address => uint96)) internal allowances;

    
    mapping (address => uint96) internal balances;

    
    mapping (address => address) public delegates;

    
    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    
    mapping (address => uint32) public numCheckpoints;

    
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    
    mapping (address => uint) public nonces;

    
    event MinterChanged(address minter, address newMinter);

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

     
    constructor() public {
        balances[msg.sender] = uint96(totalSupply);
        emit Transfer(address(0), msg.sender, totalSupply);
        minter = msg.sender;
        emit MinterChanged(address(0), minter);
    }

     
    function setMinter(address minter_) external {
        require(msg.sender == minter, "WSG::setMinter: only the minter can change the minter address");
        emit MinterChanged(minter, minter_);
        minter = minter_;
    }

     
    function mint(address dst, uint rawAmount) external {
        require(msg.sender == minter, "WSG::mint: only the minter can mint");
        require(dst != address(0), "WSG::mint: cannot transfer to the zero address");

         
        uint96 amount = safe96(rawAmount, "WSG::mint: amount exceeds 96 bits");
        totalSupply = safe96(SafeMath.add(totalSupply, amount), "WSG::mint: totalSupply exceeds 96 bits");

         
        balances[dst] = add96(balances[dst], amount, "WSG::mint: transfer amount overflows");
        emit Transfer(address(0), dst, amount);

         
        _moveDelegates(address(0), delegates[dst], amount);
    }

      
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "WSG::burn: burn from the zero address");
        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "WSG::burn: burn amount exceeds balance");
        balances[account] = safe96(SafeMath.sub(accountBalance, amount), "WSG::burn: amount exceeds 96 bits");
        totalSupply = safe96(SafeMath.sub(totalSupply, amount), "WSG::burn: amount exceeds 96 bits");

        emit Transfer(account, address(0), amount);
    }

     
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

     
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

     
    function approve(address spender, uint rawAmount) external returns (bool) {
        uint96 amount;
        if (rawAmount == uint(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(rawAmount, "WSG::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

     
    function permit(address owner, address spender, uint rawAmount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint96 amount;
        if (rawAmount == uint(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(rawAmount, "WSG::permit: amount exceeds 96 bits");
        }

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, rawAmount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "WSG::permit: invalid signature");
        require(signatory == owner, "WSG::permit: unauthorized");
        require(now <= deadline, "WSG::permit: signature expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

     
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

     
    function transfer(address dst, uint rawAmount) external returns (bool) {
        uint96 amount = safe96(rawAmount, "WSG::transfer: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

     
    function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {
        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "WSG::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != uint96(-1)) {
            uint96 newAllowance = sub96(spenderAllowance, amount, "WSG::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

     
    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

     
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "WSG::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "WSG::delegateBySig: invalid nonce");
        require(now <= expiry, "WSG::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

     
    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

     
    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {
        require(blockNumber < block.number, "WSG::getPriorVotes: not yet determined");

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
        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transferTokens(address src, address dst, uint96 amount) internal {
        require(src != address(0), "WSG::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "WSG::_transferTokens: cannot transfer to the zero address");

        balances[src] = sub96(balances[src], amount, "WSG::_transferTokens: transfer amount exceeds balance");
        balances[dst] = add96(balances[dst], amount, "WSG::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "WSG::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "WSG::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {
      uint32 blockNumber = safe32(block.number, "WSG::_writeCheckpoint: block number exceeds 32 bits");

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

    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}