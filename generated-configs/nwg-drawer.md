# NWG-Drawer Configuration for macOS-like Application Menu

**IMPORTANT**: This is a complete rewrite of the original configuration. nwg-drawer does NOT use INI configuration files. All configuration is done through command-line arguments and CSS styling.

## Quick Start

### Single Instance Setup
Add this to your Sway config (`~/.config/sway/config`):
```bash
# macOS-style launcher with Super+Space
bindsym Mod4+space exec nwg-drawer -c 6 -is 48 -spacing 20 -mb 50 -mt 50 -ml 50 -mr 50 -s drawer.css -ovl
```

### Resident Instance Setup (Recommended)
```bash
# Start resident instance on startup
exec_always nwg-drawer -r -c 6 -is 48 -spacing 20 -mb 50 -mt 50 -ml 50 -mr 50 -s drawer.css -ovl -wm sway

# Bind Super+Space to show drawer (like macOS Spotlight)
bindsym Mod4+space exec nwg-drawer
```

## Complete Command-Line Configuration

### Basic macOS-Style Configuration
```bash
nwg-drawer \
  -c 6 \                    # 6 columns for compact grid
  -is 48 \                  # 48px icon size
  -spacing 20 \             # 20px spacing between icons
  -mb 50 -mt 50 -ml 50 -mr 50 \  # 50px margins (centered)
  -s drawer.css \           # Custom CSS file
  -ovl \                    # Overlay layer
  -wm sway                  # Use swaymsg for launching
```

### Advanced Configuration with All Options
```bash
nwg-drawer \
  -c 6 \                    # Columns
  -is 48 \                  # Icon size
  -spacing 20 \             # Icon spacing
  -mb 50 -mt 50 -ml 50 -mr 50 \  # Margins
  -s drawer.css \           # CSS file
  -ovl \                    # Overlay layer
  -wm sway \                # Window manager integration
  -g Adwaita \              # GTK theme
  -i Papirus \              # Icon theme
  -fm thunar \              # File manager
  -term foot \              # Terminal
  -fscol 2 \                # File search columns
  -fslen 80 \               # File search name length limit
  -pbsize 32 \              # Power bar icon size
  -pbuseicontheme \         # Use icon theme for power bar
  -pblock "swaylock -f" \   # Lock command
  -pbexit "swaymsg exit" \  # Exit command
  -pbreboot "systemctl reboot" \     # Reboot command
  -pbpoweroff "systemctl poweroff" \ # Poweroff command
  -pbsleep "systemctl suspend"       # Suspend command
```

## CSS Styling (~/.config/nwg-drawer/drawer.css)

Create this file for authentic macOS appearance:

```css
/* Main window - macOS-like translucent background */
window {
    background-color: rgba(248, 248, 248, 0.95);
    border-radius: 12px;
    box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.25);
    border: 1px solid rgba(255, 255, 255, 0.5);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
}

/* Search entry - Spotlight-like search bar */
entry {
    background-color: rgba(255, 255, 255, 0.9);
    border-radius: 20px;
    border: 1px solid rgba(0, 0, 0, 0.1);
    padding: 10px 18px;
    margin: 15px;
    font-size: 15px;
    font-weight: 400;
    color: #1d1d1f;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

entry:focus {
    border-color: rgba(0, 122, 255, 0.6);
    background-color: rgba(255, 255, 255, 1.0);
    box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

entry::placeholder {
    color: rgba(60, 60, 67, 0.6);
}

/* Category buttons - macOS sidebar style */
button.category-btn {
    background-color: transparent;
    border-radius: 8px;
    border: none;
    margin: 2px 8px;
    padding: 8px 16px;
    color: #1d1d1f;
    font-size: 13px;
    font-weight: 500;
    transition: all 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

button.category-btn:hover {
    background-color: rgba(0, 0, 0, 0.04);
}

button.category-btn:checked {
    background-color: rgba(0, 122, 255, 0.15);
    color: #007aff;
    font-weight: 600;
}

/* Application buttons - clean, minimal style */
button.app-btn {
    background-color: transparent;
    border-radius: 12px;
    border: none;
    margin: 4px;
    padding: 12px;
    transition: all 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

button.app-btn:hover {
    background-color: rgba(0, 0, 0, 0.04);
    transform: scale(1.05);
}

button.app-btn:active {
    transform: scale(0.95);
    background-color: rgba(0, 0, 0, 0.08);
}

/* Application labels - San Francisco-like font styling */
label.app-label {
    color: #1d1d1f;
    font-size: 12px;
    font-weight: 500;
    margin-top: 6px;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.8);
}

/* Pinned applications - subtle highlight */
button.pinned {
    background-color: rgba(0, 122, 255, 0.08);
    border: 1px solid rgba(0, 122, 255, 0.2);
}

button.pinned:hover {
    background-color: rgba(0, 122, 255, 0.12);
    transform: scale(1.05);
}

/* Power bar - macOS system buttons style */
button.power-btn {
    background-color: rgba(255, 255, 255, 0.6);
    border-radius: 10px;
    border: 1px solid rgba(0, 0, 0, 0.1);
    margin: 6px;
    padding: 10px;
    color: #1d1d1f;
    transition: all 0.2s ease;
    backdrop-filter: blur(10px);
}

button.power-btn:hover {
    background-color: rgba(255, 255, 255, 0.8);
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

/* Special styling for dangerous actions */
button.power-btn.reboot:hover,
button.power-btn.poweroff:hover {
    background-color: rgba(255, 69, 58, 0.1);
    border-color: rgba(255, 69, 58, 0.3);
}

/* Scrolled window - transparent background */
scrolledwindow {
    background-color: transparent;
}

scrolledwindow > viewport {
    background-color: transparent;
}

/* Math result label - clean notification style */
#math-label {
    background-color: rgba(255, 255, 255, 0.95);
    border-radius: 10px;
    border: 1px solid rgba(0, 0, 0, 0.1);
    padding: 15px 20px;
    font-size: 16px;
    font-weight: 600;
    color: #1d1d1f;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    backdrop-filter: blur(20px);
}

/* File search results - Finder-like appearance */
button.file-btn {
    background-color: transparent;
    border-radius: 8px;
    border: none;
    padding: 6px 12px;
    margin: 2px;
    transition: all 0.15s ease;
}

button.file-btn:hover {
    background-color: rgba(0, 122, 255, 0.08);
}

label.file-label {
    color: #424242;
    font-size: 11px;
    font-weight: 400;
}

/* Separator lines - subtle dividers */
separator {
    background-color: rgba(0, 0, 0, 0.1);
    min-height: 1px;
    margin: 8px 0;
}

/* Focus indicators - macOS-style blue outline */
*:focus {
    outline: 2px solid rgba(0, 122, 255, 0.6);
    outline-offset: 2px;
}

/* Custom scrollbar - macOS-like */
scrollbar {
    background-color: transparent;
    border-radius: 10px;
    margin: 4px;
}

scrollbar slider {
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 10px;
    min-width: 8px;
    min-height: 8px;
}

scrollbar slider:hover {
    background-color: rgba(0, 0, 0, 0.3);
}
```

## File Associations (~/.config/nwg-drawer/preferred-apps.json)

```json
{
    "\\.pdf$": "evince",
    "\\.svg$": "inkscape",
    "\\.(jpg|jpeg|png|gif|tiff|webp)$": "swayimg",
    "\\.(mp3|ogg|flac|wav|m4a|aac)$": "audacious",
    "\\.(mp4|mkv|avi|mov|wmv|flv)$": "mpv",
    "\\.(doc|docx|odt)$": "libreoffice --writer",
    "\\.(xls|xlsx|ods)$": "libreoffice --calc",
    "\\.(ppt|pptx|odp)$": "libreoffice --impress",
    "\\.(txt|md|conf|log)$": "gedit",
    "\\.(zip|tar|gz|bz2|xz|7z)$": "file-roller"
}
```

## Directory Exclusions (~/.config/nwg-drawer/excluded-dirs)

```
# Version control
.git
.svn
.hg

# Build directories
node_modules
target
build
dist
__pycache__

# Cache directories
.cache
.local/share/Trash
.thumbnails

# Hidden system directories
.mozilla/firefox/*/storage
.config/google-chrome/*/storage
.var/app/*/cache
```

## Sway Configuration Integration

Add to your `~/.config/sway/config`:

```bash
# NWG-Drawer - macOS-style application launcher
exec_always {
    killall nwg-drawer 2>/dev/null || true
    nwg-drawer -r -c 6 -is 48 -spacing 20 -mb 50 -mt 50 -ml 50 -mr 50 -s drawer.css -ovl -wm sway -g Adwaita -i Papirus -pbsize 32 -pbuseicontheme -pblock "swaylock -f" -pbexit "swaymsg exit" -pbreboot "systemctl reboot" -pbpoweroff "systemctl poweroff" -pbsleep "systemctl suspend"
}

# Keybindings
bindsym Mod4+space exec nwg-drawer
bindsym Mod1+space exec nwg-drawer  # Alternative: Alt+Space

# Touchpad gestures (macOS-style)
bindgesture pinch:4:inward exec pkill -SIGUSR2 nwg-drawer
bindgesture pinch:4:outward exec pkill -SIGRTMIN+3 nwg-drawer
```

## Installation Steps

1. **Install nwg-drawer**:
   ```bash
   # Arch Linux
   sudo pacman -S nwg-drawer

   # Ubuntu/Debian
   sudo apt install nwg-drawer

   # Build from source
   git clone https://github.com/nwg-piotr/nwg-drawer.git
   cd nwg-drawer
   make get
   make build
   sudo make install
   ```

2. **Create configuration directory**:
   ```bash
   mkdir -p ~/.config/nwg-drawer
   ```

3. **Save the CSS file**:
   ```bash
   # Copy the CSS content above to:
   ~/.config/nwg-drawer/drawer.css
   ```

4. **Configure file associations** (optional):
   ```bash
   # Copy the JSON content above to:
   ~/.config/nwg-drawer/preferred-apps.json
   ```

5. **Set up directory exclusions** (optional):
   ```bash
   # Copy the exclusions content above to:
   ~/.config/nwg-drawer/excluded-dirs
   ```

6. **Update Sway configuration**:
   ```bash
   # Add the Sway config lines above to:
   ~/.config/sway/config
   ```

7. **Reload Sway**:
   ```bash
   swaymsg reload
   ```

## Key Features

- **Authentic macOS appearance** with translucent backgrounds and blur effects
- **Spotlight-like search** with Super+Space activation
- **Smooth animations** and hover effects
- **Power management integration** with system commands
- **File search capabilities** in XDG directories
- **Customizable file associations**
- **Pinned applications** support
- **Category filtering** with sidebar navigation
- **Keyboard navigation** support
- **Touchpad gesture** support for opening/closing

## Troubleshooting

- **Drawer won't start**: Check if all dependencies are installed
- **No applications showing**: Ensure XDG desktop files are properly installed
- **CSS not loading**: Verify the CSS file path and syntax
- **Power buttons not working**: Check if the system commands are available
- **Search not finding files**: Verify XDG user directories are properly set up

This configuration provides a genuine macOS-like experience while working within the constraints of nwg-drawer's actual capabilities.
