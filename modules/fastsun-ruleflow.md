# fastsun-ruleflow

## 模块概述

fastsun-ruleflow 是 Fastsun 平台的规则引擎模块，提供可视化规则设计和执行功能。

**路径**: `fastsun-ruleflow/`

**主要职责**：
- 规则设计和配置
- 规则引擎执行
- 规则版本管理
- 规则测试和调试

**子模块**：
- `fastsun-ruleflow-api` - API 接口
- `fastsun-ruleflow-domain` - 领域模型

---

## 核心功能

### 1. 创建规则

```java
@Autowired
private IRuleService ruleService;

RuleDTO rule = new RuleDTO();
rule.setCode("discount_rule");
rule.setName("折扣规则");
rule.setDescription("根据会员等级计算折扣");

// 定义规则条件
RuleConditionDTO condition = new RuleConditionDTO();
condition.setField("memberLevel");
condition.setOperator("==");
condition.setValue("VIP");

// 定义规则动作
RuleActionDTO action = new RuleActionDTO();
action.setType("set");
action.setField("discount");
action.setValue(0.8);

rule.setCondition(condition);
rule.setAction(action);

ruleService.save(rule);
```

### 2. 执行规则

```java
@Autowired
private IRuleEngineService ruleEngineService;

// 准备上下文
RuleContext context = new RuleContext();
context.put("memberLevel", "VIP");
context.put("amount", 1000);

// 执行规则
RuleResult result = ruleEngineService.execute("discount_rule", context);

// 获取结果
Double discount = (Double) result.get("discount");
System.out.println("折扣: " + discount);  // 0.8
```

### 3. 规则组

```java
RuleGroupDTO group = new RuleGroupDTO();
group.setCode("pricing_rules");
group.setName("定价规则组");

List<String> ruleCodes = Arrays.asList(
    "discount_rule",
    "coupon_rule",
    "promotion_rule"
);
group.setRuleCodes(ruleCodes);

// 设置执行策略
group.setStrategy("all");  // all, first_match, priority

ruleGroupService.save(group);

// 执行规则组
RuleResult result = ruleEngineService.executeGroup("pricing_rules", context);
```

### 4. 规则版本管理

```java
// 发布新版本
ruleService.publish(ruleId, "v2.0", "优化折扣计算逻辑");

// 回滚到指定版本
ruleService.rollback(ruleId, "v1.5");

// 查看版本历史
List<RuleVersion> versions = ruleService.getVersions(ruleId);
```

---

## 规则语法

### 条件表达式

```
field operator value
```

支持的运算符：
- `==` - 等于
- `!=` - 不等于
- `>` - 大于
- `<` - 小于
- `>=` - 大于等于
- `<=` - 小于等于
- `in` - 包含在
- `not in` - 不包含在
- `contains` - 包含
- `starts with` - 以...开头
- `ends with` - 以...结尾

### 逻辑组合

```java
// AND 条件
RuleConditionDTO andCondition = new RuleConditionDTO();
andCondition.setLogic("AND");
andCondition.addCondition(field1 == value1);
andCondition.addCondition(field2 == value2);

// OR 条件
RuleConditionDTO orCondition = new RuleConditionDTO();
orCondition.setLogic("OR");
orCondition.addCondition(field1 == value1);
orCondition.addCondition(field2 == value2);
```

### 动作类型

- `set` - 设置值
- `calculate` - 计算
- `call` - 调用方法
- `return` - 返回结果

---

## 常用类

### 服务层

- `IRuleService` - 规则服务
- `IRuleEngineService` - 规则引擎服务
- `IRuleGroupService` - 规则组服务
- `IRuleTestService` - 规则测试服务

### 实体类

- `Rule` - 规则实体
- `RuleCondition` - 规则条件
- `RuleAction` - 规则动作
- `RuleGroup` - 规则组
- `RuleVersion` - 规则版本

### 引擎

- `RuleEngine` - 规则引擎
- `RuleExecutor` - 规则执行器
- `RuleParser` - 规则解析器

---

## 最佳实践

### 1. 规则模板化

```java
@Service
public class RuleTemplateService {
    
    /**
     * 基于业务场景生成规则
     */
    public RuleDTO generateRule(String scenario) {
        if ("discount".equals(scenario)) {
            return createDiscountRule();
        } else if ("pricing".equals(scenario)) {
            return createPricingRule();
        }
        return null;
    }
    
    private RuleDTO createDiscountRule() {
        RuleDTO rule = new RuleDTO();
        rule.setCode("auto_discount");
        rule.setName("自动折扣规则");
        
        // 根据配置生成条件和动作
        // ...
        
        return rule;
    }
}
```

### 2. 规则缓存

```java
@Component
public class RuleCacheManager {
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    public RuleDTO getRule(String code) {
        String key = "rule:" + code;
        RuleDTO rule = (RuleDTO) redisTemplate.opsForValue().get(key);
        
        if (rule == null) {
            rule = ruleService.getByCode(code);
            redisTemplate.opsForValue().set(key, rule, 1, TimeUnit.HOURS);
        }
        
        return rule;
    }
    
    public void invalidateRule(String code) {
        redisTemplate.delete("rule:" + code);
    }
}
```

### 3. 规则性能监控

```java
@Aspect
@Component
public class RulePerformanceMonitor {
    
    @Around("execution(* com.fastsun.platform.ruleflow.service.*.execute(..))")
    public Object monitor(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        
        try {
            return joinPoint.proceed();
        } finally {
            long duration = System.currentTimeMillis() - start;
            
            // 记录性能指标
            if (duration > 1000) {
                log.warn("规则执行耗时过长: {}ms, 规则: {}", 
                    duration, joinPoint.getArgs()[0]);
            }
            
            metricsService.record("rule.execution.time", duration);
        }
    }
}
```

---

## 注意事项

1. **规则复杂度**：避免过于复杂的规则逻辑
2. **循环依赖**：防止规则之间相互调用形成死循环
3. **性能优化**：频繁执行的规则需要缓存
4. **版本兼容**：确保规则变更不影响现有业务

---

## 常见问题

### Q1: 规则执行结果不符合预期？

**原因**：条件配置错误或数据类型不匹配

**解决**：使用规则测试功能验证

```java
@Test
public void testRule() {
    RuleContext context = new RuleContext();
    context.put("memberLevel", "VIP");
    
    RuleResult result = ruleEngineService.execute("discount_rule", context);
    
    assertEquals(0.8, result.get("discount"));
}
```

### Q2: 规则执行慢？

**原因**：规则过多或逻辑复杂

**解决**：
- 优化规则条件
- 使用规则组分批执行
- 启用规则缓存

---

## 相关配置

```yaml
fastsun:
  platform:
    ruleflow:
      # 是否启用
      enabled: true
      # 最大规则数
      max-rules: 1000
      # 规则超时时间（毫秒）
      timeout: 5000
      # 是否启用缓存
      cache-enabled: true
```

---

## 总结

fastsun-ruleflow 模块提供了强大的规则引擎能力：
- ✅ 可视化规则设计
- ✅ 灵活的规则语法
- ✅ 规则版本管理
- ✅ 规则组执行
- ✅ 性能监控

适用于需要动态业务规则的场景。
