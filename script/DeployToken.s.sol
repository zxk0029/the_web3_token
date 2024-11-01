// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/TheWeb3TokenV1.sol";
import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署实现合约
        TheWeb3TokenV1 implementation = new TheWeb3TokenV1();
        
        // 编码初始化数据
        bytes memory initData = abi.encodeWithSelector(
            TheWeb3TokenV1.initialize.selector,
            1000000 * 10**18  // 初始供应量：1,000,000 tokens
        );

        // 部署代理合约
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        vm.stopBroadcast();

        console.log("Proxy deployed at: %s", address(proxy));
        console.log("Implementation deployed at: %s", address(implementation));
    }
}
