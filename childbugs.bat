@ECHO OFF
SETLOCAL
SET childbugs=%CD%\pkgs\childbugs\childbugs\childbugs.exe

:argloop
if not "%1"=="" (
    if "%1"=="-b" (
        set bug=%2
        shift
    )
    if "%1"=="-p" (
        set proj=%2
        shift
    )
    if "%1"=="-f" (
        set ffd=%2
        shift
    )
    shift
    goto :argloop
)

for %%a in (bug proj ffd) do (
    if not defined %%a (
        echo.
        echo Arg missing! : %%a
        goto :help
    )
)

:callcb
echo.
call %childbugs% -b %bug% -p %proj% -f %ffd%
goto :eof

:help
echo.
echo usage: childbugs [args]
echo.
echo childbugs -b [bug] -p [project] -f [ffd]
exit /b %errorlevel%