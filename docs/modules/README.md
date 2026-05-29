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

### 依赖关系说明

下表展示了各模块之间的引用和依赖关系：

| 模块 | 依赖模块 | 被依赖模块 | 说明 |
|------|---------|-----------|------|
| fastsun-base | Spring Boot/JPA/Hibernate | 所有模块 | 核心基础模块，所有模块都依赖 |
| fastsun-common | fastsun-base | fastsun-gateway, fastsun-ucenter 等 | 公共配置模块 |
| fastsun-core | fastsun-base, fastsun-common | - | 平台核心配置封装 |
| fastsun-domain | fastsun-base | fastsun-ucenter 等 | 领域模型定义 |
| fastsun-oauth | fastsun-base, fastsun-common | fastsun-gateway | 认证授权，网关依赖 |
| fastsun-ucenter | fastsun-base, fastsun-common | fastsun-oauth, fastsun-workflow 等 | 用户中心，被多个模块依赖 |
| fastsun-workflow | fastsun-base, fastsun-ucenter | - | 工作流引擎 |
| fastsun-lowcode | fastsun-base, fastsun-ucenter | - | 低代码平台 |
| fastsun-message | fastsun-base | - | 消息通知 |
| fastsun-gateway | fastsun-oauth, fastsun-common | - | API网关，依赖认证模块 |
| fastsun-tools | fastsun-base | fastsun-common 等 | 工具集成 |
| fastsun-quartz | fastsun-base | - | 定时任务 |
| fastsun-wechat | fastsun-base, fastsun-ucenter | fastsun-oauth | 微信集成 |
| fastsun-affix | fastsun-base | - | 附件管理 |
| fastsun-dashboard | fastsun-base | - | 仪表盘 |
| fastsun-form | fastsun-base | - | 表单管理 |
| fastsun-loggers | fastsun-base | - | 日志服务 |
| fastsun-dynamic | fastsun-base | - | 动态配置 |
| fastsun-sync | fastsun-base | - | 数据同步 |
| fastsun-sequence | fastsun-base, fastsun-tools/redis | - | 序列号 |
| fastsun-report | fastsun-base | - | 报表服务 |
| fastsun-ureport | fastsun-base | - | UReport报表 |
| fastsun-ruleflow | fastsun-base | - | 规则引擎 |
| fastsun-reminder | fastsun-base, fastsun-message | - | 提醒服务 |
| fastsun-sign | fastsun-base | - | 电子签名 |
| fastsun-service | fastsun-base | - | 服务管理 |
| fastsun-authority | fastsun-base | - | 权限拦截 |
| fastsun-xft | fastsun-base | - | 扩展功能 |
| fastsun-test | fastsun-base | - | 测试支持 |
| fastsun-synchron | fastsun-base | - | 数据同步框架 |
| fastsun-xxl-job | fastsun-base | - | XXL-JOB集成 |

### 依赖关系图

```
fastsun-base (基础核心)
    ├── fastsun-common (公共配置)
    │   ├── fastsun-oauth (认证授权)
    │   │   └── fastsun-gateway (API网关)
    │   ├── fastsun-ucenter (用户中心)
    │   │   ├── fastsun-workflow (工作流引擎)
    │   │   ├── fastsun-lowcode (低代码平台)
    │   │   ├── fastsun-wechat (微信集成)
    │   │   └── ...其他业务模块
    │   └── fastsun-tools (工具集成)
    │       ├── fastsun-sequence (序列号)
    │       └── ...其他工具
    ├── fastsun-domain (领域模型)
    ├── fastsun-core (核心基础)
    ├── fastsun-message (消息通知)
    │   └── fastsun-reminder (提醒服务)
    └── 其他基础模块
```

### 模块分类层级

```
基础设施层
  ├── fastsun-base         - 核心基础（工具类、注解、数据权限）
  ├── fastsun-common       - 公共配置（初始化、白名单、租户）
  ├── fastsun-core         - 核心封装（平台配置、基础服务）
  ├── fastsun-domain       - 领域模型（基础实体、DTO）
  └── fastsun-tools        - 中间件集成（Redis/Kafka/Mongo等）

业务核心层
  ├── fastsun-ucenter      - 用户中心（用户/组织/角色/租户）
  ├── fastsun-oauth        - 认证授权（OAuth2、登录、Token）
  ├── fastsun-workflow     - 工作流引擎（Activiti）
  ├── fastsun-lowcode      - 低代码平台（表单/视图/代码生成）
  ├── fastsun-message      - 消息通知（WebSocket/短信/邮件）
  └── fastsun-dashboard    - 仪表盘（数据可视化）

功能扩展层
  ├── fastsun-wechat       - 微信集成（公众号/小程序/企业微信）
  ├── fastsun-affix        - 附件管理（上传/下载/存储）
  ├── fastsun-form         - 表单管理（动态表单）
  ├── fastsun-quartz       - 定时任务（Quartz调度）
  ├── fastsun-reminder     - 提醒服务（多渠道提醒）
  └── fastsun-ruleflow     - 规则引擎

数据服务层
  ├── fastsun-loggers      - 日志服务（MySQL/MongoDB存储）
  ├── fastsun-sync         - 数据同步
  ├── fastsun-synchron     - 同步任务管理
  ├── fastsun-sequence     - 序列号生成
  ├── fastsun-report       - 报表服务
  └── fastsun-ureport      - UReport报表

微服务基础设施
  ├── fastsun-gateway      - API网关（路由/鉴权/限流）
  ├── fastsun-service      - 服务管理（Feign/Ribbon）
  ├── fastsun-authority    - 权限拦截
  └── fastsun-xxl-job      - XXL-JOB分布式调度

开发支持
  ├── fastsun-xft          - 扩展功能
  ├── fastsun-test         - 测试支持
  └── fastsun-dynamic      - 动态配置
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
