{ inputs, pkgs, config, packages, self, lib, ...}:

{
  home.packages = with pkgs; [
    blesh
    bun
    bottom
    #cargo
    dart-sass
    emacs-lsp-booster
    hyprland-qtutils
    hyprnome
    matugen
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
    nodejs_22
    nwg-drawer
    nwg-menu
    proselint
    pyprland
    rbenv
    #rofi-wayland-unwrapped
    #rustc
    swww
    texlab
    textlint
    typescript
    # yazi
    zellij
  ];
}
