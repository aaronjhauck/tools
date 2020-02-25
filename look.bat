@ECHO OFF

if "%1"=="-f" (
    call :files %2
) else (
    findstr /spinm /c:"%1" *.*
)
exit /b 0

:files
dir %1 /S /B
exit /b 0