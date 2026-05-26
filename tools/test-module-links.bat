@echo off
chcp 65001 >nul
echo ========================================
echo   模块文档链接测试
echo ========================================
echo.

cd /d "%~dp0..\docs\modules"

set ERROR_COUNT=0
set TOTAL_COUNT=0

echo [测试] 检查所有模块文档文件...
echo.

:: 核心模块
echo --- 核心模块 ---
if exist "fastsun-base-基础模块.md" (echo ✅ fastsun-base-基础模块.md) else (echo ❌ fastsun-base-基础模块.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-oauth-认证授权.md" (echo ✅ fastsun-oauth-认证授权.md) else (echo ❌ fastsun-oauth-认证授权.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-workflow-工作流引擎.md" (echo ✅ fastsun-workflow-工作流引擎.md) else (echo ❌ fastsun-workflow-工作流引擎.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-ucenter-用户中心.md" (echo ✅ fastsun-ucenter-用户中心.md) else (echo ❌ fastsun-ucenter-用户中心.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-message-消息通知.md" (echo ✅ fastsun-message-消息通知.md) else (echo ❌ fastsun-message-消息通知.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-lowcode-低代码平台.md" (echo ✅ fastsun-lowcode-低代码平台.md) else (echo ❌ fastsun-lowcode-低代码平台.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=6

echo.
echo --- 基础设施 ---
if exist "fastsun-gateway-API网关.md" (echo ✅ fastsun-gateway-API网关.md) else (echo ❌ fastsun-gateway-API网关.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-quartz-定时任务.md" (echo ✅ fastsun-quartz-定时任务.md) else (echo ❌ fastsun-quartz-定时任务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-tools-工具集成.md" (echo ✅ fastsun-tools-工具集成.md) else (echo ❌ fastsun-tools-工具集成.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-dynamic-动态配置.md" (echo ✅ fastsun-dynamic-动态配置.md) else (echo ❌ fastsun-dynamic-动态配置.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=4

echo.
echo --- 业务模块 ---
if exist "fastsun-wechat-微信集成.md" (echo ✅ fastsun-wechat-微信集成.md) else (echo ❌ fastsun-wechat-微信集成.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-affix-附件管理.md" (echo ✅ fastsun-affix-附件管理.md) else (echo ❌ fastsun-affix-附件管理.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-dashboard-仪表盘.md" (echo ✅ fastsun-dashboard-仪表盘.md) else (echo ❌ fastsun-dashboard-仪表盘.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-form-表单管理.md" (echo ✅ fastsun-form-表单管理.md) else (echo ❌ fastsun-form-表单管理.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-excel-template-Excel模板.md" (echo ✅ fastsun-excel-template-Excel模板.md) else (echo ❌ fastsun-excel-template-Excel模板.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=5

echo.
echo --- 数据服务 ---
if exist "fastsun-loggers-日志服务.md" (echo ✅ fastsun-loggers-日志服务.md) else (echo ❌ fastsun-loggers-日志服务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-sync-数据同步.md" (echo ✅ fastsun-sync-数据同步.md) else (echo ❌ fastsun-sync-数据同步.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-sequence-序列号.md" (echo ✅ fastsun-sequence-序列号.md) else (echo ❌ fastsun-sequence-序列号.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-report-报表服务.md" (echo ✅ fastsun-report-报表服务.md) else (echo ❌ fastsun-report-报表服务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-ureport-UReport报表.md" (echo ✅ fastsun-ureport-UReport报表.md) else (echo ❌ fastsun-ureport-UReport报表.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=5

echo.
echo --- 高级功能 ---
if exist "fastsun-ruleflow-规则引擎.md" (echo ✅ fastsun-ruleflow-规则引擎.md) else (echo ❌ fastsun-ruleflow-规则引擎.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-reminder-提醒服务.md" (echo ✅ fastsun-reminder-提醒服务.md) else (echo ❌ fastsun-reminder-提醒服务.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-sign-电子签名.md" (echo ✅ fastsun-sign-电子签名.md) else (echo ❌ fastsun-sign-电子签名.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-xxl-job-XXL-JOB.md" (echo ✅ fastsun-xxl-job-XXL-JOB.md) else (echo ❌ fastsun-xxl-job-XXL-JOB.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=4

echo.
echo --- 微服务 ---
if exist "fastsun-service-服务管理.md" (echo ✅ fastsun-service-服务管理.md) else (echo ❌ fastsun-service-服务管理.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-authority-权限拦截.md" (echo ✅ fastsun-authority-权限拦截.md) else (echo ❌ fastsun-authority-权限拦截.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=2

echo.
echo --- 开发支持 ---
if exist "fastsun-domain-领域模型.md" (echo ✅ fastsun-domain-领域模型.md) else (echo ❌ fastsun-domain-领域模型.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-core-核心基础.md" (echo ✅ fastsun-core-核心基础.md) else (echo ❌ fastsun-core-核心基础.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-xft-扩展功能.md" (echo ✅ fastsun-xft-扩展功能.md) else (echo ❌ fastsun-xft-扩展功能.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-test-测试支持.md" (echo ✅ fastsun-test-测试支持.md) else (echo ❌ fastsun-test-测试支持.md - 缺失 & set /a ERROR_COUNT+=1)
if exist "fastsun-synchron-数据同步框架.md" (echo ✅ fastsun-synchron-数据同步框架.md) else (echo ❌ fastsun-synchron-数据同步框架.md - 缺失 & set /a ERROR_COUNT+=1)
set /a TOTAL_COUNT+=5

echo.
echo ========================================
echo 测试结果: %TOTAL_COUNT% 个文件，错误 %ERROR_COUNT% 个
echo ========================================

if %ERROR_COUNT% EQU 0 (
    echo ✅ 所有模块文档都存在！
) else (
    echo ❌ 有 %ERROR_COUNT% 个文件缺失，请检查！
)

echo.
pause
