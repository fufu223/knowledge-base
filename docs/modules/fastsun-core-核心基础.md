# fastsun-core

## 模块概述

fastsun-core 是 Fastsun 平台的核心基础模块，提供平台级别的基础功能和配置。

**路径**: `fastsun-core/`

**主要职责**：
- 平台核心配置
- 基础服务封装
- 通用组件

**子模块**：
- `fastsun-core-platform-api` - 平台 API
- `fastsun-core-platform-domain` - 平台领域模型
- `fastsun-core-platform-sdk` - 平台 SDK
- `fastsun-core-platform-sdk-mix` - 混合 SDK

---

## 核心功能

### 1. 平台配置

```yaml
fastsun:
  platform:
    # 平台名称
    name: Fastsun Platform
    # 版本号
    version: 1.0.0
    # 是否启用多租户
    multi-tenant:
      enabled: true
```

### 2. 基础服务

```java
@Autowired
private IPlatformService platformService;

// 获取平台信息
PlatformInfo info = platformService.getInfo();

// 获取配置
String config = platformService.getConfig("key");
```

---

## 常用类

- `IPlatformService` - 平台服务
- `PlatformConfig` - 平台配置
- `PlatformInfo` - 平台信息

---

## 总结

fastsun-core 模块提供了平台的核心基础能力：
- ✅ 平台配置管理
- ✅ 基础服务封装
- ✅ 通用组件支持

是整个框架的基础支撑模块。
