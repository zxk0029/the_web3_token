#!/bin/bash

# Load environment variables
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

# Check required environment variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable is not set"
    echo "Please add to .env: PRIVATE_KEY=0x<your_private_key>"
    exit 1
fi

if [ -z "$HOLESKY_RPC_URL" ]; then
    echo "Error: HOLESKY_RPC_URL environment variable is not set"
    echo "Please add to .env: HOLESKY_RPC_URL=https://eth-holesky.g.alchemy.com/v2/your-api-key"
    exit 1
fi

if [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "Error: ETHERSCAN_API_KEY environment variable is not set"
    echo "Please add to .env: ETHERSCAN_API_KEY=your-api-key"
    exit 1
fi

# Check PRIVATE_KEY format
if [[ ! "$PRIVATE_KEY" =~ ^0x ]]; then
    echo "Error: PRIVATE_KEY must start with '0x'"
    echo "Please update your .env file with the correct format"
    exit 1
fi

# Check required environment variables
if [ -z "$PROXY_ADDRESS" ]; then
    echo "Error: PROXY_ADDRESS environment variable is not set"
    exit 1
fi

# Clean and build
echo "Building the project..."
forge clean
forge build --force
if [ $? -ne 0 ]; then
    echo "Build failed."
    exit 1
fi

# Provide upgrade steps information
echo "This script will perform the following steps:"
echo "1. Deploy TokenV2 implementation"
echo "2. Upgrade proxy to V2"

# # Ask for confirmation
# echo -e "\nAre you sure you want to proceed with the upgrade process? (y/n)"
# read -r response
# if [[ ! "$response" =~ ^[Yy]$ ]]; then
#     echo "Operation cancelled"
#     exit 1
# fi

echo "Step 1: Deploy TokenV2 implementation"
forge script script/DeployTokenV2.s.sol \
    --rpc-url $HOLESKY_RPC_URL \
    --broadcast \
    --verify \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --private-key $PRIVATE_KEY

if [ $? -eq 0 ]; then
    echo "Upgrade process completed successfully!"
else
    echo "Upgrade process failed!"
    exit 1
fi
