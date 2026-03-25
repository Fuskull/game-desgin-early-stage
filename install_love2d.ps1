# PowerShell script to download and setup Love2D

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Love2D Installer for Eclipse Protocol" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Download URL for Love2D (Windows 64-bit)
$love2dUrl = "https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip"
$downloadPath = "$PWD\love-11.5-win64.zip"
$extractPath = "$PWD\love2d"

Write-Host "Downloading Love2D 11.5..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $love2dUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "✓ Download complete!" -ForegroundColor Green
} catch {
    Write-Host "✗ Download failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Extracting Love2D..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
    Write-Host "✓ Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "✗ Extraction failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item $downloadPath

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Love2D installed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $extractPath\love-11.5-win64\" -ForegroundColor Cyan
Write-Host ""
Write-Host "To run your game, use:" -ForegroundColor Yellow
Write-Host "  .\love2d\love-11.5-win64\love.exe .\EclipseProtocol" -ForegroundColor White
Write-Host ""
