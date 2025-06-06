#!/usr/bin/env python3
import os
import sys
import subprocess
import argparse
import requests
from pathlib import Path
import tarfile
import shutil
import glob


def run_command(command, sudo=False):
    """Executes a shell command with optional sudo and error handling."""
    cmd_list = command
    if sudo:
        cmd_list = ["sudo"] + command

    print(f"Executing: {' '.join(cmd_list)}")
    try:
        subprocess.run(cmd_list, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(cmd_list)}", file=sys.stderr)
        print(e, file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(
            f"Error: Command '{cmd_list[0]}' not found. Please ensure it is installed and in your PATH.",
            file=sys.stderr,
        )
        sys.exit(1)


def install_dependencies():
    """Installs necessary build dependencies."""
    print("--- Checking and installing build dependencies ---")
    run_command(["dnf", "install", "-y", "python3-devel", "gcc"], sudo=True)
    print("--- Dependencies are ready ---\n")


def get_package_source_url(package_name):
    """Fetches the source distribution URL for a package from PyPI."""
    print(f"--- Fetching source URL for '{package_name}' from PyPI ---")
    try:
        response = requests.get(f"https://pypi.org/pypi/{package_name}/json")
        response.raise_for_status()
        data = response.json()
        for release in data["urls"]:
            if release["packagetype"] == "sdist":
                print(f"Found source distribution: {release['url']}")
                return release["url"]
        print(
            f"Error: No source distribution (sdist) found for '{package_name}'",
            file=sys.stderr,
        )
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print(f"Error fetching package information from PyPI: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Build and install a Python package from source on Fedora into /usr/local.",
        epilog="WARNING: This script installs packages that are NOT tracked by the dnf package manager.",
    )
    parser.add_argument(
        "package_name", help="The name of the Python package to install from PyPI."
    )
    args = parser.parse_args()

    package_name = args.package_name

    # 1. Install build dependencies
    install_dependencies()

    # 2. Get the source URL and download
    source_url = get_package_source_url(package_name)
    file_name = Path(source_url).name
    build_dir = Path.cwd() / "build"
    build_dir.mkdir(exist_ok=True)
    download_path = build_dir / file_name

    print(f"\n--- Downloading {file_name} ---")
    with requests.get(source_url, stream=True) as r:
        r.raise_for_status()
        with open(download_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
    print(f"Downloaded to {download_path}\n")

    # 3. Extract the source
    print(f"--- Extracting {file_name} ---")
    # Tar names can be inconsistent, so we find the directory name after extraction
    with tarfile.open(download_path) as tar:
        tar.extractall(path=build_dir)

    # Find the extracted directory
    extracted_dirs = [d for d in build_dir.iterdir() if d.is_dir()]
    if not extracted_dirs:
        print("Error: Could not find the extracted directory.", file=sys.stderr)
        sys.exit(1)
    # Assume the longest named directory is the correct one
    extract_path = max(extracted_dirs, key=lambda d: len(d.name))
    print(f"Extracted to {extract_path}\n")

    # 4. Change into the source directory
    os.chdir(extract_path)
    print(f"--- Changed directory to {os.getcwd()} ---\n")

    # 5. Build and install using setup.py install with a /usr/local prefix
    print(f"--- Building and installing {package_name} to /usr/local ---")
    install_command = ["python3", "setup.py", "install", f"--prefix=/usr/local"]
    run_command(install_command, sudo=True)

    # 6. Final cleanup and information
    print(f"\n--- Cleaning up build files ---")
    os.chdir(build_dir.parent)
    shutil.rmtree(build_dir)

    print("\n" + "=" * 80)
    print("✅ SUCCESS: Package Installation Complete")
    print("=" * 80)
    print(f"The package '{package_name}' was installed system-wide into /usr/local.")
    print("\n🚨 IMPORTANT WARNING:")
    print("This package is NOT tracked by the DNF package manager. To uninstall it,")
    print("you must manually remove its files. A record of installed files may")
    print(
        f"be located in an 'egg-info' file within your Python's /usr/local site-packages directory."
    )
    print("=" * 80)


if __name__ == "__main__":
    main()
