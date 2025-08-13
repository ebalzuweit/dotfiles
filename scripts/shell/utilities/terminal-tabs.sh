#!/usr/bin/env zsh
# Terminal Tab Functions
# Functions for managing terminal tabs with colors (works with Kitty, Warp, and other terminals)

# Lazy load guard
[[ -n "${_TERMINAL_TABS_LOADED}" ]] && return
_TERMINAL_TABS_LOADED=1

# --- Terminal Tab Functions ---
# ttn (Terminal Tab Name) - Set terminal tab name with a random color ball emoji
# Usage: ttn "Custom Name" or just ttn (uses current directory/repo name)
function ttn () {
  local tab_name="${1:-$(basename "$PWD")}"
  
  # Array of color ball emojis
  local color_balls=("🔴" "🟠" "🟡" "🟢" "🔵" "🟣" "🟤" "⚫" "⚪" "🟦" "🟧" "🟨" "🟩" "🟪" "🟫")
  
  # Get a random color ball (ZSH arrays are 1-indexed)
  local random_index=$((RANDOM % ${#color_balls[@]} + 1))
  local color_ball="${color_balls[$random_index]}"
  
  # Set the tab title with the color ball
  echo -ne "\033]0;${color_ball} ${tab_name}\007"
}

# tatn (Terminal Auto Tab Name) - Automatically set tab name on every prompt
# This runs automatically to keep the tab name updated with the current directory
function tatn () {
  ttn
}

# Note: The precmd_functions addition is handled in the main loader