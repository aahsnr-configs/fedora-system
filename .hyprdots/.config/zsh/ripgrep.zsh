# Ripgrep integration with fzf and bat preview
if command -v rg &>/dev/null; then
    # Enhanced rg search with preview using fzf
    function rgfzf() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        rg --color=always --heading --line-number "$@" | fzf --ansi \
            --preview 'bat --style=numbers --color=always --line-range :500 {1}' \
            --preview-window 'right:60%:wrap' \
            --delimiter ':' \
            --bind 'enter:execute(${EDITOR:-nvim} {1} +{2})'
    }

    # Search for contents and open in editor
    function rge() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        local selected
        selected=$(rg --no-heading --line-number "$@" | fzf --ansi -0 -1)
        
        if [[ -n "$selected" ]]; then
            local file=$(echo "$selected" | cut -d: -f1)
            local line=$(echo "$selected" | cut -d: -f2)
            ${EDITOR:-nvim} "$file" +"$line"
        fi
    }

    # Search for files by name
    function rgfiles() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        rg --files | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
    }

    # Use rg for zsh history search
    function history-rg() {
        history 1 | rg "$@"
    }

    # Use rg with bat for code search
    function rgg() {
        if command -v bat &>/dev/null; then
            rg -p "$@" | bat --style=plain --color=always
        else
            rg -p "$@" | less -RFX
        fi
    }

    # Completion enhancements
    if [[ -f /usr/share/zsh/site-functions/_rg ]]; then
        autoload -U compinit && compinit
    fi
fi

# Fedora-specific optimizations
if [[ -f /etc/fedora-release ]]; then
    alias rg="rg --max-depth=10" # Fedora's moderate directory depth
    alias rgs="rg --type-set 'spec:*.spec' --type-set 'rpm:*.spec,*.changes,*.patch' --type-set 'fedora:*.spec,*.changes,*.patch,*.service,*.target,*.mount' --type fedora"
    alias rgd="rg --type-set 'dnf:*.repo,*.conf' --type dnf"
    alias rgk="rg --type-set 'kernel:*.config,*.patch,*.spec' --type kernel"
fi


# Ripgrep environment variables - FIXED PATH
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

# Fedora-specific environment variables
export FEDORA_RIPGREP_SPEC_PATHS="/usr/src/packages/SPECS:/home/$USER/rpmbuild/SPECS"
export FEDORA_RIPGREP_SOURCE_PATHS="/usr/src/packages/SOURCES:/home/$USER/rpmbuild/SOURCES"

# Search in RPM build directories
alias rg-rpm="rg --type-set 'rpm:*.spec,*.patch,*.changes' --type rpm"

# Search in specific RPM build stages
alias rg-build="rg --glob='*/BUILD/*' --glob='*/BUILDROOT/*'"

# Search systemd service files
alias rg-systemd="rg --type-set 'systemd:*.service,*.target,*.mount,*.socket' --type systemd"
