@echo off
chcp 65001 >nul
echo ========================================
echo   Fastsun 知识库 - Node.js 本地预览
echo ========================================
echo.

cd /d "%~dp0.."

echo [1/2] 检查 Node.js 环境...
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未检测到 Node.js
    echo.
    echo 请先安装 Node.js: https://nodejs.org/
    echo.
    pause
    exit /b 1
)
echo ✅ Node.js 环境正常
echo.

echo [2/2] 启动本地服务器...
echo.
echo 🌐 访问地址: http://localhost:8080
echo.
echo 💡 提示:
echo    - 按 Ctrl+C 停止服务器
echo    - 修改文档后刷新浏览器即可
echo.

npx http-server -p 8080 -c-1

pause
