# fastsun-sign

## 模块概述

fastsun-sign 是 Fastsun 平台的电子签名模块，提供数字签名和验签功能。

**路径**: `fastsun-sign/`

**主要职责**：
- 数据签名
- 签名验证
- 支持多种签名算法（RSA、SM2）
- 证书管理

---

## 核心功能

### 1. RSA 签名

```java
@Autowired
private ISignService signService;

// 签名
String data = "Hello World";
String privateKey = "-----BEGIN PRIVATE KEY-----\n...";
String signature = signService.sign(data, privateKey, SignAlgorithm.RSA);

// 验签
String publicKey = "-----BEGIN PUBLIC KEY-----\n...";
boolean valid = signService.verify(data, signature, publicKey, SignAlgorithm.RSA);
```

### 2. SM2 签名（国密）

```java
// SM2 签名
String signature = signService.sign(data, privateKey, SignAlgorithm.SM2);

// SM2 验签
boolean valid = signService.verify(data, signature, publicKey, SignAlgorithm.SM2);
```

### 3. 文件签名

```java
// 对文件进行签名
File file = new File("document.pdf");
String signature = signService.signFile(file, privateKey);

// 验证文件签名
boolean valid = signService.verifyFile(file, signature, publicKey);
```

---

## 常用类

- `ISignService` - 签名服务
- `SignAlgorithm` - 签名算法枚举
- `CertificateManager` - 证书管理器

---

## 最佳实践

### API 请求签名

```java
@Component
public class ApiSignatureInterceptor {
    
    @Autowired
    private ISignService signService;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) {
        // 获取签名参数
        String timestamp = request.getHeader("X-Timestamp");
        String nonce = request.getHeader("X-Nonce");
        String signature = request.getHeader("X-Signature");
        
        // 构建待签名字符串
        String signData = buildSignData(request, timestamp, nonce);
        
        // 验签
        boolean valid = signService.verify(signData, signature, getPublicKey());
        
        if (!valid) {
            throw new BusinessException("签名验证失败");
        }
        
        return true;
    }
    
    private String buildSignData(HttpServletRequest request, 
                                String timestamp, 
                                String nonce) {
        return request.getMethod() + "\n" +
               request.getRequestURI() + "\n" +
               timestamp + "\n" +
               nonce + "\n" +
               getRequestBody(request);
    }
}
```

---

## 总结

fastsun-sign 模块提供了完整的数字签名能力：
- ✅ 支持 RSA、SM2 等算法
- ✅ 数据和文件签名
- ✅ 签名验证
- ✅ 证书管理

适用于需要数据完整性校验的场景。
