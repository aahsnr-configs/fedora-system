#!/bin/bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
nix run home-manager/master -- init --switch --extra-experimental-features nix-command --extra-experimental-features flakes
sudo cp -R $HOME/.dots/arch-scripts/preconfig-files/nix.conf /etc/nix/
yay -S zsh-nix-shell nix-zsh-completions
