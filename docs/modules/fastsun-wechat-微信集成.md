# fastsun-wechat

## 模块概述

fastsun-wechat 是 Fastsun 平台的微信集成模块，支持微信公众号、小程序、企业微信等功能。

**路径**: `fastsun-wechat/`

**主要职责**：
- 微信公众号接入
- 微信小程序登录
- 企业微信集成
- 微信支付
- 消息推送

---

## 应用场景

- **移动端快捷登录**：通过微信小程序或公众号授权实现一键登录，降低用户注册门槛
- **企业微信集成**：对接企业微信通讯录，实现组织架构同步和消息推送（审批通知、告警等）
- **微信支付接入**：在电商、缴费等场景中集成微信支付能力
- **消息触达**：通过公众号模板消息或企业微信应用消息，向用户发送业务通知

---

## 核心功能

### 1. 微信公众号

#### 配置

```yaml
fastsun:
  platform:
    wechat:
      mp:
        app-id: your-app-id          # 公众号 AppID <span class="config-required">(必需)</span>
        secret: your-secret          # 公众号 AppSecret <span class="config-required">(必需)</span>
        token: your-token            # 公众号 Token，用于消息验证
        aes-key: your-aes-key        # 消息加解密密钥（安全模式需要）

```

#### 接收消息

```java
@RestController
@RequestMapping("/wechat/mp")
public class WechatMpController {
    
    @Autowired
    private WechatMpService wechatMpService;
    
    @GetMapping
    public String verify(@RequestParam("signature") String signature,
                        @RequestParam("timestamp") String timestamp,
                        @RequestParam("nonce") String nonce,
                        @RequestParam("echostr") String echostr) {
        // 验证签名
        if (wechatMpService.verify(signature, timestamp, nonce)) {
            return echostr;
        }
        return "fail";
    }
    
    @PostMapping
    public String handleMessage(@RequestBody String xml) {
        // 处理微信消息
        return wechatMpService.handleMessage(xml);
    }
}
```

### 2. 微信小程序登录

```java
@PostMapping("/wechat/miniprogram/login")
public Response miniProgramLogin(@RequestBody MiniProgramLoginRequest request) {
    // 1. 通过 code 换取 session_key 和 openid
    WechatSession session = wechatService.code2Session(request.getCode());
    
    // 2. 根据 openid 查询或创建用户
    UserDTO user = userService.findByOpenid(session.getOpenid());
    if (user == null) {
        user = createUserFromWechat(session);
    }
    
    // 3. 生成 Token
    String token = oauthService.generateToken(user);
    
    return Response.success(token);
}
```

### 3. 企业微信

#### 配置

```yaml
fastsun:
  platform:
    wechat:
      cp:
        corp-id: your-corp-id        # 企业微信 CorpID <span class="config-required">(必需)</span>
        agent-id: your-agent-id      # 应用 AgentID <span class="config-required">(必需)</span>
        secret: your-secret          # 应用 Secret <span class="config-required">(必需)</span>
```

#### 获取用户信息

```java
@Autowired
private WechatCpService wechatCpService;

public WechatCpUser getUserInfo(String code) {
    // 通过 code 获取用户信息
    return wechatCpService.getUserInfo(code);
}
```

### 4. 微信支付

```java
@Autowired
private WechatPayService wechatPayService;

// 创建支付订单
public String createOrder(Order order) {
    WechatPayRequest request = new WechatPayRequest();
    request.setOutTradeNo(order.getOrderNo());
    request.setTotalFee(order.getAmount() * 100);  // 单位：分
    request.setBody("商品描述");
    request.setNotifyUrl("https://your-domain.com/wechat/pay/notify");
    
    return wechatPayService.createOrder(request);
}

// 支付回调
@PostMapping("/wechat/pay/notify")
public String payNotify(@RequestBody String xml) {
    WechatPayResult result = wechatPayService.handleNotify(xml);
    
    if (result.isSuccess()) {
        // 更新订单状态
        orderService.paySuccess(result.getOutTradeNo());
    }
    
    return "<xml><return_code><![CDATA[SUCCESS]]></return_code></xml>";
}
```

---

## API 接口

### 微信公众号

#### GET `/api/wechat/mp/verify`
**描述**: 验证服务器配置

#### POST `/api/wechat/mp/message`
**描述**: 接收微信消息

### 小程序

#### POST `/api/wechat/miniprogram/login`
**描述**: 小程序登录

### 企业微信

#### POST `/api/wechat/cp/login`
**描述**: 企业微信登录

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [认证授权](./fastsun-oauth.md)

---

## 模块引用关系

| 依赖类型 | 模块 | 说明 |
|---------|------|------|
| 依赖 | fastsun-base | 依赖核心基础模块 |
| 依赖 | fastsun-ucenter | 依赖用户中心进行用户关联 |
| 被依赖 | fastsun-oauth | OAuth 认证模块支持微信登录方式 |
