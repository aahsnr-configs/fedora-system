# Basic eza aliases
alias ls='eza --color=always --icons=always --group-directories-first'
alias ll='eza -l --color=always --icons=always --group-directories-first --git --header'
alias la='eza -la --color=always --icons=always --group-directories-first --git --header'
alias lt='eza --tree --color=always --icons=always --group-directories-first --level=3'
alias lr='eza -R --color=always --icons=always --group-directories-first'

# Development-focused aliases
alias lg='eza -l --git --git-ignore --color=always --icons=always --group-directories-first --header'
alias lG='eza -l --git --git-ignore --git-repos --color=always --icons=always --group-directories-first --header'
alias lsize='eza -l --sort=size --reverse --color=always --icons=always --group-directories-first --git --header'
alias ltime='eza -l --sort=modified --reverse --color=always --icons=always --group-directories-first --git --header'

# Fedora specific aliases
alias lrpm='eza -la --color=always --icons=always *.rpm *.srpm 2>/dev/null || echo "No RPM files found"'
alias lspec='eza -la --color=always --icons=always *.spec 2>/dev/null || echo "No spec files found"'
alias lbuild='eza -la --color=always --icons=always --group-directories-first BUILD/ BUILDROOT/ RPMS/ SOURCES/ SPECS/ SRPMS/ 2>/dev/null || eza -la --color=always --icons=always --group-directories-first'
alias lcontainer='eza -la --color=always --icons=always *dockerfile* *containerfile* docker-compose.* 2>/dev/null || echo "No container files found"'
alias lsystemd='eza -la --color=always --icons=always /etc/systemd/system/ ~/.config/systemd/user/ 2>/dev/null'

# Package management helpers
alias lflatpak='eza -la --color=always --icons=always ~/.var/app/ 2>/dev/null || echo "No Flatpak apps found"'
alias lsnap='eza -la --color=always --icons=always /snap/ 2>/dev/null || echo "No Snap packages found"'

# Utility functions
ezasize() {
    eza -l --color=always --icons=always --group-directories-first --total-size --color-scale=size --sort=size --reverse "$@"
}

ezarecent() {
    local days=${1:-7}
    eza -la --color=always --icons=always --sort=modified --reverse --color-scale=age "$@" | head -20
}

ezagit() {
    eza -la --color=always --icons=always --group-directories-first --git --git-ignore --header --sort=modified --reverse "$@"
}

ezatree() {
    local depth=${1:-3}
    shift
    eza --tree --color=always --icons=always --group-directories-first --level="$depth" --ignore-glob=".git|node_modules|.cache|__pycache__|.pytest_cache|.mypy_cache|target|build|dist" "$@"
}

# Development environment helpers
ezadev() {
    eza -la --color=always --icons=always --group-directories-first --git --header --sort=modified --reverse --ignore-glob="*.pyc|*.pyo|*.pyd|__pycache__|.pytest_cache|.mypy_cache|node_modules|.cache|target|build|dist" "$@"
}

ezalog() {
    eza -la --color=always --icons=always --sort=modified --reverse /var/log/ "$@" 2>/dev/null | head -20
}

ezasystemd() {
    echo "=== System services ==="
    eza -la --color=always --icons=always /etc/systemd/system/ 2>/dev/null | head -10
    echo -e "\n=== User services ==="
    eza -la --color=always --icons=always ~/.config/systemd/user/ 2>/dev/null | head -10
}

# Security and permissions
ezaperm() {
    eza -la --color=always --icons=always --group-directories-first --octal-permissions "$@"
}

ezasuid() {
    find "$@" -type f -perm /4000 -exec eza -la --color=always --icons=always --octal-permissions {} \; 2>/dev/null
}

# View SELinux contexts with eza
alias lz='eza -la --color=always --icons=always --group-directories-first --context'

# Function to show SELinux contexts for important directories
ezaselinux() {
    echo "=== SELinux contexts for common directories ==="
    eza -la --color=always --icons=always --context /etc/selinux/ /var/log/audit/ ~/.ssh/ 2>/dev/null
}

# View systemd service files
alias lsystemd-system='eza -la --color=always --icons=always /etc/systemd/system/'
alias lsystemd-user='eza -la --color=always --icons=always ~/.config/systemd/user/'

# Function to show systemd timer files
ezatimers() {
    echo "=== System timers ==="
    eza -la --color=always --icons=always /etc/systemd/system/*.timer 2>/dev/null
    echo -e "\n=== User timers ==="
    eza -la --color=always --icons=always ~/.config/systemd/user/*.timer 2>/dev/null
}

# Enhanced container file viewing
ezacontainers() {
    echo "=== Container files ==="
    eza -la --color=always --icons=always *dockerfile* *containerfile* docker-compose.* podman-compose.* 2>/dev/null
    echo -e "\n=== Container directories ==="
    eza -la --color=always --icons=always --group-directories-first ~/.local/share/containers/ 2>/dev/null
}
