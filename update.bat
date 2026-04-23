@echo off
REM ===========================================================
REM  VRBoxing - commit + push to GitHub
REM  Double-click this file to update the repo and docs site.
REM  (Docsify auto-deploys on push, no build step needed)
REM ===========================================================

REM Use UTF-8 so Japanese commit messages work
chcp 65001 > nul

cd /d C:\Users\hoeho\Documents\Claude\VRBoxing

echo.
echo ================================================================
echo   VRBoxing  -  update and publish
echo ================================================================
echo.

REM Ask for a commit message (press Enter to use default)
set "MSG="
set /p MSG=Commit message (press Enter for default):
if "%MSG%"=="" set "MSG=Update docs"

echo.
echo [1/3] Staging changes ...
git add .

echo.
echo [2/3] Committing ...
git commit -m "%MSG%"
if errorlevel 1 echo   (nothing to commit, or commit skipped)

echo.
echo [3/3] Pushing to GitHub ...
git push
if errorlevel 1 (
    echo.
    echo   ERROR: git push failed. Check the messages above.
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================================
echo   Done!
echo   Site URL: https://annachloe2025.github.io/VRBoxing/
echo   (reflection takes 1-2 minutes)
echo ================================================================
echo.
pause
