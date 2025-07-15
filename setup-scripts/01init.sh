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

# Path to preconfigured files
PRECONFIG_DIR="$HOME/fedora-setup/preconfigured-files"

# Destination paths
DNF_CONF_DEST="/etc/dnf/dnf.conf"
VARIABLES_SH_DEST="/etc/profile.d/variables.sh"
LOCALTIME_DEST="/etc/localtime"
TIMEZONE_SRC="../usr/share/zoneinfo/Asia/Dhaka" # Relative path from /etc/

# RPM Fusion URLs
RPMFUSION_FREE="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
RPMFUSION_NONFREE="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# COPR repositories
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

# Function to compare file contents
compare_files() {
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
  local file_name              # Declare first
  file_name=$(basename "$src") # Assign separately

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

# --- Main Script Functions ---

# Function to check for root privileges
check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    log "ERROR" "This script must be run as root. Please use sudo." "$RED"
    exit 1
  fi
}

# Function to copy DNF configuration files
setup_dnf_configs() {
  log "INFO" "Starting DNF configuration setup..." "$BLUE"
  copy_file_idempotent "$PRECONFIG_DIR/dnf.conf" "$DNF_CONF_DEST" || return 1
  copy_file_idempotent "$PRECONFIG_DIR/variables.sh" "$VARIABLES_SH_DEST" || return 1
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
}

# Function to enable Cisco OpenH264
enable_cisco_openh264() {
  log "INFO" "Starting Cisco OpenH264 setup..." "$BLUE"
  dnf_install_idempotent \
    "Fedora Cisco OpenH264" \
    "dnf config-manager --dump fedora-cisco-openh264 | grep -q 'enabled=True'" \
    "sudo dnf config-manager --setopt fedora-cisco-openh264.enabled=1" || return 1
}

# Function to enable COPR repositories
enable_copr_repos() {
  log "INFO" "Starting COPR repositories setup..." "$BLUE"
  local all_success=true
  for repo in "${COPR_REPOS[@]}"; do
    local repo_name                            # Declare first
    repo_name=$(echo "$repo" | sed 's/\//-/g') # Assign separately

    if ! dnf_install_idempotent \
      "COPR repository '$repo'" \
      "dnf repolist enabled | grep -q 'copr:copr.fedorainfracloud.org:$repo_name'"; then
      # If check fails, try to enable
      if ! sudo dnf copr enable -y "$repo"; then
        all_success=false
      fi
    fi
  done
  "$all_success" || return 1 # Return non-zero if any COPR repo failed
}

# Function to set timezone
set_timezone() {
  log "INFO" "Starting timezone setup to Asia/Dhaka..." "$BLUE"
  local current_timezone                                                                         # Declare first
  current_timezone=$(readlink "$LOCALTIME_DEST" 2>/dev/null | sed 's#^../usr/share/zoneinfo/##') # Assign separately

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
}

# Function to update the system
update_system() {
  log "INFO" "Starting system update..." "$BLUE"
  if sudo dnf update -y; then
    log "SUCCESS" "System update completed successfully." "$GREEN"
  else
    log "ERROR" "System update failed." "$RED"
    return 1
  fi
}

# --- Main Script Execution ---

# Set strict error handling
set -eEuo pipefail

# Trap errors and exit
trap 'log "FATAL" "An unexpected error occurred. Exiting." "$RED"; exit 1' ERR
trap 'log "INFO" "Script execution interrupted." "$YELLOW"; exit 1' INT

log "INFO" "Starting lean, optimized, and visually enhanced initial setup script..." "$BLUE"

check_root

# Execute functions with status logging
execute_task() {
  local func_name="$1"
  local task_desc="$2"
  if "$func_name"; then
    log "INFO" "$task_desc completed successfully." "$BLUE"
  else
    log "ERROR" "$task_desc failed. Continuing with other steps." "$RED"
  fi
}

execute_task setup_dnf_configs "DNF configuration setup"
execute_task install_rpmfusion "RPM Fusion repositories setup"
execute_task enable_cisco_openh264 "Cisco OpenH264 setup"
execute_task enable_copr_repos "COPR repositories setup"
execute_task set_timezone "Timezone setup"
execute_task update_system "System update"

log "SUCCESS" "Initial setup script finished." "$GREEN"
