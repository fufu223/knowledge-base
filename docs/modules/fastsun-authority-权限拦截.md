# fastsun-authority

## 模块概述

fastsun-authority 是 Fastsun 平台的权限拦截模块，提供资源级别的权限控制。

**路径**: `fastsun-authority/`

**主要职责**：
- 资源权限拦截
- 访问控制
- 权限验证

---

## 应用场景

- **精细权限管控**：对后端 API 接口进行细粒度的权限校验，确保用户只能访问授权的资源
- **多维度权限检查**：支持按用户角色、部门、租户等多维度进行权限判断
- **白名单机制**：配合网关的 ignore.urls 配置，公开接口可免于权限拦截

---

## 核心功能

### 1. 权限拦截器

```java
@Component
public class ResourcePermissionInterceptor implements HandlerInterceptor {
    
    @Autowired
    private IPermissionService permissionService;
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                            HttpServletResponse response, 
                            Object handler) {
        // 获取当前用户
        UserDTO user = SecurityUtils.getCurrentUser();
        
        // 获取请求资源
        String resource = request.getRequestURI();
        String method = request.getMethod();
        
        // 检查权限
        boolean hasPermission = permissionService.check(user.getId(), resource, method);
        
        if (!hasPermission) {
            throw new AccessDeniedException("没有访问权限");
        }
        
        return true;
    }
}
```

### 2. 权限配置

```java
@Configuration
public class AuthorityConfig implements WebMvcConfigurer {
    
    @Autowired
    private ResourcePermissionInterceptor permissionInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(permissionInterceptor)
            .addPathPatterns("/api/**")
            .excludePathPatterns("/api/public/**");
    }
}
```

---

## 常用类

- `ResourcePermissionInterceptor` - 资源权限拦截器
- `IPermissionService` - 权限服务
- `AccessDeniedException` - 访问拒绝异常

---

## 总结

fastsun-authority 模块提供了细粒度的权限控制：
- ✅ 资源级别权限拦截
- ✅ 灵活的权限配置
- ✅ 访问控制

配合 OAuth 模块使用，实现完整的权限管理体系。
