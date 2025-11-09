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

# Check if running on macOS
check_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Main menu
show_menu() {
    echo -e "${YELLOW}What would you like to set up?${NC}"
    echo ""
    echo "  1) ${GREEN}Full Setup${NC} - Development tools + Terminal customization"
    echo "  2) ${BLUE}Dev Environment Only${NC} - Essential development tools"
    echo "  3) ${PURPLE}Terminal Only${NC} - Beautiful terminal setup"
    echo "  4) ${CYAN}Verify Setup${NC} - Check what's already installed"
    echo "  5) Exit"
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
    check_os
    print_header
    
    print_info "This script will help you set up a complete development environment on macOS."
    echo ""
    
    show_menu
    
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            echo ""
            echo -e "${GREEN}${SPARKLES} Full Setup Selected${NC}"
            echo ""
            run_dev_setup
            echo ""
            run_terminal_setup
            ;;
        2)
            echo ""
            echo -e "${BLUE}${WRENCH} Dev Environment Setup Selected${NC}"
            echo ""
            run_dev_setup
            ;;
        3)
            echo ""
            echo -e "${PURPLE}${SPARKLES} Terminal Customization Selected${NC}"
            echo ""
            run_terminal_setup
            ;;
        4)
            echo ""
            run_verification
            ;;
        5)
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

