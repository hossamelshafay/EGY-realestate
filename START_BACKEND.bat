\
@echo off
setlocal
title EGY Local Backend
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start_local_backend.ps1" %*
set "result=%errorlevel%"
echo.
if not "%result%"=="0" echo Backend startup failed. Read the message above and docs\BACKEND_STARTUP.md.
pause
exit /b %result%
