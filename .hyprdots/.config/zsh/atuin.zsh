if command -v atuin &> /dev/null; then
    # Initialize Atuin
    eval "$(atuin init zsh)"
    
    # Configure Atuin to use vim-style keybindings in search
    bindkey -M vicmd '^R' _atuin_search_widget
    bindkey -M viins '^R' _atuin_search_widget
fi

# Enable vim mode for Zsh
bindkey -v

# Vim mode indicator function
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'  # Block cursor for normal mode
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'  # Beam cursor for insert mode
    fi
}
zle -N zle-keymap-select

# Initialize cursor on startup
echo -ne '\e[5 q'

# Enhanced history navigation (only if not using Atuin's built-in)
if ! command -v atuin &> /dev/null; then
    bindkey '^p' up-line-or-search
    bindkey '^n' down-line-or-search
fi

# Source Fedora-specific aliases if they exist
if [[ -f ~/.alias ]]; then
    source ~/.alias
fi

# Atuin performance optimizations for Fedora 42
export ATUIN_LOG="warn"

# Reduce sync frequency for better performance
export ATUIN_SYNC_FREQUENCY="600"  # 10 minutes

# Fedora-specific settings
export ATUIN_CONFIG_DIR="$HOME/.config/atuin"

# Function to show dnf history with better formatting
function show_dnf_history() {
    if command -v atuin &> /dev/null; then
        atuin search "dnf" --interactive
    else
        dnf history
    fi
}

# Function to check SELinux status and optimize Atuin accordingly
function optimize_atuin_selinux() {
    if command -v getenforce &> /dev/null; then
        local selinux_status=$(getenforce)
        echo "SELinux status: $selinux_status"
        
        if [[ "$selinux_status" == "Enforcing" ]]; then
            echo "SELinux is enforcing - checking Atuin contexts..."
            
            # Check if Atuin daemon needs special context
            if ! ls -Z ~/.local/share/atuin/history.db 2>/dev/null | grep -q user_home_t; then
                echo "Setting proper SELinux context for Atuin database..."
                restorecon -R ~/.local/share/atuin/ 2>/dev/null || true
            fi
        fi
    fi
}

# Run SELinux optimization on shell startup (once per day)
if [[ ! -f ~/.cache/atuin-selinux-optimized-$(date +%Y%m%d) ]]; then
    optimize_atuin_selinux
    mkdir -p ~/.cache
    touch ~/.cache/atuin-selinux-optimized-$(date +%Y%m%d)
    # Clean old optimization markers
    find ~/.cache -name "atuin-selinux-optimized-*" -mtime +7 -delete 2>/dev/null
fi

# Function to show system info with Atuin context
function show_system_info() {
    echo "=== Fedora 42 System Information ==="
    echo "Kernel: $(uname -r)"
    
    if [[ -f /etc/os-release ]]; then
        echo "Fedora Release: $(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')"
    fi
    
    echo "Atuin Status: $(systemctl --user is-active atuin.service 2>/dev/null || echo 'not running')"
    
    if command -v atuin &> /dev/null; then
        echo "Atuin Version: $(atuin --version 2>/dev/null | head -n1)"
        local history_count=$(atuin stats 2>/dev/null | grep -E 'Total commands|commands recorded' | awk '{print $NF}' | head -n1)
        echo "History Count: ${history_count:-unknown}"
    fi
    
    if command -v dnf &> /dev/null; then
        local last_update=$(dnf history 2>/dev/null | grep -E 'upgrade|update' | head -n1 | awk '{print $3" "$4}')
        echo "Last Update: ${last_update:-unknown}"
    fi
    
    if command -v getenforce &> /dev/null; then
        echo "SELinux Status: $(getenforce)"
    fi
    
    echo "=== End System Information ==="
}

# Alias for quick system info
alias sysinfo=show_system_info

# Function to optimize Atuin database for Btrfs
function optimize_atuin_btrfs() {
    local db_path="$HOME/.local/share/atuin/history.db"
    
    if [[ -f "$db_path" ]] && findmnt -n -o FSTYPE / | grep -q btrfs; then
        echo "Optimizing Atuin database for Btrfs..."
        
        # Disable copy-on-write for database file
        if command -v chattr &> /dev/null; then
            chattr +C "$db_path" 2>/dev/null && echo "COW disabled for database"
        fi
        
        # Set no compression for database files
        if command -v btrfs &> /dev/null; then
            btrfs property set "$db_path" compression none 2>/dev/null && echo "Compression disabled for database"
        fi
    fi
}

# Run optimization on shell startup (once per day)
if [[ ! -f ~/.cache/atuin-btrfs-optimized-$(date +%Y%m%d) ]]; then
    optimize_atuin_btrfs
    mkdir -p ~/.cache
    touch ~/.cache/atuin-btrfs-optimized-$(date +%Y%m%d)
    # Clean old optimization markers
    find ~/.cache -name "atuin-btrfs-optimized-*" -mtime +7 -delete 2>/dev/null
fi
