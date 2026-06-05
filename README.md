# Fastsun Platform Docs

Fastsun 知识库面向使用平台框架的研发、架构与交付团队，聚合多租户框架、微服务模块、配置参考和常见排障文档。

## 从这里开始

- [快速使用指南](docs/guides/QUICKSTART.md)：第一次接入或本地预览时优先阅读。
- [入门指南](docs/development/入门指南.md)：了解开发约定、代码结构和基础流程。
- [架构概览](docs/architecture/架构概览.md)：快速建立平台全局模型。

## 推荐阅读路径

### 架构理解

- [架构概览](docs/architecture/架构概览.md)
- [多租户架构](docs/architecture/多租户架构.md)
- [安全架构](docs/architecture/安全架构.md)
- [业务流程图](docs/architecture/业务流程图.md)

### 核心能力

- [fastsun-base 基础模块](docs/modules/fastsun-base-基础模块.md)
- [fastsun-oauth 认证授权](docs/modules/fastsun-oauth-认证授权.md)
- [fastsun-ucenter 用户中心](docs/modules/fastsun-ucenter-用户中心.md)
- [fastsun-workflow 工作流引擎](docs/modules/fastsun-workflow-工作流引擎.md)
- [fastsun-lowcode 低代码平台](docs/modules/fastsun-lowcode-低代码平台.md)

### 交付与排障

- [配置项大全](docs/configuration/配置项大全.md)
- [数据权限实现机制](docs/guides/数据权限实现机制.md)
- [消息通知模块使用教程](docs/guides/消息通知模块使用教程.md)
- [消息模板配置问题排查指南](docs/guides/消息模板配置问题排查指南.md)
- [数据字典使用指南](docs/guides/数据字典使用指南.md)

## 本地预览

```bash
cd knowledge-base/tools
.\preview-nodejs.bat
```

访问 `http://127.0.0.1:8080`。如果端口被占用，可以在知识库目录启动任意静态文件服务。

## 文档信息

- 文档版本：2026-05-29
- 分支版本：`2.3.26-20260509-1-RELEASE`
- 面向人群：Fastsun 框架使用者
