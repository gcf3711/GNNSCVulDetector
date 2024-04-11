 


pragma solidity ^0.5.0;

 
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
         
         
         
         
         
         
        _notEntered = true;
    }

     
    modifier nonReentrant() {
         
        require(_notEntered, "ReentrancyGuard: reentrant call");

         
        _notEntered = false;

        _;

         
         
        _notEntered = true;
    }
}

 

pragma solidity ^0.5.0;



contract MasterAware {

  INXMMaster public master;

  modifier onlyMember {
    require(master.isMember(msg.sender), "Caller is not a member");
    _;
  }

  modifier onlyInternal {
    require(master.isInternal(msg.sender), "Caller is not an internal contract");
    _;
  }

  modifier onlyMaster {
    if (address(master) != address(0)) {
      require(address(master) == msg.sender, "Not master");
    }
    _;
  }

  modifier onlyGovernance {
    require(
      master.checkIsAuthToGoverned(msg.sender),
      "Caller is not authorized to govern"
    );
    _;
  }

  modifier whenPaused {
    require(master.isPause(), "System is not paused");
    _;
  }

  modifier whenNotPaused {
    require(!master.isPause(), "System is paused");
    _;
  }

  function changeDependentContractAddress() external;

  function changeMasterAddress(address masterAddress) public onlyMaster {
    master = INXMMaster(masterAddress);
  }
}

 
pragma solidity >=0.5.0;

interface IPool {

  function transferAssetToSwapOperator(address asset, uint amount) external;

  function getAssetDetails(address _asset) external view returns (
    uint112 min,
    uint112 max,
    uint32 lastAssetSwapTime,
    uint maxSlippageRatio
  );

  function setAssetDataLastSwapTime(address asset, uint32 lastSwapTime) external;

  function minPoolEth() external returns (uint);
}

pragma solidity ^0.5.0;


 
interface OZIERC20 {
  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
  external returns (bool);

  function transferFrom(address from, address to, uint256 value)
  external returns (bool);

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
  external view returns (uint256);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

pragma solidity ^0.5.0;



contract Iupgradable {

  INXMMaster public ms;
  address public nxMasterAddress;

  modifier onlyInternal {
    require(ms.isInternal(msg.sender));
    _;
  }

  modifier isMemberAndcheckPause {
    require(ms.isPause() == false && ms.isMember(msg.sender) == true);
    _;
  }

  modifier onlyOwner {
    require(ms.isOwner(msg.sender));
    _;
  }

  modifier checkPause {
    require(ms.isPause() == false);
    _;
  }

  modifier isMember {
    require(ms.isMember(msg.sender), "Not member");
    _;
  }

   
  function changeDependentContractAddress() public;

   
  function changeMasterAddress(address _masterAddress) public {
    if (address(ms) != address(0)) {
      require(address(ms) == msg.sender, "Not master");
    }

    ms = INXMMaster(_masterAddress);
    nxMasterAddress = _masterAddress;
  }

}

pragma solidity ^0.5.0;

 

contract LockHandler {
   
  mapping(address => bytes32[]) public lockReason;

   
  struct LockToken {
    uint256 amount;
    uint256 validity;
    bool claimed;
  }

   
  mapping(address => mapping(bytes32 => LockToken)) public locked;
}

 
  address[] public assets;
  mapping(address => AssetData) public assetData;

   
  Quotation public quotation;
  NXMToken public nxmToken;
  TokenController public tokenController;
  MCR public mcr;

   
  address public swapController;
  uint public minPoolEth;
  PriceFeedOracle public priceFeedOracle;
  address public swapOperator;

   
  address constant public ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  uint public constant MCR_RATIO_DECIMALS = 4;
  uint public constant MAX_MCR_RATIO = 40000;  
  uint public constant MAX_BUY_SELL_MCR_ETH_FRACTION = 500;  

  uint internal constant CONSTANT_C = 5800000;
  uint internal constant CONSTANT_A = 1028 * 1e13;
  uint internal constant TOKEN_EXPONENT = 4;

   
  event Payout(address indexed to, address indexed asset, uint amount);
  event NXMSold (address indexed member, uint nxmIn, uint ethOut);
  event NXMBought (address indexed member, uint ethIn, uint nxmOut);
  event Swapped(address indexed fromAsset, address indexed toAsset, uint amountIn, uint amountOut);

   
  modifier onlySwapOperator {
    require(msg.sender == swapOperator, "Pool: not swapOperator");
    _;
  }

  constructor (
    address[] memory _assets,
    uint112[] memory _minAmounts,
    uint112[] memory _maxAmounts,
    uint[] memory _maxSlippageRatios,
    address _master,
    address _priceOracle,
    address _swapOperator
  ) public {

    require(_assets.length == _minAmounts.length, "Pool: length mismatch");
    require(_assets.length == _maxAmounts.length, "Pool: length mismatch");
    require(_assets.length == _maxSlippageRatios.length, "Pool: length mismatch");

    for (uint i = 0; i < _assets.length; i++) {

      address asset = _assets[i];
      require(asset != address(0), "Pool: asset is zero address");
      require(_maxAmounts[i] >= _minAmounts[i], "Pool: max < min");
      require(_maxSlippageRatios[i] <= 1 ether, "Pool: max < min");

      assets.push(asset);
      assetData[asset].minAmount = _minAmounts[i];
      assetData[asset].maxAmount = _maxAmounts[i];
      assetData[asset].maxSlippageRatio = _maxSlippageRatios[i];
    }

    master = INXMMaster(_master);
    priceFeedOracle = PriceFeedOracle(_priceOracle);
    swapOperator = _swapOperator;
  }

   
  function() external payable {}

   
  function sendEther() external payable {}

   
  function getPoolValueInEth() public view returns (uint) {

    uint total = address(this).balance;

    for (uint i = 0; i < assets.length; i++) {

      address assetAddress = assets[i];
      IERC20 token = IERC20(assetAddress);

      uint rate = priceFeedOracle.getAssetToEthRate(assetAddress);
      require(rate > 0, "Pool: zero rate");

      uint assetBalance = token.balanceOf(address(this));
      uint assetValue = assetBalance.mul(rate).div(1e18);

      total = total.add(assetValue);
    }

    return total;
  }

   

  function getAssets() external view returns (address[] memory) {
    return assets;
  }

  function getAssetDetails(address _asset) external view returns (
    uint112 min,
    uint112 max,
    uint32 lastAssetSwapTime,
    uint maxSlippageRatio
  ) {

    AssetData memory data = assetData[_asset];

    return (data.minAmount, data.maxAmount, data.lastSwapTime, data.maxSlippageRatio);
  }

  function addAsset(
    address _asset,
    uint112 _min,
    uint112 _max,
    uint _maxSlippageRatio
  ) external onlyGovernance {

    require(_asset != address(0), "Pool: asset is zero address");
    require(_max >= _min, "Pool: max < min");
    require(_maxSlippageRatio <= 1 ether, "Pool: max slippage ratio > 1");

    for (uint i = 0; i < assets.length; i++) {
      require(_asset != assets[i], "Pool: asset exists");
    }

    assets.push(_asset);
    assetData[_asset] = AssetData(_min, _max, 0, _maxSlippageRatio);
  }

  function removeAsset(address _asset) external onlyGovernance {

    for (uint i = 0; i < assets.length; i++) {

      if (_asset != assets[i]) {
        continue;
      }

      delete assetData[_asset];
      assets[i] = assets[assets.length - 1];
      assets.pop();

      return;
    }

    revert("Pool: asset not found");
  }

  function setAssetDetails(
    address _asset,
    uint112 _min,
    uint112 _max,
    uint _maxSlippageRatio
  ) external onlyGovernance {

    require(_min <= _max, "Pool: min > max");
    require(_maxSlippageRatio <= 1 ether, "Pool: max slippage ratio > 1");

    for (uint i = 0; i < assets.length; i++) {

      if (_asset != assets[i]) {
        continue;
      }

      assetData[_asset].minAmount = _min;
      assetData[_asset].maxAmount = _max;
      assetData[_asset].maxSlippageRatio = _maxSlippageRatio;

      return;
    }

    revert("Pool: asset not found");
  }

   

   
  function sendClaimPayout (
    address asset,
    address payable payoutAddress,
    uint amount
  ) external onlyInternal nonReentrant returns (bool success) {

    bool ok;

    if (asset == ETH) {
       
      (ok,  ) = payoutAddress.call.value(amount)("");
    } else {
      ok =  _safeTokenTransfer(asset, payoutAddress, amount);
    }

    if (ok) {
      emit Payout(payoutAddress, asset, amount);
    }

    return ok;
  }

   
  function _safeTokenTransfer (
    address tokenAddress,
    address to,
    uint256 value
  ) internal returns (bool) {

     
    if (!tokenAddress.isContract()) {
      return false;
    }

    IERC20 token = IERC20(tokenAddress);
    bytes memory data = abi.encodeWithSelector(token.transfer.selector, to, value);
     
    (bool success, bytes memory returndata) = tokenAddress.call(data);

     
    if (!success) {
      return false;
    }

     
    if (returndata.length == 0) {
      return true;
    }

     
    return abi.decode(returndata, (bool));
  }

   

  function transferAsset(
    address asset,
    address payable destination,
    uint amount
  ) external onlyGovernance nonReentrant {

    require(assetData[asset].maxAmount == 0, "Pool: max not zero");
    require(destination != address(0), "Pool: dest zero");

    IERC20 token = IERC20(asset);
    uint balance = token.balanceOf(address(this));
    uint transferableAmount = amount > balance ? balance : amount;

    token.safeTransfer(destination, transferableAmount);
  }

  function upgradeCapitalPool(address payable newPoolAddress) external onlyMaster nonReentrant {

     
    uint ethBalance = address(this).balance;
    (bool ok,  ) = newPoolAddress.call.value(ethBalance)("");
    require(ok, "Pool: transfer failed");

     
    for (uint i = 0; i < assets.length; i++) {
      IERC20 token = IERC20(assets[i]);
      uint tokenBalance = token.balanceOf(address(this));
      token.safeTransfer(newPoolAddress, tokenBalance);
    }

  }

   
  function changeDependentContractAddress() public {
    nxmToken = NXMToken(master.tokenAddress());
    tokenController = TokenController(master.getLatestAddress("TC"));
    quotation = Quotation(master.getLatestAddress("QT"));
    mcr = MCR(master.getLatestAddress("MC"));
  }

   

  
  
  function makeCoverBegin(
    address smartCAdd,
    bytes4 coverCurr,
    uint[] memory coverDetails,
    uint16 coverPeriod,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public payable onlyMember whenNotPaused {

    require(coverCurr == "ETH", "Pool: Unexpected asset type");
    require(msg.value == coverDetails[1], "Pool: ETH amount does not match premium");

    quotation.verifyCoverDetails(msg.sender, smartCAdd, coverCurr, coverDetails, coverPeriod, _v, _r, _s);
  }

   
  function makeCoverUsingCA(
    address smartCAdd,
    bytes4 coverCurr,
    uint[] memory coverDetails,
    uint16 coverPeriod,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public onlyMember whenNotPaused {
    require(coverCurr != "ETH", "Pool: Unexpected asset type");
    quotation.verifyCoverDetails(msg.sender, smartCAdd, coverCurr, coverDetails, coverPeriod, _v, _r, _s);
  }

  function transferAssetFrom (address asset, address from, uint amount) public onlyInternal whenNotPaused {
    IERC20 token = IERC20(asset);
    token.safeTransferFrom(from, address(this), amount);
  }

  function transferAssetToSwapOperator (address asset, uint amount) public onlySwapOperator nonReentrant whenNotPaused {

    if (asset == ETH) {
      (bool ok,  ) = swapOperator.call.value(amount)("");
      require(ok, "Pool: Eth transfer failed");
      return;
    }

    IERC20 token = IERC20(asset);
    token.safeTransfer(swapOperator, amount);
  }

  function setAssetDataLastSwapTime(address asset, uint32 lastSwapTime) public onlySwapOperator whenNotPaused {
    assetData[asset].lastSwapTime = lastSwapTime;
  }

   

   
  function sellNXMTokens(uint _amount) public onlyMember whenNotPaused returns (bool success) {
    sellNXM(_amount, 0);
    return true;
  }

   
  function getWei(uint amount) external view returns (uint weiToPay) {
    return getEthForNXM(amount);
  }

   
  function buyNXM(uint minTokensOut) public payable onlyMember whenNotPaused {

    uint ethIn = msg.value;
    require(ethIn > 0, "Pool: ethIn > 0");

    uint totalAssetValue = getPoolValueInEth().sub(ethIn);
    uint mcrEth = mcr.getMCR();
    uint mcrRatio = calculateMCRRatio(totalAssetValue, mcrEth);

    require(mcrRatio <= MAX_MCR_RATIO, "Pool: Cannot purchase if MCR% > 400%");
    uint tokensOut = calculateNXMForEth(ethIn, totalAssetValue, mcrEth);
    require(tokensOut >= minTokensOut, "Pool: tokensOut is less than minTokensOut");
    tokenController.mint(msg.sender, tokensOut);

     
    mcr.updateMCRInternal(totalAssetValue.add(ethIn), false);
    emit NXMBought(msg.sender, ethIn, tokensOut);
  }

   
  function sellNXM(uint tokenAmount, uint minEthOut) public onlyMember nonReentrant whenNotPaused {

    require(nxmToken.balanceOf(msg.sender) >= tokenAmount, "Pool: Not enough balance");
    require(nxmToken.isLockedForMV(msg.sender) <= now, "Pool: NXM tokens are locked for voting");

    uint currentTotalAssetValue = getPoolValueInEth();
    uint mcrEth = mcr.getMCR();
    uint ethOut = calculateEthForNXM(tokenAmount, currentTotalAssetValue, mcrEth);
    require(currentTotalAssetValue.sub(ethOut) >= mcrEth, "Pool: MCR% cannot fall below 100%");
    require(ethOut >= minEthOut, "Pool: ethOut < minEthOut");

    tokenController.burnFrom(msg.sender, tokenAmount);
    (bool ok,  ) = msg.sender.call.value(ethOut)("");
    require(ok, "Pool: Sell transfer failed");

     
    mcr.updateMCRInternal(currentTotalAssetValue.sub(ethOut), false);
    emit NXMSold(msg.sender, tokenAmount, ethOut);
  }

   
  function getNXMForEth(
    uint ethAmount
  ) public view returns (uint) {
    uint totalAssetValue = getPoolValueInEth();
    uint mcrEth = mcr.getMCR();
    return calculateNXMForEth(ethAmount, totalAssetValue, mcrEth);
  }

  function calculateNXMForEth(
    uint ethAmount,
    uint currentTotalAssetValue,
    uint mcrEth
  ) public pure returns (uint) {

    require(
      ethAmount <= mcrEth.mul(MAX_BUY_SELL_MCR_ETH_FRACTION).div(10 ** MCR_RATIO_DECIMALS),
      "Pool: Purchases worth higher than 5% of MCReth are not allowed"
    );

     

    if (currentTotalAssetValue == 0 || mcrEth.div(currentTotalAssetValue) > 1e12) {
       
      uint tokenPrice = CONSTANT_A;
      return ethAmount.mul(1e18).div(tokenPrice);
    }

     
    uint point0 = calculateIntegralAtPoint(currentTotalAssetValue, mcrEth);
     
    uint nextTotalAssetValue = currentTotalAssetValue.add(ethAmount);
    uint point1 = calculateIntegralAtPoint(nextTotalAssetValue, mcrEth);
    uint adjustedTokenAmount = point0.sub(point1);
     
     
    uint adjustedTokenPrice = ethAmount.mul(1e18).div(adjustedTokenAmount);
    uint tokenPrice = adjustedTokenPrice.add(CONSTANT_A);

    return ethAmount.mul(1e18).div(tokenPrice);
  }

   
  function calculateIntegralAtPoint(
    uint assetValue,
    uint mcrEth
  ) internal pure returns (uint) {

    return CONSTANT_C
      .mul(1e18)
      .div(3)
      .mul(mcrEth).div(assetValue)
      .mul(mcrEth).div(assetValue)
      .mul(mcrEth).div(assetValue);
  }

  function getEthForNXM(uint nxmAmount) public view returns (uint ethAmount) {
    uint currentTotalAssetValue = getPoolValueInEth();
    uint mcrEth = mcr.getMCR();
    return calculateEthForNXM(nxmAmount, currentTotalAssetValue, mcrEth);
  }

   
  function calculateEthForNXM(
    uint nxmAmount,
    uint currentTotalAssetValue,
    uint mcrEth
  ) public pure returns (uint) {

     
    uint spotPrice0 = calculateTokenSpotPrice(currentTotalAssetValue, mcrEth);
    uint spotEthAmount = nxmAmount.mul(spotPrice0).div(1e18);

     
    uint totalValuePostSpotPriceSell = currentTotalAssetValue.sub(spotEthAmount);
    uint spotPrice1 = calculateTokenSpotPrice(totalValuePostSpotPriceSell, mcrEth);

     
     
    uint averagePriceWithSpread = spotPrice0.add(spotPrice1).div(2).mul(975).div(1000);
    uint finalPrice = averagePriceWithSpread < spotPrice1 ? averagePriceWithSpread : spotPrice1;
    uint ethAmount = finalPrice.mul(nxmAmount).div(1e18);

    require(
      ethAmount <= mcrEth.mul(MAX_BUY_SELL_MCR_ETH_FRACTION).div(10 ** MCR_RATIO_DECIMALS),
      "Pool: Sales worth more than 5% of MCReth are not allowed"
    );

    return ethAmount;
  }

  function calculateMCRRatio(uint totalAssetValue, uint mcrEth) public pure returns (uint) {
    return totalAssetValue.mul(10 ** MCR_RATIO_DECIMALS).div(mcrEth);
  }

   
  function calculateTokenSpotPrice(uint totalAssetValue, uint mcrEth) public pure returns (uint tokenPrice) {

    uint mcrRatio = calculateMCRRatio(totalAssetValue, mcrEth);
    uint precisionDecimals = 10 ** TOKEN_EXPONENT.mul(MCR_RATIO_DECIMALS);

    return mcrEth
      .mul(mcrRatio ** TOKEN_EXPONENT)
      .div(CONSTANT_C)
      .div(precisionDecimals)
      .add(CONSTANT_A);
  }

   
  function getTokenPrice(address asset) public view returns (uint tokenPrice) {

    uint totalAssetValue = getPoolValueInEth();
    uint mcrEth = mcr.getMCR();
    uint tokenSpotPriceEth = calculateTokenSpotPrice(totalAssetValue, mcrEth);

    return priceFeedOracle.getAssetForEth(asset, tokenSpotPriceEth);
  }

  function getMCRRatio() public view returns (uint) {
    uint totalAssetValue = getPoolValueInEth();
    uint mcrEth = mcr.getMCR();
    return calculateMCRRatio(totalAssetValue, mcrEth);
  }

  function updateUintParameters(bytes8 code, uint value) external onlyGovernance {

    if (code == "MIN_ETH") {
      minPoolEth = value;
      return;
    }

    revert("Pool: unknown parameter");
  }

  function updateAddressParameters(bytes8 code, address value) external onlyGovernance {

    if (code == "SWP_OP") {
      swapOperator = value;
      return;
    }

    if (code == "PRC_FEED") {
      priceFeedOracle = PriceFeedOracle(value);
      return;
    }

    revert("Pool: unknown parameter");
  }
}

pragma solidity ^0.5.0;

 
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

pragma solidity ^0.5.0;

 
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

pragma solidity ^0.5.0;





 
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
         
         
         
         
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

     
    function callOptionalReturn(IERC20 token, bytes memory data) private {
         
         

         
         
         
         
         
        require(address(token).isContract(), "SafeERC20: call to non-contract");

         
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {  
             
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.5.5;

 
library Address {
     
    function isContract(address account) internal view returns (bool) {
         
         
         
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

     
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

 
  function changeDependentContractAddress() public onlyInternal {
    cr = ClaimsReward(master.getLatestAddress("CR"));
    pool = Pool(master.getLatestAddress("P1"));
    pooledStaking = IPooledStaking(master.getLatestAddress("PS"));
    qd = QuotationData(master.getLatestAddress("QD"));
    tc = TokenController(master.getLatestAddress("TC"));
    td = TokenData(master.getLatestAddress("TD"));
    incidents = Incidents(master.getLatestAddress("IC"));
  }

   
  function sendEther() public payable {}

   
  function expireCover(uint coverId) external {

    uint expirationDate = qd.getValidityOfCover(coverId);
    require(expirationDate < now, "Quotation: cover is not due to expire");

    uint coverStatus = qd.getCoverStatusNo(coverId);
    require(coverStatus != uint(QuotationData.CoverStatus.CoverExpired), "Quotation: cover already expired");

    ( , bool hasOpenClaim,  ) = tc.coverInfo(coverId);
    require(!hasOpenClaim, "Quotation: cover has an open claim");

    if (coverStatus != uint(QuotationData.CoverStatus.ClaimAccepted)) {
      (,, address contractAddress, bytes4 currency, uint amount,) = qd.getCoverDetailsByCoverID1(coverId);
      qd.subFromTotalSumAssured(currency, amount);
      qd.subFromTotalSumAssuredSC(contractAddress, currency, amount);
    }

    qd.changeCoverStatusNo(coverId, uint8(QuotationData.CoverStatus.CoverExpired));
  }

  function withdrawCoverNote(address coverOwner, uint[] calldata coverIds, uint[] calldata reasonIndexes) external {

    uint gracePeriod = tc.claimSubmissionGracePeriod();

    for (uint i = 0; i < coverIds.length; i++) {
      uint expirationDate = qd.getValidityOfCover(coverIds[i]);
      require(expirationDate.add(gracePeriod) < now, "Quotation: cannot withdraw before grace period expiration");
    }

    tc.withdrawCoverNote(coverOwner, coverIds, reasonIndexes);
  }

  function getWithdrawableCoverNoteCoverIds(
    address coverOwner
  ) public view returns (
    uint[] memory expiredCoverIds,
    bytes32[] memory lockReasons
  ) {

    uint[] memory coverIds = qd.getAllCoversOfUser(coverOwner);
    uint[] memory expiredIdsQueue = new uint[](coverIds.length);
    uint gracePeriod = tc.claimSubmissionGracePeriod();
    uint expiredQueueLength = 0;

    for (uint i = 0; i < coverIds.length; i++) {

      uint coverExpirationDate = qd.getValidityOfCover(coverIds[i]);
      uint gracePeriodExpirationDate = coverExpirationDate.add(gracePeriod);
      ( , bool hasOpenClaim,  ) = tc.coverInfo(coverIds[i]);

      if (!hasOpenClaim && gracePeriodExpirationDate < now) {
        expiredIdsQueue[expiredQueueLength] = coverIds[i];
        expiredQueueLength++;
      }
    }

    expiredCoverIds = new uint[](expiredQueueLength);
    lockReasons = new bytes32[](expiredQueueLength);

    for (uint i = 0; i < expiredQueueLength; i++) {
      expiredCoverIds[i] = expiredIdsQueue[i];
      lockReasons[i] = keccak256(abi.encodePacked("CN", coverOwner, expiredIdsQueue[i]));
    }
  }

  function getWithdrawableCoverNotesAmount(address coverOwner) external view returns (uint) {

    uint withdrawableAmount;
    bytes32[] memory lockReasons;
    ( , lockReasons) = getWithdrawableCoverNoteCoverIds(coverOwner);

    for (uint i = 0; i < lockReasons.length; i++) {
      uint coverNoteAmount = tc.tokensLocked(coverOwner, lockReasons[i]);
      withdrawableAmount = withdrawableAmount.add(coverNoteAmount);
    }

    return withdrawableAmount;
  }

   
  function makeCoverUsingNXMTokens(
    uint[] calldata coverDetails,
    uint16 coverPeriod,
    bytes4 coverCurr,
    address smartCAdd,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external onlyMember whenNotPaused {
    tc.burnFrom(msg.sender, coverDetails[2]);  
    _verifyCoverDetails(msg.sender, smartCAdd, coverCurr, coverDetails, coverPeriod, _v, _r, _s, true);
  }

   
  function verifyCoverDetails(
    address payable from,
    address scAddress,
    bytes4 coverCurr,
    uint[] memory coverDetails,
    uint16 coverPeriod,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public onlyInternal {
    _verifyCoverDetails(
      from,
      scAddress,
      coverCurr,
      coverDetails,
      coverPeriod,
      _v,
      _r,
      _s,
      false
    );
  }

   
  function verifySignature(
    uint[] memory coverDetails,
    uint16 coverPeriod,
    bytes4 currency,
    address contractAddress,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public view returns (bool) {
    require(contractAddress != address(0));
    bytes32 hash = getOrderHash(coverDetails, coverPeriod, currency, contractAddress);
    return isValidSignature(hash, _v, _r, _s);
  }

   
  function getOrderHash(
    uint[] memory coverDetails,
    uint16 coverPeriod,
    bytes4 currency,
    address contractAddress
  ) public view returns (bytes32) {
    return keccak256(
      abi.encodePacked(
        coverDetails[0],
        currency,
        coverPeriod,
        contractAddress,
        coverDetails[1],
        coverDetails[2],
        coverDetails[3],
        coverDetails[4],
        address(this)
      )
    );
  }

   
  function isValidSignature(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
    address a = ecrecover(prefixedHash, v, r, s);
    return (a == qd.getAuthQuoteEngine());
  }

   
  function _makeCover( 
    address payable from,
    address contractAddress,
    bytes4 coverCurrency,
    uint[] memory coverDetails,
    uint16 coverPeriod
  ) internal {

    address underlyingToken = incidents.underlyingToken(contractAddress);

    if (underlyingToken != address(0)) {
      address coverAsset = cr.getCurrencyAssetAddress(coverCurrency);
      require(coverAsset == underlyingToken, "Quotation: Unsupported cover asset for this product");
    }

    uint cid = qd.getCoverLength();

    qd.addCover(
      coverPeriod,
      coverDetails[0],
      from,
      coverCurrency,
      contractAddress,
      coverDetails[1],
      coverDetails[2]
    );

    uint coverNoteAmount = coverDetails[2].mul(qd.tokensRetained()).div(100);

    if (underlyingToken == address(0)) {
      uint gracePeriod = tc.claimSubmissionGracePeriod();
      uint claimSubmissionPeriod = uint(coverPeriod).mul(1 days).add(gracePeriod);
      bytes32 reason = keccak256(abi.encodePacked("CN", from, cid));

       
      td.setDepositCNAmount(cid, coverNoteAmount);
      tc.mintCoverNote(from, reason, coverNoteAmount, claimSubmissionPeriod);
    } else {
       
      tc.mint(from, coverNoteAmount);
    }

    qd.addInTotalSumAssured(coverCurrency, coverDetails[0]);
    qd.addInTotalSumAssuredSC(contractAddress, coverCurrency, coverDetails[0]);

    uint coverPremiumInNXM = coverDetails[2];
    uint stakersRewardPercentage = td.stakerCommissionPer();
    uint rewardValue = coverPremiumInNXM.mul(stakersRewardPercentage).div(100);
    pooledStaking.accumulateReward(contractAddress, rewardValue);
  }

   
  function _verifyCoverDetails(
    address payable from,
    address scAddress,
    bytes4 coverCurr,
    uint[] memory coverDetails,
    uint16 coverPeriod,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    bool isNXM
  ) internal {

    require(coverDetails[3] > now, "Quotation: Quote has expired");
    require(coverPeriod >= 30 && coverPeriod <= 365, "Quotation: Cover period out of bounds");
    require(!qd.timestampRepeated(coverDetails[4]), "Quotation: Quote already used");
    qd.setTimestampRepeated(coverDetails[4]);

    address asset = cr.getCurrencyAssetAddress(coverCurr);
    if (coverCurr != "ETH" && !isNXM) {
      pool.transferAssetFrom(asset, from, coverDetails[1]);
    }

    require(verifySignature(coverDetails, coverPeriod, coverCurr, scAddress, _v, _r, _s), "Quotation: signature mismatch");
    _makeCover(from, scAddress, coverCurr, coverDetails, coverPeriod);
  }

  function createCover(
    address payable from,
    address scAddress,
    bytes4 currency,
    uint[] calldata coverDetails,
    uint16 coverPeriod,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external onlyInternal {

    require(coverDetails[3] > now, "Quotation: Quote has expired");
    require(coverPeriod >= 30 && coverPeriod <= 365, "Quotation: Cover period out of bounds");
    require(!qd.timestampRepeated(coverDetails[4]), "Quotation: Quote already used");
    qd.setTimestampRepeated(coverDetails[4]);

    require(verifySignature(coverDetails, coverPeriod, currency, scAddress, _v, _r, _s), "Quotation: signature mismatch");
    _makeCover(from, scAddress, currency, coverDetails, coverPeriod);
  }

   
   
  function transferAssetsToNewContract(address) external pure {}

  function freeUpHeldCovers() external nonReentrant {

    IERC20 dai = IERC20(cr.getCurrencyAssetAddress("DAI"));
    uint membershipFee = td.joiningFee();
    uint lastCoverId = 106;

    for (uint id = 1; id <= lastCoverId; id++) {

      if (qd.holdedCoverIDStatus(id) != uint(QuotationData.HCIDStatus.kycPending)) {
        continue;
      }

      ( ,  , bytes4 currency,  ) = qd.getHoldedCoverDetailsByID1(id);
      ( , address payable userAddress, uint[] memory coverDetails) = qd.getHoldedCoverDetailsByID2(id);

      uint refundedETH = membershipFee;
      uint coverPremium = coverDetails[1];

      if (qd.refundEligible(userAddress)) {
        qd.setRefundEligible(userAddress, false);
      }

      qd.setHoldedCoverIDStatus(id, uint(QuotationData.HCIDStatus.kycFailedOrRefunded));

      if (currency == "ETH") {
        refundedETH = refundedETH.add(coverPremium);
      } else {
        require(dai.transfer(userAddress, coverPremium), "Quotation: DAI refund transfer failed");
      }

      userAddress.transfer(refundedETH);
    }
  }
}

 
  function getAssetToEthRate(address asset) public view returns (uint) {

    if (asset == ETH || asset == stETH) {
      return 1 ether;
    }

    address aggregatorAddress = aggregators[asset];

    if (aggregatorAddress == address(0)) {
      revert("PriceFeedOracle: Oracle asset not found");
    }

    int rate = Aggregator(aggregatorAddress).latestAnswer();
    require(rate > 0, "PriceFeedOracle: Rate must be > 0");

    return uint(rate);
  }

   
  function getAssetForEth(address asset, uint ethIn) external view returns (uint) {

    if (asset == daiAddress) {
      return ethIn.mul(1e18).div(getAssetToEthRate(daiAddress));
    }

    if (asset == ETH || asset == stETH) {
      return ethIn;
    }

    revert("PriceFeedOracle: Unknown asset");
  }

}

 
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

   
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

   
  function allowance(
    address owner,
    address spender
  )
  public
  view
  returns (uint256)
  {
    return _allowed[owner][spender];
  }

   
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

   
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
  public
  returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
  public
  returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

   
  function addToWhiteList(address _member) public onlyOperator returns (bool) {
    whiteListed[_member] = true;
    emit WhiteListed(_member);
    return true;
  }

   
  function removeFromWhiteList(address _member) public onlyOperator returns (bool) {
    whiteListed[_member] = false;
    emit BlackListed(_member);
    return true;
  }

   
  function changeOperator(address _newOperator) public onlyOperator returns (bool) {
    operator = _newOperator;
    return true;
  }

   
  function burn(uint256 amount) public returns (bool) {
    _burn(msg.sender, amount);
    return true;
  }

   
  function burnFrom(address from, uint256 value) public returns (bool) {
    _burnFrom(from, value);
    return true;
  }

   
  function mint(address account, uint256 amount) public onlyOperator {
    _mint(account, amount);
  }

   
  function transfer(address to, uint256 value) public canTransfer(to) returns (bool) {

    require(isLockedForMV[msg.sender] < now);  
    require(value <= _balances[msg.sender]);
    _transfer(to, value);
    return true;
  }

   
  function operatorTransfer(address from, uint256 value) public onlyOperator returns (bool) {
    require(value <= _balances[from]);
    _transferFrom(from, operator, value);
    return true;
  }

   
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
  public
  canTransfer(to)
  returns (bool)
  {
    require(isLockedForMV[from] < now);  
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    _transferFrom(from, to, value);
    return true;
  }

   
  function lockForMemberVote(address _of, uint _days) public onlyOperator {
    if (_days.add(now) > isLockedForMV[_of])
      isLockedForMV[_of] = _days.add(now);
  }

   
  function _transfer(address to, uint256 value) internal {
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
  }

   
  function _transferFrom(
    address from,
    address to,
    uint256 value
  )
  internal
  {
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
  }

   
  function _mint(address account, uint256 amount) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

   
  function _burn(address account, uint256 amount) internal {
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

   
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

     
     
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

 
  function changeDependentContractAddress() public {
    token = NXMToken(ms.tokenAddress());
    pooledStaking = IPooledStaking(ms.getLatestAddress("PS"));
  }

  function markCoverClaimOpen(uint coverId) external onlyInternal {

    CoverInfo storage info = coverInfo[coverId];

    uint16 claimCount;
    bool hasOpenClaim;
    bool hasAcceptedClaim;

     
    (claimCount, hasOpenClaim, hasAcceptedClaim) = (info.claimCount, info.hasOpenClaim, info.hasAcceptedClaim);

     
     
    claimCount = claimCount + 1;

    require(claimCount <= 2, "TokenController: Max claim count exceeded");
    require(hasOpenClaim == false, "TokenController: Cover already has an open claim");
    require(hasAcceptedClaim == false, "TokenController: Cover already has accepted claims");

     
    (info.claimCount, info.hasOpenClaim) = (claimCount, true);
  }

   
  function markCoverClaimClosed(uint coverId, bool isAccepted) external onlyInternal {

    CoverInfo storage info = coverInfo[coverId];
    require(info.hasOpenClaim == true, "TokenController: Cover claim is not marked as open");

     
    (info.hasOpenClaim, info.hasAcceptedClaim) = (false, isAccepted);
  }

   
  function changeOperator(address _newOperator) public onlyInternal {
    token.changeOperator(_newOperator);
  }

   
  function operatorTransfer(address _from, address _to, uint _value) external onlyInternal returns (bool) {
    require(msg.sender == address(pooledStaking), "TokenController: Call is only allowed from PooledStaking address");
    token.operatorTransfer(_from, _value);
    token.transfer(_to, _value);
    return true;
  }

   
  function lockClaimAssessmentTokens(uint256 _amount, uint256 _time) external checkPause {
    require(minCALockTime <= _time, "TokenController: Must lock for minimum time");
    require(_time <= 180 days, "TokenController: Tokens can be locked for 180 days maximum");
     
     
    _lock(msg.sender, "CLA", _amount, _time);
  }

   
  function lockOf(address _of, bytes32 _reason, uint256 _amount, uint256 _time)
  public
  onlyInternal
  returns (bool)
  {
     
     
    _lock(_of, _reason, _amount, _time);
    return true;
  }

   
  function mintCoverNote(
    address _of,
    bytes32 _reason,
    uint256 _amount,
    uint256 _time
  ) external onlyInternal {

    require(_tokensLocked(_of, _reason) == 0, "TokenController: An amount of tokens is already locked");
    require(_amount != 0, "TokenController: Amount shouldn't be zero");

    if (locked[_of][_reason].amount == 0) {
      lockReason[_of].push(_reason);
    }

    token.mint(address(this), _amount);

    uint256 lockedUntil = now.add(_time);
    locked[_of][_reason] = LockToken(_amount, lockedUntil, false);

    emit Locked(_of, _reason, _amount, lockedUntil);
  }

   
  function extendClaimAssessmentLock(uint256 _time) external checkPause {
    uint256 validity = getLockedTokensValidity(msg.sender, "CLA");
    require(validity.add(_time).sub(block.timestamp) <= 180 days, "TokenController: Tokens can be locked for 180 days maximum");
    _extendLock(msg.sender, "CLA", _time);
  }

   
  function extendLockOf(address _of, bytes32 _reason, uint256 _time)
  public
  onlyInternal
  returns (bool)
  {
    _extendLock(_of, _reason, _time);
    return true;
  }

   
  function increaseClaimAssessmentLock(uint256 _amount) external checkPause
  {
    require(_tokensLocked(msg.sender, "CLA") > 0, "TokenController: No tokens locked");
    token.operatorTransfer(msg.sender, _amount);

    locked[msg.sender]["CLA"].amount = locked[msg.sender]["CLA"].amount.add(_amount);
    emit Locked(msg.sender, "CLA", _amount, locked[msg.sender]["CLA"].validity);
  }

   
  function burnFrom(address _of, uint amount) public onlyInternal returns (bool) {
    return token.burnFrom(_of, amount);
  }

   
  function burnLockedTokens(address _of, bytes32 _reason, uint256 _amount) public onlyInternal {
    _burnLockedTokens(_of, _reason, _amount);
  }

   
  function reduceLock(address _of, bytes32 _reason, uint256 _time) public onlyInternal {
    _reduceLock(_of, _reason, _time);
  }

   
  function releaseLockedTokens(address _of, bytes32 _reason, uint256 _amount)
  public
  onlyInternal
  {
    _releaseLockedTokens(_of, _reason, _amount);
  }

   
  function addToWhitelist(address _member) public onlyInternal {
    token.addToWhiteList(_member);
  }

   
  function removeFromWhitelist(address _member) public onlyInternal {
    token.removeFromWhiteList(_member);
  }

   
  function mint(address _member, uint _amount) public onlyInternal {
    token.mint(_member, _amount);
  }

   
  function lockForMemberVote(address _of, uint _days) public onlyInternal {
    token.lockForMemberVote(_of, _days);
  }

   
  function withdrawClaimAssessmentTokens(address _of) external checkPause {
    uint256 withdrawableTokens = _tokensUnlockable(_of, "CLA");
    if (withdrawableTokens > 0) {
      locked[_of]["CLA"].claimed = true;
      emit Unlocked(_of, "CLA", withdrawableTokens);
      token.transfer(_of, withdrawableTokens);
    }
  }

   
  function updateUintParameters(bytes8 code, uint value) external onlyGovernance {

    if (code == "MNCLT") {
      minCALockTime = value;
      return;
    }

    if (code == "GRACEPER") {
      claimSubmissionGracePeriod = value;
      return;
    }

    revert("TokenController: invalid param code");
  }

  function getLockReasons(address _of) external view returns (bytes32[] memory reasons) {
    return lockReason[_of];
  }

   
  function getLockedTokensValidity(address _of, bytes32 reason) public view returns (uint256 validity) {
    validity = locked[_of][reason].validity;
  }

   
  function getUnlockableTokens(address _of)
  public
  view
  returns (uint256 unlockableTokens)
  {
    for (uint256 i = 0; i < lockReason[_of].length; i++) {
      unlockableTokens = unlockableTokens.add(_tokensUnlockable(_of, lockReason[_of][i]));
    }
  }

   
  function tokensLocked(address _of, bytes32 _reason)
  public
  view
  returns (uint256 amount)
  {
    return _tokensLocked(_of, _reason);
  }

   
  function tokensLockedWithValidity(address _of, bytes32 _reason)
  public
  view
  returns (uint256 amount, uint256 validity)
  {

    bool claimed = locked[_of][_reason].claimed;
    amount = locked[_of][_reason].amount;
    validity = locked[_of][_reason].validity;

    if (claimed) {
      amount = 0;
    }
  }

   
  function tokensUnlockable(address _of, bytes32 _reason)
  public
  view
  returns (uint256 amount)
  {
    return _tokensUnlockable(_of, _reason);
  }

  function totalSupply() public view returns (uint256)
  {
    return token.totalSupply();
  }

   
  function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
  public
  view
  returns (uint256 amount)
  {
    return _tokensLockedAtTime(_of, _reason, _time);
  }

   
  function totalBalanceOf(address _of) public view returns (uint256 amount) {

    amount = token.balanceOf(_of);

    for (uint256 i = 0; i < lockReason[_of].length; i++) {
      amount = amount.add(_tokensLocked(_of, lockReason[_of][i]));
    }

    uint stakerReward = pooledStaking.stakerReward(_of);
    uint stakerDeposit = pooledStaking.stakerDeposit(_of);

    amount = amount.add(stakerDeposit).add(stakerReward);
  }

   
  function totalLockedBalance(address _of) public view returns (uint256 amount) {

    for (uint256 i = 0; i < lockReason[_of].length; i++) {
      amount = amount.add(_tokensLocked(_of, lockReason[_of][i]));
    }

    amount = amount.add(pooledStaking.stakerDeposit(_of));
  }

   
  function _lock(address _of, bytes32 _reason, uint256 _amount, uint256 _time) internal {
    require(_tokensLocked(_of, _reason) == 0, "TokenController: An amount of tokens is already locked");
    require(_amount != 0, "TokenController: Amount shouldn't be zero");

    if (locked[_of][_reason].amount == 0) {
      lockReason[_of].push(_reason);
    }

    token.operatorTransfer(_of, _amount);

    uint256 validUntil = now.add(_time);
    locked[_of][_reason] = LockToken(_amount, validUntil, false);
    emit Locked(_of, _reason, _amount, validUntil);
  }

   
  function _tokensLocked(address _of, bytes32 _reason)
  internal
  view
  returns (uint256 amount)
  {
    if (!locked[_of][_reason].claimed) {
      amount = locked[_of][_reason].amount;
    }
  }

   
  function _tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
  internal
  view
  returns (uint256 amount)
  {
    if (locked[_of][_reason].validity > _time) {
      amount = locked[_of][_reason].amount;
    }
  }

   
  function _extendLock(address _of, bytes32 _reason, uint256 _time) internal {
    require(_tokensLocked(_of, _reason) > 0, "TokenController: No tokens locked");
    emit Unlocked(_of, _reason, locked[_of][_reason].amount);
    locked[_of][_reason].validity = locked[_of][_reason].validity.add(_time);
    emit Locked(_of, _reason, locked[_of][_reason].amount, locked[_of][_reason].validity);
  }

   
  function _reduceLock(address _of, bytes32 _reason, uint256 _time) internal {
    require(_tokensLocked(_of, _reason) > 0, "TokenController: No tokens locked");
    emit Unlocked(_of, _reason, locked[_of][_reason].amount);
    locked[_of][_reason].validity = locked[_of][_reason].validity.sub(_time);
    emit Locked(_of, _reason, locked[_of][_reason].amount, locked[_of][_reason].validity);
  }

   
  function _tokensUnlockable(address _of, bytes32 _reason) internal view returns (uint256 amount)
  {
    if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed) {
      amount = locked[_of][_reason].amount;
    }
  }

   
  function _burnLockedTokens(address _of, bytes32 _reason, uint256 _amount) internal {
    uint256 amount = _tokensLocked(_of, _reason);
    require(amount >= _amount, "TokenController: Amount exceedes locked tokens amount");

    if (amount == _amount) {
      locked[_of][_reason].claimed = true;
    }

    locked[_of][_reason].amount = locked[_of][_reason].amount.sub(_amount);

     

    token.burn(_amount);
    emit Burned(_of, _reason, _amount);
  }

   
  function _releaseLockedTokens(address _of, bytes32 _reason, uint256 _amount) internal
  {
    uint256 amount = _tokensLocked(_of, _reason);
    require(amount >= _amount, "TokenController: Amount exceedes locked tokens amount");

    if (amount == _amount) {
      locked[_of][_reason].claimed = true;
    }

    locked[_of][_reason].amount = locked[_of][_reason].amount.sub(_amount);

     

    token.transfer(_of, _amount);
    emit Unlocked(_of, _reason, _amount);
  }

  function withdrawCoverNote(
    address _of,
    uint[] calldata _coverIds,
    uint[] calldata _indexes
  ) external onlyInternal {

    uint reasonCount = lockReason[_of].length;
    uint lastReasonIndex = reasonCount.sub(1, "TokenController: No locked cover notes found");
    uint totalAmount = 0;

     
     
     

    for (uint i = _coverIds.length; i > 0; i--) {

      bool hasOpenClaim = coverInfo[_coverIds[i - 1]].hasOpenClaim;
      require(hasOpenClaim == false, "TokenController: Cannot withdraw for cover with an open claim");

       
      bytes32 _reason = keccak256(abi.encodePacked("CN", _of, _coverIds[i - 1]));
      uint _reasonIndex = _indexes[i - 1];
      require(lockReason[_of][_reasonIndex] == _reason, "TokenController: Bad reason index");

      uint amount = locked[_of][_reason].amount;
      totalAmount = totalAmount.add(amount);
      delete locked[_of][_reason];

      if (lastReasonIndex != _reasonIndex) {
        lockReason[_of][_reasonIndex] = lockReason[_of][lastReasonIndex];
      }

      lockReason[_of].pop();
      emit Unlocked(_of, _reason, amount);

      if (lastReasonIndex > 0) {
        lastReasonIndex = lastReasonIndex.sub(1, "TokenController: Reason count mismatch");
      }
    }

    token.transfer(_of, totalAmount);
  }

  function removeEmptyReason(address _of, bytes32 _reason, uint _index) external {
    _removeEmptyReason(_of, _reason, _index);
  }

  function removeMultipleEmptyReasons(
    address[] calldata _members,
    bytes32[] calldata _reasons,
    uint[] calldata _indexes
  ) external {

    require(_members.length == _reasons.length, "TokenController: members and reasons array lengths differ");
    require(_reasons.length == _indexes.length, "TokenController: reasons and indexes array lengths differ");

    for (uint i = _members.length; i > 0; i--) {
      uint idx = i - 1;
      _removeEmptyReason(_members[idx], _reasons[idx], _indexes[idx]);
    }
  }

  function _removeEmptyReason(address _of, bytes32 _reason, uint _index) internal {

    uint lastReasonIndex = lockReason[_of].length.sub(1, "TokenController: lockReason is empty");

    require(lockReason[_of][_index] == _reason, "TokenController: bad reason index");
    require(locked[_of][_reason].amount == 0, "TokenController: reason amount is not zero");

    if (lastReasonIndex != _index) {
      lockReason[_of][_index] = lockReason[_of][lastReasonIndex];
    }

    lockReason[_of].pop();
  }

  function initialize() external {
    require(claimSubmissionGracePeriod == 0, "TokenController: Already initialized");
    claimSubmissionGracePeriod = 120 days;
    migrate();
  }

  function migrate() internal {

    ClaimsData cd = ClaimsData(ms.getLatestAddress("CD"));
    uint totalClaims = cd.actualClaimLength() - 1;

     
    cd.changeFinalVerdict(20, -1);
    cd.setClaimStatus(20, 6);
    cd.changeFinalVerdict(21, -1);
    cd.setClaimStatus(21, 6);

     
     
    address payable[3] memory members = [
      0x4a9fA34da6d2378c8f3B9F6b83532B169beaEDFc,
      0x6b5DCDA27b5c3d88e71867D6b10b35372208361F,
      0x8B6D1e5b4db5B6f9aCcc659e2b9619B0Cd90D617
    ];

    for (uint i = 0; i < members.length; i++) {
      if (locked[members[i]]["CLA"].validity > now + 180 days) {
        locked[members[i]]["CLA"].validity = now + 180 days;
      }
    }

    for (uint i = 1; i <= totalClaims; i++) {

      ( , uint status) = cd.getClaimStatusNumber(i);
      ( , uint coverId) = cd.getClaimCoverId(i);
      int8 verdict = cd.getFinalVerdict(i);

       
      CoverInfo memory info = coverInfo[coverId];

      info.claimCount = info.claimCount + 1;
      info.hasAcceptedClaim = (status == 14);
      info.hasOpenClaim = (verdict == 0);

       
      coverInfo[coverId] = info;
    }
  }

}

 
  function changeDependentContractAddress() public {
    qd = QuotationData(master.getLatestAddress("QD"));
    pool = Pool(master.getLatestAddress("P1"));
    initialize();
  }

  function initialize() internal {

    address currentMCR = master.getLatestAddress("MC");

    if (address(previousMCR) == address(0) || currentMCR != address(this)) {
       
      return;
    }

     
    uint112 minCap = 7000 * 1e18;
    mcrFloor = uint112(previousMCR.variableMincap()) + minCap;
    mcr = uint112(previousMCR.getLastMCREther());
    desiredMCR = mcr;
    mcrFloorIncrementThreshold = uint24(previousMCR.dynamicMincapThresholdx100());
    maxMCRFloorIncrement = uint24(previousMCR.dynamicMincapIncrementx100());

     
    lastUpdateTime = uint32(block.timestamp);
    previousMCR = LegacyMCR(address(0));
  }

   
  function getAllSumAssurance() public view returns (uint) {

    PriceFeedOracle priceFeed = pool.priceFeedOracle();
    address daiAddress = priceFeed.daiAddress();

    uint ethAmount = qd.getTotalSumAssured("ETH").mul(1e18);
    uint daiAmount = qd.getTotalSumAssured("DAI").mul(1e18);

    uint daiRate = priceFeed.getAssetToEthRate(daiAddress);
    uint daiAmountInEth = daiAmount.mul(daiRate).div(1e18);

    return ethAmount.add(daiAmountInEth);
  }

   
  function updateMCR() public {
    _updateMCR(pool.getPoolValueInEth(), false);
  }

  function updateMCRInternal(uint poolValueInEth, bool forceUpdate) public onlyInternal {
    _updateMCR(poolValueInEth, forceUpdate);
  }

  function _updateMCR(uint poolValueInEth, bool forceUpdate) internal {

     
    uint _mcrFloorIncrementThreshold = mcrFloorIncrementThreshold;
    uint _maxMCRFloorIncrement = maxMCRFloorIncrement;
    uint _gearingFactor = gearingFactor;
    uint _minUpdateTime = minUpdateTime;
    uint _mcrFloor =  mcrFloor;

     
    uint112 _mcr = mcr;
    uint112 _desiredMCR = desiredMCR;
    uint32 _lastUpdateTime = lastUpdateTime;

    if (!forceUpdate && _lastUpdateTime + _minUpdateTime > block.timestamp) {
      return;
    }

    if (block.timestamp > _lastUpdateTime && pool.calculateMCRRatio(poolValueInEth, _mcr) >= _mcrFloorIncrementThreshold) {
         
         
      uint basisPointsAdjustment = min(
        _maxMCRFloorIncrement.mul(block.timestamp - _lastUpdateTime).div(1 days),
        _maxMCRFloorIncrement
      );
      uint newMCRFloor = _mcrFloor.mul(basisPointsAdjustment.add(BASIS_PRECISION)).div(BASIS_PRECISION);
      require(newMCRFloor <= uint112(~0), 'MCR: newMCRFloor overflow');

      mcrFloor = uint112(newMCRFloor);
    }

     
    uint112 newMCR = uint112(getMCR());
    if (newMCR != _mcr) {
      mcr = newMCR;
    }

     
     
    uint totalSumAssured = getAllSumAssurance();
    uint gearedMCR = totalSumAssured.mul(BASIS_PRECISION).div(_gearingFactor);
    uint112 newDesiredMCR = uint112(max(gearedMCR, mcrFloor));
    if (newDesiredMCR != _desiredMCR) {
      desiredMCR = newDesiredMCR;
    }

    lastUpdateTime = uint32(block.timestamp);

    emit MCRUpdated(mcr, desiredMCR, mcrFloor, gearedMCR, totalSumAssured);
  }

   
  function getMCR() public view returns (uint) {

     
    uint _mcr = mcr;
    uint _desiredMCR = desiredMCR;
    uint _lastUpdateTime = lastUpdateTime;


    if (block.timestamp == _lastUpdateTime) {
      return _mcr;
    }

    uint _maxMCRIncrement = maxMCRIncrement;

    uint basisPointsAdjustment = _maxMCRIncrement.mul(block.timestamp - _lastUpdateTime).div(1 days);
    basisPointsAdjustment = min(basisPointsAdjustment, MAX_MCR_ADJUSTMENT);

    if (_desiredMCR > _mcr) {
      return min(_mcr.mul(basisPointsAdjustment.add(BASIS_PRECISION)).div(BASIS_PRECISION), _desiredMCR);
    }

     
    return max(_mcr.mul(BASIS_PRECISION - basisPointsAdjustment).div(BASIS_PRECISION), _desiredMCR);
  }

  function getGearedMCR() external view returns (uint) {
    return getAllSumAssurance().mul(BASIS_PRECISION).div(gearingFactor);
  }

  function min(uint x, uint y) pure internal returns (uint) {
    return x < y ? x : y;
  }

  function max(uint x, uint y) pure internal returns (uint) {
    return x > y ? x : y;
  }

   
  function updateUintParameters(bytes8 code, uint val) public {
    require(master.checkIsAuthToGoverned(msg.sender));
    if (code == "DMCT") {

      require(val <= UINT24_MAX, "MCR: value too large");
      mcrFloorIncrementThreshold = uint24(val);

    } else if (code == "DMCI") {

      require(val <= UINT24_MAX, "MCR: value too large");
      maxMCRFloorIncrement = uint24(val);

    } else if (code == "MMIC") {

      require(val <= UINT24_MAX, "MCR: value too large");
      maxMCRIncrement = uint24(val);

    } else if (code == "GEAR") {

      require(val <= UINT24_MAX, "MCR: value too large");
      gearingFactor = uint24(val);

    } else if (code == "MUTI") {

      require(val <= UINT24_MAX, "MCR: value too large");
      minUpdateTime = uint24(val);

    } else {
      revert("Invalid param code");
    }
  }
}

 
  function claimAllPendingReward(uint records) public isMemberAndcheckPause {
    _claimRewardToBeDistributed(records);
    pooledStaking.withdrawReward(msg.sender);
    uint governanceRewards = gv.claimReward(msg.sender, records);
    if (governanceRewards > 0) {
      require(tk.transfer(msg.sender, governanceRewards));
    }
  }

   
  function getAllPendingRewardOfUser(address _add) public view returns (uint) {
    uint caReward = getRewardToBeDistributedByUser(_add);
    uint pooledStakingReward = pooledStaking.stakerReward(_add);
    uint governanceReward = gv.getPendingReward(_add);
    return caReward.add(pooledStakingReward).add(governanceReward);
  }

  
   
  
  function _rewardAgainstClaim(uint claimid, uint coverid, uint status) internal {

    uint premiumNXM = qd.getCoverPremiumNXM(coverid);
    uint distributableTokens = premiumNXM.mul(cd.claimRewardPerc()).div(100);  

    uint percCA;
    uint percMV;

    (percCA, percMV) = cd.getRewardStatus(status);
    cd.setClaimRewardDetail(claimid, percCA, percMV, distributableTokens);

    if (percCA > 0 || percMV > 0) {
      tc.mint(address(this), distributableTokens);
    }

     
    if (status == 6 || status == 9 || status == 11) {

      cd.changeFinalVerdict(claimid, -1);
      tc.markCoverClaimClosed(coverid, false);
      _burnCoverNoteDeposit(coverid);

     
    } else if (status == 7 || status == 8 || status == 10) {

      cd.changeFinalVerdict(claimid, 1);
      tc.markCoverClaimClosed(coverid, true);
      _unlockCoverNote(coverid);

      bool payoutSucceeded = attemptClaimPayout(coverid);

       
      uint nextStatus = payoutSucceeded ? 14 : 12;
      c1.setClaimStatus(claimid, nextStatus);
    }
  }

  function _burnCoverNoteDeposit(uint coverId) internal {

    address _of = qd.getCoverMemberAddress(coverId);
    bytes32 reason = keccak256(abi.encodePacked("CN", _of, coverId));
    uint lockedAmount = tc.tokensLocked(_of, reason);

    (uint amount,) = td.depositedCN(coverId);
    amount = amount.div(2);

     
    uint burnAmount = lockedAmount < amount ? lockedAmount : amount;

    if (burnAmount != 0) {
      tc.burnLockedTokens(_of, reason, amount);
    }
  }

  function _unlockCoverNote(uint coverId) internal {

    address coverHolder = qd.getCoverMemberAddress(coverId);
    bytes32 reason = keccak256(abi.encodePacked("CN", coverHolder, coverId));
    uint lockedCN = tc.tokensLocked(coverHolder, reason);

    if (lockedCN != 0) {
      tc.releaseLockedTokens(coverHolder, reason, lockedCN);
    }
  }

  
  function _changeClaimStatusCA(uint claimid, uint coverid, uint status) internal {
     
    if (c1.checkVoteClosing(claimid) == 1) {
      uint caTokens = c1.getCATokens(claimid, 0);  
      uint accept;
      uint deny;
      uint acceptAndDeny;
      bool rewardOrPunish;
      uint sumAssured;
      (, accept) = cd.getClaimVote(claimid, 1);
      (, deny) = cd.getClaimVote(claimid, - 1);
      acceptAndDeny = accept.add(deny);
      accept = accept.mul(100);
      deny = deny.mul(100);

      if (caTokens == 0) {
        status = 3;
      } else {
        sumAssured = qd.getCoverSumAssured(coverid).mul(DECIMAL1E18);
         
        if (caTokens > sumAssured.mul(5)) {

          if (accept.div(acceptAndDeny) > 70) {
            status = 7;
            qd.changeCoverStatusNo(coverid, uint8(QuotationData.CoverStatus.ClaimAccepted));
            rewardOrPunish = true;
          } else if (deny.div(acceptAndDeny) > 70) {
            status = 6;
            qd.changeCoverStatusNo(coverid, uint8(QuotationData.CoverStatus.ClaimDenied));
            rewardOrPunish = true;
          } else if (accept.div(acceptAndDeny) > deny.div(acceptAndDeny)) {
            status = 4;
          } else {
            status = 5;
          }

        } else {

          if (accept.div(acceptAndDeny) > deny.div(acceptAndDeny)) {
            status = 2;
          } else {
            status = 3;
          }
        }
      }

      c1.setClaimStatus(claimid, status);

      if (rewardOrPunish) {
        _rewardAgainstClaim(claimid, coverid, status);
      }
    }
  }

  
  function _changeClaimStatusMV(uint claimid, uint coverid, uint status) internal {

     
    if (c1.checkVoteClosing(claimid) == 1) {
      uint8 coverStatus;
      uint statusOrig = status;
      uint mvTokens = c1.getCATokens(claimid, 1);  

       
      uint sumAssured = qd.getCoverSumAssured(coverid).mul(DECIMAL1E18);
      uint thresholdUnreached = 0;
       
       
      if (mvTokens < sumAssured.mul(5)) {
        thresholdUnreached = 1;
      }

      uint accept;
      (, accept) = cd.getClaimMVote(claimid, 1);
      uint deny;
      (, deny) = cd.getClaimMVote(claimid, - 1);

      if (accept.add(deny) > 0) {
        if (accept.mul(100).div(accept.add(deny)) >= 50 && statusOrig > 1 &&
        statusOrig <= 5 && thresholdUnreached == 0) {
          status = 8;
          coverStatus = uint8(QuotationData.CoverStatus.ClaimAccepted);
        } else if (deny.mul(100).div(accept.add(deny)) >= 50 && statusOrig > 1 &&
        statusOrig <= 5 && thresholdUnreached == 0) {
          status = 9;
          coverStatus = uint8(QuotationData.CoverStatus.ClaimDenied);
        }
      }

      if (thresholdUnreached == 1 && (statusOrig == 2 || statusOrig == 4)) {
        status = 10;
        coverStatus = uint8(QuotationData.CoverStatus.ClaimAccepted);
      } else if (thresholdUnreached == 1 && (statusOrig == 5 || statusOrig == 3 || statusOrig == 1)) {
        status = 11;
        coverStatus = uint8(QuotationData.CoverStatus.ClaimDenied);
      }

      c1.setClaimStatus(claimid, status);
      qd.changeCoverStatusNo(coverid, uint8(coverStatus));
       
      _rewardAgainstClaim(claimid, coverid, status);
    }
  }

  
  function _claimRewardToBeDistributed(uint _records) internal {
    uint lengthVote = cd.getVoteAddressCALength(msg.sender);
    uint voteid;
    uint lastIndex;
    (lastIndex,) = cd.getRewardDistributedIndex(msg.sender);
    uint total = 0;
    uint tokenForVoteId = 0;
    bool lastClaimedCheck;
    uint _days = td.lockCADays();
    bool claimed;
    uint counter = 0;
    uint claimId;
    uint perc;
    uint i;
    uint lastClaimed = lengthVote;

    for (i = lastIndex; i < lengthVote && counter < _records; i++) {
      voteid = cd.getVoteAddressCA(msg.sender, i);
      (tokenForVoteId, lastClaimedCheck, , perc) = getRewardToBeGiven(1, voteid, 0);
      if (lastClaimed == lengthVote && lastClaimedCheck == true) {
        lastClaimed = i;
      }
      (, claimId, , claimed) = cd.getVoteDetails(voteid);

      if (perc > 0 && !claimed) {
        counter++;
        cd.setRewardClaimed(voteid, true);
      } else if (perc == 0 && cd.getFinalVerdict(claimId) != 0 && !claimed) {
        (perc,,) = cd.getClaimRewardDetail(claimId);
        if (perc == 0) {
          counter++;
        }
        cd.setRewardClaimed(voteid, true);
      }
      if (tokenForVoteId > 0) {
        total = tokenForVoteId.add(total);
      }
    }
    if (lastClaimed == lengthVote) {
      cd.setRewardDistributedIndexCA(msg.sender, i);
    }
    else {
      cd.setRewardDistributedIndexCA(msg.sender, lastClaimed);
    }
    lengthVote = cd.getVoteAddressMemberLength(msg.sender);
    lastClaimed = lengthVote;
    _days = _days.mul(counter);
    if (tc.tokensLockedAtTime(msg.sender, "CLA", now) > 0) {
      tc.reduceLock(msg.sender, "CLA", _days);
    }
    (, lastIndex) = cd.getRewardDistributedIndex(msg.sender);
    lastClaimed = lengthVote;
    counter = 0;
    for (i = lastIndex; i < lengthVote && counter < _records; i++) {
      voteid = cd.getVoteAddressMember(msg.sender, i);
      (tokenForVoteId, lastClaimedCheck,,) = getRewardToBeGiven(0, voteid, 0);
      if (lastClaimed == lengthVote && lastClaimedCheck == true) {
        lastClaimed = i;
      }
      (, claimId, , claimed) = cd.getVoteDetails(voteid);
      if (claimed == false && cd.getFinalVerdict(claimId) != 0) {
        cd.setRewardClaimed(voteid, true);
        counter++;
      }
      if (tokenForVoteId > 0) {
        total = tokenForVoteId.add(total);
      }
    }
    if (total > 0) {
      require(tk.transfer(msg.sender, total));
    }
    if (lastClaimed == lengthVote) {
      cd.setRewardDistributedIndexMV(msg.sender, i);
    }
    else {
      cd.setRewardDistributedIndexMV(msg.sender, lastClaimed);
    }
  }

   
  function _claimStakeCommission(uint _records, address _user) external onlyInternal {
    uint total = 0;
    uint len = td.getStakerStakedContractLength(_user);
    uint lastCompletedStakeCommission = td.lastCompletedStakeCommission(_user);
    uint commissionEarned;
    uint commissionRedeemed;
    uint maxCommission;
    uint lastCommisionRedeemed = len;
    uint counter;
    uint i;

    for (i = lastCompletedStakeCommission; i < len && counter < _records; i++) {
      commissionRedeemed = td.getStakerRedeemedStakeCommission(_user, i);
      commissionEarned = td.getStakerEarnedStakeCommission(_user, i);
      maxCommission = td.getStakerInitialStakedAmountOnContract(
        _user, i).mul(td.stakerMaxCommissionPer()).div(100);
      if (lastCommisionRedeemed == len && maxCommission != commissionEarned)
        lastCommisionRedeemed = i;
      td.pushRedeemedStakeCommissions(_user, i, commissionEarned.sub(commissionRedeemed));
      total = total.add(commissionEarned.sub(commissionRedeemed));
      counter++;
    }
    if (lastCommisionRedeemed == len) {
      td.setLastCompletedStakeCommissionIndex(_user, i);
    } else {
      td.setLastCompletedStakeCommissionIndex(_user, lastCommisionRedeemed);
    }

    if (total > 0)
      require(tk.transfer(_user, total));  
  }

}

 , _coverOwner, productId,
       currency, sumAssured,  
      ) = qd.getCoverDetailsByCoverID1(coverId);

       
      require(coverOwner == _coverOwner, "Incidents: Not cover owner");
      require(productId == incident.productId, "Incidents: Bad incident id");
    }

    {
      uint coverPeriod = uint(qd.getCoverPeriod(coverId)).mul(1 days);
      uint coverExpirationDate = qd.getValidityOfCover(coverId);
      uint coverStartDate = coverExpirationDate.sub(coverPeriod);

       
      require(coverStartDate <= incident.date, "Incidents: Cover start date is after the incident");
      require(coverExpirationDate >= incident.date, "Incidents: Cover end date is before the incident");

       
      uint gracePeriod = tokenController().claimSubmissionGracePeriod();
      require(coverExpirationDate.add(gracePeriod) >= block.timestamp, "Incidents: Grace period has expired");
    }

    {
       
      uint decimalPrecision = 1e18;
      uint maxAmount;

       
      uint coverAmount = sumAssured.mul(decimalPrecision);

      {
         
        uint deductiblePriceBefore = incident.priceBefore.mul(DEDUCTIBLE_RATIO).div(BASIS_PRECISION);
        maxAmount = coverAmount.mul(decimalPrecision).div(deductiblePriceBefore);
        require(coveredTokenAmount <= maxAmount, "Incidents: Amount exceeds sum assured");
      }

       
       
      payoutAmount = coveredTokenAmount.mul(coverAmount).div(maxAmount);
    }

    {
      TokenController tc = tokenController();
       
      tc.markCoverClaimOpen(coverId);
      tc.markCoverClaimClosed(coverId, true);

       
      ClaimsData cd = claimsData();
      claimId = cd.actualClaimLength();
      cd.addClaim(claimId, coverId, coverOwner, now);
      cd.callClaimEvent(coverId, coverOwner, claimId, now);
      cd.setClaimStatus(claimId, 14);
      qd.changeCoverStatusNo(coverId, uint8(QuotationData.CoverStatus.ClaimAccepted));

      claimPayout[claimId] = payoutAmount;
    }

    coverAsset = claimsReward().getCurrencyAssetAddress(currency);

    _sendPayoutAndPushBurn(
      incident.productId,
      address(uint160(coverOwner)),
      coveredTokenAmount,
      coverAsset,
      payoutAmount
    );

    qd.subFromTotalSumAssured(currency, sumAssured);
    qd.subFromTotalSumAssuredSC(incident.productId, currency, sumAssured);

    mcr().updateMCRInternal(pool().getPoolValueInEth(), true);
  }

  function pushBurns(address productId, uint maxIterations) external {

    uint burnAmount = accumulatedBurn[productId];
    delete accumulatedBurn[productId];

    require(burnAmount > 0, "Incidents: No burns to push");
    require(maxIterations >= 30, "Incidents: Pass at least 30 iterations");

    IPooledStaking ps = pooledStaking();
    ps.pushBurn(productId, burnAmount);
    ps.processPendingActions(maxIterations);
  }

  function withdrawAsset(address asset, address destination, uint amount) external onlyGovernance {
    IERC20 token = IERC20(asset);
    uint balance = token.balanceOf(address(this));
    uint transferAmount = amount > balance ? balance : amount;
    token.safeTransfer(destination, transferAmount);
  }

  function _sendPayoutAndPushBurn(
    address productId,
    address payable coverOwner,
    uint coveredTokenAmount,
    address coverAsset,
    uint payoutAmount
  ) internal {

    address _coveredToken = coveredToken[productId];

     
    IERC20(_coveredToken).safeTransferFrom(msg.sender, address(this), coveredTokenAmount);

    Pool p1 = pool();

     
    {
      address payable payoutAddress = memberRoles().getClaimPayoutAddress(coverOwner);
      bool success = p1.sendClaimPayout(coverAsset, payoutAddress, payoutAmount);
      require(success, "Incidents: Payout failed");
    }

    {
       
      uint decimalPrecision = 1e18;
      uint assetPerNxm = p1.getTokenPrice(coverAsset);
      uint maxBurnAmount = payoutAmount.mul(decimalPrecision).div(assetPerNxm);
      uint burnAmount = maxBurnAmount.mul(BURN_RATIO).div(BASIS_PRECISION);

      accumulatedBurn[productId] = accumulatedBurn[productId].add(burnAmount);
    }
  }

  function claimsData() internal view returns (ClaimsData) {
    return ClaimsData(internalContracts[uint(ID.CD)]);
  }

  function claimsReward() internal view returns (ClaimsReward) {
    return ClaimsReward(internalContracts[uint(ID.CR)]);
  }

  function quotationData() internal view returns (QuotationData) {
    return QuotationData(internalContracts[uint(ID.QD)]);
  }

  function tokenController() internal view returns (TokenController) {
    return TokenController(internalContracts[uint(ID.TC)]);
  }

  function memberRoles() internal view returns (MemberRoles) {
    return MemberRoles(internalContracts[uint(ID.MR)]);
  }

  function pool() internal view returns (Pool) {
    return Pool(internalContracts[uint(ID.P1)]);
  }

  function pooledStaking() internal view returns (IPooledStaking) {
    return IPooledStaking(internalContracts[uint(ID.PS)]);
  }

  function mcr() internal view returns (MCR) {
    return MCR(internalContracts[uint(ID.MC)]);
  }

  function updateUintParameters(bytes8 code, uint value) external onlyGovernance {

    if (code == "BURNRATE") {
      require(value <= BASIS_PRECISION, "Incidents: Burn ratio cannot exceed 10000");
      BURN_RATIO = value;
      return;
    }

    if (code == "DEDUCTIB") {
      require(value <= BASIS_PRECISION, "Incidents: Deductible ratio cannot exceed 10000");
      DEDUCTIBLE_RATIO = value;
      return;
    }

    revert("Incidents: Invalid parameter");
  }

  function changeDependentContractAddress() external {
    INXMMaster master = INXMMaster(master);
    internalContracts[uint(ID.CD)] = master.getLatestAddress("CD");
    internalContracts[uint(ID.CR)] = master.getLatestAddress("CR");
    internalContracts[uint(ID.QD)] = master.getLatestAddress("QD");
    internalContracts[uint(ID.TC)] = master.getLatestAddress("TC");
    internalContracts[uint(ID.MR)] = master.getLatestAddress("MR");
    internalContracts[uint(ID.P1)] = master.getLatestAddress("P1");
    internalContracts[uint(ID.PS)] = master.getLatestAddress("PS");
    internalContracts[uint(ID.MC)] = master.getLatestAddress("MC");
  }

}

 
  mapping(address => Stake[]) public stakerStakedContracts;

   
  mapping(address => Staker[]) public stakedContractStakers;

   
  mapping(address => mapping(uint => StakeCommission)) public stakedContractStakeCommission;

  mapping(address => uint) public lastCompletedStakeCommission;

   
  mapping(address => uint) public stakedContractCurrentCommissionIndex;

   
  mapping(address => uint) public stakedContractCurrentBurnIndex;

   
  mapping(uint => CoverNote) public depositedCN;

  mapping(address => uint) internal isBookedTokens;

  event Commission(
    address indexed stakedContractAddress,
    address indexed stakerAddress,
    uint indexed scIndex,
    uint commissionAmount
  );

  constructor(address payable _walletAdd) public {
    walletAddress = _walletAdd;
    bookTime = 12 hours;
    joiningFee = 2000000000000000;  
    lockTokenTimeAfterCoverExp = 35 days;
    scValidDays = 250;
    lockCADays = 7 days;
    lockMVDays = 2 days;
    stakerCommissionPer = 20;
    stakerMaxCommissionPer = 50;
    tokenExponent = 4;
    priceStep = 1000;
  }

   
  function changeWalletAddress(address payable _address) external onlyInternal {
    walletAddress = _address;
  }

   
  function getUintParameters(bytes8 code) external view returns (bytes8 codeVal, uint val) {
    codeVal = code;
    if (code == "TOKEXP") {

      val = tokenExponent;

    } else if (code == "TOKSTEP") {

      val = priceStep;

    } else if (code == "RALOCKT") {

      val = scValidDays;

    } else if (code == "RACOMM") {

      val = stakerCommissionPer;

    } else if (code == "RAMAXC") {

      val = stakerMaxCommissionPer;

    } else if (code == "CABOOKT") {

      val = bookTime / (1 hours);

    } else if (code == "CALOCKT") {

      val = lockCADays / (1 days);

    } else if (code == "MVLOCKT") {

      val = lockMVDays / (1 days);

    } else if (code == "QUOLOCKT") {

      val = lockTokenTimeAfterCoverExp / (1 days);

    } else if (code == "JOINFEE") {

      val = joiningFee;

    }
  }

   
  function changeDependentContractAddress() public { 
  }

   
  function getStakerStakedContractByIndex(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (address stakedContractAddress)
  {
    stakedContractAddress = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractAddress;
  }

   
  function getStakerStakedBurnedByIndex(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (uint burnedAmount)
  {
    burnedAmount = stakerStakedContracts[
    _stakerAddress][_stakerIndex].burnedAmount;
  }

   
  function getStakerStakedUnlockableBeforeLastBurnByIndex(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (uint unlockable)
  {
    unlockable = stakerStakedContracts[
    _stakerAddress][_stakerIndex].unLockableBeforeLastBurn;
  }

   
  function getStakerStakedContractIndex(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (uint scIndex)
  {
    scIndex = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractIndex;
  }

   
  function getStakedContractStakerIndex(
    address _stakedContractAddress,
    uint _stakedContractIndex
  )
  public
  view
  returns (uint sIndex)
  {
    sIndex = stakedContractStakers[
    _stakedContractAddress][_stakedContractIndex].stakerIndex;
  }

   
  function getStakerInitialStakedAmountOnContract(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (uint amount)
  {
    amount = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakeAmount;
  }

   
  function getStakerStakedContractLength(
    address _stakerAddress
  )
  public
  view
  returns (uint length)
  {
    length = stakerStakedContracts[_stakerAddress].length;
  }

   
  function getStakerUnlockedStakedTokens(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (uint amount)
  {
    amount = stakerStakedContracts[
    _stakerAddress][_stakerIndex].unlockedAmount;
  }

   
  function pushUnlockedStakedTokens(
    address _stakerAddress,
    uint _stakerIndex,
    uint _amount
  )
  public
  onlyInternal
  {
    stakerStakedContracts[_stakerAddress][
    _stakerIndex].unlockedAmount = stakerStakedContracts[_stakerAddress][
    _stakerIndex].unlockedAmount.add(_amount);
  }

   
  function pushBurnedTokens(
    address _stakerAddress,
    uint _stakerIndex,
    uint _amount
  )
  public
  onlyInternal
  {
    stakerStakedContracts[_stakerAddress][
    _stakerIndex].burnedAmount = stakerStakedContracts[_stakerAddress][
    _stakerIndex].burnedAmount.add(_amount);
  }

   
  function pushUnlockableBeforeLastBurnTokens(
    address _stakerAddress,
    uint _stakerIndex,
    uint _amount
  )
  public
  onlyInternal
  {
    stakerStakedContracts[_stakerAddress][
    _stakerIndex].unLockableBeforeLastBurn = stakerStakedContracts[_stakerAddress][
    _stakerIndex].unLockableBeforeLastBurn.add(_amount);
  }

   
  function setUnlockableBeforeLastBurnTokens(
    address _stakerAddress,
    uint _stakerIndex,
    uint _amount
  )
  public
  onlyInternal
  {
    stakerStakedContracts[_stakerAddress][
    _stakerIndex].unLockableBeforeLastBurn = _amount;
  }

   
  function pushEarnedStakeCommissions(
    address _stakerAddress,
    address _stakedContractAddress,
    uint _stakedContractIndex,
    uint _commissionAmount
  )
  public
  onlyInternal
  {
    stakedContractStakeCommission[_stakedContractAddress][_stakedContractIndex].
    commissionEarned = stakedContractStakeCommission[_stakedContractAddress][
    _stakedContractIndex].commissionEarned.add(_commissionAmount);

    emit Commission(
      _stakerAddress,
      _stakedContractAddress,
      _stakedContractIndex,
      _commissionAmount
    );
  }

   
  function pushRedeemedStakeCommissions(
    address _stakerAddress,
    uint _stakerIndex,
    uint _amount
  )
  public
  onlyInternal
  {
    uint stakedContractIndex = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractIndex;
    address stakedContractAddress = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractAddress;
    stakedContractStakeCommission[stakedContractAddress][stakedContractIndex].
    commissionRedeemed = stakedContractStakeCommission[
    stakedContractAddress][stakedContractIndex].commissionRedeemed.add(_amount);
  }

   
  function getStakerEarnedStakeCommission(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (uint)
  {
    return _getStakerEarnedStakeCommission(_stakerAddress, _stakerIndex);
  }

   
  function getStakerRedeemedStakeCommission(
    address _stakerAddress,
    uint _stakerIndex
  )
  public
  view
  returns (uint)
  {
    return _getStakerRedeemedStakeCommission(_stakerAddress, _stakerIndex);
  }

   
  function getStakerTotalEarnedStakeCommission(
    address _stakerAddress
  )
  public
  view
  returns (uint totalCommissionEarned)
  {
    totalCommissionEarned = 0;
    for (uint i = 0; i < stakerStakedContracts[_stakerAddress].length; i++) {
      totalCommissionEarned = totalCommissionEarned.
      add(_getStakerEarnedStakeCommission(_stakerAddress, i));
    }
  }

   
  function getStakerTotalReedmedStakeCommission(
    address _stakerAddress
  )
  public
  view
  returns (uint totalCommissionRedeemed)
  {
    totalCommissionRedeemed = 0;
    for (uint i = 0; i < stakerStakedContracts[_stakerAddress].length; i++) {
      totalCommissionRedeemed = totalCommissionRedeemed.add(
        _getStakerRedeemedStakeCommission(_stakerAddress, i));
    }
  }

   
  function setDepositCN(uint coverId, bool flag) public onlyInternal {

    if (flag == true) {
      require(!depositedCN[coverId].isDeposited, "Cover note already deposited");
    }

    depositedCN[coverId].isDeposited = flag;
  }

   
  function setDepositCNAmount(uint coverId, uint amount) public onlyInternal {

    depositedCN[coverId].amount = amount;
  }

   
  function getStakedContractStakerByIndex(
    address _stakedContractAddress,
    uint _stakedContractIndex
  )
  public
  view
  returns (address stakerAddress)
  {
    stakerAddress = stakedContractStakers[
    _stakedContractAddress][_stakedContractIndex].stakerAddress;
  }

   
  function getStakedContractStakersLength(
    address _stakedContractAddress
  )
  public
  view
  returns (uint length)
  {
    length = stakedContractStakers[_stakedContractAddress].length;
  }

   
  function addStake(
    address _stakerAddress,
    address _stakedContractAddress,
    uint _amount
  )
  public
  onlyInternal
  returns (uint scIndex)
  {
    scIndex = (stakedContractStakers[_stakedContractAddress].push(
      Staker(_stakerAddress, stakerStakedContracts[_stakerAddress].length))).sub(1);
    stakerStakedContracts[_stakerAddress].push(
      Stake(_stakedContractAddress, scIndex, now, _amount, 0, 0, 0));
  }

   
  function bookCATokens(address _of) public onlyInternal {
    require(!isCATokensBooked(_of), "Tokens already booked");
    isBookedTokens[_of] = now.add(bookTime);
  }

   
  function isCATokensBooked(address _of) public view returns (bool res) {
    if (now < isBookedTokens[_of])
      res = true;
  }

   
  function setStakedContractCurrentCommissionIndex(
    address _stakedContractAddress,
    uint _index
  )
  public
  onlyInternal
  {
    stakedContractCurrentCommissionIndex[_stakedContractAddress] = _index;
  }

   
  function setLastCompletedStakeCommissionIndex(
    address _stakerAddress,
    uint _index
  )
  public
  onlyInternal
  {
    lastCompletedStakeCommission[_stakerAddress] = _index;
  }

   
  function setStakedContractCurrentBurnIndex(
    address _stakedContractAddress,
    uint _index
  )
  public
  onlyInternal
  {
    stakedContractCurrentBurnIndex[_stakedContractAddress] = _index;
  }

   
  function updateUintParameters(bytes8 code, uint val) public {
    require(ms.checkIsAuthToGoverned(msg.sender));
    if (code == "TOKEXP") {

      _setTokenExponent(val);

    } else if (code == "TOKSTEP") {

      _setPriceStep(val);

    } else if (code == "RALOCKT") {

      _changeSCValidDays(val);

    } else if (code == "RACOMM") {

      _setStakerCommissionPer(val);

    } else if (code == "RAMAXC") {

      _setStakerMaxCommissionPer(val);

    } else if (code == "CABOOKT") {

      _changeBookTime(val * 1 hours);

    } else if (code == "CALOCKT") {

      _changelockCADays(val * 1 days);

    } else if (code == "MVLOCKT") {

      _changelockMVDays(val * 1 days);

    } else if (code == "QUOLOCKT") {

      _setLockTokenTimeAfterCoverExp(val * 1 days);

    } else if (code == "JOINFEE") {

      _setJoiningFee(val);

    } else {
      revert("Invalid param code");
    }
  }

   
  function _getStakerEarnedStakeCommission(
    address _stakerAddress,
    uint _stakerIndex
  )
  internal
  view
  returns (uint amount)
  {
    uint _stakedContractIndex;
    address _stakedContractAddress;
    _stakedContractAddress = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractAddress;
    _stakedContractIndex = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractIndex;
    amount = stakedContractStakeCommission[
    _stakedContractAddress][_stakedContractIndex].commissionEarned;
  }

   
  function _getStakerRedeemedStakeCommission(
    address _stakerAddress,
    uint _stakerIndex
  )
  internal
  view
  returns (uint amount)
  {
    uint _stakedContractIndex;
    address _stakedContractAddress;
    _stakedContractAddress = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractAddress;
    _stakedContractIndex = stakerStakedContracts[
    _stakerAddress][_stakerIndex].stakedContractIndex;
    amount = stakedContractStakeCommission[
    _stakedContractAddress][_stakedContractIndex].commissionRedeemed;
  }

   
  function _setStakerCommissionPer(uint _val) internal {
    stakerCommissionPer = _val;
  }

   
  function _setStakerMaxCommissionPer(uint _val) internal {
    stakerMaxCommissionPer = _val;
  }

   
  function _setTokenExponent(uint _val) internal {
    tokenExponent = _val;
  }

   
  function _setPriceStep(uint _val) internal {
    priceStep = _val;
  }

   
  function _changeSCValidDays(uint _days) internal {
    scValidDays = _days;
  }

   
  function _changeBookTime(uint _time) internal {
    bookTime = _time;
  }

   
  function _changelockCADays(uint _val) internal {
    lockCADays = _val;
  }

   
  function _changelockMVDays(uint _val) internal {
    lockMVDays = _val;
  }

   
  function _setLockTokenTimeAfterCoverExp(uint time) internal {
    lockTokenTimeAfterCoverExp = time;
  }

   
  function _setJoiningFee(uint _amount) internal {
    joiningFee = _amount;
  }
}

 
  function setKycAuthAddress(address _add) external onlyInternal {
    kycAuthAddress = _add;
  }

  
  function changeAuthQuoteEngine(address _add) external onlyInternal {
    authQuoteEngine = _add;
  }

   
  function getUintParameters(bytes8 code) external view returns (bytes8 codeVal, uint val) {
    codeVal = code;

    if (code == "STLP") {
      val = stlp;

    } else if (code == "STL") {

      val = stl;

    } else if (code == "PM") {

      val = pm;

    } else if (code == "QUOMIND") {

      val = minDays;

    } else if (code == "QUOTOK") {

      val = tokensRetained;

    }

  }

  
  
  
  
  
  function getProductDetails()
  external
  view
  returns (
    uint _minDays,
    uint _pm,
    uint _stl,
    uint _stlp
  )
  {

    _minDays = minDays;
    _pm = pm;
    _stl = stl;
    _stlp = stlp;
  }

  
  function getCoverLength() external view returns (uint len) {
    return (allCovers.length);
  }

  
  function getAuthQuoteEngine() external view returns (address _add) {
    _add = authQuoteEngine;
  }

  
  function getTotalSumAssured(bytes4 _curr) external view returns (uint amount) {
    amount = currencyCSA[_curr];
  }

  
  
  
  function getAllCoversOfUser(address _add) external view returns (uint[] memory allCover) {
    return (userCover[_add]);
  }

  
  function getUserCoverLength(address _add) external view returns (uint len) {
    len = userCover[_add].length;
  }

  
  function getCoverStatusNo(uint _cid) external view returns (uint8) {
    return coverStatus[_cid];
  }

  
  function getCoverPeriod(uint _cid) external view returns (uint32 cp) {
    cp = allCovers[_cid].coverPeriod;
  }

  
  function getCoverSumAssured(uint _cid) external view returns (uint sa) {
    sa = allCovers[_cid].sumAssured;
  }

  
  function getCurrencyOfCover(uint _cid) external view returns (bytes4 curr) {
    curr = allCovers[_cid].currencyCode;
  }

  
  function getValidityOfCover(uint _cid) external view returns (uint date) {
    date = allCovers[_cid].validUntil;
  }

  
  function getscAddressOfCover(uint _cid) external view returns (uint, address) {
    return (_cid, allCovers[_cid].scAddress);
  }

  
  function getCoverMemberAddress(uint _cid) external view returns (address payable _add) {
    _add = allCovers[_cid].memberAddress;
  }

  
  function getCoverPremiumNXM(uint _cid) external view returns (uint _premiumNXM) {
    _premiumNXM = allCovers[_cid].premiumNXM;
  }

  
  
  
  
  
  
  
  function getCoverDetailsByCoverID1(
    uint _cid
  )
  external
  view
  returns (
    uint cid,
    address _memberAddress,
    address _scAddress,
    bytes4 _currencyCode,
    uint _sumAssured,
    uint premiumNXM
  )
  {
    return (
    _cid,
    allCovers[_cid].memberAddress,
    allCovers[_cid].scAddress,
    allCovers[_cid].currencyCode,
    allCovers[_cid].sumAssured,
    allCovers[_cid].premiumNXM
    );
  }

  
  
  
  
  
  
  function getCoverDetailsByCoverID2(
    uint _cid
  )
  external
  view
  returns (
    uint cid,
    uint8 status,
    uint sumAssured,
    uint16 coverPeriod,
    uint validUntil
  )
  {

    return (
    _cid,
    coverStatus[_cid],
    allCovers[_cid].sumAssured,
    allCovers[_cid].coverPeriod,
    allCovers[_cid].validUntil
    );
  }

  
  
  
  
  
  function getHoldedCoverDetailsByID1(
    uint _hcid
  )
  external
  view
  returns (
    uint hcid,
    address scAddress,
    bytes4 coverCurr,
    uint16 coverPeriod
  )
  {
    return (
    _hcid,
    allCoverHolded[_hcid].scAddress,
    allCoverHolded[_hcid].coverCurr,
    allCoverHolded[_hcid].coverPeriod
    );
  }

  
  function getUserHoldedCoverLength(address _add) external view returns (uint) {
    return userHoldedCover[_add].length;
  }

  
  function getUserHoldedCoverByIndex(address _add, uint index) external view returns (uint) {
    return userHoldedCover[_add][index];
  }

  
  
  
  
  function getHoldedCoverDetailsByID2(
    uint _hcid
  )
  external
  view
  returns (
    uint hcid,
    address payable memberAddress,
    uint[] memory coverDetails
  )
  {
    return (
    _hcid,
    allCoverHolded[_hcid].userAddress,
    allCoverHolded[_hcid].coverDetails
    );
  }

  
  function getTotalSumAssuredSC(address _add, bytes4 _curr) external view returns (uint amount) {
    amount = currencyCSAOfSCAdd[_add][_curr];
  }

   
  function changeDependentContractAddress() public {}

  
  
  
  function changeCoverStatusNo(uint _cid, uint8 _stat) public onlyInternal {
    coverStatus[_cid] = _stat;
    emit CoverStatusEvent(_cid, _stat);
  }

   
  function updateUintParameters(bytes8 code, uint val) public {

    require(ms.checkIsAuthToGoverned(msg.sender));
    if (code == "STLP") {
      _changeSTLP(val);

    } else if (code == "STL") {

      _changeSTL(val);

    } else if (code == "PM") {

      _changePM(val);

    } else if (code == "QUOMIND") {

      _changeMinDays(val);

    } else if (code == "QUOTOK") {

      _setTokensRetained(val);

    } else {

      revert("Invalid param code");
    }

  }

  
  function _changePM(uint _pm) internal {
    pm = _pm;
  }

  
  function _changeSTLP(uint _stlp) internal {
    stlp = _stlp;
  }

  
  function _changeSTL(uint _stl) internal {
    stl = _stl;
  }

  
  function _changeMinDays(uint _days) internal {
    minDays = _days;
  }

   
  function _setTokensRetained(uint val) internal {
    tokensRetained = val;
  }
}

pragma solidity ^0.5.0;


 
library OZSafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);  
    uint256 c = a / b;
     

    return c;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

   
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

pragma solidity ^0.5.0;


interface IPooledStaking {

  function accumulateReward(address contractAddress, uint amount) external;

  function pushBurn(address contractAddress, uint amount) external;

  function hasPendingActions() external view returns (bool);

  function processPendingActions(uint maxIterations) external returns (bool finished);

  function contractStake(address contractAddress) external view returns (uint);

  function stakerReward(address staker) external view returns (uint);

  function stakerDeposit(address staker) external view returns (uint);

  function stakerContractStake(address staker, address contractAddress) external view returns (uint);

  function withdraw(uint amount) external;

  function stakerMaxWithdrawable(address stakerAddress) external view returns (uint);

  function withdrawReward(address stakerAddress) external;
}

 
  function setpendingClaimStart(uint _start) external onlyInternal {
    require(pendingClaimStart <= _start);
    pendingClaimStart = _start;
  }

   
  function setRewardDistributedIndexCA(address _voter, uint caIndex) external onlyInternal {
    voterVoteRewardReceived[_voter].lastCAvoteIndex = caIndex;

  }

   
  function setUserClaimVotePausedOn(address user) external {
    require(ms.checkIsAuthToGoverned(msg.sender));
    userClaimVotePausedOn[user] = now;
  }

   
  function setRewardDistributedIndexMV(address _voter, uint mvIndex) external onlyInternal {

    voterVoteRewardReceived[_voter].lastMVvoteIndex = mvIndex;
  }

   
  function setClaimRewardDetail(
    uint claimid,
    uint percCA,
    uint percMV,
    uint tokens
  )
  external
  onlyInternal
  {
    claimRewardDetail[claimid].percCA = percCA;
    claimRewardDetail[claimid].percMV = percMV;
    claimRewardDetail[claimid].tokenToBeDist = tokens;
  }

   
  function setRewardClaimed(uint _voteid, bool claimed) external onlyInternal {
    allvotes[_voteid].rewardClaimed = claimed;
  }

   
  function changeFinalVerdict(uint _claimId, int8 _verdict) external onlyInternal {
    claimVote[_claimId] = _verdict;
  }

   
  function addClaim(
    uint _claimId,
    uint _coverId,
    address _from,
    uint _nowtime
  )
  external
  onlyInternal
  {
    allClaims.push(Claim(_coverId, _nowtime));
    allClaimsByAddress[_from].push(_claimId);
  }

   
  function addVote(
    address _voter,
    uint _tokens,
    uint claimId,
    int8 _verdict
  )
  external
  onlyInternal
  {
    allvotes.push(Vote(_voter, _tokens, claimId, _verdict, false));
  }

   
  function addClaimVoteCA(uint _claimId, uint _voteid) external onlyInternal {
    claimVoteCA[_claimId].push(_voteid);
  }

   
  function setUserClaimVoteCA(
    address _from,
    uint _claimId,
    uint _voteid
  )
  external
  onlyInternal
  {
    userClaimVoteCA[_from][_claimId] = _voteid;
    voteAddressCA[_from].push(_voteid);
  }

   
  function setClaimTokensCA(uint _claimId, int8 _vote, uint _tokens) external onlyInternal {
    if (_vote == 1)
      claimTokensCA[_claimId].accept = claimTokensCA[_claimId].accept.add(_tokens);
    if (_vote == - 1)
      claimTokensCA[_claimId].deny = claimTokensCA[_claimId].deny.add(_tokens);
  }

   
  function setClaimTokensMV(uint _claimId, int8 _vote, uint _tokens) external onlyInternal {
    if (_vote == 1)
      claimTokensMV[_claimId].accept = claimTokensMV[_claimId].accept.add(_tokens);
    if (_vote == - 1)
      claimTokensMV[_claimId].deny = claimTokensMV[_claimId].deny.add(_tokens);
  }

   
  function addClaimVotemember(uint _claimId, uint _voteid) external onlyInternal {
    claimVoteMember[_claimId].push(_voteid);
  }

   
  function setUserClaimVoteMember(
    address _from,
    uint _claimId,
    uint _voteid
  )
  external
  onlyInternal
  {
    userClaimVoteMember[_from][_claimId] = _voteid;
    voteAddressMember[_from].push(_voteid);

  }

   
  function updateState12Count(uint _claimId, uint _cnt) external onlyInternal {
    claimState12Count[_claimId] = claimState12Count[_claimId].add(_cnt);
  }

   
  function setClaimStatus(uint _claimId, uint _stat) external onlyInternal {
    claimsStatus[_claimId] = _stat;
  }

   
  function setClaimdateUpd(uint _claimId, uint _dateUpd) external onlyInternal {
    allClaims[_claimId].dateUpd = _dateUpd;
  }

   
  function setClaimAtEmergencyPause(
    uint _coverId,
    uint _dateUpd,
    bool _submit
  )
  external
  onlyInternal
  {
    claimPause.push(ClaimsPause(_coverId, _dateUpd, _submit));
  }

   
  function setClaimSubmittedAtEPTrue(uint _index, bool _submit) external onlyInternal {
    claimPause[_index].submit = _submit;
  }

   
  function setFirstClaimIndexToSubmitAfterEP(
    uint _firstClaimIndexToSubmit
  )
  external
  onlyInternal
  {
    claimPauseLastsubmit = _firstClaimIndexToSubmit;
  }

   
  function setPendingClaimDetails(
    uint _claimId,
    uint _pendingTime,
    bool _voting
  )
  external
  onlyInternal
  {
    claimPauseVotingEP.push(ClaimPauseVoting(_claimId, _pendingTime, _voting));
  }

   
  function setPendingClaimVoteStatus(uint _claimId, bool _vote) external onlyInternal {
    claimPauseVotingEP[_claimId].voting = _vote;
  }

   
  function setFirstClaimIndexToStartVotingAfterEP(
    uint _claimStartVotingFirstIndex
  )
  external
  onlyInternal
  {
    claimStartVotingFirstIndex = _claimStartVotingFirstIndex;
  }

   
  function callVoteEvent(
    address _userAddress,
    uint _claimId,
    bytes4 _typeOf,
    uint _tokens,
    uint _submitDate,
    int8 _verdict
  )
  external
  onlyInternal
  {
    emit VoteCast(
      _userAddress,
      _claimId,
      _typeOf,
      _tokens,
      _submitDate,
      _verdict
    );
  }

   
  function callClaimEvent(
    uint _coverId,
    address _userAddress,
    uint _claimId,
    uint _datesubmit
  )
  external
  onlyInternal
  {
    emit ClaimRaise(_coverId, _userAddress, _claimId, _datesubmit);
  }

   
  function getUintParameters(bytes8 code) external view returns (bytes8 codeVal, uint val) {
    codeVal = code;
    if (code == "CAMAXVT") {
      val = maxVotingTime / (1 hours);

    } else if (code == "CAMINVT") {

      val = minVotingTime / (1 hours);

    } else if (code == "CAPRETRY") {

      val = payoutRetryTime / (1 hours);

    } else if (code == "CADEPT") {

      val = claimDepositTime / (1 days);

    } else if (code == "CAREWPER") {

      val = claimRewardPerc;

    } else if (code == "CAMINTH") {

      val = minVoteThreshold;

    } else if (code == "CAMAXTH") {

      val = maxVoteThreshold;

    } else if (code == "CACONPER") {

      val = majorityConsensus;

    } else if (code == "CAPAUSET") {
      val = pauseDaysCA / (1 days);
    }

  }

   
  function getClaimOfEmergencyPauseByIndex(
    uint _index
  )
  external
  view
  returns (
    uint coverId,
    uint dateUpd,
    bool submit
  )
  {
    coverId = claimPause[_index].coverid;
    dateUpd = claimPause[_index].dateUpd;
    submit = claimPause[_index].submit;
  }

   
  function getAllClaimsByIndex(
    uint _claimId
  )
  external
  view
  returns (
    uint coverId,
    int8 vote,
    uint status,
    uint dateUpd,
    uint state12Count
  )
  {
    return (
    allClaims[_claimId].coverId,
    claimVote[_claimId],
    claimsStatus[_claimId],
    allClaims[_claimId].dateUpd,
    claimState12Count[_claimId]
    );
  }

   
  function getUserClaimVoteCA(
    address _add,
    uint _claimId
  )
  external
  view
  returns (uint idVote)
  {
    return userClaimVoteCA[_add][_claimId];
  }

   
  function getUserClaimVoteMember(
    address _add,
    uint _claimId
  )
  external
  view
  returns (uint idVote)
  {
    return userClaimVoteMember[_add][_claimId];
  }

   
  function getAllVoteLength() external view returns (uint voteCount) {
    return allvotes.length.sub(1);  
  }

   
  function getClaimStatusNumber(uint _claimId) external view returns (uint claimId, uint statno) {
    return (_claimId, claimsStatus[_claimId]);
  }

   
  function getRewardStatus(uint statusNumber) external view returns (uint percCA, uint percMV) {
    return (rewardStatus[statusNumber].percCA, rewardStatus[statusNumber].percMV);
  }

   
  function getClaimState12Count(uint _claimId) external view returns (uint num) {
    num = claimState12Count[_claimId];
  }

   
  function getClaimDateUpd(uint _claimId) external view returns (uint dateupd) {
    dateupd = allClaims[_claimId].dateUpd;
  }

   
  function getAllClaimsByAddress(address _member) external view returns (uint[] memory claimarr) {
    return allClaimsByAddress[_member];
  }

   
  function getClaimsTokenCA(
    uint _claimId
  )
  external
  view
  returns (
    uint claimId,
    uint accept,
    uint deny
  )
  {
    return (
    _claimId,
    claimTokensCA[_claimId].accept,
    claimTokensCA[_claimId].deny
    );
  }

   
  function getClaimsTokenMV(
    uint _claimId
  )
  external
  view
  returns (
    uint claimId,
    uint accept,
    uint deny
  )
  {
    return (
    _claimId,
    claimTokensMV[_claimId].accept,
    claimTokensMV[_claimId].deny
    );
  }

   
  function getCaClaimVotesToken(uint _claimId) external view returns (uint claimId, uint cnt) {
    claimId = _claimId;
    cnt = 0;
    for (uint i = 0; i < claimVoteCA[_claimId].length; i++) {
      cnt = cnt.add(allvotes[claimVoteCA[_claimId][i]].tokens);
    }
  }

   
  function getMemberClaimVotesToken(
    uint _claimId
  )
  external
  view
  returns (uint claimId, uint cnt)
  {
    claimId = _claimId;
    cnt = 0;
    for (uint i = 0; i < claimVoteMember[_claimId].length; i++) {
      cnt = cnt.add(allvotes[claimVoteMember[_claimId][i]].tokens);
    }
  }

   
  function getVoteDetails(uint _voteid)
  external view
  returns (
    uint tokens,
    uint claimId,
    int8 verdict,
    bool rewardClaimed
  )
  {
    return (
    allvotes[_voteid].tokens,
    allvotes[_voteid].claimId,
    allvotes[_voteid].verdict,
    allvotes[_voteid].rewardClaimed
    );
  }

   
  function getVoterVote(uint _voteid) external view returns (address voter) {
    return allvotes[_voteid].voter;
  }

   
  function getClaim(
    uint _claimId
  )
  external
  view
  returns (
    uint claimId,
    uint coverId,
    int8 vote,
    uint status,
    uint dateUpd,
    uint state12Count
  )
  {
    return (
    _claimId,
    allClaims[_claimId].coverId,
    claimVote[_claimId],
    claimsStatus[_claimId],
    allClaims[_claimId].dateUpd,
    claimState12Count[_claimId]
    );
  }

   
  function getClaimVoteLength(
    uint _claimId,
    uint8 _ca
  )
  external
  view
  returns (uint claimId, uint len)
  {
    claimId = _claimId;
    if (_ca == 1)
      len = claimVoteCA[_claimId].length;
    else
      len = claimVoteMember[_claimId].length;
  }

   
  function getVoteVerdict(
    uint _claimId,
    uint _index,
    uint8 _ca
  )
  external
  view
  returns (int8 ver)
  {
    if (_ca == 1)
      ver = allvotes[claimVoteCA[_claimId][_index]].verdict;
    else
      ver = allvotes[claimVoteMember[_claimId][_index]].verdict;
  }

   
  function getVoteToken(
    uint _claimId,
    uint _index,
    uint8 _ca
  )
  external
  view
  returns (uint tok)
  {
    if (_ca == 1)
      tok = allvotes[claimVoteCA[_claimId][_index]].tokens;
    else
      tok = allvotes[claimVoteMember[_claimId][_index]].tokens;
  }

   
  function getVoteVoter(
    uint _claimId,
    uint _index,
    uint8 _ca
  )
  external
  view
  returns (address voter)
  {
    if (_ca == 1)
      voter = allvotes[claimVoteCA[_claimId][_index]].voter;
    else
      voter = allvotes[claimVoteMember[_claimId][_index]].voter;
  }

   
  function getUserClaimCount(address _add) external view returns (uint len) {
    len = allClaimsByAddress[_add].length;
  }

   
  function getClaimLength() external view returns (uint len) {
    len = allClaims.length.sub(pendingClaimStart);
  }

   
  function actualClaimLength() external view returns (uint len) {
    len = allClaims.length;
  }

   
  function getClaimFromNewStart(
    uint _index,
    address _add
  )
  external
  view
  returns (
    uint coverid,
    uint claimId,
    int8 voteCA,
    int8 voteMV,
    uint statusnumber
  )
  {
    uint i = pendingClaimStart.add(_index);
    coverid = allClaims[i].coverId;
    claimId = i;
    if (userClaimVoteCA[_add][i] > 0)
      voteCA = allvotes[userClaimVoteCA[_add][i]].verdict;
    else
      voteCA = 0;

    if (userClaimVoteMember[_add][i] > 0)
      voteMV = allvotes[userClaimVoteMember[_add][i]].verdict;
    else
      voteMV = 0;

    statusnumber = claimsStatus[i];
  }

   
  function getUserClaimByIndex(
    uint _index,
    address _add
  )
  external
  view
  returns (
    uint status,
    uint coverid,
    uint claimId
  )
  {
    claimId = allClaimsByAddress[_add][_index];
    status = claimsStatus[claimId];
    coverid = allClaims[claimId].coverId;
  }

   
  function getAllVotesForClaim(
    uint _claimId
  )
  external
  view
  returns (
    uint claimId,
    uint[] memory ca,
    uint[] memory mv
  )
  {
    return (_claimId, claimVoteCA[_claimId], claimVoteMember[_claimId]);
  }

   
  function getTokensClaim(
    address _of,
    uint _claimId
  )
  external
  view
  returns (
    uint claimId,
    uint tokens
  )
  {
    return (_claimId, allvotes[userClaimVoteCA[_of][_claimId]].tokens);
  }

   
  function getRewardDistributedIndex(
    address _voter
  )
  external
  view
  returns (
    uint lastCAvoteIndex,
    uint lastMVvoteIndex
  )
  {
    return (
    voterVoteRewardReceived[_voter].lastCAvoteIndex,
    voterVoteRewardReceived[_voter].lastMVvoteIndex
    );
  }

   
  function getClaimRewardDetail(
    uint claimid
  )
  external
  view
  returns (
    uint percCA,
    uint percMV,
    uint tokens
  )
  {
    return (
    claimRewardDetail[claimid].percCA,
    claimRewardDetail[claimid].percMV,
    claimRewardDetail[claimid].tokenToBeDist
    );
  }

   
  function getClaimCoverId(uint _claimId) external view returns (uint claimId, uint coverid) {
    return (_claimId, allClaims[_claimId].coverId);
  }

   
  function getClaimVote(uint _claimId, int8 _verdict) external view returns (uint claimId, uint token) {
    claimId = _claimId;
    token = 0;
    for (uint i = 0; i < claimVoteCA[_claimId].length; i++) {
      if (allvotes[claimVoteCA[_claimId][i]].verdict == _verdict)
        token = token.add(allvotes[claimVoteCA[_claimId][i]].tokens);
    }
  }

   
  function getClaimMVote(uint _claimId, int8 _verdict) external view returns (uint claimId, uint token) {
    claimId = _claimId;
    token = 0;
    for (uint i = 0; i < claimVoteMember[_claimId].length; i++) {
      if (allvotes[claimVoteMember[_claimId][i]].verdict == _verdict)
        token = token.add(allvotes[claimVoteMember[_claimId][i]].tokens);
    }
  }

   
  function getVoteAddressCA(address _voter, uint index) external view returns (uint) {
    return voteAddressCA[_voter][index];
  }

   
  function getVoteAddressMember(address _voter, uint index) external view returns (uint) {
    return voteAddressMember[_voter][index];
  }

   
  function getVoteAddressCALength(address _voter) external view returns (uint) {
    return voteAddressCA[_voter].length;
  }

   
  function getVoteAddressMemberLength(address _voter) external view returns (uint) {
    return voteAddressMember[_voter].length;
  }

   
  function getFinalVerdict(uint _claimId) external view returns (int8 verdict) {
    return claimVote[_claimId];
  }

   
  function getLengthOfClaimSubmittedAtEP() external view returns (uint len) {
    len = claimPause.length;
  }

   
  function getFirstClaimIndexToSubmitAfterEP() external view returns (uint indexToSubmit) {
    indexToSubmit = claimPauseLastsubmit;
  }

   
  function getLengthOfClaimVotingPause() external view returns (uint len) {
    len = claimPauseVotingEP.length;
  }

   
  function getPendingClaimDetailsByIndex(
    uint _index
  )
  external
  view
  returns (
    uint claimId,
    uint pendingTime,
    bool voting
  )
  {
    claimId = claimPauseVotingEP[_index].claimid;
    pendingTime = claimPauseVotingEP[_index].pendingTime;
    voting = claimPauseVotingEP[_index].voting;
  }

   
  function getFirstClaimIndexToStartVotingAfterEP() external view returns (uint firstindex) {
    firstindex = claimStartVotingFirstIndex;
  }

   
  function updateUintParameters(bytes8 code, uint val) public {
    require(ms.checkIsAuthToGoverned(msg.sender));
    if (code == "CAMAXVT") {
      _setMaxVotingTime(val * 1 hours);

    } else if (code == "CAMINVT") {

      _setMinVotingTime(val * 1 hours);

    } else if (code == "CAPRETRY") {

      _setPayoutRetryTime(val * 1 hours);

    } else if (code == "CADEPT") {

      _setClaimDepositTime(val * 1 days);

    } else if (code == "CAREWPER") {

      _setClaimRewardPerc(val);

    } else if (code == "CAMINTH") {

      _setMinVoteThreshold(val);

    } else if (code == "CAMAXTH") {

      _setMaxVoteThreshold(val);

    } else if (code == "CACONPER") {

      _setMajorityConsensus(val);

    } else if (code == "CAPAUSET") {
      _setPauseDaysCA(val * 1 days);
    } else {

      revert("Invalid param code");
    }

  }

   
  function changeDependentContractAddress() public onlyInternal {}

   
  function _pushStatus(uint percCA, uint percMV) internal {
    rewardStatus.push(ClaimRewardStatus(percCA, percMV));
  }

   
  function _addRewardIncentive() internal {
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(100, 0);  
    _pushStatus(100, 0);  
    _pushStatus(0, 100);  
    _pushStatus(0, 100);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
    _pushStatus(0, 0);  
  }

   
  function _setMaxVotingTime(uint _time) internal {
    maxVotingTime = _time;
  }

   
  function _setMinVotingTime(uint _time) internal {
    minVotingTime = _time;
  }

   
  function _setMinVoteThreshold(uint val) internal {
    minVoteThreshold = val;
  }

   
  function _setMaxVoteThreshold(uint val) internal {
    maxVoteThreshold = val;
  }

   
  function _setMajorityConsensus(uint val) internal {
    majorityConsensus = val;
  }

   
  function _setPayoutRetryTime(uint _time) internal {
    payoutRetryTime = _time;
  }

   
  function _setClaimRewardPerc(uint _val) internal {

    claimRewardPerc = _val;
  }

   
  function _setClaimDepositTime(uint _time) internal {

    claimDepositTime = _time;
  }

   
  function _setPauseDaysCA(uint val) internal {
    pauseDaysCA = val;
  }
}

pragma solidity ^0.5.0;

interface LegacyMCR {
  function addMCRData(uint mcrP, uint mcrE, uint vF, bytes4[] calldata curr, uint[] calldata _threeDayAvg, uint64 onlyDate) external;
  function addLastMCRData(uint64 date) external;
  function changeDependentContractAddress() external;
  function getAllSumAssurance() external view returns (uint amount);
  function _calVtpAndMCRtp(uint poolBalance) external view returns (uint vtp, uint mcrtp);
  function calculateStepTokenPrice(bytes4 curr, uint mcrtp) external view returns (uint tokenPrice);
  function calculateTokenPrice(bytes4 curr) external view returns (uint tokenPrice);
  function calVtpAndMCRtp() external view returns (uint vtp, uint mcrtp);
  function calculateVtpAndMCRtp(uint poolBalance) external view returns (uint vtp, uint mcrtp);
  function getThresholdValues(uint vtp, uint vF, uint totalSA, uint minCap) external view returns (uint lowerThreshold, uint upperThreshold);
  function getMaxSellTokens() external view returns (uint maxTokens);
  function getUintParameters(bytes8 code) external view returns (bytes8 codeVal, uint val);
  function updateUintParameters(bytes8 code, uint val) external;

  function variableMincap() external view returns (uint);
  function dynamicMincapThresholdx100() external view returns (uint);
  function dynamicMincapIncrementx100() external view returns (uint);

  function getLastMCREther() external view returns (uint);
}

 

 
 
 
 

 
 
 
 

 
 

pragma solidity ^0.5.0;







contract Governance is IGovernance, Iupgradable {

  using SafeMath for uint;

  enum ProposalStatus {
    Draft,
    AwaitingSolution,
    VotingStarted,
    Accepted,
    Rejected,
    Majority_Not_Reached_But_Accepted,
    Denied
  }

  struct ProposalData {
    uint propStatus;
    uint finalVerdict;
    uint category;
    uint commonIncentive;
    uint dateUpd;
    address owner;
  }

  struct ProposalVote {
    address voter;
    uint proposalId;
    uint dateAdd;
  }

  struct VoteTally {
    mapping(uint => uint) memberVoteValue;
    mapping(uint => uint) abVoteValue;
    uint voters;
  }

  struct DelegateVote {
    address follower;
    address leader;
    uint lastUpd;
  }

  ProposalVote[] internal allVotes;
  DelegateVote[] public allDelegation;

  mapping(uint => ProposalData) internal allProposalData;
  mapping(uint => bytes[]) internal allProposalSolutions;
  mapping(address => uint[]) internal allVotesByMember;
  mapping(uint => mapping(address => bool)) public rewardClaimed;
  mapping(address => mapping(uint => uint)) public memberProposalVote;
  mapping(address => uint) public followerDelegation;
  mapping(address => uint) internal followerCount;
  mapping(address => uint[]) internal leaderDelegation;
  mapping(uint => VoteTally) public proposalVoteTally;
  mapping(address => bool) public isOpenForDelegation;
  mapping(address => uint) public lastRewardClaimed;

  bool internal constructorCheck;
  uint public tokenHoldingTime;
  uint internal roleIdAllowedToCatgorize;
  uint internal maxVoteWeigthPer;
  uint internal specialResolutionMajPerc;
  uint internal maxFollowers;
  uint internal totalProposals;
  uint internal maxDraftTime;

  MemberRoles internal memberRole;
  ProposalCategory internal proposalCategory;
  TokenController internal tokenInstance;

  mapping(uint => uint) public proposalActionStatus;
  mapping(uint => uint) internal proposalExecutionTime;
  mapping(uint => mapping(address => bool)) public proposalRejectedByAB;
  mapping(uint => uint) internal actionRejectedCount;

  bool internal actionParamsInitialised;
  uint internal actionWaitingTime;
  uint constant internal AB_MAJ_TO_REJECT_ACTION = 3;

  enum ActionStatus {
    Pending,
    Accepted,
    Rejected,
    Executed,
    NoAction
  }

   
  event ActionFailed (
    uint256 proposalId
  );

   
  event ActionRejected (
    uint256 indexed proposalId,
    address rejectedBy
  );

   
  modifier onlyProposalOwner(uint _proposalId) {
    require(msg.sender == allProposalData[_proposalId].owner, "Not allowed");
    _;
  }

   
  modifier voteNotStarted(uint _proposalId) {
    require(allProposalData[_proposalId].propStatus < uint(ProposalStatus.VotingStarted));
    _;
  }

   
  modifier isAllowed(uint _categoryId) {
    require(allowedToCreateProposal(_categoryId), "Not allowed");
    _;
  }

   
  modifier isAllowedToCategorize() {
    require(memberRole.checkRole(msg.sender, roleIdAllowedToCatgorize), "Not allowed");
    _;
  }

   
  modifier checkPendingRewards {
    require(getPendingReward(msg.sender) == 0, "Claim reward");
    _;
  }

   
  event ProposalCategorized(
    uint indexed proposalId,
    address indexed categorizedBy,
    uint categoryId
  );

   
  function removeDelegation(address _add) external onlyInternal {
    _unDelegate(_add);
  }

   
  function createProposal(
    string calldata _proposalTitle,
    string calldata _proposalSD,
    string calldata _proposalDescHash,
    uint _categoryId
  )
  external isAllowed(_categoryId)
  {
    require(ms.isMember(msg.sender), "Not Member");

    _createProposal(_proposalTitle, _proposalSD, _proposalDescHash, _categoryId);
  }

   
  function updateProposal(
    uint _proposalId,
    string calldata _proposalTitle,
    string calldata _proposalSD,
    string calldata _proposalDescHash
  )
  external onlyProposalOwner(_proposalId)
  {
    require(
      allProposalSolutions[_proposalId].length < 2,
      "Not allowed"
    );
    allProposalData[_proposalId].propStatus = uint(ProposalStatus.Draft);
    allProposalData[_proposalId].category = 0;
    allProposalData[_proposalId].commonIncentive = 0;
    emit Proposal(
      allProposalData[_proposalId].owner,
      _proposalId,
      now,
      _proposalTitle,
      _proposalSD,
      _proposalDescHash
    );
  }

   
  function categorizeProposal(
    uint _proposalId,
    uint _categoryId,
    uint _incentive
  )
  external
  voteNotStarted(_proposalId) isAllowedToCategorize
  {
    _categorizeProposal(_proposalId, _categoryId, _incentive);
  }

   
  function submitProposalWithSolution(
    uint _proposalId,
    string calldata _solutionHash,
    bytes calldata _action
  )
  external
  onlyProposalOwner(_proposalId)
  {

    require(allProposalData[_proposalId].propStatus == uint(ProposalStatus.AwaitingSolution));

    _proposalSubmission(_proposalId, _solutionHash, _action);
  }

   
  function createProposalwithSolution(
    string calldata _proposalTitle,
    string calldata _proposalSD,
    string calldata _proposalDescHash,
    uint _categoryId,
    string calldata _solutionHash,
    bytes calldata _action
  )
  external isAllowed(_categoryId)
  {


    uint proposalId = totalProposals;

    _createProposal(_proposalTitle, _proposalSD, _proposalDescHash, _categoryId);

    require(_categoryId > 0);

    _proposalSubmission(
      proposalId,
      _solutionHash,
      _action
    );
  }

   
  function submitVote(uint _proposalId, uint _solutionChosen) external {

    require(allProposalData[_proposalId].propStatus ==
      uint(Governance.ProposalStatus.VotingStarted), "Not allowed");

    require(_solutionChosen < allProposalSolutions[_proposalId].length);


    _submitVote(_proposalId, _solutionChosen);
  }

   
  function closeProposal(uint _proposalId) external {
    uint category = allProposalData[_proposalId].category;


    uint _memberRole;
    if (allProposalData[_proposalId].dateUpd.add(maxDraftTime) <= now &&
      allProposalData[_proposalId].propStatus < uint(ProposalStatus.VotingStarted)) {
      _updateProposalStatus(_proposalId, uint(ProposalStatus.Denied));
    } else {
      require(canCloseProposal(_proposalId) == 1);
      (, _memberRole,,,,,) = proposalCategory.category(allProposalData[_proposalId].category);
      if (_memberRole == uint(MemberRoles.Role.AdvisoryBoard)) {
        _closeAdvisoryBoardVote(_proposalId, category);
      } else {
        _closeMemberVote(_proposalId, category);
      }
    }

  }

   
  function claimReward(address _memberAddress, uint _maxRecords)
  external returns (uint pendingDAppReward)
  {

    uint voteId;
    address leader;
    uint lastUpd;

    require(msg.sender == ms.getLatestAddress("CR"));

    uint delegationId = followerDelegation[_memberAddress];
    DelegateVote memory delegationData = allDelegation[delegationId];
    if (delegationId > 0 && delegationData.leader != address(0)) {
      leader = delegationData.leader;
      lastUpd = delegationData.lastUpd;
    } else
      leader = _memberAddress;

    uint proposalId;
    uint totalVotes = allVotesByMember[leader].length;
    uint lastClaimed = totalVotes;
    uint j;
    uint i;
    for (i = lastRewardClaimed[_memberAddress]; i < totalVotes && j < _maxRecords; i++) {
      voteId = allVotesByMember[leader][i];
      proposalId = allVotes[voteId].proposalId;
      if (proposalVoteTally[proposalId].voters > 0 && (allVotes[voteId].dateAdd > (
      lastUpd.add(tokenHoldingTime)) || leader == _memberAddress)) {
        if (allProposalData[proposalId].propStatus > uint(ProposalStatus.VotingStarted)) {
          if (!rewardClaimed[voteId][_memberAddress]) {
            pendingDAppReward = pendingDAppReward.add(
              allProposalData[proposalId].commonIncentive.div(
                proposalVoteTally[proposalId].voters
              )
            );
            rewardClaimed[voteId][_memberAddress] = true;
            j++;
          }
        } else {
          if (lastClaimed == totalVotes) {
            lastClaimed = i;
          }
        }
      }
    }

    if (lastClaimed == totalVotes) {
      lastRewardClaimed[_memberAddress] = i;
    } else {
      lastRewardClaimed[_memberAddress] = lastClaimed;
    }

    if (j > 0) {
      emit RewardClaimed(
        _memberAddress,
        pendingDAppReward
      );
    }
  }

   
  function setDelegationStatus(bool _status) external isMemberAndcheckPause checkPendingRewards {
    isOpenForDelegation[msg.sender] = _status;
  }

   
  function delegateVote(address _add) external isMemberAndcheckPause checkPendingRewards {

    require(ms.masterInitialized());

    require(allDelegation[followerDelegation[_add]].leader == address(0));

    if (followerDelegation[msg.sender] > 0) {
      require((allDelegation[followerDelegation[msg.sender]].lastUpd).add(tokenHoldingTime) < now);
    }

    require(!alreadyDelegated(msg.sender));
    require(!memberRole.checkRole(msg.sender, uint(MemberRoles.Role.Owner)));
    require(!memberRole.checkRole(msg.sender, uint(MemberRoles.Role.AdvisoryBoard)));


    require(followerCount[_add] < maxFollowers);

    if (allVotesByMember[msg.sender].length > 0) {
      require((allVotes[allVotesByMember[msg.sender][allVotesByMember[msg.sender].length - 1]].dateAdd).add(tokenHoldingTime)
        < now);
    }

    require(ms.isMember(_add));

    require(isOpenForDelegation[_add]);

    allDelegation.push(DelegateVote(msg.sender, _add, now));
    followerDelegation[msg.sender] = allDelegation.length - 1;
    leaderDelegation[_add].push(allDelegation.length - 1);
    followerCount[_add]++;
    lastRewardClaimed[msg.sender] = allVotesByMember[_add].length;
  }

   
  function unDelegate() external isMemberAndcheckPause checkPendingRewards {
    _unDelegate(msg.sender);
  }

   
  function triggerAction(uint _proposalId) external {
    require(proposalActionStatus[_proposalId] == uint(ActionStatus.Accepted) && proposalExecutionTime[_proposalId] <= now, "Cannot trigger");
    _triggerAction(_proposalId, allProposalData[_proposalId].category);
  }

   
  function rejectAction(uint _proposalId) external {
    require(memberRole.checkRole(msg.sender, uint(MemberRoles.Role.AdvisoryBoard)) && proposalExecutionTime[_proposalId] > now);

    require(proposalActionStatus[_proposalId] == uint(ActionStatus.Accepted));

    require(!proposalRejectedByAB[_proposalId][msg.sender]);

    require(
      keccak256(proposalCategory.categoryActionHashes(allProposalData[_proposalId].category))
      != keccak256(abi.encodeWithSignature("swapABMember(address,address)"))
    );

    proposalRejectedByAB[_proposalId][msg.sender] = true;
    actionRejectedCount[_proposalId]++;
    emit ActionRejected(_proposalId, msg.sender);
    if (actionRejectedCount[_proposalId] == AB_MAJ_TO_REJECT_ACTION) {
      proposalActionStatus[_proposalId] = uint(ActionStatus.Rejected);
    }
  }

   
  function setInitialActionParameters() external onlyOwner {
    require(!actionParamsInitialised);
    actionParamsInitialised = true;
    actionWaitingTime = 24 * 1 hours;
  }

   
  function getUintParameters(bytes8 code) external view returns (bytes8 codeVal, uint val) {

    codeVal = code;

    if (code == "GOVHOLD") {

      val = tokenHoldingTime / (1 days);

    } else if (code == "MAXFOL") {

      val = maxFollowers;

    } else if (code == "MAXDRFT") {

      val = maxDraftTime / (1 days);

    } else if (code == "EPTIME") {

      val = ms.pauseTime() / (1 days);

    } else if (code == "ACWT") {

      val = actionWaitingTime / (1 hours);

    }
  }

   
  function proposal(uint _proposalId)
  external
  view
  returns (
    uint proposalId,
    uint category,
    uint status,
    uint finalVerdict,
    uint totalRewar
  )
  {
    return (
    _proposalId,
    allProposalData[_proposalId].category,
    allProposalData[_proposalId].propStatus,
    allProposalData[_proposalId].finalVerdict,
    allProposalData[_proposalId].commonIncentive
    );
  }

   
  function proposalDetails(uint _proposalId) external view returns (uint, uint, uint) {
    return (
    _proposalId,
    allProposalSolutions[_proposalId].length,
    proposalVoteTally[_proposalId].voters
    );
  }

   
  function getSolutionAction(uint _proposalId, uint _solution) external view returns (uint, bytes memory) {
    return (
    _solution,
    allProposalSolutions[_proposalId][_solution]
    );
  }

   
  function getProposalLength() external view returns (uint) {
    return totalProposals;
  }

   
  function getFollowers(address _add) external view returns (uint[] memory) {
    return leaderDelegation[_add];
  }

   
  function getPendingReward(address _memberAddress)
  public view returns (uint pendingDAppReward)
  {
    uint delegationId = followerDelegation[_memberAddress];
    address leader;
    uint lastUpd;
    DelegateVote memory delegationData = allDelegation[delegationId];

    if (delegationId > 0 && delegationData.leader != address(0)) {
      leader = delegationData.leader;
      lastUpd = delegationData.lastUpd;
    } else
      leader = _memberAddress;

    uint proposalId;
    for (uint i = lastRewardClaimed[_memberAddress]; i < allVotesByMember[leader].length; i++) {
      if (allVotes[allVotesByMember[leader][i]].dateAdd > (
      lastUpd.add(tokenHoldingTime)) || leader == _memberAddress) {
        if (!rewardClaimed[allVotesByMember[leader][i]][_memberAddress]) {
          proposalId = allVotes[allVotesByMember[leader][i]].proposalId;
          if (proposalVoteTally[proposalId].voters > 0 && allProposalData[proposalId].propStatus
          > uint(ProposalStatus.VotingStarted)) {
            pendingDAppReward = pendingDAppReward.add(
              allProposalData[proposalId].commonIncentive.div(
                proposalVoteTally[proposalId].voters
              )
            );
          }
        }
      }
    }
  }

   
  function updateUintParameters(bytes8 code, uint val) public {

    require(ms.checkIsAuthToGoverned(msg.sender));
    if (code == "GOVHOLD") {

      tokenHoldingTime = val * 1 days;

    } else if (code == "MAXFOL") {

      maxFollowers = val;

    } else if (code == "MAXDRFT") {

      maxDraftTime = val * 1 days;

    } else if (code == "EPTIME") {

      ms.updatePauseTime(val * 1 days);

    } else if (code == "ACWT") {

      actionWaitingTime = val * 1 hours;

    } else {

      revert("Invalid code");

    }
  }

   
  function changeDependentContractAddress() public {
    tokenInstance = TokenController(ms.dAppLocker());
    memberRole = MemberRoles(ms.getLatestAddress("MR"));
    proposalCategory = ProposalCategory(ms.getLatestAddress("PC"));
  }

   
  function allowedToCreateProposal(uint category) public view returns (bool check) {
    if (category == 0)
      return true;
    uint[] memory mrAllowed;
    (,,,, mrAllowed,,) = proposalCategory.category(category);
    for (uint i = 0; i < mrAllowed.length; i++) {
      if (mrAllowed[i] == 0 || memberRole.checkRole(msg.sender, mrAllowed[i]))
        return true;
    }
  }

   
  function alreadyDelegated(address _add) public view returns (bool delegated) {
    for (uint i = 0; i < leaderDelegation[_add].length; i++) {
      if (allDelegation[leaderDelegation[_add][i]].leader == _add) {
        return true;
      }
    }
  }

   
  function canCloseProposal(uint _proposalId)
  public
  view
  returns (uint)
  {
    uint dateUpdate;
    uint pStatus;
    uint _closingTime;
    uint _roleId;
    uint majority;
    pStatus = allProposalData[_proposalId].propStatus;
    dateUpdate = allProposalData[_proposalId].dateUpd;
    (, _roleId, majority, , , _closingTime,) = proposalCategory.category(allProposalData[_proposalId].category);
    if (
      pStatus == uint(ProposalStatus.VotingStarted)
    ) {
      uint numberOfMembers = memberRole.numberOfMembers(_roleId);
      if (_roleId == uint(MemberRoles.Role.AdvisoryBoard)) {
        if (proposalVoteTally[_proposalId].abVoteValue[1].mul(100).div(numberOfMembers) >= majority
        || proposalVoteTally[_proposalId].abVoteValue[1].add(proposalVoteTally[_proposalId].abVoteValue[0]) == numberOfMembers
          || dateUpdate.add(_closingTime) <= now) {

          return 1;
        }
      } else {
        if (numberOfMembers == proposalVoteTally[_proposalId].voters
          || dateUpdate.add(_closingTime) <= now)
          return 1;
      }
    } else if (pStatus > uint(ProposalStatus.VotingStarted)) {
      return 2;
    } else {
      return 0;
    }
  }

   
  function allowedToCatgorize() public view returns (uint roleId) {
    return roleIdAllowedToCatgorize;
  }

   
  function voteTallyData(uint _proposalId, uint _solution) public view returns (uint, uint, uint) {
    return (proposalVoteTally[_proposalId].memberVoteValue[_solution],
    proposalVoteTally[_proposalId].abVoteValue[_solution], proposalVoteTally[_proposalId].voters);
  }

   
  function _createProposal(
    string memory _proposalTitle,
    string memory _proposalSD,
    string memory _proposalDescHash,
    uint _categoryId
  )
  internal
  {
    require(proposalCategory.categoryABReq(_categoryId) == 0 || _categoryId == 0);
    uint _proposalId = totalProposals;
    allProposalData[_proposalId].owner = msg.sender;
    allProposalData[_proposalId].dateUpd = now;
    allProposalSolutions[_proposalId].push("");
    totalProposals++;

    emit Proposal(
      msg.sender,
      _proposalId,
      now,
      _proposalTitle,
      _proposalSD,
      _proposalDescHash
    );

    if (_categoryId > 0)
      _categorizeProposal(_proposalId, _categoryId, 0);
  }

   
  function _categorizeProposal(
    uint _proposalId,
    uint _categoryId,
    uint _incentive
  )
  internal
  {
    require(
      _categoryId > 0 && _categoryId < proposalCategory.totalCategories(),
      "Invalid category"
    );
    allProposalData[_proposalId].category = _categoryId;
    allProposalData[_proposalId].commonIncentive = _incentive;
    allProposalData[_proposalId].propStatus = uint(ProposalStatus.AwaitingSolution);

    emit ProposalCategorized(_proposalId, msg.sender, _categoryId);
  }

   
  function _addSolution(uint _proposalId, bytes memory _action, string memory _solutionHash)
  internal
  {
    allProposalSolutions[_proposalId].push(_action);
    emit Solution(_proposalId, msg.sender, allProposalSolutions[_proposalId].length - 1, _solutionHash, now);
  }

   
  function _proposalSubmission(
    uint _proposalId,
    string memory _solutionHash,
    bytes memory _action
  )
  internal
  {

    uint _categoryId = allProposalData[_proposalId].category;
    if (proposalCategory.categoryActionHashes(_categoryId).length == 0) {
      require(keccak256(_action) == keccak256(""));
      proposalActionStatus[_proposalId] = uint(ActionStatus.NoAction);
    }

    _addSolution(
      _proposalId,
      _action,
      _solutionHash
    );

    _updateProposalStatus(_proposalId, uint(ProposalStatus.VotingStarted));
    (, , , , , uint closingTime,) = proposalCategory.category(_categoryId);
    emit CloseProposalOnTime(_proposalId, closingTime.add(now));

  }

   
  function _submitVote(uint _proposalId, uint _solution) internal {

    uint delegationId = followerDelegation[msg.sender];
    uint mrSequence;
    uint majority;
    uint closingTime;
    (, mrSequence, majority, , , closingTime,) = proposalCategory.category(allProposalData[_proposalId].category);

    require(allProposalData[_proposalId].dateUpd.add(closingTime) > now, "Closed");

    require(memberProposalVote[msg.sender][_proposalId] == 0, "Not allowed");
    require((delegationId == 0) || (delegationId > 0 && allDelegation[delegationId].leader == address(0) &&
    _checkLastUpd(allDelegation[delegationId].lastUpd)));

    require(memberRole.checkRole(msg.sender, mrSequence), "Not Authorized");
    uint totalVotes = allVotes.length;

    allVotesByMember[msg.sender].push(totalVotes);
    memberProposalVote[msg.sender][_proposalId] = totalVotes;

    allVotes.push(ProposalVote(msg.sender, _proposalId, now));

    emit Vote(msg.sender, _proposalId, totalVotes, now, _solution);
    if (mrSequence == uint(MemberRoles.Role.Owner)) {
      if (_solution == 1)
        _callIfMajReached(_proposalId, uint(ProposalStatus.Accepted), allProposalData[_proposalId].category, 1, MemberRoles.Role.Owner);
      else
        _updateProposalStatus(_proposalId, uint(ProposalStatus.Rejected));

    } else {
      uint numberOfMembers = memberRole.numberOfMembers(mrSequence);
      _setVoteTally(_proposalId, _solution, mrSequence);

      if (mrSequence == uint(MemberRoles.Role.AdvisoryBoard)) {
        if (proposalVoteTally[_proposalId].abVoteValue[1].mul(100).div(numberOfMembers)
        >= majority
          || (proposalVoteTally[_proposalId].abVoteValue[1].add(proposalVoteTally[_proposalId].abVoteValue[0])) == numberOfMembers) {
          emit VoteCast(_proposalId);
        }
      } else {
        if (numberOfMembers == proposalVoteTally[_proposalId].voters)
          emit VoteCast(_proposalId);
      }
    }

  }

   
  function _setVoteTally(uint _proposalId, uint _solution, uint mrSequence) internal
  {
    uint categoryABReq;
    uint isSpecialResolution;
    (, categoryABReq, isSpecialResolution) = proposalCategory.categoryExtendedData(allProposalData[_proposalId].category);
    if (memberRole.checkRole(msg.sender, uint(MemberRoles.Role.AdvisoryBoard)) && (categoryABReq > 0) ||
      mrSequence == uint(MemberRoles.Role.AdvisoryBoard)) {
      proposalVoteTally[_proposalId].abVoteValue[_solution]++;
    }
    tokenInstance.lockForMemberVote(msg.sender, tokenHoldingTime);
    if (mrSequence != uint(MemberRoles.Role.AdvisoryBoard)) {
      uint voteWeight;
      uint voters = 1;
      uint tokenBalance = tokenInstance.totalBalanceOf(msg.sender);
      uint totalSupply = tokenInstance.totalSupply();
      if (isSpecialResolution == 1) {
        voteWeight = tokenBalance.add(10 ** 18);
      } else {
        voteWeight = (_minOf(tokenBalance, maxVoteWeigthPer.mul(totalSupply).div(100))).add(10 ** 18);
      }
      DelegateVote memory delegationData;
      for (uint i = 0; i < leaderDelegation[msg.sender].length; i++) {
        delegationData = allDelegation[leaderDelegation[msg.sender][i]];
        if (delegationData.leader == msg.sender &&
          _checkLastUpd(delegationData.lastUpd)) {
          if (memberRole.checkRole(delegationData.follower, mrSequence)) {
            tokenBalance = tokenInstance.totalBalanceOf(delegationData.follower);
            tokenInstance.lockForMemberVote(delegationData.follower, tokenHoldingTime);
            voters++;
            if (isSpecialResolution == 1) {
              voteWeight = voteWeight.add(tokenBalance.add(10 ** 18));
            } else {
              voteWeight = voteWeight.add((_minOf(tokenBalance, maxVoteWeigthPer.mul(totalSupply).div(100))).add(10 ** 18));
            }
          }
        }
      }
      proposalVoteTally[_proposalId].memberVoteValue[_solution] = proposalVoteTally[_proposalId].memberVoteValue[_solution].add(voteWeight);
      proposalVoteTally[_proposalId].voters = proposalVoteTally[_proposalId].voters + voters;
    }
  }

   
  function _minOf(uint a, uint b) internal pure returns (uint res) {
    res = a;
    if (res > b)
      res = b;
  }

   
  function _checkLastUpd(uint _lastUpd) internal view returns (bool) {
    return (now - _lastUpd) > tokenHoldingTime;
  }

   
  function _checkForThreshold(uint _proposalId, uint _category) internal view returns (bool check) {
    uint categoryQuorumPerc;
    uint roleAuthorized;
    (, roleAuthorized, , categoryQuorumPerc, , ,) = proposalCategory.category(_category);
    check = ((proposalVoteTally[_proposalId].memberVoteValue[0]
    .add(proposalVoteTally[_proposalId].memberVoteValue[1]))
    .mul(100))
    .div(
      tokenInstance.totalSupply().add(
        memberRole.numberOfMembers(roleAuthorized).mul(10 ** 18)
      )
    ) >= categoryQuorumPerc;
  }

   
  function _callIfMajReached(uint _proposalId, uint _status, uint category, uint max, MemberRoles.Role role) internal {

    allProposalData[_proposalId].finalVerdict = max;
    _updateProposalStatus(_proposalId, _status);
    emit ProposalAccepted(_proposalId);
    if (proposalActionStatus[_proposalId] != uint(ActionStatus.NoAction)) {
      if (role == MemberRoles.Role.AdvisoryBoard) {
        _triggerAction(_proposalId, category);
      } else {
        proposalActionStatus[_proposalId] = uint(ActionStatus.Accepted);
        proposalExecutionTime[_proposalId] = actionWaitingTime.add(now);
      }
    }
  }

   
  function _triggerAction(uint _proposalId, uint _categoryId) internal {
    proposalActionStatus[_proposalId] = uint(ActionStatus.Executed);
    bytes2 contractName;
    address actionAddress;
    bytes memory _functionHash;
    (, actionAddress, contractName, , _functionHash) = proposalCategory.categoryActionDetails(_categoryId);
    if (contractName == "MS") {
      actionAddress = address(ms);
    } else if (contractName != "EX") {
      actionAddress = ms.getLatestAddress(contractName);
    }
     
    (bool actionStatus,) = actionAddress.call(abi.encodePacked(_functionHash, allProposalSolutions[_proposalId][1]));
    if (actionStatus) {
      emit ActionSuccess(_proposalId);
    } else {
      proposalActionStatus[_proposalId] = uint(ActionStatus.Accepted);
      emit ActionFailed(_proposalId);
    }
  }

   
  function _updateProposalStatus(uint _proposalId, uint _status) internal {
    if (_status == uint(ProposalStatus.Rejected) || _status == uint(ProposalStatus.Denied)) {
      proposalActionStatus[_proposalId] = uint(ActionStatus.NoAction);
    }
    allProposalData[_proposalId].dateUpd = now;
    allProposalData[_proposalId].propStatus = _status;
  }

   
  function _unDelegate(address _follower) internal {
    uint followerId = followerDelegation[_follower];
    if (followerId > 0) {

      followerCount[allDelegation[followerId].leader] = followerCount[allDelegation[followerId].leader].sub(1);
      allDelegation[followerId].leader = address(0);
      allDelegation[followerId].lastUpd = now;

      lastRewardClaimed[_follower] = allVotesByMember[_follower].length;
    }
  }

   
  function _closeMemberVote(uint _proposalId, uint category) internal {
    uint isSpecialResolution;
    uint abMaj;
    (, abMaj, isSpecialResolution) = proposalCategory.categoryExtendedData(category);
    if (isSpecialResolution == 1) {
      uint acceptedVotePerc = proposalVoteTally[_proposalId].memberVoteValue[1].mul(100)
      .div(
        tokenInstance.totalSupply().add(
          memberRole.numberOfMembers(uint(MemberRoles.Role.Member)).mul(10 ** 18)
        ));
      if (acceptedVotePerc >= specialResolutionMajPerc) {
        _callIfMajReached(_proposalId, uint(ProposalStatus.Accepted), category, 1, MemberRoles.Role.Member);
      } else {
        _updateProposalStatus(_proposalId, uint(ProposalStatus.Denied));
      }
    } else {
      if (_checkForThreshold(_proposalId, category)) {
        uint majorityVote;
        (,, majorityVote,,,,) = proposalCategory.category(category);
        if (
          ((proposalVoteTally[_proposalId].memberVoteValue[1].mul(100))
          .div(proposalVoteTally[_proposalId].memberVoteValue[0]
          .add(proposalVoteTally[_proposalId].memberVoteValue[1])
          ))
          >= majorityVote
        ) {
          _callIfMajReached(_proposalId, uint(ProposalStatus.Accepted), category, 1, MemberRoles.Role.Member);
        } else {
          _updateProposalStatus(_proposalId, uint(ProposalStatus.Rejected));
        }
      } else {
        if (abMaj > 0 && proposalVoteTally[_proposalId].abVoteValue[1].mul(100)
        .div(memberRole.numberOfMembers(uint(MemberRoles.Role.AdvisoryBoard))) >= abMaj) {
          _callIfMajReached(_proposalId, uint(ProposalStatus.Accepted), category, 1, MemberRoles.Role.Member);
        } else {
          _updateProposalStatus(_proposalId, uint(ProposalStatus.Denied));
        }
      }
    }

    if (proposalVoteTally[_proposalId].voters > 0) {
      tokenInstance.mint(ms.getLatestAddress("CR"), allProposalData[_proposalId].commonIncentive);
    }
  }

   
  function _closeAdvisoryBoardVote(uint _proposalId, uint category) internal {
    uint _majorityVote;
    MemberRoles.Role _roleId = MemberRoles.Role.AdvisoryBoard;
    (,, _majorityVote,,,,) = proposalCategory.category(category);
    if (proposalVoteTally[_proposalId].abVoteValue[1].mul(100)
    .div(memberRole.numberOfMembers(uint(_roleId))) >= _majorityVote) {
      _callIfMajReached(_proposalId, uint(ProposalStatus.Accepted), category, 1, _roleId);
    } else {
      _updateProposalStatus(_proposalId, uint(ProposalStatus.Denied));
    }

  }

}

 
  function getUserAllLockedCNTokens(address _of) external view returns (uint) {

    uint[] memory coverIds = qd.getAllCoversOfUser(_of);
    uint total;

    for (uint i = 0; i < coverIds.length; i++) {
      bytes32 reason = keccak256(abi.encodePacked("CN", _of, coverIds[i]));
      uint coverNote = tc.tokensLocked(_of, reason);
      total = total.add(coverNote);
    }

    return total;
  }

   
  function changeDependentContractAddress() public {
    tc = TokenController(master.getLatestAddress("TC"));
    tk = NXMToken(master.tokenAddress());
    qd = QuotationData(master.getLatestAddress("QD"));
  }

   
  function burnCAToken(uint claimid, uint _value, address _of) external onlyGovernance {
    tc.burnLockedTokens(_of, "CLA", _value);
    emit BurnCATokens(claimid, _of, _value);
  }

   
  function isLockedForMemberVote(address _of) public view returns (bool) {
    return now < tk.isLockedForMV(_of);
  }

}

 
  function setClaimStatus(uint claimId, uint stat) external onlyInternal {
    _setClaimStatus(claimId, stat);
  }

   
  function getCATokens(uint claimId, uint member) external view returns (uint tokens) {
    uint coverId;
    (, coverId) = cd.getClaimCoverId(claimId);

    bytes4 currency = qd.getCurrencyOfCover(coverId);
    address asset = cr.getCurrencyAssetAddress(currency);
    uint tokenx1e18 = p1.getTokenPrice(asset);

    uint accept;
    uint deny;
    if (member == 0) {
      (, accept, deny) = cd.getClaimsTokenCA(claimId);
    } else {
      (, accept, deny) = cd.getClaimsTokenMV(claimId);
    }
    tokens = ((accept.add(deny)).mul(tokenx1e18)).div(DECIMAL1E18);  
  }

   
  function changeDependentContractAddress() public onlyInternal {
    td = TokenData(ms.getLatestAddress("TD"));
    tc = TokenController(ms.getLatestAddress("TC"));
    p1 = Pool(ms.getLatestAddress("P1"));
    cr = ClaimsReward(ms.getLatestAddress("CR"));
    cd = ClaimsData(ms.getLatestAddress("CD"));
    qd = QuotationData(ms.getLatestAddress("QD"));
    incidents = Incidents(ms.getLatestAddress("IC"));
  }

   
  function submitClaim(uint coverId) external {
    _submitClaim(coverId, msg.sender);
  }

  function submitClaimForMember(uint coverId, address member) external onlyInternal {
    _submitClaim(coverId, member);
  }

  function _submitClaim(uint coverId, address member) internal {

    require(!ms.isPause(), "Claims: System is paused");

    ( , address contractAddress) = qd.getscAddressOfCover(coverId);
    address token = incidents.coveredToken(contractAddress);
    require(token == address(0), "Claims: Product type does not allow claims");

    address coverOwner = qd.getCoverMemberAddress(coverId);
    require(coverOwner == member, "Claims: Not cover owner");

    uint expirationDate = qd.getValidityOfCover(coverId);
    uint gracePeriod = tc.claimSubmissionGracePeriod();
    require(expirationDate.add(gracePeriod) > now, "Claims: Grace period has expired");

    tc.markCoverClaimOpen(coverId);
    qd.changeCoverStatusNo(coverId, uint8(QuotationData.CoverStatus.ClaimSubmitted));

    uint claimId = cd.actualClaimLength();
    cd.addClaim(claimId, coverId, coverOwner, now);
    cd.callClaimEvent(coverId, coverOwner, claimId, now);
  }

   
  function submitClaimAfterEPOff() external pure {}

   
  function submitCAVote(uint claimId, int8 verdict) public isMemberAndcheckPause {
    require(checkVoteClosing(claimId) != 1);
    require(cd.userClaimVotePausedOn(msg.sender).add(cd.pauseDaysCA()) < now);
    uint tokens = tc.tokensLockedAtTime(msg.sender, "CLA", now.add(cd.claimDepositTime()));
    require(tokens > 0);
    uint stat;
    (, stat) = cd.getClaimStatusNumber(claimId);
    require(stat == 0);
    require(cd.getUserClaimVoteCA(msg.sender, claimId) == 0);
    td.bookCATokens(msg.sender);
    cd.addVote(msg.sender, tokens, claimId, verdict);
    cd.callVoteEvent(msg.sender, claimId, "CAV", tokens, now, verdict);
    uint voteLength = cd.getAllVoteLength();
    cd.addClaimVoteCA(claimId, voteLength);
    cd.setUserClaimVoteCA(msg.sender, claimId, voteLength);
    cd.setClaimTokensCA(claimId, verdict, tokens);
    tc.extendLockOf(msg.sender, "CLA", td.lockCADays());
    int close = checkVoteClosing(claimId);
    if (close == 1) {
      cr.changeClaimStatus(claimId);
    }
  }

   
  function submitMemberVote(uint claimId, int8 verdict) public isMemberAndcheckPause {
    require(checkVoteClosing(claimId) != 1);
    uint stat;
    uint tokens = tc.totalBalanceOf(msg.sender);
    (, stat) = cd.getClaimStatusNumber(claimId);
    require(stat >= 1 && stat <= 5);
    require(cd.getUserClaimVoteMember(msg.sender, claimId) == 0);
    cd.addVote(msg.sender, tokens, claimId, verdict);
    cd.callVoteEvent(msg.sender, claimId, "MV", tokens, now, verdict);
    tc.lockForMemberVote(msg.sender, td.lockMVDays());
    uint voteLength = cd.getAllVoteLength();
    cd.addClaimVotemember(claimId, voteLength);
    cd.setUserClaimVoteMember(msg.sender, claimId, voteLength);
    cd.setClaimTokensMV(claimId, verdict, tokens);
    int close = checkVoteClosing(claimId);
    if (close == 1) {
      cr.changeClaimStatus(claimId);
    }
  }

   
  function pauseAllPendingClaimsVoting() external pure {}

   
  function startAllPendingClaimsVoting() external pure {}

   
  function checkVoteClosing(uint claimId) public view returns (int8 close) {
    close = 0;
    uint status;
    (, status) = cd.getClaimStatusNumber(claimId);
    uint dateUpd = cd.getClaimDateUpd(claimId);
    if (status == 12 && dateUpd.add(cd.payoutRetryTime()) < now) {
      if (cd.getClaimState12Count(claimId) < 60)
        close = 1;
    }

    if (status > 5 && status != 12) {
      close = - 1;
    } else if (status != 12 && dateUpd.add(cd.maxVotingTime()) <= now) {
      close = 1;
    } else if (status != 12 && dateUpd.add(cd.minVotingTime()) >= now) {
      close = 0;
    } else if (status == 0 || (status >= 1 && status <= 5)) {
      close = _checkVoteClosingFinal(claimId, status);
    }

  }

   
  function _checkVoteClosingFinal(uint claimId, uint status) internal view returns (int8 close) {
    close = 0;
    uint coverId;
    (, coverId) = cd.getClaimCoverId(claimId);

    bytes4 currency = qd.getCurrencyOfCover(coverId);
    address asset = cr.getCurrencyAssetAddress(currency);
    uint tokenx1e18 = p1.getTokenPrice(asset);

    uint accept;
    uint deny;
    (, accept, deny) = cd.getClaimsTokenCA(claimId);
    uint caTokens = ((accept.add(deny)).mul(tokenx1e18)).div(DECIMAL1E18);
    (, accept, deny) = cd.getClaimsTokenMV(claimId);
    uint mvTokens = ((accept.add(deny)).mul(tokenx1e18)).div(DECIMAL1E18);
    uint sumassured = qd.getCoverSumAssured(coverId).mul(DECIMAL1E18);
    if (status == 0 && caTokens >= sumassured.mul(10)) {
      close = 1;
    } else if (status >= 1 && status <= 5 && mvTokens >= sumassured.mul(10)) {
      close = 1;
    }
  }

   
  function _setClaimStatus(uint claimId, uint stat) internal {

    uint origstat;
    uint state12Count;
    uint dateUpd;
    uint coverId;
    (, coverId, , origstat, dateUpd, state12Count) = cd.getClaim(claimId);
    (, origstat) = cd.getClaimStatusNumber(claimId);

    if (stat == 12 && origstat == 12) {
      cd.updateState12Count(claimId, 1);
    }
    cd.setClaimStatus(claimId, stat);

    if (state12Count >= 60 && stat == 12) {
      cd.setClaimStatus(claimId, 13);
      qd.changeCoverStatusNo(coverId, uint8(QuotationData.CoverStatus.ClaimDenied));
    }

    cd.setClaimdateUpd(claimId, now);
  }

}

 
  function swapABMember(
    address _newABAddress,
    address _removeAB
  )
  external
  checkRoleAuthority(uint(Role.AdvisoryBoard)) {

    _updateRole(_newABAddress, uint(Role.AdvisoryBoard), true);
    _updateRole(_removeAB, uint(Role.AdvisoryBoard), false);

  }

   
  function swapOwner(
    address _newOwnerAddress
  )
  external {
    require(msg.sender == address(ms));
    _updateRole(ms.owner(), uint(Role.Owner), false);
    _updateRole(_newOwnerAddress, uint(Role.Owner), true);
  }

   
  function addInitialABMembers(address[] calldata abArray) external onlyOwner {

     
    require(ms.masterInitialized());

    require(maxABCount >=
      SafeMath.add(numberOfMembers(uint(Role.AdvisoryBoard)), abArray.length)
    );
     
    for (uint i = 0; i < abArray.length; i++) {
      require(checkRole(abArray[i], uint(MemberRoles.Role.Member)));
      _updateRole(abArray[i], uint(Role.AdvisoryBoard), true);
    }
  }

   
  function changeMaxABCount(uint _val) external onlyInternal {
    maxABCount = _val;
  }

   
  function changeDependentContractAddress() public {
    td = TokenData(ms.getLatestAddress("TD"));
    cr = ClaimsReward(ms.getLatestAddress("CR"));
    qd = QuotationData(ms.getLatestAddress("QD"));
    gv = Governance(ms.getLatestAddress("GV"));
    tf = TokenFunctions(ms.getLatestAddress("TF"));
    tk = NXMToken(ms.tokenAddress());
    tc = TokenController(ms.getLatestAddress("TC"));
  }

   
  function changeMasterAddress(address _masterAddress) public {

    if (masterAddress != address(0)) {
      require(masterAddress == msg.sender);
    }

    masterAddress = _masterAddress;
    ms = INXMMaster(_masterAddress);
    nxMasterAddress = _masterAddress;
  }

   
  function memberRolesInitiate(address _firstAB, address memberAuthority) public {
    require(!constructorCheck);
    _addInitialMemberRoles(_firstAB, memberAuthority);
    constructorCheck = true;
  }

  
  
  
  
  function addRole( 
    bytes32 _roleName,
    string memory _roleDescription,
    address _authorized
  )
  public
  onlyAuthorizedToGovern {
    _addRole(_roleName, _roleDescription, _authorized);
  }

  
  
  
  
  function updateRole( 
    address _memberAddress,
    uint _roleId,
    bool _active
  )
  public
  checkRoleAuthority(_roleId) {
    _updateRole(_memberAddress, _roleId, _active);
  }

   
  function addMembersBeforeLaunch(address[] memory userArray, uint[] memory tokens) public onlyOwner {
    require(!launched);

    for (uint i = 0; i < userArray.length; i++) {
      require(!ms.isMember(userArray[i]));
      tc.addToWhitelist(userArray[i]);
      _updateRole(userArray[i], uint(Role.Member), true);
      tc.mint(userArray[i], tokens[i]);
    }
    launched = true;
    launchedOn = now;

  }

   
  function payJoiningFee(address _userAddress) public payable {
    require(_userAddress != address(0));
    require(!ms.isPause(), "Emergency Pause Applied");
    if (msg.sender == address(ms.getLatestAddress("QT"))) {
      require(td.walletAddress() != address(0), "No walletAddress present");
      tc.addToWhitelist(_userAddress);
      _updateRole(_userAddress, uint(Role.Member), true);
      td.walletAddress().transfer(msg.value);
    } else {
      require(!qd.refundEligible(_userAddress));
      require(!ms.isMember(_userAddress));
      require(msg.value == td.joiningFee());
      qd.setRefundEligible(_userAddress, true);
    }
  }

   
  function kycVerdict(address payable _userAddress, bool verdict) public {

    require(msg.sender == qd.kycAuthAddress());
    require(!ms.isPause());
    require(_userAddress != address(0));
    require(!ms.isMember(_userAddress));
    require(qd.refundEligible(_userAddress));
    if (verdict) {
      qd.setRefundEligible(_userAddress, false);
      uint fee = td.joiningFee();
      tc.addToWhitelist(_userAddress);
      _updateRole(_userAddress, uint(Role.Member), true);
      td.walletAddress().transfer(fee);  

    } else {
      qd.setRefundEligible(_userAddress, false);
      _userAddress.transfer(td.joiningFee());  
    }
  }

   
  function withdrawMembership() public {

    require(!ms.isPause() && ms.isMember(msg.sender));
    require(tc.totalLockedBalance(msg.sender) == 0);  
    require(!tf.isLockedForMemberVote(msg.sender));  
    require(cr.getAllPendingRewardOfUser(msg.sender) == 0);  

    gv.removeDelegation(msg.sender);
    tc.burnFrom(msg.sender, tk.balanceOf(msg.sender));
    _updateRole(msg.sender, uint(Role.Member), false);
    tc.removeFromWhitelist(msg.sender);  

    if (claimPayoutAddress[msg.sender] != address(0)) {
      claimPayoutAddress[msg.sender] = address(0);
      emit ClaimPayoutAddressSet(msg.sender, address(0));
    }
  }

   
  function switchMembership(address newAddress) external {
    _switchMembership(msg.sender, newAddress);
    tk.transferFrom(msg.sender, newAddress, tk.balanceOf(msg.sender));
  }

  function switchMembershipOf(address member, address newAddress) external onlyInternal {
    _switchMembership(member, newAddress);
  }

   
  function _switchMembership(address member, address newAddress) internal {

    require(!ms.isPause() && ms.isMember(member) && !ms.isMember(newAddress));
    require(tc.totalLockedBalance(member) == 0);  
    require(!tf.isLockedForMemberVote(member));  
    require(cr.getAllPendingRewardOfUser(member) == 0);  

    gv.removeDelegation(member);
    tc.addToWhitelist(newAddress);
    _updateRole(newAddress, uint(Role.Member), true);
    _updateRole(member, uint(Role.Member), false);
    tc.removeFromWhitelist(member);

    address payable previousPayoutAddress = claimPayoutAddress[member];

    if (previousPayoutAddress != address(0)) {

      address payable storedAddress = previousPayoutAddress == newAddress ? address(0) : previousPayoutAddress;

      claimPayoutAddress[member] = address(0);
      claimPayoutAddress[newAddress] = storedAddress;

       
      emit ClaimPayoutAddressSet(member, address(0));

      if (storedAddress != address(0)) {
         
        emit ClaimPayoutAddressSet(newAddress, storedAddress);
      }
    }

    emit switchedMembership(member, newAddress, now);
  }

  function getClaimPayoutAddress(address payable _member) external view returns (address payable) {
    address payable payoutAddress = claimPayoutAddress[_member];
    return payoutAddress != address(0) ? payoutAddress : _member;
  }

  function setClaimPayoutAddress(address payable _address) external {

    require(!ms.isPause(), "system is paused");
    require(ms.isMember(msg.sender), "sender is not a member");
    require(_address != msg.sender, "should be different than the member address");

    claimPayoutAddress[msg.sender] = _address;
    emit ClaimPayoutAddressSet(msg.sender, _address);
  }

  
  function totalRoles() public view returns (uint256) { 
    return memberRoleData.length;
  }

  
  
  
  function changeAuthorized(uint _roleId, address _newAuthorized) public checkRoleAuthority(_roleId) { 
    memberRoleData[_roleId].authorized = _newAuthorized;
  }

  
  
  
  
  function members(uint _memberRoleId) public view returns (uint, address[] memory memberArray) { 
    uint length = memberRoleData[_memberRoleId].memberAddress.length;
    uint i;
    uint j = 0;
    memberArray = new address[](memberRoleData[_memberRoleId].memberCounter);
    for (i = 0; i < length; i++) {
      address member = memberRoleData[_memberRoleId].memberAddress[i];
      if (memberRoleData[_memberRoleId].memberActive[member] && !_checkMemberInArray(member, memberArray)) { 
        memberArray[j] = member;
        j++;
      }
    }

    return (_memberRoleId, memberArray);
  }

  
  
  
  function numberOfMembers(uint _memberRoleId) public view returns (uint) { 
    return memberRoleData[_memberRoleId].memberCounter;
  }

  
  function authorized(uint _memberRoleId) public view returns (address) { 
    return memberRoleData[_memberRoleId].authorized;
  }

  
  function roles(address _memberAddress) public view returns (uint[] memory) { 
    uint length = memberRoleData.length;
    uint[] memory assignedRoles = new uint[](length);
    uint counter = 0;
    for (uint i = 1; i < length; i++) {
      if (memberRoleData[i].memberActive[_memberAddress]) {
        assignedRoles[counter] = i;
        counter++;
      }
    }
    return assignedRoles;
  }

  
  
  
   
  function checkRole(address _memberAddress, uint _roleId) public view returns (bool) { 
    if (_roleId == uint(Role.UnAssigned))
      return true;
    else
      if (memberRoleData[_roleId].memberActive[_memberAddress])  
        return true;
      else
        return false;
  }

  
  
  function getMemberLengthForAllRoles() public view returns (uint[] memory totalMembers) { 
    totalMembers = new uint[](memberRoleData.length);
    for (uint i = 0; i < memberRoleData.length; i++) {
      totalMembers[i] = numberOfMembers(i);
    }
  }

   
  function _updateRole(address _memberAddress,
    uint _roleId,
    bool _active) internal {
     
    if (_active) {
      require(!memberRoleData[_roleId].memberActive[_memberAddress]);
      memberRoleData[_roleId].memberCounter = SafeMath.add(memberRoleData[_roleId].memberCounter, 1);
      memberRoleData[_roleId].memberActive[_memberAddress] = true;
      memberRoleData[_roleId].memberAddress.push(_memberAddress);
    } else {
      require(memberRoleData[_roleId].memberActive[_memberAddress]);
      memberRoleData[_roleId].memberCounter = SafeMath.sub(memberRoleData[_roleId].memberCounter, 1);
      delete memberRoleData[_roleId].memberActive[_memberAddress];
    }
  }

  
  
  
  
  function _addRole(
    bytes32 _roleName,
    string memory _roleDescription,
    address _authorized
  ) internal {
    emit MemberRole(memberRoleData.length, _roleName, _roleDescription);
    memberRoleData.push(MemberRoleDetails(0, new address[](0), _authorized));
  }

   
  function _checkMemberInArray(
    address _memberAddress,
    address[] memory memberArray
  )
  internal
  pure
  returns (bool memberExists)
  {
    uint i;
    for (i = 0; i < memberArray.length; i++) {
      if (memberArray[i] == _memberAddress) {
        memberExists = true;
        break;
      }
    }
  }

   
  function _addInitialMemberRoles(address _firstAB, address memberAuthority) internal {
    maxABCount = 5;
    _addRole("Unassigned", "Unassigned", address(0));
    _addRole(
      "Advisory Board",
      "Selected few members that are deeply entrusted by the dApp. An ideal advisory board should be a mix of skills of domain, governance, research, technology, consulting etc to improve the performance of the dApp.",  
      address(0)
    );
    _addRole(
      "Member",
      "Represents all users of Mutual.",  
      memberAuthority
    );
    _addRole(
      "Owner",
      "Represents Owner of Mutual.",  
      address(0)
    );
     
    _updateRole(_firstAB, uint(Role.Owner), true);
     
    launchedOn = 0;
  }

  function memberAtIndex(uint _memberRoleId, uint index) external view returns (address, bool) {
    address memberAddress = memberRoleData[_memberRoleId].memberAddress[index];
    return (memberAddress, memberRoleData[_memberRoleId].memberActive[memberAddress]);
  }

  function membersLength(uint _memberRoleId) external view returns (uint) {
    return memberRoleData[_memberRoleId].memberAddress.length;
  }
}

 
  function addCategory(
    string calldata _name,
    uint _memberRoleToVote,
    uint _majorityVotePerc,
    uint _quorumPerc,
    uint[] calldata _allowedToCreateProposal,
    uint _closingTime,
    string calldata _actionHash,
    address _contractAddress,
    bytes2 _contractName,
    uint[] calldata _incentives
  ) external {}

   
  function proposalCategoryInitiate() external {}

   
  function updateCategoryActionHashes() external onlyOwner {

    require(!categoryActionHashUpdated, "Category action hashes already updated");
    categoryActionHashUpdated = true;
    categoryActionHashes[1] = abi.encodeWithSignature("addRole(bytes32,string,address)");
    categoryActionHashes[2] = abi.encodeWithSignature("updateRole(address,uint256,bool)");
    categoryActionHashes[3] = abi.encodeWithSignature("newCategory(string,uint256,uint256,uint256,uint256[],uint256,string,address,bytes2,uint256[],string)");  
    categoryActionHashes[4] = abi.encodeWithSignature("editCategory(uint256,string,uint256,uint256,uint256,uint256[],uint256,string,address,bytes2,uint256[],string)");  
    categoryActionHashes[5] = abi.encodeWithSignature("upgradeContractImplementation(bytes2,address)");
    categoryActionHashes[6] = abi.encodeWithSignature("startEmergencyPause()");
    categoryActionHashes[7] = abi.encodeWithSignature("addEmergencyPause(bool,bytes4)");
    categoryActionHashes[8] = abi.encodeWithSignature("burnCAToken(uint256,uint256,address)");
    categoryActionHashes[9] = abi.encodeWithSignature("setUserClaimVotePausedOn(address)");
    categoryActionHashes[12] = abi.encodeWithSignature("transferEther(uint256,address)");
    categoryActionHashes[13] = abi.encodeWithSignature("addInvestmentAssetCurrency(bytes4,address,bool,uint64,uint64,uint8)");  
    categoryActionHashes[14] = abi.encodeWithSignature("changeInvestmentAssetHoldingPerc(bytes4,uint64,uint64)");
    categoryActionHashes[15] = abi.encodeWithSignature("changeInvestmentAssetStatus(bytes4,bool)");
    categoryActionHashes[16] = abi.encodeWithSignature("swapABMember(address,address)");
    categoryActionHashes[17] = abi.encodeWithSignature("addCurrencyAssetCurrency(bytes4,address,uint256)");
    categoryActionHashes[20] = abi.encodeWithSignature("updateUintParameters(bytes8,uint256)");
    categoryActionHashes[21] = abi.encodeWithSignature("updateUintParameters(bytes8,uint256)");
    categoryActionHashes[22] = abi.encodeWithSignature("updateUintParameters(bytes8,uint256)");
    categoryActionHashes[23] = abi.encodeWithSignature("updateUintParameters(bytes8,uint256)");
    categoryActionHashes[24] = abi.encodeWithSignature("updateUintParameters(bytes8,uint256)");
    categoryActionHashes[25] = abi.encodeWithSignature("updateUintParameters(bytes8,uint256)");
    categoryActionHashes[26] = abi.encodeWithSignature("updateUintParameters(bytes8,uint256)");
    categoryActionHashes[27] = abi.encodeWithSignature("updateAddressParameters(bytes8,address)");
    categoryActionHashes[28] = abi.encodeWithSignature("updateOwnerParameters(bytes8,address)");
    categoryActionHashes[29] = abi.encodeWithSignature("upgradeMultipleContracts(bytes2[],address[])");
    categoryActionHashes[30] = abi.encodeWithSignature("changeCurrencyAssetAddress(bytes4,address)");
    categoryActionHashes[31] = abi.encodeWithSignature("changeCurrencyAssetBaseMin(bytes4,uint256)");
    categoryActionHashes[32] = abi.encodeWithSignature("changeInvestmentAssetAddressAndDecimal(bytes4,address,uint8)");  
    categoryActionHashes[33] = abi.encodeWithSignature("externalLiquidityTrade()");
  }

   
  function totalCategories() external view returns (uint) {
    return allCategory.length;
  }

   
  function category(uint _categoryId) external view returns (uint, uint, uint, uint, uint[] memory, uint, uint) {
    return (
    _categoryId,
    allCategory[_categoryId].memberRoleToVote,
    allCategory[_categoryId].majorityVotePerc,
    allCategory[_categoryId].quorumPerc,
    allCategory[_categoryId].allowedToCreateProposal,
    allCategory[_categoryId].closingTime,
    allCategory[_categoryId].minStake
    );
  }

   
  function categoryExtendedData(uint _categoryId) external view returns (uint, uint, uint) {
    return (
    _categoryId,
    categoryABReq[_categoryId],
    isSpecialResolution[_categoryId]
    );
  }

   
  function categoryAction(uint _categoryId) external view returns (uint, address, bytes2, uint) {

    return (
    _categoryId,
    categoryActionData[_categoryId].contractAddress,
    categoryActionData[_categoryId].contractName,
    categoryActionData[_categoryId].defaultIncentive
    );
  }

   
  function categoryActionDetails(uint _categoryId) external view returns (uint, address, bytes2, uint, bytes memory) {
    return (
    _categoryId,
    categoryActionData[_categoryId].contractAddress,
    categoryActionData[_categoryId].contractName,
    categoryActionData[_categoryId].defaultIncentive,
    categoryActionHashes[_categoryId]
    );
  }

   
  function changeDependentContractAddress() public {
    mr = MemberRoles(ms.getLatestAddress("MR"));
  }

   
  function newCategory(
    string memory _name,
    uint _memberRoleToVote,
    uint _majorityVotePerc,
    uint _quorumPerc,
    uint[] memory _allowedToCreateProposal,
    uint _closingTime,
    string memory _actionHash,
    address _contractAddress,
    bytes2 _contractName,
    uint[] memory _incentives,
    string memory _functionHash
  )
  public
  onlyAuthorizedToGovern
  {

    require(_quorumPerc <= 100 && _majorityVotePerc <= 100, "Invalid percentage");

    require((_contractName == "EX" && _contractAddress == address(0)) || bytes(_functionHash).length > 0);

    require(_incentives[3] <= 1, "Invalid special resolution flag");

     
    if (_incentives[3] == 1) {
      require(_memberRoleToVote == uint(MemberRoles.Role.Member));
      _majorityVotePerc = 0;
      _quorumPerc = 0;
    }

    _addCategory(
      _name,
      _memberRoleToVote,
      _majorityVotePerc,
      _quorumPerc,
      _allowedToCreateProposal,
      _closingTime,
      _actionHash,
      _contractAddress,
      _contractName,
      _incentives
    );


    if (bytes(_functionHash).length > 0 && abi.encodeWithSignature(_functionHash).length == 4) {
      categoryActionHashes[allCategory.length - 1] = abi.encodeWithSignature(_functionHash);
    }
  }

   
  function changeMasterAddress(address _masterAddress) public {
    if (masterAddress != address(0))
      require(masterAddress == msg.sender);
    masterAddress = _masterAddress;
    ms = INXMMaster(_masterAddress);
    nxMasterAddress = _masterAddress;

  }

   
  function updateCategory(
    uint _categoryId,
    string memory _name,
    uint _memberRoleToVote,
    uint _majorityVotePerc,
    uint _quorumPerc,
    uint[] memory _allowedToCreateProposal,
    uint _closingTime,
    string memory _actionHash,
    address _contractAddress,
    bytes2 _contractName,
    uint[] memory _incentives
  ) public {}

   
  function editCategory(
    uint _categoryId,
    string memory _name,
    uint _memberRoleToVote,
    uint _majorityVotePerc,
    uint _quorumPerc,
    uint[] memory _allowedToCreateProposal,
    uint _closingTime,
    string memory _actionHash,
    address _contractAddress,
    bytes2 _contractName,
    uint[] memory _incentives,
    string memory _functionHash
  )
  public
  onlyAuthorizedToGovern
  {
    require(_verifyMemberRoles(_memberRoleToVote, _allowedToCreateProposal) == 1, "Invalid Role");

    require(_quorumPerc <= 100 && _majorityVotePerc <= 100, "Invalid percentage");

    require((_contractName == "EX" && _contractAddress == address(0)) || bytes(_functionHash).length > 0);

    require(_incentives[3] <= 1, "Invalid special resolution flag");

     
    if (_incentives[3] == 1) {
      require(_memberRoleToVote == uint(MemberRoles.Role.Member));
      _majorityVotePerc = 0;
      _quorumPerc = 0;
    }

    delete categoryActionHashes[_categoryId];
    if (bytes(_functionHash).length > 0 && abi.encodeWithSignature(_functionHash).length == 4) {
      categoryActionHashes[_categoryId] = abi.encodeWithSignature(_functionHash);
    }
    allCategory[_categoryId].memberRoleToVote = _memberRoleToVote;
    allCategory[_categoryId].majorityVotePerc = _majorityVotePerc;
    allCategory[_categoryId].closingTime = _closingTime;
    allCategory[_categoryId].allowedToCreateProposal = _allowedToCreateProposal;
    allCategory[_categoryId].minStake = _incentives[0];
    allCategory[_categoryId].quorumPerc = _quorumPerc;
    categoryActionData[_categoryId].defaultIncentive = _incentives[1];
    categoryActionData[_categoryId].contractName = _contractName;
    categoryActionData[_categoryId].contractAddress = _contractAddress;
    categoryABReq[_categoryId] = _incentives[2];
    isSpecialResolution[_categoryId] = _incentives[3];
    emit Category(_categoryId, _name, _actionHash);
  }

   
  function _addCategory(
    string memory _name,
    uint _memberRoleToVote,
    uint _majorityVotePerc,
    uint _quorumPerc,
    uint[] memory _allowedToCreateProposal,
    uint _closingTime,
    string memory _actionHash,
    address _contractAddress,
    bytes2 _contractName,
    uint[] memory _incentives
  )
  internal
  {
    require(_verifyMemberRoles(_memberRoleToVote, _allowedToCreateProposal) == 1, "Invalid Role");
    allCategory.push(
      CategoryStruct(
        _memberRoleToVote,
        _majorityVotePerc,
        _quorumPerc,
        _allowedToCreateProposal,
        _closingTime,
        _incentives[0]
      )
    );
    uint categoryId = allCategory.length - 1;
    categoryActionData[categoryId] = CategoryAction(_incentives[1], _contractAddress, _contractName);
    categoryABReq[categoryId] = _incentives[2];
    isSpecialResolution[categoryId] = _incentives[3];
    emit Category(categoryId, _name, _actionHash);
  }

   
  function _verifyMemberRoles(uint _memberRoleToVote, uint[] memory _allowedToCreateProposal)
  internal view returns (uint) {
    uint totalRoles = mr.totalRoles();
    if (_memberRoleToVote >= totalRoles) {
      return 0;
    }
    for (uint i = 0; i < _allowedToCreateProposal.length; i++) {
      if (_allowedToCreateProposal[i] >= totalRoles) {
        return 0;
      }
    }
    return 1;
  }

}

/* Copyright (C) 2017 GovBlocks.io
  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
  This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
  You should have received a copy of the GNU General Public License
    along with this program.  If not, see http: 

pragma solidity ^0.5.0;


interface IMaster {
  function getLatestAddress(bytes2 _module) external view returns (address);
}
