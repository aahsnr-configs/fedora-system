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


def install_packages_after_activation(env_name, packages):
    """
    Installs a list of Python packages into the specified virtual environment
    by first activating the environment within the shell command.

    Args:
        env_name (str): The name of the virtual environment directory.
        packages (list): A list of package names (strings) to install.
    """
    if not packages:
        print("No packages specified for installation. Skipping package installation.")
        return

    # Path to the activation script for Linux
    activate_script = os.path.join(env_name, "bin", "activate")

    if not os.path.exists(activate_script):
        print(f"Error: Activation script not found at '{activate_script}'.")
        print(
            f"This indicates an issue with the virtual environment '{env_name}' creation."
        )
        sys.exit(1)

    # Construct the pip install command
    pip_install_command = f"pip install --no-input {' '.join(packages)}"

    # Construct the full shell command: source activate script && run pip install
    # Using '&&' ensures that pip install only runs if activation is successful
    full_shell_command = f"source {activate_script} && {pip_install_command}"

    print(
        f"\nAttempting to activate '{env_name}' and install packages: {', '.join(packages)}..."
    )
    print(f"Executing command: {full_shell_command}")

    try:
        # Use shell=True to execute the combined command string
        # This creates a subshell where the activation happens before pip runs
        subprocess.run(
            full_shell_command,
            shell=True,
            check=True,
            capture_output=True,
            text=True,
            executable="/bin/bash",
        )
        print(
            "Packages installed successfully within the activated environment context."
        )
    except subprocess.CalledProcessError as e:
        print(f"Error during package installation (after activation):")
        print(
            f"  Command: {e.cmd}"
        )  # Note: e.cmd will be the full_shell_command string when shell=True
        print(f"  Return Code: {e.returncode}")
        print(f"  STDOUT: {e.stdout}")
        print(f"  STDERR: {e.stderr}")
        print(
            "Please check the package names, your internet connection, or environment setup."
        )
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: Shell executable (/bin/bash) not found. This is highly unusual on Linux."
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

    # Step 2: Activate the environment and then install specified packages
    install_packages_after_activation(env_name, packages_to_install)

    print(f"\n--- Setup Complete ---")
    print(f"Virtual environment '{env_name}' has been created and packages installed.")
    print(
        f"To activate the virtual environment manually in your current terminal, run:"
    )
    print(f"  source {env_name}/bin/activate")
    print(
        f"\nOnce activated, you can use the installed packages and run Python scripts like this:"
    )
    print(f"  python your_script.py")
    print(
        f"(Remember to deactivate the environment using 'deactivate' when you're done.)"
    )
