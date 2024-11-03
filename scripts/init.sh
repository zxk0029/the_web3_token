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
forge install OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit

# 直接创建精简的 remappings.txt
echo "Creating remappings.txt..."
cat > remappings.txt << EOF
@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/
@openzeppelin/=lib/openzeppelin-contracts/contracts/
forge-std/=lib/forge-std/src/
EOF

echo "Setup completed!"
