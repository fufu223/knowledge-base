# 配置指南

## 概述

Fastsun 平台使用 Spring Boot 的配置机制，支持多种配置方式。本文档详细说明各项配置的用途和使用方法。

## 配置文件位置

Spring Boot 按以下顺序加载配置（优先级从高到低）：

1. 命令行参数
2. JNDI 属性
3. Java 系统属性 (`System.getProperties()`)
4. 操作系统环境变量
5. `application-{profile}.yml` (特定 profile)
6. `application.yml` (默认配置)
7. `@PropertySource` 注解
8. 默认属性

## 核心配置项

### 1. 服务器配置

```yaml
server:
  port: 8080                    # 服务端口
  servlet:
    context-path: /             # 上下文路径
  tomcat:
    threads:
      max: 200                  # 最大线程数
      min-spare: 10             # 最小空闲线程
    connection-timeout: 20000   # 连接超时时间（毫秒）
```

### 2. 数据库配置

#### MySQL 配置

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/fastsun?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your-password
    
    # Druid 连接池配置
    druid:
      initial-size: 5           # 初始连接数
      min-idle: 5               # 最小空闲连接
      max-active: 20            # 最大活跃连接
      max-wait: 60000           # 获取连接最大等待时间
      time-between-eviction-runs-millis: 60000
      min-evictable-idle-time-millis: 300000
      validation-query: SELECT 1
      test-while-idle: true
      test-on-borrow: false
      test-on-return: false
```

#### Oracle 配置

```yaml
spring:
  datasource:
    driver-class-name: oracle.jdbc.OracleDriver
    url: jdbc:oracle:thin:@localhost:1521:orcl
    username: fastsun
    password: your-password
```

### 3. JPA/Hibernate 配置

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: update          # none, validate, update, create, create-drop
    show-sql: true              # 显示 SQL
    properties:
      hibernate:
        format_sql: true        # 格式化 SQL
        dialect: org.hibernate.dialect.MySQL5InnoDBDialect
        use_sql_comments: true
        default_batch_fetch_size: 100  # 批量抓取大小
```

### 4. Redis 配置

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
        max-active: 8           # 最大连接数
        max-idle: 8             # 最大空闲连接
        min-idle: 0             # 最小空闲连接
        max-wait: -1ms          # 最大等待时间
```

### 5. 多租户配置

#### 字段隔离模式

```yaml
fastsun:
  platform:
    multi:
      tenant:
        enable: false           # 关闭数据库隔离
    tenant:
      field-isolation: true     # 启用字段隔离
```

#### 数据库隔离模式

```yaml
fastsun:
  platform:
    multi:
      tenant:
        enable: true            # 启用数据库隔离
    master:
      tenant: fastsun           # 主租户标识
```

### 6. OAuth2 配置

```yaml
fastsun:
  platform:
    oauth:
      client:
        id: fastsun
        secret: fastsun
      token:
        validity: 7200          # Token 有效期（秒）
        refresh-validity: 2592000  # Refresh Token 有效期（秒）
      login-strategy: firstStrategy  # 登录策略：firstStrategy 或 lastStrategy
```

### 7. 安全配置

```yaml
fastsun:
  platform:
    security:
      # 白名单（不需要认证的 URL）
      white-list:
        - /public/**
        - /login
        - /captcha
        - /swagger-ui/**
        - /v3/api-docs/**
        
      # IP 白名单
      ip-white-list:
        - 127.0.0.1
        - 192.168.1.*
        
      # 签名配置
      signature:
        enabled: true
        secret-key: your-secret-key
        exclude-urls:
          - /public/**
```

### 8. 工作流配置

```yaml
fastsun:
  platform:
    workflow:
      # Activiti 配置
      activiti:
        check-process-definitions: true
        database-schema-update: true
        history-level: full
        
      # 流程缓存
      cache:
        enabled: true
        ttl: 3600               # 缓存过期时间（秒）
```

### 9. 消息通知配置

#### 邮件配置

```yaml
spring:
  mail:
    host: smtp.example.com
    port: 587
    username: noreply@example.com
    password: your-password
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```

#### 短信配置

```yaml
fastsun:
  platform:
    sms:
      provider: aliyun          # 短信提供商：aliyun, tencent
      aliyun:
        access-key-id: your-access-key-id
        access-key-secret: your-access-key-secret
        sign-name: 您的签名
        template-code: SMS_123456
```

### 10. 文件存储配置

#### 本地存储

```yaml
fastsun:
  platform:
    file:
      storage-type: local       # local, fastdfs, oss
      local:
        base-path: /data/files
        access-url: http://localhost:8080/files
```

#### FastDFS 配置

```yaml
fastsun:
  platform:
    file:
      storage-type: fastdfs
      fastdfs:
        connect-timeout: 5000
        network-timeout: 30000
        tracker-list:
          - 192.168.1.100:22122
```

### 11. 日志配置

```yaml
logging:
  level:
    root: INFO
    com.fastsun: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
    
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
    
  file:
    name: logs/application.log
    max-size: 10MB
    max-history: 30
```

### 12. Swagger 配置

```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    tags-sorter: alpha
    operations-sorter: alpha
```

### 13. 缓存配置

```yaml
fastsun:
  platform:
    cache:
      type: redis               # redis, caffeine
      redis:
        time-to-live: 3600000   # 默认过期时间（毫秒）
        key-prefix: "fastsun:"  # Key 前缀
```

### 14. 异步配置

```yaml
fastsun:
  platform:
    async:
      core-pool-size: 10        # 核心线程数
      max-pool-size: 50         # 最大线程数
      queue-capacity: 1000      # 队列容量
      thread-name-prefix: "async-"
```

## Profile 配置

### 开发环境 (application-dev.yml)

```yaml
spring:
  profiles:
    active: dev
    
  datasource:
    url: jdbc:mysql://localhost:3306/fastsun_dev
    username: dev_user
    password: dev_password
    
logging:
  level:
    com.fastsun: DEBUG
```

### 测试环境 (application-test.yml)

```yaml
spring:
  profiles:
    active: test
    
  datasource:
    url: jdbc:mysql://test-server:3306/fastsun_test
    username: test_user
    password: test_password
```

### 生产环境 (application-prod.yml)

```yaml
spring:
  profiles:
    active: prod
    
  datasource:
    url: jdbc:mysql://prod-server:3306/fastsun_prod
    username: prod_user
    password: ${DB_PASSWORD}    # 从环境变量读取
    
logging:
  level:
    com.fastsun: INFO
```

## 动态配置

### 使用 Nacos 配置中心

```yaml
spring:
  cloud:
    nacos:
      config:
        server-addr: 127.0.0.1:8848
        file-extension: yaml
        namespace: your-namespace
        group: DEFAULT_GROUP
        
      discovery:
        server-addr: 127.0.0.1:8848
```

### 刷新配置

对于需要动态刷新的配置，添加 `@RefreshScope` 注解：

```java
@RefreshScope
@Configuration
@ConfigurationProperties(prefix = "fastsun.platform")
public class FastsunConfigProperties {
    // 配置属性
}
```

## 配置最佳实践

### 1. 敏感信息处理

**不要硬编码密码等敏感信息**

❌ 错误做法：
```yaml
spring:
  datasource:
    password: my-secret-password
```

✅ 正确做法：
```yaml
spring:
  datasource:
    password: ${DB_PASSWORD}
```

然后在环境变量中设置：
```bash
export DB_PASSWORD=my-secret-password
```

### 2. 使用配置类

创建类型安全的配置类：

```java
@Data
@Component
@ConfigurationProperties(prefix = "fastsun.platform")
public class FastsunProperties {
    private String baseUrl;
    private SecurityConfig security = new SecurityConfig();
    
    @Data
    public static class SecurityConfig {
        private List<String> whiteList;
        private boolean enableSignature;
    }
}
```

### 3. 配置验证

添加验证注解：

```java
@Data
@Component
@ConfigurationProperties(prefix = "fastsun.platform")
@Validated
public class FastsunProperties {
    
    @NotBlank
    private String baseUrl;
    
    @Min(1)
    @Max(65535)
    private int port;
}
```

### 4. 配置分组

将相关配置组织在一起：

```yaml
fastsun:
  platform:
    database:
      # 数据库相关配置
    cache:
      # 缓存相关配置
    security:
      # 安全相关配置
```

## 常见问题

### Q1: 配置不生效？

检查：
1. 配置文件名称是否正确
2. Profile 是否激活
3. 配置项拼写是否正确
4. YAML 格式是否正确（注意缩进）

### Q2: 如何查看当前生效的配置？

访问 Actuator 端点：
```
GET /actuator/env
```

### Q3: 如何外部化配置？

使用命令行参数：
```bash
java -jar app.jar --server.port=9090
```

或使用环境变量：
```bash
export SERVER_PORT=9090
java -jar app.jar
```

### Q4: 配置优先级是什么？

命令行参数 > 环境变量 > application-{profile}.yml > application.yml

## 相关文档

- [Spring Boot 配置文档](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config)
- [架构概述](../architecture/overview.md)
- [快速开始](../development/getting-started.md)
