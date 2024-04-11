 

 

pragma solidity 0.7.6;

 






abstract contract RocketBase {

     
    uint256 constant calcBase = 1 ether;

     
    uint8 public version;

     
    RocketStorageInterface rocketStorage = RocketStorageInterface(0);


     

     
    modifier onlyLatestNetworkContract() {
        require(getBool(keccak256(abi.encodePacked("contract.exists", msg.sender))), "Invalid or outdated network contract");
        _;
    }

     
    modifier onlyLatestContract(string memory _contractName, address _contractAddress) {
        require(_contractAddress == getAddress(keccak256(abi.encodePacked("contract.address", _contractName))), "Invalid or outdated contract");
        _;
    }

     
    modifier onlyRegisteredNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("node.exists", _nodeAddress))), "Invalid node");
        _;
    }

     
    modifier onlyTrustedNode(address _nodeAddress) {
        require(getBool(keccak256(abi.encodePacked("dao.trustednodes.", "member", _nodeAddress))), "Invalid trusted node");
        _;
    }

     
    modifier onlyRegisteredMinipool(address _minipoolAddress) {
        require(getBool(keccak256(abi.encodePacked("minipool.exists", _minipoolAddress))), "Invalid minipool");
        _;
    }
    

     
    modifier onlyGuardian() {
        require(msg.sender == rocketStorage.getGuardian(), "Account is not a temporary guardian");
        _;
    }




     

    
    constructor(RocketStorageInterface _rocketStorageAddress) {
         
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
    }


    
    function getContractAddress(string memory _contractName) internal view returns (address) {
         
        address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
         
        require(contractAddress != address(0x0), "Contract not found");
         
        return contractAddress;
    }


    
    function getContractAddressUnsafe(string memory _contractName) internal view returns (address) {
         
        address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
         
        return contractAddress;
    }


    
    function getContractName(address _contractAddress) internal view returns (string memory) {
         
        string memory contractName = getString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
         
        require(bytes(contractName).length > 0, "Contract not found");
         
        return contractName;
    }

    
    function getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
         
        if (_returnData.length < 68) return "Transaction reverted silently";
        assembly {
             
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));  
    }



     

     

    
    function getAddress(bytes32 _key) internal view returns (address) { return rocketStorage.getAddress(_key); }
    function getUint(bytes32 _key) internal view returns (uint) { return rocketStorage.getUint(_key); }
    function getString(bytes32 _key) internal view returns (string memory) { return rocketStorage.getString(_key); }
    function getBytes(bytes32 _key) internal view returns (bytes memory) { return rocketStorage.getBytes(_key); }
    function getBool(bytes32 _key) internal view returns (bool) { return rocketStorage.getBool(_key); }
    function getInt(bytes32 _key) internal view returns (int) { return rocketStorage.getInt(_key); }
    function getBytes32(bytes32 _key) internal view returns (bytes32) { return rocketStorage.getBytes32(_key); }

    
    function setAddress(bytes32 _key, address _value) internal { rocketStorage.setAddress(_key, _value); }
    function setUint(bytes32 _key, uint _value) internal { rocketStorage.setUint(_key, _value); }
    function setString(bytes32 _key, string memory _value) internal { rocketStorage.setString(_key, _value); }
    function setBytes(bytes32 _key, bytes memory _value) internal { rocketStorage.setBytes(_key, _value); }
    function setBool(bytes32 _key, bool _value) internal { rocketStorage.setBool(_key, _value); }
    function setInt(bytes32 _key, int _value) internal { rocketStorage.setInt(_key, _value); }
    function setBytes32(bytes32 _key, bytes32 _value) internal { rocketStorage.setBytes32(_key, _value); }

    
    function deleteAddress(bytes32 _key) internal { rocketStorage.deleteAddress(_key); }
    function deleteUint(bytes32 _key) internal { rocketStorage.deleteUint(_key); }
    function deleteString(bytes32 _key) internal { rocketStorage.deleteString(_key); }
    function deleteBytes(bytes32 _key) internal { rocketStorage.deleteBytes(_key); }
    function deleteBool(bytes32 _key) internal { rocketStorage.deleteBool(_key); }
    function deleteInt(bytes32 _key) internal { rocketStorage.deleteInt(_key); }
    function deleteBytes32(bytes32 _key) internal { rocketStorage.deleteBytes32(_key); }

    
    function addUint(bytes32 _key, uint256 _amount) internal { rocketStorage.addUint(_key, _amount); }
    function subUint(bytes32 _key, uint256 _amount) internal { rocketStorage.subUint(_key, _amount); }
}

 

pragma solidity 0.7.6;

 

interface RocketDAOProtocolSettingsInterface {
    function getSettingUint(string memory _settingPath) external view returns (uint256);
    function setSettingUint(string memory _settingPath, uint256 _value) external;
    function getSettingBool(string memory _settingPath) external view returns (bool);
    function setSettingBool(string memory _settingPath, bool _value) external;
    function getSettingAddress(string memory _settingPath) external view returns (address);
    function setSettingAddress(string memory _settingPath, address _value) external;
}
 

pragma solidity 0.7.6;

 




 
 
abstract contract RocketDAOProtocolSettings is RocketBase, RocketDAOProtocolSettingsInterface {


     
    bytes32 settingNameSpace;


     
    modifier onlyDAOProtocolProposal() {
         
        if(getBool(keccak256(abi.encodePacked(settingNameSpace, "deployed")))) require(getContractAddress("rocketDAOProtocolProposals") == msg.sender, "Only DAO Protocol Proposals contract can update a setting");
        _;
    }


     
    constructor(RocketStorageInterface _rocketStorageAddress, string memory _settingNameSpace) RocketBase(_rocketStorageAddress) {
         
        settingNameSpace = keccak256(abi.encodePacked("dao.protocol.setting.", _settingNameSpace));
    }


     

     
    function getSettingUint(string memory _settingPath) public view override returns (uint256) {
        return getUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
    } 

     
    function setSettingUint(string memory _settingPath, uint256 _value) virtual public override onlyDAOProtocolProposal {
         
        setUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);
    } 
   

     

     
    function getSettingBool(string memory _settingPath) public view override returns (bool) {
        return getBool(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
    } 

     
    function setSettingBool(string memory _settingPath, bool _value) virtual public override onlyDAOProtocolProposal {
         
        setBool(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);
    }

    
     

     
    function getSettingAddress(string memory _settingPath) external view override returns (address) {
        return getAddress(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
    } 

     
    function setSettingAddress(string memory _settingPath, address _value) virtual external override onlyDAOProtocolProposal {
         
        setAddress(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);
    }

}

 

pragma solidity 0.7.6;

 

interface RocketDAOProtocolSettingsAuctionInterface {
    function getCreateLotEnabled() external view returns (bool);
    function getBidOnLotEnabled() external view returns (bool);
    function getLotMinimumEthValue() external view returns (uint256);
    function getLotMaximumEthValue() external view returns (uint256);
    function getLotDuration() external view returns (uint256);
    function getStartingPriceRatio() external view returns (uint256);
    function getReservePriceRatio() external view returns (uint256);
}

 

pragma solidity 0.7.6;

 




 

contract RocketDAOProtocolSettingsAuction is RocketDAOProtocolSettings, RocketDAOProtocolSettingsAuctionInterface {

     
    constructor(RocketStorageInterface _rocketStorageAddress) RocketDAOProtocolSettings(_rocketStorageAddress, "auction") {
         
        version = 1;
         
        if(!getBool(keccak256(abi.encodePacked(settingNameSpace, "deployed")))) {
             
            setSettingBool("auction.lot.create.enabled", true);      
            setSettingBool("auction.lot.bidding.enabled", true);
            setSettingUint("auction.lot.value.minimum", 1 ether);   
            setSettingUint("auction.lot.value.maximum", 10 ether);
            setSettingUint("auction.lot.duration", 40320);           
            setSettingUint("auction.price.start", 1 ether);          
            setSettingUint("auction.price.reserve", 0.5 ether);      
             
            setBool(keccak256(abi.encodePacked(settingNameSpace, "deployed")), true);
        }
    }


     
    function getCreateLotEnabled() override external view returns (bool) {
        return getSettingBool("auction.lot.create.enabled");
    }

     
    function getBidOnLotEnabled() override external view returns (bool) {
        return getSettingBool("auction.lot.bidding.enabled");
    }

     
    function getLotMinimumEthValue() override external view returns (uint256) {
        return getSettingUint("auction.lot.value.minimum");
    }

     
    function getLotMaximumEthValue() override external view returns (uint256) {
        return getSettingUint("auction.lot.value.maximum");
    }

     
    function getLotDuration() override external view returns (uint256) {
        return getSettingUint("auction.lot.duration");
    }

     
    function getStartingPriceRatio() override external view returns (uint256) {
        return getSettingUint("auction.price.start");
    }

     
    function getReservePriceRatio() override external view returns (uint256) {
        return getSettingUint("auction.price.reserve");
    }

}

 

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
