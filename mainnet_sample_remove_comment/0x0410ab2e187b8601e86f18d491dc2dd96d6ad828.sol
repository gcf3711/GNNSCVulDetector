
 

 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;  
        return msg.data;
    }
}
 
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

interface WIDToken {
  function mintAll(address account) external;
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}
contract WIDPresale is Ownable {
    using SafeMath for uint256;

    event AddTeamBalance(address indexed team, uint256 amount, bool status);
    event TokensPurchased(address indexed buyer, uint256 indexed amount);
    event TokensClaimed(address indexed buyer, uint256 indexed amount);
    event TokensReleased(address indexed buyer, uint256 indexed amount);
    event LiquidityMigrated(uint256 amountToken, uint256 amountETH, uint256 liquidity);
    event PresaleInitialized(uint256 startDate, uint256 endDate);
    event SaleClosed();
    event WithdrawAllWID(address indexed owner);

    uint256 public pricePresale;

    WIDToken public widToken;
    uint256 public tokensForPresale;
    uint256 public tokensForAdmin;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public unlockDate;
    uint256 public minCommitment;
    uint256 public maxCommitment;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public tokensSold;
    bool    public isInitialized = false;
    bool    public isClosed;
    bool    public canClaimTokens = false;

    mapping(address => uint256) public tokensPurchased;
    mapping(address => uint256) public teamBalances;
    mapping(address => bool) public teamMembers;
    
    constructor(WIDToken _widToken) public {
      widToken = _widToken;
    }
    
    modifier isActive() {
      require(block.timestamp > startDate, "WIDPresale: You are too early!");
      require(block.timestamp < endDate, "WIDPresale: You are too late!");
      _;
    }

    modifier afterClosedSale() {
      require(isClosed, "WIDPresale: Sale is not closed.");
      _;
    }
    
    function isTeamMember(address _teamMember) public view returns(bool) {
      return teamMembers[_teamMember];
    }
    
    function initializePresale(
      uint256 _tokensForPresale,
      uint256 _startDate,
      uint256 _endDate,
      uint256 _minCommitment,
      uint256 _maxCommitment,
      uint256 _softCap,
      uint256 _hardCap,
      uint256 _pricePresale
    ) external onlyOwner {
      require(isInitialized == false, "WIDPresale: Presale has already been initialized.");
      require(_softCap < _hardCap, "WIDPresale: softCap cannot be higher then hardCap");
      require(_startDate < _endDate, "WIDPresale: startDate cannot be after endDate");
      require(_endDate > block.timestamp, "WIDPresale: endDate must be in the future");
      require(_minCommitment < _maxCommitment, "WIDPresale: minCommitment cannot be higher then maxCommitment");
    
      tokensForPresale =_tokensForPresale;
      startDate     = _startDate;
      endDate       = _endDate;
      minCommitment = _minCommitment;
      maxCommitment = _maxCommitment;
      softCap       = _softCap;
      hardCap       = _hardCap;
      pricePresale  = _pricePresale;

      isInitialized = true;
      
      widToken.mintAll(address(this));
      tokensForAdmin = widToken.balanceOf(address(this)).sub(_tokensForPresale);

      emit PresaleInitialized(startDate, endDate);
    }
    
    function addTeamBalance(address _team, uint256 _balance) public onlyOwner {
      require(isInitialized, "WIDPresale: Presale has already been initialized.");
      bool _status = false;
      if (!isTeamMember(_team)) {
        teamBalances[_team] = _balance;
        teamMembers[_team] = true;
        tokensForAdmin = tokensForAdmin.sub(_balance);
        _status = true;
      }
      emit AddTeamBalance(_team, _balance, _status);
    }

    function setCanClaim(bool canClaim) external onlyOwner afterClosedSale {
      canClaimTokens = canClaim;
    }

    function purchaseTokens() external payable isActive {
      uint256 amount = msg.value;
      require(!isClosed, "WIDPresale: sale closed");
      require(amount >= minCommitment, "WIDPresale: amount to low");
      require(tokensPurchased[_msgSender()].add(amount) <= maxCommitment, "WIDPresale: maxCommitment reached");
      require(!isTeamMember(_msgSender()), "WIDPreslae: team member doesn't allow presale.");
      require(tokensSold.add(amount) <= hardCap, "WIDPresale: hardcap reached");

      tokensSold = tokensSold.add(amount);
      tokensPurchased[_msgSender()] = tokensPurchased[_msgSender()].add(amount);
      emit TokensPurchased(_msgSender(), amount);
    }
    
    function purchaseTokensManual(address investor, uint256 amount) external onlyOwner {
      require(!isClosed, "WIDPresale: sale closed");
      require(amount >= minCommitment, "WIDPresale: amount to low");
      require(tokensPurchased[investor].add(amount) <= maxCommitment, "WIDPresale: maxCommitment reached");
      require(!isTeamMember(investor), "WIDPreslae: team member doesn't allow presale.");
      require(tokensSold.add(amount) <= hardCap, "WIDPresale: hardcap reached");

      tokensSold = tokensSold.add(amount);
      tokensPurchased[investor] = tokensPurchased[investor].add(amount);
      emit TokensPurchased(investor, amount);
    }

    function closeSale() external onlyOwner {
      require(!isClosed, "WIDPresale: already closed");
      require(block.timestamp > endDate || tokensSold == hardCap, "WIDPresale: endDate not passed or hardcap not reached");
      require(tokensSold >= softCap, "WIDPresale: softCap not reached");
      isClosed = true;
    
      emit SaleClosed();
    }

    function claimTokens() external afterClosedSale {
      require(canClaimTokens, "WIDPresale: Claiming is not allowed yet!");
      require(tokensPurchased[_msgSender()] > 0, "WIDPresale: no tokens to claim");
      uint256 purchasedTokens = tokensPurchased[_msgSender()].mul(pricePresale).div(10**18);
      tokensPurchased[_msgSender()] = 0;
      widToken.transfer(_msgSender(), purchasedTokens);
      emit TokensClaimed(_msgSender(), purchasedTokens);
    }

    function releaseTokens() external {
      require(!isClosed, "WIDPresale: cannot release tokens for closed sale");
      require(softCap > 0, "WIDPresale: no softCap");
      require(block.timestamp > endDate, "WIDPresale: endDate not passed");
      require(tokensPurchased[_msgSender()] > 0, "WIDPresale: no tokens to release");
      require(tokensSold < softCap, "WIDPresale: softCap reached");

      uint256 purchasedTokens = tokensPurchased[_msgSender()];
      tokensPurchased[_msgSender()] = 0;
      _msgSender().transfer(purchasedTokens);
      emit TokensReleased(_msgSender(), purchasedTokens);
    }
    
    function withdrawAllWid() public onlyOwner afterClosedSale {
      require(canClaimTokens, "WIDPresale: Claiming is not allowed yet!");
      require(tokensForAdmin > 0, "WIDPresale: no tokens to claim");
      
      widToken.transfer(_msgSender(), tokensForAdmin);
      tokensForAdmin = 0;
      emit WithdrawAllWID(_msgSender());
    }
    
    function claimWidTeamMember() external afterClosedSale {
      require(canClaimTokens, "WIDPresale: Claiming is not allowed yet!");
      require(isTeamMember(_msgSender()), "WIDPresale: You are not WIDpresale Team member!");
      require(teamBalances[_msgSender()]>0, "WIDPresale: No tokens to claim!");
      
      widToken.transfer(_msgSender(), teamBalances[_msgSender()]);
      teamBalances[_msgSender()] = 0;
    }

    function tokensRemaining() external view returns (uint256) {
      return (hardCap.sub(tokensSold).mul(pricePresale).div(10**18));
    }

    function getTimeLeftEndDate() external view returns (uint256) {
      if (block.timestamp > endDate) {
        return 0;
      } else {
        return endDate.sub(block.timestamp);
      }
    }

    function getReservedTokens() external view returns (uint256) {
      return tokensPurchased[_msgSender()] > 0 ? tokensPurchased[_msgSender()].mul(pricePresale).div(10**18) : 0;
    }

    function withdrawETH() external onlyOwner afterClosedSale {
      _msgSender().transfer(address(this).balance);
    }

    receive() external payable {}
}