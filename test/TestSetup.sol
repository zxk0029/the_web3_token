// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {TheWeb3TokenV1} from "../src/TheWeb3TokenV1.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TestSetup is Test {
    TheWeb3TokenV1 public tokenV1;
    ERC1967Proxy public proxy;
    
    address public owner;
    address public user1;
    address public user2;
    
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;
    
    function setUp() public virtual {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        vm.startPrank(owner);
        
        // 部署实现合约
        tokenV1 = new TheWeb3TokenV1();
        
        // 准备初始化数据
        bytes memory initData = abi.encodeWithSelector(
            TheWeb3TokenV1.initialize.selector,
            INITIAL_SUPPLY
        );
        
        // 部署代理
        proxy = new ERC1967Proxy(
            address(tokenV1),
            initData
        );
        
        vm.stopPrank();
    }
} 