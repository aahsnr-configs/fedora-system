{ config, pkgs, ... }:

{
  programs.bat = {
    enable = true;
    
    # Automatically install Catppuccin themes
    themes = {
      catppuccin-mocha = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "d2bbee4f7e7d5bac63c61e0a1397973d0b871c60";
          sha256 = "sha256-x1yqPCWuoBSx/cI94eA+AWwhiSA42cLNUOFJl7qjhmw=";
        };
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
    
    config = {
      # Theme configuration
      theme = "catppuccin-mocha";
      
      # Display style: line numbers, git changes, and header
      style = "numbers,changes,header";
      
      # Show non-printable characters
      show-all = true;
      
      # Use italic text where supported
      italic-text = "always";
      
      # Custom pager configuration
      pager = "less -FRX";
      
      # Always use colored output
      color = "always";
      
      # Syntax highlighting mappings for common file types
      map-syntax = [
        "*.conf:INI"
        "*.config:INI"
        "*.service:SystemD"
        "*.timer:SystemD"
        "*.target:SystemD"
        "*.socket:SystemD"
        "*.mount:SystemD"
        "Dockerfile*:Dockerfile"
        "*.spec:RPM Spec"
        "*.changes:Diff"
        "*.patch:Diff"
        
        # Fedora-specific file mappings
        "*.repo:INI"
        "*.xml:XML"
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
        
        # Container and virtualization files
        "Containerfile:Dockerfile"
        "*.containerfile:Dockerfile"
        "Vagrantfile:Ruby"
        
        # Log files and plain text
        "/var/log/dnf.log:Log"
        "/var/log/dnf.rpm.log:Log"
        "*.log:Log"
        
        # Fedora-specific configuration files
        "/etc/fedora-release:Plain Text"
        "/etc/system-release:Plain Text"
      ];
    };
  };
}
