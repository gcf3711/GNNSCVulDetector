 
pragma experimental ABIEncoderV2;


 

pragma solidity ^0.7.6;








 
contract Life {

    using SafeMath for uint256;
    using SafeMath for uint32;

    AppStorage internal s;

     

     

    function bean() public view returns (IBean) {
        return IBean(s.c.bean);
    }

    function pair() public view returns (IUniswapV2Pair) {
        return IUniswapV2Pair(s.c.pair);
    }

    function pegPair() public view returns (IUniswapV2Pair) {
        return IUniswapV2Pair(s.c.pegPair);
    }

     

     function time() external view returns (Storage.Season memory) {
         return s.season;
     }

    function season() public view returns (uint32) {
        return s.season.current;
    }

    function seasonTime() public virtual view returns (uint32) {
        if (block.timestamp < s.season.start) return 0;
        if (s.season.period == 0) return uint32(-1);
        return uint32((block.timestamp.sub(s.season.start).div(s.season.period)));
    }

    function incentiveTime() internal view returns (uint256) {
        uint256 timestamp = block.timestamp.sub(
            s.season.start.add(s.season.period.mul(season()))
        );
        if (timestamp > 300) timestamp = 300;
        return timestamp;
    }

     

    function increaseSupply(uint256 newSupply) internal returns (uint256, uint256) {
        (uint256 newHarvestable, uint256 siloReward) = (0, 0);

        if (s.f.harvestable < s.f.pods) {
            uint256 notHarvestable = s.f.pods.sub(s.f.harvestable);
            newHarvestable = newSupply.mul(C.getHarvestPercentage()).div(1e18);
            newHarvestable = newHarvestable > notHarvestable ? notHarvestable : newHarvestable;
            mintToHarvestable(newHarvestable);
        }

        if (s.s.seeds == 0 && s.s.stalk == 0) return (newHarvestable,0);
        siloReward = newSupply.sub(newHarvestable);
        if (siloReward > 0) {
            mintToSilo(siloReward);
        }
        return (newHarvestable, siloReward);
    }

    function mintToSilo(uint256 amount) internal {
        if (amount > 0) {
            bean().mint(address(this), amount);
        }
    }

    function mintToHarvestable(uint256 amount) internal {
        bean().mint(address(this), amount);
        s.f.harvestable = s.f.harvestable.add(amount);
    }

    function mintToAccount(address account, uint256 amount) internal {
        bean().mint(account, amount);
    }

     

    function increaseSoil(uint256 amount) internal returns (int256) {
        uint256 maxTotalSoil = C.getMaxSoilRatioCap().mul(bean().totalSupply()).div(1e18);
        uint256 minTotalSoil = C.getMinSoilRatioCap().mul(bean().totalSupply()).div(1e18);
        if (s.f.soil > maxTotalSoil) {
            amount = s.f.soil.sub(maxTotalSoil);
            decrementTotalSoil(amount);
            return -int256(amount);
        }
        uint256 newTotalSoil = s.f.soil + amount;
        amount = newTotalSoil <= maxTotalSoil ? amount : maxTotalSoil.sub(s.f.soil);
        amount = newTotalSoil >= minTotalSoil ? amount : minTotalSoil.sub(s.f.soil);

        incrementTotalSoil(amount);
        return int256(amount);
    }

    function decreaseSoil(uint256 amount) internal {
        decrementTotalSoil(amount);
    }

    function ensureSoilBounds() internal returns (int256) {
        uint256 minTotalSoil = C.getMinSoilRatioCap().mul(bean().totalSupply()).div(1e18);
        if (s.f.soil < minTotalSoil) {
            uint256 amount = minTotalSoil.sub(s.f.soil);
            incrementTotalSoil(amount);
            return int256(amount);
        }
        uint256 maxTotalSoil = C.getMaxSoilRatioCap().mul(bean().totalSupply()).div(1e18);
        if (s.f.soil > maxTotalSoil) {
            uint256 amount = s.f.soil.sub(maxTotalSoil);
            decrementTotalSoil(amount);
            return -int256(amount);
        }
        return 0;
    }

    function incrementTotalSoil(uint256 amount) internal {
        s.f.soil = s.f.soil.add(amount);
    }

    function decrementTotalSoil(uint256 amount) internal {
        s.f.soil = s.f.soil.sub(amount, "Season: Not enough Soil.");
    }

}

 

pragma solidity ^0.7.6;





 
contract Silo is Life {

    using SafeMath for uint256;
    using SafeMath for uint32;
    using Decimal for Decimal.D256;

    uint256 private constant BASE = 1e12;
    uint256 private constant BURN_BASE = 1e20;
    uint256 private constant BIG_BASE = 1e24;

     

    function seasonOfPlenty(uint32 _s) external view returns (uint256) {
        return s.sops[_s];
    }

    function paused() public view returns (bool) {
        return s.paused;
    }

     

     

    function stepSilo(uint256 amount) internal {
        rewardStalk();
        rewardBeans(amount);
    }

    function rewardStalk() private {
        if (s.si.beans == 0) return;
        uint256 newStalk = s.si.beans.mul(C.getSeedsPerBean());
        s.s.stalk = s.s.stalk.add(newStalk);
        s.si.stalk = s.si.stalk.add(newStalk);
    }

    function rewardBeans(uint256 amount) private {
        if (s.s.stalk == 0 || amount == 0) return;
        s.s.stalk = s.s.stalk.add(amount.mul(C.getStalkPerBean()));
        s.si.beans = s.si.beans.add(amount);
        s.bean.deposited = s.bean.deposited.add(amount);
        s.s.seeds = s.s.seeds.add(amount.mul(C.getSeedsPerBean()));
    }

     

    function rewardEther(uint256 amount) internal {
        uint256 base;
        if (s.sop.base == 0) {
            base = amount.mul(BIG_BASE);
            s.sop.base = BURN_BASE;
        }
        else base = amount.mul(s.sop.base).div(s.sop.weth);

         
        uint256 basePerStalk = base.div(s.r.roots);
        base = basePerStalk.mul(s.r.roots);
        s.sops[s.r.start] = s.sops[s.r.start].add(basePerStalk);

         
        s.sop.weth = s.sop.weth.add(amount);
        s.sop.base = s.sop.base.add(base);
        if (base > 0) s.sop.last = s.r.start;

    }

     

    function stepGovernance() internal {
        for (uint256 i; i < s.g.activeBips.length; i++) {
            uint32 bip = s.g.activeBips[i];
            if (season() >= s.g.bips[bip].start.add(s.g.bips[bip].period)) {
                endBip(bip, i);
                i--;
            }
        }
    }

    function endBip(uint32 bipId, uint256 i) private {
        s.g.bips[bipId].timestamp = uint128(block.timestamp);
        s.g.bips[bipId].endTotalRoots = s.s.roots;
        if (i < s.g.activeBips.length-1)
            s.g.activeBips[i] = s.g.activeBips[s.g.activeBips.length-1];
        s.g.activeBips.pop();
    }

}

 

pragma solidity ^0.7.6;






 
contract Weather is Silo {

    using SafeMath for uint256;
    using SafeMath for uint32;
    using Decimal for Decimal.D256;

    event WeatherChange(uint256 indexed season, uint256 caseId, int8 change);
    event SeasonOfPlenty(uint256 indexed season, uint256 eth, uint256 harvestable);

    uint32 private constant MAX_UINT32 = 2**32-1;

     

     

    function weather() public view returns (Storage.Weather memory) {
        return s.w;
    }

    function rain() public view returns (Storage.Rain memory) {
        return s.r;
    }

    function yield() public view returns (uint32) {
        return s.w.yield;
    }

     

     
    function reserves() public view returns (uint256, uint256) {
        (uint112 reserve0, uint112 reserve1,) = pair().getReserves();
        return (s.index == 0 ? reserve1 : reserve0, s.index == 0 ? reserve0 : reserve1);
    }

     
    function pegReserves() public view returns (uint256, uint256) {
        (uint112 reserve0, uint112 reserve1,) = pegPair().getReserves();
        return (reserve1, reserve0);
    }

     

    function stepWeather(uint256 int_price, uint256 endSoil) internal {

        if (bean().totalSupply() == 0) {
            s.w.yield = 1;
            return;
        }

        Decimal.D256 memory podRate = Decimal.ratio(
            s.f.pods.sub(s.f.harvestable),
            bean().totalSupply()
        );

        uint256 dsoil = s.w.startSoil.sub(endSoil);

        Decimal.D256 memory deltaPodDemand;
        uint256 lastDSoil = s.w.lastDSoil;
        if (dsoil == 0) deltaPodDemand = Decimal.zero();
        else if (lastDSoil == 0) deltaPodDemand = Decimal.from(1e18);
        else deltaPodDemand = Decimal.ratio(dsoil, lastDSoil);

        uint8 caseId = 0;
        if (podRate.greaterThanOrEqualTo(C.getUpperBoundPodRate())) caseId = 24;
        else if (podRate.greaterThanOrEqualTo(C.getOptimalPodRate())) caseId = 16;
        else if (podRate.greaterThanOrEqualTo(C.getLowerBoundPodRate())) caseId = 8;

        if (
            int_price > 1e18 || (int_price == 1e18 &&
            podRate.lessThanOrEqualTo(C.getOptimalPodRate()))
        ) {
            caseId += 4;
        }

        if (deltaPodDemand.greaterThanOrEqualTo(C.getUpperBoundDPD())) {
            caseId += 2;
        } else if (deltaPodDemand.greaterThanOrEqualTo(C.getLowerBoundDPD())) {
            if (s.w.lastSowTime == MAX_UINT32 || !s.w.didSowBelowMin) {
                caseId += 1;
            }
            else if (s.w.didSowFaster) {
                caseId += 2;
                s.w.didSowFaster = false;
            }
        }
        s.w.lastDSoil = dsoil;
        handleExtremeWeather(endSoil);
        changeWeather(caseId);
        handleRain(caseId);
    }

    function handleExtremeWeather(uint256 endSoil) private {
        if (s.w.didSowBelowMin) {
            s.w.didSowBelowMin = false;
            s.w.lastSoilPercent = uint96(endSoil.mul(1e18).div(bean().totalSupply()));
            s.w.lastSowTime = s.w.nextSowTime;
            s.w.nextSowTime = MAX_UINT32;
        }
        else if (s.w.lastSowTime != MAX_UINT32) {
            s.w.lastSowTime = MAX_UINT32;
        }
    }

    function changeWeather(uint256 caseId) private {
        int8 change = s.cases[caseId];
        if (change < 0) {
                if (yield() <= (uint32(-change))) {
                    change = 1 - int8(yield());
                    s.w.yield = 1;
                }
                else s.w.yield = yield()-(uint32(-change));
        }
        else s.w.yield = yield()+(uint32(change));

        emit WeatherChange(season(), caseId, change);
    }

    function handleRain(uint256 caseId) internal {
        if (caseId < 4 || caseId > 7) {
            if (s.r.raining) s.r.raining = false;
            return;
        }
        else if (!s.r.raining) {
            s.r.raining = true;
            s.sops[season()] = s.sops[s.r.start];
            s.r.start = season();
            s.r.pods = s.f.pods;
            s.r.roots = s.s.roots;
        }
        else if (season() >= s.r.start.add(C.getRainTime())) {
            if (s.r.roots > 0) sop();
        }
    }

    function sop() private {
        (uint256 newBeans, uint256 newEth) = calculateSopBeansAndEth();
        if (
            newEth <= s.s.roots.div(1e20) ||
            (s.sop.base > 0 && newBeans.mul(s.sop.base).div(s.sop.weth).div(s.r.roots) == 0)
        )
            return;

        mintToSilo(newBeans);
        uint256 ethBought = LibMarket.sellToWETH(newBeans, 0);
        uint256 newHarvestable = 0;
        if (s.f.harvestable < s.r.pods) {
            newHarvestable = s.r.pods.sub(s.f.harvestable);
            mintToHarvestable(newHarvestable);
        }
        if (ethBought == 0) return;
        rewardEther(ethBought);
        emit SeasonOfPlenty(season(), ethBought, newHarvestable);
    }

    function calculateSopBeansAndEth() private view returns (uint256, uint256) {
        (uint256 ethBeanPool, uint256 beansBeanPool) = reserves();
        (uint256 ethUSDCPool, uint256 usdcUSDCPool) = pegReserves();

        uint256 newBeans = sqrt(ethBeanPool.mul(beansBeanPool).mul(usdcUSDCPool).div(ethUSDCPool));
        if (newBeans <= beansBeanPool) return (0,0);
        uint256 beans = newBeans.sub(beansBeanPool);
        beans = beans.mul(10000).div(9985).add(1);

        uint256 beansWithFee = beans.mul(997);
        uint256 numerator = beansWithFee.mul(ethBeanPool);
        uint256 denominator = beansBeanPool.mul(1000).add(beansWithFee);
        uint256 eth = numerator / denominator;

        return (beans, eth);
    }

     

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

}

 

pragma solidity ^0.7.6;




 
contract Sun is Weather {

    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    event SupplyIncrease(
        uint256 indexed season,
        uint256 price,
        uint256 newHarvestable,
        uint256 newSilo,
        int256 newSoil
    );
    event SupplyDecrease(uint256 indexed season, uint256 price, int256 newSoil);
    event SupplyNeutral(uint256 indexed season, int256 newSoil);

     

     

    function stepSun(Decimal.D256 memory beanPrice, Decimal.D256 memory usdcPrice)
        internal
        returns
        (uint256)
    {
        (uint256 eth_reserve, uint256 bean_reserve) = reserves();

        uint256 currentBeans = sqrt(
            bean_reserve.mul(eth_reserve).mul(1e6).div(beanPrice.mul(1e18).asUint256())
        );
        uint256 targetBeans = sqrt(
            bean_reserve.mul(eth_reserve).mul(1e6).div(usdcPrice.mul(1e18).asUint256())
        );

        uint256 price = beanPrice.mul(1e18).div(usdcPrice).asUint256();
        uint256 newSilo;

        if (currentBeans < targetBeans) {
            newSilo = growSupply(targetBeans.sub(currentBeans), price);
        } else if (currentBeans > targetBeans) {
            shrinkSupply(currentBeans.sub(targetBeans), price);
        } else {
            int256 newSoil = ensureSoilBounds();
            emit SupplyNeutral(season(), newSoil);
        }
        s.w.startSoil = s.f.soil;
        return newSilo;
    }

    function shrinkSupply(uint256 beans, uint256 price) private {
        int256 newSoil = increaseSoil(beans);
        emit SupplyDecrease(season(), price, newSoil);
    }

    function growSupply(uint256 beans, uint256 price) private returns (uint256) {
        (uint256 newHarvestable, uint256 newSilo) = increaseSupply(beans);
        int256 newSoil = ensureSoilBounds();
        emit SupplyIncrease(season(), price, newHarvestable, newSilo, newSoil);
        return newSilo;
    }

}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

 

pragma solidity >=0.6.0 <0.8.0;

 
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
 

pragma solidity ^0.7.6;







 
contract SeasonFacet is Sun {

    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    event Sunrise(uint256 indexed season);
    event Incentivization(address indexed account, uint256 beans);
    event SeasonSnapshot(
        uint32 indexed season,
        uint256 price,
        uint256 supply,
        uint256 stalk,
        uint256 seeds,
        uint256 podIndex,
        uint256 harvestableIndex
    );

     

    function sunrise() external {
        require(!paused(), "Season: Paused.");
        require(seasonTime() > season(), "Season: Still current Season.");

        (
            Decimal.D256 memory beanPrice,
            Decimal.D256 memory usdcPrice
        ) = IOracle(address(this)).capture();
        uint256 price = beanPrice.mul(1e18).div(usdcPrice).asUint256();

        stepGovernance();
        stepSeason();
        snapshotSeason(price);
        stepWeather(price, s.f.soil);
        uint256 increase = stepSun(beanPrice, usdcPrice);
        stepSilo(increase);
        incentivize(msg.sender, C.getAdvanceIncentive());

        LibCheck.balanceCheck();

        emit Sunrise(season());
    }

    function stepSeason() private {
        s.season.current += 1;
    }

    function snapshotSeason(uint256 price) private {
        s.season.timestamp = block.timestamp;
        emit SeasonSnapshot(
            s.season.current,
            price,
            bean().totalSupply(),
            s.s.stalk,
            s.s.seeds,
            s.f.pods,
            s.f.harvestable
        );
    }

    function incentivize(address account, uint256 amount) private {
        uint256 incentive = LibIncentive.fracExp(amount, 100, incentiveTime(), 1);
        mintToAccount(account, incentive);
        emit Incentivization(account, incentive);
    }

}

 

pragma solidity ^0.7.6;




 
interface IOracle {

  function capture() external returns (Decimal.D256 memory, Decimal.D256 memory);

}

 

pragma solidity ^0.7.6;







 
library LibCheck {

    using SafeMath for uint256;

    function beanBalanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IBean(s.c.bean).balanceOf(address(this)) >=
                s.f.harvestable.sub(s.f.harvested).add(s.bean.deposited).add(s.bean.withdrawn),
            "Check: Bean balance fail."
        );
    }

    function lpBalanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IUniswapV2Pair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited.add(s.lp.withdrawn),
            "Check: LP balance fail."
        );
    }

    function balanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            IBean(s.c.bean).balanceOf(address(this)) >=
                s.f.harvestable.sub(s.f.harvested).add(s.bean.deposited).add(s.bean.withdrawn),
            "Check: Bean balance fail."
        );
        require(
            IUniswapV2Pair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited.add(s.lp.withdrawn),
            "Check: LP balance fail."
        );
    }

}

 

pragma solidity ^0.7.6;


 
library LibIncentive {

    function fracExp(uint k, uint q, uint n, uint x) internal pure returns (uint) {
        uint p = log_two(n) + 1 + x * n / q;
        uint s = 0;
        uint N = 1;
        uint B = 1;
        for (uint i = 0; i < p; ++i){
            s += k * N / B / (q**i);
            N = N * (n-i);
            B = B * (i+1);
        }
        return s;
    }

    function log_two(uint x) private pure returns (uint y) {
        assembly {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m, 0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }
    }

}

 

pragma solidity ^0.7.6;




 
library Decimal {
    using SafeMath for uint256;

     

    uint256 constant BASE = 10**18;

     


    struct D256 {
        uint256 value;
    }

     

    function zero()
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: 0 });
    }

    function one()
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: BASE });
    }

    function from(
        uint256 a
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: a.mul(BASE) });
    }

    function ratio(
        uint256 a,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: getPartial(a, BASE, b) });
    }

     

    function add(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.add(b.mul(BASE)) });
    }

    function sub(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.mul(BASE)) });
    }

    function sub(
        D256 memory self,
        uint256 b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.mul(BASE), reason) });
    }

    function mul(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.mul(b) });
    }

    function div(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.div(b) });
    }

    function pow(
        D256 memory self,
        uint256 b
    )
    internal
    pure
    returns (D256 memory)
    {
        if (b == 0) {
            return from(1);
        }

        D256 memory temp = D256({ value: self.value });
        for (uint256 i = 1; i < b; i++) {
            temp = mul(temp, self);
        }

        return temp;
    }

    function add(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.add(b.value) });
    }

    function sub(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.value) });
    }

    function sub(
        D256 memory self,
        D256 memory b,
        string memory reason
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: self.value.sub(b.value, reason) });
    }

    function mul(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: getPartial(self.value, b.value, BASE) });
    }

    function div(
        D256 memory self,
        D256 memory b
    )
    internal
    pure
    returns (D256 memory)
    {
        return D256({ value: getPartial(self.value, BASE, b.value) });
    }

    function equals(D256 memory self, D256 memory b) internal pure returns (bool) {
        return self.value == b.value;
    }

    function greaterThan(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) == 2;
    }

    function lessThan(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) == 0;
    }

    function greaterThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) > 0;
    }

    function lessThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) < 2;
    }

    function isZero(D256 memory self) internal pure returns (bool) {
        return self.value == 0;
    }

    function asUint256(D256 memory self) internal pure returns (uint256) {
        return self.value.div(BASE);
    }

     

    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
    private
    pure
    returns (uint256)
    {
        return target.mul(numerator).div(denominator);
    }

    function compareTo(
        D256 memory a,
        D256 memory b
    )
    private
    pure
    returns (uint256)
    {
        if (a.value == b.value) {
            return 1;
        }
        return a.value > b.value ? 2 : 0;
    }
}

 

pragma solidity ^0.7.6;







 
library LibMarket {

    struct DiamondStorage {
        address bean;
        address weth;
        address router;
    }

    struct AddLiquidity {
        uint256 beanAmount;
        uint256 minBeanAmount;
        uint256 minEthAmount;
    }

    using SafeMath for uint256;

    bytes32 private constant MARKET_STORAGE_POSITION = keccak256("diamond.standard.market.storage");

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = MARKET_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function initMarket(address bean, address weth, address router) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.bean = bean;
        ds.weth = weth;
        ds.router = router;
    }

     

    function buy(uint256 buyBeanAmount) internal returns (uint256 amount) {
        (uint256 ethAmount, uint256 beanAmount) = _buy(buyBeanAmount, msg.value, msg.sender);
        (bool success,) = msg.sender.call{ value: msg.value.sub(ethAmount) }("");
        require(success, "Market: Refund failed.");
        return beanAmount;
    }

    function buyAndDeposit(uint256 buyBeanAmount) internal returns (uint256 amount) {
        (uint256 ethAmount, uint256 beanAmount) = _buy(buyBeanAmount, msg.value, address(this));
        (bool success,) = msg.sender.call{ value: msg.value.sub(ethAmount) }("");
        require(success, "Market: Refund failed.");
        return beanAmount;
    }

    function sellToWETH(uint256 sellBeanAmount, uint256 minBuyEthAmount)
        internal
        returns (uint256 amount)
    {
        (,uint256 outAmount) = _sell(sellBeanAmount, minBuyEthAmount, address(this));
        return outAmount;
    }

     

    function addLiquidity(AddLiquidity calldata al) internal returns (uint256, uint256) {
        (uint256 beansDeposited, uint256 ethDeposited, uint256 liquidity) = _addLiquidity(
            msg.value,
            al.beanAmount,
            al.minEthAmount,
            al.minBeanAmount
        );
        (bool success,) = msg.sender.call{ value: msg.value.sub(ethDeposited) }("");
        require(success, "Market: Refund failed.");
        return (beansDeposited, liquidity);
    }

    function removeLiquidity(uint256 liqudity, uint256 minBeanAmount,uint256 minEthAmount)
        internal
        returns (uint256 beanAmount, uint256 ethAmount)
    {
        DiamondStorage storage ds = diamondStorage();
        return IUniswapV2Router02(ds.router).removeLiquidityETH(
            ds.bean,
            liqudity,
            minBeanAmount,
            minEthAmount,
            msg.sender,
            block.timestamp.add(1));
    }

    function addAndDepositLiquidity(AddLiquidity calldata al) internal returns (uint256) {
        DiamondStorage storage ds = diamondStorage();
        IBean(ds.bean).transferFrom(msg.sender, address(this), al.beanAmount);
        (uint256 beans, uint256 liquidity) = addLiquidity(al);
        if (al.beanAmount > beans) IBean(ds.bean).transfer(msg.sender, al.beanAmount.sub(beans));
        return liquidity;
    }

    function swapAndAddLiquidity(
        uint256 buyBeanAmount,
        uint256 buyEthAmount,
        LibMarket.AddLiquidity calldata al
    )
        internal
        returns (uint256)
    {
        uint256 boughtLP;
        if (buyBeanAmount > 0)
            boughtLP = LibMarket.buyBeansAndAddLiquidity(buyBeanAmount, al);
        else if (buyEthAmount > 0)
            boughtLP = LibMarket.buyEthAndAddLiquidity(buyEthAmount, al);
        else
            boughtLP = LibMarket.addAndDepositLiquidity(al);
        return boughtLP;
    }


    function buyBeansAndAddLiquidity(uint256 buyBeanAmount, AddLiquidity calldata al)
        internal
        returns (uint256)
    {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.weth;
        path[1] = ds.bean;
        uint256[] memory amounts = IUniswapV2Router02(ds.router).getAmountsIn(buyBeanAmount, path);
        (uint256 ethSold, uint256 beans) = _buy(buyBeanAmount, amounts[0], address(this));
        if (al.beanAmount > buyBeanAmount) {
            IBean(ds.bean).transferFrom(msg.sender, address(this), al.beanAmount.sub(buyBeanAmount));
            beans = beans.add(al.beanAmount.sub(buyBeanAmount));
        }
        uint256 liquidity; uint256 ethAdded;
        (beans, ethAdded, liquidity) = _addLiquidity(
            msg.value.sub(ethSold),
            beans,
            al.minEthAmount,
            al.minBeanAmount
        );
        if (al.beanAmount > beans) IBean(ds.bean).transfer(msg.sender, al.beanAmount.sub(beans));
        if (msg.value > ethAdded.add(ethSold)) {
            (bool success,) = msg.sender.call{ value: msg.value.sub(ethAdded).sub(ethSold) }("");
            require(success, "Market: Refund failed.");
        }
        return liquidity;
    }

    function buyEthAndAddLiquidity(uint256 buyWethAmount, AddLiquidity calldata al)
        internal
        returns (uint256)
    {
        DiamondStorage storage ds = diamondStorage();
        uint256 sellBeans = _amountIn(buyWethAmount);
        IBean(ds.bean).transferFrom(msg.sender, address(this), al.beanAmount.add(sellBeans));
        (uint256 beansSold, uint256 wethBought) = _sell(sellBeans, buyWethAmount, address(this));
        if (msg.value > 0) IWETH(ds.weth).deposit{value: msg.value}();
        (uint256 beans, uint256 ethAdded, uint256 liquidity) = _addLiquidityWETH(
            msg.value.add(wethBought),
            al.beanAmount,
            al.minEthAmount,
            al.minBeanAmount
        );

        if (al.beanAmount.add(sellBeans) > beans.add(beansSold))
            IBean(ds.bean).transfer(
                msg.sender,
                al.beanAmount.add(sellBeans).sub(beans.add(beansSold))
            );

        if (ethAdded < wethBought.add(msg.value)) {
            uint256 eth = wethBought.add(msg.value).sub(ethAdded);
            IWETH(ds.weth).withdraw(eth);
            (bool success, ) = msg.sender.call{value: eth}("");
            require(success, "Market: Ether transfer failed.");
        }
        return liquidity;
    }

     

    function _sell(uint256 sellBeanAmount, uint256 minBuyEthAmount, address to)
        private
        returns (uint256 inAmount, uint256 outAmount)
    {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.bean;
        path[1] = ds.weth;
        uint[] memory amounts = IUniswapV2Router02(ds.router).swapExactTokensForTokens(
            sellBeanAmount,
            minBuyEthAmount,
            path,
            to,
            block.timestamp.add(1)
        );
        return (amounts[0], amounts[1]);
    }

    function _buy(uint256 beanAmount, uint256 ethAmount, address to)
        private
        returns (uint256 inAmount, uint256 outAmount)
    {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.weth;
        path[1] = ds.bean;

        uint[] memory amounts = IUniswapV2Router02(ds.router).swapExactETHForTokens{value: ethAmount}(
            beanAmount,
            path,
            to,
            block.timestamp.add(1)
        );
        return (amounts[0], amounts[1]);
    }

    function _addLiquidity(uint256 ethAmount, uint256 beanAmount, uint256 minEthAmount, uint256 minBeanAmount)
        private
        returns (uint256, uint256, uint256)
    {
        DiamondStorage storage ds = diamondStorage();
        return IUniswapV2Router02(ds.router).addLiquidityETH{value: ethAmount}(
            ds.bean,
            beanAmount,
            minBeanAmount,
            minEthAmount,
            address(this),
            block.timestamp.add(1));
    }

    function _addLiquidityWETH(uint256 wethAmount, uint256 beanAmount, uint256 minWethAmount, uint256 minBeanAmount)
        private
        returns (uint256, uint256, uint256)
    {
        DiamondStorage storage ds = diamondStorage();
        return IUniswapV2Router02(ds.router).addLiquidity(
            ds.bean,
            ds.weth,
            beanAmount,
            wethAmount,
            minBeanAmount,
            minWethAmount,
            address(this),
            block.timestamp.add(1));
    }

    function _amountIn(uint256 buyWethAmount) private view returns (uint256) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.bean;
        path[1] = ds.weth;
        uint256[] memory amounts = IUniswapV2Router02(ds.router).getAmountsIn(buyWethAmount, path);
        return amounts[0];
    }

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

pragma solidity >=0.6.2;



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

 

pragma solidity ^0.7.6;




 
abstract contract IBean is IERC20 {

    function burn(uint256 amount) public virtual;
    function burnFrom(address account, uint256 amount) public virtual;
    function mint(address account, uint256 amount) public virtual returns (bool);

}

 

pragma solidity ^0.7.6;



 
interface IWETH is IERC20 {

    function deposit() external payable;
    function withdraw(uint) external;

}

 

pragma solidity ^0.7.6;


 
library LibInternal {

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition;  
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition;  
    }

    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    struct Claim {
        uint32[] beanWithdrawals;
        uint32[] lpWithdrawals;
        uint256[] plots;
        bool claimEth;
        bool convertLP;
        uint256 minBeanAmount;
        uint256 minEthAmount;
    }

    function updateSilo(address account) internal {
        DiamondStorage storage ds = diamondStorage();
        bytes4 functionSelector = bytes4(keccak256("updateSilo(address)"));
        address facet = ds.selectorToFacetAndPosition[functionSelector].facetAddress;
        bytes memory myFunctionCall = abi.encodeWithSelector(functionSelector, account);
        (bool success,) = address(facet).delegatecall(myFunctionCall);
        require(success, "Silo: updateSilo failed.");
    }

    function updateBip(uint32 bip) internal {
        DiamondStorage storage ds = diamondStorage();
        bytes4 functionSelector = bytes4(keccak256("updateBip(uint32)"));
        address facet = ds.selectorToFacetAndPosition[functionSelector].facetAddress;
        bytes memory myFunctionCall = abi.encodeWithSelector(functionSelector, bip);
        (bool success,) = address(facet).delegatecall(myFunctionCall);
        require(success, "Silo: updateBip failed.");
    }

    function stalkFor(uint32 bip) internal returns (uint256) {
        DiamondStorage storage ds = diamondStorage();
        bytes4 functionSelector = bytes4(keccak256("stalkFor(uint32)"));
        address facet = ds.selectorToFacetAndPosition[functionSelector].facetAddress;
        bytes memory myFunctionCall = abi.encodeWithSelector(functionSelector, bip);
        (bool success, bytes memory data) = address(facet).delegatecall(myFunctionCall);
        require(success, "Governance: stalkFor failed.");
        uint stalk;
        assembly { stalk := mload(add(data, add(0x20, 0))) }
        return stalk;
    }

    function claim(Claim calldata c) internal {
        DiamondStorage storage ds = diamondStorage();
        bytes4 functionSelector = bytes4(keccak256("claim((uint32[],uint32[],uint256[],bool,bool,uint256,uint256))"));
        address facet = ds.selectorToFacetAndPosition[functionSelector].facetAddress;
        bytes memory myFunctionCall = abi.encodeWithSelector(functionSelector, c);
        (bool success,) = address(facet).delegatecall(myFunctionCall);
        require(success, "Claim: claim failed.");
    }

}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

 

pragma solidity ^0.7.6;




 
contract Account {

    struct Field {
        mapping(uint256 => uint256) plots;
        mapping(address => uint256) podAllowances;
    }

    struct AssetSilo {
        mapping(uint32 => uint256) withdrawals;
        mapping(uint32 => uint256) deposits;
        mapping(uint32 => uint256) depositSeeds;
    }

    struct Silo {
        uint256 stalk;
        uint256 seeds;
    }

    struct SeasonOfPlenty {
        uint256 base;
        uint256 roots;
        uint256 basePerRoot;
    }

    struct State {
        Field field;
        AssetSilo bean;
        AssetSilo lp;
        Silo s;
        uint32 lockedUntil;
        uint32 lastUpdate;
        uint32 lastSop;
        uint32 lastRain;
        SeasonOfPlenty sop;
        uint256 roots;
    }
}

contract Storage {
    struct Contracts {
        address bean;
        address pair;
        address pegPair;
        address weth;
    }

     

    struct Field {
        uint256 soil;
        uint256 pods;
        uint256 harvested;
        uint256 harvestable;
    }

     

    struct Bip {
        address proposer;
        uint32 start;
        uint32 period;
        bool executed;
        int pauseOrUnpause;
        uint128 timestamp;
        uint256 roots;
        uint256 endTotalRoots;
    }

    struct DiamondCut {
        IDiamondCut.FacetCut[] diamondCut;
        address initAddress;
        bytes initData;
    }

    struct Governance {
        uint32[] activeBips;
        uint32 bipIndex;
        mapping(uint32 => DiamondCut) diamondCuts;
        mapping(uint32 => mapping(address => bool)) voted;
        mapping(uint32 => Bip) bips;
    }

     

    struct AssetSilo {
        uint256 deposited;
        uint256 withdrawn;
    }

    struct IncreaseSilo {
        uint256 beans;
        uint256 stalk;
    }

    struct SeasonOfPlenty {
        uint256 weth;
        uint256 base;
        uint32 last;
    }

    struct Silo {
        uint256 stalk;
        uint256 seeds;
        uint256 roots;
    }

     

    struct Oracle {
        bool initialized;
        uint256 cumulative;
        uint256 pegCumulative;
        uint32 timestamp;
        uint32 pegTimestamp;
    }

    struct Rain {
        uint32 start;
        bool raining;
        uint256 pods;
        uint256 roots;
    }

    struct Season {
        uint32 current;
        uint256 start;
        uint256 period;
        uint256 timestamp;
    }

    struct Weather {
        uint256 startSoil;
        uint256 lastDSoil;
        uint96 lastSoilPercent;
        uint32 lastSowTime;
        uint32 nextSowTime;
        uint32 yield;
        bool didSowBelowMin;
        bool didSowFaster;
    }
}

struct AppStorage {
    uint8 index;
    int8[32] cases;
    bool paused;
    uint128 pausedAt;
    Storage.Season season;
    Storage.Contracts c;
    Storage.Field f;
    Storage.Governance g;
    Storage.Oracle o;
    Storage.Rain r;
    Storage.Silo s;
    uint256 depreciated1;
    Storage.Weather w;
    Storage.AssetSilo bean;
    Storage.AssetSilo lp;
    Storage.IncreaseSilo si;
    Storage.SeasonOfPlenty sop;
    uint256 depreciated2;
    uint256 depreciated3;
    uint256 depreciated4;
    uint256 depreciated5;
    uint256 depreciated6;
    mapping (uint32 => uint256) sops;
    mapping (address => Account.State) a;
    uint32 bip0Start;
}

 

pragma solidity ^0.7.6;




 
library C {

    using Decimal for Decimal.D256;
    using SafeMath for uint256;

     
    uint256 private constant CHAIN_ID = 1;  

     
    uint256 private constant CURRENT_SEASON_PERIOD = 3600;  

     
    uint256 private constant HARVESET_PERCENTAGE = 5e17;  

     
    uint256 private constant POD_RATE_LOWER_BOUND = 5e16;  
    uint256 private constant OPTIMAL_POD_RATE = 15e16;  
    uint256 private constant POD_RATE_UPPER_BOUND = 25e16;  

    uint256 private constant DELTA_POD_DEMAND_LOWER_BOUND = 95e16;  
    uint256 private constant DELTA_POD_DEMAND_UPPER_BOUND = 105e16;  

    uint256 private constant STEADY_SOW_TIME = 60;  
    uint256 private constant RAIN_TIME = 24;  

     
    uint32 private constant GOVERNANCE_PERIOD = 168;  
    uint32 private constant GOVERNANCE_EMERGENCY_PERIOD = 86400;  
    uint256 private constant GOVERNANCE_PASS_THRESHOLD = 5e17;  
    uint256 private constant GOVERNANCE_EMERGENCY_THRESHOLD_NUMERATOR = 2;  
    uint256 private constant GOVERNANCE_EMERGENCY_THRESHOLD_DEMONINATOR = 3;  
    uint32 private constant GOVERNANCE_EXPIRATION = 24;  
    uint256 private constant GOVERNANCE_PROPOSAL_THRESHOLD = 1e15;  
    uint256 private constant BASE_COMMIT_INCENTIVE = 1e8;  
    uint256 private constant MAX_PROPOSITIONS = 5;

     
    uint256 private constant BASE_ADVANCE_INCENTIVE = 1e8;  
    uint32 private constant WITHDRAW_TIME = 25;  
    uint256 private constant SEEDS_PER_BEAN = 2;
    uint256 private constant SEEDS_PER_LP_BEAN = 4;
    uint256 private constant STALK_PER_BEAN = 10000;
    uint256 private constant ROOTS_BASE = 1e12;

     
    uint256 private constant SOIL_MAX_RATIO_CAP = 25e16;  
    uint256 private constant SOIL_MIN_RATIO_CAP = 1e15;  


     

    function getSeasonPeriod() internal pure returns (uint256) {
        return CURRENT_SEASON_PERIOD;
    }

    function getGovernancePeriod() internal pure returns (uint32) {
        return GOVERNANCE_PERIOD;
    }

    function getGovernanceEmergencyPeriod() internal pure returns (uint32) {
        return GOVERNANCE_EMERGENCY_PERIOD;
    }

    function getGovernanceExpiration() internal pure returns (uint256) {
        return GOVERNANCE_EXPIRATION;
    }

    function getGovernancePassThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: GOVERNANCE_PASS_THRESHOLD});
    }

    function getGovernanceEmergencyThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(GOVERNANCE_EMERGENCY_THRESHOLD_NUMERATOR,GOVERNANCE_EMERGENCY_THRESHOLD_DEMONINATOR);
    }

    function getGovernanceProposalThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: GOVERNANCE_PROPOSAL_THRESHOLD});
    }

    function getAdvanceIncentive() internal pure returns (uint256) {
        return BASE_ADVANCE_INCENTIVE;
    }

    function getCommitIncentive() internal pure returns (uint256) {
        return BASE_COMMIT_INCENTIVE;
    }

    function getSiloWithdrawSeasons() internal pure returns (uint32) {
        return WITHDRAW_TIME;
    }

    function getMinSoilRatioCap() internal pure returns (uint256) {
        return SOIL_MIN_RATIO_CAP;
    }

    function getMaxSoilRatioCap() internal pure returns (uint256) {
        return SOIL_MAX_RATIO_CAP;
    }

    function getHarvestPercentage() internal pure returns (uint256) {
        return HARVESET_PERCENTAGE;
    }

    function getChainId() internal pure returns (uint256) {
        return CHAIN_ID;
    }

    function getOptimalPodRate() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(OPTIMAL_POD_RATE,1e18);
    }

    function getUpperBoundPodRate() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(POD_RATE_UPPER_BOUND,1e18);
    }

    function getLowerBoundPodRate() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(POD_RATE_LOWER_BOUND,1e18);
    }

    function getUpperBoundDPD() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(DELTA_POD_DEMAND_UPPER_BOUND,1e18);
    }

    function getLowerBoundDPD() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(DELTA_POD_DEMAND_LOWER_BOUND,1e18);
    }

    function getSteadySowTime() internal pure returns (uint256) {
        return STEADY_SOW_TIME;
    }

    function getRainTime() internal pure returns (uint256) {
        return RAIN_TIME;
    }

    function getMaxPropositions() internal pure returns (uint256) {
      return MAX_PROPOSITIONS;
    }

    function getSeedsPerBean() internal pure returns (uint256) {
        return SEEDS_PER_BEAN;
    }

    function getSeedsPerLPBean() internal pure returns (uint256) {
        return SEEDS_PER_LP_BEAN;
    }

    function getStalkPerBean() internal pure returns (uint256) {
      return STALK_PER_BEAN;
    }

    function getStalkPerLPSeed() internal pure returns (uint256) {
      return STALK_PER_BEAN/SEEDS_PER_LP_BEAN;
    }

    function getRootsBase() internal pure returns (uint256) {
        return ROOTS_BASE;
    }

}

 

pragma solidity ^0.7.6;
 

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    
     
    
    
    
     
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

 

pragma solidity ^0.7.6;




 
library LibAppStorage {

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

}
