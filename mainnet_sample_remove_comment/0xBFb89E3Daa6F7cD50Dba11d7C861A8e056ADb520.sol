 

 

 

 

pragma solidity ^0.7.6;

interface IDoubleProxy {
    function proxy() external view returns (address);
}

interface IMVDProxy {
    function getMVDFunctionalitiesManagerAddress() external view returns(address);
    function getMVDWalletAddress() external view returns (address);
    function getStateHolderAddress() external view returns(address);
    function submit(string calldata codeName, bytes calldata data) external payable returns(bytes memory returnData);
}

interface IMVDFunctionalitiesManager {
    function getFunctionalityData(string calldata codeName) external view returns(address, uint256, string memory, address, uint256);
    function isAuthorizedFunctionality(address functionality) external view returns(bool);
}

interface IStateHolder {
    function getUint256(string calldata name) external view returns(uint256);
    function getAddress(string calldata name) external view returns(address);
    function clear(string calldata varName) external returns(string memory oldDataType, bytes memory oldVal);
}

 

 
pragma solidity ^0.7.6;

interface IFarmFactory {

    event ExtensionCloned(address indexed);

    function feePercentageInfo() external view returns (uint256, address);
    function farmDefaultExtension() external view returns(address);
    function cloneFarmDefaultExtension() external returns(address);
    function getFarmTokenCollectionURI() external view returns (string memory);
    function getFarmTokenURI() external view returns (string memory);
}

 

 
pragma solidity ^0.7.6;



contract FarmFactory is IFarmFactory {

     
    address public farmMainImplAddress;
     
    address public override farmDefaultExtension;
     
    address public _doubleProxy;
     
    uint256 private _feePercentage;
     
    string public farmTokenCollectionURI;
     
    string public farmTokenURI;

     
    event FarmMainDeployed(address indexed farmMainAddress, address indexed sender, bytes initResultData);
     
    event FarmMainLogicSet(address indexed newAddress);
     
    event FarmDefaultExtensionSet(address indexed newAddress);
     
    event FeePercentageSet(uint256 newFeePercentage);

    constructor(address doubleProxy, address _farmMainImplAddress, address _farmDefaultExtension, uint256 feePercentage, string memory farmTokenCollectionUri, string memory farmTokenUri) {
        _doubleProxy = doubleProxy;
        farmTokenCollectionURI = farmTokenCollectionUri;
        farmTokenURI = farmTokenUri;
        emit FarmMainLogicSet(farmMainImplAddress = _farmMainImplAddress);
        emit FarmDefaultExtensionSet(farmDefaultExtension = _farmDefaultExtension);
        emit FeePercentageSet(_feePercentage = feePercentage);
    }

     

    function feePercentageInfo() public override view returns (uint256, address) {
        return (_feePercentage, IMVDProxy(IDoubleProxy(_doubleProxy).proxy()).getMVDWalletAddress());
    }

     
    function setDoubleProxy(address newDoubleProxy) public onlyDFO {
        _doubleProxy = newDoubleProxy;
    }

     
    function updateFeePercentage(uint256 feePercentage) public onlyDFO {
        emit FeePercentageSet(_feePercentage = feePercentage);
    }

     
    function updateLogicAddress(address _implAddress) public {
        emit FarmMainLogicSet(farmMainImplAddress = _implAddress);
    }

     
    function updateDefaultExtensionAddress(address _farmDefaultExtensionAddress) public {
        emit FarmDefaultExtensionSet(farmDefaultExtension = _farmDefaultExtensionAddress);
    }

     
    function updateFarmTokenCollectionURI(string memory farmTokenCollectionUri) public onlyDFO {
        farmTokenCollectionURI = farmTokenCollectionUri;
    }

     
    function updateFarmTokenURI(string memory farmTokenUri) public onlyDFO {
        farmTokenURI = farmTokenUri;
    }

     
    function getFarmTokenCollectionURI() public override view returns (string memory) {
        return farmTokenCollectionURI;
    }

     
    function getFarmTokenURI() public override view returns (string memory) {
        return farmTokenURI;
    }

     
    function cloneFarmDefaultExtension() public override returns(address clonedExtension) {
        emit ExtensionCloned(clonedExtension = _clone(farmDefaultExtension));
    }

     
    function deploy(bytes memory data) public returns (address contractAddress, bytes memory initResultData) {
        initResultData = _call(contractAddress = _clone(farmMainImplAddress), data);
        emit FarmMainDeployed(contractAddress, msg.sender, initResultData);
    }

     

     
    function _clone(address original) private returns (address copy) {
        assembly {
            mstore(
                0,
                or(
                    0x5880730000000000000000000000000000000000000000803b80938091923cF3,
                    mul(original, 0x1000000000000000000)
                )
            )
            copy := create(0, 0, 32)
            switch extcodesize(copy)
                case 0 {
                    invalid()
                }
        }
    }

     
    function _call(address location, bytes memory payload) private returns(bytes memory returnData) {
        assembly {
            let result := call(gas(), location, 0, add(payload, 0x20), mload(payload), 0, 0)
            let size := returndatasize()
            returnData := mload(0x40)
            mstore(returnData, size)
            let returnDataPayloadStart := add(returnData, 0x20)
            returndatacopy(returnDataPayloadStart, 0, size)
            mstore(0x40, add(returnDataPayloadStart, size))
            switch result case 0 {revert(returnDataPayloadStart, size)}
        }
    }

     
    modifier onlyDFO() {
        require(IMVDFunctionalitiesManager(IMVDProxy(IDoubleProxy(_doubleProxy).proxy()).getMVDFunctionalitiesManagerAddress()).isAuthorizedFunctionality(msg.sender), "Unauthorized.");
        _;
    }
}