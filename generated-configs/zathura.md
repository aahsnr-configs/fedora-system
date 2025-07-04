# Advanced Zathura Configuration for Fedora Linux 42

Below is a corrected and optimized `zathurarc` configuration file with Catppuccin Mocha theme integration, proper Vim keybindings, and Fedora-specific optimizations.

```sh
# ~/.config/zathura/zathurarc

# ----------------------------------
# Catppuccin Mocha Theme
# ----------------------------------
set default-bg                  "#1e1e2e"  # base
set default-fg                  "#cdd6f4"  # text

set statusbar-fg                "#cdd6f4"  # text
set statusbar-bg                "#585b70"  # surface2

set inputbar-bg                 "#1e1e2e"  # base
set inputbar-fg                 "#cdd6f4"  # text

set notification-bg             "#1e1e2e"  # base
set notification-fg             "#cdd6f4"  # text
set notification-error-bg       "#1e1e2e"  # base
set notification-error-fg       "#f38ba8"  # red
set notification-warning-bg     "#1e1e2e"  # base
set notification-warning-fg     "#fab387"  # peach

set highlight-color             "#f5c2e7"  # pink
set highlight-active-color      "#f5e0dc"  # rosewater

set completion-highlight-fg     "#1e1e2e"  # base
set completion-highlight-bg     "#89b4fa"  # blue
set completion-bg               "#313244"  # surface0
set completion-fg               "#cdd6f4"  # text

set recolor-lightcolor          "#1e1e2e"  # base
set recolor-darkcolor           "#cdd6f4"  # text
set recolor                     "true"
set recolor-keephue             "true"

# ----------------------------------
# Vim-like Keybindings
# ----------------------------------
# Navigation
map j scroll down
map k scroll up
map h scroll left
map l scroll right
map J navigate next
map K navigate previous
map gg goto top
map G goto bottom
map <C-u> scroll half-up
map <C-d> scroll half-down
map <C-f> scroll full-down
map <C-b> scroll full-up

# Zooming
map + zoom in
map - zoom out
map = zoom in
map 0 adjust_window best-fit
map zi zoom in
map zo zoom out
map zz adjust_window best-fit

# Searching
map / search
map ? search backward
map n search next
map N search previous

# Rotation
map r rotate
map R rotate

# Index navigation
map <Tab> toggle_index
map <C-m> toggle_index

# ----------------------------------
# Quality of Life Improvements
# ----------------------------------
# UI Settings
set window-title-basename       "true"
set statusbar-home-tilde        "true"
set statusbar-h-padding         8
set statusbar-v-padding         8
set adjust-open                 "best-fit"
set pages-per-row               1
set scroll-page-aware           "true"
set scroll-full-overlap         0.01
set scroll-step                 50
set scroll-wrap                 "false"

# Input Settings
set incremental-search          "true"
set search-hadjust              "true"
set selection-clipboard         "clipboard"

# Performance Settings
set render-loading              "false"
set render-loading-fg           "#cdd6f4"
set render-loading-bg           "#1e1e2e"

# Database Settings
set database                    "sqlite"

# Page settings
set page-padding                1
set page-store-threshold        3600
set page-store-interval         30
set advance-pages-per-row       "false"

# ----------------------------------
# Advanced Features
# ----------------------------------
# SyncTeX Features
set synctex                     "true"
set synctex-editor-command      "code --goto %{input}:%{line}"

# Document Settings
set show-hidden                 "false"
set show-directories            "true"
set show-recent                 10

# Zoom settings
set zoom-min                    10
set zoom-max                    1000
set zoom-step                   10

# Highlight settings
set highlight-transparency      0.5

# ----------------------------------
# Fedora-Specific Settings
# ----------------------------------
# Use clipboard for selections
set selection-clipboard         "clipboard"

# Security settings
set sandbox                     "normal"

# Font settings optimized for Fedora's default fonts
set font                        "Liberation Sans 11"

# ----------------------------------
# Advanced Keyboard Shortcuts
# ----------------------------------
# Mode switching
map i change_mode insert
map <Esc> abort

# Navigation enhancements
map <PageUp> navigate previous
map <PageDown> navigate next
map <Home> goto top
map <End> goto bottom

# Toggle features
map <C-r> recolor
map <C-i> toggle_index
map <C-n> toggle_statusbar
map <F11> toggle_fullscreen

# Focus management
map <C-l> focus_inputbar

# Quit shortcuts
map q quit
map <C-q> quit
map ZZ quit
map ZQ quit

# Reload document
map <C-R> reload
map <F5> reload

# Follow links
map f follow
map <Return> follow

# Presentation mode
map <F5> toggle_fullscreen

# Buffer commands for quick access
map H goto top
map L goto bottom
map M goto top

# ----------------------------------
# Mouse Settings (if needed)
# ----------------------------------
# Mouse wheel scrolling is handled by default
# Custom mouse mappings can be added here if needed
# map <Button4> scroll up
# map <Button5> scroll down

# ----------------------------------
# Search enhancements
# ----------------------------------
set abort-clear-search          "true"
```

## Fedora Installation Guide

### Installing Zathura on Fedora 42

```bash
# Install Zathura core and all plugins
sudo dnf install zathura zathura-plugins-all

# Or install specific plugins only
sudo dnf install zathura \
    zathura-pdf-poppler \
    zathura-epub \
    zathura-djvu \
    zathura-ps \
    zathura-cb

# Install additional dependencies for full functionality
sudo dnf install poppler-utils texlive-synctex
```

### Plugin Overview for Fedora

- **zathura-pdf-poppler**: PDF support (most common)
- **zathura-epub**: EPUB support
- **zathura-djvu**: DjVu support
- **zathura-ps**: PostScript support
- **zathura-cb**: Comic book archive support (CBZ, CBR)

## Major Corrections Made

### Fixed Invalid Options:
1. **Removed invalid options**: Eliminated non-existent options like:
   - `guioptions`
   - `smooth-scroll`
   - `continuous-hist-save`
   - `link-zoom`
   - `link-hadjust`
   - `dbus-service`
   - `seccomp`
   - `window-height`
   - `window-width`
   - `window-icon`
   - `default-font`
   - `print-command`

### Fixed Keybinding Issues:
1. **Corrected navigation commands**: 
   - `goto top/bottom` instead of invalid `navigate first/last`
   - Fixed `adjust_window` syntax
2. **Removed invalid keybindings**:
   - Tab navigation (not supported by default)
   - Bookmark commands (not standard zathura functions)
   - Invalid shortcuts like `<C-6>`, `<C-t>`
3. **Added proper function names**: Used only documented shortcut functions

### Fixed Configuration Syntax:
1. **Proper option names**: Used only documented configuration options
2. **Correct value formats**: Ensured all values match expected types
3. **Valid shortcut functions**: Used only functions listed in official documentation

### Added Missing Valid Options:
1. **Search settings**: `abort-clear-search`, `search-hadjust`
2. **Performance settings**: `page-store-threshold`, `page-store-interval`
3. **Zoom settings**: `zoom-min`, `zoom-max`, `zoom-step`
4. **Highlight settings**: `highlight-transparency`

## Key Improvements

### 1. **Standards Compliance**
- All options are now from the official zathura documentation
- All keybindings use valid shortcut functions
- Proper syntax for all configuration entries

### 2. **Performance Optimization**
- Correct page store settings for memory management
- Proper scroll and zoom configurations
- Optimized for Fedora's default setup

### 3. **Enhanced Usability**
- Better vim-like navigation
- Proper search functionality
- Correct clipboard integration
- Valid fullscreen and presentation modes

### 4. **Fedora Integration**
- Uses Liberation Sans font (Fedora default)
- Proper clipboard settings for Wayland/X11
- Optimized for Fedora's document viewer ecosystem

## Additional Recommendations

### 1. Editor Integration
For different editors, update the synctex command:

```bash
# For Vim/Neovim
set synctex-editor-command "nvim +%{line} %{input}"

# For Emacs
set synctex-editor-command "emacsclient +%{line} %{input}"

# For gedit (GNOME default)
set synctex-editor-command "gedit +%{line} %{input}"
```

### 2. Creating the Configuration Directory
```bash
mkdir -p ~/.config/zathura
```

### 3. Testing the Configuration
```bash
zathura --config-dir ~/.config/zathura /path/to/test.pdf
```

This configuration now contains only valid, documented options and functions, ensuring compatibility with current zathura versions and proper functionality on Fedora Linux 42.
