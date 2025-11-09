#!/bin/bash

# ============================================
# 🛠️ macOS Development Environment Setup
# ============================================
# Installs essential development tools for macOS:
# - Homebrew
# - Git
# - Python (via pyenv)
# - Node.js & npm
# - Common utilities
# 
# Usage: bash setup-dev-env.sh
# ============================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Emojis
CHECK="✅"
ROCKET="🚀"
WRENCH="🔧"
PACKAGE="📦"

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║   🛠️  Development Environment Setup      ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${CYAN}${ROCKET} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}${WRENCH} $1${NC}"
}

# Install Homebrew
install_homebrew() {
    print_step "Installing Homebrew (macOS package manager)..."
    
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
        print_info "Updating Homebrew..."
        brew update
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for Apple Silicon
        if [[ $(uname -m) == 'arm64' ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed successfully"
    fi
}

# Install Git
install_git() {
    print_step "Installing Git..."
    
    if command -v git &> /dev/null; then
        print_success "Git already installed: $(git --version)"
    else
        print_info "Installing Git via Homebrew..."
        brew install git
        print_success "Git installed successfully"
    fi
}

# Install Python via pyenv
install_python() {
    print_step "Installing Python (via pyenv)..."
    
    # Install pyenv
    if command -v pyenv &> /dev/null; then
        print_success "pyenv already installed"
    else
        print_info "Installing pyenv..."
        brew install pyenv
        print_success "pyenv installed"
    fi
    
    # Install latest Python 3.11
    print_info "Installing Python 3.11..."
    if pyenv versions | grep -q "3.11"; then
        print_success "Python 3.11 already installed"
    else
        pyenv install 3.11
        pyenv global 3.11
        print_success "Python 3.11 installed and set as global"
    fi
    
    # Install pip packages
    print_info "Installing essential Python packages..."
    pip install --upgrade pip
    pip install --user virtualenv ipython requests
    print_success "Essential Python packages installed"
}

# Install Node.js
install_node() {
    print_step "Installing Node.js..."
    
    if command -v node &> /dev/null; then
        print_success "Node.js already installed: $(node --version)"
        print_success "npm already installed: $(npm --version)"
    else
        print_info "Installing Node.js via Homebrew..."
        brew install node
        print_success "Node.js and npm installed successfully"
    fi
    
    # Setup npm global directory
    print_info "Configuring npm global directory..."
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    print_success "npm configured"
}

# Install common utilities
install_utilities() {
    print_step "Installing common utilities..."
    
    local tools=("tree" "jq" "wget" "curl" "htop")
    
    # Ensure Homebrew is in PATH
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null || command -v "$tool" &>/dev/null; then
            print_success "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
            print_success "$tool installed"
        fi
    done
}

# Configure shell (zsh)
configure_shell() {
    print_step "Configuring shell environment..."
    
    local zshrc="$HOME/.zshrc"
    local backup="$HOME/.zshrc.backup.devenv.$(date +%Y%m%d_%H%M%S)"
    
    # Backup existing .zshrc if it exists
    if [ -f "$zshrc" ]; then
        print_info "Backing up existing .zshrc..."
        cp "$zshrc" "$backup"
    fi
    
    # Add development environment configuration
    print_info "Adding development environment configuration to .zshrc..."
    
    # Check if dev env config already exists
    if ! grep -q "# === Development Environment Setup ===" "$zshrc" 2>/dev/null; then
        cat >> "$zshrc" << 'EOF'

# === Development Environment Setup ===
# Added by macOS dev setup script

# Homebrew
if [[ $(uname -m) == 'arm64' ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# pyenv for Python version management
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Python user installs
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="$HOME/Library/Python/3.10/bin:$PATH"
export PATH="$HOME/Library/Python/3.11/bin:$PATH"
export PATH="$HOME/Library/Python/3.12/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Node.js npm global
export PATH="$HOME/.npm-global/bin:$PATH"

# Aliases
alias python=python3
alias pip=pip3

# === End Development Environment Setup ===
EOF
        print_success "Shell configuration updated"
    else
        print_success "Development environment configuration already exists in .zshrc"
    fi
}

# Print completion message
print_completion() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ${CHECK}  Development Environment Setup Complete!     ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}📦 Installed Tools:${NC}"
    echo "  • Homebrew - Package manager"
    echo "  • Git - Version control"
    echo "  • Python 3.11 (via pyenv) - Programming language"
    echo "  • pip - Python package manager"
    echo "  • Node.js - JavaScript runtime"
    echo "  • npm - Node package manager"
    echo "  • tree, jq, wget, curl, htop - Utilities"
    
    echo ""
    echo -e "${YELLOW}🚀 Next Steps:${NC}"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Verify installation: run the verify-setup.sh script"
    echo "  3. Start developing! 🎉"
    
    echo ""
    echo -e "${PURPLE}💡 Quick Start:${NC}"
    echo "  • Create Python project: mkdir myproject && cd myproject && python -m venv venv"
    echo "  • Create Node project: mkdir myproject && cd myproject && npm init -y"
    echo "  • Check versions: python --version && node --version && git --version"
    
    echo ""
    echo -e "${CYAN}📚 Documentation:${NC}"
    echo "  Check the docs/ folder for detailed guides"
    echo ""
}

# Main installation flow
main() {
    print_header
    
    echo "This script will install essential development tools on your macOS machine."
    echo ""
    read -p "Continue? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
    
    install_homebrew
    install_git
    install_python
    install_node
    install_utilities
    configure_shell
    
    print_completion
}

# Run the script
main

