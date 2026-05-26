# fastsun-lowcode

## 模块概述

fastsun-lowcode 是 Fastsun 平台的低代码开发模块，提供可视化表单设计、视图配置、代码生成等功能，快速构建业务应用。

**路径**: `fastsun-lowcode/`

**主要职责**：
- 动态表单设计和渲染
- 视图元数据管理
- 代码自动生成
- 函数库管理
- 应用管理
- 模型管理

**子模块**：
- `fastsun-lowcode-model-api` - 模型 API
- `fastsun-lowcode-model-domain` - 模型领域
- `fastsun-lowcode-app-api` - 应用 API
- `fastsun-lowcode-app-domain` - 应用领域
- `fastsun-lowcode-code` - 代码生成
- `fastsun-lowcode-function` - 函数库
- `fastsun-pagedesign-domain-api` - 页面设计

---

## 主要类

### 模型管理

- `ModelService` - 模型服务
- `ModelController` - 模型控制器
- `ModelDTO` - 模型 DTO
- `ModelFieldDTO` - 模型字段 DTO

### 视图管理

- `ViewService` - 视图服务
- `ViewController` - 视图控制器
- `ViewMetaDataDTO` - 视图元数据 DTO
- `ViewColumnDTO` - 视图列 DTO

### 表单管理

- `FormService` - 表单服务
- `FormController` - 表单控制器
- `FormConfigDTO` - 表单配置 DTO

### 代码生成

- `CodeGenerateService` - 代码生成服务
- `CodeTemplateService` - 代码模板服务

---

## 核心功能

### 1. 模型管理

#### 创建数据模型

```java
ModelDTO model = new ModelDTO();
model.setCode("product");
model.setName("产品");
model.setTableName("demo_product");
model.setDescription("产品信息模型");

// 添加字段
List<ModelFieldDTO> fields = new ArrayList<>();

ModelFieldDTO nameField = new ModelFieldDTO();
nameField.setFieldCode("name");
nameField.setFieldName("产品名称");
nameField.setFieldType("string");
nameField.setRequired(true);
fields.add(nameField);

ModelFieldDTO priceField = new ModelFieldDTO();
priceField.setFieldCode("price");
priceField.setFieldName("价格");
priceField.setFieldType("number");
priceField.setRequired(true);
fields.add(priceField);

model.setFields(fields);

modelService.save(model);
```

#### 查询模型列表

```java
QueryParameter query = new QueryParameter();
FastsunPage<ModelDTO> page = modelService.page(query);
```

#### 获取模型详情

```java
ModelDTO model = modelService.getByCode("product");

// 获取字段列表
List<ModelFieldDTO> fields = model.getFields();
```

### 2. 视图配置

#### 创建列表视图

```java
ViewMetaDataDTO view = new ViewMetaDataDTO();
view.setViewCode("product_list");
view.setViewName("产品列表");
view.setModelCode("product");
view.setViewType("list");  // list, form, detail

// 配置列
List<ViewColumnDTO> columns = new ArrayList<>();

ViewColumnDTO nameColumn = new ViewColumnDTO();
nameColumn.setFieldCode("name");
nameColumn.setTitle("产品名称");
nameColumn.setWidth(200);
nameColumn.setSortable(true);
columns.add(nameColumn);

ViewColumnDTO priceColumn = new ViewColumnDTO();
priceColumn.setFieldCode("price");
priceColumn.setTitle("价格");
priceColumn.setWidth(100);
priceColumn.setFormatter("currency");  // 货币格式
columns.add(priceColumn);

view.setColumns(columns);

// 配置查询条件
List<QueryConditionDTO> conditions = new ArrayList<>();
QueryConditionDTO nameCondition = new QueryConditionDTO();
nameCondition.setFieldCode("name");
nameCondition.setLabel("产品名称");
nameCondition.setOperator("like");
conditions.add(nameCondition);

view.setQueryConditions(conditions);

viewService.save(view);
```

#### 使用视图查询数据

```java
@Autowired
private IViewComposeService viewService;

// 根据视图编码查询
QueryParameter query = new QueryParameter();
query.addViewCode("product_list");
query.addCondition("name", QueryOperator.LIKE, "%手机%");

FastsunPage<Map<String, Object>> page = viewService.queryByView(query);
```

### 3. 表单设计

#### 创建表单配置

```java
FormConfigDTO form = new FormConfigDTO();
form.setFormCode("product_form");
form.setFormName("产品表单");
form.setModelCode("product");

// 配置表单项
List<FormItemDTO> items = new ArrayList<>();

FormItemDTO nameItem = new FormItemDTO();
nameItem.setFieldCode("name");
nameItem.setLabel("产品名称");
nameItem.setType("input");
nameItem.setRequired(true);
items.add(nameItem);

FormItemDTO priceItem = new FormItemDTO();
priceItem.setFieldCode("price");
priceItem.setLabel("价格");
priceItem.setType("number");
priceItem.setRequired(true);
items.add(priceItem);

FormItemDTO categoryItem = new FormItemDTO();
categoryItem.setFieldCode("categoryId");
categoryItem.setLabel("分类");
categoryItem.setType("select");
categoryItem.setOptionsUrl("/api/category/list");
items.add(categoryItem);

form.setItems(items);

formService.save(form);
```

#### 前端渲染表单

```vue
<template>
  <dynamic-form 
    :form-code="'product_form'"
    :model="formData"
    @submit="handleSubmit"
  />
</template>

<script>
export default {
  data() {
    return {
      formData: {}
    }
  },
  methods: {
    handleSubmit(data) {
      // 提交表单
      this.$http.post('/api/product/save', data);
    }
  }
}
</script>
```

### 4. 代码生成

#### 生成 CRUD 代码

```java
CodeGenerateRequest request = new CodeGenerateRequest();
request.setModelCode("product");
request.setOutputPath("/tmp/generated");
request.setPackageName("com.example.demo");
request.setAuthor("张三");

// 生成代码
CodeGenerateResult result = codeGenerateService.generate(request);

// 生成的文件：
// - Product.java (实体类)
// - ProductDTO.java (DTO)
// - ProductRepository.java (Repository)
// - ProductService.java (Service)
// - ProductController.java (Controller)
```

#### 自定义代码模板

```java
// 创建自定义模板
CodeTemplateDTO template = new CodeTemplateDTO();
template.setCode("custom_service");
template.setName("自定义 Service 模板");
template.setContent("""
  package ${packageName}.service;
  
  import ${packageName}.entity.${className};
  import ${packageName}.dto.${className}DTO;
  import com.fastsun.platform.core.service.impl.AbstractFastsunDtoService;
  import org.springframework.stereotype.Service;
  
  @Service
  public class ${className}Service 
      extends AbstractFastsunDtoService<${className}DTO, ${className}, Long> {
      
      // 自定义业务逻辑
  }
  """);

codeTemplateService.save(template);
```

### 5. 函数库

#### 注册自定义函数

```java
@Component
public class CustomFunctions {
    
    /**
     * 计算折扣价格
     */
    @Function(name = "calcDiscount", description = "计算折扣价格")
    public Double calcDiscount(Double originalPrice, Double discount) {
        return originalPrice * discount;
    }
    
    /**
     * 格式化手机号
     */
    @Function(name = "formatMobile", description = "格式化手机号")
    public String formatMobile(String mobile) {
        if (mobile == null || mobile.length() != 11) {
            return mobile;
        }
        return mobile.substring(0, 3) + "****" + mobile.substring(7);
    }
}
```

#### 在表达式中使用函数

```java
// 在视图配置中使用
ViewColumnDTO column = new ViewColumnDTO();
column.setFieldCode("price");
column.setFormatter("calcDiscount(${price}, 0.8)");  // 打8折

// 在表单验证中使用
FormItemDTO item = new FormItemDTO();
item.setValidator("formatMobile(${mobile})");
```

---

## API 接口

### 模型管理接口

#### GET `/api/lowcode/model/list`
**描述**: 查询模型列表

#### POST `/api/lowcode/model/save`
**描述**: 创建模型

**请求体**:
```json
{
  "code": "product",
  "name": "产品",
  "tableName": "demo_product",
  "fields": [
    {
      "fieldCode": "name",
      "fieldName": "产品名称",
      "fieldType": "string",
      "required": true
    }
  ]
}
```

### 视图管理接口

#### GET `/api/lowcode/view/{viewCode}`
**描述**: 获取视图配置

#### POST `/api/lowcode/view/query`
**描述**: 根据视图查询数据

**请求体**:
```json
{
  "viewCode": "product_list",
  "pageNum": 1,
  "pageSize": 10,
  "conditions": [
    {
      "field": "name",
      "operator": "like",
      "value": "%手机%"
    }
  ]
}
```

### 表单管理接口

#### GET `/api/lowcode/form/{formCode}`
**描述**: 获取表单配置

#### POST `/api/lowcode/form/submit`
**描述**: 提交表单数据

### 代码生成接口

#### POST `/api/lowcode/code/generate`
**描述**: 生成代码

**请求体**:
```json
{
  "modelCode": "product",
  "outputPath": "/tmp/generated",
  "packageName": "com.example.demo"
}
```

---

## 配置项

### 低代码配置

```yaml
fastsun:
  platform:
    lowcode:
      # 是否启用代码生成功能
      code-generation:
        enabled: true
      
      # 代码模板路径
      template-path: classpath:/templates/code
      
      # 默认包名
      default-package: com.example
      
      # 作者信息
      author: System
```

### 视图缓存配置

```yaml
fastsun:
  platform:
    view:
      cache:
        enabled: true
        ttl: 3600  # 缓存过期时间（秒）
```

---

## 使用示例

### 示例 1：快速创建一个 CRUD 模块

**步骤 1：创建模型**

```bash
POST /api/lowcode/model/save
{
  "code": "article",
  "name": "文章",
  "tableName": "demo_article",
  "fields": [
    {"fieldCode": "title", "fieldName": "标题", "fieldType": "string"},
    {"fieldCode": "content", "fieldName": "内容", "fieldType": "text"},
    {"fieldCode": "author", "fieldName": "作者", "fieldType": "string"}
  ]
}
```

**步骤 2：生成代码**

```bash
POST /api/lowcode/code/generate
{
  "modelCode": "article",
  "outputPath": "./src/main/java",
  "packageName": "com.example.blog"
}
```

**步骤 3：创建视图**

```bash
POST /api/lowcode/view/save
{
  "viewCode": "article_list",
  "viewName": "文章列表",
  "modelCode": "article",
  "viewType": "list",
  "columns": [
    {"fieldCode": "title", "title": "标题", "width": 300},
    {"fieldCode": "author", "title": "作者", "width": 100},
    {"fieldCode": "createTime", "title": "创建时间", "width": 180}
  ]
}
```

**步骤 4：前端使用**

```vue
<template>
  <dynamic-list view-code="article_list" />
</template>
```

完成！无需编写任何代码，即可拥有一个完整的文章管理模块。

### 示例 2：自定义表单验证

```java
// 注册验证函数
@Function(name = "validateEmail", description = "验证邮箱")
public boolean validateEmail(String email) {
    return email != null && email.matches("^[\\w-]+@[\\w-]+\\.[\\w-]+$");
}

// 在表单配置中使用
FormItemDTO emailItem = new FormItemDTO();
emailItem.setFieldCode("email");
emailItem.setLabel("邮箱");
emailItem.setType("input");
emailItem.setValidator("validateEmail(${email})");
emailItem.setErrorMessage("邮箱格式不正确");
```

### 示例 3：动态查询构建器

```java
@Autowired
private IDynamicQueryService dynamicQueryService;

// 构建动态查询
DynamicQueryRequest request = new DynamicQueryRequest();
request.setModelCode("product");

// 添加过滤条件
request.addFilter("price", "gt", 100);      // 价格 > 100
request.addFilter("price", "lt", 1000);     // 价格 < 1000
request.addFilter("name", "like", "%手机%"); // 名称包含"手机"

// 添加排序
request.addSort("price", "desc");

// 执行查询
FastsunPage<Map<String, Object>> result = dynamicQueryService.query(request);
```

---

## 常见问题

### Q1: 如何扩展自定义组件？

A:
```javascript
// 注册自定义组件
Vue.component('custom-input', {
  props: ['value', 'config'],
  template: '<input :value="value" @input="$emit(\'input\', $event.target.value)" />',
  created() {
    // 注册到动态表单
    this.$dynamicForm.registerComponent('custom-input', this.$options);
  }
});
```

### Q2: 如何实现数据联动？

A:
```javascript
// 在表单配置中设置联动
FormItemDTO cityItem = new FormItemDTO();
cityItem.setFieldCode("cityId");
cityItem.setLabel("城市");
cityItem.setType("select");
cityItem.setDependsOn("provinceId");  // 依赖省份字段
cityItem.setOptionsUrl("/api/city/list?provinceId=${provinceId}");
```

### Q3: 如何自定义代码模板？

A:
1. 在 `resources/templates/code` 目录创建模板文件
2. 使用 Velocity 或 FreeMarker 语法
3. 在代码生成时指定模板

```velocity
## Controller.vm
package ${packageName}.controller;

import ${packageName}.service.${className}Service;
import com.fastsun.platform.core.controller.AbstractDTOCRUDController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/${modelName}")
public class ${className}Controller extends AbstractDTOCRUDController<${className}DTO> {
    
    @Autowired
    private ${className}Service service;
    
    @Override
    protected IFastsunDtoService<${className}DTO> getService() {
        return service;
    }
}
```

---

## 相关文档

- [架构概述](../architecture/overview.md)
- [快速开始](../development/getting-started.md)
- [配置指南](../configuration/properties.md)
