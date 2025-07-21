#!/usr/bin/env python3
# fedora-setup.py
# A modular and idempotent script for setting up a Fedora system.

import argparse
import datetime
import filecmp
import os
import pathlib
import platform
import pwd
import shlex
import shutil
import subprocess
import sys
from typing import List, Tuple

# --- Global Configuration ---


class Colors:
    """ANSI color codes for terminal output."""

    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[0;33m"
    BLUE = "\033[0;34m"
    NC = "\033[0m"


class Symbols:
    """Unicode symbols for logging."""

    SUCCESS = "✔"
    ERROR = "✖"
    INFO = "ℹ"
    WARNING = "⚠"


def get_user_info():
    """Determine the non-root user and their home directory."""
    try:
        sudo_user = os.environ["SUDO_USER"]
        user_home = pathlib.Path(pwd.getpwnam(sudo_user).pw_dir)
        return sudo_user, user_home
    except KeyError:
        log("FATAL", "This script must be run with sudo by a regular user.", Colors.RED)
        sys.exit(1)


SUDO_USER, USER_HOME = get_user_info()
PRECONFIG_DIR = USER_HOME / "fedora-setup" / "preconfigured-files"

# --- Helper Functions ---


def log(level: str, message: str, color: str = Colors.NC):
    """Timestamped and colored logging."""
    symbol_map = {
        "SUCCESS": Symbols.SUCCESS,
        "ERROR": Symbols.ERROR,
        "INFO": Symbols.INFO,
        "WARNING": Symbols.WARNING,
        "FATAL": Symbols.ERROR,
    }
    symbol = symbol_map.get(level, Symbols.INFO)
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{color}[{timestamp}] {symbol} {level}: {message}{Colors.NC}")


def run_command(
    command: List[str],
    as_user: str = None,
    check: bool = True,
    capture: bool = True,
    **kwargs,
) -> subprocess.CompletedProcess:
    """
    Execute a shell command with enhanced error handling and user context switching.

    Args:
        command: The command to execute as a list of strings.
        as_user: The username to run the command as. If None, runs as the current user (or root).
        check: If True, raise CalledProcessError on non-zero exit codes.
        capture: If True, capture stdout and stderr.
        **kwargs: Additional arguments to pass to subprocess.run.

    Returns:
        A subprocess.CompletedProcess object.
    """
    if as_user:
        try:
            pw_info = pwd.getpwnam(as_user)
            uid, gid = pw_info.pw_uid, pw_info.pw_gid

            def demote():
                os.setgid(gid)
                os.setuid(uid)

            kwargs["preexec_fn"] = demote
        except KeyError:
            log("ERROR", f"User '{as_user}' not found.", Colors.RED)
            raise
    try:
        return subprocess.run(
            command,
            check=check,
            capture_output=capture,
            text=True,
            **kwargs,
        )
    except FileNotFoundError as e:
        log("ERROR", f"Command not found: {e.filename}", Colors.RED)
        raise
    except subprocess.CalledProcessError as e:
        log(
            "ERROR",
            f"Command failed: {' '.join(e.cmd)} (Exit Code: {e.returncode})",
            Colors.RED,
        )
        if e.stdout:
            print(f"--- STDOUT ---\n{e.stdout.strip()}")
        if e.stderr:
            print(f"--- STDERR ---\n{e.stderr.strip()}")
        if check:
            raise
        return e


# --- Pre-flight Checks ---


def pre_flight_checks():
    """Perform essential checks before running setup tasks."""
    log("INFO", "Running pre-flight checks...")
    if os.geteuid() != 0:
        log("FATAL", "This script must be run as root. Please use sudo.", Colors.RED)
        sys.exit(1)

    try:
        run_command(["ping", "-c", "1", "8.8.8.8"], check=True, capture=False)
        log("SUCCESS", "Internet connection is active.", Colors.GREEN)
    except (subprocess.CalledProcessError, FileNotFoundError):
        log("ERROR", "No internet connection. Please check your network.", Colors.RED)
        sys.exit(1)

    if not shutil.which("dnf"):
        log(
            "ERROR",
            "DNF command not found. This script requires a DNF-based system.",
            Colors.RED,
        )
        sys.exit(1)
    log("SUCCESS", "DNF is available.", Colors.GREEN)


# --- DNF and Repository Management ---


def setup_dnf():
    """Configure DNF and enable essential repositories."""
    log("INFO", "--- Starting DNF and Repository Setup ---", Colors.BLUE)

    # Configure DNF
    dnf_conf_src = PRECONFIG_DIR / "dnf.conf"
    dnf_conf_dest = pathlib.Path("/etc/dnf/dnf.conf")
    if dnf_conf_src.is_file() and not filecmp.cmp(
        str(dnf_conf_src), str(dnf_conf_dest)
    ):
        log("INFO", "Copying custom dnf.conf...")
        shutil.copy(dnf_conf_src, dnf_conf_dest)
        log("SUCCESS", "Custom dnf.conf applied.", Colors.GREEN)
    else:
        log("INFO", "DNF configuration is already up-to-date.", Colors.YELLOW)

    # Refresh DNF metadata
    log("INFO", "Refreshing DNF metadata...")
    run_command(["dnf", "makecache"], check=True)

    # Install RPM Fusion
    fedora_version = platform.release().split(".")[2]
    rpmfusion_free = f"https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-{fedora_version}.noarch.rpm"
    rpmfusion_nonfree = f"https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-{fedora_version}.noarch.rpm"

    run_command(["dnf", "install", "-y", rpmfusion_free, rpmfusion_nonfree], check=True)
    log("SUCCESS", "RPM Fusion repositories installed.", Colors.GREEN)

    # Enable COPR Repositories
    copr_repos = [
        "solopasha/hyprland",
        "sneexy/zen-browser",
        "errornointernet/quickshell",
    ]
    for repo in copr_repos:
        run_command(["dnf", "copr", "enable", "-y", repo], check=True)
        log("SUCCESS", f"COPR repository '{repo}' enabled.", Colors.GREEN)

    log("SUCCESS", "DNF and repository setup complete.", Colors.GREEN)


# --- System Configuration ---


def configure_system():
    """Apply system-level configurations."""
    log("INFO", "--- Starting System Configuration ---", Colors.BLUE)

    # Set Timezone
    tz_src = pathlib.Path("/usr/share/zoneinfo/Asia/Dhaka")
    tz_dest = pathlib.Path("/etc/localtime")
    if not tz_dest.is_symlink() or tz_dest.resolve() != tz_src:
        log("INFO", "Setting timezone to Asia/Dhaka...")
        tz_dest.unlink(missing_ok=True)
        tz_dest.symlink_to(tz_src)
        log("SUCCESS", "Timezone updated.", Colors.GREEN)
    else:
        log("INFO", "Timezone is already correct.", Colors.YELLOW)

    log("SUCCESS", "System configuration complete.", Colors.GREEN)


# --- Package Installation ---


def install_packages(package_list: List[str], reason: str):
    """Install a list of packages using DNF."""
    if not package_list:
        return
    log("INFO", f"Installing packages for: {reason}...")
    # Using --allowerasing to resolve potential conflicts
    cmd = ["dnf", "install", "-y", "--allowerasing"] + package_list
    run_command(cmd, check=True)
    log("SUCCESS", f"Packages for {reason} installed.", Colors.GREEN)


def setup_core_packages():
    """Install core system packages and development tools."""
    log("INFO", "--- Installing Core Packages ---", Colors.BLUE)
    core_packages = [
        "git-core",
        "curl",
        "wget",
        "unzip",
        "p7zip",
        "make",
        "gcc",
        "gcc-c++",
        "kernel-devel",
        "kernel-headers",
        "akmod-nvidia",
        "xorg-x11-drv-nvidia-cuda",
        "vulkan-tools",
        "ffmpeg",
    ]
    install_packages(core_packages, "Core System and NVIDIA")


def setup_desktop_environment():
    """Install Hyprland and related desktop components."""
    log("INFO", "--- Installing Desktop Environment ---", Colors.BLUE)
    de_packages = [
        "hyprland",
        "kitty",
        "rofi-wayland",
        "waybar",
        "swaybg",
        "xdg-desktop-portal-hyprland",
        "polkit-gnome",
        "thunar",
        "mako",
    ]
    install_packages(de_packages, "Hyprland Desktop Environment")


def setup_development_tools():
    """Install common development tools and languages."""
    log("INFO", "--- Installing Development Tools ---", Colors.BLUE)
    dev_packages = [
        "neovim",
        "emacs",
        "conda",
        "python3-neovim",
        "ripgrep",
        "fd-find",
        "nodejs",
        "npm",
        "golang",
        "rust",
        "cargo",
    ]
    install_packages(dev_packages, "Development Tools")


# --- NVIDIA Specific Configuration ---


def configure_nvidia():
    """Configure NVIDIA drivers and related settings."""
    log("INFO", "--- Starting NVIDIA Configuration ---", Colors.BLUE)

    # Check if akmod-nvidia is installed
    result = run_command(["rpm", "-q", "akmod-nvidia"], check=False)
    if result.returncode != 0:
        log(
            "WARNING",
            "akmod-nvidia is not installed. Skipping NVIDIA configuration.",
            Colors.YELLOW,
        )
        return

    # Enable services
    services = [
        "nvidia-suspend.service",
        "nvidia-resume.service",
        "nvidia-hibernate.service",
    ]
    for service in services:
        run_command(["systemctl", "enable", service], check=True)
        log("INFO", f"Enabled {service}.", Colors.GREEN)

    # Rebuild akmods if necessary
    current_kernel = platform.uname().release
    if not list(pathlib.Path("/lib/modules").glob(f"{current_kernel}/extra/nvidia*")):
        log(
            "INFO",
            "NVIDIA kernel modules not found for the current kernel. Rebuilding...",
        )
        run_command(["akmods", "--force", "--kernels", current_kernel], check=True)
        log("SUCCESS", "NVIDIA akmods rebuilt.", Colors.GREEN)
    else:
        log(
            "INFO",
            "NVIDIA kernel modules already exist for the current kernel.",
            Colors.YELLOW,
        )

    log("SUCCESS", "NVIDIA configuration complete.", Colors.GREEN)


# --- Flatpak Setup ---


def setup_flatpaks():
    """Configure Flatpak and install applications."""
    log("INFO", "--- Starting Flatpak Setup ---", Colors.BLUE)

    # Ensure flatpak is installed
    if not shutil.which("flatpak"):
        install_packages(["flatpak"], "Flatpak package manager")

    # Add Flathub repository for the user
    run_command(
        [
            "flatpak",
            "remote-add",
            "--if-not-exists",
            "--user",
            "flathub",
            "https://flathub.org/repo/flathub.flatpakrepo",
        ],
        as_user=SUDO_USER,
        check=True,
    )
    log("INFO", "User-wide Flathub remote configured.", Colors.GREEN)

    # Install Flatpak applications
    flatpak_apps = [
        "com.ranfdev.DistroShelf",
        "it.mijorus.gearlever",
    ]
    for app in flatpak_apps:
        # Check if already installed
        result = run_command(
            ["flatpak", "info", "--user", app], as_user=SUDO_USER, check=False
        )
        if result.returncode == 0:
            log("INFO", f"Flatpak app '{app}' is already installed.", Colors.YELLOW)
            continue

        log("INFO", f"Installing Flatpak app '{app}'...")
        run_command(
            ["flatpak", "install", "--user", "-y", "flathub", app],
            as_user=SUDO_USER,
            check=True,
        )
        log("SUCCESS", f"Flatpak app '{app}' installed.", Colors.GREEN)

    log("SUCCESS", "Flatpak setup complete.", Colors.GREEN)


# --- Dotfiles Management ---


def setup_dotfiles():
    """Manage dotfiles using GNU Stow."""
    log("INFO", "--- Starting Dotfiles Setup ---", Colors.BLUE)

    if not shutil.which("stow"):
        install_packages(["stow"], "GNU Stow for dotfiles management")

    dotfiles_repo_url = "https://github.com/your-username/your-dotfiles-repo.git"
    dotfiles_dir = USER_HOME / "dotfiles"

    # Clone dotfiles repository if it doesn't exist
    if not dotfiles_dir.is_dir():
        log("INFO", "Cloning dotfiles repository...")
        run_command(
            ["git", "clone", dotfiles_repo_url, str(dotfiles_dir)],
            as_user=SUDO_USER,
            check=True,
        )
    else:
        log("INFO", "Dotfiles repository already exists. Pulling latest changes...")
        run_command(["git", "pull"], cwd=dotfiles_dir, as_user=SUDO_USER, check=True)

    # Stow the dotfiles
    stow_packages = ["nvim", "kitty", "hypr"]  # Example packages in your dotfiles repo
    for pkg in stow_packages:
        log(f"INFO", f"Stowing '{pkg}' configuration...")
        # The -R flag makes stow remove and re-stow to resolve conflicts
        run_command(
            ["stow", "-R", pkg], cwd=dotfiles_dir, as_user=SUDO_USER, check=True
        )
        log(f"SUCCESS", f"'{pkg}' configuration stowed successfully.", Colors.GREEN)

    log("SUCCESS", "Dotfiles setup complete.", Colors.GREEN)


# --- Main Execution ---


def main():
    """Parse arguments and execute the selected setup tasks."""
    parser = argparse.ArgumentParser(
        description="A modular script for setting up a Fedora system.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "tasks",
        nargs="*",
        help="""Tasks to run. If no tasks are specified, 'all' is assumed.
Available tasks:
  all         - Run all setup tasks.
  dnf         - Configure DNF and repositories.
  system      - Apply system-level configurations (e.g., timezone).
  packages    - Install core, desktop, and development packages.
  nvidia      - Configure NVIDIA drivers.
  flatpak     - Set up Flatpak and install applications.
  dotfiles    - Set up dotfiles using Stow.
""",
        default=["all"],
    )
    args = parser.parse_args()
    tasks_to_run = args.tasks

    if "all" in tasks_to_run:
        tasks_to_run = ["dnf", "system", "packages", "nvidia", "flatpak", "dotfiles"]

    start_time = datetime.datetime.now()
    log(
        "INFO",
        f"Starting Fedora setup for tasks: {', '.join(tasks_to_run)}",
        Colors.BLUE,
    )

    pre_flight_checks()

    task_map = {
        "dnf": setup_dnf,
        "system": configure_system,
        "packages": lambda: [
            setup_core_packages(),
            setup_desktop_environment(),
            setup_development_tools(),
        ],
        "nvidia": configure_nvidia,
        "flatpak": setup_flatpaks,
        "dotfiles": setup_dotfiles,
    }

    for task_name in tasks_to_run:
        task_func = task_map.get(task_name)
        if task_func:
            try:
                task_func()
            except (subprocess.CalledProcessError, FileNotFoundError, Exception) as e:
                log(
                    "FATAL",
                    f"A critical error occurred during '{task_name}': {e}",
                    Colors.RED,
                )
                sys.exit(1)
        else:
            log("WARNING", f"Unknown task '{task_name}'. Skipping.", Colors.YELLOW)

    # Final system update
    log("INFO", "Performing a final system update...", Colors.BLUE)
    run_command(["dnf", "update", "-y"], check=True)

    duration = datetime.datetime.now() - start_time
    log("SUCCESS", f"Fedora setup completed successfully in {duration}.", Colors.GREEN)
    log("INFO", "A reboot is recommended to apply all changes.", Colors.YELLOW)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        log("INFO", "Script execution interrupted by user.", Colors.YELLOW)
        sys.exit(130)
    except Exception as e:
        log("FATAL", f"An unhandled exception occurred: {e}", Colors.RED)
        sys.exit(1)
