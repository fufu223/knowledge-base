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

## 应用场景

### 1. 批量数据导出报表
在财务、运营等场景中，需要定期导出销售报表、财务报表、用户报表等。通过 Excel 模板配置表头格式、样式和计算公式，只需填充数据即可生成格式规范的报表文件。

### 2. 批量数据导入初始化
在系统上线数据迁移、批量导入客户信息、商品数据等场景中，用户通过下载模板填写数据后上传，系统自动解析模板字段映射关系，将 Excel 数据批量写入数据库。

### 3. 复杂多 Sheet 报表生成
在集团报表、多维分析等场景中，需要在同一个 Excel 文件中包含多个 Sheet，每个 Sheet 展示不同的统计维度。通过多 Sheet 模板配置和 Map 数据源，轻松生成复杂的多维度报表。

### 4. 工作流表单导出归档
在流程审批完成后，需要将流程表单数据导出为 Excel 进行归档或打印。结合工作流集成模块，自动拉取表单字段和审批记录，生成完整的流程归档文件。

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

## 配置项

```yaml
fastsun:
  platform:
    excel:
      template:
        storage-path: /data/templates   # 模板文件在服务器上的存储路径 <span class="config-required">(必需)</span>
        cache-enabled: true             # 是否启用模板缓存，启用后可加速模板加载
        cache-expire: 3600              # 模板缓存过期时间（秒），默认为 1 小时
```

---

## 总结

fastsun-excel-template 模块提供了强大的 Excel 模板功能：
- ✅ 基于模板的灵活导出
- ✅ 支持复杂表格结构
- ✅ 导入数据自动映射
- ✅ 工作流表单集成

适用于需要定制化 Excel 导出的业务场景。

## 模块引用关系

| 方向 | 模块名称 | 说明 |
|------|---------|------|
| 依赖 | fastsun-base | 依赖基础模块的工具类和异常处理 |
| 依赖 | fastsun-common | 依赖通用模块的公共组件 |
| 依赖 | fastsun-form | 依赖表单模块的工作流表单数据 |
| 被依赖 | 业务模块 | 各业务模块通过 Excel 模板实现数据导入导出 |
