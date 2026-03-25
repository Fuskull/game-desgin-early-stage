@echo off
echo ========================================
echo   Eclipse Protocol - Phase 1
echo ========================================
echo.

REM Check if Love2D is in PATH
where love >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Starting game with Love2D...
    echo.
    love .
) else (
    echo Love2D not found in PATH!
    echo.
    echo Please install Love2D from: https://love2d.org/
    echo.
    echo After installation, either:
    echo 1. Drag the EclipseProtocol folder onto love.exe
    echo 2. Or run: "C:\Program Files\LOVE\love.exe" .
    echo.
    pause
)
