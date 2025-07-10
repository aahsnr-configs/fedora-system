# Advanced Zathura Configuration for Fedora Linux

Below is an optimized `zathurarc` configuration file with Catppuccin Mocha theme integration, Vim keybindings, and various quality-of-life improvements specifically tailored for Fedora Linux.

## Issues Fixed from Original Configuration

1. **Removed invalid options**: `embed-orientation`, `fs-screen`, `windowing-backend` - these don't exist in zathura
2. **Fixed mode syntax**: Changed `set mode-normal "<esc>"` to proper `map` syntax
3. **Corrected tab commands**: Fixed non-existent tab commands to use actual zathura functionality
4. **Fixed synctex command**: Corrected the synctex editor command syntax
5. **Removed deprecated options**: Cleaned up options that don't exist in modern zathura versions

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
map zi zoom in
map zo zoom out
map zz adjust_window best-fit
map zw adjust_window width

# Searching
map / search
map ? search backward
map n search next
map N search previous

# Mode switching
map <Escape> abort
map i focus_inputbar

# Page navigation
map <Page_Up> navigate previous
map <Page_Down> navigate next

# ----------------------------------
# Quality of Life Improvements
# ----------------------------------
# UI Settings
set guioptions ""
set window-title-basename "true"
set statusbar-home-tilde "true"
set statusbar-h-padding 8
set statusbar-v-padding 8
set adjust-open "best-fit"
set pages-per-row 1
set scroll-page-aware "true"
set scroll-full-overlap 0.01
set scroll-step 50

# Input Settings
set incremental-search "true"
set search-hadjust "true"
set selection-clipboard "clipboard"

# Performance Settings
set dbus-service "true"
set sandbox "strict"

# ----------------------------------
# Advanced Features
# ----------------------------------
# Synctex Features
set synctex "true"
set synctex-editor-command "code --goto %{input}:%{line}"

# Document Settings
set render-loading "false"
set page-padding 1
set first-page-column "1:1"

# ----------------------------------
# Font Configuration
# ----------------------------------
set font "monospace normal 9"

# ----------------------------------
# Color and Display Settings
# ----------------------------------
set index-fg "#cdd6f4"
set index-bg "#1e1e2e"
set index-active-fg "#1e1e2e"
set index-active-bg "#89b4fa"

set render-loading-fg "#cdd6f4"
set render-loading-bg "#1e1e2e"

# ----------------------------------
# Additional Vim-like Mappings
# ----------------------------------
# Quick zoom levels
map z1 set zoom 100
map z2 set zoom 200
map z3 set zoom 300
map z0 set zoom 50

# Quick page jumping
map <C-o> jumplist backward
map <C-i> jumplist forward

# Presentation mode
map <F5> set pages-per-row 1
map <F6> set pages-per-row 2

# Rotation
map r rotate rotate_cw
map R rotate rotate_ccw

# ----------------------------------
# Mouse Settings
# ----------------------------------
set smooth-scroll "true"
set scroll-wrap "false"
```

## Fedora Installation Instructions

### Install Zathura and Plugins

```bash
# Install zathura and all common plugins
sudo dnf install zathura zathura-plugins-all

# Or install specific plugins individually:
sudo dnf install zathura-pdf-poppler zathura-cb zathura-djvu zathura-ps
```

### Additional Recommended Packages

```bash
# For enhanced PDF support
sudo dnf install poppler-utils

# For synctex support with LaTeX
sudo dnf install texlive-synctex

# For additional document format support
sudo dnf install zathura-pdf-mupdf  # Alternative PDF backend
```

## Configuration Notes

### Synctex Editor Integration

The configuration includes VS Code integration by default. To use other editors:

**For Neovim:**
```sh
set synctex-editor-command "nvim --headless -c 'edit +%{line} %{input}'"
```

**For Emacs:**
```sh
set synctex-editor-command "emacsclient +%{line} %{input}"
```

**For Vim:**
```sh
set synctex-editor-command "vim +%{line} %{input}"
```

### Performance Optimization

For better performance on Fedora systems:

1. **Wayland Support**: Zathura works well with Wayland (default on Fedora)
2. **GPU Acceleration**: Ensure your graphics drivers are properly installed
3. **Memory Usage**: For large PDFs, consider adjusting the cache size in your system

### Troubleshooting

**If clipboard doesn't work:**
```bash
# Install clipboard utilities
sudo dnf install xclip wl-clipboard
```

**For HiDPI displays:**
Add to your zathurarc:
```sh
set zoom-step 20
set zoom-max 1000
```

## Key Features

- **Catppuccin Mocha Theme**: Modern, eye-friendly color scheme
- **Vim Keybindings**: Familiar navigation for Vim users
- **Synctex Support**: Seamless integration with LaTeX editors
- **Clipboard Integration**: Works with both X11 and Wayland
- **Performance Optimized**: Configured for smooth operation on Fedora
- **Accessibility**: Proper contrast ratios and readable fonts

This configuration provides a modern, efficient Zathura setup specifically optimized for Fedora Linux with all invalid options removed and proper Fedora package management instructions included.
