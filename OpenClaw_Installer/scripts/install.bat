@echo off
setlocal enabledelayedexpansion

title OpenClaw 安装程序
chcp 936 >nul

echo ================================================
echo           OpenClaw 自动安装程序
echo ================================================
echo.
echo 这将安装 OpenClaw (AI Gateway)
echo.
echo 所需依赖:
echo   - Node.js 22+ 
echo   - API 密钥
echo.
echo ================================================
echo.

:: 检查Node.js
echo [1/7] 检查 Node.js 环境...
call :CheckNode

:: 检查管理员权限
echo [2/7] 检查管理员权限...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo       需要管理员权限创建快捷方式
)

:: 设置安装目录
set "INSTALL_DIR=%ProgramFiles%\OpenClaw"

echo.
echo [3/7] 创建安装目录...
mkdir "%INSTALL_DIR%" 2>nul
mkdir "%INSTALL_DIR%\config" 2>nul
mkdir "%INSTALL_DIR%\logs" 2>nul
mkdir "%INSTALL_DIR%\data" 2>nul
echo       目录创建成功

:: 安装OpenClaw
echo.
echo [4/7] 安装 OpenClaw...
call :InstallOpenClaw

:: 创建配置文件
echo.
echo [5/7] 创建配置文件...
call :CreateConfig

:: 创建快捷方式
echo.
echo [6/7] 创建快捷方式...
call :CreateShortcuts

:: 注册卸载
echo.
echo [7/7] 注册卸载信息...
call :RegisterUninstall

echo.
echo ================================================
echo           安装完成!
echo ================================================
echo.
echo OpenClaw 已安装到: %INSTALL_DIR%
echo.
echo 启动方式:
echo   1. 双击桌面上的 OpenClaw 快捷方式
echo   2. 或运行: npx openclaw
echo.
echo 配置说明:
echo   配置文件: %INSTALL_DIR%\config\openclaw.json
echo   日志目录: %INSTALL_DIR%\logs\
echo.
echo 控制面板: http://127.0.0.1:18789/
echo.
pause
exit /b 0

:: ========== 子程序 ==========

:CheckNode
where node >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 未找到 Node.js
    echo 请先安装 Node.js 22+ 
    echo 下载地址: https://nodejs.org/
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo       找到 Node.js: %NODE_VERSION%

:: 提取版本号
set VERSION=%NODE_VERSION:~1%
set MAJOR_VERSION=%VERSION:~0,2%

if %MAJOR_VERSION% LSS 22 (
    echo [警告] Node.js 版本过低，需要 22+
    echo 当前版本: %NODE_VERSION%
    echo 请升级: https://nodejs.org/
)
goto :eof

:InstallOpenClaw
set "OPENCLAW_DIR=%INSTALL_DIR%\node_modules\openclaw"

:: 尝试全局安装
echo       正在安装 OpenClaw...
call npm install -g openclaw >nul 2>&1
if %errorLevel% equ 0 (
    echo       OpenClaw 全局安装成功
    goto :eof
)

:: 如果全局安装失败，尝试本地安装
echo       尝试本地安装...
cd /d "%INSTALL_DIR%"
call npm init -y >nul 2>&1
call npm install openclaw >nul 2>&1
if %errorLevel% equ 0 (
    echo       OpenClaw 本地安装成功
    goto :eof
)

echo [警告] 自动安装失败，请手动运行: npm install -g openclaw
goto :eof

:CreateConfig
set "CONFIG_DIR=%USERPROFILE%\.openclaw"
mkdir "%CONFIG_DIR%" 2>nul

:: 创建默认配置文件
echo { > "%CONFIG_DIR%\openclaw.json"
echo   "channels": { >> "%CONFIG_DIR%\openclaw.json"
echo     "whatsapp": { >> "%CONFIG_DIR%\openclaw.json"
echo       "enabled": false >> "%CONFIG_DIR%\openclaw.json"
echo     }, >> "%CONFIG_DIR%\openclaw.json"
echo     "telegram": { >> "%CONFIG_DIR%\openclaw.json"
echo       "enabled": false >> "%CONFIG_DIR%\openclaw.json"
echo     }, >> "%CONFIG_DIR%\openclaw.json"
echo     "discord": { >> "%CONFIG_DIR%\openclaw.json"
echo       "enabled": false >> "%CONFIG_DIR%\openclaw.json"
echo     } >> "%CONFIG_DIR%\openclaw.json"
echo   } >> "%CONFIG_DIR%\openclaw.json"
echo } >> "%CONFIG_DIR%\openclaw.json"

echo       配置文件已创建: %CONFIG_DIR%\openclaw.json

:: 复制到安装目录
copy "%CONFIG_DIR%\openclaw.json" "%INSTALL_DIR%\config\" >nul 2>&1
goto :eof

:CreateShortcuts
:: 创建启动脚本
echo @echo off > "%INSTALL_DIR%\OpenClaw.bat"
echo cd /d "%INSTALL_DIR%" >> "%INSTALL_DIR%\OpenClaw.bat"
echo npx openclaw >> "%INSTALL_DIR%\OpenClaw.bat"
echo pause >> "%INSTALL_DIR%\OpenClaw.bat"

:: 创建桌面快捷方式
set "DESKTOP=%UserProfile%\Desktop"
if exist "%DESKTOP%" (
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $SC = $WshShell.CreateShortcut('%DESKTOP%\OpenClaw.lnk'); $SC.TargetPath = 'cmd.exe'; $SC.Arguments = '/c npx openclaw'; $SC.WorkingDirectory = '%USERPROFILE%'; $SC.Description = 'OpenClaw AI Gateway'; $SC.Save()"
)

:: 创建开始菜单
set "START_MENU=%ProgramData%\Microsoft\Windows\Start Menu\Programs"
mkdir "%START_MENU%\OpenClaw" 2>nul
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $SC = $WshShell.CreateShortcut('%START_MENU%\OpenClaw\OpenClaw.lnk'); $SC.TargetPath = 'cmd.exe'; $SC.Arguments = '/c npx openclaw'; $SC.WorkingDirectory = '%USERPROFILE%'; $SC.Description = 'OpenClaw AI Gateway'; $SC.Save()"

echo       快捷方式创建完成
goto :eof

:RegisterUninstall
set "INSTALL_PATH=%INSTALL_DIR%"

:: 创建卸载脚本
echo @echo off > "%INSTALL_PATH%\uninstall.bat"
echo title OpenClaw 卸载程序 >> "%INSTALL_PATH%\uninstall.bat"
echo. >> "%INSTALL_PATH%\uninstall.bat"
echo echo 确认卸载 OpenClaw? >> "%INSTALL_PATH%\uninstall.bat"
echo set /p CONFIRM=^(Y/N^): >> "%INSTALL_PATH%\uninstall.bat"
echo if /i not "%%CONFIRM%%"=="Y" exit >> "%INSTALL_PATH%\uninstall.bat"
echo. >> "%INSTALL_PATH%\uninstall.bat"
echo echo 正在删除文件... >> "%INSTALL_PATH%\uninstall.bat"
echo if exist "%%ProgramFiles%%\OpenClaw" rmdir /S /Q "%%ProgramFiles%%\OpenClaw" >> "%INSTALL_PATH%\uninstall.bat"
echo del /Q "%%UserProfile%%\Desktop\OpenClaw.lnk" 2^>nul >> "%INSTALL_PATH%\uninstall.bat"
echo set START_MENU=%%ProgramData%%\Microsoft\Windows\Start Menu\Programs >> "%INSTALL_PATH%\uninstall.bat"
echo if exist "%%START_MENU%%\OpenClaw" rmdir /S /Q "%%START_MENU%%\OpenClaw" >> "%INSTALL_PATH%\uninstall.bat"
echo. >> "%INSTALL_PATH%\uninstall.bat"
echo echo 卸载完成 >> "%INSTALL_PATH%\uninstall.bat"
echo pause >> "%INSTALL_PATH%\uninstall.bat"

:: 注册表
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenClaw" /v "DisplayName" /t REG_SZ /d "OpenClaw" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenClaw" /v "DisplayVersion" /t REG_SZ /d "1.0.0" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenClaw" /v "Publisher" /t REG_SZ /d "OpenClaw Team" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenClaw" /v "InstallLocation" /t REG_SZ /d "%INSTALL_PATH%" /f >nul

goto :eof
