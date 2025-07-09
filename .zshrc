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

# auto-start zellij 
# if [[ -z "$ZELLIJ" ]]
# then
#     if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
#         zellij attach -c
#     else
#         zellij
#     fi

#     if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
#         exit
#     fi
# fi
