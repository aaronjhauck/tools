@ECHO OFF
SETLOCAL
SET dmq=%CD%\pkgs\dmq\dmq\dmq.exe

if "%1"==""   goto :help
if "%2"==""   goto :help
if "%1"=="-h" goto :help

if "%3"=="nf" (
    call %dmq% %1 %2 | perl -nle "print unless m/Success/g"
    goto :eof
) else (
    call %dmq% %1 %2
    goto :eof
)

:help
echo.
echo dmq.bat - list the devmain cloud build queue status for .10000 WaitForCB task
echo.
echo    dmq.bat [labBranch (labXX)] [number of results]
echo.
echo        ex: dmq.bat lab18 3
echo.
echo    to see a list of only unfinished builds - add "nf" at end of cmd
goto :eof