#!/bin/bash

# Quick Start Development Script
# This script sets up the environment and provides options to start development

# Setup environment
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 Development Environment Quick Start${NC}"
echo "========================================"
echo ""

# Navigate to project directory
cd ~/projects/myapp  # Change to your project path

echo "What would you like to do?"
echo ""
echo "1) Start Python Backend (Flask)"
echo "2) Start React Frontend (Vite dev server)"
echo "3) Start Both (Backend + Frontend)"
echo "4) Just activate Python virtual environment"
echo "5) Install/Update dependencies"
echo "6) Run verification script"
echo "7) Deploy to Firebase"
echo "8) Exit"
echo ""

read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        echo -e "${BLUE}Starting Flask backend...${NC}"
        source venv/bin/activate
        python app.py
        ;;
    2)
        echo -e "${BLUE}Starting React frontend...${NC}"
        cd cmdashboard-react
        npm run dev
        ;;
    3)
        echo -e "${BLUE}Starting both backend and frontend...${NC}"
        source venv/bin/activate
        python app.py &
        BACKEND_PID=$!
        cd cmdashboard-react
        npm run dev
        # When frontend stops, stop backend
        kill $BACKEND_PID
        ;;
    4)
        echo -e "${BLUE}Activating Python virtual environment...${NC}"
        echo ""
        echo "Run: source venv/bin/activate"
        echo "Then you can run Python commands"
        ;;
    5)
        echo -e "${BLUE}Installing/Updating dependencies...${NC}"
        echo ""
        echo "Updating Python packages..."
        source venv/bin/activate
        pip install -r requirements.txt --upgrade
        deactivate
        echo ""
        echo "Updating Node packages..."
        cd cmdashboard-react
        npm install
        cd ..
        echo -e "${GREEN}✓ Dependencies updated!${NC}"
        ;;
    6)
        echo -e "${BLUE}Running verification script...${NC}"
        echo ""
        ./verify_setup.sh
        ;;
    7)
        echo -e "${BLUE}Deploying to Firebase...${NC}"
        echo ""
        echo "What would you like to deploy?"
        echo "1) Frontend only"
        echo "2) Cloud Functions only"
        echo "3) Everything"
        read -p "Enter choice: " deploy_choice
        
        case $deploy_choice in
            1)
                ./deploy-frontend.sh
                ;;
            2)
                cd cloud_functions
                ./deploy.sh
                ;;
            3)
                ./deploy-all.sh
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
        ;;
    8)
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Invalid choice. Please run the script again.${NC}"
        ;;
esac

