#!/bin/bash

# ============================================
# 🎨 PIMP MY TERMINAL - Auto Setup Script
# ============================================
# This script installs and configures a modern, beautiful terminal setup
# Compatible with: macOS (zsh)
# Usage: bash pimp-my-terminal.sh
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
CHECK="✅"
ROCKET="🚀"
WRENCH="🔧"
PACKAGE="📦"
SPARKLES="✨"

print_header() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║     🎨 PIMP MY TERMINAL SETUP 🎨          ║"
    echo "╔═══════════════════════════════════════════╝"
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

# Check if running on macOS
check_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_success "Running on macOS"
}

# Install Homebrew if not present
install_homebrew() {
    print_step "Checking Homebrew installation..."
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
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

# Install Oh My Zsh
install_oh_my_zsh() {
    print_step "Installing Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
    else
        export RUNZSH=no
        export KEEP_ZSHRC=yes
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed successfully"
    fi
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    print_step "Installing Powerlevel10k theme..."
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_success "Powerlevel10k already installed"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        print_success "Powerlevel10k installed successfully"
    fi
}

# Install zsh plugins
install_zsh_plugins() {
    print_step "Installing zsh plugins..."
    
    # zsh-autosuggestions
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        print_success "zsh-autosuggestions already installed"
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        print_success "zsh-autosuggestions installed"
    fi
    
    # zsh-syntax-highlighting
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        print_success "zsh-syntax-highlighting already installed"
    else
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        print_success "zsh-syntax-highlighting installed"
    fi
}

# Install modern CLI tools via Homebrew
install_cli_tools() {
    print_step "Installing modern CLI tools..."
    
    # Ensure Homebrew is in PATH
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    local tools=("eza" "bat" "fzf" "fd" "thefuck")
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_success "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
            print_success "$tool installed"
        fi
    done
}

# Backup existing .zshrc
backup_zshrc() {
    if [ -f "$HOME/.zshrc" ]; then
        print_info "Backing up existing .zshrc to .zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Create new .zshrc configuration
create_zshrc() {
    print_step "Creating new .zshrc configuration..."
    
    cat > "$HOME/.zshrc" << 'EOF'
# ===== Powerlevel10k Instant Prompt =====
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===== Oh My Zsh Configuration =====
export ZSH="$HOME/.oh-my-zsh"

# Set theme to Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh My Zsh plugins
plugins=(
  git
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
  docker
  npm
  node
  python
  pip
)

source $ZSH/oh-my-zsh.sh

# ===== Development Environment Setup =====
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
  eval "$(pyenv init -)"
fi

# Node.js
export PATH="/opt/homebrew/opt/node/bin:$PATH"

# Firebase CLI
export PATH="$PATH:$HOME/.npm-global/bin"

# Python user installs
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="$HOME/Library/Python/3.10/bin:$PATH"
export PATH="$HOME/Library/Python/3.11/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

# ===== Modern CLI Tools Setup =====
# FZF (Fuzzy Finder)
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

# FZF shell integration (Homebrew)
if command -v brew &> /dev/null; then
  FZF_PATH="$(brew --prefix)/opt/fzf"
  if [ -f "$FZF_PATH/shell/key-bindings.zsh" ]; then
    source "$FZF_PATH/shell/key-bindings.zsh"
    source "$FZF_PATH/shell/completion.zsh"
  fi
fi

# FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --margin=1 --padding=1"
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# thefuck - command correction
if command -v thefuck &> /dev/null; then
  eval $(thefuck --alias)
  eval $(thefuck --alias FUCK)
fi

# ===== Aliases =====
# Python
alias python=python3
alias pip=pip3

# Modern replacements
if command -v eza &> /dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias la='eza --icons --group-directories-first -a'
  alias ll='eza --icons --group-directories-first -lh'
  alias lla='eza --icons --group-directories-first -lha'
  alias lt='eza --icons --group-directories-first --tree'
fi

if command -v bat &> /dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'
fi

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# System
alias c='clear'
alias h='history'
alias zshconfig='nano ~/.zshrc'
alias zshreload='source ~/.zshrc'

# ===== Custom Functions =====
# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick search in files
search() {
  grep -r "$1" .
}

# Git commit all and push
gcap() {
  git add .
  git commit -m "$1"
  git push
}

# ===== Colors & Highlighting =====
# Enable colors
autoload -U colors && colors

# ZSH Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ===== History Configuration =====
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# ===== Other Settings =====
# Case-insensitive completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Auto cd (just type directory name)
setopt AUTO_CD

# Correct commands
setopt CORRECT
setopt CORRECT_ALL

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
    
    print_success "New .zshrc created"
}

# Print final instructions
print_completion() {
    echo -e "\n${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     ${SPARKLES}  TERMINAL PIMPING COMPLETE! ${SPARKLES}                     ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}✨ What's installed:${NC}"
    echo "  • Oh My Zsh - powerful zsh framework"
    echo "  • Powerlevel10k - beautiful theme"
    echo "  • zsh-autosuggestions - fish-like suggestions"
    echo "  • zsh-syntax-highlighting - command highlighting"
    echo "  • eza - modern ls with icons"
    echo "  • bat - better cat with syntax highlighting"
    echo "  • fzf - fuzzy finder (Ctrl+R for history)"
    echo "  • fd - faster find"
    echo "  • thefuck - command correction"
    
    echo -e "\n${YELLOW}🚀 Next steps:${NC}"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Powerlevel10k will launch a setup wizard on first run"
    echo "  3. Try: ll, cat ~/.zshrc, Ctrl+R, or type 'fuck' after an error"
    
    echo -e "\n${PURPLE}💡 Pro tips:${NC}"
    echo "  • Use 'Ctrl+R' for fuzzy history search"
    echo "  • Use 'Ctrl+T' for fuzzy file search"
    echo "  • Press '→' to accept autosuggestions"
    echo "  • Type 'p10k configure' to customize your theme"
    
    echo -e "\n${GREEN}Your terminal is now PIMPED! 🎉${NC}\n"
}

# Main installation flow
main() {
    print_header
    
    check_os
    install_homebrew
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    install_cli_tools
    backup_zshrc
    create_zshrc
    
    print_completion
}

# Run the script
main

