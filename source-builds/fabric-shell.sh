#!/bin/bash

# This script automates the build and installation of both 'fabric' (the Python framework)
# and 'fabric-cli' (its alternative CLI) from their Git sources on Fedora Linux.
# It is designed for robustness, idempotency, and provides clear, color-coded feedback.

# --- Global Script Configuration ---
# URL of the Fabric Python framework Git repository
FABRIC_REPO_URL="https://github.com/Fabric-Development/fabric.git"
FABRIC_PKG_NAME="fabric"
FABRIC_PKG_DESC="next-gen framework for building desktop widgets using python"

# URL of the Fabric-CLI Git repository
FABRIC_CLI_REPO_URL="https://github.com/Fabric-Development/fabric-cli"
FABRIC_CLI_PKG_NAME="fabric-cli"
FABRIC_CLI_PKG_DESC="an alternative cli for fabric"

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
PYTHON_ICON="🐍"
CLI_ICON="💻"

# --- Script Setup for Robustness ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# The return value of a pipeline is the status of the last command to exit with a non-zero status,
# or zero if all commands in the pipeline exit successfully.
set -o pipefail

# Global variables to store paths to temporary source directories.
# Initialized to empty strings; will be set by mktemp within functions.
TMP_FABRIC_SRCDIR=""
TMP_FABRIC_CLI_SRCDIR=""

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

# Function to clean up temporary directories.
# This function is registered to run automatically upon script exit or interruption.
cleanup() {
  if [[ -d "${TMP_FABRIC_SRCDIR}" ]]; then
    print_info "Cleaning up temporary ${FABRIC_PKG_NAME} build directory: ${TMP_FABRIC_SRCDIR}"
    rm -rf "${TMP_FABRIC_SRCDIR}"
  fi
  if [[ -d "${TMP_FABRIC_CLI_SRCDIR}" ]]; then
    print_info "Cleaning up temporary ${FABRIC_CLI_PKG_NAME} build directory: ${TMP_FABRIC_CLI_SRCDIR}"
    rm -rf "${TMP_FABRIC_CLI_SRCDIR}"
  fi
}

# Register the cleanup function to be executed when the script exits (normally or due to error),
# or when it receives an INT (Ctrl+C) or TERM signal.
trap cleanup EXIT INT TERM

# Function to check if a command exists (e.g., 'dnf').
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Installation Function for Fabric (Python Framework) ---
install_fabric() {
  echo -e "\n${BLUE}${PYTHON_ICON} Starting Installation of ${FABRIC_PKG_NAME} (${FABRIC_PKG_DESC})${NC}"

  # All Dependencies for Fabric
  local ALL_FABRIC_DEPS=(
    git
    python3-pip
    python3-setuptools
    python3-wheel
    python3-build
    python3-installer
    pkgconf
    libpkgconf-devel
    gtk3
    gtk3-devel
    cairo
    cairo-devel
    gobject-introspection
    gobject-introspection-devel
    gtk-layer-shell
    gtk-layer-shell-devel
    libdbusmenu-gtk3
    libdbusmenu-gtk3-devel
    cinnamon-desktop-devel
    webkit2gtk4.1
    webkit2gtk4.1-devel
    python3-gobject
    python3-gobject-devel
    python3-cairo
    python3-cairo-devel
    python3-loguru
    python3-click
    python3-psutil
  )

  # Step 1: Install all required dependencies for Fabric.
  print_step "1/3: Installing ${FABRIC_PKG_NAME} Build Dependencies"
  print_info "Attempting to install: ${ALL_FABRIC_DEPS[*]}"
  sudo dnf install -y "${ALL_FABRIC_DEPS[@]}" || print_error "Failed to install one or more required dependencies for ${FABRIC_PKG_NAME}."
  print_success "Dependencies for ${FABRIC_PKG_NAME} installed."

  # Step 2: Prepare a unique temporary source directory and clone the repository.
  print_step "2/3: Preparing ${FABRIC_PKG_NAME} Source Environment"
  TMP_FABRIC_SRCDIR=$(mktemp -d -t "${FABRIC_PKG_NAME}-XXXXXX") || print_error "Failed to create a temporary directory for ${FABRIC_PKG_NAME}."
  print_info "Created temporary source directory: ${TMP_FABRIC_SRCDIR}"
  cd "${TMP_FABRIC_SRCDIR}" || print_error "Failed to change into the temporary directory for ${FABRIC_PKG_NAME}."

  print_info "Cloning ${FABRIC_REPO_URL} into ${TMP_FABRIC_SRCDIR}/${FABRIC_PKG_NAME}..."
  git clone "${FABRIC_REPO_URL}" "${FABRIC_PKG_NAME}" || print_error "Failed to clone the Git repository for ${FABRIC_PKG_NAME}."
  cd "${FABRIC_PKG_NAME}" || print_error "Failed to change into the cloned repository directory for ${FABRIC_PKG_NAME}."

  # Step 3: Build and Install the Python package.
  print_step "3/3: Building and Installing ${FABRIC_PKG_NAME}"
  print_info "Building the Python wheel package..."
  python3 -m build --wheel --no-isolation || print_error "Failed to build the Python package for ${FABRIC_PKG_NAME}."
  print_success "Python package for ${FABRIC_PKG_NAME} built successfully."

  print_info "Installing the Python wheel package system-wide..."
  # Using 'sudo python3 -m installer dist/*.whl' for system-wide installation.
  # This is the conventional way for 'installer' to place files in the system's
  # default Python site-packages directory when run with root privileges.
  sudo python3 -m installer dist/*.whl || print_error "Failed to install the Python package for ${FABRIC_PKG_NAME}. Check permissions."
  print_success "${FABRIC_PKG_NAME} installed successfully."

  echo -e "\n${BLUE}${SPARKLE_ICON} ${FABRIC_PKG_NAME} Installation Complete! ${SPARKLE_ICON}${NC}"
  print_info "You can now try running Fabric examples or applications."
}

# --- Installation Function for Fabric-CLI ---
install_fabric_cli() {
  echo -e "\n${BLUE}${CLI_ICON} Starting Installation of ${FABRIC_CLI_PKG_NAME} (${FABRIC_CLI_PKG_DESC})${NC}"

  # Dependencies for Fabric-CLI
  local ALL_FABRIC_CLI_DEPS=(
    git
    golang
    meson
    ninja-build
  )

  # Step 1: Install necessary build dependencies for Fabric-CLI.
  print_step "1/3: Installing ${FABRIC_CLI_PKG_NAME} Build Dependencies"
  print_info "Checking and installing: git, golang, meson, ninja-build..."
  sudo dnf install -y "${ALL_FABRIC_CLI_DEPS[@]}" || print_error "Failed to install required dependencies for ${FABRIC_CLI_PKG_NAME}."
  print_success "Dependencies for ${FABRIC_CLI_PKG_NAME} installed."

  # Step 2: Prepare a unique temporary source directory and clone the repository.
  print_step "2/3: Preparing ${FABRIC_CLI_PKG_NAME} Source Environment"
  TMP_FABRIC_CLI_SRCDIR=$(mktemp -d -t "${FABRIC_CLI_PKG_NAME}-XXXXXX") || print_error "Failed to create a temporary directory for ${FABRIC_CLI_PKG_NAME}."
  print_info "Created temporary source directory: ${TMP_FABRIC_CLI_SRCDIR}"
  cd "${TMP_FABRIC_CLI_SRCDIR}" || print_error "Failed to change into the temporary directory for ${FABRIC_CLI_PKG_NAME}."

  print_info "Cloning ${FABRIC_CLI_REPO_URL} into ${TMP_FABRIC_CLI_SRCDIR}/${FABRIC_CLI_PKG_NAME}..."
  git clone "${FABRIC_CLI_REPO_URL}" "${FABRIC_CLI_PKG_NAME}" || print_error "Failed to clone the Git repository for ${FABRIC_CLI_PKG_NAME}."
  cd "${FABRIC_CLI_PKG_NAME}" || print_error "Failed to change into the cloned repository directory for ${FABRIC_CLI_PKG_NAME}."

  # Step 3: Build and Install the project.
  print_step "3/3: Building and Installing ${FABRIC_CLI_PKG_NAME}"
  print_info "Configuring build with Meson..."
  meson setup build || print_error "Meson setup failed for ${FABRIC_CLI_PKG_NAME}. Check project's build requirements."
  print_info "Compiling project with Ninja..."
  meson compile -C build || print_error "Meson compilation failed for ${FABRIC_CLI_PKG_NAME}."
  print_info "Installing..."
  # Removed --prefix. Meson will default to /usr/local.
  sudo meson install -C build || print_error "Meson installation failed for ${FABRIC_CLI_PKG_NAME}. Check permissions or target directory."
  print_success "${FABRIC_CLI_PKG_NAME} installed successfully."

  echo -e "\n${BLUE}${SPARKLE_ICON} ${FABRIC_CLI_PKG_NAME} Installation Complete! ${SPARKLE_ICON}${NC}"
  print_info "The executable should now be available in a standard system path, typically /usr/local/bin."
  print_info "You may need to log out and back in, or run 'source ~/.bashrc' (or equivalent shell config file)"
  print_info "for the new executable to be found in your system's PATH."
}

# --- Main Script Execution ---
echo -e "${BLUE}${ROCKET_ICON} Starting Combined Installation of Fabric and Fabric-CLI ${ROCKET_ICON}${NC}"

# Initial check for dnf command
if ! command_exists dnf; then
  print_error "'dnf' command not found. This script is designed for Fedora-based systems."
fi

# Execute Fabric installation first
install_fabric

# Execute Fabric-CLI installation second
install_fabric_cli

echo -e "\n${BLUE}${SPARKLE_ICON} All installations (Fabric and Fabric-CLI) complete! ${SPARKLE_ICON}${NC}"
echo "Please review the output above for any warnings or errors."
