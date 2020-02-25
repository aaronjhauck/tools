@ECHO OFF

if "%1"==""  goto :help
if "%1"=="h" goto :help
if "%1"=="?" goto :help

if "%1"=="-f" (
    call :files %2
) else (
    findstr /spinm /c:"%1" *.*
)
exit /b %errorlevel%

:files
dir %1 /S /B
exit /b %errorlevel%

:help
echo    usage: look [OPTIONS]
echo.
echo search files recursively for specific string or add 
echo -f to find location of a specific file by filename
echo.
echo ex: look ^<searchPattern^> ## look "my search pattern"
echo     look -f ^<fileName^>   ## look -f myFileName.js ^| myFileName.*
exit /b %errorlevel%