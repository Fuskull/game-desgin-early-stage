@echo off
echo ========================================
echo   Running Eclipse Protocol
echo ========================================
echo.

REM Try to find and run Love2D
if exist "C:\Program Files\LOVE\love.exe" (
    echo Found Love2D in Program Files
    "C:\Program Files\LOVE\love.exe" "%~dp0EclipseProtocol"
    goto :end
)

if exist "%LOCALAPPDATA%\love\love.exe" (
    echo Found Love2D in LocalAppData
    "%LOCALAPPDATA%\love\love.exe" "%~dp0EclipseProtocol"
    goto :end
)

echo.
echo Love2D not found!
echo.
echo Please download and install Love2D from:
echo https://love2d.org/
echo.
echo After installing, run this batch file again.
echo.
pause

:end
