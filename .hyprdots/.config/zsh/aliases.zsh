alias fd='fd-find'
alias find='fd-find'
alias rmi='sudo rm -rf'
alias vi='nvim'
command -v dust >/dev/null 2>&1 && alias du='dust'
command -v procs >/dev/null 2>&1 && alias ps='procs'
command -v rg >/dev/null 2>&1 && alias grep='rg'
command -v zoxide >/dev/null 2>&1 && alias cd='z'

# ===== Fedora-specific Aliases =====
alias dnu='sudo dnf upgrade'
alias dni='sudo dnf install'
alias dns='dnf search'
alias dnr='sudo dnf remove'
alias dninfo='dnf info'
alias dnl='dnf list'
alias dnls='dnf list installed'
alias dnrq='dnf repoquery'
alias dnmc='sudo dnf makecache'
alias dncheck='dnf check-update'
alias dnhistory='dnf history'

# Flatpak integration
if command -v flatpak &> /dev/null; then
    alias fpi='flatpak install'
    alias fps='flatpak search'
    alias fpu='flatpak update'
    alias fpr='flatpak uninstall'
    alias fpl='flatpak list'
    alias fpinfo='flatpak info'
fi


# Systemctl aliases
alias sctl='systemctl'
alias sctle='sudo systemctl enable'
alias sctld='sudo systemctl disable'
alias sctls='sudo systemctl start'
alias sctlr='sudo systemctl restart'
alias sctlS='sudo systemctl stop'
alias sctlq='systemctl status'


# ===== Additional Fedora Tools =====
# Podman aliases (if available)
if command -v podman >/dev/null 2>&1; then
  alias docker='podman'
  alias pd='podman'
  alias pdi='podman images'
  alias pdc='podman ps'
  alias pdr='podman run'
  alias pds='podman start'
  alias pdS='podman stop'
fi

alias gg='lazygit'

#=== Misc ===
if command -v emacs >/dev/null 2>&1; then
  alias emacstty='emacsclient -tty'
  alias pd='podman'
  alias pdi='podman images'
  alias pdc='podman ps'
  alias pdr='podman run'
  alias pds='podman start'
  alias pdS='podman stop'
fi
