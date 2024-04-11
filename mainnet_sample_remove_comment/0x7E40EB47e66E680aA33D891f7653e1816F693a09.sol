
 

pragma solidity ^0.5.17;

interface IProofOfHumanity {
     
    function isRegistered(address _submissionID) external view returns (bool);

     
    function submissionCounter() external view returns (uint256);
}

 
interface IERC20 {
    function balanceOf(address _human) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

 
contract UBIProxy {
    IProofOfHumanity public PoH;
    IERC20 public UBI;
    address public governor = msg.sender;
    string public name = "UBI Vote";
    string public symbol = "UBIVOTE";
    uint8 public decimals = 18;

     
    constructor(IProofOfHumanity _PoH, IERC20 _UBI) public {
        PoH = _PoH;
        UBI = _UBI;
    }

     
    function changePoH(IProofOfHumanity _PoH) external {
        require(msg.sender == governor, "The caller must be the governor.");
        PoH = _PoH;
    }

     
    function changeUBI(IERC20 _UBI) external {
        require(msg.sender == governor, "The caller must be the governor.");
        UBI = _UBI;
    }

     
    function changeGovernor(address _governor) external {
        require(msg.sender == governor, "The caller must be the governor.");
        governor = _governor;
    }

     
    function isRegistered(address _submissionID) public view returns (bool) {
        return PoH.isRegistered(_submissionID);
    }

     
    function sqrt(uint256 x) private pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

     
     
     

     
    function balanceOf(address _submissionID) external view returns (uint256) {
        return
            isRegistered(_submissionID)
                ? sqrt(UBI.balanceOf(_submissionID))
                : 0;
    }

     
    function totalSupply() external view returns (uint256) {
        return UBI.totalSupply();
    }

    function transfer(address _recipient, uint256 _amount)
        external
        returns (bool)
    {
        return false;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {}

    function approve(address _spender, uint256 _amount)
        external
        returns (bool)
    {
        return false;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool) {
        return false;
    }
}