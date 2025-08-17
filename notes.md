## ssh setup

[Note]: Run dnf swap function after issuing dnf update
[Note]: Use brew for system wide tools, like for neovim
[Note]: Use nix for project specific tools

- setup brew
- sudo dnf install openssh
- setup rustup
- setup ssh
- brew install markdownlint-cli
- sudo dnf install kitty
- git clone --recurse-submodules git@github.com:aahsnr/emacs.git ~/.config/emacs
- installed packages from packages.sh
- brew install yazi
- kept a copy of bash history for later use
- executed the following commands:
  sudo sh -c 'echo "%\_with_kmod_nvidia_open 1" > /etc/rpm/macros.nvidia-kmod'
  sudo akmods --kernels $(uname -r) --rebuild
- sudo dnf install nvidia-vaapi-driver libva-utils vdpauinfo
- sudo dnf install yarn
- sudo dnf install hspell hspell-devel nuspell nuspell-devel libvoikko libvoikko-devel hunspell-en-US enchant2-devel pkgconf
- sudo dnf install atuin python-neovim npm git-delta git-lfs libsecret-devel
- systemctl --user enable --now gnome-keyring-daemon
- sudo dnf install go ripgrep fd
- sudo dnf remove at abrt
- sudo dnf remove nfs-utils
- sudo dnf remove chrony
- sudo dnf remove tuned-ppd sssd-client
