# 🎨 Terminal Setup Guide

Transform your macOS terminal into a beautiful, productive workspace.

## What Gets Installed

### Framework & Theme

- **Oh My Zsh** - Powerful zsh configuration framework with hundreds of plugins
- **Powerlevel10k** - Beautiful, fast, and highly customizable terminal theme

### Plugins

- **zsh-autosuggestions** - Fish-like autosuggestions as you type (press → to accept)
- **zsh-syntax-highlighting** - Real-time syntax highlighting of commands
- **git** - Git aliases and functions
- **docker** - Docker completion and aliases
- **python** - Python-specific shortcuts
- **node** - Node.js and npm completion
- **fzf** - Fuzzy finder integration

### Modern CLI Tools

| Tool | Replaces | Purpose |
|------|----------|---------|
| **eza** | `ls` | Modern file listing with icons and git status |
| **bat** | `cat` | Syntax-highlighted file viewer |
| **fzf** | - | Fuzzy finder for files, history, commands |
| **fd** | `find` | Fast and user-friendly alternative to find |
| **thefuck** | - | Corrects your previous console command |

## Installation

The script is run automatically if you choose "Full Setup" or "Terminal Only" from the main menu:

```bash
./setup-macos.sh
```

Or run it directly:

```bash
./scripts/pimp-my-terminal.sh
```

## What the Script Does

1. ✅ Checks if you're on macOS
2. 📦 Installs Homebrew (if needed)
3. 🎨 Installs Oh My Zsh
4. ⚡ Installs Powerlevel10k theme
5. 🔌 Installs zsh plugins
6. 🛠️ Installs modern CLI tools
7. 💾 Backs up your existing `.zshrc`
8. ✍️ Creates optimized `.zshrc` configuration

## First Run

After installation:

1. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

2. **Powerlevel10k Configuration Wizard** will launch automatically
   - Choose your preferred prompt style
   - Configure icons, colors, and segments
   - You can always reconfigure later with `p10k configure`

3. **Install Recommended Font** (if prompted)
   - Powerlevel10k works best with Nerd Fonts
   - The wizard will offer to install MesloLGS NF
   - Accept the installation for best results

## Features & Usage

### Smart Aliases

The setup includes many useful aliases:

```bash
# Modern file listing
ls          # eza with icons
ll          # long format with icons
la          # all files with icons
lla         # long format, all files
lt          # tree view

# Better cat
cat file.txt      # bat with syntax highlighting
catp file.txt     # bat with pager

# Git shortcuts
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git log (pretty format)
gd          # git diff

# Navigation
..          # cd ..
...         # cd ../..
....        # cd ../../..
~           # cd ~

# System
c           # clear
h           # history
zshconfig   # edit .zshrc
zshreload   # reload .zshrc
```

### Custom Functions

```bash
# Create directory and cd into it
mkcd new-project

# Quick search in files
search "TODO"

# Git commit all and push
gcap "commit message"
```

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy file finder |
| `→` | Accept autosuggestion |
| `Esc` then `Backspace` | Delete word backward |

### thefuck - Command Correction

Made a typo? Just type `fuck`:

```bash
$ git psuh origin main
git: 'psuh' is not a git command

$ fuck
git push origin main [enter/↑/↓/ctrl+c]
```

### FZF - Fuzzy Finder

**Search command history:**
```bash
Ctrl+R  # Opens fuzzy search in your command history
```

**Find and open files:**
```bash
Ctrl+T  # Find files in current directory
```

**Use in commands:**
```bash
vim $(fzf)           # Open file in vim
cd $(find . -type d | fzf)  # Fuzzy cd
```

### Eza - Modern ls

```bash
# Basic usage
eza                  # Simple listing
eza -l              # Long format
eza -la             # Long format + hidden files
eza --tree          # Tree view
eza --git           # Show git status

# With aliases
ll                  # Long format with icons
lla                 # Long format with hidden files
lt                  # Tree view
```

### Bat - Better Cat

```bash
# View files with syntax highlighting
bat file.py
bat -n file.js      # With line numbers
bat -A file.sh      # Show all characters

# With alias
cat file.py         # Uses bat automatically
catp file.py        # Uses bat with pager
```

## Customization

### Reconfigure Powerlevel10k

```bash
p10k configure
```

This launches the interactive configuration wizard where you can:
- Change prompt style
- Add/remove segments
- Adjust colors
- Configure icons

### Edit .zshrc

```bash
nano ~/.zshrc
# or
zshconfig
```

After editing, reload:
```bash
source ~/.zshrc
# or
zshreload
```

### Add Your Own Aliases

Add to the end of `~/.zshrc`:

```bash
# My custom aliases
alias dev='cd ~/Documents/projects'
alias gs='git status'
alias update='brew update && brew upgrade'
```

### Install Additional Oh My Zsh Plugins

```bash
# Edit .zshrc
nano ~/.zshrc

# Find the plugins line and add more:
plugins=(
  git
  docker
  python
  node
  # Add more plugins here:
  npm
  vscode
  macos
)

# Reload
source ~/.zshrc
```

**Popular plugins:**
- `npm` - npm completions
- `yarn` - Yarn completions  
- `docker-compose` - Docker Compose completions
- `vscode` - VS Code shortcuts
- `macos` - macOS-specific commands
- `z` - Jump to frequent directories

See all available: [Oh My Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)

### Add Custom Plugins

```bash
# Clone to custom plugins directory
git clone https://github.com/user/plugin-name ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/plugin-name

# Add to .zshrc plugins list
plugins=(... plugin-name)

# Reload
source ~/.zshrc
```

## Restore Backup

If something goes wrong, your old `.zshrc` is backed up:

```bash
# Find your backup
ls -la ~ | grep zshrc.backup

# Restore it
cp ~/.zshrc.backup.20240101_120000 ~/.zshrc
source ~/.zshrc
```

## Troubleshooting

### Icons Not Showing

**Problem:** Squares or weird characters instead of icons

**Solution:**
1. Install a Nerd Font (Powerlevel10k wizard offers MesloLGS NF)
2. Set it in your terminal preferences
3. For iTerm2: Preferences → Profiles → Text → Font
4. For Terminal.app: Preferences → Profiles → Text → Font

### Theme Not Loading

**Problem:** Powerlevel10k doesn't show up

**Solution:**
```bash
# Check if theme is set
grep ZSH_THEME ~/.zshrc

# Should show:
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Reconfigure
p10k configure
```

### Slow Shell Startup

**Problem:** Terminal takes long to open

**Solution:**
```bash
# Disable some plugins in .zshrc
# Comment out plugins you don't use:
plugins=(
  git
  # docker  # Disable if not using Docker
  # python  # Disable if not using Python
)
```

### Command Not Found After Installation

**Problem:** Commands like `eza` or `bat` not found

**Solution:**
```bash
# Ensure Homebrew is in PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# Reinstall the tool
brew install eza bat
```

### Oh My Zsh Not Loading

**Problem:** Plugins not working

**Solution:**
```bash
# Check if Oh My Zsh is sourced in .zshrc
cat ~/.zshrc | grep "oh-my-zsh.sh"

# Should show:
# source $ZSH/oh-my-zsh.sh

# Reinstall if needed
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Tips & Tricks

### 1. Quick Directory Jumping with Aliases

Add to `.zshrc`:
```bash
alias proj='cd ~/Documents/projects'
alias down='cd ~/Downloads'
```

### 2. Use Fuzzy History Search

Press `Ctrl+R` and start typing - fzf will show matching commands

### 3. Pipe to bat for Syntax Highlighting

```bash
curl https://api.github.com/repos/user/repo | bat -l json
```

### 4. Git Status in Prompt

Powerlevel10k shows:
- Current branch
- Dirty/clean status
- Commits ahead/behind
- Stashed changes

### 5. Quick Command Fixing

Instead of pressing ↑ and editing, just type `fuck`

### 6. Tab Completion

Oh My Zsh provides smart completion for:
- Git commands and branches
- Docker containers
- npm scripts
- File paths

### 7. Command Syntax Highlighting

While typing, commands are highlighted:
- Green = valid command
- Red = invalid command
- Yellow = alias

### 8. Auto-suggestions from History

Start typing - suggestions appear in gray. Press → to accept.

## Uninstalling

If you want to remove the customizations:

```bash
# Restore original .zshrc
mv ~/.zshrc.backup.YYYYMMDD_HHMMSS ~/.zshrc

# Remove Oh My Zsh (optional)
uninstall_oh_my_zsh

# Remove modern CLI tools (optional)
brew uninstall eza bat fzf fd thefuck
```

## Additional Resources

- [Oh My Zsh Documentation](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [eza Documentation](https://github.com/eza-community/eza)
- [bat Documentation](https://github.com/sharkdp/bat)
- [fzf Documentation](https://github.com/junegunn/fzf)
- [thefuck Documentation](https://github.com/nvbn/thefuck)

---

**Enjoy your beautiful terminal! 🚀✨**

