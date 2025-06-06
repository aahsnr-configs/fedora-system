#!/bin/sh

# echo "@REPOS"
# sleep 2
# sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# sudo dnf config-manager --enable fedora-cisco-openh264
# sudo dnf install rpmfusion-nonfree-release-tainted
# sudo dnf copr enable atim/lazygit
# sudo dnf copr enable atim/starship
# sudo dnf copr enable solopasha/hyprland
# sudo dnf update
sudo dnf copr enable lukenukem/asus-linux
# sudo dnf copr enable heus-sueh/packages
# sudo dnf config-manager --save --setopt=copr:copr.fedorainfracloud.org:heus-sueh:packages.priority=200
#
#
# echo "@CORE"
# sleep 2
sudo dnf install -y \
  dnf-automatic \
  cargo \
  copr-selinux \
  dnf-plugins-core \
  fedora-workstation-repositories \
  flatpak \
  gtkmm3.0-devel \
  gnome-keyring \
  gsettings-desktop-schemas-devel \
  libxcb \
  gtk3-devel \
  gtk4-devel \
  xcur2png \
  kernel \
  kernel-core \
  kernel-devel \
  kernel-devel-matched \
  kernel-modules \
  kernel-modules-core \
  kernel-modules-extra \
  nodejs \
  npm \
  pipx \
  pixman \
  plymouth-theme-spinner \
  polkit-devel \
  mate-polkit \
  python3-devel \
  python3-wheel \
  python3-build \
  python3-installer \
  python3-setuptools \
  rust \
  util-linux-user \
  fzf 
#
# sudo plymouth-set-default-theme spinner -R
#
# echo "@SHELL"
# sleep 2
# sudo dnf install -y \
#   autojump-zsh \
#   starship \
#   zoxide \
#   zsh \
#   zsh-autosuggestions \
#   zsh-lovers \
#   zsh-syntax-highlighting
# #
# echo "@SYSTEM-TOOLS"
# sleep 2
# sudo dnf install -y \
#   aide \
#   arpwatch \
#   chrony \
#   cronie \
#   curl \
#   fail2ban \
#   fdupes \
#   lsd \
#   lynis \
#   PackageKit-command-not-found \
#   p7zip \
#   powertop \
#   psacct \
#   rng-tools \
#   sysstat \
#   wget
#
# echo "@NEOVIM"
# sleep 2
sudo dnf install -y \
  fd-find \
  neovim \
  ripgrep \
  python3-neovim \
  tree-sitter \
  wl-clipboard
#
# echo "@APPS"
# sleep 2
# sudo dnf install -y \
#   alacritty \
#   deluge \
#   emacs \
#   file-roller \
#   firefox \
#   ranger \
#   thunar \
#   thunar-volman \
#   thunar-media-tags-plugin \
#   thunar-archive-plugin \
#   tumbler \
#   kitty \
#   zathura \
#   zathura-zsh-completion \
#   zathura-pdf-poppler 
#
# echo "@THEME"
# sleep 2
# sudo dnf install -y \
#   kvantum \
#   papirus-icon-theme \
#   qt5ct \
#   qt6ct \
#   gnome-themes-extra \
#   gtk-murrine-engine \
#   sassc
#
# echo "@DRIVERS"
# sleep 2
# sudo dnf install -y \
#   akmod-nvidia-open \
#   xorg-x11-drv-nvidia-cuda \
#   xorg-x11-drv-nvidia-power \
#   xorg-x11-drv-nvidia-cuda-libs \
#   libva-devel \
#   libva-utils \
#   mesa-dri-drivers \
#   nvidia-vaapi-driver \
#   vulkan \
#   amd-ucode-firmware \
#   kmodtool \
#   akmods \
#   mokutil \
#   openssl
#
# sudo dnf mark install akmod-nvidia-open
# #sudo kmodgenca -a
# #sudo mokutil --import /etc/pki/akmods/certs/public_key.der
# #sudo systemctl enable nvidia-suspend.service nvidia-resume.service
# #sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
#
#
# echo "@C-DEVELOPMENT"
# sleep 2
sudo dnf install -y \
  autoconf \
  automake \
  binutils \
  bison \
  ccache \
  cmake \
  ctags \
  elfutils \
  flex \
  go \
  gcc \
  gcc-c++ \
  gdb \
  glibc-devel \
  libtool \
  make \
  perf \
  pkgconf \
  strace \
  valgrind
#
# echo "@DEVELOPMENT-TOOLS"
# sleep 2
sudo dnf install -y \
  gettext \
  git-core \
  git-credential-libsecret \
  highlight \
  lazygit \
  meld \
  meson \
  ninja-build \
  subversion
#
# echo "@ADMIN-TOOLS"
# sleep 2
sudo dnf install -y \
  abrt-desktop \
  setroubleshoot \
  system-config-language
#
# echo "@MULTIMEDIA"
# sleep 2
sudo dnf install -y \
  alsa-utils \
  pavucontrol \
  pamixer \
  pipewire \
  pipewire-alsa \
  pipewire-gstreamer \
  pipewire-pulseaudio \
  pipewire-utils \
  pulseaudio-utils \
  wireplumber
#
# echo "@RPM-DEVELOPMENT-TOOLS"
# sleep 2
sudo dnf install -y \
  redhat-rpm-config \
  rpm-build \
  koji \
  mock \
  rpmdevtools \
  pungi \
  rpmlint \
  shfmt
#
# echo "@HYPRLAND-DE"
# sleep 2
# sudo dnf install -y \
#   cliphist \
#   nwg-clipman \
#   egl-wayland \
#   greetd \
#   pam-devel \
#   grim \
#   hyprcursor \
#   hypridle \
#   hyprland \
#   hyprland-devel \
#   hyprland-contrib \
#   hyprland-welcome \
#   hyprlang \
#   hyprnome \
#   hyprpaper \
#   hyprpicker \
#   hyprwayland-scanner \
#   pyprland \
#   qt5-qtwayland \
#   qt6-qtwayland \
#   slurp \
#   swaylock-effects \
#   tomlplusplus \
#   wayland-protocols-devel \
#   xisxwayland \
#   xdg-desktop-portal-gtk \
#   xdg-desktop-portal-hyprland \
#   xorg-x11-server-Xwayland \
#   xorg-x11-server-Xwayland-devel \
#   wf-recorder
# #
# sudo dnf install -y pipewire libgtop2 bluez bluez-tools grimblast hyprpicker btop NetworkManager  wl-clipboard swww brightnessctl gnome-bluetooth aylurs-gtk-shell power-profiles-daemon gvfs matugen
#
# echo "@ASUS"
# sleep 5
sudo dnf update
sudo dnf install asusctl power-profiles-daemon supergfxctl asusctl-rog-gui
sudo dnf update --refresh
sudo systemctl enable supergfxd.service power-profiles-daemon

echo "@fonts"
sudo mkdir -p /usr/local/share/fonts/nerd
sudo cp $HOME/.dots/.fonts/* /usr/local/share/fonts/nerd/
sudo chown -R root: /usr/local/share/fonts/nerd
sudo chmod 644 /usr/local/share/fonts/nerd/*
sudo restorecon -vFr /usr/local/share/fonts/nerd
sudo fc-cache -v

echo "@BASHSCRIPTS"
sleep 5
#bash $HOME/.dots/fedora-scripts/source_builds/Insync && cd
#bash $HOME/.dots/fedora-scripts/source_builds/Ignis && cd
#bash $HOME/.dots/fedora-scripts/source_builds/Swaylock-effects && cd
#bash $HOME/.dots/fedora-scripts/source_builds/Materialyoucolor && cd
#bash $HOME/.dots/fedora-scripts/source_builds/Regreet && cd
#bash $HOME/.dots/fedora-scripts/source_builds/Emacs && cd
#bash $HOME/.dots/fedora-scripts/source_builds/Eww  && cd
#bash $HOME/.dots/fedora-scripts/source_builds/Nwg-look && cd

# echo "@DOTS"
# sleep 5
# sudo rm -R $HOME/.local
# sudo rm -R $HOME/.config/
# cd && mkdir $HOME/.config
# mkdir -p $HOME/.local/bin
# ln -s $HOME/.dots/.config/alacritty $HOME/.config/
# ln -s $HOME/.dots/.config/kitty $HOME/.config/
# ln -s $HOME/.dots/.config/anyrun $HOME/.config/
# ln -s $HOME/.dots/.config/btop $HOME/.config
# ln -s $HOME/.dots/.config/gtk-3.0 $HOME/.config/
# ln -s $HOME/.dots/.config/gtk-4.0 $HOME/.config/
# ln -s $HOME/.dots/.config/hypr $HOME/.config/
# ln -s $HOME/.dots/.config/Kvantum $HOME/.config/
# ln -s $HOME/.dots/.config/lazygit $HOME/.config/
# ln -s $HOME/.dots/.config/lsd $HOME/.config/
# ln -s $HOME/.dots/.config/Thunar $HOME/.config/
# ln -s $HOME/.dots/.config/qt5ct $HOME/.config/
# ln -s $HOME/.dots/.config/qt6ct $HOME/.config/
# ln -s $HOME/.dots/.config/wallpapers $HOME/.config/
# ln -s $HOME/.dots/bin $HOME/.local/bin
# ln -s $HOME/.dots/.config/zathura $HOME/.config/
# ln -s $HOME/.dots/.config/zsh $HOME/.config/
# ln -s $HOME/.dots/.config/starship.toml $HOME/.config/
# ln -s $HOME/.dots/.gtkrc-2.0 $HOME/
# ln -s $HOME/.dots/.themes $HOME/
# ln -s $HOME/.dots/org $HOME/
# ln -s $HOME/.dots/.fonts $HOME/
# ln -s $HOME/.dots/.config/ags $HOME/.config/
# ln -s $HOME/.dots/colorscheme.css $HOME/
# ln -s $HOME/.dots/gentoo_setup $HOME/
#
# echo "@SYSTEMD"
# sleep 5
# sudo systemctl set-default graphical.target
# systemctl --user enable --now wireplumber.service pipewire-pulse.socket pipewire.socket pipewire-pulse.service pipewire.service pipewire-pulse.socket pipewire.socket pipewire-pulse.service pipewire.service
#
echo "${bold}@NVIM-INIT${offbold}"
sleep 5
cd && mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
ln -s $HOME/.dots/.config/nvim $HOME/.config/

# flatpak install flathub --system com.dec05eba.gpu_screen_recorder
#
# pipx install gpustat pywal
#
# echo "@ZSH"
# sleep 5
curl -fsSL https://fnm.vercel.app/install | sh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
rm -R .zshrc
ln -s $HOME/.dots/.zshrc ~/
chsh -s $(which zsh)

echo "@GIT"
sleep 2
sudo cp -R ~/.dots/variables.sh /etc/profile.d/
git config --global user.name "aahsnr"
git config --global user.email "ahsanur041@proton.me"
git config --global credential.helper /usr/libexec/git-core/git-credential-libsecret


# flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#
# echo @HYPRPANEL
# sudo dnf install -y wireplumber upower libgtop2 bluez bluez-tools grimblast hyprpicker btop NetworkManager wl-clipboard swww brightnessctl gnome-bluetooth aylurs-gtk-shell power-profiles-daemon gvfs nodejs
#
# npm install -g sass 
#
# curl -fsSL https://bun.sh/install | bash && \
#   sudo ln -s $HOME/.bun/bin/bun /usr/local/bin/bun
# flatpak install flathub --system com.dec05eba.gpu_screen_recorder

