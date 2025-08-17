{ inputs, pkgs, config, packages, self, lib, ...}:

{
  home.packages = with pkgs; [
    emacs-lsp-booster
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
    nixfmt
    proselint
    tectonic
    texlab
    textlint
  ];
}
