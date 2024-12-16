@echo off
setlocal enabledelayedexpansion
echo Checking for FFmpeg installation...

winget list FFmpeg >nul 2>&1
if "%ERRORLEVEL%"=="0" (
    echo FFmpeg is already installed.
    echo.
    echo [1] Upgrade FFmpeg
    echo [2] Uninstall FFmpeg
    set /p choice="Enter your choice [1-2]: "
    set choice=!choice:~0,1!
    echo !choice!
    if "!choice!"=="1" (
        echo Upgrading FFmpeg...
        winget upgrade FFmpeg
        echo FFmpeg has been upgraded.
    ) else if "!choice!"=="2" (
        echo Uninstalling FFmpeg...
        winget uninstall FFmpeg
        echo FFmpeg has been uninstalled.
    ) else (
        echo Invalid choice.
    )
) else (
    echo FFmpeg is not installed.
    echo Installing FFmpeg...
    winget install FFmpeg
    echo FFmpeg has been installed.
)
pause