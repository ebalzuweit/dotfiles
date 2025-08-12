# Shell Module System

This directory contains a modular, optimized shell configuration system with lazy loading capabilities.

## 🚀 Key Features

- **Lazy Loading**: Functions are loaded only when first used, dramatically reducing shell startup time
- **Modular Organization**: Functions grouped by category for easy maintenance
- **Smart Detection**: Terminal-specific features load conditionally
- **Performance Monitoring**: Built-in profiling tools to measure and optimize startup

## 📁 Directory Structure

```
shell/
├── profiling/      # Performance monitoring and telemetry
│   ├── zprof.sh       # Zsh profiling tools
│   └── telemetry.sh   # Python/Go execution monitoring
├── git/            # Git and GitHub utilities  
│   └── functions.sh   # ghc, ffgn, fpr, git prompt functions
├── navigation/     # File and directory navigation
│   └── finders.sh     # ff, ffn, fch, yazi integration
├── utilities/      # General utility functions
│   ├── general.sh     # k_port, brewf, togglenetskope, r_xml
│   └── warp.sh        # Warp terminal specific features
├── network/        # Network and API tools
│   └── api.sh         # curl wrappers, ATAC integration
├── prompt/         # Shell prompt configuration
│   └── config.sh      # Custom prompt with git integration
└── loader.sh       # Main module loader with lazy loading

```

## 🎯 Quick Start

### Available Commands

After sourcing the configuration, these commands become available:

```bash
# Module management
shell_modules    # List all available modules
shell_load all   # Force load all modules
shell_loaded     # Show currently loaded modules

# Navigation (lazy loaded)
ff               # Fuzzy find directories
ffn              # Fuzzy find and open in nvim
fch              # Fuzzy command history search
y                # Yazi file manager with cd on exit

# Git (lazy loaded) 
ghc <org>        # Clone GitHub repo interactively
ffgn             # Find and open GitHub repos
fpr              # Find and open your PRs

# Utilities (lazy loaded)
k_port 8080      # Kill process on port
brewf            # Interactive Homebrew UI
r_xml file.xml   # Pretty print XML files
togglenetskope   # Toggle Netskope on/off (macOS)

# Profiling (lazy loaded)
zprofile_on      # Enable shell profiling
zprofile_off     # Show profiling results
pzprof           # Display formatted profile
```

## ⚡ Performance Optimization

### Measuring Startup Time

1. **Quick measurement**:
   ```bash
   time zsh -i -c exit
   ```

2. **Detailed profiling**:
   ```bash
   # Add to top of .zshrc
   zmodload zsh/zprof
   
   # Then check results with
   zprof
   ```

3. **Using built-in tools**:
   ```bash
   zprofile_on     # Enable profiling
   # ... use shell normally ...
   zprofile_off    # Display results
   ```

### Optimization Techniques Used

1. **Lazy Loading**: Functions create stubs that load real implementation on first use
2. **Conditional Paths**: Only add directories to PATH if they exist
3. **Fast Completion**: Using `compinit -C` to skip security checks
4. **Minimal Plugins**: Only essential plugins loaded at startup
5. **Smart Detection**: Terminal-specific code runs only when needed

## 🔧 Customization

### Disable Lazy Loading

To always load a specific module at startup, edit `loader.sh`:

```bash
# Change from lazy load:
_lazy_load "ff" "${SHELL_MODULES_DIR}/navigation/finders.sh"

# To immediate load:
source "${SHELL_MODULES_DIR}/navigation/finders.sh"
```

### Add New Functions

1. Create or edit appropriate module file in category directory
2. Add lazy load entry in `loader.sh`
3. Document in this README

### Override Default Behavior

- **Enable curl JSON detection**: Uncomment alias in `loader.sh`
- **Disable Python telemetry**: Don't use the `python_telemetry` alias
- **Force load modules**: Use `shell_load <module>` command

## 📊 Typical Performance Impact

With lazy loading enabled:
- **Before**: ~300-500ms startup time with all functions
- **After**: ~50-100ms startup time (80-90% improvement)

Functions load instantly on first use (typically <10ms per module).

## 🐛 Troubleshooting

### Function not found
- Check if module is loaded: `shell_loaded`
- Force load module: `shell_load all`
- Verify file exists in correct directory

### Slow startup
- Enable profiling to identify bottlenecks
- Check for duplicate PATH entries
- Ensure conditional loading is working

### Module conflicts
- Check for function name collisions
- Verify lazy load guards are in place
- Review load order in `loader.sh`