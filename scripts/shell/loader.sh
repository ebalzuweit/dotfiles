#!/usr/bin/env zsh
# Shell Module Loader
# Simple, reliable loading of all shell functions

# Base directory for shell modules
SHELL_MODULES_DIR="${HOME}/GitHub/matthewmyrick/dotfiles/scripts/shell"

# Function to load all shell modules
load_shell_modules() {
    local module_dir="$SHELL_MODULES_DIR"
    
    # Check if modules directory exists
    if [[ ! -d "$module_dir" ]]; then
        echo "⚠️  Shell modules directory not found: $module_dir" >&2
        return 1
    fi
    
    # Find and source all .sh files in subdirectories
    # Exclude the loader.sh file itself to avoid recursion
    local files=($(find "$module_dir" -name "*.sh" -not -name "loader.sh" -not -name "README.md" 2>/dev/null))
    
    for file in "${files[@]}"; do
        if [[ -f "$file" && -r "$file" ]]; then
            # Get relative path for cleaner output
            local rel_path="${file#$module_dir/}"
            source "$file"
        fi
    done
}

# Load all modules immediately
load_shell_modules

# --- CONDITIONAL LOADING: Terminal-specific features ---
# Terminal tab functions work with multiple terminals (Kitty, Warp, etc.)
# Add the auto function to precmd_functions for automatic updates
if [[ ! " ${precmd_functions[@]} " =~ " tatn " ]]; then
    precmd_functions+=(tatn)
fi

# --- MODULE MANAGEMENT FUNCTIONS ---

# List all available shell modules
shell_modules() {
    echo "Available shell modules:"
    echo "  profiling  - Performance profiling tools (zprofile_on, pzprof, etc.)"
    echo "  git        - Git utilities and helpers (ghc, ffgn, fpr)"
    echo "  navigation - File/directory navigation tools (ff, ffn, fch, y)"
    echo "  utilities  - General utility functions (k_port, brewf, togglenetskope, etc.)"
    echo "  network    - Network and API tools (add_req, curl_with_jqp)"
    echo "  prompt     - Prompt configuration (always loaded)"
    echo ""
    echo "All modules are now loaded automatically at shell startup."
    echo "Use 'shell_loaded' to see what's available."
}

# Force reload all modules
shell_reload() {
    echo "Reloading all shell modules..."
    load_shell_modules
    echo "✓ All modules reloaded"
}

# Show which modules are currently loaded
shell_loaded() {
    echo "Loaded shell functions:"
    
    # Check for specific function availability
    command -v zprofile_on >/dev/null && echo "  ✓ profiling/zprof (zprofile_on, zprofile_off, pzprof)"
    command -v python_with_telemetry >/dev/null && echo "  ✓ profiling/telemetry (python_with_telemetry, lrp, lrg)" 
    command -v ghc >/dev/null && echo "  ✓ git/functions (ghc, ffgn, fpr, git_branch, git_status)"
    command -v ff >/dev/null && echo "  ✓ navigation/finders (ff, ffn, fch, y)"
    command -v togglenetskope >/dev/null && echo "  ✓ utilities/general (togglenetskope, r_xml, k_port, brewf)"
    command -v ttn >/dev/null && echo "  ✓ utilities/terminal-tabs (ttn, tatn)"
    command -v add_req >/dev/null && echo "  ✓ network/api (add_req, curl_with_jqp)"
    
    echo ""
    echo "Prompt functions are always available."
    echo "Run 'shell_modules' to see available commands."
}

# --- ALIASES AND SHORTCUTS ---
# Optional: Create shortcuts for common tasks
alias shell_help='shell_modules'
alias shell_status='shell_loaded'