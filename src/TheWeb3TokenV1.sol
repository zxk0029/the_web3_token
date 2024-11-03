// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract TheWeb3TokenV1 is Initializable, ERC20Upgradeable, UUPSUpgradeable {
    address public owner;
    uint256 public remainingSupply;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 initialSupply) public initializer {
        require(initialSupply > 0, "Initial supply must be greater than 0");
        owner = msg.sender;
        remainingSupply = initialSupply;
        _mint(msg.sender, initialSupply);
        __ERC20_init("the_web3", "WEB3");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
        // 只允许 owner 进行升级
    }

    function getRemainingSupply() external view virtual returns (uint256) {
        return remainingSupply;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}
