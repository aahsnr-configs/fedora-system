#!/usr/bin/env python3.13

import subprocess
import sys
import os
import time
from pathlib import Path


def run_command(command, shell=False, check=True):
    """Execute a command and handle errors"""
    try:
        if shell:
            result = subprocess.run(
                command, shell=True, check=check, capture_output=True, text=True
            )
        else:
            result = subprocess.run(
                command, check=check, capture_output=True, text=True
            )

        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)

        return result
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}", file=sys.stderr)
        if e.stdout:
            print(f"STDOUT: {e.stdout}", file=sys.stderr)
        if e.stderr:
            print(f"STDERR: {e.stderr}", file=sys.stderr)
        sys.exit(1)


def get_fedora_version():
    """Get the current Fedora version"""
    try:
        result = subprocess.run(
            ["rpm", "-E", "%fedora"], capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        print("Error: Could not determine Fedora version", file=sys.stderr)
        sys.exit(1)


def main():
    print("Initial Setup")
    time.sleep(3)

    # Get home directory
    home_dir = Path.home()

    # Copy configuration files
    print("Copying configuration files...")
    dnf_conf_src = home_dir / "fedora-setup" / "preconfigured-files" / "dnf.conf"
    variables_sh_src = (
        home_dir / "fedora-setup" / "preconfigured-files" / "variables.sh"
    )

    if dnf_conf_src.exists():
        run_command(["sudo", "cp", str(dnf_conf_src), "/etc/dnf/"])
    else:
        print(f"Warning: {dnf_conf_src} not found, skipping dnf.conf copy")

    if variables_sh_src.exists():
        run_command(["sudo", "cp", str(variables_sh_src), "/etc/profile.d/"])
    else:
        print(f"Warning: {variables_sh_src} not found, skipping variables.sh copy")

    # Get Fedora version for RPM Fusion
    fedora_version = get_fedora_version()
    print(f"Detected Fedora version: {fedora_version}")

    # Install RPM Fusion repositories
    print("Installing RPM Fusion repositories...")
    rpmfusion_free_url = f"https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-{fedora_version}.noarch.rpm"
    rpmfusion_nonfree_url = f"https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-{fedora_version}.noarch.rpm"

    run_command(
        ["sudo", "dnf", "install", "-y", rpmfusion_free_url, rpmfusion_nonfree_url]
    )

    # Enable Cisco OpenH264 repository
    print("Enabling Cisco OpenH264 repository...")
    run_command(
        ["sudo", "dnf", "config-manager", "setopt", "fedora-cisco-openh264.enabled=1"]
    )

    # Enable COPR repositories
    print("Enabling COPR repositories...")
    copr_repos = [
        "solopasha/hyprland",
        "sneexy/zen-browser",
        "lukenukem/asus-linux",
        "errornointernet/quickshell",
        "alternateved/eza",
        "lihaohong/yazi",
        "mcpengu1/viu",
        "wehagy/protonplus",
    ]

    for repo in copr_repos:
        print(f"Enabling COPR repository: {repo}")
        run_command(["sudo", "dnf", "copr", "enable", "-y", repo])

    # Set timezone to Asia/Dhaka
    print("Setting timezone to Asia/Dhaka...")
    timezone_target = Path("/usr/share/zoneinfo/Asia/Dhaka")
    timezone_link = Path("/etc/localtime")

    if timezone_target.exists():
        run_command(["sudo", "ln", "-sf", str(timezone_target), str(timezone_link)])
    else:
        print("Warning: Timezone file not found, skipping timezone setup")

    # Update system
    print("Updating system packages...")
    run_command(["sudo", "dnf", "update", "-y"])

    print("Setup completed successfully!")


if __name__ == "__main__":
    main()
