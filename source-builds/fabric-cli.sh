#!/bin/bash

# This script automates the build and installation of fabric-cli from its Git source on Fedora Linux.
# It's designed for robustness, idempotency, and provides clear, color-coded feedback.

# --- Script Configuration ---
# Name of the project/package to install
PKG_NAME="fabric-cli"
# URL of the Git repository
REPO_URL="https://github.com/Fabric-Development/fabric-cli"

# --- ANSI Color Codes and Unicode Symbols ---
RED='\033[0;31m'    # Red for errors
GREEN='\033[0;32m'  # Green for success
YELLOW='\033[0;33m' # Yellow for information/warnings
BLUE='\033[0;34m'   # Blue for main steps
CYAN='\033[0;36m'   # Cyan for sub-steps/headers
NC='\033[0m'        # No Color (reset)

# Unicode symbols
CHECK_MARK="✅"
CROSS_MARK="❌"
INFO_ICON="ℹ️"
GEAR_ICON="⚙️"
ROCKET_ICON="🚀"
SPARKLE_ICON="✨"

# --- Script Setup for Robustness ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# The return value of a pipeline is the status of the last command to exit with a non-zero status,
# or zero if all commands in the pipeline exit successfully.
set -o pipefail

# Global variable to store the path to the temporary source directory.
# Initialized to an empty string; will be set by mktemp.
TMP_SRCDIR=""

# --- Helper Functions ---

# Function to print informational messages.
print_info() {
  echo -e "${YELLOW}${INFO_ICON} $1${NC}"
}

# Function to print major step headers.
print_step() {
  echo -e "\n${CYAN}--- ${GEAR_ICON} $1 ---${NC}"
}

# Function to print success messages.
print_success() {
  echo -e "${GREEN}${CHECK_MARK} $1${NC}"
}

# Function to print error messages and exit the script.
print_error() {
  echo -e "${RED}${CROSS_MARK} ERROR: $1${NC}" >&2 # Output to stderr
  exit 1
}

# Function to clean up the temporary directory.
# This function is registered to run automatically upon script exit or interruption.
cleanup() {
  if [[ -d "${TMP_SRCDIR}" ]]; then # Check if TMP_SRCDIR is set and is a directory
    print_info "Cleaning up temporary source directory: ${TMP_SRCDIR}"
    rm -rf "${TMP_SRCDIR}"
  fi
}

# Register the cleanup function to be executed when the script exits (normally or due to error),
# or when it receives an INT (Ctrl+C) or TERM signal.
trap cleanup EXIT INT TERM

# --- Main Installation Logic ---
install_fabric_cli() {
  echo -e "${BLUE}${ROCKET_ICON} Starting Installation of ${PKG_NAME}${NC}"

  # Step 1: Install necessary build dependencies for Fedora.
  print_step "1/4: Installing Build Dependencies"
  print_info "Checking and installing: git, golang, meson, ninja-build..."
  # Using '|| print_error' to provide custom error messages if dnf fails.
  sudo dnf install -y git golang meson ninja-build || print_error "Failed to install required dependencies."
  print_success "Dependencies installed."

  # Step 2: Prepare a unique temporary source directory.
  print_step "2/4: Preparing Source Directory"
  TMP_SRCDIR=$(mktemp -d -t "${PKG_NAME}-XXXXXX") || print_error "Failed to create a temporary directory."
  print_info "Created temporary source directory: ${TMP_SRCDIR}"
  cd "${TMP_SRCDIR}" || print_error "Failed to change into the temporary directory."

  # Step 3: Clone the repository.
  print_step "3/4: Cloning Repository"
  print_info "Cloning ${REPO_URL} into ${TMP_SRCDIR}/${PKG_NAME}..."
  git clone "${REPO_URL}" "${PKG_NAME}" || print_error "Failed to clone the Git repository."
  cd "${PKG_NAME}" || print_error "Failed to change into the cloned repository directory."

  # Step 4: Build and Install the project.
  print_step "4/4: Building and Installing ${PKG_NAME}"
  print_info "Configuring build with Meson..."
  meson setup build || print_error "Meson setup failed. Check project's build requirements."
  print_info "Compiling project with Ninja..."
  meson compile -C build || print_error "Meson compilation failed."
  print_info "Installing..."
  # Removed --prefix. Meson will default to /usr/local.
  sudo meson install -C build || print_error "Meson installation failed. Check permissions or target directory."
  print_success "${PKG_NAME} installed successfully."

  echo -e "\n${BLUE}${SPARKLE_ICON} Installation Complete! ${SPARKLE_ICON}${NC}"
  print_info "The executable should now be available in a standard system path, typically /usr/local/bin."
  print_info "You may need to log out and back in, or run 'source ~/.bashrc' (or equivalent shell config file)"
  print_info "for the new executable to be found in your system's PATH."
}

# --- Execute the main installation function ---
install_fabric_cli
