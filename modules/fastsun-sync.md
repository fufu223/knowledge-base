# fastsun-sync

## 模块概述

fastsun-sync 是 Fastsun 平台的数据同步模块，提供数据同步和迁移功能。

**路径**: `fastsun-sync/`

**主要职责**：
- 数据库间数据同步
- 增量同步
- 全量同步
- 数据转换和映射

---

## 核心功能

### 1. 全量同步

```java
@Autowired
private IDataSyncService dataSyncService;

// 配置同步任务
DataSyncTask task = new DataSyncTask();
task.setName("用户数据同步");
task.setSourceDb("source_db");
task.setTargetDb("target_db");
task.setTable("user");

// 执行同步
dataSyncService.syncFull(task);
```

### 2. 增量同步

```java
// 配置增量同步
DataSyncTask task = new DataSyncTask();
task.setType("incremental");
task.setLastSyncTime(lastSyncTime);
task.setPrimaryKey("id");

// 执行增量同步
dataSyncService.syncIncremental(task);
```

### 3. 定时同步

```java
@Component
public class ScheduledSyncTask {
    
    @Autowired
    private IDataSyncService dataSyncService;
    
    @Scheduled(cron = "0 0 2 * * ?")  // 每天凌晨2点
    public void syncData() {
        dataSyncService.syncFull("user_sync_task");
    }
}
```

---

## 常用类

- `IDataSyncService` - 数据同步服务
- `DataSyncTask` - 同步任务
- `DataSyncConfig` - 同步配置
- `DataTransformer` - 数据转换器

---

## 最佳实践

### 字段映射

```java
@DataMapping(source = "source_table", target = "target_table")
public class UserMapping {
    
    @FieldMapping(source = "user_name", target = "username")
    private String username;
    
    @FieldMapping(source = "mobile_phone", target = "phone")
    private String phone;
    
    @FieldMapping(source = "create_time", target = "created_at", 
                  converter = DateConverter.class)
    private Date createdAt;
}
```

---

## 总结

fastsun-sync 模块提供了灵活的数据同步能力：
- ✅ 全量和增量同步
- ✅ 定时同步任务
- ✅ 数据转换和映射
- ✅ 多数据源支持

适用于数据迁移和多库同步场景。
