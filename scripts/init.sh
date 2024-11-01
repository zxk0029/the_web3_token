#!/bin/bash

# 检查是否已初始化 Foundry 项目
if [ -f foundry.toml ]; then
    echo "Foundry project already initialized."
else
    echo "Initializing Foundry project..."
    forge init

    # 添加 Solidity 编译器版本
    echo 'solc_version = "0.8.28"' >> foundry.toml
fi

# 安装 OpenZeppelin 合约库并避免 Git 提交冲突
echo "Installing OpenZeppelin Contracts..."
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# 从 OpenZeppelin Contracts 5.0 版本开始，openzeppelin-contracts 已经包含了所有可升级合约的内容，不再需要单独安装 openzeppelin-contracts-upgradeable
#forge install OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit


# 生成或更新 remappings.txt
echo "Generating remappings..."
forge remappings > remappings.txt

# 在 foundry.toml 中添加 remappings 配置
if ! grep -q "remappings" foundry.toml; then
    echo 'remappings = ["openzeppelin-contracts/=lib/openzeppelin-contracts/"]' >> foundry.toml
else
    echo "Remappings already configured in foundry.toml."
fi

echo "Setup completed!"
