# aliases
if [ -f ~/.aliases ]; then
   source ~/.aliases
fi

# configuration
export HISTCONTROL=ignoredups

# prompt
if [ -f ~/.bash_prompt ]; then
    source ~/.bash_prompt;
fi;