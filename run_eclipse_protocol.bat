@echo off
echo ========================================
echo   Eclipse Protocol - Starting Game
echo ========================================
echo.

REM Check if love2d folder exists locally
if exist "love2d\love-11.5-win64\love.exe" (
    echo Running game with local Love2D...
    echo.
    love2d\love-11.5-win64\love.exe EclipseProtocol
    goto :end
)

REM Check if Love2D is in PATH
where love >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Running game with system Love2D...
    echo.
    love EclipseProtocol
    goto :end
)

REM Check common installation paths
if exist "C:\Program Files\LOVE\love.exe" (
    echo Running game with Love2D from Program Files...
    echo.
    "C:\Program Files\LOVE\love.exe" EclipseProtocol
    goto :end
)

echo Love2D not found!
echo.
echo Please run: install_love2d.ps1
echo Or install Love2D from: https://love2d.org/
echo.
pause

:end
