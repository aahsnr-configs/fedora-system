{ inputs, pkgs, config, packages, self, lib, ...}:

{
  home.packages = with pkgs; [
    emacs-lsp-booster
    eza
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
    proselint
    tectonic
    texlab
    textlint
  ];
}
