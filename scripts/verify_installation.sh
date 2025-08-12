#!/bin/bash
# Installation Verification Script
# Checks that the modular shell system is properly installed

echo "==================================="
echo "Shell Module Installation Check"
echo "==================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ERRORS=0

# Function to check if a file exists
check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (missing: $file)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check if a directory exists
check_dir() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (missing: $dir)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Function to check if a command is available
check_command() {
    local cmd="$1"
    local description="$2"
    
    if command -v "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (command not found: $cmd)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

echo "Checking core files..."
check_file "$HOME/.zshrc" ".zshrc installed"
check_file "$HOME/.aliases" ".aliases installed"

echo ""
echo "Checking shell modules directory structure..."
BASE_DIR="$HOME/GitHub/matthewmyrick/dotfiles/scripts"
check_dir "$BASE_DIR/shell" "Shell modules base directory"
check_dir "$BASE_DIR/shell/profiling" "Profiling module directory"
check_dir "$BASE_DIR/shell/git" "Git module directory"
check_dir "$BASE_DIR/shell/navigation" "Navigation module directory"
check_dir "$BASE_DIR/shell/utilities" "Utilities module directory"
check_dir "$BASE_DIR/shell/network" "Network module directory"
check_dir "$BASE_DIR/shell/prompt" "Prompt module directory"

echo ""
echo "Checking module files..."
check_file "$BASE_DIR/shell/loader.sh" "Module loader script"
check_file "$BASE_DIR/shell/profiling/zprof.sh" "Zprof profiling functions"
check_file "$BASE_DIR/shell/profiling/telemetry.sh" "Telemetry functions"
check_file "$BASE_DIR/shell/git/functions.sh" "Git functions"
check_file "$BASE_DIR/shell/navigation/finders.sh" "Navigation functions"
check_file "$BASE_DIR/shell/utilities/general.sh" "General utilities"
check_file "$BASE_DIR/shell/utilities/warp.sh" "Warp terminal functions"
check_file "$BASE_DIR/shell/network/api.sh" "Network/API functions"
check_file "$BASE_DIR/shell/prompt/config.sh" "Prompt configuration"

echo ""
echo "Checking required commands..."
check_command "fzf" "fzf (fuzzy finder)"
check_command "fd" "fd (file finder)"
check_command "eza" "eza (ls replacement)"
check_command "bat" "bat (cat replacement)"
check_command "rg" "ripgrep"
check_command "gh" "GitHub CLI"
check_command "jq" "jq (JSON processor)"

echo ""
echo "Checking optional commands..."
check_command "yazi" "yazi (file manager)" || echo -e "  ${YELLOW}→ Optional: Install with 'brew install yazi'${NC}"
check_command "jqp" "jqp (JSON viewer)" || echo -e "  ${YELLOW}→ Optional: Install with 'brew install noahgorstein/tap/jqp'${NC}"
check_command "rich" "rich (Python formatter)" || echo -e "  ${YELLOW}→ Optional: Install with 'pip3 install --user rich'${NC}"
check_command "delta" "delta (diff viewer)" || echo -e "  ${YELLOW}→ Optional: Install with 'brew install git-delta'${NC}"
check_command "xmlstarlet" "xmlstarlet (XML processor)" || echo -e "  ${YELLOW}→ Optional: Install with 'brew install xmlstarlet'${NC}"

echo ""
echo "Checking Python support files..."
if [ -f "$HOME/.config/zsh/scripts/telemetry_formatter.py" ]; then
    echo -e "${GREEN}✓${NC} Telemetry formatter installed"
else
    if [ -f "$BASE_DIR/python/telemetry.py" ]; then
        echo -e "${YELLOW}⚠${NC} Telemetry formatter found but not installed"
        echo "  → Run: cp $BASE_DIR/python/telemetry.py ~/.config/zsh/scripts/telemetry_formatter.py"
    else
        echo -e "${YELLOW}⚠${NC} Telemetry formatter not found"
    fi
fi

echo ""
echo "==================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "To test the installation:"
    echo "  1. Start a new shell or run: source ~/.zshrc"
    echo "  2. Try these commands:"
    echo "     - shell_modules    (list available modules)"
    echo "     - shell_loaded     (show loaded modules)"
    echo "     - ff              (fuzzy finder - will auto-load)"
    echo "     - ghc google      (clone GitHub repo - will auto-load)"
else
    echo -e "${RED}✗ Found $ERRORS issue(s)${NC}"
    echo ""
    echo "To fix:"
    echo "  1. Run the install script: ./install.sh"
    echo "  2. Install missing commands with Homebrew"
fi
echo "===================================="