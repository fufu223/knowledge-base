# 快速开始指南

## 环境要求

- **JDK**: 17 或更高版本
- **Maven**: 3.6+ 
- **MySQL**: 8.0+ (或其他支持的数据库)
- **Redis**: 5.0+
- **Node.js**: 16+ (前端开发需要)

## 项目结构

```
fastsun-platform/
├── fastsun-base/              # 基础核心模块
├── fastsun-common/            # 公共配置模块
├── fastsun-ucenter/           # 用户中心
├── fastsun-oauth/             # 认证授权
├── fastsun-workflow/          # 工作流引擎
├── fastsun-lowcode/           # 低代码平台
├── fastsun-message/           # 消息通知
├── fastsun-dashboard/         # 仪表盘
├── fastsun-gateway/           # API 网关
└── ...
```

## 快速启动

### 1. 克隆项目

```bash
git clone <repository-url>
cd fastsun-platform
```

### 2. 数据库初始化

执行 SQL 脚本初始化数据库：

```sql
-- 创建数据库
CREATE DATABASE fastsun DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 执行初始化脚本
source sql/init.sql;
```

### 3. 配置文件

复制并修改配置文件：

```bash
cp fastsun-gateway/src/main/resources/application.yml.example \
   fastsun-gateway/src/main/resources/application.yml
```

主要配置项：

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/fastsun?useUnicode=true&characterEncoding=utf8
    username: root
    password: your-password
  
  redis:
    host: localhost
    port: 6379
    password: 

fastsun:
  platform:
    base-url: http://localhost:8080
    multi:
      tenant:
        enable: false  # 是否启用多租户数据库隔离
    tenant:
      field-isolation: true  # 是否启用字段隔离
```

### 4. 编译项目

```bash
mvn clean install -DskipTests
```

### 5. 启动应用

```bash
# 启动网关
cd fastsun-gateway
mvn spring-boot:run

# 启动用户中心
cd ../fastsun-ucenter/fastsun-ucenter-user/fastsun-user-domain
mvn spring-boot:run

# 启动其他模块...
```

### 6. 访问系统

- **API 文档**: http://localhost:8080/swagger-ui.html
- **管理后台**: http://localhost:8080/admin

默认管理员账号：
- 用户名: `admin`
- 密码: `admin123`

## 创建第一个业务模块

### 1. 创建实体类

```java
package com.example.demo.entity;

import com.fastsun.platform.core.bean.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;
import javax.persistence.Entity;
import javax.persistence.Table;

@Data
@Entity
@Table(name = "demo_product")
@EqualsAndHashCode(callSuper = true)
public class Product extends BaseEntity {
    
    /**
     * 产品名称
     */
    private String name;
    
    /**
     * 产品价格
     */
    private Double price;
    
    /**
     * 产品描述
     */
    private String description;
}
```

### 2. 创建 DTO

```java
package com.example.demo.dto;

import com.fastsun.platform.core.bean.BaseDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@Schema(description = "产品DTO")
@EqualsAndHashCode(callSuper = true)
public class ProductDTO extends BaseDto {
    
    @Schema(description = "产品名称")
    private String name;
    
    @Schema(description = "产品价格")
    private Double price;
    
    @Schema(description = "产品描述")
    private String description;
}
```

### 3. 创建 Repository

```java
package com.example.demo.repository;

import com.example.demo.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
}
```

### 4. 创建 Service

```java
package com.example.demo.service;

import com.example.demo.dto.ProductDTO;
import com.example.demo.entity.Product;
import com.example.demo.repository.ProductRepository;
import com.fastsun.platform.core.service.impl.AbstractFastsunDtoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProductService extends AbstractFastsunDtoService<ProductDTO, Product, Long> {
    
    @Autowired
    private ProductRepository productRepository;
    
    @Override
    protected JpaRepository<Product, Long> getRepository() {
        return productRepository;
    }
}
```

### 5. 创建 Controller

```java
package com.example.demo.controller;

import com.example.demo.dto.ProductDTO;
import com.example.demo.service.ProductService;
import com.fastsun.platform.core.common.Response;
import com.fastsun.platform.core.controller.AbstractDTOCRUDController;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/product")
@Tag(name = "产品管理")
public class ProductController extends AbstractDTOCRUDController<ProductDTO> {
    
    @Autowired
    private ProductService productService;
    
    @Override
    protected com.fastsun.platform.core.service.IFastsunDtoService<ProductDTO> getService() {
        return productService;
    }
}
```

### 6. 测试 API

启动应用后，可以通过 Swagger UI 测试 API：

- **查询列表**: GET `/api/product/list`
- **查看详情**: GET `/api/product/{id}`
- **新增**: POST `/api/product/save`
- **更新**: PUT `/api/product/update`
- **删除**: DELETE `/api/product/delete/{id}`

## 常用功能

### 数据权限控制

在 Service 中重写方法实现数据权限：

```java
@Override
protected void beforePageQuery(QueryParameter query) {
    super.beforePageQuery(query);
    
    // 添加数据权限过滤
    UserDTO user = LocalUserContext.get();
    if (!user.isAdmin()) {
        query.addCondition("creatorId", QueryOperator.EQ, user.getId());
    }
}
```

### 缓存使用

```java
@Autowired
private ICacheService cacheService;

// 设置缓存
cacheService.set("key", value, 3600);

// 获取缓存
Object value = cacheService.get("key");

// 删除缓存
cacheService.delete("key");
```

### 消息发送

```java
@Autowired
private IMessageService messageService;

// 发送站内信
messageService.sendInternalMessage(userId, title, content);

// 发送邮件
messageService.sendEmail(email, subject, content);

// 发送短信
messageService.sendSms(phone, templateCode, params);
```

### 工作流使用

```java
@Autowired
private IFlowEngineService flowEngineService;

// 启动流程
StartProcessRequest request = new StartProcessRequest();
request.setProcessKey("approval");
request.setBusinessKey(businessId);
request.setVariables(variables);
flowEngineService.startProcess(request);

// 审批任务
AgreeRequest agreeRequest = new AgreeRequest();
agreeRequest.setTaskId(taskId);
agreeRequest.setComment("同意");
flowEngineService.agreeTask(agreeRequest);
```

## 开发规范

### 命名规范

- **实体类**: 使用名词，如 `User`, `Product`
- **DTO**: 实体名 + DTO，如 `UserDTO`, `ProductDTO`
- **Service**: 实体名 + Service，如 `UserService`
- **Controller**: 实体名 + Controller，如 `UserController`
- **Repository**: 实体名 + Repository，如 `UserRepository`

### 注释规范

```java
/**
 * 用户服务类
 * 
 * @author Your Name
 * @since 1.0.0
 */
@Service
public class UserService {
    
    /**
     * 根据用户名查询用户
     * 
     * @param username 用户名
     * @return 用户信息
     */
    public UserDTO findByUsername(String username) {
        // 实现代码
    }
}
```

### 异常处理

使用统一的异常处理：

```java
// 业务异常
throw new BusinessException("用户名已存在");

// 参数校验异常
throw new ParameterException("参数不能为空");

// 权限异常
throw new AccessDeniedException("没有操作权限");
```

## 调试技巧

### 1. 日志配置

```yaml
logging:
  level:
    com.fastsun: DEBUG
    com.example: DEBUG
    org.hibernate.SQL: DEBUG
```

### 2. 断点调试

在 IDEA 中设置断点，使用 Debug 模式启动应用。

### 3. API 测试

使用 Swagger UI 或 Postman 测试 API。

## 常见问题

### Q1: 启动时提示找不到 Bean?

检查是否缺少必要的依赖或配置，确保模块正确引入。

### Q2: 数据库连接失败?

检查数据库配置是否正确，数据库服务是否启动。

### Q3: Redis 连接失败?

检查 Redis 配置，确保 Redis 服务正常运行。

### Q4: 如何查看 SQL 语句?

配置 Hibernate 显示 SQL：

```yaml
spring:
  jpa:
    show-sql: true
    properties:
      hibernate:
        format_sql: true
```

## 下一步

- 阅读 [架构概述](../architecture/overview.md) 了解系统设计
- 查看 [模块详解](../modules/) 学习各模块使用
- 参考 [最佳实践](./best-practices.md) 提升开发效率

## 技术支持

如有问题，请联系技术支持团队或查阅相关文档。
