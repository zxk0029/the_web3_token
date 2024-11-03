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

    /**
     * @dev V2版本的初始化函数
     * reinitializer(2) 确保此函数只能被调用一次
     * 版本号2表示这是第二个版本的初始化
     * 注意：版本号必须大于之前的版本，且不能重复使用
     */
    function initializeV2() public reinitializer(2) {
        mintFee = 0.001 ether;
        MINT_LIMIT = 10 * 10 ** decimals();
        if (owner == address(0)) {
            owner = msg.sender;
        }
    }

    /**
     * @dev 升级授权函数，只有owner可以升级合约
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev 免费铸造函数，但有数量限制
     * @param amount 铸造数量
     */
    function mint(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(mintedAmount[msg.sender] + amount <= MINT_LIMIT, "Mint limit exceeded");
        require(amount <= remainingSupply, "Insufficient remaining supply");
        
        mintedAmount[msg.sender] += amount;
        remainingSupply -= amount;
        _mint(msg.sender, amount);
        
        emit Transfer(address(0), msg.sender, amount); // 标准 ERC20 事件
    }

    /**
     * @dev 付费铸造函数
     * @param amount 铸造数量
     */
    function mintWithFee(uint256 amount) external payable {
        require(msg.value >= mintFee, "Insufficient mint fee");
        require(amount > 0, "Amount must be greater than 0");
        require(mintedAmount[msg.sender] + amount <= MINT_LIMIT, "Mint limit exceeded");
        require(amount <= remainingSupply, "Insufficient remaining supply");
        
        mintedAmount[msg.sender] += amount;
        remainingSupply -= amount;
        _mint(msg.sender, amount);
        
        emit Transfer(address(0), msg.sender, amount); // 标准 ERC20 事件
    }

    /**
     * @dev 猜数字游戏，猜对可以获得代币奖励
     * @param guessedNumber 猜测的数字(1-6)
     */
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

    /**
     * @dev 提取合约中的ETH，只有owner可以调用
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }

    /**
     * @dev 获取剩余可铸造数量
     */
    function getRemainingSupply() external view override returns (uint256) {
        return remainingSupply;
    }

    /**
     * @dev 允许合约接收ETH
     */
    receive() external payable {}
}
