@echo off
REM Fastsun 知识库搜索工具 - Windows 批处理版本
REM 
REM 使用方法:
REM   search_kb.bat 关键词 [模块名]
REM
REM 示例:
REM   search_kb.bat 多租户                    # 搜索所有文档
REM   search_kb.bat 认证 fastsun-oauth        # 在指定模块中搜索

setlocal

REM 设置知识库目录
set KB_DIR=%~dp0..

echo ========================================
echo Fastsun 知识库搜索工具
echo ========================================
echo.

REM 检查参数
if "%1"=="" (
    echo [错误] 请提供搜索关键词
    echo.
    echo 用法: search_kb.bat 关键词 [模块名]
    echo.
    echo 示例:
    echo   search_kb.bat 多租户
    echo   search_kb.bat 认证 fastsun-oauth
    pause
    exit /b 1
)

REM 检查 Python 是否可用
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到 Python，请先安装 Python 3.7+
    pause
    exit /b 1
)

REM 构建命令
if "%2"=="" (
    echo [信息] 搜索关键词: %1
    python "%~dp0search_knowledge_base.py" --keyword "%1" --kb-dir "%KB_DIR%"
) else (
    echo [信息] 在模块 %2 中搜索: %1
    python "%~dp0search_knowledge_base.py" --keyword "%1" --module %2 --kb-dir "%KB_DIR%"
)

echo.
pause
