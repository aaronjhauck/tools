@ECHO OFF

SET PATH=%PATH%;%CD%;%CD%\Ruby
SET PROMPT=[$P]%USERNAME%@%COMPUTERNAME% ^> 

echo.
echo Ensuring sources are up to date...

git pull

echo.
echo #####################################################################
echo #  Please note: All tools are under constant development!           #
echo #                                                                   #
echo #  Head to github.com/blrepo if you'd like to submit a pull request #
echo #####################################################################
echo.
echo.
echo /$$       /$$                     /$$       /$$                 /$$                    
echo ^| $$      ^| $$                    ^| $$      ^| $$                ^| $$                    
echo ^| $$$$$$$ ^| $$  /$$$$$$   /$$$$$$$^| $$   /$$^| $$  /$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$ 
echo ^| $$__  $$^| $$ ^|____  $$ /$$_____/^| $$  /$$/^| $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$__  $$
echo ^| $$  \ $$^| $$  /$$$$$$$^| $$      ^| $$$$$$/ ^| $$^| $$  \ $$^| $$  ^| $$^| $$  \ $$^| $$$$$$$$
echo ^| $$  ^| $$^| $$ /$$__  $$^| $$      ^| $$_  $$ ^| $$^| $$  ^| $$^| $$  ^| $$^| $$  ^| $$^| $$_____/
echo ^| $$$$$$$/^| $$^|  $$$$$$$^|  $$$$$$$^| $$ \  $$^| $$^|  $$$$$$/^|  $$$$$$$^|  $$$$$$$^|  $$$$$$$
echo ^|_______/ ^|__/ \_______/ \_______/^|__/  \__/^|__/ \______/  \_______/ \____  $$ \_______/
echo                                                                      /$$  \ $$          
echo   contact v-aahauc with any issues                                  ^|  $$$$$$/          
echo                                                                      \______/  