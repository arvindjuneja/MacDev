#!/bin/bash

# Development Environment Verification Script
# This script checks that all required tools are properly installed

echo "🔍 Verifying Development Environment..."
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall success
ALL_OK=true

# Function to check if command exists
check_command() {
    local cmd=$1
    local name=$2
    local version_flag=$3
    
    if command -v $cmd &> /dev/null; then
        local version=$($cmd $version_flag 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $name: $version"
    else
        echo -e "${RED}✗${NC} $name: Not found"
        ALL_OK=false
    fi
}

# Check Homebrew
echo "Core Tools:"
echo "-----------"
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew_version=$(brew --version | head -n1)
    echo -e "${GREEN}✓${NC} Homebrew: $brew_version"
else
    echo -e "${RED}✗${NC} Homebrew: Not found"
    ALL_OK=false
fi

# Check other tools
check_command "git" "Git" "--version"
check_command "python3" "Python" "--version"
check_command "pip3" "pip" "--version"
check_command "pyenv" "pyenv" "--version"
check_command "node" "Node.js" "--version"
check_command "npm" "npm" "--version"
check_command "firebase" "Firebase CLI" "--version"

echo ""
echo "Utilities:"
echo "----------"
check_command "tree" "tree" "--version"
check_command "jq" "jq" "--version"
check_command "wget" "wget" "--version"

echo ""
echo "Project Specific:"
echo "-----------------"

# Check virtual environment
if [ -d "venv" ]; then
    echo -e "${GREEN}✓${NC} Python virtual environment: Found"
    
    # Check if venv has packages
    if [ -f "venv/bin/python" ]; then
        source venv/bin/activate
        pkg_count=$(pip list 2>/dev/null | wc -l)
        echo -e "${GREEN}✓${NC} Installed Python packages: $pkg_count packages"
        deactivate
    fi
else
    echo -e "${YELLOW}!${NC} Python virtual environment: Not found (run: virtualenv venv)"
fi

# Check node_modules
if [ -d "cmdashboard-react/node_modules" ]; then
    pkg_count=$(ls cmdashboard-react/node_modules | wc -l)
    echo -e "${GREEN}✓${NC} Node modules: $pkg_count packages installed"
else
    echo -e "${YELLOW}!${NC} Node modules: Not found (run: cd cmdashboard-react && npm install)"
fi

# Check for .env file
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} Environment file: .env found"
elif [ -f "env.example" ]; then
    echo -e "${YELLOW}!${NC} Environment file: .env not found (copy from env.example)"
else
    echo -e "${YELLOW}!${NC} Environment file: Not configured"
fi

echo ""
echo "========================================"
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}✓ All core tools are installed correctly!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Activate virtual environment: source venv/bin/activate"
    echo "2. Configure .env file with your API keys"
    echo "3. Run the development server"
else
    echo -e "${RED}✗ Some tools are missing. Please install them.${NC}"
    echo ""
    echo "Refer to DEV_ENVIRONMENT_SETUP.md for installation instructions."
fi
echo ""

