// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

contract TheWeb3TokenV1 is ERC20, Initializable, UUPSUpgradeable {
    address public owner;
    uint256 public remainingSupply;

    constructor() ERC20("the_web3", "WEB3") {
        _disableInitializers();
    }

    function initialize(uint256 initialSupply) public virtual initializer {
        require(initialSupply > 0, "Initial supply must be greater than 0");
        owner = msg.sender;
        remainingSupply = initialSupply;
        _mint(msg.sender, initialSupply);
    }

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
        // 只允许 owner 进行升级
    }

    function getRemainingSupply() external view virtual returns (uint256) {
        return remainingSupply;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
}
