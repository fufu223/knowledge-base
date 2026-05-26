# fastsun-form

## 模块概述

fastsun-form 是 Fastsun 平台的表单模块，提供动态表单设计和管理功能。

**路径**: `fastsun-form/`

**主要职责**：
- 表单设计和配置
- 表单渲染
- 表单数据管理
- 表单验证

---

## 核心功能

### 1. 表单设计

#### 创建表单

```java
@Autowired
private IFormService formService;

FormDTO form = new FormDTO();
form.setCode("user_form");
form.setName("用户表单");
form.setType("normal");  // normal, workflow

// 配置字段
List<FormFieldDTO> fields = new ArrayList<>();

FormFieldDTO nameField = new FormFieldDTO();
nameField.setKey("name");
nameField.setLabel("姓名");
nameField.setType("input");
nameField.setRequired(true);
fields.add(nameField);

FormFieldDTO ageField = new FormFieldDTO();
ageField.setKey("age");
ageField.setLabel("年龄");
ageField.setType("number");
fields.add(ageField);

form.setFields(fields);

formService.save(form);
```

### 2. 表单渲染

#### 获取表单配置

```java
@GetMapping("/form/{code}")
public Response getForm(@PathVariable String code) {
    FormDTO form = formService.getByCode(code);
    return Response.success(form);
}
```

#### 前端渲染示例（Vue）

```vue
<template>
  <el-form :model="formData" :rules="rules">
    <el-form-item 
      v-for="field in formFields" 
      :key="field.key"
      :label="field.label"
      :prop="field.key">
      
      <el-input 
        v-if="field.type === 'input'"
        v-model="formData[field.key]" />
        
      <el-select 
        v-if="field.type === 'select'"
        v-model="formData[field.key]">
        <el-option 
          v-for="opt in field.options"
          :key="opt.value"
          :label="opt.label"
          :value="opt.value" />
      </el-select>
    </el-form-item>
  </el-form>
</template>
```

### 3. 表单数据提交

```java
@PostMapping("/form/{code}/submit")
public Response submitForm(
    @PathVariable String code,
    @RequestBody Map<String, Object> data) {
    
    // 验证数据
    formService.validate(code, data);
    
    // 保存数据
    formService.saveData(code, data);
    
    return Response.success("提交成功");
}
```

### 4. 表单验证

#### 内置验证规则

```java
FormFieldDTO field = new FormFieldDTO();
field.setKey("email");
field.setLabel("邮箱");
field.setType("input");

// 添加验证规则
List<FormRuleDTO> rules = new ArrayList<>();

FormRuleDTO requiredRule = new FormRuleDTO();
requiredRule.setType("required");
requiredRule.setMessage("邮箱不能为空");
rules.add(requiredRule);

FormRuleDTO emailRule = new FormRuleDTO();
emailRule.setType("email");
emailRule.setMessage("邮箱格式不正确");
rules.add(emailRule);

field.setRules(rules);
```

#### 自定义验证

```java
@Component
public class CustomFormValidator implements FormValidator {
    
    @Override
    public ValidationResult validate(String formCode, Map<String, Object> data) {
        ValidationResult result = new ValidationResult();
        
        if ("user_form".equals(formCode)) {
            String username = (String) data.get("username");
            if (StringUtils.isBlank(username)) {
                result.addError("username", "用户名不能为空");
            }
        }
        
        return result;
    }
}
```

---

## 常用类

### 服务层

- `IFormService` - 表单服务
- `IFormDataService` - 表单数据服务
- `IFormValidator` - 表单验证器

### 实体类

- `Form` - 表单实体
- `FormField` - 表单字段实体
- `FormDTO` - 表单 DTO
- `FormFieldDTO` - 表单字段 DTO

### 组件

- `FormRenderEngine` - 表单渲染引擎
- `FormValidationEngine` - 表单验证引擎

---

## 字段类型

### 基础字段

- `input` - 文本输入框
- `textarea` - 多行文本
- `number` - 数字输入
- `password` - 密码输入

### 选择字段

- `select` - 下拉选择
- `radio` - 单选框
- `checkbox` - 复选框
- `switch` - 开关

### 日期时间

- `date` - 日期选择
- `datetime` - 日期时间选择
- `time` - 时间选择

### 高级字段

- `upload` - 文件上传
- `editor` - 富文本编辑器
- `cascader` - 级联选择
- `tree-select` - 树形选择

---

## 最佳实践

### 1. 表单模板化

```java
@Service
public class FormTemplateService {
    
    /**
     * 基于模型生成表单
     */
    public FormDTO generateFromModel(String modelCode) {
        ModelDTO model = modelService.getByCode(modelCode);
        
        FormDTO form = new FormDTO();
        form.setCode(modelCode + "_form");
        form.setName(model.getName() + "表单");
        
        List<FormFieldDTO> fields = model.getFields().stream()
            .map(this::convertToFormField)
            .collect(Collectors.toList());
        
        form.setFields(fields);
        return form;
    }
}
```

### 2. 表单权限控制

```java
@Component
public class FormPermissionInterceptor {
    
    public FormDTO filterFields(FormDTO form, UserDTO user) {
        List<FormFieldDTO> filteredFields = form.getFields().stream()
            .filter(field -> hasPermission(user, field))
            .map(field -> {
                // 根据权限设置字段属性
                if (!hasEditPermission(user, field)) {
                    field.setDisabled(true);
                }
                if (!hasViewPermission(user, field)) {
                    field.setVisible(false);
                }
                return field;
            })
            .collect(Collectors.toList());
        
        form.setFields(filteredFields);
        return form;
    }
}
```

### 3. 表单联动

```javascript
// 前端实现字段联动
watch: {
  'formData.country'(newVal) {
    if (newVal === 'CN') {
      this.formFields.find(f => f.key === 'province').options = chinaProvinces;
    } else {
      this.formFields.find(f => f.key === 'province').options = [];
    }
  }
}
```

---

## 注意事项

1. **字段唯一性**：确保字段 key 在表单内唯一
2. **验证时机**：支持实时验证和提交时验证
3. **性能优化**：复杂表单使用懒加载
4. **数据安全**：敏感字段需要加密存储

---

## 常见问题

### Q1: 表单渲染慢？

**原因**：字段过多或嵌套过深

**解决**：
- 使用分页或分步表单
- 懒加载非必填字段
- 缓存表单配置

### Q2: 动态字段不生效？

**原因**：字段配置未正确更新

**解决**：清除表单缓存并重新加载

```java
formService.clearCache(formCode);
FormDTO form = formService.getByCode(formCode);
```

---

## 相关配置

```yaml
fastsun:
  platform:
    form:
      # 是否启用缓存
      cache-enabled: true
      # 缓存过期时间（秒）
      cache-expire: 3600
      # 最大字段数
      max-fields: 100
```

---

## 总结

fastsun-form 模块提供了完整的表单管理能力：
- ✅ 可视化表单设计
- ✅ 多种字段类型支持
- ✅ 灵活的验证规则
- ✅ 表单权限控制
- ✅ 字段联动功能

适用于需要动态表单的业务场景。
