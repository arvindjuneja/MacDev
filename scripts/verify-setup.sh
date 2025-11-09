#!/bin/bash

# ============================================
# 🔍 Development Environment Verification
# ============================================
# Checks that all development tools are installed correctly
# Usage: bash verify-setup.sh
# ============================================

echo "🔍 Verifying Development Environment..."
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Track overall success
ALL_OK=true
ISSUES=()

# Function to check if command exists
check_command() {
    local cmd=$1
    local name=$2
    local version_flag=$3
    
    if command -v $cmd &> /dev/null; then
        local version=$($cmd $version_flag 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name: Not found"
        ISSUES+=("$name is not installed")
        ALL_OK=false
        return 1
    fi
}

echo -e "${BLUE}Core Development Tools:${NC}"
echo "----------------------"

# Check Homebrew
if [ -f /opt/homebrew/bin/brew ] || [ -f /usr/local/bin/brew ]; then
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew_version=$(brew --version 2>&1 | head -n1)
    echo -e "${GREEN}✓${NC} Homebrew: $brew_version"
else
    echo -e "${RED}✗${NC} Homebrew: Not found"
    ISSUES+=("Homebrew is not installed - Install from https://brew.sh")
    ALL_OK=false
fi

# Check core tools
check_command "git" "Git" "--version"
check_command "python3" "Python" "--version"
check_command "pip3" "pip" "--version"
check_command "pyenv" "pyenv" "--version"
check_command "node" "Node.js" "--version"
check_command "npm" "npm" "--version"

echo ""
echo -e "${BLUE}Utilities:${NC}"
echo "----------"
check_command "tree" "tree" "--version"
check_command "jq" "jq" "--version"
check_command "wget" "wget" "--version"
check_command "curl" "curl" "--version"

echo ""
echo -e "${BLUE}Terminal Enhancements (Optional):${NC}"
echo "---------------------------------"

# Check Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}✓${NC} Oh My Zsh: Installed"
else
    echo -e "${YELLOW}○${NC} Oh My Zsh: Not installed (run pimp-my-terminal.sh)"
fi

# Check Powerlevel10k
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo -e "${GREEN}✓${NC} Powerlevel10k: Installed"
else
    echo -e "${YELLOW}○${NC} Powerlevel10k: Not installed (run pimp-my-terminal.sh)"
fi

# Check modern CLI tools
check_command "eza" "eza (modern ls)" "--version" || echo -e "${YELLOW}○${NC} eza: Not installed (optional)"
check_command "bat" "bat (better cat)" "--version" || echo -e "${YELLOW}○${NC} bat: Not installed (optional)"
check_command "fzf" "fzf (fuzzy finder)" "--version" || echo -e "${YELLOW}○${NC} fzf: Not installed (optional)"

echo ""
echo -e "${BLUE}Shell Configuration:${NC}"
echo "--------------------"

# Check .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo -e "${GREEN}✓${NC} .zshrc: Found"
    
    # Check if dev env is configured
    if grep -q "Development Environment Setup" "$HOME/.zshrc"; then
        echo -e "${GREEN}✓${NC} Development environment: Configured in .zshrc"
    else
        echo -e "${YELLOW}!${NC} Development environment: Not configured (run setup-dev-env.sh)"
    fi
else
    echo -e "${YELLOW}!${NC} .zshrc: Not found"
    ISSUES+=(".zshrc file not found")
fi

echo ""
echo "========================================"

# Summary
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}✓ All core tools are installed correctly!${NC}"
    echo ""
    echo -e "${GREEN}Your development environment is ready! 🎉${NC}"
else
    echo -e "${RED}✗ Some tools are missing or not configured properly.${NC}"
    echo ""
    echo -e "${YELLOW}Issues found:${NC}"
    for issue in "${ISSUES[@]}"; do
        echo "  • $issue"
    done
    echo ""
    echo -e "${YELLOW}Recommended actions:${NC}"
    echo "  1. Run the setup script: ./setup-macos.sh"
    echo "  2. Or install missing tools individually"
fi

echo ""

# Optional tools suggestion
if [ "$ALL_OK" = true ]; then
    if ! command -v eza &> /dev/null || ! command -v bat &> /dev/null; then
        echo -e "${BLUE}💡 Tip: ${NC}Consider running pimp-my-terminal.sh for a better terminal experience!"
        echo ""
    fi
fi

