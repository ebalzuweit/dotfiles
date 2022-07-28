# aliases
alias home='cd ~'
alias ..='cd ..'
alias back='cd -'
alias root='cd /'

alias la='ls -a'
alias ll='ls -l'

alias ga='git add'
alias gc='git commit -m'
alias gf='git fetch'
alias gs='git status'
alias push='git push'
alias pull='git pull'

# configuration
export HISTCONTROL=ignoredups

# prompt
if [ -f ~/.bash_prompt ]; then
    source ~/.bash_prompt;
fi;