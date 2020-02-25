@ECHO OFF

if %1=="" goto :help
if %1==h  goto :help
if %1==nb goto :newbranch
if %1==su goto :setupstream

if %1==cb call git symbolic-ref --short HEAD
if %1==cl call git clone %2
if %1==ab call git branch
if %1==cm call git checkout master
if %1==sb call git checkout %2
if %1==gl call git log --pretty=oneline --abbrev-commit
if %1==aa call git add .
if %1==af call git add %2
if %1==p  call git push
if %1==pl call git pull
if %1==co call git checkout -- %2
if %1==u  call git checkout -- .
if %1==s  call git status
if %1==c  call git commit -m %2
if %1==db call git branch -d %2
if %1==ui call git gui
if %1==gi call git rm -r --cached .

goto :eof

:newbranch
if "%2"=="" (
    echo Must specify new branch name! 
    goto :eof 
)
echo Creating new branch: %2
echo.
call git checkout -b %2
goto :eof

:setupstream
for /f "tokens=*" %%g in ('git symbolic-ref --short HEAD') do (set BRANCH=%%g)
call git push --set-upstream origin %BRANCH%
goto :eof

:help
echo Shortcut git utility for Git For Windows
echo.
echo      Usage: g (arg) [OPTIONS]
echo.
echo ex: g c "My commit message"
echo     g af myFile.js
echo     g db myOldBranch
echo.
echo [The Basics]                                      [Info]
echo g nb  new branch                                  g gl  get pretty log                      
echo g cb  current branch                              g s   check status of non committed files       
echo g ab  all branches                                g ui  use git gui       
echo g cm  checkout master         
echo g sb  checkout ^<branchName^>
echo g cl  clone ^<uri^>
echo.
echo [Branch Actions]                                  [Adding/Removing FIles]
echo g su  set upstream                                g aa  add all open files from root
echo g p   push to remote                              g af  add ^<file^>
echo g pl  pull from remote                            g u   undo all non commited changes from root
echo g db  delete branch                               g co  undo ^<file^>
echo g gi  removed cached files after gitignore        g c   commit ^<message^>
goto :eof