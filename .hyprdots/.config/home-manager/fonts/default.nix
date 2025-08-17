{ config, pkgs, nixpkgs, ...}: 

{ 
  home.packages = with pkgs; [
    ubuntu_font_family
    jetbrains-mono
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    nerd-fonts.jetbrains-mono
    (google-fonts.override {fonts = ["Inter"];})
  ];

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrains Mono" ];
    };
  };
}
