{
  config,
  lib,
  pkgs,
  ...
}: {
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#ff00ff,bg=cyan,bold,underline";
    };
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    sessionVariables = {
      LC_ALL = "en_US.UTF-8";
      ZSH_AUTOSUGGEST_USE_ASYNC = "true";
      SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    };
    completionInit = "autoload -U compinit && compinit";
    history = {
      save = 2137;
      size = 2137;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    dirHashes = {
      docs = "$HOME/docs";
      notes = "$HOME/docs/notes";
      dots = "$HOME/dev/dotfiles";
      dl = "$HOME/download";
      vids = "$HOME/vids";
      music = "$HOME/music";
      media = "/run/media/$USER";
    };
    shellAliases = import ./aliases.nix {inherit pkgs lib config;};
    antidote = {
      enable = true;
      plugins = [ 
        "zsh-users/zsh-autosuggestions"
      ];
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];
  };

  programs.thefuck.enableZshIntegration = true;
}
