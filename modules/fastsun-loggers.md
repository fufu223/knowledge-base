# fastsun-loggers

## 模块概述

fastsun-loggers 是 Fastsun 平台的日志服务模块，提供多种日志存储和查询功能。

**路径**: `fastsun-loggers/`

**主要职责**：
- 操作日志记录
- 登录日志记录
- 系统日志管理
- 日志查询和统计
- 支持 MySQL、MongoDB 等多种存储

**子模块**：
- `fastsun-logger-mysql` - MySQL 存储
- `fastsun-logger-mongo` - MongoDB 存储
- `fastsun-logger-record` - 日志记录
- `fastsun-logger-subscribe` - 日志订阅
- `fastsun-logger-template` - 日志模板

---

## 核心功能

### 1. 操作日志

#### 使用注解记录日志

```java
@OperationLog(module = "用户管理", type = "add", description = "新增用户")
@PostMapping("/save")
public Response save(@RequestBody UserDTO user) {
    userService.save(user);
    return Response.success();
}
```

#### 手动记录日志

```java
@Autowired
private IOperationLogService operationLogService;

OperationLogDTO log = new OperationLogDTO();
log.setModule("订单管理");
log.setType("update");
log.setDescription("修改订单状态");
log.setOperatorId(userId);
log.setOperatorName(userName);
log.setOperateTime(new Date());
log.setResult("success");

operationLogService.save(log);
```

### 2. 登录日志

```java
@Autowired
private ILoginLogService loginLogService;

LoginLogDTO log = new LoginLogDTO();
log.setUsername(username);
log.setLoginIp(ip);
log.setLoginTime(new Date());
log.setStatus(1);  // 1:成功, 0:失败
log.setMessage("登录成功");

loginLogService.save(log);
```

### 3. 日志查询

```java
QueryParameter query = new QueryParameter();
query.addCondition("module", QueryOperator.EQ, "用户管理");
query.addCondition("operateTime", QueryOperator.GTE, startDate);
query.addCondition("operateTime", QueryOperator.LTE, endDate);

FastsunPage<OperationLogDTO> page = operationLogService.page(query);
```

---

## 配置项

### MySQL 存储

```yaml
fastsun:
  platform:
    logger:
      storage-type: mysql
      table-prefix: sys_
```

### MongoDB 存储

```yaml
fastsun:
  platform:
    logger:
      storage-type: mongo
      collection-prefix: log_
```

---

## API 接口

#### GET `/api/logger/operation/list`
**描述**: 查询操作日志

#### GET `/api/logger/login/list`
**描述**: 查询登录日志

#### DELETE `/api/logger/clear`
**描述**: 清空日志

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [配置指南](../configuration/properties.md)
