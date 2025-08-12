# dotfiles

A collection of personal dotfile configs with an optimized, modular shell configuration system.

## Features

- **⚡ Fast Shell Startup**: Modular functions with lazy loading for ~80-90% faster startup
- **📦 Organized Structure**: Functions grouped by category (git, navigation, utilities, etc.)
- **🎯 Smart Loading**: Terminal-specific features and paths load conditionally
- **🔧 Easy Management**: Built-in commands to inspect and control module loading

## Installation

Run the installation script to set up all dotfiles and dependencies:

```bash
./install.sh
```

This will:
1. Copy dotfiles to home directory (`.zshrc`, `.aliases`, etc.)
2. Install the modular shell system to `~/GitHub/matthewmyrick/dotfiles/scripts/shell/`
3. Set up config directories for nvim, yazi, kitty
4. Install required Homebrew packages
5. Configure Python virtual environment for Neovim

### Verify Installation

After installation, verify everything is set up correctly:

```bash
./scripts/verify_installation.sh
```

## Shell Module System

The shell configuration uses a modular, lazy-loading system for optimal performance:

### Available Modules

- **profiling/** - Performance monitoring and telemetry tools
- **git/** - Git utilities and GitHub integration
- **navigation/** - File/directory finders and navigation
- **utilities/** - General utilities and terminal-specific features
- **network/** - API and network request tools
- **prompt/** - Custom prompt configuration

### Key Commands

```bash
# Module management
shell_modules    # List all available modules
shell_load all   # Force load all modules
shell_loaded     # Show currently loaded modules

# Navigation (lazy loaded)
ff               # Fuzzy find directories
ffn              # Fuzzy find and open in nvim
fch              # Fuzzy command history search

# Git (lazy loaded)
ghc <org>        # Clone GitHub repo interactively
ffgn             # Find and open GitHub repos
fpr              # Find and open your PRs

# Utilities (lazy loaded)
k_port 8080      # Kill process on port
brewf            # Interactive Homebrew UI
```

### Performance

With lazy loading enabled:
- **Before**: ~300-500ms startup time
- **After**: ~50-100ms startup time
- Functions load instantly on first use (<10ms per module)

## Notes

- `.gitconfig` must be updated manually to prevent overwriting any current git configuration
- Shell functions are located in `~/GitHub/matthewmyrick/dotfiles/scripts/shell/`
- Python telemetry is opt-in via `python_telemetry` alias
- Curl JSON detection available via `curlj` alias

## Troubleshooting

If functions aren't available after installation:
1. Restart your shell or run `source ~/.zshrc`
2. Check loaded modules with `shell_loaded`
3. Force load modules with `shell_load all`
4. Run verification script: `./scripts/verify_installation.sh`