# fastsun-sequence

## 模块概述

fastsun-sequence 是 Fastsun 平台的序列号生成模块，提供分布式唯一序列号生成功能。

**路径**: `fastsun-sequence/`

**主要职责**：
- 分布式序列号生成
- 支持多种生成策略（本地、Redis）
- 序列号规则配置
- 高并发性能优化

**子模块**：
- `fastsun-sequence-api` - API 接口
- `fastsun-sequence-local` - 本地序列号生成器
- `fastsun-sequence-redis` - Redis 序列号生成器

---

## 核心功能

### 1. 基本使用

```java
@Autowired
private ISequenceService sequenceService;

// 生成订单号
String orderNo = sequenceService.nextValue("order_no");
System.out.println(orderNo);  // ORD202605090001

// 生成流水号
String serialNo = sequenceService.nextValue("serial_no");
System.out.println(serialNo);  // 20260509000001
```

### 2. 自定义序列号规则

```java
SequenceRuleDTO rule = new SequenceRuleDTO();
rule.setCode("order_no");
rule.setName("订单号规则");
rule.setPrefix("ORD");
rule.setDateFormat("yyyyMMdd");
rule.setLength(6);
rule.setStep(1);

sequenceRuleService.save(rule);
```

生成的序列号格式：`ORD20260509000001`

### 3. 批量生成

```java
// 批量生成10个序列号
List<String> sequenceNos = sequenceService.nextValues("order_no", 10);

for (String no : sequenceNos) {
    System.out.println(no);
}
```

### 4. 重置序列号

```java
// 重置为指定值
sequenceService.reset("order_no", 1000);

// 按天重置
sequenceService.resetDaily("order_no");
```

---

## 生成策略

### 1. 本地生成器（Local）

**特点**：
- 速度快，无网络开销
- 适合单机应用
- 重启后可能重复

**配置**：

```yaml
fastsun:
  platform:
    sequence:
      type: local
      local:
        # 步长
        step: 100
        # 缓存大小
        cache-size: 1000
```

**使用**：

```java
@Component
public class LocalSequenceGenerator implements SequenceGenerator {
    
    private AtomicLong current = new AtomicLong(0);
    private long max = 0;
    
    @Override
    public long nextValue() {
        if (current.get() >= max) {
            synchronized (this) {
                if (current.get() >= max) {
                    // 从数据库或配置文件获取新范围
                    max = loadNextRange();
                    current.set(max - step);
                }
            }
        }
        return current.incrementAndGet();
    }
}
```

### 2. Redis 生成器（Redis）

**特点**：
- 分布式唯一
- 高可用
- 性能较好

**配置**：

```yaml
fastsun:
  platform:
    sequence:
      type: redis
      redis:
        # Redis key 前缀
        key-prefix: "seq:"
        # 步长
        step: 10
```

**使用**：

```java
@Component
public class RedisSequenceGenerator implements SequenceGenerator {
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @Override
    public long nextValue(String code) {
        String key = "seq:" + code;
        
        // INCRBY 原子操作
        Long value = redisTemplate.opsForValue().increment(key, step);
        
        return value;
    }
}
```

---

## 常用类

### 服务层

- `ISequenceService` - 序列号服务
- `ISequenceRuleService` - 序列号规则服务
- `SequenceGenerator` - 序列号生成器接口

### 实现类

- `LocalSequenceGenerator` - 本地生成器
- `RedisSequenceGenerator` - Redis 生成器

### 实体类

- `SequenceRule` - 序列号规则实体
- `SequenceRuleDTO` - 序列号规则 DTO

---

## 最佳实践

### 1. 业务序列号示例

#### 订单号

```java
@Service
public class OrderService {
    
    @Autowired
    private ISequenceService sequenceService;
    
    public String generateOrderNo() {
        return sequenceService.nextValue("order_no");
        // 输出: ORD20260509000001
    }
}
```

#### 支付流水号

```java
public String generatePaymentNo() {
    return sequenceService.nextValue("payment_no");
    // 输出: PAY20260509123456
}
```

#### 物流单号

```java
public String generateTrackingNo() {
    return sequenceService.nextValue("tracking_no");
    // 输出: TRK20260509000001
}
```

### 2. 分库分表场景

```java
@Service
public class ShardingSequenceService {
    
    @Autowired
    private ISequenceService sequenceService;
    
    /**
     * 生成带分片信息的序列号
     */
    public String generateShardedId(String shardKey) {
        // 计算分片
        int shard = calculateShard(shardKey);
        
        // 生成分片序列号
        String seqCode = "order_" + shard;
        long seq = sequenceService.nextValue(seqCode);
        
        // 组合：分片号 + 序列号
        return String.format("%d%012d", shard, seq);
    }
}
```

### 3. 高并发优化

```java
@Component
public class BatchSequenceService {
    
    @Autowired
    private ISequenceService sequenceService;
    
    private ConcurrentLinkedQueue<Long> buffer = new ConcurrentLinkedQueue<>();
    private static final int BATCH_SIZE = 100;
    
    /**
     * 批量预取序列号
     */
    public long nextValue() {
        Long value = buffer.poll();
        
        if (value == null) {
            // 批量获取
            List<Long> values = sequenceService.nextValues("order_no", BATCH_SIZE);
            buffer.addAll(values);
            value = buffer.poll();
        }
        
        return value;
    }
}
```

---

## 注意事项

1. **唯一性保证**：分布式环境使用 Redis 生成器
2. **性能考虑**：高并发场景使用批量预取
3. **重置策略**：谨慎使用重置功能，避免重复
4. **监控告警**：监控序列号使用情况，防止耗尽

---

## 常见问题

### Q1: 序列号重复？

**原因**：本地生成器在多实例环境下可能重复

**解决**：使用 Redis 生成器

```yaml
fastsun:
  platform:
    sequence:
      type: redis
```

### Q2: 序列号不连续？

**原因**：批量预取时部分序列号未使用

**说明**：这是正常现象，为了保证性能牺牲了连续性

### Q3: Redis 故障如何处理？

**解决**：实现降级策略

```java
@Component
public class FallbackSequenceService {
    
    @Autowired(required = false)
    private RedisSequenceGenerator redisGenerator;
    
    @Autowired
    private LocalSequenceGenerator localGenerator;
    
    public long nextValue(String code) {
        try {
            if (redisGenerator != null) {
                return redisGenerator.nextValue(code);
            }
        } catch (Exception e) {
            log.error("Redis 序列号生成失败，使用本地生成器", e);
        }
        
        // 降级到本地生成器
        return localGenerator.nextValue(code);
    }
}
```

---

## 相关配置

```yaml
fastsun:
  platform:
    sequence:
      # 生成器类型: local, redis
      type: redis
      # 默认步长
      default-step: 1
      # Redis 配置
      redis:
        key-prefix: "seq:"
        step: 10
        # 连接超时
        timeout: 3000
      # 本地配置
      local:
        step: 100
        cache-size: 1000
```

---

## 总结

fastsun-sequence 模块提供了高效的序列号生成能力：
- ✅ 多种生成策略（本地、Redis）
- ✅ 灵活的规则配置
- ✅ 高并发性能优化
- ✅ 分布式唯一保证
- ✅ 降级容错机制

适用于需要生成唯一标识符的业务场景。
