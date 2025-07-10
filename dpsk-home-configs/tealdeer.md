# Unified Advanced Tealdeer Configuration for Gentoo Linux

This is a comprehensive `tealdeer` (tldr) configuration that combines Gentoo-specific optimizations, the beautiful Catppuccin Mocha color theme, quality-of-life improvements, and cross-distribution compatibility.

## Configuration File

Save this as `~/.config/tealdeer/config.toml` or `/etc/tealdeer/config.toml` for system-wide settings:

```toml
[updates]
auto_update = true
auto_update_interval_hours = 24  # Daily updates to stay current
cache_dir = "~/.cache/tealdeer"  # Standard cache location

[display]
compact = false                  # More readable multi-line output
use_pager = true                 # For longer outputs
pager = "less -FRXK"             # Gentoo-standard less with good defaults
raw = false                      # Formatted output
markdown = true                  # Render markdown properly
show_hints = true                # Helpful usage hints
show_os = "linux"                # Prioritize Linux pages
show_language = "en"             # English pages
show_progress = true             # Show progress during updates
quiet = false                    # Show update progress and info

[style]
# Catppuccin Mocha Theme with enhanced readability
command_name = "bold #f5e0dc"    # Command highlight (renamed from command)
description = "#cdd6f4"          # Description text
example_text = "#cdd6f4"         # Example text color
example_code = "bold #a6e3a1"    # Code blocks - green for visibility
example_variable = "italic #f38ba8" # Variables in examples - pink italic
header = "bold #b4befe"          # Section headers - lavender
quote = "#bac2de"                # Quoted text - muted blue
hidden = "dim #6c7086"           # Hidden elements - overlay0
code_block = "#89b4fa"           # Code background - blue
code_block_line_number = "#585b70" # Line numbers - surface2

[output]
show_hints = true                # Helpful usage hints (backup setting)
show_os = "linux"                # Prioritize Linux pages (backup setting)
show_language = "en"             # English pages (backup setting)
show_progress = true             # Show progress during updates (backup setting)

[gentoo]
priority = ["portage", "emerge", "equery", "ebuild", "etc-update", "revdep-rebuild"]
```

## Quality of Life Improvements

### 1. Gentoo-Specific Optimizations
- **Portage Priority**: Gentoo-specific commands (emerge, equery, etc.) appear first in search results
- **Pager Integration**: Optimized for Gentoo's standard `less` pager configuration
- **Workflow-Aware**: Designed for common Portage maintenance tasks

### 2. Universal Performance Enhancements
- **Auto-Updates**: Daily cache updates with minimal resource usage
- **Local Cache**: Instant access to documentation without network delays
- **OS-Aware**: Prioritizes Linux-specific command variations

### 3. Visual & Readability Improvements
- **Catppuccin Mocha Theme**: Beautiful, eye-friendly color palette
- **Syntax Highlighting**: Clear distinction between commands, variables, and code blocks
- **Markdown Rendering**: Proper formatting for complex documentation
- **Multi-line Display**: More readable than compact mode

### 4. Cross-Distribution Compatibility
- Works seamlessly on Gentoo, Arch, Debian, and other Linux distributions
- Graceful fallbacks for missing features on different systems

## Installation and Setup

### Gentoo-Specific Installation
```bash
# Install tealdeer via Portage
sudo emerge -av app-misc/tealdeer

# Create configuration directory
mkdir -p ~/.config/tealdeer

# Generate initial cache (run as regular user)
tldr --update

# Optional: Pre-cache all pages for offline use
tldr --list-all | xargs -n 1 tldr --render

# Add convenient alias
echo "alias t='tldr'" >> ~/.bashrc
```

### Cross-Distribution Installation
```bash
# For other distributions, install via package manager or cargo:
# sudo pacman -S tealdeer        # Arch Linux
# sudo apt install tealdeer      # Debian/Ubuntu
# cargo install tealdeer         # Via Rust/Cargo

# Create config directory
mkdir -p ~/.config/tealdeer

# Initialize cache
tldr --update

# Optional: Add shell alias
echo "alias t='tldr'" >> ~/.bashrc
```

## Advanced Shell Integration

Add these functions to your shell configuration file (`.bashrc`, `.zshrc`, etc.):

```bash
# Faster tldr access with cache-only lookup
tldrf() {
    if [[ -n "$1" ]]; then
        tldr -f "$@"
    else
        echo "Usage: tldrf <command>"
        echo "Faster tldr with local cache only"
    fi
}

# Search pages by description or content
tldr-search() {
    if [[ -n "$1" ]]; then
        tldr --list | grep -i "$1" | xargs -n 1 tldr
    else
        echo "Usage: tldr-search <pattern>"
        echo "Search tldr pages by description"
    fi
}

# Quick Gentoo-specific commands
alias tldr-emerge='tldr emerge'
alias tldr-portage='tldr portage'
alias tldr-equery='tldr equery'
```

## Systemd Auto-Update Service (Optional)

For automated cache updates, create these systemd user service files:

### Service File
Create `~/.config/systemd/user/tldr-update.service`:
```ini
[Unit]
Description=Update tldr cache
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/tldr --update
```

### Timer File
Create `~/.config/systemd/user/tldr-update.timer`:
```ini
[Unit]
Description=Daily tldr cache update
Requires=tldr-update.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
```

### Enable the Timer
```bash
# Enable and start the timer
systemctl --user enable --now tldr-update.timer

# Check timer status
systemctl --user status tldr-update.timer

# View timer schedule
systemctl --user list-timers tldr-update.timer
```

## Usage Tips and Examples

### 1. Gentoo-Specific Workflow
```bash
# Essential Gentoo commands
tldr emerge          # Package management
tldr equery          # Package queries
tldr etc-update      # Configuration file updates
tldr revdep-rebuild  # Dependency rebuilding
tldr ebuild          # Package building
```

### 2. Pager Integration for Long Outputs
```bash
# Use pager for lengthy command documentation
tldr --pager systemd
tldr --pager docker
```

### 3. Cache Management
```bash
# Force immediate cache update
tldr --update

# Check cache status
tldr --list | wc -l  # Count available pages

# Clear and rebuild cache
rm -rf ~/.cache/tealdeer && tldr --update
```

### 4. Search and Discovery
```bash
# Find commands related to networking
tldr-search network

# List all available pages
tldr --list

# Random command discovery
tldr --random
```

## Customization Options

### Color Theme Modification
To customize the Catppuccin Mocha colors, modify the `[style]` section hex codes:
- `#f5e0dc` - Rosewater (command names)
- `#cdd6f4` - Text (descriptions)
- `#a6e3a1` - Green (code blocks)
- `#f38ba8` - Pink (variables)
- `#b4befe` - Lavender (headers)

### Alternative Pager Configuration
```toml
# For different pager preferences
pager = "bat --paging=always --style=plain"  # Using bat as pager
# or
pager = "more"                               # Simple more pager
```

## Troubleshooting

### Common Issues and Solutions

1. **Cache Update Failures**:
   ```bash
   # Clear cache and retry
   rm -rf ~/.cache/tealdeer
   tldr --update
   ```

2. **Pager Not Working**:
   ```bash
   # Check if less is installed
   which less
   # Install if missing: sudo emerge -av sys-apps/less
   ```

3. **Colors Not Displaying**:
   ```bash
   # Check terminal color support
   echo $TERM
   # Ensure terminal supports 256 colors or truecolor
   ```

4. **Permission Issues**:
   ```bash
   # Fix cache directory permissions
   chmod -R 755 ~/.cache/tealdeer
   ```

This unified configuration provides the best of both worlds: Gentoo-optimized workflows with beautiful theming and cross-platform compatibility. The configuration balances performance, aesthetics, and functionality for an optimal tldr experience.
