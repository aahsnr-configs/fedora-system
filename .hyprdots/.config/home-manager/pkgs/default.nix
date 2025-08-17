{pkgs, ...}: {
  home.packages = with pkgs; [
    emacs-lsp-booster
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
    proselint
    tectonic
    texlab
    textlint
  ];
}
