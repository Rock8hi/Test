@echo off

echo 脚本执行开始
echo ============

set DIR=%~dp0
%DIR%lua_535.exe %DIR%test_535.lua

echo ============
echo 脚本执行结束

@pause