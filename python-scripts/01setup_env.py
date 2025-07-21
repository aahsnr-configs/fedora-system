#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys


def check_os_compatibility():
    """
    Checks if the operating system is Linux. Exits if not.
    """
    if sys.platform != "linux":
        print("Error: This script is designed to run only on Linux systems.")
        sys.exit(1)


def find_python_executable(version="python3"):
    """
    Finds a suitable Python executable, preferring a specific version if requested.
    It searches the system's PATH for the specified Python version.
    """
    # Attempt to find the exact version first (e.g., "python3.13")
    if version:
        python_exec = shutil.which(version)
        if python_exec:
            print(f"Found {version} at: {python_exec}")
            return python_exec

    # Fallback to generic "python3" if the specific version is not found or not requested
    python_exec = shutil.which("python3")
    if python_exec:
        print(f"Found python3 at: {python_exec}")
        return python_exec

    # If no suitable Python executable is found, print an error and exit
    print(f"Error: Neither {version} nor python3 was found in your system's PATH.")
    sys.exit(1)


def create_virtual_environment(env_name="my_env", python_version="python3.13"):
    """
    Creates a new Python virtual environment in the current directory.
    It first removes any existing environment with the same name to ensure a clean setup.
    It attempts to use 'virtualenv' if available, otherwise falls back to the 'venv' module.

    Args:
        env_name (str): The name of the virtual environment directory.
        python_version (str): The desired Python executable for the environment (e.g., "python3.13").
    """
    print(
        f"Attempting to create virtual environment: {env_name} using {python_version}..."
    )

    # Step 1: Remove any existing virtual environment with the same name
    if os.path.exists(env_name) and os.path.isdir(env_name):
        print(
            f"Existing virtual environment '{env_name}' found. Removing it for a clean setup..."
        )
        try:
            shutil.rmtree(env_name)
            print(f"Successfully removed old virtual environment '{env_name}'.")
        except OSError as e:
            print(f"Error removing existing virtual environment '{env_name}': {e}")
            print(
                "Please ensure you have the necessary permissions and no processes are currently using the directory."
            )
            sys.exit(1)

    # Step 2: Find the specified Python executable on the system
    python_exec = find_python_executable(python_version)

    # Step 3: Create the new virtual environment
    # First, try using the 'virtualenv' tool
    try:
        print("Attempting to use 'virtualenv' for environment creation...")
        subprocess.run(
            ["virtualenv", "-p", python_exec, env_name],
            check=True,  # Raise CalledProcessError for non-zero exit codes
            capture_output=True,  # Capture stdout and stderr
            text=True,  # Decode stdout/stderr as text
        )
        print(
            f"Successfully created virtual environment '{env_name}' using virtualenv."
        )
        return  # Exit the function if virtualenv succeeded
    except FileNotFoundError:
        print(
            "'virtualenv' command not found. Falling back to the standard 'venv' module."
        )
    except subprocess.CalledProcessError as e:
        print(f"Error creating virtual environment with virtualenv:")
        print(f"  Command: {' '.join(e.cmd)}")
        print(f"  Return Code: {e.returncode}")
        print(f"  STDOUT:\n{e.stdout}")
        print(f"  STDERR:\n{e.stderr}")
        print("Attempting to use 'venv' module instead due to virtualenv error.")

    # Fallback to the 'venv' module if virtualenv failed or was not found
    try:
        print("Attempting to use 'venv' module for environment creation...")
        subprocess.run(
            [python_exec, "-m", "venv", env_name],
            check=True,
            capture_output=True,
            text=True,
        )
        print(f"Successfully created virtual environment '{env_name}' using venv.")
    except subprocess.CalledProcessError as e:
        print(f"Error creating virtual environment with venv:")
        print(f"  Command: {' '.join(e.cmd)}")
        print(f"  Return Code: {e.returncode}")
        print(f"  STDOUT:\n{e.stdout}")
        print(f"  STDERR:\n{e.stderr}")
        print(
            "Please ensure Python 3 and the 'venv' module are properly installed on your system."
        )
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: Python interpreter not found. Make sure Python is installed and in your PATH."
        )
        sys.exit(1)


def install_packages_into_env(env_name, packages):
    """
    Installs a list of Python packages into the specified virtual environment.
    This function directly calls the 'pip' executable located within the virtual environment.

    Args:
        env_name (str): The name of the virtual environment directory.
        packages (list): A list of package names (strings) to install.
    """
    if not packages:
        print("No packages specified for installation. Skipping package installation.")
        return

    # Construct the full path to the pip executable within the virtual environment
    pip_executable = os.path.join(env_name, "bin", "pip")

    if not os.path.exists(pip_executable):
        print(f"Error: pip executable not found at '{pip_executable}'.")
        print(
            f"This indicates an issue with the virtual environment '{env_name}' setup or it was not created correctly."
        )
        sys.exit(1)

    # Construct the pip install command. Using --no-input prevents interactive prompts.
    pip_install_command = [pip_executable, "install", "--no-input"] + packages

    print(
        f"\nAttempting to install packages into '{env_name}': {', '.join(packages)}..."
    )
    print(f"Executing command: {' '.join(pip_install_command)}")

    try:
        subprocess.run(
            pip_install_command,
            check=True,
            capture_output=True,
            text=True,
        )
        print("Packages installed successfully within the virtual environment.")
    except subprocess.CalledProcessError as e:
        print(f"Error during package installation:")
        print(f"  Command: {' '.join(e.cmd)}")
        print(f"  Return Code: {e.returncode}")
        print(f"  STDOUT:\n{e.stdout}")
        print(f"  STDERR:\n{e.stderr}")
        print(
            "Please check the package names, your internet connection, or the virtual environment setup."
        )
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: pip executable not found. This should not happen if the environment was created correctly."
        )
        sys.exit(1)


if __name__ == "__main__":
    # Ensure the script is run on a Linux operating system
    check_os_compatibility()

    # Define the name for the virtual environment directory
    env_name = "practice"

    # Define the desired Python version to use for the virtual environment
    # The script will attempt to find this specific executable (e.g., python3.13)
    python_target_version = "python3.13"

    # Define the list of Python packages to install into the virtual environment
    packages_to_install = [
        "requests",
        "beautifulsoup4",
        "numpy",
        "jupyterlab",
        "jupyterlab-vim",
    ]

    # Step 1: Create the virtual environment. This function handles removal of old envs.
    create_virtual_environment(env_name, python_target_version)

    # Step 2: Install the specified packages into the newly created environment.
    install_packages_into_env(env_name, packages_to_install)

    print(f"\n--- Setup Complete ---")
    print(
        f"Virtual environment '{env_name}' has been freshly created and packages installed."
    )
    print(
        f"\nIMPORTANT: To activate the virtual environment in your current terminal session, "
        f"please copy and paste the following command into your terminal and press Enter:"
    )
    print(f"  source {env_name}/bin/activate")
    print(
        f"\nOnce activated, you will see '({env_name})' at the beginning of your shell prompt, "
        f"indicating you are inside the virtual environment. You can then use the installed "
        f"packages and run Python scripts or JupyterLab directly:"
    )
    print(f"  python your_script.py")
    print(f"  jupyter-lab")
    print(
        f"(Remember to deactivate the environment using 'deactivate' when you're done.)"
    )
