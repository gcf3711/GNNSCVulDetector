
 

 

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

 

 

pragma solidity 0.5.17;


contract MerkleAirdrop {
    struct Airdrop {
        bytes32 root;
        string dataURI;
        bool paused;
        mapping(address => bool) awarded;
    }

     
    event Start(uint256 id);
    event PauseChange(uint256 id, bool paused);
    event Award(uint256 id, address recipient, uint256 amount);

     
    mapping(uint256 => Airdrop) public airdrops;
    IERC20 public token;
    uint256 public airdropsCount;

    address public core;

     
    string private constant ERROR_AWARDED = "AWARDED";
    string private constant ERROR_INVALID = "INVALID";
    string private constant ERROR_PAUSED = "PAUSED";
    string private constant ERROR_INVALID_BAL = "INVALID_BAL";

    modifier onlyCore() {
        require(msg.sender == core, "Not Authorized");
        _;
    }

    constructor() public {
        core = msg.sender;
    }

    function setToken(address _token) public onlyCore {
        token = IERC20(_token);
    }

     
    function start(bytes32 _root, string memory _dataURI) public onlyCore {
        require(token.balanceOf(address(this)) > 0, ERROR_INVALID_BAL);

        uint256 id = ++airdropsCount;  
        airdrops[id] = Airdrop(_root, _dataURI, false);
        emit Start(id);
    }

     
    function setPause(uint256 _id, bool _paused) public onlyCore {
        require(_id <= airdropsCount, ERROR_INVALID);
        airdrops[_id].paused = _paused;
        emit PauseChange(_id, _paused);
    }

     
    function removeToken() public onlyCore {
        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            token.transfer(core, balance);
        }
    }

     
    function award(
        uint256 _id,
        address _recipient,
        uint256 _amount,
        bytes32[] memory _proof
    ) public {
        require(_id <= airdropsCount, ERROR_INVALID);

        Airdrop storage airdrop = airdrops[_id];
        require(!airdrop.paused, ERROR_PAUSED);

        bytes32 hash = keccak256(abi.encodePacked(_recipient, _amount));
        require(validate(airdrop.root, _proof, hash), ERROR_INVALID);

        require(!airdrops[_id].awarded[_recipient], ERROR_AWARDED);

        airdrops[_id].awarded[_recipient] = true;

        uint256 bal = token.balanceOf(address(this));
        if (bal >= _amount) {
            token.transfer(_recipient, _amount);
        } else {
            revert("INVALID_CONTRACT_BALANCE");
        }

        emit Award(_id, _recipient, _amount);
    }

     
    function awardFromMany(
        uint256[] memory _ids,
        address _recipient,
        uint256[] memory _amounts,
        bytes memory _proofs,
        uint256[] memory _proofLengths
    ) public {
        uint256 totalAmount;

        uint256 marker = 32;

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            require(id <= airdropsCount, ERROR_INVALID);
            require(!airdrops[id].paused, ERROR_PAUSED);

            bytes32[] memory proof =
                extractProof(_proofs, marker, _proofLengths[i]);
            marker += _proofLengths[i] * 32;

            bytes32 hash = keccak256(abi.encodePacked(_recipient, _amounts[i]));
            require(validate(airdrops[id].root, proof, hash), ERROR_INVALID);

            require(!airdrops[id].awarded[_recipient], ERROR_AWARDED);

            airdrops[id].awarded[_recipient] = true;

            totalAmount += _amounts[i];

            emit Award(id, _recipient, _amounts[i]);
        }

        uint256 bal = token.balanceOf(address(this));
        if (bal >= totalAmount) {
            token.transfer(_recipient, totalAmount);
        } else {
            revert("INVALID_CONTRACT_BALANCE");
        }
    }

    function extractProof(
        bytes memory _proofs,
        uint256 _marker,
        uint256 proofLength
    ) public pure returns (bytes32[] memory proof) {
        proof = new bytes32[](proofLength);

        bytes32 el;

        for (uint256 j = 0; j < proofLength; j++) {
            assembly {
                el := mload(add(_proofs, _marker))
            }
            proof[j] = el;
            _marker += 32;
        }
    }

    function validate(
        bytes32 root,
        bytes32[] memory proof,
        bytes32 hash
    ) public pure returns (bool) {
        for (uint256 i = 0; i < proof.length; i++) {
            if (hash < proof[i]) {
                hash = keccak256(abi.encodePacked(hash, proof[i]));
            } else {
                hash = keccak256(abi.encodePacked(proof[i], hash));
            }
        }

        return hash == root;
    }

     
    function awarded(uint256 _id, address _recipient)
        public
        view
        returns (bool)
    {
        return airdrops[_id].awarded[_recipient];
    }
}