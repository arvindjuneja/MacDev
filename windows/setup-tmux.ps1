# ============================================
# Terminal Multiplexer Setup (Windows)
# ============================================
# Sets up terminal multiplexing on Windows:
# - Windows Terminal pane/tab configuration
# - Optional WSL2 + tmux installation
# - btop system monitor
# - Dev session launcher (via wt CLI)
#
# Usage: powershell -ExecutionPolicy Bypass -File setup-tmux.ps1
# ============================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

function Print-Header {
    Write-Host ""
    Write-Host "+===========================================" -ForegroundColor Magenta
    Write-Host "|    TERMINAL MULTIPLEXER SETUP (Windows)   |" -ForegroundColor Magenta
    Write-Host "+===========================================" -ForegroundColor Magenta
    Write-Host ""
}

function Print-Step { param([string]$Message) Write-Host "`n>> $Message" -ForegroundColor Cyan }
function Print-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Print-Error { param([string]$Message) Write-Host "[X] $Message" -ForegroundColor Red }
function Print-Info { param([string]$Message) Write-Host "[i] $Message" -ForegroundColor Yellow }

# Ensure Windows Terminal is installed
function Ensure-WindowsTerminal {
    Print-Step "Checking Windows Terminal..."

    if (Get-Command wt -ErrorAction SilentlyContinue) {
        Print-Success "Windows Terminal is available"
    } else {
        Print-Info "Installing Windows Terminal via winget..."
        winget install --id Microsoft.WindowsTerminal --accept-source-agreements --accept-package-agreements
        Print-Success "Windows Terminal installed"
    }
}

# Install btop
function Install-Btop {
    Print-Step "Installing btop (system monitor)..."

    if (Get-Command btop -ErrorAction SilentlyContinue) {
        Print-Success "btop already installed"
    } else {
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Print-Info "Installing Scoop first..."
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        }
        Print-Info "Installing btop via scoop..."
        scoop install btop
        Print-Success "btop installed"
    }
}

# Offer WSL + tmux installation
function Install-WSL-Tmux {
    Print-Step "WSL + tmux Setup (Optional)"
    Write-Host ""
    Write-Host "  WSL (Windows Subsystem for Linux) lets you run Linux tools natively." -ForegroundColor Cyan
    Write-Host "  This includes tmux with the full Catppuccin Mocha theme from this project." -ForegroundColor Cyan
    Write-Host ""

    $reply = Read-Host "  Install WSL2 + tmux? (y/n)"

    if ($reply -notin @("y", "Y", "yes")) {
        Print-Info "Skipping WSL setup"
        return
    }

    # Check if WSL is already installed
    $wslInstalled = $false
    try {
        $wslOutput = wsl --status 2>&1
        if ($LASTEXITCODE -eq 0) {
            $wslInstalled = $true
        }
    } catch {}

    if ($wslInstalled) {
        Print-Success "WSL is already installed"
    } else {
        Print-Info "Installing WSL2 (requires admin privileges)..."
        Print-Info "You may be prompted for administrator access."

        # Check if running as admin
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if ($isAdmin) {
            wsl --install --no-launch
            Print-Success "WSL2 installed. A restart may be required."
        } else {
            Print-Info "Re-launching with admin privileges..."
            Start-Process powershell -Verb RunAs -ArgumentList "-Command", "wsl --install --no-launch"
            Print-Info "WSL2 installation started in admin window."
            Print-Info "Restart your computer, then re-run this script to continue setup."
            return
        }
    }

    # Check if Ubuntu is installed
    $distros = wsl --list --quiet 2>$null
    if ($distros -match "Ubuntu") {
        Print-Success "Ubuntu is installed in WSL"
    } else {
        Print-Info "Installing Ubuntu in WSL..."
        wsl --install -d Ubuntu --no-launch
        Print-Success "Ubuntu installed. Run 'wsl' to complete initial setup."
        Print-Info "After Ubuntu setup, re-run this script to install tmux inside WSL."
        return
    }

    # Install tmux inside WSL
    Print-Info "Installing tmux inside WSL..."
    wsl -d Ubuntu -- bash -c "sudo apt-get update && sudo apt-get install -y tmux"
    Print-Success "tmux installed in WSL"

    # Deploy tmux config to WSL
    $tmuxConfSrc = Join-Path $ProjectRoot "configs\tmux.conf"
    if (Test-Path $tmuxConfSrc) {
        $wslHome = wsl -d Ubuntu -- bash -c 'echo $HOME' 2>$null
        $wslHome = $wslHome.Trim()
        wsl -d Ubuntu -- bash -c "cp '$(wslpath -a $tmuxConfSrc)' '$wslHome/.tmux.conf'" 2>$null

        # Try direct file copy via \\wsl$ path
        $wslPath = "\\wsl$\Ubuntu$wslHome\.tmux.conf"
        try {
            Copy-Item $tmuxConfSrc $wslPath -Force -ErrorAction Stop
            Print-Success "tmux.conf deployed to WSL"
        } catch {
            # Fallback: use wsl command
            $tmuxContent = Get-Content $tmuxConfSrc -Raw
            $escapedContent = $tmuxContent -replace "'", "'\\''"
            wsl -d Ubuntu -- bash -c "cat > ~/.tmux.conf << 'TMUXEOF'
$tmuxContent
TMUXEOF"
            Print-Success "tmux.conf deployed to WSL (via pipe)"
        }
    }

    # Install TPM in WSL
    Print-Info "Installing TPM (Tmux Plugin Manager) in WSL..."
    wsl -d Ubuntu -- bash -c 'if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; fi'
    Print-Success "TPM installed in WSL"

    # Install btop in WSL
    wsl -d Ubuntu -- bash -c "sudo apt-get install -y btop 2>/dev/null || sudo snap install btop 2>/dev/null || true"
    Print-Info "btop installation attempted in WSL"
}

# Deploy dev-session script
function Deploy-DevSession {
    Print-Step "Setting up dev session launcher..."

    $sessionSrc = Join-Path $ScriptDir "dev-session.ps1"
    $binDir = Join-Path $env:USERPROFILE ".local\bin"

    if (-not (Test-Path $binDir)) {
        New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    }

    if (Test-Path $sessionSrc) {
        Copy-Item $sessionSrc (Join-Path $binDir "dev-session.ps1") -Force
        Print-Success "dev-session.ps1 installed to $binDir"
    } else {
        Print-Info "dev-session.ps1 not found, skipping"
    }

    # Add to PATH and create alias in profile
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileContent = ""
    if (Test-Path $profilePath) {
        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    }

    if ($profileContent -notmatch "=== Multiplexer Configuration ===") {
        $muxConfig = @'

# === Multiplexer Configuration ===
# Added by Windows multiplexer setup

# Dev session launcher (creates multi-pane Windows Terminal layout)
$devSessionBin = "$env:USERPROFILE\.local\bin"
if (Test-Path $devSessionBin) {
    $env:Path = "$devSessionBin;$env:Path"
}

function dev-session { & "$env:USERPROFILE\.local\bin\dev-session.ps1" @args }
Set-Alias -Name dev -Value dev-session -Force
Set-Alias -Name sc -Value dev-session -Force

# === End Multiplexer Configuration ===
'@
        $profileDir = Split-Path -Parent $profilePath
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        Add-Content -Path $profilePath -Value $muxConfig
        Print-Success "Shell aliases added to PowerShell profile"
    } else {
        Print-Success "Multiplexer config already exists in profile"
    }
}

# Print completion
function Print-Completion {
    Write-Host ""
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host "|     TERMINAL MULTIPLEXER SETUP COMPLETE!                 |" -ForegroundColor Green
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "What's installed:" -ForegroundColor Cyan
    Write-Host "  - Windows Terminal - Modern terminal with built-in panes"
    Write-Host "  - btop             - Beautiful system monitor"
    Write-Host "  - dev-session      - Multi-pane layout launcher"

    $wslCheck = wsl --status 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  - WSL2 + tmux     - Linux terminal multiplexer"
        Write-Host "  - TPM             - Tmux Plugin Manager"
        Write-Host "  - Catppuccin      - Beautiful Mocha color theme"
    }

    Write-Host ""
    Write-Host "Quick Start:" -ForegroundColor Yellow
    Write-Host "  Start a dev session:     dev-session"
    Write-Host "  Start with project:      dev-session C:\path\to\project"
    Write-Host "  System monitor:          btop"

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "WSL tmux:" -ForegroundColor Yellow
        Write-Host "  Start tmux in WSL:       wsl -d Ubuntu -- tmux"
        Write-Host "  Prefix key:              Ctrl+a"
        Write-Host "  Install plugins:         Ctrl+a then I (capital I)"
    }

    Write-Host ""
    Write-Host "Windows Terminal Shortcuts:" -ForegroundColor Magenta
    Write-Host "  +----------------------------------------------------+"
    Write-Host "  |  Alt+Shift+D     Split pane (auto direction)       |"
    Write-Host "  |  Alt+Shift+-     Split pane horizontally           |"
    Write-Host "  |  Alt+Shift++     Split pane vertically             |"
    Write-Host "  |  Alt+arrows      Navigate between panes            |"
    Write-Host "  |  Ctrl+Shift+W    Close pane                        |"
    Write-Host "  |  Ctrl+Shift+T    New tab                           |"
    Write-Host "  |  Ctrl+Alt+arrows Resize pane                       |"
    Write-Host "  +----------------------------------------------------+"

    Write-Host ""
    Write-Host "Restart your terminal or run: . `$PROFILE" -ForegroundColor Green
    Write-Host ""
}

# Main
function Main {
    Print-Header

    Ensure-WindowsTerminal
    Install-Btop
    Install-WSL-Tmux
    Deploy-DevSession

    Print-Completion
}

Main
