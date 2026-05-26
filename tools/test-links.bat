@echo off
chcp 65001 >nul
echo ========================================
echo   文档链接测试工具
echo ========================================
echo.

cd /d "%~dp0"

set ERROR_COUNT=0
set TOTAL_COUNT=0

echo [测试] 检查所有文档文件是否存在...
echo.

:: 测试架构文档
echo --- 架构文档 ---
if exist "docs\architecture\架构概览.md" (echo ✅ 架构概览.md) else (echo ❌ 架构概览.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\architecture\多租户架构.md" (echo ✅ 多租户架构.md) else (echo ❌ 多租户架构.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\architecture\安全架构.md" (echo ✅ 安全架构.md) else (echo ❌ 安全架构.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=3

echo.
echo --- 核心模块 ---
if exist "docs\modules\基础模块.md" (echo ✅ 基础模块.md) else (echo ❌ 基础模块.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\认证授权.md" (echo ✅ 认证授权.md) else (echo ❌ 认证授权.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\工作流引擎.md" (echo ✅ 工作流引擎.md) else (echo ❌ 工作流引擎.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\用户中心.md" (echo ✅ 用户中心.md) else (echo ❌ 用户中心.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\消息通知.md" (echo ✅ 消息通知.md) else (echo ❌ 消息通知.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\低代码平台.md" (echo ✅ 低代码平台.md) else (echo ❌ 低代码平台.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=6

echo.
echo --- 基础设施 ---
if exist "docs\modules\API网关.md" (echo ✅ API网关.md) else (echo ❌ API网关.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\定时任务.md" (echo ✅ 定时任务.md) else (echo ❌ 定时任务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\工具集成.md" (echo ✅ 工具集成.md) else (echo ❌ 工具集成.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\动态配置.md" (echo ✅ 动态配置.md) else (echo ❌ 动态配置.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=4

echo.
echo --- 业务模块 ---
if exist "docs\modules\微信集成.md" (echo ✅ 微信集成.md) else (echo ❌ 微信集成.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\附件管理.md" (echo ✅ 附件管理.md) else (echo ❌ 附件管理.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\仪表盘.md" (echo ✅ 仪表盘.md) else (echo ❌ 仪表盘.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\表单管理.md" (echo ✅ 表单管理.md) else (echo ❌ 表单管理.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\Excel模板.md" (echo ✅ Excel模板.md) else (echo ❌ Excel模板.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=5

echo.
echo --- 数据服务 ---
if exist "docs\modules\日志服务.md" (echo ✅ 日志服务.md) else (echo ❌ 日志服务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\数据同步.md" (echo ✅ 数据同步.md) else (echo ❌ 数据同步.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\序列号.md" (echo ✅ 序列号.md) else (echo ❌ 序列号.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\报表服务.md" (echo ✅ 报表服务.md) else (echo ❌ 报表服务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\UReport报表.md" (echo ✅ UReport报表.md) else (echo ❌ UReport报表.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=5

echo.
echo --- 高级功能 ---
if exist "docs\modules\规则引擎.md" (echo ✅ 规则引擎.md) else (echo ❌ 规则引擎.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\提醒服务.md" (echo ✅ 提醒服务.md) else (echo ❌ 提醒服务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\电子签名.md" (echo ✅ 电子签名.md) else (echo ❌ 电子签名.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\XXL-JOB.md" (echo ✅ XXL-JOB.md) else (echo ❌ XXL-JOB.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=4

echo.
echo --- 微服务 ---
if exist "docs\modules\服务管理.md" (echo ✅ 服务管理.md) else (echo ❌ 服务管理.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\权限拦截.md" (echo ✅ 权限拦截.md) else (echo ❌ 权限拦截.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=2

echo.
echo --- 开发支持 ---
if exist "docs\modules\领域模型.md" (echo ✅ 领域模型.md) else (echo ❌ 领域模型.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\核心基础.md" (echo ✅ 核心基础.md) else (echo ❌ 核心基础.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\扩展功能.md" (echo ✅ 扩展功能.md) else (echo ❌ 扩展功能.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\测试支持.md" (echo ✅ 测试支持.md) else (echo ❌ 测试支持.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\modules\数据同步框架.md" (echo ✅ 数据同步框架.md) else (echo ❌ 数据同步框架.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=5

echo.
echo --- 其他文档 ---
if exist "docs\development\入门指南.md" (echo ✅ 入门指南.md) else (echo ❌ 入门指南.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\configuration\配置项大全.md" (echo ✅ 配置项大全.md) else (echo ❌ 配置项大全.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\deployment\DEPLOYMENT_GUIDE.md" (echo ✅ DEPLOYMENT_GUIDE.md) else (echo ❌ DEPLOYMENT_GUIDE.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\deployment\TROUBLESHOOTING.md" (echo ✅ TROUBLESHOOTING.md) else (echo ❌ TROUBLESHOOTING.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "docs\guides\QUICKSTART.md" (echo ✅ QUICKSTART.md) else (echo ❌ QUICKSTART.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=5

echo.
echo ========================================
echo   测试结果汇总
echo ========================================
echo 总文件数: %TOTAL_COUNT%
echo 缺失文件: %ERROR_COUNT%
echo.

if %ERROR_COUNT% EQU 0 (
    echo ✅ 所有文档文件都存在！
    echo.
    echo 现在可以启动本地预览测试链接跳转：
    echo   .\preview-nodejs.bat
) else (
    echo ❌ 有 %ERROR_COUNT% 个文件缺失，请检查！
)

echo.
pause
