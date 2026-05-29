# fastsun-service

## 模块概述

fastsun-service 是 Fastsun 平台的服务管理模块，提供微服务注册、发现和调用功能。

**路径**: `fastsun-service/`

**主要职责**：
- 服务注册和发现
- Feign 客户端管理
- 服务负载均衡
- 服务健康检查

**子模块**：
- `fastsun-feign-service-management-api` - API 接口
- `fastsun-feign-service-management-domain` - 领域模型
- `fastsun-feign-service-management-sdk` - SDK

---

## 应用场景

### 1. 微服务间远程调用

在微服务架构中，服务之间需要相互调用获取数据或执行操作，通过 Feign 声明式客户端实现服务间的 RESTful 调用，简化开发流程。

### 2. 服务注册与动态发现

服务实例启动后自动注册到 Nacos 注册中心，调用方通过服务名称动态发现可用实例，实现服务的自动伸缩和故障转移。

### 3. 负载均衡与流量分发

当一个服务有多个实例时，通过 Ribbon 负载均衡策略将请求分发到不同实例，避免单点过载，提升系统整体吞吐量。

### 4. 熔断降级与容错保护

当被调用服务出现故障或超时时，触发熔断降级机制返回友好的降级响应，防止级联故障，保障系统核心功能的可用性。

---

## 核心功能

### 1. 服务注册

```java
@SpringBootApplication
@EnableDiscoveryClient
public class ServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServiceApplication.class, args);
    }
}
```

**配置**：

```yaml
spring:
  application:
    name: user-service
  cloud:
    nacos:
      discovery:
        server-addr: 127.0.0.1:8848
        namespace: dev
```

### 2. Feign 客户端

#### 定义 Feign 接口

```java
@FeignClient(name = "user-service", path = "/api/users")
public interface UserFeignClient {
    
    @GetMapping("/{id}")
    Response<UserDTO> getUser(@PathVariable("id") Long id);
    
    @PostMapping
    Response<UserDTO> createUser(@RequestBody UserDTO user);
    
    @PutMapping("/{id}")
    Response<Void> updateUser(@PathVariable("id") Long id, 
                              @RequestBody UserDTO user);
    
    @DeleteMapping("/{id}")
    Response<Void> deleteUser(@PathVariable("id") Long id);
}
```

#### 使用 Feign 客户端

```java
@Service
public class OrderService {
    
    @Autowired
    private UserFeignClient userFeignClient;
    
    public OrderDTO createOrder(OrderDTO order) {
        // 调用用户服务
        Response<UserDTO> userResponse = userFeignClient.getUser(order.getUserId());
        
        if (!userResponse.isSuccess()) {
            throw new BusinessException("用户不存在");
        }
        
        // 创建订单
        order.setUserName(userResponse.getData().getName());
        return orderRepository.save(order);
    }
}
```

### 3. 负载均衡

```yaml
user-service:
  ribbon:
    # 负载均衡策略
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RoundRobinRule
    # 连接超时
    ConnectTimeout: 3000
    # 读取超时
    ReadTimeout: 5000
    # 最大重试次数
    MaxAutoRetries: 1
    MaxAutoRetriesNextServer: 2
```

### 4. 熔断降级

```java
@Component
public class UserFeignFallback implements UserFeignClient {
    
    @Override
    public Response<UserDTO> getUser(Long id) {
        log.error("调用用户服务失败，id: {}", id);
        return Response.error("服务暂时不可用");
    }
    
    @Override
    public Response<UserDTO> createUser(UserDTO user) {
        return Response.error("服务暂时不可用");
    }
    
    @Override
    public Response<Void> updateUser(Long id, UserDTO user) {
        return Response.error("服务暂时不可用");
    }
    
    @Override
    public Response<Void> deleteUser(Long id) {
        return Response.error("服务暂时不可用");
    }
}
```

**配置熔断**：

```yaml
feign:
  hystrix:
    enabled: true

hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 3000
```

---

## 常用类

### Feign 相关

- `@FeignClient` - Feign 客户端注解
- `UserFeignClient` - 用户服务 Feign 客户端
- `OrderFeignClient` - 订单服务 Feign 客户端

### 服务发现

- `DiscoveryClient` - 服务发现客户端
- `LoadBalancerClient` - 负载均衡客户端

### 配置类

- `FeignConfig` - Feign 配置
- `RibbonConfig` - Ribbon 配置
- `HystrixConfig` - Hystrix 配置

---

## 最佳实践

### 1. 统一响应处理

```java
@Configuration
public class FeignResponseDecoder implements Decoder {
    
    private final Decoder delegate;
    
    public FeignResponseDecoder(Decoder delegate) {
        this.delegate = delegate;
    }
    
    @Override
    public Object decode(Response response, Type type) throws IOException {
        if (response.status() == 404) {
            return Util.emptyValueOf(type);
        }
        
        if (response.status() >= 400) {
            throw new FeignException(response.status(), 
                response.reason(), 
                response.request(), 
                response.body());
        }
        
        return delegate.decode(response, type);
    }
}
```

### 2. 请求拦截器

```java
@Component
public class FeignRequestInterceptor implements RequestInterceptor {
    
    @Override
    public void apply(RequestTemplate template) {
        // 添加认证 token
        String token = SecurityUtils.getCurrentToken();
        if (StringUtils.isNotBlank(token)) {
            template.header("Authorization", "Bearer " + token);
        }
        
        // 添加租户 ID
        String tenantId = TenantContext.getTenantId();
        if (StringUtils.isNotBlank(tenantId)) {
            template.header("X-Tenant-Id", tenantId);
        }
        
        // 添加追踪 ID
        String traceId = MDC.get("traceId");
        if (StringUtils.isNotBlank(traceId)) {
            template.header("X-Trace-Id", traceId);
        }
    }
}
```

### 3. 服务健康检查

```java
@RestController
@RequestMapping("/actuator")
public class HealthController {
    
    @GetMapping("/health")
    public Response health() {
        HealthInfo health = new HealthInfo();
        health.setStatus("UP");
        health.setTimestamp(System.currentTimeMillis());
        
        // 检查依赖服务
        health.setDependencies(checkDependencies());
        
        return Response.success(health);
    }
    
    private Map<String, String> checkDependencies() {
        Map<String, String> status = new HashMap<>();
        
        // 检查数据库
        status.put("database", checkDatabase() ? "UP" : "DOWN");
        
        // 检查 Redis
        status.put("redis", checkRedis() ? "UP" : "DOWN");
        
        return status;
    }
}
```

### 4. 服务调用监控

```java
@Aspect
@Component
public class FeignMonitorAspect {
    
    @Around("@annotation(org.springframework.cloud.openfeign.FeignClient)")
    public Object monitor(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        String methodName = joinPoint.getSignature().getName();
        
        try {
            Object result = joinPoint.proceed();
            
            long duration = System.currentTimeMillis() - start;
            metricsService.record("feign.call.success", methodName, duration);
            
            return result;
            
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - start;
            metricsService.record("feign.call.failure", methodName, duration);
            
            throw e;
        }
    }
}
```

---

## 注意事项

1. **超时配置**：合理设置超时时间，避免长时间等待
2. **重试策略**：谨慎使用重试，避免雪崩效应
3. **熔断降级**：必须实现降级逻辑，保证系统可用性
4. **日志记录**：记录服务调用日志，便于问题排查

---

## 常见问题

### Q1: Feign 调用超时？

**原因**：网络延迟或服务响应慢

**解决**：调整超时配置

```yaml
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 10000
```

### Q2: 服务找不到？

**原因**：服务未注册或网络不通

**解决**：
- 检查服务是否启动
- 检查注册中心配置
- 查看服务列表

```bash
curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=user-service
```

### Q3: 负载均衡不生效？

**原因**：Ribbon 配置错误

**解决**：检查 Ribbon 配置

```yaml
user-service:
  ribbon:
    listOfServers: localhost:8081,localhost:8082
```

---

## 相关配置

服务管理的核心配置，包括服务发现、Feign 客户端和熔断降级策略。

```yaml
spring:
  cloud:
    # 服务发现
    discovery:
      enabled: true  # 是否启用服务发现 <span class="config-required">(必需)</span>
    # Nacos 配置
    nacos:
      discovery:
        server-addr: 127.0.0.1:8848  # Nacos 注册中心地址 <span class="config-required">(必需)</span>
        namespace: dev  # Nacos 命名空间，用于环境隔离
        group: DEFAULT_GROUP  # Nacos 分组

# Feign 配置
feign:
  hystrix:
    enabled: true  # 是否启用 Hystrix 熔断支持
  compression:
    request:
      enabled: true  # 是否启用请求压缩
    response:
      enabled: true  # 是否启用响应压缩

# Hystrix 配置
hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 3000  # Hystrix 线程超时时间（毫秒）

---

## 总结

fastsun-service 模块提供了完善的微服务治理能力：
- ✅ 服务注册和发现
- ✅ Feign 远程调用
- ✅ 负载均衡
- ✅ 熔断降级
- ✅ 健康检查

适用于微服务架构下的服务间调用场景。

---

## 模块引用关系

| 依赖类型 | 模块 | 说明 |
|---------|------|------|
| 调用依赖 | fastsun-ucenter | 用户中心，服务管理 SDK 用于用户服务的 Feign 调用 |
| 调用依赖 | fastsun-oauth | 认证授权，Feign 调用中传递 Token 实现鉴权 |
| 调用依赖 | fastsun-gateway | API 网关，网关通过服务发现路由到后端服务 |
| 注册依赖 | Nacos | 服务注册与发现中心 |
| 存储依赖 | MySQL | 存储服务注册信息、调用日志等数据
