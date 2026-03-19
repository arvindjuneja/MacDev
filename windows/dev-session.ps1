# ============================================
# Dev Session - Windows Terminal multi-pane layout
# ============================================
# Creates a pre-configured Windows Terminal layout with:
#   - Left (65%): Claude Code
#   - Top-right: Dev server pane
#   - Bottom-right: System monitor (btop)
#
# Uses the Windows Terminal CLI (wt.exe) to create split panes.
#
# Usage:
#   dev-session                          # uses current dir
#   dev-session C:\path\to\project       # uses given path
#
# Aliases (add to profile):
#   Set-Alias -Name sc -Value dev-session
# ============================================

param(
    [Parameter(Position = 0)]
    [string]$ProjectPath = (Get-Location).Path
)

# Resolve to absolute path
if ($ProjectPath -and (Test-Path $ProjectPath)) {
    $ProjectPath = (Resolve-Path $ProjectPath).Path
}

$ProjectName = Split-Path -Leaf $ProjectPath

# Colors
function Print-Info { param([string]$Message) Write-Host $Message -ForegroundColor Cyan }
function Print-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }

# Check if Windows Terminal is installed
if (-not (Get-Command wt -ErrorAction SilentlyContinue)) {
    Write-Host "Windows Terminal (wt) is not installed." -ForegroundColor Yellow
    Write-Host "Install it via: winget install Microsoft.WindowsTerminal" -ForegroundColor Yellow
    exit 1
}

# Determine monitor command
$monitorCmd = "echo System monitor pane"
if (Get-Command btop -ErrorAction SilentlyContinue) {
    $monitorCmd = "btop"
} elseif (Get-Command htop -ErrorAction SilentlyContinue) {
    $monitorCmd = "htop"
}

# Determine claude-monitor command
$claudeMonitorCmd = ""
if (Get-Command claude-monitor -ErrorAction SilentlyContinue) {
    $claudeMonitorCmd = "claude-monitor --compact"
}

Print-Info "Starting dev session: $ProjectName"
Print-Info "Project directory:    $ProjectPath"
Write-Host ""

# ┌────────────────────────┬──────────────────┐
# │                        │   Dev Server     │
# │    Claude Code         │                  │
# │    (65% width)         ├──────────────────┤
# │                        │   Monitor        │
# │                        │   (btop)         │
# └────────────────────────┴──────────────────┘
#         65% width              35% width

# Build the wt command
# Windows Terminal CLI uses semicolons to separate pane commands
# split-pane -H splits horizontally (side by side), -V splits vertically (top/bottom)

$wtArgs = @(
    "--title", $ProjectName,
    "-d", $ProjectPath,
    "powershell", "-NoExit", "-Command", "cd '$ProjectPath'; Write-Host 'Claude Code pane - run: claude' -ForegroundColor Cyan"
)

# Add right pane (35% width) - dev server
$wtArgs += @(
    ";", "split-pane", "-H", "--size", "0.35",
    "-d", $ProjectPath,
    "powershell", "-NoExit", "-Command", "cd '$ProjectPath'; Write-Host 'Dev server pane - run your server here (e.g., npm run dev)' -ForegroundColor Cyan"
)

# Split right pane vertically for monitor (bottom-right)
$wtArgs += @(
    ";", "split-pane", "-V", "--size", "0.5",
    "-d", $ProjectPath,
    "powershell", "-NoExit", "-Command", "$monitorCmd"
)

# If claude-monitor is available, split left pane for it (bottom-left)
if ($claudeMonitorCmd) {
    $wtArgs += @(
        ";", "move-focus", "left",
        ";", "split-pane", "-V", "--size", "0.2",
        "-d", $ProjectPath,
        "powershell", "-NoExit", "-Command", "$claudeMonitorCmd"
    )
}

# Focus on the first (Claude Code) pane
$wtArgs += @(";", "focus-tab", "-t", "0")

Print-Success "Launching Windows Terminal layout..."
Start-Process wt -ArgumentList $wtArgs
