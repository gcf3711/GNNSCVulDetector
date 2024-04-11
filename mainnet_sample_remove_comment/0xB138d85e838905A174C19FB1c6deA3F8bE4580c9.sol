 
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

 

pragma solidity >=0.6.0 <0.8.0;



 

pragma solidity >=0.6.0 <0.8.0;





 
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

     
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

     
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

     
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

     
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

     
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

     
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

     
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

     
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

     
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

     
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

     
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

     
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

 

pragma solidity >=0.6.0 <0.8.0;



 
abstract contract Pausable is Context {
     
    event Paused(address account);

     
    event Unpaused(address account);

    bool private _paused;

     
    constructor () internal {
        _paused = false;
    }

     
    function paused() public view virtual returns (bool) {
        return _paused;
    }

     
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

     
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

     
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

     
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
 

pragma solidity ^0.7.6;







abstract contract StandardToken is Context, AccessControl, Pausable {
    using SafeMath for uint256;
    uint256 private _totalSupply = 0;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    bytes32 public constant PAUSE_MANAGER_ROLE = keccak256("PAUSE_MANAGER_ROLE");


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }


    function name() public view returns(string memory) {
        return _name;
    }


    function symbol() public view returns(string memory) {
        return _symbol;
    }


    function decimals() public view returns(uint8) {
        return _decimals;
    }


    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public virtual view returns(uint256);


    function transfer(address recipient, uint256 amount) public virtual returns(bool);


    function pause() public {
        require(hasRole(PAUSE_MANAGER_ROLE, msg.sender), "StandardToken: must have pauser manager role to pause");
        _pause();
    }


    function unpause() public {
        require(hasRole(PAUSE_MANAGER_ROLE, msg.sender), "StandardToken: must have pauser manager role to unpause");
        _unpause();
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal view {
        require(!paused(), "StandardToken: token transfer while paused");
        require(from != address(0), "StandardToken: transfer from the zero address");
        require(to != address(0), "StandardToken: transfer to the zero address");
    }


    function setTotalSupply(uint256 amount) internal {
        _totalSupply = amount;
    }


    function increaseTotalSupply(uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
    }


    function decreaseTotalSupply(uint256 amount) internal {
        _totalSupply = _totalSupply.sub(amount);
    }
}
 

pragma solidity ^0.7.6;








abstract contract AccountStorage is StandardToken {

    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    struct AccountData {
        address sponsor;
        uint256 balance;
        uint256 selfBuy;
        uint256 directBonus;
        uint256 reinvestedAmount;
        uint256 withdrawnAmount;
        int256 stakingValue;
    }


    struct MigrationData {
        address account;
        address sponsor;
        uint256 tokensToMint;
        uint256 selfBuy;
    }


    bool private _accountsMigrated = false;

    EnumerableSet.AddressSet private _accounts;
    mapping (address => AccountData) private _accountsData;

    bytes32 constant public ACCOUNT_MANAGER_ROLE = keccak256("ACCOUNT_MANAGER_ROLE");

    event AccountCreation(address indexed account, address indexed sponsor);
    event AccountMigrationFinished();
    event DirectBonusPaid(address indexed account, address indexed fromAccount, uint256 amountOfEthereum);
    event AccountSponsorUpdated(address indexed account, address indexed oldSponsor, address indexed newSponsor);


    modifier isRegistered(address account) {
        require(_accountsMigrated, "AccountStorage: account data isn't migrated yet, try later");
        require(hasAccount(account), "AccountStorage: account must be registered first");
        _;
    }


    modifier hasEnoughBalance(uint256 amount) {
        require(amount <= balanceOf(msg.sender), "AccountStorage: insufficient account balance");
        _;
    }


    modifier hasEnoughAvailableEther(uint256 amount) {
        uint256 totalBonus = totalBonusOf(msg.sender);
        require(totalBonus > 0, "AccountStorage: you don't have any available ether");
        require(amount <= totalBonus, "AccountStorage: you don't have enough available ether to perform operation");
        _;
    }


    constructor() {
        addAccountData(address(this), address(0));
    }


    function migrateAccount(address account, address sponsor, uint256 tokensToMint, uint256 selfBuy) public {
        MigrationData[] memory data = new MigrationData[](1);
        data[0] = MigrationData(account, sponsor, tokensToMint, selfBuy);
        migrateAccountsInBatch(data);
    }


    function migrateAccountsInBatch(MigrationData[] memory data) public {
        require(hasRole(ACCOUNT_MANAGER_ROLE, msg.sender), "AccountStorage: must have account manager role to migrate data");
        require(!_accountsMigrated, "AccountStorage: account data migration method is no more available");

        for (uint i = 0; i < data.length; i += 1) {
            address curAddress = data[i].account;
            address curSponsorAddress = data[i].sponsor;
            uint256 tokensToMint = data[i].tokensToMint;
            uint256 selfBuy = data[i].selfBuy;
            if (curSponsorAddress == address(0)) {
                curSponsorAddress = address(this);
            }
            addAccountData(curAddress, curSponsorAddress);
            _accounts.add(curAddress);

            increaseTotalSupply(tokensToMint);
            increaseBalanceOf(curAddress, tokensToMint);
            increaseSelfBuyOf(curAddress, selfBuy);
            emit AccountCreation(curAddress, curSponsorAddress);
        }
    }


    function isDataMigrated() public view returns(bool) {
        return _accountsMigrated;
    }


    function finishAccountMigration() public {
        require(hasRole(ACCOUNT_MANAGER_ROLE, msg.sender), "AccountStorage: must have account manager role to migrate data");
        require(!_accountsMigrated, "AccountStorage: account data migration method is no more available");

        _accountsMigrated = true;
        emit AccountMigrationFinished();
    }


    function createAccount(address sponsor) public returns(bool) {
        require(_accountsMigrated, "AccountStorage: account data isn't migrated yet, try later");
        require(!hasAccount(msg.sender), "AccountStorage: account already exists");

        address account = msg.sender;

        if (sponsor == address(0)) {
            sponsor = address(this);
        }

        addAccountData(account, sponsor);
        _accounts.add(account);

        emit AccountCreation(account, sponsor);
        return true;
    }


    function setSponsorFor(address account, address newSponsor) public {
        require(hasRole(ACCOUNT_MANAGER_ROLE, msg.sender), "AccountStorage: must have account manager role to change sponsor for account");
        address oldSponsor = _accountsData[account].sponsor;
        _accountsData[account].sponsor = newSponsor;
        emit AccountSponsorUpdated(account, oldSponsor, newSponsor);
    }


    function getAccountsCount() public view returns(uint256) {
        return _accounts.length();
    }


    function hasAccount(address account) public view returns(bool) {
        return _accounts.contains(account);
    }


    function sponsorOf(address account) public view returns(address) {
        return _accountsData[account].sponsor;
    }


    function selfBuyOf(address account) public view returns(uint256) {
        return _accountsData[account].selfBuy;
    }


    function balanceOf(address account) public override view returns(uint256) {
        return _accountsData[account].balance;
    }


    function directBonusOf(address account) public view returns(uint256) {
        return _accountsData[account].directBonus;
    }


    function withdrawnAmountOf(address account) public view returns(uint256) {
        return _accountsData[account].withdrawnAmount;
    }


    function reinvestedAmountOf(address account) public view returns(uint256) {
        return _accountsData[account].reinvestedAmount;
    }


    function stakingBonusOf(address account) public virtual view returns(uint256);


    function totalBonusOf(address account) public view returns(uint256) {
        return directBonusOf(account) + stakingBonusOf(account) - withdrawnAmountOf(account) - reinvestedAmountOf(account);
    }


    function increaseSelfBuyOf(address account, uint256 amount) internal {
        _accountsData[account].selfBuy =_accountsData[account].selfBuy.add(amount);
    }


    function increaseBalanceOf(address account, uint256 amount) internal {
        _accountsData[account].balance = _accountsData[account].balance.add(amount);
    }


    function decreaseBalanceOf(address account, uint256 amount) internal {
        _accountsData[account].balance = _accountsData[account].balance.sub(amount, "AccountStorage: amount exceeds balance");
    }


    function addDirectBonusTo(address account, uint256 amount) internal {
        _accountsData[account].directBonus = _accountsData[account].directBonus.add(amount);
        emit DirectBonusPaid(account, msg.sender, amount);
    }


    function addWithdrawnAmountTo(address account, uint256 amount) internal {
        _accountsData[account].withdrawnAmount = _accountsData[account].withdrawnAmount.add(amount);
    }


    function addReinvestedAmountTo(address account, uint256 amount) internal {
        _accountsData[account].reinvestedAmount = _accountsData[account].reinvestedAmount.add(amount);
    }


    function stakingValueOf(address account) internal view returns(int256) {
        return _accountsData[account].stakingValue;
    }


    function increaseStakingValueFor(address account, int256 amount) internal {
        _accountsData[account].stakingValue += amount;
    }


    function decreaseStakingValueFor(address account, int256 amount) internal {
        _accountsData[account].stakingValue -= amount;
    }


    function addAccountData(address account, address sponsor) private {
        AccountData memory accountData = AccountData({
            sponsor: sponsor,
            balance: 0,
            selfBuy: 0,
            directBonus: 0,
            reinvestedAmount: 0,
            withdrawnAmount: 0,
            stakingValue: 0
        });
        _accountsData[account] = accountData;
    }
}

 

pragma solidity ^0.7.6;






abstract contract Founder is AccountStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private FOUNDER_INVESTMENT_CAP_BONUS = 20 ether;
    bytes32 constant public FOUNDER_MANAGER_ROLE = keccak256("FOUNDER_MANAGER_ROLE");

    EnumerableSet.AddressSet private _founderAccounts;

    event FounderInvestmentCapBonusUpdate(uint256 newInvestmentCapBonus);


    function isFounder(address account) public view returns(bool) {
        return _founderAccounts.contains(account);
    }


    function getFoundersCount() public view returns(uint256) {
        return _founderAccounts.length();
    }


    function setFounderInvestmentCapBonus(uint256 investmentCapBonus) public {
        require(hasRole(FOUNDER_MANAGER_ROLE, msg.sender), "Founder: must have founder manager role set investment cap bonus for founders");
        FOUNDER_INVESTMENT_CAP_BONUS = investmentCapBonus;

        emit FounderInvestmentCapBonusUpdate(investmentCapBonus);
    }


    function getFounderInvestmentCapBonus() public view returns(uint256){
        return FOUNDER_INVESTMENT_CAP_BONUS;
    }


    function addFounder(address account) public returns(bool) {
        require(hasRole(FOUNDER_MANAGER_ROLE, msg.sender), "Founder: must have founder manager role to add founder");
        return _founderAccounts.add(account);
    }


    function removeFounder(address account) public returns(bool) {
        require(hasRole(FOUNDER_MANAGER_ROLE, msg.sender), "Founder: must have founder manager role to remove founder");
        return _founderAccounts.remove(account);
    }


    function dropFounderOnSell(address account) internal returns(bool) {
        return _founderAccounts.remove(account);
    }


    function founderInvestmentBonusCapFor(address account) internal view returns(uint256) {
        return isFounder(account) ? getFounderInvestmentCapBonus() : 0;
    }
}

 

pragma solidity ^0.7.6;





abstract contract Price is StandardToken {
    using SafeMath for uint256;

    uint256 constant private INITIAL_TOKEN_PRICE = 0.0000001 ether;
    uint256 constant private INCREMENT_TOKEN_PRICE = 0.00000001 ether;


    function tokenPrice() public view returns(uint256) {
        return tokensToEthereum(1 ether);
    }


    function ethereumToTokens(uint256 _ethereum) internal view returns(uint256) {
        uint256 _tokenPriceInitial = INITIAL_TOKEN_PRICE * 1e18;
        uint256 _tokensReceived =
        (
        (
         
        SafeMath.sub(
            (sqrt
        (
            (_tokenPriceInitial**2)
            +
            (2*(INCREMENT_TOKEN_PRICE * 1e18)*(_ethereum * 1e18))
            +
            (((INCREMENT_TOKEN_PRICE)**2)*(totalSupply()**2))
            +
            (2*(INCREMENT_TOKEN_PRICE)*_tokenPriceInitial*totalSupply())
        )
            ), _tokenPriceInitial
        )
        )/(INCREMENT_TOKEN_PRICE)
        )-(totalSupply())
        ;

        return _tokensReceived;
    }


    function tokensToEthereum(uint256 _tokens) internal view returns(uint256) {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (totalSupply() + 1e18);
        uint256 _etherReceived =
        (
         
        SafeMath.add(
            (
            (
            (
            INITIAL_TOKEN_PRICE + (INCREMENT_TOKEN_PRICE * (_tokenSupply / 1e18))
            ) - INCREMENT_TOKEN_PRICE
            ) * (tokens_ - 1e18)
            ), (INCREMENT_TOKEN_PRICE * ((tokens_ ** 2 - tokens_) / 1e18)) / 2
        )
        /1e18);
        return _etherReceived;
    }


    function sqrt(uint x) internal pure returns(uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

 

pragma solidity ^0.7.6;





contract Company is AccessControl {
    using SafeMath for uint256;

    uint256 private COMPANY_FEE = 41;
    uint256 private _companyBalance = 0;

    event CompanyWithdraw(address indexed account, uint256 amount);
    event CompanyFeeUpdate(uint256 fee);

    bytes32 public constant COMPANY_MANAGER_ROLE = keccak256("COMPANY_MANAGER_ROLE");


    function companyBalance() public view returns(uint256) {
        return _companyBalance;
    }


    function getCompanyFee() public view returns(uint256) {
        return COMPANY_FEE;
    }


    function setCompanyFee(uint256 fee) public {
        require(hasRole(COMPANY_MANAGER_ROLE, msg.sender), "Company: must have company manager role");
        COMPANY_FEE = fee;

        emit CompanyFeeUpdate(fee);
    }


    function withdrawCompanyBalance(uint256 amount) public {
        require(hasRole(COMPANY_MANAGER_ROLE, msg.sender), "Company: must have company manager role");
        require(amount <= _companyBalance, "Company: insufficient company balance");
        require(amount <= address(this).balance, "Company: insufficient contract balance");

        msg.sender.transfer(amount);
        _companyBalance = _companyBalance.add(amount);

        emit CompanyWithdraw(msg.sender, amount);
    }


    function increaseCompanyBalance(uint256 amount) internal {
        _companyBalance = _companyBalance.add(amount);
    }


    function calculateCompanyFee(uint256 amount) internal view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, COMPANY_FEE), 100);
    }
}

 

pragma solidity ^0.7.6;






abstract contract DirectBonus is AccountStorage {

    using SafeMath for uint256;

    uint256 private DIRECT_BONUS_FEE = 10;
    uint256 private MINIMUM_SELF_BUY_FOR_DIRECT_BONUS = 0.001 ether;

    bytes32 public constant DIRECT_BONUS_MANAGER_ROLE = keccak256("DIRECT_BONUS_MANAGER_ROLE");

    event MinimumSelfBuyForDirectBonusUpdate(uint256 amount);
    event DirectBonusFeeUpdate(uint256 fee);


    function getDirectBonusFee() public view returns(uint256) {
        return DIRECT_BONUS_FEE;
    }


    function setDirectBonusFee(uint256 fee) public {
        require(hasRole(DIRECT_BONUS_MANAGER_ROLE, msg.sender), "DirectBonus: must have direct bonus manager role to set direct bonus fee");
        DIRECT_BONUS_FEE = fee;

        emit DirectBonusFeeUpdate(fee);
    }


    function getMinimumSelfBuyForDirectBonus() public view returns(uint256) {
        return MINIMUM_SELF_BUY_FOR_DIRECT_BONUS;
    }


    function setMinimumSelfBuyForDirectBonus(uint256 amount) public {
        require(hasRole(DIRECT_BONUS_MANAGER_ROLE, msg.sender), "DirectBonus: must have direct bonus manager role to set minimum self buy for direct bonus");
        MINIMUM_SELF_BUY_FOR_DIRECT_BONUS = amount;

        emit MinimumSelfBuyForDirectBonusUpdate(amount);
    }


    function calculateDirectBonus(uint256 amount) internal view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, DIRECT_BONUS_FEE), 100);
    }


    function isEligibleForDirectBonus(address sponsor) internal view returns(bool) {
        return (selfBuyOf(sponsor) >= MINIMUM_SELF_BUY_FOR_DIRECT_BONUS);
    }
}

 

pragma solidity ^0.7.6;






abstract contract Emergency is Founder {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 constant public EMERGENCY_MANAGER_ROLE = keccak256("EMERGENCY_MANAGER_ROLE");

    EnumerableSet.AddressSet private _emergencyVotes;

    uint256 private _emergencyThresholdCount;
    bool private _emergencyVotingStarted = false;

    event EmergencyVotingStarted();
    event EmergencyWithdraw(address account, uint256 amount);


    function isEmergencyCase() public view returns(bool) {
        return _emergencyVotingStarted;
    }


    function emergencyContractBalanceWithdraw() public {
        require(hasRole(EMERGENCY_MANAGER_ROLE, msg.sender), "Emergency: you're not allowed to do this");
        require(emergencyVotesCount() >= emergencyVotingThresholdCount(), "Emergency: not enough votes for performing emergency withdraw");

        msg.sender.transfer(address(this).balance);
        emit EmergencyWithdraw(msg.sender, address(this).balance);
    }


    function voteForEmergencyCase() public returns(bool) {
        require(_emergencyVotingStarted, "Emergency: emergency voting is not activated");
        require(isFounder(msg.sender), "Emergency: only founders have right to vote for emergency cases");

        return _emergencyVotes.add(msg.sender);
    }


    function emergencyVotesCount() public view returns(uint256) {
        return _emergencyVotes.length();
    }


    function emergencyVotingThresholdCount() public view returns(uint256) {
        return _emergencyThresholdCount;
    }


    function hasVotedForEmergency(address account) public view returns(bool) {
        return _emergencyVotes.contains(account);
    }


    function startEmergencyVote(uint256 thresholdCount) public {
        require(hasRole(EMERGENCY_MANAGER_ROLE, msg.sender), "Emergency: you're not allowed to start emergency vote");
        require(0 < thresholdCount && thresholdCount <= getFoundersCount(), "Emergency: please set right threshold");

        _emergencyVotingStarted = true;
        _emergencyThresholdCount = thresholdCount;

        emit EmergencyVotingStarted();
    }
}

 

pragma solidity ^0.7.6;





abstract contract Sale is Founder {
    using SafeMath for uint256;

    uint private _saleStartBlockNumber = 0;
    bytes32 public constant SALE_MANAGER_ROLE = keccak256("SALE_MANAGER_ROLE");

    event SaleStarted(uint atBlockNumber, uint atTimestamp);
    event NewSaleStartBlock(uint atBlockNumber, uint atTimestamp);


    modifier canInvest(uint256 amount) {
        require(selfBuyOf(msg.sender) + amount <= getInvestmentCap() + founderInvestmentBonusCapFor(msg.sender), "Sale: you can't invest more than current investment cap");
        _;
    }


    function getInvestmentCap() public view returns(uint256) {
        if (_saleStartBlockNumber == 0)
            return 0 ether;
        uint256 currentBlockNumberFromSaleStart = block.number - _saleStartBlockNumber;
        if (currentBlockNumberFromSaleStart <= 1250000)
            return 31680000 * (currentBlockNumberFromSaleStart**2) + 1 ether;
        if (currentBlockNumberFromSaleStart <= 2500000)
            return 100 ether - 31680000 * (currentBlockNumberFromSaleStart - 2500000)**2;
        return 100 ether;
    }


    function startSale() public {
        require(hasRole(SALE_MANAGER_ROLE, msg.sender), "Sale: must have sale manager role");
        require(_saleStartBlockNumber == 0, "Sale: start sale method is no more available");

        _saleStartBlockNumber = block.number;

        emit SaleStarted(block.number, block.timestamp);
    }


    function moveSaleForwardBy(uint256 blocks) public {
        require(hasRole(SALE_MANAGER_ROLE, msg.sender), "Sale: must have sale manager role");
        require(_saleStartBlockNumber > 0, "Sale: sale forward move method is not available yet, start sale first");
        require(blocks < _saleStartBlockNumber, "Sale: you can't move sale start from zero block");

        _saleStartBlockNumber = _saleStartBlockNumber.sub(blocks);
        emit NewSaleStartBlock(_saleStartBlockNumber, block.timestamp);
    }
}

 

pragma solidity ^0.7.6;







abstract contract Staking is AccountStorage, Price {
    using SafeMath for uint256;

    uint256 private _stakingProfitPerShare;

    bytes32 public constant STAKING_MANAGER_ROLE = keccak256("STAKING_MANAGER_ROLE");
    bytes32 public constant LOYALTY_BONUS_MANAGER_ROLE = keccak256("LOYALTY_BONUS_MANAGER_ROLE");

    uint256 constant private MAGNITUDE = 2 ** 64;
    uint256 private STAKING_FEE = 8;

    event StakingFeeUpdate(uint256 fee);
    event LoyaltyBonusStaked(uint256 amount);


    function getStakingFee() public view returns(uint256) {
        return STAKING_FEE;
    }


    function setStakingFee(uint256 fee) public {
        require(hasRole(STAKING_MANAGER_ROLE, msg.sender), "Staking: must have staking manager role to set staking fee");
        STAKING_FEE = fee;

        emit StakingFeeUpdate(fee);
    }


    function stakeLoyaltyBonus() public payable {
        require(hasRole(LOYALTY_BONUS_MANAGER_ROLE, msg.sender), "Staking: must have loyalty bonus manager role to stake bonuses");
        increaseStakingProfitPerShare(msg.value);

        emit LoyaltyBonusStaked(msg.value);
    }


    function stakingBonusOf(address account) public override view returns(uint256) {
        return (uint256) ((int256)(_stakingProfitPerShare * balanceOf(account)) - stakingValueOf(account)) / MAGNITUDE;
    }


    function calculateStakingFee(uint256 amount) internal view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, STAKING_FEE), 100);
    }


    function increaseStakingProfitPerShare(uint256 stakingBonus) internal {
        _stakingProfitPerShare += (stakingBonus * MAGNITUDE / totalSupply());
    }


    function processStakingOnBuy(address account, uint256 amountOfTokens, uint256 stakingBonus) internal {
        uint256 stakingFee = stakingBonus * MAGNITUDE;

        if (totalSupply() > 0) {
            increaseTotalSupply(amountOfTokens);
            increaseStakingProfitPerShare(stakingBonus);
            stakingFee = amountOfTokens * (stakingBonus * MAGNITUDE / totalSupply());
        } else {
            setTotalSupply(amountOfTokens);
        }

        int256 stakingPayout = (int256) (_stakingProfitPerShare * amountOfTokens - stakingFee);
        increaseStakingValueFor(account, stakingPayout);
    }


    function processStakingOnSell(address account, uint256 amountOfTokens) internal returns(uint256) {
        uint256 ethereum = tokensToEthereum(amountOfTokens);
        uint256 stakingFee = calculateStakingFee(ethereum);
        uint256 taxedEthereum = SafeMath.sub(ethereum, stakingFee);

        int256 stakingValueUpdate = (int256) (_stakingProfitPerShare * amountOfTokens);
        decreaseStakingValueFor(account, stakingValueUpdate);

        if (totalSupply() > 0) {
            increaseStakingProfitPerShare(stakingFee);
        }
        return taxedEthereum;
    }


    function processDistributionOnTransfer(address sender, uint256 amountOfTokens, address recipient, uint256 taxedTokens) internal {
        uint256 stakedBonus = tokensToEthereum(SafeMath.sub(amountOfTokens, taxedTokens));

        decreaseStakingValueFor(sender, (int256) (_stakingProfitPerShare * amountOfTokens));
        increaseStakingValueFor(recipient, (int256) (_stakingProfitPerShare * taxedTokens));

        increaseStakingProfitPerShare(stakedBonus);
    }

}

 

pragma solidity ^0.7.6;











contract BXFToken is Staking, Company, Sale, DirectBonus, Emergency {

    using SafeMath for uint256;

    event BXFBuy(address indexed account, uint256 ethereumInvested, uint256 taxedEthereum, uint256 tokensMinted);
    event BXFSell(address indexed account, uint256 tokenBurned, uint256 ethereumGot);
    event BXFReinvestment(address indexed account, uint256 ethereumReinvested, uint256 tokensMinted);
    event Withdraw(address indexed account, uint256 ethereumWithdrawn);
    event Transfer(address indexed from, address indexed to, uint256 value);


    constructor(string memory name, string memory symbol) StandardToken(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    fallback() external payable {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "BXFToken: you're not allowed to do this");
    }


    function buy() public payable isRegistered(msg.sender) {
        (uint256 taxedEthereum, uint256 amountOfTokens) = purchaseTokens(msg.sender, msg.value);

        emit Transfer(address(0), msg.sender, amountOfTokens);
        emit BXFBuy(msg.sender, msg.value, taxedEthereum, amountOfTokens);
    }


    function sell(uint256 amountOfTokens) public isRegistered(msg.sender) hasEnoughBalance(amountOfTokens) {
        address account = msg.sender;

        decreaseTotalSupply(amountOfTokens);
        decreaseBalanceOf(account, amountOfTokens);

        if (isFounder(account)) dropFounderOnSell(account);

        uint256 taxedEthereum = processStakingOnSell(account, amountOfTokens);

        msg.sender.transfer(taxedEthereum);

        emit Transfer(account, address(0), amountOfTokens);
        emit BXFSell(account, amountOfTokens, taxedEthereum);
    }


    function withdraw(uint256 amountToWithdraw) public isRegistered(msg.sender) hasEnoughAvailableEther(amountToWithdraw) {
        require(amountToWithdraw <= address(this).balance, "BXFToken: insufficient contract balance");

        address account = msg.sender;
        addWithdrawnAmountTo(account, amountToWithdraw);
        msg.sender.transfer(amountToWithdraw);

        emit Withdraw(account, amountToWithdraw);
    }


    function reinvest(uint256 amountToReinvest) public isRegistered(msg.sender) hasEnoughAvailableEther(amountToReinvest) {
        address account = msg.sender;

        addReinvestedAmountTo(account, amountToReinvest);
        (uint256 taxedEthereum, uint256 amountOfTokens) = purchaseTokens(account, amountToReinvest);

        emit Transfer(address(0), account, amountOfTokens);
        emit BXFReinvestment(account, amountToReinvest, amountOfTokens);
    }


    function exit() public isRegistered(msg.sender) {
        address account = msg.sender;
        if (balanceOf(account) > 0) {
            sell(balanceOf(account));
        }
        if (totalBonusOf(account) > 0) {
            withdraw(totalBonusOf(account));
        }
    }


    function transfer(address recipient, uint256 amount) public override hasEnoughBalance(amount) returns(bool) {
        address sender = msg.sender;

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 stakingFee = calculateStakingFee(amount);
        uint256 taxedTokens = SafeMath.sub(amount, stakingFee);

        decreaseTotalSupply(stakingFee);

        decreaseBalanceOf(sender, amount);
        increaseBalanceOf(recipient, taxedTokens);

        processDistributionOnTransfer(sender, amount, recipient, taxedTokens);

        emit Transfer(sender, address(0), stakingFee);
        emit Transfer(sender, recipient, taxedTokens);
        return true;
    }


    function purchaseTokens(address senderAccount, uint256 amountOfEthereum) internal canInvest(amountOfEthereum) returns(uint256, uint256) {
        uint256 taxedEthereum = amountOfEthereum;

        uint256 companyFee = calculateCompanyFee(amountOfEthereum);
        uint256 directBonus = calculateDirectBonus(amountOfEthereum);
        uint256 stakingFee = calculateStakingFee(amountOfEthereum);

        taxedEthereum = taxedEthereum.sub(companyFee);
        increaseCompanyBalance(companyFee);

        address account = senderAccount;
        address sponsor = sponsorOf(account);
        increaseSelfBuyOf(account, amountOfEthereum);


        if (sponsor == address(this)) {
            increaseCompanyBalance(directBonus);
            taxedEthereum = taxedEthereum.sub(directBonus);
        } else if (isEligibleForDirectBonus(sponsor)) {
            addDirectBonusTo(sponsor, directBonus);
            taxedEthereum = taxedEthereum.sub(directBonus);
        }

        taxedEthereum = taxedEthereum.sub(stakingFee);

        uint256 amountOfTokens = ethereumToTokens(taxedEthereum);

        processStakingOnBuy(senderAccount, amountOfTokens, stakingFee);
        increaseBalanceOf(senderAccount, amountOfTokens);

        return (taxedEthereum, amountOfTokens);
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

 

pragma solidity >=0.6.0 <0.8.0;

 
library EnumerableSet {
     
     
     
     
     
     
     
     

    struct Set {
         
        bytes32[] _values;

         
         
        mapping (bytes32 => uint256) _indexes;
    }

     
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
             
             
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

     
    function _remove(Set storage set, bytes32 value) private returns (bool) {
         
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {  
             
             
             

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

             
             

            bytes32 lastvalue = set._values[lastIndex];

             
            set._values[toDeleteIndex] = lastvalue;
             
            set._indexes[lastvalue] = toDeleteIndex + 1;  

             
            set._values.pop();

             
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

     
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

     
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

     

    struct Bytes32Set {
        Set _inner;
    }

     
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

     
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

     
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

     
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

     

    struct AddressSet {
        Set _inner;
    }

     
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

     
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


     

    struct UintSet {
        Set _inner;
    }

     
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

     
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

     
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}
