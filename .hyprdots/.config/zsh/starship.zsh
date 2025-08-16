# Enable Starship
eval "$(starship init zsh)"

# Fedora-specific optimizations
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
#export STARSHIP_CACHE=~/.cache/starship

# Zsh completion cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# DNF completion
zstyle ':completion:*:dnf:*' group-name ''
zstyle ':completion:*:dnf:*' menu select

# Fedora aliases
alias dnf='nocorrect dnf'
alias rpm='nocorrect rpm'
alias systemctl='nocorrect systemctl'

# Git performance optimization
export GIT_OPTIONAL_LOCKS=0

