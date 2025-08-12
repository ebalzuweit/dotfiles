#!/usr/bin/env zsh
# General Utility Functions
# Various helper functions for daily tasks

# Lazy load guard
[[ -n "${_UTILITIES_LOADED}" ]] && return
_UTILITIES_LOADED=1

# Toggle Netskope on/off (macOS specific)
togglenetskope() {
    # check if Netskope directory exists in /Library/Application Support and if does, move it to /Library/Application Support/Netskope_disabled
    if [ -d "/Library/Application Support/Netskope" ]
    then
        sudo mv /Library/Application\ Support/Netskope /Library/Application\ Support/Netskope_disabled
        echo "Netskope will shortly be disabled!"
    else
        sudo mv /Library/Application\ Support/Netskope_disabled /Library/Application\ Support/Netskope
        echo "Netskope will shortly be enabled!"
    fi

    pids=$(ps aux | grep Netskope | grep -v grep | awk '{print $2}')

    # go through each pid and kill it
    while IFS= read -r pid; do
        sudo kill -9 "$pid"
        echo $?
    done <<< "$pids"
}

# A function to read XML files with formatting and syntax highlighting
r_xml() {
  # Check if a filename was provided
  if [ -z "$1" ]; then
    echo "Usage: r_xml <filename.xml>"
    return 1
  fi

  # Format the file with xmlstarlet and pipe to bat
  xmlstarlet format "$1" | bat -l xml --paging=always
}

# Kill process using a specific port
k_port() {
    if [ -z "$1" ]; then
        echo "Usage: k_port <port>"
        echo "Example: k_port 8080"
        return 1
    fi
    
    local port="$1"
    
    # Find PIDs using the port
    local pids=$(lsof -ti :$port 2>/dev/null)
    
    if [ -z "$pids" ]; then
        echo "No process found using port $port"
        return 0
    fi
    
    # Show what processes will be killed
    echo "Found processes using port $port:"
    lsof -i :$port
    echo ""
    
    # Kill each PID
    echo "$pids" | while read -r pid; do
        if kill -9 "$pid" 2>/dev/null; then
            echo "✅ Killed process $pid"
        else
            echo "❌ Failed to kill process $pid (might need sudo)"
        fi
    done
    
    # Verify port is free
    sleep 1
    if lsof -ti :$port >/dev/null 2>&1; then
        echo ""
        echo "⚠️  Some processes still using port $port. Try running with sudo:"
        echo "sudo k_port $port"
    else
        echo ""
        echo "✅ Port $port is now free"
    fi
}

# A powerful, interactive Homebrew TUI using fzf and delta
# Usage: brewf [install|uninstall|info]
brewf() {
    # The default action is 'info'
    local action=${1:-info}

    if [[ "$action" == "install" ]]; then
        # This part for installing new packages is the same
        local selection=$(brew search | fzf --height=40% --border=rounded --prompt="Install> ")
        if [[ -n "$selection" ]]; then
            brew install "$selection"
        fi
    else
        # This part for acting on INSTALLED packages has been corrected
        local selection=$(brew list --formula -1 | fzf --height=40% --border=rounded --prompt="Select> " \
            --preview 'brew info {} | delta' \
            --preview-window 'right:60%:border-sharp')

        # This logic runs *after* you press Enter in fzf and a selection is made
        if [[ -n "$selection" ]]; then
            if [[ "$action" == "info" ]]; then
                # The info was already in the preview, so we don't need to do anything here.
                # The function will just exit cleanly after you press Enter.
                : # The ':' command is a "no-op", which means "do nothing".
            elif [[ "$action" == "uninstall" ]]; then
                # If the action was 'uninstall', run the command on the selection.
                brew uninstall "$selection"
            fi
        fi
    fi
}