#!/usr/bin/bash

# adapted from https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh

function installDotfiles() {
    echo "Installing:";

    echo "  .bash_profile";
    cp .bash_profile ~;
    echo "  .bash_prompt";
    cp .bash_prompt ~;
    echo "  .bashrc";
    cp .bashrc ~;
    echo "  .vimrc";
    cp .vimrc ~;
    echo "  .gitconfig - Automatic installation not supported at this time.";

    source ~/.bash_profile;
}

read -p "This is a one-way, destructive process. Are you sure? (y/n) " -n 1;
echo "";
if [[ $REPLY =~ ^[Yy]$ ]]; then
    installDotfiles;
fi;

unset installDotfiles;
