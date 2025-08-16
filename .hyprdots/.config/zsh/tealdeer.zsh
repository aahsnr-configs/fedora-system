alias tl='tldr'

# Enhanced tldr functions for Fedora
tldrf() {
    if [[ -n "$1" ]]; then
        # Fast local-only lookup
        tldr "$@" 2>/dev/null || echo "Command not found in cache. Try: tldr --update"
    else
        echo "Usage: tldrf <command>"
        echo "Fast tldr with local cache only"
    fi
}

# Search tldr pages
tldr-search() {
    if [[ -n "$1" ]]; then
        tldr --list | grep -i "$1"
    else
        echo "Usage: tldr-search <pattern>"
        echo "Search available tldr pages"
    fi
}

# Quick Fedora-specific command shortcuts
alias tldr-dnf='tldr dnf'
alias tldr-rpm='tldr rpm'
alias tldr-flatpak='tldr flatpak'
alias tldr-systemctl='tldr systemctl'
alias tldr-firewall='tldr firewall-cmd'
alias tldr-selinux='tldr semanage'
alias tldr-podman='tldr podman'

# Package management workflow shortcuts
alias help-install='tldr dnf | grep -A5 -B5 install'
alias help-update='tldr dnf | grep -A5 -B5 update'
alias help-search='tldr dnf | grep -A5 -B5 search'
alias help-remove='tldr dnf | grep -A5 -B5 remove'

# Integration with fzf for fuzzy searching
tldr-fzf() {
    tldr --list | fzf --preview 'tldr {1}' --preview-window right:70%
}

# Integration with bat for syntax highlighting
tldr-bat() {
    tldr "$1" | bat --language=markdown --style=plain
}
