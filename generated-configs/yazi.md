# Complete Yazi Configuration for Fedora 42 with Catppuccin Mocha Theme

Here's a corrected and updated configuration for Yazi file manager with Catppuccin Mocha theme, Nerd Fonts, Vim keybindings, and quality-of-life improvements specifically tailored for Fedora 42.

## File Structure

```
~/.config/yazi/
├── yazi.toml        # Main configuration
├── theme.toml       # Catppuccin Mocha theme
├── keymap.toml      # Vim-style keybindings
└── init.lua         # Lua initialization (optional)
```

## Installation and Setup for Fedora 42

### 1. Install Required Dependencies

```bash
# Install Yazi and core dependencies
sudo dnf install -y yazi rust cargo fontconfig libxcb-devel

# Install Nerd Fonts
sudo dnf install -y jetbrains-mono-fonts-all fira-code-fonts fontawesome-fonts
# Alternative: Install specific nerd fonts
sudo dnf install -y 'nerd-fonts-*'

# Install preview and utility dependencies
sudo dnf install -y ffmpeg pandoc poppler-utils
sudo dnf install -y unrar zip unzip p7zip p7zip-plugins
sudo dnf install -y ImageMagick fzf zoxide
sudo dnf install -y trash-cli file

# Install additional media tools
sudo dnf install -y bat fd-find ripgrep jq
```

### 2. Create Configuration Directory

```bash
mkdir -p ~/.config/yazi
```

## Configuration Files

### `~/.config/yazi/yazi.toml` (Main Configuration)

```toml
[manager]
# Display and behavior
show_hidden = false
show_symlink = true
linemode = "size"
scrolloff = 5
mouse_support = true
title_format = "Yazi: {cwd}"

# Sorting
sort_by = "natural"
sort_dir_first = true
sort_reverse = false
sort_translit = false

# Selection and interaction
tab_size = 4
max_preview = 1048576  # 1MB in bytes

[preview]
# Image preview settings
image_filter = "triangle"
image_quality = 75
max_width = 600
max_height = 900
cache_dir = ""

# Wrap settings
wrap = "no"
tab_size = 2

[opener]
# Text files
edit = [
    { run = 'nvim "$@"', desc = "Edit with Neovim", block = true },
    { run = 'vim "$@"', desc = "Edit with Vim", block = true },
    { run = 'code "$@"', desc = "Edit with VS Code" },
    { run = 'gedit "$@"', desc = "Edit with Gedit" },
]

# Archives
archive = [
    { run = 'file-roller "$@"', desc = "Open with File Roller" },
    { run = 'ark "$@"', desc = "Open with Ark" },
]

# Images
image = [
    { run = 'eog "$@"', desc = "Open with Eye of GNOME" },
    { run = 'gwenview "$@"', desc = "Open with Gwenview" },
    { run = 'feh "$@"', desc = "Open with Feh" },
]

# Videos
video = [
    { run = 'mpv "$@"', desc = "Play with mpv" },
    { run = 'vlc "$@"', desc = "Play with VLC" },
    { run = 'totem "$@"', desc = "Play with Totem" },
]

# Audio
audio = [
    { run = 'mpv "$@"', desc = "Play with mpv" },
    { run = 'rhythmbox "$@"', desc = "Play with Rhythmbox" },
]

# Documents
document = [
    { run = 'evince "$@"', desc = "Open with Evince" },
    { run = 'okular "$@"', desc = "Open with Okular" },
    { run = 'libreoffice "$@"', desc = "Open with LibreOffice" },
]

# Fallback
fallback = [
    { run = 'xdg-open "$@"', desc = "Open with default application" },
]

# File associations
[[opener.rules]]
name = "*/
use = "edit"

[[opener.rules]]
mime = "text/*"
use = "edit"

[[opener.rules]]
mime = "image/*"
use = "image"

[[opener.rules]]
mime = "video/*"
use = "video"

[[opener.rules]]
mime = "audio/*"
use = "audio"

[[opener.rules]]
mime = "application/pdf"
use = "document"

[[opener.rules]]
mime = "application/zip"
use = "archive"

[[opener.rules]]
mime = "application/x-tar"
use = "archive"

[[opener.rules]]
mime = "application/x-bzip2"
use = "archive"

[[opener.rules]]
mime = "application/x-gzip"
use = "archive"

[[opener.rules]]
name = "*"
use = "fallback"

[open]
# Rules for opening files
rules = [
    { name = "*/", use = "edit" },
    { mime = "text/*", use = "edit" },
    { mime = "image/*", use = "image" },
    { mime = "video/*", use = "video" },
    { mime = "audio/*", use = "audio" },
    { mime = "application/pdf", use = "document" },
    { mime = "application/*zip", use = "archive" },
    { mime = "application/x-tar", use = "archive" },
    { mime = "application/x-bzip2", use = "archive" },
    { mime = "application/x-gzip", use = "archive" },
    { mime = "application/x-7z-compressed", use = "archive" },
    { name = "*", use = "fallback" },
]

[tasks]
# Task management
micro_workers = 5
macro_workers = 10
bizarre_retry = 5
image_alloc = 536870912  # 512MB
image_bound = [0, 0]
suppress_preload = false

[log]
# Logging configuration
enabled = true
```

### `~/.config/yazi/theme.toml` (Catppuccin Mocha Theme)

```toml
[manager]
# Catppuccin Mocha color scheme
cwd = { fg = "#89b4fa" }  # Blue

hovered         = { fg = "#1e1e2e", bg = "#89b4fa" }  # Blue background
preview_hovered = { underline = true }

# Find
find_keyword  = { fg = "#f9e2af", italic = true }       # Yellow
find_position = { fg = "#f5c2e7", bg = "reset", italic = true }  # Pink

# Marker
marker_selected = { fg = "#a6e3a1", bg = "#a6e3a1" }    # Green
marker_copied   = { fg = "#f9e2af", bg = "#f9e2af" }    # Yellow
marker_cut      = { fg = "#f38ba8", bg = "#f38ba8" }    # Red

# Tab
tab_active   = { fg = "#1e1e2e", bg = "#cba6f7" }       # Mauve
tab_inactive = { fg = "#cdd6f4", bg = "#45475a" }       # Surface1
tab_width    = 1

# Border
border_symbol = "│"
border_style  = { fg = "#7f849c" }                      # Overlay0

# Highlighting
syntect_theme = "~/.config/yazi/Catppuccin-mocha.tmTheme"

[status]
separator_open  = ""
separator_close = ""
separator_style = { fg = "#45475a", bg = "#45475a" }    # Surface1

# Mode
mode_normal = { fg = "#1e1e2e", bg = "#89b4fa", bold = true }  # Blue
mode_select = { fg = "#1e1e2e", bg = "#a6e3a1", bold = true }  # Green
mode_unset  = { fg = "#1e1e2e", bg = "#f38ba8", bold = true }  # Red

# Progress
progress_label  = { fg = "#ffffff", bold = true }
progress_normal = { fg = "#89b4fa", bg = "#45475a" }     # Blue on Surface1
progress_error  = { fg = "#f38ba8", bg = "#45475a" }     # Red on Surface1

# Permissions
permissions_t = { fg = "#a6e3a1" }  # Green
permissions_r = { fg = "#f9e2af" }  # Yellow
permissions_w = { fg = "#f38ba8" }  # Red
permissions_x = { fg = "#74c7ec" }  # Sapphire
permissions_s = { fg = "#cba6f7" }  # Mauve

[input]
border   = { fg = "#89b4fa" }   # Blue
title    = {}
value    = {}
selected = { reversed = true }

[select]
border   = { fg = "#89b4fa" }   # Blue
active   = { fg = "#f5c2e7" }   # Pink
inactive = {}

[tasks]
border  = { fg = "#89b4fa" }    # Blue
title   = {}
hovered = { underline = true }

[which]
mask            = { bg = "#11111b" }     # Crust
cand            = { fg = "#74c7ec" }     # Sapphire
rest            = { fg = "#9399b2" }     # Overlay1
desc            = { fg = "#f5c2e7" }     # Pink
separator       = "  "
separator_style = { fg = "#585b70" }     # Surface2

[help]
on      = { fg = "#f5c2e7" }             # Pink
exec    = { fg = "#74c7ec" }             # Sapphire
desc    = { fg = "#9399b2" }             # Overlay1
hovered = { bg = "#585b70", bold = true } # Surface2

[filetype]
rules = [
    # Images
    { mime = "image/*", fg = "#f5c2e7" },              # Pink
    
    # Videos
    { mime = "video/*", fg = "#fab387" },              # Peach
    { mime = "video/webm", fg = "#fab387" },
    { mime = "video/mp4", fg = "#fab387" },
    { mime = "video/x-msvideo", fg = "#fab387" },
    
    # Audio
    { mime = "audio/*", fg = "#89b4fa" },              # Blue
    
    # Archives
    { mime = "application/zip", fg = "#f9e2af" },      # Yellow
    { mime = "application/gzip", fg = "#f9e2af" },
    { mime = "application/x-tar", fg = "#f9e2af" },
    { mime = "application/x-bzip", fg = "#f9e2af" },
    { mime = "application/x-bzip2", fg = "#f9e2af" },
    { mime = "application/x-7z-compressed", fg = "#f9e2af" },
    { mime = "application/x-rar", fg = "#f9e2af" },
    { mime = "application/xz", fg = "#f9e2af" },
    
    # Documents
    { mime = "application/pdf", fg = "#f38ba8" },      # Red
    { mime = "application/doc", fg = "#89b4fa" },      # Blue
    { mime = "application/docx", fg = "#89b4fa" },
    { mime = "application/xls", fg = "#a6e3a1" },      # Green
    { mime = "application/xlsx", fg = "#a6e3a1" },
    { mime = "application/ppt", fg = "#fab387" },      # Peach
    { mime = "application/pptx", fg = "#fab387" },
    
    # Text
    { mime = "text/*", fg = "#a6e3a1" },               # Green
    
    # Programming
    { name = "*.c", fg = "#89b4fa" },                  # Blue
    { name = "*.cpp", fg = "#89b4fa" },
    { name = "*.cc", fg = "#89b4fa" },
    { name = "*.h", fg = "#89b4fa" },
    { name = "*.hpp", fg = "#89b4fa" },
    { name = "*.rs", fg = "#fab387" },                 # Peach
    { name = "*.go", fg = "#74c7ec" },                 # Sapphire
    { name = "*.py", fg = "#f9e2af" },                 # Yellow
    { name = "*.js", fg = "#f9e2af" },
    { name = "*.ts", fg = "#89b4fa" },                 # Blue
    { name = "*.html", fg = "#fab387" },               # Peach
    { name = "*.css", fg = "#89b4fa" },                # Blue
    { name = "*.scss", fg = "#f5c2e7" },               # Pink
    { name = "*.sass", fg = "#f5c2e7" },
    { name = "*.json", fg = "#f9e2af" },               # Yellow
    { name = "*.xml", fg = "#a6e3a1" },                # Green
    { name = "*.yaml", fg = "#f38ba8" },               # Red
    { name = "*.yml", fg = "#f38ba8" },
    { name = "*.toml", fg = "#fab387" },               # Peach
    { name = "*.ini", fg = "#cba6f7" },                # Mauve
    { name = "*.conf", fg = "#cba6f7" },
    { name = "*.sh", fg = "#a6e3a1" },                 # Green
    { name = "*.bash", fg = "#a6e3a1" },
    { name = "*.zsh", fg = "#a6e3a1" },
    { name = "*.fish", fg = "#a6e3a1" },
    { name = "*.vim", fg = "#a6e3a1" },
    { name = "*.lua", fg = "#89b4fa" },                # Blue
    { name = "*.rb", fg = "#f38ba8" },                 # Red
    { name = "*.php", fg = "#cba6f7" },                # Mauve
    { name = "*.java", fg = "#fab387" },               # Peach
    { name = "*.class", fg = "#fab387" },
    { name = "*.jar", fg = "#fab387" },
    
    # Makefiles and build
    { name = "Makefile", fg = "#a6e3a1" },             # Green
    { name = "Dockerfile", fg = "#89b4fa" },           # Blue
    { name = "docker-compose.yml", fg = "#89b4fa" },
    { name = "*.mk", fg = "#a6e3a1" },
    
    # Git
    { name = ".gitignore", fg = "#fab387" },           # Peach
    { name = ".gitattributes", fg = "#fab387" },
    { name = ".gitmodules", fg = "#fab387" },
    
    # Configs
    { name = "*.cfg", fg = "#cba6f7" },                # Mauve
    { name = "*.config", fg = "#cba6f7" },
    { name = "*.properties", fg = "#cba6f7" },
    
    # Logs
    { name = "*.log", fg = "#6c7086" },                # Surface2
    { name = "*.out", fg = "#6c7086" },
    
    # Temporary files
    { name = "*~", fg = "#6c7086" },                   # Surface2
    { name = "*.tmp", fg = "#6c7086" },
    { name = "*.temp", fg = "#6c7086" },
    { name = "*.bak", fg = "#6c7086" },
    { name = "*.swp", fg = "#6c7086" },
    { name = "*.swo", fg = "#6c7086" },
    
    # Executables
    { name = "*/", fg = "#89b4fa" },                   # Blue for directories
    { name = "*", fg = "#cdd6f4" },                    # Text for regular files
]

[icon]
rules = [
    # Programming
    { name = "*.c", text = "" },
    { name = "*.cpp", text = "" },
    { name = "*.cc", text = "" },
    { name = "*.h", text = "" },
    { name = "*.hpp", text = "" },
    { name = "*.rs", text = "" },
    { name = "*.go", text = "" },
    { name = "*.py", text = "" },
    { name = "*.js", text = "" },
    { name = "*.ts", text = "" },
    { name = "*.html", text = "" },
    { name = "*.css", text = "" },
    { name = "*.scss", text = "" },
    { name = "*.sass", text = "" },
    { name = "*.json", text = "" },
    { name = "*.xml", text = "" },
    { name = "*.yaml", text = "" },
    { name = "*.yml", text = "" },
    { name = "*.toml", text = "" },
    { name = "*.ini", text = "" },
    { name = "*.conf", text = "" },
    { name = "*.sh", text = "" },
    { name = "*.bash", text = "" },
    { name = "*.zsh", text = "" },
    { name = "*.fish", text = "" },
    { name = "*.vim", text = "" },
    { name = "*.lua", text = "" },
    { name = "*.rb", text = "" },
    { name = "*.php", text = "" },
    { name = "*.java", text = "" },
    { name = "*.class", text = "" },
    { name = "*.jar", text = "" },
    
    # Archives
    { name = "*.zip", text = "" },
    { name = "*.tar", text = "" },
    { name = "*.gz", text = "" },
    { name = "*.bz2", text = "" },
    { name = "*.xz", text = "" },
    { name = "*.7z", text = "" },
    { name = "*.rar", text = "" },
    { name = "*.deb", text = "" },
    { name = "*.rpm", text = "" },
    
    # Images
    { name = "*.png", text = "" },
    { name = "*.jpg", text = "" },
    { name = "*.jpeg", text = "" },
    { name = "*.gif", text = "" },
    { name = "*.bmp", text = "" },
    { name = "*.ico", text = "" },
    { name = "*.svg", text = "" },
    { name = "*.webp", text = "" },
    
    # Videos
    { name = "*.mp4", text = "" },
    { name = "*.mkv", text = "" },
    { name = "*.webm", text = "" },
    { name = "*.avi", text = "" },
    { name = "*.mov", text = "" },
    { name = "*.wmv", text = "" },
    { name = "*.flv", text = "" },
    
    # Audio
    { name = "*.mp3", text = "" },
    { name = "*.flac", text = "" },
    { name = "*.wav", text = "" },
    { name = "*.ogg", text = "" },
    { name = "*.m4a", text = "" },
    { name = "*.wma", text = "" },
    
    # Documents
    { name = "*.pdf", text = "" },
    { name = "*.doc", text = "" },
    { name = "*.docx", text = "" },
    { name = "*.xls", text = "" },
    { name = "*.xlsx", text = "" },
    { name = "*.ppt", text = "" },
    { name = "*.pptx", text = "" },
    { name = "*.odt", text = "" },
    { name = "*.ods", text = "" },
    { name = "*.odp", text = "" },
    { name = "*.epub", text = "" },
    
    # Text
    { name = "*.txt", text = "" },
    { name = "*.md", text = "" },
    { name = "*.markdown", text = "" },
    { name = "*.rst", text = "" },
    
    # Special files
    { name = "Makefile", text = "" },
    { name = "Dockerfile", text = "" },
    { name = "docker-compose.yml", text = "" },
    { name = ".gitignore", text = "" },
    { name = ".gitattributes", text = "" },
    { name = ".gitmodules", text = "" },
    { name = "LICENSE", text = "" },
    { name = "README.md", text = "" },
    { name = "README", text = "" },
    { name = "CHANGELOG.md", text = "" },
    { name = "CHANGELOG", text = "" },
    
    # Directories
    { name = "*/", text = "" },
    { name = ".git/", text = "" },
    { name = ".github/", text = "" },
    { name = "node_modules/", text = "" },
    { name = ".vscode/", text = "" },
    { name = ".idea/", text = "" },
    
    # Default
    { name = "*", text = "" },
]
```

### `~/.config/yazi/keymap.toml` (Vim-style Keybindings)

```toml
[[manager.prepend_keymap]]
on   = "h"
run  = "leave"
desc = "Go back"

[[manager.prepend_keymap]]
on   = "j"
run  = "arrow -1"
desc = "Move cursor down"

[[manager.prepend_keymap]]
on   = "k"
run  = "arrow 1"
desc = "Move cursor up"

[[manager.prepend_keymap]]
on   = "l"
run  = "enter"
desc = "Enter directory"

[[manager.prepend_keymap]]
on   = [ "g", "g" ]
run  = "arrow -99999999"
desc = "Move cursor to top"

[[manager.prepend_keymap]]
on   = [ "G" ]
run  = "arrow 99999999"
desc = "Move cursor to bottom"

[[manager.prepend_keymap]]
on   = [ "<C-d>" ]
run  = "arrow -5"
desc = "Move cursor down 5 lines"

[[manager.prepend_keymap]]
on   = [ "<C-u>" ]
run  = "arrow 5"
desc = "Move cursor up 5 lines"

[[manager.prepend_keymap]]
on   = [ "<C-f>" ]
run  = "arrow -10"
desc = "Move cursor down 10 lines"

[[manager.prepend_keymap]]
on   = [ "<C-b>" ]
run  = "arrow 10"
desc = "Move cursor up 10 lines"

# File operations
[[manager.prepend_keymap]]
on   = "y"
run  = "copy"
desc = "Copy selected files"

[[manager.prepend_keymap]]
on   = "x"
run  = "cut"
desc = "Cut selected files"

[[manager.prepend_keymap]]
on   = "d"
run  = "cut"
desc = "Cut selected files"

[[manager.prepend_keymap]]
on   = "p"
run  = "paste"
desc = "Paste files"

[[manager.prepend_keymap]]
on   = [ "d", "d" ]
run  = "remove"
desc = "Remove selected files"

[[manager.prepend_keymap]]
on   = "v"
run  = "visual_mode"
desc = "Enter visual mode"

[[manager.prepend_keymap]]
on   = "V"
run  = "visual_mode --unset"
desc = "Enter visual mode (unset)"

[[manager.prepend_keymap]]
on   = "a"
run  = "create"
desc = "Create new file or directory"

[[manager.prepend_keymap]]
on   = "r"
run  = "rename --cursor=before_ext"
desc = "Rename selected file"

[[manager.prepend_keymap]]
on   = "u"
run  = "undo"
desc = "Undo last operation"

[[manager.prepend_keymap]]
on   = [ "<C-r>" ]
run  = "redo"
desc = "Redo last operation"

[[manager.prepend_keymap]]
on   = "c"
run  = "cd"
desc = "Change directory"

[[manager.prepend_keymap]]
on   = "o"
run  = "open"
desc = "Open file"

[[manager.prepend_keymap]]
on   = "O"
run  = "open --interactive"
desc = "Open file interactively"

# Search and find
[[manager.prepend_keymap]]
on   = "/"
run  = "find --smart"
desc = "Find files"

[[manager.prepend_keymap]]
on   = "n"
run  = "find_arrow"
desc = "Go to next found file"

[[manager.prepend_keymap]]
on   = "N"
run  = "find_arrow --previous"
desc = "Go to previous found file"

[[manager.prepend_keymap]]
on   = "f"
run  = "filter --smart"
desc = "Filter files"

# Selection
[[manager.prepend_keymap]]
on   = "<Space>"
run  = "select --state=none"
desc = "Toggle selection"

[[manager.prepend_keymap]]
on   = [ "<C-a>" ]
run  = "select_all --state=true"
desc = "Select all files"

[[manager.prepend_keymap]]
on   = [ "g", "r" ]
run  = "select_all --state=false"
desc = "Deselect all files"

[[manager.prepend_keymap]]
on   = [ "g", "t" ]
run  = "select_all --state=none"
desc = "Toggle selection for all files"

# Tabs
[[manager.prepend_keymap]]
on   = "t"
run  = "tab_create --current"
desc = "Create new tab"

[[manager.prepend_keymap]]
on   = "T"
run  = "tab_close 0"
desc = "Close current tab"

[[manager.prepend_keymap]]
on   = "w"
run  = "tab_close 0"
desc = "Close current tab"

[[manager.prepend_keymap]]
on   = [ "<C-t>" ]
run  = "tab_create --current"
desc = "Create new tab"

[[manager.prepend_keymap]]
on   = [ "<C-w>" ]
run  = "tab_close 0"
desc = "Close current tab"

[[manager.prepend_keymap]]
on   = "["
run  = "tab_switch -1 --relative"
desc = "Switch to previous tab"

[[manager.prepend_keymap]]
on   = "]"
run  = "tab_switch 1 --relative"
desc = "Switch to next tab"

[[manager.prepend_keymap]]
on   = [ "g", "T" ]
run  = "tab_switch -1 --relative"
desc = "Switch to previous tab"

[[manager.prepend_keymap]]
on   = [ "g", "t" ]
run  = "tab_switch 1 --relative"
desc = "Switch to next tab"

[[manager.prepend_keymap]]
on   = "{"
run  = "tab_swap -1"
desc = "Swap current tab with previous"

[[manager.prepend_keymap]]
on   = "}"
run  = "tab_swap 1"
desc = "Swap current tab with next"

# Tab switching with numbers
[[manager.prepend_keymap]]
on   = "1"
run  = "tab_switch 0"
desc = "Switch to tab 1"

[[manager.prepend_keymap]]
on   = "2"
run  = "tab_switch 1"
desc = "Switch to tab 2"

[[manager.prepend_keymap]]
on   = "3"
run  = "tab_switch 2"
desc = "Switch to tab 3"

[[manager.prepend_keymap]]
on   = "4"
run  = "tab_switch 3"
desc = "Switch to tab 4"

[[manager.prepend_keymap]]
on   = "5"
run  = "tab_switch 4"
desc = "Switch to tab 5"

[[manager.prepend_keymap]]
on   = "6"
run  = "tab_switch 5"
desc = "Switch to tab 6"

[[manager.prepend_keymap]]
on   = "7"
run  = "tab_switch 6"
desc = "Switch to tab 7"

[[manager.prepend_keymap]]
on   = "8"
run  = "tab_switch 7"
desc = "Switch to tab 8"

[[manager.prepend_keymap]]
on   = "9"
run  = "tab_switch 8"
desc = "Switch to tab 9"

# Directory navigation
[[manager.prepend_keymap]]
on   = "~"
run  = "cd ~"
desc = "Go to home directory"

[[manager.prepend_keymap]]
on   = "-"
run  = "leave"
desc = "Go to parent directory"

# Miscellaneous
[[manager.prepend_keymap]]
on   = "q"
run  = "quit"
desc = "Quit yazi"

[[manager.prepend_keymap]]
on   = "Q"
run  = "quit --no-cwd-file"
desc = "Quit yazi without saving cwd"

[[manager.prepend_keymap]]
on   = ":"
run  = "shell --interactive"
desc = "Run shell command"

[[manager.prepend_keymap]]
on   = "!"
run  = "shell --block"
desc = "Run shell command and wait"

[[manager.prepend_keymap]]
on   = "?"
run  = "help"
desc = "Show help"

[[manager.prepend_keymap]]
on   = "<Esc>"
run  = "escape"
desc = "Exit current mode"

[[manager.prepend_keymap]]
on   = [ "<C-l>" ]
run  = "refresh"
desc = "Refresh current directory"

[[manager.prepend_keymap]]
on   = [ "<C-h>" ]
run  = "toggle hidden"
desc = "Toggle hidden files"

[[manager.prepend_keymap]]
on   = [ "<C-s>" ]
run  = "peek"
desc = "Peek file content"

[[manager.prepend_keymap]]
on   = [ "<C-z>" ]
run  = "suspend"
desc = "Suspend yazi"

[[manager.prepend_keymap]]
on   = "i"
run  = "inspect"
desc = "Inspect file"

[[manager.prepend_keymap]]
on   = "R"
run  = "refresh"
desc = "Refresh current directory"

# Sorting
[[manager.prepend_keymap]]
on   = [ "s", "n" ]
run  = "sort natural"
desc = "Sort naturally"

[[manager.prepend_keymap]]
on   = [ "s", "s" ]
run  = "sort size"
desc = "Sort by size"

[[manager.prepend_keymap]]
on   = [ "s", "m" ]
run  = "sort modified"
desc = "Sort by modified time"

[[manager.prepend_keymap]]
on   = [ "s", "c" ]
run  = "sort created"
desc = "Sort by created time"

[[manager.prepend_keymap]]
on   = [ "s", "e" ]
run  = "sort extension"
desc = "Sort by extension"

[[manager.prepend_keymap]]
on   = [ "s", "r" ]
run  = "sort reverse"
desc = "Reverse sort order"

# Input mode keybindings
[[input.prepend_keymap]]
on   = "<Esc>"
run  = "close"
desc = "Cancel input"

[[input.prepend_keymap]]
on   = [ "<C-c>" ]
run  = "close"
desc = "Cancel input"

[[input.prepend_keymap]]
on   = [ "<C-n>" ]
run  = "move 1"
desc = "Move cursor down in history"

[[input.prepend_keymap]]
on   = [ "<C-p>" ]
run  = "move -1"
desc = "Move cursor up in history"

[[input.prepend_keymap]]
on   = [ "<C-f>" ]
run  = "forward"
desc = "Move cursor forward"

[[input.prepend_keymap]]
on   = [ "<C-b>" ]
run  = "backward"
desc = "Move cursor backward"

[[input.prepend_keymap]]
on   = [ "<C-a>" ]
run  = "move -999"
desc = "Move cursor to start"

[[input.prepend_keymap]]
on   = [ "<C-e>" ]
run  = "move 999"
desc = "Move cursor to end"

[[input.prepend_keymap]]
on   = [ "<C-u>" ]
run  = "kill bol"
desc = "Kill from cursor to beginning of line"

[[input.prepend_keymap]]
on   = [ "<C-k>" ]
run  = "kill eol"
desc = "Kill from cursor to end of line"

[[input.prepend_keymap]]
on   = [ "<C-w>" ]
run  = "kill backward"
desc = "Kill word backward"

[[input.prepend_keymap]]
on   = [ "<C-d>" ]
run  = "delete"
desc = "Delete character forward"

[[input.prepend_keymap]]
on   = [ "<C-h>" ]
run  = "backspace"
desc = "Delete character backward"

[[input.prepend_keymap]]
on   = "<Backspace>"
run  = "backspace"
desc = "Delete character backward"

[[input.prepend_keymap]]
on   = "<Delete>"
run  = "delete"
desc = "Delete character forward"

[[input.prepend_keymap]]
on   = "<Enter>"
run  = "submit"
desc = "Submit input"

# Select mode keybindings
[[select.prepend_keymap]]
on   = "<Esc>"
run  = "close"
desc = "Cancel selection"

[[select.prepend_keymap]]
on   = [ "<C-c>" ]
run  = "close"
desc = "Cancel selection"

[[select.prepend_keymap]]
on   = "j"
run  = "arrow -1"
desc = "Move cursor down"

[[select.prepend_keymap]]
on   = "k"
run  = "arrow 1"
desc = "Move cursor up"

[[select.prepend_keymap]]
on   = "<Enter>"
run  = "submit"
desc = "Submit selection"

# Tasks mode keybindings
[[tasks.prepend_keymap]]
on   = "<Esc>"
run  = "close"
desc = "Close task manager"

[[tasks.prepend_keymap]]
on   = [ "<C-c>" ]
run  = "close"
desc = "Close task manager"

[[tasks.prepend_keymap]]
on   = "j"
run  = "arrow -1"
desc = "Move cursor down"

[[tasks.prepend_keymap]]
on   = "k"
run  = "arrow 1"
desc = "Move cursor up"

[[tasks.prepend_keymap]]
on   = "w"
run  = "inspect"
desc = "Inspect task"

[[tasks.prepend_keymap]]
on   = "c"
run  = "cancel"
desc = "Cancel task"

# Help mode keybindings
[[help.prepend_keymap]]
on   = "<Esc>"
run  = "close"
desc = "Close help"

[[help.prepend_keymap]]
on   = [ "<C-c>" ]
run  = "close"
desc = "Close help"

[[help.prepend_keymap]]
on   = "j"
run  = "arrow -1"
desc = "Move cursor down"

[[help.prepend_keymap]]
on   = "k"
run  = "arrow 1"
desc = "Move cursor up"

[[help.prepend_keymap]]
on   = [ "<C-d>" ]
run  = "arrow -5"
desc = "Move cursor down 5 lines"

[[help.prepend_keymap]]
on   = [ "<C-u>" ]
run  = "arrow 5"
desc = "Move cursor up 5 lines"
```

## Quality of Life Improvements for Fedora 42

### 1. Shell Integration

Add these aliases to your shell config (`~/.bashrc` or `~/.zshrc`):

```bash
# Yazi aliases for quick access
alias yy='yazi'
alias yz='yazi $(pwd)'

# Yazi with directory tracking (recommended)
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Quick directory jumping with zoxide integration
eval "$(zoxide init bash)"  # or zsh if you use zsh
alias z='zoxide'
alias zi='zoxide query -i'
```

### 2. Bash/Zsh Completion

Add to your shell config:

```bash
# Yazi completion
if command -v yazi &> /dev/null; then
    source <(yazi --generate-completion zsh)
fi
```

### 3. Desktop Integration

Create `~/.local/share/applications/yazi.desktop`:

```ini
[Desktop Entry]
Name=Yazi File Manager
Comment=A blazing fast terminal file manager
Exec=yazi
Icon=system-file-manager
Terminal=true
Type=Application
Categories=Utility;FileManager;System;
Keywords=file;manager;terminal;vim;
StartupNotify=true
MimeType=inode/directory;
```

### 4. Terminal Configuration for Fedora 42

Make sure your terminal emulator supports:
- True color (24-bit color)
- Nerd Fonts (install with `sudo dnf install 'nerd-fonts-*'`)
- Unicode support

For GNOME Terminal:
```bash
# Set a Nerd Font
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ font 'JetBrains Mono Nerd Font 11'

# Enable true color
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')/ use-theme-colors false
```

### 5. Optional: Install Catppuccin Theme for Terminal

```bash
# For GNOME Terminal
curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/main/install.py | python3 -

# For Alacritty, add to ~/.config/alacritty/alacritty.yml:
# import:
#   - ~/.config/alacritty/catppuccin-mocha.yml
```

### 6. Additional Fedora-specific Utilities

```bash
# Install additional file preview tools
sudo dnf install -y bat exa fd-find ripgrep tree
sudo dnf install -y mediainfo exiftool
sudo dnf install -y highlight glow  # for syntax highlighting

# Install archiving tools
sudo dnf install -y p7zip p7zip-plugins unrar

# Install image tools
sudo dnf install -y chafa viu  # for terminal image viewing
```

### 7. Environment Variables

Add to your shell config:

```bash
# Yazi configuration
export YAZI_FILE_ONE="bat --paging=never --color=always"
export YAZI_CONFIG_HOME="$HOME/.config/yazi"

# Better file listing
export EXA_COLORS="di=1;34:ln=1;36:so=32:pi=33:ex=1;31:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"
```

## Key Features of This Configuration

This corrected configuration provides:

- **Updated syntax** compatible with modern Yazi versions
- **Fedora 42 specific** package installation commands using `dnf`
- **Fixed keymap format** using the correct `prepend_keymap` structure
- **Proper theme configuration** with Catppuccin Mocha colors
- **Comprehensive file type support** with appropriate icons and colors
- **Vim-style keybindings** for efficient navigation
- **Quality-of-life improvements** tailored for Fedora
- **Shell integration** with directory tracking
- **Desktop integration** with .desktop file
- **Terminal configuration** recommendations

## Major Fixes Applied

1. **Configuration syntax**: Updated to use modern Yazi TOML format
2. **Package manager**: Changed from `emerge` (Gentoo) to `dnf` (Fedora)
3. **Keymap format**: Fixed to use proper `prepend_keymap` arrays
4. **Theme structure**: Corrected color definitions and removed invalid options
5. **File associations**: Updated opener rules to use proper syntax
6. **Fedora-specific paths**: Updated for Fedora directory structure
7. **Font installation**: Updated for Fedora's font packages
8. **Dependencies**: Corrected package names for Fedora repositories

## Usage Tips

1. **Navigation**: Use `h/j/k/l` for Vim-style movement
2. **File Operations**: `y` (copy), `d` (cut), `p` (paste), `dd` (delete)
3. **Visual Mode**: `v` for visual selection
4. **Tabs**: `t` (new tab), `[`/`]` (switch tabs), `w` (close tab)
5. **Search**: `/` to find files, `n`/`N` to navigate results
6. **Sorting**: `s` followed by `n`/`s`/`m`/`c`/`e` for different sort modes
7. **Quick Actions**: `o` (open), `r` (rename), `c` (change directory)
8. **Help**: `?` for help, `:` for shell commands

This configuration is now properly formatted for modern Yazi versions and optimized for Fedora 42!

---

*Note: Make sure to restart your terminal or source your shell config after making these changes for the aliases and environment variables to take effect.*
