#!/bin/bash

# ============================================
# 🚀 macOS Development Setup
# ============================================
# One-stop script for setting up your macOS development environment
# 
# Options:
#   1. Complete setup (Dev tools + Terminal customization)
#   2. Development environment only
#   3. Terminal customization only
# 
# Usage: bash setup-macos.sh
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
SPARKLES="✨"
WRENCH="🔧"

print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║         🚀  macOS Development Environment Setup  🚀       ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Detect OS (macOS or Linux)
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        OS_TYPE="linux"
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Gate macOS-only features
require_macos() {
    if [[ "$OS_TYPE" != "macos" ]]; then
        print_error "This option requires macOS. On Linux, only Claude Monitor (option 5) is supported."
        return 1
    fi
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Main menu
show_menu() {
    echo -e "${YELLOW}What would you like to set up?${NC}"
    echo ""
    echo "  1) ${GREEN}Full Setup${NC} - Development tools + Terminal customization + tmux"
    echo "  2) ${BLUE}Dev Environment Only${NC} - Essential development tools"
    echo "  3) ${PURPLE}Terminal Only${NC} - Beautiful terminal setup"
    echo "  4) ${YELLOW}Multiplexer Only${NC} - tmux with Catppuccin theme + dev sessions"
    echo "  5) ${PURPLE}Claude Monitor${NC} - Live dashboard for Claude Code instances"
    echo "  6) ${CYAN}Verify Setup${NC} - Check what's already installed"
    echo "  7) Exit"
    echo ""
}

# Run dev environment setup
run_dev_setup() {
    print_info "Starting development environment setup..."
    echo ""
    
    if [ -f "$SCRIPT_DIR/scripts/setup-dev-env.sh" ]; then
        bash "$SCRIPT_DIR/scripts/setup-dev-env.sh"
    else
        print_error "setup-dev-env.sh not found!"
        exit 1
    fi
}

# Run terminal setup
run_terminal_setup() {
    print_info "Starting terminal customization..."
    echo ""
    
    if [ -f "$SCRIPT_DIR/scripts/pimp-my-terminal.sh" ]; then
        bash "$SCRIPT_DIR/scripts/pimp-my-terminal.sh"
    else
        print_error "pimp-my-terminal.sh not found!"
        exit 1
    fi
}

# Run tmux setup
run_tmux_setup() {
    print_info "Starting terminal multiplexer setup..."
    echo ""

    if [ -f "$SCRIPT_DIR/scripts/setup-tmux.sh" ]; then
        bash "$SCRIPT_DIR/scripts/setup-tmux.sh"
    else
        print_error "setup-tmux.sh not found!"
        exit 1
    fi
}

# Run Claude Monitor setup
run_claude_monitor_setup() {
    print_info "Starting Claude Monitor setup..."
    echo ""

    if [ -f "$SCRIPT_DIR/scripts/setup-claude-monitor.sh" ]; then
        bash "$SCRIPT_DIR/scripts/setup-claude-monitor.sh"
    else
        print_error "setup-claude-monitor.sh not found!"
        exit 1
    fi
}

# Run verification
run_verification() {
    print_info "Verifying your setup..."
    echo ""
    
    if [ -f "$SCRIPT_DIR/scripts/verify-setup.sh" ]; then
        bash "$SCRIPT_DIR/scripts/verify-setup.sh"
    else
        print_error "verify-setup.sh not found!"
        exit 1
    fi
}

# Main execution
main() {
    detect_os
    print_header

    if [[ "$OS_TYPE" == "linux" ]]; then
        print_info "Running on Linux. Options 1-4, 6 require macOS; Claude Monitor (5) works on Linux."
    else
        print_info "This script will help you set up a complete development environment on macOS."
    fi
    echo ""
    
    show_menu
    
    read -p "Enter your choice (1-7): " choice

    case $choice in
        1)
            require_macos || { main; return; }
            echo ""
            echo -e "${GREEN}${SPARKLES} Full Setup Selected${NC}"
            echo ""
            run_dev_setup
            echo ""
            run_terminal_setup
            echo ""
            run_tmux_setup
            ;;
        2)
            require_macos || { main; return; }
            echo ""
            echo -e "${BLUE}${WRENCH} Dev Environment Setup Selected${NC}"
            echo ""
            run_dev_setup
            ;;
        3)
            require_macos || { main; return; }
            echo ""
            echo -e "${PURPLE}${SPARKLES} Terminal Customization Selected${NC}"
            echo ""
            run_terminal_setup
            ;;
        4)
            require_macos || { main; return; }
            echo ""
            echo -e "${YELLOW}🖥️  Multiplexer Setup Selected${NC}"
            echo ""
            run_tmux_setup
            ;;
        5)
            echo ""
            echo -e "${PURPLE}📊 Claude Monitor Setup Selected${NC}"
            echo ""
            run_claude_monitor_setup
            ;;
        6)
            echo ""
            run_verification
            ;;
        7)
            echo ""
            print_info "Goodbye! 👋"
            exit 0
            ;;
        *)
            echo ""
            print_error "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              ${SPARKLES}  Setup Complete! ${SPARKLES}                         ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_info "📖 Check the docs/ folder for detailed guides and documentation."
    echo ""
}

# Run the script
main

