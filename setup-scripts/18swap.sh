#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
SWAP_SUBVOLUME="/var/swap"
SWAP_FILE_NAME="swapfile"
SWAP_FILE_PATH="${SWAP_SUBVOLUME}/${SWAP_FILE_NAME}"
DRACUT_CONF_FILE="/etc/dracut.conf.d/resume.conf"
FSTAB_ENTRY="${SWAP_FILE_PATH} none swap defaults 0 0"

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Functions ---

log_info() {
  echo -e "${GREEN}INFO:${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}WARN:${NC} $1"
}

log_error() {
  echo -e "${RED}ERROR:${NC} $1" >&2
  exit 1
}

# Calculate swap size based on RAM.
# - If RAM < 2GB, swap = 2 * RAM
# - If 2GB <= RAM < 8GB, swap = 1.5 * RAM
# - If RAM >= 8GB, swap = RAM
calculate_swap_size() {
  local mem_total_kb_str
  mem_total_kb_str=$(free | awk '/Mem:/ {print $2}')
  if [[ -z "$mem_total_kb_str" ]]; then
    log_error "Could not determine total memory. 'free' command output is empty or unexpected."
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
}

# --- Main Script ---

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  log_error "This script must be run as root. Please run with 'sudo bash $0'."
fi

# 1. Determine SWAPSIZE
log_info "Calculating optimal swap size..."
SWAPSIZE=$(calculate_swap_size)
log_info "Calculated swap size: ${YELLOW}$SWAPSIZE${NC}"

# 2. Check if Btrfs filesystem is in use for the root.
log_info "Checking if root filesystem is Btrfs..."
if ! findmnt -no FSTYPE / | grep -q btrfs; then
  log_error "Root filesystem is not Btrfs. This script is designed for Btrfs only."
fi

# 3. Create Btrfs subvolume for swap if it doesn't exist
if [ ! -d "$SWAP_SUBVOLUME" ]; then
  log_info "Creating Btrfs subvolume: ${YELLOW}$SWAP_SUBVOLUME${NC}"
  sudo btrfs subvolume create "$SWAP_SUBVOLUME" || log_error "Failed to create Btrfs subvolume."
else
  log_warn "Btrfs subvolume ${YELLOW}$SWAP_SUBVOLUME${NC} already exists. Skipping creation."
fi

# 4. Set NoCoW attribute on the subvolume
# This step is crucial for Btrfs swap files to prevent CoW issues.
log_info "Setting NoCoW attribute on ${YELLOW}$SWAP_SUBVOLUME${NC}..."
if ! sudo chattr +C "$SWAP_SUBVOLUME"; then
  log_error "Failed to set NoCoW attribute. Ensure your kernel supports +C on Btrfs subvolumes."
fi

# 5. Restore SELinux context if applicable
if command -v restorecon &>/dev/null; then
  log_info "Restoring SELinux context for ${YELLOW}$SWAP_SUBVOLUME${NC}..."
  if ! sudo restorecon -Rv "$SWAP_SUBVOLUME"; then
    log_warn "Failed to restore SELinux context. This might indicate an SELinux issue."
  fi
else
  log_warn "restorecon not found, skipping SELinux context restoration. (Only relevant for SELinux enabled systems)"
fi

# 6. Create swapfile if it doesn't exist and format it
if [ ! -f "$SWAP_FILE_PATH" ]; then
  log_info "Creating swap file: ${YELLOW}$SWAP_FILE_PATH${NC} with size ${YELLOW}$SWAPSIZE${NC}..."
  # fallocate is the preferred method on modern systems and with btrfs for pre-allocating space
  if ! sudo fallocate -l "$SWAPSIZE" "$SWAP_FILE_PATH"; then
    log_error "Failed to create swap file with fallocate. Check disk space or permissions."
  fi
  log_info "Setting permissions on swap file to 600..."
  if ! sudo chmod 600 "$SWAP_FILE_PATH"; then
    log_error "Failed to set permissions on swap file. This is critical for security."
  fi
  log_info "Formatting swap file..."
  if ! sudo mkswap -L SWAPFILE "$SWAP_FILE_PATH"; then
    log_error "Failed to format swap file. Check if it's already in use or corrupted."
  fi
else
  log_warn "Swap file ${YELLOW}$SWAP_FILE_PATH${NC} already exists. Checking its status."
  # Check if it's already a swap signature and active
  if sudo blkid -p -s TYPE -o value "$SWAP_FILE_PATH" | grep -q "swap"; then
    log_info "Swap file is already formatted as swap. Skipping formatting."
  else
    log_warn "Existing file is not formatted as swap. Attempting to format."
    if ! sudo mkswap -L SWAPFILE "$SWAP_FILE_PATH"; then
      log_error "Failed to format existing swap file. It might be in use or corrupted."
    fi
  fi
fi

# 7. Add entry to /etc/fstab if not present
log_info "Adding swap entry to /etc/fstab..."
if ! grep -q "^${FSTAB_ENTRY}$" /etc/fstab; then
  log_info "Adding '${YELLOW}$FSTAB_ENTRY${NC}' to /etc/fstab."
  echo "${FSTAB_ENTRY}" | sudo tee -a /etc/fstab >/dev/null || log_error "Failed to add swap entry to /etc/fstab."
else
  log_warn "Swap entry already exists in /etc/fstab. Skipping addition."
fi

# 8. Activate swap
log_info "Activating swap..."
if ! sudo swapon -av; then
  log_error "Failed to activate swap. Check /etc/fstab entry or swap file integrity."
fi
log_info "Swap is now ${GREEN}active${NC}."
free -h

# 9. Configure Dracut for resume (if not already configured)
log_info "Configuring Dracut for resume..."
if [ ! -f "$DRACUT_CONF_FILE" ] || ! grep -q "add_dracutmodules+=\" resume \"" "$DRACUT_CONF_FILE"; then
  log_info "Adding resume module to Dracut configuration in ${YELLOW}$DRACUT_CONF_FILE${NC}."
  echo 'add_dracutmodules+=" resume "' | sudo tee "$DRACUT_CONF_FILE" >/dev/null || log_error "Failed to configure Dracut."
else
  log_warn "Dracut resume module already configured. Skipping."
fi

# 10. Rebuild Dracut initramfs
log_info "Rebuilding Dracut initramfs. This might take some time..."
if ! sudo dracut -f; then
  log_error "Failed to rebuild Dracut initramfs. Check Dracut logs for errors."
fi
log_info "Dracut initramfs rebuilt ${GREEN}successfully${NC}."

log_info "${GREEN}Swap setup complete!${NC}"
log_info "Please ${YELLOW}reboot your system${NC} for full effect, especially for suspend-to-disk (resume) functionality."
