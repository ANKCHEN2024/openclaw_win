# OpenClaw Dependencies Downloader
# Downloads all required software to redist folder

param(
    [string]$RedistPath = "$PSScriptRoot\..\redist"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw Dependencies Downloader" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create redist directory
New-Item -ItemType Directory -Path $RedistPath -Force | Out-Null
Write-Host "Output directory: $RedistPath" -ForegroundColor Gray
Write-Host ""

# Download Node.js LTS (64-bit Windows Installer)
$nodeUrl = "https://nodejs.org/dist/v22.13.1/node-v22.13.1-x64.msi"
$nodeFile = "node-v22.13.1-x64.msi"

Write-Host "Downloading Node.js 22 LTS..." -ForegroundColor Yellow

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $nodeUrl -OutFile (Join-Path $RedistPath $nodeFile) -UseBasicParsing
    Write-Host "Downloaded: $nodeFile" -ForegroundColor Green
} catch {
    Write-Host "Failed to download Node.js: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Download complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Files in redist folder:" -ForegroundColor Gray
Get-ChildItem $RedistPath | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
Write-Host ""

<#
Alternative: Download using curl
curl -L -o redist\node-v22.13.1-x64.msi https://nodejs.org/dist/v22.13.1/node-v22.13.1-x64.msi
#>
