@echo off

echo 脚本执行开始
echo ============

set DIR=%~dp0
"E:\test\lua\LuaJIT_bin\luajit.exe" %DIR%test3.lua

echo ============
echo 脚本执行结束

@pause