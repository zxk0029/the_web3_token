// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/TheWeb3TokenV2.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployTokenV2 is Script {
    function run() external {
        // 获取代理合约地址
        address payable proxyAddress = payable(vm.envAddress("PROXY_ADDRESS"));
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署新的实现合约
        TheWeb3TokenV2 implementation = new TheWeb3TokenV2();

        // 将代理合约转换为 V2
        TheWeb3TokenV2 upgradedToken = TheWeb3TokenV2(proxyAddress);

        // 准备初始化调用数据
        bytes memory initData = abi.encodeWithSelector(TheWeb3TokenV2.initializeV2.selector);

        // 升级到新的实现并调用初始化函数
        upgradedToken.upgradeToAndCall(address(implementation), initData);

        console.log("Proxy Address: %s", address(upgradedToken));
        console.log("New Implementation Address: %s", address(implementation));
        console.log("Deployer Address: %s", msg.sender);
        console.log("Upgrade successful");
        console.log("New mint fee: %s", upgradedToken.mintFee());
        console.log("Mint limit: %s", upgradedToken.MINT_LIMIT());

        vm.stopBroadcast();
    }
}
