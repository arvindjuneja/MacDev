# ============================================
# Windows Development Setup
# ============================================
# One-stop script for setting up your Windows development environment
#
# Options:
#   1. Complete setup (Dev tools + Terminal + Multiplexer)
#   2. Development environment only
#   3. Terminal customization only
#   4. Multiplexer setup (Windows Terminal + optional WSL/tmux)
#   5. Claude Monitor
#   6. Verify Setup
#   7. Exit
#
# Usage: powershell -ExecutionPolicy Bypass -File setup-windows.ps1
# ============================================

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Print-Header {
    Clear-Host
    Write-Host ""
    Write-Host "+===========================================================" -ForegroundColor Magenta
    Write-Host "|                                                           |" -ForegroundColor Magenta
    Write-Host "|       Windows Development Environment Setup               |" -ForegroundColor Magenta
    Write-Host "|                                                           |" -ForegroundColor Magenta
    Write-Host "+===========================================================" -ForegroundColor Magenta
    Write-Host ""
}

function Print-Info { param([string]$Message) Write-Host $Message -ForegroundColor Cyan }
function Print-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Print-Error { param([string]$Message) Write-Host "[X] $Message" -ForegroundColor Red }
function Print-Warning { param([string]$Message) Write-Host "[!] $Message" -ForegroundColor Yellow }

function Show-Menu {
    Write-Host "What would you like to set up?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1) " -NoNewline; Write-Host "Full Setup" -ForegroundColor Green -NoNewline; Write-Host " - Dev tools + Terminal + Multiplexer"
    Write-Host "  2) " -NoNewline; Write-Host "Dev Environment Only" -ForegroundColor Blue -NoNewline; Write-Host " - Essential development tools"
    Write-Host "  3) " -NoNewline; Write-Host "Terminal Only" -ForegroundColor Magenta -NoNewline; Write-Host " - Beautiful terminal with Oh My Posh"
    Write-Host "  4) " -NoNewline; Write-Host "Multiplexer Only" -ForegroundColor Yellow -NoNewline; Write-Host " - Windows Terminal panes + optional WSL/tmux"
    Write-Host "  5) " -NoNewline; Write-Host "Claude Monitor" -ForegroundColor Magenta -NoNewline; Write-Host " - Live dashboard for Claude Code instances"
    Write-Host "  6) " -NoNewline; Write-Host "Verify Setup" -ForegroundColor Cyan -NoNewline; Write-Host " - Check what's already installed"
    Write-Host "  7) Exit"
    Write-Host ""
}

function Run-Script {
    param([string]$ScriptPath, [string]$Description)
    if (Test-Path $ScriptPath) {
        Print-Info "Starting $Description..."
        Write-Host ""
        & $ScriptPath
    } else {
        Print-Error "$ScriptPath not found!"
        exit 1
    }
}

function Main {
    Print-Header

    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Print-Error "Windows 10 or later is required."
        exit 1
    }
    Print-Info "Running on Windows $($osVersion.Major).$($osVersion.Minor) (Build $($osVersion.Build))"

    # Check execution policy
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -eq "Restricted") {
        Print-Warning "PowerShell execution policy is Restricted."
        Print-Info "Run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
        Print-Info "Then re-run this script."
        exit 1
    }

    Write-Host ""
    Show-Menu

    $choice = Read-Host "Enter your choice (1-7)"

    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "Full Setup Selected" -ForegroundColor Green
            Write-Host ""
            Run-Script "$ScriptDir\windows\setup-dev-env.ps1" "development environment setup"
            Write-Host ""
            Run-Script "$ScriptDir\windows\pimp-my-terminal.ps1" "terminal customization"
            Write-Host ""
            Run-Script "$ScriptDir\windows\setup-tmux.ps1" "multiplexer setup"
        }
        "2" {
            Write-Host ""
            Write-Host "Dev Environment Setup Selected" -ForegroundColor Blue
            Write-Host ""
            Run-Script "$ScriptDir\windows\setup-dev-env.ps1" "development environment setup"
        }
        "3" {
            Write-Host ""
            Write-Host "Terminal Customization Selected" -ForegroundColor Magenta
            Write-Host ""
            Run-Script "$ScriptDir\windows\pimp-my-terminal.ps1" "terminal customization"
        }
        "4" {
            Write-Host ""
            Write-Host "Multiplexer Setup Selected" -ForegroundColor Yellow
            Write-Host ""
            Run-Script "$ScriptDir\windows\setup-tmux.ps1" "multiplexer setup"
        }
        "5" {
            Write-Host ""
            Write-Host "Claude Monitor Setup Selected" -ForegroundColor Magenta
            Write-Host ""
            Run-Script "$ScriptDir\windows\setup-claude-monitor.ps1" "Claude Monitor setup"
        }
        "6" {
            Write-Host ""
            Run-Script "$ScriptDir\windows\verify-setup.ps1" "setup verification"
        }
        "7" {
            Write-Host ""
            Print-Info "Goodbye!"
            exit 0
        }
        default {
            Write-Host ""
            Print-Error "Invalid choice. Please run the script again."
            exit 1
        }
    }

    Write-Host ""
    Write-Host "+===========================================================" -ForegroundColor Green
    Write-Host "|              Setup Complete!                              |" -ForegroundColor Green
    Write-Host "+===========================================================" -ForegroundColor Green
    Write-Host ""
    Print-Info "Check the docs/ folder for detailed guides and documentation."
    Write-Host ""
}

Main
