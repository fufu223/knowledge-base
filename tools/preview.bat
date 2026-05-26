@echo off
chcp 65001 >nul
echo ========================================
echo   Fastsun 知识库 - 本地预览
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] 检查 Python 环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未检测到 Python
    echo.
    echo 请先安装 Python: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)
echo ✅ Python 环境正常
echo.

echo [2/3] 检查依赖...
pip show mkdocs-material >nul 2>&1
if errorlevel 1 (
    echo 📦 正在安装 MkDocs Material...
    pip install mkdocs mkdocs-material -q
    if errorlevel 1 (
        echo ❌ 安装失败
        pause
        exit /b 1
    )
    echo ✅ 依赖安装完成
) else (
    echo ✅ 依赖已安装
)
echo.

echo [3/3] 启动本地服务器...
echo.
echo 🌐 访问地址: http://127.0.0.1:8000
echo.
echo 💡 提示:
echo    - 按 Ctrl+C 停止服务器
echo    - 修改文档后会自动刷新
echo.

mkdocs serve

pause
