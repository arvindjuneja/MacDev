# 🚀 macOS Development Setup

Complete, automated setup for macOS development environments. Get up and running with essential dev tools and a beautiful terminal in minutes!

## ✨ What This Does

This repository provides automated scripts to set up a complete development environment on macOS, including:

### 🛠️ Development Tools
- **Homebrew** - Package manager for macOS
- **Git** - Version control
- **Python 3.11** with pyenv - Python version management
- **Node.js & npm** - JavaScript runtime and package manager
- **Common utilities** - tree, jq, wget, curl, htop

### 🎨 Terminal Customization (Optional)
- **Oh My Zsh** - Powerful zsh framework
- **Powerlevel10k** - Beautiful terminal theme
- **zsh plugins** - Autosuggestions, syntax highlighting, and more
- **Modern CLI tools** - eza, bat, fzf, fd, thefuck

## 🚀 Quick Start

### One-Command Setup

```bash
cd "/Users/arvind/Documents/macOs dev setup"
./setup-macos.sh
```

This launches an interactive menu where you can choose:

1. **Full Setup** - Everything (dev tools + terminal customization)
2. **Dev Environment Only** - Just the essential development tools
3. **Terminal Only** - Just terminal beautification
4. **Verify Setup** - Check what's already installed

## 📋 Prerequisites

- macOS 11.0 or later
- Terminal with zsh (default on modern macOS)
- Internet connection
- Admin privileges (for Homebrew installation)

## 📁 Repository Structure

```
macOs dev setup/
├── setup-macos.sh           # Main entry point (interactive menu)
├── scripts/                 # Core setup scripts
│   ├── setup-dev-env.sh    # Development environment installer
│   ├── pimp-my-terminal.sh # Terminal customization installer
│   └── verify-setup.sh     # Verification script
├── docs/                    # Documentation
│   ├── DEV_ENVIRONMENT_GUIDE.md
│   └── TERMINAL_SETUP_GUIDE.md
└── examples/                # Project-specific script examples
    ├── start_dev.sh
    ├── verify_setup_project.sh
    └── README.md
```

## 📖 Detailed Usage

### Option 1: Development Environment Only

Perfect if you just need coding tools without terminal customization:

```bash
./scripts/setup-dev-env.sh
```

**What it installs:**
- Homebrew
- Git
- Python 3.11 (via pyenv)
- Node.js & npm
- tree, jq, wget, curl, htop

**Time:** ~10 minutes

### Option 2: Terminal Customization Only

For those who already have dev tools and just want a beautiful terminal:

```bash
./scripts/pimp-my-terminal.sh
```

**What it installs:**
- Oh My Zsh framework
- Powerlevel10k theme
- zsh-autosuggestions & zsh-syntax-highlighting
- eza (modern ls)
- bat (better cat)
- fzf (fuzzy finder)
- fd (faster find)
- thefuck (command correction)

**Time:** ~5 minutes

### Option 3: Verify Your Setup

Check what's already installed:

```bash
./scripts/verify-setup.sh
```

This shows:
- ✅ What's installed correctly
- ❌ What's missing
- 💡 Suggestions for improvements

## 🎯 What You Get

### Development Environment

After setup, you'll have:

```bash
# Check versions
python --version    # Python 3.11.x
node --version      # Node.js v20+
git --version       # Latest Git
npm --version       # Latest npm

# Ready to use
pyenv               # Manage Python versions
pip                 # Install Python packages
npm                 # Install Node packages
```

### Terminal Features

If you chose terminal customization:

```bash
# Beautiful file listing
ll                  # Long format with icons
la                  # Show all files
lt                  # Tree view

# Better file viewing
cat file.py         # Syntax highlighting with bat

# Fuzzy finding
Ctrl+R              # Search command history
Ctrl+T              # Find files

# Git shortcuts
gs                  # git status
gl                  # Pretty git log
gcap "msg"          # Add, commit, and push

# Command correction
fuck                # Fix your last command
```

## 📚 Documentation

- **[Development Environment Guide](docs/DEV_ENVIRONMENT_GUIDE.md)** - Complete guide to installed dev tools
- **[Terminal Setup Guide](docs/TERMINAL_SETUP_GUIDE.md)** - Detailed terminal customization documentation
- **[Examples README](examples/README.md)** - How to create project-specific automation

## 🎨 Screenshots

### Before
```
username@Macbook ~ %
```

### After Terminal Setup
```
╭─ ~/projects/my-app  main ✓ 
╰─➤
```

With:
- Git status indicators
- Icons for files and folders
- Syntax highlighting as you type
- Auto-suggestions from history
- Fuzzy search for files and commands

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

### Add Custom Aliases

Add to `~/.zshrc`:

```bash
alias proj='cd ~/Documents/projects'
alias update='brew update && brew upgrade'
```

## 🐛 Troubleshooting

### Homebrew not found

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Icons not showing in terminal

Install a Nerd Font (Powerlevel10k wizard will help)

### Command not found after installation

```bash
source ~/.zshrc
# or restart your terminal
```

### Permission errors

The scripts handle this automatically, but if you encounter issues:

```bash
sudo chown -R $(whoami) /opt/homebrew
```

## 🌟 Features

- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Backs up** your existing configuration
- ✅ **Non-interactive** installation (except for main menu)
- ✅ **Error handling** - Stops on failures
- ✅ **Colorful output** - Easy to follow progress
- ✅ **Modular** - Use only what you need

## 🤝 Contributing

This is a personal setup toolkit made shareable. Feel free to:

1. Fork the repository
2. Adapt scripts to your needs
3. Share your improvements
4. Report issues or suggestions

## 📝 License

Free to use and modify for personal or commercial projects.

## 🙏 Credits

This setup installs and configures these amazing open-source projects:

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [eza](https://github.com/eza-community/eza)
- [bat](https://github.com/sharkdp/bat)
- [fzf](https://github.com/junegunn/fzf)
- [fd](https://github.com/sharkdp/fd)
- [thefuck](https://github.com/nvbn/thefuck)

## 🚀 Next Steps

1. ✅ Run the setup: `./setup-macos.sh`
2. 📖 Read the guides in `docs/`
3. 🎨 Configure your terminal: `p10k configure`
4. 💻 Start developing!

---

**Ready to pimp your development environment? Let's go! 🚀**

*Made with ❤️ for developers who want a great setup without the hassle*
