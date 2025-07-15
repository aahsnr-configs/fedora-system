#!/bin/bash
# This script attempts to build and install python-fabric-git on Fedora.
# It is designed to be robust and user-friendly, with all dependencies combined.

# --- Configuration ---
REPOSRC="https://github.com/Fabric-Development/fabric.git"
REPONAME="fabric"
PKGDESC="next-gen framework for building desktop widgets using python"
TEMP_DIR="/tmp/fabric_build_$(date +%s)" # Unique temporary directory

# --- All Dependencies ---
# Combining all build and runtime dependencies into a single array
ALL_DEPS=(
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

# --- Functions ---

# Function to clean up temporary files
cleanup() {
  echo "Cleaning up temporary build directory: ${TEMP_DIR}"
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

# Trap signals for robust cleanup
trap cleanup EXIT

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Main Script ---

echo "Starting installation of ${PKGDESC}..."
echo "This script will attempt to install necessary dependencies and build Fabric."

# Ensure dnf is available
if ! command_exists dnf; then
  echo "Error: 'dnf' command not found. This script is for Fedora-based systems."
  exit 1
fi

# --- Step 1: Install All Dependencies ---
echo ""
echo "--- Step 1: Installing all required dependencies ---"
echo "Attempting to install: ${ALL_DEPS[*]}"

sudo dnf install -y "${ALL_DEPS[@]}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to install one or more required dependencies using dnf."
  echo "Please review the output above for specific package failures and try installing them manually."
  exit 1
fi
echo "All dependencies installed successfully."

# --- Step 2: Prepare build environment and Clone the Repository ---
echo ""
echo "--- Step 2: Preparing build environment and cloning the repository ---"

mkdir -p "$TEMP_DIR"
if [ $? -ne 0 ]; then
  echo "Error: Failed to create temporary directory: ${TEMP_DIR}. Exiting."
  exit 1
fi
cd "$TEMP_DIR" || {
  echo "Error: Could not enter temporary directory. Exiting."
  exit 1
}

echo "Cloning the ${REPONAME} repository into ${TEMP_DIR}/${REPONAME}..."
git clone "$REPOSRC"

if [ $? -ne 0 ]; then
  echo "Error: Failed to clone the repository from ${REPOSRC}. Exiting."
  exit 1
fi
echo "Repository cloned successfully."

# --- Step 3: Build and Install ---
echo ""
echo "--- Step 3: Building and installing ${REPONAME} ---"
cd "$REPONAME" || {
  echo "Error: Could not enter repository directory ${TEMP_DIR}/${REPONAME}. Exiting."
  exit 1
}

echo "Building the Python wheel package..."
python3 -m build --wheel --no-isolation

if [ $? -ne 0 ]; then
  echo "Error: Failed to build the Python package. Please check for build errors above."
  exit 1
fi
echo "Python package built successfully."

echo "Installing the Python wheel package system-wide..."
# The installer module expects a destination directory, for system-wide install, it's typically /
# Using --prefix to ensure correct installation path for Python packages
sudo python3 -m installer --destdir / dist/*.whl

if [ $? -ne 0 ]; then
  echo "Error: Failed to install the Python package. Check permissions or previous errors."
  exit 1
fi
echo "Python package installed successfully."

echo ""
echo "-------------------------------------"
echo "Installation of ${PKGDESC} complete!"
echo "-------------------------------------"
echo "You can now try running Fabric examples or applications."
echo "Remember to run 'cleanup' manually if the script exited prematurely without cleaning up."
