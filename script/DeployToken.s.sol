// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/TheWeb3TokenV1.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployToken is Script {
    // 预期的管理员地址
    address constant EXPECTED_ADMIN_ADDRESS = 0x0dc831B7b64F369AAde6738653626d6C159aA3B1;
    
    // 初始供应量常量
    uint256 constant INITIAL_SUPPLY = 1024 * 10 ** 18;

    function run() external {
        // 使用最终管理员的私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // 确保使用正确的地址
        require(deployer == EXPECTED_ADMIN_ADDRESS, "Wrong deployer address");

        vm.startBroadcast(deployerPrivateKey);

        // 1. 部署 ProxyAdmin
        ProxyAdmin proxyAdmin = new ProxyAdmin(deployer);
        console.log("ProxyAdmin deployed to:", address(proxyAdmin));

        // 2. 部署逻辑合约
        TheWeb3TokenV1 logic = new TheWeb3TokenV1();
        console.log("Logic contract deployed to:", address(logic));

        // 3. 编码初始化数据
        bytes memory data = abi.encodeWithSelector(
            TheWeb3TokenV1.initialize.selector,
            INITIAL_SUPPLY
        );

        // 4. 部署代理合约
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(logic),
            address(proxyAdmin),
            data
        );

        // 5. 验证部署
        TheWeb3TokenV1 token = TheWeb3TokenV1(address(proxy));
        require(token.owner() == deployer, "Initialization failed: wrong owner");
        require(token.totalSupply() == INITIAL_SUPPLY, "Initialization failed: wrong supply");
        require(token.remainingSupply() == INITIAL_SUPPLY, "Initialization failed: wrong remaining supply");

        vm.stopBroadcast();
        
        console.log("Proxy deployed to:", address(proxy));
        console.log("Deployment completed by:", deployer);
        console.log("Initial supply:", INITIAL_SUPPLY);
        console.log("Owner:", token.owner());
    }
}
