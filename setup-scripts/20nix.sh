#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---

# Function to print messages with colors
print_message() {
  local color="$1"
  local message="$2"
  echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
check_command() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    print_message "$RED" "Error: '$cmd' is not installed. Please install it and try again."
    exit 1
  fi
}

# Function to check if the OS is Fedora
check_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "fedora" ]; then
      print_message "$GREEN" "Detected OS: Fedora Linux. Proceeding with installation."
    else
      print_message "$RED" "Error: This script is designed for Fedora Linux. Detected OS: $PRETTY_NAME"
      exit 1
    fi
  else
    print_message "$RED" "Error: Cannot determine OS. /etc/os-release not found."
    exit 1
  fi
}

# --- Main Script Execution ---

print_message "$BLUE" "--- Starting Nix and Home-Manager Installation Script ---"

# 1. Check OS
check_os

# 2. Check for prerequisites (curl)
print_message "$YELLOW" "Checking for 'curl' command..."
check_command "curl"
print_message "$GREEN" "'curl' is installed. Proceeding."

# 3. Install Nix package manager
print_message "$BLUE" "Attempting to install Nix package manager using Determinate Systems installer..."
print_message "$YELLOW" "This might take a few minutes and may prompt for sudo password."

# The --proto '=https' --tlsv1.2 ensures secure download
# -sSf makes curl silent, fail silently on errors
# -L makes curl follow redirects
# sh -s -- install --determinate runs the script with the 'install --determinate' arguments
if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate; then
  print_message "$GREEN" "Nix installation command executed successfully."
else
  print_message "$RED" "Error: Nix installation failed. Please check the output above for details."
  exit 1
fi

# 4. Source Nix profile for current session
# The Nix installer typically adds lines to ~/.profile or ~/.bashrc.
# We need to source them to make `nix` commands available immediately in this script's session.
print_message "$YELLOW" "Attempting to source Nix profile for current session..."
NIX_PROFILE_PATH="$HOME/.nix-profile/etc/profile.d/nix.sh"
if [ -f "$NIX_PROFILE_PATH" ]; then
  source "$NIX_PROFILE_PATH"
  print_message "$GREEN" "Nix profile sourced successfully."
else
  print_message "$YELLOW" "Nix profile script not found at $NIX_PROFILE_PATH. This might happen if the installer placed it elsewhere or if there was an issue."
  print_message "$YELLOW" "You may need to restart your terminal or manually source your shell configuration (e.g., 'source ~/.bashrc' or 'source ~/.profile') for 'nix' commands to be available."
  print_message "$YELLOW" "Attempting to proceed, but if 'nix' commands fail later, restart your terminal and re-run the script."
fi

# 5. Verify Nix is available
print_message "$YELLOW" "Verifying 'nix' command availability..."
check_command "nix"
print_message "$GREEN" "'nix' command is available."

# 6. Set up Home-Manager and flakes
print_message "$BLUE" "Setting up Home-Manager and flakes..."
print_message "$YELLOW" "This will initialize Home-Manager and create default configuration files."

if nix run home-manager/master -- init --switch; then
  print_message "$GREEN" "Home-Manager initialized successfully."
else
  print_message "$RED" "Error: Home-Manager initialization failed. Please check the output."
  exit 1
fi

# 7. Handle directory symlinking
print_message "$BLUE" "Handling Home-Manager configuration directory symlinking..."

CONFIG_HOME_MANAGER_DIR="$HOME/.config/home-manager"
HYPRDOTS_HOME_MANAGER_DIR="$HOME/.hyprdots/.config/home-manager"

# Remove the default $HOME/.config/home-manager directory if it exists and is not a symlink to our target
if [ -d "$CONFIG_HOME_MANAGER_DIR" ] && [ ! -L "$CONFIG_HOME_MANAGER_DIR" ]; then
  print_message "$YELLOW" "Found existing directory $CONFIG_HOME_MANAGER_DIR. Removing it to create symlink."
  rm -rf "$CONFIG_HOME_MANAGER_DIR"
elif [ -L "$CONFIG_HOME_MANAGER_DIR" ] && [ "$(readlink "$CONFIG_HOME_MANAGER_DIR")" != "$HYPRDOTS_HOME_MANAGER_DIR" ]; then
  print_message "$YELLOW" "Found existing symlink $CONFIG_HOME_MANAGER_DIR pointing elsewhere. Removing it."
  rm "$CONFIG_HOME_MANAGER_DIR"
elif [ -L "$CONFIG_HOME_MANAGER_DIR" ] && [ "$(readlink "$CONFIG_HOME_MANAGER_DIR")" == "$HYPRDOTS_HOME_MANAGER_DIR" ]; then
  print_message "$GREEN" "$CONFIG_HOME_MANAGER_DIR is already symlinked correctly to $HYPRDOTS_HOME_MANAGER_DIR. Skipping removal."
else
  print_message "$YELLOW" "$CONFIG_HOME_MANAGER_DIR does not exist or is not a conflicting symlink. Proceeding."
fi

# Create the parent directory for the symlink target if it doesn't exist
print_message "$YELLOW" "Ensuring parent directory for $HYPRDOTS_HOME_MANAGER_DIR exists..."
mkdir -p "$(dirname "$HYPRDOTS_HOME_MANAGER_DIR")"
print_message "$GREEN" "Parent directory created/exists."

# Create a symlink from $HOME/.config/home-manager to $HOME/.hyprdots/.config/home-manager
if [ ! -L "$CONFIG_HOME_MANAGER_DIR" ] || [ "$(readlink "$CONFIG_HOME_MANAGER_DIR")" != "$HYPRDOTS_HOME_MANAGER_DIR" ]; then
  print_message "$BLUE" "Creating symlink from $CONFIG_HOME_MANAGER_DIR to $HYPRDOTS_HOME_MANAGER_DIR..."
  ln -s "$HYPRDOTS_HOME_MANAGER_DIR" "$CONFIG_HOME_MANAGER_DIR"
  print_message "$GREEN" "Symlink created successfully."
else
  print_message "$GREEN" "Symlink already exists and points correctly. Skipping symlink creation."
fi

# 8. Install all required packages using home-manager switch
print_message "$BLUE" "Installing/updating required packages with Home-Manager switch..."
print_message "$YELLOW" "This will apply your Home-Manager configuration (home.nix)."

if home-manager switch; then
  print_message "$GREEN" "Home-Manager switch completed successfully. Your environment should now be configured."
else
  print_message "$RED" "Error: Home-Manager switch failed. Please check your home.nix and the output above."
  exit 1
fi

print_message "$GREEN" "--- Script finished successfully! ---"
print_message "$YELLOW" "Please restart your terminal or log out and log back in to ensure all changes take effect."
