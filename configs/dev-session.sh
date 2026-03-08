#!/bin/bash

# ============================================
# Dev Session - tmux layout for Claude Code workflow
# ============================================
# Creates a pre-configured tmux session with:
#   - Top-left (65% w, 80% h): Claude Code
#   - Bottom-left (65% w, 20% h): Claude Monitor
#   - Top-right: Dev server (npm run dev, etc.)
#   - Bottom-right: System monitor (btop/htop)
#
# Usage:
#   dev-session                          # uses current dir, auto-names session
#   dev-session [project-path]           # uses given path
#   dev-session [session-name] [path]    # explicit name + path
#   dev-session --monitor=btop           # override system monitor
#
# Aliases (add to .zshrc):
#   alias sc='dev-session'               # just type: sc
# ============================================

# Parse flags first
MONITOR_OVERRIDE=""
POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        --monitor=*) MONITOR_OVERRIDE="${arg#--monitor=}" ;;
        *) POSITIONAL+=("$arg") ;;
    esac
done

# Smart argument handling:
#   0 args: session name = folder name, path = current dir
#   1 arg:  if it's a directory, use it as path + derive name; otherwise use as session name
#   2 args: first = session name, second = path
if [ ${#POSITIONAL[@]} -eq 0 ]; then
    PROJECT_DIR="$(pwd)"
    SESSION_NAME="$(basename "$PROJECT_DIR")"
elif [ ${#POSITIONAL[@]} -eq 1 ]; then
    if [ -d "${POSITIONAL[0]}" ]; then
        PROJECT_DIR="$(cd "${POSITIONAL[0]}" && pwd)"
        SESSION_NAME="$(basename "$PROJECT_DIR")"
    else
        SESSION_NAME="${POSITIONAL[0]}"
        PROJECT_DIR="$(pwd)"
    fi
else
    SESSION_NAME="${POSITIONAL[0]}"
    PROJECT_DIR="${POSITIONAL[1]}"
fi

# tmux session names can't contain dots
SESSION_NAME="${SESSION_NAME//./-}"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}tmux is not installed. Run scripts/setup-tmux.sh first.${NC}"
    exit 1
fi

# If already inside tmux, warn
if [ -n "$TMUX" ]; then
    echo -e "${YELLOW}Already inside a tmux session.${NC}"
    echo "Use 'Ctrl+a d' to detach first, or run from outside tmux."
    exit 1
fi

# Kill existing session with same name (if any)
tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME"

# Determine monitor command (claude-monitor > btop > htop > top)
if [ -n "$MONITOR_OVERRIDE" ]; then
    MONITOR_CMD="$MONITOR_OVERRIDE"
elif command -v claude-monitor &> /dev/null; then
    MONITOR_CMD="claude-monitor"
elif command -v btop &> /dev/null; then
    MONITOR_CMD="btop"
elif command -v htop &> /dev/null; then
    MONITOR_CMD="htop"
else
    MONITOR_CMD="top"
fi

echo -e "${CYAN}Starting dev session: ${GREEN}$SESSION_NAME${NC}"
echo -e "${CYAN}Project directory:    ${GREEN}$PROJECT_DIR${NC}"
echo ""

# ┌────────────────────────┬──────────────────┐
# │                        │   Dev Server     │
# │    Claude Code         │   (npm run dev)  │
# │    (80% height)        ├──────────────────┤
# │                        │   Monitoring     │
# ├────────────────────────┤   (btop)         │
# │    Claude Monitor      │                  │
# │    (20% height)        │                  │
# └────────────────────────┴──────────────────┘
#         65% width              35% width

# Determine claude-monitor command for bottom-left pane
if command -v claude-monitor &> /dev/null; then
    CLAUDE_MONITOR_CMD="claude-monitor"
else
    CLAUDE_MONITOR_CMD=""
fi

# Create session with first window (this becomes the left/main pane)
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR" -x "$(tput cols)" -y "$(tput lines)"

# Split right sidebar (35% width)
tmux split-window -h -p 35 -c "$PROJECT_DIR"

# Split right pane top/bottom (50/50)
tmux split-window -v -p 50 -c "$PROJECT_DIR"

# Split left pane to add Claude Monitor at bottom (20% height)
# Note: pane-base-index is 1 in tmux.conf, so panes start at 1
tmux select-pane -t "$SESSION_NAME:1.1"
tmux split-window -v -p 20 -c "$PROJECT_DIR"

# Pane layout after splits (pane-base-index=1):
#   pane 1 = top-left (Claude Code)
#   pane 2 = bottom-left (Claude Monitor)
#   pane 3 = top-right (dev server)
#   pane 4 = bottom-right (system monitor)

# Pane 1 (top-left): Claude Code (auto-launch)
tmux send-keys -t "$SESSION_NAME:1.1" "cd '$PROJECT_DIR' && clear && claude" C-m

# Pane 2 (bottom-left): Claude Monitor
if [ -n "$CLAUDE_MONITOR_CMD" ]; then
    tmux send-keys -t "$SESSION_NAME:1.2" "$CLAUDE_MONITOR_CMD --compact" C-m
else
    tmux send-keys -t "$SESSION_NAME:1.2" "cd '$PROJECT_DIR' && clear && echo 'Install claude-monitor for live dashboard here'" C-m
fi

# Pane 3 (top-right): dev server
tmux send-keys -t "$SESSION_NAME:1.3" "cd '$PROJECT_DIR' && clear && echo 'Dev server pane - run your server here (e.g., npm run dev)'" C-m

# Pane 4 (bottom-right): system monitor
tmux send-keys -t "$SESSION_NAME:1.4" "$MONITOR_CMD" C-m

# Select Claude Code pane (top-left)
tmux select-pane -t "$SESSION_NAME:1.1"

# Rename window
tmux rename-window -t "$SESSION_NAME:1" "workspace"

# Attach to session
echo -e "${GREEN}Attaching to session...${NC}"
tmux attach-session -t "$SESSION_NAME"
