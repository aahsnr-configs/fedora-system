# thefuck configuration with Catppuccin Mocha theme
eval $(thefuck --alias)

# Custom keybinding for thefuck (Alt+f)
bindkey -M emacs '^[f' thefuck-command-line
bindkey -M vicmd '^[f' thefuck-command-line
bindkey -M viins '^[f' thefuck-command-line

# Function to run thefuck on current command line
thefuck-command-line() {
    local FUCK="$(THEFUCK_REQUIRE_CONFIRMATION=false thefuck $(echo $BUFFER) 2>/dev/null)"
    if [[ -n $FUCK ]]; then
        BUFFER=$FUCK
        zle end-of-line
    fi
}
zle -N thefuck-command-line

# Catppuccin Mocha color scheme for zsh-syntax-highlighting
if [[ -n "${ZSH_HIGHLIGHT_STYLES}" ]]; then
    # Commands
    ZSH_HIGHLIGHT_STYLES[command]='fg=#cba6f7,bold'
    ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#cba6f7'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#f5c2e7,bold'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1,bold'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#fab387,bold'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,underline'
    
    # Paths
    ZSH_HIGHLIGHT_STYLES[path]='fg=#89b4fa'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#89b4fa,underline'
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#cdd6f4,underline'
    
    # Arguments
    ZSH_HIGHLIGHT_STYLES[arg0]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'
    ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#f5c2e7,underline'
    ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#f5c2e7'
    
    # Strings
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#fab387'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#fab387'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#fab387'
    
    # Operators
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f38ba8'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#fab387'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#f5c2e7'
    ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=#fab387'
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#f5c2e7'
    ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=#fab387'
    
    # Brackets
    ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#f38ba8,bold'
    ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#cba6f7'
    ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#f5c2e7'
    ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#a6e3a1'
    ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#89b4fa'
    ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=#fab387'
    
    # Line
    ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='fg=#1e1e2e,bg=#cdd6f4'
    ZSH_HIGHLIGHT_STYLES[line]='fg=#cdd6f4'
fi

# Catppuccin Mocha colors for zsh-autosuggestions
if [[ -n "${ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE}" ]]; then
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'
fi

# Load custom Fedora rules
if [[ -f ~/.config/thefuck/fedora_rules.py ]]; then
    export THEFUCK_RULES_DIR="$HOME/.config/thefuck"
fi
