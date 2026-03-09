#!/bin/bash

# ============================================
# Claude Code Monitor Setup
# ============================================
# Installs the Claude Code Monitor dashboard:
# - Checks/installs uv (Python package runner)
# - Deploys claude-monitor to ~/.local/bin
# - Adds shell alias
#
# Usage: bash setup-claude-monitor.sh
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

CHECK="✅"
ROCKET="🚀"
WRENCH="🔧"
SPARKLES="✨"

print_header() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║    📊  CLAUDE CODE MONITOR SETUP 📊       ║"
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

# Check OS (macOS or Linux)
check_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        print_success "Running on macOS"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        OS_TYPE="linux"
        print_success "Running on Linux"
    else
        print_error "This script supports macOS and Linux only."
        exit 1
    fi
}

# Ensure Homebrew is available
ensure_homebrew() {
    if command -v brew &> /dev/null; then
        return 0
    elif [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        print_error "Homebrew not found. Run setup-macos.sh first or install from https://brew.sh"
        exit 1
    fi
}

# Install uv if not present
install_uv() {
    print_step "Checking uv (Python package runner)..."
    if command -v uv &> /dev/null; then
        local version=$(uv --version 2>&1)
        print_success "uv already installed ($version)"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        print_info "Installing uv via Homebrew..."
        ensure_homebrew
        brew install uv
        print_success "uv installed ($(uv --version))"
    else
        print_info "Installing uv via installer script..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
        print_success "uv installed ($(uv --version))"
    fi
}

# Deploy claude-monitor script
deploy_monitor() {
    print_step "Deploying claude-monitor..."

    local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local monitor_src="$script_dir/claude-monitor.py"
    local monitor_dest="$HOME/.local/bin/claude-monitor"

    # Ensure ~/.local/bin exists
    mkdir -p "$HOME/.local/bin"

    if [ -f "$monitor_src" ]; then
        cp "$monitor_src" "$monitor_dest"
        chmod +x "$monitor_dest"
        print_success "claude-monitor installed to $monitor_dest"
    else
        print_error "claude-monitor.py not found at $monitor_src"
        exit 1
    fi
}

# Run once to trigger uv dependency resolution
warmup_dependencies() {
    print_step "Warming up dependencies (first-run uv install)..."
    if "$HOME/.local/bin/claude-monitor" --once > /dev/null 2>&1; then
        print_success "Dependencies installed and monitor works"
    else
        print_info "First run may take a moment while uv installs rich..."
        "$HOME/.local/bin/claude-monitor" --once || true
        print_success "Dependencies resolved"
    fi
}

# Add alias to shell rc file
configure_shell() {
    print_step "Adding shell alias..."

    # Detect the user's shell rc file
    local shell_rc=""
    local shell_name=""
    if [ -n "$ZSH_VERSION" ] || [[ "$SHELL" == */zsh ]]; then
        shell_rc="$HOME/.zshrc"
        shell_name="zsh"
    elif [ -n "$BASH_VERSION" ] || [[ "$SHELL" == */bash ]]; then
        shell_rc="$HOME/.bashrc"
        shell_name="bash"
    else
        shell_rc="$HOME/.profile"
        shell_name="profile"
    fi

    if ! grep -q "# === Claude Monitor ===" "$shell_rc" 2>/dev/null; then
        cat >> "$shell_rc" << 'EOF'

# === Claude Monitor ===
# Added by MacDev claude-monitor setup
export PATH="$HOME/.local/bin:$PATH"
alias cmon='claude-monitor'
# === End Claude Monitor ===
EOF
        print_success "Alias 'cmon' added to $shell_rc"
    else
        print_success "Claude Monitor shell config already exists in $shell_rc"
    fi
}

# Print completion message
print_completion() {
    echo -e "\n${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     ${SPARKLES}  CLAUDE CODE MONITOR SETUP COMPLETE! ${SPARKLES}            ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${CYAN}${SPARKLES} What's installed:${NC}"
    echo "  • uv             - Python package runner (zero-setup deps)"
    echo "  • claude-monitor  - Live dashboard for Claude Code instances"
    echo "  • cmon alias      - Quick launch shortcut"

    echo -e "\n${YELLOW}${ROCKET} Quick Start:${NC}"
    echo "  Live dashboard:      claude-monitor"
    echo "  Single snapshot:     claude-monitor --once"
    echo "  Custom interval:     claude-monitor --interval 10"
    echo "  Quick alias:         cmon"

    echo -e "\n${GREEN}Restart your terminal or source your shell rc file.${NC}\n"
}

# Main
main() {
    print_header

    check_os
    install_uv
    deploy_monitor
    warmup_dependencies
    configure_shell

    print_completion
}

main
