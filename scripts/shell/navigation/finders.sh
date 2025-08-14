#!/usr/bin/env zsh
# Navigation and Finder Functions
# Interactive file and directory navigation tools

# Lazy load guard
[[ -n "${_NAVIGATION_LOADED}" ]] && return
_NAVIGATION_LOADED=1

# GIT_ROOT is a global variable, so 'local' is not used here.
GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

# A powerful, context-aware project finder that displays clean, relative paths.
# If run inside a git repository, it searches only within that project.
# Otherwise, it searches from your home directory.
# Usage: Type 'ff' in your terminal and press Enter.
ff() {
    # Attempt to find the root of the current git repository. 
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    local search_path
    # Check if we are inside a git repository.
    if [[ -n "$git_root" ]]; then
        # If yes, set the search path to the project's root directory.
        search_path="$git_root"
    else
        # If no, fall back to searching from the home directory.
        search_path="$HOME"
    fi

    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FF_SEARCH_PATH="$search_path"

    # Find directories, strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FF_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'Project Finder | Press Enter to select')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        # Change the current directory of your terminal to that full path.
        cd "$full_path" || return
        # Optional: clear the screen and show a tree of the new location.
        clear
        eza --tree --icons=always --level=2 # Corrected eza flag
    fi
}

ffn() {
    # Attempt to find the root of the current git repository. 
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    local search_path
    # Check if we are inside a git repository.
    if [[ -n "$git_root" ]]; then
        # If yes, set the search path to the project's root directory.
        search_path="$git_root"
    else
        # If no, fall back to searching from the home directory.
        search_path="$HOME"
    fi

    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FF_SEARCH_PATH="$search_path"

    # Find directories, strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FF_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'Project Finder | Press Enter to select')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        cd "$full_path"
        # Get the name of the current directory to use as the session name.
        # We replace periods with underscores as they can be problematic in session names.
        local session_name=$(basename "$PWD" | tr '.' '_')
        nvim .
    fi
}

# Function: fch (Fuzzy Command History)
# Description:
#   Launches an interactive fzf session to search through your entire Zsh history.
#   Allows fuzzy matching, navigation with arrow keys, and immediate execution
#   of the selected command upon pressing Enter.
#   The display and matching behavior will be similar to your 'ff' command.
#
# Usage:
#   Type 'fch' in your terminal and press Enter.
#   Inside the fzf window:
#     - Type any part of a command to fuzzy-filter the history.
#     - Use Up/Down arrow keys to navigate the filtered list.
#     - Press Enter to execute the highlighted command.
#     - Press Ctrl+Y to paste the command to the prompt for editing.
#     - Press Esc or Ctrl+C to cancel and return to the prompt.
fch() {
    local selected_command

    # Get the entire history list (fc -l 1) and remove the leading history number
    # (e.g., "   123  ls -la" becomes "ls -la") for cleaner fzf display.
    selected_command=$( \
        fc -l 1 | \
        sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | \
        fzf \
            --no-sort \
            --height '80%' \
            --border 'rounded' \
            --header 'Fuzzy History Search | Enter to execute, Ctrl+Y to paste' \
            --ansi # Enable ANSI color codes in fzf if your history has them
    )

    # If a command was selected (user pressed Enter in fzf)
    if [[ -n "$selected_command" ]]; then
        # Print the command to the terminal before executing it, for clarity.
        # This makes it clear what command is about to run.
        echo "$selected_command"
        # Execute the selected command.
        # 'eval' is necessary to run the string as a shell command.
        eval "$selected_command"
    fi
}

# fft (Fuzzy Find Terraform) - Find directories containing .tf files and run terraform plan
# Usage: Type 'fft' in your terminal and press Enter.
fft() {
    # Attempt to find the root of the current git repository. 
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    local search_path
    # Check if we are inside a git repository.
    if [[ -n "$git_root" ]]; then
        # If yes, set the search path to the project's root directory.
        search_path="$git_root"
    else
        # If no, fall back to searching from the home directory.
        search_path="$HOME"
    fi

    # Find directories that contain .tf files
    local tf_dirs
    tf_dirs=$(find "$search_path" -name "*.tf" -type f -exec dirname {} \; 2>/dev/null | sort -u)
    
    # Check if any Terraform directories were found
    if [[ -z "$tf_dirs" ]]; then
        echo "No directories with .tf files found in $search_path"
        return 1
    fi
    
    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFT_SEARCH_PATH="$search_path"

    # Strip the base path for a clean display and pipe to fzf
    local selected_relative_path
    selected_relative_path=$(echo "$tf_dirs" | sed "s|^$search_path/||" | fzf \
        --preview "echo 'Terraform files in this directory:' && find \"$FZF_FFT_SEARCH_PATH\"/{} -name '*.tf' -type f -exec basename {} \\; 2>/dev/null | sort" \
        --preview-window 'right:50%' \
        --height '80%' \
        --border 'rounded' \
        --header 'Terraform Finder | Press Enter to cd and run terraform plan')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        
        # Change to the selected directory
        echo "Changing to: $full_path"
        cd "$full_path" || return 1
        
        # Clear screen and show current location
        clear
        echo "📁 Current directory: $(pwd)"
        echo "🔍 Terraform files found:"
        find . -name "*.tf" -type f -exec basename {} \; | sort
        echo ""
        
        # Run terraform init and plan
        echo "🚀 Running terraform init && terraform plan..."
        echo "────────────────────────────────────────"
        terraform init && terraform plan
    fi
}

# fftg (Fuzzy Find Terragrunt) - Find directories containing .hcl files and run terragrunt plan
# Usage: Type 'fftg' in your terminal and press Enter.
fftg() {
    # Attempt to find the root of the current git repository. 
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    local search_path
    # Check if we are inside a git repository.
    if [[ -n "$git_root" ]]; then
        # If yes, set the search path to the project's root directory.
        search_path="$git_root"
    else
        # If no, fall back to searching from the home directory.
        search_path="$HOME"
    fi

    # Find directories that contain .hcl files
    local hcl_dirs
    hcl_dirs=$(find "$search_path" -name "*.hcl" -type f -exec dirname {} \; 2>/dev/null | sort -u)
    
    # Check if any Terragrunt directories were found
    if [[ -z "$hcl_dirs" ]]; then
        echo "No directories with .hcl files found in $search_path"
        return 1
    fi
    
    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFTG_SEARCH_PATH="$search_path"

    # Strip the base path for a clean display and pipe to fzf
    local selected_relative_path
    selected_relative_path=$(echo "$hcl_dirs" | sed "s|^$search_path/||" | fzf \
        --preview "echo 'Terragrunt files in this directory:' && find \"$FZF_FFTG_SEARCH_PATH\"/{} -name '*.hcl' -type f -exec basename {} \\; 2>/dev/null | sort" \
        --preview-window 'right:50%' \
        --height '80%' \
        --border 'rounded' \
        --header 'Terragrunt Finder | Press Enter to cd and run terragrunt plan')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        
        # Change to the selected directory
        echo "Changing to: $full_path"
        cd "$full_path" || return 1
        
        # Clear screen and show current location
        clear
        echo "📁 Current directory: $(pwd)"
        echo "🔍 Terragrunt files found:"
        find . -name "*.hcl" -type f -exec basename {} \; | sort
        echo ""
        
        # Run terragrunt plan
        echo "🚀 Running terragrunt plan..."
        echo "────────────────────────────────────────"
        terragrunt plan
    fi
}

# Yazi file manager integration
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if [ -f "$tmp" ]; then
        cwd=$(cat "$tmp")
    fi
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}