@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ==============================================
REM  VRBoxing - update and publish
REM  Double-click this file.
REM ==============================================

cd /d C:\Users\hoeho\Documents\Claude\VRBoxing

echo.
echo ==============================================
echo   VRBoxing - update and publish
echo ==============================================
echo.

REM --- setup: install MkDocs + Material if needed ---
echo [setup] Checking MkDocs + Material ...
pip install --quiet --upgrade mkdocs mkdocs-material pymdown-extensions
if errorlevel 1 (
    echo.
    echo   ERROR: pip install failed.
    echo   Make sure Python and pip are installed.
    echo.
    pause
    exit /b 1
)

REM --- migrate: clean up old Docsify files if present ---
if exist index.html (
    echo [migrate] Removing old Docsify files ...
    git rm -f index.html _sidebar.md _coverpage.md 2>nul
)
if exist 01_Docs\README.md git rm -f 01_Docs\README.md 2>nul
if exist 01_Docs\step1_plan.md git rm -f 01_Docs\step1_plan.md 2>nul
if exist 01_Docs\design_notes.md git rm -f 01_Docs\design_notes.md 2>nul
if exist 01_Docs\dev_log.md git rm -f 01_Docs\dev_log.md 2>nul
if exist 01_Docs\github_setup.md git rm -f 01_Docs\github_setup.md 2>nul
if exist 01_Docs\docs_site_guide.md git rm -f 01_Docs\docs_site_guide.md 2>nul
if exist 02_Assets_Source\README.md git rm -f 02_Assets_Source\README.md 2>nul
if exist 02_Assets_Source\Characters\README.md git rm -f 02_Assets_Source\Characters\README.md 2>nul
if exist 03_Unity_Project\README.md git rm -f 03_Unity_Project\README.md 2>nul
if exist 04_Builds\README.md git rm -f 04_Builds\README.md 2>nul
if exist 05_Reference\README.md git rm -f 05_Reference\README.md 2>nul
if exist 06_Backups\README.md git rm -f 06_Backups\README.md 2>nul
if exist TASKS.md git rm -f TASKS.md 2>nul

REM --- commit message input (default on Enter) ---
set "MSG="
set /p MSG=Commit message (press Enter for default): 
if "!MSG!"=="" set "MSG=Update docs"

echo.
echo [1/4] Staging changes ...
git add .

echo.
echo [2/4] Committing ...
git commit -m "!MSG!"
if errorlevel 1 echo   (nothing to commit, or commit skipped)

echo.
echo [3/4] Pushing to GitHub ...
git push
if errorlevel 1 (
    echo.
    echo   ERROR: git push failed.
    echo.
    pause
    exit /b 1
)

echo.
echo [4/4] Deploying site to GitHub Pages ...
python -m mkdocs gh-deploy --force
if errorlevel 1 (
    echo.
    echo   ERROR: mkdocs gh-deploy failed.
    echo.
    pause
    exit /b 1
)

echo.
echo ==============================================
echo   Done!
echo   Site: https://annachloe2025.github.io/VRBoxing/
echo   (reflection takes 1-2 minutes)
echo ==============================================
echo.
pause
