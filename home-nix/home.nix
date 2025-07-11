{ inputs, pkgs, config, lib, nixgl, ... }:

{
  home = {
    username = "ahsan";
    homeDirectory = "/home/ahsan";
    stateVersion = "25.05";
    extraOutputsToInstall = ["doc" "info" "devdoc"];
    
    #--- Setting Session Variables ---
    # sessionVariables = {
    #   EDITOR = "nvim";
    #   BROWSER = "brave";
    #   TERMINAL = "alacritty";
    # };

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

  home.packages = with pkgs; [
    bun
    bottom
    dart-sass
    emacs-lsp-booster
    matugen
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
    tectonic
    texlab
    yazi
  ];

  imports = [ 
    ./fonts
    # ./git
    # ./gpg
    ./pkgs
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
