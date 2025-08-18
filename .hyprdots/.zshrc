source "$HOME/.config/zsh/export.zsh"
source "$HOME/.config/zsh/aliases.zsh"
#source $HOME/.config/zsh/atuin.zsh
source "$HOME/.config/zsh/bat.zsh"
source "$HOME/.config/zsh/eza.zsh"
source "$HOME/.config/zsh/fzf.zsh"
source "$HOME/.config/fzf/fzf.fedora"
source "$HOME/.config/zsh/ripgrep.zsh"
source "$HOME/.config/zsh/starship.zsh"
source "$HOME/.config/zsh/tealdeer.zsh"
source "$HOME/.config/zsh/thefuck.zsh"
source "$HOME/.config/zsh/tmux.zsh"
source "$HOME/.config/zsh/yazi.zsh" # main error
source "$HOME/.config/zsh/zoxide.zsh"

# ===== History Configuration =====
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
HISTSIZE=50000

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
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' rehash true

# Menu select bindings (set up after completion system)
# if [[ -n "${terminfo[smkx]}" ]] && [[ -n "${terminfo[rmkx]}" ]]; then
#   autoload -Uz add-zsh-hook
#   function _setup_menuselect_keys() {
#     bindkey -M menuselect 'h' vi-backward-char
#     bindkey -M menuselect 'k' vi-up-line-or-history
#     bindkey -M menuselect 'l' vi-forward-char
#     bindkey -M menuselect 'j' vi-down-line-or-history
#     bindkey -M menuselect '^M' accept-line
#     bindkey -M menuselect '^[[Z' reverse-menu-complete
#   }
#   add-zsh-hook precmd _setup_menuselect_keys
# fi

# fzf-tab configuration
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags \
  --height=50% \
  --border=rounded \
  '--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8' \
  '--color=fg:#cdd6f4,header:#f38ba8,info:#cba6ac,pointer:#f5e0dc' \
  '--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6ac,hl+:#f38ba8'
zstyle ':fzf-tab:*' switch-group ',' '.'

# Add preview for files and directories
zstyle ':fzf-tab:complete:*' fzf-preview \
  '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || [[ -d $realpath ]] && eza --tree --level=2 --color=always $realpath 2>/dev/null || echo "No preview available"'

# ===== Vi Mode Configuration =====
# zsh-vi-mode configuration
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_HIGHLIGHT_BACKGROUND='#313244'
ZVM_VI_HIGHLIGHT_FOREGROUND='#cdd6f4'

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

  # Enable FZF bindings after zsh-vi-mode
  if [[ -f /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
  fi
}

# ===== Abbreviations System =====
# Improved abbreviations system
# declare -A abbrs=(
#   # Git abbreviations
#   [g]="git"
#   [ga]="git add"
#   [gaa]="git add --all"
#   [gc]="git commit"
#   [gca]="git commit --amend"
#   [gcm]="git commit -m"
#   [gco]="git checkout"
#   [gd]="git diff"
#   [gl]="git pull"
#   [gp]="git push"
#   [gs]="git status"
#   [gst]="git status"
#   [glog]="git log --oneline --graph --decorate"
#
#   # File operations
#   [ll]="eza -l --group-directories-first --header --git --icons"
#   [la]="eza -la --group-directories-first --header --git --icons"
#   [v]="nvim"
#   [vim]="nvim"
#   [c]="clear"
#   [e]="exit"
#   [md]="mkdir -p"
#   [rd]="rmdir"
#
#   # Fedora package management
#   [dnfi]="sudo dnf install"
#   [dnfu]="sudo dnf update"
#   [dnfs]="dnf search"
#   [dnfr]="sudo dnf remove"
#   [dnfq]="dnf info"
#   [dnfl]="dnf list"
#   [dnfh]="dnf history"
#
#   # Systemd
#   [sctl]="systemctl"
#   [sctle]="sudo systemctl enable"
#   [sctld]="sudo systemctl disable"
#   [sctls]="sudo systemctl start"
#   [sctlr]="sudo systemctl restart"
#   [sctlS]="sudo systemctl stop"
#   [sctlq]="systemctl status"
#
#   # Flatpak
#   [fp]="flatpak"
#   [fpi]="flatpak install"
#   [fpu]="flatpak update"
#   [fpr]="flatpak uninstall"
#   [fps]="flatpak search"
#   [fpl]="flatpak list"
# )

# Abbreviation expansion function
# magic-abbrev-expand() {
#   local MATCH
#   LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
#   local expansion=${abbrs[$MATCH]}
#   LBUFFER+=${expansion:-$MATCH}
#
#   if [[ -n "$expansion" ]]; then
#     zle self-insert
#     return 0
#   fi
#
#   zle self-insert
# }
#
# magic-abbrev-expand-and-accept() {
#   local MATCH
#   LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
#   local expansion=${abbrs[$MATCH]}
#   LBUFFER+=${expansion:-$MATCH}
#   zle accept-line
# }
#
# no-magic-abbrev-expand() {
#   LBUFFER+=' '
# }
#
# zle -N magic-abbrev-expand
# zle -N magic-abbrev-expand-and-accept
# zle -N no-magic-abbrev-expand
#
# bindkey " " magic-abbrev-expand
# bindkey "^M" magic-abbrev-expand-and-accept
# bindkey "^x " no-magic-abbrev-expand
# bindkey -M isearch " " self-insert
#

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
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *.xz) unxz "$1" ;;
    *.lzma) unlzma "$1" ;;
    *) echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# DNF helper functions
dnf-installed() { dnf list installed | grep -i "$1"; }
dnf-available() { dnf list available | grep -i "$1"; }
dnf-info() { dnf info "$1"; }

autoload -U compaudit compinit

# ===== Local Configuration =====
# Source local configuration if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
#
# ===== Emacs Integration
source ~/.zshrc.vterm 2>/dev/null || true

. "$HOME/.cargo/env"

# bun completions
[ -s "/home/ahsan/.bun/_bun" ] && source "/home/ahsan/.bun/_bun"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

eval "$(direnv hook zsh)"
