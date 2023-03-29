@echo off
setlocal

set PATH=%CD%\src\msquic\artifacts\dotnet-tools;%PATH%
powershell -ExecutionPolicy ByPass -NoProfile -command "& """%~dp0eng\common\Build.ps1""" -warnAsError:$false -build -restore -pack %*"
exit /b %ErrorLevel%