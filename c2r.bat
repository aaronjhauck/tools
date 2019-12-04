@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

set ffd=%1
set iter=%2

if "%1"=="?"  goto help
if "%1"=="-h" goto help
if "%1"==""   goto help
if "%2"==""   goto help

set install=%USERPROFILE%\Dogfood
set location=\\o.fornax.off\tenants\FFD%ffd%\16.0.%ffd%.%iter%

REM ###===== get architecture ======###
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set _arch=x64
    if exist "%ProgramFiles(x86)%\Microsoft Office" (
        set _arch=x86
    )
) else (
    set _arch=x86
)
set exe=SetupO365ProPlusRetail.%_arch%.en-us.exe

REM ###===== get location from iter number ======###
if exist "%location%\C2RUniversalCB\latest" (
    set iterpath=%location%\C2RUniversalCB\latest
    goto copyout
) else if exist "%location%\C2R\latest" (
    REM If for any reason someone wants a release before C2RUniCB was a thing
    set iterpath=%location%\C2R\latest
    goto copyout
) else (
    echo.
    echo No c2r release availabe at %ffd%.%iter%^^! Try a different build number.
    echo.
    goto :help
)

REM ###===== copy the release ======###
:copyout
call :format "Downloading C2R Release: %ffd%.%iter%..."
xcopy %iterpath%\releases\client\en-us\16.0.%ffd%.%iter%_MondoRetailC2R_retail_ship_%_arch%_en-us\* %install%\%ffd%.%iter%\ /h/i/c/k/e/r/y>nul
echo.
echo Done^^!
echo.
echo   Location of download ===^> %install%\%ffd%.%iter%
if "%3"=="install" goto install
goto :eof

REM ###===== install the release ======###
:install
echo.
echo Looking for open Office applications...
echo.
REM Loop thru office apps - close if running
set "list=EXCEL LYNC MSACCESS OUTLOOK POWERPNT WINWORD"
for %%i in (%list%) do (
    for /f %%x in ('tasklist /nh /fi "IMAGENAME eq %%i.exe"') do (
        if %%x==%%i.EXE (
            echo Attempting to terminate %%x
            TASKKILL /IM %%x
        )
    )
)
call :format "Installing c2r release -- 16.0.%ffd%.%iter%..."
call %install%\%ffd%.%iter%\Office\Data\%exe%
echo Done^^!
goto clean

REM ###===== remove install dir ======###
:clean
echo.
echo Cleaning up...
rd /s /q %install%\%ffd%.%iter%
call :format "Removed install location: %install%\%ffd%.%iter%"
goto :eof

:format
echo.
echo    ##################################################################
echo    %~1
echo    ##################################################################
echo.
goto :eof

:help
echo == c2r.bat : unauthorized c2r install tool==
echo.
echo usage: c2r [buildgroup] [iter] (optional: install)
echo.
echo    Download only:
echo    c2r 11723 20004
echo.
echo    Download and install:
echo    c2r 11723 20004 install
goto :eof

ENDLOCAL