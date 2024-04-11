// SPDX-License-Identifier: GPL-3.0-or-later"


// "

pragma solidity 0.7.6;




interface IDerivativeSpecification {
    
    
    
    function isDerivativeSpecification() external pure returns (bool);

    
    /// between the start and the end of the Live period
    
    
    function oracleSymbols() external view returns (bytes32[] memory);

    
    /// finds the value closest to a given timestamp
    
    
    function oracleIteratorSymbols() external view returns (bytes32[] memory);

    
    
    
    function collateralTokenSymbol() external view returns (bytes32);

    
    /// and the initial collateral split to the final collateral split
    
    
    function collateralSplitSymbol() external view returns (bytes32);

    
    
    
    function livePeriod() external view returns (uint256);

    
    
    
    function primaryNominalValue() external view returns (uint256);

    
    
    
    function complementNominalValue() external view returns (uint256);

    
    
    
    function authorFee() external view returns (uint256);

    
    
    
    function symbol() external view returns (string memory);

    
    
    
    function name() external view returns (string memory);

    
    
    
    function baseURI() external view returns (string memory);

    
    
    
    function author() external view returns (address);
}
// "

pragma solidity 0.7.6;




contract DerivativeSpecification is IDerivativeSpecification {
    function isDerivativeSpecification() external pure override returns (bool) {
        return true;
    }

    string internal symbol_;

    bytes32[] internal oracleSymbols_;
    bytes32[] internal oracleIteratorSymbols_;
    bytes32 internal collateralTokenSymbol_;
    bytes32 internal collateralSplitSymbol_;

    uint256 internal livePeriod_;

    uint256 internal primaryNominalValue_;
    uint256 internal complementNominalValue_;

    uint256 internal authorFee_;

    string internal name_;
    string private baseURI_;
    address internal author_;

    function name() external view virtual override returns (string memory) {
        return name_;
    }

    function baseURI() external view virtual override returns (string memory) {
        return baseURI_;
    }

    function symbol() external view virtual override returns (string memory) {
        return symbol_;
    }

    function oracleSymbols()
        external
        view
        virtual
        override
        returns (bytes32[] memory)
    {
        return oracleSymbols_;
    }

    function oracleIteratorSymbols()
        external
        view
        virtual
        override
        returns (bytes32[] memory)
    {
        return oracleIteratorSymbols_;
    }

    function collateralTokenSymbol()
        external
        view
        virtual
        override
        returns (bytes32)
    {
        return collateralTokenSymbol_;
    }

    function collateralSplitSymbol()
        external
        view
        virtual
        override
        returns (bytes32)
    {
        return collateralSplitSymbol_;
    }

    function livePeriod() external view virtual override returns (uint256) {
        return livePeriod_;
    }

    function primaryNominalValue()
        external
        view
        virtual
        override
        returns (uint256)
    {
        return primaryNominalValue_;
    }

    function complementNominalValue()
        external
        view
        virtual
        override
        returns (uint256)
    {
        return complementNominalValue_;
    }

    function authorFee() external view virtual override returns (uint256) {
        return authorFee_;
    }

    function author() external view virtual override returns (address) {
        return author_;
    }

    constructor(
        address _author,
        string memory _name,
        string memory _symbol,
        bytes32[] memory _oracleSymbols,
        bytes32[] memory _oracleIteratorSymbols,
        bytes32 _collateralTokenSymbol,
        bytes32 _collateralSplitSymbol,
        uint256 _livePeriod,
        uint256 _primaryNominalValue,
        uint256 _complementNominalValue,
        uint256 _authorFee,
        string memory _baseURI
    ) public {
        author_ = _author;
        name_ = _name;
        symbol_ = _symbol;
        oracleSymbols_ = _oracleSymbols;
        oracleIteratorSymbols_ = _oracleIteratorSymbols;
        collateralTokenSymbol_ = _collateralTokenSymbol;
        collateralSplitSymbol_ = _collateralSplitSymbol;
        livePeriod_ = _livePeriod;
        primaryNominalValue_ = _primaryNominalValue;
        complementNominalValue_ = _complementNominalValue;
        authorFee_ = _authorFee;
        baseURI_ = _baseURI;
    }
}

// 
pragma solidity >=0.6.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}
