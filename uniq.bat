@ECHO OFF

if "%1"=="" goto help
if "%2"=="" goto help

type %1 | sort /unique > %2
goto eof

:help
echo uniq - sort text file into unique entries
echo.
echo     usage: uniq [inputFile] [outputFile]
echo.
echo example: uniq errors.txt errorsNoDupes.txt

:eof
exit /b %errorlevel%