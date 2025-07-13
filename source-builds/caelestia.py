#!/usr/bin/env python3.13
"""
Caelestia Setup Script - Python 3.13 Version
Translates the bash script to Python with modern features and error handling.
"""

import atexit
import json
import logging
import os
import shutil
import signal
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional


class LogLevel(Enum):
    """Log levels with color codes."""

    INFO = ("\033[0;34m", "[INFO]")
    SUCCESS = ("\033[0;32m", "[SUCCESS]")
    WARNING = ("\033[1;33m", "[WARNING]")
    ERROR = ("\033[0;31m", "[ERROR]")


@dataclass
class Config:
    """Configuration class for the setup script."""

    caelestia_cli_repo: str = "https://github.com/caelestia-dots/cli.git"
    caelestia_shell_repo: str = "https://github.com/caelestia-dots/shell.git"
    beat_detector_target: Path = Path("/usr/lib/caelestia/beat_detector")
    temp_dir: Optional[Path] = None

    def __post_init__(self):
        """Initialize temporary directory."""
        if self.temp_dir is None:
            self.temp_dir = Path(tempfile.mkdtemp(prefix="caelestia-setup-"))


class CaelestiaSetup:
    """Main setup class for Caelestia installation."""

    def __init__(self):
        self.config = Config()
        self.logger = self._setup_logger()
        self._setup_cleanup()

    def _setup_logger(self) -> logging.Logger:
        """Setup logger with custom formatting."""
        logger = logging.getLogger("caelestia_setup")
        logger.setLevel(logging.INFO)

        # Create console handler with custom formatter
        handler = logging.StreamHandler()
        handler.setLevel(logging.INFO)

        # Custom formatter that handles colors
        class ColorFormatter(logging.Formatter):
            def format(self, record):
                # Don't use logging levels, use our custom log methods
                return record.getMessage()

        handler.setFormatter(ColorFormatter())
        logger.addHandler(handler)
        logger.propagate = False

        return logger

    def _setup_cleanup(self):
        """Setup cleanup handlers."""
        atexit.register(self._cleanup)
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)

    def _cleanup(self):
        """Clean up temporary directory."""
        if self.config.temp_dir and self.config.temp_dir.exists():
            self.log_info("Cleaning up temporary directory...")
            shutil.rmtree(self.config.temp_dir, ignore_errors=True)

    def _signal_handler(self, signum, frame):
        """Handle script interruption."""
        self.log_error("Script interrupted by user")
        sys.exit(130)

    def log_info(self, message: str):
        """Log info message with color."""
        color, prefix = LogLevel.INFO.value
        print(f"{color}{prefix}\033[0m {message}")

    def log_success(self, message: str):
        """Log success message with color."""
        color, prefix = LogLevel.SUCCESS.value
        print(f"{color}{prefix}\033[0m {message}")

    def log_warning(self, message: str):
        """Log warning message with color."""
        color, prefix = LogLevel.WARNING.value
        print(f"{color}{prefix}\033[0m {message}")

    def log_error(self, message: str):
        """Log error message with color."""
        color, prefix = LogLevel.ERROR.value
        print(f"{color}{prefix}\033[0m {message}", file=sys.stderr)

    def run_command(
        self,
        cmd: List[str],
        cwd: Optional[Path] = None,
        check: bool = True,
        capture_output: bool = False,
    ) -> subprocess.CompletedProcess:
        """Run a command with proper error handling."""
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd,
                check=check,
                capture_output=capture_output,
                text=True,
                timeout=300,  # 5 minute timeout
            )
            return result
        except subprocess.CalledProcessError as e:
            self.log_error(f"Command failed: {' '.join(cmd)}")
            self.log_error(f"Exit code: {e.returncode}")
            if e.stderr:
                self.log_error(f"Error output: {e.stderr}")
            raise
        except subprocess.TimeoutExpired:
            self.log_error(f"Command timed out: {' '.join(cmd)}")
            raise

    def check_command(self, cmd: str) -> bool:
        """Check if a command exists."""
        return shutil.which(cmd) is not None

    def check_package_installed(self, package: str) -> bool:
        """Check if a DNF package is installed."""
        try:
            result = self.run_command(
                ["rpm", "-q", package], check=False, capture_output=True
            )
            return result.returncode == 0
        except Exception:
            return False

    def check_python_package(self, package: str) -> bool:
        """Check if a Python package is available."""
        try:
            __import__(package)
            return True
        except ImportError:
            return False

    def check_root(self):
        """Check if running as root."""
        if os.geteuid() == 0:
            self.log_error(
                "This script should not be run as root. Please run as a regular user."
            )
            sys.exit(1)

    def check_system(self):
        """Check system requirements."""
        self.log_info("Checking system requirements...")

        required_commands = {
            "dnf": "This script requires dnf package manager (Fedora/RHEL/CentOS).",
            "sudo": "sudo is required but not installed. Please install sudo first.",
            "git": "git is required but not installed. Please install git first.",
            "g++": "g++ is required but not installed. Please install gcc-c++ first.",
            "python3": "python3 is required but not installed.",
        }

        for cmd, error_msg in required_commands.items():
            if not self.check_command(cmd):
                self.log_error(error_msg)
                sys.exit(1)

        self.log_success("System requirements check passed")

    def install_packages(self):
        """Install required system packages."""
        self.log_info("Installing required system packages...")

        # Core packages required for the project
        packages = [
            "git",
            "gcc-c++",
            "cmake",
            "make",
            "pkg-config",
            "glib2-devel",
            "libqalculate-devel",
            "qt6-qtbase-devel",
            "qt6-qtdeclarative-devel",
            "qt6-qtsvg-devel",
            "qt6-qtwayland-devel",
            "pipewire-devel",
            "aubio-devel",
            "libnotify-devel",
            "pulseaudio-utils",
            "pulseaudio-libs-devel",
            "wayland-devel",
            "wayland-protocols-devel",
            "python3",
            "python3-pip",
            "python3-build",
            "python3-installer",
            "python3-wheel",
            "python3-setuptools",
            "python3-pillow",
            "fish",
        ]

        # Python packages that might not be in DNF
        python_packages = ["hatch", "hatch-vcs"]

        # Check and install DNF packages
        to_install = [pkg for pkg in packages if not self.check_package_installed(pkg)]

        if to_install:
            self.log_info(f"Installing DNF packages: {', '.join(to_install)}")
            try:
                self.run_command(["sudo", "dnf", "install", "-y"] + to_install)
                self.log_success("DNF packages installed successfully")
            except subprocess.CalledProcessError:
                self.log_error("Failed to install DNF packages")
                sys.exit(1)
        else:
            self.log_info("All required DNF packages are already installed")

        # Install Python packages
        self.log_info("Installing Python packages...")
        for py_package in python_packages:
            if not self.check_python_package(py_package):
                self.log_info(f"Installing Python package: {py_package}")
                try:
                    self.run_command(
                        ["python3", "-m", "pip", "install", "--user", py_package]
                    )
                except subprocess.CalledProcessError:
                    self.log_warning(
                        f"Failed to install {py_package} via pip, trying DNF alternative..."
                    )
                    # Try DNF alternative names
                    dnf_alternatives = {
                        "hatch": "python3-hatch",
                        "hatch-vcs": "python3-hatch-vcs",
                    }
                    if py_package in dnf_alternatives:
                        try:
                            self.run_command(
                                [
                                    "sudo",
                                    "dnf",
                                    "install",
                                    "-y",
                                    dnf_alternatives[py_package],
                                ]
                            )
                        except subprocess.CalledProcessError:
                            self.log_warning(f"Could not install {py_package}")

        self.log_success("Package installation completed")

    def check_quickshell(self):
        """Check if QuickShell is installed."""
        self.log_info("Checking QuickShell installation...")

        if not self.check_command("quickshell"):
            self.log_warning(
                "QuickShell is not installed. Please install QuickShell first."
            )
            self.log_info(
                "  - Fedora COPR: https://copr.fedorainfracloud.org/coprs/errornointernet/quickshell"
            )

            response = (
                input("Do you want to continue without QuickShell? (y/N): ")
                .strip()
                .lower()
            )
            if response not in ("y", "yes"):
                self.log_error("QuickShell is required for the shell to work. Exiting.")
                sys.exit(1)
        else:
            self.log_success("QuickShell is installed")

    def setup_cli(self):
        """Setup CLI tool."""
        self.log_info("Setting up Caelestia CLI...")

        # Create temporary directory
        self.config.temp_dir.mkdir(parents=True, exist_ok=True)
        cli_dir = self.config.temp_dir / "cli"

        # Clone repository
        self.log_info("Cloning CLI repository...")
        try:
            self.run_command(
                ["git", "clone", self.config.caelestia_cli_repo, str(cli_dir)]
            )
        except subprocess.CalledProcessError:
            self.log_error("Failed to clone CLI repository")
            sys.exit(1)

        # Build and install
        pyproject_toml = cli_dir / "pyproject.toml"
        setup_py = cli_dir / "setup.py"

        if pyproject_toml.exists():
            self.log_info("Building CLI tool with modern Python build system...")

            # Build the wheel
            try:
                self.run_command(["python3", "-m", "build", "--wheel"], cwd=cli_dir)
            except subprocess.CalledProcessError:
                self.log_error("Failed to build CLI tool")
                sys.exit(1)

            # Install the wheel
            self.log_info("Installing CLI tool...")
            wheel_files = list((cli_dir / "dist").glob("*.whl"))
            if not wheel_files:
                self.log_error("No wheel files found")
                sys.exit(1)

            try:
                self.run_command(
                    ["python3", "-m", "installer", "--user", str(wheel_files[0])]
                )
            except subprocess.CalledProcessError:
                self.log_warning(
                    "User installation failed, trying system-wide installation..."
                )
                try:
                    self.run_command(
                        ["sudo", "python3", "-m", "installer", str(wheel_files[0])]
                    )
                except subprocess.CalledProcessError:
                    self.log_error("Failed to install CLI tool")
                    sys.exit(1)

        elif setup_py.exists():
            self.log_info("Building CLI tool with setup.py...")
            try:
                self.run_command(
                    ["python3", "setup.py", "install", "--user"], cwd=cli_dir
                )
            except subprocess.CalledProcessError:
                self.log_warning(
                    "User installation failed, trying system-wide installation..."
                )
                try:
                    self.run_command(
                        ["sudo", "python3", "setup.py", "install"], cwd=cli_dir
                    )
                except subprocess.CalledProcessError:
                    self.log_error("Failed to install CLI tool")
                    sys.exit(1)
        else:
            self.log_error("No recognizable build system found in CLI repository")
            sys.exit(1)

        # Install fish completion if available
        completion_file = cli_dir / "completions" / "caelestia.fish"
        if self.check_command("fish") and completion_file.exists():
            self.log_info("Installing fish completion...")
            completion_dir = Path("/usr/share/fish/vendor_completions.d")
            self.run_command(["sudo", "mkdir", "-p", str(completion_dir)])
            self.run_command(
                [
                    "sudo",
                    "cp",
                    str(completion_file),
                    str(completion_dir / "caelestia.fish"),
                ]
            )
            self.log_success("Fish completion installed")

        self.log_success("CLI tool setup completed")

    def setup_quickshell(self):
        """Setup QuickShell configuration."""
        self.log_info("Setting up QuickShell configuration...")

        quickshell_dir = Path.home() / ".config" / "quickshell"
        caelestia_dir = quickshell_dir / "caelestia"

        # Create quickshell config directory
        quickshell_dir.mkdir(parents=True, exist_ok=True)

        # Remove existing caelestia directory if it exists
        if caelestia_dir.exists():
            self.log_warning("Removing existing QuickShell Caelestia directory")
            shutil.rmtree(caelestia_dir)

        # Clone shell configuration
        self.log_info("Cloning shell configuration...")
        try:
            self.run_command(
                ["git", "clone", self.config.caelestia_shell_repo, str(caelestia_dir)]
            )
        except subprocess.CalledProcessError:
            self.log_error("Failed to clone shell configuration")
            sys.exit(1)

        # Make sure the shell has executable permissions if it has a run script
        run_script = caelestia_dir / "run.fish"
        if run_script.exists():
            run_script.chmod(0o755)

        self.log_success("QuickShell configuration setup completed")

    def compile_beat_detector(self):
        """Compile and install beat detector."""
        self.log_info("Compiling beat detector...")

        caelestia_dir = Path.home() / ".config" / "quickshell" / "caelestia"
        beat_detector_source = caelestia_dir / "assets" / "beat_detector.cpp"

        # Check if source file exists
        if not beat_detector_source.exists():
            self.log_error(
                f"Beat detector source file not found: {beat_detector_source}"
            )
            self.log_error("Make sure the shell configuration was cloned correctly")
            sys.exit(1)

        # Create compilation directory
        compile_dir = self.config.temp_dir / "beat_detector_build"
        compile_dir.mkdir(parents=True, exist_ok=True)

        # Copy source file
        source_copy = compile_dir / "beat_detector.cpp"
        shutil.copy2(beat_detector_source, source_copy)

        # Check for required headers
        include_dirs = [
            Path("/usr/include/pipewire-0.3"),
            Path("/usr/include/spa-0.2"),
            Path("/usr/include/aubio"),
        ]

        for include_dir in include_dirs:
            if not include_dir.exists():
                self.log_error(f"Required include directory not found: {include_dir}")
                self.log_error("Make sure all development packages are installed")
                sys.exit(1)

        # Compile with enhanced error checking
        self.log_info("Compiling beat detector binary...")
        compile_cmd = [
            "g++",
            "-std=c++17",
            "-Wall",
            "-Wextra",
            "-O2",
            "-I/usr/include/pipewire-0.3",
            "-I/usr/include/spa-0.2",
            "-I/usr/include/aubio",
            "-o",
            "beat_detector",
            "beat_detector.cpp",
            "-lpipewire-0.3",
            "-laubio",
            "-lpthread",
        ]

        try:
            self.run_command(compile_cmd, cwd=compile_dir)
        except subprocess.CalledProcessError:
            self.log_error("Failed to compile beat detector")
            self.log_error("Check that all required development packages are installed")
            sys.exit(1)

        # Test the binary
        beat_detector_binary = compile_dir / "beat_detector"
        if not beat_detector_binary.exists() or not os.access(
            beat_detector_binary, os.X_OK
        ):
            self.log_error("Beat detector binary is not executable")
            sys.exit(1)

        # Install beat detector
        self.log_info("Installing beat detector...")
        self.config.beat_detector_target.parent.mkdir(parents=True, exist_ok=True)

        try:
            self.run_command(
                [
                    "sudo",
                    "cp",
                    str(beat_detector_binary),
                    str(self.config.beat_detector_target),
                ]
            )
            self.run_command(
                ["sudo", "chmod", "+x", str(self.config.beat_detector_target)]
            )
        except subprocess.CalledProcessError:
            self.log_error("Failed to install beat detector")
            sys.exit(1)

        self.log_success("Beat detector compiled and installed successfully")

    def verify_installation(self):
        """Verify installation."""
        self.log_info("Verifying installation...")

        errors = []

        # Check if CLI tool is available
        if not self.check_command("caelestia"):
            errors.append("Caelestia CLI tool is not in PATH")

        # Check if shell configuration exists
        shell_config = Path.home() / ".config" / "quickshell" / "caelestia"
        if not shell_config.exists():
            errors.append("QuickShell configuration directory not found")

        # Check if beat detector exists and is executable
        if not (
            self.config.beat_detector_target.exists()
            and os.access(self.config.beat_detector_target, os.X_OK)
        ):
            errors.append("Beat detector binary not found or not executable")

        if errors:
            self.log_error("Installation verification failed:")
            for error in errors:
                self.log_error(f"  - {error}")
            sys.exit(1)

        self.log_success("Installation verification passed")

    def show_usage(self):
        """Display usage information."""
        self.log_info("To use Caelestia:")
        self.log_info("  - Start the shell: caelestia shell -d")
        self.log_info("  - Or use QuickShell directly: qs -c caelestia")
        self.log_info("  - Make sure QuickShell is installed and working")
        self.log_info(
            f"  - Configuration location: {Path.home() / '.config' / 'quickshell' / 'caelestia'}"
        )

        if self.check_command("fish"):
            self.log_info("  - Fish completion is installed and ready to use")

    def run(self):
        """Main execution method."""
        print("\033[0;34m========================================\033[0m")
        print("\033[0;34m       Caelestia Setup Script\033[0m")
        print("\033[0;34m       (Python 3.13 Version)\033[0m")
        print("\033[0;34m========================================\033[0m")

        # Pre-flight checks
        self.check_root()
        self.check_system()

        # Main setup steps
        self.install_packages()
        self.check_quickshell()
        self.setup_cli()
        self.setup_quickshell()
        self.compile_beat_detector()

        # Post-installation
        self.verify_installation()

        print("\033[0;32m========================================\033[0m")
        print("\033[0;32m   Caelestia Setup Completed!\033[0m")
        print("\033[0;32m========================================\033[0m")

        self.show_usage()


def main():
    """Main entry point."""
    try:
        setup = CaelestiaSetup()
        setup.run()
    except KeyboardInterrupt:
        print("\n\033[0;31m[ERROR]\033[0m Script interrupted by user", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"\n\033[0;31m[ERROR]\033[0m Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
