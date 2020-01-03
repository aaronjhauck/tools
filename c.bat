@ECHO OFF

REM set _src=C:\src

if %1==""  pushd C:\src
if %1==t   pushd C:\src\tools
if %1==ms  pushd C:\old\ms_tools
if %1==src pushd C:\src
if %1==asd pushd C:\src\asdtools