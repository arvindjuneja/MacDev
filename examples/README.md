# 📝 Example Scripts

This folder contains example scripts that show how to create project-specific automation.

## Files

### `start_dev.sh`
An example interactive menu script for a specific project (cmdashboard). This demonstrates how to:
- Create an interactive development menu
- Start backend and frontend servers
- Manage dependencies
- Handle deployments

### `verify_setup_project.sh`
An example verification script for a specific project. Shows how to:
- Check project-specific dependencies
- Verify virtual environments
- Check for configuration files

## Usage

These are **examples** meant to inspire your own project-specific scripts. You'll need to:

1. **Copy** the script you want to use
2. **Modify** it for your project structure
3. **Update** paths and project-specific commands
4. **Test** it in your project

## Creating Your Own Script

### Project Startup Script Template

```bash
#!/bin/bash

# Navigate to your project
cd /path/to/your/project

# Setup environment
source venv/bin/activate  # If using Python

# Show menu
echo "1) Start Backend"
echo "2) Start Frontend"
# ... more options

read -p "Choice: " choice

case $choice in
    1)
        # Your backend command
        python app.py
        ;;
    2)
        # Your frontend command
        npm run dev
        ;;
esac
```

## Tips

- Make scripts executable: `chmod +x your-script.sh`
- Use absolute paths or change directory at the start
- Add error handling with `set -e`
- Use colors for better UX (see examples)
- Test scripts before committing

## Integration with Main Setup

These project-specific scripts are separate from the main setup scripts in the `scripts/` folder, which are generic and reusable across different projects.

