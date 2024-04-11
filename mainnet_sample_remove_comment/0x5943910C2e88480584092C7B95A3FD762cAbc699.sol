 
pragma experimental ABIEncoderV2;

 

 

pragma solidity 0.6.12;


 

interface IRocketPool {
    function getBalance() external view returns (uint256);

    function getMaximumDepositPoolSize() external view returns (uint256);

    function getAddress(bytes32 _key) external view returns (address);

    function getUint(bytes32 _key) external view returns (uint256);

    function getDepositEnabled() external view returns (bool);

    function getMinimumDeposit() external view returns (uint256);
}


 

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
             
            if (returndata.length > 0) {
                 

                 
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

 

contract RocketPoolHelper {
    using SafeMath for uint256;
    using Address for address;

    IRocketPool internal constant rocketStorage =
        IRocketPool(0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46);

    
     
     
     
     
    
    
    function isRethFree(address _user) public view returns (bool) {
         
        bytes32 key = keccak256(abi.encodePacked("user.deposit.block", _user));
        uint256 lastDepositBlock = rocketStorage.getUint(key);
        if (lastDepositBlock > 0) {
             
            uint256 depositDelay =
                rocketStorage.getUint(
                    keccak256(
                        abi.encodePacked(
                            keccak256("dao.protocol.setting.network"),
                            "network.reth.deposit.delay"
                        )
                    )
                );
            uint256 blocksPassed = block.number.sub(lastDepositBlock);
            return blocksPassed > depositDelay;
        } else {
            return true;  
        }
    }

    
     
     
     
     
    
    
    function rEthCanAcceptDeposit(uint256 _ethAmount)
        public
        view
        returns (bool)
    {
        IRocketPool rocketDAOProtocolSettingsDeposit =
            IRocketPool(getRPLContract("rocketDAOProtocolSettingsDeposit"));
        
         
        if (!rocketDAOProtocolSettingsDeposit.getDepositEnabled()) {
            return false;
        }
        
         
        uint256 freeSpace = getPoolFreeSpace();
        
        return freeSpace > _ethAmount;
    }

    
    function getMinimumDepositSize() public view returns (uint256) {
         
        IRocketPool rocketDAOProtocolSettingsDeposit =
            IRocketPool(getRPLContract("rocketDAOProtocolSettingsDeposit"));

        return rocketDAOProtocolSettingsDeposit.getMinimumDeposit();
    }

    
    function getPoolFreeSpace() public view returns (uint256) {
         
        IRocketPool rocketDAOProtocolSettingsDeposit =
            IRocketPool(getRPLContract("rocketDAOProtocolSettingsDeposit"));
        IRocketPool rocketDepositPool =
            IRocketPool(getRPLContract("rocketDepositPool"));

         
        uint256 maxDeposit =
            rocketDAOProtocolSettingsDeposit.getMaximumDepositPoolSize().sub(
                rocketDepositPool.getBalance()
            );

        return maxDeposit;
    }

    
    function getRocketDepositPoolAddress() public view returns (address) {
        return getRPLContract("rocketDepositPool");
    }

    function getRPLContract(string memory _contractName)
        internal
        view
        returns (address)
    {
        return
            rocketStorage.getAddress(
                keccak256(abi.encodePacked("contract.address", _contractName))
            );
    }
}