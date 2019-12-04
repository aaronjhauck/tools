@echo off

SETLOCAL

set _usr=%USERPROFILE%\BLRepo

REM Ensure git looks okay

git --version>nul & if errorlevel 1 (
    echo.
    echo Git is not installed! Google "git for windows"
    echo.
    exit /b %errorlevel% )

echo.
echo Git appears to be installed...
echo.

if not exist "%_usr%" mkdir %_usr%

git clone https://github.com/blrepo/tools.git %_usr%

REM Ensure perl looks okay

perl -v>nul & if errorlevel 1 (
    echo.
    echo Perl is not installed! Google "perl for windows"
    echo.
    exit /b %errorlevel% )

echo.
echo Perl appears to be installed...
echo.

REM Create desktop shortcut for BLRepo
echo.
echo Creating BLRepo desktop shortcut...

set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%.vbs"

echo set object            = WScript.CreateObject("WScript.Shell")  >> %SCRIPT%
echo shortcut              = "%USERPROFILE%\Desktop\BLRepo.lnk"     >> %SCRIPT%
echo set link              = object.CreateShortcut(shortcut)        >> %SCRIPT%
echo link.TargetPath       = "C:\Windows\System32\cmd.exe"          >> %SCRIPT%
echo link.Arguments        = "/k ""%_usr%\setenv.bat"""             >> %SCRIPT%
echo link.IconLocation     = "%_usr%\blacklodge.ico"                >> %SCRIPT%
echo link.WorkingDirectory = "%_usr%"                               >> %SCRIPT%
echo link.Save                                                      >> %SCRIPT%

cscript /nologo %SCRIPT%

del %SCRIPT%


echo.
echo Done - launch BLRepo from desktop to set the environment