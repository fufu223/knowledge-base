# fastsun-base

## 模块概述

fastsun-base 是 Fastsun 平台的基础核心模块，提供通用的工具类、注解、异常处理和数据权限控制等基础功能。

**路径**: `fastsun-base/`

**主要职责**：
- 提供通用工具类和辅助方法
- 定义基础注解和常量
- 统一异常处理机制
- 实现数据权限拦截器
- 提供基础 Controller 和 Service 抽象类

---

## 主要类

### Controller 层

- `AbstractBaseController` - 基础 Controller 抽象类
- `AbstractDTOCRUDController` - CRUD Controller 抽象类，提供标准的增删改查接口
- `TableGeratorController` - 表格生成控制器

### Service 层

- `AbstractFastsunDtoService` - 基础 DTO Service 抽象类
- `IFastsunDtoService` - DTO Service 接口

### 组件层

- `DataPermissionsHandler` - 数据权限处理器
- `HibernateInterceptor` - Hibernate SQL 拦截器，用于多租户字段隔离
- `DynamicFeignClientFactory` - 动态 Feign 客户端工厂

### 工具类

- `ClassUtils` - 类工具类
- `EntityUtils` - 实体工具类
- `JsonUtils` - JSON 工具类
- `TenantUtils` - 租户工具类
- `ViewObjectUtil` - 视图对象工具类

### 注解

- `@Comment` - 注释注解
- `@DBTable` - 数据库表注解
- `@AutoDetectEntity` - 自动检测实体注解
- `@Valid` - 验证注解
- `@Parameter` - 参数注解
- `@Signature` - 签名注解

### 常量

- `SystemConstant` - 系统常量
- `ValueConstants` - 值常量
- `ViewMetaConstants` - 视图元数据常量

---

## 核心功能

### 1. 数据权限控制

**类**: `DataPermissionsHandler`

数据权限处理器负责在查询时自动添加数据过滤条件，支持多种数据权限范围：

```java
@Component
public class DataPermissionsHandler {
    
    public QueryParameter handleDataPermission(QueryParameter query) {
        UserDTO user = LocalUserContext.get();
        
        // 获取用户的数据权限范围
        DataScope scope = getDataScope(user);
        
        switch (scope.getType()) {
            case ALL:           // 全部数据
            case CUSTOM:        // 自定义数据
            case DEPT:          // 本部门数据
            case DEPT_AND_CHILD: // 本部门及下级
            case SELF:          // 仅本人
        }
        
        return query;
    }
}
```

**使用方式**：
在 Service 中继承 `AbstractFastsunDtoService`，框架会自动应用数据权限过滤。

### 2. 多租户字段隔离

**类**: `HibernateInterceptor`

通过 Hibernate 拦截器，在 SQL 执行时自动添加租户条件：

```java
@Component
public class HibernateInterceptor implements StatementInspector {
    
    @Override
    public String inspect(String sql) {
        String fieldIsolation = ApplicationContextProvider.getProperty(
            PLATFORM_TENANT_FIELD_ISOLATION, "false");
        
        if (Objects.equals(fieldIsolation, "true")) {
            TenantDTO tenantDTO = LocalTenantContext.get();
            if (!ObjectUtils.isEmpty(tenantDTO)) {
                sql = HibernateUtils.addCondition(sql, "tenant_code", 
                    "tenant_code = '" + tenantDTO.getTenantCode() + "'");
            }
        }
        
        return sql;
    }
}
```

**配置**：
```yaml
fastsun:
  platform:
    tenant:
      field-isolation: true  # 启用字段隔离
```

### 3. 统一异常处理

**异常类**：
- `FastsunException` - Fastsun 基础异常
- `BusinessException` - 业务异常
- `ParameterException` - 参数异常

**使用示例**：
```java
// 抛出业务异常
throw new BusinessException("用户名已存在");

// 抛出参数异常
throw new ParameterException("参数不能为空");
```

### 4. 基础 Controller

**类**: `AbstractDTOCRUDController`

提供标准的 CRUD 接口，子类只需实现 `getService()` 方法：

```java
@RestController
@RequestMapping("/api/product")
public class ProductController extends AbstractDTOCRUDController<ProductDTO> {
    
    @Autowired
    private ProductService productService;
    
    @Override
    protected IFastsunDtoService<ProductDTO> getService() {
        return productService;
    }
}
```

**自动提供的接口**：
- `GET /list` - 分页查询列表
- `GET /{id}` - 查询详情
- `POST /save` - 新增
- `PUT /update` - 更新
- `DELETE /delete/{id}` - 删除
- `POST /batchDelete` - 批量删除

### 5. 基础 Service

**类**: `AbstractFastsunDtoService`

提供基础的 CRUD 操作实现，支持：
- 分页查询
- 条件查询
- 批量操作
- 数据权限自动过滤

**使用示例**：
```java
@Service
public class ProductService extends AbstractFastsunDtoService<ProductDTO, Product, Long> {
    
    @Autowired
    private ProductRepository productRepository;
    
    @Override
    protected JpaRepository<Product, Long> getRepository() {
        return productRepository;
    }
    
    // 可选：重写方法添加自定义逻辑
    @Override
    protected void beforeSave(ProductDTO dto) {
        // 保存前的处理
    }
    
    @Override
    protected void afterSave(ProductDTO dto) {
        // 保存后的处理
    }
}
```

---

## API 接口

### AbstractDTOCRUDController 提供的标准接口

#### GET `/list`
**描述**: 分页查询列表

**请求参数**:
```json
{
  "pageNum": 1,
  "pageSize": 10,
  "queryConditions": [
    {
      "field": "name",
      "operator": "like",
      "value": "%测试%"
    }
  ]
}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "total": 100,
    "list": [...]
  }
}
```

#### GET `/{id}`
**描述**: 根据 ID 查询详情

**响应**:
```json
{
  "code": 200,
  "data": {...}
}
```

#### POST `/save`
**描述**: 新增记录

**请求体**: DTO 对象

#### PUT `/update`
**描述**: 更新记录

**请求体**: DTO 对象（需包含 id）

#### DELETE `/delete/{id}`
**描述**: 删除记录

---

## 配置项

### 数据权限配置

```yaml
fastsun:
  platform:
    # 是否启用数据权限
    data-permission:
      enabled: true
```

### 多租户字段隔离配置

```yaml
fastsun:
  platform:
    tenant:
      # 是否启用字段隔离
      field-isolation: true
```

---

## 依赖关系

**被依赖模块**：
- fastsun-common
- fastsun-ucenter（用户信息）

**依赖模块**：
- Spring Boot Starter Web
- Spring Data JPA
- Hibernate

---

## 使用示例

### 示例 1：创建简单的 CRUD 模块

**1. 实体类**
```java
@Entity
@Table(name = "demo_product")
public class Product extends BaseEntity {
    private String name;
    private Double price;
}
```

**2. DTO**
```java
public class ProductDTO extends BaseDto {
    private String name;
    private Double price;
}
```

**3. Repository**
```java
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
}
```

**4. Service**
```java
@Service
public class ProductService extends AbstractFastsunDtoService<ProductDTO, Product, Long> {
    
    @Autowired
    private ProductRepository repository;
    
    @Override
    protected JpaRepository<Product, Long> getRepository() {
        return repository;
    }
}
```

**5. Controller**
```java
@RestController
@RequestMapping("/api/product")
public class ProductController extends AbstractDTOCRUDController<ProductDTO> {
    
    @Autowired
    private ProductService service;
    
    @Override
    protected IFastsunDtoService<ProductDTO> getService() {
        return service;
    }
}
```

完成！无需编写任何 CRUD 代码，框架已自动提供所有接口。

### 示例 2：添加数据权限

```java
@Service
public class OrderService extends AbstractFastsunDtoService<OrderDTO, Order, Long> {
    
    @Override
    protected void beforePageQuery(QueryParameter query) {
        super.beforePageQuery(query);
        
        // 添加自定义数据权限
        UserDTO user = LocalUserContext.get();
        if (!user.isAdmin()) {
            // 只能查看自己创建的订单
            query.addCondition("creatorId", QueryOperator.EQ, user.getId());
        }
    }
}
```

---

## 常见问题

### Q1: 如何自定义 CRUD 接口？

A: 在 Controller 中添加自定义方法：

```java
@RestController
@RequestMapping("/api/product")
public class ProductController extends AbstractDTOCRUDController<ProductDTO> {
    
    @GetMapping("/special")
    public Response specialMethod() {
        // 自定义逻辑
    }
}
```

### Q2: 数据权限不生效？

A: 检查：
1. 是否启用了数据权限配置
2. 用户是否有正确的角色和权限
3. Service 是否正确继承了 AbstractFastsunDtoService

### Q3: 如何禁用某个接口的数据权限？

A: 在 Service 中重写方法：

```java
@Override
protected void beforePageQuery(QueryParameter query) {
    // 不调用 super，跳过数据权限
}
```

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [快速开始](../development/getting-started.md)
- [多租户架构](../architecture/multi-tenancy.md)
