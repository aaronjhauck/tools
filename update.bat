@ECHO OFF

cls
echo Refreshing %COMPUTERNAME%
echo.
call c root
call sd sync -q

call officenuget cleangen
call officenuget cleancache
call officenuget init

echo.
echo Finished refreshing %COMPUTERNAME%