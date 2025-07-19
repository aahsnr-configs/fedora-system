#!/usr/bin/env python3

import os
import subprocess
import sys


# --- ANSI Escape Codes for Colors and Styles ---
class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    BLUE = "\033[94m"
    CYAN = "\033[96m"


# --- Unicode Symbols ---
class Symbols:
    CHECK = "✔"
    CROSS = "✖"
    INFO = "ℹ"
    WARNING = "⚠"
    ARROW = "➤"


# --- Helper function for colored output ---
def print_status(message, color=Colors.RESET, symbol=None, end="\n"):
    """Prints a message with optional color and symbol."""
    if symbol:
        print(f"{color}{symbol} {message}{Colors.RESET}", end=end)
    else:
        print(f"{color}{message}{Colors.RESET}", end=end)


# --- Define file paths and content ---
HOME_DIR = os.path.expanduser("~")
BAT_CONFIG_DIR = os.path.join(HOME_DIR, ".config", "bat")
BAT_CONFIG_FILE = os.path.join(BAT_CONFIG_DIR, "config")
BAT_THEMES_DIR = os.path.join(BAT_CONFIG_DIR, "themes")
CATPPUCCIN_MOCHA_THEME_URL = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin-mocha.tmTheme"
CATPPUCCIN_MOCHA_THEME_FILE = os.path.join(BAT_THEMES_DIR, "Catppuccin-mocha.tmTheme")

ZSH_CONFIG_DIR = os.path.join(HOME_DIR, ".config", "zsh")
BAT_ZSH_INTEGRATION_FILE = os.path.join(ZSH_CONFIG_DIR, "bat_integration.zsh")
ZSHRC_FILE = os.path.join(HOME_DIR, ".zshrc")

BAT_CONFIG_CONTENT = """\
# ~/.config/bat/config

# Set the default theme to Catppuccin Mocha.
# This will be overridden by specific aliases/functions if needed.
--theme="Catppuccin-mocha"

# Always show line numbers by default.
--line-numbers

# Always show a grid around the code and a header with file information.
--style=full

# Always paginate output when bat is used as a pager (e.g., via `less` or `PAGER`).
# This ensures large files are scrollable.
--paging=always

# Disable line wrapping to maintain code integrity and readability, especially for wide files.
--wrap=never

# Always color the output, even when piping to other commands.
# Useful for debugging or when you want colored output in scripts.
--color=always

# Configure custom syntax mappings for common configuration files on Linux.
# This ensures that files like .conf, .service, .repo, etc., are highlighted correctly
# even if bat doesn't auto-detect their syntax.

--map-syntax="*.conf:INI"
--map-syntax="*.service:INI"
--map-syntax="*.timer:INI"
--map-syntax="*.mount:INI"
--map-syntax="*.target:INI"
--map-syntax="*.slice:INI"
--map-syntax="*.socket:INI"
--map-syntax="*.path:INI"
--map-syntax="*.repo:INI"
--map-syntax="*.desktop:INI" # For desktop entry files

# Map common Markdown file extensions.
--map-syntax="*.md:Markdown"
--map-syntax="*.markdown:Markdown"

# Map specific file names to their respective syntaxes.
--map-syntax="Dockerfile:Docker"
# PKGBUILD is common in Arch-based systems, but good to have for consistency
--map-syntax="PKGBUILD:Bash"
--map-syntax="hosts:Hosts"
--map-syntax="fstab:Fstab"
--map-syntax="crontab:Crontab" # For user crontabs
"""

BAT_ZSH_INTEGRATION_CONTENT = """\
# ~/.config/zsh/bat_integration.zsh

# --- Bat Integration for Zsh ---

# Set bat as the default pager for commands like 'less', 'git diff', etc.
# --paging=always ensures bat always uses its pager, even for small files,
# providing a consistent scrolling experience.
# --theme='Catppuccin-mocha' applies your chosen theme.
export PAGER="bat --paging=always --theme='Catppuccin-mocha'"

# Set bat as the pager for 'man' pages.
# 'col -bx' is essential here: it strips backspaces and bold/underline sequences
# that 'man' pages often use, which can interfere with bat's rendering and cause
# visual artifacts.
# '-l man' forces bat to use the 'man' syntax highlighting, which is optimized
# for man page content.
# '-p' (plain) disables line numbers and git diffs for man pages, keeping them clean.
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging=always --theme=\"Catppuccin-mocha\"'"

# Alias 'cat' to 'bat'.
# --paging=never ensures that 'bat' behaves exactly like 'cat' for small files,
# printing directly to the terminal without pagination.
# This makes 'cat file.txt' use bat's highlighting without requiring a pager.
alias cat='bat --paging=never --theme="Catppuccin-mocha"'

# Optional: Create a function for 'less' to explicitly use bat.
# This can be useful if other tools or environment variables might
# occasionally override PAGER, ensuring that 'less filename' still
# uses bat with your preferred settings.
function less() {
    bat --paging=always --theme="Catppuccin-mocha" "$@"
}

# Optional: Alias 'grep' to use 'bat' for its output.
# This pipes grep's output to bat, allowing for syntax highlighting of matched lines.
# Note: This might not be ideal for all use cases, as it highlights the entire line
# based on the detected syntax, not just the matched text.
# alias grep='grep --color=always | bat --plain --language=text'
"""

ZSHRC_SOURCE_LINE = f'if [ -f "{BAT_ZSH_INTEGRATION_FILE}" ]; then\n    source "{BAT_ZSH_INTEGRATION_FILE}"\nfi'


def run_command(command, check_output=False, sudo=False, suppress_output=False):
    """
    Runs a shell command and handles errors.
    :param command: List of command and its arguments.
    :param check_output: If True, returns the command's standard output.
    :param sudo: If True, prepend 'sudo' to the command.
    :param suppress_output: If True, suppress stdout/stderr for subprocess.run.
    :return: Output of the command if check_output is True, otherwise None.
    """
    full_command = command
    if sudo:
        full_command = ["sudo"] + command

    try:
        stdout_dest = subprocess.PIPE if check_output or suppress_output else None
        stderr_dest = subprocess.PIPE if suppress_output else None

        result = subprocess.run(
            full_command,
            capture_output=True,
            text=True,
            check=True,
            stdout=stdout_dest,
            stderr=stderr_dest,
        )

        if not suppress_output:
            print_status(
                f"Command executed: {' '.join(full_command)}",
                Colors.CYAN,
                Symbols.ARROW,
            )

        if check_output:
            return result.stdout.strip()
        else:
            return None
    except subprocess.CalledProcessError as e:
        print_status(
            f"Error executing command: {' '.join(full_command)}",
            Colors.RED,
            Symbols.CROSS,
        )
        print_status(f"Return code: {e.returncode}", Colors.RED)
        if e.stdout:
            print_status(f"Standard Output: {e.stdout.strip()}", Colors.RED)
        if e.stderr:
            print_status(f"Standard Error: {e.stderr.strip()}", Colors.RED)
        sys.exit(1)
    except FileNotFoundError:
        print_status(f"Command not found: {full_command[0]}", Colors.RED, Symbols.CROSS)
        sys.exit(1)


def is_command_installed(command_name):
    """Checks if a given command is installed and available in PATH."""
    try:
        # Use check=False to avoid raising CalledProcessError if command is not found
        result = subprocess.run(
            ["which", command_name], capture_output=True, check=False, text=True
        )
        return result.returncode == 0
    except FileNotFoundError:
        return False


def install_package(package_name, command_to_check):
    """Installs a package using dnf if the command is not found."""
    print_status(
        f"Checking if '{command_to_check}' is installed...", Colors.BLUE, Symbols.INFO
    )
    if is_command_installed(command_to_check):
        print_status(
            f"'{command_to_check}' is already installed.", Colors.GREEN, Symbols.CHECK
        )
    else:
        print_status(
            f"'{command_to_check}' not found. Attempting to install '{package_name}' using dnf...",
            Colors.YELLOW,
            Symbols.WARNING,
        )
        run_command(["dnf", "install", "-y", package_name], sudo=True)
        if is_command_installed(command_to_check):
            print_status(
                f"'{package_name}' installed successfully.", Colors.GREEN, Symbols.CHECK
            )
        else:
            print_status(
                f"Failed to install '{package_name}'. Please install it manually and re-run the script.",
                Colors.RED,
                Symbols.CROSS,
            )
            sys.exit(1)


def create_or_update_file(filepath, content):
    """Creates or updates a file with the given content."""
    print_status(f"Creating/updating {filepath}...", Colors.BLUE, Symbols.INFO)
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    try:
        # Read current content if file exists to check for changes
        current_content = ""
        if os.path.exists(filepath):
            with open(filepath, "r") as f:
                current_content = f.read()

        if current_content == content:
            print_status(
                f"File {filepath} is already up to date.", Colors.YELLOW, Symbols.INFO
            )
        else:
            with open(filepath, "w") as f:
                f.write(content)
            print_status(f"Successfully wrote {filepath}.", Colors.GREEN, Symbols.CHECK)
    except IOError as e:
        print_status(f"Error writing {filepath}: {e}", Colors.RED, Symbols.CROSS)
        sys.exit(1)


def setup_bat_theme():
    """Downloads the Catppuccin Mocha theme and builds bat's cache."""
    print_status("Setting up Catppuccin Mocha theme...", Colors.BLUE, Symbols.INFO)
    os.makedirs(BAT_THEMES_DIR, exist_ok=True)

    # Always ensure curl is installed before attempting download
    install_package("curl", "curl")

    # Check if theme file already exists and is the same. This is a simple check.
    # For robust check, one might compare file hashes or content.
    if (
        os.path.exists(CATPPUCCIN_MOCHA_THEME_FILE)
        and os.path.getsize(CATPPUCCIN_MOCHA_THEME_FILE) > 0
    ):
        print_status(
            f"Catppuccin Mocha theme file already exists at {CATPPUCCIN_MOCHA_THEME_FILE}.",
            Colors.YELLOW,
            Symbols.INFO,
        )
    else:
        print_status(
            f"Downloading theme from {CATPPUCCIN_MOCHA_THEME_URL}...",
            Colors.BLUE,
            Symbols.ARROW,
        )
        # Use -f to fail silently on HTTP errors, -s for silent, -L to follow redirects, -o for output file
        run_command(
            [
                "curl",
                "-fsSL",
                "-o",
                CATPPUCCIN_MOCHA_THEME_FILE,
                CATPPUCCIN_MOCHA_THEME_URL,
            ]
        )
        print_status("Theme downloaded successfully.", Colors.GREEN, Symbols.CHECK)

    print_status("Building bat's theme cache...", Colors.BLUE, Symbols.INFO)
    # Rebuilding cache is idempotent and safe to run multiple times
    run_command(["bat", "cache", "--build"])
    print_status("Bat theme cache built.", Colors.GREEN, Symbols.CHECK)


def update_zshrc():
    """Adds the source line to .zshrc if it's not already present."""
    print_status(f"Updating {ZSHRC_FILE}...", Colors.BLUE, Symbols.INFO)
    try:
        existing_content = ""
        if os.path.exists(ZSHRC_FILE):
            with open(ZSHRC_FILE, "r") as f:
                existing_content = f.read()

        if ZSHRC_SOURCE_LINE not in existing_content:
            with open(ZSHRC_FILE, "a") as f:  # Open in append mode
                f.write(f"\n\n# Source bat integration\n{ZSHRC_SOURCE_LINE}\n")
            print_status(
                f"Added source line to {ZSHRC_FILE}.", Colors.GREEN, Symbols.CHECK
            )
        else:
            print_status(
                f"Source line already present in {ZSHRC_FILE}.",
                Colors.YELLOW,
                Symbols.INFO,
            )
    except IOError as e:
        print_status(
            f"Error reading/writing {ZSHRC_FILE}: {e}", Colors.RED, Symbols.CROSS
        )
        sys.exit(1)


def main():
    """Main function to run the bat setup."""
    print_status(
        f"{Colors.BOLD}Starting bat configuration setup for Fedora 42...{Colors.RESET}\n",
        Colors.BLUE,
    )

    install_package("bat", "bat")
    create_or_update_file(BAT_CONFIG_FILE, BAT_CONFIG_CONTENT)
    setup_bat_theme()
    create_or_update_file(BAT_ZSH_INTEGRATION_FILE, BAT_ZSH_INTEGRATION_CONTENT)
    update_zshrc()

    print_status(
        f"\n{Colors.BOLD}Bat configuration setup complete!{Colors.RESET}",
        Colors.GREEN,
        Symbols.CHECK,
    )
    print_status(
        f"Please run '{Colors.YELLOW}source {ZSHRC_FILE}{Colors.RESET}' or restart your terminal for changes to take effect.",
        Colors.CYAN,
        Symbols.INFO,
    )
    print_status(
        "You can test your setup by running: 'cat ~/.zshrc' or 'man ls'",
        Colors.CYAN,
        Symbols.INFO,
    )


if __name__ == "__main__":
    main()
