# ============================================
# Development Environment Verification (Windows)
# ============================================
# Checks that all development tools are installed correctly
# Usage: powershell -ExecutionPolicy Bypass -File verify-setup.ps1
# ============================================

Write-Host "Verifying Development Environment..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allOk = $true
$issues = @()

function Check-Command {
    param(
        [string]$Command,
        [string]$Name,
        [string]$VersionFlag = "--version"
    )

    try {
        $result = & $Command $VersionFlag 2>&1 | Select-Object -First 1
        Write-Host "[OK] ${Name}: $result" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[X] ${Name}: Not found" -ForegroundColor Red
        $script:issues += "$Name is not installed"
        $script:allOk = $false
        return $false
    }
}

function Check-CommandExists {
    param(
        [string]$Command,
        [string]$Name
    )

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        $version = & $Command --version 2>&1 | Select-Object -First 1
        Write-Host "[OK] ${Name}: $version" -ForegroundColor Green
        return $true
    } else {
        Write-Host "[X] ${Name}: Not found" -ForegroundColor Red
        $script:issues += "$Name is not installed"
        $script:allOk = $false
        return $false
    }
}

# === Package Managers ===
Write-Host "Package Managers:" -ForegroundColor Blue
Write-Host "-----------------"

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "[OK] winget: Available" -ForegroundColor Green
} else {
    Write-Host "[X] winget: Not found" -ForegroundColor Red
    $issues += "winget is not available - Install 'App Installer' from Microsoft Store"
    $allOk = $false
}

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Scoop: Available" -ForegroundColor Green
} else {
    Write-Host "[X] Scoop: Not found" -ForegroundColor Red
    $issues += "Scoop is not installed"
    $allOk = $false
}

# === Core Development Tools ===
Write-Host ""
Write-Host "Core Development Tools:" -ForegroundColor Blue
Write-Host "-----------------------"

Check-CommandExists "git" "Git" | Out-Null
Check-CommandExists "python" "Python" | Out-Null
Check-CommandExists "pip" "pip" | Out-Null

if (Get-Command pyenv -ErrorAction SilentlyContinue) {
    Write-Host "[OK] pyenv-win: Available" -ForegroundColor Green
} else {
    Write-Host "[!] pyenv-win: Not installed (run setup-dev-env.ps1)" -ForegroundColor Yellow
}

Check-CommandExists "node" "Node.js" | Out-Null
Check-CommandExists "npm" "npm" | Out-Null

# === Utilities ===
Write-Host ""
Write-Host "Utilities:" -ForegroundColor Blue
Write-Host "----------"

$utils = @("tree", "jq", "wget", "curl")
foreach ($util in $utils) {
    if (Get-Command $util -ErrorAction SilentlyContinue) {
        Write-Host "[OK] ${util}: Available" -ForegroundColor Green
    } else {
        Write-Host "[!] ${util}: Not installed (optional)" -ForegroundColor Yellow
    }
}

# === Terminal Customization ===
Write-Host ""
Write-Host "Terminal Customization:" -ForegroundColor Blue
Write-Host "------------------------"

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $ompVersion = oh-my-posh --version 2>&1
    Write-Host "[OK] Oh My Posh: $ompVersion" -ForegroundColor Green
} else {
    Write-Host "[!] Oh My Posh: Not installed (run pimp-my-terminal.ps1)" -ForegroundColor Yellow
}

# Check Oh My Posh theme
$ompTheme = Join-Path $env:USERPROFILE ".config\oh-my-posh\catppuccin-mocha.omp.json"
if (Test-Path $ompTheme) {
    Write-Host "[OK] Catppuccin Mocha theme: Found" -ForegroundColor Green
} else {
    Write-Host "[!] Catppuccin Mocha theme: Not deployed (run pimp-my-terminal.ps1)" -ForegroundColor Yellow
}

if (Get-Module -ListAvailable -Name PSReadLine) {
    $prlVersion = (Get-Module -ListAvailable -Name PSReadLine | Select-Object -First 1).Version
    Write-Host "[OK] PSReadLine: $prlVersion" -ForegroundColor Green
} else {
    Write-Host "[!] PSReadLine: Not found" -ForegroundColor Yellow
}

if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Write-Host "[OK] Terminal-Icons: Installed" -ForegroundColor Green
} else {
    Write-Host "[!] Terminal-Icons: Not installed (run pimp-my-terminal.ps1)" -ForegroundColor Yellow
}

# Modern CLI tools
Write-Host ""
Write-Host "Modern CLI Tools (Optional):" -ForegroundColor Blue
Write-Host "-----------------------------"

$cliTools = @(
    @{ Name = "eza"; Desc = "modern ls" },
    @{ Name = "bat"; Desc = "better cat" },
    @{ Name = "fzf"; Desc = "fuzzy finder" },
    @{ Name = "fd"; Desc = "faster find" }
)

foreach ($tool in $cliTools) {
    if (Get-Command $tool.Name -ErrorAction SilentlyContinue) {
        Write-Host "[OK] $($tool.Name) ($($tool.Desc)): Available" -ForegroundColor Green
    } else {
        Write-Host "[!] $($tool.Name) ($($tool.Desc)): Not installed (optional)" -ForegroundColor Yellow
    }
}

# === Multiplexer ===
Write-Host ""
Write-Host "Terminal Multiplexer:" -ForegroundColor Blue
Write-Host "---------------------"

if (Get-Command wt -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Windows Terminal: Available" -ForegroundColor Green
} else {
    Write-Host "[!] Windows Terminal: Not installed (run setup-tmux.ps1)" -ForegroundColor Yellow
}

if (Get-Command btop -ErrorAction SilentlyContinue) {
    Write-Host "[OK] btop: Available" -ForegroundColor Green
} else {
    Write-Host "[!] btop: Not installed (run setup-tmux.ps1)" -ForegroundColor Yellow
}

# Check dev-session
$devSessionPath = Join-Path $env:USERPROFILE ".local\bin\dev-session.ps1"
if (Test-Path $devSessionPath) {
    Write-Host "[OK] dev-session: Available" -ForegroundColor Green
} else {
    Write-Host "[!] dev-session: Not installed (run setup-tmux.ps1)" -ForegroundColor Yellow
}

# Check WSL
try {
    $wslCheck = wsl --status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] WSL: Installed" -ForegroundColor Green

        # Check tmux in WSL
        $tmuxCheck = wsl -d Ubuntu -- which tmux 2>$null
        if ($tmuxCheck) {
            Write-Host "[OK] tmux (WSL): Available" -ForegroundColor Green
        } else {
            Write-Host "[!] tmux (WSL): Not installed (run setup-tmux.ps1)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[!] WSL: Not installed (optional)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] WSL: Not installed (optional)" -ForegroundColor Yellow
}

# === Claude Monitor ===
Write-Host ""
Write-Host "Claude Code Monitor:" -ForegroundColor Blue
Write-Host "---------------------"

if (Get-Command uv -ErrorAction SilentlyContinue) {
    $uvVersion = uv --version 2>&1
    Write-Host "[OK] uv: $uvVersion" -ForegroundColor Green
} else {
    Write-Host "[!] uv: Not installed (run setup-claude-monitor.ps1)" -ForegroundColor Yellow
}

$monitorPath = Join-Path $env:USERPROFILE ".local\bin\claude-monitor.cmd"
if (Test-Path $monitorPath) {
    Write-Host "[OK] claude-monitor: Available" -ForegroundColor Green
} else {
    Write-Host "[!] claude-monitor: Not installed (run setup-claude-monitor.ps1)" -ForegroundColor Yellow
}

# === Shell Configuration ===
Write-Host ""
Write-Host "Shell Configuration:" -ForegroundColor Blue
Write-Host "---------------------"

$profilePath = $PROFILE.CurrentUserAllHosts
if (Test-Path $profilePath) {
    Write-Host "[OK] PowerShell profile: Found" -ForegroundColor Green

    $content = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($content -match "Development Environment Setup") {
        Write-Host "[OK] Dev environment: Configured in profile" -ForegroundColor Green
    } else {
        Write-Host "[!] Dev environment: Not configured (run setup-dev-env.ps1)" -ForegroundColor Yellow
    }

    if ($content -match "Terminal Customization") {
        Write-Host "[OK] Terminal customization: Configured in profile" -ForegroundColor Green
    } else {
        Write-Host "[!] Terminal customization: Not configured (run pimp-my-terminal.ps1)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] PowerShell profile: Not found" -ForegroundColor Yellow
    $issues += "PowerShell profile not found"
}

# === Summary ===
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "[OK] All core tools are installed correctly!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your development environment is ready!" -ForegroundColor Green
} else {
    Write-Host "[X] Some tools are missing or not configured properly." -ForegroundColor Red
    Write-Host ""
    Write-Host "Issues found:" -ForegroundColor Yellow
    foreach ($issue in $issues) {
        Write-Host "  - $issue"
    }
    Write-Host ""
    Write-Host "Recommended actions:" -ForegroundColor Yellow
    Write-Host "  1. Run: .\setup-windows.ps1"
    Write-Host "  2. Or install missing tools individually"
}

Write-Host ""
