# 🚀 知识库快速使用指南

## 📋 目录

- [立即开始](#立即开始)
- [浏览文档](#浏览文档)
- [搜索内容](#搜索内容)
- [生成最新文档](#生成最新文档)
- [在其他项目中使用](#在其他项目中使用)

---

## 立即开始

### 方式一：直接阅读（最简单）

1. 打开 `knowledge-base/README.md` 文件
2. 点击链接浏览各个文档
3. 使用 IDE 的 Markdown 预览功能查看格式化内容

**推荐起点**：
- 📖 [架构概述](./architecture/overview.md) - 了解系统整体设计
- 🏃 [快速开始](./development/getting-started.md) - 开始第一个项目
- ⚙️ [配置指南](./configuration/properties.md) - 查看所有配置项

### 方式二：使用搜索工具（最快捷）

**Windows 用户**：
```bash
# 双击运行或在命令行执行
knowledge-base\tools\search_kb.bat 多租户
knowledge-base\tools\search_kb.bat 认证 fastsun-oauth
```

**Mac/Linux 用户**：
```bash
cd knowledge-base/tools
python search_knowledge_base.py --keyword "多租户"
python search_knowledge_base.py --keyword "认证" --module fastsun-oauth
```

---

## 浏览文档

### 📚 文档结构

```
knowledge-base/
├── README.md                    ← 从这里开始
├── INDEX.md                     ← 完整索引
├── architecture/                ← 架构设计
│   ├── overview.md              ← 必读：整体架构
│   ├── multi-tenancy.md         ← 多租户机制
│   └── security.md              ← 安全体系
├── modules/                     ← 模块文档（自动生成）
├── development/                 ← 开发指南
│   └── getting-started.md       ← 必读：快速开始
├── configuration/               ← 配置指南
│   └── properties.md            ← 所有配置项
└── tools/                       ← 工具脚本
```

### 🎯 按场景阅读

#### 我是新成员，想了解框架
1. 阅读 [README.md](./README.md) 了解概况
2. 阅读 [架构概述](./architecture/overview.md) 理解设计
3. 阅读 [快速开始](./development/getting-started.md) 动手实践
4. 根据需要深入具体模块

#### 我要开始一个新项目
1. 阅读 [快速开始](./development/getting-started.md)
2. 查阅 [配置指南](./configuration/properties.md)
3. 参考 [模块文档](./modules/) 中的相关模块
4. 查看示例代码

#### 我遇到了具体问题
1. 使用搜索工具查找关键词
2. 查阅 [故障排查](./troubleshooting/) 目录
3. 在对应模块文档中查找
4. 查看相关配置项

#### 我需要配置系统
1. 查阅 [配置指南](./configuration/properties.md)
2. 根据环境选择对应的配置段
3. 复制配置并修改参数
4. 测试配置是否生效

---

## 搜索内容

### 方法一：使用搜索脚本（推荐）

**Windows**：
```bash
knowledge-base\tools\search_kb.bat 关键词
knowledge-base\tools\search_kb.bat 关键词 模块名
```

**Mac/Linux**：
```bash
cd knowledge-base/tools
python search_knowledge_base.py --keyword "关键词"
python search_knowledge_base.py --keyword "关键词" --module 模块名
```

**示例**：
```bash
# 搜索所有文档
search_kb.bat OAuth2

# 在特定模块搜索
search_kb.bat 认证 fastsun-oauth

# 搜索多租户
search_kb.bat 多租户
```

### 方法二：IDE 全局搜索

1. 按快捷键：
   - Windows: `Ctrl + Shift + F`
   - Mac: `Cmd + Shift + F`
2. 设置搜索范围为 `knowledge-base/`
3. 输入关键词
4. 查看结果并双击跳转

### 方法三：文件系统搜索

**Windows**：
```powershell
# PowerShell
Get-ChildItem -Path knowledge-base -Recurse -Filter *.md | Select-String "关键词"
```

**Mac/Linux**：
```bash
grep -r "关键词" knowledge-base/ --include="*.md"
```

---

## 生成最新文档

### 何时需要重新生成？

- ✅ 框架代码有重大更新
- ✅ 新增了模块或 API
- ✅ 发现文档与代码不一致
- ✅ 定期维护（建议每月一次）

### 如何生成？

**Windows**：
```bash
# 生成所有模块
knowledge-base\tools\generate_kb.bat

# 生成指定模块
knowledge-base\tools\generate_kb.bat fastsun-oauth
```

**Mac/Linux**：
```bash
cd knowledge-base/tools

# 生成所有模块
python generate_knowledge_base.py --project ../../ --output ..

# 生成指定模块
python generate_knowledge_base.py --project ../../ --output .. --module fastsun-oauth
```

### 生成后做什么？

1. 检查生成的文档
2. 查看是否有错误或警告
3. 补充手动编写的详细说明
4. 提交到版本控制系统

```bash
git add knowledge-base/
git commit -m "Update knowledge base"
git push
```

---

## 在其他项目中使用

### 方案一：Git Submodule（推荐用于团队）

```bash
# 在业务项目中执行
git submodule add <fastsun-repo-url>/knowledge-base docs/fastsun-kb

# 初始化
git submodule update --init

# 更新
git submodule update --remote docs/fastsun-kb
```

**优点**：自动同步、版本可控  
**适用**：团队协作、长期项目

### 方案二：复制文档（简单直接）

```bash
# 复制整个知识库
cp -r fastsun-platform/knowledge-base my-project/docs/framework

# 或只复制需要的部分
cp fastsun-platform/knowledge-base/architecture my-project/docs/
cp fastsun-platform/knowledge-base/development my-project/docs/
```

**优点**：独立、可自定义  
**适用**：个人项目、短期项目

### 方案三：在线文档（最佳体验）

部署 MkDocs 或 Docsify：

```bash
# 安装 MkDocs
pip install mkdocs mkdocs-material

# 构建文档
cd knowledge-base
mkdocs build

# 将 site 目录部署到 Web 服务器
```

然后在业务项目的 README 中添加链接：
```markdown
## 框架文档

查看 [Fastsun 平台知识库](http://docs.your-company.com/fastson)
```

**优点**：访问方便、搜索强大  
**适用**：大型团队、多个项目

---

## 💡 使用技巧

### 提高效率的小技巧

1. **收藏常用文档**
   - 在浏览器或 IDE 中 bookmark 常用文档
   - 创建快捷方式或别名

2. **建立个人笔记**
   - 基于知识库创建个人学习笔记
   - 记录实际使用中遇到的问题

3. **分享给团队**
   - 组织文档学习会
   - 建立内部 Wiki

4. **持续更新**
   - 发现错误及时修正
   - 补充实际使用经验

### 常见问题速查

| 问题 | 解决方案 |
|------|---------|
| 找不到某个功能的文档 | 使用搜索工具或查看 INDEX.md |
| 文档与代码不一致 | 重新生成知识库 |
| 想看最新的 API | 查看 modules/ 下对应模块文档 |
| 不知道如何配置 | 查阅 configuration/properties.md |
| 想快速上手 | 阅读 development/getting-started.md |

---

## 📞 需要帮助？

1. **先查文档** - 90% 的问题都有答案
2. **使用搜索** - 快速定位相关内容
3. **查看示例** - 参考代码示例
4. **联系团队** - 内部技术支持

---

## 🎉 开始使用吧！

现在您已经了解了如何使用知识库，立即开始：

1. 👉 打开 [README.md](./README.md) 开始浏览
2. 🔍 使用搜索工具查找您关心的内容
3. 📝 阅读 [快速开始](./development/getting-started.md) 动手实践

**祝您使用愉快！**

---

*提示：建议将此文件添加到书签，方便随时查阅。*
