# ============================================
# Windows Development Environment Setup
# ============================================
# Installs essential development tools for Windows:
# - Scoop (package manager)
# - Git (via winget)
# - Python (via pyenv-win)
# - Node.js & npm (via winget)
# - Common utilities (via scoop)
#
# Usage: powershell -ExecutionPolicy Bypass -File setup-dev-env.ps1
# ============================================

$ErrorActionPreference = "Stop"

function Print-Header {
    Write-Host ""
    Write-Host "+===========================================" -ForegroundColor Blue
    Write-Host "|   Development Environment Setup           |" -ForegroundColor Blue
    Write-Host "+===========================================" -ForegroundColor Blue
    Write-Host ""
}

function Print-Step { param([string]$Message) Write-Host "`n>> $Message" -ForegroundColor Cyan }
function Print-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Print-Error { param([string]$Message) Write-Host "[X] $Message" -ForegroundColor Red }
function Print-Info { param([string]$Message) Write-Host "[i] $Message" -ForegroundColor Yellow }

# Install Scoop
function Install-Scoop {
    Print-Step "Installing Scoop (package manager)..."

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Print-Success "Scoop already installed"
        Print-Info "Updating Scoop..."
        scoop update
    } else {
        Print-Info "Installing Scoop..."
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        # Add extras bucket for additional packages
        scoop bucket add extras
        Print-Success "Scoop installed successfully"
    }
}

# Ensure winget is available
function Ensure-Winget {
    Print-Step "Checking winget..."

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Print-Success "winget is available"
    } else {
        Print-Error "winget is not available. It should be pre-installed on Windows 10/11."
        Print-Info "Install 'App Installer' from the Microsoft Store if missing."
        throw "winget not found"
    }
}

# Install Git
function Install-Git {
    Print-Step "Installing Git..."

    if (Get-Command git -ErrorAction SilentlyContinue) {
        $version = git --version
        Print-Success "Git already installed: $version"
    } else {
        Print-Info "Installing Git via winget..."
        winget install --id Git.Git --accept-source-agreements --accept-package-agreements
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Print-Success "Git installed successfully"
    }
}

# Install Python via pyenv-win
function Install-Python {
    Print-Step "Installing Python (via pyenv-win)..."

    # Install pyenv-win
    if (Get-Command pyenv -ErrorAction SilentlyContinue) {
        Print-Success "pyenv-win already installed"
    } else {
        Print-Info "Installing pyenv-win via scoop..."
        scoop install pyenv
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Print-Success "pyenv-win installed"
    }

    # Install Python 3.11
    Print-Info "Installing Python 3.11..."
    $installedVersions = pyenv versions 2>&1
    if ($installedVersions -match "3\.11") {
        Print-Success "Python 3.11 already installed"
    } else {
        pyenv install 3.11.9
        pyenv global 3.11.9
        Print-Success "Python 3.11 installed and set as global"
    }

    # Install essential pip packages
    Print-Info "Installing essential Python packages..."
    python -m pip install --upgrade pip 2>$null
    python -m pip install virtualenv ipython requests 2>$null
    Print-Success "Essential Python packages installed"
}

# Install Node.js
function Install-Node {
    Print-Step "Installing Node.js..."

    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        $npmVersion = npm --version
        Print-Success "Node.js already installed: $nodeVersion"
        Print-Success "npm already installed: $npmVersion"
    } else {
        Print-Info "Installing Node.js via winget..."
        winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Print-Success "Node.js and npm installed successfully"
    }

    # Setup npm global directory
    Print-Info "Configuring npm global directory..."
    $npmGlobal = Join-Path $env:USERPROFILE ".npm-global"
    if (-not (Test-Path $npmGlobal)) {
        New-Item -ItemType Directory -Path $npmGlobal -Force | Out-Null
    }
    npm config set prefix $npmGlobal
    Print-Success "npm configured"
}

# Install common utilities
function Install-Utilities {
    Print-Step "Installing common utilities..."

    $tools = @("jq", "wget", "curl", "btop", "tree")

    foreach ($tool in $tools) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) {
            Print-Success "$tool already installed"
        } elseif ((scoop list $tool 2>$null) -match $tool) {
            Print-Success "$tool already installed (via scoop)"
        } else {
            Print-Info "Installing $tool..."
            scoop install $tool
            Print-Success "$tool installed"
        }
    }
}

# Configure PowerShell profile
function Configure-Shell {
    Print-Step "Configuring PowerShell profile..."

    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path -Parent $profilePath

    # Ensure profile directory exists
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    # Backup existing profile if it exists
    if (Test-Path $profilePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backup = "$profilePath.backup.devenv.$timestamp"
        Print-Info "Backing up existing profile to $backup"
        Copy-Item $profilePath $backup
    }

    # Check if dev env config already exists
    $profileContent = ""
    if (Test-Path $profilePath) {
        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    }

    if ($profileContent -notmatch "=== Development Environment Setup ===") {
        $devConfig = @'

# === Development Environment Setup ===
# Added by Windows dev setup script

# pyenv-win for Python version management
if (Get-Command pyenv -ErrorAction SilentlyContinue) {
    $env:PYENV = "$env:USERPROFILE\.pyenv\pyenv-win"
    $env:Path = "$env:PYENV\bin;$env:PYENV\shims;$env:Path"
}

# Node.js npm global
$npmGlobal = "$env:USERPROFILE\.npm-global"
if (Test-Path $npmGlobal) {
    $env:Path = "$npmGlobal;$env:Path"
}

# Aliases
Set-Alias -Name python3 -Value python -ErrorAction SilentlyContinue
Set-Alias -Name pip3 -Value pip -ErrorAction SilentlyContinue

# === End Development Environment Setup ===
'@
        Add-Content -Path $profilePath -Value $devConfig
        Print-Success "PowerShell profile updated"
    } else {
        Print-Success "Development environment configuration already exists in profile"
    }
}

# Print completion message
function Print-Completion {
    Write-Host ""
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host "|     [OK]  Development Environment Setup Complete!        |" -ForegroundColor Green
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "Installed Tools:" -ForegroundColor Cyan
    Write-Host "  - Scoop - Package manager"
    Write-Host "  - winget - Microsoft package manager"
    Write-Host "  - Git - Version control"
    Write-Host "  - Python 3.11 (via pyenv-win) - Programming language"
    Write-Host "  - pip - Python package manager"
    Write-Host "  - Node.js - JavaScript runtime"
    Write-Host "  - npm - Node package manager"
    Write-Host "  - jq, wget, curl, btop, tree - Utilities"

    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart your terminal or run: . `$PROFILE"
    Write-Host "  2. Verify installation: run verify-setup.ps1"
    Write-Host "  3. Start developing!"
    Write-Host ""
}

# Main installation flow
function Main {
    Print-Header

    Write-Host "This script will install essential development tools on your Windows machine."
    Write-Host ""
    $reply = Read-Host "Continue? (y/n)"

    if ($reply -notin @("y", "Y", "yes")) {
        Print-Error "Installation cancelled"
        exit 1
    }

    Ensure-Winget
    Install-Scoop
    Install-Git
    Install-Python
    Install-Node
    Install-Utilities
    Configure-Shell

    Print-Completion
}

Main
