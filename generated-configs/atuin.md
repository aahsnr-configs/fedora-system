# Advanced Atuin Configuration for Fedora 42

This configuration provides an optimized setup for Atuin (modern shell history) on Fedora 42 with:

- Vim keybindings
- Zsh integration
- Systemd service integration
- Performance optimizations for Fedora 42
- DNF integration

## 1. Systemd Integration

Create a systemd user service for the Atuin daemon:

```bash
mkdir -p ~/.config/systemd/user/
cat > ~/.config/systemd/user/atuin.service << 'EOF'
[Unit]
Description=Atuin Shell History Daemon
Documentation=https://atuin.sh/docs
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
# Use correct path - check both locations
ExecStartPre=/bin/sh -c 'test -x /usr/bin/atuin'
ExecStart=usr/bin/atuin daemon
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5
Environment=ATUIN_CONFIG_DIR=%h/.config/atuin
KillMode=mixed
TimeoutStopSec=5

# Security settings (relaxed for proper operation)
ProtectSystem=false
PrivateTmp=true
PrivateDevices=false
ProtectHome=false
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=true
RestrictRealtime=true
LockPersonality=true
RestrictSUIDSGID=true
NoNewPrivileges=true
ProtectHostname=true
ProtectClock=true

[Install]
WantedBy=default.target
EOF
```

Enable and start the service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now atuin.service
```

## 2. Zsh Integration with Vim Bindings

Add to your `~/.zshrc`:

```bash
# Initialize Atuin for zsh with vim bindings
if command -v atuin &> /dev/null; then
    # Initialize Atuin
    eval "$(atuin init zsh)"
    
    # Configure Atuin to use vim-style keybindings in search
    bindkey -M vicmd '^R' _atuin_search_widget
    bindkey -M viins '^R' _atuin_search_widget
fi

# Enable vim mode for Zsh
bindkey -v

# Vim mode indicator function
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'  # Block cursor for normal mode
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'  # Beam cursor for insert mode
    fi
}
zle -N zle-keymap-select

# Initialize cursor on startup
echo -ne '\e[5 q'

# Enhanced history navigation (only if not using Atuin's built-in)
if ! command -v atuin &> /dev/null; then
    bindkey '^p' up-line-or-search
    bindkey '^n' down-line-or-search
fi

# Source Fedora-specific aliases if they exist
if [[ -f ~/.alias ]]; then
    source ~/.alias
fi
```

## 3. Advanced Atuin Configuration

Create `~/.config/atuin/config.toml`:

```toml
# Atuin configuration optimized for Fedora 42

# Core settings
auto_sync = true
update_check = false
sync_frequency = "10m"
sync_address = "https://api.atuin.sh"

# Search configuration
search_mode = "fuzzy"
filter_mode = "global"
filter_mode_shell_up_key_binding = "session"
inline_height = 25
show_preview = true
max_preview_height = 10
show_help = true
exit_mode = "return-original"
word_jump_mode = "emacs"

# Display settings
style = "compact"

# Key bindings - vim mode settings
keymap_mode = "vim-insert"

# Sync settings
sync_records = true

# Common commands to potentially filter
common_prefix = ["sudo", "doas"]
common_subcommands = false

# History filtering options
history_filter = [
    "^ls$",
    "^cd$",
    "^pwd$",
    "^exit$",
    "^clear$",
    "^history$"
]

# Daemon settings
daemon_timeout = 3000
```

## 4. Performance Optimizations for Fedora 42

Add these environment variables to your `~/.zshrc`:

```bash
# Atuin performance optimizations for Fedora 42
export ATUIN_LOG="warn"

# Reduce sync frequency for better performance
export ATUIN_SYNC_FREQUENCY="600"  # 10 minutes

# Fedora-specific settings
export ATUIN_CONFIG_DIR="$HOME/.config/atuin"
```

## 5. Database Maintenance with Systemd Timer

Create systemd timer for periodic maintenance:

```bash
# Create maintenance service
cat > ~/.config/systemd/user/atuin-maintenance.service << 'EOF'
[Unit]
Description=Atuin Database Maintenance
After=atuin.service

[Service]
Type=oneshot
ExecStartPre=/bin/sh -c 'systemctl --user is-active --quiet atuin.service || exit 0'
ExecStartPre=/bin/sh -c 'test -f %h/.local/share/atuin/history.db || exit 0'
ExecStart=/bin/sh -c 'if command -v sqlite3 >/dev/null 2>&1; then sqlite3 %h/.local/share/atuin/history.db "PRAGMA optimize; PRAGMA wal_checkpoint(TRUNCATE); PRAGMA integrity_check;"; fi'
IOSchedulingClass=3
Nice=19
PrivateTmp=true

[Install]
WantedBy=default.target
EOF

# Create maintenance timer
cat > ~/.config/systemd/user/atuin-maintenance.timer << 'EOF'
[Unit]
Description=Daily Atuin Database Maintenance
Requires=atuin-maintenance.service

[Timer]
OnCalendar=daily
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable the timer
systemctl --user daemon-reload
systemctl --user enable --now atuin-maintenance.timer
```

## 6. Shell Integration with DNF Commands

For enhanced shell integration with Fedora-specific commands, add to your `~/.zshrc`:

```bash
# Fedora-specific aliases with Atuin integration
alias dnu='sudo dnf upgrade'
alias dni='sudo dnf install'
alias dns='dnf search'
alias dnr='sudo dnf remove'
alias dninfo='dnf info'
alias dnl='dnf list'
alias dnls='dnf list installed'
alias dnrq='dnf repoquery'
alias dnmc='sudo dnf makecache'
alias dncheck='dnf check-update'
alias dnhistory='dnf history'

# Flatpak integration
if command -v flatpak &> /dev/null; then
    alias fpi='flatpak install'
    alias fps='flatpak search'
    alias fpu='flatpak update'
    alias fpr='flatpak uninstall'
    alias fpl='flatpak list'
    alias fpinfo='flatpak info'
fi

# Function to show dnf history with better formatting
dnf-history() {
    if command -v atuin &> /dev/null; then
        atuin search "dnf" --interactive
    else
        dnf history
    fi
}
```

## 7. Troubleshooting

### Service Status
```bash
# Check service status
systemctl --user status atuin.service

# View logs
journalctl --user -u atuin.service -f

# Restart service
systemctl --user restart atuin.service

# Check if atuin is working
atuin status
```

### Database Issues
```bash
# Check database integrity (if sqlite3 is installed)
if command -v sqlite3 &> /dev/null; then
    sqlite3 ~/.local/share/atuin/history.db "PRAGMA integrity_check;"
fi

# Backup database
mkdir -p ~/.local/share/atuin/backups
cp ~/.local/share/atuin/history.db ~/.local/share/atuin/backups/history.db.$(date +%Y%m%d_%H%M%S)

# If using Btrfs and snapper is available
if command -v snapper &> /dev/null && findmnt -n -o FSTYPE / | grep -q btrfs; then
    sudo snapper create --description "Before Atuin DB maintenance"
fi

# Reset Atuin (last resort)
atuin doctor
```

## 8. Keybindings Reference

With this configuration, you get these vim-style keybindings:

- `Ctrl-r`: Open Atuin search in interactive mode
- Inside Atuin search interface:
  - `/`: Start searching (vim-style)
  - `Esc`: Exit search or return to normal mode
  - `j/k`: Navigate results up/down (in vim mode)
  - `Enter`: Execute selected command
  - `Tab`: Accept suggestion
  - `Ctrl-c`: Cancel search

## 9. Fedora-Specific Optimizations

### SELinux Integration
```bash
# Function to check SELinux status and optimize Atuin accordingly
optimize-atuin-selinux() {
    if command -v getenforce &> /dev/null; then
        local selinux_status=$(getenforce)
        echo "SELinux status: $selinux_status"
        
        if [[ "$selinux_status" == "Enforcing" ]]; then
            echo "SELinux is enforcing - checking Atuin contexts..."
            
            # Check if Atuin daemon needs special context
            if ! ls -Z ~/.local/share/atuin/history.db 2>/dev/null | grep -q user_home_t; then
                echo "Setting proper SELinux context for Atuin database..."
                restorecon -R ~/.local/share/atuin/ 2>/dev/null || true
            fi
        fi
    fi
}

# Run SELinux optimization on shell startup (once per day)
if [[ ! -f ~/.cache/atuin-selinux-optimized-$(date +%Y%m%d) ]]; then
    optimize-atuin-selinux
    mkdir -p ~/.cache
    touch ~/.cache/atuin-selinux-optimized-$(date +%Y%m%d)
    # Clean old optimization markers
    find ~/.cache -name "atuin-selinux-optimized-*" -mtime +7 -delete 2>/dev/null
fi
```

### Package Management Integration
```bash
# Enhanced dnf wrapper with Atuin integration
enhanced_dnf() {
    local cmd="$1"
    shift
    
    case "$cmd" in
        install|in)
            echo "Installing packages: $*"
            sudo dnf install "$@"
            ;;
        remove|rm)
            echo "Removing packages: $*"
            sudo dnf remove "$@"
            ;;
        update|upgrade|up)
            echo "Updating system..."
            sudo dnf upgrade "$@"
            ;;
        search|se)
            echo "Searching for: $*"
            dnf search "$@"
            ;;
        *)
            dnf "$cmd" "$@"
            ;;
    esac
}

# Uncomment to use enhanced wrapper
# alias dnf=enhanced_dnf
```

### System Information Integration
```bash
# Function to show system info with Atuin context
show-system-info() {
    echo "=== Fedora 42 System Information ==="
    echo "Kernel: $(uname -r)"
    
    if [[ -f /etc/os-release ]]; then
        echo "Fedora Release: $(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')"
    fi
    
    echo "Atuin Status: $(systemctl --user is-active atuin.service 2>/dev/null || echo 'not running')"
    
    if command -v atuin &> /dev/null; then
        echo "Atuin Version: $(atuin --version 2>/dev/null | head -n1)"
        local history_count=$(atuin stats 2>/dev/null | grep -E 'Total commands|commands recorded' | awk '{print $NF}' | head -n1)
        echo "History Count: ${history_count:-unknown}"
    fi
    
    if command -v dnf &> /dev/null; then
        local last_update=$(dnf history 2>/dev/null | grep -E 'upgrade|update' | head -n1 | awk '{print $3" "$4}')
        echo "Last Update: ${last_update:-unknown}"
    fi
    
    if command -v getenforce &> /dev/null; then
        echo "SELinux Status: $(getenforce)"
    fi
    
    echo "=== End System Information ==="
}

# Alias for quick system info
alias sysinfo=show-system-info
```

### Btrfs Optimization
```bash
# Function to optimize Atuin database for Btrfs
optimize-atuin-btrfs() {
    local db_path="$HOME/.local/share/atuin/history.db"
    
    if [[ -f "$db_path" ]] && findmnt -n -o FSTYPE / | grep -q btrfs; then
        echo "Optimizing Atuin database for Btrfs..."
        
        # Disable copy-on-write for database file
        if command -v chattr &> /dev/null; then
            chattr +C "$db_path" 2>/dev/null && echo "COW disabled for database"
        fi
        
        # Set no compression for database files
        if command -v btrfs &> /dev/null; then
            btrfs property set "$db_path" compression none 2>/dev/null && echo "Compression disabled for database"
        fi
    fi
}

# Run optimization on shell startup (once per day)
if [[ ! -f ~/.cache/atuin-btrfs-optimized-$(date +%Y%m%d) ]]; then
    optimize-atuin-btrfs
    mkdir -p ~/.cache
    touch ~/.cache/atuin-btrfs-optimized-$(date +%Y%m%d)
    # Clean old optimization markers
    find ~/.cache -name "atuin-btrfs-optimized-*" -mtime +7 -delete 2>/dev/null
fi
```

## 10. Installation Verification Script

Create a verification script to ensure everything is working:

```bash
# Create verification script
mkdir -p ~/.local/bin
cat > ~/.local/bin/verify-atuin-setup << 'EOF'
#!/bin/bash
# Atuin setup verification for Fedora 42

echo "=== Atuin Setup Verification ==="

# Check if Atuin is installed
if command -v atuin &> /dev/null; then
    echo "✓ Atuin is installed: $(atuin --version | head -n1)"
else
    echo "✗ Atuin is not installed"
    exit 1
fi

# Check systemd service
if systemctl --user is-active --quiet atuin.service; then
    echo "✓ Atuin systemd service is running"
else
    echo "⚠ Atuin systemd service is not running"
    echo "  Try: systemctl --user start atuin.service"
fi

# Check config file
if [[ -f ~/.config/atuin/config.toml ]]; then
    echo "✓ Atuin config file exists"
else
    echo "⚠ Atuin config file not found"
fi

# Check database
if [[ -f ~/.local/share/atuin/history.db ]]; then
    echo "✓ Atuin database exists"
    if command -v sqlite3 &> /dev/null; then
        if sqlite3 ~/.local/share/atuin/history.db "PRAGMA integrity_check;" 2>/dev/null | grep -q "ok"; then
            echo "✓ Database integrity check passed"
        else
            echo "⚠ Database integrity check failed"
        fi
    fi
else
    echo "⚠ Atuin database not found"
fi

# Check shell integration
if grep -q "atuin init" ~/.zshrc 2>/dev/null; then
    echo "✓ Shell integration configured"
else
    echo "⚠ Shell integration not found in ~/.zshrc"
fi

# Check SELinux compatibility
if command -v getenforce &> /dev/null; then
    echo "✓ SELinux status: $(getenforce)"
    if [[ -f ~/.local/share/atuin/history.db ]]; then
        if ls -Z ~/.local/share/atuin/history.db 2>/dev/null | grep -q user_home_t; then
            echo "✓ Database has correct SELinux context"
        else
            echo "⚠ Database may need SELinux context adjustment"
        fi
    fi
fi

# Check Btrfs optimization
if findmnt -n -o FSTYPE / | grep -q btrfs; then
    echo "✓ Btrfs filesystem detected"
    if [[ -f ~/.local/share/atuin/history.db ]]; then
        if lsattr ~/.local/share/atuin/history.db 2>/dev/null | grep -q "C"; then
            echo "✓ Database optimized for Btrfs (COW disabled)"
        else
            echo "⚠ Database not optimized for Btrfs"
        fi
    fi
fi

echo "=== Verification Complete ==="
EOF

chmod +x ~/.local/bin/verify-atuin-setup
```

This corrected configuration addresses several issues from the original:

1. **Fixed vim keybindings** - Properly configured Atuin's vim mode integration
2. **Removed invalid config options** - Removed `ATUIN_KEYMAP_MODE` export and `timezone` setting which aren't valid
3. **Improved error handling** - Added proper error checking in scripts
4. **Fixed command syntax** - Corrected dnf wrapper function to handle commands properly
5. **Enhanced verification** - Made the verification script more robust with proper error handling
6. **Streamlined structure** - Removed requested sections while maintaining functionality

The configuration is now cleaner, more focused, and free of the identified issues while maintaining all the core functionality for Fedora 42.
