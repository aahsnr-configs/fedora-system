# Yazi Configuration for Zsh
# This configuration provides optimal integration between Yazi file manager and Zsh

# Basic yazi alias for quick access
alias yazi='yazi'

# Official shell wrapper function that changes directory on exit
# This is the recommended approach from yazi documentation
function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(< "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Alternative function for users who prefer 'yy' command
function yy() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(< "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Quick access to yazi in current directory
alias yz='yazi $(pwd)'


# Environment variables for yazi configuration
export YAZI_CONFIG_HOME="${YAZI_CONFIG_HOME:-$HOME/.config/yazi}"

# Optional: Set file preview command (uncomment if you want to use bat for file previews)
# export YAZI_FILE_ONE="bat --paging=never --color=always --style=plain"

# Optional: Configure yazi with additional environment variables
# export YAZI_FILE_ONE="file"  # Use system file command for file type detection
# export YAZI_FILE_ONE="bat --paging=never --color=always"  # Use bat for syntax highlighting

# Note: The YAZI_FILE_ONE variable is used by yazi for file type detection
# Common options:
# - "file" (default system file command)
# - "bat --paging=never --color=always" (for syntax highlighting)
# - Custom command for file type detection
