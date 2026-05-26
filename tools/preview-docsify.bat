@echo off
chcp 65001 >nul
echo ========================================
echo   Fastsun 知识库 - Docsify 本地预览
echo   （无需 Python 环境）
echo ========================================
echo.

cd /d "%~dp0"

echo 📂 当前目录: %CD%
echo.
echo 💡 使用说明:
echo    1. 双击此文件会自动在浏览器中打开
echo    2. 或者手动用浏览器打开 index.html
echo.
echo ⚠️  注意:
echo    - 由于浏览器安全限制，直接打开 HTML 文件可能无法正常加载
echo    - 建议使用以下方法之一:
echo.
echo 方法 1: 使用 VS Code Live Server（推荐）
echo    1. 安装 VS Code
echo    2. 安装 "Live Server" 扩展
echo    3. 右键 index.html → "Open with Live Server"
echo.
echo 方法 2: 使用 Node.js http-server
echo    1. 安装 Node.js
echo    2. 运行: npx http-server -p 8080
echo    3. 访问: http://localhost:8080
echo.
echo 方法 3: 使用 Python（如果已安装）
echo    运行: python -m http.server 8080
echo.
echo 方法 4: 直接使用浏览器打开（可能有跨域问题）
echo    双击 index.html 文件
echo.
echo ========================================
echo.

pause

REM 尝试自动打开浏览器
start "" "index.html"
