# Solidity 事件日志解析指南

## 事件日志结构
每个事件日志包含两个主要部分：
1. `topics`: 用于存储事件签名和 indexed 参数
2. `data`: 用于存储非 indexed 参数

## Topics 规则
1. `topics[0]`: 永远是事件签名的 keccak256 哈希值
2. `topics[1]` 到 `topics[3]`: 对应 indexed 标记的参数
3. 最多支持 3 个 indexed 参数（即 topics 数组最多 4 个元素）

## 示例解析

### 1. 基础事件（无 indexed 参数）
```solidity
event BasicEvent(address user, uint256 amount);
```
日志结构：
```json
{
    "topics": ["0x事件哈希"],
    "data": "0x编码后的user和amount数据"
}
```

### 2. 带一个 indexed 参数的事件
```solidity
event TransferEvent(address indexed from, address to, uint256 amount);
```
日志结构：
```json
{
    "topics": [
        "0x事件哈希",
        "0x000000000000000000000000{from地址}"
    ],
    "data": "0x编码后的to和amount数据"
}
```

### 3. 全部使用 indexed 参数的事件
```solidity
event FullIndexedEvent(address indexed from, address indexed to, uint256 indexed amount);
```
日志结构：
```json
{
    "topics": [
        "0x事件哈希",
        "0x000000000000000000000000{from地址}",
        "0x000000000000000000000000{to地址}",
        "0x{amount的hex格式}"
    ],
    "data": "0x"  // 空
}
```

### 4. 混合参数的事件
```solidity
event GameEvent(address indexed player, uint8 indexed guess, uint8 indexed result, uint256 reward);
```
日志结构：
```json
{
    "topics": [
        "0x事件哈希",
        "0x000000000000000000000000{player地址}",
        "0x000000000000000000000000000000000000000000000000000000000000000{guess}",
        "0x000000000000000000000000000000000000000000000000000000000000000{result}"
    ],
    "data": "0x{reward的hex格式}"
}
```

## 注意事项
1. indexed 参数会被存储在 topics 中，方便外部查询
2. 非 indexed 参数会按顺序打包在 data 中
3. 地址类型会被补齐到 32 字节（前面补0）
4. 使用 indexed 会增加 gas 消耗，但便于事件过滤和查询

## 事件日志解析技巧

### 1. 解析复杂事件
对于包含多个参数的事件，可以使用 `cast` 工具查询日志，然后手动解析：

```bash
# 查询事件日志
cast logs <topic0> [<topic1>] [<topic2>] [<topic3>] [options] --rpc-url <RPC_URL>
```
- topic0: 事件签名（必须）
- topic1: 第一个 indexed 参数（可选）
- topic2: 第二个 indexed 参数（可选）
- topic3: 第三个 indexed 参数（可选）

示例：
```bash
cast logs 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef \
0x0000000000000000000000000083e852be06da37ba84fb7876b485f81306a9ed \
0x000000000000000000000000df979304190a3f06289cfecd117976ccd2653a09 \
--from-block 46000000 \
--to-block 46000100 \
--address 0xBF6Cd8D57ffe3CBe3D78DEd8DA34345A3B736102 \
--rpc-url https://bsc-dataseed.binance.org/
```
> 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef 是 ERC20 标准中 Transfer 事件的 Keccak-256 哈希值  
> event Transfer(address indexed from, address indexed to, uint256 value）   
> --to-block 可以传入latest，也可以传入具体的数字  
> 0x000...9ED：发送方地址（流动性池），需要填充为32字节  
> 0x000...A09：接收方地址（limitSwapAddress），同样填充为32字节  
> address 合约地址

### 2. 批量查询事件
可以使用 `--from-block` 和 `--to-block` 参数查询特定区块范围内的事件：

```bash
# 查询区块 10000000 到 10001000 之间的 Transfer 事件
cast logs 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef \
  --from-block 10000000 \
  --to-block 10001000
```

### 3. 过滤特定合约的事件
可以使用 `--address` 参数过滤特定合约地址的事件：

```bash
# 查询特定合约的 Transfer 事件
cast logs 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef \
  --address <合约地址>
```

## 常见问题

### 1. 为什么有些事件无法查询？
可能原因包括：
- 事件参数未标记为 `indexed`
- 查询的区块范围过大
- RPC 节点限制

### 2. 如何提高事件查询效率？
- 使用较小的区块范围
- 指定合约地址
- 使用高性能的 RPC 节点

### 3. 如何处理大量事件数据？
- 使用分页查询
- 将数据存储到本地数据库
- 使用批量处理工具

## 工具推荐

1. **Cast**: Foundry 提供的命令行工具，适合快速查询和解析事件
2. **Ethers.js**: JavaScript 库，适合在应用中处理事件
3. **Web3.py**: Python 库，适合数据分析和处理
4. **The Graph**: 链下索引服务，适合复杂的事件查询和分析
