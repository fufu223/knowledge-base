# fastsun-xft

## 模块概述

fastsun-xft 是 Fastsun 平台的扩展功能模块，提供额外的业务功能支持。

**路径**: `fastsun-xft/`

**主要职责**：
- 扩展业务功能
- 自定义组件
- 第三方集成

**子模块**：
- `fastsun-xft-api` - API 接口
- `fastsun-xft-domain` - 领域模型

---

## 核心功能

### 1. 扩展服务

```java
@Autowired
private IXftService xftService;

// 调用扩展功能
XftResult result = xftService.execute("custom_operation", params);
```

### 2. 自定义组件

```java
@Component
public class CustomComponent implements XftComponent {
    
    @Override
    public String getName() {
        return "custom_component";
    }
    
    @Override
    public Object execute(Map<String, Object> params) {
        // 自定义逻辑
        return result;
    }
}
```

---

## 常用类

- `IXftService` - 扩展服务
- `XftComponent` - 扩展组件接口
- `XftConfig` - 扩展配置

---

## 总结

fastsun-xft 模块提供了灵活的扩展能力：
- ✅ 自定义业务逻辑
- ✅ 插件化组件
- ✅ 第三方集成

适用于需要扩展框架功能的场景。
