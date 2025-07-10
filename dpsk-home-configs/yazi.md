# Complete Yazi Configuration with Catppuccin Mocha Theme

Here's a unified, advanced configuration for Yazi file manager with Catppuccin Mocha theme, Nerd Fonts, Vim keybindings, and quality-of-life improvements for Gentoo Linux.

## File Structure

```
~/.config/yazi/
├── yazi.toml        # Main configuration
├── theme.toml       # Catppuccin Mocha theme
├── keymap.toml      # Vim-style keybindings
└── plugins/
    └── preview.toml # File preview configuration
```

## Installation and Setup for Gentoo Linux

### 1. Install Required Dependencies

```bash
# Install Yazi and dependencies
sudo emerge -av app-misc/yazi dev-lang/rust media-libs/fontconfig x11-libs/libxcb

# Install Nerd Fonts (choose one or more)
sudo emerge -av media-fonts/nerd-fonts
# or specific fonts:
sudo emerge -av media-fonts/jetbrains-mono-nerd media-fonts/firacode-nerdfont

# Install preview and utility dependencies
sudo emerge -av media-video/ffmpeg app-text/pandoc app-text/poppler 
sudo emerge -av app-arch/unrar app-arch/zip app-arch/unzip app-arch/atool
sudo emerge -av media-gfx/imagemagick app-shells/fzf app-misc/zoxide
sudo emerge -av app-misc/trash-cli
```

### 2. Create Configuration Directory

```bash
mkdir -p ~/.config/yazi/plugins
```

## Configuration Files

### `~/.config/yazi/yazi.toml` (Main Configuration)

```toml
[manager]
# Display settings
show_hidden = false
show_symlink = true
linemode = "size"
scrolloff = 3
mouse_support = true

# Icons and visual
icons = true
icon_size = 14
icon_theme = "fancy"

# Sorting
sort_by = "natural"
sort_dir_first = true
sort_reverse = false
sort_case_insensitive = true
sort_sensitive = false

# Behavior
select_all_on_hover = false
trash_method = "auto"
hover_delay = 200
max_preview_size = 1024 # in KB

# Preview settings
preview_images = true
preview_videos = true
preview_audio = true
preview_pdf = true

# Vim-like behavior
cursor_style = "block"
cursor_blink = true

[preview]
max_width = 800
max_height = 600
cache_dir = "~/.cache/yazi/preview"
image_quality = 80
image_filter = "catimg -w 80"
image_ueberzug = true
image_ueberzug_scale = 1
image_ueberzug_x = 0
image_ueberzug_y = 0
image_ueberzug_width = 0
image_ueberzug_height = 0

[finder]
position = "right"
width = 30
max_results = 50
wrap_around = true
highlight = true
case_sensitive = false
smart_case = true
fuzzy = true
regex = false

[tab]
show_index = true
show_title = true
show_hidden = true
show_powerline = true
position = "top"
width = 20

[status]
show_mode = true
show_progress = true
show_sync = true
show_permissions = true
show_owner = true
show_group = true
show_size = true
show_created = true
show_modified = true

[task]
max_operations = 10
retry_failed = true
notify_completion = true

[opener]
edit = ["nvim", "vim", "micro", "nano"]
open = ["xdg-open"]
rules = [
    { mime = "text/*", use = "edit" },
    { mime = "inode/directory", use = "open" },
    { mime = "image/*", use = "open" },
    { mime = "video/*", use = "open" },
    { mime = "audio/*", use = "open" },
    { mime = "application/pdf", use = "open" },
]

[log]
level = "warn"
max_files = 5
max_file_size = "10MB"

[plugin]
preload = [
    "fzf",
    "zoxide",
    "file-type",
    "image-preview",
    "archive",
    "trash",
]
preview = ["image", "video", "pdf", "archive", "text"]
finder = ["fzf"]
archive = ["zip", "tar", "rar"]
```

### `~/.config/yazi/theme.toml` (Catppuccin Mocha Theme)

```toml
[manager]
# Base colors
bg = "#1e1e2e"             # Base
fg = "#cdd6f4"             # Text
background = "#1e1e2e"
foreground = "#cdd6f4"

# Selection colors
selection_bg = "#585b70"   # Surface2
selection_fg = "#cdd6f4"   # Text
selection = "#585b70"

# Cursor colors
cursor_bg = "#f5e0dc"      # Rosewater
cursor_fg = "#1e1e2e"      # Base
cursor = "#f5e0dc"

# Border colors
border_bg = "#1e1e2e"      # Base
border_fg = "#7f849c"      # Overlay0
border = "#45475a"         # Surface1

# Preview colors
preview_bg = "#1e1e2e"     # Base
preview_fg = "#cdd6f4"     # Text

# Status colors
status_bg = "#181825"      # Mantle
status_fg = "#cdd6f4"      # Text

# Tab colors
tab_active_bg = "#cba6f7"  # Mauve
tab_active_fg = "#1e1e2e"  # Base
tab_inactive_bg = "#6c7086" # Surface2
tab_inactive_fg = "#1e1e2e" # Base
tab_active = "#89b4fa"     # Blue
tab_inactive = "#6c7086"   # Surface2
tab_width = 20

# Finder colors
finder_bg = "#313244"      # Surface0
finder_fg = "#cdd6f4"      # Text

# Highlight colors
highlight_bg = "#585b70"   # Surface2
highlight_fg = "#cdd6f4"   # Text
highlighted_bg = "#585b70"
highlighted_fg = "#cdd6f4"

# Hovered items
hovered_bg = "#313244"     # Surface0
hovered_fg = "#cdd6f4"     # Text

# Active and inactive
active = "#b4befe"         # Lavender
inactive = "#6c7086"       # Surface2

# Special colors
link = "#89b4fa"           # Blue
error = "#f38ba8"          # Red
warning = "#f9e2af"        # Yellow
info = "#74c7ec"           # Sapphire
success = "#a6e3a1"        # Green

# File type colors
file = "#cdd6f4"           # Text
directory = "#89b4fa"      # Blue
symlink = "#f5c2e7"        # Pink
executable = "#a6e3a1"     # Green
image = "#fab387"          # Peach
video = "#f38ba8"          # Red
audio = "#cba6f7"          # Mauve
archive = "#f9e2af"        # Yellow
temp = "#f2cdcd"           # Flamingo
special = "#b4befe"        # Lavender

[status]
bg = "#1e1e2e"             # Base
fg = "#cdd6f4"             # Text
separator = "#7f849c"      # Overlay0
# Mode indicators
mode_normal = "#a6e3a1"    # Green
mode_select = "#f9e2af"    # Yellow
mode_unset = "#f38ba8"     # Red
# Progress bar
progress_bg = "#313244"    # Surface0
progress_fg = "#89b4fa"    # Blue

[input]
bg = "#1e1e2e"             # Base
fg = "#cdd6f4"             # Text
border = "#7f849c"         # Overlay0
# Placeholder
placeholder = "#6c7086"    # Surface2
# Suggestions
suggestions_bg = "#313244" # Surface0
suggestions_fg = "#7f849c" # Overlay0
# Selected suggestion
selected_bg = "#585b70"    # Surface2
selected_fg = "#cdd6f4"    # Text

[completion]
bg = "#1e1e2e"             # Base
fg = "#cdd6f4"             # Text
border = "#7f849c"         # Overlay0
fg_match = "#89b4fa"       # Blue
# Selected item
selected_bg = "#585b70"    # Surface2
selected_fg = "#cdd6f4"    # Text

[preview]
# Default preview colors
default_bg = "#1e1e2e"     # Base
default_fg = "#cdd6f4"     # Text
hovered = "#313244"        # Surface0
# Highlighting in previews
highlight_bg = "#585b70"   # Surface2
highlight_fg = "#cdd6f4"   # Text
# Line numbers
linenum_bg = "#1e1e2e"     # Base
linenum_fg = "#6c7086"     # Surface2
# Matched text in preview
matched_bg = "#f9e2af"     # Yellow
matched_fg = "#1e1e2e"     # Base

[tab]
bg = "#1e1e2e"             # Base
fg = "#cdd6f4"             # Text
# Active tab
active_bg = "#cba6f7"      # Mauve
active_fg = "#1e1e2e"      # Base
# Inactive tabs
inactive_bg = "#313244"    # Surface0
inactive_fg = "#7f849c"    # Overlay0
# Hovered tab
hovered_bg = "#45475a"     # Surface1
hovered_fg = "#cdd6f4"     # Text

[header]
bg = "#1e1e2e"             # Base
fg = "#cdd6f4"             # Text
border = "#7f849c"         # Overlay0

[highlight]
bg = "#45475a"             # Surface1
fg = "#f5e0dc"             # Rosewater

[file]
# Default file colors
fg = "#cdd6f4"             # Text
bg = "#1e1e2e"             # Base
# File type colors
directory = "#89b4fa"      # Blue
link = "#74c7ec"           # Sapphire
socket = "#fab387"         # Peach
pipe = "#f9e2af"           # Yellow
executable = "#a6e3a1"     # Green
block = "#f5c2e7"          # Pink
char = "#94e2d5"           # Teal
# Special files
special = "#cba6f7"        # Mauve
# MIME type colors
image = "#f5bde6"          # Pink
video = "#f5a97f"          # Flamingo
audio = "#91d7e3"          # Sky
archive = "#eed49f"        # Yellow
# Other files
temp = "#9399b2"           # Subtext0
document = "#a6adc8"       # Subtext1

[filetype]
rules = [
    { mime = "image/*", fg = "#f5bde6" },
    { mime = "video/*", fg = "#f9e2af" },
    { mime = "audio/*", fg = "#fab387" },
    { mime = "application/pdf", fg = "#f38ba8" },
    { name = "*.rs", fg = "#f38ba8" },
    { name = "*.go", fg = "#74c7ec" },
    { name = "*.py", fg = "#89b4fa" },
    { name = "*.sh", fg = "#a6e3a1" },
    { name = "*.toml", fg = "#89dceb" },
    { name = "*.json", fg = "#f9e2af" },
    { name = "*.md", fg = "#74c7ec" },
    { name = "*.html", fg = "#fab387" },
    { name = "*.css", fg = "#89b4fa" },
    { name = "*.js", fg = "#f9e2af" },
    { name = "*.ts", fg = "#74c7ec" },
    { name = "*config*", fg = "#cba6f7" },
    { name = "*.lock", fg = "#585b70" },
    { name = "*.log", fg = "#585b70" },
    { name = "*.tmp", fg = "#585b70" },
    { name = "*.bak", fg = "#585b70" },
]

[icons]
rules = [
    { name = "*.rs", icon = "" },
    { name = "*.go", icon = "" },
    { name = "*.py", icon = "" },
    { name = "*.sh", icon = "" },
    { name = "*.toml", icon = "" },
    { name = "*.json", icon = "" },
    { name = "*.md", icon = "" },
    { name = "*.html", icon = "" },
    { name = "*.css", icon = "" },
    { name = "*.js", icon = "" },
    { name = "*.ts", icon = "" },
    { name = "*config*", icon = "" },
    { name = "*.lock", icon = "" },
    { name = "*.log", icon = "" },
    { name = "*.tmp", icon = "" },
    { name = "*.bak", icon = "" },
    { name = "*.zip", icon = "" },
    { name = "*.gz", icon = "" },
    { name = "*.tar", icon = "" },
    { name = "*.xz", icon = "" },
    { name = "*.7z", icon = "" },
    { name = "*.deb", icon = "" },
    { name = "*.rpm", icon = "" },
    { name = "*.png", icon = "" },
    { name = "*.jpg", icon = "" },
    { name = "*.jpeg", icon = "" },
    { name = "*.gif", icon = "" },
    { name = "*.svg", icon = "" },
    { name = "*.mp4", icon = "" },
    { name = "*.mkv", icon = "" },
    { name = "*.webm", icon = "" },
    { name = "*.mp3", icon = "" },
    { name = "*.flac", icon = "" },
    { name = "*.wav", icon = "" },
    { name = "*.pdf", icon = "" },
    { name = "*.epub", icon = "" },
    { name = "dir", icon = "" },
    { name = "dir-git", icon = "" },
    { name = "dir-git-ignored", icon = "" },
    { name = "dir-git-modified", icon = "" },
    { name = "dir-git-untracked", icon = "" },
    { name = "file", icon = "" },
    { name = "file-executable", icon = "" },
    { name = "file-hidden", icon = "" },
    { name = "file-symlink", icon = "" },
    { name = "file-broken-symlink", icon = "" },
]
```

### `~/.config/yazi/keymap.toml` (Vim-style Keybindings)

```toml
[manager]
# Navigation
"h" = "leave"
"j" = "arrow_down"
"k" = "arrow_up"
"l" = "enter"
"gg" = "arrow_top"
"G" = "arrow_bottom"
"ctrl+d" = "arrow_down_10"
"ctrl+u" = "arrow_up_10"
"ctrl+f" = "page_down"
"ctrl+b" = "page_up"
"~" = "cd ~"
"-" = "cd_parent"

# File operations
"y" = "copy"
"x" = "cut"
"d" = "cut"
"p" = "paste"
"dd" = "remove"
"v" = "visual_mode"
"V" = "visual_mode_line"
"ctrl+v" = "visual_mode_block"
"a" = "create"
"r" = "rename"
"m" = "rename"
"u" = "undo"
"z" = "undo"
"ctrl+r" = "redo"
"Z" = "redo"
"c" = "cd"
"o" = "open"
"O" = "open_with"

# Searching
"/" = "search"
"n" = "search_next"
"N" = "search_prev"
"*" = "search_glob"
"f" = "find"
"F" = "find_arrow"

# Selection
" " = "select"
"ctrl+a" = "select_all"
"gr" = "select_none"
"gt" = "select_invert"

# Tabs
"t" = "tab_create"
"T" = "tab_close"
"w" = "tab_close"
"ctrl+t" = "tab_create"
"ctrl+w" = "tab_close"
"[" = "tab_prev"
"]" = "tab_next"
"gT" = "tab_prev"
"gt" = "tab_next"
"{" = "tab_swap_prev"
"}" = "tab_swap_next"
"1" = "tab_switch 0"
"2" = "tab_switch 1"
"3" = "tab_switch 2"
"4" = "tab_switch 3"
"5" = "tab_switch 4"
"6" = "tab_switch 5"
"7" = "tab_switch 6"
"8" = "tab_switch 7"
"9" = "tab_switch 8"

# Misc
"q" = "quit"
"Q" = "quit --force"
":" = "shell"
"!" = "shell --block"
"?" = "help"
"esc" = "escape"
"ctrl+l" = "refresh"
"ctrl+n" = "show_hidden"
"ctrl+s" = "peek"
"ctrl+z" = "suspend"
"i" = "reveal"
"R" = "reload"

[input]
"esc" = "escape"
"ctrl+c" = "escape"
"ctrl+n" = "arrow_down"
"ctrl+p" = "arrow_up"
"ctrl+f" = "move_forward"
"ctrl+b" = "move_backward"
"ctrl+a" = "move_to_start"
"ctrl+e" = "move_to_end"
"ctrl+u" = "backspace_line"
"ctrl+w" = "backspace_word"
"ctrl+d" = "delete_forward"
"ctrl+h" = "backspace"
"backspace" = "backspace"
"delete" = "delete_forward"
"enter" = "submit"
```

### `~/.config/yazi/plugins/preview.toml`

```toml
[preview]
image = true
video = true
pdf = true
archive = true
text = true
json = true
code = true
```

## Quality of Life Improvements

### 1. Shell Aliases

Add these aliases to your shell config (`~/.bashrc` or `~/.zshrc`):

```bash
# Yazi aliases for quick access
alias yy='yazi'
alias yz='yazi $(pwd)'

# Yazi with directory tracking
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

### 2. Zoxide Integration

```bash
# Add to your shell config for better directory jumping
eval "$(zoxide init bash)"  # or zsh if you use zsh
```

### 3. Desktop Entry (Optional)

Create `~/.local/share/applications/yazi.desktop`:

```ini
[Desktop Entry]
Name=Yazi File Manager
Comment=A terminal file manager with Vim keybindings
Exec=yazi
Icon=system-file-manager
Terminal=true
Type=Application
Categories=Utility;FileManager;
Keywords=file;manager;terminal;
StartupNotify=true
```

### 4. Terminal Configuration

Make sure your terminal emulator:
- Uses a Nerd Font for proper icon display
- Has the Catppuccin Mocha color scheme for consistency
- Supports true color (24-bit color)

## Features Overview

This unified configuration provides:

- **Beautiful Catppuccin Mocha theme** with proper color coding for different file types
- **Comprehensive Vim-style keybindings** for efficient navigation and file operations
- **Nerd Fonts integration** with extensive icon support for various file types
- **Advanced preview capabilities** for images, videos, PDFs, and archives
- **Plugin support** for fzf, zoxide, and other useful tools
- **Quality-of-life improvements** optimized for Gentoo Linux
- **Consistent theming** across all components (manager, status, tabs, preview, etc.)
- **Smart file type recognition** with appropriate colors and icons
- **Efficient tab management** with multiple switching methods
- **Powerful search and selection** capabilities

## Usage Tips

1. **Navigation**: Use `h/j/k/l` for Vim-style movement
2. **File Operations**: `y` (copy), `d` (cut), `p` (paste), `dd` (delete)
3. **Visual Mode**: `v` for visual selection, `V` for line mode
4. **Tabs**: `t` (new tab), `gt`/`gT` (switch tabs), `w` (close tab)
5. **Search**: `/` to search, `n`/`N` to navigate results
6. **Quick Actions**: `o` (open), `r` (rename), `c` (change directory)
7. **Help**: `?` for help, `:` for shell commands

Enjoy your powerful and beautiful file management experience on Gentoo Linux!
