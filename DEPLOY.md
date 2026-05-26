# GitHub Pages 部署指南

## 📋 部署步骤

### 1. 准备仓库

有两种方式部署到 GitHub Pages：

#### 方式一：使用现有仓库的子目录（推荐）
```bash
# 在 fastsun-platform 仓库中
git add knowledge-base/
git commit -m "Add knowledge base documentation"
git push origin main
```

然后在 GitHub 仓库设置中：
- Settings → Pages
- Source: Deploy from a branch
- Branch: main
- Folder: /knowledge-base
- Save

#### 方式二：创建独立仓库
```bash
# 创建新仓库 fastsun-docs
cd knowledge-base
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/fastsun-docs.git
git push -u origin main
```

### 2. 修改 basePath 配置

**重要！** 部署前必须修改 `index.html` 中的 `basePath`：

#### 如果使用子目录方式（仓库根目录下的 knowledge-base 文件夹）：
```javascript
basePath: '/fastsun-platform/',  // 替换为你的仓库名
```

#### 如果使用独立仓库：
```javascript
basePath: '/',  // 保持根路径
```

### 3. 等待部署完成

GitHub Pages 通常需要 1-5 分钟完成部署。

访问地址：
- 子目录方式：`https://yourusername.github.io/fastsun-platform/`
- 独立仓库：`https://yourusername.github.io/fastsun-docs/`

## ⚠️ 注意事项

### 1. 文件检查清单
确保以下文件都已提交：
- ✅ `index.html` - 主配置文件
- ✅ `_sidebar.md` - 侧边栏导航
- ✅ `README.md` - 首页文档
- ✅ `theme-modern.css` - 主题样式
- ✅ `docs/` - 所有文档文件
- ✅ `images/` - 图片资源（动漫助手等）

### 2. 常见问题

#### 问题1：页面空白或404错误
**原因**：basePath 配置不正确  
**解决**：根据仓库结构修改 basePath

#### 问题2：图片无法加载
**原因**：图片路径问题  
**解决**：检查 `images/anime-helper.png` 是否存在

#### 问题3：侧边栏链接失效
**原因**：文档路径错误  
**解决**：检查 `_sidebar.md` 中的链接是否正确

### 3. 自定义域名（可选）

如果想使用自定义域名：
1. 在仓库根目录创建 `CNAME` 文件
2. 添加你的域名，例如：`docs.fastsun.com`
3. 在 DNS 服务商配置 CNAME 记录指向 `yourusername.github.io`

## 🔄 更新文档

每次更新文档后：
```bash
git add knowledge-base/
git commit -m "Update documentation"
git push origin main
```

GitHub Pages 会自动重新部署，通常1-2分钟内生效。

## 🎨 主题定制

如需修改主题样式，编辑 `theme-modern.css` 文件即可。

## 📱 移动端适配

当前主题已支持响应式设计，在移动设备上会自动调整布局。

---

**部署完成后，您的知识库将可以通过 GitHub Pages 公开访问！** 🎉
