#!/usr/bin/env zsh
# Warp Terminal Functions
# Functions specific to Warp terminal

# Lazy load guard
[[ -n "${_WARP_LOADED}" ]] && return
_WARP_LOADED=1

# --- Warp Terminal Tab Functions ---
# wtn (Warp Tab Name) - Set terminal tab name with a random color ball emoji
# Usage: wtn "Custom Name" or just wtn (uses current directory/repo name)
function wtn () {
  local tab_name="${1:-$(basename "$PWD")}"
  
  # Array of color ball emojis
  local color_balls=("🔴" "🟠" "🟡" "🟢" "🔵" "🟣" "🟤" "⚫" "⚪" "🟦" "🟧" "🟨" "🟩" "🟪" "🟫")
  
  # Get a random color ball
  local random_index=$((RANDOM % ${#color_balls[@]}))
  local color_ball="${color_balls[$random_index]}"
  
  # Set the tab title with the color ball
  echo -ne "\033]0;${color_ball} ${tab_name}\007"
}

# watn (Warp Auto Tab Name) - Automatically set tab name on every prompt
# This runs automatically to keep the tab name updated with the current directory
function watn () {
  wtn
}

# Note: The precmd_functions addition is handled in the main loader