@call :SETTOOLPATH
@%_TOOLPATH% %*
@set _TOOLPATH=& exit /b %ERRORLEVEL%

:SETTOOLPATH
@set _TOOLPATH="\\officefile\public\y-arnold\Tools\CloudBuild.BuildRequester.19.9.11.150830\tools\CB.exe"
@exit /b