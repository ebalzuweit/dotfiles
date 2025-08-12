#!/usr/bin/env zsh
# Zsh Profiling Functions
# Tools for profiling zsh startup and performance

# Lazy load guard
[[ -n "${_ZPROF_LOADED}" ]] && return
_ZPROF_LOADED=1

# Enable, then show a rich CSV of timings for this session (after 'exit')
zprofile_on() {
  zmodload zsh/zprof 2>/dev/null || return
  print -u2 -- "[zprof] enabled; run 'zprofile_off' to dump"
}

zprofile_off() {
  command zprof | awk '
    NR==2 { next }
    NR>0 { for(i=1;i<=NF;i++) printf "%s%s", $i, (i==NF?"":","); printf "\n" }
  ' | rich --csv --title "Zsh Startup Profile" -
}

function pzprof() {
  # Check if the 'zsh/zprof' key exists in the special 'modules' array.
  if [[ -z "${modules[zsh/zprof]}" ]]; then
    echo "Error: zprof module not loaded." >&2
    echo "Please add 'zmodload zsh/zprof' to the top of your ~/.zshrc" >&2
    return 1
  fi

  # The pipeline to format and display the zprof output.
  zprof | awk '
    # Skip the "----" separator line.
    NR==2 { next }

    # For all other lines (header and data)...
    NR>0 {
      # Loop through each field and print it, followed by a comma
      # unless it is the last field on the line.
      for(i=1; i<=NF; i++) {
        printf "%s%s", $i, (i==NF ? "" : ",");
      }
      # Print a newline character to end the row.
      printf "\n";
    }
  ' | rich --csv --title "Zsh Startup Profile" -
}