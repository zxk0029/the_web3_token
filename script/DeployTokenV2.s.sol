// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {TheWeb3TokenV2} from "../src/TheWeb3TokenV2.sol";
import {TransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployTokenV2Script is Script {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        address proxyAdminAddress = vm.envAddress("PROXY_ADMIN_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // 部署新的实现合约
        TheWeb3TokenV2 tokenV2 = new TheWeb3TokenV2();

        // 获取 ProxyAdmin 实例
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);

        // 准备初始化数据
        bytes memory initData = abi.encodeWithSelector(
            TheWeb3TokenV2.initializeV2.selector
        );

        // 升级代理
        proxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(proxyAddress),
            address(tokenV2),
            initData
        );

        vm.stopBroadcast();
    }
}
