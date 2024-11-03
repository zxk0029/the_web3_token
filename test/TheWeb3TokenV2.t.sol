// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {TheWeb3TokenV2} from "../src/TheWeb3TokenV2.sol";
import {TheWeb3TokenV1} from "../src/TheWeb3TokenV1.sol";
import {TestSetup} from "./TestSetup.sol";
import {UUPSUpgradeable} from "@openzeppelin/proxy/utils/UUPSUpgradeable.sol";

contract TheWeb3TokenV2Test is TestSetup {
    TheWeb3TokenV2 public tokenV2;
    
    function setUp() public override {
        super.setUp();
        
        vm.startPrank(owner);
        
        // 部署新的实现合约
        tokenV2 = new TheWeb3TokenV2();
        
        // 使用 UUPS 升级
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(address(tokenV2), "");
        
        // 初始化 V2
        TheWeb3TokenV2(payable(address(proxy))).initializeV2();
        
        vm.stopPrank();
    }
    
    function test_UpgradeToV2() public view {
        assertEq(TheWeb3TokenV2(payable(address(proxy))).owner(), owner);
        assertEq(TheWeb3TokenV2(payable(address(proxy))).mintFee(), 0.001 ether);
    }
    
    function test_MintWithFee() public {
        address user = address(0x123);
        uint256 amount = 1 * 10 ** 18; // 1 token
        
        vm.deal(user, 1 ether); // 给测试用户一些 ETH
        
        vm.startPrank(user);
        TheWeb3TokenV2(payable(address(proxy))).mintWithFee{value: 0.01 ether}(amount);
        vm.stopPrank();
        
        // 验证用户收到了代币
        assertEq(TheWeb3TokenV2(payable(address(proxy))).balanceOf(user), amount);
        // 验证铸造记录更新了
        assertEq(TheWeb3TokenV2(payable(address(proxy))).mintedAmount(user), amount);
    }
    
    function test_Mint() public {
        uint256 mintAmount = 1 * 10**tokenV2.decimals();
        
        // Test zero amount first
        vm.expectRevert("Amount must be greater than 0");
        TheWeb3TokenV2(payable(address(proxy))).mint(0);
        
        // Test normal mint
        TheWeb3TokenV2(payable(address(proxy))).mint(mintAmount);
        assertEq(TheWeb3TokenV2(payable(address(proxy))).balanceOf(address(this)), mintAmount);
        
        // Test single large mint exceeding limit
        uint256 overLimit = 11 * 10**tokenV2.decimals();
        vm.expectRevert("Mint limit exceeded");
        TheWeb3TokenV2(payable(address(proxy))).mint(overLimit);
        
        // Test accumulated mints reaching limit
        for(uint i = 0; i < 9; i++) {
            TheWeb3TokenV2(payable(address(proxy))).mint(mintAmount);
        }
        
        // This should exceed the limit (1 + 9 = 10 tokens already minted)
        vm.expectRevert("Mint limit exceeded");
        TheWeb3TokenV2(payable(address(proxy))).mint(mintAmount);
    }
    
    function test_MintWithDifferentUsers() public {
        address user1 = address(1);
        address user2 = address(2);
        
        vm.startPrank(user1);
        uint256 mintAmount = 5 * 10**tokenV2.decimals();
        TheWeb3TokenV2(payable(address(proxy))).mint(mintAmount);
        assertEq(TheWeb3TokenV2(payable(address(proxy))).balanceOf(user1), mintAmount);
        vm.stopPrank();
        
        vm.startPrank(user2);
        TheWeb3TokenV2(payable(address(proxy))).mint(mintAmount);
        assertEq(TheWeb3TokenV2(payable(address(proxy))).balanceOf(user2), mintAmount);
        vm.stopPrank();
    }
} 