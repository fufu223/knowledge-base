# fastsun-dynamic

## 模块概述

fastsun-dynamic 是 Fastsun 平台的动态配置模块，提供动态数据源、动态路由等功能。

**路径**: `fastsun-dynamic/`

**主要职责**：
- 动态数据源切换
- 动态路由配置
- 运行时配置更新
- 多数据源管理

---

## 核心功能

### 1. 动态数据源

#### 配置多数据源

```yaml
spring:
  datasource:
    dynamic:
      primary: master
      strict: false
      datasource:
        master:
          url: jdbc:mysql://localhost:3306/master_db
          username: root
          password: password
        slave:
          url: jdbc:mysql://localhost:3306/slave_db
          username: root
          password: password
```

#### 使用注解切换数据源

```java
@DS("slave")
public List<User> listUsers() {
    return userMapper.selectList(null);
}
```

#### 编程式切换

```java
@Autowired
private DynamicDataSourceContextHolder dataSourceContextHolder;

public void queryFromSlave() {
    dataSourceContextHolder.push("slave");
    try {
        // 查询从库
        List<User> users = userMapper.selectList(null);
    } finally {
        dataSourceContextHolder.poll();
    }
}
```

### 2. 动态路由

#### 注册动态路由

```java
@Autowired
private RouteDefinitionWriter routeDefinitionWriter;

public void addRoute(String id, String uri, String predicates) {
    RouteDefinition definition = new RouteDefinition();
    definition.setId(id);
    definition.setUri(URI.create(uri));
    
    // 添加断言
    PredicateDefinition predicate = new PredicateDefinition();
    predicate.setName("Path");
    predicate.addArg("_genkey_0", predicates);
    definition.setPredicates(Arrays.asList(predicate));
    
    routeDefinitionWriter.save(Mono.just(definition)).subscribe();
}
```

### 3. 动态配置刷新

```java
@RestController
@RequestMapping("/config")
public class DynamicConfigController {
    
    @Autowired
    private RefreshScope refreshScope;
    
    @PostMapping("/refresh")
    public Response refresh() {
        refreshScope.refreshAll();
        return Response.success("配置已刷新");
    }
}
```

---

## 常用类

### 数据源相关

- `DynamicDataSource` - 动态数据源
- `DynamicDataSourceContextHolder` - 数据源上下文
- `DS` - 数据源切换注解

### 路由相关

- `RouteDefinitionWriter` - 路由定义写入器
- `RouteDefinitionLocator` - 路由定义定位器
- `DynamicRouteService` - 动态路由服务

---

## 最佳实践

### 1. 读写分离

```java
@Service
public class UserServiceImpl implements UserService {
    
    @DS("master")
    public void saveUser(User user) {
        // 写操作使用主库
        userMapper.insert(user);
    }
    
    @DS("slave")
    public List<User> listUsers() {
        // 读操作使用从库
        return userMapper.selectList(null);
    }
}
```

### 2. 多租户数据源隔离

```java
@Component
public class TenantDataSourceInterceptor implements HandlerInterceptor {
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) {
        String tenantId = request.getHeader("X-Tenant-Id");
        if (StringUtils.isNotBlank(tenantId)) {
            DynamicDataSourceContextHolder.push(tenantId);
        }
        return true;
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, 
                               HttpServletResponse response, 
                               Object handler, 
                               Exception ex) {
        DynamicDataSourceContextHolder.poll();
    }
}
```

### 3. 动态路由管理

```java
@Service
public class DynamicRouteManager {
    
    @Autowired
    private RouteDefinitionWriter routeDefinitionWriter;
    
    @Autowired
    private ApplicationEventPublisher publisher;
    
    /**
     * 添加路由
     */
    public void addRoute(RouteDTO route) {
        RouteDefinition definition = convert(route);
        routeDefinitionWriter.save(Mono.just(definition)).subscribe();
        publisher.publishEvent(new RefreshRoutesEvent(this));
    }
    
    /**
     * 删除路由
     */
    public void deleteRoute(String id) {
        routeDefinitionWriter.delete(Mono.just(id)).subscribe();
        publisher.publishEvent(new RefreshRoutesEvent(this));
    }
}
```

---

## 注意事项

1. **数据源切换时机**：必须在事务开启前切换数据源
2. **线程安全**：使用 ThreadLocal 存储数据源标识，注意清理
3. **路由刷新**：修改路由后需要发布刷新事件
4. **性能考虑**：频繁切换数据源会影响性能，建议合理使用

---

## 常见问题

### Q1: 数据源切换不生效？

**原因**：在事务内切换数据源

**解决**：确保在方法入口或事务外切换

```java
// ❌ 错误示例
@Transactional
public void method() {
    DynamicDataSourceContextHolder.push("slave");
    // ...
}

// ✅ 正确示例
@DS("slave")
@Transactional
public void method() {
    // ...
}
```

### Q2: 动态路由不生效？

**原因**：未发布刷新事件

**解决**：修改路由后发布 RefreshRoutesEvent

```java
publisher.publishEvent(new RefreshRoutesEvent(this));
```

---

## 相关配置

```yaml
fastsun:
  platform:
    dynamic:
      # 是否启用动态数据源
      enabled: true
      # 默认数据源
      primary: master
      # 严格模式
      strict: false
```

---

## 总结

fastsun-dynamic 模块提供了强大的动态配置能力，支持：
- ✅ 动态数据源切换（读写分离、多租户）
- ✅ 动态路由管理
- ✅ 运行时配置刷新

适用于需要灵活配置和多数据源管理的场景。
