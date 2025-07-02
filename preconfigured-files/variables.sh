#!/bin/sh
# You should override these in your ~/.bashrc (or equivalent) for per-user
# settings.  For system defaults, you can add a new file in /etc/profile.d/.
export EDITOR="${EDITOR:-/usr/bin/nvim}"
export PAGER="${PAGER:-/usr/bin/less}"
export TERMINAL="kitty"
export VISUAL="nvim"

export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.bun/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/bin/hypr"
export PATH="$PATH:$HOME/.config/emacs/bin"
export PATH="$PATH:$HOME/.npm-global/bin"
