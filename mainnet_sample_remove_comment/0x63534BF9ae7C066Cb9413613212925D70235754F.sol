 
pragma abicoder v2;
pragma experimental ABIEncoderV2;


 
pragma solidity >=0.7.6;


interface IUnipilotFarm {
    struct PoolInfo {
        uint256 startBlock;
        uint256 globalReward;
        uint256 lastRewardBlock;
        uint256 totalLockedLiquidity;
        uint256 rewardMultiplier;
        bool isRewardActive;
        bool isAltActive;
    }

    struct PoolAltInfo {
        address altToken;
        uint256 startBlock;
        uint256 globalReward;
        uint256 lastRewardBlock;
    }

    struct UserInfo {
        bool boosterActive;
        address pool;
        address user;
        uint256 reward;
        uint256 altReward;
        uint256 liquidity;
    }

    struct TempInfo {
        uint256 globalReward;
        uint256 lastRewardBlock;
        uint256 rewardMultiplier;
    }

    enum DirectTo {
        GRforPilot,
        GRforAlt
    }

    event Deposit(
        address pool,
        uint256 tokenId,
        uint256 liquidity,
        uint256 totalSupply,
        uint256 globalReward,
        uint256 rewardMultiplier,
        uint256 rewardPerBlock
    );
    event WithdrawReward(
        address pool,
        uint256 tokenId,
        uint256 liquidity,
        uint256 reward,
        uint256 globalReward,
        uint256 totalSupply,
        uint256 lastRewardTransferred
    );
    event WithdrawNFT(
        address pool,
        address userAddress,
        uint256 tokenId,
        uint256 totalSupply
    );

    event NewPool(
        address pool,
        uint256 rewardPerBlock,
        uint256 rewardMultiplier,
        uint256 lastRewardBlock,
        bool status
    );

    event BlacklistPool(address pool, bool status, uint256 time);

    event UpdateULM(address oldAddress, address newAddress, uint256 time);

    event UpdatePilotPerBlock(address pool, uint256 updated);

    event UpdateMultiplier(address pool, uint256 old, uint256 updated);

    event UpdateActiveAlt(address old, address updated, address pool);

    event UpdateAltState(bool old, bool updated, address pool);

    event UpdateFarmingLimit(uint256 old, uint256 updated);

    event RewardStatus(address pool, bool old, bool updated);

    event MigrateFunds(address account, address token, uint256 amount);

    event FarmingStatus(bool old, bool updated, uint256 time);

    event Stake(address old, address updated);

    event ToggleBooster(uint256 tokenId, bool old, bool updated);

    event UserBooster(uint256 tokenId, uint256 booster);

    event BackwardCompatible(bool old, bool updated);

    event GovernanceUpdated(address old, address updated);

    function initializer(address[] memory pools, uint256[] memory _multipliers) external;

    function blacklistPools(address[] memory pools) external;

    function updatePilotPerBlock(uint256 value) external;

    function updateMultiplier(address pool, uint256 value) external;

    function updateULM(address _ULM) external;

    function totalUserNftWRTPool(address userAddress, address pool)
        external
        view
        returns (uint256 tokenCount, uint256[] memory tokenIds);

    function nftStatus(uint256 tokenId) external view returns (bool);

    function depositNFT(uint256 tokenId) external returns (bool);

    function withdrawNFT(uint256 tokenId) external;

    function withdrawReward(uint256 tokenId) external;

    function currentReward(uint256 _tokenId)
        external
        view
        returns (
            uint256 pilotReward,
            uint256 globalReward,
            uint256 globalAltReward,
            uint256 altReward
        );

    function toggleRewardStatus(address pool) external;

    function toggleFarmingActive() external;
}

 

pragma solidity ^0.7.0;

 
interface IERC721Receiver {
     
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

 
pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {
    uint8 private _unlocked = 1;

    modifier nonReentrant() {
        require(_unlocked == 1, "ReentrancyGuard: reentrant call");
        _unlocked = 0;
        _;
        _unlocked = 1;
    }
}

 

pragma solidity >=0.7.6;

interface IULMEvents {
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        address indexed pool,
        uint24 fee,
        uint160 sqrtPriceX96
    );

    event PoolReajusted(
        address pool,
        uint128 baseLiquidity,
        uint128 rangeLiquidity,
        int24 newBaseTickLower,
        int24 newBaseTickUpper,
        int24 newRangeTickLower,
        int24 newRangeTickUpper
    );

    event Deposited(
        address indexed pool,
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    event Collect(
        uint256 tokenId,
        uint256 userAmount0,
        uint256 userAmount1,
        uint256 pilotAmount,
        address pool,
        address recipient
    );

    event Withdrawn(
        address indexed pool,
        address indexed recipient,
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    );
}

 

pragma solidity ^0.7.0;

 
interface IERC165 {
     
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
 
pragma solidity >=0.7.6;







 






 


 








contract UnipilotFarm is IUnipilotFarm, ReentrancyGuard, IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isFarmingActive;
    bool public backwardCompatible;
    address public governance;
    uint256 public pilotPerBlock = 1e18;
    uint256 public farmingGrowthBlockLimit;
    uint256 public totalRewardSent;

    address private ulm;
    address private stakeContract;
    address[2] private deprecated;

    address private constant PILOT_TOKEN = 0x37C997B35C619C21323F3518B9357914E8B99525; 
    address private constant UNIPILOT = 0xde5bF92E3372AA59C73Ca7dFc6CEc599E1B2b08C;

    address[] public poolListed;

     
    mapping(uint256 => bool) public farmingActive;

     
    mapping(address => bool) public poolWhitelist;

     
    mapping(address => PoolInfo) public poolInfo;

     
    mapping(address => PoolAltInfo) public poolAltInfo;

     
    mapping(uint256 => UserInfo) public userInfo;

     
    mapping(address => mapping(address => uint256[])) public userToPoolToTokenIds;
    modifier onlyGovernance() {
        require(msg.sender == governance, "NA");
        _;
    }

    modifier isActive() {
        require(isFarmingActive, "FNA");
        _;
    }

    modifier isLimitActive() {
        require(farmingGrowthBlockLimit == 0, "LA");
        _;
    }

    modifier onlyOwner(uint256 _tokenId) {
        require(IERC721(UNIPILOT).ownerOf(_tokenId) == msg.sender, "NO");
        _;
    }

    modifier isPoolRewardActive(address pool) {
        require(poolInfo[pool].isRewardActive, "RNA");
        _;
    }

    modifier onlyStake() {
        require(msg.sender == stakeContract, "NS");
        _;
    }

    constructor(
        address _ulm,
        address _governance,
        address[2] memory _deprecated
    ) {
        governance = _governance;

        ulm = _ulm;

        isFarmingActive = true;

        deprecated = _deprecated;

        backwardCompatible = true;
    }

    
    
    
    function withdrawNFT(uint256 _tokenId) external override {
        UserInfo storage userState = userInfo[_tokenId];

        PoolInfo storage poolState = poolInfo[userState.pool];

        PoolAltInfo storage poolAltState = poolAltInfo[userState.pool];

        withdrawReward(_tokenId);

        poolState.totalLockedLiquidity = poolState.totalLockedLiquidity.sub(
            userState.liquidity
        );

        IERC721(UNIPILOT).safeTransferFrom(address(this), msg.sender, _tokenId);

        farmingActive[_tokenId] = false;

        emit WithdrawNFT(
            userState.pool,
            userState.user,
            _tokenId,
            poolState.totalLockedLiquidity
        );

        if (poolState.totalLockedLiquidity == 0) {
            poolState.startBlock = block.number;
            poolState.lastRewardBlock = block.number;
            poolState.globalReward = 0;

            poolAltState.startBlock = block.number;
            poolAltState.lastRewardBlock = block.number;
            poolAltState.globalReward = 0;
        }

        uint256 index = callIndex(userState.pool, _tokenId);

        updateNFTList(index, userState.user, userState.pool);

        delete userInfo[_tokenId];
    }

    
    
    function emergencyNFTWithdraw(uint256 _tokenId) external {
        UserInfo storage userState = userInfo[_tokenId];

        require(userState.user == msg.sender, "NOO");

        PoolInfo storage poolState = poolInfo[userState.pool];

        PoolAltInfo storage poolAltState = poolAltInfo[userState.pool];

        poolState.totalLockedLiquidity = poolState.totalLockedLiquidity.sub(
            userState.liquidity
        );

        IERC721(UNIPILOT).safeTransferFrom(address(this), userState.user, _tokenId);

        if (poolState.totalLockedLiquidity == 0) {
            poolState.startBlock = block.number;
            poolState.lastRewardBlock = block.number;
            poolState.globalReward = 0;

            poolAltState.startBlock = block.number;
            poolAltState.lastRewardBlock = block.number;
            poolAltState.globalReward = 0;
        }
        uint256 index = callIndex(userState.pool, _tokenId);
        updateNFTList(index, userState.user, userState.pool);
        delete userInfo[_tokenId];
    }

    
    
    
    
    
    function migrateFunds(
        address _newContract,
        address _tokenAddress,
        uint256 _amount
    ) external onlyGovernance {
        require(_newContract != address(0), "CNE");
        IERC20(_tokenAddress).safeTransfer(_newContract, _amount);
        emit MigrateFunds(_newContract, _tokenAddress, _amount);
    }

    
    
    
    function blacklistPools(address[] memory _pools) external override onlyGovernance {
        for (uint256 i = 0; i < _pools.length; i++) {
            poolWhitelist[_pools[i]] = false;
            poolInfo[_pools[i]].rewardMultiplier = 0;    
            emit BlacklistPool(_pools[i], poolWhitelist[_pools[i]], block.timestamp);
        }
    }

    
    
    
    function updateULM(address _ulm) external override onlyGovernance {
        emit UpdateULM(ulm, ulm = _ulm, block.timestamp);
    }

    
    
    
    function updatePilotPerBlock(uint256 _value) external override onlyGovernance {
        address[] memory pools = poolListed;
        pilotPerBlock = _value;
        for (uint256 i = 0; i < pools.length; i++) {
            if (poolWhitelist[pools[i]]) {
                if (poolInfo[pools[i]].totalLockedLiquidity != 0) {
                    updatePoolState(pools[i]);
                }
                emit UpdatePilotPerBlock(pools[i], pilotPerBlock);
            }
        }
    }

    
    
    
    
    function updateMultiplier(address _pool, uint256 _value)
        external
        override
        onlyGovernance
    {
        updatePoolState(_pool);

        emit UpdateMultiplier(
            _pool,
            poolInfo[_pool].rewardMultiplier,
            poolInfo[_pool].rewardMultiplier = _value
        );
    }

    
    
    
    
    
    function totalUserNftWRTPool(address _user, address _pool)
        external
        view
        override
        returns (uint256 tokenCount, uint256[] memory tokenIds)
    {
        tokenCount = userToPoolToTokenIds[_user][_pool].length;
        tokenIds = userToPoolToTokenIds[_user][_pool];
    }

    
    
    function nftStatus(uint256 _tokenId) external view override returns (bool) {
        return farmingActive[_tokenId];
    }

    
    
    
    
    function depositNFT(uint256 _tokenId)
        external
        override
        isActive
        isLimitActive
        onlyOwner(_tokenId)
        returns (bool)
    {
        address sender = msg.sender;
        IUniswapLiquidityManager.Position memory positions = IUniswapLiquidityManager(ulm)
            .userPositions(_tokenId);

        (address pool, uint256 liquidity) = (positions.pool, positions.liquidity);

        require(poolWhitelist[pool], "PNW");

        IUniswapLiquidityManager.LiquidityPosition
            memory liquidityPositions = IUniswapLiquidityManager(ulm).poolPositions(pool);

        uint256 totalLiquidity = liquidityPositions.totalLiquidity;

        require(totalLiquidity >= liquidity && liquidity > 0, "IL");

        PoolInfo storage poolState = poolInfo[pool];

        if (poolState.lastRewardBlock != poolState.startBlock) {
            uint256 blockDifference = (block.number).sub(poolState.lastRewardBlock);

            poolState.globalReward = getGlobalReward(
                pool,
                blockDifference,
                pilotPerBlock,
                poolState.rewardMultiplier,
                poolState.globalReward
            );
        }

        poolState.totalLockedLiquidity = poolState.totalLockedLiquidity.add(liquidity);

        userInfo[_tokenId] = UserInfo({
            pool: pool,
            liquidity: liquidity,
            user: sender,
            reward: poolState.globalReward,
            altReward: userInfo[_tokenId].altReward,
            boosterActive: false
        });
        userToPoolToTokenIds[sender][pool].push(_tokenId);

        farmingActive[_tokenId] = true;  

        IERC721(UNIPILOT).safeTransferFrom(sender, address(this), _tokenId);

        if (poolState.isAltActive) {
            altGR(pool, _tokenId);
        }

        poolState.lastRewardBlock = block.number;

        emit Deposit(
            pool,
            _tokenId,
            userInfo[_tokenId].liquidity,
            poolState.totalLockedLiquidity,
            poolState.globalReward,
            poolState.rewardMultiplier,
            pilotPerBlock
        );
        return farmingActive[_tokenId];
    }

    
    
    
    function toggleActiveAlt(address _pool) external onlyGovernance returns (bool) {
        require(poolAltInfo[_pool].altToken != address(0), "TNE");
        emit UpdateAltState(
            poolInfo[_pool].isAltActive,
            poolInfo[_pool].isAltActive = !poolInfo[_pool].isAltActive,
            _pool
        );

        if (poolInfo[_pool].isAltActive) {
            updateAltPoolState(_pool);
        } else {
            poolAltInfo[_pool].lastRewardBlock = block.number;
        }

        return poolInfo[_pool].isAltActive;
    }

    
    
    function updateAltToken(address _pool, address _altToken) external onlyGovernance {
        emit UpdateActiveAlt(
            poolAltInfo[_pool].altToken,
            poolAltInfo[_pool].altToken = _altToken,
            _pool
        );

        PoolAltInfo memory poolAltState = poolAltInfo[_pool];
        poolAltState = PoolAltInfo({
            globalReward: 0,
            lastRewardBlock: block.number,
            altToken: poolAltInfo[_pool].altToken,
            startBlock: block.number
        });

        poolAltInfo[_pool] = poolAltState;
    }

    
    
    
    function initializer(address[] memory _pools, uint256[] memory _multipliers)
        public
        override
        onlyGovernance
    {
        require(_pools.length == _multipliers.length, "LNS");
        for (uint256 i = 0; i < _pools.length; i++) {
            if (
                !poolWhitelist[_pools[i]] && poolInfo[_pools[i]].startBlock == 0
            ) {
                insertPool(_pools[i], _multipliers[i]);
            } else {
                poolWhitelist[_pools[i]] = true;
                poolInfo[_pools[i]].rewardMultiplier = _multipliers[i];
            }
        }
    }

    
    
    
    
    
    
    function getGlobalReward(
        address pool,
        uint256 blockDifference,
        uint256 rewardPerBlock,
        uint256 multiplier,
        uint256 _globalReward
    ) public view returns (uint256 globalReward) {
        uint256 tvl;
        if (backwardCompatible) {
            for(uint i = 0; i < deprecated.length; i++){
               uint256 prevTvl=(IUnipilotFarmV1(deprecated[i]).poolInfo(pool).totalLockedLiquidity);
               tvl=tvl.add(prevTvl); 
            }
            tvl = tvl.add(poolInfo[pool].totalLockedLiquidity);
        } else {
            tvl = poolInfo[pool].totalLockedLiquidity;
        }
        uint256 temp = FullMath.mulDiv(rewardPerBlock, multiplier, 1e18);
        globalReward = FullMath.mulDiv(blockDifference.mul(temp), 1e18, tvl).add(
            _globalReward
        );
    }

    
    
    
    
    
    
    function currentReward(uint256 _tokenId)
        public
        view
        override
        returns (
            uint256 pilotReward,
            uint256 globalReward,
            uint256 globalAltReward,
            uint256 altReward
        )
    {
        UserInfo memory userState = userInfo[_tokenId];
        PoolInfo memory poolState = poolInfo[userState.pool];
        PoolAltInfo memory poolAltState = poolAltInfo[userState.pool];

        DirectTo check = DirectTo.GRforPilot;

        if (isFarmingActive) {
            globalReward = checkLimit(_tokenId, check);

            if (poolState.isAltActive) {
                check = DirectTo.GRforAlt;
                globalAltReward = checkLimit(_tokenId, check);
            } else {
                globalAltReward = poolAltState.globalReward;
            }
        } else {
            globalReward = poolState.globalReward;
            globalAltReward = poolAltState.globalReward;
        }

        uint256 userReward = globalReward.sub(userState.reward);
        uint256 _reward = (userReward.mul(userState.liquidity)).div(1e18);
        if (userState.boosterActive) {
            uint256 multiplier = IUnipilotStake(stakeContract).getBoostMultiplier(
                userState.user,
                userState.pool,
                _tokenId
            );
            uint256 boostedReward = (_reward.mul(multiplier)).div(1e18);
            pilotReward = _reward.add((boostedReward));
        } else {
            pilotReward = _reward;
        }

        _reward = globalAltReward.sub(userState.altReward);
        altReward = (_reward.mul(userState.liquidity)).div(1e18);
    }

    
    function checkLimit(uint256 _tokenId, DirectTo _check)
        internal
        view
        returns (uint256 globalReward)
    {
        address pool = userInfo[_tokenId].pool;

        TempInfo memory poolState;

        if (_check == DirectTo.GRforPilot) {
            poolState = TempInfo({
                globalReward: poolInfo[pool].globalReward,
                lastRewardBlock: poolInfo[pool].lastRewardBlock,
                rewardMultiplier: poolInfo[pool].rewardMultiplier
            });
        } else if (_check == DirectTo.GRforAlt) {
            poolState = TempInfo({
                globalReward: poolAltInfo[pool].globalReward,
                lastRewardBlock: poolAltInfo[pool].lastRewardBlock,
                rewardMultiplier: poolInfo[pool].rewardMultiplier
            });
        }

        if (
            poolState.lastRewardBlock < farmingGrowthBlockLimit &&
            block.number > farmingGrowthBlockLimit
        ) {
            globalReward = getGlobalReward(
                pool,
                farmingGrowthBlockLimit.sub(poolState.lastRewardBlock),
                pilotPerBlock,
                poolState.rewardMultiplier,
                poolState.globalReward
            );
        } else if (
            poolState.lastRewardBlock > farmingGrowthBlockLimit &&
            farmingGrowthBlockLimit > 0
        ) {
            globalReward = poolState.globalReward;
        } else {
            uint256 blockDifference = (block.number).sub(poolState.lastRewardBlock);
            globalReward = getGlobalReward(
                pool,
                blockDifference,
                pilotPerBlock,
                poolState.rewardMultiplier,
                poolState.globalReward
            );
        }
    }

    
    
    
    function withdrawReward(uint256 _tokenId)
        public
        override
        nonReentrant
        isPoolRewardActive(userInfo[_tokenId].pool)
    {
        UserInfo storage userState = userInfo[_tokenId];
        PoolInfo storage poolState = poolInfo[userState.pool];

        require(userState.user == msg.sender, "NO");
        (
            uint256 pilotReward,
            uint256 globalReward,
            uint256 globalAltReward,
            uint256 altReward
        ) = currentReward(_tokenId);

        require(IERC20(PILOT_TOKEN).balanceOf(address(this)) >= pilotReward, "IF");

        poolState.globalReward = globalReward;
        poolState.lastRewardBlock = block.number;
        userState.reward = globalReward;

        totalRewardSent += pilotReward;

        IERC20(PILOT_TOKEN).safeTransfer(userInfo[_tokenId].user, pilotReward);

        if (poolState.isAltActive) {
            altWithdraw(_tokenId, globalAltReward, altReward);
        }

        emit WithdrawReward(
            userState.pool,
            _tokenId,
            userState.liquidity,
            userState.reward,
            poolState.globalReward,
            poolState.totalLockedLiquidity,
            pilotReward
        );
    }

    
    
    
    function insertPool(address _pool, uint256 _multiplier) internal {
        poolWhitelist[_pool] = true;
        poolListed.push(_pool);
        poolInfo[_pool] = PoolInfo({
            startBlock: block.number,
            globalReward: 0,
            lastRewardBlock: block.number,
            totalLockedLiquidity: 0,
            rewardMultiplier: _multiplier,
            isRewardActive: true,
            isAltActive: poolInfo[_pool].isAltActive
        });

        emit NewPool(
            _pool,
            pilotPerBlock,
            poolInfo[_pool].rewardMultiplier,
            poolInfo[_pool].lastRewardBlock,
            poolWhitelist[_pool]
        );
    }

    
    function altGR(address _pool, uint256 _tokenId) internal {
        PoolAltInfo storage poolAltState = poolAltInfo[_pool];

        if (poolAltState.lastRewardBlock != poolAltState.startBlock) {
            uint256 blockDifference = (block.number).sub(poolAltState.lastRewardBlock);

            poolAltState.globalReward = getGlobalReward(
                _pool,
                blockDifference,
                pilotPerBlock,
                poolInfo[_pool].rewardMultiplier,
                poolAltState.globalReward
            );
        }

        poolAltState.lastRewardBlock = block.number;

        userInfo[_tokenId].altReward = poolAltState.globalReward;
    }

    
    function callIndex(address pool, uint256 _tokenId)
        internal
        view
        returns (uint256 index)
    {
        uint256[] memory tokens = userToPoolToTokenIds[msg.sender][pool];
        for (uint256 i = 0; i <= tokens.length; i++) {
            if (_tokenId == userToPoolToTokenIds[msg.sender][pool][i]) {
                index = i;
                break;
            }
        }
        return index;
    }

    
    function updateNFTList(
        uint256 _index,
        address user,
        address pool
    ) internal {
        require(_index < userToPoolToTokenIds[user][pool].length, "IOB");
        uint256 temp = userToPoolToTokenIds[user][pool][
            userToPoolToTokenIds[user][pool].length.sub(1)
        ];
        userToPoolToTokenIds[user][pool][_index] = temp;
        userToPoolToTokenIds[user][pool].pop();
    }

    
    function toggleFarmingActive() external override onlyGovernance {
        emit FarmingStatus(
            isFarmingActive,
            isFarmingActive = !isFarmingActive,
            block.timestamp
        );
    }

    
    function altWithdraw(
        uint256 _tokenId,
        uint256 altGlobalReward,
        uint256 altReward
    ) internal {
        PoolAltInfo storage poolAltState = poolAltInfo[userInfo[_tokenId].pool];
        require(
            IERC20(poolAltState.altToken).balanceOf(address(this)) >= altReward,
            "IF"
        );
        poolAltState.lastRewardBlock = block.number;
        poolAltState.globalReward = altGlobalReward;
        userInfo[_tokenId].altReward = altGlobalReward;
        IERC20(poolAltState.altToken).safeTransfer(userInfo[_tokenId].user, altReward);
    }

    
    function toggleRewardStatus(address _pool) external override onlyGovernance {
        if (poolInfo[_pool].isRewardActive) {
            updatePoolState(_pool);
        } else {
            poolInfo[_pool].lastRewardBlock = block.number;
        }

        emit RewardStatus(
            _pool,
            poolInfo[_pool].isRewardActive,
            poolInfo[_pool].isRewardActive = !poolInfo[_pool].isRewardActive
        );
    }

    
    function updatePoolState(address _pool) internal {
        PoolInfo storage poolState = poolInfo[_pool];
        if (poolState.totalLockedLiquidity > 0) {
            uint256 currentGlobalReward = getGlobalReward(
                _pool,
                (block.number).sub(poolState.lastRewardBlock),
                pilotPerBlock,
                poolState.rewardMultiplier,
                poolState.globalReward
            );

            poolState.globalReward = currentGlobalReward;
            poolState.lastRewardBlock = block.number;
        }
    }

    
    function updateAltPoolState(address _pool) internal {
        PoolAltInfo storage poolAltState = poolAltInfo[_pool];
        if (poolInfo[_pool].totalLockedLiquidity > 0) {
            uint256 currentGlobalReward = getGlobalReward(
                _pool,
                (block.number).sub(poolAltState.lastRewardBlock),
                pilotPerBlock,
                poolInfo[_pool].rewardMultiplier,
                poolAltState.globalReward
            );

            poolAltState.globalReward = currentGlobalReward;
            poolAltState.lastRewardBlock = block.number;
        }
    }

    
    function updateFarmingLimit(uint256 _blockNumber) external onlyGovernance {
        emit UpdateFarmingLimit(
            farmingGrowthBlockLimit,
            farmingGrowthBlockLimit = _blockNumber
        );
    }

    
    function toggleBooster(uint256 tokenId) external onlyStake {
        emit ToggleBooster(
            tokenId,
            userInfo[tokenId].boosterActive,
            userInfo[tokenId].boosterActive = !userInfo[tokenId].boosterActive
        );
    }

    
    function setStake(address _stakeContract) external onlyGovernance {
        emit Stake(stakeContract, stakeContract = _stakeContract);
    }

    
    function toggleBackwardCompatibility() external onlyGovernance {
        emit BackwardCompatible(
            backwardCompatible,
            backwardCompatible = !backwardCompatible
        );
    }

    
    function updateGovernance(address _governance) external onlyGovernance {
        emit GovernanceUpdated(governance, governance = _governance);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {
         
    }
}

 

pragma solidity >=0.7.6;




interface IUniswapLiquidityManager is IULMEvents {
    struct LiquidityPosition {
         
        int24 baseTickLower;
        int24 baseTickUpper;
        uint128 baseLiquidity;
         
        int24 rangeTickLower;
        int24 rangeTickUpper;
        uint128 rangeLiquidity;
         
        uint256 fees0;
        uint256 fees1;
        uint256 feeGrowthGlobal0;
        uint256 feeGrowthGlobal1;
         
        uint256 totalLiquidity;
         
        bool feesInPilot;
         
        address oracle0;
        address oracle1;
         
        uint256 timestamp;
        uint8 counter;
        bool status;
        bool managed;
    }

    struct Position {
        uint256 nonce;
        address pool;
        uint256 liquidity;
        uint256 feeGrowth0;
        uint256 feeGrowth1;
        uint256 tokensOwed0;
        uint256 tokensOwed1;
    }

    struct ReadjustVars {
        bool zeroForOne;
        address poolAddress;
        int24 currentTick;
        uint160 sqrtPriceX96;
        uint160 exactSqrtPriceImpact;
        uint160 sqrtPriceLimitX96;
        uint128 baseLiquidity;
        uint256 amount0;
        uint256 amount1;
        uint256 amountIn;
        uint256 amount0Added;
        uint256 amount1Added;
        uint256 amount0Range;
        uint256 amount1Range;
        uint256 currentTimestamp;
        uint256 gasUsed;
        uint256 pilotAmount;
    }

    struct VarsEmerency {
        address token;
        address pool;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
    }

    struct WithdrawVars {
        address recipient;
        uint256 amount0Removed;
        uint256 amount1Removed;
        uint256 userAmount0;
        uint256 userAmount1;
        uint256 pilotAmount;
    }

    struct WithdrawTokenOwedParams {
        address token0;
        address token1;
        uint256 tokensOwed0;
        uint256 tokensOwed1;
    }

    struct MintCallbackData {
        address payer;
        address token0;
        address token1;
        uint24 fee;
    }

    struct UnipilotProtocolDetails {
        uint8 swapPercentage;
        uint24 swapPriceThreshold;
        uint256 premium;
        uint256 gasPriceLimit;
        uint256 userPilotPercentage;
        uint256 feesPercentageIndexFund;
        uint24 readjustFrequencyTime;
        uint16 poolCardinalityDesired;
        address pilotWethPair;
        address oracle;
        address indexFund;  
        address uniStrategy;
        address unipilot;
    }

    struct SwapCallbackData {
        address token0;
        address token1;
        uint24 fee;
    }

    struct AddLiquidityParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
    }

    struct RemoveLiquidity {
        uint256 amount0;
        uint256 amount1;
        uint128 liquidityRemoved;
        uint256 feesCollected0;
        uint256 feesCollected1;
    }

    struct Tick {
        int24 baseTickLower;
        int24 baseTickUpper;
        int24 bidTickLower;
        int24 bidTickUpper;
        int24 rangeTickLower;
        int24 rangeTickUpper;
    }

    struct TokenDetails {
        address token0;
        address token1;
        uint24 fee;
        int24 currentTick;
        uint16 poolCardinality;
        uint128 baseLiquidity;
        uint128 bidLiquidity;
        uint128 rangeLiquidity;
        uint256 amount0Added;
        uint256 amount1Added;
    }

    struct DistributeFeesParams {
        bool pilotToken;
        bool wethToken;
        address pool;
        address recipient;
        uint256 tokenId;
        uint256 liquidity;
        uint256 amount0Removed;
        uint256 amount1Removed;
    }

    struct AddLiquidityManagerParams {
        address pool;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 shares;
    }

    struct DepositVars {
        uint24 fee;
        address pool;
        uint256 amount0Base;
        uint256 amount1Base;
        uint256 amount0Range;
        uint256 amount1Range;
    }

    struct RangeLiquidityVars {
        address token0;
        address token1;
        uint24 fee;
        uint128 rangeLiquidity;
        uint256 amount0Range;
        uint256 amount1Range;
    }

    struct IncreaseParams {
        address token0;
        address token1;
        uint24 fee;
        int24 currentTick;
        uint128 baseLiquidity;
        uint256 baseAmount0;
        uint256 baseAmount1;
        uint128 rangeLiquidity;
        uint256 rangeAmount0;
        uint256 rangeAmount1;
    }

    
    
    
    
    
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external;

    
    
    
    
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

    
    
    
     
     
     
     
     
     
     
    function userPositions(uint256 tokenId) external view returns (Position memory);

    
    
    
     
     
     
     
     
     
     
     
     
     
     
     
     
    function poolPositions(address pool) external view returns (LiquidityPosition memory);

    
     
     
    
    
    
    
    function updatePositionTotalAmounts(address _pool)
        external
        view
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 totalLiquidity
        );

    
     
     
    
    
    
    
    
    
    
    function getReserves(
        address token0,
        address token1,
        bytes calldata data
    )
        external
        returns (
            uint256 totalAmount0,
            uint256 totalAmount1,
            uint256 totalLiquidity
        );

    
    
    
    
     
     
    
    function createPair(
        address _token0,
        address _token1,
        bytes memory data
    ) external returns (address _pool);

    
     
    
    
    
    
    
    
    
    
    function deposit(
        address token0,
        address token1,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 shares,
        uint256 tokenId,
        bool isTokenMinted,
        bytes memory data
    ) external payable;

    
    
    
    
    
    
    function withdraw(
        bool pilotToken,
        bool wethToken,
        uint256 liquidity,
        uint256 tokenId,
        bytes memory data
    ) external payable;

    
    
    
    
    
    
    function collect(
        bool pilotToken,
        bool wethToken,
        uint256 tokenId,
        bytes memory data
    ) external payable;
}

 
pragma solidity >=0.7.6;




interface IUnipilot {
    struct DepositVars {
        uint256 totalAmount0;
        uint256 totalAmount1;
        uint256 totalLiquidity;
        uint256 shares;
        uint256 amount0;
        uint256 amount1;
    }

    function governance() external view returns (address);

    function mintPilot(address recipient, uint256 amount) external;

    function mintUnipilotNFT(address sender) external returns (uint256 mintedTokenId);

    function deposit(IHandler.DepositParams memory params, bytes memory data)
        external
        payable
        returns (
            uint256 amount0Base,
            uint256 amount1Base,
            uint256 amount0Range,
            uint256 amount1Range,
            uint256 mintedTokenId
        );

    function createPoolAndDeposit(
        IHandler.DepositParams memory params,
        bytes[2] calldata data
    )
        external
        payable
        returns (
            uint256 amount0Base,
            uint256 amount1Base,
            uint256 amount0Range,
            uint256 amount1Range,
            uint256 mintedTokenId
        );
}

 
pragma solidity >=0.7.6;


interface IUnipilotFarmV1 {
    struct PoolInfo {
        uint256 startBlock;
        uint256 globalReward;
        uint256 lastRewardBlock;
        uint256 totalLockedLiquidity;
        uint256 rewardMultiplier;
        bool isRewardActive;
        bool isAltActive;
    }
    function poolInfo(address pool) external view returns (PoolInfo memory);
}

 
pragma solidity >=0.7.6;

interface IUnipilotStake {
    function getBoostMultiplier(
        address userAddress,
        address poolAddress,
        uint256 tokenId
    ) external view returns (uint256);

    function userMultiplier(address userAddress, address poolAddress)
        external
        view
        returns (uint256);
}

 
pragma solidity >=0.4.0;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
         
         
         
         
         
        uint256 prod0;  
        uint256 prod1;  
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

         
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

         
         
        require(denominator > prod1);

         
         
         

         
         
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
         
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

         
         
         
        uint256 twos = -denominator & denominator;
         
        assembly {
            denominator := div(denominator, twos)
        }

         
        assembly {
            prod0 := div(prod0, twos)
        }
         
         
         
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

         
         
         
         
         
        uint256 inv = (3 * denominator) ^ 2;
         
         
         
        inv *= 2 - denominator * inv;  
        inv *= 2 - denominator * inv;  
        inv *= 2 - denominator * inv;  
        inv *= 2 - denominator * inv;  
        inv *= 2 - denominator * inv;  
        inv *= 2 - denominator * inv;  

         
         
         
         
         
         
        result = prod0 * inv;
        return result;
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

 

pragma solidity ^0.7.0;

 
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

 

pragma solidity ^0.7.0;



 
interface IERC721 is IERC165 {
     
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

     
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

     
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

     
    function balanceOf(address owner) external view returns (uint256 balance);

     
    function ownerOf(uint256 tokenId) external view returns (address owner);

     
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

     
    function transferFrom(address from, address to, uint256 tokenId) external;

     
    function approve(address to, uint256 tokenId) external;

     
    function getApproved(uint256 tokenId) external view returns (address operator);

     
    function setApprovalForAll(address operator, bool _approved) external;

     
    function isApprovedForAll(address owner, address operator) external view returns (bool);

     
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

 

pragma solidity ^0.7.0;

 
interface IERC20 {
     
    function totalSupply() external view returns (uint256);

     
    function balanceOf(address account) external view returns (uint256);

     
    function transfer(address recipient, uint256 amount) external returns (bool);

     
    function allowance(address owner, address spender) external view returns (uint256);

     
    function approve(address spender, uint256 amount) external returns (bool);

     
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

     
    event Transfer(address indexed from, address indexed to, uint256 value);

     
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 

pragma solidity ^0.7.0;





 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
         
         
         

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

 
pragma solidity >=0.7.6;




interface IHandler {
    struct DepositParams {
        address sender;
        address exchangeAddress;
        address token0;
        address token1;
        uint256 amount0Desired;
        uint256 amount1Desired;
    }

    struct WithdrawParams {
        bool pilotToken;
        bool wethToken;
        address exchangeAddress;
        uint256 liquidity;
        uint256 tokenId;
    }

    struct CollectParams {
        bool pilotToken;
        bool wethToken;
        address exchangeAddress;
        uint256 tokenId;
    }

    function createPair(
        address _token0,
        address _token1,
        bytes calldata data
    ) external;

    function deposit(
        address token0,
        address token1,
        address sender,
        uint256 amount0,
        uint256 amount1,
        uint256 shares,
        bytes calldata data
    )
        external
        returns (
            uint256 amount0Base,
            uint256 amount1Base,
            uint256 amount0Range,
            uint256 amount1Range,
            uint256 mintedTokenId
        );

    function withdraw(
        bool pilotToken,
        bool wethToken,
        uint256 liquidity,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function getReserves(
        address token0,
        address token1,
        bytes calldata data
    )
        external
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        );

    function collect(
        bool pilotToken,
        bool wethToken,
        uint256 tokenId,
        bytes calldata data
    ) external payable;
}

 

pragma solidity ^0.7.0;

 
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