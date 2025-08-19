{pkgs, ...}: {
  home.packages = with pkgs; [
    delta
    lua5_1
    luarocks
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
