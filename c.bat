@ECHO OFF

::personal
if %1==""      call chdir C:\src
if %1==src     call chdir C:\src
if %1==t       call chdir C:\src\tools
if %1==ms      call chdir C:\old\ms_tools
if %1==asd     call chdir C:\src\asdtools
if %1==local   call chdir C:\local

::azuremart
if %1==cc      call chdir C:\src\azuremart\ControlCenter
if %1==db      call chdir C:\src\azuremart\Databases
if %1==scripts call chdir C:\src\azuremart\Scripts
if %1==ssas    call chdir C:\src\azuremart\SSAS
if %1==ssrs    call chdir C:\src\azuremart\SSRS
if %1==azt     call chdir C:\src\azuremart\Tools

::bijoe
if %1==bijoe   call chdir C:\src\bi-joe

goto quit

:chdir
pushd %1

:quit
exit /b %errorlevel%