#!/usr/bin/env zsh
# Azure Key Vault tools

# azv - Azure Key Vault fuzzy finder
azv() {
    local script_path="${HOME}/GitHub/matthewmyrick/dotfiles/scripts/azv"
    
    if [[ ! -f "$script_path" ]]; then
        echo "Error: azv script not found at $script_path"
        return 1
    fi
    
    if [[ ! -x "$script_path" ]]; then
        echo "Error: azv script is not executable"
        return 1
    fi
    
    "$script_path" "$@"
}