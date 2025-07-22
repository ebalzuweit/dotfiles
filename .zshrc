setopt prompt_subst;

git_branch() {
	local branchName='';

	# Check for what branch we’re on.
	# Get the short symbolic ref. If HEAD isn’t a symbolic ref, get a
	# tracking remote branch or tag. Otherwise, get the
	# short SHA for the latest commit, or give up.
	branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
		git describe --all --exact-match HEAD 2> /dev/null || \
		git rev-parse --short HEAD 2> /dev/null || \
		echo '(unknown)')";
	
	echo -e "${branchName}";
}
git_status() {
	local s='';

	# Early exit for Chromium & Blink repo, as the dirty check takes too long.
	# Thanks, @paulirish!
	# https://github.com/paulirish/dotfiles/blob/dd33151f/.bash_prompt#L110-L123
	repoUrl="$(git config --get remote.origin.url)";
	if grep -q 'chromium/src.git' <<< "${repoUrl}"; then
		s+='*';
	else
		# Check for uncommitted changes in the index.
		if ! $(git diff --quiet --ignore-submodules --cached); then
			s+='+';
		fi;
		# Check for unstaged changes.
		if ! $(git diff-files --quiet --ignore-submodules --); then
			s+='!';
		fi;
		# Check for untracked files.
		if [ -n "$(git ls-files --others --exclude-standard)" ]; then
			s+='?';
		fi;
		# Check for stashed files.
		if $(git rev-parse --verify refs/stash &>/dev/null); then
			s+='$';
		fi;
	fi;

	[ -n "${s}" ] && s=" [${s}]";

	echo -e "${s}";
}
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

# aliases
source $HOME/.aliases;

# prompt
precmd() {
	echo # add newline before prompt header
	print -rP "$(prompt_header)"
}
PROMPT="%B%F{15}$%f%b ";
PS2="%B%F{136}→%f%b ";

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

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

local GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
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
      --preview 'eza --tree --color=always --icons=always --level=2 "$FZF_FF_SEARCH_PATH"/{}' \
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
    eza --tree --icons=always -L 2
  fi
}
alias ls='eza --icons --git --color=always --group-directories-first --tree --level=2 --no-permissions --no-user --no-time'
