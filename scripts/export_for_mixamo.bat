@echo off
REM ============================================================
REM  Mixamo用 FBX 自動エクスポート (.bat ダブルクリックで起動)
REM
REM  ・引数なしでこの .bat を実行 → 練習用キャラを書き出し
REM  ・別キャラを書き出したい場合: 「.bat に .blend / .vrm をドラッグ＆ドロップ」
REM ============================================================

setlocal

REM === Blenderの実行パス（5.1）===
set "BLENDER_EXE=C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"

REM === スクリプトの場所（このbatと同じフォルダ）===
set "SCRIPT_DIR=%~dp0"
set "PYSCRIPT=%SCRIPT_DIR%export_for_mixamo.py"

REM === 入力ファイルの決定 ===
if "%~1"=="" (
    REM 引数なし → デフォルトの練習用キャラ
    set "INPUT=%SCRIPT_DIR%..\blender\Characters\Character_01_練習用.blend"
) else (
    REM ドラッグ&ドロップされたファイル
    set "INPUT=%~1"
)

REM === Blender実行可否チェック ===
if not exist "%BLENDER_EXE%" (
    echo [ERROR] Blender not found: %BLENDER_EXE%
    echo Blender 5.1 がこのパスに無い場合、この .bat の BLENDER_EXE を書き換えてください。
    pause
    exit /b 1
)

if not exist "%PYSCRIPT%" (
    echo [ERROR] Pythonスクリプトが見つかりません: %PYSCRIPT%
    pause
    exit /b 1
)

if not exist "%INPUT%" (
    echo [ERROR] 入力ファイルが見つかりません: %INPUT%
    pause
    exit /b 1
)

echo ============================================================
echo  Mixamo用 FBX エクスポート開始
echo  Input : %INPUT%
echo ============================================================
echo.

"%BLENDER_EXE%" --background --python "%PYSCRIPT%" -- "%INPUT%"

set EXITCODE=%ERRORLEVEL%
echo.
if %EXITCODE% NEQ 0 (
    echo [失敗] エラーコード=%EXITCODE%
) else (
    echo [成功] FBXは元ファイルと同じフォルダに「<元ファイル名>_for_mixamo.fbx」で出力されています
)
echo.
pause
endlocal
