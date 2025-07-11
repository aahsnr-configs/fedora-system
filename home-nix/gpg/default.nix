{config, ... }: 

{
  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
    settings = {
      default-key = "FF3BF2B45594DDA2";
    };
  };
}
