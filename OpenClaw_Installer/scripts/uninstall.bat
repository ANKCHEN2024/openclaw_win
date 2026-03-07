@echo off
setlocal enabledelayedexpansion

title OpenClaw 卸载程序
color 1f

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 此卸载程序需要管理员权限运行
    echo 请右键点击此脚本，选择"以管理员身份运行"
    pause
    exit /b 1
)

echo ================================================
echo           OpenClaw 卸载程序
echo ================================================
echo.

set "INSTALL_DIR=%ProgramFiles%\OpenClaw"

if not exist "%INSTALL_DIR%" (
    echo OpenClaw 未安装或已卸载
    pause
    exit /b 0
)

echo 发现安装目录: %INSTALL_DIR%
echo.

:: 确认卸载
set /p CONFIRM="确认完全卸载 OpenClaw? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo 卸载已取消
    pause
    exit /b 0
)

echo.
echo 正在删除文件...
if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%"
)
echo       文件删除完成

:: 删除桌面快捷方式
echo.
echo 删除快捷方式...
del /Q "%UserProfile%\Desktop\OpenClaw.lnk" 2>nul

:: 删除开始菜单快捷方式
set "START_MENU=%ProgramData%\Microsoft\Windows\Start Menu\Programs"
if exist "%START_MENU%\OpenClaw" (
    rmdir /S /Q "%START_MENU%\OpenClaw"
)
echo       快捷方式删除完成

:: 删除注册表卸载项
echo.
echo 删除注册表项...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenClaw" /f >nul 2>&1

:: 尝试删除安装目录(如果还存在)
if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%" 2>nul
)

echo.
echo ================================================
echo           卸载完成
echo ================================================
echo.
pause
