// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./TestSetup.sol";
import {TheWeb3TokenV2} from "../src/TheWeb3TokenV2.sol";
import {UUPSUpgradeable} from "@openzeppelin/proxy/utils/UUPSUpgradeable.sol";

contract TokenUpgradeTest is TestSetup {
    function test_UpgradeToV2() public {
        // 记录升级前的状态
        uint256 oldTotalSupply = TheWeb3TokenV1(address(proxy)).totalSupply();
        
        // 部署新的实现合约
        TheWeb3TokenV2 tokenV2 = new TheWeb3TokenV2();
        
        // 使用 owner 进行升级
        vm.prank(owner);
        UUPSUpgradeable(address(proxy)).upgradeToAndCall(address(tokenV2), "");
        
        // 初始化 V2
        TheWeb3TokenV2(payable(address(proxy))).initializeV2();
        
        // 验证升级后的状态
        TheWeb3TokenV2 proxyTokenV2 = TheWeb3TokenV2(payable(address(proxy)));
        assertEq(proxyTokenV2.owner(), owner);
        assertEq(proxyTokenV2.totalSupply(), oldTotalSupply);
        assertEq(proxyTokenV2.mintFee(), 0.001 ether);
    }
} 