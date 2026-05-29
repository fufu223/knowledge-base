# fastsun-dashboard

## 模块概述

fastsun-dashboard 是 Fastsun 平台的仪表盘模块，提供可视化的数据展示和组件管理功能。

**路径**: `fastsun-dashboard/`

**主要职责**：
- 仪表盘布局管理
- 组件配置和渲染
- 数据可视化
- 个性化定制

---

## 应用场景

- **个人工作台**：为不同角色用户定制个性化首页，展示待办任务、统计数据、通知公告等
- **运营监控面板**：实时展示系统运行指标、业务数据趋势、异常告警等
- **管理驾驶舱**：高管视角的全局数据汇总和多维度分析看板
- **角色自定义视图**：不同角色（管理员、普通用户）可配置不同的仪表盘布局和组件

---

## 核心功能

### 1. 仪表盘配置

```java
DashboardDTO dashboard = new DashboardDTO();
dashboard.setName("我的工作台");
dashboard.setLayout("grid");  // grid, list

// 添加组件
List<WidgetDTO> widgets = new ArrayList<>();

WidgetDTO chartWidget = new WidgetDTO();
chartWidget.setType("chart");
chartWidget.setTitle("销售统计");
chartWidget.setPosition(0, 0);
chartWidget.setSize(6, 4);
widgets.add(chartWidget);

dashboard.setWidgets(widgets);

dashboardService.save(dashboard);
```

### 2. 组件类型

- **图表组件**: 折线图、柱状图、饼图等
- **统计卡片**: 数字展示
- **列表组件**: 数据表格
- **日历组件**: 日程安排
- **快捷操作**: 常用功能入口

### 3. 数据源配置

```java
WidgetDataSource dataSource = new WidgetDataSource();
dataSource.setType("api");  // api, sql, static
dataSource.setUrl("/api/sales/statistics");
dataSource.setMethod("GET");

widget.setDataSource(dataSource);
```

---

## API 接口

#### GET `/api/dashboard/list`
**描述**: 查询仪表盘列表

#### POST `/api/dashboard/save`
**描述**: 保存仪表盘配置

#### GET `/api/widget/data/{widgetId}`
**描述**: 获取组件数据

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [快速开始](../development/getting-started.md)
