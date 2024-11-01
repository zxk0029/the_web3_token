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
