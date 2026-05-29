# fastsun-xxl-job

## 模块概述

fastsun-xxl-job 是 Fastsun 平台的 XXL-JOB 集成模块，提供分布式任务调度功能。

**路径**: `fastsun-xxl-job/`

**主要职责**：
- 分布式任务调度
- 任务管理
- 执行日志
- 故障转移

**子模块**：
- `fastsun-xxl-job-core` - 核心组件

---

## 应用场景

- **定时批量处理**：每日定时执行数据统计、报表生成、数据清理等批量任务
- **分布式任务分片**：大数据量处理时通过分片广播实现并行处理，提升效率
- **跨服务任务编排**：在分布式微服务架构中统一管理各服务的定时任务
- **任务监控告警**：通过 XXL-JOB 管理台监控任务执行状态，失败自动告警

---

## 核心功能

### 1. 配置 XXL-JOB

```yaml
xxl:
  job:
    admin:
      addresses: http://127.0.0.1:8080/xxl-job-admin
    executor:
      appname: fastsun-executor
      port: 9999
      logpath: /data/applogs/xxl-job/jobhandler
      logretentiondays: 30
```

### 2. 创建任务处理器

```java
@Component
@XxlJob("demoJobHandler")
public class DemoJobHandler {
    
    @XxlJob("demoJobHandler")
    public void execute() throws Exception {
        XxlJobHelper.log("XXL-JOB 任务开始执行");
        
        // 业务逻辑
        System.out.println("执行定时任务...");
        
        XxlJobHelper.log("XXL-JOB 任务执行完成");
    }
}
```

### 3. 分片广播任务

```java
@Component
@XxlJob("shardingJobHandler")
public class ShardingJobHandler {
    
    @XxlJob("shardingJobHandler")
    public void execute() throws Exception {
        // 获取分片参数
        int shardIndex = XxlJobHelper.getShardIndex();
        int shardTotal = XxlJobHelper.getShardTotal();
        
        XxlJobHelper.log("分片参数: index={}, total={}", shardIndex, shardTotal);
        
        // 根据分片处理数据
        List<Data> dataList = getDataList();
        for (int i = 0; i < dataList.size(); i++) {
            if (i % shardTotal == shardIndex) {
                processData(dataList.get(i));
            }
        }
    }
}
```

### 4. 任务参数

```java
@Component
@XxlJob("paramJobHandler")
public class ParamJobHandler {
    
    @XxlJob("paramJobHandler")
    public void execute() throws Exception {
        // 获取任务参数
        String param = XxlJobHelper.getJobParam();
        
        XxlJobHelper.log("任务参数: {}", param);
        
        // 解析参数并执行
        Map<String, Object> params = parseParam(param);
        executeBusiness(params);
    }
}
```

---

## 常用类

- `@XxlJob` - 任务注解
- `XxlJobHelper` - 任务助手类
- `XxlJobExecutor` - 任务执行器

---

## 最佳实践

### 1. 任务幂等性

```java
@Component
@XxlJob("idempotentJobHandler")
public class IdempotentJobHandler {
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @XxlJob("idempotentJobHandler")
    public void execute() throws Exception {
        String lockKey = "job:lock:idempotentJobHandler";
        
        // 分布式锁
        Boolean locked = redisTemplate.opsForValue()
            .setIfAbsent(lockKey, "1", 5, TimeUnit.MINUTES);
        
        if (!Boolean.TRUE.equals(locked)) {
            XxlJobHelper.log("任务正在执行中，跳过");
            return;
        }
        
        try {
            // 业务逻辑
            doBusiness();
        } finally {
            redisTemplate.delete(lockKey);
        }
    }
}
```

### 2. 任务监控

```java
@Component
public class JobMonitorListener implements ApplicationListener<XxlJobEvent> {
    
    @Override
    public void onApplicationEvent(XxlJobEvent event) {
        String jobName = event.getJobName();
        long duration = event.getDuration();
        
        // 记录监控指标
        metricsService.record("job.execution.time", jobName, duration);
        
        // 告警
        if (duration > 60000) {
            alertService.alert("任务执行超时", jobName + ": " + duration + "ms");
        }
    }
}
```

---

## 注意事项

1. **任务幂等**：确保任务可以重复执行
2. **超时控制**：设置合理的超时时间
3. **异常处理**：捕获并记录异常
4. **日志记录**：详细记录执行日志

---

## 总结

fastsun-xxl-job 模块提供了强大的分布式任务调度能力：
- ✅ 可视化任务管理
- ✅ 分片广播
- ✅ 故障转移
- ✅ 执行日志

适用于需要定时任务和分布式调度的场景。
