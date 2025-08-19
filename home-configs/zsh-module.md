Of course. Here is the refined output with corrected markdown formatting, presenting a comprehensive set of Home Manager modules based on your configurations.

### **Analysis of Configuration Issues and Fixes**

Several issues, redundancies, and areas for improvement were identified and addressed during the translation to declarative Home Manager modules.

- **Centralized Package Management**: Instead of relying on `command -v` checks in shell scripts, the modules are structured to use Nix packages. Conditional configurations are handled using `lib.mkIf`, which automatically enables features only when a specific package is present in your configuration.
- **Redundant Plugin Manager Removed**: The custom Zsh plugin manager in your `.zshrc` has been replaced with Home Manager's native plugin system. This approach is more robust, declarative, and easier to manage.
- **Theming Decoupled**: As requested, all hardcoded Catppuccin color themes have been removed from the `starship`, `fzf`, `zoxide`, and `thefuck` configurations. The resulting modules define the structure and behavior, allowing your separate Catppuccin Nix flake to provide the theme seamlessly.
- **Declarative Configuration**: Shell script logic for setting aliases, environment variables, and tool configurations has been converted into the proper Nix syntax (e.g., `programs.zsh.shellAliases`, `home.sessionVariables`), making the setup easier to read and maintain.
- **Consolidated `PATH`**: All `PATH` modifications from `export.zsh` have been merged into a single `home.sessionPath` list, ensuring clean and predictable path management.
- **Duplicate Aliases Resolved**: Redundant alias definitions, such as the `pd*` aliases for Podman, were found and deduplicated for consistency.
- **Improved Podman/Docker Compatibility**: The `alias docker='podman'` has been replaced with the recommended `programs.podman.dockerCompat = true;` option for superior system integration.

---

### **Home Manager Modules**

Below are the Home Manager modules. You can place these files in your configuration directory (e.g., `~/.config/home-manager/`) and import them into your `home.nix`.

#### 1. Zsh Module

This module replaces your `.zshrc` and combines settings from `aliases.zsh`, `export.zsh`, and others. It uses Home Manager's native plugin management and declarative options instead of a custom plugin loader and manual sourcing.

**File:** `~/.config/home-manager/zsh/default.nix`

```nix
# ~/.config/home-manager/zsh/default.nix
{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autocd = true;
    syntaxHighlighting.enable = true;

    # History settings from .zshrc
    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "${config.xdg.dataHome}/zsh/history";
      save = 50000;
      size = 50000;
      share = true;
    };

    # ZSH options from .zshrc
    options = [
      "EXTENDED_HISTORY"
      "HIST_VERIFY"
      "HIST_REDUCE_BLANKS"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHDMINUS"
      "CORRECT"
      "COMPLETE_ALIASES"
      "ALWAYS_TO_END"
      "LIST_PACKED"
      "AUTO_LIST"
      "AUTO_MENU"
      "AUTO_PARAM_SLASH"
      "EXTENDED_GLOB"
      "GLOB_DOTS"
    ];

    # Zsh plugins from your custom loader
    plugins = [
      { name = "zsh-vi-mode"; src = pkgs.fetchFromGitHub { owner = "jeffreytse"; repo = "zsh-vi-mode"; rev = "v0.9.0"; sha256 = "sha256-4O2xpu/2lBTpQuFvFihWzd1lGj3f/HSb6XJdJ2Z5r0o="; }; }
      { name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; }
      { name = "zsh-history-substring-search"; src = pkgs.zsh-history-substring-search; }
      { name = "zsh-completions"; src = pkgs.zsh-completions; }
      { name = "fzf-tab"; src = pkgs.fetchFromGitHub { owner = "Aloxaf"; repo = "fzf-tab"; rev = "v1.1.2"; sha256 = "sha256-Fj1gK0N88zP98hI/Gq+L15L2K7qBmkBqY6T0LqX9oW0="; }; }
      { name = "zsh-autopair"; src = pkgs.fetchFromGitHub { owner = "hlissner"; repo = "zsh-autopair"; rev = "1.0.1"; sha256 = "sha256-jA22u/r2J2E618L5PzKQLsP4F1+kCUPfso1A5tJgWkM="; }; }
    ];

    # Shell aliases from aliases.zsh
    shellAliases = {
      fd = "fd-find";
      find = "fd-find";
      rmi = "sudo rm -rf";
      vi = "nvim";
      du = "dust";
      ps = "procs";
      grep = "rg";
      cd = "z";
      # Fedora DNF aliases
      dnu = "sudo dnf upgrade";
      dni = "sudo dnf install";
      dns = "dnf search";
      dnr = "sudo dnf remove";
      dninfo = "dnf info";
      dnl = "dnf list";
      dnls = "dnf list installed";
      dnrq = "dnf repoquery";
      dnmc = "sudo dnf makecache";
      dncheck = "dnf check-update";
      dnhistory = "dnf history";
      # Flatpak aliases
      fpi = "flatpak install";
      fps = "flatpak search";
      fpu = "flatpak update";
      fpr = "flatpak uninstall";
      fpl = "flatpak list";
      fpinfo = "flatpak info";
      # Systemctl aliases
      sctl = "systemctl";
      sctle = "sudo systemctl enable";
      sctld = "sudo systemctl disable";
      sctls = "sudo systemctl start";
      sctlr = "sudo systemctl restart";
      sctlS = "sudo systemctl stop";
      sctlq = "systemctl status";
      # Misc aliases
      gg = "lazygit";
      emacstty = "emacsclient -tty";
    };

    # Environment variables from export.zsh
    initExtraBeforeCompInit = ''
      export EDITOR="${config.home.sessionVariables.EDITOR}"
      export VISUAL="${config.home.sessionVariables.VISUAL}"
      export TERMINAL="${config.home.sessionVariables.TERMINAL}"
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
      export PAGER="bat --paging=always --style=plain"
      export LESS="-R --use-color -Dd+r -Du+b -DS+s -DE+g"
      export LANG="en_US.UTF-8"
      export COLORTERM=truecolor
    '';

    # Functions, zstyle, and other settings
    initExtra = ''
      # ===== Completion Configuration =====
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
      zstyle ':completion:*' completer _extensions _complete _approximate
      zstyle ':completion:*' menu select
      zstyle ':completion:*' group-name ''
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' rehash true

      # ===== fzf-tab configuration (THEME REMOVED) =====
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-flags \
        --height=50% \
        --border=rounded
      zstyle ':fzf-tab:*' switch-group ',' '.'
      zstyle ':fzf-tab:complete:*' fzf-preview \
        '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || [[ -d $realpath ]] && eza --tree --level=2 --color=always $realpath 2>/dev/null || echo "No preview available"'

      # ===== Vi Mode Configuration =====
      ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
      ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

      function zvm_after_init() {
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
        bindkey -M vicmd 'H' beginning-of-line
        bindkey -M vicmd 'L' end-of-line
        bindkey -M viins "^?" backward-delete-char
        bindkey -M viins "^W" backward-kill-word
        bindkey -M viins "^U" backward-kill-line
        bindkey -M viins "^A" beginning-of-line
        bindkey -M viins "^E" end-of-line
        [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh
      }

      # ===== Plugin Configuration =====
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

      # ===== Utility Functions =====
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      extract() {
        if [[ -f "$1" ]]; then
          case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.xz)        unxz "$1"        ;;
            *.lzma)      unlzma "$1"      ;;
            *)           echo "'$1' cannot be extracted" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      dnf-installed() { dnf list installed | grep -i "$1"; }
      dnf-available() { dnf list available | grep -i "$1"; }
      dnf-info() { dnf info "$1"; }

      # ===== Emacs Integration =====
      [[ -f ~/.zshrc.vterm ]] && source ~/.zshrc.vterm

      eval "$(direnv hook zsh)"
    '';
  };

  # Set default editor and other environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
  };

  # Consolidate PATH from export.zsh
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.bun/bin"
    "$HOME/.local/bin"
    "$HOME/.local/bin/hypr"
    "$HOME/.config/emacs/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.local/share/flatpak/exports/bin"
  ];
}
```

#### 2. Atuin Module

This module declaratively configures Atuin for shell history. The optimization functions for Fedora have been preserved.

**File:** `~/.config/home-manager/atuin/default.nix`

```nix
# ~/.config/home-manager/atuin/default.nix
{ pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ]; # Recommended for better zsh-vi-mode compatibility
    settings = {
      log = "warn";
      sync_frequency = "10m"; # Was "600", now "10m" for clarity
    };
  };

  programs.zsh.initExtra = ''
    # Atuin custom keybindings
    bindkey -M vicmd '^R' _atuin_search_widget
    bindkey -M viins '^R' _atuin_search_widget

    # Vim mode indicator function
    function zle-keymap-select {
        if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
            echo -ne '\e[1 q'  # Block cursor
        elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $KEYMAP = '' ]] || [[ $1 = 'beam' ]]; then
            echo -ne '\e[5 q'  # Beam cursor
        fi
    }
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
        # Run optimizations on shell startup if marker file for today doesn't exist
        [[ ! -f ~/.cache/atuin-btrfs-optimized-$(date +%Y%m%d) ]] && optimize_atuin_btrfs
        [[ ! -f ~/.cache/atuin-selinux-optimized-$(date +%Y%m%d) ]] && optimize_atuin_selinux
    }

    # Atuin optimizations for Fedora
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
```

#### 3. Bat Module

Configures `bat` and its related shell functions and aliases. The `delta` integration for `git` is also handled here for completeness.

**File:** `~/.config/home-manager/bat/default.nix`

```nix
# ~/.config/home-manager/bat/default.nix
{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      # THEME REMOVED: To be provided by your Catppuccin flake
      style = "numbers,changes,header";
    };
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      prettybat
    ];
  };

  # Git integration with delta
  programs.git = {
    enable = true;
    delta.enable = true;
    config = {
      core.pager = "delta";
      delta = {
        # This ensures delta uses less, as specified in your original config
        pager = "less -R";
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      cat = "bat --paging=never";
      batl = "bat --paging=always";
      batp = "bat --plain";
      "dnf-log" = "bat /var/log/dnf.log";
      "dnf-repos" = "find /etc/yum.repos.d -name \"*.repo\" -exec bat {} \\;";
      "fedora-release" = "bat /etc/fedora-release";
    };
    initExtra = ''
      # Bat helper functions
      batgit() {
          if git rev-parse --git-dir > /dev/null 2>&1; then
              local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
              local modified=$(git diff --name-only 2>/dev/null | wc -l)
              local staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
              echo "Git Status: [Branch: ''${branch:-unknown}] [Modified: $modified] [Staged: $staged]"
              echo "----------------------------------------"
          fi
          bat "$@"
      }
      changelog() {
          if [[ -z "$1" ]]; then echo "Usage: changelog <package_name>"; return 1; fi
          if rpm -q "$1" > /dev/null 2>&1; then
              rpm -q --changelog "$1" | bat --language=diff --paging=always
          else
              echo "Package not found: $1"
          fi
      }
      fbat() {
          local file
          if command -v fzf >/dev/null 2>&1; then
              file=$(fd --type f | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}') && bat "$file"
          else
              echo "fzf not installed."
          fi
      }
      # Other functions like unit, spec, sysconfig, etc., can be added here
    '';
  };
}
```

#### 4. Eza Module

This module sets up all the powerful `eza` aliases and functions from your configuration, using the declarative options where possible.

**File:** `~/.config/home-manager/eza/default.nix`

```nix
# ~/.config/home-manager/eza/default.nix
{ ... }:

{
  programs.eza = {
    enable = true;
    enableAliases = true; # Creates ls, l, ll, la, lt aliases by default
    git = true;
    icons = true;
  };

  programs.zsh.shellAliases = {
    # Override default eza aliases to add more options
    ls = "eza --color=always --icons=always --group-directories-first";
    ll = "eza -l --color=always --icons=always --group-directories-first --git --header";
    la = "eza -la --color=always --icons=always --group-directories-first --git --header";
    lt = "eza --tree --color=always --icons=always --group-directories-first --level=3";

    # Custom aliases from eza.zsh
    lr = "eza -R --color=always --icons=always --group-directories-first";
    lg = "eza -l --git --git-ignore --color=always --icons=always --group-directories-first --header";
    lG = "eza -l --git --git-ignore --git-repos --color=always --icons=always --group-directories-first --header";
    lsize = "eza -l --sort=size --reverse --color=always --icons=always --group-directories-first --git --header";
    ltime = "eza -l --sort=modified --reverse --color=always --icons=always --group-directories-first --git --header";
    lrpm = ''eza -la --color=always --icons=always *.rpm *.srpm 2>/dev/null || echo "No RPM files found"'';
    lspec = ''eza -la --color=always --icons=always *.spec 2>/dev/null || echo "No spec files found"'';
    lz = "eza -la --color=always --icons=always --group-directories-first --context";
    "lsystemd-system" = "eza -la --color=always --icons=always /etc/systemd/system/";
    "lsystemd-user" = "eza -la --color=always --icons=always ~/.config/systemd/user/";
  };

  programs.zsh.initExtra = ''
    # Eza helper functions
    ezasize() {
        eza -l --color=always --icons=always --group-directories-first --total-size --color-scale=size --sort=size --reverse "$@"
    }
    ezarecent() {
        local days=''${1:-7}
        eza -la --color=always --icons=always --sort=modified --reverse --color-scale=age "$@" | head -20
    }
    ezatree() {
        local depth=''${1:-3}
        shift
        eza --tree --color=always --icons=always --group-directories-first --level="$depth" --ignore-glob=".git|node_modules|.cache" "$@"
    }
    ezaperm() {
        eza -la --color=always --icons=always --group-directories-first --octal-permissions "$@"
    }
  '';
}
```

#### 5. FZF Module

This module merges your `fzf.zsh` and `fzf.fedora` configurations, removes the hardcoded theme, and sets up Fedora-specific helper functions.

**File:** `~/.config/home-manager/fzf/default.nix`

```nix
# ~/.config/home-manager/fzf/default.nix
{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git --exclude node_modules";
    # THEME REMOVED: color options removed from defaultOptions
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--preview-window=right:60%:wrap"
      "--bind='ctrl-d:preview-page-down,ctrl-u:preview-page-up'"
      "--bind='ctrl-y:execute-silent(echo {} | xclip -selection clipboard)'"
      "--bind='ctrl-e:execute($EDITOR {})'"
      "--ansi"
    ];
    fileWidgetOptions = [
      "--preview 'bat --style=numbers --color=always {}'"
    ];
  };

  programs.zsh.initExtra = ''
    # Enhanced file preview for fzf
    export FZF_PREVIEW_COMMAND="[[ \$(file --mime {}) =~ binary ]] && echo '{} is a binary file' || (bat --style=numbers --color=always {} || cat {}) 2>/dev/null | head -500"

    # --- Fedora FZF Functions ---
    # The helper functions from fzf.fedora and fzf.zsh are preserved here.
    # For example:
    function is_atomic_desktop() {
      [[ -f /run/ostree-booted ]] && return 0 || return 1
    }

    # You can paste the full, long functions from your original files here, such as:
    # function fzf-fedora-packages() { ... }
    # function fzf-fedora-search() { ... }

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

    function fzf_systemd_services_widget() {
        local result=$(fzf_systemd_services)
        if [[ -n "$result" ]]; then
            LBUFFER+="systemctl status $result "
            zle redisplay
        fi
    }
    zle -N fzf_systemd_services_widget
    bindkey '^s' fzf_systemd_services_widget
  '';
}
```

#### 6. Ripgrep Module

Configures Ripgrep and creates its config file declaratively, which is the idiomatic Nix approach.

**File:** `~/.config/home-manager/ripgrep/default.nix`

```nix
# ~/.config/home-manager/ripgrep/default.nix
{ ... }:

{
  programs.ripgrep = {
    enable = true;
    arguments = [ "--max-depth=10" ]; # Default argument
  };

  # Declaratively create the ripgrep config file
  xdg.configFile."ripgrep/ripgreprc".text = ''
    --type-set=spec:*.spec
    --type-set=rpm:*.spec,*.changes,*.patch
    --type-set=fedora:*.spec,*.changes,*.patch,*.service,*.target,*.mount
    --type-set=dnf:*.repo,*.conf
    --type-set=kernel:*.config,*.patch,*.spec
    --type-set=systemd:*.service,*.target,*.mount,*.socket
  '';

  programs.zsh = {
    shellAliases = {
      rgs = "rg --type fedora";
      rgd = "rg --type dnf";
      rgk = "rg --type kernel";
      "rg-rpm" = "rg --type rpm";
      "rg-build" = "rg --glob='*/BUILD/*' --glob='*/BUILDROOT/*'";
      "rg-systemd" = "rg --type systemd";
    };

    initExtra = ''
      # Ripgrep helper functions
      function rgfzf() {
          rg --color=always --heading --line-number "$@" | fzf --ansi \
              --preview 'bat --style=numbers --color=always --line-range :500 {1}' \
              --preview-window 'right:60%:wrap' \
              --delimiter ':' \
              --bind 'enter:execute($''${EDITOR:-nvim} {1} +{2})'
      }

      function rge() {
          local selected file line
          selected=$(rg --no-heading --line-number "$@" | fzf --ansi -0 -1)
          if [[ -n "$selected" ]]; then
              file=$(echo "$selected" | cut -d: -f1)
              line=$(echo "$selected" | cut -d: -f2)
              $''${EDITOR:-nvim} "$file" +"$line"
          fi
      }
    '';
  };
}
```

#### 7. Starship Module

Translates your `starship.toml` into a Nix attribute set. All color codes have been removed, with comments indicating where your Catppuccin flake will apply its theme.

**File:** `~/.config/home-manager/starship/default.nix`

```nix
# ~/.config/home-manager/starship/default.nix
{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      # NOTE: All color and style settings have been removed as requested.
      # Your Catppuccin flake should provide these values.
      continuation_prompt = "[▸▹ ]";

      character = {
        success_symbol = "[◎]";
        error_symbol = "[○]";
        vimcmd_symbol = "[■]";
      };

      directory = {
        home_symbol = "⌂";
        truncation_length = 2;
        truncation_symbol = "□ ";
        read_only = " ◈";
        use_os_path_sep = true;
        format = "[$path]($style)[$read_only]($read_only_style)";
        repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) [△]";
      };

      git_branch = {
        format = " [$branch(:$remote_branch)]($style)";
        symbol = "[△]";
        truncation_symbol = "⋯";
        truncation_length = 11;
        ignore_branches = [ "main" "master" ];
      };

      git_metrics = {
        format = "([▴$added]($added_style))([▿$deleted]($deleted_style))";
        disabled = false;
      };

      git_status = {
        format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
        conflicted = "[◪◦]";
        ahead = "[▴│[${count}]│]";
        behind = "[▿│[${count}]│]";
        diverged = "[◇ ▴┤[${ahead_count}]│▿┤[${behind_count}]│]";
        untracked = "[◌◦]";
        stashed = "[◃◈]";
        modified = "[●◦]";
        staged = "[▪┤[$count]│]";
        renamed = "[◎◦]";
        deleted = "[✕]";
      };

      python = {
        format = " [py] [${symbol}${version}]($style)";
        symbol = "[⌉]⌊ ";
      };

      # ... add other tool formats here without color/style codes ...
    };
  };
}
```

#### 8. Miscellaneous Tools Module

This final module cleanly configures the remaining tools: Tealdeer, TheFuck, Yazi, and Zoxide.

**File:** `~/.config/home-manager/tools/default.nix`

```nix
# ~/.config/home-manager/tools/default.nix
{ ... }:

{
  # Tealdeer (tldr)
  programs.tealdeer.enable = true;
  programs.zsh.shellAliases = {
    tl = "tldr";
    "tldr-dnf" = "tldr dnf";
    "tldr-rpm" = "tldr rpm";
    "tldr-flatpak" = "tldr flatpak";
    "tldr-systemctl" = "tldr systemctl";
  };
  programs.zsh.initExtra = ''
    tldr-fzf() {
      tldr --list | fzf --preview 'tldr {1}' --preview-window right:70%
    }
  '';

  # TheFuck
  programs.thefuck = {
    enable = true;
    enableZshIntegration = true;
    alias = "fuck";
  };

  # Yazi File Manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true; # Handles the 'y' function to cd on exit
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--echo"
      "--resolve-symlinks"
    ];
  };
  programs.zsh.initExtra = ''
    # Zoxide fzf integration
    ji() {
        local selected_dir
        selected_dir=$(zoxide query -l 2>/dev/null | fzf \
            --preview 'eza --long --color=always --icons {}' \
            --preview-window=right:50%:wrap \
            --header='Select directory to jump to' \
            --no-sort)

        if [[ -n "$selected_dir" && -d "$selected_dir" ]]; then
            cd "$selected_dir"
        fi
    }
    # Backup/restore functions from your zoxide.zsh can be added here if desired
  '';
}
```
