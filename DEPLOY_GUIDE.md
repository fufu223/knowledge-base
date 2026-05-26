# GitHub Pages 部署指南

## 🔧 已完成的配置

### 1. 创建 `.nojekyll` 文件
✅ 已在根目录创建 `.nojekyll` 空文件
- **作用**：告诉 GitHub Pages 不要使用 Jekyll 处理文件
- **原因**：Jekyll 会忽略所有以下划线开头的文件（如 `_sidebar.md`）

### 2. 修改 `basePath`
✅ 已将 `index.html` 中的 `basePath` 设置为 `/knowledge-base/`
```javascript
basePath: '/knowledge-base/'
```

### 3. 优化路由别名
✅ 已添加 alias 配置确保侧边栏正确加载
```javascript
alias: {
  '/.*/_sidebar.md': '/_sidebar.md',
  '/_sidebar.md': '/_sidebar.md'
}
```

---

## 📦 部署步骤

### 方法一：直接推送到 gh-pages 分支（推荐）

```bash
# 1. 进入知识库目录
cd d:\1\project\fastsun-platform\knowledge-base

# 2. 初始化 git（如果还没有）
git init

# 3. 添加所有文件
git add .

# 4. 提交
git commit -m "Deploy to GitHub Pages"

# 5. 添加远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/fufu223/knowledge-base.git

# 6. 推送到 gh-pages 分支
git push -f origin master:gh-pages
```

### 方法二：使用 GitHub Actions 自动部署

创建 `.github/workflows/deploy.yml`：

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./knowledge-base
          force_orphan: true
```

### 方法三：手动上传（最简单）

1. 访问 https://github.com/fufu223/knowledge-base
2. 切换到 `gh-pages` 分支（如果没有就创建）
3. 点击 "Add file" → "Upload files"
4. 拖拽 `knowledge-base` 文件夹中的所有文件
5. 确保包含 `.nojekyll` 文件
6. 提交更改

---

## ⚙️ GitHub Pages 设置

1. 访问仓库 Settings → Pages
2. Source 选择：
   - Branch: `gh-pages`
   - Folder: `/ (root)`
3. 保存后等待几分钟
4. 访问：https://fufu223.github.io/knowledge-base/

---

## ✅ 验证清单

部署后检查以下内容：

- [ ] 访问 https://fufu223.github.io/knowledge-base/ 能正常打开
- [ ] 侧边栏正常显示（没有 404 错误）
- [ ] 点击侧边栏菜单能正常跳转
- [ ] 页面内容正常渲染
- [ ] 搜索功能正常工作
- [ ] 锚点定位正常工作

---

## 🐛 常见问题

### 问题 1：侧边栏 404
**原因**：缺少 `.nojekyll` 文件  
**解决**：确保 `.nojekyll` 文件已上传到仓库根目录

### 问题 2：页面空白或资源 404
**原因**：`basePath` 配置错误  
**解决**：确认 `basePath` 设置为 `/knowledge-base/`

### 问题 3：样式丢失
**原因**：CSS/JS 文件路径错误  
**解决**：检查浏览器控制台的网络请求，确认所有资源都能加载

### 问题 4：缓存问题
**原因**：浏览器缓存了旧版本  
**解决**：强制刷新（Ctrl+F5）或清除浏览器缓存

---

## 🔍 调试技巧

### 检查 .nojekyll 是否生效
在浏览器中访问：
```
https://fufu223.github.io/knowledge-base/_sidebar.md
```
如果能看到这个文件的内容，说明 `.nojekyll` 生效了。

### 检查 basePath 是否正确
打开浏览器控制台，运行：
```javascript
console.log(window.$docsify.basePath);
// 应该输出: /knowledge-base/
```

### 检查网络请求
1. 打开开发者工具（F12）
2. 切换到 Network 标签
3. 刷新页面
4. 查看所有请求是否成功（状态码 200）
5. 特别关注 `_sidebar.md`、`theme-modern.css` 等文件

---

## 📝 本地测试部署配置

如果想在本地的模拟 GitHub Pages 环境测试：

```bash
# 使用 serve 并指定基础路径
npx serve -l 3000 --single index.html

# 然后在浏览器访问
http://localhost:3000/knowledge-base/
```

或者修改 `basePath` 回 `/` 进行本地测试：
```javascript
basePath: '/'  // 本地测试用
// basePath: '/knowledge-base/'  // 部署时用
```

---

## 🎯 快速部署命令

```bash
cd d:\1\project\fastsun-platform\knowledge-base
git add .
git commit -m "Fix GitHub Pages deployment"
git push -f origin master:gh-pages
```

等待 1-2 分钟后访问：https://fufu223.github.io/knowledge-base/

---

**最后更新**: 2026-05-26  
**部署状态**: 配置已完成，等待推送
