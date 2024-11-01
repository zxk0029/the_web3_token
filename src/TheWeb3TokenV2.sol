// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./TheWeb3TokenV1.sol";

contract TheWeb3TokenV2 is TheWeb3TokenV1 {
    uint256 public mintFee;
    uint256 public MINT_LIMIT;

    mapping(address => uint256) public mintedAmount;
    mapping(address => bool) public taskCompleted;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() TheWeb3TokenV1() {
        _disableInitializers();
    }

    function initializeV2() public reinitializer(2) {
        mintFee = 0.001 ether;
        MINT_LIMIT = 10 * 10 ** decimals();
        if (owner == address(0)) {
            owner = msg.sender;
        }
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    modifier onlyOwner() override {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function mint(uint256 amount) external {
        // Convert amount to tokens with decimals
        uint256 tokenAmount = amount * 10 ** decimals();
        
        require(mintedAmount[msg.sender] + tokenAmount <= MINT_LIMIT, "Mint limit exceeded");
        require(tokenAmount <= remainingSupply, "Insufficient remaining supply");
        
        mintedAmount[msg.sender] += tokenAmount;
        remainingSupply -= tokenAmount;
        _mint(msg.sender, tokenAmount);
    }

    function mintWithFee(uint256 amount) external payable {
        // Convert amount to tokens with decimals
        uint256 tokenAmount = amount * 10 ** decimals();
        
        require(msg.value >= mintFee, "Insufficient mint fee");
        require(tokenAmount <= remainingSupply, "Insufficient remaining supply");
        
        remainingSupply -= tokenAmount;
        _mint(msg.sender, tokenAmount);
    }

    function completeGuess(uint8 guessedNumber) external payable {
        require(guessedNumber >= 1 && guessedNumber <= 6, "Guess must be between 1 and 6");
        uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 6 + 1);

        if (guessedNumber == randomNumber) {
            uint256 ethReward = 0.001 ether;
            uint256 tokenReward = randomNumber * 10 ** decimals();
            require(tokenReward <= remainingSupply, "Insufficient remaining supply");
            
            remainingSupply -= tokenReward;
            payable(msg.sender).transfer(ethReward);
            _mint(msg.sender, tokenReward);
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }

    function getRemainingSupply() external view override returns (uint256) {
        return remainingSupply;
    }

    receive() external payable {}
}
