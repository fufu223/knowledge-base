# fastsun-oauth

## 模块概述

fastsun-oauth 是 Fastsun 平台的认证授权模块，基于 OAuth2 + Spring Security 实现完整的安全认证体系。

**路径**: `fastsun-oauth/`

**主要职责**：
- OAuth2 认证服务器
- OAuth2 资源服务器
- 多种登录方式支持
- Token 管理和验证
- 权限控制

**子模块**：
- `fastsun-oauth-authorization` - 认证服务器
- `fastsun-oauth-resource` - 资源服务器
- `fastsun-oauth-security` - 安全配置
- `fastsun-oauth-sdk` - SDK 接口

---

## 主要类

### 认证服务器

- `AuthorizationServerConfigurer` - 认证服务器配置
- `WebSecurityConfigurer` - Web 安全配置
- `Oauth2ManageService` - OAuth2 管理服务

### 认证器（登录方式）

- `UsernamePasswordAuthenticator` - 用户名密码登录
- `WechatMpAuthenticator` - 微信公众号登录
- `WechatCpMobileAuthenticator` - 企业微信登录
- `AbstractPreparableIntegrationAuthenticator` - 认证器抽象基类

### 登录策略

- `FirstLoginStrategyImpl` - 首次登录策略（踢掉旧会话）
- `LastLoginStrategyImpl` - 末次登录策略（禁止重复登录）

### Token 管理

- `SecurityTokenService` - Token 服务
- `TokenStore` - Token 存储（Redis/JWT）

### 过滤器

- `IntegrationAuthenticationFilter` - 集成认证过滤器
- `FeignRequestInterceptor` - Feign 请求拦截器（传递 Token）

---

## 核心功能

### 1. OAuth2 认证流程

**认证服务器配置**：

```java
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfigurer extends AuthorizationServerConfigurerAdapter {
    
    @Autowired
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private TokenStore tokenStore;
    
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory()
            .withClient("fastsun")
            .secret(passwordEncoder.encode("fastsun"))
            .authorizedGrantTypes(
                "password",           // 密码模式
                "refresh_token",      // 刷新令牌
                "authorization_code"  // 授权码模式
            )
            .scopes("all")
            .accessTokenValiditySeconds(7200)        // 2小时
            .refreshTokenValiditySeconds(2592000);   // 30天
    }
    
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) {
        endpoints
            .authenticationManager(authenticationManager)
            .tokenStore(tokenStore)
            .userDetailsService(userDetailsService);
    }
}
```

**资源服务器配置**：

```java
@Configuration
@EnableResourceServer
public class ResourceServerConfigurer extends ResourceServerConfigurerAdapter {
    
    @Override
    public void configure(HttpSecurity http) throws Exception {
        http
            .authorizeRequests()
            .antMatchers("/public/**").permitAll()  // 公开接口
            .anyRequest().authenticated();           // 其他需要认证
    }
}
```

### 2. 多种登录方式

#### 用户名密码登录

**类**: `UsernamePasswordAuthenticator`

```java
@Component
public class UsernamePasswordAuthenticator extends AbstractPreparableIntegrationAuthenticator {
    
    @Autowired
    private IUserComposeService userService;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Override
    protected UserDTO findUserInfo(IntegrationAuthentication auth, Application app) {
        String username = auth.getAuthParameter("username");
        String password = auth.getAuthParameter("password");
        
        // 1. 验证码校验
        checkCaptcha(auth);
        
        // 2. 查询用户
        UserDTO user = userService.findByUsername(username);
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 3. 密码校验
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        
        return user;
    }
}
```

**请求示例**：
```bash
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
&username=admin
&password=admin123
&client_id=fastsun
&client_secret=fastsun
```

**响应**：
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 7199,
  "scope": "all"
}
```

#### 微信公众号登录

**类**: `WechatMpAuthenticator`

```java
@Component
public class WechatMpAuthenticator extends AbstractPreparableIntegrationAuthenticator {
    
    @Override
    protected UserDTO findUserInfo(IntegrationAuthentication auth, Application app) {
        String code = auth.getAuthParameter("code");
        
        // 1. 通过 code 换取 openid
        String openid = wechatService.getOpenid(code);
        
        // 2. 根据 openid 查询用户
        UserDTO user = userService.findByOpenid(openid);
        
        // 3. 如果用户不存在，自动注册
        if (user == null) {
            user = createNewUser(openid);
        }
        
        return user;
    }
}
```

**请求示例**：
```bash
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
&auth_type=wechat_mp
&code=WECHAT_CODE
&client_id=fastsun
&client_secret=fastsun
```

#### 企业微信登录

**类**: `WechatCpMobileAuthenticator`

```java
@Component
public class WechatCpMobileAuthenticator extends AbstractPreparableIntegrationAuthenticator {
    
    @Override
    protected UserDTO findUserInfo(IntegrationAuthentication auth, Application app) {
        String code = auth.getAuthParameter("code");
        String agentId = auth.getAuthParameter("agentId");
        
        // 1. 获取企业微信用户信息
        WechatCpUser cpUser = wechatCpService.getUserInfo(code, agentId);
        
        // 2. 根据手机号查询用户
        UserDTO user = userService.findByMobile(cpUser.getMobile());
        
        return user;
    }
}
```

### 3. 登录策略

#### 首次登录策略（First Strategy）

新登录会使旧 Token 失效，保证同一用户只有一个有效会话。

```java
@Component("firstStrategy")
public class FirstLoginStrategyImpl implements ILoginStrategy {
    
    @Autowired
    private TokenStore tokenStore;
    
    @Autowired
    private ConsumerTokenServices consumerTokenServices;
    
    @Override
    public void execute(String clientId, String username) {
        // 查找该用户的所有 Token
        Collection<OAuth2AccessToken> tokens = 
            tokenStore.findTokensByClientIdAndUserName(clientId, username);
        
        if (!CollectionUtils.isEmpty(tokens)) {
            // 撤销所有旧 Token
            tokens.forEach(token -> 
                consumerTokenServices.revokeToken(token.getValue()));
        }
    }
}
```

**配置**：
```yaml
fastsun:
  platform:
    oauth:
      login-strategy: firstStrategy
```

#### 末次登录策略（Last Strategy）

不允许重复登录，如果已登录则抛出异常。

```java
@Component("lastStrategy")
public class LastLoginStrategyImpl implements ILoginStrategy {
    
    @Autowired
    private TokenStore tokenStore;
    
    @Override
    public void execute(String clientId, String username) {
        Collection<OAuth2AccessToken> tokens = 
            tokenStore.findTokensByClientIdAndUserName(clientId, username);
        
        if (!CollectionUtils.isEmpty(tokens)) {
            throw new FastsunOAuthException("您的账户已经登录，请不要重复登录！");
        }
    }
}
```

**配置**：
```yaml
fastsun:
  platform:
    oauth:
      login-strategy: lastStrategy
```

### 4. Token 管理

#### Redis Token Store

```java
@Bean
public TokenStore tokenStore(RedisConnectionFactory connectionFactory) {
    RedisTokenStore tokenStore = new RedisTokenStore(connectionFactory);
    tokenStore.setPrefix("oauth:token:");
    return tokenStore;
}
```

#### JWT Token Store

```java
@Bean
public TokenStore jwtTokenStore() {
    return new JwtTokenStore(accessTokenConverter());
}

@Bean
public JwtAccessTokenConverter accessTokenConverter() {
    JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
    converter.setSigningKey("your-secret-key");
    return converter;
}
```

#### Token 刷新

```bash
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&refresh_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
&client_id=fastsun
&client_secret=fastsun
```

#### Token 撤销

```java
@Autowired
private ConsumerTokenServices consumerTokenServices;

// 撤销 Token
consumerTokenServices.revokeToken(accessToken);
```

### 5. 权限控制

#### 资源权限

基于角色的访问控制（RBAC）：

```java
@Component
public class ResourcePermissionInterceptor implements HandlerInterceptor {
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) {
        UserDTO user = LocalUserContext.get();
        String url = request.getRequestURI();
        String method = request.getMethod();
        
        // 检查用户是否有访问该资源的权限
        boolean hasPermission = permissionService.checkPermission(
            user.getId(), url, method);
        
        if (!hasPermission) {
            throw new AccessDeniedException("没有访问权限");
        }
        
        return true;
    }
}
```

#### 白名单配置

```yaml
fastsun:
  platform:
    security:
      white-list:
        - /public/**
        - /login
        - /captcha
        - /swagger-ui/**
        - /v3/api-docs/**
```

---

## API 接口

### 认证接口

#### POST `/oauth/token`
**描述**: 获取 Access Token

**请求参数**（密码模式）:
```
grant_type=password
&username=admin
&password=admin123
&client_id=fastsun
&client_secret=fastsun
```

**请求参数**（刷新 Token）:
```
grant_type=refresh_token
&refresh_token=xxx
&client_id=fastsun
&client_secret=fastsun
```

**响应**:
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "refresh_token": "eyJhbGci...",
  "expires_in": 7199,
  "scope": "all"
}
```

#### POST `/oauth/revoke`
**描述**: 撤销 Token

**请求头**:
```
Authorization: Bearer {access_token}
```

### 管理接口

#### GET `/oauth/users/{username}/tokens`
**描述**: 查询用户的 Token 列表

#### DELETE `/oauth/users/{username}/tokens`
**描述**: 撤销用户的所有 Token

---

## 配置项

### OAuth2 基础配置

```yaml
fastsun:
  platform:
    oauth:
      client:
        id: fastsun
        secret: fastsun
      token:
        validity: 7200              # Access Token 有效期（秒）
        refresh-validity: 2592000   # Refresh Token 有效期（秒）
      login-strategy: firstStrategy # 登录策略
```

### Token 存储配置

#### Redis 存储
```yaml
spring:
  redis:
    host: localhost
    port: 6379
```

#### JWT 存储
```yaml
fastsun:
  platform:
    oauth:
      jwt:
        signing-key: your-secret-key
```

### 安全配置

```yaml
fastsun:
  platform:
    security:
      # 白名单
      white-list:
        - /public/**
        - /login
      
      # IP 白名单
      ip-white-list:
        - 127.0.0.1
      
      # 签名验证
      signature:
        enabled: true
        secret-key: your-secret-key
```

---

## 使用示例

### 示例 1：前端登录流程

```javascript
// 1. 用户输入用户名密码
const username = 'admin';
const password = 'admin123';

// 2. 调用登录接口
const response = await fetch('/oauth/token', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: new URLSearchParams({
    grant_type: 'password',
    username: username,
    password: password,
    client_id: 'fastsun',
    client_secret: 'fastsun'
  })
});

const data = await response.json();

// 3. 保存 Token
localStorage.setItem('access_token', data.access_token);
localStorage.setItem('refresh_token', data.refresh_token);

// 4. 后续请求携带 Token
fetch('/api/user/info', {
  headers: {
    'Authorization': `Bearer ${data.access_token}`
  }
});
```

### 示例 2：自定义登录方式

```java
@Component
public class SmsAuthenticator extends AbstractPreparableIntegrationAuthenticator {
    
    @Autowired
    private ISmsService smsService;
    
    @Override
    protected UserDTO findUserInfo(IntegrationAuthentication auth, Application app) {
        String mobile = auth.getAuthParameter("mobile");
        String code = auth.getAuthParameter("code");
        
        // 1. 验证短信验证码
        if (!smsService.verifyCode(mobile, code)) {
            throw new BusinessException("验证码错误");
        }
        
        // 2. 根据手机号查询用户
        UserDTO user = userService.findByMobile(mobile);
        
        // 3. 如果用户不存在，自动注册
        if (user == null) {
            user = createUserByMobile(mobile);
        }
        
        return user;
    }
    
    @Override
    public boolean support(IntegrationAuthentication authentication) {
        return "sms".equals(authentication.getAuthType());
    }
}
```

**使用**：
```bash
POST /oauth/token
grant_type=password
&auth_type=sms
&mobile=13800138000
&code=123456
&client_id=fastsun
&client_secret=fastsun
```

### 示例 3：Feign 调用传递 Token

```java
@Configuration
public class FeignConfig {
    
    @Bean
    public RequestInterceptor feignRequestInterceptor() {
        return template -> {
            // 从当前上下文获取 Token
            Authentication authentication = SecurityContextHolder
                .getContext().getAuthentication();
            
            if (authentication != null && 
                authentication.getDetails() instanceof OAuth2AuthenticationDetails) {
                
                OAuth2AuthenticationDetails details = 
                    (OAuth2AuthenticationDetails) authentication.getDetails();
                
                String token = details.getTokenValue();
                template.header("Authorization", "Bearer " + token);
            }
        };
    }
}
```

---

## 常见问题

### Q1: Token 过期如何处理？

A: 使用 Refresh Token 刷新：

```javascript
async function refreshToken() {
  const refreshToken = localStorage.getItem('refresh_token');
  
  const response = await fetch('/oauth/token', {
    method: 'POST',
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: 'fastsun',
      client_secret: 'fastsun'
    })
  });
  
  const data = await response.json();
  localStorage.setItem('access_token', data.access_token);
  localStorage.setItem('refresh_token', data.refresh_token);
}
```

### Q2: 如何实现单点登录（SSO）？

A: 使用 OAuth2 授权码模式：

1. 应用 A 重定向到认证服务器
2. 用户登录后获得授权码
3. 应用 A 用授权码换取 Token
4. 应用 B 可以使用相同的 Token

### Q3: 如何限制登录设备数量？

A: 使用 `LastLoginStrategy` 或在自定义策略中实现：

```java
@Component("deviceLimitStrategy")
public class DeviceLimitStrategyImpl implements ILoginStrategy {
    
    @Override
    public void execute(String clientId, String username) {
        Collection<OAuth2AccessToken> tokens = 
            tokenStore.findTokensByClientIdAndUserName(clientId, username);
        
        // 限制最多 3 个设备
        if (tokens.size() >= 3) {
            throw new FastsunOAuthException("登录设备已达上限");
        }
    }
}
```

### Q4: 如何自定义 Token 内容？

A: 扩展 `TokenEnhancer`：

```java
@Component
public class CustomTokenEnhancer implements TokenEnhancer {
    
    @Override
    public OAuth2AccessToken enhance(OAuth2AccessToken accessToken, 
                                     OAuth2Authentication authentication) {
        
        Map<String, Object> additionalInfo = new HashMap<>();
        UserDTO user = (UserDTO) authentication.getPrincipal();
        
        additionalInfo.put("userId", user.getId());
        additionalInfo.put("username", user.getUsername());
        additionalInfo.put("tenantCode", user.getTenantCode());
        
        ((DefaultOAuth2AccessToken) accessToken).setAdditionalInformation(additionalInfo);
        
        return accessToken;
    }
}
```

---

## 相关文档

- [安全架构](../architecture/security.md)
- [快速开始](../development/getting-started.md)
- [配置指南](../configuration/properties.md)
