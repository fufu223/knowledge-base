# fastsun-reminder

## 模块概述

fastsun-reminder 是 Fastsun 平台的提醒模块，提供多种渠道的定时提醒功能。

**路径**: `fastsun-reminder/`

**主要职责**：
- 定时提醒任务管理
- 多渠道提醒推送（短信、邮件、微信、钉钉）
- 提醒模板管理
- 提醒订阅管理

**子模块**：
- `fastsun-reminder-api` - API 接口
- `fastsun-reminder-domain` - 领域模型
- `fastsun-reminder-sdk` - SDK
- `fastsun-reminder-sdk-mix` - 混合 SDK
- `fastsun-reminder-subscribe` - 提醒订阅
- `fastsun-reminder-processor` - 提醒处理器

---

## 应用场景

### 1. 会议与日程提醒
适用于会议开始前、任务截止前等需要提前通知用户的场景，支持自定义提前时间和循环规则。

### 2. 任务超时催办
适用于流程审批超时、工单过期等需要催办督办的业务场景，通过多渠道推送确保任务及时处理。

### 3. 周期性打卡提醒
适用于每日签到、周报提交、月度总结等周期性业务的提醒，支持工作日/节假日规则配置。

### 4. 业务事件预警
适用于库存不足预警、合同到期提醒、会员生日祝福等业务事件驱动的提醒场景。

---

## 核心功能

### 1. 创建提醒任务

```java
@Autowired
private IReminderService reminderService;

ReminderDTO reminder = new ReminderDTO();
reminder.setTitle("会议提醒");
reminder.setContent("今天下午3点开会");
reminder.setRemindTime(new Date());
reminder.setChannel("wechat");  // wechat, sms, email, dingtalk

// 设置接收人
List<String> receivers = Arrays.asList("user001", "user002");
reminder.setReceivers(receivers);

reminderService.create(reminder);
```

### 2. 循环提醒

```java
ReminderDTO reminder = new ReminderDTO();
reminder.setTitle("每日打卡提醒");
reminder.setContent("请及时打卡");

// 设置循环规则
ReminderCycleDTO cycle = new ReminderCycleDTO();
cycle.setType("daily");  // daily, weekly, monthly
cycle.setTime("09:00");
cycle.setWeekDays(Arrays.asList(1, 2, 3, 4, 5));  // 工作日

reminder.setCycle(cycle);
reminderService.create(reminder);
```

### 3. 提醒模板

#### 创建模板

```java
ReminderTemplateDTO template = new ReminderTemplateDTO();
template.setCode("meeting_reminder");
template.setName("会议提醒模板");
template.setContent("您有一个会议：{{title}}，时间：{{time}}");
template.setChannel("wechat");

reminderTemplateService.save(template);
```

#### 使用模板发送提醒

```java
Map<String, Object> params = new HashMap<>();
params.put("title", "项目评审会");
params.put("time", "2026-05-09 15:00");

reminderService.sendByTemplate(
    "meeting_reminder",
    params,
    Arrays.asList("user001")
);
```

### 4. 提醒订阅

```java
// 用户订阅提醒
ReminderSubscribeDTO subscribe = new ReminderSubscribeDTO();
subscribe.setUserId("user001");
subscribe.setType("meeting");
subscribe.setChannel("wechat");
subscribe.setEnabled(true);

reminderSubscribeService.subscribe(subscribe);

// 取消订阅
reminderSubscribeService.unsubscribe("user001", "meeting");
```

---

## 提醒渠道

### 1. 微信提醒

```yaml
fastsun:
  platform:
    reminder:
      wechat:
        enabled: true
        app-id: your-app-id
        secret: your-secret
```

### 2. 短信提醒

```yaml
fastsun:
  platform:
    reminder:
      sms:
        enabled: true
        provider: aliyun  # aliyun, tencent
```

### 3. 邮件提醒

```yaml
spring:
  mail:
    host: smtp.example.com
    username: noreply@example.com
    password: your-password
```

### 4. 钉钉提醒

```yaml
fastsun:
  platform:
    reminder:
      dingtalk:
        enabled: true
        webhook: https://oapi.dingtalk.com/robot/send?access_token=xxx
```

---

## 常用类

### 服务层

- `IReminderService` - 提醒服务
- `IReminderTemplateService` - 提醒模板服务
- `IReminderSubscribeService` - 提醒订阅服务
- `IReminderProcessor` - 提醒处理器

### 实体类

- `Reminder` - 提醒实体
- `ReminderTemplate` - 提醒模板实体
- `ReminderSubscribe` - 提醒订阅实体

### 处理器

- `WechatReminderProcessor` - 微信提醒处理器
- `SmsReminderProcessor` - 短信提醒处理器
- `EmailReminderProcessor` - 邮件提醒处理器
- `DingtalkReminderProcessor` - 钉钉提醒处理器

---

## 最佳实践

### 1. 批量发送提醒

```java
List<ReminderDTO> reminders = new ArrayList<>();

for (Meeting meeting : meetings) {
    ReminderDTO reminder = new ReminderDTO();
    reminder.setTitle(meeting.getTitle());
    reminder.setContent(meeting.getDescription());
    reminder.setRemindTime(meeting.getStartTime());
    reminder.setReceivers(meeting.getParticipants());
    reminders.add(reminder);
}

reminderService.batchCreate(reminders);
```

### 2. 提醒优先级

```java
ReminderDTO reminder = new ReminderDTO();
reminder.setPriority("high");  // low, normal, high, urgent

// 高优先级提醒会立即发送
if ("urgent".equals(reminder.getPriority())) {
    reminderService.sendImmediately(reminder);
} else {
    reminderService.schedule(reminder);
}
```

### 3. 提醒重试机制

```java
@Component
public class ReminderRetryHandler {
    
    @Autowired
    private IReminderService reminderService;
    
    public void handleSendFailure(ReminderDTO reminder, Exception e) {
        // 记录失败日志
        log.error("提醒发送失败: {}", reminder.getId(), e);
        
        // 重试策略
        if (reminder.getRetryCount() < 3) {
            reminder.setRetryCount(reminder.getRetryCount() + 1);
            reminder.setNextRetryTime(
                new Date(System.currentTimeMillis() + 5 * 60 * 1000)
            );
            reminderService.update(reminder);
        } else {
            // 超过重试次数，发送告警
            alertService.alert("提醒发送失败", reminder);
        }
    }
}
```

### 4. 智能提醒时间

```java
@Service
public class SmartReminderService {
    
    /**
     * 根据用户习惯计算最佳提醒时间
     */
    public Date calculateRemindTime(UserDTO user, Date eventTime) {
        // 获取用户历史数据
        List<ReminderLog> logs = reminderLogService.getUserLogs(user.getId());
        
        // 分析用户平均提前多久处理提醒
        long avgAdvanceTime = logs.stream()
            .mapToLong(log -> log.getAdvanceTime())
            .average()
            .orElse(30 * 60 * 1000);  // 默认提前30分钟
        
        return new Date(eventTime.getTime() - avgAdvanceTime);
    }
}
```

---

## 注意事项

1. **时区问题**：注意用户时区差异
2. **频率限制**：避免频繁发送相同提醒
3. **退订机制**：提供便捷的退订方式
4. **隐私保护**：敏感信息需要脱敏

---

## 常见问题

### Q1: 提醒未按时发送？

**原因**：定时任务未执行或队列阻塞

**解决**：
- 检查定时任务配置
- 查看任务执行日志
- 监控队列状态

### Q2: 重复发送提醒？

**原因**：任务重复调度

**解决**：确保提醒任务的唯一性标识

```java
reminder.setUniqueKey(userId + "_" + eventType + "_" + eventDate);
```

---

## 相关配置

```yaml
fastsun:
  platform:
    reminder:
      # 是否启用 — 提醒模块总开关，关闭后所有提醒任务停止执行 <span class="config-required">(必需)</span>
      enabled: true
      # 定时任务 cron 表达式 — 提醒扫描任务的执行频率，默认每5分钟执行一次 <span class="config-required">(必需)</span>
      cron: "0 */5 * * * ?"
      # 最大重试次数 — 提醒发送失败后的最大重试次数，默认 3
      max-retry: 3
      # 重试间隔（分钟） — 每次重试之间的等待时间，默认 5
      retry-interval: 5
```

---

## 总结

fastsun-reminder 模块提供了完整的提醒功能：
- ✅ 多种提醒渠道支持
- ✅ 灵活的提醒模板
- ✅ 循环提醒任务
- ✅ 提醒订阅管理
- ✅ 智能提醒时间

适用于需要定时提醒的业务场景。

---

## 模块引用关系

| 模块名称 | 引用关系 | 说明 |
|---------|--------|------|
| fastsun-message | 依赖 | 通过消息模块发送短信、邮件、站内信等提醒通知 |
| fastsun-system | 依赖 | 提供用户信息用于接收人解析和时区计算 |
| fastsun-workflow | 被依赖 | 工作流模块的任务超时催办依赖提醒服务 |
| fastsun-lowcode | 被依赖 | 低代码平台通过提醒服务实现业务定时提醒 |
| fastsun-sequence | 依赖 | 生成提醒记录的业务编号 |
