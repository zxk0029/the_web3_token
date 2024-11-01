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

# 部署合约
echo "Deploying V1 contract..."
forge script script/DeployToken.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast

# 部署并升级到 V2
echo "Deploying and upgrading to V2..."
forge script script/DeployTokenV2.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast

echo "Local deployment completed!" 