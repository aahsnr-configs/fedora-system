#!/bin/bash

# This script automates the setup of a Fedora system, integrating various configurations
# into a single, optimized, and idempotent solution.
# It includes:
# - Pre-flight checks (root, internet, DNF availability)
# - System configuration (DNF settings, RPM Fusion, COPR repos, timezone)
# - Core system enhancements (swap file)
# - Package installations (Git, editors, multimedia, general DNF packages)
# - Desktop Environment setup (Hyprland, theming, plugins)
# - Specific hardware/software setups (NVIDIA, Asus laptops, Flatpaks, Tmux, Nix/Home-Manager)
# - Systemd service configurations
# - Post-installation steps (system update)
#
# The script is designed to be idempotent, meaning it can be run multiple times
# without causing issues or re-applying configurations that are already in place.
# It uses robust logging with colors and Unicode symbols for better readability.

# --- Configuration ---
# Define colors for output
RED='\033[0;31m'    # Error
GREEN='\033[0;32m'  # Success
YELLOW='\033[0;33m' # Warning
BLUE='\033[0;34m'   # Info
NC='\\033[0m'       # No Color

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
  "dejan/lazygit"
)

# Swap file configuration
SWAP_SUBVOLUME="/var/swap"
SWAP_FILE_NAME="swapfile"
SWAP_FILE_PATH="${SWAP_SUBVOLUME}/${SWAP_FILE_NAME}"
DRACUT_CONF_FILE="/etc/dracut.conf.d/resume.conf"
FSTAB_ENTRY="${SWAP_FILE_PATH} none swap defaults 0 0"

# --- Helper Functions ---

# Function for logging messages with colors, timestamps, and Unicode symbols
# Arguments:
#   $1: Type of log (e.g., "INFO", "SUCCESS", "ERROR", "WARNING", "FATAL")
#   $2: Message to log
#   $3: Color code (e.g., "$BLUE", "$GREEN")
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
# Returns 0 if files are identical or if destination does not exist, 1 otherwise.
# Arguments:
#   $1: Source file path
#   $2: Destination file path
compare_files() {
  [[ -f "$1" && -f "$2" ]] && cmp -s "$1" "$2"
}

# Function to handle DNF package/repo installation with idempotency
# Usage: dnf_install_idempotent "description" "check_command" "install_command"
# Arguments:
#   $1: Description of the installation task
#   $2: Command to check if the item is already installed/configured (should return 0 for true, non-zero for false)
#   $3: Command to perform the installation/configuration
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
# Arguments:
#   $1: Source file path
#   $2: Destination file path
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
# Arguments:
#   $@: List of packages to install
install_packages() {
  local packages=("$@")
  if [ ${#packages[@]} -eq 0 ]; then
    log "INFO" "No packages to install." "$BLUE"
    return 0
  fi

  # Deduplicate packages to avoid redundant installation attempts
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
  # Check if PRECONFIG_DIR exists
  if [ ! -d "$PRECONFIG_DIR" ]; then
    log "WARNING" "Preconfigured files directory '$PRECONFIG_DIR' not found. Skipping DNF config and variables.sh copy." "$YELLOW"
    return 1
  fi
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

# Function to calculate swap size based on RAM.
# - If RAM < 2GB, swap = 2 * RAM
# - If 2GB <= RAM < 8GB, swap = 1.5 * RAM
# - If RAM >= 8GB, swap = RAM
calculate_swap_size() {
  local mem_total_kb_str
  mem_total_kb_str=$(free | awk '/Mem:/ {print $2}')
  if [[ -z "$mem_total_kb_str" ]]; then
    log "ERROR" "Could not determine total memory. 'free' command output is empty or unexpected." "$RED"
    return 1
  fi

  local mem_total_gb_str
  mem_total_gb_str=$(echo "scale=2; $mem_total_kb_str / 1024 / 1024" | bc -l)

  local swap_size_gb
  if (($(echo "$mem_total_gb_str < 2" | bc -l))); then
    swap_size_gb=$(echo "scale=0; 2 * $mem_total_gb_str / 1" | bc)
  elif (($(echo "$mem_total_gb_str >= 2 && $mem_total_gb_str < 8" | bc -l))); then
    swap_size_gb=$(echo "scale=0; 1.5 * $mem_total_gb_str / 1" | bc)
  else
    swap_size_gb=$(echo "scale=0; $mem_total_gb_str / 1" | bc)
  fi

  # Ensure minimum 1GB swap and round up
  if (($(echo "$swap_size_gb < 1" | bc -l))); then
    swap_size_gb=1
  fi
  echo "${swap_size_gb}G"
  return 0
}

# Function to set up swap file
setup_swap() {
  log "INFO" "Starting swap file setup..." "$BLUE"

  # 1. Determine SWAPSIZE
  log "INFO" "Calculating optimal swap size..." "$BLUE"
  local SWAPSIZE
  SWAPSIZE=$(calculate_swap_size) || return 1
  log "INFO" "Calculated swap size: ${YELLOW}$SWAPSIZE${NC}"

  # 2. Check if Btrfs filesystem is in use for the root.
  log "INFO" "Checking if root filesystem is Btrfs..." "$BLUE"
  if ! findmnt -no FSTYPE / | grep -q btrfs; then
    log "ERROR" "Root filesystem is not Btrfs. This script's swap setup is designed for Btrfs only." "$RED"
    return 1
  fi

  # 3. Create Btrfs subvolume for swap if it doesn't exist
  if [ ! -d "$SWAP_SUBVOLUME" ]; then
    log "INFO" "Creating Btrfs subvolume: ${YELLOW}$SWAP_SUBVOLUME${NC}" "$BLUE"
    sudo btrfs subvolume create "$SWAP_SUBVOLUME" || {
      log "ERROR" "Failed to create Btrfs subvolume." "$RED"
      return 1
    }
  else
    log "INFO" "Btrfs subvolume ${YELLOW}$SWAP_SUBVOLUME${NC} already exists. Skipping creation." "$YELLOW"
  fi

  # 4. Set NoCoW attribute on the subvolume
  # This step is crucial for Btrfs swap files to prevent CoW issues.
  log "INFO" "Setting NoCoW attribute on ${YELLOW}$SWAP_SUBVOLUME${NC}..." "$BLUE"
  if ! sudo chattr +C "$SWAP_SUBVOLUME"; then
    log "ERROR" "Failed to set NoCoW attribute. Ensure your kernel supports +C on Btrfs subvolumes." "$RED"
    return 1
  fi

  # 5. Restore SELinux context if applicable
  if command -v restorecon &>/dev/null; then
    log "INFO" "Restoring SELinux context for ${YELLOW}$SWAP_SUBVOLUME${NC}..." "$BLUE"
    if ! sudo restorecon -Rv "$SWAP_SUBVOLUME"; then
      log "WARNING" "Failed to restore SELinux context. This might indicate an SELinux issue." "$YELLOW"
    fi
  else
    log "WARNING" "restorecon not found, skipping SELinux context restoration. (Only relevant for SELinux enabled systems)" "$YELLOW"
  fi

  # 6. Create swapfile if it doesn't exist and format it
  if [ ! -f "$SWAP_FILE_PATH" ]; then
    log "INFO" "Creating swap file: ${YELLOW}$SWAP_FILE_PATH${NC} with size ${YELLOW}$SWAPSIZE${NC}..." "$BLUE"
    # fallocate is the preferred method on modern systems and with btrfs for pre-allocating space
    if ! sudo fallocate -l "$SWAPSIZE" "$SWAP_FILE_PATH"; then
      log "ERROR" "Failed to create swap file with fallocate. Check disk space or permissions." "$RED"
      return 1
    fi
    log "INFO" "Setting permissions on swap file to 600..." "$BLUE"
    if ! sudo chmod 600 "$SWAP_FILE_PATH"; then
      log "ERROR" "Failed to set permissions on swap file. This is critical for security." "$RED"
      return 1
    fi
    log "INFO" "Formatting swap file..." "$BLUE"
    if ! sudo mkswap -L SWAPFILE "$SWAP_FILE_PATH"; then
      log "ERROR" "Failed to format swap file. Check if it's already in use or corrupted." "$RED"
      return 1
    fi
  else
    log "INFO" "Swap file ${YELLOW}$SWAP_FILE_PATH${NC} already exists. Checking its status." "$YELLOW"
    # Check if it's already a swap signature and active
    if sudo blkid -p -s TYPE -o value "$SWAP_FILE_PATH" | grep -q "swap"; then
      log "INFO" "Swap file is already formatted as swap. Skipping formatting." "$YELLOW"
    else
      log "WARNING" "Existing file is not formatted as swap. Attempting to format." "$YELLOW"
      if ! sudo mkswap -L SWAPFILE "$SWAP_FILE_PATH"; then
        log "ERROR" "Failed to format existing swap file. It might be in use or corrupted." "$RED"
        return 1
      fi
    fi
  fi

  # 7. Add entry to /etc/fstab if not present
  log "INFO" "Adding swap entry to /etc/fstab..." "$BLUE"
  if ! grep -q "^${FSTAB_ENTRY}$" /etc/fstab; then
    log "INFO" "Adding '${YELLOW}$FSTAB_ENTRY${NC}' to /etc/fstab." "$BLUE"
    echo "${FSTAB_ENTRY}" | sudo tee -a /etc/fstab >/dev/null || {
      log "ERROR" "Failed to add swap entry to /etc/fstab." "$RED"
      return 1
    }
  else
    log "INFO" "Swap entry already exists in /etc/fstab. Skipping addition." "$YELLOW"
  fi

  # 8. Activate swap
  log "INFO" "Activating swap..." "$BLUE"
  if ! sudo swapon -av; then
    log "ERROR" "Failed to activate swap. Check /etc/fstab entry or swap file integrity." "$RED"
    return 1
  fi
  log "SUCCESS" "Swap is now ${GREEN}active${NC}." "$GREEN"
  free -h

  # 9. Configure Dracut for resume (if not already configured)
  log "INFO" "Configuring Dracut for resume..." "$BLUE"
  if [ ! -f "$DRACUT_CONF_FILE" ] || ! grep -q "add_dracutmodules+=\" resume \"" "$DRACUT_CONF_FILE"; then
    log "INFO" "Adding resume module to Dracut configuration in ${YELLOW}$DRACUT_CONF_FILE${NC}." "$BLUE"
    echo 'add_dracutmodules+=" resume "' | sudo tee "$DRACUT_CONF_FILE" >/dev/null || {
      log "ERROR" "Failed to configure Dracut." "$RED"
      return 1
    }
  else
    log "INFO" "Dracut resume module already configured. Skipping." "$YELLOW"
  fi

  # 10. Rebuild Dracut initramfs
  log "INFO" "Rebuilding Dracut initramfs. This might take some time..." "$BLUE"
  if ! sudo dracut -f; then
    log "ERROR" "Failed to rebuild Dracut initramfs. Check Dracut logs for errors." "$RED"
    return 1
  fi
  log "SUCCESS" "Dracut initramfs rebuilt ${GREEN}successfully${NC}." "$GREEN"

  log "SUCCESS" "Swap setup complete! Please ${YELLOW}reboot your system${NC} for full effect, especially for suspend-to-disk (resume) functionality." "$GREEN"
  return 0
}

# Function to install Git and configure it
setup_git() {
  log "INFO" "Setting up Git..." "$BLUE"
  local git_packages=(
    git-core
    git-credential-libsecret
    gnome-keyring
    subversion
    git-delta
    highlight
  )
  install_packages "${git_packages[@]}" || return 1

  # Git configurations - check if already set before attempting to set
  log "INFO" "Configuring Git user name and email..." "$BLUE"
  if [[ "$(git config --global user.name)" != "aahsnr" ]]; then
    git config --global user.name "aahsnr"
    log "SUCCESS" "Git user.name set to 'aahsnr'." "$GREEN"
  else
    log "INFO" "Git user.name is already 'aahsnr'." "$YELLOW"
  fi

  if [[ "$(git config --global user.email)" != "ahsanur041@proton.me" ]]; then
    git config --global user.email "ahsanur041@proton.me"
    log "SUCCESS" "Git user.email set to 'ahsanur041@proton.me'." "$GREEN"
  else
    log "INFO" "Git user.email is already 'ahsanur041@proton.me'." "$YELLOW"
  fi

  if [[ "$(git config --global credential.helper)" != "/usr/libexec/git-core/git-credential-libsecret" ]]; then
    git config --global credential.helper /usr/libexec/git-core/git-credential-libsecret
    log "SUCCESS" "Git credential.helper set." "$GREEN"
  else
    log "INFO" "Git credential.helper is already set." "$YELLOW"
  fi

  # Other Git global configurations (these are generally safe to re-apply)
  log "INFO" "Setting other Git global configurations..." "$BLUE"
  git config --global core.preloadindex true
  git config --global core.fscache true
  git config --global gc.auto 256
  log "SUCCESS" "Other Git configurations applied." "$GREEN"

  return 0
}

# Function to install editors and related tools
setup_editors() {
  log "INFO" "Setting up Editors and related tools..." "$BLUE"
  local editor_packages=(
    emacs
    nodejs
    npm
    yarnpkg
    fzf
    fd-find
    ripgrep
    neovim
    python3-neovim
    tree-sitter-cli
    wl-clipboard
    shfmt
    ImageMagick
    hunspell
    hunspell-en-US
    pyright
    pylint
    black
    isort
    debugpy
    stix-fonts
    google-noto-sans-fonts
    google-noto-color-emoji-fonts
    bash-language-server
    ansible
    direnv
    clang-tools-extra
    fprettify
    fortls
    gfortran
    grip
    shellcheck
    java
    jetbrains-mono-fonts-all
    conda
    pipx         # Added for stylepak
    python3-pipx # Added for stylepak
  )
  install_packages "${editor_packages[@]}" || return 1
  return 0
}

# Function to install media-related packages
setup_multimedia() {
  log "INFO" "Installing Media-Related packages..." "$BLUE"

  # Update @multimedia group without weak dependencies and excluding PackageKit-gstreamer-plugin
  log "INFO" "Updating @multimedia group..." "$BLUE"
  if sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y; then
    log "SUCCESS" "@multimedia group updated successfully." "$GREEN"
  else
    log "ERROR" "Failed to update @multimedia group." "$RED"
    return 1
  fi

  local media_packages=(
    alsa-utils
    pipewire
    pipewire-alsa
    pipewire-gstreamer
    pipewire-pulseaudio
    pipewire-utils
    pulseaudio-utils
    wireplumber
    libva-nvidia-driver
    mesa-vdpau-drivers-freeworld
    mesa-va-drivers-freeworld
    nvidia-vaapi-driver
    mesa-vulkan-drivers
    vulkan-tools
    ffmpeg
    mediainfo
  )
  install_packages "${media_packages[@]}" || return 1

  log "INFO" "Installing rpmfusion-nonfree-release-tainted and firmware..." "$BLUE"
  # Install rpmfusion-nonfree-release-tainted
  dnf_install_idempotent \
    "RPM Fusion Nonfree Tainted repository" \
    "dnf repolist enabled | grep -q 'rpmfusion-nonfree-tainted'" \
    "sudo dnf install -y rpmfusion-nonfree-release-tainted" || return 1

  # Install tainted firmware
  log "INFO" "Installing tainted firmware..." "$BLUE"
  # Check if any firmware from this repo is already installed
  if rpm -qa | grep -q "*-firmware-"; then # A more general check for installed firmware packages
    log "INFO" "Some tainted firmware packages appear to be already installed." "$YELLOW"
  fi
  # We still try to install to ensure all are present, dnf is idempotent for packages.
  if sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware" -y; then
    log "SUCCESS" "Tainted firmware installed successfully." "$GREEN"
  else
    log "ERROR" "Failed to install tainted firmware." "$RED"
    return 1
  fi

  return 0
}

# Function to install all general DNF packages
install_all_dnf_packages() {
  log "INFO" "Starting installation of all general DNF packages..." "$BLUE"

  # Combined, deduplicated, and sorted list of all packages.
  # Packages handled by setup_git, setup_editors, setup_multimedia, setup_hyprland are EXCLUDED here.
  # @multimedia is also excluded as it's handled specifically in setup_multimedia.
  local all_packages=(
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
    bluez
    brightnessctl
    btop
    byacc
    cairo-devel
    ccache
    cava
    checkpolicy
    chrony
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
    glaze-devel
    glib2
    glx-utils
    gmock
    gnome-software
    gnuplot
    groff-base
    gsl
    gsl-devel
    gtest
    gtk-layer-shell-devel
    gtk3-devel
    greetd
    grim
    haveged
    hwdata-devel
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
    mock
    mokutil
    NetworkManager-tui
    nvidia-gpu-firmware
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
    wayland-protocols-devel
    wget
    wxMaxima
    xcb-util-devel
    xcb-util-errors-devel
    xcb-util-renderutil-devel
    xcb-util-wm-devel
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    xhtml1-dtds
    xisxwayland
    xmlto
    xorg-x11-drv-nvidia-cuda
    xorg-x11-drv-nvidia-cuda-libs
    xorg-x11-server-Xwayland-devel
    xournalpp
    xcur2png
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
    gcc
    gcc-c++
  )

  install_packages "${all_packages[@]}" || return 1
  return 0
}

# Function for NVIDIA specific configurations
configure_nvidia() {
  log "INFO" "Starting NVIDIA specific configurations..." "$BLUE"

  log "INFO" "Marking akmod-nvidia as user-managed..." "$BLUE"
  # Check if akmod-nvidia is already marked user-managed
  if dnf repoquery --userinstalled akmod-nvidia &>/dev/null; then
    log "INFO" "akmod-nvidia is already marked as user-managed." "$YELLOW"
  elif sudo dnf mark user akmod-nvidia; then
    log "SUCCESS" "akmod-nvidia marked as user-managed." "$GREEN"
  else
    log "ERROR" "Failed to mark akmod-nvidia as user-managed." "$RED"
    return 1
  fi

  log "INFO" "Enabling NVIDIA suspend, resume, and hibernate services..." "$BLUE"
  local nvidia_services=(nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service)
  local all_nvidia_services_enabled=true
  for service in "${nvidia_services[@]}"; do
    if sudo systemctl is-enabled "$service" &>/dev/null; then
      log "INFO" "$service is already enabled." "$YELLOW"
    elif sudo systemctl enable "$service"; then
      log "SUCCESS" "$service enabled." "$GREEN"
    else
      log "ERROR" "Failed to enable $service." "$RED"
      all_nvidia_services_enabled=false
    fi
  done
  "$all_nvidia_services_enabled" || return 1

  log "INFO" "Creating RPM macro for NVIDIA kmod..." "$BLUE"
  local macro_file="/etc/rpm/macros.nvidia-kmod"
  if [[ -f "$macro_file" && "$(cat "$macro_file")" == "%_with_kmod_nvidia_open 1" ]]; then
    log "INFO" "RPM macro for NVIDIA kmod already exists and is correct." "$YELLOW"
  elif sudo sh -c 'echo "%_with_kmod_nvidia_open 1" > /etc/rpm/macros.nvidia-kmod'; then
    log "SUCCESS" "RPM macro for NVIDIA kmod created." "$GREEN"
  else
    log "ERROR" "Failed to create RPM macro for NVIDIA kmod." "$RED"
    return 1
  fi

  log "INFO" "Rebuilding NVIDIA akmods for current kernel..." "$BLUE"
  # Check if the NVIDIA kernel module is already built and present for the current kernel
  if ls /lib/modules/"$(uname -r)"/extra/nvidia/nvidia.ko &>/dev/null; then
    log "INFO" "NVIDIA akmods for current kernel already built." "$YELLOW"
  elif sudo akmods --kernels "$(uname -r)" --rebuild; then
    log "SUCCESS" "NVIDIA akmods rebuilt successfully." "$GREEN"
  else
    log "ERROR" "Failed to rebuild NVIDIA akmods." "$RED"
    return 1
  fi

  log "INFO" "Masking nvidia-fallback.service..." "$BLUE"
  if sudo systemctl is-masked nvidia-fallback.service &>/dev/null; then
    log "INFO" "nvidia-fallback.service is already masked." "$YELLOW"
  elif sudo systemctl mask nvidia-fallback.service; then
    log "SUCCESS" "nvidia-fallback.service masked." "$GREEN"
  else
    log "ERROR" "Failed to mask nvidia-fallback.service." "$RED"
    return 1
  fi
  return 0
}

# Function to setup Asus specific utilities
setup_asus_laptops() {
  log "INFO" "Setting up for Asus Laptops..." "$BLUE"
  local asus_packages=(
    asusctl
    power-profiles-daemon
    supergfxctl
    asusctl-rog-gui
  )
  install_packages "${asus_packages[@]}" || return 1

  log "INFO" "Enabling supergfxd and power-profiles-daemon services..." "$BLUE"
  local asus_services=(supergfxd power-profiles-daemon)
  local all_asus_services_enabled=true
  for service in "${asus_services[@]}"; do
    if sudo systemctl is-enabled "$service" &>/dev/null; then
      log "INFO" "$service is already enabled." "$YELLOW"
    elif sudo systemctl enable "$service"; then
      log "SUCCESS" "$service enabled." "$GREEN"
    else
      log "ERROR" "Failed to enable $service." "$RED"
      all_asus_services_enabled=false
    fi
  done
  "$all_asus_services_enabled" || return 1
  return 0
}

# Function to setup Flatpak
setup_flatpaks() {
  log "INFO" "Setting up Flatpak and installing applications..." "$BLUE"

  dnf_install_idempotent \
    "Flatpak package manager" \
    "command -v flatpak &>/dev/null" \
    "sudo dnf install -y flatpak" || return 1

  log "INFO" "Removing system-wide Flatpak remotes..." "$BLUE"
  local system_remotes=(fedora flathub-beta flathub)
  for remote in "${system_remotes[@]}"; do
    if flatpak remote-list --system | grep -q "$remote"; then
      log "INFO" "Removing system remote '$remote'..." "$YELLOW"
      if sudo flatpak remote-delete --system "$remote"; then
        log "SUCCESS" "System remote '$remote' removed." "$GREEN"
      else
        log "WARNING" "Failed to remove system remote '$remote'. It might not exist or an error occurred." "$YELLOW"
      fi
    else
      log "INFO" "System remote '$remote' does not exist. Skipping." "$YELLOW"
    fi
  done

  log "INFO" "Removing user-wide flathub remote if it exists..." "$BLUE"
  if flatpak remote-list --user | grep -q "flathub"; then
    log "INFO" "Removing user remote 'flathub'..." "$YELLOW"
    if flatpak remote-delete --user flathub; then
      log "SUCCESS" "User remote 'flathub' removed." "$GREEN"
    else
      log "WARNING" "Failed to remove user remote 'flathub'. It might not exist or an error occurred." "$YELLOW"
    fi
  else
    log "INFO" "User remote 'flathub' does not exist. Skipping." "$YELLOW"
  fi

  log "INFO" "Adding user-wide Flathub remote..." "$BLUE"
  dnf_install_idempotent \
    "User-wide Flathub remote" \
    "flatpak remote-list --user | grep -q 'flathub'" \
    "flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo" || return 1

  log "INFO" "Installing Flatpak applications..." "$BLUE"
  local flatpak_apps=(
    com.ticktick.TickTick
    org.onlyoffice.desktopeditors
    com.github.tchx84.Flatseal
    org.js.nuclear.Nuclear
    tv.kodi.Kodi
    com.bitwarden.desktop
    io.github.alainm23.planify
    com.ranfdev.DistroShelf
    com.dec05eba.gpu_screen_recorder
  )

  local all_flatpak_installed=true
  for app in "${flatpak_apps[@]}"; do
    if flatpak info "$app" &>/dev/null; then
      log "INFO" "Flatpak app '$app' is already installed." "$YELLOW"
    else
      log "INFO" "Installing Flatpak app '$app'..." "$BLUE"
      # Using --noninteractive to avoid interactive prompts
      if flatpak install flathub "$app" -y --noninteractive; then
        log "SUCCESS" "Flatpak app '$app' installed successfully." "$GREEN"
      else
        log "ERROR" "Failed to install Flatpak app '$app'." "$RED"
        all_flatpak_installed=false
      fi
    fi
  done
  "$all_flatpak_installed" || return 1
  return 0
}

# Function to setup Tmux
setup_tmux() {
  log "INFO" "Setting up tmux..." "$BLUE"
  local tmux_config_file="$HOME/.hyprdots/.tmux.conf"

  # Install required packages (tmux, git, curl, wl-clipboard are already handled by other functions, but re-list for clarity if this were standalone)
  local tmux_dependencies=(
    tmux
    git
    curl
    wl-clipboard
  )
  install_packages "${tmux_dependencies[@]}" || return 1

  # Create tmux directories
  log "INFO" "Creating tmux directories..." "$BLUE"
  if mkdir -p ~/.tmux/plugins && chmod 700 ~/.tmux; then
    log "SUCCESS" "Tmux directories created and permissions set." "$GREEN"
  else
    log "ERROR" "Failed to create tmux directories or set permissions." "$RED"
    return 1
  fi

  # Backup existing tmux config if it exists and is not our symlink
  if [[ -f ~/.tmux.conf && ! -L ~/.tmux.conf ]]; then
    log "INFO" "Backing up existing ~/.tmux.conf..." "$YELLOW"
    if mv ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S); then
      log "SUCCESS" "Existing ~/.tmux.conf backed up." "$GREEN"
    else
      log "ERROR" "Failed to backup existing ~/.tmux.conf." "$RED"
      return 1
    fi
  elif [[ -L ~/.tmux.conf && "$(readlink ~/.tmux.conf)" != "$tmux_config_file" ]]; then
    log "INFO" "Removing old symlink for ~/.tmux.conf..." "$YELLOW"
    if rm ~/.tmux.conf; then
      log "SUCCESS" "Old symlink for ~/.tmux.conf removed." "$GREEN"
    else
      log "ERROR" "Failed to remove old symlink for ~/.tmux.conf." "$RED"
      return 1
    fi
  fi

  # Symlink tmux configuration
  log "INFO" "Setting up tmux configuration symlink..." "$BLUE"
  if [ ! -f "$tmux_config_file" ]; then
    log "ERROR" "tmux configuration file not found at '$tmux_config_file'. Please ensure it exists." "$RED"
    return 1
  fi

  if [[ ! -L ~/.tmux.conf || "$(readlink ~/.tmux.conf)" != "$tmux_config_file" ]]; then
    if ln -sf "$tmux_config_file" ~/.tmux.conf && chmod 600 ~/.tmux.conf; then
      log "SUCCESS" "Symlinked $tmux_config_file to ~/.tmux.conf." "$GREEN"
    else
      log "ERROR" "Failed to symlink $tmux_config_file to ~/.tmux.conf." "$RED"
      return 1
    fi
  else
    log "INFO" "~/.tmux.conf is already symlinked correctly to $tmux_config_file." "$YELLOW"
  fi

  # Install TPM (tmux Plugin Manager)
  log "INFO" "Installing TPM (tmux Plugin Manager)..." "$BLUE"
  if [ -d ~/.tmux/plugins/tpm ]; then
    log "INFO" "TPM already exists, updating..." "$YELLOW"
    if (cd ~/.tmux/plugins/tpm && git pull); then
      log "SUCCESS" "TPM updated." "$GREEN"
    else
      log "ERROR" "Failed to update TPM." "$RED"
      return 1
    fi
  else
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; then
      log "SUCCESS" "TPM installed." "$GREEN"
    else
      log "ERROR" "Failed to install TPM." "$RED"
      return 1
    fi
  fi

  # Start tmux in detached mode to install plugins
  log "INFO" "Installing tmux plugins..." "$BLUE"
  if tmux new-session -d -s setup_session; then
    sleep 2 # Give tmux a moment to start
    if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
      tmux send-keys -t setup_session "$HOME/.tmux/plugins/tpm/bin/install_plugins" Enter
      sleep 10 # Wait for installation to complete
      log "SUCCESS" "Tmux plugins installation command sent." "$GREEN"
    else
      log "WARNING" "TPM install script not found, plugins may need manual installation (Ctrl-a + I)." "$YELLOW"
    fi
    tmux kill-session -t setup_session 2>/dev/null || true
  else
    log "ERROR" "Failed to start tmux session for plugin installation." "$RED"
    return 1
  fi

  # Create systemd user service
  log "INFO" "Creating systemd user service for tmux..." "$BLUE"
  if mkdir -p ~/.config/systemd/user; then
    if ! cmp -s <(
      cat <<'EOF'
[Unit]
Description=tmux default session (detached)
Documentation=man:tmux(1)
After=graphical-session.target

[Service]
Type=forking
WorkingDirectory=%h
ExecStart=/usr/bin/tmux new-session -d -s main
ExecStop=/usr/bin/tmux kill-session -t main
KillMode=none
Restart=on-failure

[Install]
WantedBy=default.target
EOF
    ) ~/.config/systemd/user/tmux.service; then
      cat >~/.config/systemd/user/tmux.service <<'EOF'
[Unit]
Description=tmux default session (detached)
Documentation=man:tmux(1)
After=graphical-session.target

[Service]
Type=forking
WorkingDirectory=%h
ExecStart=/usr/bin/tmux new-session -d -s main
ExecStop=/usr/bin/tmux kill-session -t main
KillMode=none
Restart=on-failure

[Install]
WantedBy=default.target
EOF
      log "SUCCESS" "Tmux systemd service file created/updated." "$GREEN"
    else
      log "INFO" "Tmux systemd service file is already up-to-date." "$YELLOW"
    fi
  else
    log "ERROR" "Failed to create ~/.config/systemd/user directory." "$RED"
    return 1
  fi

  # Enable and start tmux service
  log "INFO" "Enabling and starting tmux systemd service..." "$BLUE"
  systemctl --user daemon-reload
  if systemctl --user enable tmux.service && systemctl --user start tmux.service; then
    log "SUCCESS" "Tmux systemd service enabled and started." "$GREEN"
  else
    log "ERROR" "Failed to enable or start tmux systemd service." "$RED"
    return 1
  fi

  # Add useful aliases to bashrc (idempotent check)
  log "INFO" "Adding tmux aliases to ~/.bashrc..." "$BLUE"
  if ! grep -q "# tmux aliases" ~/.bashrc 2>/dev/null; then
    cat >>~/.bashrc <<'EOF'

# tmux aliases
alias tm='tmux'
alias tma='tmux attach -t'
alias tmn='tmux new-session -s'
alias tml='tmux list-sessions'
alias tmk='tmux kill-session -t'
alias tmr='tmux source-file ~/.tmux.conf'
EOF
    log "SUCCESS" "Tmux aliases added to ~/.bashrc." "$GREEN"
  else
    log "INFO" "Tmux aliases already present in ~/.bashrc." "$YELLOW"
  fi

  return 0
}

# Function to setup Nix and Home-Manager
setup_nix() {
  log "INFO" "Starting Nix and Home-Manager Installation Script..." "$BLUE"

  # Check if curl is available (already handled in pre-flight, but good for standalone function)
  if ! command -v curl &>/dev/null; then
    log "ERROR" "'curl' is not installed. Please install it to proceed with Nix setup." "$RED"
    return 1
  fi

  # Install Nix package manager
  log "INFO" "Attempting to install Nix package manager using Determinate Systems installer..." "$BLUE"
  if ! command -v nix &>/dev/null; then
    log "INFO" "Running Determinate Systems Nix installer. This might take a few minutes." "$YELLOW"
    if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate; then
      log "SUCCESS" "Nix installation command executed successfully." "$GREEN"
    else
      log "ERROR" "Nix installation failed. Please check the output above for details." "$RED"
      return 1
    fi
  else
    log "INFO" "Nix is already installed. Skipping installation." "$YELLOW"
  fi

  # Source Nix profile for current session
  log "INFO" "Attempting to source Nix profile for current session..." "$BLUE"
  local nix_profile_path="$HOME/.nix-profile/etc/profile.d/nix.sh"
  if [ -f "$nix_profile_path" ]; then
    source "$nix_profile_path"
    log "SUCCESS" "Nix profile sourced successfully." "$GREEN"
  else
    log "WARNING" "Nix profile script not found at $nix_profile_path. This might happen if the installer placed it elsewhere or if there was an issue. You may need to restart your terminal or manually source your shell configuration (e.g., 'source ~/.bashrc' or 'source ~/.profile') for 'nix' commands to be available." "$YELLOW"
  fi

  # Verify Nix is available
  if ! command -v nix &>/dev/null; then
    log "ERROR" "'nix' command is not available even after attempting to source profile. Exiting Nix setup." "$RED"
    return 1
  else
    log "INFO" "'nix' command is available." "$GREEN"
  fi

  # Set up Home-Manager and flakes
  log "INFO" "Setting up Home-Manager and flakes..." "$BLUE"
  if ! command -v home-manager &>/dev/null; then
    log "INFO" "Initializing Home-Manager for the first time." "$YELLOW"
    if nix run home-manager/master -- init --switch; then
      log "SUCCESS" "Home-Manager initialized successfully." "$GREEN"
    else
      log "ERROR" "Home-Manager initialization failed. Please check the output." "$RED"
      return 1
    fi
  else
    log "INFO" "Home-Manager is already initialized. Skipping initialization." "$YELLOW"
  fi

  # Handle directory symlinking for Home-Manager config
  log "INFO" "Handling Home-Manager configuration directory symlinking..." "$BLUE"
  local config_home_manager_dir="$HOME/.config/home-manager"
  local hyprdots_home_manager_dir="$HOME/.hyprdots/.config/home-manager"

  if [ -d "$config_home_manager_dir" ] && [ ! -L "$config_home_manager_dir" ]; then
    log "WARNING" "Found existing directory $config_home_manager_dir. Removing it to create symlink." "$YELLOW"
    if rm -rf "$config_home_manager_dir"; then
      log "SUCCESS" "$config_home_manager_dir directory removed." "$GREEN"
    else
      log "ERROR" "Failed to remove existing directory $config_home_manager_dir." "$RED"
      return 1
    fi
  elif [ -L "$config_home_manager_dir" ] && [ "$(readlink "$config_home_manager_dir")" != "$hyprdots_home_manager_dir" ]; then
    log "WARNING" "Found existing symlink $config_home_manager_dir pointing elsewhere. Removing it." "$YELLOW"
    if rm "$config_home_manager_dir"; then
      log "SUCCESS" "Old symlink $config_home_manager_dir removed." "$GREEN"
    else
      log "ERROR" "Failed to remove old symlink $config_home_manager_dir." "$RED"
      return 1
    fi
  elif [ -L "$config_home_manager_dir" ] && [ "$(readlink "$config_home_manager_dir")" == "$hyprdots_home_manager_dir" ]; then
    log "INFO" "$config_home_manager_dir is already symlinked correctly to $hyprdots_home_manager_dir. Skipping removal." "$YELLOW"
  else
    log "INFO" "$config_home_manager_dir does not exist or is not a conflicting symlink. Proceeding." "$BLUE"
  fi

  log "INFO" "Ensuring parent directory for $hyprdots_home_manager_dir exists..." "$BLUE"
  if mkdir -p "$(dirname "$hyprdots_home_manager_dir")"; then
    log "SUCCESS" "Parent directory created/exists." "$GREEN"
  else
    log "ERROR" "Failed to create parent directory for $hyprdots_home_manager_dir." "$RED"
    return 1
  fi

  if [ ! -L "$config_home_manager_dir" ] || [ "$(readlink "$config_home_manager_dir")" != "$hyprdots_home_manager_dir" ]; then
    log "INFO" "Creating symlink from $config_home_manager_dir to $hyprdots_home_manager_dir..." "$BLUE"
    if ln -s "$hyprdots_home_manager_dir" "$config_home_manager_dir"; then
      log "SUCCESS" "Symlink created successfully." "$GREEN"
    else
      log "ERROR" "Failed to create symlink." "$RED"
      return 1
    fi
  else
    log "INFO" "Symlink already exists and points correctly. Skipping symlink creation." "$YELLOW"
  fi

  # Install all required packages using home-manager switch
  log "INFO" "Installing/updating required packages with Home-Manager switch..." "$BLUE"
  if home-manager switch; then
    log "SUCCESS" "Home-Manager switch completed successfully. Your environment should now be configured." "$GREEN"
  else
    log "ERROR" "Home-Manager switch failed. Please check your home.nix and the output above." "$RED"
    return 1
  fi

  log "INFO" "Nix and Home-Manager setup completed. Please restart your terminal or log out and log back in to ensure all changes take effect." "$YELLOW"
  return 0
}

# Function to install GTK/Icon themes
install_theming() {
  log "INFO" "Installing GTK3/GTK4 theme..." "$BLUE"

  local theme_deps=(sassc gtk-murrine-engine gnome-themes-extra ostree libappstream-glib)
  install_packages "${theme_deps[@]}" || return 1

  local colloid_gtk_theme_repo="https://github.com/vinceliuice/Colloid-gtk-theme.git"
  local colloid_gtk_theme_dir="$HOME/Colloid-gtk-theme"

  if [ ! -d "$colloid_gtk_theme_dir" ]; then
    log "INFO" "Cloning Colloid-gtk-theme..." "$BLUE"
    if git clone "$colloid_gtk_theme_repo" "$colloid_gtk_theme_dir"; then
      log "SUCCESS" "Colloid-gtk-theme cloned." "$GREEN"
    else
      log "ERROR" "Failed to clone Colloid-gtk-theme." "$RED"
      return 1
    fi
  else
    log "INFO" "Colloid-gtk-theme directory already exists. Skipping clone." "$YELLOW"
  fi

  log "INFO" "Installing Colloid-gtk-theme..." "$BLUE"
  if [ -f "$colloid_gtk_theme_dir/install.sh" ]; then
    # Check if the theme is already installed by looking for the theme directory
    if [ -d "/usr/share/themes/Colloid-Dark-Catppuccin" ]; then
      log "INFO" "Colloid-Dark-Catppuccin GTK theme appears to be already installed. Skipping installation." "$YELLOW"
    else
      if (cd "$colloid_gtk_theme_dir" && sudo ./install.sh -l --tweaks catppuccin --tweaks normal); then
        log "SUCCESS" "Colloid-gtk-theme installed." "$GREEN"
      else
        log "ERROR" "Failed to install Colloid-gtk-theme." "$RED"
        return 1
      fi
    fi
  else
    log "ERROR" "Colloid-gtk-theme install script not found." "$RED"
    return 1
  fi

  log "INFO" "Cleaning up Colloid-gtk-theme directory..." "$BLUE"
  if sudo rm -rf "$colloid_gtk_theme_dir"; then
    log "SUCCESS" "Colloid-gtk-theme directory removed." "$GREEN"
  else
    log "WARNING" "Failed to remove Colloid-gtk-theme directory. Manual cleanup may be needed." "$YELLOW"
  fi

  log "INFO" "Installing Icon Theme..." "$BLUE"
  local colloid_icon_theme_repo="https://github.com/vinceliuice/Colloid-icon-theme.git"
  local colloid_icon_theme_dir="$HOME/Colloid-icon-theme"

  if [ ! -d "$colloid_icon_theme_dir" ]; then
    log "INFO" "Cloning Colloid-icon-theme..." "$BLUE"
    if git clone "$colloid_icon_theme_repo" "$colloid_icon_theme_dir"; then
      log "SUCCESS" "Colloid-icon-theme cloned." "$GREEN"
    else
      log "ERROR" "Failed to clone Colloid-icon-theme." "$RED"
      return 1
    fi
  else
    log "INFO" "Colloid-icon-theme directory already exists. Skipping clone." "$YELLOW"
  fi

  log "INFO" "Installing Colloid-icon-theme..." "$BLUE"
  if [ -f "$colloid_icon_theme_dir/install.sh" ]; then
    # Check if the icon theme is already installed
    if [ -d "/usr/share/icons/Colloid-Catppuccin-Orange-Dark" ]; then
      log "INFO" "Colloid-Catppuccin-Orange-Dark icon theme appears to be already installed. Skipping installation." "$YELLOW"
    else
      if (cd "$colloid_icon_theme_dir" && sudo ./install.sh -s catppuccin -t orange); then
        log "SUCCESS" "Colloid-icon-theme installed." "$GREEN"
      else
        log "ERROR" "Failed to install Colloid-icon-theme." "$RED"
        return 1
      fi
    fi
  else
    log "ERROR" "Colloid-icon-theme install script not found." "$RED"
    return 1
  fi

  log "INFO" "Cleaning up Colloid-icon-theme directory..." "$BLUE"
  if sudo rm -rf "$colloid_icon_theme_dir"; then
    log "SUCCESS" "Colloid-icon-theme directory removed." "$GREEN"
  else
    log "WARNING" "Failed to remove Colloid-icon-theme directory. Manual cleanup may be needed." "$YELLOW"
  fi

  log "INFO" "Applying Flatpak overrides for theming..." "$BLUE"
  local flatpak_overrides=(
    "--filesystem=~/.themes"
    "--filesystem=~/.local/share/themes"
    "--env=GTK_THEME=Colloid-Dark-Catppuccin"
  )
  local all_overrides_applied=true
  for override in "${flatpak_overrides[@]}"; do
    log "INFO" "Applying flatpak override: flatpak override --user $override" "$BLUE"
    if flatpak override --user "$override"; then # Changed to --user
      log "SUCCESS" "Flatpak override '$override' applied." "$GREEN"
    else
      log "ERROR" "Failed to apply flatpak override '$override'." "$RED"
      all_overrides_applied=false
    fi
  done
  "$all_overrides_applied" || return 1

  log "INFO" "Installing system-wide Colloid-Dark-Catppuccin stylepak (requires pipx)..." "$BLUE"
  if command -v pipx &>/dev/null; then
    if ! pipx list | grep -q "stylepak"; then
      log "INFO" "Installing stylepak via pipx..." "$BLUE"
      if pipx install stylepak; then
        log "SUCCESS" "stylepak installed via pipx." "$GREEN"
      else
        log "ERROR" "Failed to install stylepak via pipx." "$RED"
        return 1
      fi
    else
      log "INFO" "stylepak is already installed via pipx. Skipping installation." "$YELLOW"
    fi

    if stylepak list-system | grep -q "Colloid-Dark-Catppuccin"; then
      log "INFO" "Colloid-Dark-Catppuccin stylepak already installed system-wide. Skipping." "$YELLOW"
    else
      if sudo stylepak install-system Colloid-Dark-Catppuccin; then
        log "SUCCESS" "Colloid-Dark-Catppuccin stylepak installed system-wide." "$GREEN"
      else
        log "ERROR" "Failed to install Colloid-Dark-Catppuccin stylepak system-wide." "$RED"
        return 1
      fi
    fi
  else
    log "WARNING" "pipx command not found. Skipping system-wide stylepak installation." "$YELLOW"
  fi

  log "SUCCESS" "Theming setup complete." "$GREEN"
  return 0
}

# Function to setup Hyprland and its plugins
setup_hyprland() {
  log "INFO" "Starting Hyprland Desktop Environment Setup and Plugins..." "$BLUE"

  local hyprland_packages=(
    hyprland-git
    hypridle
    hyprpaper
    hyprlock
    hyprpicker
    hyprshot
    hyprsunset
    hyprcursor-devel
    hyprgraphics-devel
    hyprlang-devel
    hyprland-contrib
    pyprland
    xdg-desktop-portal-hyprland
  )
  install_packages "${hyprland_packages[@]}" || return 1

  log "INFO" "Installing Hyprland plugins..." "$BLUE"
  if ! command -v hyprpm &>/dev/null; then
    log "ERROR" "hyprpm command not found. Please ensure hyprpm is installed (usually comes with hyprland-git)." "$RED"
    return 1
  fi

  log "INFO" "Updating hyprpm..." "$BLUE"
  if hyprpm update; then
    log "SUCCESS" "hyprpm updated." "$GREEN"
  else
    log "WARNING" "Failed to update hyprpm. Continuing anyway." "$YELLOW"
  fi

  local plugins=(
    "https://github.com/KZDKM/Hyprspace"
    "https://github.com/outfoxxed/hy3"
  )

  for plugin_url in "${plugins[@]}"; do
    local plugin_name=$(basename "$plugin_url")                # e.g., Hyprspace or hy3
    local plugin_dir="$HOME/.config/hypr/plugins/$plugin_name" # Common hyprpm plugin location

    log "INFO" "Processing plugin: $plugin_name from $plugin_url" "$BLUE"

    # Check if the plugin directory exists as a basic idempotency check for 'add'
    if [ -d "$plugin_dir" ]; then
      log "INFO" "Plugin directory '$plugin_name' already exists. Assuming plugin is added." "$YELLOW"
    else
      log "INFO" "Adding plugin: $plugin_name..." "$BLUE"
      if hyprpm add "$plugin_url"; then
        log "SUCCESS" "Plugin '$plugin_name' added." "$GREEN"
      else
        log "ERROR" "Failed to add plugin '$plugin_name'." "$RED"
        return 1
      fi
    fi

    # Enable plugin (hyprpm enable seems idempotent)
    if [[ "$plugin_name" == "Hyprspace" ]]; then # Only Hyprspace explicitly mentioned enable
      log "INFO" "Enabling plugin: $plugin_name..." "$BLUE"
      if hyprpm enable "$plugin_name"; then
        log "SUCCESS" "Plugin '$plugin_name' enabled." "$GREEN"
      else
        log "ERROR" "Failed to enable plugin '$plugin_name'." "$RED"
        return 1
      fi
    fi
  done

  log "INFO" "Final hyprpm update after plugin operations..." "$BLUE"
  if hyprpm update; then
    log "SUCCESS" "Final hyprpm update completed." "$GREEN"
  else
    log "WARNING" "Final hyprpm update failed. Continuing anyway." "$YELLOW"
  fi

  log "INFO" "Enabling and starting Hyprland-related user services..." "$BLUE"
  local hyprland_user_services=(
    hyprpolkitagent
    hyprpaper
    hypridle
  )
  local all_hyprland_user_services_enabled=true
  for service in "${hyprland_user_services[@]}"; do
    if systemctl --user is-enabled "$service" &>/dev/null && systemctl --user is-active "$service" &>/dev/null; then
      log "INFO" "User service '$service' is already enabled and active." "$YELLOW"
    else
      log "INFO" "Enabling and starting user service '$service'..." "$BLUE"
      if systemctl --user enable --now "$service"; then
        log "SUCCESS" "User service '$service' enabled and started." "$GREEN"
      else
        log "ERROR" "Failed to enable or start user service '$service'." "$RED"
        all_hyprland_user_services_enabled=false
      fi
    fi
  done
  "$all_hyprland_user_services_enabled" || return 1

  log "SUCCESS" "Hyprland Desktop Environment Setup and Plugins complete." "$GREEN"
  return 0
}

# Function to configure general Systemd services
configure_systemd_services_general() {
  log "INFO" "Configuring general Systemd services..." "$BLUE"

  log "INFO" "Reloading user daemon..." "$BLUE"
  if systemctl --user daemon-reload; then
    log "SUCCESS" "User daemon reloaded." "$GREEN"
  else
    log "ERROR" "Failed to reload user daemon." "$RED"
    return 1
  fi

  # Services not specific to Hyprland, or already handled by other functions
  local user_services=(
    wireplumber.service
    pipewire-pulse.socket
    pipewire.socket
    pipewire-pulse.service
    pipewire.service
    gnome-keyring-daemon # Fixed typo here
  )

  log "INFO" "Enabling and starting remaining user services..." "$BLUE"
  local all_user_services_enabled=true
  for service in "${user_services[@]}"; do
    if systemctl --user is-enabled "$service" &>/dev/null && systemctl --user is-active "$service" &>/dev/null; then
      log "INFO" "User service '$service' is already enabled and active." "$YELLOW"
    else
      log "INFO" "Enabling and starting user service '$service'..." "$BLUE"
      if systemctl --user enable --now "$service"; then
        log "SUCCESS" "User service '$service' enabled and started." "$GREEN"
      else
        log "ERROR" "Failed to enable or start user service '$service'." "$RED"
        all_user_services_enabled=false
      fi
    fi
  done
  "$all_user_services_enabled" || return 1

  local system_services=(
    haveged
    rngd
    pmcd
    pmlogger
  )

  log "INFO" "Enabling and starting system services..." "$BLUE"
  local all_system_services_enabled=true
  for service in "${system_services[@]}"; do
    if sudo systemctl is-enabled "$service" &>/dev/null && sudo systemctl is-active "$service" &>/dev/null; then
      log "INFO" "System service '$service' is already enabled and active." "$YELLOW"
    else
      log "INFO" "Enabling and starting system service '$service'..." "$BLUE"
      if sudo systemctl enable --now "$service"; then
        log "SUCCESS" "System service '$service' enabled and started." "$GREEN"
      else
        log "ERROR" "Failed to enable or start system service '$service'." "$RED"
        all_system_services_enabled=false
      fi
    fi
  done
  "$all_system_services_enabled" || return 1

  log "SUCCESS" "General Systemd services configuration complete." "$GREEN"
  return 0
}

# Function to update the system
update_system() {
  log "INFO" "Starting full system update..." "$BLUE"
  if sudo dnf update -y; then
    log "SUCCESS" "System update completed successfully." "$GREEN"
    return 0
  else
    log "ERROR" "System update failed." "$RED"
    return 1
  fi
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
  # Arguments:
  #   $1: Function name to execute
  #   $2: Description of the task for logging
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

  # --- Core System Enhancements ---
  execute_task setup_swap "Swap file setup for Btrfs"

  # --- Package Installation ---
  # These functions handle their specific package lists. Order matters somewhat for dependencies.
  execute_task setup_git "Git and related tools setup"
  execute_task setup_editors "Editors and development tools setup"
  execute_task setup_multimedia "Multimedia packages setup"
  execute_task install_all_dnf_packages "All general DNF package installation" # This handles remaining general packages

  # --- Desktop Environment / Theming / Plugins ---
  execute_task setup_hyprland "Hyprland Desktop Environment Setup and Plugins" # Consolidated Hyprland setup
  execute_task install_theming "GTK and Icon Theming"

  # --- Hardware / Application Specific Setups ---
  execute_task setup_asus_laptops "Asus Laptop specific setup"
  execute_task setup_flatpaks "Flatpak and application setup"
  execute_task setup_tmux "Tmux and TPM setup"
  execute_task setup_nix "Nix and Home-Manager setup"

  # --- Post-Installation Configurations ---
  execute_task configure_nvidia "NVIDIA specific configurations"
  execute_task configure_systemd_services_general "General Systemd Services Configuration" # Remaining services
  execute_task update_system "Final full system update"

  log "SUCCESS" "Fedora setup script finished successfully!" "$GREEN"
}

# Call the main function to start script execution
main
