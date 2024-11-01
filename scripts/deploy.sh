#!/bin/bash

# 加载环境变量
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found."
    echo "Please create .env file with:"
    echo "PRIVATE_KEY=0x<your_private_key>"
    echo "HOLESKY_RPC_URL=https://eth-holesky.g.alchemy.com/v2/your-api-key"
    echo "ETHERSCAN_API_KEY=your-api-key"
    exit 1
fi

# 检查必需的环境变量
for var in PRIVATE_KEY HOLESKY_RPC_URL ETHERSCAN_API_KEY; do
    if [ -z "${!var}" ]; then
        echo "Error: $var environment variable is not set"
        echo "Please add to .env: $var=<value>"
        exit 1
    fi
done

# 检查私钥格式
if [[ ! "$PRIVATE_KEY" =~ ^0x ]]; then
    echo "Error: PRIVATE_KEY must start with '0x'"
    exit 1
fi

# 编译合约
echo "Building the project..."
forge clean
forge build --force
if [ $? -ne 0 ]; then
    echo "Build failed."
    exit 1
fi

# 部署合约
echo "Deploying contract to Holesky testnet..."
DEPLOY_OUTPUT=$(forge script script/DeployToken.s.sol \
    --rpc-url $HOLESKY_RPC_URL \
    --broadcast \
    --verify \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --private-key $PRIVATE_KEY)

if [ $? -eq 0 ]; then
    # Extract proxy address from the output using grep and awk
    PROXY_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "Proxy deployed at:" | awk '{print $4}')
    
    # Check if PROXY_ADDRESS was found
    if [ ! -z "$PROXY_ADDRESS" ]; then
        # Check if PROXY_ADDRESS already exists in .env
        if grep -q "PROXY_ADDRESS=" .env; then
            # Update existing PROXY_ADDRESS
            sed -i '' "s/PROXY_ADDRESS=.*/PROXY_ADDRESS=$PROXY_ADDRESS/" .env
        else
            # Add new PROXY_ADDRESS
            echo "PROXY_ADDRESS=$PROXY_ADDRESS" >> .env
        fi
        echo "PROXY_ADDRESS has been saved to .env file"
    fi
    
    echo "Deployment and verification completed successfully!"
else
    echo "Deployment failed!"
    exit 1
fi
