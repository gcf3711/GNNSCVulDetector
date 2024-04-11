 


 
 

pragma solidity ^0.8.0;

 
interface IERC1822Proxiable {
     
    function proxiableUUID() external view returns (bytes32);
}

 
 

pragma solidity ^0.8.2;






 
abstract contract ERC1967Upgrade {
     
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

     
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

     
    event Upgraded(address indexed implementation);

     
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

     
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

     
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

     
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

     
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
         
         
         
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

     
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

     
    event AdminChanged(address previousAdmin, address newAdmin);

     
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

     
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

     
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

     
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

     
    event BeaconUpgraded(address indexed beacon);

     
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

     
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

     
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

 
 

pragma solidity ^0.8.0;

 
abstract contract ReentrancyGuard {
     
     
     
     
     

     
     
     
     
     
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

     
    modifier nonReentrant() {
         
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

         
        _status = _ENTERED;

        _;

         
         
        _status = _NOT_ENTERED;
    }
}

 
 

pragma solidity ^0.8.2;



 
abstract contract Initializable {
     
    uint8 private _initialized;

     
    bool private _initializing;

     
    event Initialized(uint8 version);

     
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

     
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

     
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

     
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
         
         
         
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

 
 

pragma solidity ^0.8.0;




 
abstract contract UUPSUpgradeable is IERC1822Proxiable, ERC1967Upgrade {
    
    address private immutable __self = address(this);

     
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

     
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

     
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

     
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

     
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

     
    function _authorizeUpgrade(address newImplementation) internal virtual;
}

 

pragma solidity ^0.8.7;

 
 
 
interface IStakefishTransactionFeePool {
    struct UserSummary {
        uint256 validatorCount;
         
         
        uint256 totalStartTimestamps;
         
        uint256 pendingReward;
         
        uint256 collectedReward;
    }

    struct ComputationCache {
        uint256 lastCacheUpdateTime;
        uint256 totalValidatorUptime;

         
        uint256 totalUncollectedCommission;
         
        uint256 totalUncollectedUserBalance;
         
        uint256 totalUnsentUserRewards;
    }

    event ValidatorJoined(bytes indexed validatorPubkey, address indexed depositorAddress, uint256 ts);
    event ValidatorParted(bytes indexed validatorPubkey, address indexed depositorAddress, uint256 ts);
    event ValidatorBulkJoined(bytes validatorPubkeyArray, address[] depositorAddress, uint256 time);
    event ValidatorBulkParted(bytes validatorPubkeyArray, address[] depositorAddress, uint256 time);
    event ValidatorRewardCollected(address indexed depositorAddress, address beneficiary, uint256 rewardAmount, address requester);
    event OperatorChanged(address newOperator);
    event CommissionRateChanged(uint256 newRate);

     
    function joinPool(bytes calldata validatorPubkey, address depositorAddress, uint256 ts) external;
    function partPool(bytes calldata validatorPubkey, uint256 ts) external;
    function bulkJoinPool(bytes calldata validatorPubkeyArray, address[] calldata depositorAddress, uint256 ts) external;
    function bulkPartPool(bytes calldata validatorPubkeyArray, uint256 ts) external;

     
     
     
    function collectReward(address payable beneficiary, uint256 amountRequested) external;

     
    function setCommissionRate(uint256) external;
    function collectPoolCommission(address payable beneficiary, uint256 amountRequested) external;
    function changeOperator(address _newOperator) external;
    function closePoolForWithdrawal() external;
    function openPoolForWithdrawal() external;

     
     
     
     
     
    function emergencyWithdraw(address[] calldata depositorAddresses, address[] calldata beneficiaries, uint256 amountRequested) external;

     
     
     
     
    function pendingReward(address depositorAddress) external view returns (uint256, uint256);
    function totalValidators() external view returns (uint256);
    function getPoolState() external view returns (ComputationCache memory);
    receive() external payable;
}

 

pragma solidity ^0.8.7;



contract StakefishTransactionStorage {

    address internal adminAddress;
    address internal operatorAddress;
    address internal developerAddress;

    uint256 internal validatorCount;
    uint256 public stakefishCommissionRateBasisPoints;

    bool isOpenForWithdrawal;

     
    mapping(address => IStakefishTransactionFeePool.UserSummary) internal users;
     
    mapping(bytes => address) internal validatorsInPool;

     
    IStakefishTransactionFeePool.ComputationCache internal cache;

}

 

pragma solidity ^0.8.7;









contract StakefishTransactionFeePool is
    IStakefishTransactionFeePool,
    StakefishTransactionStorage,
    Initializable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    using Address for address payable;

     
    constructor() initializer {
    }

    function initialize(address operatorAddress_, address adminAddress_, address devAddress_) initializer external {
        require(operatorAddress_ != address(0));
        require(adminAddress_ != address(0));
        require(devAddress_ != address(0));
        adminAddress = adminAddress_;
        operatorAddress = operatorAddress_;
        developerAddress = devAddress_;
        validatorCount = 0;
        stakefishCommissionRateBasisPoints = 2000;
        isOpenForWithdrawal = true;
    }

     
    function _authorizeUpgrade(address) internal override devOnly {}

     
    function updateComputationCache() internal {
        require(cache.lastCacheUpdateTime <= block.timestamp, "Time cannot flow backward");

         
        uint256 balanceDiffSinceLastUpdate = address(this).balance
            - cache.totalUncollectedCommission
            - cache.totalUncollectedUserBalance
            - cache.totalUnsentUserRewards;
        uint256 commission = balanceDiffSinceLastUpdate * stakefishCommissionRateBasisPoints / 10000;
        cache.totalUncollectedCommission += commission;
        cache.totalUncollectedUserBalance += balanceDiffSinceLastUpdate - commission;

         
        cache.totalValidatorUptime += (block.timestamp - cache.lastCacheUpdateTime) * validatorCount;
        cache.lastCacheUpdateTime = block.timestamp;
    }

     
    function joinPool(
        bytes calldata validatorPubKey,
        address depositor,
        uint256 joinTime
    ) external override nonReentrant operatorOnly {
        _joinPool(validatorPubKey, depositor, joinTime);
         
        emit ValidatorJoined(validatorPubKey, depositor, joinTime);
    }

    function _joinPool(
        bytes calldata validatorPubKey,
        address depositor,
        uint256 joinTime
    ) internal {
        require(
            validatorsInPool[validatorPubKey] == address(0),
            "Validator already in pool"
        );
        require(
            depositor != address(0),
            "depositorAddress must be set"
        );

        uint256 curTime = block.timestamp;
        require(joinTime <= curTime, "Invalid validator joinTime");

         
        users[depositor].validatorCount += 1;
        users[depositor].totalStartTimestamps += joinTime;
        validatorsInPool[validatorPubKey] = depositor;

        updateComputationCache();
         
        cache.totalValidatorUptime += curTime - joinTime;
        validatorCount += 1;
    }

    function partPool(
        bytes calldata validatorPubKey,
        uint256 leaveTime
    ) external override nonReentrant operatorOnly {
        address depositor = _partPool(validatorPubKey, leaveTime);
        emit ValidatorParted(validatorPubKey, depositor, leaveTime);
    }

    function _partPool(
        bytes calldata validatorPubKey,
        uint256 leaveTime
    ) internal returns (address depositorAddress) {
        address depositor = validatorsInPool[validatorPubKey];
        require(
            depositor != address(0),
            "Validator not in pool"
        );

        uint256 curTime = block.timestamp;
        require(leaveTime <= curTime, "Invalid validator leaveTime");

        updateComputationCache();

         
        validatorCount -= 1;
        uint256 averageStartTime = users[depositor].totalStartTimestamps / users[depositor].validatorCount;
        users[depositor].totalStartTimestamps -= averageStartTime;
        users[depositor].validatorCount -= 1;
        delete validatorsInPool[validatorPubKey];

         
        uint256 payoutUptime = curTime - averageStartTime;
        uint256 payoutAmount = computePayout(payoutUptime);
        cache.totalValidatorUptime -= payoutUptime;
        cache.totalUncollectedUserBalance -= payoutAmount;
        cache.totalUnsentUserRewards += payoutAmount;
        users[depositor].pendingReward += payoutAmount;

        return depositor;
    }

     
     
     
     
    function bulkJoinPool(
        bytes calldata validatorPubkeyArray,
        address[] calldata depositorAddresses,
        uint256 ts
    ) external override nonReentrant operatorOnly {
        require(ts <= block.timestamp, "Invalid validator join timestamp");
        uint256 bulkCount = validatorPubkeyArray.length / 48;
        require(depositorAddresses.length == 1 || depositorAddresses.length == bulkCount, "Invalid depositorAddresses length");

        if (depositorAddresses.length == 1) {
            bytes memory validatorPubkey;
            address depositor = depositorAddresses[0];
            require(depositor != address(0), "depositorAddress must be set");
            for(uint256 i = 0; i < bulkCount; i++) {
                validatorPubkey = validatorPubkeyArray[i * 48 : (i + 1) * 48];
                require(
                    validatorsInPool[validatorPubkey] == address(0),
                    "Validator already in pool"
                );
                validatorsInPool[validatorPubkey] = depositor;
            }
             
             
            users[depositor].validatorCount += bulkCount;
            users[depositor].totalStartTimestamps += ts * bulkCount;
        } else {
            address depositor;
            bytes memory validatorPubkey;
            for(uint256 i = 0; i < bulkCount; i++) {
                depositor = depositorAddresses[i];
                require(depositor != address(0), "depositorAddress must be set");
                validatorPubkey = validatorPubkeyArray[i * 48 : (i + 1) * 48];
                require(
                    validatorsInPool[validatorPubkey] == address(0),
                    "Validator already in pool"
                );

                users[depositor].validatorCount += 1;
                users[depositor].totalStartTimestamps += ts;
                validatorsInPool[validatorPubkey] = depositor;
            }
        }

        updateComputationCache();
        cache.totalValidatorUptime += (block.timestamp - ts) * bulkCount;
        validatorCount += bulkCount;
        emit ValidatorBulkJoined(validatorPubkeyArray, depositorAddresses, ts);
    }

    function bulkPartPool(
        bytes calldata validatorPubkeyArray,
        uint256 ts
    ) external override nonReentrant operatorOnly {
        address[] memory depositorAddresses = new address[](validatorPubkeyArray.length / 48);

        for(uint256 i = 0; i < depositorAddresses.length; i++) {
             
            address depositorAddress = _partPool(validatorPubkeyArray[i*48:(i+1)*48], ts);
            depositorAddresses[i] = depositorAddress;
        }

        emit ValidatorBulkParted(validatorPubkeyArray, depositorAddresses, ts);
    }

     
     
    function computePayout(uint256 payoutUptime) internal view returns (uint256) {
        return cache.totalUncollectedUserBalance * payoutUptime / cache.totalValidatorUptime;
    }

     
     
    function pendingReward(address depositorAddress) external override view returns (uint256, uint256) {
        require(depositorAddress != address(0), "depositorAddress must be set");

        if (users[depositorAddress].validatorCount > 0) {
            uint256 balanceDiffSinceLastUpdate = address(this).balance
                - cache.totalUncollectedCommission
                - cache.totalUncollectedUserBalance
                - cache.totalUnsentUserRewards;
            uint256 commission = balanceDiffSinceLastUpdate * stakefishCommissionRateBasisPoints / 10000;
            uint256 uncollectedUserBalance = cache.totalUncollectedUserBalance + balanceDiffSinceLastUpdate - commission;

            uint256 totalValidatorUptime =
                cache.totalValidatorUptime + (block.timestamp - cache.lastCacheUpdateTime) * validatorCount;

            uint256 payoutAmount = 0;
             
            if (totalValidatorUptime > 0) {
                uint256 payoutUptime =
                    block.timestamp * users[depositorAddress].validatorCount - users[depositorAddress].totalStartTimestamps;
                payoutAmount = uncollectedUserBalance * payoutUptime / totalValidatorUptime;
            }
            return (
                payoutAmount + users[depositorAddress].pendingReward,
                users[depositorAddress].collectedReward
            );
        } else {
            return (users[depositorAddress].pendingReward, users[depositorAddress].collectedReward);
        }
    }

    function _collectReward(
        address depositorAddress,
        address payable beneficiary,
        uint256 amountRequested
    ) internal {
        if (beneficiary == address(0)) {
            beneficiary = payable(depositorAddress);
        }

        uint256 userValidatorCount = users[depositorAddress].validatorCount;
        if (userValidatorCount > 0) {
            uint256 payoutUptime =
                block.timestamp * userValidatorCount - users[depositorAddress].totalStartTimestamps;
            uint256 payoutAmount = computePayout(payoutUptime);

            cache.totalValidatorUptime -= payoutUptime;
            cache.totalUncollectedUserBalance -= payoutAmount;
            cache.totalUnsentUserRewards += payoutAmount;
            users[depositorAddress].totalStartTimestamps = block.timestamp * userValidatorCount;
            users[depositorAddress].pendingReward += payoutAmount;
        }

        if (amountRequested == 0 || users[depositorAddress].pendingReward <= amountRequested) {
            uint256 amount = users[depositorAddress].pendingReward;
            cache.totalUnsentUserRewards -= amount;
            users[depositorAddress].collectedReward += amount;
            users[depositorAddress].pendingReward -= amount;
            emit ValidatorRewardCollected(depositorAddress, beneficiary, amount, msg.sender);
            beneficiary.sendValue(amount);
        } else {
            cache.totalUnsentUserRewards -= amountRequested;
            users[depositorAddress].collectedReward += amountRequested;
            users[depositorAddress].pendingReward -= amountRequested;
            emit ValidatorRewardCollected(depositorAddress, beneficiary, amountRequested, msg.sender);
            beneficiary.sendValue(amountRequested);
        }
    }

     
     
    function collectReward(address payable beneficiary, uint256 amountRequested) external override nonReentrant {
        require(isOpenForWithdrawal, "Pool is not open for withdrawal right now");
        updateComputationCache();
        _collectReward(msg.sender, beneficiary, amountRequested);
    }

     
    function setCommissionRate(uint256 commissionRate) external override nonReentrant adminOnly {
        stakefishCommissionRateBasisPoints = commissionRate;
        emit CommissionRateChanged(stakefishCommissionRateBasisPoints);
    }

     
     
    function collectPoolCommission(address payable beneficiary, uint256 amountRequested)
        external
        override
        nonReentrant
        adminOnly
    {
        updateComputationCache();

        if (amountRequested == 0 || cache.totalUncollectedCommission < amountRequested) {
          uint256 payout = cache.totalUncollectedCommission;
          cache.totalUncollectedCommission = 0;
          beneficiary.sendValue(payout);
        } else {
          cache.totalUncollectedCommission -= amountRequested;
          beneficiary.sendValue(amountRequested);
        }
    }

     
    function closePoolForWithdrawal() external virtual override nonReentrant adminOnly {
        require(isOpenForWithdrawal, "Pool is already closed for withdrawal");
        isOpenForWithdrawal = false;
    }

    function openPoolForWithdrawal() external virtual override nonReentrant adminOnly {
        require(!isOpenForWithdrawal, "Pool is already open for withdrawal");
        isOpenForWithdrawal = true;
    }

    function changeOperator(address newOperator) external override nonReentrant adminOnly {
        require(newOperator != address(0));
        operatorAddress = newOperator;
        emit OperatorChanged(operatorAddress);
    }

    function emergencyWithdraw (
        address[] calldata depositorAddresses,
        address[] calldata beneficiaries,
        uint256 maxAmount
    )
        external
        override
        nonReentrant
        adminOnly
    {
        require(beneficiaries.length == depositorAddresses.length || beneficiaries.length == 1, "beneficiaries length incorrect");
        updateComputationCache();
        if (beneficiaries.length == 1) {
            for (uint256 i = 0; i < depositorAddresses.length; i++) {
                _collectReward(depositorAddresses[i], payable(beneficiaries[0]), maxAmount);
            }
        } else {
            for (uint256 i = 0; i < depositorAddresses.length; i++) {
                _collectReward(depositorAddresses[i], payable(beneficiaries[i]), maxAmount);
            }
        }
    }

     

    function totalValidators() external override view returns (uint256) {
        return validatorCount;
    }

    function getPoolState() external override view returns (ComputationCache memory) {
        return cache;
    }

     
    modifier operatorOnly() {
        require(
            msg.sender == operatorAddress,
            "Only stakefish operator allowed"
        );
        _;
    }

    modifier adminOnly() {
        require(
            msg.sender == adminAddress,
            "Only stakefish admin allowed"
        );
        _;
    }

    modifier devOnly() {
        require(
            msg.sender == developerAddress,
            "Only stakefish dev allowed"
        );
        _;
    }

     
    receive() external override payable {
         
         
         
         
    }
}

 

pragma solidity ^0.8.7;

 
interface IMigrator {
    function migrate(address payable toAddress) external;
} 

pragma solidity ^0.8.7;




contract StakefishTransactionFeePoolMigrator is
    StakefishTransactionFeePool,
    IMigrator
{
    using Address for address payable;

    function closePoolForWithdrawal() external override nonReentrant devOnly {
        require(isOpenForWithdrawal, "Pool is already closed for withdrawal");
        isOpenForWithdrawal = false;
    }

    function openPoolForWithdrawal() external override nonReentrant devOnly {
        require(!isOpenForWithdrawal, "Pool is already open for withdrawal");
        isOpenForWithdrawal = true;
    }

     
    function migrate(address payable toAddress) external override nonReentrant devOnly {
        require(toAddress != address(0), "Invalid toAddress");
        toAddress.sendValue(address(this).balance);
    }

}

 
 

pragma solidity ^0.8.1;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         

        return account.code.length > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

     
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

     
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

     
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

     
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

     
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

     
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

 
 

pragma solidity ^0.8.0;

 
interface IBeacon {
     
    function implementation() external view returns (address);
}

 
 

pragma solidity ^0.8.0;

 
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

     
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

     
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}
