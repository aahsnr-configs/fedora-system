#!/bin/bash

# --- Configuration ---
# Define colors for output
RED='\033[0;31m'    # Error
GREEN='\033[0;32m'  # Success
YELLOW='\033[0;33m' # Warning
BLUE='\033[0;34m'   # Info
NC='\033[0m'        # No Color

# Define Unicode symbols
SYMBOL_SUCCESS="✔" # U+2714 HEAVY CHECK MARK
SYMBOL_ERROR="✖"   # U+2716 HEAVY MULTIPLICATION X
SYMBOL_INFO="ℹ"    # U+2139 INFORMATION SOURCE
SYMBOL_WARNING="⚠" # U+26A0 WARNING SIGN

# Path to preconfigured files (adjust if your preconfigured-files are elsewhere)
# Ensure this directory exists and contains 'dnf.conf' and 'variables.sh' if used.
PRECONFIG_DIR="$HOME/fedora-setup/preconfigured-files"

# Destination paths for configuration files
DNF_CONF_DEST="/etc/dnf/dnf.conf"
VARIABLES_SH_DEST="/etc/profile.d/variables.sh"
LOCALTIME_DEST="/etc/localtime"
TIMEZONE_SRC="../usr/share/zoneinfo/Asia/Dhaka" # Relative path from /etc/

# RPM Fusion URLs
RPMFUSION_FREE="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
RPMFUSION_NONFREE="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# COPR repositories to enable
COPR_REPOS=(
  "solopasha/hyprland"
  "sneexy/zen-browser"
  "lukenukem/asus-linux"
  "wehagy/protonplus"
)

# --- Helper Functions ---

# Function for logging messages with colors, timestamps, and Unicode symbols
log() {
  local type="$1"
  local message="$2"
  local color="$3"
  local symbol=""

  case "$type" in
  "SUCCESS") symbol="$SYMBOL_SUCCESS" ;;
  "ERROR") symbol="$SYMBOL_ERROR" ;;
  "INFO") symbol="$SYMBOL_INFO" ;;
  "WARNING") symbol="$SYMBOL_WARNING" ;;
  "FATAL") symbol="$SYMBOL_ERROR" ;; # Fatal errors use the error symbol
  *) symbol="" ;;                    # No symbol for unknown types
  esac

  printf "${color}[%s] %s %s: %s${NC}\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$symbol" "$type" "$message"
}

# Function to compare file contents for idempotency checks
compare_files() {
  # Returns 0 if files are identical or if destination does not exist, 1 otherwise.
  [[ -f "$1" && -f "$2" ]] && cmp -s "$1" "$2"
}

# Function to handle DNF package/repo installation with idempotency
# Usage: dnf_install_idempotent "description" "check_command" "install_command"
dnf_install_idempotent() {
  local desc="$1"
  local check_cmd="$2"
  local install_cmd="$3"

  log "INFO" "Checking: $desc" "$BLUE"
  if eval "$check_cmd"; then
    log "INFO" "$desc is already configured/installed." "$YELLOW"
    return 0
  else
    log "INFO" "Attempting to configure/install: $desc" "$BLUE"
    if eval "$install_cmd"; then
      log "SUCCESS" "$desc configured/installed successfully." "$GREEN"
      return 0
    else
      log "ERROR" "Failed to configure/install $desc." "$RED"
      return 1
    fi
  fi
}

# Function to handle file copying with idempotency and content comparison
# Usage: copy_file_idempotent "source_path" "destination_path"
copy_file_idempotent() {
  local src="$1"
  local dest="$2"
  local file_name=$(basename "$src")

  if [[ ! -f "$src" ]]; then
    log "WARNING" "Source file '$src' not found. Skipping '$file_name' copy." "$YELLOW"
    return 1
  fi

  log "INFO" "Checking '$file_name' configuration..." "$BLUE"
  if compare_files "$src" "$dest"; then
    log "INFO" "'$file_name' is already up-to-date at '$dest'." "$YELLOW"
    return 0
  else
    log "INFO" "Copying '$src' to '$dest'..." "$BLUE"
    if sudo cp -f "$src" "$dest"; then
      log "SUCCESS" "Copied '$file_name' to '$dest'." "$GREEN"
      return 0
    else
      log "ERROR" "Failed to copy '$file_name' to '$dest'." "$RED"
      return 1
    fi
  fi
}

# Function to install DNF packages, handling duplicates and allowing partial failures
install_packages() {
  local packages=("$@")
  if [ ${#packages[@]} -eq 0 ]; then
    log "INFO" "No packages to install." "$BLUE"
    return 0
  fi

  # Deduplicate packages (though the main list is already deduplicated, this adds a layer of safety)
  IFS=$'\n' sorted_unique_packages=($(sort -u <<<"${packages[*]}"))
  unset IFS

  log "INFO" "Attempting to install ${#sorted_unique_packages[@]} unique packages..." "$BLUE"
  log "INFO" "Packages to install: ${sorted_unique_packages[*]}" "$BLUE"

  # Temporarily disable -e to allow dnf to continue if some packages fail
  set +e
  sudo dnf install -y "${sorted_unique_packages[@]}"
  local dnf_exit_code=$?
  set -e # Re-enable -e

  if [ "$dnf_exit_code" -eq 0 ]; then
    log "SUCCESS" "All specified packages installed successfully." "$GREEN"
    return 0
  else
    log "ERROR" "DNF installation completed with errors (exit code: $dnf_exit_code). Some packages might not have been installed." "$RED"
    log "WARNING" "Please review DNF's output above for details on failed packages." "$YELLOW"
    return 1 # Indicate partial failure
  fi
}

# --- Pre-flight Checks ---

# Function to check for root privileges
check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    log "ERROR" "This script must be run as root. Please use sudo." "$RED"
    exit 1
  fi
  return 0
}

# Function to check for internet connectivity
check_internet_connection() {
  log "INFO" "Checking internet connectivity..." "$BLUE"
  if curl -s -m 10 http://google.com >/dev/null; then
    log "SUCCESS" "Internet connection is active." "$GREEN"
    return 0
  else
    log "ERROR" "No internet connection detected. Please check your network settings." "$RED"
    return 1
  fi
}

# Function to check if DNF command is available
check_dnf_availability() {
  log "INFO" "Checking DNF availability..." "$BLUE"
  if command -v dnf &>/dev/null; then
    log "SUCCESS" "DNF command found." "$GREEN"
    return 0
  else
    log "ERROR" "DNF command not found. This script requires DNF to be installed." "$RED"
    return 1
  fi
}

# Function to clean DNF cache and refresh metadata
refresh_dnf_metadata() {
  log "INFO" "Cleaning DNF cache and refreshing metadata..." "$BLUE"
  if sudo dnf clean all && sudo dnf makecache; then
    log "SUCCESS" "DNF cache cleaned and metadata refreshed." "$GREEN"
    return 0
  else
    log "ERROR" "Failed to clean DNF cache or refresh metadata. This might cause issues with package installations." "$RED"
    return 1
  fi
}

# --- Main Script Functions ---

# Function to copy DNF configuration files
setup_dnf_configs() {
  log "INFO" "Starting DNF configuration setup..." "$BLUE"
  copy_file_idempotent "$PRECONFIG_DIR/dnf.conf" "$DNF_CONF_DEST" || return 1
  copy_file_idempotent "$PRECONFIG_DIR/variables.sh" "$VARIABLES_SH_DEST" || return 1
  return 0
}

# Function to install RPM Fusion repositories
install_rpmfusion() {
  log "INFO" "Starting RPM Fusion repositories setup..." "$BLUE"

  dnf_install_idempotent \
    "RPM Fusion Free repository" \
    "dnf repolist enabled | grep -q 'rpmfusion-free'" \
    "sudo dnf install -y '$RPMFUSION_FREE'" || return 1

  dnf_install_idempotent \
    "RPM Fusion Nonfree repository" \
    "dnf repolist enabled | grep -q 'rpmfusion-nonfree'" \
    "sudo dnf install -y '$RPMFUSION_NONFREE'" || return 1
  return 0
}

# Function to enable Cisco OpenH264
enable_cisco_openh264() {
  log "INFO" "Starting Cisco OpenH264 setup..." "$BLUE"
  dnf_install_idempotent \
    "Fedora Cisco OpenH264" \
    "dnf config-manager --dump fedora-cisco-openh264 | grep -q 'enabled=True'" \
    "sudo dnf config-manager --setopt fedora-cisco-openh264.enabled=1" || return 1
  return 0
}

# Function to enable COPR repositories
enable_copr_repos() {
  log "INFO" "Starting COPR repositories setup..." "$BLUE"
  local all_copr_success=true
  for repo in "${COPR_REPOS[@]}"; do
    local repo_name=$(echo "$repo" | sed 's/\//-/g')

    # Check if COPR repo is already enabled
    if dnf repolist enabled | grep -q "copr:copr.fedorainfracloud.org:$repo_name"; then
      log "INFO" "COPR repository '$repo' is already enabled." "$YELLOW"
    else
      log "INFO" "Attempting to enable COPR repository: '$repo'..." "$BLUE"
      if sudo dnf copr enable -y "$repo"; then
        log "SUCCESS" "COPR repository '$repo' enabled successfully." "$GREEN"
      else
        log "ERROR" "Failed to enable COPR repository '$repo'." "$RED"
        all_copr_success=false
      fi
    fi
  done
  "$all_copr_success" || return 1 # Return non-zero if any COPR repo failed
  return 0
}

# Function to set timezone
set_timezone() {
  log "INFO" "Starting timezone setup to Asia/Dhaka..." "$BLUE"
  local current_timezone=$(readlink "$LOCALTIME_DEST" 2>/dev/null | sed 's#^../usr/share/zoneinfo/##')

  if [[ "$current_timezone" == "Asia/Dhaka" ]]; then
    log "INFO" "Timezone is already set to Asia/Dhaka." "$YELLOW"
  else
    log "INFO" "Creating symlink for timezone: '$TIMEZONE_SRC' to '$LOCALTIME_DEST'..." "$BLUE"
    if sudo ln -sf "$TIMEZONE_SRC" "$LOCALTIME_DEST"; then
      log "SUCCESS" "Timezone set to Asia/Dhaka." "$GREEN"
    else
      log "ERROR" "Failed to set timezone to Asia/Dhaka." "$RED"
      return 1
    fi
  fi
  return 0
}

# Function to install all DNF packages
install_all_dnf_packages() {
  log "INFO" "Starting installation of all DNF packages..." "$BLUE"

  # Combined, deduplicated, and sorted list of all packages from the original scripts
  local all_packages=(
    @multimedia
    @fonts
    abseil-cpp-devel
    abseil-cpp-testing
    acpid
    aide
    akmod-nvidia
    akmods
    alsa-sof-firmware
    amd-gpu-firmware
    aquamarine-devel
    arpwatch
    autoconf
    automake
    bat
    bison
    black
    bluez
    brightnessctl
    btop
    byacc
    cairo-devel
    ccache
    cava
    checkpolicy
    chrony
    clang
    cliphist
    copr-selinux
    cronie
    cscope
    ctags
    curl
    diffstat
    distrobox
    dkms
    dnf-automatic
    dnf-plugins-core
    docbook-slides
    docbook-style-dsssl
    docbook-style-xsl
    docbook-utils
    docbook-utils-pdf
    docbook5-schemas
    docbook5-style-xsl
    doxygen
    egl-wayland
    exiftool
    fail2ban
    fastfetch
    fdupes
    fedora-workstation-repositories
    ffmpegthumbnailer
    file
    file-roller
    fish
    flex
    fontconfig
    fuzzel
    fzf
    gcc
    gcc-c++
    gdb
    gettext
    git-core
    glaze-devel
    glib2
    glx-utils
    gmock
    gnome-software
    gnuplot
    google-noto-emoji-fonts
    groff-base
    gsl
    gsl-devel
    gtest
    gtk-layer-shell-devel
    gtk3-devel
    greetd
    grim
    haveged
    highlight
    hwdata-devel
    hyprcursor-devel
    hyprgraphics-devel
    hypridle
    hyprland-contrib
    hyprland-git
    hyprlang-devel
    hyprlock
    hyprnome
    hyprpaper
    hyprpicker
    hyprpolkitagent
    hyprshot
    hyprsunset
    ImageMagick
    imv
    inotify-tools
    intel-audio-firmware
    intel-gpu-firmware
    intel-vsc-firmware
    iwlwifi-dvm-firmware
    iwlwifi-mvm-firmware
    jq
    kernel
    kernel-core
    kernel-devel
    kernel-devel-matched
    kernel-headers
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
    kitty
    kmodtool
    koji
    kvantum
    kvantum-qt5
    latexmk
    lazygit
    less
    libavif
    libavdevice-free-devel
    libavfilter-free-devel
    libavformat-free-devel
    libavutil-free-devel
    libdisplay-info-devel
    libdrm-devel
    libglvnd-devel
    libglvnd-glx
    libglvnd-opengl
    libheif
    libinput-devel
    libliftoff
    libliftoff-devel
    libnotify-devel
    libpciaccess-devel
    libsemanage
    libseat-devel
    libsepol
    libsepol-utils
    libtool
    libva-utils
    libwebp
    libxcb
    libxcb-devel
    linuxdoc-tools
    lm_sensors
    ltrace
    lynis
    make
    man-db
    man-pages
    matugen
    maxima
    mcstrans
    mesa-libgbm-devel
    mesa-vulkan-drivers
    mock
    mokutil
    NetworkManager-tui
    nvidia-gpu-firmware
    nvidia-vaapi-driver
    nvtop
    nwg-look
    openssl
    PackageKit-command-not-found
    pandoc
    papirus-icon-theme
    patchutils
    p7zip
    p7zip-plugins
    perf
    pkgconf
    plymouth-theme-spinner
    plymouth-system-theme
    podman
    policycoreutils
    policycoreutils-dbus
    policycoreutils-devel
    policycoreutils-gui
    policycoreutils-python-utils
    policycoreutils-restorecond
    policycoreutils-sandbox
    poppler-utils
    powertop
    procs
    psacct
    pylint
    pyprland
    python3-build
    python3-devel
    python3-installer
    python3-matplotlib
    python3-matplotlib-tk
    python3-notebook
    python3-numpy
    python3-pandas
    python3-pillow
    python3-pillow-tk
    python3-policycoreutils
    python3-scikit-image
    python3-scikit-learn
    python3-scipy
    python3-setools
    python3-sympy
    qt5-qtwayland
    qt5ct
    qt6-qtwayland
    qt6ct
    quickshell-git
    re2-devel
    realtek-firmware
    redhat-rpm-config
    rng-tools
    rofi-wayland
    rpm-build
    rpmdevtools
    sassc
    secilc
    secilc-doc
    selint
    selinux-policy
    selinux-policy-devel
    selinux-policy-doc
    selinux-policy-sandbox
    selinux-policy-targeted
    sepolicy_analysis
    setools
    setools-console
    setools-console-analyses
    setools-gui
    setroubleshoot
    setroubleshoot-server
    slurp
    socat
    starship
    strace
    subversion
    swappy
    switcheroo-control
    swww
    sysstat
    system-config-language
    systemtap
    tar
    tealdeer
    texlive
    texlive-cm-lgc
    texlive-kerkis
    texlive-synctex
    thefuck
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-volman
    tmux
    tomlplusplus-devel
    toolbox
    transmission-qt
    trash-cli
    tree
    tumbler
    tuigreet
    udica
    units
    unzip
    usb_modeswitch
    uwsm
    valgrind
    viu
    vulkan
    wayland-protocols-devel
    wget
    wxMaxima
    xcb-util-devel
    xcb-util-errors-devel
    xcb-util-renderutil-devel
    xcb-util-wm-devel
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xhtml1-dtds
    xisxwayland
    xmlto
    xorg-x11-drv-nvidia-cuda
    xorg-x11-drv-nvidia-cuda-libs
    xorg-x11-server-Xwayland-devel
    xournalpp
    xcur2png
    yazi
    zathura
    zathura-cb
    zathura-djvu
    zathura-pdf-poppler
    zathura-plugins-all
    zathura-ps
    zen-browser
    zip
    zoxide
    zsh
  )

  install_packages "${all_packages[@]}" || return 1
  return 0
}

# Function for NVIDIA specific configurations
configure_nvidia() {
  log "INFO" "Starting NVIDIA specific configurations..." "$BLUE"

  log "INFO" "Marking akmod-nvidia as user-managed..." "$BLUE"
  if sudo dnf mark user akmod-nvidia; then
    log "SUCCESS" "akmod-nvidia marked as user-managed." "$GREEN"
  else
    log "ERROR" "Failed to mark akmod-nvidia as user-managed." "$RED"
    return 1
  fi

  log "INFO" "Enabling NVIDIA suspend, resume, and hibernate services..." "$BLUE"
  if sudo systemctl enable nvidia-{suspend,resume,hibernate}; then
    log "SUCCESS" "NVIDIA services enabled." "$GREEN"
  else
    log "ERROR" "Failed to enable NVIDIA services." "$RED"
    return 1
  fi

  log "INFO" "Creating RPM macro for NVIDIA kmod..." "$BLUE"
  if sudo sh -c 'echo "%_with_kmod_nvidia_open 1" > /etc/rpm/macros.nvidia-kmod'; then
    log "SUCCESS" "RPM macro for NVIDIA kmod created." "$GREEN"
  else
    log "ERROR" "Failed to create RPM macro for NVIDIA kmod." "$RED"
    return 1
  fi

  log "INFO" "Rebuilding NVIDIA akmods for current kernel..." "$BLUE"
  if sudo akmods --kernels "$(uname -r)" --rebuild; then
    log "SUCCESS" "NVIDIA akmods rebuilt successfully." "$GREEN"
  else
    log "ERROR" "Failed to rebuild NVIDIA akmods." "$RED"
    return 1
  fi

  log "INFO" "Masking nvidia-fallback.service..." "$BLUE"
  if sudo systemctl mask nvidia-fallback.service; then
    log "SUCCESS" "nvidia-fallback.service masked." "$GREEN"
  else
    log "ERROR" "Failed to mask nvidia-fallback.service." "$RED"
    return 1
  fi
  return 0
}

# Function to update the system
update_system() {
  log "INFO" "Starting full system update..." "$BLUE"
  if sudo dnf update -y; then
    log "SUCCESS" "System update completed successfully." "$GREEN"
  else
    log "ERROR" "System update failed." "$RED"
    return 1
  fi
  return 0
}

# --- Main Script Execution Flow ---

main() {
  # Set strict error handling:
  # -e: Exit immediately if a command exits with a non-zero status.
  # -E: Inherit ERR trap in functions.
  # -u: Treat unset variables as an error.
  # -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status.
  set -eEuo pipefail

  # Trap errors and exit with a FATAL message
  trap 'log "FATAL" "An unexpected error occurred. Exiting." "$RED"; exit 1' ERR
  # Trap SIGINT (Ctrl+C) and exit gracefully
  trap 'log "INFO" "Script execution interrupted by user (Ctrl+C). Exiting." "$YELLOW"; exit 1' INT

  log "INFO" "Starting lean, optimized, and visually enhanced Fedora setup script..." "$BLUE"

  # Execute functions with status logging
  execute_task() {
    local func_name="$1"
    local task_desc="$2"
    log "INFO" "Executing task: $task_desc" "$BLUE"
    if "$func_name"; then
      log "SUCCESS" "$task_desc completed successfully." "$GREEN"
    else
      log "ERROR" "$task_desc failed. Continuing with other steps where possible." "$RED"
      # If a task fails, we log it but don't exit immediately due to `set -e` being carefully managed.
      # However, if the function explicitly returns 1, `execute_task` will propagate that.
    fi
  }

  # --- Pre-flight Checks ---
  execute_task check_root "Root privileges check"
  execute_task check_internet_connection "Internet connectivity check"
  execute_task check_dnf_availability "DNF availability check"
  execute_task refresh_dnf_metadata "DNF cache cleanup and metadata refresh"

  # --- System Configuration and Repository Setup ---
  execute_task setup_dnf_configs "DNF configuration setup"
  execute_task install_rpmfusion "RPM Fusion repositories setup"
  execute_task enable_cisco_openh264 "Cisco OpenH264 setup"
  execute_task enable_copr_repos "COPR repositories setup"
  execute_task set_timezone "Timezone setup to Asia/Dhaka"

  # --- Package Installation ---
  execute_task install_all_dnf_packages "All DNF package installation (groups, system, security, desktop)"

  # --- Post-Installation Configurations ---
  execute_task configure_nvidia "NVIDIA specific configurations"
  execute_task update_system "Final full system update"

  log "SUCCESS" "Fedora setup script finished successfully!" "$GREEN"
}

# Call the main function to start script execution
main
