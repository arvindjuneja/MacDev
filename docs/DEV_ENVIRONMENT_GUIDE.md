# 🛠️ Development Environment Guide

Complete guide to the development tools installed by this setup.

## Installed Tools

### Core Development Tools

| Tool | Purpose | Version Check |
|------|---------|---------------|
| **Homebrew** | macOS package manager | `brew --version` |
| **Git** | Version control | `git --version` |
| **Python** | Programming language | `python --version` |
| **pyenv** | Python version management | `pyenv --version` |
| **pip** | Python package manager | `pip --version` |
| **Node.js** | JavaScript runtime | `node --version` |
| **npm** | Node package manager | `npm --version` |

### Utilities

- **tree** - Directory structure visualization
- **jq** - JSON processor
- **wget** - File downloader
- **curl** - Transfer data with URLs
- **htop** - Interactive process viewer

## Configuration

### Shell Configuration (~/.zshrc)

The setup script adds the following to your `~/.zshrc`:

```bash
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# pyenv for Python version management
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Python user installs
export PATH="$HOME/Library/Python/3.11/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Node.js npm global
export PATH="$HOME/.npm-global/bin:$PATH"

# Aliases
alias python=python3
alias pip=pip3
```

**Apply changes:** Run `source ~/.zshrc` or restart your terminal.

## Working with Python

### Creating a Virtual Environment

```bash
# Navigate to your project
cd /path/to/your/project

# Create virtual environment
python -m venv venv

# Activate it
source venv/bin/activate

# Install packages
pip install flask requests

# Save dependencies
pip freeze > requirements.txt

# Deactivate when done
deactivate
```

### Managing Python Versions with pyenv

```bash
# List available versions
pyenv install --list

# Install a specific version
pyenv install 3.12.0

# Set global version
pyenv global 3.12.0

# Set local version for a project
cd /path/to/project
pyenv local 3.12.0

# Check current version
pyenv version
```

## Working with Node.js

### Creating a Node Project

```bash
# Create project directory
mkdir my-project
cd my-project

# Initialize package.json
npm init -y

# Install dependencies
npm install express

# Install dev dependencies
npm install --save-dev nodemon

# Run your app
node app.js
```

### Global npm Packages

The setup configures npm to install global packages in `~/.npm-global/`:

```bash
# Install a global package
npm install -g typescript

# List global packages
npm list -g --depth=0

# Update a global package
npm update -g typescript
```

## Common Development Commands

### Git

```bash
# Configure Git (first time)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Initialize a repository
git init

# Clone a repository
git clone https://github.com/user/repo.git

# Basic workflow
git status
git add .
git commit -m "Your message"
git push
```

### Python Development

```bash
# Create and activate venv
python -m venv venv
source venv/bin/activate

# Install from requirements
pip install -r requirements.txt

# Run Python script
python script.py

# Start interactive Python
python
```

### Node.js Development

```bash
# Install dependencies
npm install

# Run scripts from package.json
npm run dev
npm run build
npm test

# Update dependencies
npm update
```

## Useful Commands

### Directory Navigation

```bash
tree -L 2           # Show directory tree (2 levels)
tree -I node_modules  # Exclude node_modules
```

### JSON Processing

```bash
cat file.json | jq '.'                    # Pretty print
cat file.json | jq '.data'                # Extract field
cat file.json | jq '.[] | .name'          # Array processing
```

### File Operations

```bash
wget https://example.com/file.zip         # Download file
curl -O https://example.com/file.zip      # Download file
curl -X POST -d "data" https://api.com    # API call
```

### System Monitoring

```bash
htop                # Interactive process viewer
top                 # Process viewer
df -h               # Disk usage
du -sh *            # Directory sizes
```

## Troubleshooting

### Homebrew not found

```bash
# For Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel Macs
eval "$(/usr/local/bin/brew shellenv)"
```

### Python/pip not found

```bash
# Check if python3 is available
which python3

# Use python3 explicitly
python3 --version
pip3 --version
```

### pyenv issues

```bash
# Reload shell configuration
exec $SHELL

# Reinstall specific Python version
pyenv uninstall 3.11.0
pyenv install 3.11.0
```

### npm permission errors

```bash
# Use npm global directory (already configured)
npm install -g package-name

# Or use --user flag for pip
pip install --user package-name
```

### Node modules issues

```bash
# Clean install
rm -rf node_modules package-lock.json
npm install

# Clear npm cache
npm cache clean --force
```

## Best Practices

### Python Projects

1. **Always use virtual environments** for project isolation
2. **Keep requirements.txt updated** for reproducibility
3. **Use .gitignore** to exclude venv/ and __pycache__/
4. **Pin package versions** for stability

### Node.js Projects

1. **Commit package-lock.json** for consistent installs
2. **Use .gitignore** to exclude node_modules/
3. **Use npm scripts** for common tasks
4. **Keep dependencies updated** but test changes

### General

1. **Commit often** with clear messages
2. **Use branches** for features
3. **Write documentation** as you code
4. **Test before deploying**

## Additional Resources

- [Homebrew Documentation](https://docs.brew.sh/)
- [Git Documentation](https://git-scm.com/doc)
- [Python Documentation](https://docs.python.org/)
- [pyenv Documentation](https://github.com/pyenv/pyenv)
- [Node.js Documentation](https://nodejs.org/docs/)
- [npm Documentation](https://docs.npmjs.com/)

## Next Steps

1. ✅ Verify your setup with `./scripts/verify-setup.sh`
2. 📖 Read the Terminal Setup Guide if you want to customize your terminal
3. 🚀 Start building your project!
4. 💡 Check the examples/ folder for project automation scripts

---

*Need help? Check the troubleshooting section or refer to the official documentation.*

