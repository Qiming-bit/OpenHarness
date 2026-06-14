@echo off
cd /d F:\BaiduNetdiskDownload\atguigu_ai\supply_project\OpenHarness
echo 启动 OpenHarness...
.venv\Scripts\oh.exe
if errorlevel 1 (
    echo.
    echo [启动失败，按任意键关闭]
    pause >nul
)
