#!/bin/bash

# 检查 anvil 是否已经运行
if ! nc -z localhost 8545 2>/dev/null; then
    echo "Starting Anvil..."
    anvil > anvil.log 2>&1 &
    sleep 2
fi

# 设置环境变量
export ANVIL_RPC_URL=http://localhost:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# PROXY_ADMIN_ADDRESS 是手动设置的管理员地址，有权限进行合约升级，更新代理合约指向新的实现合约
export PROXY_ADMIN_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

# 部署 V1 合约
echo "Deploying V1 contract..."
DEPLOY_OUTPUT=$(forge script script/DeployToken.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast 2>&1)

# 从部署输出中提取代理地址（PROXY_ADDRESS 是通过部署脚本自动获取的）
PROXY_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -o "Proxy deployed at: 0x[a-fA-F0-9]\{40\}")
if [ -n "$PROXY_ADDRESS" ]; then
    export PROXY_ADDRESS=${PROXY_ADDRESS#"Proxy deployed at: "}
    echo "Proxy deployed at: $PROXY_ADDRESS"

    # 部署并升级到 V2
    echo "Deploying and upgrading to V2..."
    forge script script/DeployTokenV2.s.sol \
        --rpc-url $ANVIL_RPC_URL \
        --private-key $PRIVATE_KEY \
        --broadcast
else
    echo "Failed to get proxy address from deployment output"
    exit 1
fi

echo "Local deployment completed!" 