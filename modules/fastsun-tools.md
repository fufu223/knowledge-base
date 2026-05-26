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
