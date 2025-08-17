# FZF configuration for Fedora 42 with Catppuccin Mocha
export FZF_DEFAULT_OPTS="
--height 40% --layout=reverse --border
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--color=gutter:#1e1e2e
--preview-window=right:60%:wrap
--bind='ctrl-d:preview-page-down,ctrl-u:preview-page-up'
--bind='ctrl-y:execute-silent(echo {} | xclip -selection clipboard)'
--bind='ctrl-e:execute(\$EDITOR {})'
--ansi"

# Fedora-specific optimizations
export FZF_COMPLETION_DIR_COMMANDS="dnf rpm-ostree flatpak toolbox podman"

# Enhanced file preview with syntax highlighting
export FZF_PREVIEW_COMMAND="[[ \$(file --mime {}) =~ binary ]] && 
    echo '{} is a binary file' || 
    (bat --style=numbers --color=always {} || 
    cat {}) 2>/dev/null | head -500"

# Source FZF completion
[[ -f /usr/share/fzf/shell/completion.zsh ]] && source /usr/share/fzf/shell/completion.zsh

# Detect if running on Atomic Desktop (Silverblue, Kinoite, etc.)
function is_atomic_desktop() {
    [[ -f /run/ostree-booted ]] && return 0 || return 1
}

# DNF package search integration (for traditional Fedora)
function fzf_dnf_packages() {
    local selected
    if ! (($ + commands[dnf])); then
        echo "DNF not found"
        return 1
    fi

    selected=$(dnf list installed 2>/dev/null | awk 'NR>1 && NF>=3 {print $1}' | sed 's/\.[^.]*$//' | sort -u | fzf --multi \
        --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
        --preview-window=right:50%:wrap \
        --header 'Installed DNF Packages')
    [[ -n "$selected" ]] && echo "$selected"
}

# RPM-OSTree package search integration (for Atomic Desktops)
function fzf_rpm_ostree_packages() {
    local selected
    if ! (($ + commands[rpm - ostree])); then
        echo "rpm-ostree not found"
        return 1
    fi

    # Get layered packages from rpm-ostree status
    selected=$(rpm-ostree status --json 2>/dev/null |
        jq -r '.deployments[0]["requested-packages"][]? // empty' 2>/dev/null |
        sort -u | fzf --multi \
        --preview 'rpm -qi {} 2>/dev/null || dnf info {} 2>/dev/null || echo "Package info not available"' \
        --preview-window=right:50%:wrap \
        --header 'Layered RPM-OSTree Packages')
    [[ -n "$selected" ]] && echo "$selected"
}

# Flatpak package search integration
function fzf_flatpak_packages() {
    local selected
    if ! (($ + commands[flatpak])); then
        echo "Flatpak not found"
        return 1
    fi

    selected=$(flatpak list --app --columns=application 2>/dev/null | fzf --multi \
        --preview 'flatpak info {} 2>/dev/null || echo "Application info not available"' \
        --preview-window=right:50%:wrap \
        --header 'Installed Flatpak Applications')
    [[ -n "$selected" ]] && echo "$selected"
}

# Universal package search (detects system type)
function fzf_fedora_packages() {
    if is_atomic_desktop; then
        echo "=== Layered Packages ==="
        fzf_rpm_ostree_packages
        echo -e "\n=== Flatpak Applications ==="
        fzf_flatpak_packages
    else
        fzf_dnf_packages
    fi
}

# DNF package search in repositories
function fzf_dnf_search() {
    local query selected
    query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: fzf_dnf_search <search_term>"
        return 1
    fi

    selected=$(dnf search "$query" 2>/dev/null |
        grep -E '^[a-zA-Z0-9].*\..*:' |
        awk '{print $1}' |
        sed 's/\.[^.]*$//' |
        sort -u | fzf --multi \
        --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
        --preview-window=right:50%:wrap \
        --header "DNF Search Results for: $query")
    [[ -n "$selected" ]] && echo "$selected"
}

# Toolbox container management (for Atomic Desktops)
function fzf_toolbox_containers() {
    local selected
    if ! (($ + commands[toolbox])); then
        echo "Toolbox not found"
        return 1
    fi

    selected=$(toolbox list --containers 2>/dev/null |
        awk 'NR>1 && NF>=2 {print $2}' | fzf \
        --preview 'toolbox list --containers 2>/dev/null | grep {} || echo "Container info not available"' \
        --preview-window=right:50%:wrap \
        --header 'Toolbox Containers')
    [[ -n "$selected" ]] && echo "$selected"
}

# System service management
function fzf_systemd_services() {
    local selected
    selected=$(systemctl list-units --type=service --all --no-pager --no-legend 2>/dev/null |
        awk '{print $1}' |
        grep '\.service$' | fzf --multi \
        --preview 'systemctl status {} 2>/dev/null || echo "Service status not available"' \
        --preview-window=right:50%:wrap \
        --header 'Systemd Services')
    [[ -n "$selected" ]] && echo "$selected"
}

# Zsh widgets for key bindings
function fzf_fedora_packages_widget() {
    local result=$(fzf_fedora_packages)
    if [[ -n "$result" ]]; then
        LBUFFER+="$result "
        zle redisplay
    fi
}

function fzf_systemd_services_widget() {
    local result=$(fzf_systemd_services)
    if [[ -n "$result" ]]; then
        LBUFFER+="systemctl status $result "
        zle redisplay
    fi
}

function fzf_toolbox_widget() {
    local result=$(fzf_toolbox_containers)
    if [[ -n "$result" ]]; then
        LBUFFER+="toolbox enter $result "
        zle redisplay
    fi
}

# Register ZSH widgets
zle -N fzf_fedora_packages_widget
zle -N fzf_systemd_services_widget
zle -N fzf_toolbox_widget

# Key bindings
bindkey '^p' fzf_fedora_packages_widget  # Ctrl+P for packages
bindkey '^s' fzf_systemd_services_widget # Ctrl+S for services
bindkey '^o' fzf_toolbox_widget          # Ctrl+O for toolbox containers
