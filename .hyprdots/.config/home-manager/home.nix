{ inputs, pkgs, config, lib, nixgl, ... }:

{
  home = {
    username = "ahsan";
    homeDirectory = "/home/ahsan";
    stateVersion = "25.05";
    extraOutputsToInstall = ["doc" "info" "devdoc"];
    
    #--- Setting Session Variables ---
    sessionVariables = {
      EDITOR = "emacsclient -c -a 'emacs'";
      BROWSER = "zen-browser";
      TERMINAL = "kitty";
    };

    #--- Setting Session Path ---
    sessionPath = [
      "$HOME/.local/bin"
    # "/usr/libexec"
    ];
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # ".screenrc".source = dotfiles/screenrc;
  };

  # nix-pkgs: yazi texlab tectonic emacs-lsp-booster
  home.packages = with pkgs; [
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
  ];

  imports = [ 
    # ./fonts
    # ./git
    # ./gpg
    # inputs.nix-doom-emacs-unstraightened.hmModule
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowUnfreePredicate = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
