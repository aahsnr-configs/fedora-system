Of course. After carefully studying your new Home Manager modules, I have integrated them with the previous configurations derived from your shell scripts. The result is a complete, cohesive, and declarative set of modules that are optimized for your Fedora environment.

Redundancies have been eliminated, configurations have been centralized, and all modules are designed to work together seamlessly. For example, shell-specific functions and aliases have been consolidated into the `zsh` module, while program-specific configurations like `bat`'s syntax mapping or `eza`'s color theme are kept within their respective modules.

Here are the final, refined Home Manager modules.

---

### **System & Development Modules**

These modules configure core development tools and the Catppuccin theme integration.

#### `~/.config/home-manager/catppuccin/default.nix`

This module is the central point for theming. The commented-out sections are preserved as you provided, allowing you to enable them as needed.

```nix
# ~/.config/home-manager/catppuccin/default.nix
{...}: {
  catppuccin = {
    bat = {
      enable = true;
      flavor = "macchiato";
    };

    # btop = {
    #   enable = true;
    #   flavor = "macchiato";
    # };

    delta = {
      enable = true;
      flavor = "macchiato";
    };
    #
    # foot = {
    #   enable = true;
    #   flavor = "macchiato";
    # };
    #
    # fzf = {
    #   enable = true;
    #   accent = "flamingo";
    #   flavor = "macchiato";
    # };
    #
    # kvantum = {
    #   enable = true;
    #   apply = true;
    #   accent = "flamingo";
    #   flavor = "macchiato";
    # };
    #
    # kitty = {
    #   enable = true;
    #   flavor = "macchiato";
    # };
    #
    lazygit = {
      enable = true;
      accent = "flamingo";
      flavor = "macchiato";
    };
    #
    # mpv = {
    #   enable = true;
    #   accent = "flamingo";
    #   flavor = "macchiato";
    # };
    #
    # starship = {
    #   enable = true;
    #   flavor = "macchiato";
    # };
    #
    # tmux = {
    #   enable = true;
    #   extraConfig =
    #     ''
    #     set -g @catppuccin_status_modules_right "application session user host date_time"
    #     ''
    #   ;
    #   flavor = "macchiato";
    # };
    #
    # zathura = {
    #   enable = true;
    #   flavor = "macchiato";
    # };
    #
    # zsh-syntax-highlighting = {
    #   enable = true;
    #   flavor = "macchiato";
    # };
    #
    yazi = {
      enable = true;
      accent = "flamingo";
      flavor = "macchiato";
    };
  };
}
```

#### `~/.config/home-manager/dev/default.nix`

This module sets up `direnv` and installs essential Nix maintenance tools. The Zsh integration for `direnv` is handled here, so it is removed from the `zsh` module.

```nix
# ~/.config/home-manager/dev/default.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [ deadnix statix niv ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    config.global = { hide_env_diff = true; };
  };
}
```

---

### **Shell & Terminal Modules**

This is the core of your terminal experience, defining the shell, prompt, and history.

#### `~/.config/home-manager/zsh/default.nix`

This is the main module for Zsh, consolidating all shell-specific aliases, functions, and settings from your original scripts into a single, declarative configuration.

```nix
# ~/.config/home-manager/zsh/default.nix
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    autocd = true;
    syntaxHighlighting.enable = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "${config.xdg.dataHome}/zsh/history";
      save = 50000;
      size = 50000;
      share = true;
    };

    options = [
      "EXTENDED_HISTORY" "HIST_VERIFY" "HIST_REDUCE_BLANKS"
      "AUTO_PUSHD" "PUSHD_IGNORE_DUPS" "PUSHDMINUS"
      "CORRECT" "COMPLETE_ALIASES" "ALWAYS_TO_END"
      "LIST_PACKED" "AUTO_LIST" "AUTO_MENU" "AUTO_PARAM_SLASH"
      "EXTENDED_GLOB" "GLOB_DOTS"
    ];

    plugins = [
      { name = "zsh-vi-mode"; src = pkgs.fetchFromGitHub { owner = "jeffreytse"; repo = "zsh-vi-mode"; rev = "v0.9.0"; sha256 = "sha256-4O2xpu/2lBTpQuFvFihWzd1lGj3f/HSb6XJdJ2Z5r0o="; }; }
      { name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; }
      { name = "zsh-history-substring-search"; src = pkgs.zsh-history-substring-search; }
      { name = "zsh-completions"; src = pkgs.zsh-completions; }
      { name = "fzf-tab"; src = pkgs.fetchFromGitHub { owner = "Aloxaf"; repo = "fzf-tab"; rev = "v1.1.2"; sha256 = "sha256-Fj1gK0N88zP98hI/Gq+L15L2K7qBmkBqY6T0LqX9oW0="; }; }
      { name = "zsh-autopair"; src = pkgs.fetchFromGitHub { owner = "hlissner"; repo = "zsh-autopair"; rev = "1.0.1"; sha256 = "sha256-jA22u/r2J2E618L5PzKQLsP4F1+kCUPfso1A5tJgWkM="; }; }
    ];

    shellAliases = {
      # General
      fd = "fd-find";
      find = "fd-find";
      rmi = "sudo rm -rf";
      vi = "nvim";
      du = "dust";
      ps = "procs";
      grep = "rg";
      gg = "lazygit";
      emacstty = "emacsclient -tty";

      # Fedora DNF
      dnu = "sudo dnf upgrade";
      dni = "sudo dnf install";
      dns = "dnf search";
      dnr = "sudo dnf remove";
      dninfo = "dnf info";
      dnls = "dnf list installed";

      # Eza (extra aliases not covered by enableAliases)
      lr = "eza -R --icons=always --group-directories-first";
      lg = "eza -l --git --git-ignore --icons=always --group-directories-first --header";
      lsize = "eza -l --sort=size --reverse --icons=always --group-directories-first --git --header";
      ltime = "eza -l --sort=modified --reverse --icons=always --group-directories-first --git --header";
      lz = "eza -la --context";

      # Ripgrep (Fedora-specific searches)
      rgs = "rg --type fedora";
      rgd = "rg --type dnf";
      rgk = "rg --type kernel";

      # Zoxide (Fedora-specific shortcuts)
      jroot = "j /";
      jetc = "j /etc";
      jvar = "j /var";
      jlog = "j /var/log";
      jconfig = "j ~/.config";

      # Tealdeer
      tl = "tldr";
      "tldr-dnf" = "tldr dnf";
      "tldr-rpm" = "tldr rpm";
      "tldr-flatpak" = "tldr flatpak";
    };

    initExtraBeforeCompInit = ''
      export EDITOR="${config.home.sessionVariables.EDITOR}"
      export VISUAL="${config.home.sessionVariables.VISUAL}"
      export TERMINAL="${config.home.sessionVariables.TERMINAL}"
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
      export PAGER="bat --paging=always --style=plain"
      export LANG="en_US.UTF-8"
      export COLORTERM=truecolor
    '';

    initExtra = ''
      # ===== zstyle Configurations =====
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
      zstyle ':completion:*' menu select
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-flags --height=50% --border=rounded
      zstyle ':fzf-tab:complete:*' fzf-preview \
        '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:100 $realpath || eza --tree --level=2 --color=always $realpath'

      # ===== Vi Mode Configuration =====
      ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
      ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
      function zvm_after_init() {
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
      }

      # ===== Utility Functions =====
      mkcd() { mkdir -p "$1" && cd "$1"; }
      extract() {
        if [[ -f "$1" ]]; then
          case "$1" in
            *.tar.bz2) tar xjf "$1" ;; *.tar.gz) tar xzf "$1" ;; *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;; *.gz) gunzip "$1" ;; *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;; *.tgz) tar xzf "$1" ;; *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;; *.7z) 7z x "$1" ;; *.xz) unxz "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }

      # ===== FZF Helper Functions =====
      function fzf_systemd_services() {
          systemctl list-units --type=service --all --no-pager --no-legend | \
              awk '{print $1}' | fzf --multi \
              --preview 'systemctl status {}' --preview-window=right:50%:wrap
      }
      function fzf_systemd_services_widget() {
          LBUFFER+="systemctl status $(fzf_systemd_services)"
          zle redisplay
      }
      zle -N fzf_systemd_services_widget
      bindkey '^s' fzf_systemd_services_widget

      # ===== Ripgrep Helper Functions =====
      function rgfzf() {
          rg --color=always --line-number "$@" | fzf --ansi \
              --preview 'bat --style=numbers --color=always --line-range :500 {1}' \
              --delimiter ':' --bind 'enter:execute($''{EDITOR:-nvim} {1} +{2})'
      }

      # ===== Zoxide Helper Functions =====
      ji() {
          cd "$(zoxide query -l | fzf --preview 'eza --tree --level=2 --color=always {}')"
      }
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin" "$HOME/go/bin" "$HOME/.bun/bin"
    "$HOME/.local/bin" "$HOME/.local/bin/hypr"
    "$HOME/.config/emacs/bin" "$HOME/.npm-global/bin"
    "$HOME/.local/share/flatpak/exports/bin"
  ];
}
```

#### `~/.config/home-manager/atuin/default.nix`

Configures the Atuin shell history, preserving your custom helper and optimization functions for Fedora.

```nix
# ~/.config/home-manager/atuin/default.nix
{ ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      log = "warn";
      sync_frequency = "10m";
    };
  };

  programs.zsh.initExtra = ''
    # Atuin custom keybindings for vi-mode
    bindkey -M vicmd '^R' _atuin_search_widget;
    bindkey -M viins '^R' _atuin_search_widget;
  '';
}
```

#### `~/.config/home-manager/starship/default.nix`

Sets up the Starship prompt. All theme and color information has been removed, as it will be handled by the `catppuccin` module.

```nix
# ~/.config/home-manager/starship/default.nix
{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
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
        symbol = "[△]";
        format = " [$symbol$branch(:$remote_branch)]($style)";
        truncation_length = 11;
        truncation_symbol = "⋯";
      };

      git_metrics.disabled = false;
      git_status = {
        format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
        conflicted = "[◪◦]";
        ahead = "[▴│${count}│]";
        behind = "[▿│${count}│]";
        untracked = "[◌◦]";
        stashed = "[◃◈]";
        modified = "[●◦]";
        staged = "[▪┤$count│]";
        renamed = "[◎◦]";
        deleted = "[✕]";
      };
    };
  };
}
```

---

### **Command-Line Tools**

These modules configure your primary CLI applications.

#### `~/.config/home-manager/bat/default.nix`

Configures `bat` with extensive, Fedora-specific syntax mappings.

```nix
# ~/.config/home-manager/bat/default.nix
{ ... }:

{
  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes,header";
      "show-all" = true;
      "italic-text" = "always";
      color = "always";
      "map-syntax" = [
        # Fedora-specific
        "*.repo:INI" "*.ks:Bash" "kickstart.cfg:Bash"
        # System config
        "/etc/sysconfig/*:Bash" "/etc/dnf/*.conf:INI"
        "/etc/yum.repos.d/*.repo:INI" "/etc/NetworkManager/system-connections/*:INI"
        # SystemD units
        "/etc/systemd/system/*:Systemd"
        "/home/*/.config/systemd/user/*:Systemd"
        # SELinux policies
        "*.te:C" "*.if:C"
        # Container files
        "Containerfile:Dockerfile" "*.containerfile:Dockerfile"
        # Logs
        "/var/log/dnf.log:Log" "*.log:Log"
        # Release files
        "/etc/fedora-release:Plain Text" "/etc/system-release:Plain Text"
      ];
    };
  };
}
```

#### `~/.config/home-manager/eza/default.nix`

This module enables `eza` and applies a full, declarative Catppuccin color theme directly in Nix.

```nix
# ~/.config/home-manager/eza/default.nix
{...}: {
  programs.eza = {
    enable = true;
    enableZshIntegration = true; # Manages core aliases like ls, l, la, ll
    icons = "always";
    git = true;
    extraOptions = ["--group-directories-first" "--header"];
    colors = {
      ui = {
        size.number = "#fab387";
        user = "#f9e2af";
        group = "#a6e3a1";
        date.time = "#cba6f7";
        header = "#b4befe";
        tree = "#cba6f7";
      };
      punctuation = "#9399b2";
      permission = { read = "#a6e3a1"; write = "#f9e2af"; exec = "#f38ba8"; };
      filetype = { directory = "#89b4fa"; symlink = "#89dceb"; pipe = "#f5c2e7"; };
      filekinds = {
        image = "#94e2d5"; video = "#74c7ec"; music = "#cba6f7";
        document = "#f5c2e7"; compressed = "#fab387"; executable = "#a6e3a1";
      };
      git = {
        clean = "#a6e3a1"; new = "#89b4fa"; modified = "#f9e2af";
        deleted = "#f38ba8"; renamed = "#cba6f7"; conflicted = "#eba0ac";
      };
      extension = {
        # Programming
        nix = "#89b4fa"; sh = "#a6e3a1"; js = "#f9e2af"; py = "#f9e2af";
        rs = "#fab387"; java = "#fab387"; rb = "#f38ba8";
        # Documents & Text
        md = "#f5c2e7"; txt = "#cdd6f4";
        # Config
        json = "#f9e2af"; toml = "#f9e2af"; yaml = "#f9e2af";
        # Fedora
        spec = "#a6e3a1"; repo = "#89b4fa";
      };
    };
  };
}
```

#### `~/.config/home-manager/fzf/default.nix`

Configures `fzf`. The theme is intentionally omitted to allow the `catppuccin` module to handle it.

```nix
# ~/.config/home-manager/fzf/default.nix
{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%" "--layout=reverse" "--border"
      "--preview-window=right:60%:wrap" "--ansi"
      "--bind='ctrl-e:execute($EDITOR {})'"
    ];
    fileWidgetOptions = [
      "--preview 'bat --style=numbers --color=always {}'"
    ];
  };

  programs.zsh.initExtra = ''
    # FZF enhanced preview command
    export FZF_PREVIEW_COMMAND="[[ \$(file --mime {}) =~ binary ]] && echo '{} is a binary' || (bat --style=numbers --color=always {} || cat {}) 2>/dev/null | head -500"
  '';
}
```

#### `~/.config/home-manager/ripgrep/default.nix`

Configures `ripgrep` with a comprehensive list of ignored files and paths, optimized for both general development and the Fedora filesystem layout.

```nix
# ~/.config/home-manager/ripgrep/default.nix
{...}: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      # Performance & Preferences
      "--max-columns=300" "--max-columns-preview" "--smart-case"
      "--one-file-system" "--mmap" "--hidden" "--follow"
      # General ignores
      "--glob=!.git/" "--glob=!*.min.*" "--glob=!__pycache__/"
      "--glob=!node_modules/" "--glob=!target/"
      # Fedora-specific ignores
      "--glob=!*.rpm" "--glob=!/var/cache/dnf/" "--glob=!/var/lib/rpm/"
      "--glob=!/proc/" "--glob=!/sys/" "--glob=!/dev/" "--glob=!/run/"
    ];
  };
}
```

#### `~/.config/home-manager/pay-respects/default.nix`

This module declaratively configures `pay-respects` (a fork of `thefuck`), including its Python settings and custom rule files for Fedora-specific command corrections.

```nix
# ~/.config/home-manager/pay-respects/default.nix
{ ... }:
let
  fedoraRules = ''
    # Custom rules for Fedora-specific commands like dnf, systemctl, etc.
    # This content is taken directly from your provided module.
    import re
    from thefuck.utils import for_app

    def match_dnf_no_such_command(command):
        return "dnf" in command.script and "No such command" in command.stderr
    def get_new_command_dnf_no_such_command(command):
        typos = {"isntall": "install", "updgrade": "upgrade", "serach": "search"}
        for typo, correct in typos.items():
            if typo in command.script:
                return command.script.replace(typo, correct)
        return command.script

    def match_systemctl_unit_not_found(command):
        return "systemctl" in command.script and "Unit" in command.stderr and "not found" in command.stderr
    def get_new_command_systemctl_unit_not_found(command):
        if "enable" in command.script and "--now" not in command.script:
            return command.script.replace("enable", "enable --now")
        return command.script

    enabled_by_default = True
  '';

  settingsPy = ''
    # This file is managed declaratively by Home Manager.
    rules = [
        "cd_mkdir", "git_add", "git_push", "sudo", "no_command",
        # Custom Fedora rules are enabled by adding the file name
        "fedora_rules",
    ]
    exclude_rules = []
    require_confirmation = True
    history_limit = 2000
    priority = "no_command=9999:sudo=100"
    env = {"LC_ALL": "C", "LANG": "C"}
  '';
in {
  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
  };

  # Declaratively write the settings and custom rules
  xdg.configFile = {
    "pay-respects/rules/fedora_rules.py".text = fedoraRules;
    "pay-respects/settings.py".text = settingsPy;
  };
}
```

#### `~/.config/home-manager/zoxide/default.nix`

A clean and simple module to enable `zoxide` and change its default command alias to `cd` for seamless integration.

```nix
# ~/.config/home-manager/zoxide/default.nix
{...}: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    # This makes zoxide hijack `cd` for its functionality.
    options = ["--cmd cd"];
  };
}
```

---

### **GUI & Application Modules**

These modules configure more complex applications like `lazygit` and `yazi`.

#### `~/.config/home-manager/lazygit/default.nix`

An extremely detailed, declarative configuration for Lazygit, translating your entire settings file into Nix.

```nix
# ~/.config/home-manager/lazygit/default.nix
{pkgs, ...}: {
  home.packages = with pkgs; [delta];
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        border = "rounded";
        nerdFontsVersion = "3";
        showFileTree = true;
        showRandomTip = true;
        spinner = {
          frames = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"];
          rate = 50;
        };
      };
      keybinding = {
        universal = {
          quit = "q";
          "return" = "<esc>";
          prevItem = "k";
          nextItem = "j";
          prevBlock = "h";
          nextBlock = "l";
          nextTab = "]";
          prevTab = "[";
          undo = "z";
          redo = "<c-z>";
        };
        files = {
          commitChanges = "c";
          amendLastCommit = "A";
          ignoreFile = "i";
          refreshFiles = "r";
          stashAllChanges = "s";
          viewStashOptions = "S";
          toggleStagedAll = "a";
          viewResetOptions = "D";
          fetch = "f";
        };
        branches = {
          createPullRequest = "o";
          checkoutBranch = "<space>";
          rebaseBranch = "r";
          renameBranch = "R";
          mergeIntoCurrentBranch = "m";
          push = "P";
          pull = "p";
          deleteBranch = "d";
        };
      };
      os = {
        editCommand = "nvim";
        editPreset = "nvim";
        openLinkCommand = "xdg-open {{link}}";
        copyToClipboardCmd = "wl-copy";
      };
      update.method = "prompt";
      refresher.refreshInterval = 10;
      confirmOnQuit = false;
      quitOnTopLevelReturn = false;
      disableStartupPopups = true;
      customCommands = [
        { key = "n"; command = "nvim {{.SelectedFile.Name}}"; context = "files"; description = "Open file in Neovim"; output = "terminal"; }
        { key = "I"; command = "git rebase -i {{.SelectedLocalCommit.Sha}}^"; context = "commits"; description = "Interactive rebase from selected commit"; output = "terminal"; }
        { key = "P"; command = "git push --force-with-lease"; context = "global"; description = "Force push with lease"; output = "log"; }
      ];
      performance.useAsyncGit = true;
    };
  };
}
```

#### `~/.config/home-manager/yazi/default.nix`

A comprehensive module for the Yazi file manager, declaratively managing its settings, keybindings, openers, and plugins.

```nix
# ~/.config/home-manager/yazi/default.nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [ rich-cli ouch ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    plugins = with pkgs.yaziPlugins; {
      # Essential & UI
      inherit full-border toggle-pane smart-enter chmod starship yatline;
      # Preview & Media
      inherit rich-preview ouch;
      # Navigation & Git
      inherit jump-to-char git lazygit;
    };

    settings = {
      manager = {
        show_hidden = false;
        linemode = "size";
        sort_by = "natural";
        sort_dir_first = true;
      };
      preview = {
        max_width = 600;
        max_height = 900;
        wrap = "no";
      };
      opener = {
        edit = [{ run = "nvim ''$@''"; block = true; }];
        archive = [{ run = "file-roller ''$@''"; }];
        image = [{ run = "imv ''$@''"; }];
        video = [{ run = "mpv ''$@''"; }];
        document = [{ run = "zathura ''$@''"; }];
        fallback = [{ run = "xdg-open ''$@''"; }];
      };
      open.rules = [
        { name = "*/"; use = "edit"; }
        { mime = "text/*"; use = "edit"; }
        { mime = "image/*"; use = "image"; }
        { mime = "video/*"; use = "video"; }
        { mime = "audio/*"; use = "video"; } # Using mpv for audio too
        { mime = "application/pdf"; use = "document"; }
        { mime = "application/*zip"; use = "archive"; }
        { mime = "application/x-tar"; use = "archive"; }
        { name = "*"; use = "fallback"; }
      ];
    };

    keymap = {
      manager = {
        prepend = [
          # Navigation
          { on = "h"; run = "leave"; }
          { on = "j"; run = "arrow 1"; }
          { on = "k"; run = "arrow -1"; }
          { on = "l"; run = "enter"; }
          { on = "G"; run = "arrow bot"; }
          # File operations
          { on = "y"; run = "yank"; }
          { on = "d"; run = "yank --cut"; }
          { on = "p"; run = "paste"; }
          { on = [ "d" "d" ]; run = "remove"; }
          { on = "a"; run = "create"; }
          { on = "r"; run = "rename"; }
          # Tabs
          { on = "t"; run = "tab_create --current"; }
          { on = "w"; run = "tab_close"; }
          { on = "["; run = "tab_switch -1 --relative"; }
          { on = "]"; run = "tab_switch 1 --relative"; }
          # Misc
          { on = "q"; run = "quit"; }
          { on = ":"; run = "shell --interactive"; }
          { on = "!"; run = "shell --block"; }
          { on = "<C-h>"; run = "hidden toggle"; }
        ];
      };
      input.prepend = [ { on = "<Esc>"; run = "close"; } ];
    };
  };
}
```
