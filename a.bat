@echo off

if %1==h    goto :help

if %1==m    perl -ne "$_=\"$.: $_\"; next unless m/%2/; print $_" %3
if %1==fr   perl -i.bak -p -e "BEGIN{@ARGV=map glob,@ARGV}s/%2/%3/gi;" %4 && del *.bak
if %1==dr   dir /a-d /b | perl -nle "$o=$_;s/%2/%3/g;$n=$_;rename($o,$n)if!-e$n"
goto :eof

:help
echo.
echo [m]  Find and print line numbers from pattern in files
echo [fr] Find and replace string in bulk files
echo [dr] Bulk rename files in directory
goto :eof