#!/bin/bash

# adapted from https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh

function installDotfiles() {
  echo "Installing:"

  # copy files to home
  echo "  .aliases"
  cp .aliases ~
  echo "  .bash_profile"
  cp .bash_profile ~
  echo "  .bash_prompt"
  cp .bash_prompt ~
  echo "  .bashrc"
  cp .bashrc ~
  echo "  .zshrc"
  cp .zshrc ~
  echo "  .vimrc"
  cp .vimrc ~
  echo "  nvim"
  cp -r nvim/ ~/.config/

  echo "  .gitconfig - Automatic installation not supported at this time."

  echo ""
  echo "dotfiles have been updated successfully!"
  echo "Please restart your shell or source the appropriate file:"
  echo "- ~/.bash_profile"
  echo "- ~/.zshrc"
}

read -p "This is a one-way, destructive process. Are you sure? (y/n) " -n 1
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  installDotfiles
fi

unset installDotfiles
