#!/usr/bin/env python3

import os
import subprocess
import sys


def print_colored(text, color_code):
    """Prints text with ANSI color codes."""
    print(f"\033[{color_code}m{text}\033[0m")


def git_clone_simplified():
    """
    Clones a Git repository and prints the command to navigate into the new directory.
    This script needs to be 'sourced' (e.g., `source ./git_clone_simplified.py <URL>`)
    for the `cd` command to affect your current shell session.
    """
    if len(sys.argv) < 2:
        print_colored(
            "Usage: source ./git_clone_simplified.py <repository_url> [destination_path]",
            "91",
        )  # Red
        sys.exit(1)

    repo_url = sys.argv[1]
    destination_path = sys.argv[2] if len(sys.argv) > 2 else None

    # Determine the repository name for directory change
    repo_name = os.path.basename(repo_url)
    if repo_name.endswith(".git"):
        repo_name = repo_name[:-4]

    target_directory = destination_path if destination_path else repo_name

    # Check if target directory already exists
    if os.path.exists(target_directory) and os.path.isdir(target_directory):
        print_colored(
            f"Warning: Destination directory '{target_directory}' already exists. Cloning might fail or merge.",
            "93",
        )  # Yellow
        confirm = input("Do you want to proceed? (y/N): ").lower()
        if confirm != "y":
            print_colored("Operation cancelled.", "93")
            sys.exit(0)

    print_colored(f"Cloning {repo_url} into '{target_directory}'...", "96")  # Cyan
    try:
        clone_args = ["git", "clone", repo_url]
        if destination_path:
            clone_args.append(destination_path)

        subprocess.run(clone_args, check=True)
        print_colored(f"Successfully cloned into '{target_directory}'", "92")  # Green

        # This is the key for the calling shell to change directory
        # We print the `cd` command so the sourcing shell can execute it.
        print(f"cd {target_directory}")

    except subprocess.CalledProcessError as e:
        print_colored(f"Error cloning repository: {e}", "91")  # Red
        print_colored(
            f"Git output: {e.stderr.decode() if e.stderr else 'No stderr output'}", "91"
        )
    except FileNotFoundError:
        print_colored(
            "Error: 'git' command not found. Please ensure Git is installed and in your PATH.",
            "91",
        )
    except Exception as e:
        print_colored(f"An unexpected error occurred: {e}", "91")


if __name__ == "__main__":
    git_clone_simplified()
