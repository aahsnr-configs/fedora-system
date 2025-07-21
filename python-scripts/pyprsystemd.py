#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess
import sys


def create_pyprland_systemd_service():
    """
    Creates a systemd user service file for pyprland,
    enables it, and starts it.
    Uses colored Unicode output for better user feedback.
    Assumes 'pyprland' executable is in the user's PATH.
    """
    # ANSI escape codes for colored output
    COLOR_GREEN = "\033[92m"
    COLOR_YELLOW = "\033[93m"
    COLOR_RED = "\033[91m"
    COLOR_RESET = "\033[0m"

    service_content = f"""
[Unit]
Description=Pyprland - Hyprland Utility
Documentation=https://github.com/hyprland-community/pyprland
After=graphical-session.target hyprland.target
PartOf=graphical-session.target hyprland.target

[Service]
Type=simple
ExecStart=pypr
Restart=on-failure
RestartSec=5

# Security Enhancements for a secure user service
# For user services, ProtectHome=true allows the service's own user to write to their home directory.
# This is crucial for applications that need to write configuration or logs to ~/.config or ~/.local/share.
PrivateTmp=true               # Isolate temporary directories for the service
ProtectSystem=full            # Make /usr, /boot, /etc read-only for the service
ProtectHome=true              # Make user's home directory read-only for others, but writable for the service's user
NoNewPrivileges=true          # Prevent the service from gaining new privileges
RestrictRealtime=true         # Prevent real-time scheduling
SystemCallFilter=@system-service # Restrict system calls to a safe set for general system services
CapabilityBoundingSet=        # Remove all capabilities (e.g., CAP_NET_RAW)
AmbientCapabilities=          # No ambient capabilities
MemoryDenyWriteExecute=true   # Prevent writing to and executing from memory
RestrictSUIDSGID=true         # Prevent SUID/SGID bits from being used
LockPersonality=true          # Prevent personality changes
RemoveIPC=true                # Remove IPC objects when the service stops

[Install]
WantedBy=graphical-session.target hyprland.target
"""

    home_dir = os.path.expanduser("~")
    service_dir = os.path.join(home_dir, ".config", "systemd", "user")
    service_file_path = os.path.join(service_dir, "pyprland.service")

    print(
        f"{COLOR_YELLOW}Attempting to create systemd user service file for Pyprland...{COLOR_RESET}"
    )
    print(f"{COLOR_YELLOW}Target path: {service_file_path}{COLOR_RESET}")

    try:
        # Create the directory if it doesn't exist
        os.makedirs(service_dir, exist_ok=True)
        print(f"{COLOR_GREEN}✔ Directory '{service_dir}' ensured.{COLOR_RESET}")

        # Write the service content to the file
        with open(service_file_path, "w", encoding="utf-8") as f:
            f.write(
                service_content.strip()
            )  # .strip() removes leading/trailing whitespace

        print(
            f"{COLOR_GREEN}✔ Service file 'pyprland.service' created successfully.{COLOR_RESET}"
        )

        # Reload systemd user daemon to pick up the new service file
        print(f"{COLOR_YELLOW}↻ Reloading systemd user daemon...{COLOR_RESET}")
        subprocess.run(
            ["systemctl", "--user", "daemon-reload"],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
        print(f"{COLOR_GREEN}✔ Systemd user daemon reloaded.{COLOR_RESET}")

        # Enable the service to start automatically on login
        print(f"{COLOR_YELLOW}⚙ Enabling pyprland service...{COLOR_RESET}")
        subprocess.run(
            ["systemctl", "--user", "enable", "pyprland.service"],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
        print(
            f"{COLOR_GREEN}✔ Pyprland service enabled. It will start automatically on login.{COLOR_RESET}"
        )

        # Start the service immediately for the current session
        print(f"{COLOR_YELLOW}▶ Starting pyprland service now...{COLOR_RESET}")
        subprocess.run(
            ["systemctl", "--user", "start", "pyprland.service"],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
        print(f"{COLOR_GREEN}✔ Pyprland service started.{COLOR_RESET}")

        print(
            f"\n{COLOR_GREEN}✨ Pyprland systemd user service setup complete!{COLOR_RESET}"
        )
        print(
            f"You can check its status with: {COLOR_YELLOW}systemctl --user status pyprland.service{COLOR_RESET}"
        )
        print(
            f"To stop it: {COLOR_YELLOW}systemctl --user stop pyprland.service{COLOR_RESET}"
        )
        print(
            f"To disable it: {COLOR_YELLOW}systemctl --user disable pyprland.service{COLOR_RESET}"
        )

    except subprocess.CalledProcessError as e:
        print(
            f"{COLOR_RED}✖ Error executing systemctl command: {e}{COLOR_RESET}",
            file=sys.stderr,
        )
        print(f"{COLOR_RED}  Command: {' '.join(e.cmd)}{COLOR_RESET}", file=sys.stderr)
        print(f"{COLOR_RED}  Return Code: {e.returncode}{COLOR_RESET}", file=sys.stderr)
        print(
            f"{COLOR_RED}  STDOUT: {e.stdout.strip() if e.stdout else 'N/A'}{COLOR_RESET}",
            file=sys.stderr,
        )
        print(
            f"{COLOR_RED}  STDERR: {e.stderr.strip() if e.stderr else 'N/A'}{COLOR_RESET}",
            file=sys.stderr,
        )
        print(
            f"{COLOR_RED}  Please ensure systemd user services are properly configured and 'systemctl' is in your PATH.{COLOR_RESET}",
            file=sys.stderr,
        )
    except IOError as e:
        print(
            f"{COLOR_RED}✖ Error writing service file: {e}{COLOR_RESET}",
            file=sys.stderr,
        )
        print(
            f"{COLOR_RED}  Please check your file permissions and ensure you have write access to '{service_dir}'.{COLOR_RESET}",
            file=sys.stderr,
        )
    except Exception as e:
        print(
            f"{COLOR_RED}✖ An unexpected error occurred: {e}{COLOR_RESET}",
            file=sys.stderr,
        )
        print(f"{COLOR_RED}  Details: {e}{COLOR_RESET}", file=sys.stderr)


if __name__ == "__main__":
    create_pyprland_systemd_service()
