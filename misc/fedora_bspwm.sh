#!/bin/bash

echo "Setting up Repos"
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 

sudo dnf copr enable atim/lazygit 
sudo dnf copr enable atim/alacritty
sudo dnf update

echo "Installing Several Packages"
sudo dnf install bspwm sxhkd alacritty xdg-desktop-portal-gtk pixman polkit-devel xsel xclip polkit-gnome pipewire pipewire-alsa pipewire-pulseaudio pipewire-utils wireplumber alsa-utils thunar thunar-volman thunar-media-tags-plugin thunar-archive-plugin file-roller  kvantum qt5ct neofetch zsh util-linux-user sysstat psacct rng-tools cronie wget aide lynis mpv transmission-gtk copr-selinux zathura zathura-zsh-completion zathura-pdf-poppler akmod-nvidia nodejs npm papirus-icon-theme python3-devel gnome-keyring lazygit plymouth-theme-spinner ninja-build cmake meson gcc-c++ libxcb gtkmm3.0-devel alsa-utils yad ckb-next sassc boom-boot bat maim python-neovim neovim ripgrep tree-sitter-cli fd-find zsh zsh-autosuggestions zsh-syntax-highlighting zoxide fzf rofi dunst ranger jgmenu gammastep setxkbmap xrdb xsetroot hsetroot xournalpp pymol pipx python3-yapf black python3-pytest-isort python3-matplotlib python3-scipy python3-scikit-learn haveged qt6ct flatpak firefox

sudo plymouth-set-default-theme spinner -R

echo "Installing emacs"
sudo dnf install dnf-plugins-core
sudo dnf builddep emacs
wget https://gnu.mirror.constant.com/emacs/emacs-29.1.tar.xz
tar -xvf emacs-29.1.tar.xz && cd emacs-29.1 && ./autogen.sh
./configure --with-motif --with-native-compilation --with-modules --with-json --with-mailutils --with-imagemagick --with-tree-sitter --with-xft --with-modules --with-threads --with-harfbuzz --with-sqlite3 --without-jpeg --without-tiff --without-gif --without-png --without-rsvg --without-webp
make -j22
sudo make install && cd


echo "Setting up Dotfiles"
sudo rm -R ~/.config/
cd && mkdir ~/.config
ln -s $HOME/.dots/.fonts $HOME/
ln -s $HOME/.dots/.themes $HOME/
ln -s $HOME/.dots/gentoo_setup $HOME/
ln -s $HOME/.dots/Projects $HOME/
ln -s $HOME/.dots/.local/bin/bspwm $HOME/.local/bin
ln -s $HOME/.dots/.gtkrc-2.0 $HOME/
ln -s $HOME/.dots/.xinitrc $HOME/
ln -s $HOME/.dots/.Xresources $HOME/
ln -s $HOME/.dots/catppuccin.css $HOME/
ln -s $HOME/.dots/.config/alacritty $HOME/.config/
ln -s $HOME/.dots/.config/bspwm $HOME/.config/
ln -s $HOME/.dots/.config/btop $HOME/.config/
ln -s $HOME/.dots/.config/ckb-next $HOME/.config/
ln -s $HOME/.dots/.config/dunst $HOME/.config/
ln -s $HOME/.dots/.config/eww $HOME/.config/
ln -s $HOME/.dots/.config/gammastep $HOME/.config/
ln -s $HOME/.dots/.config/gtk-3.0 $HOME/.config/
ln -s $HOME/.dots/.config/gtk-3.0 $HOME/.config/
ln -s $HOME/.dots/.config/jgmenu $HOME/.config/
ln -s $HOME/.dots/.config/Kvantum $HOME/.config/
ln -s $HOME/.dots/.config/lazygit $HOME/.config/
ln -s $HOME/.dots/.config/lsd $HOME/.config/
ln -s $HOME/.dots/.config/lvim $HOME/.config/
ln -s $HOME/.dots/.config/picom $HOME/.config/
ln -s $HOME/.dots/.config/polybar $HOME/.config/
ln -s $HOME/.dots/.config/qalculate $HOME/.config/
ln -s $HOME/.dots/.config/qt5ct $HOME/.config/
ln -s $HOME/.dots/.config/qt6ct $HOME/.config/
ln -s $HOME/.dots/.config/ranger $HOME/.config/
ln -s $HOME/.dots/.config/rofi $HOME/.config/
ln -s $HOME/.dots/.config/suckless $HOME/.config/
ln -s $HOME/.dots/.config/sxhkd $HOME/.config/
ln -s $HOME/.dots/.config/wallpapers $HOME/.config/
ln -s $HOME/.dots/.config/zathura $HOME/.config/
ln -s $HOME/.dots/.config/zsh $HOME/.config/

echo "Setting Up Systemd"
sudo systemctl set-default graphical.target 
systemctl --user enable --now wireplumber.service pipewire-pulse.socket pipewire.socket pipewire-pulse.service pipewire.service pipewire-pulse.socket pipewire.socket pipewire-pulse.service pipewire.service

cd && mkdir ~/.npm-global && npm config set prefix '~/.npm-global' 

curl -fsSL https://fnm.vercel.app/install | sh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
rm -R .zshrc
ln -s $HOME/.dots/.zshrc ~/
chsh -s $(which zsh)
