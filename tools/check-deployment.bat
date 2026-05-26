@echo off
chcp 65001 >nul
echo ========================================
echo   GitHub Pages 部署检查工具
echo ========================================
echo.

cd /d "%~dp0"

echo [1/5] 检查必需文件...
if exist "index.html" (
    echo ✅ index.html 存在
) else (
    echo ❌ index.html 缺失
)

if exist "_sidebar.md" (
    echo ✅ _sidebar.md 存在
) else (
    echo ❌ _sidebar.md 缺失
)

if exist "README.md" (
    echo ✅ README.md 存在
) else (
    echo ❌ README.md 缺失
)

echo.
echo [2/5] 检查 basePath 配置...
findstr /C:"basePath:" index.html >nul
if errorlevel 1 (
    echo ⚠️  未找到 basePath 配置
    echo    建议在 index.html 中添加 basePath 配置
) else (
    echo ✅ basePath 配置存在
    findstr /C:"basePath:" index.html
)

echo.
echo [3/5] 检查侧边栏链接格式...
echo    检查前 10 个链接：
findstr /R "\]\([^)]+\)" _sidebar.md | head -10

echo.
echo [4/5] 检查文件大小...
for %%F in (index.html _sidebar.md README.md) do (
    if exist "%%F" (
        for %%A in ("%%F") do echo    %%F: %%~zA bytes
    )
)

echo.
echo [5/5] 常见問題检查...
echo.
echo ⚠️  重要提示：
echo    1. 确保所有文件名小写（Linux 服务器大小写敏感）
echo    2. 确保 _sidebar.md 中的路径与实际文件名完全匹配
echo    3. 如果部署在 https://username.github.io/repo/，需要设置 basePath: '/repo/'
echo.

echo ========================================
echo.
echo 💡 下一步操作：
echo.
echo 1. 本地预览测试：
echo    preview-nodejs.bat
echo.
echo 2. 查看详细排查指南：
echo    GITHUB_PAGES_TROUBLESHOOTING.md
echo.
echo 3. 推送到 GitHub：
echo    git add .
echo    git commit -m "Fix deployment issues"
echo    git push
echo.

pause
