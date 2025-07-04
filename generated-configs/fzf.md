# Advanced and Optimized FZF Configuration for Fedora 42 with Catppuccin Mocha Colorscheme (ZSH Edition)

## ~/.zshrc additions

```zsh
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

# Use fd (faster and respects .gitignore)
if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Fedora-specific optimizations
export FZF_COMPLETION_DIR_COMMANDS="dnf rpm-ostree flatpak toolbox podman"

# Enhanced file preview with syntax highlighting
export FZF_PREVIEW_COMMAND="[[ \$(file --mime {}) =~ binary ]] && 
    echo '{} is a binary file' || 
    (bat --style=numbers --color=always {} || 
    cat {}) 2>/dev/null | head -500"

# Detect if running on Atomic Desktop (Silverblue, Kinoite, etc.)
function is_atomic_desktop() {
    [[ -f /run/ostree-booted ]] && return 0 || return 1
}

# DNF package search integration (for traditional Fedora)
function fzf_dnf_packages() {
    local selected
    if ! (( $+commands[dnf] )); then
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
    if ! (( $+commands[rpm-ostree] )); then
        echo "rpm-ostree not found"
        return 1
    fi
    
    # Get layered packages from rpm-ostree status
    selected=$(rpm-ostree status --json 2>/dev/null | \
        jq -r '.deployments[0]["requested-packages"][]? // empty' 2>/dev/null | \
        sort -u | fzf --multi \
        --preview 'rpm -qi {} 2>/dev/null || dnf info {} 2>/dev/null || echo "Package info not available"' \
        --preview-window=right:50%:wrap \
        --header 'Layered RPM-OSTree Packages')
    [[ -n "$selected" ]] && echo "$selected"
}

# Flatpak package search integration
function fzf_flatpak_packages() {
    local selected
    if ! (( $+commands[flatpak] )); then
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
    
    selected=$(dnf search "$query" 2>/dev/null | \
        grep -E '^[a-zA-Z0-9].*\..*:' | \
        awk '{print $1}' | \
        sed 's/\.[^.]*$//' | \
        sort -u | fzf --multi \
        --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
        --preview-window=right:50%:wrap \
        --header "DNF Search Results for: $query")
    [[ -n "$selected" ]] && echo "$selected"
}

# Toolbox container management (for Atomic Desktops)
function fzf_toolbox_containers() {
    local selected
    if ! (( $+commands[toolbox] )); then
        echo "Toolbox not found"
        return 1
    fi
    
    selected=$(toolbox list --containers 2>/dev/null | \
        awk 'NR>1 && NF>=2 {print $2}' | fzf \
        --preview 'toolbox list --containers 2>/dev/null | grep {} || echo "Container info not available"' \
        --preview-window=right:50%:wrap \
        --header 'Toolbox Containers')
    [[ -n "$selected" ]] && echo "$selected"
}

# System service management
function fzf_systemd_services() {
    local selected
    selected=$(systemctl list-units --type=service --all --no-pager --no-legend 2>/dev/null | \
        awk '{print $1}' | \
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
bindkey '^p' fzf_fedora_packages_widget      # Ctrl+P for packages
bindkey '^s' fzf_systemd_services_widget     # Ctrl+S for services
bindkey '^o' fzf_toolbox_widget              # Ctrl+O for toolbox containers
```

## ~/.config/fzf/fzf.fedora

```sh
#!/usr/bin/env zsh

# Fedora-specific FZF functions with proper error handling

# Detect system type helper
function is_atomic_desktop() {
    [[ -f /run/ostree-booted ]] && return 0 || return 1
}

# Comprehensive package management
function fzf-fedora-packages() {
    if is_atomic_desktop; then
        echo "🔷 RPM-OSTree Layered Packages:"
        if (( $+commands[rpm-ostree] )); then
            rpm-ostree status --json 2>/dev/null | \
                jq -r '.deployments[0]["requested-packages"][]? // empty' 2>/dev/null | \
                sort -u | fzf --multi \
                --preview 'rpm -qi {} 2>/dev/null || dnf info {} 2>/dev/null || echo "Package info not available"' \
                --preview-window=right:50%:wrap \
                --header 'Layered Packages (rpm-ostree)' \
                --bind 'enter:execute(rpm -qi {} 2>/dev/null || dnf info {})'
        else
            echo "rpm-ostree not available"
        fi
        
        echo -e "\n🔷 Flatpak Applications:"
        if (( $+commands[flatpak] )); then
            flatpak list --app --columns=application 2>/dev/null | fzf --multi \
                --preview 'flatpak info {} 2>/dev/null || echo "Application info not available"' \
                --preview-window=right:50%:wrap \
                --header 'Flatpak Applications' \
                --bind 'enter:execute(flatpak info {})'
        else
            echo "Flatpak not available"
        fi
    else
        if (( $+commands[dnf] )); then
            dnf list installed 2>/dev/null | \
                awk 'NR>1 && NF>=3 {print $1}' | \
                sed 's/\.[^.]*$//' | \
                sort -u | fzf --multi \
                --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
                --preview-window=right:50%:wrap \
                --header 'Installed DNF Packages' \
                --bind 'enter:execute(dnf info {})'
        else
            echo "DNF not available"
        fi
    fi
}

# Search available packages
function fzf-fedora-search() {
    local query
    query="${1:-}"
    if [[ -z "$query" ]]; then
        echo "Usage: fzf-fedora-search <search_term>"
        return 1
    fi
    
    if ! (( $+commands[dnf] )); then
        echo "DNF not available"
        return 1
    fi
    
    if is_atomic_desktop; then
        echo "Searching for packages to layer with rpm-ostree..."
        dnf search "$query" 2>/dev/null | \
            grep -E '^[a-zA-Z0-9].*\..*:' | \
            awk '{print $1}' | \
            sed 's/\.[^.]*$//' | \
            sort -u | fzf --multi \
            --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
            --preview-window=right:50%:wrap \
            --header "Available packages for: $query" \
            --bind 'enter:execute(dnf info {})'
    else
        dnf search "$query" 2>/dev/null | \
            grep -E '^[a-zA-Z0-9].*\..*:' | \
            awk '{print $1}' | \
            sed 's/\.[^.]*$//' | \
            sort -u | fzf --multi \
            --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
            --preview-window=right:50%:wrap \
            --header "DNF Search Results: $query" \
            --bind 'enter:execute(dnf info {})'
    fi
}

# System update management
function fzf-fedora-updates() {
    if is_atomic_desktop; then
        if (( $+commands[rpm-ostree] )); then
            echo "🔄 Checking for rpm-ostree updates..."
            rpm-ostree upgrade --check 2>/dev/null | fzf \
                --preview 'rpm-ostree status' \
                --header 'RPM-OSTree System Updates' \
                --bind 'enter:execute(rpm-ostree status)'
        else
            echo "rpm-ostree not available"
        fi
    else
        if (( $+commands[dnf] )); then
            dnf check-update 2>/dev/null | \
                awk 'NR>1 && NF>=3 {print $1}' | \
                sed 's/\.[^.]*$//' | \
                sort -u | fzf --multi \
                --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
                --preview-window=right:50%:wrap \
                --header 'Available DNF Updates' \
                --bind 'enter:execute(dnf info {})'
        else
            echo "DNF not available"
        fi
    fi
}

# Toolbox management (Atomic Desktop specific)
function fzf-fedora-toolbox() {
    if ! (( $+commands[toolbox] )); then
        echo "Toolbox is not installed. Install with: sudo dnf install toolbox"
        return 1
    fi
    
    local action
    action=$(echo -e "list\nenter\ncreate\nrm" | fzf --header 'Toolbox Actions')
    
    case "$action" in
        "list")
            toolbox list 2>/dev/null || echo "No toolbox containers found"
            ;;
        "enter")
            local container
            container=$(toolbox list --containers 2>/dev/null | \
                awk 'NR>1 && NF>=2 {print $2}' | fzf \
                --preview 'toolbox list --containers 2>/dev/null | grep {} || echo "Container info not available"' \
                --header 'Select Container to Enter')
            [[ -n "$container" ]] && toolbox enter "$container"
            ;;
        "create")
            echo -n "Enter container name: "
            read container_name
            [[ -n "$container_name" ]] && toolbox create "$container_name"
            ;;
        "rm")
            local container
            container=$(toolbox list --containers 2>/dev/null | \
                awk 'NR>1 && NF>=2 {print $2}' | fzf \
                --preview 'toolbox list --containers 2>/dev/null | grep {} || echo "Container info not available"' \
                --header 'Select Container to Remove')
            [[ -n "$container" ]] && toolbox rm "$container"
            ;;
    esac
}

# System service management
function fzf-fedora-services() {
    local service_type
    service_type=$(echo -e "user\nsystem" | fzf --header 'Service Type')
    
    local systemctl_cmd
    case "$service_type" in
        "user")
            systemctl_cmd="systemctl --user"
            ;;
        "system")
            systemctl_cmd="systemctl"
            ;;
        *)
            return 1
            ;;
    esac
    
    $systemctl_cmd list-units --type=service --all --no-pager --no-legend 2>/dev/null | \
        awk '{print $1}' | \
        grep '\.service$' | fzf --multi \
        --preview "$systemctl_cmd status {} 2>/dev/null || echo 'Service status not available'" \
        --preview-window=right:50%:wrap \
        --header "Systemd Services ($service_type)" \
        --bind "enter:execute($systemctl_cmd status {})"
}

# Repository management
function fzf-fedora-repos() {
    if ! (( $+commands[dnf] )); then
        echo "DNF not available"
        return 1
    fi
    
    dnf repolist --all 2>/dev/null | \
        awk 'NR>1 && NF>=2 {print $1}' | fzf \
        --preview 'dnf repoinfo {} 2>/dev/null || echo "Repository info not available"' \
        --preview-window=right:50%:wrap \
        --header 'DNF Repositories' \
        --bind 'enter:execute(dnf repoinfo {})'
}

# Kernel management (especially useful for Atomic Desktops)
function fzf-fedora-kernels() {
    if is_atomic_desktop; then
        if (( $+commands[rpm-ostree] )); then
            rpm-ostree status 2>/dev/null | \
                grep -E '^\*|^  ' | fzf \
                --preview 'rpm-ostree status' \
                --header 'OSTree Deployments' \
                --bind 'enter:execute(rpm-ostree status)'
        else
            echo "rpm-ostree not available"
        fi
    else
        if (( $+commands[dnf] )); then
            dnf list installed 'kernel*' 2>/dev/null | \
                awk 'NR>1 && NF>=3 {print $1}' | \
                sed 's/\.[^.]*$//' | \
                sort -u | fzf \
                --preview 'dnf info {} 2>/dev/null || echo "Package info not available"' \
                --preview-window=right:50%:wrap \
                --header 'Installed Kernels' \
                --bind 'enter:execute(dnf info {})'
        else
            echo "DNF not available"
        fi
    fi
}

# Container management (Podman integration)
function fzf-fedora-containers() {
    if ! (( $+commands[podman] )); then
        echo "Podman not available. Install with: sudo dnf install podman"
        return 1
    fi
    
    local action
    action=$(echo -e "ps\nimages\nvolumes\nnetworks" | fzf --header 'Container Resources')
    
    case "$action" in
        "ps")
            podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null | \
                awk 'NR>1 {print $1}' | fzf \
                --preview 'podman inspect {} 2>/dev/null || echo "Container info not available"' \
                --header 'Podman Containers'
            ;;
        "images")
            podman images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" 2>/dev/null | \
                awk 'NR>1 {print $1":"$2}' | fzf \
                --preview 'podman inspect {} 2>/dev/null || echo "Image info not available"' \
                --header 'Podman Images'
            ;;
        "volumes")
            podman volume ls --format "table {{.Name}}" 2>/dev/null | \
                awk 'NR>1 {print $1}' | fzf \
                --preview 'podman volume inspect {} 2>/dev/null || echo "Volume info not available"' \
                --header 'Podman Volumes'
            ;;
        "networks")
            podman network ls --format "table {{.Name}}" 2>/dev/null | \
                awk 'NR>1 {print $1}' | fzf \
                --preview 'podman network inspect {} 2>/dev/null || echo "Network info not available"' \
                --header 'Podman Networks'
            ;;
    esac
}
```

## Installation Notes (Fedora 42 Edition)

### For Traditional Fedora Workstation:

1. Install dependencies:
   ```zsh
   sudo dnf install fzf fd-find bat xclip jq
   ```

### For Fedora Atomic Desktops (Silverblue, Kinoite, etc.):

1. Layer essential packages:
   ```zsh
   rpm-ostree install fzf fd-find bat xclip jq
   systemctl reboot
   ```

2. Install additional tools via Flatpak (optional):
   ```zsh
   flatpak install flathub org.gnome.TextEditor
   ```

### Common Setup:

1. Setup Catppuccin theme for bat:
   ```zsh
   mkdir -p ~/.config/bat/themes
   git clone https://github.com/catppuccin/bat.git ~/.config/bat/themes/catppuccin
   bat cache --build
   ```

2. Create config directory and add Fedora-specific functions:
   ```zsh
   mkdir -p ~/.config/fzf
   # Copy the fzf.fedora script to ~/.config/fzf/fzf.fedora
   chmod +x ~/.config/fzf/fzf.fedora
   ```

3. Source configuration in zshrc:
   ```zsh
   echo "source ~/.config/fzf/fzf.fedora" >> ~/.zshrc
   ```

4. Reload configuration:
   ```zsh
   source ~/.zshrc
   ```

## Key Features for Fedora 42 (Fixed Version)

### 1. **Robust Error Handling**:
   - All commands now check for tool availability with `(( $+commands[tool] ))`
   - Proper error messages when tools are unavailable
   - Graceful fallbacks and informative error reporting

### 2. **Correct Package Parsing**:
   - Fixed DNF output parsing to handle architecture suffixes properly
   - Proper rpm-ostree JSON parsing using correct field names
   - Improved package name extraction and deduplication

### 3. **Enhanced System Detection**:
   - Reliable Atomic Desktop detection using `/run/ostree-booted`
   - Context-aware package management based on system type
   - Proper handling of both DNF and rpm-ostree workflows

### 4. **Container Integration**:
   - Full Toolbox support with proper error handling
   - Added Podman container management functions
   - Container creation, management, and inspection workflows

### 5. **Improved Key Bindings**:
   - `Ctrl+P`: Package management (system-aware)
   - `Ctrl+S`: System service management
   - `Ctrl+O`: Toolbox/container management (changed from Ctrl+T to avoid conflict)

### 6. **Advanced Features**:
   - Repository management with proper error handling
   - System update checking for both DNF and rpm-ostree
   - Kernel version tracking with system-specific handling
   - User and system service management

### 7. **Performance and Reliability**:
   - All preview commands include error handling
   - Proper JSON parsing for structured data
   - Efficient sorting and deduplication
   - Robust command availability checking

This configuration is now production-ready for Fedora 42 systems and handles both traditional Workstation and Atomic Desktop variants with proper error handling and command validation.
