@echo off
chcp 65001 >nul
echo ========================================
echo   文档中文重命名工具
echo ========================================
echo.

cd /d "%~dp0docs\modules"

echo [1/4] 重命名模块文档...

rename "fastsun-base.md" "基础模块.md"
rename "fastsun-oauth.md" "认证授权.md"
rename "fastsun-workflow.md" "工作流引擎.md"
rename "fastsun-ucenter.md" "用户中心.md"
rename "fastsun-message.md" "消息通知.md"
rename "fastsun-lowcode.md" "低代码平台.md"
rename "fastsun-gateway.md" "API网关.md"
rename "fastsun-quartz.md" "定时任务.md"
rename "fastsun-tools.md" "工具集成.md"
rename "fastsun-dynamic.md" "动态配置.md"
rename "fastsun-wechat.md" "微信集成.md"
rename "fastsun-affix.md" "附件管理.md"
rename "fastsun-dashboard.md" "仪表盘.md"
rename "fastsun-form.md" "表单管理.md"
rename "fastsun-excel-template.md" "Excel模板.md"
rename "fastsun-loggers.md" "日志服务.md"
rename "fastsun-sync.md" "数据同步.md"
rename "fastsun-sequence.md" "序列号.md"
rename "fastsun-report.md" "报表服务.md"
rename "fastsun-ureport.md" "UReport报表.md"
rename "fastsun-ruleflow.md" "规则引擎.md"
rename "fastsun-reminder.md" "提醒服务.md"
rename "fastsun-sign.md" "电子签名.md"
rename "fastsun-xxl-job.md" "XXL-JOB.md"
rename "fastsun-service.md" "服务管理.md"
rename "fastsun-authority.md" "权限拦截.md"
rename "fastsun-domain.md" "领域模型.md"
rename "fastsun-core.md" "核心基础.md"
rename "fastsun-xft.md" "扩展功能.md"
rename "fastsun-test.md" "测试支持.md"
rename "fastsun-synchron.md" "数据同步框架.md"

echo ✅ 模块文档重命名完成

cd /d "%~dp0docs\architecture"
echo.
echo [2/4] 重命名架构文档...

rename "overview.md" "架构概览.md"
rename "multi-tenancy.md" "多租户架构.md"
rename "security.md" "安全架构.md"

echo ✅ 架构文档重命名完成

cd /d "%~dp0docs\development"
echo.
echo [3/4] 重命名开发文档...

if exist "getting-started.md" rename "getting-started.md" "入门指南.md"

echo ✅ 开发文档重命名完成

cd /d "%~dp0docs\configuration"
echo.
echo [4/4] 重命名配置文档...

if exist "properties.md" rename "properties.md" "配置项大全.md"

echo ✅ 配置文档重命名完成

echo.
echo ========================================
echo   重命名完成！
echo ========================================
echo.
echo 下一步：更新 _sidebar.md 中的链接
echo.
pause
