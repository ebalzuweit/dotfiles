#!/bin/bash

# adapted from https://github.com/mathiasbynens/dotfiles/blob/main/bootstrap.sh

function installDotfiles() {
  echo "Installing:"

  # Get the directory where this script is located
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  echo "  yazi"
  cp -R yazi ~/.config/
  # echo "   kitty"
  # cp -R kitty ~/.config/
  echo "  ghostty"
  cp -R ghostyy ~/.config/ghostty
  
  # Install custom Ghostty icon if Ghostty is installed
  if [ -d "/Applications/Ghostty.app" ] && [ -f "ghostyy/icon/sublime.icns" ]; then
    echo "  Installing custom Ghostty icon..."
    # Backup original icon
    if [ ! -f "/Applications/Ghostty.app/Contents/Resources/AppIcon-backup.icns" ]; then
      sudo cp /Applications/Ghostty.app/Contents/Resources/AppIcon.icns /Applications/Ghostty.app/Contents/Resources/AppIcon-backup.icns
    fi
    # Install custom icon
    sudo cp ghostyy/icon/sublime.icns /Applications/Ghostty.app/Contents/Resources/AppIcon.icns
    # Clear icon cache
    sudo rm -rf /Library/Caches/com.apple.iconservices.store 2>/dev/null
    killall Dock 2>/dev/null
    echo "    ✓ Custom Ghostty icon installed"
  fi
  
  echo "  karabiner"
  # Close Karabiner if it's running before copying config
  osascript -e 'tell application "Karabiner-Elements" to quit' 2>/dev/null || true
  osascript -e 'tell application "Karabiner-EventViewer" to quit' 2>/dev/null || true
  
  # Copy the configuration
  cp -R keyboard/mac/karabiner ~/.config/
  
  # Reload Karabiner configuration without opening the GUI
  # This uses the CLI tool to reload config silently
  if command -v '/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' &>/dev/null; then
    '/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --reload-karabiner-config 2>/dev/null || true
  fi

  # Create necessary directories
  echo "Creating script directories..."
  mkdir -p ~/.local/bin
  mkdir -p ~/GitHub/matthewmyrick/dotfiles/scripts

  # Handle scripts directory with new structure
  echo "  scripts"

  # Copy Python scripts to ~/.local/bin (if they're executables)
  if [ -d "scripts/python" ] && [ "$(ls -A scripts/python/*.py 2>/dev/null)" ]; then
    echo "    - Python scripts to ~/.local/bin"
    for script in scripts/python/*.py; do
      if [ -f "$script" ] && [ -x "$script" ]; then
        cp "$script" ~/.local/bin/
      fi
    done
  fi

  # Copy the entire scripts directory structure for shell modules
  # This preserves the modular organization
  echo "    - Shell modules to ~/GitHub/matthewmyrick/dotfiles/scripts"
  if [ -d "scripts" ]; then
    # Ensure the destination exists
    mkdir -p ~/GitHub/matthewmyrick/dotfiles
    # Copy the entire scripts directory structure
    cp -R scripts ~/GitHub/matthewmyrick/dotfiles/
    echo "      ✓ Copied modular shell functions"
    echo "      ✓ Copied shell module loader"
    echo "      ✓ Preserved directory structure for lazy loading"
  fi

  # Handle telemetry formatter separately if needed
  if [ -f "scripts/python/telemetry.py" ]; then
    echo "    - Telemetry formatter"
    mkdir -p ~/.config/zsh/scripts
    cp scripts/python/telemetry.py ~/.config/zsh/scripts/telemetry_formatter.py
  fi

  echo "  .gitconfig - Automatic installation not supported at this time."

  echo ""
  echo "dotfiles have been updated successfully!"
  echo ""
  echo "ℹ️  Shell Module System:"
  echo "  - Modular functions installed to ~/GitHub/matthewmyrick/dotfiles/scripts/shell/"
  echo "  - Functions use lazy loading for optimal performance"
  echo "  - Run 'shell_modules' to see available modules"
  echo "  - Run 'shell_loaded' to see what's currently loaded"
  echo ""
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

  # Install or upgrade the necessary packages using Homebrew
  echo "Checking and installing/upgrading required packages with Homebrew..."

  # List of required packages
  BREW_PACKAGES=(
    git eza fd fzf yazi
    zsh-autosuggestions zsh-syntax-highlighting
    bat kubectx k9s neovim
    blueutil xmlstarlet golangci-lint
    jq ripgrep gh lazygit lazydocker
  )

  # Install or upgrade each package
  for package in "${BREW_PACKAGES[@]}"; do
    if brew list --formula | grep -q "^${package}$"; then
      echo "  📦 ${package} already installed, checking for updates..."
      brew upgrade "$package" 2>/dev/null || echo "    ✓ ${package} is up to date"
    else
      echo "  📦 Installing ${package}..."
      brew install "$package"
    fi
  done

  # brew isntall cask packages
  echo "Checking and installing/upgrading cask packages..."

  CASK_PACKAGES=(
    # kitty
    ghostty
    karabiner-elements
    nikitabobko/tap/aerospace
  )

  # Install or upgrade each cask package
  for package in "${CASK_PACKAGES[@]}"; do
    if brew list --cask | grep -q "^${package}$"; then
      echo "  📦 ${package} already installed, checking for updates..."
      brew upgrade --cask "$package" 2>/dev/null || echo "    ✓
  ${package} is up to date"
    else
      echo "  📦 Installing ${package}..."
      brew install --cask "$package"
    fi
  done

  # taproom is a special case, it needs to be installed from the tap
  brew tap gromgit/brewtils
  brew install gromgit/brewtils/taproom

  # Handle tap packages separately
  echo "  📦 Checking jqp..."
  if ! brew list --formula | grep -q "^jqp$"; then
    echo "    Installing jqp from tap..."
    brew install noahgorstein/tap/jqp
  else
    echo "    ✓ jqp already installed"
  fi

  echo "Homebrew packages ready."

  # Install Python packages for shell tools
  echo "Checking Python packages for shell tools..."

  # Check if pipx is available (preferred for macOS)
  if ! command -v pipx &>/dev/null; then
    echo "  📦 Installing pipx for Python package management..."
    brew install pipx
    pipx ensurepath
  fi

  # Install rich using pipx or pip with break-system-packages
  echo "  📦 Checking rich (Python formatter)..."

  # Try to check if rich is available in PATH
  if python3 -c "import rich" 2>/dev/null; then
    echo "    ✓ rich is available"
  else
    echo "    Installing rich..."
    # Try pipx first (preferred)
    if command -v pipx &>/dev/null; then
      pipx install rich-cli 2>/dev/null || true
    fi

    # If rich still not available, use pip with break-system-packages flag
    if ! python3 -c "import rich" 2>/dev/null; then
      python3 -m pip install --user --break-system-packages rich 2>/dev/null || {
        echo "    ⚠️  Could not install rich automatically"
        echo "    Try: python3 -m pip install --user --break-system-packages rich"
      }
    fi
  fi

  echo "Python packages ready."

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
