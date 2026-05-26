# fastsun-ureport

## 模块概述

fastsun-ureport 是 Fastsun 平台的 UReport 报表模块，提供复杂的报表设计和展示功能。

**路径**: `fastsun-ureport/`

**主要职责**：
- 复杂报表设计
- 报表预览和打印
- 报表导出（PDF、Excel）
- 数据源配置

**子模块**：
- `fastsun-ureport-api` - API 接口
- `fastsun-ureport-domain` - 领域模型

---

## 核心功能

### 1. 报表设计

```java
@Autowired
private IUReportService ureportService;

// 保存报表设计
String reportXml = loadReportDesign();
ureportService.saveReport("sales_report", reportXml);
```

### 2. 报表预览

```java
@GetMapping("/report/preview/{reportCode}")
public void preview(@PathVariable String reportCode, 
                   HttpServletResponse response) {
    Map<String, Object> params = new HashMap<>();
    params.put("startDate", "2026-01-01");
    params.put("endDate", "2026-12-31");
    
    ureportService.preview(reportCode, params, response);
}
```

### 3. 报表导出

```java
// 导出为 Excel
@GetMapping("/report/export/excel/{reportCode}")
public void exportExcel(@PathVariable String reportCode,
                       HttpServletResponse response) {
    Map<String, Object> params = buildParams();
    ureportService.exportToExcel(reportCode, params, response);
}

// 导出为 PDF
@GetMapping("/report/export/pdf/{reportCode}")
public void exportPdf(@PathVariable String reportCode,
                     HttpServletResponse response) {
    Map<String, Object> params = buildParams();
    ureportService.exportToPdf(reportCode, params, response);
}
```

---

## 常用类

- `IUReportService` - UReport 服务
- `UReportDesigner` - 报表设计器
- `UReportEngine` - 报表引擎

---

## 最佳实践

### 动态数据源

```java
@Component
public class CustomDataSourceProvider implements DataSourceProvider {
    
    @Autowired
    private DataSource dataSource;
    
    @Override
    public Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
    
    @Override
    public void close() {
        // 关闭连接
    }
}
```

---

## 总结

fastsun-ureport 模块提供了强大的报表能力：
- ✅ 可视化报表设计
- ✅ 多种格式导出
- ✅ 复杂报表支持
- ✅ 动态数据源

适用于需要复杂报表展示的场景。
