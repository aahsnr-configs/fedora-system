{ config, pkgs, lib, ... }:

{
  # Enable zsh as the default shell
  programs.zsh = {
    enable = true;
    
    # Set the default shell for the user
    defaultKeymap = "viins";
    
    # History configuration
    history = {
      size = 50000;
      save = 50000;
      path = "${config.home.homeDirectory}/.local/share/zsh/history";
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    
    # ZSH options
    setopt = [
      "AUTO_CD"
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
      "HIST_EXPIRE_DUPS_FIRST"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "HIST_VERIFY"
      "SHARE_HISTORY"
      "HIST_REDUCE_BLANKS"
    ];
    
    # Enable completions
    enableCompletion = true;
    
    # Completion configuration with Catppuccin Mocha theming
    completionInit = ''
      # Load completions
      autoload -Uz compinit
      compinit -u -d "${config.home.homeDirectory}/.cache/zsh/zcompdump-$ZSH_VERSION"
      
      # Completion caching
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "${config.home.homeDirectory}/.cache/zsh/zcompcache"
      
      # Completion configuration with Catppuccin Mocha colors
      zstyle ':completion:*' completer _extensions _complete _approximate
      zstyle ':completion:*' menu select
      zstyle ':completion:*' group-name 
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:*:*:*:descriptions' format '%F{#89b4fa}── %d ──%f'
      zstyle ':completion:*:*:*:*:corrections' format '%F{#f38ba8}!- %d (errors: %e) -!%f'
      zstyle ':completion:*:messages' format '%F{#fab387}-- %d --%f'
      zstyle ':completion:*:warnings' format '%F{#f38ba8}-- no matches found --%f'
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' rehash true
      
      # Catppuccin Mocha menu colors
      zstyle ':completion:*:*:*:*:default' list-colors \
        "di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"
      
      # Special completion styling
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01;31'
      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
      
      # Directory completion colors
      zstyle ':completion:*:*:cd:*:directory-stack' list-colors '=*=32;33'
    '';
    
    # Plugins configuration
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.fetchFromGitHub {
          owner = "jeffreytse";
          repo = "zsh-vi-mode";
          rev = "v0.11.0";
          sha256 = "sha256-xbchXJTFWeABTwq6h4KWLh+EvydDrDzcY9AQVK65RS8=";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "v1.1.0";
          sha256 = "sha256-+P5XLNLuEQzfKKjkTHdOhO3kFQqiCGXSXSzh5JRcQks=";
        };
      }
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.35.0";
          sha256 = "sha256-GFHlZjIHUWwyeVoCpszgn4AmLPSSE8UVNfRmisnhkpg=";
        };
      }
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.1.2";
          sha256 = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
        };
      }
      {
        name = "zsh-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
          sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          sha256 = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6FiAY8XQElkvUjZV0=";
        };
      }
    ];
    
    # Session variables with Catppuccin Mocha theming
    sessionVariables = {
      # Autosuggestions theming
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#6c7086,italic";
      ZSH_AUTOSUGGEST_STRATEGY = "history completion";
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
      ZSH_AUTOSUGGEST_USE_ASYNC = "true";
      
      # History substring search theming
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND = "bg=#313244,fg=#89b4fa,bold";
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND = "bg=#313244,fg=#f38ba8,bold";
      HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS = "i";
      
      # Less theming
      LESS_TERMCAP_mb = "\\e[1;32m";
      LESS_TERMCAP_md = "\\e[1;32m";
      LESS_TERMCAP_me = "\\e[0m";
      LESS_TERMCAP_se = "\\e[0m";
      LESS_TERMCAP_so = "\\e[01;33m";
      LESS_TERMCAP_ue = "\\e[0m";
      LESS_TERMCAP_us = "\\e[1;4;31m";
      
      # FZF theming
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8";
      
      # Grep colors
      GREP_COLOR = "1;33";
      GREP_COLORS = "ms=1;33:mc=1;33:sl=:cx=:fn=1;32:ln=1;36:bn=1;36:se=1;30";
    };
    
    # Shell aliases - basic ones, others should be in separate modules
    shellAliases = {
      vi = "nvim";
      e = "exit";
      md = "mkdir -p";
      rd = "rmdir";
      
      # Fedora package management
      dnfi = "sudo dnf install";
      dnfu = "sudo dnf update";
      dnfs = "dnf search";
      dnfr = "sudo dnf remove";
      dnfq = "dnf info";
      dnfl = "dnf list";
      dnfh = "dnf history";
      
      # Systemd
      sctl = "systemctl";
      sctle = "sudo systemctl enable";
      sctld = "sudo systemctl disable";
      sctls = "sudo systemctl start";
      sctlr = "sudo systemctl restart";
      sctlS = "sudo systemctl stop";
      sctlq = "systemctl status";
      
      # Flatpak
      fp = "flatpak";
      fpi = "flatpak install";
      fpu = "flatpak update";
      fpr = "flatpak uninstall";
      fps = "flatpak search";
      fpl = "flatpak list";
      
      # Colorful system monitoring
      htop = "htop --color";
      df = "df -h";
      du = "du -h";
      free = "free -h";
      ps = "ps aux";
      
      # Network
      ping = "ping -c 5";
      wget = "wget -c";
      curl = "curl -w '\\n'";
    };
    
    # Local variables with Catppuccin Mocha theming
    localVariables = {
      # zsh-vi-mode configuration
      ZVM_VI_INSERT_ESCAPE_BINDKEY = "jk";
      ZVM_LINE_INIT_MODE = "$ZVM_MODE_INSERT";
      ZVM_VI_HIGHLIGHT_BACKGROUND = "#313244";
      ZVM_VI_HIGHLIGHT_FOREGROUND = "#cdd6f4";
      ZVM_VI_SURROUND_BINDKEY = "s";
      ZVM_VI_EDITOR = "nvim";
      
      # Prompt colors
      PROMPT_COLOR_USER = "#89b4fa";
      PROMPT_COLOR_HOST = "#a6e3a1";
      PROMPT_COLOR_PATH = "#fab387";
      PROMPT_COLOR_GIT = "#f5c2e7";
      PROMPT_COLOR_ERROR = "#f38ba8";
      PROMPT_COLOR_SUCCESS = "#a6e3a1";
    };
    
    # Init extra - additional configuration
    initExtra = ''
      # Create necessary directories
      mkdir -p "${config.home.homeDirectory}/.cache/zsh"
      mkdir -p "${config.home.homeDirectory}/.local/share/zsh"
      mkdir -p "${config.home.homeDirectory}/.config/zsh"
      
      # Catppuccin Mocha LS_COLORS
      export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"
      
      # Zsh syntax highlighting with Catppuccin Mocha colors
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
      ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
      ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7,bold'
      ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a6e3a1'
      ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a6e3a1'
      ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
      ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7'
      ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#fab387,italic'
      ZSH_HIGHLIGHT_STYLES[path]='fg=#89b4fa'
      ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#f5c2e7'
      ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#f5c2e7'
      ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'
      ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#cba6f7'
      ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#94e2d5'
      ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#f5c2e7'
      ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=#94e2d5'
      ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#f5c2e7'
      ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fab387'
      ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fab387'
      ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#cba6f7'
      ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#f5c2e7'
      ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
      ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
      ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'
      ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#a6e3a1'
      ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#94e2d5'
      ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#94e2d5'
      ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#94e2d5'
      ZSH_HIGHLIGHT_STYLES[assign]='fg=#f9e2af'
      ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7,bold'
      ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'
      ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#f9e2af'
      ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#f9e2af'
      ZSH_HIGHLIGHT_STYLES[arg0]='fg=#89b4fa'
      ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#f38ba8,bold'
      ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#89b4fa'
      ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#a6e3a1'
      ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#f5c2e7'
      ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#fab387'
      ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=#cba6f7'
      ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='fg=#1e1e2e,bg=#89b4fa'
      
      # Fast syntax highlighting theme
      FAST_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
      FAST_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
      FAST_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7,bold'
      FAST_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa'
      FAST_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
      FAST_HIGHLIGHT_STYLES[command]='fg=#89b4fa'
      FAST_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
      FAST_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7'
      FAST_HIGHLIGHT_STYLES[hashed-command]='fg=#89b4fa'
      FAST_HIGHLIGHT_STYLES[path]='fg=#fab387'
      FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=#89b4fa,underline'
      FAST_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'
      FAST_HIGHLIGHT_STYLES[history-expansion]='fg=#cba6f7'
      FAST_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fab387'
      FAST_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fab387'
      FAST_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#cba6f7'
      FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
      FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
      FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'
      FAST_HIGHLIGHT_STYLES[back-or-dollar-double-quoted-argument]='fg=#94e2d5'
      FAST_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#94e2d5'
      FAST_HIGHLIGHT_STYLES[assign]='fg=#f9e2af'
      FAST_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7,bold'
      FAST_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'
      FAST_HIGHLIGHT_STYLES[variable]='fg=#94e2d5'
      FAST_HIGHLIGHT_STYLES[mathvar]='fg=#94e2d5'
      FAST_HIGHLIGHT_STYLES[mathnum]='fg=#fab387'
      FAST_HIGHLIGHT_STYLES[matherr]='fg=#f38ba8'
      FAST_HIGHLIGHT_STYLES[assign-array-bracket]='fg=#f5c2e7'
      FAST_HIGHLIGHT_STYLES[for-loop-variable]='fg=#94e2d5'
      FAST_HIGHLIGHT_STYLES[for-loop-number]='fg=#fab387'
      FAST_HIGHLIGHT_STYLES[for-loop-operator]='fg=#f5c2e7'
      FAST_HIGHLIGHT_STYLES[for-loop-separator]='fg=#f5c2e7'
      FAST_HIGHLIGHT_STYLES[exec-descriptor]='fg=#f9e2af'
      FAST_HIGHLIGHT_STYLES[here-string-tri]='fg=#f9e2af'
      FAST_HIGHLIGHT_STYLES[here-string-text]='fg=#a6e3a1'
      FAST_HIGHLIGHT_STYLES[here-string-var]='fg=#94e2d5'
      FAST_HIGHLIGHT_STYLES[secondary]='fg=#bac2de'
      FAST_HIGHLIGHT_STYLES[case-input]='fg=#94e2d5'
      FAST_HIGHLIGHT_STYLES[case-parentheses]='fg=#f5c2e7'
      FAST_HIGHLIGHT_STYLES[case-condition]='fg=#a6e3a1'
      
      # Custom prompt with Catppuccin Mocha colors
      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ':vcs_info:git:*' formats '%F{#f5c2e7}(%b)%f'
      zstyle ':vcs_info:*' enable git
      
      setopt PROMPT_SUBST
      PROMPT='%F{#89b4fa}%n%f@%F{#a6e3a1}%m%f:%F{#fab387}%~%f ''${vcs_info_msg_0_} %(?:%F{#a6e3a1}➜%f:%F{#f38ba8}➜%f) '
      
      # Right prompt with time and exit code
      RPROMPT='%(?..%F{#f38ba8}[%?]%f )%F{#6c7086}%T%f'
      
      # Source additional module files
      for config_file in "${config.home.homeDirectory}/.config/zsh"/*.zsh; do
        [[ -r "$config_file" ]] && source "$config_file"
      done
      
      # Source cargo environment
      [[ -f "${config.home.homeDirectory}/.cargo/env" ]] && source "${config.home.homeDirectory}/.cargo/env"
      
      # Source FZF configuration
      [[ -f "${config.home.homeDirectory}/.config/fzf/fzf.fedora" ]] && source "${config.home.homeDirectory}/.config/fzf/fzf.fedora"
      
      # Configure vi mode after initialization
      function zvm_after_init() {
        # History substring search bindings
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
        
        # Enhanced vi bindings
        bindkey -M vicmd 'H' beginning-of-line
        bindkey -M vicmd 'L' end-of-line
        bindkey -M vicmd 'u' undo
        bindkey -M vicmd '^R' redo
        
        # Fix common keys in insert mode
        bindkey -M viins "^?" backward-delete-char
        bindkey -M viins "^W" backward-kill-word
        bindkey -M viins "^U" backward-kill-line
        bindkey -M viins "^A" beginning-of-line
        bindkey -M viins "^E" end-of-line
        bindkey -M viins "^K" kill-line
        bindkey -M viins "^Y" yank
        
        # Enable FZF bindings after zsh-vi-mode
        if [[ -f /usr/share/fzf/shell/key-bindings.zsh ]]; then
          source /usr/share/fzf/shell/key-bindings.zsh
        fi
        
        # Custom FZF key bindings with Catppuccin colors
        bindkey -M viins '^T' fzf-file-widget
        bindkey -M viins '^R' fzf-history-widget
        bindkey -M viins '\ec' fzf-cd-widget
        bindkey -M vicmd '^T' fzf-file-widget
        bindkey -M vicmd '^R' fzf-history-widget
        bindkey -M vicmd '\ec' fzf-cd-widget
      }
      
      # fzf-tab configuration with Catppuccin Mocha theming
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-flags \
        --height=60% \
        --layout=reverse \
        --border=rounded \
        --margin=1,2 \
        --padding=1 \
        --info=inline \
        --prompt='❯ ' \
        --pointer='▶' \
        --marker='✓' \
        --color=bg+:#313244,bg:#1e1e2e,border:#89b4fa,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#a6e3a1,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
        --color=selected-bg:#45475a,selected-fg:#cdd6f4
      
      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
      zstyle ':fzf-tab:*' accept-line enter
      zstyle ':fzf-tab:*' continuous-trigger 'right'
      
      # Add preview for files and directories with enhanced theming
      zstyle ':fzf-tab:complete:*' fzf-preview \
        'if [[ -f $realpath ]]; then
          if command -v bat >/dev/null 2>&1; then
            bat --color=always --style=numbers,changes --line-range=:100 --theme="Catppuccin Mocha" "$realpath" 2>/dev/null
          elif command -v highlight >/dev/null 2>&1; then
            highlight -O ansi -l "$realpath" 2>/dev/null
          else
            cat "$realpath" 2>/dev/null | head -100
          fi
        elif [[ -d $realpath ]]; then
          if command -v eza >/dev/null 2>&1; then
            eza --tree --level=2 --color=always --icons --git "$realpath" 2>/dev/null
          elif command -v tree >/dev/null 2>&1; then
            tree -C -L 2 "$realpath" 2>/dev/null
          else
            ls -la --color=always "$realpath" 2>/dev/null
          fi
        else
          echo "📁 Directory or 📄 File preview not available"
        fi'
      
      # Enhanced preview for different command types
      zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
      zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
      zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always $word'
      zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always --oneline --graph --decorate $word'
      zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $word'
      zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always --oneline --graph --decorate $word'
      
      # Process completion with colors
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o pid,ppid,user,comm,cmd --no-headers --color=always'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
      
      # Package management previews
      zstyle ':fzf-tab:complete:dnf:*' fzf-preview 'dnf info $word 2>/dev/null || echo "Package information not available"'
      zstyle ':fzf-tab:complete:flatpak:*' fzf-preview 'flatpak info $word 2>/dev/null || echo "Flatpak information not available"'
      
      # Man page previews
      zstyle ':fzf-tab:complete:man:*' fzf-preview 'man $word | col -bx | bat --color=always --language=man --style=grid'
      
      # Utility Functions with enhanced error handling and theming
      mkcd() {
        if [[ -z "$1" ]]; then
          echo "Usage: mkcd <directory>"
          return 1
        fi
        mkdir -p "$1" && cd "$1"
        echo "📁 Created and entered directory: $1"
      }
      
      # Enhanced extract function with progress indication
      extract() {
        if [[ -f "$1" ]]; then
          echo "🔧 Extracting $1..."
          case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
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
            *.deb)       ar x "$1"        ;;
            *.rpm)       rpm2cpio "$1" | cpio -idmv ;;
            *)           echo "❌ '$1' cannot be extracted via extract()" ;;
          esac
          echo "✅ Extraction complete!"
        else
          echo "❌ '$1' is not a valid file"
          return 1
        fi
      }
      
      # Enhanced DNF helper functions with colored output
      dnf-installed() { 
        if [[ -z "$1" ]]; then
          echo "Usage: dnf-installed <package-name>"
          return 1
        fi
        dnf list installed | grep -i --color=always "$1"
      }
      
      dnf-available() { 
        if [[ -z "$1" ]]; then
          echo "Usage: dnf-available <package-name>"
          return 1
        fi
        dnf list available | grep -i --color=always "$1"
      }
      
      dnf-info() { 
        if [[ -z "$1" ]]; then
          echo "Usage: dnf-info <package-name>"
          return 1
        fi
        dnf info "$1" 2>/dev/null || echo "Package '$1' not found"
      }
      
      # Git utilities with enhanced theming
      git-pretty-log() {
        git log --graph --pretty=format:'%C(#f38ba8)%h%C(reset) -%C(#89b4fa)%d%C(reset) %C(#cdd6f4)%s%C(reset) %C(#6c7086)(%cr) <%an>%C(reset)' --abbrev-commit "${@}"
      }
      
      git-branch-clean() {
        echo "🧹 Cleaning up merged branches..."
        git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
        echo "✅ Cleanup complete!"
      }
      

      # Weather function (requires curl)
      weather() {
        local location="${1:-}"
        if command -v curl >/dev/null 2>&1; then
          if [[ -n "$location" ]]; then
            curl -s "wttr.in/$location?format=3"
          else
            curl -s "wttr.in/?format=3"
          fi
        else
          echo "❌ curl is required for weather information"
        fi
      }
      
      # Quick file search with FZF
      ff() {
        local file
        file=$(find . -type f -not -path '*/\.git/*' | fzf --preview 'bat --color=always --style=numbers --line-range=:100 {}' --height=60% --border=rounded)
        [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
      }
      
      # Quick directory navigation with FZF
      fd() {
        local dir
        dir=$(find . -type d -not -path '*/\.git/*' | fzf --preview 'eza --tree --level=2 --color=always --icons {}' --height=60% --border=rounded)
        [[ -n "$dir" ]] && cd "$dir"
      }
      
      # Process killer with FZF
      fkill() {
        local pid
        pid=$(ps -ef | sed 1d | fzf -m --header='Select process to kill' --preview='echo {}' --preview-window=down:3:wrap | awk '{print $2}')
        if [[ -n "$pid" ]]; then
          echo "🔫 Killing process $pid..."
          kill -9 "$pid"
        fi
      }
      
      # Docker container management (if docker is available)
      if command -v docker >/dev/null 2>&1; then
        docker-fzf() {
          local container
          container=$(docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | tail -n +2 | fzf --header='Select Docker container' --height=60% --border=rounded)
          if [[ -n "$container" ]]; then
            local container_name=$(echo "$container" | awk '{print $1}')
            echo "🐳 Selected container: $container_name"
            docker exec -it "$container_name" /bin/bash 2>/dev/null || docker exec -it "$container_name" /bin/sh
          fi
        }
      fi
      
      # Source local configuration if it exists
      [[ -f "${config.home.homeDirectory}/.zshrc.local" ]] && source "${config.home.homeDirectory}/.zshrc.local"
      
      # Emacs Integration
      [[ -f "${config.home.homeDirectory}/.zshrc.vterm" ]] && source "${config.home.homeDirectory}/.zshrc.vterm"
      
      # Bun completions
      [[ -s "${config.home.homeDirectory}/.bun/_bun" ]] && source "${config.home.homeDirectory}/.bun/_bun"
      
      # Node Version Manager (if available)
      [[ -s "${config.home.homeDirectory}/.nvm/nvm.sh" ]] && source "${config.home.homeDirectory}/.nvm/nvm.sh"
      [[ -s "${config.home.homeDirectory}/.nvm/bash_completion" ]] && source "${config.home.homeDirectory}/.nvm/bash_completion"
      
      # Rust completion
      [[ -f "${config.home.homeDirectory}/.cargo/env" ]] && source "${config.home.homeDirectory}/.cargo/env"
      
      # Python virtual environment support
      if command -v python3 >/dev/null 2>&1; then
        venv() {
          if [[ "$1" == "create" ]]; then
            python3 -m venv "${2:-venv}"
            echo "🐍 Virtual environment created: ${2:-venv}"
          elif [[ "$1" == "activate" ]]; then
            source "${2:-venv}/bin/activate"
            echo "🐍 Virtual environment activated: ${2:-venv}"
          elif [[ "$1" == "deactivate" ]]; then
            deactivate 2>/dev/null || echo "❌ No virtual environment to deactivate"
          else
            echo "Usage: venv {create|activate|deactivate} [name]"
          fi
        }
      fi
      
      # Final setup message
      echo "🎨 Catppuccin Mocha ZSH theme loaded successfully!"
      echo "✨ Enhanced with syntax highlighting, autosuggestions, and custom functions"
      echo "🔧 Type 'sysinfo' for system information or 'weather' for weather"
    '';
  };
}
