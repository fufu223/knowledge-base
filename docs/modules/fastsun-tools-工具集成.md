# fastsun-tools

## 模块概述

fastsun-tools 是 Fastsun 平台的工具集成模块，提供 Redis、Kafka、RabbitMQ、MongoDB、Elasticsearch 等中间件的集成和封装。

**路径**: `fastsun-tools/`

**主要职责**：
- Redis 缓存和分布式锁
- Kafka 消息队列
- RabbitMQ 消息队列
- MongoDB 文档数据库
- Elasticsearch 搜索引擎
- Druid 数据源监控

**子模块**：
- `fastsun-redis` - Redis 集成
- `fastsun-kafka` - Kafka 集成
- `fastsun-rabbitmq` - RabbitMQ 集成
- `fastsun-mongo` - MongoDB 集成
- `fastsun-elastic` - Elasticsearch 集成
- `fastsun-druid` - Druid 监控

---

## 应用场景

### 1. 高并发缓存加速
在电商秒杀、热点数据查询等场景中，通过 Redis 缓存将数据库查询压力降低 90% 以上，结合分布式锁解决缓存击穿和并发竞争问题，保障系统在高并发下的稳定运行。

### 2. 消息驱动的异步解耦
在订单处理、短信通知、日志收集等场景中，通过 Kafka 或 RabbitMQ 实现业务系统间的异步通信，削峰填谷，提升系统的吞吐能力和响应速度。

### 3. 全文搜索与日志分析
在文档检索、商品搜索、操作日志分析等场景中，利用 Elasticsearch 的倒排索引和聚合分析能力，实现毫秒级的全文搜索和实时数据统计。

### 4. 数据源监控与诊断
在生产环境中，通过 Druid 监控统计 SQL 执行情况、连接池使用状态和慢查询分析，帮助运维人员快速定位数据库性能瓶颈。

---

## Redis 集成

### 配置

```yaml
spring:
  redis:
    host: localhost
    port: 6379
    password: 
    database: 0
    timeout: 3000
    
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
```

### 基本操作

```java
@Autowired
private RedisTemplate<String, Object> redisTemplate;

// 设置值
redisTemplate.opsForValue().set("key", "value", 1, TimeUnit.HOURS);

// 获取值
Object value = redisTemplate.opsForValue().get("key");

// 删除
redisTemplate.delete("key");

// 判断是否存在
Boolean exists = redisTemplate.hasKey("key");
```

### 分布式锁

```java
@Autowired
private RedissonClient redissonClient;

public void doWithLock() {
    RLock lock = redissonClient.getLock("my_lock");
    
    try {
        // 尝试获取锁，最多等待 10 秒，锁定 30 秒后自动释放
        boolean locked = lock.tryLock(10, 30, TimeUnit.SECONDS);
        
        if (locked) {
            // 执行业务逻辑
            doSomething();
        }
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
```

---

## Kafka 集成

### 配置

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
      
    consumer:
      group-id: my-group
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      auto-offset-reset: earliest
```

### 发送消息

```java
@Autowired
private KafkaTemplate<String, String> kafkaTemplate;

public void sendMessage(String topic, String message) {
    kafkaTemplate.send(topic, message);
}
```

### 接收消息

```java
@Component
public class KafkaConsumer {
    
    @KafkaListener(topics = "my-topic", groupId = "my-group")
    public void listen(String message) {
        System.out.println("收到消息: " + message);
        
        // 处理消息
        processMessage(message);
    }
}
```

---

## RabbitMQ 集成

### 配置

```yaml
spring:
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
    virtual-host: /
```

### 发送消息

```java
@Autowired
private RabbitTemplate rabbitTemplate;

public void sendMessage(String exchange, String routingKey, Object message) {
    rabbitTemplate.convertAndSend(exchange, routingKey, message);
}
```

### 接收消息

```java
@Component
public class RabbitMQConsumer {
    
    @RabbitListener(queues = "my-queue")
    public void listen(String message) {
        System.out.println("收到消息: " + message);
    }
}
```

---

## MongoDB 集成

### 配置

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/mydb
```

### 基本操作

```java
@Repository
public class UserRepository {
    
    @Autowired
    private MongoTemplate mongoTemplate;
    
    // 保存
    public void save(User user) {
        mongoTemplate.save(user);
    }
    
    // 查询
    public List<User> findAll() {
        return mongoTemplate.findAll(User.class);
    }
    
    // 条件查询
    public List<User> findByName(String name) {
        Query query = new Query(Criteria.where("name").is(name));
        return mongoTemplate.find(query, User.class);
    }
}
```

---

## Elasticsearch 集成

### 配置

```yaml
spring:
  elasticsearch:
    rest:
      uris: http://localhost:9200
```

### 索引操作

```java
@Service
public class SearchService {
    
    @Autowired
    private ElasticsearchRestTemplate esTemplate;
    
    // 创建索引
    public void createIndex() {
        IndexOperations indexOps = esTemplate.indexOps(Product.class);
        indexOps.create();
        indexOps.putMapping(indexOps.createMapping(Product.class));
    }
    
    // 保存文档
    public void save(Product product) {
        esTemplate.save(product);
    }
    
    // 搜索
    public List<Product> search(String keyword) {
        NativeSearchQuery query = new NativeSearchQueryBuilder()
            .withQuery(QueryBuilders.multiMatchQuery(keyword, "name", "description"))
            .build();
        
        SearchHits<Product> hits = esTemplate.search(query, Product.class);
        return hits.stream()
            .map(SearchHit::getContent)
            .collect(Collectors.toList());
    }
}
```

---

## Druid 监控

### 配置

```yaml
spring:
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    druid:
      # 连接池配置
      initial-size: 5
      min-idle: 5
      max-active: 20
      
      # 监控配置
      stat-view-servlet:
        enabled: true
        url-pattern: /druid/*
        login-username: admin
        login-password: admin123
      
      # Web 监控
      web-stat-filter:
        enabled: true
        url-pattern: /*
        exclusions: "*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*"
```

访问监控页面：`http://localhost:8080/druid`

---

## 配置项

### Redis 配置

```yaml
spring:
  redis:
    host: localhost          # Redis 服务器地址 <span class="config-required">(必需)</span>
    port: 6379               # Redis 服务器端口
    password:                # Redis 密码，无密码留空
    database: 0              # Redis 数据库索引（0-15）
    timeout: 3000            # 连接超时时间（毫秒）
    lettuce:
      pool:
        max-active: 8        # 连接池最大连接数
        max-idle: 8          # 连接池最大空闲连接数
        min-idle: 0          # 连接池最小空闲连接数
```

### Kafka 配置

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092  # Kafka 服务器地址 <span class="config-required">(必需)</span>
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
    consumer:
      group-id: my-group               # 消费者组 ID <span class="config-required">(必需)</span>
      auto-offset-reset: earliest      # 偏移量重置策略
```

### 数据源配置（Druid）

```yaml
spring:
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource  # 数据源类型 <span class="config-required">(必需)</span>
    druid:
      initial-size: 5      # 连接池初始化连接数
      min-idle: 5          # 连接池最小空闲连接数
      max-active: 20       # 连接池最大活跃连接数
      stat-view-servlet:
        enabled: true      # 是否启用监控页面
```

---

## 常见问题

### Q1: Redis 连接失败？

A: 检查 Redis 服务是否启动，配置是否正确。

### Q2: Kafka 消息丢失？

A: 配置 ACK 机制：
```yaml
spring:
  kafka:
    producer:
      acks: all
```

### Q3: Elasticsearch 索引创建失败？

A: 确保 ES 服务正常运行，检查映射配置。

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [配置指南](../configuration/properties.md)

## 模块引用关系

| 方向 | 模块名称 | 说明 |
|------|---------|------|
| 依赖 | fastsun-base | 依赖基础模块的工具类和异常处理 |
| 依赖 | fastsun-common | 依赖通用模块的公共组件 |
| 被依赖 | 业务模块 | 各业务模块通过工具集成模块快速接入中间件能力 |
