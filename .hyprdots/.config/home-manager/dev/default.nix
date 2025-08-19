# ~/.config/home-manager/dev/default.nix
{pkgs, ...}: {
  home.packages = with pkgs; [deadnix statix niv];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    config.global = {hide_env_diff = true;};
  };
}
