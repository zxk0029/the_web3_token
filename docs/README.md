# Web3 Token 项目文档

## 目录
1. [项目结构](#项目结构)
2. [快速开始](#快速开始)
3. [合约说明](#合约说明)
4. [脚本说明](#脚本说明)
5. [测试说明](#测试说明)
6. [部署地址](#部署地址)
7. [常见问题](#常见问题)
8. [贡献指南](#贡献指南)
9. [许可证](#许可证)

## 项目结构
```
project/
├── src/                    # 合约源码
│   ├── TheWeb3TokenV1.sol  # V1 合约实现
│   └── TheWeb3TokenV2.sol  # V2 合约实现
├── script/                 # 部署脚本
│   ├── DeployToken.s.sol   # V1 部署脚本
│   └── DeployTokenV2.s.sol # V2 部署脚本
├── test/                   # 测试文件
│   ├── TheWeb3Token.t.sol  # V1 测试
│   └── TheWeb3TokenV2.t.sol# V2 测试
├── scripts/                # Shell 脚本
│   ├── init.sh            # 项目初始化脚本
│   ├── deploy.sh          # 部署脚本
│   └── upgrade.sh         # 升级脚本
│   └── local.sh           # 本地开发脚本
└── docs/                   # 项目文档
```

## 快速开始

### 1. 环境设置
```bash
# 初始化项目
./scripts/init.sh

# 创建 .env 文件并填入以下内容：
PRIVATE_KEY=0x<your_private_key>
HOLESKY_RPC_URL=https://eth-holesky.g.alchemy.com/v2/your-api-key
ETHERSCAN_API_KEY=your-api-key
```

### 2. 本地开发
```bash
# 启动本地测试网络
anvil

# Anvil 会输出类似以下信息：
# Available Accounts
# ==================
# (0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
# (1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
# ...
#
# Private Keys
# ==================
# (0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# (1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
# ...

# 在新的终端窗口，使用 anvil 生成的测试账户
# 选择其中一个私钥（例如第一个账户的私钥）
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80  # Anvil 第一个账户的私钥
export ANVIL_RPC_URL=http://localhost:8545

# 部署到本地网络
forge script script/DeployToken.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast

# 升级到 V2
forge script script/DeployTokenV2.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

注意：
- Anvil 启动时会生成 10 个测试账户
- 每个账户都有 10000 ETH
- 使用生成的私钥中的任意一个即可
- 这些账户和私钥仅用于本地测试，不要在实际网络中使用

### 3. 测试
```bash
# 运行所有测试
forge test

# 测试特定文件
forge test --match-path test/TheWeb3Token.t.sol -vvv

# 测试特定函数
forge test --match-path test/TheWeb3Token.t.sol --match-test test_Initialize

# 显示测试覆盖率
forge coverage

# 显示 gas 报告
forge test --gas-report
```

### 4. 部署
```bash
# 部署 V1 合约
./scripts/deploy.sh

# 升级到 V2
./scripts/upgrade.sh
```

### 5. 本地开发
```bash
# 检查 anvil 是否运行
if ! nc -z localhost 8545 2>/dev/null; then
    echo "Starting Anvil..."
    anvil > anvil.log 2>&1 &
    sleep 2
fi

# 设置环境变量
export ANVIL_RPC_URL=http://localhost:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# 部署合约
forge script script/DeployToken.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast

# 部署并升级到 V2
forge script script/DeployTokenV2.s.sol
```

## 合约说明

### TheWeb3TokenV1
- 基础 ERC20 代币实现
- 使用 UUPS 代理模式支持升级
- 主要功能：
  - 代币铸造
  - 代币转账
  - 所有权管理

### TheWeb3TokenV2
- V1 的升级版本
- 新增功能：
  - 铸币费用系统
    - 设置铸币费用 (mintFee = 0.01 ETH)
    - 每个地址最大铸币限制 (MINT_LIMIT = 10 tokens)
  
  - 多种铸币方式
    - 普通铸币 (mint): 无需支付 ETH，但有数量限制
    - 付费铸币 (mintWithFee): 支付 ETH 铸币，需要支付铸币费用
  
  - 猜数字游戏系统 (completeGuess)
    - 用户猜测 1-6 之间的数字
    - 猜对可获得 ETH 奖励 (0.001 ETH)
    - 猜对可获得代币奖励 (随机数 * 10^18 tokens)
    - TODO: 将 block.timestamp 随机数改为 [Chainlink VRF 等安全的链下随机数源](https://www.wtf.academy/docs/solidity-103/Random/)
  
  - 合约管理功能
    - 提现功能 (withdraw): 管理员可提取合约中的 ETH
    - 铸币记录追踪: 记录每个地址的铸币数量
    
- 功能变更：
  - 重写了 getRemainingSupply 函数
  - 增强了 onlyOwner 修饰器
  - 添加了合约余额管理

## 脚本说明

### init.sh
初始化脚本，包含：
```bash
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

# 安装 OpenZeppelin 合约库
echo "Installing OpenZeppelin Contracts..."
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# 生成 remappings
echo "Generating remappings..."
forge remappings > remappings.txt

# 配置 remappings
if ! grep -q "remappings" foundry.toml; then
    echo 'remappings = ["@openzeppelin/=lib/openzeppelin-contracts/"]' >> foundry.toml
fi
```

### deploy.sh
部署脚本，包含：
```bash
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
        exit 1
    fi
done

# 部署合约
forge script script/DeployToken.s.sol:DeployToken \
    --rpc-url $HOLESKY_RPC_URL \
    --broadcast \
    --verify \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --private-key $PRIVATE_KEY
```

### upgrade.sh
升级脚本，包含：
```bash
#!/bin/bash

# 加载环境变量检查（同 deploy.sh）

# 部署和升级
forge script script/DeployTokenV2.s.sol \
    --rpc-url $HOLESKY_RPC_URL \
    --broadcast \
    --verify \
    --etherscan-api-key ${ETHERSCAN_API_KEY} \
    --private-key $PRIVATE_KEY
```

### local.sh
本地开发脚本，包含：
```bash
#!/bin/bash

# 检查 anvil 是否运行
if ! nc -z localhost 8545 2>/dev/null; then
    echo "Starting Anvil..."
    anvil > anvil.log 2>&1 &
    sleep 2
fi

# 设置环境变量
export ANVIL_RPC_URL=http://localhost:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# 部署合约
forge script script/DeployToken.s.sol \
    --rpc-url $ANVIL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast

# 部署并升级到 V2
forge script script/DeployTokenV2.s.sol
```

## 测试说明

### 测试命令参数
- `-v`: 显示基本信息
- `-vv`: 显示更多信息，包括事件日志
- `-vvv`: 显示最详细的信息，包括事件日志和跟踪信息

### 测试文件说明
- `TheWeb3Token.t.sol`: V1 合约测试
  - `test_Initialize`: 测试初始化
  - `test_Transfer`: 测试转账
  - `test_TransferOwnership`: 测试所有权转移
- `TheWeb3TokenV2.t.sol`: V2 合约测试
  - `test_UpgradeToV2`: 测试升级功能

## 部署地址

### Holesky 测试网
- Proxy: [待部署]
- Implementation V1: [待部署]
- Implementation V2: [待部署]

## 常见问题

### 1. 如何获取 ETHERSCAN_API_KEY？
1. 访问 [Etherscan](https://etherscan.io/)
2. 注册/登录账号
3. 进入 Account -> API Keys
4. 点击 "Add" 创建新的 API key

### 2. 为什么需要验证合约？
合约验证后，可以在 Etherscan 上：
- 查看完整源代码
- 直接与合约交互
- 验证合约实现
- 增加项目透明度

### 3. UUPS 代理模式是什么？
UUPS (Universal Upgradeable Proxy Standard) 是一种代理模式：
- 升级逻辑在实现合约中
- 比传统代理模式更省 gas
- 更安全的升级机制

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证
MIT License

## 文档
- [开发和测试指南](development.md)
- [事件日志解析指南](event-logs.md)