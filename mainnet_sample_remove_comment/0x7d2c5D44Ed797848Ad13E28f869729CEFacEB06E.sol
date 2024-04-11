 
pragma experimental ABIEncoderV2;


 
 

pragma solidity ^0.7.0;

 
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    this;  
    return msg.data;
  }
}

 
 

pragma solidity ^0.7.0;



 
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

   
  function owner() public view virtual returns (address) {
    return _owner;
  }

   
  modifier onlyOwner() {
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

   
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

   
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
 
pragma solidity ^0.7.0;











contract TokenDistributor is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct Distribution {
    address[] receivers;
    uint256[] percentages;
  }

  event DistributionUpdated(address[] receivers, uint256[] percentages);
  event Distributed(address receiver, uint256 percentage, uint256 amount);

  
  Distribution private distribution;

  
  uint256 public constant DISTRIBUTION_BASE = 10000;

  constructor(address[] memory _receivers, uint256[] memory _percentages) {
    _setTokenDistribution(_receivers, _percentages);
  }

  
  
   
  
  function setTokenDistribution(address[] memory _receivers, uint256[] memory _percentages)
    external
    onlyOwner
  {
    _setTokenDistribution(_receivers, _percentages);
  }

  
  
  function distribute(IERC20[] memory _tokens) external {
    for (uint256 i = 0; i < _tokens.length; i++) {
      uint256 _balanceToDistribute =
        (address(_tokens[i]) != EthAddressLib.ethAddress())
          ? _tokens[i].balanceOf(address(this))
          : address(this).balance;
      if (_balanceToDistribute <= 0) {
        continue;
      }

      _distributeTokenWithAmount(_tokens[i], _balanceToDistribute);
    }
  }

  
  
  
  function distributeWithAmounts(IERC20[] memory _tokens, uint256[] memory _amounts) public {
    for (uint256 i = 0; i < _tokens.length; i++) {
      _distributeTokenWithAmount(_tokens[i], _amounts[i]);
    }
  }

  
  
  
  function distributeWithPercentages(IERC20[] memory _tokens, uint256[] memory _percentages)
    external
  {
    for (uint256 i = 0; i < _tokens.length; i++) {
      uint256 _amountToDistribute =
        (address(_tokens[i]) != EthAddressLib.ethAddress())
          ? _tokens[i].balanceOf(address(this)).mul(_percentages[i]).div(100)
          : address(this).balance.mul(_percentages[i]).div(100);
      if (_amountToDistribute <= 0) {
        continue;
      }

      _distributeTokenWithAmount(_tokens[i], _amountToDistribute);
    }
  }

  
  
  function getDistribution() external view returns (Distribution memory) {
    return distribution;
  }

  receive() external payable {}

  function _setTokenDistribution(address[] memory _receivers, uint256[] memory _percentages)
    internal
  {
    require(_receivers.length == _percentages.length, 'Array lengths should be equal');

    uint256 sumPercentages;
    for (uint256 i = 0; i < _percentages.length; i++) {
      sumPercentages += _percentages[i];
    }
    require(sumPercentages == DISTRIBUTION_BASE, 'INVALID_%_SUM');

    distribution = Distribution({receivers: _receivers, percentages: _percentages});
    emit DistributionUpdated(_receivers, _percentages);
  }

  function _distributeTokenWithAmount(IERC20 _token, uint256 _amountToDistribute) internal {
    address _tokenAddress = address(_token);
    Distribution memory _distribution = distribution;
    for (uint256 j = 0; j < _distribution.receivers.length; j++) {
      uint256 _amount =
        _amountToDistribute.mul(_distribution.percentages[j]).div(DISTRIBUTION_BASE);

       
      if (_amount == 0) {
        continue;
      }

      if (_tokenAddress != EthAddressLib.ethAddress()) {
        _token.safeTransfer(_distribution.receivers[j], _amount);
      } else {
         
        (bool _success, ) = _distribution.receivers[j].call{value: _amount}('');
        require(_success, 'Reverted ETH transfer');
      }
      emit Distributed(_distribution.receivers[j], _distribution.percentages[j], _amount);
    }
  }
}

 
 

pragma solidity ^0.7.0;

 
interface IERC20 {
   
  function totalSupply() external view returns (uint256);

   
  function balanceOf(address account) external view returns (uint256);

   
  function transfer(address recipient, uint256 amount) external returns (bool);

   
  function allowance(address owner, address spender) external view returns (uint256);

   
  function approve(address spender, uint256 amount) external returns (bool);

   
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

   
  event Transfer(address indexed from, address indexed to, uint256 value);

   
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.7.0;

library EthAddressLib {
   
  function ethAddress() internal pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  }
}

 
 

pragma solidity ^0.7.0;

 
library SafeMath {
   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath: subtraction overflow');
    uint256 c = a - b;

    return c;
  }

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
    require(b > 0, 'SafeMath: division by zero');
    uint256 c = a / b;
     

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, 'SafeMath: modulo by zero');
    return a % b;
  }
}

 
 

pragma solidity ^0.7.0;





 
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
     
     
     
     
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

   
  function callOptionalReturn(IERC20 token, bytes memory data) private {
     
     

     
     
     
     
     
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

     
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
       
       
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

 
 

pragma solidity ^0.7.0;

 
library Address {
   
  function isContract(address account) internal view returns (bool) {
     
     
     

    uint256 size;
     
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}
