
pragma solidity ^0.5.16;

 
contract InterestRateModel {
    
    bool public constant isInterestRateModel = true;

     
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);

     
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);
}

pragma solidity ^0.5.16;

 
 

 
library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

     
    function add(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

     
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

     
    function mul(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
         
         
         
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

     
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
         
        require(b > 0, errorMessage);
        uint256 c = a / b;
         

        return c;
    }

     
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.5.16;




 
contract TripleSlopeRateModel is InterestRateModel {
    using SafeMath for uint256;

    event NewInterestParams(
        uint256 baseRatePerBlock,
        uint256 multiplierPerBlock,
        uint256 jumpMultiplierPerBlock,
        uint256 kink1,
        uint256 kink2,
        uint256 roof
    );

     
    address public owner;

     
    uint256 public constant blocksPerYear = 2102400;

     
    uint256 internal constant minRoofValue = 1e18;

     
    uint256 public multiplierPerBlock;

     
    uint256 public baseRatePerBlock;

     
    uint256 public jumpMultiplierPerBlock;

     
    uint256 public kink1;

     
    uint256 public kink2;

     
    uint256 public roof;

     
    constructor(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink1_,
        uint256 kink2_,
        uint256 roof_,
        address owner_
    ) public {
        owner = owner_;

        updateTripleRateModelInternal(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink1_, kink2_, roof_);
    }

     
    function updateTripleRateModel(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink1_,
        uint256 kink2_,
        uint256 roof_
    ) external {
        require(msg.sender == owner, "only the owner may call this function.");

        updateTripleRateModelInternal(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink1_, kink2_, roof_);
    }

     
    function utilizationRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) public view returns (uint256) {
         
        if (borrows == 0) {
            return 0;
        }

        uint256 util = borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
         
        if (util > roof) {
            util = roof;
        }
        return util;
    }

     
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) public view returns (uint256) {
        uint256 util = utilizationRate(cash, borrows, reserves);

        if (util <= kink1) {
            return util.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
        } else if (util <= kink2) {
            return kink1.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
        } else {
            uint256 normalRate = kink1.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
            uint256 excessUtil = util.sub(kink2);
            return excessUtil.mul(jumpMultiplierPerBlock).div(1e18).add(normalRate);
        }
    }

     
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) public view returns (uint256) {
        uint256 oneMinusReserveFactor = uint256(1e18).sub(reserveFactorMantissa);
        uint256 borrowRate = getBorrowRate(cash, borrows, reserves);
        uint256 rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
        return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
    }

     
    function updateTripleRateModelInternal(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink1_,
        uint256 kink2_,
        uint256 roof_
    ) internal {
        require(kink1_ <= kink2_, "kink1 must less than or equal to kink2");
        require(roof_ >= minRoofValue, "invalid roof value");

        baseRatePerBlock = baseRatePerYear.div(blocksPerYear);
        multiplierPerBlock = (multiplierPerYear.mul(1e18)).div(blocksPerYear.mul(kink1_));
        jumpMultiplierPerBlock = jumpMultiplierPerYear.div(blocksPerYear);
        kink1 = kink1_;
        kink2 = kink2_;
        roof = roof_;

        emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink1, kink2, roof);
    }
}