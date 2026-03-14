# 🚀 macOS & Windows Development Setup

Complete, automated setup for macOS and Windows development environments. Get up and running with essential dev tools, a beautiful terminal, tmux workflow, and a live Claude Code monitoring dashboard.

## ✨ What This Does

This repository provides automated scripts to set up a complete development environment on macOS, including:

### 🛠️ Development Tools
- **Homebrew** - Package manager for macOS
- **Git** - Version control
- **Python 3.11** with pyenv - Python version management
- **Node.js & npm** - JavaScript runtime and package manager
- **Common utilities** - tree, jq, wget, curl, htop

### 🎨 Terminal Customization
- **Oh My Zsh** - Powerful zsh framework
- **Powerlevel10k** - Beautiful terminal theme
- **zsh plugins** - Autosuggestions, syntax highlighting, and more
- **Modern CLI tools** - eza, bat, fzf, fd, thefuck

### 🖥️ Terminal Multiplexer (tmux)
- **tmux** with Catppuccin Mocha theme
- **TPM** - Tmux Plugin Manager
- **tmux-resurrect** & **tmux-continuum** - Session persistence
- **btop** - Beautiful system monitor
- **dev-session** - Pre-configured Claude Code workflow layout

### 📊 Claude Code Monitor
- **Live TUI dashboard** for tracking Claude Code CLI instances
- Active instance tracking (PID, CPU%, uptime, project)
- Today's message/session counts from `history.jsonl`
- Lifetime token usage by model from `stats-cache.json`
- Recent activity feed with timestamps
- Catppuccin Mocha colors, flicker-free 5s refresh via `rich`

## 🚀 Quick Start

### One-Command Setup

```bash
./setup-macos.sh
```

This launches an interactive menu:

1. **Full Setup** - Dev tools + Terminal + tmux
2. **Dev Environment Only** - Essential development tools
3. **Terminal Only** - Terminal beautification
4. **Multiplexer Only** - tmux with Catppuccin theme + dev sessions
5. **Claude Monitor** - Live dashboard for Claude Code instances
6. **Verify Setup** - Check what's already installed
7. **Exit**

## 🪟 Windows Setup

### One-Command Setup

```powershell
powershell -ExecutionPolicy Bypass -File setup-windows.ps1
```

Same interactive menu, adapted for Windows:

1. **Full Setup** - Dev tools + Terminal + Multiplexer
2. **Dev Environment Only** - Git, Python (pyenv-win), Node.js, utilities via winget + scoop
3. **Terminal Only** - Oh My Posh + PSReadLine + modern CLI tools + Catppuccin theme
4. **Multiplexer Only** - Windows Terminal panes + optional WSL2/tmux
5. **Claude Monitor** - Live dashboard for Claude Code instances
6. **Verify Setup** - Check what's already installed

### Windows Equivalents

| macOS | Windows |
|-------|---------|
| Homebrew | winget + scoop |
| Oh My Zsh + Powerlevel10k | Oh My Posh + Catppuccin theme |
| zsh-autosuggestions | PSReadLine PredictiveIntelliSense |
| zsh-syntax-highlighting | PSReadLine inline predictions |
| tmux | Windows Terminal panes + optional WSL/tmux |
| .zshrc | PowerShell $PROFILE |

### Windows Prerequisites

- Windows 10 or later
- PowerShell 5.1+ (pre-installed)
- Internet connection
- winget (pre-installed on Windows 10/11)

## 📋 macOS Prerequisites

- macOS 11.0 or later
- Terminal with zsh (default on modern macOS)
- Internet connection
- Admin privileges (for Homebrew installation)

## 📁 Repository Structure

```
MacDev/
├── setup-macos.sh                # macOS entry point (interactive menu)
├── setup-windows.ps1             # Windows entry point (interactive menu)
├── scripts/                      # macOS/Linux setup scripts
│   ├── setup-dev-env.sh         # Development environment installer
│   ├── pimp-my-terminal.sh      # Terminal customization installer
│   ├── setup-tmux.sh            # tmux + theme + plugins installer
│   ├── setup-claude-monitor.sh  # Claude Code Monitor installer
│   ├── claude-monitor.py        # Live dashboard (rich TUI, cross-platform)
│   └── verify-setup.sh          # Verification script
├── windows/                      # Windows setup scripts (PowerShell)
│   ├── setup-dev-env.ps1        # Dev tools via winget + scoop
│   ├── pimp-my-terminal.ps1     # Oh My Posh + PSReadLine + CLI tools
│   ├── setup-tmux.ps1           # Windows Terminal + optional WSL/tmux
│   ├── setup-claude-monitor.ps1 # Claude Monitor installer
│   ├── dev-session.ps1          # Multi-pane layout via wt CLI
│   ├── verify-setup.ps1         # Verification script
│   └── configs/                 # Windows-specific configs
│       ├── oh-my-posh-theme.json       # Catppuccin Mocha for Oh My Posh
│       └── windows-terminal-settings.json  # Color scheme for Windows Terminal
├── configs/                      # macOS configuration files
│   ├── tmux.conf                # tmux config (Catppuccin Mocha theme)
│   └── dev-session.sh           # Dev session layout launcher
├── docs/                         # Documentation
│   ├── DEV_ENVIRONMENT_GUIDE.md
│   └── TERMINAL_SETUP_GUIDE.md
└── examples/                     # Project-specific examples
    ├── start_dev.sh
    ├── verify_setup_project.sh
    └── README.md
```

## 📖 Detailed Usage

### Development Environment

```bash
./scripts/setup-dev-env.sh
```

Installs Homebrew, Git, Python 3.11 (via pyenv), Node.js & npm, and common utilities.

### Terminal Customization

```bash
./scripts/pimp-my-terminal.sh
```

Installs Oh My Zsh, Powerlevel10k, zsh plugins, and modern CLI tools (eza, bat, fzf, fd, thefuck).

### tmux Multiplexer

```bash
./scripts/setup-tmux.sh
```

Installs tmux with Catppuccin Mocha theme, TPM, session persistence plugins, btop, and the `dev-session` command for a Claude Code workflow layout.

### Claude Code Monitor

```bash
./scripts/setup-claude-monitor.sh
```

Installs the live monitoring dashboard. Requires `uv` (auto-installed via Homebrew).

**Usage after install:**

```bash
claude-monitor          # Live dashboard (5s refresh)
claude-monitor --once   # Single snapshot
claude-monitor -i 10    # Custom refresh interval
cmon                    # Alias for claude-monitor
```

**Dashboard shows:**

```
╭──────────────────────── CLAUDE CODE MONITOR ─────────────────────────╮
│  ● 5 active instances                                                │
│  MacDev       PID 56300  CPU 9.7%    37m                             │
│  bhealth      PID 1237   CPU 8.7%    3d 12h                         │
│  studio       PID 63503  CPU 0.7%    23m                             │
│                                                                      │
│  TODAY  Mar 8                                                        │
│  Messages █░░░░░░░░░░░░░░  15                                        │
│  Sessions ██████░░░░░░░░░  4                                         │
│                                                                      │
│  TOKENS (lifetime)                                                   │
│  opus-4-5           2.07B tokens                                     │
│  opus-4-6           730M tokens                                      │
│  sonnet-4-5         114M tokens                                      │
│                                                                      │
│  LIFETIME  171 sessions · 93,674 msgs                                │
│  Since Jan 13, 2026                                                  │
╰──────────────────────────── ↻ 02:02:17 ──────────────────────────────╯
```

### Dev Session (tmux layout)

```bash
cd ~/projects/myapp
sc                    # that's it - launches everything

# also works as:
dev-session                              # same as sc, uses current dir
dev-session ~/projects/myapp             # give it a path
dev-session myapp ~/projects/myapp       # explicit name + path
dev-session --monitor=btop               # override system monitor
```

Creates a tmux layout optimized for Claude Code:

```
┌────────────────────────┬──────────────────┐
│                        │   Dev Server     │
│    Claude Code         │   (npm run dev)  │
│    (80% height)        ├──────────────────┤
│                        │   System Monitor │
├────────────────────────┤   (btop)         │
│    Claude Monitor      │                  │
│    (20% height)        │                  │
└────────────────────────┴──────────────────┘
        65% width              35% width
```

- **Bottom-left:** Claude Monitor always runs here (live dashboard)
- **Bottom-right:** System monitor (`btop` > `htop` > `top`, or `--monitor=CMD`)

### Verify Setup

```bash
./scripts/verify-setup.sh
```

Checks all installed components including dev tools, terminal enhancements, tmux, and Claude Monitor.

## 🎯 What You Get

### Terminal Features

```bash
ll                  # Beautiful file listing with icons
cat file.py         # Syntax highlighting with bat
Ctrl+R              # Fuzzy search command history
Ctrl+T              # Find files
gs                  # git status
fuck                # Fix your last command
```

### tmux Keybindings (prefix = Ctrl+a)

| Key | Action |
|-----|--------|
| `Ctrl+a \|` | Split pane vertically |
| `Ctrl+a -` | Split pane horizontally |
| `Alt+arrows` | Navigate between panes |
| `Shift+arrows` | Switch between windows |
| `Ctrl+a z` | Zoom/unzoom current pane |
| `Ctrl+a d` | Detach from session |
| `Ctrl+a I` | Install plugins (capital I) |

## 🔧 Customization

### Configure Terminal Theme

```bash
p10k configure
```

### Edit Shell Configuration

```bash
nano ~/.zshrc
source ~/.zshrc
```

## 🐛 Troubleshooting

### Homebrew not found

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Icons not showing in terminal

Install a Nerd Font (Powerlevel10k wizard will help).

### Command not found after installation

```bash
source ~/.zshrc
```

### uv cache permission error

If `claude-monitor` fails with a permission error on `~/.cache/uv`:

```bash
sudo chown -R $(whoami) ~/.cache/uv
```

## 🌟 Features

- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Backs up** your existing configuration
- ✅ **Modular** - Use only what you need
- ✅ **Error handling** - Stops on failures
- ✅ **Colorful output** - Easy to follow progress
- ✅ **Zero-setup dependencies** - `uv run` handles Python packages automatically

## 🙏 Credits

This setup installs and configures these open-source projects:

- [Homebrew](https://brew.sh/) · [Oh My Zsh](https://ohmyz.sh/) · [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [tmux](https://github.com/tmux/tmux) · [Catppuccin](https://github.com/catppuccin/tmux) · [TPM](https://github.com/tmux-plugins/tpm)
- [eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat) · [fzf](https://github.com/junegunn/fzf) · [fd](https://github.com/sharkdp/fd)
- [rich](https://github.com/Textualize/rich) · [uv](https://github.com/astral-sh/uv)
- [Oh My Posh](https://ohmyposh.dev/) · [Scoop](https://scoop.sh/) · [Windows Terminal](https://github.com/microsoft/terminal)

---

**Ready to pimp your development environment? Let's go! 🚀**
