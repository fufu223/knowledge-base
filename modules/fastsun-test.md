# fastsun-test

## 模块概述

fastsun-test 是 Fastsun 平台的测试模块，提供单元测试和集成测试支持。

**路径**: `fastsun-test/`

**主要职责**：
- 单元测试框架
- 集成测试支持
- 测试工具类
- Mock 数据生成

---

## 核心功能

### 1. 单元测试

```java
@SpringBootTest
@RunWith(SpringRunner.class)
public class UserServiceTest {
    
    @Autowired
    private UserService userService;
    
    @Test
    public void testCreateUser() {
        UserDTO user = new UserDTO();
        user.setUsername("test");
        user.setEmail("test@example.com");
        
        UserDTO result = userService.create(user);
        
        assertNotNull(result.getId());
        assertEquals("test", result.getUsername());
    }
}
```

### 2. Mock 测试

```java
@Test
public void testWithMock() {
    // Mock 依赖
    when(userRepository.findByUsername("test"))
        .thenReturn(mockUser);
    
    // 执行测试
    UserDTO result = userService.getUser("test");
    
    // 验证结果
    assertNotNull(result);
    verify(userRepository, times(1)).findByUsername("test");
}
```

### 3. 集成测试

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ApiControllerTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    public void testGetUser() {
        ResponseEntity<Response> response = restTemplate.getForEntity(
            "/api/users/1", 
            Response.class
        );
        
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
    }
}
```

---

## 常用类

- `BaseTest` - 基础测试类
- `MockDataGenerator` - Mock 数据生成器
- `TestUtils` - 测试工具类

---

## 最佳实践

### 测试数据准备

```java
@TestConfiguration
public class TestDataConfig {
    
    @Bean
    public User createTestUser() {
        User user = new User();
        user.setUsername("test_user");
        user.setEmail("test@example.com");
        return user;
    }
}
```

### 清理测试数据

```java
@AfterEach
public void cleanup() {
    userRepository.deleteAll();
    orderRepository.deleteAll();
}
```

---

## 总结

fastsun-test 模块提供了完整的测试支持：
- ✅ 单元测试框架
- ✅ 集成测试支持
- ✅ Mock 工具
- ✅ 测试数据管理

确保代码质量和系统稳定性。
