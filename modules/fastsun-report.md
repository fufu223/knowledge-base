# fastsun-report

## 模块概述

fastsun-report 是 Fastsun 平台的报表模块，提供数据报表和统计功能。

**路径**: `fastsun-report/`

**主要职责**：
- 数据报表生成
- 统计分析
- 报表导出（Excel、PDF）
- 图表展示

---

## 核心功能

### 1. 报表配置

```java
ReportDTO report = new ReportDTO();
report.setCode("sales_report");
report.setName("销售报表");
report.setType("table");  // table, chart

// 配置数据源
report.setSql("SELECT * FROM orders WHERE create_time >= :startDate");

// 配置列
List<ReportColumnDTO> columns = new ArrayList<>();
columns.add(new ReportColumnDTO("orderNo", "订单号"));
columns.add(new ReportColumnDTO("amount", "金额"));
report.setColumns(columns);

reportService.save(report);
```

### 2. 生成报表

```java
Map<String, Object> params = new HashMap<>();
params.put("startDate", "2026-01-01");
params.put("endDate", "2026-12-31");

ReportDataDTO data = reportService.generate("sales_report", params);
```

### 3. 导出 Excel

```java
@GetMapping("/export")
public void export(HttpServletResponse response) {
    reportService.exportToExcel("sales_report", params, response);
}
```

---

## API 接口

#### POST `/api/report/generate`
**描述**: 生成报表

#### GET `/api/report/export`
**描述**: 导出报表

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [UReport 报表](./fastsun-ureport.md)
