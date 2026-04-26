@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cd /d C:\Users\hoeho\Documents\Claude\VRBoxing

echo ==============================================
echo VRBoxing - リポジトリ整理 (一度だけ実行)
echo ==============================================
echo.
echo このスクリプトは:
echo   1. 旧フォルダをリネーム
echo      02_Assets_Source -^> blender
echo      03_Unity_Project -^> unity
echo   2. GitHub に履歴書き換え済みの内容を force push (不可逆)
echo.
echo [重要] 開始前に Unity Editor / VS Code / Explorer で
echo        VRBoxing を開いていたら全部閉じてください。
echo.

set "CONFIRM="
set /p CONFIRM=続行しますか？ (Y/N):
if /i not "!CONFIRM!"=="Y" (
    echo キャンセルしました。
    pause
    exit /b 0
)

echo.
echo [1/3] フォルダリネーム ...
if exist 02_Assets_Source (
    ren 02_Assets_Source blender
    if errorlevel 1 (
        echo   ERROR: 02_Assets_Source のリネームに失敗しました。
        echo   フォルダを開いているアプリを閉じてからやり直してください。
        pause
        exit /b 1
    )
    echo   02_Assets_Source -^> blender  OK
) else (
    echo   02_Assets_Source は既に存在しません ^(skip^)
)

if exist 03_Unity_Project (
    ren 03_Unity_Project unity
    if errorlevel 1 (
        echo   ERROR: 03_Unity_Project のリネームに失敗しました。
        echo   Unity Editor を閉じてからやり直してください。
        pause
        exit /b 1
    )
    echo   03_Unity_Project -^> unity  OK
) else (
    echo   03_Unity_Project は既に存在しません ^(skip^)
)

echo.
echo [2/3] GitHub に force push ...
git push --force origin main
if errorlevel 1 (
    echo.
    echo   ERROR: push に失敗しました。Git 認証を確認してください。
    pause
    exit /b 1
)
echo   push OK

echo.
echo [3/3] 完了！
echo ==============================================
echo  リポジトリサイズが 114MB から 1.1MB へ削減されました。
echo  GitHub: https://github.com/annachloe2025/VRBoxing
echo.
echo  ▼ 次にやること:
echo   1. Unity Hub を開く
echo   2. 旧プロジェクト 03_Unity_Project の登録を Remove
echo   3. Add から新パスを追加:
echo      C:\Users\hoeho\Documents\Claude\VRBoxing\unity
echo   4. このスクリプト ^(reorganize_once.bat^) を削除して OK
echo ==============================================
echo.
pause
