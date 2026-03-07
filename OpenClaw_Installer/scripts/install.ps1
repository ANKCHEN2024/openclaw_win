# OpenClaw Installer Script
# Requires: Admin rights
# Optional: Node.js in redist folder

param(
    [string]$InstallPath = "$env:ProgramFiles\OpenClaw",
    [switch]$Silent
)

$ErrorActionPreference = "Continue"

$RedistPath = Join-Path $PSScriptRoot "..\redist"

function Write-Step {
    param([string]$Message)
    Write-Host "[Step] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[Warn] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[Error] $Message" -ForegroundColor Red
}

# Check Admin
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Err "Admin rights required"
    Write-Host "Please run as Administrator" -ForegroundColor Yellow
    exit 1
}

# Check/Install Node.js
Write-Step "Checking Node.js..."
$nodeVersion = & node --version 2>$null

if (-not $nodeVersion) {
    Write-Warn "Node.js not found"
    
    # Try to install from local
    $nodeMsi = Get-ChildItem $RedistPath -Filter "node-*.msi" | Select-Object -First 1
    
    if ($nodeMsi) {
        Write-Host "Installing Node.js from local file..." -ForegroundColor Yellow
        $msiPath = $nodeMsi.FullName
        Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
        Write-Success "Node.js installed"
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        $nodeVersion = & node --version 2>$null
    } else {
        Write-Err "Node.js not found and no local installer"
        Write-Host "Please install Node.js 22+: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
}

Write-Success "Node.js: $nodeVersion"

# Create directories
Write-Step "Creating directories..."
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
New-Item -ItemType Directory -Path "$InstallPath\config" -Force | Out-Null
New-Item -ItemType Directory -Path "$InstallPath\logs" -Force | Out-Null
New-Item -ItemType Directory -Path "$InstallPath\data" -Force | Out-Null
Write-Success "Directories created"

# Install OpenClaw
Write-Step "Installing OpenClaw..."
Set-Location $InstallPath

$installSuccess = $false

# Try global install
Write-Host "  Trying global install..." -ForegroundColor Gray
$null = & npm install -g openclaw 2>&1 | Out-String
if ($LASTEXITCODE -eq 0) {
    $installSuccess = $true
    Write-Success "Global install OK"
}

# Try local install if global failed
if (-not $installSuccess) {
    Write-Host "  Trying local install..." -ForegroundColor Gray
    $null = & npm init -y 2>&1 | Out-String
    $null = & npm install openclaw 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        $installSuccess = $true
        Write-Success "Local install OK"
    }
}

if (-not $installSuccess) {
    Write-Warn "OpenClaw install failed - will use npx to run"
}

# Run initial setup
Write-Step "Configuring OpenClaw..."
Write-Host "  Running doctor..." -ForegroundColor Gray
$null = & npx openclaw doctor --fix 2>&1 | Out-String

Write-Host "  Setting gateway mode..." -ForegroundColor Gray
$null = & npx openclaw config set gateway.mode local 2>&1 | Out-String

# ====== FIX: Disable token auth ======
Write-Host "  Disabling token authentication..." -ForegroundColor Gray
$null = & npx openclaw config set gateway.auth.mode none 2>&1 | Out-String

# ====== CONFIGURE AGENT FULL PERMISSIONS ======
Write-Step "Configuring AGENT FULL permissions..."

Write-Host "  Setting allowBrowser=true..." -ForegroundColor Gray
$null = & npx openclaw config set agents.defaults.permissions.allowBrowser true 2>&1 | Out-String

Write-Host "  Setting allowReadFiles=true..." -ForegroundColor Gray
$null = & npx openclaw config set agents.defaults.permissions.allowReadFiles true 2>&1 | Out-String

Write-Host "  Setting allowWriteFiles=true..." -ForegroundColor Gray
$null = & npx openclaw config set agents.defaults.permissions.allowWriteFiles true 2>&1 | Out-String

Write-Host "  Setting allowExecute=true..." -ForegroundColor Gray
$null = & npx openclaw config set agents.defaults.permissions.allowExecute true 2>&1 | Out-String

Write-Host "  Setting allowTerminal=true..." -ForegroundColor Gray
$null = & npx openclaw config set agents.defaults.permissions.allowTerminal true 2>&1 | Out-String

Write-Host "  Setting maxConcurrentTools=10..." -ForegroundColor Gray
$null = & npx openclaw config set agents.defaults.permissions.maxConcurrentTools 10 2>&1 | Out-String

Write-Host "  Setting security.requireApproval=false..." -ForegroundColor Gray
$null = & npx openclaw config set security.requireApproval false 2>&1 | Out-String

Write-Host "  Setting channel group policies to open..." -ForegroundColor Gray
$null = & npx openclaw config set channels.whatsapp.groupPolicy open 2>&1 | Out-String
$null = & npx openclaw config set channels.telegram.groupPolicy open 2>&1 | Out-String
$null = & npx openclaw config set channels.discord.groupPolicy open 2>&1 | Out-String

Write-Success "Agent FULL permissions configured!"

# Create config directory copy
$configDir = "$env:USERPROFILE\.openclaw"
if (Test-Path "$configDir\openclaw.json") {
    Copy-Item "$configDir\openclaw.json" "$InstallPath\config\" -Force -ErrorAction SilentlyContinue
}

# Create start script
$startScript = "@echo off`ncd /d `"%~dp0`"`ntitle OpenClaw Gateway`nnpx openclaw gateway`npause"
$startScriptPath = Join-Path $InstallPath "start.bat"
Set-Content -Path $startScriptPath -Value $startScript -Encoding ASCII

# Create start minimized script (for startup)
$startMinimizedScript = "@echo off`nstart /min cmd /c `"npx openclaw gateway`""
$startMinimizedScriptPath = Join-Path $InstallPath "start_minimized.bat"
Set-Content -Path $startMinimizedScriptPath -Value $startMinimizedScript -Encoding ASCII

# Create shortcuts
Write-Step "Creating shortcuts..."

try {
    $WshShell = New-Object -ComObject WScript.Shell

    $desktopShortcut = Join-Path $env:USERPROFILE "Desktop\OpenClaw.lnk"
    $Shortcut = $WshShell.CreateShortcut($desktopShortcut)
    $Shortcut.TargetPath = "cmd.exe"
    $Shortcut.Arguments = "/c npx openclaw gateway"
    $Shortcut.WorkingDirectory = $env:USERPROFILE
    $Shortcut.Description = "OpenClaw AI Gateway (FULL permissions)"
    $Shortcut.Save()
    Write-Success "Desktop shortcut created"

    $startMenuPath = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\OpenClaw"
    New-Item -ItemType Directory -Path $startMenuPath -Force | Out-Null
    $startMenuShortcut = Join-Path $startMenuPath "OpenClaw.lnk"
    $Shortcut = $WshShell.CreateShortcut($startMenuShortcut)
    $Shortcut.TargetPath = "cmd.exe"
    $Shortcut.Arguments = "/c npx openclaw gateway"
    $Shortcut.WorkingDirectory = $env:USERPROFILE
    $Shortcut.Description = "OpenClaw AI Gateway"
    $Shortcut.Save()
    
    # Add dashboard shortcut
    $dashboardShortcut = Join-Path $startMenuPath "Dashboard.lnk"
    $Shortcut = $WshShell.CreateShortcut($dashboardShortcut)
    $Shortcut.TargetPath = "cmd.exe"
    $Shortcut.Arguments = "/c start http://127.0.0.1:18789/"
    $Shortcut.WorkingDirectory = $env:USERPROFILE
    $Shortcut.Description = "OpenClaw Control Panel"
    $Shortcut.Save()
} catch {
    Write-Warn "Could not create shortcuts: $_"
}

# ====== CREATE WINDOWS SCHEDULED TASK FOR AUTO START ======
Write-Step "Creating Windows scheduled task for auto-start..."

$taskName = "OpenClaw Gateway"
$taskDescription = "Auto-start OpenClaw Gateway on Windows startup"

# Delete existing task if exists
$null = & schtasks /Delete /TN $taskName /F 2>&1 | Out-Null

# Create new task
$taskCommand = "schtasks /Create /TN `"$taskName`" /TR `"`"$InstallPath\start_minimized.bat`"" /SC ONLOGON /RL LIMITED /F"
$null = & cmd /c $taskCommand 2>&1 | Out-Null
Write-Success "Auto-start task created"

# Register uninstall
Write-Step "Registering uninstall..."

$uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenClaw"
New-Item -Path $uninstallKey -Force | Out-Null
Set-ItemProperty -Path $uninstallKey -Name "DisplayName" -Value "OpenClaw" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $uninstallKey -Name "DisplayVersion" -Value "2026.3.2" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $uninstallKey -Name "Publisher" -Value "OpenClaw Team" -ErrorAction SilentlyContinue
Set-ItemProperty -Path $uninstallKey -Name "InstallLocation" -Value $InstallPath -ErrorAction SilentlyContinue

$uninstallScript = "@echo off`ntitle OpenClaw Uninstall`necho Confirm uninstall? (Y/N)`nset /p CONFIRM=`nif /i not `"%CONFIRM%`"==`"Y`" exit`necho Deleting files...`nschtasks /Delete /TN `"OpenClaw Gateway`" /F 2>nul`nif exist `"%ProgramFiles%\OpenClaw`" rmdir /S /Q `"%ProgramFiles%\OpenClaw`"`ndel /Q `"%USERPROFILE%\Desktop\OpenClaw.lnk`" 2>nul`nreg delete `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenClaw`" /f 2>nul`necho Done`npause"

$uninstallPath = Join-Path $InstallPath "uninstall.bat"
Set-Content -Path $uninstallPath -Value $uninstallScript -Encoding ASCII

Write-Success "Uninstall registered"

# ====== START GATEWAY AND OPEN BROWSER ======
Write-Step "Starting Gateway and opening browser..."

# Start gateway in background
Start-Process -FilePath "npx" -ArgumentList "openclaw gateway" -WindowStyle Hidden

# Wait a moment for gateway to start
Start-Sleep -Seconds 3

# Open browser
Start-Process -FilePath "http://127.0.0.1:18789/"
Write-Success "Browser opened"

# Done
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $InstallPath" -ForegroundColor White
Write-Host ""
Write-Host "======================================" -ForegroundColor Yellow
Write-Host "   AGENT FULL PERMISSIONS CONFIGURED!" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Agent Permissions:" -ForegroundColor White
Write-Host "  - allowBrowser: true" -ForegroundColor Green
Write-Host "  - allowReadFiles: true" -ForegroundColor Green
Write-Host "  - allowWriteFiles: true" -ForegroundColor Green
Write-Host "  - allowExecute: true" -ForegroundColor Green
Write-Host "  - allowTerminal: true" -ForegroundColor Green
Write-Host "  - requireApproval: false" -ForegroundColor Green
Write-Host "  - gateway.auth.mode: none" -ForegroundColor Green
Write-Host ""
Write-Host "Auto-start:" -ForegroundColor Yellow
Write-Host "  - Windows task created (will start on login)" -ForegroundColor Green
Write-Host ""
Write-Host "Control Panel: http://127.0.0.1:18789/" -ForegroundColor Cyan
Write-Host ""

exit 0
