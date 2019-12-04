@ECHO OFF

if "%1"=="f" (
    call N:\src\otools\bin\OpenEnlistment.bat
    call \\obuildlab\Shares\Published\CredMapping\credmap.bat
    goto :eof
) 
call \\obuildlab\Shares\Published\CredMapping\credmap.bat

:eof
