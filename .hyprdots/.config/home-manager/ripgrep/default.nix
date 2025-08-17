# ~/.config/home-manager/ripgrep/default.nix
{ config, pkgs, ... }:

{
  programs.ripgrep = {
    enable = true;
    arguments = [
      # Performance optimizations
      "--max-columns=300"
      "--max-columns-preview"
      "--smart-case"
      "--one-file-system"
      "--mmap"

      # Search preferences
      "--hidden"
      "--follow"

      # Globs to ignore
      "--glob=!.git/"
      "--glob=!.svn/"
      "--glob=!.hg/"
      "--glob=!CVS/"
      "--glob=!.idea/"
      "--glob=!.vscode/"
      "--glob=!*.min.*"
      "--glob=!*.o"
      "--glob=!*.so"
      "--glob=!*.pyc"
      "--glob=!__pycache__/"
      "--glob=!node_modules/"
      "--glob=!target/"
      "--glob=!*.swp"
      "--glob=!*.swo"
      "--glob=!*.aux"
      "--glob=!*.out"
      "--glob=!*.toc"
      "--glob=!*.blg"
      "--glob=!*.bbl"
      "--glob=!*.fls"
      "--glob=!*.fdb_latexmk"

      # Fedora-specific excludes
      "--glob=!*.rpm"
      "--glob=!*.dnf"
      "--glob=!*.cache"
      "--glob=!*.tmp"
      "--glob=!*.lock"
      "--glob=!*.log"
      "--glob=!*.pid"
      "--glob=!*.socket"
      "--glob=!*.service.d/"
      "--glob=!*.target.d/"
      "--glob=!/var/cache/dnf/"
      "--glob=!/var/lib/dnf/"
      "--glob=!/var/log/dnf*/"
      "--glob=!/var/lib/rpm/"
      "--glob=!/proc/"
      "--glob=!/sys/"
      "--glob=!/dev/"
      "--glob=!/run/"
      "--glob=!/tmp/"
      "--glob=!/boot/"
      "--glob=!/media/"
      "--glob=!/mnt/"
    ];
  };
}
