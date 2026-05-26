# 企业微信消息 description 缺失问题修复

## 一、问题描述

### 错误信息

```
企业微信推送失败，原因为： description missing, hint: [1777536087609113353166538]
错误码：41033
```

### 错误原因

企业微信API要求文本卡片消息的 `description` 字段**不能为空**，但框架在处理时出现了问题。

---

## 二、问题分析

### 2.1 框架的处理逻辑

查看 `WechatCPMessageReminder.java` 第115-130行：

```java
private void setContent(ReminderDTO reminderDTO, WechatCPMessage build, MessageTemplateDTO template) {
    // 1. 使用 Freemarker 渲染模板内容
    String content = FreemarkerUtil.process(
        template.getTemplateName(), 
        template.getContent(), 
        reminderDTO.getParams()
    );

    // 2. 根据消息类型设置参数
    switch (reminderDTO.getWechatType()) {
        case "text":
            build.putParams("content", content);
            break;
        case "textcard":
            build.putParams("title", reminderDTO.getTitle());
            build.putParams("description", content);  // ❌ 这里用模板渲染结果
            build.putParams("url", reminderDTO.getLink());
            break;
    }
}
```

**关键问题：**
- `description` 的值来自 **模板渲染后的内容**（`content`）
- 不是来自 `reminderDTO.getParams()` 中的 `description`
- 如果模板不存在或模板内容为空，`content` 就是空字符串
- 导致企业微信API报错：`description missing`

---

### 2.2 之前的错误做法

```java
// ❌ 错误：设置了 params，但没有配置模板
Map<String, Object> params = new LinkedHashMap<>();
params.put("title", title);
params.put("description", description);  // 这个值会被忽略！
reminder.setParams(params);
reminder.setTemplateId("TPL_WCP_NOTIFY");  // 模板不存在
```

**结果：**
1. 框架查找模板 `TPL_WCP_NOTIFY` → 找不到
2. 或者找到模板但内容为空
3. 模板渲染结果为空字符串
4. `description` = ""（空）
5. 企业微信API报错

---

## 三、解决方案

### 方案1：修改 NotificationUtil（已完成）✅

**核心思路：** 不使用模板，直接设置 `message` 字段

#### 修改前

```java
// ❌ 旧代码
reminder.setTemplateId("TPL_WCP_NOTIFY");
Map<String, Object> params = new LinkedHashMap<>();
params.put("title", title);
params.put("description", description);
reminder.setParams(params);
```

#### 修改后

```java
// ✅ 新代码
// 不设置 templateId，避免模板查找
// reminder.setTemplateId("TPL_WCP_NOTIFY");

// 直接设置 message，框架会使用这个值作为 description
reminder.setMessage(description);
reminder.setLink(url);  // 如果有链接
```

**优点：**
- ✅ 不依赖模板配置
- ✅ 即插即用
- ✅ 保证 `description` 有值

---

### 方案2：配置企业微信默认模板（可选）

如果你希望使用模板功能，需要配置正确的模板：

```sql
-- 企业微信文本卡片默认模板
INSERT INTO TB_MESSAGE_TEMPLATE (
    ID, TEMPLATE_ID, TEMPLATE_NAME, TEMPLATE_TYPE, 
    DETAIL_TYPE, TEMPLATE_CONTENT, TEMPLATE_STATUS, TENANT_CODE
) VALUES (
    1000000002,
    'TPL_WCP_NOTIFY',
    '默认企微通知',
    'wcp',
    'wcp_notify',
    '{title}\n{description}',  -- ⚠️ 必须包含这两个占位符
    'valid',
    'default'  -- 改成你的租户编码
);
```

**关键点：**
- 模板内容必须包含 `{title}` 和 `{description}` 占位符
- 这样框架会用 `params` 中的值渲染出正确的内容

---

## 四、使用方法

### 4.1 发送企业微信文本消息

```java
@Autowired
private NotificationUtil notificationUtil;

// 简单文本消息
notificationUtil.sendWechatWorkText(
    "zhangsan",              // 企业微信用户ID
    "工作提醒",               // 标题
    "您有一个待办事项需要处理"  // 描述（会作为 content）
);
```

**特点：**
- ✅ 不需要配置模板
- ✅ 直接发送文本

---

### 4.2 发送企业微信文本卡片消息（推荐）⭐

```java
notificationUtil.sendWechatWorkTextCard(
    "zhangsan",                                    // 企业微信用户ID
    "审批通知",                                     // 标题
    "您有一个采购申请需要审批，请及时处理",           // 描述（必填！）
    "http://xxx.com/approval/123"                  // 点击跳转URL
);
```

**特点：**
- ✅ 显示标题和描述
- ✅ 支持点击跳转
- ✅ 不需要配置模板

---

### 4.3 批量发送

```java
notificationUtil.sendWechatWorkBatch(
    "zhangsan,lisi,wangwu",                       // 多个用户ID
    "会议通知",
    "今天下午3点在会议室A召开项目评审会",
    "http://xxx.com/meeting/456"
);
```

---

### 4.4 使用智能模式（需要配置模板）

```java
// 前提：数据库中必须有 TPL_WCP_APPROVAL 模板
Map<String, Object> params = new LinkedHashMap<>();
params.put("title", "审批通知");
params.put("description", "有待办事项");

notificationUtil.sendWechatMessageAuto(
    "zhangsan",
    "TPL_WCP_APPROVAL",  // 模板ID
    params
);
```

**注意：**
- 这种方法需要先配置模板
- 模板内容要包含 `{title}` 和 `{description}` 占位符

---

## 五、技术细节

### 5.1 框架如何处理 message 字段

当**没有设置 templateId** 时，框架的处理流程：

```
1. ReminderServiceImpl.push()
   - 检查是否有 templateId
   - 如果没有，直接使用 reminderDTO.getMessage()
   
2. AbstractMessageReminder.execute()
   - 检查是否有 templateId
   - 如果没有，跳过模板渲染
   
3. WechatCPMessageReminder.onReminder()
   - 调用 setContent()
   - 如果没有模板，使用 reminderDTO.getMessage() 作为 content
   - 对于 textcard 类型，将 content 设置为 description
```

**关键代码：**

```java
// ReminderServiceImpl.java 第174-190行
if(reminderDTO.getData()!=null && reminderDTO.getTemplateId()!=null) {
    // 有模板，进行渲染
    String resultMessage = FastsunTemplateUtil.process(...);
    reminderDTO.setMessage(resultMessage);
} else {
    // 没有模板，直接使用原有 message
    reminderDTO.setMessage(reminderDTO.getMessage());
}
```

---

### 5.2 企业微信API要求

根据[企业微信官方文档](https://developer.work.weixin.qq.com/document/path/90236)：

**文本卡片消息（textcard）必填字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `touser` | string | 是 | 接收者用户ID |
| `msgtype` | string | 是 | 消息类型，固定为 `textcard` |
| `agentid` | int | 是 | 应用ID |
| `textcard.title` | string | 是 | 标题 |
| `textcard.description` | string | **是** | 描述（不能为空） |
| `textcard.url` | string | 是 | 点击跳转URL |

**错误码 41033：** `description missing` - 描述字段缺失或为空

---

## 六、常见问题

### Q1: 为什么之前设置了 params 中的 description 还是报错？

**回答：** 框架会忽略 `params` 中的 `description`，而是使用**模板渲染后的内容**作为 `description`。

```java
// 你设置的
params.put("description", "描述内容");

// 但框架实际使用的是
String content = FreemarkerUtil.process(template.getContent(), params);
build.putParams("description", content);  // ← 用的是这个
```

如果模板不存在或内容为空，`content` 就是空字符串。

---

### Q2: 如何确认 description 有值？

**方法1：查看日志**

```java
log.info("发送企业微信卡片消息: wechatUserId={}, userName={}, title={}, url={}", 
        wechatUserId, userName, title, url);
```

**方法2：调试代码**

在 `WechatCPMessageReminder.setContent()` 方法中打断点，查看 `content` 的值。

**方法3：检查数据库**

```sql
-- 查看模板内容
SELECT TEMPLATE_CONTENT 
FROM TB_MESSAGE_TEMPLATE 
WHERE TEMPLATE_ID = 'TPL_WCP_NOTIFY';
```

---

### Q3: 同时使用 title 和 description 怎么配置？

**不使用模板的方式（推荐）：**

```java
notificationUtil.sendWechatWorkTextCard(
    "zhangsan",
    "审批通知",              // title
    "申请人：张三\n金额：5000元",  // description
    "http://xxx.com/approval/123"
);
```

**使用模板的方式：**

```sql
-- 模板内容
{title}\n{description}

-- 调用代码
Map<String, Object> params = new LinkedHashMap<>();
params.put("title", "审批通知");
params.put("description", "申请人：张三\n金额：5000元");

notificationUtil.sendWechatMessageAuto("zhangsan", "TPL_WCP_NOTIFY", params);
```

---

### Q4: description 可以有多长？

**企业微信限制：**
- `description` 最长 **512字节**
- 超过会被截断

**建议：**
- 保持简洁明了
- 重要信息放在前面
- 使用 `\n` 换行提高可读性

---

## 七、最佳实践

### 7.1 简单场景 - 不使用模板

```java
// ✅ 推荐：直接调用，无需配置
notificationUtil.sendWechatWorkTextCard(
    wechatUserId,
    title,
    description,
    url
);
```

**适用场景：**
- 临时通知
- 测试环境
- 简单的业务通知

---

### 7.2 复杂场景 - 使用模板

```java
// 1. 先配置模板
INSERT INTO TB_MESSAGE_TEMPLATE (...) VALUES (
    'TPL_WCP_ORDER',
    '订单通知',
    'wcp',
    'order_notify',
    '订单{orderNo}已发货\n金额：{amount}元\n下单时间：{orderTime}',
    'valid',
    'default'
);

// 2. 使用模板发送
Map<String, Object> params = new LinkedHashMap<>();
params.put("orderNo", "ORD123");
params.put("amount", "999.00");
params.put("orderTime", "2026-04-30 16:00:00");

notificationUtil.sendWechatMessageAuto(wechatUserId, "TPL_WCP_ORDER", params);
```

**适用场景：**
- 正式业务
- 需要统一管理消息格式
- 多租户不同配置

---

### 7.3 错误处理

```java
Response response = notificationUtil.sendWechatWorkTextCard(
    wechatUserId, title, description, url
);

if (!response.success()) {
    log.error("企业微信消息发送失败: {}", response.getMessage());
    // 重试或记录日志
}
```

---

## 八、总结

### 8.1 问题根源

```
框架使用模板渲染结果作为 description
  ↓
模板不存在或内容为空
  ↓
description 为空字符串
  ↓
企业微信API报错：description missing
```

### 8.2 解决方案

**方案1（已实施）：** 不使用模板，直接设置 `message` 字段
- ✅ 修改了 `sendWechatWorkText()`
- ✅ 修改了 `sendWechatWorkTextCard()`
- ✅ 修改了 `sendWechatWorkBatch()`
- ✅ 不再设置 `templateId`
- ✅ 直接设置 `reminder.setMessage(description)`

**方案2（可选）：** 配置正确的模板
- 模板内容包含 `{title}` 和 `{description}` 占位符
- 确保模板存在且状态为 `valid`

### 8.3 使用建议

| 场景 | 推荐方法 | 是否需要模板 |
|------|---------|-------------|
| 日常使用 | `sendWechatWorkTextCard()` | ❌ 不需要 |
| 批量发送 | `sendWechatWorkBatch()` | ❌ 不需要 |
| 正式业务 | `sendWechatMessageAuto()` | ✅ 需要 |

**记住：现在可以直接使用，不需要配置模板！** 🚀

---

**文档版本：** v1.0  
**更新日期：** 2026-04-30  
**作者：** fastsun-platform 开发团队
