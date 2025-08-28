#!/bin/bash
set -e

t="$HOME/.cache/depends/"
rm -rf "$t"
mkdir -p "$t"
cd "$t"

# Update System
sudo dnf update --refresh -y

# COPR repositories
sudo dnf copr enable solopasha/hyprland -y
sudo dnf copr enable errornointernet/quickshell -y
sudo dnf copr enable deltacopy/darkly -y
sudo dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:luisbocanegra/Fedora_42/home:luisbocanegra.repo --overwrite

if ! dnf repolist --all | grep -qE '^terra\s'; then
  dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
else
  echo "Repo 'terra' already exists, skipping."
fi

# Core development tools
sudo dnf install --allowerasing -y cmake clang python3 python3-devel python3.12 python3.12-devel unzip hypridle libsoup-devel hyprland hyprland-qtutils hyprpicker hyprutils hyprshot hyprwayland-scanner hyprlock wlogout pugixml hyprlang-devel cliphist gtk4-devel libadwaita-devel gtk-layer-shell-devel gtk3 gtksourceview3 gtksourceview3-devel gobject-introspection upower gtksourceviewmm3-devel webp-pixbuf-loader gobject-introspection-devel gjs-devel pulseaudio-libs-devel xrandr xdg-desktop-portal xdg-desktop-portal-kde xdg-desktop-portal-hyprland gnome-bluetooth bluez-cups bluez hyprsunset mate-polkit translate-shell coreutils wl-clipboard xdg-utils curl fuzzel rsync wget ripgrep gojq npm meson typescript gjs axel brightnessctl ddcutil pavucontrol wireplumber libdbusmenu-gtk3-devel libdbusmenu playerctl cava yad scdoc ydotool tinyxml tinyxml2 tinyxml2-devel file-devel libwebp-devel libdrm-devel libgbm-devel pam-devel libsass-devel libsass gnome-themes-extra adw-gtk3-theme qt5ct qt6ct qt6-qtwayland kcmshell6 qt5-qtwayland fontconfig jetbrains-mono-fonts gdouros-symbola-fonts lato-fonts darkly fish kitty kvantum kvantum-qt5 libxdp-devel libxdp libportal swappy wf-recorder grim tesseract slurp appstream-util libsoup3-devel uv make python-opencv plasma-desktop plasma-nm kdialog bluedevil plasma-systemmonitor wtype matugen quickshell-git grimblast kde-material-you-colors mpvpaper ffmpeg

#upscayl
cd "$t"
url=$(curl -s https://api.github.com/repos/upscayl/upscayl/releases/latest |
  jq -r '.assets[] | select(.name | test("\\.rpm$")) | .browser_download_url')

wget "$url"
rpm_file="${url##*/}"
sudo dnf install -y "$rpm_file"

rm -rf "$t"
