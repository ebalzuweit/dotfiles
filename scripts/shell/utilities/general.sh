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

# Help command - Show all available aliases and custom commands with descriptions
help() {
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                         CUSTOM COMMANDS & ALIASES                            ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📁 NAVIGATION & DIRECTORIES"
    echo "  home          - Go to home directory"
    echo "  ..            - Go up one directory"
    echo "  ...           - Go up two directories"
    echo "  back          - Go to previous directory"
    echo "  root          - Go to root directory"
    echo "  repos         - Go to ~/source/repos"
    echo "  ff            - Fuzzy find directories (context-aware: git repo or home)"
    echo "  ffn           - Fuzzy find & open in Neovim"
    echo "  ffgn          - Fuzzy find GitHub repos & open in Neovim"
    echo "  fch           - Fuzzy search command history & execute"
    echo "  y             - Yazi file manager with directory change on exit"
    echo ""
    
    echo "📝 FILE OPERATIONS"
    echo "  ls            - Enhanced ls with icons, tree view (via eza)"
    echo "  cat           - Enhanced cat with syntax highlighting (via bat)"
    echo "  r_xml <file>  - Read & format XML files with syntax highlighting"
    echo ""
    
    echo "🔀 GIT COMMANDS"
    echo "  ga            - git add"
    echo "  gc <msg>      - git commit -m"
    echo "  gf            - git fetch"
    echo "  gs            - git status"
    echo "  push          - git push"
    echo "  pull          - git pull"
    echo "  gg            - Launch lazygit"
    echo ""
    
    echo "🐙 GITHUB OPERATIONS"
    echo "  ghrc [org]    - Clone repo from GitHub org interactively"
    echo "  ghpr [org] [repo] - Browse & open pull requests with metadata"
    echo "  ghpra <pr>    - Auto-approve PR with LGTM comment"
    echo "  ghro [org]    - Open GitHub repo in browser"
    echo "  ghra [org] [repo] - View GitHub Actions runs"
    echo "  fpr           - Find & open your own PRs"
    echo ""
    
    echo "🔧 UTILITIES"
    echo "  k_port <port> - Kill process using specified port"
    echo "  togglenetskope - Toggle Netskope on/off (macOS)"
    echo "  brewf [action] - Interactive Homebrew TUI (install/uninstall/info)"
    echo "  ttn [name]    - Set terminal tab name with colored emoji"
    echo "  tatn          - Auto-update terminal tab name (runs on each prompt)"
    echo ""
    
    echo "🌐 NETWORK & API"
    echo "  add_req <collection> <name> \"<curl>\" - Add curl to ATAC collection"
    echo "  curlj         - curl with auto JSON detection & jqp viewer"
    echo ""
    
    echo "☸️  KUBERNETES"
    echo "  k             - kubectl"
    echo "  ka            - kubectl apply -f . -R"
    echo "  kctx          - kubectx (context switcher)"
    echo "  kns           - kubens (namespace switcher)"
    echo ""
    
    echo "🏗️  TERRAFORM"
    echo "  tf            - terraform"
    echo "  tfa           - terraform apply"
    echo "  tfi           - terraform init"
    echo "  tfd           - terraform destroy"
    echo "  tfp           - terraform plan"
    echo "  tfs           - terraform show"
    echo "  tfv           - terraform validate"
    echo "  tfc           - terraform console"
    echo ""
    
    echo "📊 PROFILING & TELEMETRY"
    echo "  zprofile_on   - Enable zsh profiling"
    echo "  zprofile_off  - Show zsh profile results"
    echo "  pzprof        - Display formatted zsh profile"
    echo "  python_telemetry - Run python with telemetry"
    echo "  lrp           - View last Python run telemetry"
    echo "  lrg           - View last Go run telemetry"
    echo ""
    
    echo "🐳 CONTAINERS"
    echo "  dd            - Launch lazydocker"
    echo "  zj            - Launch zellij"
    echo ""
    
    echo "ℹ️  SHELL MANAGEMENT"
    echo "  shell_modules - List available shell modules"
    echo "  shell_reload  - Reload all shell modules"
    echo "  shell_loaded  - Show loaded shell functions"
    echo "  shell_help    - Show module information"
    echo "  shell_status  - Show loaded functions status"
    echo ""
    
    echo "💡 Tips:"
    echo "  • Most GitHub commands support interactive selection with fzf"
    echo "  • Use Tab for autocompletion on most commands"
    echo "  • Run 'man <command>' for detailed documentation on system commands"
    echo ""
}