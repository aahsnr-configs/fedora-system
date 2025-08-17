# ~/.config/home-manager/zoxide/default.nix
{...}: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
}
