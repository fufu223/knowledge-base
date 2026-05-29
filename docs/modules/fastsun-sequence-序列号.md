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

## 应用场景

### 1. 订单号/流水号生成
适用于电商订单、支付流水、物流运单等需要业务含义唯一编号的场景，支持灵活的前缀和时间格式配置。

### 2. 分布式 ID 生成
适用于多实例部署的微服务架构，通过 Redis 生成器保证跨实例的序列号全局唯一。

### 3. 分库分表场景
适用于数据量大的业务系统，在分库分表架构中生成带分片信息的序列号，支持数据路由和水平扩展。

### 4. 高并发批量生成
适用于需要批量获取序列号的高并发场景，通过预取机制减少数据库/Redis 访问频率，提升性能。

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
      # 生成器类型 — local（本地生成器）、redis（Redis 生成器） <span class="config-required">(必需)</span>
      type: redis
      # 默认步长 — 序列号每次递增的步长，默认 1 <span class="config-required">(必需)</span>
      default-step: 1
      # Redis 配置（当 type 为 redis 时必填）
      redis:
        key-prefix: "seq:"    # Redis key 前缀，用于区分不同业务序列号 <span class="config-required">(必需)</span>
        step: 10               # Redis 生成器步长，决定每次 INCRBY 的增量 <span class="config-required">(必需)</span>
        timeout: 3000          # Redis 连接超时时间（毫秒），默认 3000
      # 本地配置（当 type 为 local 时生效）
      local:
        step: 100              # 本地生成器步长，每次从数据库预取的范围大小
        cache-size: 1000       # 本地缓存大小，预取的序列号数量
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

---

## 模块引用关系

| 模块名称 | 引用关系 | 说明 |
|---------|--------|------|
| fastsun-system | 依赖 | 提供租户上下文用于隔离不同租户的序列号 |
| fastsun-workflow | 被依赖 | 工作流模块使用序列号生成流程实例编号 |
| fastsun-lowcode | 被依赖 | 低代码平台使用序列号生成模型记录的业务编号 |
| fastsun-message | 被依赖 | 消息模块使用序列号生成消息记录编号 |
| fastsun-reminder | 被依赖 | 提醒服务使用序列号生成提醒记录编号 |
