# ⚡ Quick Start Guide

Get your macOS development environment up and running in 5 minutes!

## TL;DR

```bash
cd path/to/MacDev
./setup-macos.sh
```

Choose option 1 for full setup, then follow the prompts. Done! 🎉

## What Will Happen

### If You Choose "Full Setup" (Recommended)

**Step 1: Development Tools (~10 minutes)**
- Installs Homebrew
- Installs Git, Python, Node.js
- Configures shell environment
- You'll see colorful progress messages

**Step 2: Terminal Customization (~5 minutes)**
- Installs Oh My Zsh and Powerlevel10k
- Installs modern CLI tools
- Creates beautiful terminal setup
- Backs up your existing .zshrc

**Step 3: First Run**
- Restart terminal or run: `source ~/.zshrc`
- Powerlevel10k wizard launches automatically
- Follow the wizard (choose what looks good!)
- Done!

## Verification

After setup, verify everything works:

```bash
./scripts/verify-setup.sh
```

You should see all green checkmarks ✅

## Test Your New Setup

### Development Tools

```bash
# Check versions
python --version
node --version
git --version

# Create a test Python project
mkdir test-project && cd test-project
python -m venv venv
source venv/bin/activate
pip install requests
python -c "import requests; print('Python works!')"
deactivate
cd ..
```

### Terminal Features

```bash
# Try new commands
ll                  # Beautiful file listing
cat README.md       # Syntax-highlighted viewing
Ctrl+R              # Fuzzy history search
Ctrl+T              # Fuzzy file finder

# Git shortcuts (in a git repo)
gs                  # git status
gl                  # pretty git log
```

## Common Issues & Quick Fixes

### "Homebrew not found"

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/.zshrc
```

### "Icons look weird"

The Powerlevel10k wizard will offer to install the correct font. Accept it and restart your terminal.

### "Script failed"

Make sure you have:
- Internet connection
- Admin password ready
- At least 500MB free disk space

Then run again - scripts are safe to run multiple times.

## What's Next?

1. **Customize your theme**: Run `p10k configure`
2. **Read the guides**: Check `docs/` folder
3. **Create project automation**: See `examples/` folder
4. **Start coding**: Your environment is ready!

## Customization

### Add Your Own Aliases

Edit `~/.zshrc` and add at the end:

```bash
alias dev='cd ~/Documents/projects'
alias update='brew update && brew upgrade'
```

Then run: `source ~/.zshrc`

### Change Colors/Theme

```bash
p10k configure
```

### Add More Tools

```bash
brew install imagemagick    # Image processing
brew install ffmpeg         # Video processing
npm install -g typescript   # TypeScript
```

## Getting Help

- **Dev tools help**: Read `docs/DEV_ENVIRONMENT_GUIDE.md`
- **Terminal help**: Read `docs/TERMINAL_SETUP_GUIDE.md`
- **Examples**: Check `examples/` folder

## One-Liners for Specific Setups

**Just dev tools:**
```bash
./scripts/setup-dev-env.sh
```

**Just terminal:**
```bash
./scripts/pimp-my-terminal.sh
```

**Just verification:**
```bash
./scripts/verify-setup.sh
```

---

**That's it! You're ready to code! 🚀**

