# 模块文档索引

## 已生成的模块文档

### ✅ 核心模块（已创建详细文档）

- [fastsun-base](./fastsun-base.md) - 基础核心模块 ⭐⭐⭐
  - 通用工具类、基础注解、数据权限控制、CRUD 抽象类
  
- [fastsun-oauth](./fastsun-oauth.md) - 认证授权模块 ⭐⭐⭐
  - OAuth2 认证服务器、多种登录方式、Token 管理、权限控制
  
- [fastsun-workflow](./fastsun-workflow.md) - 工作流模块 ⭐⭐⭐
  - 流程设计和部署、任务审批、动态节点添加、草稿箱功能

- [fastsun-ucenter](./fastsun-ucenter.md) - 用户中心模块 ⭐⭐⭐
  - 用户管理、组织架构、角色权限、租户管理、字典管理

- [fastsun-message](./fastsun-message.md) - 消息通知模块 ⭐⭐⭐
  - WebSocket 推送、短信发送、邮件发送、站内信、消息模板

- [fastsun-lowcode](./fastsun-lowcode.md) - 低代码平台模块 ⭐⭐⭐
  - 动态表单、视图配置、代码生成、函数库

### ✅ 基础设施模块

- [fastsun-gateway](./fastsun-gateway.md) - API 网关模块 ⭐⭐
  - 路由转发、统一认证、限流熔断、CORS 配置

- [fastsun-quartz](./fastsun-quartz.md) - 定时任务模块 ⭐⭐
  - 任务调度、集群支持、任务日志、动态管理

- [fastsun-tools](./fastsun-tools.md) - 工具集成模块 ⭐⭐
  - Redis、Kafka、RabbitMQ、MongoDB、Elasticsearch、Druid

### ✅ 业务功能模块

- [fastsun-wechat](./fastsun-wechat.md) - 微信集成模块 ⭐
  - 微信公众号、小程序、企业微信、微信支付

- [fastsun-affix](./fastsun-affix.md) - 附件管理模块 ⭐
  - 文件上传下载、本地/FastDFS/OSS 存储

- [fastsun-dashboard](./fastsun-dashboard.md) - 仪表盘模块 ⭐
  - 仪表盘布局、组件配置、数据可视化

### ✅ 其他模块（已全部生成）

- [fastsun-dynamic](./fastsun-dynamic.md) - 动态配置模块
  - 动态数据源、动态路由、运行时配置更新

- [fastsun-excel-template](./fastsun-excel-template.md) - Excel 模板模块
  - 基于模板的导入导出、模板管理

- [fastsun-form](./fastsun-form.md) - 表单模块
  - 动态表单设计、表单渲染、表单验证

- [fastsun-loggers](./fastsun-loggers.md) - 日志服务模块
  - 操作日志、登录日志、系统日志管理

- [fastsun-reminder](./fastsun-reminder.md) - 提醒模块
  - 定时提醒、多渠道推送、提醒订阅

- [fastsun-report](./fastsun-report.md) - 报表模块
  - 数据报表、统计分析、报表导出

- [fastsun-ruleflow](./fastsun-ruleflow.md) - 规则引擎模块
  - 规则设计、规则执行、版本管理

- [fastsun-sequence](./fastsun-sequence.md) - 序列号模块
  - 分布式序列号生成、本地/Redis 策略

- [fastsun-service](./fastsun-service.md) - 服务管理模块
  - 服务注册发现、Feign 调用、负载均衡

- [fastsun-sign](./fastsun-sign.md) - 电子签名模块
  - 数字签名、验签、RSA/SM2 算法

- [fastsun-sync](./fastsun-sync.md) - 数据同步模块
  - 全量/增量同步、数据转换映射

- [fastsun-synchron](./fastsun-synchron.md) - 同步领域模块
  - 同步任务管理、同步日志记录

- [fastsun-ureport](./fastsun-ureport.md) - UReport 报表模块
  - 复杂报表设计、报表预览和导出

- [fastsun-xft](./fastsun-xft.md) - 扩展功能模块
  - 自定义组件、第三方集成

- [fastsun-xxl-job](./fastsun-xxl-job.md) - XXL-JOB 集成模块
  - 分布式任务调度、分片广播

- [fastsun-core](./fastsun-core.md) - 核心基础模块
  - 平台配置、基础服务封装

- [fastsun-authority](./fastsun-authority.md) - 权限拦截模块
  - 资源权限控制、访问拦截

- [fastsun-domain](./fastsun-domain.md) - 领域模型模块
  - 基础实体定义、DTO 转换

- [fastsun-test](./fastsun-test.md) - 测试模块
  - 单元测试、集成测试支持
---

## 如何生成模块文档

### 方法一：使用自动化工具（推荐）

```bash
cd knowledge-base/tools

# 生成所有模块文档
python generate_knowledge_base.py --project ../../ --output ..

# 生成指定模块
python generate_knowledge_base.py --module fastsun-oauth
```

**Windows 用户**：
```bash
# 生成所有模块
generate_kb.bat

# 生成指定模块
generate_kb.bat fastsun-oauth
```

### 方法二：手动创建

参考已生成的模块文档格式，创建新的 Markdown 文件。

**文档结构**：
```markdown
# 模块名称

## 模块概述
- 路径
- 主要职责
- 子模块

## 主要类
- Controller 层
- Service 层
- Entity 层
- DTO 层

## 核心功能
1. 功能一
2. 功能二
3. ...

## API 接口
- 接口列表和说明

## 配置项
- 相关配置说明

## 使用示例
- 代码示例

## 常见问题
- Q&A

## 相关文档
- 链接到其他文档
```

---

## 模块分类

### 基础设施层
- fastsun-base
- fastsun-common
- fastsun-gateway
- fastsun-tools/*

### 业务核心层
- fastsun-ucenter/*
- fastsun-oauth/*
- fastsun-workflow/*
- fastsun-lowcode/*

### 功能扩展层
- fastsun-message/*
- fastsun-dashboard/*
- fastsun-report/*
- fastsun-wechat/*
- fastsun-quartz/*
- fastsun-reminder/*

### 数据服务层
- fastsun-loggers/*
- fastsun-sync/*
- fastsun-affix/*
- fastsun-sequence/*

---

## 模块依赖关系

```
fastsun-base (基础)
    ↓
fastsun-common (公共配置)
    ↓
fastsun-ucenter (用户中心) ← fastsun-oauth (认证)
    ↓
fastsun-workflow (工作流)
fastsun-lowcode (低代码)
fastsun-message (消息)
fastsun-dashboard (仪表盘)
    ↓
其他业务模块
```

---

## 快速查找

**按功能查找**：

| 功能 | 模块 |
|------|------|
| 用户管理 | fastsun-ucenter-user |
| 认证授权 | fastsun-oauth |
| 工作流 | fastsun-workflow |
| 低代码 | fastsun-lowcode-* |
| 消息推送 | fastsun-message-* |
| 仪表盘 | fastsun-dashboard-* |
| 定时任务 | fastsun-quartz |
| 报表 | fastsun-ureport, fastsun-report |
| 微信集成 | fastsun-wechat |
| 文件上传 | fastsun-affix |
| 日志记录 | fastsun-loggers-* |
| 缓存 | fastsun-tools/redis |
| 消息队列 | fastsun-tools/kafka, fastsun-tools/rabbitmq |

**按技术查找**：

| 技术 | 模块 |
|------|------|
| OAuth2 | fastsun-oauth |
| Activiti | fastsun-workflow |
| Redis | fastsun-tools/redis |
| Kafka | fastsun-tools/kafka |
| MongoDB | fastsun-tools/mongo |
| Elasticsearch | fastsun-tools/elastic |
| WebSocket | fastsun-message-websocket |
| Quartz | fastsun-quartz |
| XXL-JOB | fastsun-xxl-job |

---

## 贡献指南

如果您创建了新的模块文档，欢迎提交 PR：

1. Fork 项目
2. 在 `modules/` 目录创建文档
3. 遵循文档规范
4. 在本文件中添加链接
5. 提交 PR

---

*最后更新: 2026-05-09*
