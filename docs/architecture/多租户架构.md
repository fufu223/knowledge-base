# 多租户架构详解

## 概述

Fastsun 平台提供完善的多租户支持，允许在同一套系统中为多个租户提供服务，同时保证数据的隔离性和安全性。

## 租户隔离模式

### 1. 字段隔离模式 (Field Isolation)

#### 原理
所有租户共享同一个数据库和表结构，通过在表中添加 `tenant_code` 字段来区分不同租户的数据。

#### 实现机制

**Hibernate 拦截器**
```java
// HibernateInterceptor.java
String fieldIsolation = ApplicationContextProvider.getProperty(PLATFORM_TENANT_FIELD_ISOLATION, "false");
if (Objects.equals(fieldIsolation, "true")) {
    TenantDTO tenantDTO = LocalTenantContext.get();
    if (!ObjectUtils.isEmpty(tenantDTO)) {
        sql = HibernateUtils.addCondition(sql, "tenant_code", 
            "tenant_code = '" + tenantDTO.getTenantCode() + "'");
    }
}
```

**自动过滤**
在查询时，框架会自动在 SQL 中添加租户条件，开发者无需手动处理。

#### 配置方式
```yaml
fastsun:
  platform:
    multi:
      tenant:
        enable: false  # 关闭数据库隔离模式
    tenant:
      field-isolation: true  # 启用字段隔离
```

#### 适用场景
- 租户数量较多
- 租户数据量不大
- 对数据隔离要求不高
- 希望降低运维成本

### 2. 数据库隔离模式 (Database Isolation)

#### 原理
每个租户拥有独立的数据库实例，通过动态数据源切换来实现租户隔离。

#### 核心组件

**租户标识解析器**
```java
// TenantIdentifierResolver.java
@Component
@ConditionalOnProperty(prefix = "fastsun.platform.multi.tenant", 
                       name = "enable", havingValue = "true")
public class TenantIdentifierResolver implements CurrentTenantIdentifierResolver {
    
    @Override
    public String resolveCurrentTenantIdentifier() {
        TenantDTO tenant = LocalTenantContext.get();
        EnterpriseDTO enterprise = LocalEnterpriseContext.get();
        
        if (ObjectUtils.isEmpty(tenant)){
            return defaultTenant;
        } else {
            if (ObjectUtils.isEmpty(enterprise)){
                return tenant.getTenantCode();
            } else {
                return tenant.getTenantCode() + TENANT_SEPARATOR + enterprise.getCode();
            }
        }
    }
}
```

**多租户连接提供者**
```java
// MultiTenantConnectionProviderImpl.java
@Component
@ConditionalOnProperty(prefix = "fastsun.platform.multi.tenant", 
                       name = "enable", havingValue = "true")
public class MultiTenantConnectionProviderImpl 
    extends AbstractDataSourceBasedMultiTenantConnectionProviderImpl {
    
    @Override
    protected DataSource selectAnyDataSource() {
        // 返回默认数据源
    }
    
    @Override
    protected DataSource selectDataSource(String tenantIdentifier) {
        // 根据租户标识返回对应的数据源
    }
}
```

#### 配置方式
```yaml
fastsun:
  platform:
    multi:
      tenant:
        enable: true  # 启用数据库隔离模式
    master:
      tenant: fastsun  # 主租户标识
```

#### 数据源注册
系统启动时会自动注册各租户的数据源：
```java
// 动态数据源注册
IDynamicDatasourceRegister datasourceRegister = 
    ApplicationContextProvider.getBean(IDynamicDatasourceRegister.class);
datasourceRegister.register(tenantCode, dataSource);
```

#### 适用场景
- 租户数量较少
- 租户数据量大
- 对数据隔离要求高
- 需要独立备份恢复

## 租户上下文管理

### ThreadLocal 存储
```java
// LocalTenantContext.java
public class LocalTenantContext {
    private static InheritableThreadLocal<TenantDTO> holder = 
        new InheritableThreadLocal<>();
    
    public static void set(TenantDTO tenant) {
        holder.set(tenant);
    }
    
    public static TenantDTO get() {
        return holder.get();
    }
    
    public static void clear() {
        holder.remove();
    }
}
```

### 请求过滤器
```java
// FastsunGlobalFilter.java
@Override
public void doFilter(ServletRequest request, ServletResponse response, 
                     FilterChain filterChain) {
    // 从请求头或 Token 中获取租户信息
    String tenant = extractTenantFromRequest(request);
    
    // 设置租户上下文
    TenantDTO tenantDTO = cacheService.getMapValue(
        TENANT_CACHE_KEY_NAME, tenant);
    LocalTenantContext.set(tenantDTO);
    
    try {
        filterChain.doFilter(request, response);
    } finally {
        // 清理上下文
        LocalTenantContext.clear();
    }
}
```

## 租户初始化

### 缓存初始化器
系统为每个租户初始化必要的缓存数据：

```java
// ITenantCacheInitializer.java
public interface ITenantCacheInitializer {
    void cache(String appId, TenantDTO tenantDTO);
    void cache(String appId, TenantDTO tenantDTO, String enterpriseCode);
}
```

### 初始化流程
1. 接收请求，解析租户信息
2. 检查租户缓存是否存在
3. 如不存在，触发异步初始化
4. 加载租户相关配置和数据
5. 存入缓存供后续使用

## 企业级多租户

Fastsun 还支持企业维度的多租户，即在租户下再细分企业：

```
租户 (Tenant)
  └── 企业 A (Enterprise)
  └── 企业 B (Enterprise)
  └── 企业 C (Enterprise)
```

### 租户标识格式
```
{tenantCode}@{enterpriseCode}
例如: fastsun@companyA
```

### 数据隔离
- 租户级别：`tenant_code` 字段
- 企业级别：`enterprise_code` 字段

## 最佳实践

### 1. 选择合适的隔离模式

| 考虑因素 | 字段隔离 | 数据库隔离 |
|---------|---------|-----------|
| 租户数量 | > 100 | < 100 |
| 数据量 | 小/中 | 大 |
| 隔离要求 | 一般 | 严格 |
| 运维成本 | 低 | 高 |
| 性能要求 | 一般 | 高 |

### 2. 租户缓存优化
- 使用 Redis 缓存租户配置
- 设置合理的过期时间
- 实现缓存预热机制

### 3. 数据迁移
- 字段隔离：直接插入数据，确保 tenant_code 正确
- 数据库隔离：需要切换到对应租户的数据源

### 4. 跨租户操作
某些场景可能需要跨租户操作（如平台管理员）：
```java
// 临时切换到指定租户
TenantDTO originalTenant = LocalTenantContext.get();
try {
    LocalTenantContext.set(targetTenant);
    // 执行跨租户操作
} finally {
    LocalTenantContext.set(originalTenant);
}
```

## 常见问题

### Q1: 如何判断当前使用的是哪种隔离模式？
```java
String dbIsolation = ApplicationContextProvider.getProperty(
    "fastsun.platform.multi.tenant.enable");
String fieldIsolation = ApplicationContextProvider.getProperty(
    "fastsun.platform.tenant.field-isolation");

if ("true".equals(dbIsolation)) {
    // 数据库隔离模式
} else if ("true".equals(fieldIsolation)) {
    // 字段隔离模式
} else {
    // 无租户隔离
}
```

### Q2: 如何在代码中获取当前租户信息？
```java
TenantDTO tenant = LocalTenantContext.get();
if (tenant != null) {
    String tenantCode = tenant.getTenantCode();
    String appId = tenant.getAppId();
}
```

### Q3: 工作流如何支持多租户？
工作流引擎为每个租户创建独立的 ProcessEngine 实例：
```java
// MultiTenantProcessEngine.java
public ProcessEngine getProcessEngine(){
    String identifier = tenantIdentifierResolver.resolveCurrentTenantIdentifier();
    ProcessEngine result = processEngineCache.get(identifier);
    if (result == null){
        result = buildProcessEngine(identifier);
        processEngineCache.put(identifier, result);
    }
    return result;
}
```

## 相关文档

- [架构概述](./overview.md)
- [安全架构](./security.md)
- [配置指南](../configuration/properties.md)
