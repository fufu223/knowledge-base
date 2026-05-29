# fastsun-synchron

## 模块概述

fastsun-synchron 是 Fastsun 平台的数据同步领域模块，提供同步任务的领域模型和业务逻辑。

**路径**: `fastsun-synchron/`

**主要职责**：
- 同步任务管理
- 同步日志记录
- 同步状态跟踪

**子模块**：
- `fastsun-synchron-domain` - 领域模型

---

## 应用场景

- **定时同步任务**：管理跨系统、跨数据库的数据同步任务的生命周期
- **同步过程监控**：记录每次同步的执行记录，支持失败重试和告警
- **数据一致性保障**：通过同步日志追踪数据同步的完整过程，确保数据一致性

---

## 核心功能

### 1. 同步任务管理

```java
@Autowired
private ISyncTaskService syncTaskService;

// 创建同步任务
SyncTaskDTO task = new SyncTaskDTO();
task.setName("订单数据同步");
task.setSourceConfig(sourceConfig);
task.setTargetConfig(targetConfig);
task.setCron("0 0 2 * * ?");

syncTaskService.create(task);

// 启动任务
syncTaskService.start(task.getId());

// 暂停任务
syncTaskService.pause(task.getId());
```

### 2. 同步日志

```java
// 查询同步日志
List<SyncLogDTO> logs = syncLogService.listByTask(taskId);

for (SyncLogDTO log : logs) {
    System.out.println("同步时间: " + log.getSyncTime());
    System.out.println("同步数量: " + log.getRecordCount());
    System.out.println("状态: " + log.getStatus());
}
```

---

## 常用类

- `ISyncTaskService` - 同步任务服务
- `ISyncLogService` - 同步日志服务
- `SyncTask` - 同步任务实体
- `SyncLog` - 同步日志实体

---

## 总结

fastsun-synchron 模块提供了同步任务的完整管理能力：
- ✅ 任务配置和管理
- ✅ 同步日志记录
- ✅ 状态监控

配合 fastsun-sync 使用，实现完整的数据同步解决方案。
