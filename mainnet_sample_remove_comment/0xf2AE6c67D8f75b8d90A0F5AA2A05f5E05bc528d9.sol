 


 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
abstract contract Proxy {
     
    function _delegate(address implementation) internal virtual {
         
        assembly {
             
             
             
            calldatacopy(0, 0, calldatasize())

             
             
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

             
            returndatacopy(0, 0, returndatasize())

            switch result
             
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

     
    function _implementation() internal view virtual returns (address);

     
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

     
    fallback () external payable virtual {
        _fallback();
    }

     
    receive () external payable virtual {
        _fallback();
    }

     
    function _beforeFallback() internal virtual {
    }
}

 
pragma solidity 0.7.6;



 
interface IGardenFactory {
    function createGarden(
        address _reserveAsset,
        address _creator,
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _seed,
        uint256[] calldata _gardenParams,
        uint256 _initialContribution,
        bool[] memory _publicGardenStrategistsStewards
    ) external returns (address);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
interface IBeacon {
     
    function implementation() external view returns (address);
}

 

pragma solidity >=0.6.0 <0.8.0;


 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

     
    function owner() public view virtual returns (address) {
        return _owner;
    }

     
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

     
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;





 
contract BeaconProxy is Proxy {
     
    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

     
    constructor(address beacon, bytes memory data) public payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

     
    function _beacon() internal view virtual returns (address beacon) {
        bytes32 slot = _BEACON_SLOT;
         
        assembly {
            beacon := sload(slot)
        }
    }

     
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_beacon()).implementation();
    }

     
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

         
        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}
 

pragma solidity 0.7.6;









 
contract GardenFactory is IGardenFactory {
    IBabController private immutable controller;
    UpgradeableBeacon private immutable beacon;

    constructor(IBabController _controller, UpgradeableBeacon _beacon) {
        require(address(_controller) != address(0), 'Controller is zero');
        require(address(_beacon) != address(0), 'Beacon is zero');

        controller = IBabController(_controller);
        beacon = _beacon;
    }

     
    function createGarden(
        address _reserveAsset,
        address _creator,
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _seed,
        uint256[] calldata _gardenParams,
        uint256 _initialContribution,
        bool[] memory _publicGardenStrategistsStewards
    ) external override returns (address) {
        require(msg.sender == address(controller), 'Only the controller can create gardens');
        address payable proxy =
            payable(
                new SafeBeaconProxy(
                    address(beacon),
                    abi.encodeWithSelector(
                        IGarden.initialize.selector,
                        _reserveAsset,
                        controller,
                        _creator,
                        _name,
                        _symbol,
                        _gardenParams,
                        _initialContribution,
                        _publicGardenStrategistsStewards
                    )
                )
            );
        IGardenNFT(controller.gardenNFT()).saveGardenURIAndSeed(proxy, _tokenURI, _seed);
        return proxy;
    }
}

 

pragma solidity >=0.6.0 <0.8.0;

 
library Clones {
     
    function clone(address master) internal returns (address instance) {
         
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

     
    function cloneDeterministic(address master, bytes32 salt) internal returns (address instance) {
         
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

     
    function predictDeterministicAddress(address master, bytes32 salt, address deployer) internal pure returns (address predicted) {
         
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

     
    function predictDeterministicAddress(address master, bytes32 salt) internal view returns (address predicted) {
        return predictDeterministicAddress(master, salt, address(this));
    }
}

 

pragma solidity >=0.6.0 <0.8.0;





 
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

     
    event Upgraded(address indexed implementation);

     
    constructor(address implementation_) public {
        _setImplementation(implementation_);
    }

     
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

     
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

     
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}

 

pragma solidity 0.7.6;



 
contract SafeBeaconProxy is BeaconProxy {
     
    constructor(address beacon, bytes memory data) public payable BeaconProxy(beacon, data) {}

     
    receive() external payable override {}
}

 
pragma solidity 0.7.6;

 
interface IBabController {
     

    function createGarden(
        address _reserveAsset,
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _seed,
        uint256[] calldata _gardenParams,
        uint256 _initialContribution,
        bool[] memory _publicGardenStrategistsStewards,
        uint256[] memory _profitSharing
    ) external payable returns (address);

    function removeGarden(address _garden) external;

    function addReserveAsset(address _reserveAsset) external;

    function removeReserveAsset(address _reserveAsset) external;

    function disableGarden(address _garden) external;

    function editPriceOracle(address _priceOracle) external;

    function editIshtarGate(address _ishtarGate) external;

    function editGardenValuer(address _gardenValuer) external;

    function editRewardsDistributor(address _rewardsDistributor) external;

    function editTreasury(address _newTreasury) external;

    function editGardenFactory(address _newGardenFactory) external;

    function editGardenNFT(address _newGardenNFT) external;

    function editStrategyNFT(address _newStrategyNFT) external;

    function editStrategyFactory(address _newStrategyFactory) external;

    function setOperation(uint8 _kind, address _operation) external;

    function setDefaultTradeIntegration(address _newDefaultTradeIntegation) external;

    function addKeeper(address _keeper) external;

    function addKeepers(address[] memory _keepers) external;

    function removeKeeper(address _keeper) external;

    function enableGardenTokensTransfers() external;

    function enableBABLMiningProgram() external;

    function setAllowPublicGardens() external;

    function editLiquidityReserve(address _reserve, uint256 _minRiskyPairLiquidityEth) external;

    function maxContributorsPerGarden() external view returns (uint256);

    function gardenCreationIsOpen() external view returns (bool);

    function openPublicGardenCreation() external;

    function setMaxContributorsPerGarden(uint256 _newMax) external;

    function owner() external view returns (address);

    function guardianGlobalPaused() external view returns (bool);

    function guardianPaused(address _address) external view returns (bool);

    function setPauseGuardian(address _guardian) external;

    function setGlobalPause(bool _state) external returns (bool);

    function setSomePause(address[] memory _address, bool _state) external returns (bool);

    function isPaused(address _contract) external view returns (bool);

    function priceOracle() external view returns (address);

    function gardenValuer() external view returns (address);

    function gardenNFT() external view returns (address);

    function strategyNFT() external view returns (address);

    function rewardsDistributor() external view returns (address);

    function gardenFactory() external view returns (address);

    function treasury() external view returns (address);

    function ishtarGate() external view returns (address);

    function strategyFactory() external view returns (address);

    function defaultTradeIntegration() external view returns (address);

    function gardenTokensTransfersEnabled() external view returns (bool);

    function bablMiningProgramEnabled() external view returns (bool);

    function allowPublicGardens() external view returns (bool);

    function enabledOperations(uint256 _kind) external view returns (address);

    function getProfitSharing()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getBABLSharing()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getGardens() external view returns (address[] memory);

    function getOperations() external view returns (address[20] memory);

    function isGarden(address _garden) external view returns (bool);

    function isValidReserveAsset(address _reserveAsset) external view returns (bool);

    function isValidKeeper(address _keeper) external view returns (bool);

    function isSystemContract(address _contractAddress) external view returns (bool);

    function getMinCooldownPeriod() external view returns (uint256);

    function getMaxCooldownPeriod() external view returns (uint256);

    function protocolPerformanceFee() external view returns (uint256);

    function protocolManagementFee() external view returns (uint256);

    function minLiquidityPerReserve(address _reserve) external view returns (uint256);
}

 
pragma solidity 0.7.6;

 
interface IGarden {
     
    function initialize(
        address _reserveAsset,
        address _controller,
        address _creator,
        string memory _name,
        string memory _symbol,
        uint256[] calldata _gardenParams,
        uint256 _initialContribution,
        bool[] memory _publicGardenStrategistsStewards
    ) external payable;

    function makeGardenPublic() external;

    function setPublicRights(bool _publicStrategist, bool _publicStewards) external;

    function setActive(bool _val) external;

    function active() external view returns (bool);

    function privateGarden() external view returns (bool);

    function publicStrategists() external view returns (bool);

    function publicStewards() external view returns (bool);

    function controller() external view returns (address);

    function creator() external view returns (address);

    function isGardenStrategy(address _strategy) external view returns (bool);

    function getContributor(address _contributor)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function reserveAsset() external view returns (address);

    function totalContributors() external view returns (uint256);

    function gardenInitializedAt() external view returns (uint256);

    function minContribution() external view returns (uint256);

    function maxContributors() external view returns (uint256);

    function depositHardlock() external view returns (uint256);

    function minLiquidityAsset() external view returns (uint256);

    function minStrategyDuration() external view returns (uint256);

    function maxStrategyDuration() external view returns (uint256);

    function principal() external view returns (uint256);

    function reserveAssetRewardsSetAside() external view returns (uint256);

    function absoluteReturns() external view returns (int256);

    function totalStake() external view returns (uint256);

    function minVotesQuorum() external view returns (uint256);

    function minVoters() external view returns (uint256);

    function maxDepositLimit() external view returns (uint256);

    function strategyCooldownPeriod() external view returns (uint256);

    function getStrategies() external view returns (address[] memory);

    function getFinalizedStrategies() external view returns (address[] memory);

    function strategyMapping(address _strategy) external view returns (bool);

    function finalizeStrategy(uint256 _profits, int256 _returns) external;

    function allocateCapitalToStrategy(uint256 _capital) external;

    function addStrategy(
        string memory _name,
        string memory _symbol,
        uint256[] calldata _stratParams,
        uint8[] calldata _opTypes,
        address[] calldata _opIntegrations,
        bytes calldata _opEncodedDatas
    ) external;

    function deposit(
        uint256 _reserveAssetQuantity,
        uint256 _minGardenTokenReceiveQuantity,
        address _to,
        bool mintNFT
    ) external payable;

    function depositBySig(
        uint256 _amountIn,
        uint256 _minAmountOut,
        bool _mintNft,
        uint256 _nonce,
        uint256 _pricePerShare,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function withdraw(
        uint256 _gardenTokenQuantity,
        uint256 _minReserveReceiveQuantity,
        address payable _to,
        bool _withPenalty,
        address _unwindStrategy
    ) external;

    function withdrawBySig(
        uint256 _gardenTokenQuantity,
        uint256 _minReserveReceiveQuantity,
        uint256 _nonce,
        uint256 _pricePerShare,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function claimReturns(address[] calldata _finalizedStrategies) external;

    function getLockedBalance(address _contributor) external view returns (uint256);

    function expireCandidateStrategy(address _strategy) external;

    function burnStrategistStake(address _strategist, uint256 _amount) external;

    function payKeeper(address payable _keeper, uint256 _fee) external;

    function keeperDebt() external view returns (uint256);

    function totalKeeperFees() external view returns (uint256);
}

 
pragma solidity 0.7.6;




 
interface IGardenNFT {
    function grantGardenNFT(address _user) external returns (uint256);

    function saveGardenURIAndSeed(
        address _garden,
        string memory _gardenTokenURI,
        uint256 _seed
    ) external;

    function gardenTokenURIs(address _garden) external view returns (string memory);

    function gardenSeeds(address _garden) external view returns (uint256);
}

 

pragma solidity >=0.6.2 <0.8.0;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        uint256 size;
         
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

         
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

         
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

         
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

 
pragma solidity 0.7.6;

 
interface IIntegration {
    function getName() external view returns (string memory);
}