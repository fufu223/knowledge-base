@echo off
chcp 65001 >nul
echo ========================================
echo   Fastsun 知识库 - GitHub Pages 部署
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] 检查 Python 环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未检测到 Python，请先安装 Python
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo ✅ Python 环境正常
echo.

echo [2/4] 安装依赖...
pip install mkdocs mkdocs-material -q
echo ✅ 依赖安装完成
echo.

echo [3/4] 构建文档站点...
mkdocs build
if errorlevel 1 (
    echo ❌ 构建失败
    pause
    exit /b 1
)
echo ✅ 构建完成，输出目录: site/
echo.

echo [4/4] 本地预览（按 Ctrl+C 停止）...
echo 访问地址: http://127.0.0.1:8000
echo.
mkdocs serve

pause
