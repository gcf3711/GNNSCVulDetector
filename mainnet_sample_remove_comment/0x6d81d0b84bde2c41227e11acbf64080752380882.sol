 
pragma abicoder v2;


 

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
 
pragma solidity ^0.7.6;


interface IVault {
    function setBalance(address _voter, uint256 _amount) external;
    function deposit(uint256 _amount) external;
    function claimUSDH(address _voter) external returns (uint256);
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
 
pragma solidity ^0.7.6;






contract WeekVault is IVault, Ownable {
    struct Share {
        uint256 amount;
        uint256 uncounted;
        uint256 counted;
    }

    address[] voters;
    mapping (address => uint256) voterIds;
    mapping (address => uint256) voterClaims;

    mapping (address => uint256) public totalRewardsToVoter;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalRewards;
    uint256 public totalDistributed;
    uint256 public rewardsPerShare;
    uint256 public constant decimals = 10 ** 36;

    address public vehrd;
    IERC20 public immutable USDH;

    bool public canSetVEHRD = true;

    constructor () {
        vehrd = msg.sender;
        USDH = IERC20(0xe350E32ca91B04F2D7307185BB352F0b7E7BcE35);
    }

    function _getCumulativeUSDH(uint256 _share) private view returns (uint256) {
        return _share * rewardsPerShare / decimals;
    }

    function setBalance(address _voter, uint256 _amount) external override {
        require(msg.sender == vehrd);
        if (_amount > 0 && shares[_voter].amount == 0) {
            voterIds[_voter] = voters.length;
            voters.push(_voter);
        } else if (_amount == 0 && shares[_voter].amount > 0) {
            voters[voterIds[_voter]] = voters[voters.length - 1];
            voterIds[voters[voters.length - 1]] = voterIds[_voter];
            voters.pop();
        }
        totalShares = totalShares - shares[_voter].amount + _amount;
        shares[_voter].amount = _amount;
        shares[_voter].uncounted = _getCumulativeUSDH(shares[_voter].amount);
    }

    function claimUSDH(address _voter) external override returns (uint256) {
        require(msg.sender == vehrd);
        if (shares[_voter].amount == 0) return 0;
        uint256 _amount = getUnclaimedUSDH(_voter);
        if (_amount > 0) {
            voterClaims[_voter] = block.timestamp;
            shares[_voter].counted = shares[_voter].counted + _amount;
            shares[_voter].uncounted = _getCumulativeUSDH(shares[_voter].amount);
            USDH.transfer(vehrd, _amount);
            totalDistributed = totalDistributed + _amount;
            totalRewardsToVoter[_voter] = totalRewardsToVoter[_voter] + _amount;
            return _amount;
        } else {
            return 0;
        }
    }

    function deposit(uint256 _amount) external override {
        require(msg.sender == vehrd);
        require(USDH.balanceOf(msg.sender) >= _amount, "Insufficient Balance");
        require(USDH.allowance(msg.sender, address(this)) >= _amount, "Insufficient Allowance");
        uint256 balance = USDH.balanceOf(address(this));
        USDH.transferFrom(msg.sender, address(this), _amount);
        require(USDH.balanceOf(address(this)) == balance + _amount, "Transfer Failed");
        totalRewards = totalRewards + _amount;
        rewardsPerShare = rewardsPerShare + (decimals * _amount / totalShares);
    }

    function getUnclaimedUSDH(address _voter) public view returns (uint256) {
        if (shares[_voter].amount == 0) return 0;
        uint256 _voterRewards = _getCumulativeUSDH(shares[_voter].amount);
        uint256 _voterUncounted = shares[_voter].uncounted;
        if (_voterRewards <= _voterUncounted) return 0;
        return _voterRewards - _voterUncounted;
    }

    function getClaimedRewardsTotal() external view returns (uint256) {
        return totalDistributed;
    }

    function getClaimedRewards(address _voter) external view returns (uint256) {
        return totalRewardsToVoter[_voter];
    }

    function getLastClaim(address _voter) external view returns (uint256) {
        return voterClaims[_voter];
    }

    function balanceOf(address _voter) external view returns (uint256) {
        return shares[_voter].amount;
    }

    function setVEHRD(address _vehrd, bool _canSetVEHRD) external onlyOwner {
        require(canSetVEHRD);
        vehrd = _vehrd;
        canSetVEHRD = _canSetVEHRD;
    }

    function rescue(address token) external onlyOwner {
        if (token == 0x0000000000000000000000000000000000000000) {
            payable(msg.sender).call{value: address(this).balance}("");
        } else {
            require(token != address(USDH));
            IERC20 Token = IERC20(token);
            Token.transfer(msg.sender, Token.balanceOf(address(this)));
        }
    }

    receive() external payable {}
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
