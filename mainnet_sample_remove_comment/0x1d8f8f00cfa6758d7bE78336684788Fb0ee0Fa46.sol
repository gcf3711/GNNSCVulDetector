 


 

pragma solidity 0.7.6;

 

interface RocketStorageInterface {

     
    function getDeployedStatus() external view returns (bool);

     
    function getGuardian() external view returns(address);
    function setGuardian(address _newAddress) external;
    function confirmGuardian() external;

     
    function getAddress(bytes32 _key) external view returns (address);
    function getUint(bytes32 _key) external view returns (uint);
    function getString(bytes32 _key) external view returns (string memory);
    function getBytes(bytes32 _key) external view returns (bytes memory);
    function getBool(bytes32 _key) external view returns (bool);
    function getInt(bytes32 _key) external view returns (int);
    function getBytes32(bytes32 _key) external view returns (bytes32);

     
    function setAddress(bytes32 _key, address _value) external;
    function setUint(bytes32 _key, uint _value) external;
    function setString(bytes32 _key, string calldata _value) external;
    function setBytes(bytes32 _key, bytes calldata _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setInt(bytes32 _key, int _value) external;
    function setBytes32(bytes32 _key, bytes32 _value) external;

     
    function deleteAddress(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteBytes32(bytes32 _key) external;

     
    function addUint(bytes32 _key, uint256 _amount) external;
    function subUint(bytes32 _key, uint256 _amount) external;

     
    function getNodeWithdrawalAddress(address _nodeAddress) external view returns (address);
    function getNodePendingWithdrawalAddress(address _nodeAddress) external view returns (address);
    function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external;
    function confirmWithdrawalAddress(address _nodeAddress) external;
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

 

pragma solidity 0.7.6;

 







contract RocketStorage is RocketStorageInterface {

     
    event NodeWithdrawalAddressSet(address indexed node, address indexed withdrawalAddress, uint256 time);
    event GuardianChanged(address oldGuardian, address newGuardian);

     
    using SafeMath for uint256;

     
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => uint256)    private uintStorage;
    mapping(bytes32 => int256)     private intStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bool)       private booleanStorage;
    mapping(bytes32 => bytes32)    private bytes32Storage;

     
    mapping(address => address)    private withdrawalAddresses;
    mapping(address => address)    private pendingWithdrawalAddresses;

     
    address guardian;
    address newGuardian;

     
    bool storageInit = false;

    
    modifier onlyLatestRocketNetworkContract() {
        if (storageInit == true) {
             
            require(booleanStorage[keccak256(abi.encodePacked("contract.exists", msg.sender))], "Invalid or outdated network contract");
        } else {
             
             
            require((
                booleanStorage[keccak256(abi.encodePacked("contract.exists", msg.sender))] || tx.origin == guardian
            ), "Invalid or outdated network contract attempting access during deployment");
        }
        _;
    }


    
    constructor() {
         
        guardian = msg.sender;
    }

     
    function getGuardian() external override view returns (address) {
        return guardian;
    }

     
    function setGuardian(address _newAddress) external override {
         
        require(msg.sender == guardian, "Is not guardian account");
         
        newGuardian = _newAddress;
    }

     
    function confirmGuardian() external override {
         
        require(msg.sender == newGuardian, "Confirmation must come from new guardian address");
         
        address oldGuardian = guardian;
         
        guardian = newGuardian;
        delete newGuardian;
         
        emit GuardianChanged(oldGuardian, guardian);
    }

     
    function getDeployedStatus() external override view returns (bool) {
        return storageInit;
    }

     
    function setDeployedStatus() external {
         
        require(msg.sender == guardian, "Is not guardian account");
         
        storageInit = true;
    }

     

     
    function getNodeWithdrawalAddress(address _nodeAddress) public override view returns (address) {
         
        address withdrawalAddress = withdrawalAddresses[_nodeAddress];
        if (withdrawalAddress == address(0)) {
            return _nodeAddress;
        }
        return withdrawalAddress;
    }

     
    function getNodePendingWithdrawalAddress(address _nodeAddress) external override view returns (address) {
        return pendingWithdrawalAddresses[_nodeAddress];
    }

     
    function setWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress, bool _confirm) external override {
         
        require(_newWithdrawalAddress != address(0x0), "Invalid withdrawal address");
         
        address withdrawalAddress = getNodeWithdrawalAddress(_nodeAddress);
        require(withdrawalAddress == msg.sender, "Only a tx from a node's withdrawal address can update it");
         
        if (_confirm) {
            updateWithdrawalAddress(_nodeAddress, _newWithdrawalAddress);
        }
         
        else {
            pendingWithdrawalAddresses[_nodeAddress] = _newWithdrawalAddress;
        }
    }

     
    function confirmWithdrawalAddress(address _nodeAddress) external override {
         
        require(pendingWithdrawalAddresses[_nodeAddress] == msg.sender, "Confirmation must come from the pending withdrawal address");
        delete pendingWithdrawalAddresses[_nodeAddress];
         
        updateWithdrawalAddress(_nodeAddress, msg.sender);
    }

     
    function updateWithdrawalAddress(address _nodeAddress, address _newWithdrawalAddress) private {
         
        withdrawalAddresses[_nodeAddress] = _newWithdrawalAddress;
         
        emit NodeWithdrawalAddressSet(_nodeAddress, _newWithdrawalAddress, block.timestamp);
    }

    
    function getAddress(bytes32 _key) override external view returns (address r) {
        return addressStorage[_key];
    }

    
    function getUint(bytes32 _key) override external view returns (uint256 r) {
        return uintStorage[_key];
    }

    
    function getString(bytes32 _key) override external view returns (string memory) {
        return stringStorage[_key];
    }

    
    function getBytes(bytes32 _key) override external view returns (bytes memory) {
        return bytesStorage[_key];
    }

    
    function getBool(bytes32 _key) override external view returns (bool r) {
        return booleanStorage[_key];
    }

    
    function getInt(bytes32 _key) override external view returns (int r) {
        return intStorage[_key];
    }

    
    function getBytes32(bytes32 _key) override external view returns (bytes32 r) {
        return bytes32Storage[_key];
    }


    
    function setAddress(bytes32 _key, address _value) onlyLatestRocketNetworkContract override external {
        addressStorage[_key] = _value;
    }

    
    function setUint(bytes32 _key, uint _value) onlyLatestRocketNetworkContract override external {
        uintStorage[_key] = _value;
    }

    
    function setString(bytes32 _key, string calldata _value) onlyLatestRocketNetworkContract override external {
        stringStorage[_key] = _value;
    }

    
    function setBytes(bytes32 _key, bytes calldata _value) onlyLatestRocketNetworkContract override external {
        bytesStorage[_key] = _value;
    }

    
    function setBool(bytes32 _key, bool _value) onlyLatestRocketNetworkContract override external {
        booleanStorage[_key] = _value;
    }

    
    function setInt(bytes32 _key, int _value) onlyLatestRocketNetworkContract override external {
        intStorage[_key] = _value;
    }

    
    function setBytes32(bytes32 _key, bytes32 _value) onlyLatestRocketNetworkContract override external {
        bytes32Storage[_key] = _value;
    }


    
    function deleteAddress(bytes32 _key) onlyLatestRocketNetworkContract override external {
        delete addressStorage[_key];
    }

    
    function deleteUint(bytes32 _key) onlyLatestRocketNetworkContract override external {
        delete uintStorage[_key];
    }

    
    function deleteString(bytes32 _key) onlyLatestRocketNetworkContract override external {
        delete stringStorage[_key];
    }

    
    function deleteBytes(bytes32 _key) onlyLatestRocketNetworkContract override external {
        delete bytesStorage[_key];
    }

    
    function deleteBool(bytes32 _key) onlyLatestRocketNetworkContract override external {
        delete booleanStorage[_key];
    }

    
    function deleteInt(bytes32 _key) onlyLatestRocketNetworkContract override external {
        delete intStorage[_key];
    }

    
    function deleteBytes32(bytes32 _key) onlyLatestRocketNetworkContract override external {
        delete bytes32Storage[_key];
    }


    
    
    function addUint(bytes32 _key, uint256 _amount) onlyLatestRocketNetworkContract override external {
        uintStorage[_key] = uintStorage[_key].add(_amount);
    }

    
    
    function subUint(bytes32 _key, uint256 _amount) onlyLatestRocketNetworkContract override external {
        uintStorage[_key] = uintStorage[_key].sub(_amount);
    }
}
