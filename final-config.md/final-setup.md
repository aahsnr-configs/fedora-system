Of course. I have re-engineered the application to support a fully automated installation process that intelligently handles reboots and resumes without any user intervention. This is a significant enhancement, transforming the script into a true "fire-and-forget" solution for a complete system setup.

The key improvements are:
*   **Automatic Reboot & Resume**: When run without flags (for a full installation), the script now automatically reboots the system after installing core packages and drivers—a step often necessary for kernel modules to load correctly.
*   **State Management**: The script saves its progress to a state file (`/var/tmp/fedora_installer.state`) before rebooting. Upon restart, it reads this file to seamlessly continue from where it left off, skipping already completed tasks.
*   **Systemd Resume Service**: A temporary `systemd` service is dynamically created to relaunch the installer automatically after the reboot. This service cleans itself up once the entire process is finished, leaving the system in a pristine state.
*   **User-Initiated vs. Automatic Flow**: The new reboot logic is **only** active during a full, no-flag installation. If you run the script with any specific task flags (e.g., `--install-packages`), it will perform only that task and exit as before, preserving its modularity for testing and debugging.
*   **Enhanced `--dry-run`**: The dry run mode now simulates the entire reboot-and-resume process, showing you when a reboot would be triggered and how the resume service would be configured, all without making any changes.

Here is the complete, final version of the Python application with the new automated resume functionality.

### How to Use the Flag-Based Application

The usage is now simpler for a full installation.

1.  **Prerequisites**: Ensure `python3.13` and `git` are available.
    ```bash
    sudo dnf install -y python3 git
    ```

2.  **Download**: Create a `fedora_installer` directory and save all the Python files listed below inside it.

3.  **Run the Script**: From the directory *containing* the `fedora_installer` package, execute with `sudo`.

    *   **Fully Automated Installation (Recommended):**
        This single command will start the process, automatically reboot, and continue until everything is finished.
        ```bash
        sudo python3.13 -m fedora_installer.install
        ```

    *   **Verify with a Dry Run (Highly Recommended First Step):**
        Simulate the entire automated process, including the reboot and resume steps.
        ```bash
        sudo python3.13 -m fedora_installer.install --dry-run
        ```

    *   **Running Specific Tasks (Manual Mode):**
        All flags still work independently for manual control without automatic reboots.
        ```bash
        # Example: Harden the system and then clean up packages
        sudo python3.13 -m fedora_installer.install --harden-system --cleanup
        ```

---

### Project Structure

A new `resume_manager.py` file has been added to handle the reboot and resume logic.

```
.
└── fedora_installer/
    ├── __init__.py
    ├── config.py
    ├── ui.py
    ├── utils.py
    ├── packages.py
    ├── system_setup.py
    ├── user_setup.py
    ├── source_installer.py
    ├── system_hardening.py
    ├── service_creator.py
    ├── resume_manager.py     # <-- NEW FILE
    ├── engine.py
    └── install.py
```

---

### The Python Application Files

#### `fedora_installer/__init__.py`
```python
# fedora_installer/__init__.py
# This file intentionally left blank to mark the directory as a Python package.
```

#### `fedora_installer/config.py`
```python
# fedora_installer/config.py
"""
Centralized configuration for the Fedora setup script.
"""
import os
from pathlib import Path

LOG_FILE: Path = Path("fedora_setup.log")
STATE_FILE: Path = Path("/var/tmp/fedora_installer.state")
SUDO_USER: str = os.environ.get("SUDO_USER", os.getlogin())
USER_HOME: Path = Path.home().joinpath("..", SUDO_USER).resolve()
DOTFILES_DIR: Path = USER_HOME / ".hyprdots"
TEMP_BUILD_DIR: Path = Path("/tmp/fedora_installer_builds")

RPMFUSION_FREE_URL = "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
RPMFUSION_NONFREE_URL = "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
```

#### `fedora_installer/ui.py`
```python
# fedora_installer/ui.py
"""
Handles all user interface elements, including colored printing and logging setup.
"""
import logging
import sys
from .config import LOG_FILE

class Colors:
    HEADER, BLUE, GREEN, YELLOW, RED, ENDC, BOLD = "\033[95m", "\033[94m", "\033[92m", "\033[93m", "\033[91m", "\033[0m", "\033[1m"

class Icons:
    STEP, INFO, SUCCESS, WARNING, ERROR, PROMPT, FINISH, PACKAGE, DESKTOP, SECURITY, HARDWARE, DEBUG, BUILD, REBOOT = "⚙️", "ℹ️", "✅", "⚠️", "❌", "❓", "🎉", "📦", "🖥️", "🛡️", "🔩", "🐞", "🛠️", "🔄"

def setup_logging() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s", handlers=[logging.FileHandler(LOG_FILE, mode="w", encoding="utf-8")])

def print_step(message: str) -> None:
    print(f"\n{Colors.HEADER}{Colors.BOLD}═══ {Icons.STEP} {message} ═══{Colors.ENDC}")
    logging.info(f"--- STEP: {message} ---")

def print_info(message: str) -> None:
    print(f"{Colors.BLUE}{Icons.INFO} {message}{Colors.ENDC}")
    logging.info(message)

def print_success(message: str) -> None:
    print(f"{Colors.GREEN}{Icons.SUCCESS} {message}{Colors.ENDC}")
    logging.info(f"SUCCESS: {message}")

def print_warning(message: str) -> None:
    print(f"{Colors.YELLOW}{Icons.WARNING} {message}{Colors.ENDC}", file=sys.stderr)
    logging.warning(message)

def print_error(message: str, fatal: bool = False) -> None:
    print(f"{Colors.RED}{Icons.ERROR} {message}{Colors.ENDC}", file=sys.stderr)
    logging.error(message)
    if fatal:
        sys.exit(1)

def print_dry_run(message: str) -> None:
    print(f"{Colors.YELLOW}{Icons.DEBUG} [DRY RUN] {message}{Colors.ENDC}")
    logging.info(f"[DRY RUN] {message}")
```

#### `fedora_installer/utils.py`
```python
# fedora_installer/utils.py
"""
Core utility functions for executing commands, checking system state, and file operations.
"""
import logging
import socket
import subprocess
import shutil
from pathlib import Path
from .ui import print_info, print_error, print_dry_run
from .config import LOG_FILE

def execute_command(command: list[str], description: str, as_user: str | None = None, cwd: Path | None = None, dry_run: bool = False) -> bool:
    """Executes a shell command using subprocess.run."""
    if as_user:
        command = ["sudo", "-u", as_user] + command

    cmd_str = ' '.join(command)
    print_info(description)
    logging.info(f"Preparing to run command: {cmd_str} in {cwd or Path.cwd()}")

    if dry_run:
        print_dry_run(f"Would execute: {cmd_str}")
        return True

    try:
        subprocess.run(command, check=True, text=True, capture_output=True, encoding="utf-8", cwd=cwd)
        return True
    except FileNotFoundError:
        print_error(f"Command not found: {command[0]}.")
        return False
    except subprocess.CalledProcessError as e:
        error_message = f"Command failed with exit code {e.returncode}: {cmd_str}"
        logging.error(f"{error_message}\nSTDOUT: {e.stdout.strip()}\nSTDERR: {e.stderr.strip()}")
        print_error(f"{error_message}\nError details logged to {LOG_FILE.name}.")
        return False
    except Exception as e:
        print_error(f"An unexpected error occurred while running '{cmd_str}': {e}")
        return False

def check_internet_connection() -> bool:
    print_info("Checking for internet connectivity...")
    try:
        socket.create_connection(("8.8.8.8", 53), timeout=5)
        return True
    except OSError:
        return False

def is_package_installed(package_name: str) -> bool:
    try:
        subprocess.run(["rpm", "-q", package_name], check=True, capture_output=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def binary_exists(name: str) -> bool:
    return shutil.which(name) is not None

def is_copr_enabled(repo_name: str) -> bool:
    try:
        result = subprocess.run(["dnf", "repolist", "enabled"], check=True, capture_output=True, text=True)
        return repo_name in result.stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def write_file_idempotent(path: Path, content: str, dry_run: bool = False) -> bool:
    if path.exists() and path.read_text(encoding="utf-8") == content:
        print_info(f"Configuration file {path} is already up to date.")
        return True
    if dry_run:
        print_dry_run(f"Would write new content to {path}.")
        return True
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return True
    except IOError as e:
        print_error(f"Failed to write to file {path}: {e}")
        return False
```

#### `fedora_installer/packages.py`
```python
# fedora_installer/packages.py
"""
This module centralizes all package lists for DNF, COPR, and Flatpak.
"""
from typing import List, Dict, Set

class PackageLists:
    """Provides categorized lists of packages for installation."""

    COPR_REPOS: Dict[str, str] = {
        "hyprland": "solopasha/hyprland", "zen-browser": "sneexy/zen-browser",
        "asus-linux": "lukenukem/asus-linux", "protonplus": "wehagy/protonplus",
        "lazygit": "dejan/lazygit", "starship": "atim/starship",
    }

    FLATPAK_APPS: List[str] = [
        "com.ticktick.TickTick", "org.onlyoffice.desktopeditors", "com.github.tchx84.Flatseal",
        "org.js.nuclear.Nuclear", "tv.kodi.Kodi", "com.bitwarden.desktop",
        "io.github.alainm23.planify", "com.ranfdev.DistroShelf", "com.dec05eba.gpu_screen_recorder",
    ]

    @staticmethod
    def _get_core_system() -> Set[str]:
        return {
            "acpid", "alsa-sof-firmware", "amd-gpu-firmware", "btrfs-progs", "chrony",
            "curl", "dnf-automatic", "dnf-plugins-core", "dnf-utils", "efibootmgr", "fwupd",
            "haveged", "intel-audio-firmware", "intel-gpu-firmware",
            "intel-vsc-firmware", "iwlwifi-dvm-firmware", "iwlwifi-mvm-firmware",
            "kernel", "kernel-core", "kernel-devel", "kernel-devel-matched", "kernel-headers",
            "kernel-modules", "kernel-modules-core", "kernel-modules-extra", "kmodtool",
            "lm_sensors", "mokutil", "NetworkManager-tui", "openssh", "plymouth",
            "plymouth-system-theme", "plymouth-theme-spinner", "power-profiles-daemon",
            "realtek-firmware", "rng-tools", "sysstat", "system-config-language", "tar",
            "usb_modeswitch", "bluez", "bluez-utils"
        }

    @staticmethod
    def _get_hyprland_desktop() -> Set[str]:
        return {
            "cliphist", "greetd", "grim", "hyprcursor", "hypridle", "hyprland",
            "hyprland-contrib", "hyprnome", "hyprpaper", "hyprpicker", "pyprland",
            "rofi-wayland", "slurp", "swappy", "swww", "tuigreet", "uwsm", "wf-recorder",
            "wl-clipboard", "xdg-desktop-portal-gnome", "xdg-desktop-portal-gtk",
            "xdg-desktop-portal-hyprland", "xorg-x11-server-Xwayland", "fuzzel"
        }

    @staticmethod
    def _get_desktop_apps_and_theming() -> Set[str]:
        return {
            "adw-gtk3-theme", "bibata-cursor-theme", "bleachbit", "deluge", "file-roller",
            "gnome-software", "imv", "kitty", "kvantum", "kvantum-qt5", "matugen", "maxima",
            "nwg-look", "papirus-icon-theme", "pavucontrol", "qt5ct", "qt6ct", "thunar",
            "thunar-archive-plugin", "thunar-media-tags-plugin", "thunar-volman", "tumbler",
            "transmission-qt", "wxMaxima", "xcur2png", "xournalpp", "zathura", "zathura-cb",
            "zathura-djvu", "zathura-pdf-poppler", "zathura-plugins-all", "zathura-ps", "zen-browser"
        }

    @staticmethod
    def _get_development_tools() -> Set[str]:
        return {
            "autoconf", "automake", "bison", "byacc", "cargo", "ccache", "cmake", "cscope", "ctags",
            "diffstat", "direnv", "emacs", "flex", "gcc", "gcc-c++", "git-delta", "git-lfs",
            "gmock", "gtest", "golang", "hatch", "koji", "lazygit", "libtool", "make", "meson",
            "mock", "neovim", "nodejs", "npm", "openssl", "patchutils", "pkgconf", "python3-build",
            "python3-devel", "python3-installer", "python3-neovim", "python3-pip",
            "redhat-rpm-config", "rpm-build", "rpmdevtools", "rust", "tree-sitter-cli", "valgrind",
            "yarnpkg", "quickshell-git"
        }

    @staticmethod
    def _get_cli_utilities() -> Set[str]:
        return {
            "atuin", "bat", "brightnessctl", "btop", "cava", "ddcutil", "eza", "fastfetch",
            "fd-find", "fdupes", "file", "fish", "fzf", "jq", "less", "man-db", "man-pages",
            "procs", "ripgrep", "socat", "starship", "tealdeer", "the-fuck", "tmux", "trash-cli",
            "tree", "units", "unrar", "unzip", "wget", "xz", "zip", "zoxide", "zsh", "zstd"
        }

    @staticmethod
    def _get_media_and_graphics() -> Set[str]:
        return {
            "akmod-nvidia", "ffmpegthumbnailer", "glx-utils", "libavif", "libheif", "libva-utils",
            "libva-vdpau-driver", "libwebp", "mesa-vulkan-drivers", "nvidia-gpu-firmware",
            "nvtop", "pipewire", "pipewire-utils", "switcheroo-control", "vulkan-tools",
            "wireplumber", "xorg-x11-drv-nvidia-cuda", "xorg-x11-drv-nvidia-cuda-libs",
            "p7zip", "p7zip-plugins"
        }

    @staticmethod
    def _get_security_and_system_admin() -> Set[str]:
        return {
            "aide", "arpwatch", "audit", "checkpolicy", "copr-selinux", "cronie",
            "dkms", "exiftool", "fail2ban", "git-credential-libsecret", "gnome-keyring",
            "libsemanage", "libsepol", "libsepol-utils", "ltrace", "lynis", "mcstrans", "libsecret",
            "PackageKit-command-not-found", "perf",  "policycoreutils", "policycoreutils-dbus",
            "policycoreutils-gui", "policycoreutils-python-utils", "policycoreutils-restorecond",
            "policycoreutils-sandbox", "poppler-utils", "powertop", "psacct", "seahorse", "secilc",
            "selint", "selinux-policy", "selinux-policy-sandbox", "selinux-policy-targeted",
            "sepolicy_analysis", "setools", "setools-console", "setools-gui", "setroubleshoot",
            "setroubleshoot-server", "snapper", "strace", "systemtap", "udica"
        }

    @staticmethod
    def _get_virtualization_and_containers() -> Set[str]:
        return {"distrobox", "lxc", "toolbox", "podman"}

    @staticmethod
    def _get_documentation_and_tex() -> Set[str]:
        return {
            "docbook-slides", "docbook-style-dsssl", "docbook-style-xsl", "docbook-utils",
            "docbook-utils-pdf", "docbook5-schemas", "docbook5-style-xsl", "doxygen",
            "groff-base", "linuxdoc-tools", "pandoc", "secilc-doc", "selinux-policy-doc",
            "texlive-scheme-basic", "xhtml1-dtds", "xmlto"
        }

    @staticmethod
    def _get_build_dependencies() -> Set[str]:
        return {
            "abseil-cpp-devel", "abseil-cpp-testing", "aquamarine-devel", "cairo-devel",
            "glaze-devel", "gsl-devel", "gtk-layer-shell-devel", "gtk3-devel", "hyprland-devel",
            "hyprlang", "hwdata-devel", "libavdevice-free-devel", "libavfilter-free-devel",
            "libavformat-free-devel", "libavutil-free-devel", "libdisplay-info-devel",
            "libdrm-devel", "libglvnd-devel", "libinput-devel", "libliftoff-devel",
            "libnotify-devel", "libpciaccess-devel", "libseat-devel", "libxcb-devel",
            "mesa-libgbm-devel", "policycoreutils-devel", "re2-devel", "selinux-policy-devel",
            "tomlplusplus-devel", "wayland-protocols-devel", "xcb-util-devel",
            "xcb-util-errors-devel", "xcb-util-renderutil-devel", "xcb-util-wm-devel",
            "xorg-x11-server-Xwayland-devel", "xisxwayland", "gsl", "glib2"
        }

    @classmethod
    def get_all_dnf(cls) -> List[str]:
        """Returns a sorted, unique list of all DNF packages from all categories."""
        all_packages = set.union(*[
            cls._get_core_system(), cls._get_hyprland_desktop(), cls._get_desktop_apps_and_theming(),
            cls._get_development_tools(), cls._get_cli_utilities(), cls._get_media_and_graphics(),
            cls._get_security_and_system_admin(), cls._get_virtualization_and_containers(),
            cls._get_documentation_and_tex(), cls._get_build_dependencies()
        ])
        return sorted(list(all_packages))
```

#### `fedora_installer/system_setup.py`
```python
# fedora_installer/system_setup.py
"""
Handles all system-wide configurations that require root privileges.
"""
from pathlib import Path
from .config import RPMFUSION_FREE_URL, RPMFUSION_NONFREE_URL
from .packages import PackageLists
from .ui import Icons, print_info, print_success, print_warning, print_error, Colors
from .utils import execute_command, is_package_installed, is_copr_enabled, write_file_idempotent

def configure_dnf(dry_run: bool = False) -> bool:
    print_info(f"{Icons.PACKAGE} Configuring DNF for optimal performance.")
    dnf_config_content = (
        "[main]\n"
        "gpgcheck=1\ninstallonly_limit=3\nclean_requirements_on_remove=True\n"
        "best=False\nskip_if_unavailable=True\nfastestmirror=True\n"
        "max_parallel_downloads=10\ndefaultyes=True\n"
    )
    path = Path("/etc/dnf/dnf.conf")
    return write_file_idempotent(path, dnf_config_content, dry_run)

def setup_repositories(dry_run: bool = False) -> bool:
    print_info(f"{Icons.PACKAGE} Setting up external repositories (RPM Fusion, COPR).")
    all_success = True
    if not is_package_installed("rpmfusion-free-release"):
        if not execute_command(["dnf", "install", "-y", RPMFUSION_FREE_URL], "Installing RPM Fusion Free.", dry_run=dry_run): all_success = False
    else: print_success("RPM Fusion Free is already installed.")
    if not is_package_installed("rpmfusion-nonfree-release"):
        if not execute_command(["dnf", "install", "-y", RPMFUSION_NONFREE_URL], "Installing RPM Fusion Non-Free.", dry_run=dry_run): all_success = False
    else: print_success("RPM Fusion Non-Free is already installed.")
    for name, repo in PackageLists.COPR_REPOS.items():
        if not is_copr_enabled(name):
            if not execute_command(["dnf", "copr", "enable", "-y", repo], f"Enabling COPR repository: {repo}", dry_run=dry_run): all_success = False
        else: print_success(f"COPR repository '{repo}' is already enabled.")
    return all_success

def install_dnf_packages(dry_run: bool = False) -> bool:
    packages = PackageLists.get_all_dnf()
    print_info(f"Found {len(packages)} unique DNF packages to install.")
    return execute_command(["dnf", "install", "-y"] + packages, "Installing all system packages via DNF.", dry_run=dry_run)

def configure_nvidia(dry_run: bool = False) -> bool:
    print_info(f"{Icons.HARDWARE} Applying NVIDIA-specific configurations.")
    if not is_package_installed("akmod-nvidia"):
        print_warning("NVIDIA drivers not found. Skipping NVIDIA configuration.")
        return True
    services = ["nvidia-suspend.service", "nvidia-resume.service", "nvidia-hibernate.service"]
    if not execute_command(["systemctl", "enable"] + services, "Enabling NVIDIA power management services.", dry_run=dry_run): return False
    if not execute_command(["systemctl", "mask", "nvidia-fallback.service"], "Masking NVIDIA fallback service.", dry_run=dry_run): return False
    print_warning("A reboot is required to build and load the NVIDIA kernel modules.")
    return True

def configure_shell(username: str, dry_run: bool = False) -> bool:
    print_info(f"Setting Zsh as the default shell for '{username}'.")
    zsh_path = "/usr/bin/zsh"
    return execute_command(["chsh", "-s", zsh_path, username], f"Changing shell for '{username}'.", dry_run=dry_run)

def cleanup_packages(dry_run: bool = False) -> bool:
    print_info("Checking for and removing any orphaned packages.")
    if dry_run:
        print_dry_run("Would run 'dnf autoremove'.")
        return True
    try:
        prompt = f"{Colors.YELLOW}{Icons.PROMPT} Do you want to remove all unused packages? [Y/n]: {Colors.ENDC}"
        if input(prompt).lower().strip() in ['n', 'no']:
            print_info("Skipping package cleanup.")
            return True
        return execute_command(["dnf", "autoremove", "-y"], "Removing orphaned packages.")
    except (EOFError, KeyboardInterrupt):
        print_info("\nSkipping package cleanup.")
        return True
```

#### `fedora_installer/user_setup.py`
```python
# fedora_installer/user_setup.py
"""
Handles all user-specific configurations.
"""
from pathlib import Path
from .config import SUDO_USER, DOTFILES_DIR, USER_HOME
from .packages import PackageLists
from .ui import Icons, print_info, print_warning, print_error
from .utils import execute_command, is_package_installed

def configure_git(dry_run: bool = False) -> bool:
    print_info(f"{Icons.DESKTOP} Configuring global Git settings for user '{SUDO_USER}'.")
    if not SUDO_USER: return False
    configs = [
        (["git", "config", "--global", "user.name", "aahsnr"], "Configuring Git user name."),
        (["git", "config", "--global", "user.email", "ahsanur041@proton.me"], "Configuring Git user email."),
        (["git", "config", "--global", "credential.helper", "/usr/libexec/git-core/git-credential-libsecret"], "Configuring Git credential helper.")
    ]
    return all(execute_command(cmd, desc, as_user=SUDO_USER, dry_run=dry_run) for cmd, desc in configs)

def configure_npm(dry_run: bool = False) -> bool:
    print_info(f"Configuring NPM global directory for user '{SUDO_USER}'.")
    if not SUDO_USER: return False
    npm_dir = USER_HOME / ".npm-global"
    if not dry_run: npm_dir.mkdir(exist_ok=True)
    return execute_command(["npm", "config", "set", "prefix", str(npm_dir)], "Setting NPM global prefix.", as_user=SUDO_USER, dry_run=dry_run)

def setup_flatpaks(dry_run: bool = False) -> bool:
    print_info(f"{Icons.PACKAGE} Setting up Flatpak and applications for user '{SUDO_USER}'.")
    if not SUDO_USER: return False
    if not is_package_installed("flatpak"):
        if not execute_command(["dnf", "install", "-y", "flatpak"], "Installing Flatpak system-wide.", dry_run=dry_run): return False
    repo_cmd = ["flatpak", "remote-add", "--if-not-exists", "--user", "flathub", "https://dl.flathub.org/repo/flathub.flatpakrepo"]
    if not execute_command(repo_cmd, "Adding Flathub repository (user).", as_user=SUDO_USER, dry_run=dry_run): return False
    apps = PackageLists.FLATPAK_APPS
    install_cmd = ["flatpak", "install", "--user", "-y", "flathub"] + apps
    return execute_command(install_cmd, f"Installing {len(apps)} Flatpak applications.", as_user=SUDO_USER, dry_run=dry_run)

def clone_dotfiles(dry_run: bool = False) -> bool:
    if not SUDO_USER: return False
    print_info(f"Cloning Hyprland dotfiles from github.com/aahsnr/.hyprdots.git")
    if DOTFILES_DIR.exists():
        print_warning(f"Dotfiles directory '{DOTFILES_DIR}' already exists. Skipping clone.")
        return True
    return execute_command(["git", "clone", "https://github.com/aahsnr/.hyprdots.git", str(DOTFILES_DIR)], "Cloning dotfiles repository.", as_user=SUDO_USER, dry_run=dry_run)

def configure_script_symlinks(dry_run: bool = False) -> bool:
    print_info("Creating symbolic links for custom scripts in /usr/local/bin.")
    scripts_dir = DOTFILES_DIR / "arch-scripts/bin"
    if not scripts_dir.is_dir():
        print_warning(f"Dotfiles script directory not found: {scripts_dir}. Skipping symlinks.")
        return True
    success = True
    for script_path in scripts_dir.iterdir():
        if script_path.is_file():
            dest = Path("/usr/local/bin") / script_path.name
            if dest.exists(): continue
            if not execute_command(["ln", "-s", str(script_path), str(dest)], f"Linking '{script_path.name}' to '{dest}'", dry_run=dry_run):
                success = False
    return success```

#### `fedora_installer/source_installer.py`
```python
# fedora_installer/source_installer.py
"""
Handles building and installing packages from source code.
"""
import shutil
from pathlib import Path
from .config import TEMP_BUILD_DIR, SUDO_USER, USER_HOME
from .ui import Icons, print_info, print_success, print_warning, print_error
from .utils import execute_command, binary_exists

def _build_python_from_git(repo_url: str, final_binary_name: str, dry_run: bool = False) -> bool:
    if binary_exists(final_binary_name):
        print_success(f"{final_binary_name} is already installed. Skipping build.")
        return True
    repo_name = Path(repo_url).stem
    clone_dir = TEMP_BUILD_DIR / repo_name
    if not dry_run:
        if clone_dir.exists(): shutil.rmtree(clone_dir)
        clone_dir.mkdir(parents=True, exist_ok=True)
    if not execute_command(["git", "clone", repo_url, "."], f"Cloning {repo_name}", cwd=clone_dir, dry_run=dry_run): return False
    if not execute_command(["python3", "-m", "build", "--wheel", "--no-isolation"], f"Building {repo_name}", cwd=clone_dir, dry_run=dry_run): return False
    if dry_run: return True
    try:
        wheel_file = next(clone_dir.joinpath("dist").glob("*.whl"))
    except StopIteration:
        print_error(f"Could not find a built wheel file for {repo_name}.")
        return False
    return execute_command(["python3", "-m", "installer", str(wheel_file)], f"Installing {repo_name}", dry_run=dry_run)

def install_grub_btrfs(dry_run: bool = False) -> bool:
    print_info(f"{Icons.BUILD} Building grub-btrfs from source.")
    install_script = Path("/etc/grub.d/41_snapshots-btrfs")
    if install_script.exists():
        print_success("grub-btrfs appears to be already installed. Skipping.")
        return True
    repo_url = "https://github.com/Antynea/grub-btrfs.git"
    clone_dir = TEMP_BUILD_DIR / "grub-btrfs"
    if not dry_run:
        if clone_dir.exists(): shutil.rmtree(clone_dir)
        clone_dir.mkdir(parents=True, exist_ok=True)
    if not execute_command(["git", "clone", repo_url, "."], "Cloning grub-btrfs", cwd=clone_dir, dry_run=dry_run): return False
    if not execute_command(["./install.sh"], "Running grub-btrfs install script", cwd=clone_dir, dry_run=dry_run): return False
    print_warning("grub-btrfs installed. You must now update your GRUB config.")
    print_info("Run 'sudo grub2-mkconfig -o /boot/grub2/grub.cfg' after this script finishes.")
    return True

def install_materialyoucolor(dry_run: bool = False) -> bool:
    print_info(f"{Icons.BUILD} Building materialyoucolor from source.")
    return _build_python_from_git("https://github.com/T-Dynamos/materialyoucolor-python.git", "materialyoucolor", dry_run)

def install_caelestia(dry_run: bool = False) -> bool:
    print_info(f"{Icons.BUILD} Building Caelestia from source.")
    if not SUDO_USER: return False
    if binary_exists("caelestia"):
        print_success("Caelestia CLI is already installed. Skipping build.")
        return True
    deps = ["glib2-devel", "libqalculate-devel", "qt6-qtdeclarative-devel", "pipewire-devel", "aubio-devel", "hatch", "python3-hatch-vcs", "python3-pillow", "libnotify-devel"]
    if not execute_command(["dnf", "install", "-y"] + deps, "Installing Caelestia build dependencies", dry_run=dry_run): return False
    if not _build_python_from_git("https://github.com/caelestia-dots/cli.git", "caelestia", dry_run): return False
    q_dir = USER_HOME / ".config/quickshell"
    shell_dir = q_dir / "caelestia"
    beat_detector_src = shell_dir / "assets/beat_detector.cpp"
    beat_detector_bin = q_dir / "beat_detector"
    final_bin_path = Path("/usr/lib/caelestia/beat_detector")
    if not execute_command(["mkdir", "-p", str(q_dir)], "Creating Quickshell config directory", as_user=SUDO_USER, dry_run=dry_run): return False
    if not shell_dir.exists():
        if not execute_command(["git", "clone", "https://github.com/caelestia-dots/shell.git", str(shell_dir)], "Cloning Caelestia shell config", as_user=SUDO_USER, dry_run=dry_run): return False
    if not final_bin_path.exists():
        compile_cmd = ["g++", "-std=c++17", "-o", str(beat_detector_bin), str(beat_detector_src), "-lpipewire-0.3", "-laubio"]
        if not execute_command(compile_cmd, "Compiling beat_detector", as_user=SUDO_USER, dry_run=dry_run): return False
        if not execute_command(["mkdir", "-p", str(final_bin_path.parent)], "Creating Caelestia lib directory", dry_run=dry_run): return False
        if not execute_command(["mv", str(beat_detector_bin), str(final_bin_path)], "Installing beat_detector binary", dry_run=dry_run): return False
    else: print_success("beat_detector binary is already installed.")
    return True

def cleanup_build_files(dry_run: bool = False) -> bool:
    print_info("Cleaning up temporary build files.")
    if dry_run:
        print_dry_run(f"Would remove directory: {TEMP_BUILD_DIR}")
        return True
    if TEMP_BUILD_DIR.exists(): shutil.rmtree(TEMP_BUILD_DIR)
    return True
```

#### `fedora_installer/system_hardening.py`
```python
# fedora_installer/system_hardening.py
"""
Handles system-wide security and configuration hardening tasks.
"""
from pathlib import Path
from .ui import Icons, print_info
from .utils import write_file_idempotent

def configure_environment_variables(dry_run: bool = False) -> bool:
    print_info(f"{Icons.SECURITY} Setting system-wide environment variables.")
    content = (
        '#!/bin/sh\n'
        'export EDITOR=${EDITOR:-/usr/bin/nano}\n'
        'export PAGER=${PAGER:-/usr/bin/less}\n'
        'export BROWSER="firefox"\n'
        'export PATH="$PATH:$HOME/.local/bin:$HOME/.npm-global/bin"\n'
    )
    path = Path("/etc/profile.d/99-custom-env.sh")
    return write_file_idempotent(path, content, dry_run)

def configure_security_limits(dry_run: bool = False) -> bool:
    print_info(f"{Icons.SECURITY} Setting user resource limits.")
    content = (
        "# Custom security limits added by installer\n"
        "* soft nofile 65536\n"
        "* hard nofile 1048576\n"
    )
    path = Path("/etc/security/limits.d/99-custom-limits.conf")
    return write_file_idempotent(path, content, dry_run)

def configure_login_banner(dry_run: bool = False) -> bool:
    print_info(f"{Icons.SECURITY} Setting security login banner.")
    content = (
        "--- WARNING ---\n"
        "This system is for authorized use only. Activity may be monitored.\n"
    )
    issue_path = Path("/etc/issue")
    issue_net_path = Path("/etc/issue.net")
    if not write_file_idempotent(issue_path, content, dry_run): return False
    return write_file_idempotent(issue_net_path, content, dry_run)

def configure_sshd(dry_run: bool = False) -> bool:
    print_info(f"{Icons.SECURITY} Applying hardened SSH server configuration.")
    content = (
        "Include /etc/ssh/sshd_config.d/*.conf\n"
        "PermitRootLogin no\n"
        "PasswordAuthentication no\n"
        "PubkeyAuthentication yes\n"
        "ChallengeResponseAuthentication no\n"
        "UsePAM yes\n"
        "X11Forwarding no\n"
        "PrintMotd no\n"
        "AcceptEnv LANG LC_*\n"
        "Subsystem sftp /usr/libexec/openssh/sftp-server\n"
        "MaxAuthTries 3\n"
    )
    path = Path("/etc/ssh/sshd_config.d/99-hardened.conf")
    return write_file_idempotent(path, content, dry_run)
```

#### `fedora_installer/service_creator.py`
```python
# fedora_installer/service_creator.py
"""
Creates and enables secure, sandboxed systemd user services.
"""
from pathlib import Path
from .config import SUDO_USER, USER_HOME
from .ui import Icons, print_info, print_error
from .utils import execute_command, binary_exists

def _get_pyprland_service_content(exec_path: str) -> str:
    return f"""[Unit]
Description=Pyprland - Hyprland IPC gateway
Documentation=https://github.com/hyprland-community/pyprland
PartOf=graphical-session.target
[Service]
ExecStart={exec_path}
Restart=on-failure
ProtectSystem=strict
ProtectHome=read-only
PrivateTmp=true
NoNewPrivileges=true
[Install]
WantedBy=graphical-session.target
"""

def _get_cliphist_service_content(exec_start: str, service_type: str) -> str:
    return f"""[Unit]
Description=Clipboard History Manager ({service_type})
Documentation=https://github.com/sentriz/cliphist
PartOf=graphical-session.target
[Service]
ExecStart={exec_start}
Restart=on-failure
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
NoNewPrivileges=true
ReadWritePaths=%h/.local/share/cliphist/
[Install]
WantedBy=graphical-session.target
"""

def _create_service_file(service_name: str, content: str, dry_run: bool = False) -> bool:
    service_dir = USER_HOME / ".config/systemd/user"
    service_path = service_dir / service_name
    if dry_run:
        print_info(f"[DRY RUN] Would write systemd service to {service_path}")
        return True
    try:
        service_dir.mkdir(parents=True, exist_ok=True)
        service_path.write_text(content, encoding="utf-8")
        return True
    except IOError as e:
        print_error(f"Failed to write {service_name}: {e}")
        return False

def configure_all_user_services(dry_run: bool = False) -> bool:
    print_info(f"{Icons.DESKTOP} Creating and enabling systemd user services.")
    if not SUDO_USER: return False
    all_success = True
    if binary_exists("pypr"):
        content = _get_pyprland_service_content("/usr/bin/pypr")
        if not _create_service_file("pyprland.service", content, dry_run): all_success = False
    if binary_exists("wl-paste") and binary_exists("cliphist"):
        text_cmd = "/usr/bin/wl-paste --watch /usr/bin/cliphist store"
        img_cmd = "/usr/bin/wl-paste --type image/png --watch /usr/bin/cliphist store"
        if not _create_service_file("cliphist-text.service", _get_cliphist_service_content(text_cmd, "Text"), dry_run): all_success = False
        if not _create_service_file("cliphist-image.service", _get_cliphist_service_content(img_cmd, "Image"), dry_run): all_success = False

    if not execute_command(["systemctl", "--user", "daemon-reload"], "Reloading user systemd daemon.", as_user=SUDO_USER, dry_run=dry_run): return False

    services_to_enable = ["pipewire.service", "pipewire-pulse.service", "wireplumber.service", "hypridle.service", "hyprpaper.service", "pyprland.service", "cliphist-text.service", "cliphist-image.service"]
    enable_cmd = ["systemctl", "--user", "enable", "--now"] + services_to_enable
    if not execute_command(enable_cmd, "Enabling and starting all user services.", as_user=SUDO_USER, dry_run=dry_run): all_success = False
    return all_success
```

#### `fedora_installer/resume_manager.py`
```python
# fedora_installer/resume_manager.py
"""
Manages the automatic reboot and resume functionality for the installer.
"""
from pathlib import Path
import sys
from .ui import Icons, print_info, print_warning
from .utils import write_file_idempotent, execute_command

SERVICE_FILE = Path("/etc/systemd/system/fedora-installer-resume.service")
# Get the absolute path to the current python executable to ensure the correct one is used.
PYTHON_EXEC = sys.executable
# Get the path of the running script package.
ENTRY_POINT = Path(sys.argv[0]).parent.name

SERVICE_CONTENT = f"""[Unit]
Description=Resume Fedora Installer after reboot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart={PYTHON_EXEC} -m {ENTRY_POINT} --resume
ExecStartPost=/bin/rm -f {SERVICE_FILE}

[Install]
WantedBy=default.target
"""

def schedule_reboot_and_resume(dry_run: bool = False):
    """Creates and enables the resume service, then triggers a reboot."""
    print_warning(f"{Icons.REBOOT} System reboot is required to continue the installation.")
    if not write_file_idempotent(SERVICE_FILE, SERVICE_CONTENT, dry_run): return
    if not execute_command(["systemctl", "enable", str(SERVICE_FILE)], "Enabling resume service.", dry_run=dry_run): return
    print_info("The system will now reboot to apply core updates and continue the installation automatically.")
    if not execute_command(["systemctl", "reboot"], "Rebooting system.", dry_run=dry_run): return

def cleanup_resume_service(dry_run: bool = False):
    """Disables and removes the resume service file if it exists."""
    if SERVICE_FILE.exists():
        print_info("Cleaning up resume service.")
        execute_command(["systemctl", "disable", SERVICE_FILE.name], "Disabling resume service.", dry_run=dry_run)
        if not dry_run:
            SERVICE_FILE.unlink()
```

#### `fedora_installer/engine.py`
```python
# fedora_installer/engine.py
"""
The engine orchestrates the entire setup process.
"""
from .ui import print_step, print_success, print_error, print_info
from .utils import check_internet_connection
from . import system_setup, user_setup, source_installer, system_hardening, service_creator
from .config import SUDO_USER, STATE_FILE

class SetupManager:
    """Orchestrates and executes the main steps of the Fedora setup process."""
    def __init__(self, dry_run: bool = False):
        self.dry_run = dry_run
        self.failed_tasks = []
        self.completed_tasks = set()

    def load_state(self):
        """Loads the set of completed tasks from the state file."""
        if STATE_FILE.exists():
            print_info(f"Found state file. Loading progress...")
            self.completed_tasks = set(STATE_FILE.read_text().splitlines())
        else:
            print_info("No state file found. Starting a fresh run.")

    def save_state(self):
        """Saves the set of completed tasks to the state file."""
        if not self.dry_run:
            STATE_FILE.write_text("\n".join(sorted(list(self.completed_tasks))))

    def clear_state(self):
        """Removes the state file on a fresh start or successful completion."""
        if not self.dry_run and STATE_FILE.exists():
            STATE_FILE.unlink()

    def _run_task(self, func, name: str, *args, **kwargs) -> bool:
        """Wrapper to run tasks, handle state, and track failures."""
        if name in self.completed_tasks:
            print_success(f"Task '{name}' already completed. Skipping.")
            return True
        if not func(*args, **kwargs, dry_run=self.dry_run):
            self.failed_tasks.append(name)
            print_error(f"Task '{name}' failed.")
            return False
        else:
            self.completed_tasks.add(name)
            self.save_state()
            print_success(f"Task '{name}' completed successfully.")
            return True

    def run_pre_flight_checks(self):
        print_step("Running Pre-flight Checks")
        if not check_internet_connection(): print_error("Internet connection is required.", fatal=True)
        if not SUDO_USER: print_error("Could not determine user via $SUDO_USER.", fatal=True)
        print_success(f"Internet is active. Running tasks for user: {SUDO_USER}")

    def run_repo_setup(self):
        print_step("Configuring System Repositories")
        if not self._run_task(system_setup.configure_dnf, "Configure DNF"): return False
        if not self._run_task(system_setup.setup_repositories, "Setup External Repositories"): return False
        return True

    def run_package_installation(self):
        print_step("Installing All System Packages")
        if not self._run_task(system_setup.install_dnf_packages, "Install DNF Packages"): return False
        if not self._run_task(user_setup.setup_flatpaks, "Install Flatpak Apps"): return False
        return True

    def run_source_installations(self):
        print_step("Building and Installing Packages from Source")
        if not self._run_task(source_installer.install_grub_btrfs, "Install grub-btrfs"): return False
        if not self._run_task(source_installer.install_materialyoucolor, "Install materialyoucolor"): return False
        if not self._run_task(source_installer.install_caelestia, "Install Caelestia"): return False
        if not self._run_task(source_installer.cleanup_build_files, "Cleanup Build Files"): return False
        return True

    def run_system_hardening(self):
        print_step("Applying System-Wide Hardening")
        if not self._run_task(system_hardening.configure_environment_variables, "Set Environment Variables"): return False
        if not self._run_task(system_hardening.configure_security_limits, "Set Security Limits"): return False
        if not self._run_task(system_hardening.configure_login_banner, "Set Login Banner"): return False
        if not self._run_task(system_hardening.configure_sshd, "Harden SSH Daemon"): return False
        return True

    def run_hardware_configuration(self):
        print_step("Configuring Hardware Drivers")
        if not self._run_task(system_setup.configure_nvidia, "Configure NVIDIA Drivers"): return False
        return True

    def run_user_configuration(self):
        print_step("Applying User-Specific Configurations")
        if not self._run_task(user_setup.clone_dotfiles, "Clone Hyprland Dotfiles"): return False
        if not self._run_task(system_setup.configure_shell, "Set Zsh as Default Shell", SUDO_USER): return False
        if not self._run_task(user_setup.configure_git, "Configure Git"): return False
        if not self._run_task(user_setup.configure_npm, "Configure NPM"): return False
        if not self._run_task(user_setup.configure_script_symlinks, "Configure Script Symlinks"): return False
        return True

    def run_desktop_environment_setup(self):
        print_step("Setting Up Desktop Environment")
        if not self._run_task(service_creator.configure_all_user_services, "Create and Enable User Services"): return False
        return True

    def run_cleanup(self):
        print_step("Running System Cleanup")
        if not self._run_task(system_setup.cleanup_packages, "Remove Orphaned Packages"): return False
        return True```

#### `fedora_installer/install.py`
```python
# fedora_installer/install.py
"""
Main entry point for the Fedora installer script.
"""
import argparse
import sys
import os
from .engine import SetupManager
from .ui import Colors, Icons, print_error, print_step, print_success, print_warning, setup_logging, print_dry_run, print_info
from .config import LOG_FILE
from . import resume_manager

def check_root():
    if os.geteuid() != 0:
        print_error("This script requires root privileges. Please run with 'sudo'.", fatal=True)

def print_summary_and_confirm(dry_run: bool):
    print_step("Full Installation Plan Summary")
    summary = f"""
This script will perform a full, opinionated setup of a Fedora Hyprland desktop.
It is designed to be fully automated, including a system reboot.

{Colors.HEADER}Execution Plan:{Colors.ENDC}
{Colors.BLUE}Phase 1 (Pre-Reboot):{Colors.ENDC}
   - Configure DNF, enable external repositories.
   - Install all core system packages, drivers, and applications.
   - The system will {Colors.YELLOW}automatically reboot{Colors.ENDC} after this phase.
{Colors.BLUE}Phase 2 (Post-Reboot):{Colors.ENDC}
   - The script will {Colors.YELLOW}resume automatically{Colors.ENDC} after login.
   - Build and install packages from source (grub-btrfs, etc.).
   - Apply system-wide security hardening.
   - Configure user settings (dotfiles, shell, Git, NPM).
   - Create and enable all desktop services.
   - Clean up any orphaned packages.
"""
    print(summary)
    if dry_run:
        print_dry_run("This is a dry run. The system will not actually reboot.")
        return
    try:
        prompt = f"{Colors.YELLOW}{Icons.PROMPT} Do you want to begin the automated installation? [y/N]: {Colors.ENDC}"
        if input(prompt).lower().strip() != 'y':
            print_info("Aborting at user request."); sys.exit(0)
    except (EOFError, KeyboardInterrupt):
        print_info("\nNo input received. Aborting."); sys.exit(0)

def main() -> None:
    parser = argparse.ArgumentParser(
        description=f"{Colors.BOLD}--- Fedora Hyprland Setup Script ---{Colors.ENDC}\n\nA modular installer for a personalized Fedora Hyprland setup.",
        epilog="""
Running the script without any flags triggers the fully automated installation.
Use specific task flags for manual control (this will disable automatic reboots).
""", formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument("--full-install", action="store_true", help=argparse.SUPPRESS) # Legacy, now default
    parser.add_argument("--resume", action="store_true", help=argparse.SUPPRESS) # For internal use by the resume service

    task_group = parser.add_argument_group('Manual Task Flags', 'Run specific parts of the setup. Using any of these disables the automatic reboot-resume flow.')
    task_group.add_argument("--setup-repos", action="store_true", help="Task: Configure DNF and set up all external repositories.")
    task_group.add_argument("--install-packages", action="store_true", help="Task: Install all DNF and Flatpak packages.")
    task_group.add_argument("--build-from-source", action="store_true", help="Task: Build packages from source (grub-btrfs, etc.).")
    task_group.add_argument("--harden-system", action="store_true", help="Task: Apply system-wide security hardening configurations.")
    task_group.add_argument("--configure-hardware", action="store_true", help="Task: Apply hardware-specific configurations (e.g., NVIDIA).")
    task_group.add_argument("--configure-user", action="store_true", help="Task: Apply user settings (Shell, Git, Dotfiles).")
    task_group.add_argument("--setup-hyprland", action="store_true", help="Task: Create and enable all Hyprland user systemd services.")
    task_group.add_argument("--cleanup", action="store_true", help="Task: Remove orphaned packages from the system.")

    options_group = parser.add_argument_group('Options')
    options_group.add_argument("--dry-run", action="store_true", help="Simulate the run without making any system changes.")
    args = parser.parse_args()

    check_root()
    setup_logging()
    if args.dry_run: print_dry_run("DRY RUN MODE ENABLED. No changes will be made to the system.")

    manager = SetupManager(dry_run=args.dry_run)
    manager.run_pre_flight_checks()

    # Check if any manual task flag was used
    manual_mode = any([
        args.setup_repos, args.install_packages, args.build_from_source,
        args.harden_system, args.configure_hardware, args.configure_user,
        args.setup_hyprland, args.cleanup
    ])

    if manual_mode:
        # --- MANUAL MODE ---
        print_info("Running in manual mode. Automatic reboot is disabled.")
        if args.setup_repos: manager.run_repo_setup()
        if args.install_packages: manager.run_package_installation()
        if args.build_from_source: manager.run_source_installations()
        if args.harden_system: manager.run_system_hardening()
        if args.configure_hardware: manager.run_hardware_configuration()
        if args.configure_user: manager.run_user_configuration()
        if args.setup_hyprland: manager.run_desktop_environment_setup()
        if args.cleanup: manager.run_cleanup()
    else:
        # --- AUTOMATED MODE ---
        if args.resume:
            print_info(f"{Icons.REBOOT} Resuming installation after reboot...")
            manager.load_state()
        else:
            print_summary_and_confirm(args.dry_run)
            manager.clear_state()

        # Phase 1: Pre-Reboot
        if not all([manager.run_repo_setup(), manager.run_package_installation(), manager.run_hardware_configuration()]):
            print_error("Pre-reboot phase failed. Aborting.", fatal=True)
        
        # Trigger reboot if this is the first run
        if not args.resume:
            resume_manager.schedule_reboot_and_resume(args.dry_run)
            # The script will exit here if not in dry run
            if not args.dry_run: sys.exit(0)

        # Phase 2: Post-Reboot
        if not all([
            manager.run_source_installations(), manager.run_system_hardening(),
            manager.run_user_configuration(), manager.run_desktop_environment_setup(),
            manager.run_cleanup()
        ]):
            print_error("Post-reboot phase failed. Please check logs.", fatal=True)
        
        # Final cleanup
        manager.clear_state()
        resume_manager.cleanup_resume_service(args.dry_run)

    print_step(f"{Icons.FINISH} Run Complete!")
    if not manager.failed_tasks:
        print_success("All requested tasks finished successfully!")
    else:
        print_warning(f"Process finished with {len(manager.failed_tasks)} error(s):")
        for failure in manager.failed_tasks: print(f"  - {failure}")
        print_warning(f"Please review the log file ('{LOG_FILE.name}') for details."); sys.exit(1)
    
    if not manual_mode or args.configure_hardware:
        print_warning("A final reboot is recommended to ensure all changes are applied.")
    sys.exit(0)

if __name__ == "__main__":
    main()
```
