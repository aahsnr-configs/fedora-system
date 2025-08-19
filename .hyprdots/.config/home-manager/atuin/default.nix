# ~/.config/home-manager/atuin/default.nix
{ ... }: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
    ]; # Recommended for better zsh-vi-mode compatibility
    settings = {
      log = "warn";
      sync_frequency = "10m";
    };
  };

  programs.zsh.initContent = ''
    # Atuin custom keybindings
    bindkey -M vicmd '^R' _atuin_search_widget
    bindkey -M viins '^R' _atuin_search_widget

    # Vim mode indicator function
    zle -N zle-keymap-select
    echo -ne '\e[5 q' # Initialize cursor on startup

    # Atuin helper functions
    function show_dnf_history() {
        if command -v atuin &> /dev/null; then
            atuin search "dnf" --interactive
        else
            dnf history
        fi
    }

    # Alias for system info
    alias sysinfo=show_system_info

    function show_system_info() {
        echo "=== Fedora System Information ==="
        echo "Kernel: $(uname -r)"
        [[ -f /etc/os-release ]] && echo "Fedora Release: $(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')"
        echo "Atuin Status: $(systemctl --user is-active atuin.service 2>/dev/null || echo 'not running')"
        if command -v atuin &> /dev/null; then
            echo "Atuin Version: $(atuin --version 2>/dev/null | head -n1)"
            local history_count=$(atuin stats 2>/dev/null | grep -E 'Total commands|commands recorded' | awk '{print $NF}' | head -n1)
            echo "History Count: ''${history_count:-unknown}"
        fi
        [[ -f ~/.cache/atuin-btrfs-optimized-$(date +%Y%m%d) ]] || optimize_atuin_btrfs
        [[ -f ~/.cache/atuin-selinux-optimized-$(date +%Y%m%d) ]] || optimize_atuin_selinux
    }

    # Atuin optimizations (Note: these run on shell startup)
    function optimize_atuin_selinux() {
        if command -v getenforce &> /dev/null; then
            if [[ "$(getenforce)" == "Enforcing" ]]; then
                restorecon -R ~/.local/share/atuin/ 2>/dev/null || true
            fi
            mkdir -p ~/.cache && touch ~/.cache/atuin-selinux-optimized-$(date +%Y%m%d)
        fi
    }
    function optimize_atuin_btrfs() {
        local db_path="$HOME/.local/share/atuin/history.db"
        if [[ -f "$db_path" ]] && findmnt -n -o FSTYPE / | grep -q btrfs; then
            chattr +C "$db_path" 2>/dev/null
            btrfs property set "$db_path" compression none 2>/dev/null
            mkdir -p ~/.cache && touch ~/.cache/atuin-btrfs-optimized-$(date +%Y%m%d)
        fi
    }
  '';
}
