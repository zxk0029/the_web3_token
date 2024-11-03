#!/bin/bash

set -e  # 遇到错误立即退出

# 函数：显示使用说明
show_usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  start    - Start local node and deploy contracts"
    echo "  stop     - Stop local node"
    echo "  restart  - Restart local node and deploy contracts"
    echo "  status   - Check if local node is running"
}

# 函数：设置环境变量
setup_env() {
    export ANVIL_RPC_URL=http://localhost:8545
    export ANVIL_LOG_FILE="anvil.log"
    # PRIVATE_KEY 和 PROXY_ADMIN_ADDRESS 使用的是 anvil启动后，自动生成的账户
    export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
    # PROXY_ADMIN_ADDRESS 是手动设置的管理员地址，有权限进行合约升级，更新代理合约指向新的实现合约
    export PROXY_ADMIN_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
}

# 函数：部署合约
deploy_contracts() {
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
        return 1
    fi
}

# 启动 Anvil 并等待它准备就绪
start_anvil() {
    echo "Starting Anvil..."
    anvil > $ANVIL_LOG_FILE 2>&1 &
    
    # 等待 Anvil 启动，最多等待 10 秒
    for i in {1..10}; do
        if nc -z localhost 8545 2>/dev/null; then
            echo "Anvil is ready!"
            return 0
        fi
        echo "Waiting for Anvil to start... ($i/10)"
        sleep 1
    done
    
    echo "Failed to start Anvil"
    return 1
}

# 函数：停止 Anvil
stop_anvil() {
    if nc -z localhost 8545 2>/dev/null; then
        echo "Stopping Anvil..."
        pkill anvil
        [ -f "$ANVIL_LOG_FILE" ] && rm "$ANVIL_LOG_FILE"
        echo "Anvil stopped"
    else
        echo "Anvil is not running"
    fi
}

# 函数：检查 Anvil 状态
check_status() {
    if nc -z localhost 8545 2>/dev/null; then
        echo "Anvil is running"
        ps aux | grep anvil | grep -v grep
        
        # 如果存在代理地址，显示它
        if [ -n "$PROXY_ADDRESS" ]; then
            echo "Current proxy address: $PROXY_ADDRESS"
        fi
    else
        echo "Anvil is not running"
    fi
}

# 设置环境变量
setup_env

# 主逻辑
case "$1" in
    start)
        if start_anvil; then
            setup_env
            deploy_contracts
            echo "Local environment started and contracts deployed!"
        else
            echo "Failed to start local environment"
            exit 1
        fi
        ;;
    stop)
        stop_anvil
        echo "Local environment stopped!"
        ;;
    restart)
        stop_anvil
        sleep 2
        if start_anvil; then
            setup_env
            deploy_contracts
            echo "Local environment restarted and contracts redeployed!"
        else
            echo "Failed to restart local environment"
            exit 1
        fi
        ;;
    status)
        check_status
        ;;
    *)
        show_usage
        exit 1
        ;;
esac