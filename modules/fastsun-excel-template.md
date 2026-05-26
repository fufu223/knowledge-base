# fastsun-excel-template

## 模块概述

fastsun-excel-template 是 Fastsun 平台的 Excel 模板模块，提供基于模板的 Excel 导入导出功能。

**路径**: `fastsun-excel-template/`

**主要职责**：
- Excel 模板管理
- 基于模板的数据导出
- Excel 数据导入
- 模板动态渲染

**子模块**：
- `fastsun-excel-template-api` - API 接口
- `fastsun-excel-template-domain` - 领域模型
- `fastsun-excel-template-workflow` - 工作流集成

---

## 核心功能

### 1. 模板管理

#### 上传模板

```java
@Autowired
private IExcelTemplateService templateService;

@PostMapping("/upload")
public Response uploadTemplate(@RequestParam("file") MultipartFile file) {
    ExcelTemplateDTO template = templateService.upload(file);
    return Response.success(template);
}
```

#### 查询模板列表

```java
@GetMapping("/list")
public Response listTemplates() {
    List<ExcelTemplateDTO> templates = templateService.list();
    return Response.success(templates);
}
```

### 2. 基于模板导出

#### 简单导出

```java
@Autowired
private IExcelExportService exportService;

@GetMapping("/export")
public void export(HttpServletResponse response) {
    // 准备数据
    List<OrderDTO> orders = orderService.list();
    
    // 导出
    exportService.exportByTemplate(
        "order_template",  // 模板编码
        orders,            // 数据
        response
    );
}
```

#### 复杂导出（多 Sheet）

```java
Map<String, Object> data = new HashMap<>();
data.put("orders", orderList);
data.put("summary", summaryData);

exportService.exportByTemplate(
    "complex_template",
    data,
    response
);
```

### 3. 导入数据

```java
@PostMapping("/import")
public Response importData(@RequestParam("file") MultipartFile file) {
    List<OrderDTO> orders = exportService.importByTemplate(
        "order_template",
        file,
        OrderDTO.class
    );
    
    // 保存数据
    orderService.batchSave(orders);
    
    return Response.success("导入成功，共" + orders.size() + "条");
}
```

---

## 模板语法

### 基本变量

```
{{variable}}
```

示例：
```
订单号：{{orderNo}}
金额：{{amount}}
```

### 循环列表

```
{{#list}}
  {{item.field}}
{{/list}}
```

示例：
```
{{#orders}}
  {{orderNo}} | {{productName}} | {{amount}}
{{/orders}}
```

### 条件判断

```
{{#condition}}
  显示内容
{{/condition}}
```

### 格式化

```
{{date:yyyy-MM-dd}}
{{amount:#,##0.00}}
```

---

## 常用类

### 服务层

- `IExcelTemplateService` - 模板服务
- `IExcelExportService` - 导出服务
- `IExcelImportService` - 导入服务

### 实体类

- `ExcelTemplate` - 模板实体
- `ExcelTemplateDTO` - 模板 DTO

### 工具类

- `ExcelTemplateUtils` - 模板工具类
- `ExcelRenderEngine` - 模板渲染引擎

---

## 最佳实践

### 1. 定义模板

在 resources/templates 目录下创建 Excel 模板文件：

```
src/main/resources/templates/
  ├── order_template.xlsx
  ├── user_template.xlsx
  └── report_template.xlsx
```

### 2. 注册模板

```java
@Component
public class TemplateInitializer implements ApplicationRunner {
    
    @Autowired
    private IExcelTemplateService templateService;
    
    @Override
    public void run(ApplicationArguments args) {
        // 注册订单模板
        templateService.register(
            "order_template",
            "订单导出模板",
            "/templates/order_template.xlsx"
        );
    }
}
```

### 3. 自定义转换器

```java
@Component
public class CustomConverter implements DataConverter {
    
    @Override
    public Object convert(Object value, String pattern) {
        if (value instanceof Date) {
            return DateFormatUtils.format((Date) value, pattern);
        }
        return value;
    }
}
```

### 4. 大数据量导出

```java
@GetMapping("/export/large")
public void exportLargeData(HttpServletResponse response) {
    // 使用流式导出
    exportService.exportStream(
        "large_template",
        () -> orderService.streamQuery(),  // 流式查询
        response
    );
}
```

---

## 工作流集成

### 流程表单导出

```java
@Autowired
private IWorkflowExportService workflowExportService;

@GetMapping("/workflow/export/{instanceId}")
public void exportWorkflowForm(
    @PathVariable String instanceId,
    HttpServletResponse response) {
    
    workflowExportService.exportForm(instanceId, response);
}
```

---

## 注意事项

1. **模板格式**：支持 .xlsx 格式
2. **性能优化**：大数据量使用流式导出
3. **内存管理**：避免一次性加载大量数据
4. **模板缓存**：模板会被缓存，修改后需刷新

---

## 常见问题

### Q1: 模板变量不渲染？

**原因**：变量名不匹配或数据类型错误

**解决**：检查模板中的变量名是否与 DTO 字段一致

### Q2: 导出大文件内存溢出？

**原因**：一次性加载所有数据

**解决**：使用流式导出

```java
exportService.exportStream(templateCode, streamSupplier, response);
```

### Q3: 导入数据校验失败？

**解决**：实现自定义校验器

```java
@Component
public class OrderValidator implements DataValidator<OrderDTO> {
    
    @Override
    public ValidationResult validate(OrderDTO data) {
        ValidationResult result = new ValidationResult();
        
        if (StringUtils.isBlank(data.getOrderNo())) {
            result.addError("订单号不能为空");
        }
        
        return result;
    }
}
```

---

## 相关配置

```yaml
fastsun:
  platform:
    excel:
      template:
        # 模板存储路径
        storage-path: /data/templates
        # 是否启用缓存
        cache-enabled: true
        # 缓存过期时间（秒）
        cache-expire: 3600
```

---

## 总结

fastsun-excel-template 模块提供了强大的 Excel 模板功能：
- ✅ 基于模板的灵活导出
- ✅ 支持复杂表格结构
- ✅ 导入数据自动映射
- ✅ 工作流表单集成

适用于需要定制化 Excel 导出的业务场景。
