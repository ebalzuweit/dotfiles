# aliases
if [ -f $HOME/.aliases ]; then
   source $HOME/.aliases
fi

# paths
if [ -f $HOME/.paths ]; then
  source $HOME/.paths
fi

# configuration
export HISTCONTROL=ignoredups

# prompt
if [ -f $HOME/.bash_prompt ]; then
    source $HOME/.bash_prompt;
fi;
