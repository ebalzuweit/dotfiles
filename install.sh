#!/bin/bash

# adapted from https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh

function installDotfiles() {
  echo "Installing:"

  # copy files to home
  echo "  .aliases"
  cp .aliases $HOME
  echo "  .paths"
  cp .paths $HOME
  echo "  .bash_profile"
  cp .bash_profile $HOME
  echo "  .bash_prompt"
  cp .bash_prompt $HOME
  echo "  .bashrc"
  cp .bashrc $HOME
  echo "  .zshrc"
  cp .zshrc $HOME
  echo "  .wezterm.lua"
  cp .wezterm.lua $HOME
  echo "  .vimrc"
  cp .vimrc $HOME
  echo "  nvim"
  cp -R nvim $HOME/.config/
  echo "  helix"
  cp -R helix $HOME/.config/
  echo "  yazi"
  cp -R yazi $HOME/.config/
  echo "  zellij"
  cp -R zellij $HOME/.config/
  echo "  scripts"
  cp scripts/* $HOME/.local/bin/

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
