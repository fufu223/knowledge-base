# fastsun-domain

## 模块概述

fastsun-domain 是 Fastsun 平台的领域模型模块，提供通用的领域对象和基础实体。

**路径**: `fastsun-domain/`

**主要职责**：
- 通用领域模型
- 基础实体定义
- DTO 转换

---

## 核心功能

### 1. 基础实体

```java
@Data
@MappedSuperclass
public abstract class BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "create_time")
    private Date createTime;
    
    @Column(name = "update_time")
    private Date updateTime;
    
    @Column(name = "create_by")
    private String createBy;
    
    @Column(name = "update_by")
    private String updateBy;
}
```

### 2. 领域对象

```java
@Data
public class User extends BaseEntity {
    
    private String username;
    private String password;
    private String email;
    private String phone;
    private Integer status;
}
```

### 3. DTO 转换

```java
@Component
public class UserConverter {
    
    public UserDTO toDTO(User user) {
        UserDTO dto = new UserDTO();
        BeanUtils.copyProperties(user, dto);
        return dto;
    }
    
    public User toEntity(UserDTO dto) {
        User user = new User();
        BeanUtils.copyProperties(dto, user);
        return user;
    }
}
```

---

## 常用类

- `BaseEntity` - 基础实体
- `BaseDTO` - 基础 DTO
- `BaseConverter` - 基础转换器

---

## 总结

fastsun-domain 模块提供了通用的领域模型：
- ✅ 基础实体定义
- ✅ 通用 DTO
- ✅ 对象转换工具

为各业务模块提供统一的领域层支持。
