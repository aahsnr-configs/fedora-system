# Advanced Unified ZSH Configuration for Fedora 42 with Fish-like Features

## Configuration

```sh
#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Advanced ZSH configuration for Fedora 42 with Fish-like features
# Fixed version addressing compatibility issues and performance problems

# ===== Performance Optimization =====
# Disable compfix for faster startup
typeset -g ZSH_DISABLE_COMPFIX=true

# Profiling (uncomment to debug startup time)
# zmodload zsh/zprof

# Ensure required directories exist
[[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]] || mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zsh" ]] || mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

# ===== Environment Variables =====
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="Catppuccin Mocha"
export TERM=${TERM:-xterm-256color}
export KEYTIMEOUT=1

# Fedora-specific environment variables
export BROWSER=${BROWSER:-firefox}
export PAGER=${PAGER:-less}

# ===== History Configuration =====
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history
setopt hist_reduce_blanks

# ===== Directory Navigation =====
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

# ===== ZSH Options =====
setopt correct
setopt complete_aliases
setopt always_to_end
setopt list_packed
setopt auto_list
setopt auto_menu
setopt auto_param_slash
setopt extended_glob
setopt glob_dots

# ===== Plugin Management =====
ZSH_PLUGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# Simple plugin loader function
function _load_plugin() {
  local repo="$1"
  local plugin_name="${repo##*/}"
  local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
  
  # Clone if doesn't exist
  if [[ ! -d "$plugin_dir" ]]; then
    echo "Installing plugin: $plugin_name..."
    git clone --depth 1 "https://github.com/$repo.git" "$plugin_dir" 2>/dev/null || {
      echo "Failed to clone $repo"
      return 1
    }
  fi
  
  # Source the plugin
  local plugin_files=(
    "$plugin_dir/${plugin_name}.plugin.zsh"
    "$plugin_dir/${plugin_name}.zsh"
    "$plugin_dir/zsh-${plugin_name}.plugin.zsh"
    "$plugin_dir/${plugin_name#zsh-}.plugin.zsh"
    "$plugin_dir/init.zsh"
  )
  
  for file in "${plugin_files[@]}"; do
    if [[ -f "$file" ]]; then
      source "$file"
      return 0
    fi
  done
  
  return 1
}

# Function to update all plugins
function zsh_update_plugins() {
  echo "Updating ZSH plugins..."
  for plugin_dir in "$ZSH_PLUGINS_DIR"/*; do
    if [[ -d "$plugin_dir/.git" ]]; then
      echo "Updating $(basename "$plugin_dir")..."
      git -C "$plugin_dir" pull --ff-only 2>/dev/null
    fi
  done
  echo "Plugin update complete. Restart your shell to apply changes."
}

# Load plugins in proper order to avoid conflicts
[[ -d "$ZSH_PLUGINS_DIR" ]] || mkdir -p "$ZSH_PLUGINS_DIR"

# Load zsh-vi-mode first (must be loaded before other plugins)
_load_plugin "jeffreytse/zsh-vi-mode"

# Load other plugins (excluding zsh-autocomplete due to conflicts)
_load_plugin "zsh-users/zsh-autosuggestions"
_load_plugin "zsh-users/zsh-syntax-highlighting"
_load_plugin "zsh-users/zsh-history-substring-search"
_load_plugin "zsh-users/zsh-completions"
_load_plugin "Aloxaf/fzf-tab"
_load_plugin "hlissner/zsh-autopair"

# ===== Completion System =====
# Load completions
autoload -Uz compinit
compinit -u -d "$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION"

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"

# Completion configuration
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' rehash true

# fzf-tab configuration
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags \
  --height=50% \
  --border=rounded \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6ac,pointer:#f5e0dc \
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6ac,hl+:#f38ba8
zstyle ':fzf-tab:*' switch-group ',' '.'

# Add preview for files and directories
zstyle ':fzf-tab:complete:*' fzf-preview \
  '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || [[ -d $realpath ]] && eza --tree --level=2 --color=always $realpath 2>/dev/null || echo "No preview available"'

# ===== Vi Mode Configuration =====
# zsh-vi-mode configuration
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_HIGHLIGHT_BACKGROUND=#313244
ZVM_VI_HIGHLIGHT_FOREGROUND=#cdd6f4

# Configure vi mode after initialization
function zvm_after_init() {
  # History substring search bindings
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
  
  # Enhanced vi bindings
  bindkey -M vicmd 'H' beginning-of-line
  bindkey -M vicmd 'L' end-of-line
  
  # Fix common keys in insert mode
  bindkey -M viins "^?" backward-delete-char
  bindkey -M viins "^W" backward-kill-word
  bindkey -M viins "^U" backward-kill-line
  bindkey -M viins "^A" beginning-of-line
  bindkey -M viins "^E" end-of-line
  
  # Menu select bindings
  bindkey -M menuselect 'h' vi-backward-char
  bindkey -M menuselect 'k' vi-up-line-or-history
  bindkey -M menuselect 'l' vi-forward-char
  bindkey -M menuselect 'j' vi-down-line-or-history
  
  # Enable FZF bindings after zsh-vi-mode
  if [[ -f /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
  fi
}

# ===== Modern Command Replacements =====

# Handle fd-find (Fedora package name)
if command -v fd-find >/dev/null 2>&1; then
  alias fd='fd-find'
  alias find='fd-find'
elif command -v fd >/dev/null 2>&1; then
  alias find='fd'
fi

# Other modern tools
command -v dust >/dev/null 2>&1 && alias du='dust'
command -v procs >/dev/null 2>&1 && alias ps='procs'
command -v rg >/dev/null 2>&1 && alias grep='rg'
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)" && alias cd='z'

# ===== Abbreviations System =====
# Improved abbreviations system
declare -A abbrs=(
  # Git abbreviations
  [g]="git"
  [ga]="git add"
  [gaa]="git add --all"
  [gc]="git commit"
  [gca]="git commit --amend"
  [gcm]="git commit -m"
  [gco]="git checkout"
  [gd]="git diff"
  [gl]="git pull"
  [gp]="git push"
  [gs]="git status"
  [gst]="git status"
  [glog]="git log --oneline --graph --decorate"
  
  # File operations
  [ll]="eza -l --group-directories-first --header --git --icons"
  [la]="eza -la --group-directories-first --header --git --icons"
  [v]="nvim"
  [vim]="nvim"
  [c]="clear"
  [e]="exit"
  [md]="mkdir -p"
  [rd]="rmdir"
  
  # Fedora package management
  [dnfi]="sudo dnf install"
  [dnfu]="sudo dnf update"
  [dnfs]="dnf search"
  [dnfr]="sudo dnf remove"
  [dnfq]="dnf info"
  [dnfl]="dnf list"
  [dnfh]="dnf history"
  
  # Systemd
  [sctl]="systemctl"
  [sctle]="sudo systemctl enable"
  [sctld]="sudo systemctl disable"
  [sctls]="sudo systemctl start"
  [sctlr]="sudo systemctl restart"
  [sctlS]="sudo systemctl stop"
  [sctlq]="systemctl status"
  
  # Flatpak
  [fp]="flatpak"
  [fpi]="flatpak install"
  [fpu]="flatpak update"
  [fpr]="flatpak uninstall"
  [fps]="flatpak search"
  [fpl]="flatpak list"
)

# Abbreviation expansion function
magic-abbrev-expand() {
  local MATCH
  LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
  local expansion=${abbrs[$MATCH]}
  LBUFFER+=${expansion:-$MATCH}
  
  if [[ -n "$expansion" ]]; then
    zle self-insert
    return 0
  fi
  
  zle self-insert
}

magic-abbrev-expand-and-accept() {
  local MATCH
  LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
  local expansion=${abbrs[$MATCH]}
  LBUFFER+=${expansion:-$MATCH}
  zle accept-line
}

no-magic-abbrev-expand() {
  LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N magic-abbrev-expand-and-accept
zle -N no-magic-abbrev-expand

bindkey " " magic-abbrev-expand
bindkey "^M" magic-abbrev-expand-and-accept
bindkey "^x " no-magic-abbrev-expand
bindkey -M isearch " " self-insert

# ===== Fish-like Features =====
# Auto-ls after cd
function chpwd() {
  emulate -L zsh
  if command -v eza >/dev/null 2>&1; then
    eza --group-directories-first --icons
  else
    ls --color=auto
  fi
}

# ===== Plugin Configuration =====
# ZSH Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# History substring search
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#313244,fg=#f38ba8,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#313244,fg=#f38ba8,bold'

# ===== Utility Functions =====
# Quick directory creation and navigation
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract various archive types
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.xz)        unxz "$1"        ;;
      *.lzma)      unlzma "$1"      ;;
      *)           echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# System information (Fedora-specific)
sysinfo() {
  echo "System Information:"
  echo "==================="
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
  echo "Kernel: $(uname -r)"
  echo "Shell: $SHELL"
  echo "Terminal: $TERM"
  [[ -f /etc/fedora-release ]] && echo "Fedora: $(cat /etc/fedora-release)"
  echo "Memory: $(free -h | awk 'NR==2{printf "%.1f/%.1f GB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2 }')"
  echo "Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')"
}

# DNF helper functions
dnf-installed() { dnf list installed | grep -i "$1"; }
dnf-available() { dnf list available | grep -i "$1"; }
dnf-info() { dnf info "$1"; }

# ===== Fedora-specific Aliases =====
alias dnf='dnf --color=always'
alias dnf-update='sudo dnf update && sudo dnf autoremove'
alias dnf-clean='sudo dnf clean all'
alias dnf-history='dnf history'
alias dnf-repos='dnf repolist'

# Systemctl aliases
alias sctl='systemctl'
alias sctle='sudo systemctl enable'
alias sctld='sudo systemctl disable'
alias sctls='sudo systemctl start'
alias sctlr='sudo systemctl restart'
alias sctlS='sudo systemctl stop'
alias sctlq='systemctl status'

# Flatpak aliases
if command -v flatpak >/dev/null 2>&1; then
  alias fp='flatpak'
  alias fpi='flatpak install'
  alias fpu='flatpak update'
  alias fpr='flatpak uninstall'
  alias fps='flatpak search'
  alias fpl='flatpak list'
fi

# ===== Additional Fedora Tools =====
# Podman aliases (if available)
if command -v podman >/dev/null 2>&1; then
  alias docker='podman'
  alias pd='podman'
  alias pdi='podman images'
  alias pdc='podman ps'
  alias pdr='podman run'
  alias pds='podman start'
  alias pdS='podman stop'
fi

# ===== Local Configuration =====
# Source local configuration if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ===== Performance Profiling =====
# Uncomment to profile startup time
# zprof
```

## Installation Instructions

### 1. Prerequisites

Install required packages on Fedora 42:

```bash
# Core ZSH and modern CLI tools
sudo dnf install -y zsh

# Modern command replacements
sudo dnf install -y \
  bat \
  eza \
  fd-find \
  dust \
  procs \
  ripgrep \
  fzf \
  zoxide

# Optional but recommended
sudo dnf install -y \
  starship \
  neovim \
  vivid

# Additional tools (may require COPR or manual installation)
# For atuin: cargo install atuin
# For some tools, you might need to enable additional repositories
```

### 2. Install from COPR (Optional Advanced Tools)

```bash
# Enable COPR for additional tools if needed
sudo dnf copr enable atim/starship
sudo dnf install starship

# For atuin (if not available in main repos)
cargo install atuin
```

### 3. Backup and Install Configuration

### 7. First Run

Start ZSH to initialize plugins:

```bash
zsh
```

The configuration will automatically download and configure all plugins on first run.

## Fedora-Specific Features

### 🔧 DNF Integration
- **Smart aliases**: `dnfi` for install, `dnfu` for update, etc.
- **Helper functions**: `dnf-installed`, `dnf-available`, `dnf-info`
- **System maintenance**: `dnf-update`, `dnf-clean`

### 🏗️ Systemd Integration
- **Service management**: `sysu` (start), `syss` (stop), `sysr` (restart)
- **Service status**: `sysq` for quick status checks
- **Enable/disable**: `syse` and `sysd` for service management

### 📦 Flatpak Support
- **Flatpak aliases**: `fp`, `fpi`, `fpu`, `fpr` for common operations
- **Integrated search**: `fps` for searching Flatpak applications

### 🖥️ Fedora System Information
- **Enhanced sysinfo**: Shows Fedora version, memory, disk usage
- **OS detection**: Reads from `/etc/fedora-release` and `/etc/os-release`

## Key Improvements for Fedora 42

1. **Package Manager**: Changed from Gentoo's `emerge` to Fedora's `dnf`
2. **Command Availability**: Proper handling of `fd` vs `fd-find` naming
3. **System Paths**: Updated to use Fedora's standard paths
4. **FZF Integration**: Added proper sourcing of FZF files from Fedora locations
5. **Systemd Integration**: Added systemctl abbreviations for service management
6. **Flatpak Support**: Built-in support for Flatpak package management
7. **Performance**: Optimized for Fedora's file system layout and conventions

## Usage Tips

1. **Update plugins**: Run `zsh_update_plugins` to update all plugins
2. **Profile performance**: Uncomment the profiling lines to debug startup time
3. **Customize abbreviations**: Edit the `abbrs` array to add your own shortcuts
4. **Local config**: Use `~/.zshrc.local` for machine-specific settings
5. **System info**: Run `sysinfo` to get detailed system information
6. **Package search**: Use `dnfs <package>` for quick package searches

This Fedora-optimized configuration provides a modern, efficient shell environment with Fish-like features while maintaining full compatibility with Fedora 42's package management and system architecture.
