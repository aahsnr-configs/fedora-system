#!/usr/bin/env python3

"""
Homebrew Installation Script for Fedora Linux
This script installs Homebrew and configures it for the current shell
"""

import os
import shutil
import socket
import subprocess
import sys
from pathlib import Path


class Colors:
    """ANSI color codes for terminal output"""

    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    NC = "\033[0m"  # No Color


class HomebrewInstaller:
    """Main class for Homebrew installation on Fedora"""

    def __init__(self):
        self.homebrew_prefix = "/home/linuxbrew/.linuxbrew"
        self.homebrew_bin = f"{self.homebrew_prefix}/bin"
        self.brew_executable = f"{self.homebrew_bin}/brew"

    def print_status(self, message):
        """Print info message with blue color"""
        print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

    def print_success(self, message):
        """Print success message with green color"""
        print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

    def print_warning(self, message):
        """Print warning message with yellow color"""
        print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")

    def print_error(self, message):
        """Print error message with red color"""
        print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

    def run_command(
        self, command, shell=False, check=True, capture_output=True, timeout=300
    ):
        """Run a command and return the result with better error handling"""
        try:
            if isinstance(command, str) and not shell:
                command = command.split()

            result = subprocess.run(
                command,
                shell=shell,
                capture_output=capture_output,
                text=True,
                check=check,
                timeout=timeout,
            )
            return result
        except subprocess.TimeoutExpired:
            self.print_error(f"Command timed out after {timeout} seconds")
            if check:
                sys.exit(1)
            return None
        except subprocess.CalledProcessError as e:
            command_str = (
                " ".join(command) if isinstance(command, list) else str(command)
            )
            self.print_error(f"Command failed: {command_str}")
            if e.stderr:
                self.print_error(f"Error: {e.stderr.strip()}")
            if check:
                sys.exit(1)
            return e
        except FileNotFoundError:
            command_str = (
                " ".join(command) if isinstance(command, list) else str(command)
            )
            self.print_error(f"Command not found: {command_str}")
            if check:
                sys.exit(1)
            return None
        except Exception as e:
            self.print_error(f"Unexpected error running command: {e}")
            if check:
                sys.exit(1)
            return None

    def check_internet_connection(self):
        """Check if internet connection is available"""
        try:
            socket.create_connection(("8.8.8.8", 53), timeout=10)
            return True
        except OSError:
            return False

    def check_sudo_access(self):
        """Check if user has sudo access"""
        try:
            result = self.run_command(
                ["sudo", "-n", "true"], check=False, capture_output=True
            )
            if result and result.returncode == 0:
                return True

            # If non-interactive sudo fails, prompt for password
            self.print_status("Checking sudo access...")
            result = self.run_command(
                ["sudo", "true"], check=False, capture_output=False
            )
            return result and result.returncode == 0
        except Exception:
            return False

    def check_fedora(self):
        """Check if running on Fedora Linux"""
        try:
            os_release_path = Path("/etc/os-release")
            if not os_release_path.exists():
                self.print_error(
                    "Cannot determine OS version - /etc/os-release not found"
                )
                return False

            with open(os_release_path, "r", encoding="utf-8") as f:
                content = f.read()
                if "Fedora" not in content:
                    self.print_error("This script is designed for Fedora Linux")
                    return False
            return True
        except Exception as e:
            self.print_error(f"Error checking OS version: {e}")
            return False

    def check_command_exists(self, command):
        """Check if a command exists in PATH"""
        return shutil.which(command) is not None

    def install_dependencies(self):
        """Install required dependencies"""
        self.print_status("Installing required dependencies...")

        # Check if Development Tools group exists
        group_check = self.run_command(
            ["dnf", "group", "list", "Development Tools"], check=False
        )
        if group_check and group_check.returncode == 0:
            result1 = self.run_command(
                ["sudo", "dnf", "groupinstall", "-y", "Development Tools"], check=False
            )
            if result1 and result1.returncode != 0:
                self.print_warning(
                    "Development Tools group installation had issues, continuing..."
                )
        else:
            self.print_warning(
                "Development Tools group not found, installing essential packages..."
            )
            essential_dev_packages = ["gcc", "gcc-c++", "make", "git"]
            self.run_command(
                ["sudo", "dnf", "install", "-y"] + essential_dev_packages, check=False
            )

        # Install individual packages
        packages = ["procps-ng", "curl", "file", "git"]
        result2 = self.run_command(
            ["sudo", "dnf", "install", "-y"] + packages, check=False
        )
        if result2 and result2.returncode == 0:
            self.print_success("Dependencies installed successfully")
            return True
        else:
            self.print_error("Failed to install some dependencies")
            return False

    def homebrew_already_installed(self):
        """Check if Homebrew is already installed"""
        possible_locations = [
            self.brew_executable,
            "/opt/homebrew/bin/brew",
            shutil.which("brew"),
        ]

        for location in possible_locations:
            if location and os.path.exists(location) and os.access(location, os.X_OK):
                return location
        return None

    def install_homebrew(self):
        """Install Homebrew if not already installed"""
        existing_brew = self.homebrew_already_installed()

        if existing_brew:
            self.print_warning("Homebrew is already installed")
            result = self.run_command([existing_brew, "--version"], check=False)
            if result and result.stdout:
                print(result.stdout.strip())
            return True

        if not self.check_internet_connection():
            self.print_error(
                "No internet connection available for Homebrew installation"
            )
            return False

        self.print_status("Installing Homebrew...")

        # Set environment variables for non-interactive installation
        env = os.environ.copy()
        env["NONINTERACTIVE"] = "1"

        # Download and install Homebrew
        install_cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

        try:
            result = subprocess.run(
                install_cmd,
                shell=True,
                env=env,
                timeout=1800,  # 30 minutes timeout
                check=False,
            )

            if result.returncode == 0:
                self.print_success("Homebrew installation completed")
                return True
            else:
                self.print_error("Homebrew installation failed")
                return False

        except subprocess.TimeoutExpired:
            self.print_error("Homebrew installation timed out")
            return False
        except Exception as e:
            self.print_error(f"Error during Homebrew installation: {e}")
            return False

    def setup_homebrew_environment(self):
        """Set up Homebrew environment variables for current session"""
        # Add Homebrew bin to PATH
        current_path = os.environ.get("PATH", "")
        if self.homebrew_bin not in current_path:
            os.environ["PATH"] = f"{self.homebrew_bin}:{current_path}"

        # Set other Homebrew environment variables
        os.environ["HOMEBREW_PREFIX"] = self.homebrew_prefix
        os.environ["HOMEBREW_CELLAR"] = f"{self.homebrew_prefix}/Cellar"
        os.environ["HOMEBREW_REPOSITORY"] = f"{self.homebrew_prefix}/Homebrew"

        # Update MANPATH and INFOPATH
        manpath = os.environ.get("MANPATH", "")
        homebrew_manpath = f"{self.homebrew_prefix}/share/man"
        if homebrew_manpath not in manpath:
            os.environ["MANPATH"] = (
                f"{homebrew_manpath}:{manpath}" if manpath else homebrew_manpath
            )

        infopath = os.environ.get("INFOPATH", "")
        homebrew_infopath = f"{self.homebrew_prefix}/share/info"
        if homebrew_infopath not in infopath:
            os.environ["INFOPATH"] = (
                f"{homebrew_infopath}:{infopath}" if infopath else homebrew_infopath
            )

        self.print_success("Homebrew environment configured for current session")
        return True

    def configure_shell_profile(self):
        """Configure Homebrew for common shell profiles"""
        self.print_status("Configuring shell profiles for Homebrew...")

        home_dir = Path.home()
        shell_configs = []

        # Check which shell config files exist or should be created
        possible_configs = [
            (".bashrc", "bash"),
            (".bash_profile", "bash"),
            (".zshrc", "zsh"),
            (".profile", "generic shell"),
        ]

        for config_file, shell_name in possible_configs:
            config_path = home_dir / config_file
            if config_path.exists():
                shell_configs.append((config_path, shell_name))

        # If no shell configs exist, create .profile as a fallback
        if not shell_configs:
            profile_path = home_dir / ".profile"
            try:
                profile_path.touch(mode=0o644)
                shell_configs.append((profile_path, "generic shell"))
                self.print_status("Created ~/.profile file")
            except Exception as e:
                self.print_error(f"Could not create ~/.profile: {e}")
                return False

        # Homebrew configuration to add
        homebrew_config = f"""
# Homebrew configuration
export PATH="{self.homebrew_bin}:$PATH"
export HOMEBREW_PREFIX="{self.homebrew_prefix}"
export HOMEBREW_CELLAR="{self.homebrew_prefix}/Cellar"
export HOMEBREW_REPOSITORY="{self.homebrew_prefix}/Homebrew"
export MANPATH="{self.homebrew_prefix}/share/man:$MANPATH"
export INFOPATH="{self.homebrew_prefix}/share/info:$INFOPATH"

# Load Homebrew environment
if [ -f "{self.brew_executable}" ]; then
    eval "$({self.brew_executable} shellenv)"
fi
"""

        # Add configuration to each shell config file
        configs_updated = 0
        for config_path, shell_name in shell_configs:
            try:
                with open(config_path, "r", encoding="utf-8") as f:
                    content = f.read()

                if "linuxbrew/.linuxbrew/bin" not in content:
                    with open(config_path, "a", encoding="utf-8") as f:
                        f.write(homebrew_config)
                    self.print_success(
                        f"Added Homebrew configuration to {config_path.name} ({shell_name})"
                    )
                    configs_updated += 1
                else:
                    self.print_warning(
                        f"Homebrew configuration already exists in {config_path.name}"
                    )

            except Exception as e:
                self.print_error(f"Error configuring {config_path.name}: {e}")

        if configs_updated > 0:
            self.print_success(f"Updated {configs_updated} shell configuration file(s)")

        return True

    def install_recommended_packages(self):
        """Install additional recommended packages"""
        self.print_status("Installing recommended packages...")

        if not os.path.exists(self.brew_executable):
            self.print_warning(
                "Brew executable not found, skipping package installation"
            )
            return False

        packages = ["gcc"]
        for package in packages:
            result = self.run_command(
                [self.brew_executable, "install", package], check=False
            )
            if result and result.returncode == 0:
                self.print_success(f"Installed {package} successfully")
            else:
                self.print_warning(
                    f"Could not install {package} - you may need to install it manually"
                )

        return True

    def verify_installation(self):
        """Verify Homebrew installation"""
        self.print_status("Verifying Homebrew installation...")

        if not os.path.exists(self.brew_executable):
            self.print_error("Brew executable not found")
            return False

        # Test basic brew command
        result = self.run_command([self.brew_executable, "--version"], check=False)
        if not result or result.returncode != 0:
            self.print_error("Brew command is not working")
            return False

        self.print_success("Homebrew basic functionality verified")

        # Run brew doctor
        result = self.run_command([self.brew_executable, "doctor"], check=False)
        if result and result.returncode == 0:
            self.print_success("Homebrew doctor check passed!")
        else:
            self.print_warning(
                "Homebrew doctor found some issues, but basic functionality works"
            )

        return True

    def display_usage_info(self):
        """Display usage information"""
        self.print_status("To use Homebrew in your current session, run:")
        print(f'  export PATH="{self.homebrew_bin}:$PATH"')
        print(f'  eval "$({self.brew_executable} shellenv)"')
        print()
        self.print_status("Or restart your terminal/shell session")
        print()
        self.print_status("Common Homebrew commands:")
        print("  brew search <package>     # Search for packages")
        print("  brew install <package>    # Install a package")
        print("  brew uninstall <package>  # Uninstall a package")
        print("  brew update               # Update Homebrew")
        print("  brew upgrade              # Upgrade all packages")
        print("  brew list                 # List installed packages")

    def run_installation(self):
        """Main installation workflow"""
        self.print_status("🍺 Setting up Homebrew on Fedora Linux...")

        # Pre-flight checks
        if not self.check_fedora():
            return False

        if not self.check_internet_connection():
            self.print_error("Internet connection required for installation")
            return False

        if not self.check_sudo_access():
            self.print_error("Sudo access required for installation")
            return False

        # Installation steps
        steps = [
            ("Installing dependencies", self.install_dependencies),
            ("Installing Homebrew", self.install_homebrew),
            ("Setting up environment", self.setup_homebrew_environment),
            ("Configuring shell profiles", self.configure_shell_profile),
            ("Installing recommended packages", self.install_recommended_packages),
            ("Verifying installation", self.verify_installation),
        ]

        for step_name, step_func in steps:
            try:
                if not step_func():
                    self.print_error(f"Step failed: {step_name}")
                    return False
            except Exception as e:
                self.print_error(f"Error in {step_name}: {e}")
                return False

        print("\n" + "=" * 50)
        self.print_success("Homebrew setup completed successfully!")
        print("=" * 50)
        print()

        self.display_usage_info()

        return True


def main():
    """Main function"""
    installer = HomebrewInstaller()

    try:
        success = installer.run_installation()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        installer.print_error("\nInstallation interrupted by user")
        sys.exit(1)
    except Exception as e:
        installer.print_error(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
