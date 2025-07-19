import os
import subprocess
import sys

try:
    import colorama
    from colorama import Fore, Style

    colorama.init()  # Initialize Colorama for cross-platform colored output
except ImportError:
    # Fallback if colorama is not installed
    print("Warning: 'colorama' library not found. Output will not be colored.")

    class NoColor:
        def __getattr__(self, name):
            return ""

    Fore = NoColor()
    Style = NoColor()

# --- Color Constants ---
GREEN = Fore.GREEN
YELLOW = Fore.YELLOW
RED = Fore.RED
BLUE = Fore.BLUE
MAGENTA = Fore.MAGENTA
CYAN = Fore.CYAN
RESET = Style.RESET_ALL
BOLD = Style.BRIGHT

# --- Unicode Symbols ---
CHECK_MARK = "\u2714"  # ✔
CROSS_MARK = "\u2718"  # ✘
ARROW = "\u27a4"  # ➢
INFO_ICON = "\u2139\ufe0f"  # ℹ️

# --- Configuration Contents ---

# Atuin config.toml content
ATUIN_CONFIG_CONTENT = """
# Atuin Configuration File (~/.config/atuin/config.toml)

# --- General Settings ---
# Set the key bindings to 'vim'. Other options include 'atuin' (default) and 'emacs'.
key_bindings = "vim"

# --- Sync Settings (Managed by Systemd for Performance & Reliability) ---
# When using a dedicated systemd timer for background syncing (recommended),
# it's best to disable Atuin's built-in auto-sync from interactive shells.
# This centralizes sync management and prevents redundant sync attempts from
# every open terminal, improving performance and reducing resource usage.
auto_sync = false

# If you were NOT using a systemd timer, you would enable auto_sync and
# set an interval like this (e.g., 5 minutes):
# auto_sync = true
# auto_sync_interval = 300

# The maximum number of history entries to keep in the local database.
# Setting a lower number can improve performance for extremely large histories.
# For most users, Atuin is performant enough that this isn't strictly necessary.
# If you experience slowness with a history of millions of entries, consider uncommenting.
# max_history_entries = 100000

# The maximum number of history entries to sync to the server.
# This helps manage the size of your synced history across devices.
# Similar to max_history_entries, only necessary for very large histories.
# max_sync_entries = 50000

# --- UI/Display Settings ---
# Set the style of the Atuin UI. "auto" uses the default, "compact" is more minimal.
# style = "auto"

# Show the full command line when searching.
# show_full_command = true

# --- Filter Settings ---
# Ignore certain commands from being saved to history.
# This can help keep your history clean and prevent sensitive commands from being stored.
# ignored_commands = [
#     "ls",
#     "cd",
#     "exit",
#     "clear",
#     "history",
#     "atuin",
#     "reboot",
#     "shutdown",
#     "sudo reboot",
#     "sudo shutdown",
# ]

# --- Shell Integration (Advanced) ---
# Atuin usually detects your shell automatically.
# disable_history_hook = false
"""

# Zsh integration line for .zshrc
ZSHRC_LINE = 'eval "$(atuin init zsh)"'

# Systemd service file content (ExecStart path will be dynamically set)
ATUIN_SERVICE_TEMPLATE = """
[Unit]
Description=Atuin History Sync Service
Documentation=https://atuin.sh/docs/client/sync
After=network-online.target
Wants=network-online.target

[Service]
ExecStart={atuin_path} sync
Type=oneshot

[Install]
WantedBy=default.target
"""

# Systemd timer file content
ATUIN_TIMER_CONTENT = """
[Unit]
Description=Run Atuin History Sync every 5 minutes
Documentation=https://atuin.sh/docs/client/sync

[Timer]
OnUnitActiveSec=5min
OnBootSec=15s
Persistent=true

[Install]
WantedBy=timers.target
"""

# --- Helper Functions ---


def print_success(message):
    """Prints a success message in green with a check mark."""
    print(f"{GREEN}{CHECK_MARK} {message}{RESET}")


def print_info(message):
    """Prints an informational message in blue with an info icon."""
    print(f"{BLUE}{INFO_ICON} {message}{RESET}")


def print_warning(message):
    """Prints a warning message in yellow."""
    print(f"{YELLOW}⚠ {message}{RESET}")


def print_error(message):
    """Prints an error message in red with a cross mark and exits."""
    print(f"{RED}{CROSS_MARK} {message}{RESET}")
    sys.exit(1)


def print_header(message):
    """Prints a section header in bold magenta."""
    print(f"\n{BOLD}{MAGENTA}--- {message} ---{RESET}")


def run_command(
    command, check=True, capture_output=False, error_message=None, **kwargs
):
    """
    Runs a shell command.
    :param command: List of command and its arguments.
    :param check: If True, raises CalledProcessError on non-zero exit code.
    :param capture_output: If True, captures stdout and stderr.
    :param error_message: Custom error message to print on failure.
    :return: CompletedProcess object. If capture_output is True, returns stdout string.
    """
    try:
        result = subprocess.run(
            command, check=check, capture_output=capture_output, text=True, **kwargs
        )
        if capture_output:
            return result.stdout.strip()
        return result
    except subprocess.CalledProcessError as e:
        print_error(
            error_message or f"Command failed: {' '.join(command)}\nStderr: {e.stderr}"
        )
    except FileNotFoundError:
        print_error(
            f"Command not found: {command[0]}. Please ensure it's in your PATH."
        )


def write_file(filepath, content):
    """Writes content to a file, creating directories if necessary."""
    try:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, "w") as f:
            f.write(content)
        print_success(f"Created/Updated: {filepath}")
    except IOError as e:
        print_error(f"Error writing to file {filepath}: {e}")


def append_if_not_exists(filepath, line):
    """Appends a line to a file only if it doesn't already exist."""
    try:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        # Read the file content
        file_exists = os.path.exists(filepath)
        content = ""
        if file_exists:
            with open(filepath, "r") as f:
                content = f.read()

        if line not in content:
            # If line not found, append it
            with open(filepath, "a") as f:  # Use 'a' for append mode
                f.write(f"\n{line}\n")  # Add newlines for cleanliness
            print_success(f"Added line to: {filepath}")
        else:
            print_info(f"Line already exists in: {filepath}")
    except IOError as e:
        print_error(f"Error modifying file {filepath}: {e}")


def find_atuin_path():
    """Finds the full path to the atuin executable."""
    print_info("Searching for 'atuin' executable...")
    atuin_path = run_command(
        ["which", "atuin"],
        capture_output=True,
        error_message="Error: 'atuin' executable not found. Please ensure Atuin is installed and in your PATH.",
    )
    print_success(f"Found atuin at: {atuin_path}")
    return atuin_path


# --- Main Setup Logic ---


def setup_atuin_configuration():
    home_dir = os.path.expanduser("~")
    print_info(f"Starting Atuin setup for user: {BOLD}{CYAN}{home_dir}{RESET}")

    # --- 1. Atuin Config File (Symlinked) ---
    print_header("Setting up Atuin config.toml")
    atuin_config_dir = os.path.join(home_dir, ".config", "atuin")
    atuin_config_symlink_path = os.path.join(atuin_config_dir, "config.toml")
    atuin_managed_config_dir = os.path.join(
        home_dir, ".local", "share", "atuin_automated_configs"
    )
    atuin_managed_config_path = os.path.join(atuin_managed_config_dir, "config.toml")

    # Ensure the directory for the managed config exists
    os.makedirs(atuin_managed_config_dir, exist_ok=True)
    write_file(atuin_managed_config_path, ATUIN_CONFIG_CONTENT)

    symlink_established = False  # Initialize flag

    # Ensure the target directory for the symlink exists
    os.makedirs(atuin_config_dir, exist_ok=True)

    if os.path.exists(atuin_config_symlink_path):
        if os.path.islink(atuin_config_symlink_path):
            current_target = os.readlink(atuin_config_symlink_path)
            if current_target == atuin_managed_config_path:
                print_info(
                    f"Symlink at {atuin_config_symlink_path} already correctly points to {atuin_managed_config_path}."
                )
                symlink_established = True
            else:
                print_warning(
                    f"Existing symlink at {atuin_config_symlink_path} points to a different location ({current_target}). Removing and recreating."
                )
                try:
                    os.remove(atuin_config_symlink_path)
                except OSError as e:
                    print_error(
                        f"Failed to remove old symlink {atuin_config_symlink_path}: {e}"
                    )
        else:
            # It's an existing file or directory, not a symlink
            if os.path.isfile(atuin_config_symlink_path):
                print_warning(
                    f"Existing file at {atuin_config_symlink_path} is not a symlink. Removing and recreating as symlink."
                )
                try:
                    os.remove(atuin_config_symlink_path)
                except OSError as e:
                    print_error(
                        f"Failed to remove existing file {atuin_config_symlink_path}: {e}"
                    )
            elif os.path.isdir(atuin_config_symlink_path):
                print_error(
                    f"Cannot replace directory {atuin_config_symlink_path} with a symlink. Please move or remove this directory manually if it's safe to do so."
                )
            else:
                print_error(
                    f"Unexpected file type at {atuin_config_symlink_path}. Please inspect and resolve manually."
                )

    # If symlink was not established by existing checks, create it
    if not symlink_established:
        try:
            os.symlink(atuin_managed_config_path, atuin_config_symlink_path)
            print_success(
                f"Created symlink: {atuin_config_symlink_path} {ARROW} {atuin_managed_config_path}"
            )
            symlink_established = True
        except OSError as e:
            print_error(f"Error creating symlink {atuin_config_symlink_path}: {e}")

    if not symlink_established:
        print_error(
            "Failed to establish symlink for Atuin config. This is critical for Atuin to function."
        )

    # --- 2. Zsh Integration ---
    print_header("Integrating Atuin with Zsh")
    zshrc_path = os.path.join(home_dir, ".zshrc")
    append_if_not_exists(zshrc_path, ZSHRC_LINE)
    print_info(
        f"Please remember to run '{BOLD}source ~/.zshrc{RESET}{BLUE}' or open a new terminal for Zsh changes to take effect.{RESET}"
    )

    # --- 3. Systemd Service Integration ---
    print_header("Setting up Systemd for Atuin Sync")
    atuin_path = find_atuin_path()
    systemd_user_dir = os.path.join(home_dir, ".config", "systemd", "user")
    os.makedirs(systemd_user_dir, exist_ok=True)

    # Create atuin-sync.service
    atuin_service_path = os.path.join(systemd_user_dir, "atuin-sync.service")
    service_content = ATUIN_SERVICE_TEMPLATE.format(atuin_path=atuin_path)
    write_file(atuin_service_path, service_content)

    # Create atuin-sync.timer
    atuin_timer_path = os.path.join(systemd_user_dir, "atuin-sync.timer")
    write_file(atuin_timer_path, ATUIN_TIMER_CONTENT)

    # Reload systemd user daemon, enable and start timer
    print_info("Reloading systemd user daemon...")
    run_command(
        ["systemctl", "--user", "daemon-reload"],
        error_message="Failed to reload systemd user daemon. Check systemd logs.",
    )
    print_success("Systemd user daemon reloaded.")

    print_info("Enabling and starting atuin-sync.timer...")
    # These commands are idempotent; enabling/starting an already enabled/started unit is fine.
    run_command(
        ["systemctl", "--user", "enable", "atuin-sync.timer"],
        error_message="Failed to enable atuin-sync.timer. Check systemd logs.",
    )
    run_command(
        ["systemctl", "--user", "start", "atuin-sync.timer"],
        error_message="Failed to start atuin-sync.timer. Check systemd logs.",
    )
    print_success("Atuin sync timer enabled and started.")

    print(f"\n{BOLD}{GREEN}--- Atuin Setup Complete! ---{RESET}")
    print(
        f"{BLUE}You can check the timer status with: {BOLD}systemctl --user status atuin-sync.timer{RESET}"
    )
    print(
        f"{BLUE}Remember to run '{BOLD}source ~/.zshrc{RESET}{BLUE}' or open a new terminal to activate Zsh integration.{RESET}"
    )


if __name__ == "__main__":
    setup_atuin_configuration()
