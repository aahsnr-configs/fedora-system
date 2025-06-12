#!/usr/bin/env python3
"""
Fedora PyPI/Git Package Builder and Installer

This script downloads, builds, and installs Python packages from PyPI or Git repositories
system-wide on Fedora Linux. It handles dependencies, compilation,
and proper system integration.

Usage:
    # PyPI packages
    sudo python3 pypi_installer.py <package_name> [version]
    sudo python3 pypi_installer.py -r requirements.txt
    sudo python3 pypi_installer.py -l packages.txt
    
    # Git repositories
    sudo python3 pypi_installer.py --git https://github.com/user/repo.git
    sudo python3 pypi_installer.py --git https://github.com/user/repo.git --branch main
    sudo python3 pypi_installer.py --git https://github.com/user/repo.git --tag v1.0.0
    sudo python3 pypi_installer.py --git https://github.com/user/repo.git --commit abc123
    
    # Mixed sources file
    sudo python3 pypi_installer.py -m mixed_sources.txt

Requirements:
    - Run as root (sudo)
    - Fedora Linux system
    - Development tools installed (gcc, python3-devel, etc.)
    - Git (for Git repository support)
"""

import os
import sys
import subprocess
import tempfile
import shutil
import json
import urllib.request
import urllib.parse
import tarfile
import zipfile
import argparse
import logging
import re
from pathlib import Path
from typing import List, Optional, Dict, Any, Tuple

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class FedoraPyPIGitInstaller:
    def __init__(self):
        self.temp_dir = None
        self.python_version = f"{sys.version_info.major}.{sys.version_info.minor}"
        self.site_packages = f"/usr/local/lib/python{self.python_version}/site-packages"
        
        # Ensure we're running as root
        if os.geteuid() != 0:
            logger.error("This script must be run as root (use sudo)")
            sys.exit(1)
            
        # Create site-packages directory if it doesn't exist
        os.makedirs(self.site_packages, exist_ok=True)
        
    def check_dependencies(self):
        """Check and install required system dependencies"""
        logger.info("Checking system dependencies...")
        
        required_packages = [
            'python3-devel',
            'gcc',
            'gcc-c++',
            'make',
            'cmake',
            'pkg-config',
            'python3-pip',
            'python3-setuptools',
            'python3-wheel',
            'python3-build',  # For modern Python packaging
            'git'  # Added git support
        ]
        
        # Check if packages are installed
        missing_packages = []
        for package in required_packages:
            result = subprocess.run(['rpm', '-q', package], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                missing_packages.append(package)
        
        if missing_packages:
            logger.info(f"Installing missing packages: {', '.join(missing_packages)}")
            cmd = ['dnf', 'install', '-y'] + missing_packages
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode != 0:
                logger.error(f"Failed to install dependencies: {result.stderr}")
                return False
                
        return True
    
    def get_package_info(self, package_name: str, version: Optional[str] = None) -> Dict[str, Any]:
        """Get package information from PyPI"""
        logger.info(f"Fetching package info for {package_name}")
        
        if version:
            url = f"https://pypi.org/pypi/{package_name}/{version}/json"
        else:
            url = f"https://pypi.org/pypi/{package_name}/json"
            
        try:
            with urllib.request.urlopen(url) as response:
                data = json.loads(response.read().decode())
                return data
        except Exception as e:
            logger.error(f"Failed to fetch package info: {e}")
            return {}
    
    def parse_git_url(self, git_url: str) -> Tuple[str, str]:
        """Parse Git URL to extract repository name"""
        # Extract repo name from URL
        if git_url.endswith('.git'):
            repo_name = os.path.basename(git_url)[:-4]
        else:
            repo_name = os.path.basename(git_url)
        
        # Clean URL
        clean_url = git_url.strip()
        return clean_url, repo_name
    
    def clone_git_repository(self, git_url: str, branch: Optional[str] = None, 
                           tag: Optional[str] = None, commit: Optional[str] = None) -> Optional[str]:
        """Clone Git repository"""
        clean_url, repo_name = self.parse_git_url(git_url)
        logger.info(f"Cloning Git repository: {clean_url}")
        
        clone_dir = os.path.join(self.temp_dir, repo_name)
        
        try:
            # Base clone command
            cmd = ['git', 'clone', clean_url, clone_dir]
            
            # Add branch if specified
            if branch:
                cmd.extend(['--branch', branch])
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                logger.error(f"Failed to clone repository: {result.stderr}")
                return None
            
            # Checkout specific tag or commit if specified
            if tag or commit:
                original_dir = os.getcwd()
                try:
                    os.chdir(clone_dir)
                    
                    if tag:
                        logger.info(f"Checking out tag: {tag}")
                        result = subprocess.run(['git', 'checkout', f'tags/{tag}'], 
                                              capture_output=True, text=True)
                    elif commit:
                        logger.info(f"Checking out commit: {commit}")
                        result = subprocess.run(['git', 'checkout', commit], 
                                              capture_output=True, text=True)
                    
                    if result.returncode != 0:
                        logger.error(f"Failed to checkout: {result.stderr}")
                        return None
                        
                finally:
                    os.chdir(original_dir)
            
            logger.info(f"Successfully cloned to {clone_dir}")
            return clone_dir
            
        except Exception as e:
            logger.error(f"Error cloning repository: {e}")
            return None
    
    def get_package_name_from_source(self, source_dir: str) -> str:
        """Extract package name from source directory"""
        # Try to get name from pyproject.toml first (modern packaging)
        pyproject_path = os.path.join(source_dir, 'pyproject.toml')
        if os.path.exists(pyproject_path):
            try:
                with open(pyproject_path, 'r') as f:
                    content = f.read()
                    # Look for name = "package_name" in [project] section
                    import re
                    # Try project.name first
                    match = re.search(r'\[project\].*?name\s*=\s*["\']([^"\']+)["\']', content, re.DOTALL)
                    if match:
                        return match.group(1)
                    # Fallback to top-level name
                    match = re.search(r'name\s*=\s*["\']([^"\']+)["\']', content)
                    if match:
                        return match.group(1)
            except Exception as e:
                logger.warning(f"Error parsing pyproject.toml: {e}")
        
        # Try to get name from setup.py
        setup_py_path = os.path.join(source_dir, 'setup.py')
        if os.path.exists(setup_py_path):
            try:
                with open(setup_py_path, 'r') as f:
                    content = f.read()
                    # Look for name= parameter
                    import re
                    match = re.search(r'name\s*=\s*["\']([^"\']+)["\']', content)
                    if match:
                        return match.group(1)
            except Exception as e:
                logger.warning(f"Error parsing setup.py: {e}")
        
        # Try to get name from setup.cfg
        setup_cfg_path = os.path.join(source_dir, 'setup.cfg')
        if os.path.exists(setup_cfg_path):
            try:
                with open(setup_cfg_path, 'r') as f:
                    content = f.read()
                    import re
                    match = re.search(r'name\s*=\s*([^\s\n]+)', content)
                    if match:
                        return match.group(1)
            except Exception as e:
                logger.warning(f"Error parsing setup.cfg: {e}")
        
        # Fall back to directory name
        return os.path.basename(source_dir)
    
    def download_source(self, package_info: Dict[str, Any]) -> Optional[str]:
        """Download source distribution"""
        urls = package_info.get('urls', [])
        
        # Prefer source distributions
        source_url = None
        for url_info in urls:
            if url_info.get('packagetype') == 'sdist':
                source_url = url_info['url']
                filename = url_info['filename']
                break
        
        if not source_url:
            # Fall back to any available distribution
            for url_info in urls:
                if url_info.get('packagetype') in ['bdist_wheel', 'bdist_egg']:
                    source_url = url_info['url']
                    filename = url_info['filename']
                    break
        
        if not source_url:
            logger.error("No suitable distribution found")
            return None
            
        logger.info(f"Downloading {filename}")
        
        download_path = os.path.join(self.temp_dir, filename)
        try:
            urllib.request.urlretrieve(source_url, download_path)
            return download_path
        except Exception as e:
            logger.error(f"Failed to download package: {e}")
            return None
    
    def extract_source(self, archive_path: str) -> Optional[str]:
        """Extract source archive"""
        logger.info("Extracting source archive")
        
        extract_dir = os.path.join(self.temp_dir, 'extracted')
        os.makedirs(extract_dir, exist_ok=True)
        
        try:
            if archive_path.endswith('.tar.gz') or archive_path.endswith('.tar.bz2'):
                with tarfile.open(archive_path, 'r:*') as tar:
                    tar.extractall(extract_dir)
            elif archive_path.endswith('.zip'):
                with zipfile.ZipFile(archive_path, 'r') as zip_file:
                    zip_file.extractall(extract_dir)
            else:
                logger.error(f"Unsupported archive format: {archive_path}")
                return None
            
            # Find the extracted directory
            extracted_contents = os.listdir(extract_dir)
            if len(extracted_contents) == 1:
                return os.path.join(extract_dir, extracted_contents[0])
            else:
                return extract_dir
                
        except Exception as e:
            logger.error(f"Failed to extract archive: {e}")
            return None
    
    def install_dependencies(self, source_dir: str) -> bool:
        """Install dependencies from various sources"""
        logger.info("Installing dependencies")
        
        original_dir = os.getcwd()
        dependencies_installed = False
        
        try:
            os.chdir(source_dir)
            
            # 1. Install from requirements.txt if it exists
            requirements_files = ['requirements.txt', 'requirements/base.txt', 'requirements/production.txt']
            for req_file in requirements_files:
                if os.path.exists(req_file):
                    logger.info(f"Installing dependencies from {req_file}")
                    cmd = [sys.executable, '-m', 'pip', 'install', '-r', req_file]
                    result = subprocess.run(cmd, capture_output=True, text=True)
                    if result.returncode == 0:
                        dependencies_installed = True
                        logger.info(f"Successfully installed dependencies from {req_file}")
                    else:
                        logger.warning(f"Failed to install some dependencies from {req_file}: {result.stderr}")
            
            # 2. Install dependencies from pyproject.toml
            if os.path.exists('pyproject.toml'):
                logger.info("Checking pyproject.toml for dependencies")
                try:
                    with open('pyproject.toml', 'r') as f:
                        content = f.read()
                    
                    # Extract dependencies using regex (basic parsing)
                    import re
                    deps_match = re.search(r'dependencies\s*=\s*\[(.*?)\]', content, re.DOTALL)
                    if deps_match:
                        deps_content = deps_match.group(1)
                        # Extract quoted dependencies
                        deps = re.findall(r'["\']([^"\']+)["\']', deps_content)
                        if deps:
                            logger.info(f"Installing {len(deps)} dependencies from pyproject.toml")
                            for dep in deps:
                                dep = dep.strip()
                                if dep:
                                    cmd = [sys.executable, '-m', 'pip', 'install', dep]
                                    result = subprocess.run(cmd, capture_output=True, text=True)
                                    if result.returncode == 0:
                                        logger.info(f"Installed dependency: {dep}")
                                        dependencies_installed = True
                                    else:
                                        logger.warning(f"Failed to install dependency {dep}: {result.stderr}")
                except Exception as e:
                    logger.warning(f"Error parsing pyproject.toml dependencies: {e}")
            
            # 3. Install dependencies from setup.py (if no pyproject.toml)
            elif os.path.exists('setup.py'):
                logger.info("Extracting dependencies from setup.py")
                try:
                    # Try to extract install_requires from setup.py
                    with open('setup.py', 'r') as f:
                        content = f.read()
                    
                    # Look for install_requires
                    import re
                    install_requires_match = re.search(r'install_requires\s*=\s*\[(.*?)\]', content, re.DOTALL)
                    if install_requires_match:
                        deps_content = install_requires_match.group(1)
                        deps = re.findall(r'["\']([^"\']+)["\']', deps_content)
                        if deps:
                            logger.info(f"Installing {len(deps)} dependencies from setup.py")
                            for dep in deps:
                                dep = dep.strip()
                                if dep:
                                    cmd = [sys.executable, '-m', 'pip', 'install', dep]
                                    result = subprocess.run(cmd, capture_output=True, text=True)
                                    if result.returncode == 0:
                                        logger.info(f"Installed dependency: {dep}")
                                        dependencies_installed = True
                                    else:
                                        logger.warning(f"Failed to install dependency {dep}: {result.stderr}")
                except Exception as e:
                    logger.warning(f"Error parsing setup.py dependencies: {e}")
            
            return True  # Don't fail if dependency installation has issues
            
        except Exception as e:
            logger.error(f"Error installing dependencies: {e}")
            return True  # Don't fail the entire process for dependency issues
        finally:
            os.chdir(original_dir)

    def build_and_install_package(self, source_dir: str) -> bool:
        """Build and install the package"""
        logger.info("Building and installing package")
        
        original_dir = os.getcwd()
        try:
            os.chdir(source_dir)
            
            # First install dependencies
            self.install_dependencies(source_dir)
            
            # Check for different build/install systems
            if os.path.exists('pyproject.toml'):
                logger.info("Using modern Python packaging (pyproject.toml)")
                # Install directly using pip in editable mode, then copy to system location
                cmd = [sys.executable, '-m', 'pip', 'install', '.', '--prefix=/usr/local', '--root=/']
                
            elif os.path.exists('setup.py'):
                logger.info("Using traditional setuptools (setup.py)")
                # Use setup.py install with proper system paths
                cmd = [sys.executable, 'setup.py', 'install', '--prefix=/usr/local', '--root=/']
                
            else:
                logger.error("No recognized build system found (setup.py or pyproject.toml)")
                return False
            
            # Execute installation
            logger.info(f"Running installation command: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                logger.error(f"Installation failed: {result.stderr}")
                logger.error(f"Installation stdout: {result.stdout}")
                return False
                
            logger.info("Installation completed successfully")
            logger.info(f"Installation stdout: {result.stdout}")
            
            # Update system library cache
            subprocess.run(['ldconfig'], capture_output=True)
            
            return True
            
        except Exception as e:
            logger.error(f"Installation error: {e}")
            return False
        finally:
            os.chdir(original_dir)
    
    def install_package(self, source_dir: str, package_name: str) -> bool:
        """Install the package system-wide (legacy method, now integrated into build_and_install_package)"""
        # This method is now handled by build_and_install_package
        return self.build_and_install_package(source_dir)
    
    def install_git_package(self, git_url: str, branch: Optional[str] = None,
                           tag: Optional[str] = None, commit: Optional[str] = None) -> bool:
        """Install a package from Git repository"""
        logger.info(f"Installing package from Git: {git_url}")
        
        # Clone repository
        source_dir = self.clone_git_repository(git_url, branch, tag, commit)
        if not source_dir:
            return False
        
        # Get package name
        package_name = self.get_package_name_from_source(source_dir)
        
        # Build package
        if not self.build_package(source_dir):
            return False
        
        # Install package
    def install_single_package(self, package_name: str, version: Optional[str] = None) -> bool:
    def install_single_package(self, package_name: str, version: Optional[str] = None) -> bool:
        """Install a single package"""
        logger.info(f"Installing package: {package_name}" + (f" (version {version})" if version else ""))
        
        # Get package info
        package_info = self.get_package_info(package_name, version)
        if not package_info:
            logger.error(f"Failed to get package info for {package_name}")
            return False
        
        # Download source
        archive_path = self.download_source(package_info)
        if not archive_path:
            return False
        
        # Extract source
        source_dir = self.extract_source(archive_path)
        if not source_dir:
            return False
        
        # Build and install package (includes dependencies)
        return self.build_and_install_package(source_dir)
    
    def parse_source_line(self, line: str) -> Dict[str, Any]:
        """Parse a line from a source file (supports PyPI and Git)"""
        line = line.strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            return {'type': 'skip'}
        
        # Check if it's a Git URL
        if line.startswith(('http://', 'https://', 'git://', 'ssh://')) and ('github.com' in line or 'gitlab.com' in line or '.git' in line):
            # Parse Git URL with optional parameters
            parts = line.split()
            git_url = parts[0]
            
            result = {
                'type': 'git',
                'url': git_url,
                'branch': None,
                'tag': None,
                'commit': None
            }
            
            # Parse additional parameters
            for part in parts[1:]:
                if part.startswith('--branch=') or part.startswith('-b='):
                    result['branch'] = part.split('=', 1)[1]
                elif part.startswith('--tag=') or part.startswith('-t='):
                    result['tag'] = part.split('=', 1)[1]
                elif part.startswith('--commit=') or part.startswith('-c='):
                    result['commit'] = part.split('=', 1)[1]
            
            return result
        
        # Otherwise, treat as PyPI package
        if '==' in line:
            package_name, version = line.split('==', 1)
            return {
                'type': 'pypi',
                'package': package_name.strip(),
                'version': version.strip()
            }
        else:
            return {
                'type': 'pypi',
                'package': line.strip(),
                'version': None
            }
    
    def install_from_file(self, filepath: str, mixed_sources: bool = False):
        """Install packages from a file (supports mixed PyPI/Git sources if mixed_sources=True)"""
        file_type = "mixed sources" if mixed_sources else "requirements"
        logger.info(f"Installing packages from {file_type} file: {filepath}")
        
        try:
            with open(filepath, 'r') as f:
                lines = f.readlines()
            
            for line_num, line in enumerate(lines, 1):
                try:
                    source_info = self.parse_source_line(line)
                    
                    if source_info['type'] == 'skip':
                        continue
                    elif source_info['type'] == 'pypi':
                        logger.info(f"Line {line_num}: Installing PyPI package {source_info['package']}")
                        self.install_single_package(source_info['package'], source_info['version'])
                    elif source_info['type'] == 'git':
                        logger.info(f"Line {line_num}: Installing Git package {source_info['url']}")
                        self.install_git_package(
                            source_info['url'],
                            source_info['branch'],
                            source_info['tag'],
                            source_info['commit']
                        )
                    
                except Exception as e:
                    logger.error(f"Error processing line {line_num}: {e}")
                    continue
                    
        except Exception as e:
            logger.error(f"Failed to read {file_type} file: {e}")
    
    def cleanup(self):
        """Clean up temporary files"""
        if self.temp_dir and os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def run(self, args):
        """Main execution method"""
        # Create temporary directory
        self.temp_dir = tempfile.mkdtemp(prefix='pypi_installer_')
        
        try:
            # Check system dependencies
            if not self.check_dependencies():
                logger.error("Failed to install system dependencies")
                return False
            
            if args.requirements:
                self.install_from_file(args.requirements, mixed_sources=False)
            elif args.list_file:
                self.install_from_file(args.list_file, mixed_sources=False)
            elif args.mixed_sources:
                self.install_from_file(args.mixed_sources, mixed_sources=True)
            elif args.git_url:
                success = self.install_git_package(
                    args.git_url, 
                    args.branch, 
                    args.tag, 
                    args.commit
                )
                if not success:
                    return False
            elif args.package:
                success = self.install_single_package(args.package, args.version)
                if not success:
                    return False
            else:
                logger.error("No package or source specified")
                return False
            
            logger.info("Installation completed successfully")
            return True
            
        finally:
            self.cleanup()

def main():
    parser = argparse.ArgumentParser(
        description='Build and install Python packages from PyPI or Git repositories on Fedora',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # PyPI packages
    sudo python3 pypi_installer.py requests
    sudo python3 pypi_installer.py numpy 1.24.0
    sudo python3 pypi_installer.py -r requirements.txt
    
    # Git repositories
    sudo python3 pypi_installer.py --git https://github.com/psf/requests.git
    sudo python3 pypi_installer.py --git https://github.com/user/repo.git --branch develop
    sudo python3 pypi_installer.py --git https://github.com/user/repo.git --tag v1.0.0
    sudo python3 pypi_installer.py --git https://github.com/user/repo.git --commit abc123
    
    # Mixed sources file
    sudo python3 pypi_installer.py -m mixed_sources.txt
        """
    )
    
    # Main source groups (mutually exclusive)
    source_group = parser.add_mutually_exclusive_group(required=True)
    source_group.add_argument('package', nargs='?', help='Package name to install from PyPI')
    source_group.add_argument('-r', '--requirements', help='Requirements file (PyPI packages only)')
    source_group.add_argument('-l', '--list-file', help='List file containing PyPI package names')
    source_group.add_argument('-m', '--mixed-sources', help='Mixed sources file (PyPI packages and Git repositories)')
    source_group.add_argument('--git', dest='git_url', help='Git repository URL')
    
    # Additional arguments
    parser.add_argument('version', nargs='?', help='Specific version to install (PyPI only)')
    parser.add_argument('--branch', '-b', help='Git branch to checkout (Git only)')
    parser.add_argument('--tag', '-t', help='Git tag to checkout (Git only)')
    parser.add_argument('--commit', '-c', help='Git commit to checkout (Git only)')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    # Validate Git-specific arguments
    if args.git_url:
        if args.version:
            parser.error("Version specification is not supported for Git repositories")
        # Ensure only one of branch, tag, or commit is specified
        git_refs = [args.branch, args.tag, args.commit]
        if sum(bool(ref) for ref in git_refs) > 1:
            parser.error("Only one of --branch, --tag, or --commit can be specified")
    else:
        if any([args.branch, args.tag, args.commit]):
            parser.error("Git-specific options (--branch, --tag, --commit) can only be used with --git")
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    installer = FedoraPyPIGitInstaller()
    success = installer.run(args)
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
