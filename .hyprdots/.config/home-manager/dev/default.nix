{ pkgs, self, ... }:

{
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
    niv
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
