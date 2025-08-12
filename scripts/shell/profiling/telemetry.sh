#!/usr/bin/env zsh
# Telemetry and Profiling Functions
# These functions help profile and monitor command execution

# Lazy load guard - only load when needed
[[ -n "${_TELEMETRY_LOADED}" ]] && return
_TELEMETRY_LOADED=1

# --- Central Telemetry Wrapper ---
# This internal function is the core logic for capturing data.
function _run_and_monitor() {
  local language="$1"
  local log_file="$2"
  shift 2 # Remove language and log_file from arguments
  local command_to_run=("$@")
  local formatter_script="$HOME/.config/telemetry/python/telemetry.py"

  # Determine the OS for the time command flag
  local time_flag
  if [[ "$(uname)" == "Darwin" ]]; then
    time_flag="-l"
  else
    time_flag="-v"
  fi

  # --- Data Capture ---
  # The magic happens here. We run the command, redirecting the output of
  # 'time' (stderr) to a temporary file.
  {
    /usr/bin/time "$time_flag" "$@"
  } &> "$log_file"

  # Append a separator for parsing
  echo "\n---PROFILER DATA---" >> "$log_file"
}

# --- Python Wrapper ---
# NOTE: This overrides the python command - consider making it opt-in
function python_with_telemetry() {
  local log_file="/tmp/python_telemetry.log"
  local profile_file="/tmp/python_profile.prof"
  local command_to_run=("python" "$@")

  # Run the python script with cProfile to get function-level data
  _run_and_monitor "Python" "$log_file" python -m cProfile -o "$profile_file" "$@"

  # Append the readable profile data to the log
  python -m pstats "$profile_file" |& sed -n '/function calls/,/Ordered by:/p' >> "$log_file"

  # Display the final report
  python "$HOME/.config/zsh/scripts/telemetry_formatter.py" "$log_file" "$(uname)" "Python" "$command_to_run"
}

# Alias to enable telemetry for python (opt-in)
alias python_telemetry='python_with_telemetry'

# --- Report Viewer Functions ---
function lrp() {
  local log_file="/tmp/python_telemetry.log"
  if [[ ! -f "$log_file" ]]; then
    echo "No Python run log found. Run a python script first."
    return 1
  fi
  # We need to extract the original command from the log file to pass it
  local last_command=$(head -n 1 "$log_file" | sed 's/Command: //')
  python "$HOME/.config/zsh/scripts/telemetry_formatter.py" "$log_file" "$(uname)" "Python" "$last_command"
}

function lrg() {
  local log_file="/tmp/go_telemetry.log"
  if [[ ! -f "$log_file" ]]; then
    echo "No Go run log found. Run a 'go run' command first."
    return 1
  fi
  local last_command=$(head -n 1 "$log_file" | sed 's/Command: //')
  python "$HOME/.config/zsh/scripts/telemetry_formatter.py" "$log_file" "$(uname)" "Go" "$last_command"
}