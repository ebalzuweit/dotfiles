#!/usr/bin/env zsh
# Prompt Configuration
# Custom prompt setup - always loaded for shell appearance

# Note: No lazy load guard here as prompt needs to be always available

# Source git functions for prompt (lightweight, needed for prompt)
source "$HOME/GitHub/matthewmyrick/dotfiles/scripts/shell/git/functions.sh"

# --- Prompt Configuration ---
prompt_header() {
    local header='%B';

    header+='%F{166}%n%f'; # username
    header+=' at ';
    header+='%F{136}%m%f'; # host
    header+=' in ';
    header+='%F{64}%~%f'; # working directory
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        # add git info if the current directory is in a repo
        header+=' on ';
        header+='%F{61}$(git_branch)%f'; # git branch
        header+='%F{33}$(git_status)%f'; # git status
    fi
    header+='%b';

    echo -e "${header}";
}

# prompt
precmd() {
    echo # add newline before prompt header
    print -rP "$(prompt_header)"
}

PROMPT="%B%F{15}$%f%b ";
PS2="%B%F{136}→%f%b ";