@echo off
chcp 65001 >nul
echo ========================================
echo   模块文档添加原名称
echo ========================================
echo.

cd /d "%~dp0docs\modules"

echo [1/1] 重命名模块文档...

rename "基础模块.md" "fastsun-base-基础模块.md"
rename "认证授权.md" "fastsun-oauth-认证授权.md"
rename "工作流引擎.md" "fastsun-workflow-工作流引擎.md"
rename "用户中心.md" "fastsun-ucenter-用户中心.md"
rename "消息通知.md" "fastsun-message-消息通知.md"
rename "低代码平台.md" "fastsun-lowcode-低代码平台.md"
rename "API网关.md" "fastsun-gateway-API网关.md"
rename "定时任务.md" "fastsun-quartz-定时任务.md"
rename "工具集成.md" "fastsun-tools-工具集成.md"
rename "动态配置.md" "fastsun-dynamic-动态配置.md"
rename "微信集成.md" "fastsun-wechat-微信集成.md"
rename "附件管理.md" "fastsun-affix-附件管理.md"
rename "仪表盘.md" "fastsun-dashboard-仪表盘.md"
rename "表单管理.md" "fastsun-form-表单管理.md"
rename "Excel模板.md" "fastsun-excel-template-Excel模板.md"
rename "UReport报表.md" "fastsun-ureport-UReport报表.md"
rename "序列号.md" "fastsun-sequence-序列号.md"
rename "服务管理.md" "fastsun-service-服务管理.md"
rename "日志服务.md" "fastsun-loggers-日志服务.md"
rename "提醒服务.md" "fastsun-reminder-提醒服务.md"
rename "数据同步.md" "fastsun-sync-数据同步.md"
rename "数据同步框架.md" "fastsun-synchron-数据同步框架.md"
rename "规则引擎.md" "fastsun-ruleflow-规则引擎.md"
rename "电子签名.md" "fastsun-sign-电子签名.md"
rename "测试支持.md" "fastsun-test-测试支持.md"
rename "领域模型.md" "fastsun-domain-领域模型.md"
rename "核心基础.md" "fastsun-core-核心基础.md"
rename "权限拦截.md" "fastsun-authority-权限拦截.md"
rename "扩展功能.md" "fastsun-xft-扩展功能.md"
rename "XXL-JOB.md" "fastsun-xxl-job-XXL-JOB.md"
rename "报表服务.md" "fastsun-report-报表服务.md"

echo.
echo ✅ 所有模块文档已添加原模块名称！
echo.
pause
