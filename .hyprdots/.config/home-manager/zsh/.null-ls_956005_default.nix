
{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    #dotDir = ".config/zsh";
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
      zstyle ': completion:*' list-colors "${lib.strings.dollar}{(s.:.)LS_COLORS}"
        zstyle ': completion:*:*:*:*:descriptions' format '%F { blue }-- %d --%f'
        zstyle ': completion:*' matcher-list 'm: { a-zA-Z }={A-Za-z}' 'r: |[ ._- ]=* r:|=*' 'l:|=* r:|=*'
    zstyle ':completion:*' rehash true

    # ===== fzf-tab configuration =====
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
    if [[ -f "$1" ]];
    then
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

    '';
  };
}
