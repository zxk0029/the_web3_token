// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./TheWeb3TokenV1.sol";

contract TheWeb3TokenV2 is TheWeb3TokenV1 {
    uint256 public mintFee;
    uint256 public constant MINT_LIMIT = 10 * 10 ** 18;

    mapping(address => uint256) public mintedAmount;
    mapping(address => bool) public taskCompleted;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() TheWeb3TokenV1() {
        _disableInitializers();
    }

    function initializeV2() public reinitializer(2) {
        mintFee = 0.01 ether;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    modifier onlyOwner() override {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function mint(uint256 amount) external {
        require(mintedAmount[msg.sender] + amount <= MINT_LIMIT, "Mint limit exceeded");
        require(amount <= remainingSupply, "Insufficient remaining supply");
        
        mintedAmount[msg.sender] += amount;
        remainingSupply -= amount;
        _mint(msg.sender, amount);
    }

    function mintWithFee(uint256 amount) external payable {
        require(msg.value >= mintFee, "Insufficient mint fee");
        require(amount <= remainingSupply, "Insufficient remaining supply");
        
        remainingSupply -= amount;
        _mint(msg.sender, amount);
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
        payable(owner).transfer(address(this).balance);
    }

    function getRemainingSupply() external view override returns (uint256) {
        return remainingSupply;
    }
}
