#!/bin/bash
# In fedora linux, this script will install the nix package manager will be installed using the following command from determinate: 'curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate'

# After the above command is finished, the script will setup home-manager and flakes using the command 'nix run home-manager/master -- init --switch'. This will create the home.nix and the flake.nix in the directory $HOME/.config/home-manager. But this script will remove this directory. Instead the directory $HOME/.hyprdots/.config/home-manager will be symlinked to $HOME/.config/home-manager. Then the script will install all the required packages using the command 'home-manager switch'
