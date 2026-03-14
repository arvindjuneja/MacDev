# ============================================
# Claude Code Monitor Setup (Windows)
# ============================================
# Installs the Claude Code Monitor dashboard:
# - Checks/installs uv (Python package runner)
# - Deploys claude-monitor to ~/.local/bin
# - Adds shell alias
#
# Usage: powershell -ExecutionPolicy Bypass -File setup-claude-monitor.ps1
# ============================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

function Print-Header {
    Write-Host ""
    Write-Host "+===========================================" -ForegroundColor Magenta
    Write-Host "|    Claude Code Monitor Setup (Windows)    |" -ForegroundColor Magenta
    Write-Host "+===========================================" -ForegroundColor Magenta
    Write-Host ""
}

function Print-Step { param([string]$Message) Write-Host "`n>> $Message" -ForegroundColor Cyan }
function Print-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Print-Error { param([string]$Message) Write-Host "[X] $Message" -ForegroundColor Red }
function Print-Info { param([string]$Message) Write-Host "[i] $Message" -ForegroundColor Yellow }

# Install uv if not present (or broken shim)
function Install-UV {
    Print-Step "Checking uv (Python package runner)..."

    $uvWorks = $false
    try {
        $version = uv --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $uvWorks = $true
            Print-Success "uv already installed ($version)"
        }
    } catch {
        # uv command not found or broken shim
    }

    if (-not $uvWorks) {
        # Try scoop first
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Print-Info "Installing uv via scoop..."
            scoop install uv
        } else {
            Print-Info "Installing uv via installer..."
            Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        }
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Print-Success "uv installed ($(uv --version))"
    }
}

# Deploy claude-monitor script
function Deploy-Monitor {
    Print-Step "Deploying claude-monitor..."

    $monitorSrc = Join-Path $ProjectRoot "scripts\claude-monitor.py"
    $binDir = Join-Path $env:USERPROFILE ".local\bin"
    $monitorDest = Join-Path $binDir "claude-monitor.py"

    # Ensure bin directory exists
    if (-not (Test-Path $binDir)) {
        New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    }

    if (Test-Path $monitorSrc) {
        Copy-Item $monitorSrc $monitorDest -Force
        Print-Success "claude-monitor.py installed to $monitorDest"

        # Create a wrapper batch file for easy execution
        $wrapperPath = Join-Path $binDir "claude-monitor.cmd"
        $wrapperContent = "@echo off`r`nuv run --script `"%~dp0claude-monitor.py`" %*"
        Set-Content -Path $wrapperPath -Value $wrapperContent
        Print-Success "claude-monitor.cmd wrapper created"
    } else {
        Print-Error "claude-monitor.py not found at $monitorSrc"
        exit 1
    }
}

# Warm up dependencies
function Warmup-Dependencies {
    Print-Step "Warming up dependencies (first-run uv install)..."

    $monitorPath = Join-Path $env:USERPROFILE ".local\bin\claude-monitor.cmd"
    try {
        & $monitorPath --once 2>$null | Out-Null
        Print-Success "Dependencies installed and monitor works"
    } catch {
        Print-Info "First run may take a moment while uv installs rich..."
        try {
            & $monitorPath --once 2>$null
        } catch {}
        Print-Success "Dependencies resolved"
    }
}

# Add alias to PowerShell profile
function Configure-Shell {
    Print-Step "Adding shell alias..."

    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path -Parent $profilePath

    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $profileContent = ""
    if (Test-Path $profilePath) {
        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    }

    if ($profileContent -notmatch "=== Claude Monitor ===") {
        $monitorConfig = @'

# === Claude Monitor ===
# Added by MacDev claude-monitor setup
$clMonBin = "$env:USERPROFILE\.local\bin"
if (Test-Path $clMonBin) {
    $env:Path = "$clMonBin;$env:Path"
}
function cmon { claude-monitor @args }
# === End Claude Monitor ===
'@
        Add-Content -Path $profilePath -Value $monitorConfig
        Print-Success "Alias 'cmon' added to PowerShell profile"
    } else {
        Print-Success "Claude Monitor config already exists in profile"
    }
}

# Print completion
function Print-Completion {
    Write-Host ""
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host "|     Claude Code Monitor Setup Complete!                   |" -ForegroundColor Green
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "What's installed:" -ForegroundColor Cyan
    Write-Host "  - uv             - Python package runner (zero-setup deps)"
    Write-Host "  - claude-monitor  - Live dashboard for Claude Code instances"
    Write-Host "  - cmon alias      - Quick launch shortcut"

    Write-Host ""
    Write-Host "Quick Start:" -ForegroundColor Yellow
    Write-Host "  Live dashboard:      claude-monitor"
    Write-Host "  Single snapshot:     claude-monitor --once"
    Write-Host "  Custom interval:     claude-monitor --interval 10"
    Write-Host "  Quick alias:         cmon"

    Write-Host ""
    Write-Host "Restart your terminal or run: . `$PROFILE" -ForegroundColor Green
    Write-Host ""
}

# Main
function Main {
    Print-Header

    Install-UV
    Deploy-Monitor
    Warmup-Dependencies
    Configure-Shell

    Print-Completion
}

Main
