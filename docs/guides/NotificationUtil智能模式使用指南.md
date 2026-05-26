# NotificationUtil 智能模式使用指南

## 一、核心改进

### 1.1 之前的问题

之前使用模板时，需要手动指定多个参数：

```java
// ❌ 旧方式 - 需要传很多参数
notificationUtil.sendSiteMessageWithTemplate(
    userId,
    "TPL_ORDER_NOTIFY",     // 模板ID
    "order_notify",         // 明细类型（需要从模板中读取）
    params
);
```

**问题：**
- 需要知道 `templateType`（虽然可以从模板ID推断）
- 需要知道 `detailType`（也需要从模板中读取）
- 参数多，容易出错

### 1.2 现在的解决方案 ⭐

**只需要传入 templateId，自动从模板中读取所有信息！**

```java
// ✅ 新方式 - 只需传入用户ID和模板ID
notificationUtil.sendMessageAuto(
    userId,
    "TPL_ORDER_NOTIFY",     // 只传模板ID
    params                  // 模板参数
);
```

**框架会自动：**
1. 根据 `templateId` 查询模板
2. 从模板中读取 `templateType`（site/wcp/mobile/email）
3. 从模板中读取 `detailType`
4. 自动设置其他必填字段

---

## 二、三种使用方式对比

### 方式1：最简化 - sendMessageAuto() ⭐⭐⭐ 推荐

**适用场景：** 已知用户ID，使用模板发送消息

```java
@Autowired
private NotificationUtil notificationUtil;

// 站内消息
Map<String, Object> params = new LinkedHashMap<>();
params.put("orderNo", "ORD20260417001");
params.put("amount", "999.00");

notificationUtil.sendMessageAuto(
    1001L,                      // 用户ID
    "TPL_ORDER_NOTIFY",         // 模板ID
    params                      // 模板参数
);
```

**优点：**
- ✅ 代码最简洁
- ✅ 自动获取用户姓名
- ✅ 自动读取模板信息
- ✅ 适用于站内、企微、短信等所有渠道

---

### 方式2：企业微信专用 - sendWechatMessageAuto() ⭐⭐

**适用场景：** 已知企业微信用户ID

```java
Map<String, Object> params = new LinkedHashMap<>();
params.put("title", "审批通知");
params.put("description", "有待办事项");

notificationUtil.sendWechatMessageAuto(
    "zhangsan",                 // 企业微信用户ID
    "TPL_WCP_APPROVAL",         // 模板ID
    params                      // 模板参数
);
```

**说明：**
- 通过 `externalId` 查找用户
- 如果找不到用户，使用 `wechatUserId` 作为姓名

---

### 方式3：通用智能模式 - sendMessageSmart() ⭐

**适用场景：** 已有接收者ID和姓名，不需要查询用户

```java
notificationUtil.sendMessageSmart(
    "1001",                     // 接收者ID
    "张三",                     // 接收者姓名
    "TPL_ORDER_NOTIFY",         // 模板ID
    params                      // 模板参数
);
```

**适用场景：**
- 批量发送（已准备好用户列表）
- 外部系统调用（已有用户信息）
- 性能优化（避免重复查询用户）

---

## 三、完整示例

### 3.1 站内消息

#### 配置模板

```sql
INSERT INTO TB_MESSAGE_TEMPLATE (
    TEMPLATE_ID, TEMPLATE_NAME, TEMPLATE_TYPE, 
    DETAIL_TYPE, TEMPLATE_CONTENT, TEMPLATE_STATUS, TENANT_CODE
) VALUES (
    'TPL_ORDER_NOTIFY',
    '订单通知',
    'site',
    'order_notify',
    '您的订单{orderNo}已发货，金额：{amount}元',
    'valid',
    'default'
);
```

#### 发送消息

```java
@Service
public class OrderService {
    
    @Autowired
    private NotificationUtil notificationUtil;
    
    public void notifyOrderShipped(Long userId, String orderNo, String amount) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put("orderNo", orderNo);
        params.put("amount", amount);
        
        // 一行代码搞定！
        Response response = notificationUtil.sendMessageAuto(
            userId,
            "TPL_ORDER_NOTIFY",
            params
        );
        
        if (response.success()) {
            log.info("订单通知发送成功");
        } else {
            log.error("订单通知发送失败: {}", response.getMessage());
        }
    }
}
```

---

### 3.2 企业微信消息

#### 配置模板

```sql
INSERT INTO TB_MESSAGE_TEMPLATE (
    TEMPLATE_ID, TEMPLATE_NAME, TEMPLATE_TYPE, 
    DETAIL_TYPE, TEMPLATE_CONTENT, TEMPLATE_STATUS, TENANT_CODE
) VALUES (
    'TPL_WCP_APPROVAL',
    '审批通知',
    'wcp',
    'approval_notify',
    '{title}\n{description}',
    'valid',
    'default'
);
```

#### 发送消息

```java
@Service
public class WorkflowService {
    
    @Autowired
    private NotificationUtil notificationUtil;
    
    public void notifyApprover(String wechatUserId, String title, String description) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put("title", title);
        params.put("description", description);
        
        // 一行代码搞定！
        notificationUtil.sendWechatMessageAuto(
            wechatUserId,
            "TPL_WCP_APPROVAL",
            params
        );
    }
}
```

---

### 3.3 短信验证码

#### 配置模板

```sql
INSERT INTO TB_MESSAGE_TEMPLATE (
    TEMPLATE_ID, TEMPLATE_NAME, TEMPLATE_TYPE, 
    DETAIL_TYPE, TEMPLATE_CONTENT, TEMPLATE_STATUS, TENANT_CODE
) VALUES (
    'SMS_VERIFY_CODE',
    '验证码',
    'mobile',
    'verify_code',
    '您的验证码是：{code}，5分钟内有效',
    'valid',
    'default'
);
```

#### 发送消息

```java
@Service
public class AuthService {
    
    @Autowired
    private NotificationUtil notificationUtil;
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    public void sendVerifyCode(String mobile) {
        // 生成验证码
        String code = String.valueOf((int)((Math.random()*9+1)*100000));
        
        Map<String, Object> params = new LinkedHashMap<>();
        params.put("code", code);
        
        // 发送短信
        notificationUtil.sendMessageSmart(
            mobile,                   // 手机号
            mobile,                   // 姓名（短信可以用手机号代替）
            "SMS_VERIFY_CODE",        // 模板ID
            params
        );
        
        // 存入Redis，5分钟过期
        redisTemplate.opsForValue().set(
            "sms:code:" + mobile, 
            code, 
            5, 
            TimeUnit.MINUTES
        );
    }
}
```

---

### 3.4 邮件通知

#### 配置模板

```sql
INSERT INTO TB_MESSAGE_TEMPLATE (
    TEMPLATE_ID, TEMPLATE_NAME, TEMPLATE_TYPE, 
    DETAIL_TYPE, TEMPLATE_CONTENT, TEMPLATE_STATUS, TENANT_CODE
) VALUES (
    'EMAIL_WELCOME',
    '欢迎邮件',
    'email',
    'welcome',
    '<h1>欢迎{userName}加入</h1><p>点击链接激活账号：{link}</p>',
    'valid',
    'default'
);
```

#### 发送消息

```java
@Service
public class UserService {
    
    @Autowired
    private NotificationUtil notificationUtil;
    
    public void sendWelcomeEmail(UserDTO user) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put("userName", user.getName());
        params.put("link", "http://xxx.com/activate?token=" + user.getToken());
        
        notificationUtil.sendMessageSmart(
            user.getEmail(),          // 邮箱地址
            user.getName(),           // 用户姓名
            "EMAIL_WELCOME",          // 模板ID
            params
        );
    }
}
```

---

## 四、高级用法

### 4.1 批量发送

```java
@Service
public class BatchNotificationService {
    
    @Autowired
    private NotificationUtil notificationUtil;
    
    @Autowired
    private IUserComposeService userComposeService;
    
    public void batchNotify(List<Long> userIds, String templateId, Map<String, Object> params) {
        for (Long userId : userIds) {
            try {
                // 异步发送，提高性能
                CompletableFuture.runAsync(() -> {
                    notificationUtil.sendMessageAuto(userId, templateId, params);
                });
            } catch (Exception e) {
                log.error("批量发送失败: userId={}", userId, e);
            }
        }
    }
}
```

### 4.2 多渠道同时发送

```java
public void notifyAllChannels(Long userId, String wechatUserId, String templateId, Map<String, Object> params) {
    // 站内消息
    notificationUtil.sendMessageAuto(userId, templateId, params);
    
    // 企业微信
    notificationUtil.sendWechatMessageAuto(wechatUserId, templateId, params);
    
    // 如果有手机号，还可以发短信
    UserDTO user = userService.findById(userId);
    if (!ObjectUtils.isEmpty(user.getMobile())) {
        notificationUtil.sendMessageSmart(
            user.getMobile(),
            user.getName(),
            templateId,
            params
        );
    }
}
```

### 4.3 条件发送

```java
public void smartNotify(UserDTO user, String templateId, Map<String, Object> params) {
    // 优先发送企业微信
    if (!ObjectUtils.isEmpty(user.getExternalId())) {
        notificationUtil.sendWechatMessageAuto(user.getExternalId(), templateId, params);
    }
    // 其次发送站内消息
    else {
        notificationUtil.sendMessageAuto(user.getId(), templateId, params);
    }
}
```

---

## 五、工作原理

### 5.1 流程图

```
调用 sendMessageAuto(userId, templateId, params)
  ↓
1. 根据 userId 查询用户信息
   - 获取 userName（必填）
  ↓
2. 根据 templateId 查询模板信息
   - 获取 templateType（site/wcp/mobile/email）
   - 获取 detailType（业务场景）
  ↓
3. 构建 ReminderDTO
   - 自动设置 templateType、messageType、detailType
   - 设置 receivers、receiverNames
   - 设置 params
  ↓
4. 调用 reminderComposeService.push()
   - 框架根据 templateType 找到对应的处理器
   - 渲染模板内容
   - 发送消息
```

### 5.2 关键代码

```java
// NotificationUtil.java

public Response sendMessageAuto(Long userId, String templateId, Map<String, Object> params) {
    // 1. 获取用户信息
    UserDTO user = getUserById(userId);
    
    // 2. 获取模板信息
    MessageTemplateDTO template = getTemplateById(templateId);
    
    // 3. 调用智能发送
    return sendMessageSmart(
        String.valueOf(userId),
        user.getName(),
        templateId,
        params
    );
}

public Response sendMessageSmart(String userIds, String userName, String templateId, Map<String, Object> params) {
    // 1. 查询模板
    MessageTemplateDTO template = getTemplateById(templateId);
    
    // 2. 构建 ReminderDTO
    ReminderDTO reminder = new ReminderDTO();
    reminder.setTemplateType(template.getTemplateType());  // 自动从模板读取
    reminder.setMessageType(template.getTemplateType());   // 自动从模板读取
    reminder.setDetailType(template.getDetailType());      // 自动从模板读取
    reminder.setTemplateId(template.getTemplateId());
    reminder.setReceivers(userIds);
    reminder.setReceiverNames(userName);  // 必填
    reminder.setParams(params);
    
    // 3. 发送
    return sendMessage(reminder);
}
```

---

## 六、常见问题

### Q1: 提示"模板不存在"？

**原因：**
- 模板未在数据库中配置
- `templateId` 写错

**解决方法：**
```sql
-- 检查模板是否存在
SELECT * FROM TB_MESSAGE_TEMPLATE WHERE TEMPLATE_ID = 'TPL_ORDER_NOTIFY';
```

### Q2: 提示"用户不存在"？

**原因：**
- 用户ID错误
- 用户已被删除

**解决方法：**
```java
// 先检查用户是否存在
UserDTO user = userService.findById(userId);
if (user == null) {
    log.error("用户不存在: {}", userId);
    return;
}
```

### Q3: 如何知道应该传哪些参数？

**方法：** 查看模板内容中的占位符

```sql
-- 查看模板内容
SELECT TEMPLATE_CONTENT FROM TB_MESSAGE_TEMPLATE 
WHERE TEMPLATE_ID = 'TPL_ORDER_NOTIFY';

-- 结果：您的订单{orderNo}已发货，金额：{amount}元
-- 所以需要传：orderNo, amount
```

```java
Map<String, Object> params = new LinkedHashMap<>();
params.put("orderNo", "ORD123");
params.put("amount", "999.00");
```

### Q4: 性能问题 - 每次都查询数据库吗？

**回答：**
- 用户信息：会查询数据库（可以加缓存优化）
- 模板信息：会查询数据库（可以加缓存优化）

**优化建议：**
```java
// 方案1：使用 sendMessageSmart()，自己管理用户信息
notificationUtil.sendMessageSmart(userId, userName, templateId, params);

// 方案2：在 Service 层加缓存
@Cacheable(value = "user", key = "#userId")
public UserDTO getUserWithCache(Long userId) {
    return userService.findById(userId);
}
```

### Q5: 可以同时使用旧方法和新方法吗？

**可以！** 新旧方法共存：

```java
// 新方法（推荐）
notificationUtil.sendMessageAuto(userId, templateId, params);

// 旧方法（仍然可用）
notificationUtil.sendSiteMessage(userId, title, content);
notificationUtil.sendWechatWorkTextCard(wechatUserId, title, desc, url);
```

---

## 七、最佳实践

### 7.1 推荐使用顺序

1. **首选：** `sendMessageAuto()` / `sendWechatMessageAuto()`
   - 代码最简洁
   - 自动化程度最高

2. **次选：** `sendMessageSmart()`
   - 批量发送时使用
   - 已有用户信息时使用

3. **备选：** 旧方法
   - 简单文本消息
   - 不使用模板的场景

### 7.2 模板设计建议

```sql
-- ✅ 好的模板设计
TEMPLATE_CONTENT: '您的订单{orderNo}已发货'

-- ❌ 不好的模板设计
TEMPLATE_CONTENT: '您的订单ORD20260417001已发货'  -- 硬编码
```

### 7.3 参数命名规范

```java
// ✅ 推荐：有意义的key
params.put("orderNo", "ORD123");
params.put("amount", "999.00");

// ❌ 不推荐：无意义的key
params.put("param1", "ORD123");
params.put("param2", "999.00");
```

---

## 八、总结

### 8.1 核心优势

| 特性 | 旧方式 | 新方式（智能模式） |
|------|--------|-------------------|
| 需要传 templateType | ✅ 需要 | ❌ 不需要 |
| 需要传 detailType | ✅ 需要 | ❌ 不需要 |
| 需要传 receiverNames | ✅ 需要 | ❌ 自动获取 |
| 代码行数 | 5-10行 | 1-3行 |
| 出错概率 | 高 | 低 |

### 8.2 使用建议

```java
// 🎯 最简单的用法
notificationUtil.sendMessageAuto(userId, templateId, params);

// 🎯 企业微信
notificationUtil.sendWechatMessageAuto(wechatUserId, templateId, params);

// 🎯 批量发送
notificationUtil.sendMessageSmart(userIds, userNames, templateId, params);
```

**记住：只需要 templateId，其他都是自动的！** 🚀

---

**文档版本：** v2.0  
**更新日期：** 2026-04-17  
**作者：** fastsun-platform 开发团队
