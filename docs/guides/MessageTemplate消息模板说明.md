# 消息模板（MessageTemplate）详细说明

## 一、什么是消息模板？

**消息模板**是 Fastsun 平台中用于统一管理消息内容的配置机制。它将消息的格式、内容、参数等集中管理，实现了：

- ✅ **内容与代码分离** - 修改消息内容无需重新编译代码
- ✅ **多租户支持** - 不同租户可以配置不同的消息模板
- ✅ **动态渲染** - 支持 Freemarker 模板引擎，动态替换参数
- ✅ **多渠道复用** - 同一业务场景可以为不同渠道配置不同模板

---

## 二、数据库表结构

### 表名：`TB_MESSAGE_TEMPLATE`

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `ID` | BIGINT | 主键ID | 1 |
| `TEMPLATE_ID` | VARCHAR(32) | 模板ID（唯一标识） | `TPL_ORDER_NOTIFY` |
| `TEMPLATE_NAME` | VARCHAR(50) | 模板名称 | `订单通知模板` |
| `TEMPLATE_TYPE` | VARCHAR(30) | 模板类型 | `site`, `wcp`, `mobile`, `email` |
| `DETAIL_TYPE` | VARCHAR(30) | 明细类型（业务场景） | `order_notify`, `verify_code` |
| `TEMPLATE_CONTENT` | TEXT | 模板内容（支持占位符） | `您的订单{orderNo}已发货` |
| `TEMPLATE_STATUS` | VARCHAR(20) | 状态 | `valid`（有效）, `invalid`（无效） |
| `TEMPLATE_URL` | VARCHAR(500) | 跳转链接 | `/order/detail/{orderId}` |
| `WECHAT_APPID` | VARCHAR(50) | 微信小程序AppId | `wx123456789` |
| `WECHAT_PAGE` | VARCHAR(200) | 小程序页面路径 | `pages/order/detail` |
| `TENANT_CODE` | VARCHAR(50) | 租户编码 | `default` |
| `ENTERPRISE_CODE` | VARCHAR(50) | 企业编码 | `enterprise001` |
| `CREATE_TIME` | DATETIME | 创建时间 | `2026-04-17 10:00:00` |
| `UPDATE_TIME` | DATETIME | 更新时间 | `2026-04-17 10:00:00` |

---

## 三、核心字段说明

### 3.1 TEMPLATE_TYPE（模板类型）

定义消息发送的渠道，对应枚举 `TemplateType`：

| 值 | 说明 | 用途 |
|----|------|------|
| `site` | 站内消息 | 系统内部消息中心显示 |
| `wcp` | 企业微信 | 发送到企业微信应用 |
| `wechat` | 微信公众号 | 发送到公众号 |
| `mobile` | 手机短信 | 发送短信验证码等 |
| `email` | 电子邮件 | 发送邮件通知 |
| `jpush` | 极光推送 | APP推送通知 |

### 3.2 DETAIL_TYPE（明细类型）

用于区分同一渠道下的不同业务场景，例如：

```
templateType = "mobile"
detailType 可以是：
  - "verify_code"      // 登录验证码
  - "reset_password"   // 找回密码
  - "order_notify"     // 订单通知
  - "workflow"         // 工作流通知
```

### 3.3 TEMPLATE_CONTENT（模板内容）

支持 **Freemarker** 模板语法，可以使用占位符：

```freemarker
// 简单变量
您好，{userName}！

// 条件判断
<#if amount > 1000>大额订单<#else>普通订单</#if>

// 列表遍历
<#list items as item>
  - ${item.name}: ${item.price}元
</#list>

// 默认值
${userName!'匿名用户'}
```

---

## 四、工作流程

### 4.1 整体流程

```
┌─────────────────────────────────────────────────────┐
│ 1. 开发者调用推送接口                                 │
│    notificationUtil.sendSiteMessageWithTemplate(...) │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 2. ReminderServiceImpl.push()                       │
│    - 设置租户信息                                     │
│    - 从 Redis 缓存读取模板列表                        │
│    - 根据 templateType + templateId 查找模板          │
│    - 如果找到模板，使用 Freemarker 渲染内容            │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 3. 发布消息事件（Redis Pub/Sub）                      │
│    messagePublisher.publisher(FastsunEventType.REMINDER) │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 4. AbstractMessageReminder.execute()                │
│    - 订阅到消息事件                                   │
│    - 再次验证模板存在                                 │
│    - 调用具体处理器 onReminder()                      │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 5. 具体处理器（如 WechatCPMessageReminder）           │
│    - 使用 handlerTemplate() 渲染模板                 │
│    - 调用第三方API发送消息                            │
│    - 更新发送状态                                     │
└─────────────────────────────────────────────────────┘
```

### 4.2 关键代码位置

#### （1）查找模板 - ReminderServiceImpl.java

```java
// 第176-186行
List<MessageTemplateDTO> templates = (List<MessageTemplateDTO>) 
    TenantCacheUtils.getValue(cache, MESSAGE_TEMPLATE_CACHE_NAME, reminderDTO.getTemplateType());

Assert.notNull(templates, "未找到当前模板类型【" + reminderDTO.getTemplateType() + "】的配置信息！");

MessageTemplateDTO template = templates.stream()
    .filter(o -> Objects.equals(o.getTemplateId(), finalReminderDTO.getTemplateId()))
    .findFirst()
    .orElseThrow(() -> new FastsunException("未找到当前租户配置的模板..."));

// 使用 Freemarker 渲染模板
String resultMessage = FastsunTemplateUtil.process(template.getContent(), (String)reminderDTO.getData());
reminderDTO.setMessage(resultMessage);
```

#### （2）使用模板 - AbstractMessageReminder.java

```java
// 第63-69行
List<MessageTemplateDTO> templateList = (List<MessageTemplateDTO>) 
    TenantCacheUtils.getValue(cache, SystemConstant.MESSAGE_TEMPLATE_CACHE_NAME, reminderDTO.getTemplateType());

MessageTemplateDTO template = templateList.stream()
    .filter(o -> Objects.equals(o.getTemplateId(), templateId))
    .findFirst()
    .orElseThrow(() -> new FastsunException("未找到模板..."));

// 第73行：传入模板对象给具体处理器
onReminder(reminderDTO, template);

// 第104-110行：模板渲染方法
protected String handlerTemplate(ReminderDTO reminderDTO, MessageTemplateDTO templateDTO) {
    return FreemarkerUtil.process(templateDTO.getTemplateName(), templateDTO.getContent(), reminderDTO.getParams());
}
```

---

## 五、如何配置消息模板

### 5.1 方式一：通过系统管理界面（推荐）

1. 登录系统管理后台
2. 进入 **系统管理 → 消息模板管理**
3. 点击 **新增**
4. 填写模板信息

**示例：订单通知模板**

```
模板ID: TPL_ORDER_NOTIFY
模板名称: 订单通知
模板类型: site
明细类型: order_notify
模板内容: 您的订单{orderNo}已发货，金额：{amount}元，下单时间：{orderTime}
状态: 有效
```

**示例：企业微信审批通知**

```
模板ID: TPL_WCP_APPROVAL
模板名称: 审批通知
模板类型: wcp
明细类型: approval_notify
模板内容: {title}\n{description}
状态: 有效
```

**示例：短信验证码**

```
模板ID: SMS_VERIFY_CODE
模板名称: 验证码
模板类型: mobile
明细类型: verify_code
模板内容: 您的验证码是：{code}，5分钟内有效，请勿泄露给他人。
状态: 有效
```

### 5.2 方式二：直接插入数据库

```sql
-- 站内消息模板
INSERT INTO TB_MESSAGE_TEMPLATE (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    TEMPLATE_TYPE,
    DETAIL_TYPE,
    TEMPLATE_CONTENT,
    TEMPLATE_STATUS,
    TENANT_CODE,
    CREATE_TIME,
    UPDATE_TIME
) VALUES (
    'TPL_ORDER_NOTIFY',
    '订单通知',
    'site',
    'order_notify',
    '您的订单{orderNo}已发货，金额：{amount}元',
    'valid',
    'default',
    NOW(),
    NOW()
);

-- 企业微信模板
INSERT INTO TB_MESSAGE_TEMPLATE (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    TEMPLATE_TYPE,
    DETAIL_TYPE,
    TEMPLATE_CONTENT,
    TEMPLATE_STATUS,
    TENANT_CODE
) VALUES (
    'TPL_WCP_APPROVAL',
    '审批通知',
    'wcp',
    'approval_notify',
    '{title}\n{description}',
    'valid',
    'default'
);

-- 短信模板
INSERT INTO TB_MESSAGE_TEMPLATE (
    TEMPLATE_ID,
    TEMPLATE_NAME,
    TEMPLATE_TYPE,
    DETAIL_TYPE,
    TEMPLATE_CONTENT,
    TEMPLATE_STATUS,
    TENANT_CODE
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

### 5.3 方式三：通过代码初始化

在系统启动时自动创建默认模板：

```java
@Component
public class DefaultTemplateInitializer implements ApplicationListener<ApplicationReadyEvent> {
    
    @Autowired
    private IMessageTemplateService templateService;
    
    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        // 检查模板是否存在
        if (!templateExists("TPL_ORDER_NOTIFY")) {
            MessageTemplateDTO template = new MessageTemplateDTO();
            template.setTemplateId("TPL_ORDER_NOTIFY");
            template.setTemplateName("订单通知");
            template.setTemplateType("site");
            template.setDetailType("order_notify");
            template.setContent("您的订单{orderNo}已发货，金额：{amount}元");
            template.setStatus("valid");
            templateService.save(template);
        }
    }
}
```

---

## 六、NotificationUtil 如何使用模板

### 6.1 使用模板发送消息（推荐）

```java
@Autowired
private NotificationUtil notificationUtil;

// 准备模板参数
Map<String, Object> params = new LinkedHashMap<>();
params.put("orderNo", "ORD20260417001");
params.put("amount", "999.00");
params.put("orderTime", "2026-04-17 10:30:00");

// 发送站内消息（使用模板）
Response response = notificationUtil.sendSiteMessageWithTemplate(
    1001L,                          // 用户ID
    "TPL_ORDER_NOTIFY",             // 模板ID
    "order_notify",                 // 明细类型
    params                          // 模板参数
);

if (response.success()) {
    System.out.println("发送成功");
} else {
    System.out.println("发送失败: " + response.getMessage());
}
```

**框架会自动：**
1. 根据 `templateType=site` 和 `templateId=TPL_ORDER_NOTIFY` 查找模板
2. 获取模板内容：`您的订单{orderNo}已发货，金额：{amount}元`
3. 使用 Freemarker 渲染：`您的订单ORD20260417001已发货，金额：999.00元`
4. 发送消息

### 6.2 不使用模板（简单文本）

```java
// 直接发送简单文本，不经过模板渲染
notificationUtil.sendSiteMessage(1001L, "通知标题", "通知内容");
```

这种方式适合临时通知，不需要配置模板。

### 6.3 企业微信使用模板

```java
// 准备参数
Map<String, Object> params = new LinkedHashMap<>();
params.put("title", "采购申请审批");
params.put("description", "申请人：张三\n金额：5000元");
params.put("url", "http://xxx.com/approval/123");

// 发送企业微信消息（使用模板）
Response response = notificationUtil.sendWechatWorkTextCardWithTemplate(
    "zhangsan",                     // 企业微信用户ID
    "TPL_WCP_APPROVAL",             // 模板ID
    "approval_notify",              // 明细类型
    params                          // 模板参数
);
```

---

## 七、模板占位符语法详解

框架使用 **Freemarker** 作为模板引擎，支持丰富的语法：

### 7.1 简单变量替换

```freemarker
// 模板
您好，{userName}！您的订单{orderNo}已发货。

// 参数
{
  "userName": "张三",
  "orderNo": "ORD20260417001"
}

// 结果
您好，张三！您的订单ORD20260417001已发货。
```

### 7.2 条件判断

```freemarker
// 模板
<#if amount gt 1000>
  恭喜您获得VIP优惠！
<#else>
  普通订单
</#if>

// 参数
{"amount": 1500}

// 结果
恭喜您获得VIP优惠！
```

### 7.3 列表遍历

```freemarker
// 模板
订单明细：
<#list items as item>
  - ${item.name}: ${item.price}元
</#list>
总计：${total}元

// 参数
{
  "items": [
    {"name": "商品A", "price": 100},
    {"name": "商品B", "price": 200}
  ],
  "total": 300
}

// 结果
订单明细：
  - 商品A: 100元
  - 商品B: 200元
总计：300元
```

### 7.4 默认值

```freemarker
// 模板
您好，${userName!'匿名用户'}！

// 参数（userName 为空）
{}

// 结果
您好，匿名用户！
```

### 7.5 日期格式化

```freemarker
// 模板
订单时间：${orderTime?string('yyyy-MM-dd HH:mm:ss')}

// 参数
{"orderTime": "2026-04-17T10:30:00"}

// 结果
订单时间：2026-04-17 10:30:00
```

### 7.6 数字格式化

```freemarker
// 模板
金额：${amount?string('0.00')}元

// 参数
{"amount": 999}

// 结果
金额：999.00元
```

---

## 八、常见问题

### Q1: 提示"未找到模板"？

**原因：**
- 模板未在数据库中配置
- `templateId` 或 `templateType` 写错
- Redis 缓存未更新

**解决方法：**
1. 检查数据库中是否有对应的模板记录
2. 确认 `templateId` 和 `templateType` 正确
3. 清除 Redis 缓存或重启服务

```bash
# 清除模板缓存
redis-cli DEL MESSAGE_TEMPLATE:site
redis-cli DEL MESSAGE_TEMPLATE:wcp
```

### Q2: 模板参数没有替换？

**原因：**
- `params` 为空或 key 不匹配
- 模板语法错误

**解决方法：**
1. 检查 `params` 中的 key 是否与模板中的占位符一致
2. 查看日志中的异常信息

```java
Map<String, Object> params = new LinkedHashMap<>();
params.put("orderNo", "ORD123");  // key 必须与模板中的 {orderNo} 一致
params.put("amount", "999.00");
```

### Q3: 如何调试模板？

**方法1：查看日志**

```java
log.debug("模板内容: {}", template.getContent());
log.debug("模板参数: {}", JsonUtils.toJsonString(params));
log.debug("渲染结果: {}", renderedContent);
```

**方法2：在线测试**

使用 Freemarker 在线测试工具：
- https://try.freemarker.apache.org/

**方法3：单元测试**

```java
@Test
public void testTemplate() {
    String template = "您的订单{orderNo}已发货";
    Map<String, Object> params = new HashMap<>();
    params.put("orderNo", "ORD123");
    
    String result = FreemarkerUtil.process("test", template, params);
    assertEquals("您的订单ORD123已发货", result);
}
```

### Q4: 模板修改后不生效？

**原因：** 模板缓存在 Redis 中

**解决方法：**
1. 清除 Redis 缓存
2. 或者重启服务

```bash
# 清除所有模板缓存
redis-cli KEYS "MESSAGE_TEMPLATE:*" | xargs redis-cli DEL
```

### Q5: 不同租户如何配置不同模板？

**方法：** 在创建模板时指定 `TENANT_CODE`

```sql
-- 租户A的模板
INSERT INTO TB_MESSAGE_TEMPLATE (...) VALUES (..., 'tenant_a');

-- 租户B的模板
INSERT INTO TB_MESSAGE_TEMPLATE (...) VALUES (..., 'tenant_b');
```

框架会根据当前租户上下文自动加载对应的模板。

---

## 九、最佳实践

### 9.1 模板命名规范

```
格式: TPL_{CHANNEL}_{BUSINESS}_{SCENE}

示例:
  TPL_SITE_ORDER_NOTIFY      // 站内-订单-通知
  TPL_WCP_APPROVAL_REMIND    // 企微-审批-提醒
  SMS_VERIFY_CODE_LOGIN      // 短信-验证码-登录
  EMAIL_ORDER_CONFIRM        // 邮件-订单-确认
```

### 9.2 明细类型规范

```
格式: {business}_{scene}

示例:
  order_notify               // 订单通知
  approval_remind            // 审批提醒
  verify_code_login          // 登录验证码
  workflow_task              // 工作流任务
```

### 9.3 模板内容设计

✅ **推荐：**
```freemarker
// 简洁明了
您的订单{orderNo}已发货

// 包含关键信息
审批提醒：{title}\n申请人：{applicant}\n金额：{amount}元
```

❌ **不推荐：**
```freemarker
// 过于复杂
<#if user.vip><#if order.amount>1000>...</#if></#if>

// 硬编码内容
订单号：ORD20260417001（应该用 {orderNo}）
```

### 9.4 参数设计

```java
// ✅ 推荐：使用有意义的 key
params.put("orderNo", "ORD123");
params.put("amount", "999.00");

// ❌ 不推荐：使用无意义的 key
params.put("param1", "ORD123");
params.put("param2", "999.00");
```

### 9.5 缓存策略

- 模板数据缓存在 Redis 中，提高性能
- 修改模板后需要清除缓存
- 建议在管理界面提供"刷新缓存"按钮

---

## 十、总结

### 10.1 核心要点

1. **MessageTemplate 是消息内容的配置中心**
   - 存储在数据库表 `TB_MESSAGE_TEMPLATE`
   - 缓存在 Redis 中提高性能

2. **模板通过 templateType + templateId 定位**
   - `templateType`: 渠道类型（site/wcp/mobile/email）
   - `templateId`: 模板唯一标识

3. **使用 Freemarker 渲染模板**
   - 支持变量替换、条件判断、列表遍历等
   - 参数通过 `params` 传递

4. **NotificationUtil 简化了模板使用**
   - `sendSiteMessageWithTemplate()` - 使用模板
   - `sendSiteMessage()` - 简单文本

### 10.2 使用建议

- ✅ **推荐使用模板** - 便于管理和维护
- ✅ **合理设计模板结构** - 简洁明了
- ✅ **规范命名** - 方便查找和使用
- ✅ **做好缓存管理** - 修改后及时刷新

---

**文档版本：** v1.0  
**更新日期：** 2026-04-17  
**作者：** fastsun-platform 开发团队
