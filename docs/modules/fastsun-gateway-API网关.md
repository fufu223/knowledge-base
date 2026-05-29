# fastsun-gateway

## 模块概述

fastsun-gateway 是 Fastsun 平台的 API 网关模块，基于 Spring Cloud Gateway 实现，提供统一的路由转发、认证鉴权、限流熔断等功能。

**路径**: `fastsun-gateway/`

**主要职责**：
- 路由转发和负载均衡
- 统一认证和鉴权
- 限流和熔断
- 日志记录和监控
- CORS 跨域配置
- 请求/响应过滤

---

## 应用场景

### 1. 微服务统一入口

API 网关作为微服务架构的统一入口，所有外部请求都通过网关转发到对应的后端服务，实现请求路由、负载均衡和服务发现。

### 2. 统一安全认证

在网关层统一处理所有请求的身份认证和权限校验，避免每个微服务单独实现安全逻辑，降低重复开发和维护成本。

### 3. 流量控制与防护

通过限流和熔断机制保护后端服务不被突发流量冲垮，支持 Redis 限流和 Sentinel 熔断降级，保障系统高可用。

### 4. 跨域与请求审计

统一处理 CORS 跨域请求，记录所有请求日志，便于问题追踪和系统监控。

---

## 主要类

### 配置类

- `ResourceServerConfigurer` - 资源服务器配置
- `GatewayConfig` - 网关配置
- `CorsConfig` - CORS 配置

### 过滤器

- `AuthenticationFilter` - 认证过滤器
- `AuthorizationFilter` - 授权过滤器
- `LoggingFilter` - 日志过滤器
- `RateLimitFilter` - 限流过滤器

### 组件

- `AuthenticationManager` - 认证管理器
- `AuthorizationManager` - 授权管理器
- `AccessDeniedHandler` - 访问拒绝处理器
- `AuthenticationEntryPoint` - 认证入口点

---

## 核心功能

### 1. 路由配置

#### 动态路由

```yaml
spring:
  cloud:
    gateway:
      routes:
        # 用户中心
        - id: ucenter
          uri: lb://fastsun-ucenter
          predicates:
            - Path=/api/user/**
          filters:
            - StripPrefix=1
            
        # 工作流
        - id: workflow
          uri: lb://fastsun-workflow
          predicates:
            - Path=/api/workflow/**
          filters:
            - StripPrefix=1
            
        # 低代码
        - id: lowcode
          uri: lb://fastsun-lowcode
          predicates:
            - Path=/api/lowcode/**
          filters:
            - StripPrefix=1
```

#### 从 Nacos 获取路由

```yaml
spring:
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true  # 启用服务发现
          lower-case-service-id: true
```

### 2. 认证过滤器

```java
@Component
public class AuthenticationFilter implements GlobalFilter, Ordered {
    
    @Autowired
    private TokenStore tokenStore;
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();
        
        // 白名单直接放行
        if (isWhiteList(path)) {
            return chain.filter(exchange);
        }
        
        // 获取 Token
        String authHeader = request.getHeaders().getFirst("Authorization");
        if (StringUtils.isEmpty(authHeader) || !authHeader.startsWith("Bearer ")) {
            return unauthorized(exchange, "未提供认证令牌");
        }
        
        String token = authHeader.substring(7);
        
        // 验证 Token
        OAuth2AccessToken accessToken = tokenStore.readAccessToken(token);
        if (accessToken == null || accessToken.isExpired()) {
            return unauthorized(exchange, "Token 无效或已过期");
        }
        
        // 将用户信息添加到请求头
        ServerHttpRequest mutatedRequest = request.mutate()
            .header("X-User-Id", getUserId(accessToken))
            .header("X-Username", getUsername(accessToken))
            .build();
        
        return chain.filter(exchange.mutate().request(mutatedRequest).build());
    }
    
    @Override
    public int getOrder() {
        return -100;  // 优先级最高
    }
}
```

### 3. 授权过滤器

```java
@Component
public class AuthorizationFilter implements GlobalFilter {
    
    @Autowired
    private PermissionService permissionService;
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String userId = request.getHeaders().getFirst("X-User-Id");
        String path = request.getURI().getPath();
        String method = request.getMethodValue();
        
        // 检查权限
        boolean hasPermission = permissionService.checkPermission(
            Long.parseLong(userId), 
            path, 
            method
        );
        
        if (!hasPermission) {
            return forbidden(exchange, "没有访问权限");
        }
        
        return chain.filter(exchange);
    }
}
```

### 4. 限流配置

#### Redis 限流

```yaml
spring:
  cloud:
    gateway:
      default-filters:
        - name: RequestRateLimiter
          args:
            redis-rate-limiter.replenishRate: 10    # 每秒允许请求数
            redis-rate-limiter.burstCapacity: 20    # 突发容量
            key-resolver: "#{@ipKeyResolver}"       # 限流键
```

```java
@Bean
public KeyResolver ipKeyResolver() {
    return exchange -> {
        String ip = exchange.getRequest().getRemoteAddress().getAddress().getHostAddress();
        return Mono.just(ip);
    };
}
```

#### 自定义限流

```java
@Component
public class RateLimitFilter implements GlobalFilter {
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String ip = exchange.getRequest().getRemoteAddress().getAddress().getHostAddress();
        String key = "rate_limit:" + ip;
        
        // 使用 Redis INCR 实现限流
        Long count = redisTemplate.opsForValue().increment(key);
        
        if (count == 1) {
            // 设置过期时间 1 秒
            redisTemplate.expire(key, 1, TimeUnit.SECONDS);
        }
        
        if (count > 100) {  // 每秒最多 100 次请求
            return tooManyRequests(exchange);
        }
        
        return chain.filter(exchange);
    }
}
```

### 5. 熔断降级

#### Sentinel 集成

```yaml
spring:
  cloud:
    sentinel:
      transport:
        dashboard: localhost:8080  # Sentinel 控制台
      datasource:
        flow:
          nacos:
            server-addr: localhost:8848
            data-id: ${spring.application.name}-flow-rules
            group-id: DEFAULT_GROUP
            rule-type: flow
```

#### 降级配置

```java
@Configuration
public class SentinelConfig {
    
    @PostConstruct
    public void initRules() {
        List<FlowRule> rules = new ArrayList<>();
        
        FlowRule rule = new FlowRule();
        rule.setResource("/api/user/**");
        rule.setGrade(RuleConstant.FLOW_GRADE_QPS);
        rule.setCount(100);  // QPS 限制 100
        rules.add(rule);
        
        FlowRuleManager.loadRules(rules);
    }
}
```

### 6. 日志记录

```java
@Component
public class LoggingFilter implements GlobalFilter {
    
    private static final Logger log = LoggerFactory.getLogger(LoggingFilter.class);
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        
        long startTime = System.currentTimeMillis();
        
        return chain.filter(exchange).then(Mono.fromRunnable(() -> {
            long duration = System.currentTimeMillis() - startTime;
            
            log.info("Request: {} {} | Status: {} | Duration: {}ms",
                request.getMethod(),
                request.getURI().getPath(),
                exchange.getResponse().getStatusCode(),
                duration
            );
        }));
    }
}
```

### 7. CORS 跨域配置

```java
@Configuration
public class CorsConfig {
    
    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.addAllowedOrigin("*");
        config.addAllowedMethod("*");
        config.addAllowedHeader("*");
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        
        return new CorsWebFilter(source);
    }
}
```

---

## 配置项

### 网关基础配置

网关服务的基础运行配置，包括端口、应用名称和网关过滤器设置。

```yaml
server:
  port: 8080  # 网关服务端口 <span class="config-required">(必需)</span>

spring:
  application:
    name: fastsun-gateway  # 应用名称，用于 Nacos 服务注册 <span class="config-required">(必需)</span>
    
  cloud:
    gateway:
      # 全局默认过滤器
      default-filters:
        - AddResponseHeader=X-Response-Time, %{response.time}ms  # 添加响应时间头
      
      # 全局 CORS 配置
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOrigins: "*"  # 允许的跨域来源
            allowedMethods: "*"  # 允许的 HTTP 方法
            allowedHeaders: "*"  # 允许的请求头
```

### Nacos 配置

用于服务注册发现和配置中心，实现动态路由和配置管理。

```yaml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848  # Nacos 注册中心地址 <span class="config-required">(必需)</span>
        namespace: your-namespace  # Nacos 命名空间，用于环境隔离
      config:
        server-addr: localhost:8848  # Nacos 配置中心地址 <span class="config-required">(必需)</span>
        file-extension: yaml  # 配置文件格式
```

### Sentinel 配置

用于限流熔断，保护网关和后端服务不被突发流量冲垮。如不使用 Sentinel 可省略此部分。

```yaml
spring:
  cloud:
    sentinel:
      transport:
        dashboard: localhost:8080  # Sentinel 控制台地址
        port: 8719  # Sentinel 客户端端口
      datasource:
        flow:
          nacos:
            server-addr: localhost:8848  # 流控规则持久化地址
```

---

## API 接口

### 健康检查

#### GET `/actuator/health`
**描述**: 健康检查

**响应**:
```json
{
  "status": "UP"
}
```

### 路由信息

#### GET `/actuator/gateway/routes`
**描述**: 查询所有路由

### 限流测试

任何受保护的接口都会受到限流控制。

---

## 使用示例

### 示例 1：添加新服务路由

在 Nacos 配置中心添加路由配置：

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: my-service
          uri: lb://my-service
          predicates:
            - Path=/api/my/**
          filters:
            - StripPrefix=1
            - AddRequestHeader=X-Custom-Header, CustomValue
```

### 示例 2：自定义全局过滤器

```java
@Component
public class CustomGlobalFilter implements GlobalFilter, Ordered {
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // 前置处理
        ServerHttpRequest request = exchange.getRequest();
        System.out.println("Request: " + request.getURI());
        
        return chain.filter(exchange).then(Mono.fromRunnable(() -> {
            // 后置处理
            ServerHttpResponse response = exchange.getResponse();
            System.out.println("Response: " + response.getStatusCode());
        }));
    }
    
    @Override
    public int getOrder() {
        return 0;
    }
}
```

### 示例 3：灰度发布

```java
@Component
public class GrayReleaseFilter implements GlobalFilter {
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String userId = exchange.getRequest().getHeaders().getFirst("X-User-Id");
        
        // 根据用户 ID 决定路由到哪个版本
        if (isGrayUser(userId)) {
            // 路由到新版本
            exchange.getAttributes().put("gray_version", "v2");
        }
        
        return chain.filter(exchange);
    }
    
    private boolean isGrayUser(String userId) {
        // 灰度用户逻辑
        return userId != null && userId.hashCode() % 100 < 10;  // 10% 用户
    }
}
```

---

## 常见问题

### Q1: 网关启动失败？

A: 检查：
1. Nacos 是否正常运行
2. 端口是否被占用
3. 配置文件是否正确

### Q2: 路由不生效？

A: 检查：
1. 服务是否在 Nacos 注册
2. 路由配置是否正确
3. Predicate 是否匹配

### Q3: 跨域问题？

A: 确保 CORS 配置正确：
```java
config.addAllowedOrigin("*");
config.setAllowCredentials(true);
```

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [安全架构](../architecture/security.md)
- [配置指南](../configuration/properties.md)

---

## 模块引用关系

| 依赖类型 | 模块 | 说明 |
|---------|------|------|
| 调用依赖 | fastsun-oauth | 认证鉴权服务用于 Token 验证和权限校验 |
| 调用依赖 | fastsun-ucenter | 用户中心，网关路由转发用户相关请求 |
| 调用依赖 | fastsun-service | 服务管理，网关路由转发服务相关请求 |
| 注册依赖 | Nacos | 服务注册与发现、配置中心 |
| 存储依赖 | Redis | 用于限流计数和缓存
