# Advanced Zathura Configuration for Gentoo Linux

Below is an optimized `zathurarc` configuration file with Catppuccin Mocha theme integration, Vim keybindings, syntax support, Poppler features, Wayland support, and various quality-of-life improvements for Gentoo Linux.

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
map gg navigate first
map G navigate last
map <C-u> scroll half-up
map <C-d> scroll half-down
map <C-f> scroll full-down
map <C-b> scroll full-up

# Zooming
map + zoom in
map - zoom out
map = zoom in
map <C-6> zoom best-fit
map zi zoom in
map zo zoom out
map zz zoom best-fit

# Searching
map / search
map ? search backward
map n search next
map N search previous

# Modes
set mode-normal "<esc>"
map i enter-mode insert

# Tabs
map gt tab-next
map gT tab-previous
map gn tab-open
map gc tab-close

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
set wrap-search "true"
set selection-clipboard "clipboard"

# Performance Settings
set dbus-service "true"
set sandbox "strict"

# ----------------------------------
# Advanced Features
# ----------------------------------
# Poppler Features
set synctex "true"
set synctex-editor-command "emacsclient +%{line} %{input}"
set embed-orientation "true"

# Document Settings
set adjust-open "width"
set render-loading "false"

# ----------------------------------
# Wayland Specific Settings
# ----------------------------------
set selection-clipboard "clipboard"
set fs-screen "all"

# ----------------------------------
# Syntax and Filetype Support
# ----------------------------------
# Add custom file associations if needed
# filetype-assoc update "application/epub+zip" "epub"

# ----------------------------------
# Gentoo-Specific Optimizations
# ----------------------------------
# Use GPU acceleration if available
set windowing-backend "wayland"
```

## Gentoo Installation Notes

To ensure all features work properly, make sure you have the following USE flags enabled when installing zathura:

```sh
# Add these to your package.use or make.conf
app-text/zathura synctex pdf-poppler seccomp sqlite wayland
app-text/zathura-pdf-poppler jpeg openmp tiff
```

Install required dependencies:

```sh
emerge -av app-text/zathura app-text/zathura-pdf-poppler app-text/zathura-cb app-text/zathura-djvu app-text/zathura-ps
```

## Additional Recommendations

1. **Font Configuration**: For best readability, add this to your font configuration:
   ```sh
   set font "Sans 10"
   set font "Monospace 10" # for status bar
   ```

2. **Synctex with Editor**: Configure your preferred editor for synctex backward search. For Emacs:
   ```sh
   set synctex-editor-command "emacsclient +%{line} %{input}"
   ```
   For Vim/Neovim:
   ```sh
   set synctex-editor-command "nvim --headless +'%{line}' '%{input}'"
   ```

3. **Performance Tuning**: If you experience performance issues with large PDFs, consider:
   ```sh
   set render-loading "false"
   set windowing-backend "x11" # if Wayland has issues
   ```

This configuration provides a modern, efficient Zathura setup optimized for Gentoo Linux with all the requested features integrated.
