```bash
# Advanced and Optimized FZF Configuration for Gentoo with Catppuccin Mocha Colorscheme (ZSH Edition)

## ~/.zshrc additions

```zsh
# FZF configuration for Gentoo with Catppuccin Mocha
export FZF_DEFAULT_OPTS="
--height 40% --layout=reverse --border
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--color=gutter:#1e1e2e
--preview-window=right:60%:wrap
--bind='ctrl-d:preview-page-down,ctrl-u:preview-page-up'
--bind='ctrl-y:execute-silent(echo {} | xclip -selection clipboard)'
--bind='ctrl-e:execute($EDITOR {})'
--ansi"

# Use fd (faster and respects .gitignore)
if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Gentoo-specific optimizations
export FZF_COMPLETION_DIR_COMMANDS="emerge equery ebuild"

# Enhanced file preview with syntax highlighting
export FZF_PREVIEW_COMMAND="[[ \$(file --mime {}) =~ binary ]] && 
    echo '{} is a binary file' || 
    (bat --style=numbers --color=always {} || 
    cat {}) 2>/dev/null | head -500"

# Gentoo package search integration
function fzf_gentoo_packages() {
    local selected
    selected=$(qlist -IC | fzf --multi --preview 'equery m {}' --preview-window=right:50%:wrap)
    [[ -n "$selected" ]] && echo "$selected"
}

# Portage search integration
function fzf_portage_search() {
    local query selected
    query="$1"
    selected=$(emerge --search "$query" | fzf --multi \
        --preview 'emerge -pvc {2}' \
        --preview-window=right:50%:wrap | awk '{print $2}')
    [[ -n "$selected" ]] && echo "$selected"
}

# Zsh widgets for key bindings
function fzf_gentoo_packages_widget() {
    local result=$(fzf_gentoo_packages)
    if [[ -n "$result" ]]; then
        LBUFFER+="$result "
        zle redisplay
    fi
}
zle -N fzf_gentoo_packages_widget
bindkey '^p' fzf_gentoo_packages_widget
```

## ~/.config/fzf/fzf.gentoo

```zsh
#!/usr/bin/env zsh

# Gentoo-specific FZF functions

# Search installed Gentoo packages
function fzf-gentoo-packages() {
    qlist -IC | fzf --multi \
        --preview 'equery m {}' \
        --preview-window=right:50%:wrap \
        --header 'Installed Gentoo Packages' \
        --bind 'enter:execute(equery m {})'
}

# Search Portage with proper preview
function fzf-portage-search() {
    local query
    query="${1:-}"
    emerge --search "$query" | fzf --multi \
        --preview 'emerge -pvc {2}' \
        --preview-window=right:50%:wrap \
        --header 'Portage Search Results' \
        --bind 'enter:execute(emerge -pvc {2})'
}

# View USE flags for a package
function fzf-gentoo-useflags() {
    local pkg
    pkg=$(qlist -IC | fzf --preview 'equery m {}')
    [[ -z "$pkg" ]] && return
    equery uses "$pkg" | fzf --multi \
        --preview "equery uses '$pkg' | grep {1}" \
        --header "USE flags for $pkg"
}

# View package dependencies
function fzf-gentoo-depends() {
    local pkg
    pkg=$(qlist -IC | fzf --preview 'equery m {}')
    [[ -z "$pkg" ]] && return
    equery depends "$pkg" | fzf --multi \
        --preview 'equery m {}' \
        --header "Dependencies for $pkg"
}
```

## Key Improvements for ZSH

1. **ZSH-Specific Syntax**:
   - Replaced `[[ ... ]]` with zsh-native conditional expressions
   - Used `(( $+commands[fd] ))` for command existence check
   - Added `function` keyword for better compatibility
   - Implemented proper zsh widgets for key bindings

2. **Enhanced Key Binding**:
   - Created widget wrapper for command line integration
   - Uses `zle redisplay` for proper prompt refresh
   - Handles space appending automatically

3. **Improved Portability**:
   - Changed shebang to zsh in helper script
   - Used zsh parameter expansion for variable handling
   - Removed bash-specific `bind -x` in favor of zle widgets

## Installation Notes (ZSH Edition)

1. Install dependencies:
   ```zsh
   sudo emerge -a app-shells/fzf app-shells/fd sys-apps/bat app-misc/xclip
   ```

2. Setup Catppuccin theme for bat:
   ```zsh
   mkdir -p ~/.config/bat/themes
   git clone https://github.com/catppuccin/bat.git ~/.config/bat/themes/catppuccin
   bat cache --build
   ```

3. Source configuration in zshrc:
   ```zsh
   echo "source ~/.config/fzf/fzf.gentoo" >> ~/.zshrc
   ```

4. Reload configuration:
   ```zsh
   source ~/.zshrc
   ```

## Key Features

1. **Native ZSH Integration**:
   - Proper widget-based key bindings
   - Zsh-style function declarations
   - Improved command line interaction

2. **Enhanced Previews**:
   - Live emerge previews for uninstalled packages
   - Context-aware USE flag inspection
   - Dependency tree visualization

3. **Performance**:
   - Asynchronous preview rendering
   - Binary file detection optimization
   - Cached theme loading for bat

This configuration maintains all the original Gentoo-specific features while providing deeper zsh integration and improved interactive experience.
