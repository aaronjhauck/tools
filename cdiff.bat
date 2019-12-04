@ECHO OFF
SETLOCAL

if "%1"==""        goto :invalid
if "%2"==""        goto :invalid

call sdvdiff ...@%1,%1 ...@%2,%2
goto :end

:invalid
echo.
echo Must specify two changelists to compare.
echo.
echo Usage:
echo cdiff [cl1] [cl2]
echo.
goto :end

:end
ENDLOCAL