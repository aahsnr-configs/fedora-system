#!/bin/bash
echo "Initiating Setup"
sleep 5
bash $HOME/fedora-setup/setup-scripts/01init
bash $HOME/fedora-setup/setup-scripts/02fonts
bash $HOME/fedora-setup/setup-scripts/03groups
bash $HOME/fedora-setup/setup-scripts/04syspkgs
bash $HOME/fedora-setup/setup-scripts/05security
bash $HOME/fedora-setup/setup-scripts/06desktop
bash $HOME/fedora-setup/setup-scripts/07git
bash $HOME/fedora-setup/setup-scripts/08editors
bash $HOME/fedora-setup/setup-scripts/09multimedia
bash $HOME/fedora-setup/setup-scripts/10asus
bash $HOME/fedora-setup/setup-scripts/11flatpaks
bash $HOME/fedora-setup/setup-scripts/12rustpkgs
bash $HOME/fedora-setup/setup-scripts/13srcpkgs
bash $HOME/fedora-setup/setup-scripts/14systemd
