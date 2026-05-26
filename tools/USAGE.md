# 知识库使用指南

## 概述

本指南介绍如何使用 Fastsun 平台知识库，包括如何生成、查询和维护知识库。

## 知识库结构

```
knowledge-base/
├── README.md                      # 知识库主文档
├── INDEX.md                       # 索引文件
├── architecture/                  # 架构设计文档
│   ├── overview.md                # 架构概述
│   ├── multi-tenancy.md           # 多租户架构
│   └── security.md                # 安全架构
├── modules/                       # 模块文档（自动生成）
│   ├── fastsun-base.md
│   ├── fastsun-oauth.md
│   └── ...
├── api-reference/                 # API 参考
├── configuration/                 # 配置指南
├── development/                   # 开发指南
│   └── getting-started.md         # 快速开始
├── deployment/                    # 部署指南
├── troubleshooting/               # 故障排查
└── tools/                         # 工具脚本
    ├── generate_knowledge_base.py # 知识库生成工具
    └── search_knowledge_base.py   # 知识库搜索工具
```

## 生成知识库

### 前置要求

- Python 3.7+
- 项目源码访问权限

### 使用方法

#### 1. 生成完整知识库

```bash
cd knowledge-base/tools
python generate_knowledge_base.py --project ../../ --output ..
```

参数说明：
- `--project`: 项目根目录路径（默认当前目录）
- `--output`: 输出目录（默认 knowledge-base）

#### 2. 生成指定模块文档

```bash
python generate_knowledge_base.py --module fastsun-oauth
```

#### 3. 定期更新知识库

建议每次框架更新后重新生成知识库：

```bash
# 拉取最新代码
git pull

# 重新生成知识库
python generate_knowledge_base.py
```

### 生成内容

工具会自动扫描并生成：

1. **模块文档**: 每个模块的主要类、API 接口
2. **索引文件**: 方便快速查找
3. **README**: 知识库说明

## 查询知识库

### 方法一：直接浏览

在 GitHub/GitLab 或本地文件浏览器中直接打开 Markdown 文件查看。

### 方法二：使用搜索工具

```bash
python search_knowledge_base.py --keyword "多租户"
```

### 方法三：使用 IDE 搜索

在 VS Code 或 IDEA 中使用全局搜索功能：
- 快捷键: `Ctrl+Shift+F` (Windows) / `Cmd+Shift+F` (Mac)
- 搜索范围: `knowledge-base/` 目录

### 方法四：转换为在线文档

可以使用以下工具将 Markdown 转换为在线文档：

**MkDocs**
```bash
pip install mkdocs
mkdocs new .
mkdocs serve
```

**Docsify**
```bash
npm i docsify-cli -g
docsify init ./docs
docsify serve ./docs
```

## 维护知识库

### 手动补充文档

自动生成的文档可能不够详细，可以手动补充：

1. 在对应目录创建 Markdown 文件
2. 按照现有格式编写内容
3. 在 INDEX.md 中添加链接

### 更新策略

**版本发布时**
- 完整重新生成知识库
- 审查并更新手动编写的文档
- 提交到版本控制系统

**日常开发时**
- 新增重要功能时及时补充文档
- 修复文档错误
- 保持文档与代码同步

### 文档规范

**标题层级**
```markdown
# 一级标题（文档标题）
## 二级标题（章节）
### 三级标题（小节）
#### 四级标题（子小节）
```

**代码块**
```java
// 指定语言，获得语法高亮
public class Example {
    // 代码内容
}
```

**链接**
```markdown
[链接文本](相对路径或URL)
```

**表格**
```markdown
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 值1 | 值2 | 值3 |
```

## 在其他项目中引用

### 场景一：作为 Git Submodule

```bash
# 在业务项目中添加知识库
git submodule add <knowledge-base-repo-url> docs/fastsun-kb

# 更新知识库
git submodule update --remote docs/fastsun-kb
```

### 场景二：复制文档

```bash
# 复制知识库到业务项目
cp -r fastsun-platform/knowledge-base my-project/docs/framework
```

### 场景三：在线文档服务

1. 部署 MkDocs/Docsify 文档服务
2. 配置 CI/CD 自动更新文档
3. 在业务项目中添加文档链接

### 场景四：IDE 插件

开发 IDE 插件，实现：
- 快速搜索框架文档
- 代码提示中显示相关文档
- 一键跳转到文档

## 最佳实践

### 1. 保持文档简洁

- 只记录关键信息
- 避免冗余内容
- 使用图表辅助说明

### 2. 及时更新

- 代码变更后立即更新文档
- 定期检查文档准确性
- 删除过时内容

### 3. 分类清晰

- 按功能模块组织
- 提供清晰的导航
- 建立交叉引用

### 4. 示例丰富

- 提供完整的代码示例
- 包含常见使用场景
- 标注注意事项

### 5. 版本管理

- 文档与代码版本对应
- 记录变更历史
- 保留历史版本文档

## 常见问题

### Q1: 生成的文档不完整？

A: 自动化工具只能提取结构化信息，需要手动补充详细说明。

### Q2: 如何搜索特定内容？

A: 
- 使用 `search_knowledge_base.py` 工具
- 使用 IDE 的全局搜索
- 使用 grep 命令

### Q3: 文档与代码不一致？

A: 重新运行生成工具，并审查手动编写的部分。

### Q4: 如何提高生成速度？

A: 
- 只生成需要的模块
- 使用增量生成
- 缓存扫描结果

### Q5: 能否集成到 CI/CD？

A: 可以，在构建流程中添加文档生成步骤：

```yaml
# .gitlab-ci.yml 示例
generate-docs:
  script:
    - cd knowledge-base/tools
    - python generate_knowledge_base.py
  artifacts:
    paths:
      - knowledge-base/
```

## 工具脚本说明

### generate_knowledge_base.py

**功能**: 扫描源码，生成知识库文档

**用法**:
```bash
python generate_knowledge_base.py [选项]

选项:
  --project PATH    项目根目录（默认: .）
  --output PATH     输出目录（默认: knowledge-base）
  --module NAME     指定模块名称
```

**输出**:
- 模块文档（modules/*.md）
- 索引文件（INDEX.md）
- README.md

### search_knowledge_base.py

**功能**: 在知识库中搜索内容

**用法**:
```bash
python search_knowledge_base.py --keyword "关键词" [--module 模块名]
```

**输出**:
- 匹配的文档列表
- 相关内容片段

## 贡献指南

欢迎贡献文档改进：

1. Fork 项目
2. 创建分支 (`git checkout -b docs/improvement`)
3. 修改文档
4. 提交更改 (`git commit -am 'Add some docs'`)
5. 推送到分支 (`git push origin docs/improvement`)
6. 创建 Pull Request

## 技术支持

如有问题，请：
1. 查阅现有文档
2. 搜索 Issues
3. 提交新 Issue
4. 联系技术支持团队

## 许可证

内部使用，请勿外传。
