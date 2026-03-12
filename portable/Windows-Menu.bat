@echo off
chcp 65001 >/dev/null 2>&1
title U-Claw Menu

set "UCLAW_DIR=%~dp0"
set "CORE_DIR=%UCLAW_DIR%app\core"
set "DATA_DIR=%UCLAW_DIR%data"
set "STATE_DIR=%DATA_DIR%\.openclaw"
set "NODE_DIR=%UCLAW_DIR%app\runtime\node-win-x64"
set "NODE_BIN=%NODE_DIR%\node.exe"

set "OPENCLAW_HOME=%DATA_DIR%"
set "OPENCLAW_STATE_DIR=%STATE_DIR%"
set "OPENCLAW_CONFIG_PATH=%STATE_DIR%\openclaw.json"
set "PATH=%NODE_DIR%;%PATH%"

set "OPENCLAW_MJS=%CORE_DIR%\node_modules\openclaw\openclaw.mjs"

if not exist "%STATE_DIR%" mkdir "%STATE_DIR%"
if not exist "%DATA_DIR%\memory" mkdir "%DATA_DIR%\memory"
if not exist "%DATA_DIR%\backups" mkdir "%DATA_DIR%\backups"

:menu
cls
echo.
echo   ========================================
echo     U-Claw v1.1 - Menu
echo     Portable AI Agent
echo   ========================================
echo.

if exist "%NODE_BIN%" (
    for /f "tokens=*" %%v in ('"%%NODE_BIN%%" --version') do echo   Node: %%v
) else (
    echo   [!] Node.js not found
)
if exist "%STATE_DIR%\openclaw.json" (echo   Config: OK) else (echo   Config: NOT SET)
echo.
echo   -- Config --
echo   [1] Setup wizard (model, API key)
echo   [2] Open web dashboard
echo.
echo   -- Chat Platforms --
echo   [3] QQ Bot (pre-installed, enter ID only)
echo   [4] Other platforms (Feishu/Telegram/WeChat)
echo.
echo   -- Maintenance --
echo   [5] Diagnostics
echo   [6] Backup config
echo   [7] Restore backup
echo   [8] System info
echo.
echo   [0] Exit
echo.
set /p choice="  Choose [0-8]: "

if "%choice%"=="1" goto :onboard
if "%choice%"=="2" goto :dashboard
if "%choice%"=="3" goto :qqbot
if "%choice%"=="4" goto :channels
if "%choice%"=="5" goto :doctor
if "%choice%"=="6" goto :backup
if "%choice%"=="7" goto :restore
if "%choice%"=="8" goto :sysinfo
if "%choice%"=="0" exit /b 0
echo   Invalid choice
pause
goto :menu

:onboard
echo.
echo   === Setup Wizard ===
echo.
echo   DeepSeek  - Custom Provider, URL: https://api.deepseek.com/v1
echo   Kimi      - Moonshot AI
echo   Qwen      - Qwen
echo   Doubao    - Volcano Engine
echo.
cd /d "%CORE_DIR%"
"%NODE_BIN%" "%OPENCLAW_MJS%" onboard
pause
goto :menu

:dashboard
echo.
echo   Starting gateway...
set PORT=18789
:find_port
netstat -an | findstr ":%PORT% " | findstr "LISTENING" >/dev/null 2>&1
if %errorlevel%==0 (
    set /a PORT+=1
    if %PORT% gtr 18799 (echo No available port & pause & goto :menu)
    goto :find_port
)
cd /d "%CORE_DIR%"
if not exist "%STATE_DIR%\openclaw.json" (
    echo {"gateway":{"mode":"local","auth":{"token":"uclaw"}}} > "%STATE_DIR%\openclaw.json"
)
start "" http://127.0.0.1:%PORT%/#token=uclaw
"%NODE_BIN%" "%OPENCLAW_MJS%" gateway run --allow-unconfigured --force --port %PORT%
pause
goto :menu

:qqbot
echo.
echo   === QQ Bot Setup ===
echo.
echo   QQ plugin is pre-installed!
echo   You only need your AppID and AppSecret.
echo.
echo   Get them at: q.qq.com (create a bot)
echo.
set /p qqid="  AppID: "
set /p qqsecret="  AppSecret: "
if "%qqid%"=="" goto :qq_cancel
if "%qqsecret%"=="" goto :qq_cancel
cd /d "%CORE_DIR%"
"%NODE_BIN%" "%OPENCLAW_MJS%" channels add --channel qqbot --token "%qqid%:%qqsecret%"
echo.
set /p qqallow="  Your QQ number (allowlist, empty to skip): "
if not "%qqallow%"=="" "%NODE_BIN%" "%OPENCLAW_MJS%" config set channels.qqbot.allowFrom "%qqallow%"
echo.
echo   QQ Bot configured! Restart gateway to apply.
pause
goto :menu
:qq_cancel
echo   Cancelled.
pause
goto :menu

:channels
echo.
echo   === Other Platforms ===
echo.
echo   Feishu:   Built-in. Use [1] Setup wizard.
echo   Telegram: Built-in. Use [1] Setup wizard.
echo   Discord:  Built-in. Use [1] Setup wizard.
echo   WeChat:   Community plugin.
echo.
echo   Use Setup wizard [1] to configure these.
pause
goto :menu

:doctor
cd /d "%CORE_DIR%"
"%NODE_BIN%" "%OPENCLAW_MJS%" doctor --repair
pause
goto :menu

:backup
echo.
set "TS=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%"
set "TS=%TS: =0%"
set "BK=%DATA_DIR%\backups\backup_%TS%"
mkdir "%BK%" 2>nul
if exist "%STATE_DIR%\openclaw.json" copy "%STATE_DIR%\openclaw.json" "%BK%\" >nul
if exist "%DATA_DIR%\memory" xcopy /s /q "%DATA_DIR%\memory" "%BK%\memory\" >/dev/null 2>nul
echo   Backup saved: %BK%
pause
goto :menu

:restore
echo.
echo   Available backups:
dir /b "%DATA_DIR%\backups\" 2>nul
echo.
set /p rname="  Backup folder name: "
if exist "%DATA_DIR%\backups\%rname%\openclaw.json" (
    copy "%DATA_DIR%\backups\%rname%\openclaw.json" "%STATE_DIR%\" >nul
    echo   Config restored!
)
pause
goto :menu

:sysinfo
echo.
echo   OS: Windows
"%NODE_BIN%" --version
echo   Path: %UCLAW_DIR%
echo   Data: %DATA_DIR%
pause
goto :menu