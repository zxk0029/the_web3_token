// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {TheWeb3TokenV2} from "../src/TheWeb3TokenV2.sol";
import {TheWeb3TokenV1} from "../src/TheWeb3TokenV1.sol";
import {TestSetup} from "./TestSetup.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

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
        assertEq(TheWeb3TokenV2(payable(address(proxy))).mintFee(), 0.01 ether);
    }
} 