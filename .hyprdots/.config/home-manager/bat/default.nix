# ~/.config/home-manager/bat/default.nix
{pkgs, ...}: {
  programs.bat = {
    enable = true;
    extraPackages = with pkgs; [
      bat-extras.batdiff
      bat-extras.batman
      bat-extras.prettybat
    ];
    config = {
      style = "numbers,changes,header";
      "show-all" = true;
      "italic-text" = "always";
      color = "always";

      # All syntax mappings go here as a list of strings.
      "map-syntax" = [
        # Fedora-specific file mappings
        "*.repo:INI"
        "kickstart.cfg:Bash"
        "*.ks:Bash"

        # System configuration files
        "/etc/sysconfig/*:Bash"
        "/etc/dnf/*.conf:INI"
        "/etc/dnf/*.repo:INI"
        "/etc/yum.repos.d/*.repo:INI"
        "/etc/security/*.conf:INI"
        "/etc/NetworkManager/system-connections/*:INI"
        "/etc/modprobe.d/*.conf:Bash"

        # SystemD unit files
        "/usr/lib/systemd/system/*:SystemD"
        "/etc/systemd/system/*:SystemD"
        "/home/*/.config/systemd/user/*:SystemD"

        # SELinux policy files
        "*.te:C"
        "*.if:C"
        "*.fc:Plain Text"

        # Container files
        "Containerfile:Dockerfile"
        "*.containerfile:Dockerfile"

        # Log files and plain text
        "/var/log/dnf.log:Log"
        "/var/log/dnf.rpm.log:Log"
        "*.log:Log"

        # Fedora-specific release files
        "/etc/fedora-release:Plain Text"
        "/etc/system-release:Plain Text"
      ];
    };
  };
}
