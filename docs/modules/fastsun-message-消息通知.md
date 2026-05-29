# fastsun-message

## 模块概述

fastsun-message 是 Fastsun 平台的消息通知模块，提供多种消息渠道的推送功能。

**路径**: `fastsun-message/`

**主要职责**：
- WebSocket 实时消息推送
- 短信发送（阿里云、腾讯云）
- 邮件发送
- 站内信管理
- 消息模板管理
- 企业微信/钉钉通知

**子模块**：
- `fastsun-message-websocket` - WebSocket 推送
- `fastsun-message-sms` - 短信服务
- `fastsun-message-push` - 消息推送
- `fastsun-message-template` - 消息模板

---

## 应用场景

### 1. 实时消息推送
适用于需要即时通知用户的场景，如订单状态变更、审批任务到达、系统公告等实时消息推送。

### 2. 多渠道消息通知
支持短信、邮件、站内信、企业微信/钉钉等多种消息渠道，满足不同场景下的消息触达需求。

### 3. 消息模板化管理
通过消息模板统一管理各渠道的消息内容格式，支持参数化渲染，提高消息维护效率。

### 4. 业务系统集成通知
为平台内其他业务模块提供统一的消息发送接口，实现各模块之间的事件驱动通知。

---

## 主要类

### WebSocket

- `WebSocketServer` - WebSocket 服务端
- `WebSocketConfig` - WebSocket 配置
- `MessagePushService` - 消息推送服务

### 短信

- `SmsService` - 短信服务接口
- `AliyunSmsService` - 阿里云短信
- `TencentSmsService` - 腾讯云短信

### 邮件

- `EmailService` - 邮件服务
- `EmailTemplateService` - 邮件模板服务

### 站内信

- `InternalMessageService` - 站内信服务
- `InternalMessageController` - 站内信控制器

---

## 核心功能

### 1. WebSocket 实时推送

#### 配置 WebSocket

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 注册 WebSocket 端点
        registry.addEndpoint("/ws")
                .setAllowedOrigins("*")
                .withSockJS();
    }
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // 配置消息代理
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setApplicationDestinationPrefixes("/app");
    }
}
```

#### 前端连接 WebSocket

```javascript
// 使用 SockJS + STOMP
const socket = new SockJS('/ws');
const stompClient = Stomp.over(socket);

stompClient.connect({}, function(frame) {
  console.log('Connected: ' + frame);
  
  // 订阅个人消息
  stompClient.subscribe('/queue/user/' + userId, function(message) {
    const data = JSON.parse(message.body);
    console.log('收到消息:', data);
    
    // 显示通知
    showNotification(data.title, data.content);
  });
  
  // 订阅广播消息
  stompClient.subscribe('/topic/notifications', function(message) {
    const data = JSON.parse(message.body);
    console.log('收到广播:', data);
  });
});
```

#### 后端推送消息

```java
@Autowired
private SimpMessagingTemplate messagingTemplate;

// 推送给指定用户
public void sendToUser(Long userId, String title, String content) {
    MessageDTO message = new MessageDTO();
    message.setTitle(title);
    message.setContent(content);
    message.setCreateTime(new Date());
    
    messagingTemplate.convertAndSendToUser(
        userId.toString(), 
        "/queue/messages", 
        message
    );
}

// 广播给所有用户
public void broadcast(String title, String content) {
    MessageDTO message = new MessageDTO();
    message.setTitle(title);
    message.setContent(content);
    
    messagingTemplate.convertAndSend("/topic/notifications", message);
}
```

### 2. 短信发送

#### 配置短信服务

```yaml
fastsun:
  platform:
    sms:
      provider: aliyun  # aliyun 或 tencent
      
      # 阿里云配置
      aliyun:
        access-key-id: your-access-key-id
        access-key-secret: your-access-key-secret
        sign-name: 您的签名
        region-id: cn-hangzhou
      
      # 腾讯云配置
      tencent:
        secret-id: your-secret-id
        secret-key: your-secret-key
        sdk-app-id: 1400000000
        sign-name: 您的签名
```

#### 发送短信

```java
@Autowired
private ISmsService smsService;

// 发送验证码
SmsRequest request = new SmsRequest();
request.setMobile("13800138000");
request.setTemplateCode("SMS_123456");
request.setTemplateParam("{\"code\":\"123456\"}");

smsService.send(request);

// 批量发送
List<String> mobiles = Arrays.asList("13800138000", "13900139000");
smsService.batchSend(mobiles, templateCode, templateParam);
```

#### 自定义短信服务

```java
@Component
public class CustomSmsService implements ISmsService {
    
    @Override
    public void send(SmsRequest request) {
        // 实现自定义短信发送逻辑
        // 例如：调用第三方短信平台 API
    }
    
    @Override
    public boolean support(String provider) {
        return "custom".equals(provider);
    }
}
```

### 3. 邮件发送

#### 配置邮件服务

```yaml
spring:
  mail:
    host: smtp.example.com
    port: 587
    username: noreply@example.com
    password: your-password
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```

#### 发送简单邮件

```java
@Autowired
private JavaMailSender mailSender;

public void sendSimpleEmail(String to, String subject, String content) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setTo(to);
    message.setSubject(subject);
    message.setText(content);
    
    mailSender.send(message);
}
```

#### 发送 HTML 邮件

```java
public void sendHtmlEmail(String to, String subject, String htmlContent) 
        throws MessagingException {
    
    MimeMessage message = mailSender.createMimeMessage();
    MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
    
    helper.setTo(to);
    helper.setSubject(subject);
    helper.setText(htmlContent, true);  // true 表示 HTML
    
    mailSender.send(message);
}
```

#### 发送带附件的邮件

```java
public void sendEmailWithAttachment(String to, String subject, 
                                    String content, File attachment) 
        throws MessagingException {
    
    MimeMessage message = mailSender.createMimeMessage();
    MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
    
    helper.setTo(to);
    helper.setSubject(subject);
    helper.setText(content, true);
    helper.addAttachment(attachment.getName(), attachment);
    
    mailSender.send(message);
}
```

#### 使用邮件模板

```java
@Autowired
private EmailTemplateService templateService;

public void sendTemplateEmail(String to, Map<String, Object> params) {
    // 渲染模板
    String subject = templateService.renderSubject("order_confirm", params);
    String content = templateService.renderContent("order_confirm", params);
    
    // 发送邮件
    emailService.sendHtmlEmail(to, subject, content);
}
```

**模板文件** (`templates/email/order_confirm.html`):
```html
<!DOCTYPE html>
<html>
<body>
  <h1>订单确认</h1>
  <p>尊敬的 ${userName}：</p>
  <p>您的订单 ${orderNo} 已确认。</p>
  <p>订单金额：${amount} 元</p>
</body>
</html>
```

### 4. 站内信

#### 发送站内信

```java
@Autowired
private IInternalMessageService messageService;

// 发送给单个用户
InternalMessageDTO message = new InternalMessageDTO();
message.setReceiverId(userId);
message.setTitle("系统通知");
message.setContent("您有新的待办任务");
message.setType("todo");  // todo, system, notice
message.setStatus(0);     // 0:未读, 1:已读

messageService.save(message);

// 批量发送
List<Long> receiverIds = Arrays.asList(1L, 2L, 3L);
messageService.batchSend(receiverIds, title, content, type);

// 发送给角色
messageService.sendToRole(roleCode, title, content);

// 发送给组织
messageService.sendToOrgan(organId, title, content);
```

#### 查询站内信

```java
// 查询用户的未读消息
QueryParameter query = new QueryParameter();
query.addCondition("receiverId", QueryOperator.EQ, userId);
query.addCondition("status", QueryOperator.EQ, 0);

FastsunPage<InternalMessageDTO> page = messageService.page(query);
```

#### 标记为已读

```java
// 标记单条为已读
messageService.markAsRead(messageId);

// 标记全部为已读
messageService.markAllAsRead(userId);
```

#### 删除站内信

```java
messageService.delete(messageId);

// 批量删除
messageService.batchDelete(new Long[]{1L, 2L, 3L});
```

### 5. 消息模板管理

#### 创建消息模板

```java
MessageTemplateDTO template = new MessageTemplateDTO();
template.setCode("ORDER_CONFIRM");
template.setName("订单确认通知");
template.setType("email");  // email, sms, internal
template.setSubject("订单确认 - ${orderNo}");
template.setContent("您的订单 ${orderNo} 已确认...");
template.setStatus(1);

templateService.save(template);
```

#### 使用模板发送消息

```java
@Autowired
private IMessageTemplateService templateService;

// 准备模板参数
Map<String, Object> params = new HashMap<>();
params.put("orderNo", "ORD20260509001");
params.put("userName", "张三");
params.put("amount", 999.00);

// 发送
templateService.sendByCode("ORDER_CONFIRM", userId, params);
```

---

## API 接口

### WebSocket 接口

#### WS `/ws`
**描述**: WebSocket 连接端点

**前端连接**:
```javascript
const socket = new SockJS('/ws');
const stompClient = Stomp.over(socket);
stompClient.connect({}, callback);
```

### 站内信接口

#### GET `/api/message/internal/list`
**描述**: 查询站内信列表

**请求参数**:
```
pageNum=1&pageSize=10&status=0
```

#### POST `/api/message/internal/send`
**描述**: 发送站内信

**请求体**:
```json
{
  "receiverId": 1,
  "title": "系统通知",
  "content": "您有新的消息",
  "type": "notice"
}
```

#### PUT `/api/message/internal/read/{id}`
**描述**: 标记为已读

#### DELETE `/api/message/internal/delete/{id}`
**描述**: 删除站内信

### 短信接口

#### POST `/api/sms/send`
**描述**: 发送短信

**请求体**:
```json
{
  "mobile": "13800138000",
  "templateCode": "SMS_123456",
  "templateParam": "{\"code\":\"123456\"}"
}
```

### 邮件接口

#### POST `/api/email/send`
**描述**: 发送邮件

**请求体**:
```json
{
  "to": "user@example.com",
  "subject": "测试邮件",
  "content": "<h1>Hello</h1>",
  "isHtml": true
}
```

---

## 配置项

### WebSocket 配置

```yaml
fastsun:
  platform:
    websocket:
      enabled: true            # 是否启用 WebSocket 服务 <span class="config-required">(必需)</span>
      path: /ws                # WebSocket 连接端点路径 <span class="config-required">(必需)</span>
      allowed-origins: "*"     # 允许跨域来源，生产环境建议设置具体域名
      heartbeat-interval: 30000 # 心跳检测间隔（毫秒），默认 30000
```

### 短信配置

```yaml
fastsun:
  platform:
    sms:
      provider: aliyun         # 短信服务提供商，可选：aliyun（阿里云）、tencent（腾讯云） <span class="config-required">(必需)</span>
      aliyun:
        access-key-id: LTAI***         # 阿里云 AccessKey ID <span class="config-required">(必需)</span>
        access-key-secret: ***         # 阿里云 AccessKey Secret <span class="config-required">(必需)</span>
        sign-name: 我的网站            # 短信签名，需在阿里云短信服务中审核通过 <span class="config-required">(必需)</span>
        template-code: SMS_123456      # 短信模板编码 <span class="config-required">(必需)</span>
```

### 邮件配置

```yaml
spring:
  mail:
    host: smtp.qq.com          # SMTP 服务器地址 <span class="config-required">(必需)</span>
    port: 587                  # SMTP 服务器端口，常用端口：25、465（SSL）、587（TLS） <span class="config-required">(必需)</span>
    username: xxx@qq.com       # 邮箱账号 <span class="config-required">(必需)</span>
    password: authorization-code # 邮箱授权码或密码 <span class="config-required">(必需)</span>
    properties:
      mail:
        smtp:
          auth: true           # 是否启用 SMTP 认证
          starttls:
            enable: true       # 是否启用 STARTTLS 加密
            required: true     # 是否要求必须使用 STARTTLS
```

---

## 使用示例

### 示例 1：完整的消息通知流程

```java
@Service
public class OrderNotificationService {
    
    @Autowired
    private IInternalMessageService internalMessageService;
    
    @Autowired
    private ISmsService smsService;
    
    @Autowired
    private EmailService emailService;
    
    /**
     * 订单创建后发送通知
     */
    public void notifyOrderCreated(Order order) {
        User user = userService.getById(order.getUserId());
        
        // 1. 发送站内信
        InternalMessageDTO internalMsg = new InternalMessageDTO();
        internalMsg.setReceiverId(user.getId());
        internalMsg.setTitle("订单创建成功");
        internalMsg.setContent("您的订单 " + order.getOrderNo() + " 已创建");
        internalMsg.setType("order");
        internalMessageService.save(internalMsg);
        
        // 2. 发送短信
        if (StringUtils.isNotEmpty(user.getMobile())) {
            SmsRequest smsRequest = new SmsRequest();
            smsRequest.setMobile(user.getMobile());
            smsRequest.setTemplateCode("SMS_ORDER_CREATED");
            smsRequest.setTemplateParam("{\"orderNo\":\"" + order.getOrderNo() + "\"}");
            smsService.send(smsRequest);
        }
        
        // 3. 发送邮件
        if (StringUtils.isNotEmpty(user.getEmail())) {
            Map<String, Object> params = new HashMap<>();
            params.put("orderNo", order.getOrderNo());
            params.put("amount", order.getAmount());
            emailService.sendTemplateEmail(user.getEmail(), "order_created", params);
        }
        
        // 4. WebSocket 实时推送
        webSocketService.sendToUser(user.getId(), "订单通知", 
            "您的订单已创建");
    }
}
```

### 示例 2：定时推送待办提醒

```java
@Component
public class TodoReminderTask {
    
    @Autowired
    private ITodoService todoService;
    
    @Autowired
    private IInternalMessageService messageService;
    
    @Scheduled(cron = "0 0 9 * * ?")  // 每天上午9点
    public void sendTodoReminder() {
        // 查询今天的待办
        List<TodoDTO> todos = todoService.findTodayTodos();
        
        // 按用户分组
        Map<Long, List<TodoDTO>> userTodos = todos.stream()
            .collect(Collectors.groupingBy(TodoDTO::getUserId));
        
        // 给每个用户发送提醒
        userTodos.forEach((userId, todoList) -> {
            String title = "待办提醒";
            String content = String.format("您今天有 %d 个待办事项", todoList.size());
            
            InternalMessageDTO message = new InternalMessageDTO();
            message.setReceiverId(userId);
            message.setTitle(title);
            message.setContent(content);
            message.setType("reminder");
            
            messageService.save(message);
            
            // WebSocket 推送
            webSocketService.sendToUser(userId, title, content);
        });
    }
}
```

### 示例 3：WebSocket 聊天室

```java
@Controller
public class ChatController {
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    @MessageMapping("/chat/send")
    public void sendMessage(ChatMessage message) {
        // 保存到数据库
        chatService.save(message);
        
        // 推送到聊天室
        messagingTemplate.convertAndSend(
            "/topic/chat/" + message.getRoomId(), 
            message
        );
    }
    
    @EventListener
    public void handleWebSocketConnectListener(SessionConnectedEvent event) {
        System.out.println("用户连接: " + event.getUser().getName());
    }
    
    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        System.out.println("用户断开: " + event.getUser().getName());
    }
}
```

---

## 常见问题

### Q1: WebSocket 连接失败？

A: 检查：
1. WebSocket 端点是否正确配置
2. 防火墙是否允许 WebSocket 连接
3. 前端是否正确引入 SockJS 和 STOMP

### Q2: 短信发送失败？

A: 检查：
1. AccessKey 是否正确
2. 短信签名是否审核通过
3. 模板是否正确
4. 手机号格式是否正确

### Q3: 邮件被识别为垃圾邮件？

A: 
1. 使用企业邮箱
2. 设置 SPF、DKIM 记录
3. 避免频繁发送相同内容
4. 添加退订链接

### Q4: 如何实现消息重试？

A:
```java
@Retryable(value = Exception.class, maxAttempts = 3, backoff = @Backoff(delay = 1000))
public void sendMessage(MessageDTO message) {
    // 发送消息
    // 如果失败会自动重试 3 次
}
```

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [快速开始](../development/getting-started.md)
- [配置指南](../configuration/properties.md)

---

## 模块引用关系

| 模块名称 | 引用关系 | 说明 |
|---------|--------|------|
| fastsun-system | 依赖 | 提供用户信息用于消息接收人解析 |
| fastsun-workflow | 被依赖 | 工作流模块在流程任务到达时调用消息模块发送通知 |
| fastsun-lowcode | 被依赖 | 低代码平台在应用操作时发送消息通知 |
| fastsun-reminder | 被依赖 | 提醒服务通过消息模块发送提醒通知 |
| fastsun-sequence | 依赖 | 生成消息记录的业务编号 |
