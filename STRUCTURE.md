# 📂 Repository Structure

Visual guide to understanding how everything is organized.

## Directory Tree

```
macOs dev setup/
│
├── 🚀 setup-macos.sh              # START HERE - Main interactive installer
│
├── 📖 README.md                    # Main documentation
├── ⚡ QUICK_START.md               # Quick setup guide
├── 📂 STRUCTURE.md                 # This file
│
├── scripts/                        # Core installation scripts
│   ├── setup-dev-env.sh           # Installs development tools
│   ├── pimp-my-terminal.sh        # Installs terminal customization
│   ├── setup-tmux.sh             # Installs tmux + theme + plugins
│   ├── setup-claude-monitor.sh   # Installs Claude Code Monitor
│   ├── claude-monitor.py         # Live dashboard for Claude Code instances
│   └── verify-setup.sh            # Verifies installation
│
├── configs/                        # Configuration files
│   ├── tmux.conf                  # tmux config (Catppuccin Mocha theme)
│   └── dev-session.sh             # Dev session layout launcher
│
├── docs/                           # Detailed guides
│   ├── DEV_ENVIRONMENT_GUIDE.md   # Development tools documentation
│   └── TERMINAL_SETUP_GUIDE.md    # Terminal customization guide
│
└── examples/                       # Project-specific examples
    ├── README.md                   # How to use examples
    ├── start_dev.sh               # Example: project startup script
    └── verify_setup_project.sh    # Example: project verification
```

## Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                        setup-macos.sh                            │
│                  (Interactive Main Menu)                          │
└──┬──────────┬──────────┬──────────┬──────────┬──────────────┘
   │          │          │          │          │
   │ Opt 1    │ Opt 2    │ Opt 3    │ Opt 4    │ Opt 5
   │ Full     │ Dev Only │ Terminal │ Mux      │ Monitor
   │          │          │          │          │
   ▼          ▼          ▼          ▼          ▼
┌──────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐
│setup-dev-│ │ same   │ │pimp-my-│ │setup-  │ │setup-    │
│env.sh    │ │        │ │terminal│ │tmux.sh │ │claude-   │
│ +        │ │        │ │.sh     │ │        │ │monitor.sh│
│pimp-my-  │ │        │ │        │ │        │ │          │
│terminal  │ │        │ │        │ │        │ │          │
│.sh +     │ │        │ │        │ │        │ │          │
│setup-    │ │        │ │        │ │        │ │          │
│tmux.sh   │ │        │ │        │ │        │ │          │
└──────────┘ └────────┘ └────────┘ └────────┘ └──────────┘
```

## File Purposes

### Root Level

| File | Purpose | When to Use |
|------|---------|-------------|
| `setup-macos.sh` | Main entry point with menu | First time setup or adding more features |
| `README.md` | Complete documentation | Overview and sharing with others |
| `QUICK_START.md` | Fast setup guide | Quick reference |
| `STRUCTURE.md` | This file | Understanding organization |

### scripts/

| File | Purpose | Can Run Standalone? |
|------|---------|---------------------|
| `setup-dev-env.sh` | Installs Homebrew, Git, Python, Node.js, utilities | ✅ Yes |
| `pimp-my-terminal.sh` | Installs Oh My Zsh, Powerlevel10k, modern CLI tools | ✅ Yes |
| `setup-tmux.sh` | Installs tmux, btop, TPM, Catppuccin theme, dev sessions | ✅ Yes |
| `setup-claude-monitor.sh` | Installs Claude Code Monitor dashboard | ✅ Yes |
| `claude-monitor.py` | Live TUI dashboard — scans `~/.claude/` for instances, tokens, history | ✅ Yes (`uv run`) |
| `verify-setup.sh` | Checks what's installed | ✅ Yes |

### configs/

| File | Purpose |
|------|---------|
| `tmux.conf` | tmux configuration with Catppuccin Mocha theme, keybindings |
| `dev-session.sh` | Launches a pre-configured tmux layout for Claude Code workflow |

### docs/

| File | Content |
|------|---------|
| `DEV_ENVIRONMENT_GUIDE.md` | Complete guide to dev tools, Python, Node.js, Git |
| `TERMINAL_SETUP_GUIDE.md` | Terminal features, customization, troubleshooting |

### examples/

| File | Purpose |
|------|---------|
| `README.md` | How to create project-specific scripts |
| `start_dev.sh` | Example: Interactive menu for a specific project |
| `verify_setup_project.sh` | Example: Verify project-specific setup |

## Usage Patterns

### Pattern 1: Full Setup (Recommended for New Machines)

```bash
./setup-macos.sh
# Choose option 1 (Full Setup)
```

This runs both `setup-dev-env.sh` and `pimp-my-terminal.sh` in sequence.

### Pattern 2: Selective Installation

```bash
# Just dev tools
./scripts/setup-dev-env.sh

# Or just terminal
./scripts/pimp-my-terminal.sh
```

Each script can run independently.

### Pattern 3: Verification Only

```bash
./scripts/verify-setup.sh
```

Check what's already installed without installing anything.

### Pattern 4: Project-Specific Automation

```bash
# Copy example
cp examples/start_dev.sh /path/to/your/project/
cd /path/to/your/project/

# Customize for your project
nano start_dev.sh

# Use it
./start_dev.sh
```

## Design Principles

### 1. **Modularity**
Each script can run independently. No complex dependencies.

### 2. **Idempotency**
Safe to run multiple times. Scripts check if things are already installed.

### 3. **Clarity**
Clear separation between:
- Generic setup (scripts/)
- Documentation (docs/)
- Examples (examples/)

### 4. **Safety**
- Backs up existing configurations
- Non-destructive operations
- Clear error messages

### 5. **Shareability**
Ready to share via:
- GitHub repository
- USB drive
- Company internal tools
- Personal dotfiles repo

## Customization Points

### For Personal Use

Edit these files:
- `scripts/setup-dev-env.sh` - Add tools you always need
- `scripts/pimp-my-terminal.sh` - Add your favorite CLI tools
- `~/.zshrc` (after install) - Add personal aliases

### For Team Use

1. Fork this repository
2. Customize `scripts/setup-dev-env.sh` with team tools
3. Update `examples/` with your project templates
4. Share the repository URL

### For Specific Projects

1. Copy `examples/start_dev.sh` to your project
2. Modify for your project structure
3. Commit to your project repository

## Maintenance

### Adding New Tools to Dev Environment

Edit `scripts/setup-dev-env.sh`:

```bash
# In install_utilities() function, add:
local tools=("tree" "jq" "wget" "curl" "htop" "your-tool")
```

### Adding Terminal Tools

Edit `scripts/pimp-my-terminal.sh`:

```bash
# In install_cli_tools() function, add:
local tools=("eza" "bat" "fzf" "fd" "thefuck" "your-tool")
```

### Updating Documentation

- User guides → `docs/`
- Quick reference → `QUICK_START.md`
- Project examples → `examples/README.md`

## Backup & Restore

### What Gets Backed Up

- `.zshrc` → `.zshrc.backup.YYYYMMDD_HHMMSS`

### How to Restore

```bash
# Find your backup
ls -la ~ | grep zshrc.backup

# Restore
cp ~/.zshrc.backup.20240101_120000 ~/.zshrc
source ~/.zshrc
```

## Sharing This Repository

### Via GitHub

```bash
cd path/to/MacDev
git init
git add .
git commit -m "Initial commit: macOS dev setup"
git remote add origin https://github.com/yourusername/macos-dev-setup.git
git push -u origin main
```

Then others can:
```bash
git clone https://github.com/yourusername/macos-dev-setup.git
cd macos-dev-setup
./setup-macos.sh
```

### Via Download

Share as ZIP. Users:
```bash
unzip macos-dev-setup.zip
cd macos-dev-setup
./setup-macos.sh
```

### One-Liner Install (if hosted)

```bash
bash <(curl -fsSL https://your-domain.com/setup-macos.sh)
```

## Philosophy

This repository follows these principles:

1. **Simple over clever** - Easy to understand and modify
2. **Modular over monolithic** - Each piece works independently
3. **Safe over fast** - Backups and checks before changes
4. **Clear over concise** - Readable code with comments
5. **Generic over specific** - Reusable across projects

---

**This structure makes it easy to maintain, extend, and share! 🚀**

