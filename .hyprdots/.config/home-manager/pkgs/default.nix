{ pkgs, ... }: {
  home.packages = with pkgs; [
    emacs-lsp-booster
    markdownlint-cli
    nix-prefetch-git
    nix-prefetch-github
    nil
    nixfmt
    nixpkgs-fmt
    proselint
    tectonic
    texlab
    textlint
    zeromq
  ];
}
