#!/usr/bin/env python3

import os
import subprocess
import sys


def check_os_compatibility():
    """
    Checks if the operating system is Linux. Exits if not.
    """
    if sys.platform != "linux":
        print("Error: This script is designed to run only on Linux systems.")
        sys.exit(1)


def create_virtual_environment(env_name="my_env"):
    """
    Creates a new Python virtual environment in the current directory.

    Args:
        env_name (str): The name of the virtual environment directory.
    """
    print(f"Attempting to create virtual environment: {env_name}...")
    try:
        # Use subprocess to run the 'venv' module, which is standard for virtual environments
        # sys.executable ensures the correct Python interpreter is used
        subprocess.run(
            [sys.executable, "-m", "venv", env_name],
            check=True,
            capture_output=True,
            text=True,
        )
        print(f"Successfully created virtual environment '{env_name}'.")
    except subprocess.CalledProcessError as e:
        print(f"Error creating virtual environment:")
        print(f"  Command: {' '.join(e.cmd)}")
        print(f"  Return Code: {e.returncode}")
        print(f"  STDOUT: {e.stdout}")
        print(f"  STDERR: {e.stderr}")
        print("Please ensure Python 3 and the 'venv' module are properly installed.")
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: Python interpreter not found. Make sure Python 3 is installed and in your PATH."
        )
        sys.exit(1)


def install_packages(env_name, packages):
    """
    Installs a list of Python packages into the specified virtual environment.

    Args:
        env_name (str): The name of the virtual environment directory.
        packages (list): A list of package names (strings) to install.
    """
    if not packages:
        print("No packages specified for installation. Skipping package installation.")
        return

    # Construct the path to the pip executable within the Linux virtual environment
    pip_executable = os.path.join(env_name, "bin", "pip")

    if not os.path.exists(pip_executable):
        print(f"Error: pip executable not found at '{pip_executable}'.")
        print(
            f"This indicates an issue with the virtual environment '{env_name}' creation."
        )
        sys.exit(1)

    print(
        f"\nAttempting to install packages into '{env_name}': {', '.join(packages)}..."
    )
    try:
        # Construct the command for pip installation
        # The '--no-input' flag can be useful in automated scripts to prevent prompts
        command = [pip_executable, "install", "--no-input"] + packages
        subprocess.run(command, check=True, capture_output=True, text=True)
        print("Packages installed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error installing packages:")
        print(f"  Command: {' '.join(e.cmd)}")
        print(f"  Return Code: {e.returncode}")
        print(f"  STDOUT: {e.stdout}")
        print(f"  STDERR: {e.stderr}")
        print("Please check the package names and your internet connection.")
        sys.exit(1)
    except FileNotFoundError:
        print(
            f"Error: '{pip_executable}' command not found. This should not happen if pip_executable exists."
        )
        sys.exit(1)


if __name__ == "__main__":
    # Ensure the script runs only on Linux
    check_os_compatibility()

    # Define the virtual environment name
    env_name = "my_env"

    # Define the list of packages to install
    packages_to_install = ["requests", "beautifulsoup4", "numpy"]

    # Step 1: Create the virtual environment
    create_virtual_environment(env_name)

    # Step 2: Install specified packages into the newly created environment
    install_packages(env_name, packages_to_install)

    print(f"\n--- Setup Complete ---")
    print(f"Virtual environment '{env_name}' has been created and packages installed.")
    print(
        f"To activate the virtual environment, run the following command in your terminal:"
    )
    print(f"  source {env_name}/bin/activate")
    print(
        f"\nOnce activated, you can use the installed packages and run Python scripts like this:"
    )
    print(f"  python your_script.py")
    print(
        f"(Remember to deactivate the environment using 'deactivate' when you're done.)"
    )
