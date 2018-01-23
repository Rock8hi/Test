@echo off

echo 脚本执行开始
echo ============

set DIR=%~dp0
%DIR%lua53.exe %DIR%test.lua

echo ============
echo 脚本执行结束

@pause