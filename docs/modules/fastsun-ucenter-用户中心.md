# fastsun-ucenter

## 模块概述

fastsun-ucenter 是 Fastsun 平台的用户中心模块，提供完整的用户、组织、角色、权限管理功能。

**路径**: `fastsun-ucenter/`

**主要职责**：
- 用户管理（增删改查、导入导出）
- 组织架构管理
- 角色和权限管理
- 租户管理
- 字典管理
- 系统配置

**核心功能速览**：

| 功能 | 说明 | 章节 |
|------|------|------|
| 用户管理 | 用户增删改查、导入导出、密码管理 | §1 |
| 组织架构 | 组织树管理、岗位分配、人员调整 | §2 |
| 角色权限 | RBAC 角色管理、资源权限分配 | §4 |
| 租户管理 | 多租户创建、上下文切换 | §6 |
| **字典管理** | 数据字典定义、字典项查询、前端使用 | §7 |
| **编号规则** | 业务流水号规则定义、自动生成 | 子模块 |
| **授权码** | 授权码生成、验证 | 子模块 |
| 视图管理 | 自定义展示视图配置 | 子模块 |
| 系统配置 | 系统参数配置、密码策略 | 配置项 |

**子模块**：
- `fastsun-ucenter-user` - 用户管理
- `fastsun-ucenter-resource` - 资源权限
- `fastsun-ucenter-dictionay` - 字典管理
- `fastsun-ucenter-config` - 配置管理
- `fastsun-ucenter-view` - 视图管理
- `fastsun-ucenter-task` - 定时任务
- `fastsun-ucenter-authorizationcode` - 授权码
- `fastsun-ucenter-numberrules` - 编号规则

---

## 应用场景

### 1. 企业组织与人员管理

为企业管理员提供完整的组织架构和人员管理功能，包括用户增删改查、组织树管理、岗位分配等，支持企业级的人员信息化管理。

### 2. 角色权限分配

通过 RBAC 模型实现灵活的权限管理，管理员可以创建角色并分配资源权限，将角色授予用户，实现细粒度的访问控制。

### 3. 多租户隔离管理

支持 SaaS 多租户模式，不同租户间数据和配置完全隔离，每个租户可独立管理自己的用户、组织和角色，适用于平台型业务场景。

### 4. 系统字典与配置管理

提供统一的字典管理和系统配置功能，支持业务数据的标准化（如性别、状态等枚举值），以及系统级和租户级的配置管理。

---

## 主要类

### 用户管理

- `UserService` - 用户服务
- `UserController` - 用户控制器
- `UserRepository` - 用户仓库
- `UserDTO` - 用户 DTO
- `User` - 用户实体

### 组织管理

- `OrganService` - 组织服务
- `OrganController` - 组织控制器
- `OrganDTO` - 组织 DTO

### 角色管理

- `RoleService` - 角色服务
- `RoleController` - 角色控制器
- `RoleDTO` - 角色 DTO

### 用户组织关系

- `UserOrganService` - 用户组织关系服务
- `UserOrganDTO` - 用户组织 DTO

### 租户管理

- `TenantService` - 租户服务
- `TenantController` - 租户控制器
- `TenantDTO` - 租户 DTO

---

## 核心功能

### 1. 用户管理

#### 查询用户列表

```java
@Autowired
private IUserComposeService userService;

QueryParameter query = new QueryParameter();
query.setPageNum(1);
query.setPageSize(10);

// 添加查询条件
query.addCondition("username", QueryOperator.LIKE, "%admin%");
query.addCondition("status", QueryOperator.EQ, 1);

FastsunPage<UserDTO> page = userService.page(query);
```

#### 创建用户

```java
UserDTO user = new UserDTO();
user.setUsername("zhangsan");
user.setName("张三");
user.setMobile("13800138000");
user.setEmail("zhangsan@example.com");
user.setPassword(passwordEncoder.encode("123456"));
user.setStatus(1);

userService.save(user);
```

#### 更新用户

```java
UserDTO user = userService.getById(userId);
user.setName("李四");
user.setMobile("13900139000");

userService.update(user);
```

#### 删除用户

```java
userService.delete(userId);

// 批量删除
userService.batchDelete(new Long[]{1L, 2L, 3L});
```

#### 重置密码

```java
userService.resetPassword(userId, newPassword);
```

### 2. 组织架构管理

#### 查询组织树

```java
@Autowired
private IOrganService organService;

// 获取完整组织树
List<OrganDTO> tree = organService.getOrganTree();

// 获取指定组织的子组织
List<OrganDTO> children = organService.getChildren(organId);
```

#### 创建组织

```java
OrganDTO organ = new OrganDTO();
organ.setName("技术部");
organ.setCode("TECH");
organ.setParentId(parentOrganId);
organ.setType("dept");  // dept:部门, group:小组

organService.save(organ);
```

#### 移动组织

```java
organService.move(organId, newParentId);
```

### 3. 用户组织关系

#### 分配用户到组织

```java
UserOrganDTO userOrgan = new UserOrganDTO();
userOrgan.setUserId(userId);
userOrgan.setOrganId(organId);
userOrgan.setPostId(postId);  // 可选：职位

userOrganService.save(userOrgan);
```

#### 查询用户的组织

```java
List<UserOrganDTO> organs = userOrganService.findByUserId(userId);
```

#### 查询组织的用户

```java
QueryParameter query = new QueryParameter();
query.addCondition("organId", QueryOperator.EQ, organId);

List<UserOrganDTO> users = userOrganService.list(query);
```

### 4. 角色管理

#### 创建角色

```java
RoleDTO role = new RoleDTO();
role.setCode("ADMIN");
role.setName("管理员");
role.setType("system");  // system:系统角色, custom:自定义角色

roleService.save(role);
```

#### 分配角色给用户

```java
UserRoleDTO userRole = new UserRoleDTO();
userRole.setUserId(userId);
userRole.setRoleId(roleId);

userRoleService.save(userRole);
```

#### 查询用户的角色

```java
List<RoleDTO> roles = roleService.findByUserId(userId);
```

### 5. 资源权限管理

#### 分配资源给角色

```java
RoleResourceDTO roleResource = new RoleResourceDTO();
roleResource.setRoleId(roleId);
roleResource.setResourceId(resourceId);
roleResource.setPermissionType("view");  // view, add, edit, delete

roleResourceService.save(roleResource);
```

#### 检查用户权限

```java
boolean hasPermission = permissionService.checkPermission(
    userId, 
    resourceCode, 
    permissionType
);
```

### 6. 租户管理

#### 创建租户

```java
TenantDTO tenant = new TenantDTO();
tenant.setTenantCode("company_a");
tenant.setTenantName("A公司");
tenant.setAppId("app_001");
tenant.setStatus(1);

tenantService.save(tenant);
```

#### 切换租户上下文

```java
TenantDTO tenant = tenantService.getByCode("company_a");
LocalTenantContext.set(tenant);

try {
    // 在指定租户上下文中操作
} finally {
    LocalTenantContext.clear();
}
```

### 7. 字典管理

#### 查询字典

```java
@Autowired
private IDictionaryService dictionaryService;

// 根据字典类型查询
List<DictionaryDTO> dicts = dictionaryService.findByType("gender");

// 结果示例：
// [{code: "M", name: "男"}, {code: "F", name: "女"}]
```

#### 使用字典

```java
// 在表单中使用
<select name="gender">
  <option value="">请选择</option>
  <option th:each="dict : ${dictionaries}" 
          th:value="${dict.code}" 
          th:text="${dict.name}"></option>
</select>
```

---

## API 接口

### 用户管理接口

#### GET `/api/user/list`
**描述**: 分页查询用户列表

**请求参数**:
```
pageNum=1&pageSize=10&username=admin&status=1
```

#### POST `/api/user/save`
**描述**: 新增用户

**请求体**:
```json
{
  "username": "zhangsan",
  "name": "张三",
  "mobile": "13800138000",
  "email": "zhangsan@example.com",
  "password": "123456"
}
```

#### PUT `/api/user/update`
**描述**: 更新用户

#### DELETE `/api/user/delete/{id}`
**描述**: 删除用户

#### POST `/api/user/resetPassword`
**描述**: 重置密码

**请求体**:
```json
{
  "userId": 1,
  "newPassword": "newpass123"
}
```

### 组织管理接口

#### GET `/api/organ/tree`
**描述**: 获取组织树

**响应**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "总公司",
      "children": [
        {
          "id": 2,
          "name": "技术部",
          "children": []
        }
      ]
    }
  ]
}
```

#### POST `/api/organ/save`
**描述**: 新增组织

### 角色管理接口

#### GET `/api/role/list`
**描述**: 查询角色列表

#### POST `/api/role/save`
**描述**: 新增角色

#### POST `/api/role/assignResources`
**描述**: 为角色分配资源

**请求体**:
```json
{
  "roleId": 1,
  "resourceIds": [1, 2, 3, 4]
}
```

### 租户管理接口

#### GET `/api/tenant/list`
**描述**: 查询租户列表

#### POST `/api/tenant/save`
**描述**: 新增租户

---

## 配置项

### 用户配置

用户密码策略和登录安全配置，用于控制密码强度要求和登录失败锁定机制。

```yaml
fastsun:
  platform:
    user:
      # 密码强度要求
      password:
        min-length: 6  # 密码最小长度，默认 6
        require-uppercase: false  # 是否需要大写字母
        require-lowercase: false  # 是否需要小写字母
        require-digit: false  # 是否需要数字
        require-special: false  # 是否需要特殊字符
      
      # 登录失败锁定
      login:
        max-fail-count: 5  # 最大登录失败次数，超过后锁定
        lock-duration: 1800  # 锁定时间（秒），默认 30 分钟
```

### 租户配置

多租户模式配置，控制是否启用多租户以及主租户标识。

```yaml
fastsun:
  platform:
    multi:
      tenant:
        enable: true  # 是否启用多租户模式
    master:
      tenant: fastsun  # 主租户标识 <span class="config-required">(必需)</span>

---

## 使用示例

### 示例 1：完整的用户注册流程

```java
@PostMapping("/register")
public Response register(@RequestBody RegisterRequest request) {
    // 1. 检查用户名是否存在
    if (userService.existsByUsername(request.getUsername())) {
        return Response.error("用户名已存在");
    }
    
    // 2. 检查手机号是否存在
    if (userService.existsByMobile(request.getMobile())) {
        return Response.error("手机号已注册");
    }
    
    // 3. 创建用户
    UserDTO user = new UserDTO();
    user.setUsername(request.getUsername());
    user.setName(request.getName());
    user.setMobile(request.getMobile());
    user.setPassword(passwordEncoder.encode(request.getPassword()));
    user.setStatus(1);
    
    userService.save(user);
    
    // 4. 分配默认角色
    RoleDTO defaultRole = roleService.getByCode("USER");
    UserRoleDTO userRole = new UserRoleDTO();
    userRole.setUserId(user.getId());
    userRole.setRoleId(defaultRole.getId());
    userRoleService.save(userRole);
    
    return Response.success();
}
```

### 示例 2：批量导入用户

```java
@PostMapping("/import")
public Response importUsers(@RequestParam("file") MultipartFile file) {
    try {
        // 1. 解析 Excel
        List<UserImportDTO> imports = ExcelUtils.read(file, UserImportDTO.class);
        
        // 2. 数据校验
        for (UserImportDTO importData : imports) {
            if (StringUtils.isEmpty(importData.getUsername())) {
                return Response.error("用户名不能为空");
            }
        }
        
        // 3. 批量创建
        List<UserDTO> users = imports.stream().map(importData -> {
            UserDTO user = new UserDTO();
            user.setUsername(importData.getUsername());
            user.setName(importData.getName());
            user.setMobile(importData.getMobile());
            user.setPassword(passwordEncoder.encode("123456"));  // 默认密码
            user.setStatus(1);
            return user;
        }).collect(Collectors.toList());
        
        userService.batchSave(users);
        
        return Response.success("成功导入 " + users.size() + " 个用户");
        
    } catch (Exception e) {
        return Response.error("导入失败: " + e.getMessage());
    }
}
```

### 示例 3：查询当前用户的权限

```java
@GetMapping("/myPermissions")
public Response getMyPermissions() {
    UserDTO user = LocalUserContext.get();
    
    // 1. 获取用户角色
    List<RoleDTO> roles = roleService.findByUserId(user.getId());
    
    // 2. 获取角色的资源权限
    Set<String> permissions = new HashSet<>();
    for (RoleDTO role : roles) {
        List<ResourceDTO> resources = resourceService.findByRoleId(role.getId());
        for (ResourceDTO resource : resources) {
            permissions.add(resource.getCode());
        }
    }
    
    return Response.success(permissions);
}
```

---

## 常见问题

### Q1: 如何实现用户数据权限？

A: 在 Service 中重写 `beforePageQuery` 方法：

```java
@Override
protected void beforePageQuery(QueryParameter query) {
    super.beforePageQuery(query);
    
    UserDTO currentUser = LocalUserContext.get();
    
    // 非管理员只能查看本部门的用户
    if (!currentUser.isAdmin()) {
        List<Long> organIds = organService.getDescendantIds(currentUser.getOrganId());
        query.addCondition("organId", QueryOperator.IN, organIds);
    }
}
```

### Q2: 如何批量分配角色？

A:
```java
@PostMapping("/batchAssignRole")
public Response batchAssignRole(@RequestBody BatchAssignRequest request) {
    List<UserRoleDTO> userRoles = request.getUserIds().stream()
        .map(userId -> {
            UserRoleDTO userRole = new UserRoleDTO();
            userRole.setUserId(userId);
            userRole.setRoleId(request.getRoleId());
            return userRole;
        })
        .collect(Collectors.toList());
    
    userRoleService.batchSave(userRoles);
    return Response.success();
}
```

### Q3: 如何实现软删除用户？

A:
```java
@Update
public void softDelete(Long id) {
    User user = userRepository.findById(id).orElseThrow();
    user.setStatus(-1);  // -1 表示已删除
    user.setUpdateTime(new Date());
    userRepository.save(user);
}
```

查询时过滤：
```java
query.addCondition("status", QueryOperator.NE, -1);
```

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [快速开始](../development/getting-started.md)
- [多租户架构](../architecture/multi-tenancy.md)

---

## 模块引用关系

| 依赖类型 | 模块 | 说明 |
|---------|------|------|
| 调用依赖 | fastsun-oauth | 认证授权，用户中心为 OAuth 提供用户信息查询接口 |
| 调用依赖 | fastsun-gateway | API 网关，网关路由转发用户中心请求 |
| 调用依赖 | fastsun-service | 服务管理，服务注册需要关联用户信息 |
| 调用依赖 | fastsun-ruleflow | 规则引擎，规则执行需要查询用户上下文 |
| 存储依赖 | MySQL | 存储用户、组织、角色、权限等数据
