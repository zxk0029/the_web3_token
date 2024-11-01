# 本地开发和测试指南

## Anvil 分叉测试网络

Anvil 提供了强大的分叉功能，允许我们基于真实区块链创建本地测试环境。

### 基本用法

```bash
anvil --fork-url <RPC_URL> --fork-block-number <LATEST_BLOCK>
```

### 参数说明
- `--fork-url <RPC_URL>`: 指定要分叉的网络 RPC 地址（如 Infura、Alchemy 的 URL）
- `--fork-block-number <BLOCK>`: 可选，指定要分叉的具体区块号

### 使用示例

```bash
# 分叉以太坊主网
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR-API-KEY

# 分叉特定区块
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR-API-KEY --fork-block-number 17000000
```

### 主要用途
- 测试与已部署合约的交互
- 在本地模拟主网环境进行开发
- 测试升级或漏洞修复
- 使用主网的真实数据进行测试

### 优势
- 可以使用主网的状态，但不消耗真实 ETH
- 交易即时确认
- 可以模拟任何账户（包括使用其资金）
- 便于调试和测试

### 注意事项
- 需要可靠的 RPC 提供者（如 Alchemy、Infura）
- 本地网络的状态是从指定区块开始的快照
- 后续的改动只存在于本地

## Cast 命令行工具使用

### 查询合约状态

```bash
# 查看 mintFee
cast call $CONTRACT_ADDRESS "mintFee()" --rpc-url http://localhost:8545

# 查看 token 名称
cast call $CONTRACT_ADDRESS "name()" --rpc-url http://localhost:8545

# 查看 token 符号
cast call $CONTRACT_ADDRESS "symbol()" --rpc-url http://localhost:8545

# 查看某个地址的余额
cast call $CONTRACT_ADDRESS "balanceOf(address)" <钱包地址> --rpc-url http://localhost:8545

# 查看 owner
cast call $CONTRACT_ADDRESS "owner()" --rpc-url http://localhost:8545
```

### 发送交易

```bash
# 使用私钥发送交易（例如 mint）
cast send $CONTRACT_ADDRESS "mint()" --value 0.01ether --private-key <私钥> --rpc-url http://localhost:8545
```

### 本地测试网络默认账户

```bash
# Anvil 的默认私钥
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### 解码返回值

```bash
# 解码返回值（例如字符串）
cast call $CONTRACT_ADDRESS "name()" --rpc-url http://localhost:8545 --abi-decode "string"

# 查看合约接口
cast interface $CONTRACT_ADDRESS --rpc-url http://localhost:8545
```

## 环境变量设置

建议创建一个 `.env` 文件来存储配置：

```env
ETH_RPC_URL=your_rpc_url
CONTRACT_ADDRESS=your_contract_address
PRIVATE_KEY=your_private_key
```

然后在使用时：
```bash
source .env
```

## 常见问题解决

1. 如果返回值是 Wei，可以使用以下命令转换为 ETH：
```bash
cast call $CONTRACT_ADDRESS "mintFee()" --rpc-url http://localhost:8545 | cast --from-wei
```

2. 对于多参数函数的调用：
```bash
cast call $CONTRACT_ADDRESS "yourFunction(uint256,address)" 123 0x... --rpc-url http://localhost:8545
```
