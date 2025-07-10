# Cliphist Configuration for openSUSE Tumbleweed

## Overview

This configuration provides a complete setup for `cliphist` (clipboard history manager) on openSUSE Tumbleweed with a beautiful Rofi interface using the Catppuccin Mocha theme.

## Initial Setup

### Create Required Directories

```bash
# Create all necessary directories
mkdir -p ~/.config/{cliphist,rofi/{themes,scripts},systemd/user,environment.d}
mkdir -p ~/.local/{bin,share/backups/cliphist}
mkdir -p ~/.cache/cliphist
```

## Cliphist Configuration

### Configuration File

Create `~/.config/cliphist/config`:

```bash
# Cliphist configuration file
max-items 1000
max-dedupe-search 300
preview-width 150
```

Available configuration options:
- `max-items`: Maximum number of items to store (default 750)
- `max-dedupe-search`: Maximum number of last items to look through when finding duplicates (default 100)
- `preview-width`: Maximum number of characters to preview (default 100)
- `db-path`: Path to database (default $XDG_CACHE_HOME/cliphist/db)

### Alternative Environment Variables Configuration

If you prefer environment variables, create `~/.config/environment.d/cliphist.conf`:

```bash
# Cliphist environment variables
CLIPHIST_MAX_ITEMS=1000
CLIPHIST_PREVIEW_WIDTH=150
CLIPHIST_MAX_DEDUPE_SEARCH=300
```

## System Integration

### Systemd User Service

Create `~/.config/systemd/user/cliphist.service`:

```ini
[Unit]
Description=Clipboard History Manager
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/wl-paste --watch /usr/bin/cliphist store
Restart=on-failure
RestartSec=3
Environment=PATH=/usr/local/bin:/usr/bin:/bin

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=false
ReadWritePaths=%h/.cache/cliphist
ReadWritePaths=%h/.config/cliphist

[Install]
WantedBy=default.target
```

Enable and start the service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now cliphist.service
```

### Multi-type Clipboard Support

For better image and text handling, create separate services:

**Text clipboard service** (`~/.config/systemd/user/cliphist-text.service`):

```ini
[Unit]
Description=Clipboard History Manager - Text
After=graphical-session.target
Wants=graphical-session.target
Conflicts=cliphist.service

[Service]
Type=simple
ExecStart=/usr/bin/wl-paste --type text --watch /usr/bin/cliphist store
Restart=on-failure
RestartSec=3
Environment=PATH=/usr/local/bin:/usr/bin:/bin

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=false
ReadWritePaths=%h/.cache/cliphist
ReadWritePaths=%h/.config/cliphist

[Install]
WantedBy=default.target
```

**Image clipboard service** (`~/.config/systemd/user/cliphist-image.service`):

```ini
[Unit]
Description=Clipboard History Manager - Images
After=graphical-session.target
Wants=graphical-session.target
Conflicts=cliphist.service

[Service]
Type=simple
ExecStart=/usr/bin/wl-paste --type image --watch /usr/bin/cliphist store
Restart=on-failure
RestartSec=3
Environment=PATH=/usr/local/bin:/usr/bin:/bin

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=false
ReadWritePaths=%h/.cache/cliphist
ReadWritePaths=%h/.config/cliphist

[Install]
WantedBy=default.target
```

**Note**: Use either the single `cliphist.service` OR the combined `cliphist-text.service` + `cliphist-image.service`, not both.

For the multi-type approach:

```bash
# Disable the single service if enabled
systemctl --user disable --now cliphist.service

# Enable the multi-type services
systemctl --user enable --now cliphist-text.service
systemctl --user enable --now cliphist-image.service
```

## Rofi Configuration

### Catppuccin Mocha Theme (`~/.config/rofi/themes/cliphist.rasi`)

```rasi
* {
    /* Catppuccin Mocha Colors */
    bg0: #1e1e2e;
    bg1: #181825;
    bg2: #313244;
    bg3: #45475a;
    fg0: #cdd6f4;
    fg1: #bac2de;
    fg2: #a6adc8;
    red: #f38ba8;
    green: #a6e3a1;
    yellow: #f9e2af;
    blue: #89b4fa;
    magenta: #f5c2e7;
    cyan: #94e2d5;
    
    background-color: transparent;
    text-color: @fg0;
    font: "JetBrains Mono 10";
}

window {
    location: center;
    anchor: center;
    width: 700px;
    border-radius: 12px;
    border: 2px solid;
    border-color: @blue;
    background-color: @bg0;
    padding: 0;
}

mainbox {
    background-color: transparent;
    children: [inputbar, listview, mode-switcher];
    padding: 20px;
    spacing: 15px;
}

inputbar {
    background-color: @bg1;
    border-radius: 8px;
    padding: 12px 16px;
    children: [prompt, entry];
    spacing: 12px;
}

prompt {
    text-color: @blue;
    font: "JetBrains Mono Bold 11";
}

entry {
    placeholder: "Search clipboard history...";
    placeholder-color: @fg2;
    text-color: @fg0;
    background-color: transparent;
}

listview {
    background-color: transparent;
    lines: 12;
    columns: 1;
    spacing: 4px;
    scrollbar: false;
    border: 0;
    dynamic: true;
    cycle: true;
}

element {
    background-color: transparent;
    border-radius: 6px;
    padding: 10px 14px;
    orientation: horizontal;
    children: [element-text];
}

element-text {
    background-color: transparent;
    text-color: @fg0;
    vertical-align: 0.5;
    font: "JetBrains Mono 9";
}

element normal.normal {
    background-color: transparent;
    text-color: @fg0;
}

element selected.normal {
    background-color: @bg2;
    text-color: @fg0;
    border: 1px solid @blue;
}

element alternate.normal {
    background-color: @bg1;
    text-color: @fg1;
}

mode-switcher {
    background-color: @bg1;
    border-radius: 8px;
    padding: 8px;
    spacing: 8px;
}

button {
    background-color: transparent;
    text-color: @fg2;
    border-radius: 4px;
    padding: 6px 12px;
}

button selected {
    background-color: @blue;
    text-color: @bg0;
}

message {
    background-color: @bg1;
    border-radius: 8px;
    padding: 12px;
    margin: 0;
    border: 1px solid @bg3;
}

textbox {
    text-color: @fg0;
    background-color: transparent;
    font: "JetBrains Mono 9";
}
```

### Cliphist Rofi Script (`~/.config/rofi/scripts/cliphist.sh`)

```bash
#!/usr/bin/env bash

# Cliphist Rofi Integration Script
set -euo pipefail

ROFI_THEME="$HOME/.config/rofi/themes/cliphist.rasi"

# Check if cliphist is installed
if ! command -v cliphist &> /dev/null; then
    echo "Error: cliphist is not installed"
    exit 1
fi

# Check if rofi is installed
if ! command -v rofi &> /dev/null; then
    echo "Error: rofi is not installed"
    exit 1
fi

# Function to show notification
show_notification() {
    local title="$1"
    local message="$2"
    local icon="${3:-edit-copy}"
    
    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message" -i "$icon" -t 1500
    fi
}

# Function to handle clipboard selection
main() {
    local selected
    
    # Get clipboard history and show in rofi
    selected=$(cliphist list | \
        rofi -dmenu -p "📋 Clipboard History" \
            -theme "$ROFI_THEME" \
            -i \
            -display-columns 2 \
            -display-column-separator $'\t' \
            -kb-custom-1 "Alt+d" \
            -kb-custom-2 "Alt+c" \
            -mesg "Enter: Copy | Alt+d: Delete | Alt+c: Clear All" \
            -format "s")
    
    # Handle rofi exit codes
    local exit_code=$?
    case $exit_code in
        0)
            # Normal selection - copy to clipboard
            if [[ -n "$selected" ]]; then
                echo "$selected" | cliphist decode | wl-copy
                show_notification "Clipboard" "Content copied"
            fi
            ;;
        10)
            # Alt+d pressed - delete mode
            if [[ -n "$selected" ]]; then
                delete_item "$selected"
            fi
            ;;
        11)
            # Alt+c pressed - clear all
            clear_all
            ;;
        1)
            # Escaped or cancelled
            exit 0
            ;;
        *)
            echo "Unexpected exit code: $exit_code"
            exit 1
            ;;
    esac
}

# Function to delete specific clipboard entry
delete_item() {
    local item="$1"
    
    if echo "$item" | cliphist delete; then
        show_notification "Clipboard" "Item deleted" "edit-delete"
    else
        show_notification "Clipboard" "Failed to delete item" "dialog-error"
    fi
}

# Function to delete clipboard entry (interactive mode)
delete_mode() {
    local selected
    
    selected=$(cliphist list | \
        rofi -dmenu -p "🗑️ Delete from Clipboard" \
            -theme "$ROFI_THEME" \
            -i \
            -display-columns 2 \
            -display-column-separator $'\t' \
            -mesg "Select item to delete" \
            -format "s")
    
    if [[ -n "$selected" ]]; then
        delete_item "$selected"
    fi
}

# Function to clear all clipboard history
clear_all() {
    local confirm
    
    confirm=$(echo -e "Yes\nNo" | \
        rofi -dmenu -p "Clear all clipboard history?" \
            -theme "$ROFI_THEME" \
            -mesg "This action cannot be undone")
    
    if [[ "$confirm" == "Yes" ]]; then
        if cliphist wipe; then
            show_notification "Clipboard" "History cleared" "edit-clear"
        else
            show_notification "Clipboard" "Failed to clear history" "dialog-error"
        fi
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        cat <<EOF
Cliphist Rofi Integration

Usage: $0 [OPTIONS]

OPTIONS:
    --help, -h      Show this help message
    --delete, -d    Delete specific item from clipboard
    --clear, -c     Clear all clipboard history
    --version, -v   Show version information

KEYBINDINGS:
    Enter           Copy selected item to clipboard
    Alt+d           Delete selected item
    Alt+c           Clear all clipboard history
    Escape          Cancel/Exit

EXAMPLES:
    $0              Show clipboard history
    $0 --delete     Delete specific item
    $0 --clear      Clear all history

EOF
        exit 0
        ;;
    --version|-v)
        echo "Cliphist Rofi Integration v1.0"
        echo "Dependencies:"
        echo "  - cliphist: $(cliphist --version 2>/dev/null || echo 'not found')"
        echo "  - rofi: $(rofi -version 2>/dev/null | head -1 || echo 'not found')"
        echo "  - wl-copy: $(wl-copy --version 2>/dev/null || echo 'not found')"
        exit 0
        ;;
    --delete|-d)
        delete_mode
        ;;
    --clear|-c)
        clear_all
        ;;
    *)
        main
        ;;
esac
```

Make the script executable:

```bash
chmod +x ~/.config/rofi/scripts/cliphist.sh
```

## Hyprland Integration

Add to `~/.config/hypr/hyprland.conf`:

```bash
# Clipboard bindings
bind = SUPER, V, exec, ~/.config/rofi/scripts/cliphist.sh
bind = SUPER_SHIFT, V, exec, ~/.config/rofi/scripts/cliphist.sh --delete
bind = SUPER_CTRL, V, exec, ~/.config/rofi/scripts/cliphist.sh --clear

# Start cliphist daemon (choose one approach)
# Single service approach:
# exec-once = systemctl --user start cliphist.service

# Multi-type approach (recommended):
exec-once = systemctl --user start cliphist-text.service
exec-once = systemctl --user start cliphist-image.service

# Manual daemon start (alternative to systemd):
# exec-once = wl-paste --type text --watch cliphist store
# exec-once = wl-paste --type image --watch cliphist store
```

## Utility Scripts

### Backup Script (`~/.local/bin/cliphist-backup`)

```bash
#!/bin/bash

set -euo pipefail

BACKUP_DIR="$HOME/.local/share/backups/cliphist"
DB_PATH="$HOME/.cache/cliphist/db"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to stop services
stop_services() {
    echo "Stopping cliphist services..."
    systemctl --user stop cliphist.service 2>/dev/null || true
    systemctl --user stop cliphist-text.service 2>/dev/null || true
    systemctl --user stop cliphist-image.service 2>/dev/null || true
    sleep 1
}

# Function to start services
start_services() {
    echo "Starting cliphist services..."
    # Start whichever services were originally running
    if systemctl --user is-enabled cliphist.service &>/dev/null; then
        systemctl --user start cliphist.service
    fi
    if systemctl --user is-enabled cliphist-text.service &>/dev/null; then
        systemctl --user start cliphist-text.service
    fi
    if systemctl --user is-enabled cliphist-image.service &>/dev/null; then
        systemctl --user start cliphist-image.service
    fi
}

# Trap to ensure services are restarted on exit
trap start_services EXIT

# Stop services
stop_services

# Create backup
if [[ -f "$DB_PATH" ]]; then
    BACKUP_FILE="$BACKUP_DIR/cliphist-$TIMESTAMP.db"
    cp "$DB_PATH" "$BACKUP_FILE"
    echo "✅ Backup created: $BACKUP_FILE"
    
    # Keep only last 10 backups
    find "$BACKUP_DIR" -name "cliphist-*.db" -type f | sort -r | tail -n +11 | xargs rm -f
    echo "📁 Cleaned old backups (kept last 10)"
else
    echo "❌ Database not found at $DB_PATH"
    exit 1
fi

# Show backup info
echo ""
echo "📊 Backup Information:"
echo "   Size: $(du -h "$BACKUP_FILE" | cut -f1)"
echo "   Items: $(cliphist list | wc -l) entries"
echo "   Location: $BACKUP_FILE"
```

### Cleanup Script (`~/.local/bin/cliphist-cleanup`)

```bash
#!/bin/bash

set -euo pipefail

# Sensitive patterns to remove
PATTERNS=(
    "password"
    "passwd"
    "token"
    "secret"
    "key"
    "auth"
    "credential"
    "login"
    "ssh"
    "api"
)

echo "🧹 Cleaning sensitive items from clipboard history..."

# Count items before cleanup
BEFORE_COUNT=$(cliphist list | wc -l)

# Remove items containing sensitive patterns
for pattern in "${PATTERNS[@]}"; do
    echo "   Removing items containing: $pattern"
    cliphist delete-query "$pattern" 2>/dev/null || true
done

# Count items after cleanup
AFTER_COUNT=$(cliphist list | wc -l)
REMOVED=$((BEFORE_COUNT - AFTER_COUNT))

echo ""
echo "✅ Cleanup completed!"
echo "   Items before: $BEFORE_COUNT"
echo "   Items after: $AFTER_COUNT"
echo "   Items removed: $REMOVED"

# Show notification if available
if command -v notify-send &> /dev/null; then
    notify-send "Clipboard Cleanup" "Removed $REMOVED sensitive items" -i edit-clear -t 3000
fi
```

### Status Script (`~/.local/bin/cliphist-status`)

```bash
#!/bin/bash

set -euo pipefail

echo "📋 Cliphist Status Report"
echo "========================"

# Check if cliphist is installed
if command -v cliphist &> /dev/null; then
    echo "✅ Cliphist: Installed"
else
    echo "❌ Cliphist: Not installed"
    exit 1
fi

# Check database
DB_PATH="$HOME/.cache/cliphist/db"
if [[ -f "$DB_PATH" ]]; then
    DB_SIZE=$(du -h "$DB_PATH" | cut -f1)
    ITEM_COUNT=$(cliphist list | wc -l)
    echo "✅ Database: $DB_PATH ($DB_SIZE, $ITEM_COUNT items)"
else
    echo "❌ Database: Not found at $DB_PATH"
fi

# Check services
echo ""
echo "🔧 Services:"
for service in cliphist cliphist-text cliphist-image; do
    if systemctl --user is-active "$service.service" &>/dev/null; then
        echo "   ✅ $service.service: Active"
    elif systemctl --user is-enabled "$service.service" &>/dev/null; then
        echo "   ⚠️  $service.service: Enabled but not active"
    else
        echo "   ❌ $service.service: Disabled"
    fi
done

# Check processes
echo ""
echo "🔍 Processes:"
if pgrep -f "cliphist" > /dev/null; then
    echo "   ✅ Cliphist processes running:"
    pgrep -f "cliphist" | while read -r pid; do
        echo "      PID $pid: $(ps -p "$pid" -o cmd --no-headers)"
    done
else
    echo "   ❌ No cliphist processes found"
fi

# Check configuration
echo ""
echo "⚙️  Configuration:"
CONFIG_FILE="$HOME/.config/cliphist/config"
if [[ -f "$CONFIG_FILE" ]]; then
    echo "   ✅ Config file: $CONFIG_FILE"
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        echo "      $line"
    done < "$CONFIG_FILE"
else
    echo "   ⚠️  No config file found (using defaults)"
fi

# Check rofi integration
echo ""
echo "🎨 Rofi Integration:"
ROFI_SCRIPT="$HOME/.config/rofi/scripts/cliphist.sh"
ROFI_THEME="$HOME/.config/rofi/themes/cliphist.rasi"

if [[ -x "$ROFI_SCRIPT" ]]; then
    echo "   ✅ Rofi script: $ROFI_SCRIPT"
else
    echo "   ❌ Rofi script: Not found or not executable"
fi

if [[ -f "$ROFI_THEME" ]]; then
    echo "   ✅ Rofi theme: $ROFI_THEME"
else
    echo "   ❌ Rofi theme: Not found"
fi

# Test clipboard functionality
echo ""
echo "🧪 Clipboard Test:"
if command -v wl-copy &> /dev/null && command -v wl-paste &> /dev/null; then
    echo "   ✅ wl-clipboard: Available"
    
    # Test basic clipboard functionality
    TEST_STRING="cliphist-test-$(date +%s)"
    echo "$TEST_STRING" | wl-copy
    if wl-paste | grep -q "$TEST_STRING"; then
        echo "   ✅ Clipboard: Working"
    else
        echo "   ❌ Clipboard: Not working properly"
    fi
else
    echo "   ❌ wl-clipboard: Not available"
fi

echo ""
echo "📈 Recent Activity:"
if [[ -f "$DB_PATH" ]] && [[ $ITEM_COUNT -gt 0 ]]; then
    echo "   Last 5 clipboard entries:"
    cliphist list | head -5 | while IFS=$'\t' read -r id preview; do
        echo "      $(echo "$preview" | cut -c1-50)..."
    done
else
    echo "   No clipboard history available"
fi
```

Make all scripts executable:

```bash
chmod +x ~/.local/bin/cliphist-{backup,cleanup,status}
```

## Troubleshooting

### Service Diagnostics

```bash
# Check service status
systemctl --user status cliphist.service

# View service logs
journalctl --user -u cliphist.service -f

# Check if database is being updated
watch -n 1 'ls -la ~/.cache/cliphist/db'

# Test clipboard manually
echo "test-$(date)" | wl-copy && cliphist list | head -1
```

### Common Issues and Solutions

1. **Service fails to start**:
   ```bash
   # Check if directories exist
   mkdir -p ~/.cache/cliphist ~/.config/cliphist
   
   # Verify permissions
   ls -la ~/.cache/cliphist/
   
   # Restart with debug
   systemctl --user stop cliphist.service
   wl-paste --watch cliphist store &
   ```

2. **No clipboard history**:
   ```bash
   # Test wl-clipboard
   wl-paste --list-types
   
   # Check if wl-paste is working
   echo "test" | wl-copy
   wl-paste
   
   # Verify cliphist is receiving data
   echo "test" | wl-copy
   cliphist list
   ```

3. **Rofi integration issues**:
   ```bash
   # Test rofi directly
   echo -e "test1\ntest2" | rofi -dmenu
   
   # Test with theme
   echo -e "test1\ntest2" | rofi -dmenu -theme ~/.config/rofi/themes/cliphist.rasi
   
   # Check rofi version and features
   rofi -help | grep display-columns
   ```

4. **Permission errors**:
   ```bash
   # Fix ownership
   sudo chown -R $USER:$USER ~/.cache/cliphist ~/.config/cliphist
   
   # Fix permissions
   chmod 755 ~/.cache/cliphist ~/.config/cliphist
   chmod 644 ~/.config/cliphist/config
   ```

### Performance Optimization

For systems with limited resources, adjust the configuration:

```bash
# In ~/.config/cliphist/config
max-items 500
max-dedupe-search 100
preview-width 80
```

### Debug Mode

Enable debug logging by running cliphist manually:

```bash
# Stop services
systemctl --user stop cliphist{,-text,-image}.service

# Run manually with debug
CLIPHIST_DEBUG=1 wl-paste --watch cliphist store
```

This comprehensive configuration provides a robust, well-tested clipboard history solution for openSUSE Tumbleweed with proper error handling, security considerations, and extensive troubleshooting capabilities.
