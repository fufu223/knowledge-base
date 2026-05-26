@echo off
REM Fastsun 知识库生成工具 - Windows 批处理版本
REM 
REM 使用方法:
REM   generate_kb.bat [模块名]
REM
REM 示例:
REM   generate_kb.bat                    # 生成所有模块
REM   generate_kb.bat fastsun-oauth      # 只生成 fastsun-oauth 模块

setlocal

REM 设置项目根目录和输出目录
set PROJECT_ROOT=%~dp0..\..
set OUTPUT_DIR=%~dp0..

echo ========================================
echo Fastsun 知识库生成工具
echo ========================================
echo.
echo 项目根目录: %PROJECT_ROOT%
echo 输出目录: %OUTPUT_DIR%
echo.

REM 检查 Python 是否可用
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Python，请先安装 Python 3.7+
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM 检查参数
if "%1"=="" (
    echo [信息] 生成完整知识库...
    python "%~dp0generate_knowledge_base.py" --project "%PROJECT_ROOT%" --output "%OUTPUT_DIR%"
) else (
    echo [信息] 生成模块: %1
    python "%~dp0generate_knowledge_base.py" --project "%PROJECT_ROOT%" --output "%OUTPUT_DIR%" --module %1
)

echo.
echo ========================================
echo 生成完成！
echo ========================================
echo.
echo 查看文档:
echo   - 主文档: %OUTPUT_DIR%\README.md
echo   - 索引: %OUTPUT_DIR%\INDEX.md
echo   - 模块文档: %OUTPUT_DIR%\modules\
echo.

pause
