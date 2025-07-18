#!/usr/bin/env python3
# fedora_setup.py

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

# --- Configuration ---


# Define colors for output
class Colors:
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[0;33m"
    BLUE = "\033[0;34m"
    NC = "\033[0m"


# Define Unicode symbols
class Symbols:
    SUCCESS = "✔"
    ERROR = "✖"
    INFO = "ℹ"
    WARNING = "⚠"


# Determine the non-root user's home directory
try:
    SUDO_USER = os.environ["SUDO_USER"]
    USER_HOME = pathlib.Path(pwd.getpwnam(SUDO_USER).pw_dir)
except KeyError:
    log("FATAL", "This script must be run with sudo by a regular user.", Colors.RED)
    sys.exit(1)


# Path to preconfigured files
PRECONFIG_DIR = USER_HOME / "fedora-setup" / "preconfigured-files"

# Destination paths for configuration files
DNF_CONF_DEST = pathlib.Path("/etc/dnf/dnf.conf")
VARIABLES_SH_DEST = pathlib.Path("/etc/profile.d/variables.sh")
TIMEZONE_DEST = pathlib.Path("/etc/localtime")
TIMEZONE_SRC = pathlib.Path("/usr/share/zoneinfo/Asia/Dhaka")

# Get Fedora release version
try:
    FEDORA_VERSION = subprocess.run(
        ["rpm", "-E", "%fedora"], check=True, capture_output=True, text=True
    ).stdout.strip()
except (subprocess.CalledProcessError, FileNotFoundError):
    print(f"{Colors.RED}Could not determine Fedora version. Exiting.{Colors.NC}")
    sys.exit(1)


# RPM Fusion URLs
RPMFUSION_FREE = f"https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-{FEDORA_VERSION}.noarch.rpm"
RPMFUSION_NONFREE = f"https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-{FEDORA_VERSION}.noarch.rpm"

# COPR repositories to enable
COPR_REPOS = [
    "solopasha/hyprland",
    "sneexy/zen-browser",
    "lukenukem/asus-linux",
    "wehagy/protonplus",
]

# Swap file configuration
SWAP_SUBVOLUME = pathlib.Path("/var/swap")
SWAP_FILE_NAME = "swapfile"
SWAP_FILE_PATH = SWAP_SUBVOLUME / SWAP_FILE_NAME
DRACUT_CONF_FILE = pathlib.Path("/etc/dracut.conf.d/resume.conf")
FSTAB_ENTRY = f"{SWAP_FILE_PATH} none swap defaults 0 0"

# --- Helper Functions ---


def log(log_type: str, message: str, color: str):
    """Logs messages with colors, timestamps, and symbols."""
    symbol_map = {
        "SUCCESS": Symbols.SUCCESS,
        "ERROR": Symbols.ERROR,
        "INFO": Symbols.INFO,
        "WARNING": Symbols.WARNING,
        "FATAL": Symbols.ERROR,
    }
    symbol = symbol_map.get(log_type, "")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{color}[{timestamp}] {symbol} {log_type}: {message}{Colors.NC}")


def run_command(
    command: List[str],
    as_user: str = None,
    check: bool = True,
    capture: bool = True,
    text: bool = True,
    **kwargs,
) -> subprocess.CompletedProcess:
    """
    Runs a command with optional user context and error checking.
    Handles 'sudo' automatically for non-root execution.
    """
    effective_command = command[:]
    if os.geteuid() != 0 and as_user is None:
        effective_command.insert(0, "sudo")

    def demote(user_uid, user_gid):
        def result():
            os.setgid(user_gid)
            os.setuid(user_uid)

        return result

    if as_user:
        pw_info = pwd.getpwnam(as_user)
        uid = pw_info.pw_uid
        gid = pw_info.pw_gid
        kwargs["preexec_fn"] = demote(uid, gid)

    try:
        return subprocess.run(
            effective_command, check=check, capture_output=capture, text=text, **kwargs
        )
    except subprocess.CalledProcessError as e:
        log(
            "ERROR",
            f"Command '{' '.join(e.cmd)}' failed with exit code {e.returncode}",
            Colors.RED,
        )
        if e.stdout:
            print(f"--- STDOUT ---\n{e.stdout}")
        if e.stderr:
            print(f"--- STDERR ---\n{e.stderr}")
        raise


def compare_files(src: pathlib.Path, dest: pathlib.Path) -> bool:
    """Returns True if files are identical or if destination does not exist."""
    if not src.is_file() or not dest.is_file():
        return False
    return filecmp.cmp(src, dest, shallow=False)


def copy_file_idempotent(src: pathlib.Path, dest: pathlib.Path) -> bool:
    """Copies a file if it's different from the destination."""
    file_name = src.name
    if not src.is_file():
        log(
            "WARNING",
            f"Source file '{src}' not found. Skipping '{file_name}' copy.",
            Colors.YELLOW,
        )
        return False

    log("INFO", f"Checking '{file_name}' configuration...", Colors.BLUE)
    if compare_files(src, dest):
        log("INFO", f"'{file_name}' is already up-to-date at '{dest}'.", Colors.YELLOW)
        return True

    log("INFO", f"Copying '{src}' to '{dest}'...", Colors.BLUE)
    try:
        dest.parent.mkdir(parents=True, exist_ok=True)
        run_command(["cp", "-f", str(src), str(dest)])
        log("SUCCESS", f"Copied '{file_name}' to '{dest}'.", Colors.GREEN)
        return True
    except Exception as e:
        log("ERROR", f"Failed to copy '{file_name}' to '{dest}': {e}", Colors.RED)
        return False


def dnf_install_idempotent(
    desc: str, check_cmd: List[str], install_cmd: List[str]
) -> bool:
    """Handles DNF package/repo installation with idempotency."""
    log("INFO", f"Checking: {desc}", Colors.BLUE)
    result = run_command(check_cmd, check=False)
    if result.returncode == 0:
        log("INFO", f"{desc} is already configured/installed.", Colors.YELLOW)
        return True

    log("INFO", f"Attempting to configure/install: {desc}", Colors.BLUE)
    try:
        run_command(install_cmd)
        log("SUCCESS", f"{desc} configured/installed successfully.", Colors.GREEN)
        return True
    except subprocess.CalledProcessError:
        log("ERROR", f"Failed to configure/install {desc}.", Colors.RED)
        return False


def install_packages(packages: List[str]) -> bool:
    """Installs a list of DNF packages, handling duplicates."""
    if not packages:
        log("INFO", "No packages to install.", Colors.BLUE)
        return True

    unique_packages = sorted(list(set(packages)))
    log(
        "INFO",
        f"Attempting to install {len(unique_packages)} unique packages...",
        Colors.BLUE,
    )
    log("INFO", f"Packages to install: {' '.join(unique_packages)}", Colors.BLUE)

    try:
        result = run_command(["dnf", "install", "-y"] + unique_packages, check=False)
        if result.returncode == 0:
            log(
                "SUCCESS",
                "All specified packages installed successfully.",
                Colors.GREEN,
            )
            return True
        else:
            log(
                "ERROR",
                f"DNF installation completed with errors (exit code: {result.returncode}). Some packages might not have been installed.",
                Colors.RED,
            )
            log(
                "WARNING",
                "Please review DNF's output above for details on failed packages.",
                Colors.YELLOW,
            )
            return False
    except Exception as e:
        log(
            "ERROR",
            f"An unexpected error occurred during package installation: {e}",
            Colors.RED,
        )
        return False


# --- Pre-flight Checks ---


def check_root():
    if os.geteuid() != 0:
        log("FATAL", "This script must be run as root. Please use sudo.", Colors.RED)
        sys.exit(1)


def check_internet_connection():
    log("INFO", "Checking internet connectivity...", Colors.BLUE)
    try:
        run_command(["curl", "-s", "-m", "10", "http://google.com"], capture=False)
        log("SUCCESS", "Internet connection is active.", Colors.GREEN)
    except subprocess.CalledProcessError:
        log(
            "ERROR",
            "No internet connection detected. Please check your network settings.",
            Colors.RED,
        )
        raise


def check_dnf_availability():
    log("INFO", "Checking DNF availability...", Colors.BLUE)
    if not shutil.which("dnf"):
        log("ERROR", "DNF command not found. This script requires DNF.", Colors.RED)
        raise FileNotFoundError("DNF not found")
    log("SUCCESS", "DNF command found.", Colors.GREEN)


def refresh_dnf_metadata():
    log("INFO", "Cleaning DNF cache and refreshing metadata...", Colors.BLUE)
    try:
        run_command(["dnf", "clean", "all"])
        run_command(["dnf", "makecache"])
        log("SUCCESS", "DNF cache cleaned and metadata refreshed.", Colors.GREEN)
    except subprocess.CalledProcessError:
        log("ERROR", "Failed to clean DNF cache or refresh metadata.", Colors.RED)
        raise


# --- Main Script Functions ---


def setup_dnf_configs() -> bool:
    log("INFO", "Starting DNF configuration setup...", Colors.BLUE)
    if not PRECONFIG_DIR.is_dir():
        log(
            "WARNING",
            f"Preconfigured files directory '{PRECONFIG_DIR}' not found. Skipping DNF config and variables.sh copy.",
            Colors.YELLOW,
        )
        return False
    copy_file_idempotent(PRECONFIG_DIR / "dnf.conf", DNF_CONF_DEST)
    copy_file_idempotent(PRECONFIG_DIR / "variables.sh", VARIABLES_SH_DEST)
    return True


def install_rpmfusion() -> bool:
    log("INFO", "Starting RPM Fusion repositories setup...", Colors.BLUE)
    free_ok = dnf_install_idempotent(
        "RPM Fusion Free repository",
        ["bash", "-c", "dnf repolist enabled | grep -q 'rpmfusion-free'"],
        ["dnf", "install", "-y", RPMFUSION_FREE],
    )
    nonfree_ok = dnf_install_idempotent(
        "RPM Fusion Nonfree repository",
        ["bash", "-c", "dnf repolist enabled | grep -q 'rpmfusion-nonfree'"],
        ["dnf", "install", "-y", RPMFUSION_NONFREE],
    )
    return free_ok and nonfree_ok


def enable_cisco_openh264() -> bool:
    log("INFO", "Starting Cisco OpenH264 setup...", Colors.BLUE)
    return dnf_install_idempotent(
        "Fedora Cisco OpenH264",
        [
            "bash",
            "-c",
            "dnf config-manager --dump fedora-cisco-openh264 | grep -q 'enabled = True'",
        ],
        ["dnf", "config-manager", "--set-enabled", "fedora-cisco-openh264"],
    )


def enable_copr_repos() -> bool:
    log("INFO", "Starting COPR repositories setup...", Colors.BLUE)
    all_success = True
    for repo in COPR_REPOS:
        repo_name = repo.replace("/", "-")
        check_proc = run_command(["dnf", "repolist", "enabled"], check=False)
        if f"copr:copr.fedorainfracloud.org:{repo_name}" in check_proc.stdout:
            log("INFO", f"COPR repository '{repo}' is already enabled.", Colors.YELLOW)
            continue
        try:
            log("INFO", f"Enabling COPR repository: '{repo}'...", Colors.BLUE)
            run_command(["dnf", "copr", "enable", "-y", repo])
            log(
                "SUCCESS",
                f"COPR repository '{repo}' enabled successfully.",
                Colors.GREEN,
            )
        except subprocess.CalledProcessError:
            log("ERROR", f"Failed to enable COPR repository '{repo}'.", Colors.RED)
            all_success = False
    return all_success


def set_timezone() -> bool:
    log("INFO", f"Starting timezone setup to {TIMEZONE_SRC.name}...", Colors.BLUE)
    if TIMEZONE_DEST.is_symlink() and TIMEZONE_DEST.resolve() == TIMEZONE_SRC.resolve():
        log("INFO", f"Timezone is already set to {TIMEZONE_SRC.name}.", Colors.YELLOW)
        return True

    log(
        "INFO",
        f"Creating symlink for timezone: '{TIMEZONE_SRC}' to '{TIMEZONE_DEST}'...",
        Colors.BLUE,
    )
    try:
        run_command(["ln", "-sf", str(TIMEZONE_SRC), str(TIMEZONE_DEST)])
        log("SUCCESS", f"Timezone set to {TIMEZONE_SRC.name}.", Colors.GREEN)
        return True
    except Exception as e:
        log("ERROR", f"Failed to set timezone: {e}", Colors.RED)
        return False


def calculate_swap_size() -> str:
    """Calculates swap size based on RAM, returns size string like '8G'."""
    try:
        import psutil

        mem_total_gb = psutil.virtual_memory().total / (1024**3)
    except ImportError:
        log(
            "WARNING",
            "'psutil' not found. Falling back to parsing 'free' command.",
            Colors.YELLOW,
        )
        free_output = run_command(["free", "-b"]).stdout
        mem_line = [
            line for line in free_output.split("\n") if line.startswith("Mem:")
        ][0]
        mem_total_bytes = int(mem_line.split()[1])
        mem_total_gb = mem_total_bytes / (1024**3)

    if mem_total_gb < 2:
        swap_size_gb = int(2 * mem_total_gb)
    elif 2 <= mem_total_gb < 8:
        swap_size_gb = int(1.5 * mem_total_gb)
    else:
        swap_size_gb = int(mem_total_gb)

    swap_size_gb = max(1, swap_size_gb)  # Ensure minimum 1GB
    return f"{swap_size_gb}G"


def setup_swap() -> bool:
    log("INFO", "Starting swap file setup...", Colors.BLUE)
    try:
        swap_size = calculate_swap_size()
        log(
            "INFO",
            f"Calculated swap size: {Colors.YELLOW}{swap_size}{Colors.NC}",
            Colors.BLUE,
        )

        if "btrfs" not in run_command(["findmnt", "-no", "FSTYPE", "/"]).stdout:
            log(
                "ERROR",
                "Root filesystem is not Btrfs. This script's swap setup is for Btrfs only.",
                Colors.RED,
            )
            return False

        if not SWAP_SUBVOLUME.is_dir():
            log(
                "INFO",
                f"Creating Btrfs subvolume: {Colors.YELLOW}{SWAP_SUBVOLUME}{Colors.NC}",
                Colors.BLUE,
            )
            run_command(["btrfs", "subvolume", "create", str(SWAP_SUBVOLUME)])
        else:
            log(
                "INFO",
                f"Btrfs subvolume {Colors.YELLOW}{SWAP_SUBVOLUME}{Colors.NC} already exists.",
                Colors.YELLOW,
            )

        log(
            "INFO",
            f"Setting NoCoW attribute on {Colors.YELLOW}{SWAP_SUBVOLUME}{Colors.NC}...",
            Colors.BLUE,
        )
        run_command(["chattr", "+C", str(SWAP_SUBVOLUME)])

        if not SWAP_FILE_PATH.is_file():
            log(
                "INFO",
                f"Creating swap file: {Colors.YELLOW}{SWAP_FILE_PATH}{Colors.NC} with size {Colors.YELLOW}{swap_size}{Colors.NC}...",
                Colors.BLUE,
            )
            run_command(["fallocate", "-l", swap_size, str(SWAP_FILE_PATH)])
            SWAP_FILE_PATH.chmod(0o600)
            log("INFO", "Formatting swap file...", Colors.BLUE)
            run_command(["mkswap", "-L", "SWAPFILE", str(SWAP_FILE_PATH)])
        else:
            log(
                "INFO",
                f"Swap file {Colors.YELLOW}{SWAP_FILE_PATH}{Colors.NC} already exists.",
                Colors.YELLOW,
            )
            blkid_check = run_command(
                ["blkid", "-p", "-s", "TYPE", "-o", "value", str(SWAP_FILE_PATH)],
                check=False,
            )
            if "swap" not in blkid_check.stdout:
                log(
                    "WARNING",
                    "Existing file is not formatted as swap. Formatting now.",
                    Colors.YELLOW,
                )
                run_command(["mkswap", "-L", "SWAPFILE", str(SWAP_FILE_PATH)])

        with open("/etc/fstab", "r") as f:
            if FSTAB_ENTRY not in f.read():
                log(
                    "INFO",
                    f"Adding '{Colors.YELLOW}{FSTAB_ENTRY}{Colors.NC}' to /etc/fstab.",
                    Colors.BLUE,
                )
                with open("/etc/fstab", "a") as f_append:
                    f_append.write(f"\n{FSTAB_ENTRY}\n")
            else:
                log("INFO", "Swap entry already exists in /etc/fstab.", Colors.YELLOW)

        log("INFO", "Activating swap...", Colors.BLUE)
        run_command(["swapon", "-av"])
        log("SUCCESS", f"Swap is now {Colors.GREEN}active{Colors.NC}.", Colors.GREEN)
        run_command(["free", "-h"], capture=False)

        dracut_conf_content = 'add_dracutmodules+=" resume "'
        if (
            not DRACUT_CONF_FILE.is_file()
            or dracut_conf_content not in DRACUT_CONF_FILE.read_text()
        ):
            DRACUT_CONF_FILE.parent.mkdir(exist_ok=True)
            DRACUT_CONF_FILE.write_text(dracut_conf_content + "\n")
            log("INFO", "Adding resume module to Dracut configuration.", Colors.BLUE)
        else:
            log("INFO", "Dracut resume module already configured.", Colors.YELLOW)

        log(
            "INFO",
            "Rebuilding Dracut initramfs. This might take some time...",
            Colors.BLUE,
        )
        run_command(["dracut", "-f"])
        log(
            "SUCCESS",
            f"Dracut initramfs rebuilt {Colors.GREEN}successfully{Colors.NC}.",
            Colors.GREEN,
        )

        log(
            "SUCCESS",
            f"Swap setup complete! Please {Colors.YELLOW}reboot your system{Colors.NC} for full effect.",
            Colors.GREEN,
        )
        return True
    except Exception as e:
        log("ERROR", f"Swap setup failed: {e}", Colors.RED)
        return False


# --- Package Installation Functions ---
def setup_git() -> bool:
    log("INFO", "Setting up Git...", Colors.BLUE)
    packages = [
        "git-core",
        "git-credential-libsecret",
        "gnome-keyring",
        "subversion",
        "git-delta",
        "highlight",
    ]
    if not install_packages(packages):
        return False

    git_configs = {
        "user.name": "aahsnr",
        "user.email": "ahsanur041@proton.me",
        "credential.helper": "/usr/libexec/git-core/git-credential-libsecret",
    }
    for key, value in git_configs.items():
        current_val = run_command(
            ["git", "config", "--global", key], as_user=SUDO_USER, check=False
        ).stdout.strip()
        if current_val != value:
            run_command(["git", "config", "--global", key, value], as_user=SUDO_USER)
            log("SUCCESS", f"Git {key} set to '{value}'.", Colors.GREEN)
        else:
            log("INFO", f"Git {key} is already '{value}'.", Colors.YELLOW)

    run_command(
        ["git", "config", "--global", "core.preloadindex", "true"], as_user=SUDO_USER
    )
    run_command(
        ["git", "config", "--global", "core.fscache", "true"], as_user=SUDO_USER
    )
    run_command(["git", "config", "--global", "gc.auto", "256"], as_user=SUDO_USER)
    log("SUCCESS", "Other Git configurations applied.", Colors.GREEN)
    return True


def setup_editors() -> bool:
    log("INFO", "Setting up Editors and related tools...", Colors.BLUE)
    packages = [
        "emacs",
        "nodejs",
        "npm",
        "yarnpkg",
        "fzf",
        "fd-find",
        "ripgrep",
        "neovim",
        "enchant2-devel",
        "pkgconf",
        "python3-lsp-server+all",
        "python3-neovim",
        "tree-sitter-cli",
        "wl-clipboard",
        "shfmt",
        "ImageMagick",
        "hunspell",
        "pandoc",
        "hunspell-en-US",
        "pyright",
        "pylint",
        "black",
        "isort",
        "debugpy",
        "stix-fonts",
        "google-noto-sans-fonts",
        "google-noto-color-emoji-fonts",
        "bash-language-server",
        "ansible",
        "direnv",
        "clang-tools-extra",
        "fprettify",
        "fortls",
        "gfortran",
        "grip",
        "shellcheck",
        "java",
        "jetbrains-mono-fonts-all",
        "conda",
        "pipx",
        "python3-pipx",
    ]
    return install_packages(packages)


def setup_multimedia() -> bool:
    log("INFO", "Installing Media-Related packages...", Colors.BLUE)

    log("INFO", "Updating @multimedia group...", Colors.BLUE)
    try:
        run_command(
            [
                "dnf",
                "group",
                "update",
                "@multimedia",
                "--setopt=install_weak_deps=False",
                "--exclude=PackageKit-gstreamer-plugin",
                "-y",
            ]
        )
        log("SUCCESS", "@multimedia group updated successfully.", Colors.GREEN)
    except subprocess.CalledProcessError:
        log("ERROR", "Failed to update @multimedia group.", Colors.RED)
        return False

    media_packages = [
        "alsa-utils",
        "pipewire",
        "pipewire-alsa",
        "pipewire-gstreamer",
        "pipewire-pulseaudio",
        "pipewire-utils",
        "pulseaudio-utils",
        "wireplumber",
        "libva-nvidia-driver",
        "mesa-vdpau-drivers-freeworld",
        "mesa-va-drivers-freeworld",
        "nvidia-vaapi-driver",
        "mesa-vulkan-drivers",
        "vulkan-tools",
        "ffmpeg",
        "mediainfo",
    ]
    if not install_packages(media_packages):
        return False

    log(
        "INFO",
        "Installing rpmfusion-nonfree-release-tainted and firmware...",
        Colors.BLUE,
    )
    if not dnf_install_idempotent(
        "RPM Fusion Nonfree Tainted repository",
        ["bash", "-c", "dnf repolist enabled | grep -q 'rpmfusion-nonfree-tainted'"],
        ["dnf", "install", "-y", "rpmfusion-nonfree-release-tainted"],
    ):
        return False

    try:
        log("INFO", "Installing tainted firmware...", Colors.BLUE)
        run_command(
            ["dnf", "--repo=rpmfusion-nonfree-tainted", "install", "*-firmware", "-y"]
        )
        log("SUCCESS", "Tainted firmware installed successfully.", Colors.GREEN)
    except subprocess.CalledProcessError:
        log("ERROR", "Failed to install tainted firmware.", Colors.RED)
        return False

    return True


def install_all_dnf_packages() -> bool:
    log("INFO", "Starting installation of all general DNF packages...", Colors.BLUE)
    all_packages = [
        "@fonts",
        "abseil-cpp-devel",
        "abseil-cpp-testing",
        "acpid",
        "aide",
        "akmod-nvidia",
        "akmods",
        "alsa-sof-firmware",
        "amd-gpu-firmware",
        "arpwatch",
        "autoconf",
        "automake",
        "bat",
        "bison",
        "bluez",
        "brightnessctl",
        "btop",
        "byacc",
        "ccache",
        "cava",
        "checkpolicy",
        "chrony",
        "cliphist",
        "copr-selinux",
        "cronie",
        "cscope",
        "ctags",
        "curl",
        "diffstat",
        "distrobox",
        "dkms",
        "dnf-automatic",
        "dnf-plugins-core",
        "docbook-slides",
        "docbook-style-dsssl",
        "docbook-style-xsl",
        "docbook-utils",
        "docbook-utils-pdf",
        "docbook5-schemas",
        "docbook5-style-xsl",
        "doxygen",
        "egl-wayland",
        "exiftool",
        "fail2ban",
        "fastfetch",
        "fdupes",
        "fedora-workstation-repositories",
        "ffmpegthumbnailer",
        "file",
        "file-roller",
        "fish",
        "flex",
        "fontconfig",
        "fuzzel",
        "glaze-devel",
        "glib2",
        "glx-utils",
        "gmock",
        "gnome-software",
        "gnuplot",
        "groff-base",
        "gsl",
        "gsl-devel",
        "gtest",
        "gtk-layer-shell-devel",
        "gtk3-devel",
        "greetd",
        "grim",
        "haveged",
        "imv",
        "inotify-tools",
        "intel-audio-firmware",
        "intel-gpu-firmware",
        "intel-vsc-firmware",
        "iwlwifi-dvm-firmware",
        "iwlwifi-mvm-firmware",
        "jq",
        "kernel",
        "kernel-core",
        "kernel-devel",
        "kernel-devel-matched",
        "kernel-headers",
        "kernel-modules",
        "kernel-modules-core",
        "kernel-modules-extra",
        "kitty",
        "kmodtool",
        "koji",
        "kvantum",
        "kvantum-qt5",
        "latexmk",
        "lazygit",
        "less",
        "libavif",
        "libavdevice-free-devel",
        "libavfilter-free-devel",
        "libavformat-free-devel",
        "libavutil-free-devel",
        "libdisplay-info-devel",
        "libdrm-devel",
        "libglvnd-devel",
        "libglvnd-glx",
        "libglvnd-opengl",
        "libheif",
        "libinput-devel",
        "libliftoff",
        "libliftoff-devel",
        "libnotify-devel",
        "libpciaccess-devel",
        "libsemanage",
        "libseat-devel",
        "libsepol",
        "libsepol-utils",
        "libtool",
        "libva-utils",
        "libwebp",
        "libxcb",
        "libxcb-devel",
        "linuxdoc-tools",
        "lm_sensors",
        "ltrace",
        "lynis",
        "make",
        "man-db",
        "man-pages",
        "matugen",
        "maxima",
        "mcstrans",
        "mesa-libgbm-devel",
        "mock",
        "mokutil",
        "NetworkManager-tui",
        "nvidia-gpu-firmware",
        "nvtop",
        "nwg-look",
        "openssl",
        "PackageKit-command-not-found",
        "pandoc",
        "papirus-icon-theme",
        "patchutils",
        "p7zip",
        "p7zip-plugins",
        "perf",
        "pkgconf",
        "plymouth-theme-spinner",
        "plymouth-system-theme",
        "podman",
        "policycoreutils",
        "policycoreutils-dbus",
        "policycoreutils-devel",
        "policycoreutils-gui",
        "policycoreutils-python-utils",
        "policycoreutils-restorecond",
        "policycoreutils-sandbox",
        "poppler-utils",
        "powertop",
        "procs",
        "psacct",
        "python3-build",
        "python3-devel",
        "python3-installer",
        "python3-matplotlib",
        "python3-matplotlib-tk",
        "python3-notebook",
        "python3-numpy",
        "python3-pandas",
        "python3-pillow",
        "python3-pillow-tk",
        "python3-policycoreutils",
        "python3-scikit-image",
        "python3-scikit-learn",
        "python3-scipy",
        "python3-setools",
        "python3-sympy",
        "qt5-qtwayland",
        "qt5ct",
        "qt6-qtwayland",
        "qt6ct",
        "re2-devel",
        "realtek-firmware",
        "redhat-rpm-config",
        "rng-tools",
        "rofi-wayland",
        "rpm-build",
        "rpmdevtools",
        "sassc",
        "secilc",
        "secilc-doc",
        "selint",
        "selinux-policy",
        "selinux-policy-devel",
        "selinux-policy-doc",
        "selinux-policy-sandbox",
        "selinux-policy-targeted",
        "sepolicy_analysis",
        "setools",
        "setools-console",
        "setools-console-analyses",
        "setools-gui",
        "setroubleshoot",
        "setroubleshoot-server",
        "slurp",
        "socat",
        "starship",
        "strace",
        "swappy",
        "switcheroo-control",
        "swww",
        "sysstat",
        "system-config-language",
        "systemtap",
        "tar",
        "tealdeer",
        "texlive",
        "texlive-cm-lgc",
        "texlive-kerkis",
        "texlive-synctex",
        "thefuck",
        "thunar",
        "thunar-archive-plugin",
        "thunar-media-tags-plugin",
        "thunar-volman",
        "tmux",
        "tomlplusplus-devel",
        "toolbox",
        "transmission-gtk",
        "trash-cli",
        "tree",
        "tumbler",
        "tuigreet",
        "udica",
        "units",
        "unzip",
        "usb_modeswitch",
        "uwsm",
        "valgrind",
        "wayland-protocols-devel",
        "wget",
        "wxMaxima",
        "xdg-desktop-portal-gtk",
        "xhtml1-dtds",
        "xisxwayland",
        "xmlto",
        "xorg-x11-drv-nvidia-cuda",
        "xorg-x11-drv-nvidia-cuda-libs",
        "xorg-x11-server-Xwayland-devel",
        "xournalpp",
        "xcur2png",
        "zathura",
        "zathura-cb",
        "zathura-djvu",
        "zathura-pdf-poppler",
        "zathura-plugins-all",
        "zathura-ps",
        "zen-browser",
        "zip",
        "zoxide",
        "zsh",
        "gcc",
        "gcc-c++",
    ]
    return install_packages(all_packages)


# --- Specific Setups ---
def configure_systemd_service(service: str, user_mode=False) -> bool:
    """Checks, enables, and starts a systemd service idempotently."""
    cmd_base = ["systemctl"]
    run_args = {"check": False}

    if user_mode:
        cmd_base.append("--user")
        run_args["as_user"] = SUDO_USER

    run_command(cmd_base + ["daemon-reload"], **run_args)

    if run_command(cmd_base + ["is-enabled", service], **run_args).returncode == 0:
        log("INFO", f"Service '{service}' is already enabled.", Colors.YELLOW)
        return True

    log("INFO", f"Enabling and starting service '{service}'...", Colors.BLUE)
    try:
        run_command(cmd_base + ["enable", "--now", service], **run_args, check=True)
        log("SUCCESS", f"Service '{service}' enabled and started.", Colors.GREEN)
        return True
    except subprocess.CalledProcessError:
        log("ERROR", f"Failed to enable/start service '{service}'.", Colors.RED)
        return False


def configure_nvidia() -> bool:
    log("INFO", "Starting NVIDIA specific configurations...", Colors.BLUE)
    current_kernel = platform.uname().release

    if (
        run_command(
            ["dnf", "repoquery", "--userinstalled", "akmod-nvidia"], check=False
        ).returncode
        != 0
    ):
        log("INFO", "Marking akmod-nvidia as user-managed...", Colors.BLUE)
        run_command(["dnf", "mark", "user", "akmod-nvidia"])
    else:
        log("INFO", "akmod-nvidia is already marked as user-managed.", Colors.YELLOW)

    all_ok = True
    for service in [
        "nvidia-suspend.service",
        "nvidia-resume.service",
        "nvidia-hibernate.service",
    ]:
        if not configure_systemd_service(service):
            all_ok = False
    if not all_ok:
        return False

    macro_file = pathlib.Path("/etc/rpm/macros.nvidia-kmod")
    macro_content = "%_with_kmod_nvidia_open 1"
    if not macro_file.is_file() or macro_file.read_text().strip() != macro_content:
        log("INFO", "Creating RPM macro for NVIDIA kmod...", Colors.BLUE)
        macro_file.write_text(macro_content + "\n")
    else:
        log("INFO", "RPM macro for NVIDIA kmod already exists.", Colors.YELLOW)

    if not pathlib.Path(
        f"/lib/modules/{current_kernel}/extra/nvidia/nvidia.ko"
    ).exists():
        log("INFO", "Rebuilding NVIDIA akmods for current kernel...", Colors.BLUE)
        run_command(["akmods", "--kernels", current_kernel, "--rebuild"])
    else:
        log("INFO", "NVIDIA akmods for current kernel already built.", Colors.YELLOW)

    if (
        run_command(
            ["systemctl", "is-masked", "nvidia-fallback.service"], check=False
        ).returncode
        != 0
    ):
        log("INFO", "Masking nvidia-fallback.service...", Colors.BLUE)
        run_command(["systemctl", "mask", "nvidia-fallback.service"])
    else:
        log("INFO", "nvidia-fallback.service is already masked.", Colors.YELLOW)

    return True


def setup_asus_laptops() -> bool:
    log("INFO", "Setting up for Asus Laptops...", Colors.BLUE)
    packages = ["asusctl", "power-profiles-daemon", "supergfxctl", "asusctl-rog-gui"]
    if not install_packages(packages):
        return False

    all_ok = True
    for service in ["supergfxd", "power-profiles-daemon"]:
        if not configure_systemd_service(service):
            all_ok = False
    return all_ok


def setup_flatpaks() -> bool:
    log("INFO", "Setting up Flatpak and installing applications...", Colors.BLUE)
    if not dnf_install_idempotent(
        "Flatpak package manager",
        ["command", "-v", "flatpak"],
        ["dnf", "install", "-y", "flatpak"],
    ):
        return False

    log("INFO", "Ensuring system-wide Flatpak remotes are removed...", Colors.BLUE)
    system_remotes = run_command(
        ["flatpak", "remote-list", "--system"], check=False
    ).stdout
    for remote in ["fedora", "flathub-beta", "flathub"]:
        if remote in system_remotes:
            log("INFO", f"Removing system remote '{remote}'...", Colors.YELLOW)
            run_command(["flatpak", "remote-delete", "--system", remote], check=False)

    if (
        "flathub"
        not in run_command(
            ["flatpak", "remote-list", "--user"], as_user=SUDO_USER, check=False
        ).stdout
    ):
        log("INFO", "Adding user-wide Flathub remote...", Colors.BLUE)
        run_command(
            [
                "flatpak",
                "remote-add",
                "--user",
                "--if-not-exists",
                "flathub",
                "https://dl.flathub.org/repo/flathub.flatpakrepo",
            ],
            as_user=SUDO_USER,
        )
    else:
        log("INFO", "User-wide Flathub remote already exists.", Colors.YELLOW)

    flatpak_apps = [
        "com.ticktick.TickTick",
        "org.onlyoffice.desktopeditors",
        "com.github.tchx84.Flatseal",
        "org.js.nuclear.Nuclear",
        "tv.kodi.Kodi",
        "com.bitwarden.desktop",
        "io.github.alainm23.planify",
        "com.ranfdev.DistroShelf",
        "com.dec05eba.gpu_screen_recorder",
    ]
    all_installed = True
    for app in flatpak_apps:
        if (
            run_command(
                ["flatpak", "info", app], as_user=SUDO_USER, check=False
            ).returncode
            == 0
        ):
            log("INFO", f"Flatpak app '{app}' is already installed.", Colors.YELLOW)
            continue
        log("INFO", f"Installing Flatpak app '{app}'...", Colors.BLUE)
        try:
            run_command(
                ["flatpak", "install", "flathub", app, "-y", "--noninteractive"],
                as_user=SUDO_USER,
            )
            log("SUCCESS", f"Flatpak app '{app}' installed successfully.", Colors.GREEN)
        except subprocess.CalledProcessError:
            log("ERROR", f"Failed to install Flatpak app '{app}'.", Colors.RED)
            all_installed = False
    return all_installed


def setup_tmux() -> bool:
    log("INFO", "Setting up tmux...", Colors.BLUE)
    tmux_config_file = USER_HOME / ".hyprdots" / ".tmux.conf"
    tmux_conf_symlink = USER_HOME / ".tmux.conf"

    tmux_dir = USER_HOME / ".tmux"
    tmux_plugins_dir = tmux_dir / "plugins"
    run_command(["mkdir", "-p", str(tmux_plugins_dir)], as_user=SUDO_USER)
    run_command(["chmod", "700", str(tmux_dir)], as_user=SUDO_USER)

    if not tmux_config_file.is_file():
        log(
            "ERROR", f"tmux configuration not found at '{tmux_config_file}'", Colors.RED
        )
        return False
    if not tmux_conf_symlink.is_symlink() or str(tmux_conf_symlink.resolve()) != str(
        tmux_config_file
    ):
        log("INFO", "Setting up tmux configuration symlink...", Colors.BLUE)
        run_command(
            ["ln", "-sf", str(tmux_config_file), str(tmux_conf_symlink)],
            as_user=SUDO_USER,
        )
        run_command(["chmod", "600", str(tmux_conf_symlink)], as_user=SUDO_USER)
    else:
        log("INFO", "tmux.conf is already symlinked correctly.", Colors.YELLOW)

    tpm_dir = tmux_plugins_dir / "tpm"
    if tpm_dir.is_dir():
        log("INFO", "Updating TPM...", Colors.YELLOW)
        run_command(["git", "pull"], as_user=SUDO_USER, check=False, cwd=str(tpm_dir))
    else:
        log("INFO", "Installing TPM...", Colors.BLUE)
        run_command(
            ["git", "clone", "https://github.com/tmux-plugins/tpm", str(tpm_dir)],
            as_user=SUDO_USER,
        )

    log("INFO", "Installing tmux plugins...", Colors.BLUE)
    try:
        run_command(
            ["tmux", "new-session", "-d", "-s", "setup_session"], as_user=SUDO_USER
        )
        install_script = USER_HOME / ".tmux/plugins/tpm/bin/install_plugins"
        if install_script.exists():
            run_command(
                [
                    "tmux",
                    "send-keys",
                    "-t",
                    "setup_session",
                    str(install_script),
                    "Enter",
                ],
                as_user=SUDO_USER,
            )
            import time

            time.sleep(10)
        run_command(
            ["tmux", "kill-session", "-t", "setup_session"],
            as_user=SUDO_USER,
            check=False,
        )
        log("SUCCESS", "Tmux plugins installation command sent.", Colors.GREEN)
    except Exception as e:
        log(
            "ERROR",
            f"Failed to start tmux session for plugin installation: {e}",
            Colors.RED,
        )

    systemd_user_dir = USER_HOME / ".config/systemd/user"
    run_command(["mkdir", "-p", str(systemd_user_dir)], as_user=SUDO_USER)
    service_file = systemd_user_dir / "tmux.service"
    service_content = """[Unit]
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
WantedBy=default.target"""
    if (
        not service_file.is_file()
        or service_file.read_text().strip() != service_content
    ):
        run_command(
            ["bash", "-c", f"echo '{service_content}' > {service_file}"],
            as_user=SUDO_USER,
        )
        log("SUCCESS", "Tmux systemd service file created/updated.", Colors.GREEN)
    else:
        log("INFO", "Tmux systemd service file is up-to-date.", Colors.YELLOW)

    return configure_systemd_service("tmux.service", user_mode=True)


def setup_nix() -> bool:
    log("INFO", "Starting Nix and Home-Manager Installation...", Colors.BLUE)

    if not shutil.which("nix"):
        log("INFO", "Running Determinate Systems Nix installer...", Colors.YELLOW)
        try:
            import requests

            installer_script = requests.get(
                "https://install.determinate.systems/nix"
            ).text
            run_command(
                ["sh", "-s", "--", "install", "--determinate"],
                input=installer_script,
                check=True,
            )
            log(
                "SUCCESS",
                "Nix installation command executed successfully.",
                Colors.GREEN,
            )
        except (
            ImportError,
            requests.RequestException,
            subprocess.CalledProcessError,
        ) as e:
            log("ERROR", f"Nix installation failed: {e}", Colors.RED)
            return False
    else:
        log("INFO", "Nix is already installed.", Colors.YELLOW)

    log("INFO", "Running Home-Manager setup as user '{SUDO_USER}'...", Colors.BLUE)
    nix_env_cmd = f"source {USER_HOME}/.nix-profile/etc/profile.d/nix.sh && "

    hm_check_cmd = nix_env_cmd + "command -v home-manager"
    if (
        run_command(
            ["bash", "-c", hm_check_cmd], as_user=SUDO_USER, check=False
        ).returncode
        != 0
    ):
        log("INFO", "Initializing Home-Manager for the first time.", Colors.YELLOW)
        hm_init_cmd = nix_env_cmd + "nix run home-manager/master -- init --switch"
        try:
            run_command(["bash", "-c", hm_init_cmd], as_user=SUDO_USER)
            log("SUCCESS", "Home-Manager initialized successfully.", Colors.GREEN)
        except subprocess.CalledProcessError:
            log("ERROR", "Home-Manager initialization failed.", Colors.RED)
            return False
    else:
        log("INFO", "Home-Manager is already initialized.", Colors.YELLOW)

    config_hm_dir = USER_HOME / ".config/home-manager"
    hyprdots_hm_dir = USER_HOME / ".hyprdots/.config/home-manager"

    if not hyprdots_hm_dir.is_dir():
        log(
            "ERROR",
            f"Source home-manager config not found at {hyprdots_hm_dir}",
            Colors.RED,
        )
        return False

    if config_hm_dir.is_dir() and not config_hm_dir.is_symlink():
        log(
            "WARNING",
            f"Removing existing directory {config_hm_dir} to create symlink.",
            Colors.YELLOW,
        )
        run_command(["rm", "-rf", str(config_hm_dir)], as_user=SUDO_USER)

    if not config_hm_dir.is_symlink() or str(config_hm_dir.resolve()) != str(
        hyprdots_hm_dir
    ):
        log("INFO", "Creating symlink for Home-Manager configuration...", Colors.BLUE)
        run_command(
            ["ln", "-s", str(hyprdots_hm_dir), str(config_hm_dir)], as_user=SUDO_USER
        )
    else:
        log("INFO", "Home-Manager configuration is already symlinked.", Colors.YELLOW)

    log(
        "INFO",
        "Installing/updating required packages with Home-Manager switch...",
        Colors.BLUE,
    )
    hm_switch_cmd = nix_env_cmd + "home-manager switch"
    try:
        run_command(["bash", "-c", hm_switch_cmd], as_user=SUDO_USER)
        log("SUCCESS", "Home-Manager switch completed successfully.", Colors.GREEN)
    except subprocess.CalledProcessError:
        log("ERROR", "Home-Manager switch failed.", Colors.RED)
        return False

    return True


def install_theming() -> bool:
    log("INFO", "Installing GTK/Icon themes...", Colors.BLUE)
    deps = [
        "sassc",
        "gtk-murrine-engine",
        "gnome-themes-extra",
        "ostree",
        "libappstream-glib",
    ]
    if not install_packages(deps):
        return False

    theme_repo_url = "https://github.com/vinceliuice/Colloid-gtk-theme.git"
    theme_dir = USER_HOME / "Colloid-gtk-theme"
    if not theme_dir.is_dir():
        run_command(["git", "clone", theme_repo_url, str(theme_dir)], as_user=SUDO_USER)

    if not pathlib.Path("/usr/share/themes/Colloid-Dark-Catppuccin").is_dir():
        log("INFO", "Installing Colloid-gtk-theme...", Colors.BLUE)
        run_command(
            ["./install.sh", "-l", "--tweaks", "catppuccin", "--tweaks", "normal"],
            cwd=str(theme_dir),
        )
    else:
        log("INFO", "Colloid-gtk-theme appears to be installed.", Colors.YELLOW)
    run_command(["rm", "-rf", str(theme_dir)])

    icon_repo_url = "https://github.com/vinceliuice/Colloid-icon-theme.git"
    icon_dir = USER_HOME / "Colloid-icon-theme"
    if not icon_dir.is_dir():
        run_command(["git", "clone", icon_repo_url, str(icon_dir)], as_user=SUDO_USER)

    if not pathlib.Path("/usr/share/icons/Colloid-Catppuccin-Orange-Dark").is_dir():
        log("INFO", "Installing Colloid-icon-theme...", Colors.BLUE)
        run_command(
            ["./install.sh", "-s", "catppuccin", "-t", "orange"], cwd=str(icon_dir)
        )
    else:
        log("INFO", "Colloid-icon-theme appears to be installed.", Colors.YELLOW)
    run_command(["rm", "-rf", str(icon_dir)])

    log("INFO", "Applying Flatpak overrides for theming...", Colors.BLUE)
    overrides = [
        "--filesystem=~/.themes",
        "--filesystem=~/.local/share/themes",
        "--env=GTK_THEME=Colloid-Dark-Catppuccin",
    ]
    all_ok = True
    for override_str in overrides:
        try:
            cmd = ["flatpak", "override", "--user"] + shlex.split(override_str)
            run_command(cmd, as_user=SUDO_USER)
        except subprocess.CalledProcessError:
            log(
                "ERROR", f"Failed to apply flatpak override: {override_str}", Colors.RED
            )
            all_ok = False

    return all_ok


def setup_hyprland() -> bool:
    log("INFO", "Starting Hyprland Desktop Environment Setup...", Colors.BLUE)
    packages = [
        "hyprland",
        "hyprland-devel",
        "hypridle",
        "hyprpaper",
        "hyprlock",
        "hyprpicker",
        "hyprshot",
        "hyprsunset",
        "hyprlang-devel",
        "hyprland-contrib",
        "pyprland",
        "xdg-desktop-portal-hyprland",
    ]
    if not install_packages(packages):
        return False

    log("INFO", "Updating hyprpm...", Colors.BLUE)
    run_command(["hyprpm", "update"], as_user=SUDO_USER, check=False)

    plugins = ["https://github.com/KZDKM/Hyprspace", "https://github.com/outfoxxed/hy3"]
    for plugin in plugins:
        plugin_name = pathlib.Path(plugin).name
        log("INFO", f"Adding plugin: {plugin_name}...", Colors.BLUE)
        run_command(["hyprpm", "add", plugin], as_user=SUDO_USER, check=False)
        if plugin_name == "Hyprspace":
            log("INFO", "Enabling plugin: Hyprspace...", Colors.BLUE)
            run_command(
                ["hyprpm", "enable", plugin_name], as_user=SUDO_USER, check=False
            )

    all_ok = True
    for service in ["hyprpolkitagent", "hyprpaper", "hypridle"]:
        if not configure_systemd_service(service, user_mode=True):
            all_ok = False
    return all_ok


def configure_systemd_services_general() -> bool:
    log("INFO", "Configuring general Systemd services...", Colors.BLUE)
    all_ok = True
    user_services = [
        "wireplumber.service",
        "pipewire-pulse.socket",
        "pipewire.socket",
        "pipewire-pulse.service",
        "pipewire.service",
        "gnome-keyring-daemon.socket",
    ]
    for service in user_services:
        if not configure_systemd_service(service, user_mode=True):
            all_ok = False

    system_services = ["haveged", "rngd", "pmcd", "pmlogger"]
    for service in system_services:
        if not configure_systemd_service(service):
            all_ok = False

    return all_ok


def update_system() -> bool:
    log("INFO", "Starting full system update...", Colors.BLUE)
    try:
        run_command(["dnf", "update", "-y"])
        log("SUCCESS", "System update completed successfully.", Colors.GREEN)
        return True
    except subprocess.CalledProcessError:
        log("ERROR", "System update failed.", Colors.RED)
        return False


# --- Main Script Execution Flow ---


def main():
    """Main function to execute all setup tasks."""
    start_time = datetime.datetime.now()
    log(
        "INFO",
        "Starting lean, optimized, and visually enhanced Fedora setup script...",
        Colors.BLUE,
    )

    tasks: List[Tuple] = [
        (check_root, "Root privileges check"),
        (check_internet_connection, "Internet connectivity check"),
        (check_dnf_availability, "DNF availability check"),
        (refresh_dnf_metadata, "DNF cache cleanup and metadata refresh"),
        (setup_dnf_configs, "DNF configuration setup"),
        (install_rpmfusion, "RPM Fusion repositories setup"),
        (enable_cisco_openh264, "Cisco OpenH264 setup"),
        (enable_copr_repos, "COPR repositories setup"),
        (set_timezone, "Timezone setup"),
        (setup_swap, "Swap file setup for Btrfs"),
        (setup_git, "Git and related tools setup"),
        (setup_editors, "Editors and development tools setup"),
        (setup_multimedia, "Multimedia packages setup"),
        (install_all_dnf_packages, "All general DNF package installation"),
        (setup_hyprland, "Hyprland Desktop Environment Setup"),
        (install_theming, "GTK and Icon Theming"),
        (setup_asus_laptops, "Asus Laptop specific setup"),
        (setup_flatpaks, "Flatpak and application setup"),
        (setup_tmux, "Tmux and TPM setup"),
        (setup_nix, "Nix and Home-Manager setup"),
        (configure_nvidia, "NVIDIA specific configurations"),
        (configure_systemd_services_general, "General Systemd Services Configuration"),
        (update_system, "Final full system update"),
    ]

    failed_tasks = []

    for func, desc in tasks:
        log("INFO", f"--- Executing task: {desc} ---", Colors.BLUE)
        try:
            if func():
                log("SUCCESS", f"Task '{desc}' completed successfully.", Colors.GREEN)
            else:
                log(
                    "ERROR",
                    f"Task '{desc}' failed. Continuing with other steps.",
                    Colors.RED,
                )
                failed_tasks.append(desc)
        except Exception as e:
            log(
                "FATAL",
                f"A critical error occurred during task '{desc}': {e}",
                Colors.RED,
            )
            failed_tasks.append(desc)

    end_time = datetime.datetime.now()
    duration = end_time - start_time

    print("\n" + "=" * 50)
    if not failed_tasks:
        log(
            "SUCCESS",
            f"Fedora setup script finished successfully in {duration}!",
            Colors.GREEN,
        )
    else:
        log(
            "ERROR",
            f"Fedora setup script finished in {duration} with {len(failed_tasks)} failed tasks:",
            Colors.RED,
        )
        for task in failed_tasks:
            print(f"  - {task}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        log(
            "INFO",
            "Script execution interrupted by user (Ctrl+C). Exiting.",
            Colors.YELLOW,
        )
        sys.exit(1)
    except Exception as e:
        log("FATAL", f"An unhandled exception occurred: {e}", Colors.RED)
        sys.exit(1)
