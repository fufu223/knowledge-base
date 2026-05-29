# fastsun-affix

## 模块概述

fastsun-affix 是 Fastsun 平台的附件管理模块，提供文件上传、下载、存储等功能。

**路径**: `fastsun-affix/`

**主要职责**：
- 文件上传和下载
- 文件存储（本地、FastDFS、OSS）
- 文件预览
- 文件管理

---

## 应用场景

- **业务附件管理**：各类业务单据（审批单、订单、工单等）的附件上传和管理
- **文件存储扩展**：支持本地存储、FastDFS、阿里云 OSS 多种存储策略，根据业务需要灵活切换
- **多媒体文件处理**：图片、文档等在线预览和缩略图生成
- **安全存储需求**：支持文件加密存储和访问权限控制

---

## 核心功能

### 1. 文件上传

```java
@Autowired
private IAffixService affixService;

@PostMapping("/upload")
public Response upload(@RequestParam("file") MultipartFile file) {
    AffixDTO affix = affixService.upload(file);
    return Response.success(affix);
}
```

### 2. 文件下载

```java
@GetMapping("/download/{id}")
public void download(@PathVariable Long id, HttpServletResponse response) {
    affixService.download(id, response);
}
```

### 3. 文件存储配置

#### 本地存储

```yaml
fastsun:
  platform:
    affix:
      storage-type: local
      local:
        base-path: /data/files
        access-url: http://localhost:8080/files
```

#### FastDFS

```yaml
fastsun:
  platform:
    affix:
      storage-type: fastdfs
      fastdfs:
        connect-timeout: 5000
        tracker-list:
          - 192.168.1.100:22122
```

#### 阿里云 OSS

```yaml
fastsun:
  platform:
    affix:
      storage-type: oss
      oss:
        endpoint: oss-cn-hangzhou.aliyuncs.com
        access-key-id: your-access-key-id
        access-key-secret: your-access-key-secret
        bucket-name: your-bucket
```

---

## API 接口

#### POST `/api/affix/upload`
**描述**: 上传文件

#### GET `/api/affix/download/{id}`
**描述**: 下载文件

#### DELETE `/api/affix/delete/{id}`
**描述**: 删除文件

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [配置指南](../configuration/properties.md)
