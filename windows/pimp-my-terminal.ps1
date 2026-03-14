# ============================================
# PIMP MY TERMINAL - Windows Setup Script
# ============================================
# Installs and configures a modern, beautiful terminal on Windows:
# - Oh My Posh (prompt theme engine)
# - PSReadLine (autosuggestions + syntax highlighting)
# - Modern CLI tools (eza, bat, fzf, fd)
# - Terminal-Icons module
# - Windows Terminal Catppuccin theme
#
# Usage: powershell -ExecutionPolicy Bypass -File pimp-my-terminal.ps1
# ============================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Print-Header {
    Write-Host ""
    Write-Host "+===========================================" -ForegroundColor Magenta
    Write-Host "|     PIMP MY TERMINAL SETUP                |" -ForegroundColor Magenta
    Write-Host "+===========================================" -ForegroundColor Magenta
    Write-Host ""
}

function Print-Step { param([string]$Message) Write-Host "`n>> $Message" -ForegroundColor Cyan }
function Print-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Print-Error { param([string]$Message) Write-Host "[X] $Message" -ForegroundColor Red }
function Print-Info { param([string]$Message) Write-Host "[i] $Message" -ForegroundColor Yellow }

# Ensure Scoop is available
function Ensure-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Print-Info "Installing Scoop (needed for CLI tools)..."
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        scoop bucket add extras
    }
}

# Install Oh My Posh
function Install-OhMyPosh {
    Print-Step "Installing Oh My Posh..."

    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Print-Success "Oh My Posh already installed"
    } else {
        Print-Info "Installing Oh My Posh via winget..."
        winget install --id JanDeDobbeleer.OhMyPosh --accept-source-agreements --accept-package-agreements
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Print-Success "Oh My Posh installed successfully"
    }

    # Deploy Catppuccin Mocha theme
    $themeDir = Join-Path $env:USERPROFILE ".config\oh-my-posh"
    if (-not (Test-Path $themeDir)) {
        New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
    }

    $themeSrc = Join-Path $ScriptDir "configs\oh-my-posh-theme.json"
    $themeDest = Join-Path $themeDir "catppuccin-mocha.omp.json"

    if (Test-Path $themeSrc) {
        Copy-Item $themeSrc $themeDest -Force
        Print-Success "Catppuccin Mocha theme deployed to $themeDest"
    } else {
        Print-Error "Theme file not found at $themeSrc"
    }
}

# Install and configure PSReadLine
function Configure-PSReadLine {
    Print-Step "Configuring PSReadLine (autosuggestions + highlighting)..."

    # PSReadLine ships with PowerShell 5.1+, but update to latest
    $currentVersion = (Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
    Print-Info "Current PSReadLine version: $currentVersion"

    try {
        Install-Module PSReadLine -Force -AllowPrerelease -Scope CurrentUser -ErrorAction SilentlyContinue
        Print-Success "PSReadLine updated"
    } catch {
        Print-Info "PSReadLine is up to date or update skipped"
    }
}

# Install Terminal-Icons module
function Install-TerminalIcons {
    Print-Step "Installing Terminal-Icons (file icons in directory listings)..."

    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Print-Success "Terminal-Icons already installed"
    } else {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
        Print-Success "Terminal-Icons installed"
    }
}

# Install modern CLI tools via Scoop
function Install-CLITools {
    Print-Step "Installing modern CLI tools..."

    Ensure-Scoop

    $tools = @(
        @{ Name = "eza"; Desc = "modern ls replacement" },
        @{ Name = "bat"; Desc = "better cat with syntax highlighting" },
        @{ Name = "fzf"; Desc = "fuzzy finder" },
        @{ Name = "fd";  Desc = "faster find" }
    )

    foreach ($tool in $tools) {
        if (Get-Command $tool.Name -ErrorAction SilentlyContinue) {
            Print-Success "$($tool.Name) already installed ($($tool.Desc))"
        } else {
            Print-Info "Installing $($tool.Name) ($($tool.Desc))..."
            scoop install $tool.Name
            Print-Success "$($tool.Name) installed"
        }
    }
}

# Install a Nerd Font for icon support
function Install-NerdFont {
    Print-Step "Installing Nerd Font (for icons and glyphs)..."

    # Check if scoop nerd-fonts bucket exists
    $buckets = scoop bucket list 2>$null
    if ($buckets -notmatch "nerd-fonts") {
        scoop bucket add nerd-fonts
    }

    # Install CaskaydiaCove Nerd Font (recommended for Windows Terminal)
    $fontName = "CascadiaCode-NF"
    $installed = scoop list $fontName 2>$null
    if ($installed -match $fontName) {
        Print-Success "CascadiaCode Nerd Font already installed"
    } else {
        Print-Info "Installing CascadiaCode Nerd Font..."
        scoop install $fontName
        Print-Success "CascadiaCode Nerd Font installed"
    }
}

# Deploy Windows Terminal color scheme
function Deploy-TerminalSettings {
    Print-Step "Deploying Windows Terminal Catppuccin theme..."

    $settingsSrc = Join-Path $ScriptDir "configs\windows-terminal-settings.json"
    if (-not (Test-Path $settingsSrc)) {
        Print-Info "Windows Terminal settings fragment not found, skipping"
        return
    }

    # Windows Terminal settings location
    $wtSettingsDir = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $wtSettingsPath = Join-Path $wtSettingsDir "settings.json"

    if (-not (Test-Path $wtSettingsPath)) {
        # Try Windows Terminal Preview
        $wtSettingsDir = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState"
        $wtSettingsPath = Join-Path $wtSettingsDir "settings.json"
    }

    if (Test-Path $wtSettingsPath) {
        # Backup existing settings
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Copy-Item $wtSettingsPath "$wtSettingsPath.backup.$timestamp"
        Print-Info "Windows Terminal settings backed up"

        # Read and merge color scheme
        try {
            $wtSettings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json
            $catppuccin = Get-Content $settingsSrc -Raw | ConvertFrom-Json

            # Add color scheme if not already present
            if (-not $wtSettings.schemes) {
                $wtSettings | Add-Member -NotePropertyName "schemes" -NotePropertyValue @()
            }

            $existingScheme = $wtSettings.schemes | Where-Object { $_.name -eq "Catppuccin Mocha" }
            if (-not $existingScheme) {
                $wtSettings.schemes += $catppuccin.scheme
                $wtSettings | ConvertTo-Json -Depth 10 | Set-Content $wtSettingsPath
                Print-Success "Catppuccin Mocha color scheme added to Windows Terminal"
            } else {
                Print-Success "Catppuccin Mocha scheme already exists in Windows Terminal"
            }
        } catch {
            Print-Info "Could not auto-merge settings. See windows/configs/ for manual import."
        }
    } else {
        Print-Info "Windows Terminal settings not found. Install Windows Terminal first."
        Print-Info "Color scheme saved to: $settingsSrc"
    }
}

# Create PowerShell profile
function Create-Profile {
    Print-Step "Creating PowerShell profile..."

    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path -Parent $profilePath

    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    # Backup existing profile
    if (Test-Path $profilePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Copy-Item $profilePath "$profilePath.backup.terminal.$timestamp"
        Print-Info "Existing profile backed up"
    }

    # Check if terminal config already exists
    $existingContent = ""
    if (Test-Path $profilePath) {
        $existingContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    }

    if ($existingContent -notmatch "=== Terminal Customization ===") {
        $terminalConfig = @'

# === Terminal Customization ===
# Added by Windows terminal setup script

# Oh My Posh prompt
$ompTheme = "$env:USERPROFILE\.config\oh-my-posh\catppuccin-mocha.omp.json"
if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $ompTheme)) {
    oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
}

# PSReadLine configuration (autosuggestions + history)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
}

# Terminal-Icons
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# FZF integration
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --margin=1 --padding=1"
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
    }
}

# === Modern CLI Aliases ===
# eza (modern ls)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls_eza { eza --icons --group-directories-first @args }
    Set-Alias -Name ls -Value ls_eza -Force -Option AllScope
    function la_eza { eza --icons --group-directories-first -a @args }
    Set-Alias -Name la -Value la_eza -Force
    function ll_eza { eza --icons --group-directories-first -lh @args }
    Set-Alias -Name ll -Value ll_eza -Force
    function lla_eza { eza --icons --group-directories-first -lha @args }
    Set-Alias -Name lla -Value lla_eza -Force
    function lt_eza { eza --icons --group-directories-first --tree @args }
    Set-Alias -Name lt -Value lt_eza -Force
}

# bat (better cat)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat_bat { bat --paging=never @args }
    Set-Alias -Name cat -Value cat_bat -Force -Option AllScope
}

# Git shortcuts
function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline --graph --decorate --all @args }
function gd { git diff @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# System
function c { Clear-Host }
Set-Alias -Name h -Value Get-History -Force

# Custom Functions
function mkcd { param([string]$dir) New-Item -ItemType Directory -Path $dir -Force | Out-Null; Set-Location $dir }
function search { param([string]$pattern) Get-ChildItem -Recurse | Select-String $pattern }

# Git commit all and push
function gcap { param([string]$message) git add .; git commit -m $message; git push }

# === End Terminal Customization ===
'@
        Add-Content -Path $profilePath -Value $terminalConfig
        Print-Success "Terminal configuration added to PowerShell profile"
    } else {
        Print-Success "Terminal configuration already exists in profile"
    }
}

# Print completion message
function Print-Completion {
    Write-Host ""
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host "|     TERMINAL PIMPING COMPLETE!                           |" -ForegroundColor Green
    Write-Host "+==========================================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "What's installed:" -ForegroundColor Cyan
    Write-Host "  - Oh My Posh - Beautiful prompt themes"
    Write-Host "  - PSReadLine - Autosuggestions + history predictions"
    Write-Host "  - Terminal-Icons - File icons in listings"
    Write-Host "  - eza - Modern ls with icons"
    Write-Host "  - bat - Better cat with syntax highlighting"
    Write-Host "  - fzf - Fuzzy finder (Ctrl+R for history)"
    Write-Host "  - fd - Faster find"
    Write-Host "  - CascadiaCode Nerd Font - Icon support"
    Write-Host "  - Catppuccin Mocha - Color theme"

    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart your terminal or run: . `$PROFILE"
    Write-Host "  2. Set 'CaskaydiaCove Nerd Font' as your terminal font"
    Write-Host "  3. In Windows Terminal: Settings > Color scheme > Catppuccin Mocha"
    Write-Host "  4. Try: ll, cat `$PROFILE, Ctrl+R, or use Tab for completions"

    Write-Host ""
    Write-Host "Pro tips:" -ForegroundColor Magenta
    Write-Host "  - Press Tab for menu-style completions"
    Write-Host "  - Use Up/Down arrows for history search"
    Write-Host "  - PSReadLine shows inline predictions from history"
    Write-Host "  - Type 'lt' for tree view of directories"
    Write-Host ""
}

# Main
function Main {
    Print-Header

    Install-OhMyPosh
    Configure-PSReadLine
    Install-TerminalIcons
    Install-CLITools
    Install-NerdFont
    Deploy-TerminalSettings
    Create-Profile

    Print-Completion
}

Main
