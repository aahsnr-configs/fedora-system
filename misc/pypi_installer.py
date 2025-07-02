#!/usr/bin/env python3
"""
Fedora PyPI/Git Package Builder and Installer (with optional RPM support)
"""

import argparse
import datetime
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.parse
import urllib.request
import zipfile
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class FedoraPyPIGitInstaller:
    def __init__(self):
        self.temp_dir: Optional[str] = None
        self.python_version = f"{sys.version_info.major}.{sys.version_info.minor}"
        self.site_packages = f"/usr/local/lib/python{self.python_version}/site-packages"
        self.build_rpm = False
        self.rpm_build_dir: Optional[str] = None

        # Ensure running as root
        if os.geteuid() != 0:
            logger.error("This script must be run as root (use sudo)")
            sys.exit(1)

        os.makedirs(self.site_packages, exist_ok=True)

    def check_dependencies(self) -> bool:
        """Ensure required system packages are installed"""
        logger.info("Checking system dependencies...")
        required = [
            "python3-devel",
            "gcc",
            "gcc-c++",
            "make",
            "cmake",
            "pkg-config",
            "python3-pip",
            "python3-setuptools",
            "python3-wheel",
            "python3-build",
            "git",
        ]
        if self.build_rpm:
            required += [
                "rpm-build",
                "python3-rpm-generators",
                "python3-setuptools-rpm",
            ]

        missing = []
        for pkg in required:
            if subprocess.run(["rpm", "-q", pkg], capture_output=True).returncode != 0:
                missing.append(pkg)
        if missing:
            logger.info(f"Installing missing packages: {', '.join(missing)}")
            if (
                subprocess.run(
                    ["dnf", "install", "-y"] + missing, capture_output=True
                ).returncode
                != 0
            ):
                logger.error("Failed to install dependencies")
                return False
        return True

    def setup_rpm_build_tree(self) -> None:
        """Prepare directories for RPM build"""
        self.rpm_build_dir = os.path.join(self.temp_dir, "rpmbuild")
        for sub in ["SOURCES", "SPECS", "BUILD", "RPMS", "SRPMS"]:
            os.makedirs(os.path.join(self.rpm_build_dir, sub), exist_ok=True)

    def create_rpm_tarball(self, source_dir: str, name: str) -> Optional[str]:
        """Archive source for RPM"""
        path = os.path.join(self.temp_dir, f"{name}.tar.gz")
        try:
            with tarfile.open(path, "w:gz") as tar:
                tar.add(source_dir, arcname=name)
            return path
        except Exception as e:
            logger.error(f"Failed tarball creation: {e}")
            return None

    def generate_rpm_spec(self, pkg: str, version: str) -> Optional[str]:
        """Produce RPM spec file"""
        spec = f"""
%global python3_version %(echo %{{__python3}} | sed 's/python3//g' | tr -d .)
Name:           python-{pkg}
Version:        {version}
Release:        1%{{?dist}}
Summary:        Python module for {pkg}
License:        UNKNOWN
URL:            UNKNOWN
BuildArch:      noarch
BuildRequires:  python3-devel
BuildRequires:  python3-setuptools
%description
Python module {pkg}
%prep
%setup -q
%build
%pyproject_build
%install
%pyproject_install
%files
%{{python3_sitelib}}/*
%changelog
* {datetime.date.today().strftime('%a %b %d %Y')} {pkg} <none> - {version}-1
- Auto-generated
"""
        spec_path = os.path.join(self.rpm_build_dir, "SPECS", f"python-{pkg}.spec")
        try:
            with open(spec_path, "w") as f:
                f.write(spec)
            return spec_path
        except Exception as e:
            logger.error(f"Spec generation failed: {e}")
            return None

    def build_rpm_package(self, src: str, pkg: str, ver: str) -> Optional[str]:
        """Build an RPM from source"""
        tarball = self.create_rpm_tarball(src, pkg)
        if not tarball:
            return None
        self.setup_rpm_build_tree()
        shutil.copy(tarball, os.path.join(self.rpm_build_dir, "SOURCES"))
        spec = self.generate_rpm_spec(pkg, ver)
        if not spec:
            return None
        cmd = ["rpmbuild", "-ba", "--define", f"_topdir {self.rpm_build_dir}", spec]
        if subprocess.run(cmd, capture_output=True).returncode != 0:
            logger.error("RPM build failed")
            return None
        # find rpm
        for root, _, files in os.walk(os.path.join(self.rpm_build_dir, "RPMS")):
            for f in files:
                if f.endswith(".rpm"):
                    return os.path.join(root, f)
        logger.error("RPM not found after build")
        return None

    def install_rpm_package(self, path: str) -> bool:
        """Install RPM package"""
        if (
            subprocess.run(
                ["dnf", "install", "-y", path], capture_output=True
            ).returncode
            != 0
        ):
            logger.error("RPM install failed")
            return False
        return True

    def build_and_install_package(
        self,
        source_dir: str,
        package_name: Optional[str] = None,
        version: Optional[str] = None,
    ) -> bool:
        """Core build/install logic"""
        logger.info("Building and installing package")
        if not package_name:
            package_name = self.get_package_name_from_source(source_dir)
        if not version:
            version = "0.1"
        if self.build_rpm:
            rpm_path = self.build_rpm_package(source_dir, package_name, version)
            return False if not rpm_path else self.install_rpm_package(rpm_path)

        original = os.getcwd()
        try:
            os.chdir(source_dir)
            self.install_dependencies(source_dir)
            if os.path.exists("pyproject.toml"):
                cmd = [
                    sys.executable,
                    "-m",
                    "pip",
                    "install",
                    ".",
                    "--prefix=/usr/local",
                    "--root=/",
                ]
            elif os.path.exists("setup.py"):
                cmd = [
                    sys.executable,
                    "setup.py",
                    "install",
                    "--prefix=/usr/local",
                    "--root=/",
                ]
            else:
                logger.error("No recognized build system (pyproject.toml or setup.py)")
                return False
            logger.info(f"Running: {' '.join(cmd)}")
            res = subprocess.run(cmd, capture_output=True, text=True)
            if res.returncode != 0:
                logger.error(f"Install failed: {res.stderr}")
                return False
            subprocess.run(["ldconfig"], capture_output=True)
            return True
        except Exception as e:
            logger.error(f"Error during install: {e}")
            return False
        finally:
            os.chdir(original)

    def cleanup(self) -> None:
        """Remove temporary build directory"""
        if self.temp_dir and os.path.isdir(self.temp_dir):
            logger.info(f"Cleaning up {self.temp_dir}")
            shutil.rmtree(self.temp_dir)

    # Placeholder for unmodified helper methods
    def get_package_name_from_source(self, source_dir: str) -> str:
        # Logic to infer package name
        return Path(source_dir).name

    def install_dependencies(self, source_dir: str) -> None:
        # Extract and install python dependencies if needed
        pass

    def get_package_info(
        self, pkg: str, ver: Optional[str]
    ) -> Optional[Dict[str, Any]]:
        # Query PyPI JSON API
        return {}

    def download_source(self, info: Dict[str, Any]) -> Optional[str]:
        # Download archive
        return None

    def extract_source(self, archive_path: str) -> Optional[str]:
        # Extract .tar.gz or .zip
        return None

    def clone_git_repository(
        self, url: str, branch: Optional[str], tag: Optional[str], commit: Optional[str]
    ) -> Optional[str]:
        # Git clone logic
        return None

    def install_git_package(
        self,
        git_url: str,
        branch: Optional[str] = None,
        tag: Optional[str] = None,
        commit: Optional[str] = None,
    ) -> bool:
        # Clone then build
        return False

    def install_single_package(
        self, package_name: str, version: Optional[str] = None
    ) -> bool:
        # PyPI install
        return False

    def run(self, args: Any) -> bool:
        """Entry point for installer"""
        self.build_rpm = args.rpm
        self.temp_dir = tempfile.mkdtemp(prefix="pypi_installer_")
        try:
            if not self.check_dependencies():
                return False
            # dispatch logic omitted for brevity
            return True
        finally:
            self.cleanup()


def main():
    parser = argparse.ArgumentParser(
        description="Build/install Python packages (PyPI/Git) with optional RPM on Fedora"
    )
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("package", nargs="?", help="PyPI package name")
    source.add_argument("-r", "--requirements", help="Requirements file")
    source.add_argument("--git", dest="git_url", help="Git URL")
    parser.add_argument("version", nargs="?", help="Package version")
    parser.add_argument("--branch", "-b", help="Git branch")
    parser.add_argument("--tag", "-t", help="Git tag")
    parser.add_argument("--commit", "-c", help="Git commit")
    parser.add_argument("--rpm", action="store_true", help="Build RPM")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose logging")
    args = parser.parse_args()
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    installer = FedoraPyPIGitInstaller()
    success = installer.run(args)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
