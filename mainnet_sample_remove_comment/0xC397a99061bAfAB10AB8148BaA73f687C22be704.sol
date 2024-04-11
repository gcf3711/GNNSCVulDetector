 


 
pragma solidity ^0.7.6;



contract DSMath {
    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(x, y);
    }

    function sub(uint256 x, uint256 y)
        internal
        pure
        virtual
        returns (uint256 z)
    {
        z = SafeMath.sub(x, y);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.mul(x, y);
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.div(x, y);
    }

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
    }

    function toInt(uint256 x) internal pure returns (int256 y) {
        y = int256(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint256 wad) internal pure returns (uint256 rad) {
        rad = mul(wad, 10**27);
    }
}

 
pragma solidity ^0.7.6;



abstract contract Stores {
     
    address internal constant ethAddr =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

     
    address internal constant wethAddr =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

     
    MemoryInterface internal constant stakeAllMemory =
        MemoryInterface(0x0A25F019be4C4aAa0B04C0d43dff519dc720D275);

    uint256 public constant PORTIONS_SUM = 1000000;

     
    function getUint(uint256 getId, uint256 val)
        internal
        returns (uint256 returnVal)
    {
        returnVal = getId == 0 ? val : stakeAllMemory.getUint(getId);
    }

     
    function setUint(uint256 setId, uint256 val) internal virtual {
        if (setId != 0) stakeAllMemory.setUint(setId, val);
    }
}
 
pragma solidity ^0.7.6;





abstract contract Basic is DSMath, Stores {
    function convert18ToDec(uint256 _dec, uint256 _amt)
        internal
        pure
        returns (uint256 amt)
    {
        amt = (_amt / 10**(18 - _dec));
    }

    function convertTo18(uint256 _dec, uint256 _amt)
        internal
        pure
        returns (uint256 amt)
    {
        amt = mul(_amt, 10**(18 - _dec));
    }

    function getTokenBal(TokenInterface token)
        internal
        view
        returns (uint256 _amt)
    {
        _amt = address(token) == ethAddr
            ? address(this).balance
            : token.balanceOf(address(this));
    }

    function getTokensDec(TokenInterface buyAddr, TokenInterface sellAddr)
        internal
        view
        returns (uint256 buyDec, uint256 sellDec)
    {
        buyDec = address(buyAddr) == ethAddr ? 18 : buyAddr.decimals();
        sellDec = address(sellAddr) == ethAddr ? 18 : sellAddr.decimals();
    }

    function encodeEvent(string memory eventName, bytes memory eventParam)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encode(eventName, eventParam);
    }

    function approve(
        TokenInterface token,
        address spender,
        uint256 amount
    ) internal {
        try token.approve(spender, amount) {} catch {
            token.approve(spender, 0);
            token.approve(spender, amount);
        }
    }

    function changeEthAddress(address buy, address sell)
        internal
        pure
        returns (TokenInterface _buy, TokenInterface _sell)
    {
        _buy = buy == ethAddr ? TokenInterface(wethAddr) : TokenInterface(buy);
        _sell = sell == ethAddr
            ? TokenInterface(wethAddr)
            : TokenInterface(sell);
    }

    function convertEthToWeth(
        bool isEth,
        TokenInterface token,
        uint256 amount
    ) internal {
        if (isEth) token.deposit{value: amount}();
    }

    function convertWethToEth(
        bool isEth,
        TokenInterface token,
        uint256 amount
    ) internal {
        if (isEth) {
            approve(token, address(token), amount);
            token.withdraw(amount);
        }
    }
}

 
pragma solidity ^0.7.6;





abstract contract Helpers is DSMath, Basic {
    enum DelegationType {
        VOTING_POWER,
        PROPOSITION_POWER,
        BOTH
    }

     
    StakedAaveInterface internal constant stkAave =
        StakedAaveInterface(0x4da27a545c0c5B758a6BA100e3a049001de870f5);

     
    AaveInterface internal constant aave =
        AaveInterface(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);

    function _delegateAave(address _delegatee, DelegationType _type) internal {
        if (_type == DelegationType.BOTH) {
            require(
                aave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );
            require(
                aave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            aave.delegate(_delegatee);
        } else if (_type == DelegationType.VOTING_POWER) {
            require(
                aave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );

            aave.delegateByType(_delegatee, 0);
        } else {
            require(
                aave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            aave.delegateByType(_delegatee, 1);
        }
    }

    function _delegateStakedAave(address _delegatee, DelegationType _type)
        internal
    {
        if (_type == DelegationType.BOTH) {
            require(
                stkAave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );
            require(
                stkAave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            stkAave.delegate(_delegatee);
        } else if (_type == DelegationType.VOTING_POWER) {
            require(
                stkAave.getDelegateeByType(address(this), 0) != _delegatee,
                "already-delegated"
            );

            stkAave.delegateByType(_delegatee, 0);
        } else {
            require(
                stkAave.getDelegateeByType(address(this), 1) != _delegatee,
                "already-delegated"
            );

            stkAave.delegateByType(_delegatee, 1);
        }
    }
}

 
pragma solidity ^0.7.6;

contract Events {
    event LogClaim(uint256 amt, uint256 getId, uint256 setId);
    event LogStake(uint256 amt, uint256 getId, uint256 setId);
    event LogCooldown();
    event LogRedeem(uint256 amt, uint256 getId, uint256 setId);
    event LogDelegate(
        address delegatee,
        bool delegateAave,
        bool delegateStkAave,
        uint8 aaveDelegationType,
        uint8 stkAaveDelegationType
    );
}

 
pragma solidity ^0.7.6;

interface TokenInterface {
    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function deposit() external payable;

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function decimals() external view returns (uint256);
}
 
pragma solidity ^0.7.6;

 




abstract contract AaveResolver is Helpers, Events {
     
    function claim(
        uint256 amount,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amount);

        uint256 intialBal = aave.balanceOf(address(this));
        stkAave.claimRewards(address(this), _amt);
        uint256 finalBal = aave.balanceOf(address(this));
        _amt = sub(finalBal, intialBal);

        setUint(setId, _amt);

        _eventName = "LogClaim(uint256,uint256,uint256)";
        _eventParam = abi.encode(_amt, getId, setId);
    }

     
    function stake(
        uint256 amount,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amount);

        _amt = _amt == uint256(-1) ? aave.balanceOf(address(this)) : _amt;
        stkAave.stake(address(this), _amt);

        setUint(setId, _amt);

        _eventName = "LogStake(uint256,uint256,uint256)";
        _eventParam = abi.encode(_amt, getId, setId);
    }

     
    function cooldown()
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        require(stkAave.balanceOf(address(this)) > 0, "no-staking");

        stkAave.cooldown();

        _eventName = "LogCooldown()";
    }

     
    function redeem(
        uint256 amount,
        uint256 getId,
        uint256 setId
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        uint256 _amt = getUint(getId, amount);

        uint256 intialBal = aave.balanceOf(address(this));
        stkAave.redeem(address(this), _amt);
        uint256 finalBal = aave.balanceOf(address(this));
        _amt = sub(finalBal, intialBal);

        setUint(setId, _amt);

        _eventName = "LogRedeem(uint256,uint256,uint256)";
        _eventParam = abi.encode(_amt, getId, setId);
    }

     
    function delegate(
        address delegatee,
        bool delegateAave,
        bool delegateStkAave,
        uint8 aaveDelegationType,
        uint8 stkAaveDelegationType
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        require(delegateAave || delegateStkAave, "invalid-delegate");
        require(delegatee != address(0), "invalid-delegatee");

        if (delegateAave) {
            _delegateAave(
                delegatee,
                Helpers.DelegationType(aaveDelegationType)
            );
        }

        if (delegateStkAave) {
            _delegateStakedAave(
                delegatee,
                Helpers.DelegationType(stkAaveDelegationType)
            );
        }

        _eventName = "LogDelegate(address,bool,bool,uint8,uint8)";
        _eventParam = abi.encode(
            delegatee,
            delegateAave,
            delegateStkAave,
            aaveDelegationType,
            stkAaveDelegationType
        );
    }
}

 
pragma solidity ^0.7.6;



interface AaveInterface is TokenInterface {
    function delegate(address delegatee) external;

    function delegateByType(address delegatee, uint8 delegationType) external;

    function getDelegateeByType(address delegator, uint8 delegationType)
        external
        view
        returns (address);
}

contract ConnectV2AaveStake is AaveResolver {
    string public constant name = "Aave-Stake-v1";
}

interface StakedAaveInterface is AaveInterface {
    function stake(address onBehalfOf, uint256 amount) external;

    function redeem(address to, uint256 amount) external;

    function cooldown() external;

    function claimRewards(address to, uint256 amount) external;
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

interface MemoryInterface {
    function getUint(uint256 id) external returns (uint256 num);

    function setUint(uint256 id, uint256 val) external;
}

interface AccountInterface {
    function enable(address) external;

    function disable(address) external;

    function isAuth(address) external view returns (bool);
}
