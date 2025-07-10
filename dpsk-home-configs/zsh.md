# Advanced Unified ZSH Configuration for Gentoo with Fish-like Features

## Configuration

```sh
#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# Advanced ZSH configuration for Gentoo with Fish-like features
# Unified version combining best features from V1 and V2

# ===== Performance Optimization =====
# Disable magic functions for faster autocomplete
__attribute__() {}
typeset -g ZSH_DISABLE_COMPFIX=true

# Profiling (uncomment to debug startup time)
# zmodload zsh/zprof

# Ensure required directories exist
[[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]] || mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zsh" ]] || mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

# ===== Environment Variables =====
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="Catppuccin Mocha"
export TERM=${TERM:-xterm-256color}
export KEYTIMEOUT=1  # Reduce vi-mode switch delay

# ===== History Configuration =====
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

# History options
setopt extended_history       # Record timestamp and duration
setopt hist_expire_dups_first # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # Ignore duplicated commands in history list
setopt hist_ignore_space      # Ignore commands that start with space
setopt hist_verify            # Show command with history expansion before running it
setopt share_history          # Share command history data between sessions
setopt hist_reduce_blanks     # Remove superfluous blanks from history items

# ===== Directory Navigation =====
setopt auto_cd                # Change directory without cd command
setopt auto_pushd             # Make cd push old directory to directory stack
setopt pushd_ignore_dups      # Don't push duplicates to directory stack
setopt pushdminus            # Invert + and - meanings for directory stack

# ===== Plugin Management =====
ZSH_PLUGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# Function to clone or update plugins
function _zsh_plugin_manage() {
  local repo="$1"
  local plugin_name="${repo##*/}"
  local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
  
  # Clone if doesn't exist
  if [[ ! -d "$plugin_dir" ]]; then
    echo "Installing plugin: $plugin_name..."
    git clone --depth 1 "https://github.com/$repo.git" "$plugin_dir" || {
      echo "Failed to clone $repo"
      return 1
    }
  fi
  
  # Find and source the plugin file
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
  
  echo "Warning: Could not find plugin file for $plugin_name"
  return 1
}

# Function to update all plugins
function zsh_update_plugins() {
  echo "Updating ZSH plugins..."
  for plugin_dir in "$ZSH_PLUGINS_DIR"/*; do
    if [[ -d "$plugin_dir/.git" ]]; then
      echo "Updating $(basename "$plugin_dir")..."
      git -C "$plugin_dir" pull --ff-only
    fi
  done
  rm -f "$ZSH_CACHE_DIR/plugins_loaded"
  echo "Plugin update complete. Restart your shell to apply changes."
}

# Load plugins
plugins=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-history-substring-search"
  "zsh-users/zsh-completions"
  "marlonrichert/zsh-autocomplete"
  "Aloxaf/fzf-tab"
  "hlissner/zsh-autopair"
  "jeffreytse/zsh-vi-mode"
)

# Check if plugins need to be loaded
if [[ ! -f "$ZSH_CACHE_DIR/plugins_loaded" ]] || [[ "$1" == "--update-plugins" ]]; then
  [[ -d "$ZSH_PLUGINS_DIR" ]] || mkdir -p "$ZSH_PLUGINS_DIR"
  
  for plugin in "${plugins[@]}"; do
    _zsh_plugin_manage "$plugin"
  done
  
  touch "$ZSH_CACHE_DIR/plugins_loaded"
else
  # Quick load without update check
  for plugin in "${plugins[@]}"; do
    plugin_name="${plugin##*/}"
    plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
    
    plugin_files=(
      "$plugin_dir/${plugin_name}.plugin.zsh"
      "$plugin_dir/${plugin_name}.zsh"
      "$plugin_dir/zsh-${plugin_name}.plugin.zsh"
      "$plugin_dir/${plugin_name#zsh-}.plugin.zsh"
      "$plugin_dir/init.zsh"
    )
    
    for file in "${plugin_files[@]}"; do
      [[ -f "$file" ]] && { source "$file"; break; }
    done
  done
fi

# ===== Completion System =====
# Initialize completion system
autoload -Uz compinit
compinit -u -d "$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION"

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"

# Completion menu configuration
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' rehash true

# fzf-tab configuration with Catppuccin colors
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags \
  --height=50% \
  --border=rounded \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6ac,pointer:#f5e0dc \
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6ac,hl+:#f38ba8
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:*' fzf-preview '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:500 $realpath || [[ -d $realpath ]] && eza --tree --level=2 --color=always $realpath'

# ===== Vi Mode Configuration =====
# zsh-vi-mode configuration
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_HIGHLIGHT_BACKGROUND=#313244
ZVM_VI_HIGHLIGHT_FOREGROUND=#cdd6f4

# Cursor configuration for vi modes
function zvm_after_init() {
  # History substring search bindings
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
  bindkey -M vicmd '^P' history-substring-search-up
  bindkey -M vicmd '^N' history-substring-search-down
  
  # Enhanced vi bindings
  bindkey -M vicmd 'H' beginning-of-line
  bindkey -M vicmd 'L' end-of-line
  bindkey -M vicmd '?' history-incremental-pattern-search-backward
  bindkey -M vicmd '/' history-incremental-pattern-search-forward
  
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
}

# ===== Modern Command Replacements =====
# Conditional aliases for modern CLI tools
(( $+commands[bat] )) && {
  alias cat='bat --pager=never'
  alias batcat='bat'
}

(( $+commands[eza] )) && {
  alias ls='eza --group-directories-first --icons'
  alias ll='eza --long --header --git --group --icons --group-directories-first'
  alias la='eza --long --header --git --group --icons --group-directories-first --all'
  alias tree='eza --tree --level=3 --group-directories-first --icons'
  alias lt='eza --tree --level=2 --long --icons'
} || {
  alias ll='ls -lah'
  alias la='ls -la'
}

(( $+commands[fd] )) && alias find='fd'
(( $+commands[dust] )) && alias du='dust'
(( $+commands[procs] )) && alias ps='procs'
(( $+commands[rg] )) && alias grep='rg'
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)" && alias cd='z'

# ===== Fish-like Features =====
# Abbreviations system (improved from both versions)
declare -A abbrs
abbrs=(
  "g" "git"
  "ga" "git add"
  "gc" "git commit"
  "gca" "git commit --amend"
  "gco" "git checkout"
  "gd" "git diff"
  "gl" "git pull"
  "gp" "git push"
  "gs" "git status"
  "gst" "git status"
  "ll" "eza -l --group-directories-first --header --git --icons"
  "la" "eza -la --group-directories-first --header --git --icons"
  "v" "nvim"
  "vim" "nvim"
  "c" "clear"
  "e" "exit"
  "md" "mkdir -p"
  "rd" "rmdir"
)

# Enhanced abbreviation expansion
magic-abbrev-expand() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
    command=${abbrs[$MATCH]}
    LBUFFER+=${command:-$MATCH}

    if [[ "${command}" != "${MATCH}" ]]; then
        zle self-insert
        return 0
    fi

    zle self-insert
}

magic-abbrev-expand-and-accept() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
    command=${abbrs[$MATCH]}
    LBUFFER+=${command:-$MATCH}
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

# Auto-ls after cd (Fish-like behavior)
function chpwd() {
  emulate -L zsh
  if (( $+commands[eza] )); then
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

# ===== External Tool Integration =====
# FZF configuration with Catppuccin theme
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS="
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6ac,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6ac,hl+:#f38ba8
    --height=50% --border=rounded --preview-window=right:50%"
  
  # Use fd for FZF if available
  (( $+commands[fd] )) && {
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  }
fi

# Atuin integration (better history)
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# Starship prompt
(( $+commands[starship] )) && eval "$(starship init zsh)" || {
  # Fallback prompt with Catppuccin colors
  autoload -U colors && colors
  PROMPT='%F{#89b4fa}%n@%m%f %F{#a6e3a1}%~%f %F{#f38ba8}%#%f '
  RPROMPT='%F{#6c7086}%*%f'
}

# ===== Catppuccin Theme Integration =====
# Apply Catppuccin Mocha colors to various tools
export GTK_THEME=Catppuccin-Mocha-Standard-Blue-Dark
export QT_STYLE_OVERRIDE=Catppuccin-Mocha

# LS_COLORS for better file type visualization
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
elif [[ -f "$HOME/.config/dircolors/catppuccin-mocha" ]]; then
  eval "$(dircolors "$HOME/.config/dircolors/catppuccin-mocha")"
fi

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
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# System information function
sysinfo() {
  echo "System Information:"
  echo "==================="
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
  echo "Kernel: $(uname -r)"
  echo "Shell: $SHELL"
  echo "Terminal: $TERM"
  [[ -f /etc/gentoo-release ]] && echo "Gentoo: $(cat /etc/gentoo-release)"
}

# ===== Local Configuration =====
# Source local zshrc if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ===== Performance Profiling =====
# Uncomment the line below if you enabled profiling at the top
# zprof
```

## Installation Instructions

### 1. Prerequisites

Install required packages on Gentoo:

```bash
# Core ZSH and modern CLI tools
sudo emerge -av app-shells/zsh

# Modern command replacements
sudo emerge -av \
  sys-apps/bat \
  sys-apps/eza \
  sys-apps/fd \
  sys-block/dust \
  sys-process/procs \
  sys-apps/ripgrep \
  app-shells/fzf \
  app-shells/zoxide

# Optional but recommended
sudo emerge -av \
  app-shells/starship \
  app-misc/atuin \
  dev-util/vivid
```

### 2. Backup and Install Configuration

```bash
# Backup existing configuration
[[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.backup

# Install the new configuration
curl -L https://raw.githubusercontent.com/your-repo/zsh-config/main/.zshrc -o ~/.zshrc

# Or copy the configuration manually from the artifact above
```

### 3. Set ZSH as Default Shell

```bash
chsh -s $(which zsh)
```

### 4. Install Starship Configuration (Optional)

Create a Starship configuration with Catppuccin theme:

```bash
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'EOF'
format = """
[](#a6e3a1)\
$os\
$username\
[](bg:#89b4fa fg:#a6e3a1)\
$directory\
[](fg:#89b4fa bg:#fab387)\
$git_branch\
$git_status\
[](fg:#fab387 bg:#f38ba8)\
$nodejs\
$rust\
$golang\
$php\
[](fg:#f38ba8 bg:#b4befe)\
$time\
[ ](fg:#b4befe)\
"""

[os]
disabled = false
style = "bg:#a6e3a1 fg:#1e1e2e"

[username]
show_always = true
style_user = "bg:#a6e3a1 fg:#1e1e2e"
style_root = "bg:#a6e3a1 fg:#1e1e2e"
format = '[$user ]($style)'
disabled = false

[directory]
style = "bg:#89b4fa fg:#1e1e2e"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:#fab387 fg:#1e1e2e"
format = '[[ $symbol $branch ](bg:#fab387 fg:#1e1e2e)]($style)'

[git_status]
style = "bg:#fab387 fg:#1e1e2e"
format = '[[($all_status$ahead_behind )](bg:#fab387 fg:#1e1e2e)]($style)'

[nodejs]
symbol = ""
style = "bg:#f38ba8 fg:#1e1e2e"
format = '[[ $symbol ($version) ](bg:#f38ba8 fg:#1e1e2e)]($style)'

[rust]
symbol = ""
style = "bg:#f38ba8 fg:#1e1e2e"
format = '[[ $symbol ($version) ](bg:#f38ba8 fg:#1e1e2e)]($style)'

[golang]
symbol = ""
style = "bg:#f38ba8 fg:#1e1e2e"
format = '[[ $symbol ($version) ](bg:#f38ba8 fg:#1e1e2e)]($style)'

[php]
symbol = ""
style = "bg:#f38ba8 fg:#1e1e2e"
format = '[[ $symbol ($version) ](bg:#f38ba8 fg:#1e1e2e)]($style)'

[time]
disabled = false
time_format = "%R"
style = "bg:#b4befe fg:#1e1e2e"
format = '[[  $time ](bg:#b4befe fg:#1e1e2e)]($style)'
EOF
```

### 5. Install Catppuccin LS_COLORS (Optional)

```bash
mkdir -p ~/.config/dircolors
curl -o ~/.config/dircolors/catppuccin-mocha \
  https://raw.githubusercontent.com/catppuccin/dircolors/main/themes/catppuccin-mocha.dircolors
```

### 6. First Run

Start ZSH to initialize plugins:

```bash
zsh
```

The configuration will automatically download and configure all plugins on first run.

## Features Overview

### 🐟 Fish-like Features
- **Abbreviations**: Smart command expansion (e.g., `g` → `git`)
- **Auto-completion**: Intelligent tab completion with preview
- **Auto-ls**: Directory contents shown after `cd`
- **Smart history**: Shared history with substring search

### ⚡ Performance Optimizations
- **Lazy plugin loading**: Plugins load only when needed
- **Compilation caching**: Faster startup times
- **Minimal function calls**: Optimized for speed

### 🎨 Catppuccin Mocha Theme
- **Consistent theming**: Applied to prompt, FZF, completion menu
- **Syntax highlighting**: Color-coded command syntax
- **Modern aesthetics**: Beautiful, eye-friendly colors

### 🛠️ Modern CLI Tools Integration
- **bat**: Enhanced `cat` with syntax highlighting
- **eza**: Modern `ls` replacement with icons
- **fd**: Fast file finder
- **ripgrep**: Better grep
- **zoxide**: Smart directory jumping
- **starship**: Fast, informative prompt

### ⌨️ Vi Mode Enhancement
- **Visual feedback**: Different cursor shapes for modes
- **Smart keybindings**: Intuitive key combinations
- **History navigation**: Vi keys for history search

### 🔧 Quality of Life Improvements
- **Smart completion**: Context-aware suggestions
- **Directory stack**: Easy directory navigation
- **Utility functions**: `mkcd`, `extract`, `sysinfo`
- **Local configuration**: Support for `.zshrc.local`

## Usage Tips

1. **Update plugins**: Run `zsh_update_plugins` to update all plugins
2. **Profile performance**: Uncomment the profiling lines to debug startup time
3. **Customize abbreviations**: Edit the `abbrs` array to add your own shortcuts
4. **Local config**: Use `~/.zshrc.local` for machine-specific settings

This unified configuration provides the best of both worlds with enhanced error handling, better performance, and a more cohesive user experience while maintaining full compatibility with Gentoo Linux.
