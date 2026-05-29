# fastsun-quartz

## 模块概述

fastsun-quartz 是 Fastsun 平台的定时任务模块，基于 Quartz 实现分布式定时任务调度。

**路径**: `fastsun-quartz/`

**主要职责**：
- 定时任务管理
- 任务调度和执行
- 任务日志记录
- 集群支持
- 动态添加/修改/删除任务

**子模块**：
- `fastsun-quartz-api` - API 接口
- `fastsun-quartz-domain` - 领域模型
- `fastsun-quartz-sdk` - SDK
- `fastsun-quartz-sdk-mix` - 混合 SDK

---

## 应用场景

### 1. 数据定时同步
在多数据源系统中，需要定时从源数据库抽取数据并同步到目标数据库。通过 fastsun-quartz 配置 Cron 表达式，实现每日凌晨自动执行数据同步任务，并记录每次同步的执行状态和日志。

### 2. 定时报表生成
企业运营需要每日、每周或每月生成统计报表并推送给相关人员。利用定时任务模块调用报表服务生成 PDF/Excel 报表，通过邮件或消息通知自动分发。

### 3. 过期数据清理
业务数据存在生命周期管理需求，例如超过 90 天的临时数据、30 天前的操作日志需要定期清理。通过定时任务结合自定义参数，灵活配置清理策略和保留时长。

### 4. HTTP 接口定时回调
在系统间集成场景中，需要定时调用第三方系统的 API 接口，如状态同步、心跳检测、定时推送等。通过 HttpJob 直接配置 URL 和方法，无需编写额外的 Job 实现类。

---

## 主要类

### 服务层

- `JobService` - 任务服务
- `JobLogService` - 任务日志服务
- `QuartzManager` - Quartz 管理器

### 实体类

- `Job` - 任务实体
- `JobLog` - 任务日志实体

### DTO

- `JobDTO` - 任务 DTO
- `JobLogDTO` - 任务日志 DTO

### Job 实现

- `AbstractJob` - 抽象 Job
- `HttpJob` - HTTP 请求 Job
- `BeanJob` - Spring Bean Job

---

## 核心功能

### 1. 创建定时任务

#### 使用注解方式

```java
@Component
public class MyJob implements Job {
    
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println("任务执行: " + new Date());
        
        // 业务逻辑
        doSomething();
    }
    
    private void doSomething() {
        // 具体业务
    }
}
```

#### 使用数据库配置

```java
JobDTO job = new JobDTO();
job.setJobName("数据同步任务");
job.setJobGroup("DEFAULT");
job.setBeanName("dataSyncJob");  // Spring Bean 名称
job.setMethodName("execute");     // 方法名
job.setCronExpression("0 0 2 * * ?");  // 每天凌晨2点
job.setStatus(1);  // 1:启用, 0:禁用

jobService.save(job);
```

### 2. Cron 表达式

常用 Cron 表达式示例：

```
每秒执行:    * * * * * ?
每分钟执行:  0 * * * * ?
每小时执行:  0 0 * * * ?
每天零点:    0 0 0 * * ?
每周一零点:  0 0 0 ? * MON
每月1号:     0 0 0 1 * ?
每5分钟:     0 0/5 * * * ?
工作日9点:   0 0 9 ? * MON-FRI
```

### 3. 任务管理

#### 启动任务

```java
@Autowired
private QuartzManager quartzManager;

// 启动任务
quartzManager.startJob(jobId);

// 或根据 Cron 启动
quartzManager.scheduleJob(jobDTO);
```

#### 暂停任务

```java
quartzManager.pauseJob(jobId);
```

#### 恢复任务

```java
quartzManager.resumeJob(jobId);
```

#### 删除任务

```java
quartzManager.deleteJob(jobId);
```

#### 立即执行一次

```java
quartzManager.triggerJob(jobId);
```

### 4. 任务参数传递

```java
JobDataMap dataMap = new JobDataMap();
dataMap.put("param1", "value1");
dataMap.put("param2", 123);

JobDetail jobDetail = JobBuilder.newJob(MyJob.class)
    .withIdentity("myJob", "DEFAULT")
    .usingJobData(dataMap)
    .build();
```

在 Job 中获取参数：

```java
@Override
public void execute(JobExecutionContext context) {
    JobDataMap dataMap = context.getMergedJobDataMap();
    String param1 = dataMap.getString("param1");
    int param2 = dataMap.getInt("param2");
}
```

### 5. 任务日志

#### 自动记录日志

```java
@Aspect
@Component
public class JobLogAspect {
    
    @Autowired
    private IJobLogService jobLogService;
    
    @Around("@annotation(Scheduled)")
    public Object around(ProceedingJoinPoint point) throws Throwable {
        JobLogDTO log = new JobLogDTO();
        log.setStartTime(new Date());
        log.setJobName(getJobName(point));
        
        try {
            Object result = point.proceed();
            log.setStatus(1);  // 成功
            log.setResult("success");
            return result;
        } catch (Exception e) {
            log.setStatus(0);  // 失败
            log.setErrorMsg(e.getMessage());
            throw e;
        } finally {
            log.setEndTime(new Date());
            jobLogService.save(log);
        }
    }
}
```

#### 查询任务日志

```java
QueryParameter query = new QueryParameter();
query.addCondition("jobName", QueryOperator.EQ, "数据同步任务");
query.addCondition("status", QueryOperator.EQ, 0);  // 只查失败的

FastsunPage<JobLogDTO> page = jobLogService.page(query);
```

### 6. 集群支持

#### 配置集群

```yaml
spring:
  quartz:
    job-store-type: jdbc
    jdbc:
      initialize-schema: never  # 不自动初始化表
    
    properties:
      org:
        quartz:
          scheduler:
            instanceId: AUTO
            instanceName: clusteredScheduler
          
          jobStore:
            class: org.quartz.impl.jdbcjobstore.JobStoreTX
            driverDelegateClass: org.quartz.impl.jdbcjobstore.StdJDBCDelegate
            tablePrefix: QRTZ_
            isClustered: true
            clusterCheckinInterval: 10000
            useProperties: false
          
          threadPool:
            class: org.quartz.simpl.SimpleThreadPool
            threadCount: 10
            threadPriority: 5
```

---

## API 接口

### 任务管理接口

#### GET `/api/quartz/job/list`
**描述**: 查询任务列表

#### POST `/api/quartz/job/save`
**描述**: 新增任务

**请求体**:
```json
{
  "jobName": "数据同步",
  "jobGroup": "DEFAULT",
  "beanName": "dataSyncJob",
  "methodName": "execute",
  "cronExpression": "0 0 2 * * ?",
  "status": 1
}
```

#### PUT `/api/quartz/job/update`
**描述**: 更新任务

#### DELETE `/api/quartz/job/delete/{id}`
**描述**: 删除任务

#### POST `/api/quartz/job/start/{id}`
**描述**: 启动任务

#### POST `/api/quartz/job/pause/{id}`
**描述**: 暂停任务

#### POST `/api/quartz/job/resume/{id}`
**描述**: 恢复任务

#### POST `/api/quartz/job/trigger/{id}`
**描述**: 立即执行一次

### 任务日志接口

#### GET `/api/quartz/log/list`
**描述**: 查询任务日志

#### DELETE `/api/quartz/log/clear`
**描述**: 清空日志

---

## 配置项

### Quartz 基础配置

```yaml
spring:
  quartz:
    # 任务存储类型：memory（内存）或 jdbc（数据库），生产环境建议使用 jdbc <span class="config-required">(必需)</span>
    job-store-type: jdbc
    
    # 是否覆盖已存在的同名任务，true 表示同名任务自动覆盖
    overwrite-existing-jobs: true
    
    # Quartz 调度器属性
    properties:
      org:
        quartz:
          scheduler:
            instanceName: myScheduler   # 调度器实例名称，集群模式下各实例需保持一致
          threadPool:
            threadCount: 10             # 任务线程池大小，影响并行执行的任务数量
```

### 数据源配置（JDBC Store）

```yaml
spring:
  datasource:
    quartz:
      url: jdbc:mysql://localhost:3306/fastsun_quartz  # Quartz 专用数据库连接地址 <span class="config-required">(必需)</span>
      username: root                                    # 数据库用户名 <span class="config-required">(必需)</span>
      password: password                                # 数据库密码 <span class="config-required">(必需)</span>
```

---

## 使用示例

### 示例 1：简单的定时任务

```java
@Component
public class SimpleJob {
    
    @Scheduled(cron = "0 0/5 * * * ?")  // 每5分钟执行
    public void execute() {
        System.out.println("简单任务执行: " + new Date());
    }
}
```

### 示例 2：HTTP 请求任务

```java
@Component("httpJob")
public class HttpJob {
    
    @Autowired
    private RestTemplate restTemplate;
    
    public void execute(String url, String method) {
        try {
            ResponseEntity<String> response;
            
            if ("GET".equalsIgnoreCase(method)) {
                response = restTemplate.getForEntity(url, String.class);
            } else {
                response = restTemplate.postForEntity(url, null, String.class);
            }
            
            System.out.println("HTTP 请求成功: " + response.getStatusCode());
            
        } catch (Exception e) {
            System.err.println("HTTP 请求失败: " + e.getMessage());
        }
    }
}
```

**配置任务**：
```json
{
  "jobName": "调用外部API",
  "beanName": "httpJob",
  "methodName": "execute",
  "cronExpression": "0 0 */1 * * ?",
  "params": {
    "url": "https://api.example.com/sync",
    "method": "POST"
  }
}
```

### 示例 3：数据同步任务

```java
@Component("dataSyncJob")
public class DataSyncJob {
    
    @Autowired
    private DataSource sourceDataSource;
    
    @Autowired
    private DataSource targetDataSource;
    
    public void execute() {
        System.out.println("开始数据同步...");
        
        try {
            // 从源数据库读取数据
            List<Map<String, Object>> data = readFromSource();
            
            // 写入目标数据库
            writeToTarget(data);
            
            System.out.println("数据同步完成，共同步 " + data.size() + " 条记录");
            
        } catch (Exception e) {
            System.err.println("数据同步失败: " + e.getMessage());
            throw e;
        }
    }
    
    private List<Map<String, Object>> readFromSource() {
        // 实现读取逻辑
        return new ArrayList<>();
    }
    
    private void writeToTarget(List<Map<String, Object>> data) {
        // 实现写入逻辑
    }
}
```

### 示例 4：带重试机制的任务

```java
@Component("retryJob")
public class RetryJob {
    
    private static final int MAX_RETRY = 3;
    
    public void execute() {
        int retryCount = 0;
        Exception lastException = null;
        
        while (retryCount < MAX_RETRY) {
            try {
                doWork();
                System.out.println("任务执行成功");
                return;
                
            } catch (Exception e) {
                retryCount++;
                lastException = e;
                System.err.println("任务执行失败，第 " + retryCount + " 次重试");
                
                if (retryCount < MAX_RETRY) {
                    try {
                        Thread.sleep(1000 * retryCount);  // 递增等待时间
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                    }
                }
            }
        }
        
        throw new RuntimeException("任务执行失败，已重试 " + MAX_RETRY + " 次", lastException);
    }
    
    private void doWork() {
        // 具体业务逻辑
    }
}
```

---

## 常见问题

### Q1: 任务不执行？

A: 检查：
1. Cron 表达式是否正确
2. 任务状态是否为启用
3. Quartz 是否正常启动
4. 查看任务日志是否有错误

### Q2: 集群环境下任务重复执行？

A: 确保配置了集群模式：
```yaml
org.quartz.jobStore.isClustered: true
```

### Q3: 如何动态修改 Cron 表达式？

A:
```java
public void updateCron(Long jobId, String newCron) {
    JobDTO job = jobService.getById(jobId);
    job.setCronExpression(newCron);
    jobService.update(job);
    
    // 重新调度
    quartzManager.rescheduleJob(jobId, newCron);
}
```

### Q4: 如何监控任务执行情况？

A:
1. 查看任务日志表 `qrtz_job_log`
2. 集成 Prometheus + Grafana
3. 使用 Quartz 自带的 JMX 监控

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [配置指南](../configuration/properties.md)

## 模块引用关系

| 方向 | 模块名称 | 说明 |
|------|---------|------|
| 依赖 | fastsun-base | 依赖基础模块的 Service 抽象和异常处理 |
| 依赖 | fastsun-common | 依赖通用模块的公共组件 |
| 依赖 | Spring Data JPA | 使用 JPA 存储任务和日志数据 |
| 被依赖 | 业务模块 | 各业务模块通过 SDK 接入定时任务能力 |
