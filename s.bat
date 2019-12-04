@ECHO OFF

set _src=C:\src

if %1==src      pushd %_src%
if %1==""       pushd %_src%
if %1==t        pushd %_src%\personal\tools
if %1==p        pushd %_src%\personal\personal
