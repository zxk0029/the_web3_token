#!/bin/bash

# 进入前端目录
cd frontend

# 安装依赖
pnpm install

# 复制合约 ABI
cp ../out/TheWeb3TokenV2.sol/TheWeb3TokenV2.json ./src/config/abi.json

# 启动开发服务器    
pnpm dev 

# todo: 完成 dapp 开发
# https://github.com/WTFAcademy/WTF-Dapp/blob/main/01_QuickStart/readme.md
# https://wagmi.sh/react/getting-started