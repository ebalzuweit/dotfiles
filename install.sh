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
  echo "  .wezterm.lua"
  cp .wezterm.lua ~
  echo "  .vimrc"
  cp .vimrc ~
  echo "  nvim"
  cp -R nvim ~/.config/
  echo "  helix"
  cp -R helix ~/.config/
  echo "  yazi"
  cp -R yazi ~/.config/
  echo "  zellij"
  cp -R zellij ~/.config/
  echo "  scripts"
  cp scripts/* ~/.local/bin/

  echo "  .gitconfig - Automatic installation not supported at this time."

  echo ""
  echo "dotfiles have been updated successfully!"
  echo "Please restart your shell or source the appropriate file:"
  echo "- ~/.bash_profile"
  echo "- ~/.zshrc"
}

# Function to install Homebrew if it's not already installed
function install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for the current session if it wasn't already
    if [ -f "/opt/homebrew/bin/brew" ]; then # For Apple Silicon
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then # For Intel Macs
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "Homebrew installed successfully!"
  else
    echo "Homebrew is already installed."
  fi
}

read -p "This is a one-way, destructive process. Are you sure? (y/n) " -n 1
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  installDotfiles

  # Check and install Homebrew
  install_homebrew

  # Install the necessary packages using Homebrew
  echo "Installing required packages with Homebrew..."
  brew install git eza fd fzf yazi zsh-autosuggestions zsh-syntax-highlighting bat kubectx k9s zellij neovim blueutil xmlstarlet golangci-lint jq noahgorstein/tap/jqp atac
  echo "Homebrew packages installed."

  # Fix Go linking if needed
  if ! brew list go &>/dev/null; then
    echo "Go not installed via Homebrew, skipping link fix."
  else
    echo "Ensuring Go is properly linked..."
    brew link --overwrite go 2>/dev/null || true
  fi

  echo "Installing additional tools..."
  cargo install --git https://github.com/MatthewMyrick/quill
  go install github.com/MatthewMyrick/bluetooth-tui@latest
  go install github.com/matthewmyrick/azure-searcher@latest
  echo "Additional tools installed."

  echo "Setting up Python virtual environment for Neovim..."
  if [ ! -d ~/.local/share/nvim/venv ]; then
    echo "Creating new virtual environment..."
    python3 -m venv ~/.local/share/nvim/venv
  else
    echo "Virtual environment already exists."
  fi

  source ~/.local/share/nvim/venv/bin/activate

  # Check if packages are installed and update/install them
  if pip show xlrd pylightxl &>/dev/null; then
    echo "Packages already installed. Updating to latest versions..."
    pip install --upgrade xlrd pylightxl
  else
    echo "Installing Python packages for Excel support..."
    pip install xlrd pylightxl
  fi

  echo "Python virtual environment for Neovim configured."
fi

unset installDotfiles
unset install_homebrew
