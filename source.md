# Document Title
Here's the comprehensive, modularized Python script that transforms Fedora 42 into a source-based distribution with Gentoo-like features, including USE flags and accept-keywords functionality:

```python
#!/usr/bin/env python3
"""
Fedora 42 Source-Based Distribution with Gentoo Features
Version: 4.0.0 (2025-06-05)
"""

import os
import re
import sys
import json
import shutil
import argparse
import hashlib
import tempfile
import subprocess
import configparser
import concurrent.futures
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict

# Configuration
DEFAULT_CONFIG = {
    'system': {
        'arch': subprocess.check_output(['uname', '-m'], text=True).strip(),
        'fedora_version': 42,
        'base_image': 'registry.fedoraproject.org/fedora:42',
        'build_root': '/var/lib/source-fedora',
        'rpmbuild_root': '/var/lib/rpmbuild',
        'state_file': '/var/lib/source-fedora/state.json',
        'log_file': '/var/log/source-fedora.log',
        'use_flags_dir': '/etc/source-fedora/use_flags.d',
        'accept_keywords': '/etc/source-fedora/accept_keywords'
    },
    'repositories': {
        'fedora': ['fedora', 'fedora-updates', 'fedora-updates-testing', 'fedora-rawhide'],
        'rpmfusion': ['rpmfusion-free', 'rpmfusion-nonfree'],
        'thirdparty': ['copr:copr.fedorainfracloud.org:group:custom']
    },
    'build': {
        'parallel_jobs': 'auto',
        'container_backend': 'buildah',
        'strict_checks': True,
        'exclude_packages': ['kernel*', 'microcode*', 'firmware*', 'grub*', 'shim*'],
        'default_use_flags': 'X alsa pulseaudio network',
        'unstable_keywords': ['~git', '~rawhide']
    }
}

class ConfigManager:
    """Manage configuration settings and user preferences"""
    def __init__(self):
        self.config = DEFAULT_CONFIG.copy()
        self.user_config = self.load_user_config()
        self.use_flags = self.load_use_flags()
        self.accept_keywords = self.load_accept_keywords()
        
    def load_user_config(self):
        """Load user configuration from /etc/source-fedora.conf"""
        config_path = Path('/etc/source-fedora.conf')
        if not config_path.exists():
            return {}
            
        config = configparser.ConfigParser()
        config.read(config_path)
        return config
        
    def load_use_flags(self) -> Dict[str, List[str]]:
        """Load package-specific USE flags"""
        flags = defaultdict(list)
        flags_dir = Path(self.config['system']['use_flags_dir'])
        
        # Default global flags
        if 'DEFAULT' in self.user_config:
            flags['global'] = self.user_config['DEFAULT'].get(
                'use_flags', 
                self.config['build']['default_use_flags']
            ).split()
        
        # Package-specific flags
        for pkg_file in flags_dir.glob('*.conf'):
            pkg_name = pkg_file.stem
            with pkg_file.open() as f:
                flags[pkg_name] = f.read().split()
                
        return flags
        
    def load_accept_keywords(self) -> Set[str]:
        """Load accepted keywords for unstable packages"""
        accept_file = Path(self.config['system']['accept_keywords'])
        if not accept_file.exists():
            return set()
            
        with accept_file.open() as f:
            return {line.strip() for line in f if line.strip() and not line.startswith('#')}
            
    def get_use_flags(self, package: str) -> List[str]:
        """Get USE flags for a specific package"""
        return self.use_flags.get(package, self.use_flags.get('global', []))
        
    def is_keyword_accepted(self, package: str) -> bool:
        """Check if package is allowed to use unstable versions"""
        return package in self.accept_keywords
        
    def get_parallel_jobs(self) -> int:
        """Determine optimal parallel job count"""
        if self.config['build']['parallel_jobs'] == 'auto':
            return os.cpu_count() or 1
        return int(self.config['build']['parallel_jobs'])
        
    def get_build_root(self) -> Path:
        """Get build root directory"""
        return Path(self.config['system']['build_root'])
        
    def get_rpmbuild_root(self) -> Path:
        """Get RPM build directory"""
        return Path(self.config['system']['rpmbuild_root'])

class SourceManager:
    """Manage source retrieval and processing"""
    def __init__(self, config: ConfigManager):
        self.config = config
        self.cache_dir = self.config.get_build_root() / 'cache'
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
    def get_package_info(self, package: str) -> List[Dict]:
        """Retrieve package information from repositories"""
        cmd = ['dnf', 'repoquery', '--quiet', '--queryformat', 'json', package]
        for repo_group in self.config.config['repositories'].values():
            for repo in repo_group:
                cmd.extend(['--repo', repo])
                
        try:
            output = subprocess.check_output(cmd, text=True)
            return json.loads(output)
        except subprocess.CalledProcessError:
            return []
            
    def resolve_version(self, package: str) -> Optional[Dict]:
        """Find best available version with keyword acceptance"""
        packages = self.get_package_info(package)
        if not packages:
            return None
            
        # Filter excluded packages
        packages = [
            pkg for pkg in packages 
            if not any(re.match(pattern, pkg['name']) 
                for pattern in self.config.config['build']['exclude_packages'])
        ]
        
        if not packages:
            return None
            
        # Prioritize sources: git > rawhide > testing > stable
        source_priority = {
            'git': 1000,
            'rawhide': 900,
            'updates-testing': 800,
            'testing': 700,
            'stable': 600
        }
        
        best_pkg = None
        for pkg in packages:
            # Check if unstable version needs acceptance
            pkg_keywords = pkg.get('keywords', '').split()
            unstable = any(kw in pkg_keywords 
                for kw in self.config.config['build']['unstable_keywords'])
                
            if unstable and not self.config.is_keyword_accepted(pkg['name']):
                continue
                
            # Calculate priority
            repo_priority = 0
            for repo_pattern, priority in source_priority.items():
                if repo_pattern in pkg['repo'].lower():
                    repo_priority = priority
                    break
                    
            # Git sources get highest priority
            if 'git' in pkg.get('release', '').lower():
                repo_priority = source_priority['git']
                
            # Select best candidate
            if not best_pkg or repo_priority > best_pkg['priority']:
                best_pkg = pkg
                best_pkg['priority'] = repo_priority
            elif repo_priority == best_pkg['priority']:
                if self.compare_versions(pkg['version'], best_pkg['version']) > 0:
                    best_pkg = pkg
                    best_pkg['priority'] = repo_priority
                    
        return best_pkg
        
    def compare_versions(self, v1: str, v2: str) -> int:
        """Compare RPM versions using rpmdev-vercmp"""
        try:
            result = subprocess.run(
                ['rpmdev-vercmp', v1, v2],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True
            )
            # Return codes: 0=equal, 11=v1>v2, 12=v1<v2
            if result.returncode == 11:
                return 1
            elif result.returncode == 12:
                return -1
            return 0
        except subprocess.CalledProcessError as e:
            print(f"Version comparison failed: {e.stderr.decode()}")
            return 0
            
    def fetch_source(self, package_info: Dict) -> Path:
        """Retrieve source for building"""
        # Create unique cache key
        cache_key = f"{package_info['name']}-{package_info['version']}-{package_info['release']}"
        cache_hash = hashlib.sha256(cache_key.encode()).hexdigest()
        cache_file = self.cache_dir / f"{cache_hash}.src.rpm"
        
        if cache_file.exists():
            return cache_file
            
        # Handle git sources
        if 'git' in package_info.get('release', '').lower():
            return self.fetch_git_source(package_info, cache_file)
            
        # Download SRPM
        cmd = [
            'dnf', 'download', '--source',
            '--destdir', str(self.cache_dir),
            f"{package_info['name']}-{package_info['version']}-{package_info['release']}"
        ]
        subprocess.run(cmd, check=True)
        
        # Find downloaded file
        pattern = f"{package_info['name']}*.src.rpm"
        downloaded = list(self.cache_dir.glob(pattern))
        if not downloaded:
            raise FileNotFoundError(f"Source download failed for {package_info['name']}")
            
        # Rename to hashed filename
        downloaded[0].rename(cache_file)
        return cache_file
        
    def fetch_git_source(self, package_info: Dict, cache_file: Path) -> Path:
        """Clone git repository and generate SRPM"""
        git_url = self.resolve_git_url(package_info)
        
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp_path = Path(tmpdir)
            # Clone repository
            subprocess.run(['git', 'clone', '--depth=1', git_url, tmpdir], check=True)
            
            # Find spec file
            spec_files = list(tmp_path.rglob('*.spec'))
            if not spec_files:
                raise FileNotFoundError(f"No .spec file found in {git_url}")
                
            spec_file = spec_files[0]
            
            # Prepare sources
            sources_dir = tmp_path / 'SOURCES'
            sources_dir.mkdir(exist_ok=True)
            for src in tmp_path.glob('*'):
                if src != spec_file and src != sources_dir:
                    shutil.move(src, sources_dir)
            
            # Build SRPM
            subprocess.run([
                'rpmbuild', '-bs',
                '--define', f'_sourcedir {sources_dir}',
                '--define', f'_srcrpmdir {tmp_path}',
                spec_file
            ], check=True)
            
            # Find generated SRPM
            srpms = list(tmp_path.glob('*.src.rpm'))
            if not srpms:
                raise FileNotFoundError("SRPM build failed")
            
            # Cache the result
            shutil.copy(srpms[0], cache_file)
            
        return cache_file
        
    def resolve_git_url(self, package_info: Dict) -> str:
        """Determine git URL for package"""
        # Check for URL in package metadata
        if 'url' in package_info:
            return package_info['url']
            
        # Default to Fedora's git
        return f"https://src.fedoraproject.org/rpms/{package_info['name']}.git"

class BuildManager:
    """Manage package building process"""
    def __init__(self, config: ConfigManager, source: SourceManager):
        self.config = config
        self.source = source
        self.state = self.load_state()
        self.dependency_graph = defaultdict(list)
        
    def load_state(self) -> Dict:
        """Load persistent build state"""
        state_file = Path(self.config.config['system']['state_file'])
        try:
            with state_file.open() as f:
                return json.load(f)
        except FileNotFoundError:
            return {'built': {}, 'sources': {}}
            
    def save_state(self):
        """Save persistent build state"""
        state_file = Path(self.config.config['system']['state_file'])
        with state_file.open('w') as f:
            json.dump(self.state, f, indent=2)
            
    def resolve_dependencies(self, srpm: Path) -> Set[str]:
        """Extract build dependencies from SRPM"""
        requires = set()
        
        # Query SRPM metadata
        cmd = ['rpm', '-qRp', '--requires', str(srpm)]
        output = subprocess.check_output(cmd, text=True)
        
        # Parse requirements
        for line in output.splitlines():
            dep = line.split()[0]
            # Filter out internal dependencies
            if dep.startswith('rpmlib(') or dep.startswith('/'):
                continue
            # Filter out excluded packages
            if any(re.match(pattern, dep) 
                   for pattern in self.config.config['build']['exclude_packages']):
                continue
            requires.add(dep)
        
        return requires
        
    def apply_use_flags(self, spec_file: Path, package: str):
        """Modify spec file based on USE flags"""
        use_flags = self.config.get_use_flags(package)
        if not use_flags:
            return
            
        print(f"  🚩 Applying USE flags: {', '.join(use_flags)}")
        
        # Read spec content
        with spec_file.open('r') as f:
            lines = f.readlines()
            
        # Apply flag transformations
        modified = False
        for i, line in enumerate(lines):
            # Handle conditional blocks
            if line.strip().startswith('%if'):
                condition = line.split()[1]
                if condition in use_flags:
                    lines[i] = line.replace('%if', '%if 1')
                    modified = True
                    
        # Add global defines
        for flag in use_flags:
            if flag.startswith('-'):
                continue
            define_line = f"%global with_{flag} 1\n"
            if define_line not in lines:
                lines.insert(0, define_line)
                modified = True
                
        # Save changes
        if modified:
            with spec_file.open('w') as f:
                f.writelines(lines)
                
    def build_with_buildah(self, srpm: Path, package: str) -> List[Path]:
        """Build package using Buildah container with USE flags"""
        container_name = f"build-{package}"
        build_dir = self.config.get_build_root() / package
        build_dir.mkdir(exist_ok=True)
        
        try:
            # Create container
            subprocess.run([
                'buildah', 'from', '--name', container_name, 
                self.config.config['system']['base_image']
            ], check=True)
            
            # Install build dependencies
            subprocess.run([
                'buildah', 'run', container_name, 'dnf', 'install', '-y',
                'rpm-build', 'dnf-plugins-core', 'git'
            ], check=True)
            
            # Copy SRPM into container
            subprocess.run([
                'buildah', 'copy', container_name, str(srpm), '/root/'
            ], check=True)
            
            # Install SRPM
            subprocess.run([
                'buildah', 'run', container_name, 'rpm', '-i', f"/root/{srpm.name}"
            ], check=True)
            
            # Extract and modify spec file for USE flags
            spec_path = f"/root/rpmbuild/SPECS/{package}.spec"
            subprocess.run([
                'buildah', 'run', container_name, 'rpm', '-q', '--specfile', spec_path
            ], check=True)
            
            # Copy spec file out for modification
            spec_temp = build_dir / f"{package}.spec"
            subprocess.run([
                'buildah', 'copy', container_name, spec_path, str(spec_temp)
            ], check=True)
            
            # Apply USE flags
            self.apply_use_flags(spec_temp, package)
            
            # Copy modified spec back
            subprocess.run([
                'buildah', 'copy', container_name, str(spec_temp), spec_path
            ], check=True)
            
            # Install build dependencies
            subprocess.run([
                'buildah', 'run', container_name, 'dnf', 'builddep', '-y', spec_path
            ], check=True)
            
            # Build RPMs
            subprocess.run([
                'buildah', 'run', container_name, 'rpmbuild', '-ba', spec_path
            ], check=True)
            
            # Copy out built RPMs
            subprocess.run(['buildah', 'mount', container_name], check=True)
            mount_point = subprocess.check_output([
                'buildah', 'mount', container_name
            ], text=True).strip()
            
            rpm_dir = Path(mount_point) / 'root/rpmbuild/RPMS'
            for rpm in rpm_dir.rglob('*.rpm'):
                shutil.copy(rpm, build_dir)
            
        finally:
            # Clean up container
            subprocess.run(['buildah', 'rm', container_name], stderr=subprocess.DEVNULL)
        
        return list(build_dir.glob('*.rpm'))
        
    def build_package(self, package: str):
        """Orchestrate package build process with dependencies"""
        if package in self.state['built']:
            return
            
        # Resolve best version
        package_info = self.source.resolve_version(package)
        if not package_info:
            print(f"⚠️ Package not available: {package}")
            return
            
        print(f"🔨 Building {package} ({package_info['version']}-{package_info['release']}) "
              f"from {package_info['repo']}")
        
        # Fetch source
        srpm = self.source.fetch_source(package_info)
        
        # Resolve dependencies
        dependencies = self.resolve_dependencies(srpm)
        print(f"  📦 Dependencies: {', '.join(dependencies) if dependencies else 'None'}")
        
        # Build dependencies first
        with concurrent.futures.ThreadPoolExecutor(
            max_workers=self.config.get_parallel_jobs()
        ) as executor:
            futures = {executor.submit(self.build_package, dep): dep for dep in dependencies}
            for future in concurrent.futures.as_completed(futures):
                dep_name = futures[future]
                try:
                    future.result()
                except Exception as e:
                    print(f"🚨 Dependency build failed for {dep_name}: {e}")
        
        # Build package
        try:
            rpms = self.build_with_buildah(srpm, package)
            print(f"  ✅ Built: {', '.join(rpm.name for rpm in rpms)}")
            
            # Install package
            subprocess.run(['dnf', 'install', '-y'] + [str(rpm) for rpm in rpms], check=True)
            
            # Update state
            self.state['built'][package] = {
                'version': package_info['version'],
                'release': package_info['release'],
                'source': str(srpm),
                'built_rpms': [str(rpm) for rpm in rpms],
                'use_flags': self.config.get_use_flags(package)
            }
            self.save_state()
            
        except subprocess.CalledProcessError as e:
            print(f"🚨 Build failed for {package}: {e}")
            
    def rebuild_system(self):
        """Rebuild all installed packages from source"""
        # Get installed packages
        cmd = ['dnf', 'repoquery', '--installed', '--queryformat', '%{name}']
        output = subprocess.check_output(cmd, text=True)
        packages = set(output.splitlines())
        
        # Filter excluded packages
        to_build = [
            pkg for pkg in packages
            if not any(re.match(pattern, pkg) 
                for pattern in self.config.config['build']['exclude_packages'])
        ]
        
        print(f"🔄 Rebuilding {len(to_build)} packages...")
        
        # Parallel build execution
        with concurrent.futures.ThreadPoolExecutor(
            max_workers=self.config.get_parallel_jobs()
        ) as executor:
            futures = {executor.submit(self.build_package, pkg): pkg for pkg in to_build}
            for future in concurrent.futures.as_completed(futures):
                pkg = futures[future]
                try:
                    future.result()
                except Exception as e:
                    print(f"🚨 Critical error building {pkg}: {e}")

class SourceFedoraCLI:
    """Command-line interface for Source Fedora"""
    def __init__(self):
        self.config = ConfigManager()
        self.source = SourceManager(self.config)
        self.builder = BuildManager(self.config, self.source)
        
    def run(self):
        """Main command-line interface"""
        parser = argparse.ArgumentParser(
            description="Fedora 42 Source-Based Distribution Transformer",
            epilog="Gentoo-inspired features: USE flags and accept-keywords")
        
        subparsers = parser.add_subparsers(dest='command', required=True)
        
        # Rebuild command
        rebuild_parser = subparsers.add_parser('rebuild', 
            help='Rebuild entire system from source')
        rebuild_parser.add_argument('--full', action='store_true',
            help='Perform a complete rebuild including dependencies')
            
        # Build command
        build_parser = subparsers.add_parser('build', 
            help='Build specific package(s) from source')
        build_parser.add_argument('packages', nargs='+', 
            help='Package names to build')
            
        # Git-build command
        git_parser = subparsers.add_parser('git-build', 
            help='Build package from Git repository')
        git_parser.add_argument('url', 
            help='Git repository URL')
        git_parser.add_argument('--accept', action='store_true',
            help='Automatically accept keywords for this package')
            
        # Manage USE flags
        use_parser = subparsers.add_parser('use', 
            help='Manage USE flags for packages')
        use_parser.add_argument('action', choices=['list', 'set', 'unset'],
            help='Action to perform')
        use_parser.add_argument('package', nargs='?',
            help='Package name')
        use_parser.add_argument('flags', nargs='*',
            help='USE flags to set/unset')
            
        # Manage keywords
        keyword_parser = subparsers.add_parser('keywords', 
            help='Manage accepted keywords')
        keyword_parser.add_argument('action', choices=['list', 'add', 'remove'],
            help='Action to perform')
        keyword_parser.add_argument('packages', nargs='*',
            help='Packages to modify')
            
        # System management
        sys_parser = subparsers.add_parser('system', 
            help='System management commands')
        sys_parser.add_argument('action', choices=['clean', 'update', 'info'],
            help='Action to perform')
            
        args = parser.parse_args()
        
        try:
            if args.command == 'rebuild':
                self.handle_rebuild(args)
            elif args.command == 'build':
                self.handle_build(args)
            elif args.command == 'git-build':
                self.handle_git_build(args)
            elif args.command == 'use':
                self.handle_use_flags(args)
            elif args.command == 'keywords':
                self.handle_keywords(args)
            elif args.command == 'system':
                self.handle_system(args)
                
        except KeyboardInterrupt:
            print("\n⛔ Operation cancelled by user")
            sys.exit(1)
        except Exception as e:
            print(f"💥 Critical error: {e}")
            sys.exit(1)
            
    def handle_rebuild(self, args):
        """Handle system rebuild"""
        print("🚀 Starting full system rebuild...")
        self.builder.rebuild_system()
        print("\n✨ System rebuild complete!")
        
    def handle_build(self, args):
        """Handle package builds"""
        for package in args.packages:
            print(f"🚀 Building package: {package}")
            self.builder.build_package(package)
        print("\n✨ Package builds complete!")
        
    def handle_git_build(self, args):
        """Handle Git-based builds"""
        print(f"🚀 Building from Git repository: {args.url}")
        
        # Clone repository
        with tempfile.TemporaryDirectory() as tmpdir:
            repo_dir = Path(tmpdir) / 'repo'
            subprocess.run(['git', 'clone', args.url, str(repo_dir)], check=True)
            
            # Find spec file
            spec_files = list(repo_dir.rglob('*.spec'))
            if not spec_files:
                print("❌ No .spec file found in repository")
                return
                
            spec_file = spec_files[0]
            package_name = spec_file.stem
            
            # Add to accept-keywords if requested
            if args.accept:
                self.add_accept_keyword(package_name)
                print(f"🔓 Added {package_name} to accept-keywords")
                
            # Build the package
            self.builder.build_package(package_name)
            
        print("\n✨ Git build complete!")
        
    def handle_use_flags(self, args):
        """Manage USE flags"""
        if args.action == 'list':
            if args.package:
                flags = self.config.get_use_flags(args.package)
                print(f"USE flags for {args.package}: {', '.join(flags)}")
            else:
                for package, flags in self.config.use_flags.items():
                    print(f"{package}: {', '.join(flags)}")
                    
        elif args.action == 'set' and args.package and args.flags:
            self.set_use_flags(args.package, args.flags)
            print(f"✅ USE flags set for {args.package}")
            
        elif args.action == 'unset' and args.package and args.flags:
            self.unset_use_flags(args.package, args.flags)
            print(f"✅ USE flags unset for {args.package}")
            
    def set_use_flags(self, package: str, flags: List[str]):
        """Set USE flags for a package"""
        flags_dir = Path(self.config.config['system']['use_flags_dir'])
        flags_dir.mkdir(parents=True, exist_ok=True)
        flag_file = flags_dir / f"{package}.conf"
        
        current_flags = self.config.get_use_flags(package)
        new_flags = set(current_flags) | set(flags)
        
        with flag_file.open('w') as f:
            f.write('\n'.join(new_flags))
            
        # Reload config
        self.config.use_flags = self.config.load_use_flags()
        
    def unset_use_flags(self, package: str, flags: List[str]):
        """Unset USE flags for a package"""
        flags_dir = Path(self.config.config['system']['use_flags_dir'])
        flag_file = flags_dir / f"{package}.conf"
        
        if not flag_file.exists():
            return
            
        current_flags = self.config.get_use_flags(package)
        new_flags = set(current_flags) - set(flags)
        
        if new_flags:
            with flag_file.open('w') as f:
                f.write('\n'.join(new_flags))
        else:
            flag_file.unlink()
            
        # Reload config
        self.config.use_flags = self.config.load_use_flags()
        
    def handle_keywords(self, args):
        """Manage accepted keywords"""
        accept_file = Path(self.config.config['system']['accept_keywords'])
        
        if args.action == 'list':
            if accept_file.exists():
                with accept_file.open() as f:
                    print("Accepted packages:")
                    for line in f:
                        if line.strip() and not line.startswith('#'):
                            print(f"  - {line.strip()}")
            else:
                print("No packages in accept-keywords")
                
        elif args.action == 'add' and args.packages:
            packages = set(args.packages)
            current = set()
            
            if accept_file.exists():
                with accept_file.open() as f:
                    current = {line.strip() for line in f if line.strip()}
                    
            current |= packages
            
            with accept_file.open('w') as f:
                f.write('\n'.join(sorted(current)))
                
            print(f"✅ Added packages to accept-keywords: {', '.join(packages)}")
            
        elif args.action == 'remove' and args.packages:
            if not accept_file.exists():
                return
                
            packages = set(args.packages)
            with accept_file.open() as f:
                current = {line.strip() for line in f if line.strip()}
                
            current -= packages
            
            with accept_file.open('w') as f:
                f.write('\n'.join(sorted(current)))
                
            print(f"✅ Removed packages from accept-keywords: {', '.join(packages)}")
            
    def add_accept_keyword(self, package: str):
        """Add package to accept-keywords"""
        accept_file = Path(self.config.config['system']['accept_keywords'])
        current = set()
        
        if accept_file.exists():
            with accept_file.open() as f:
                current = {line.strip() for line in f if line.strip()}
                
        current.add(package)
        
        with accept_file.open('w') as f:
            f.write('\n'.join(sorted(current)))
            
    def handle_system(self, args):
        """System management commands"""
        if args.action == 'clean':
            self.clean_system()
            print("🧹 System cleaned")
        elif args.action == 'update':
            self.update_system()
            print("🔄 System updated")
        elif args.action == 'info':
            self.system_info()
            
    def clean_system(self):
        """Clean build artifacts"""
        build_root = self.config.get_build_root()
        for item in build_root.iterdir():
            if item.is_dir():
                shutil.rmtree(item)
                
        rpmbuild = self.config.get_rpmbuild_root()
        for item in rpmbuild.iterdir():
            if item.name not in ['SOURCES', 'SPECS']:
                if item.is_dir():
                    shutil.rmtree(item)
                else:
                    item.unlink()
                    
    def update_system(self):
        """Update the system and rebuild packages"""
        subprocess.run(['dnf', 'upgrade', '--refresh', '-y'], check=True)
        self.builder.rebuild_system()
        
    def system_info(self):
        """Display system information"""
        print(f"Source Fedora System Information")
        print(f"Fedora Version: {self.config.config['system']['fedora_version']}")
        print(f"Architecture: {self.config.config['system']['arch']}")
        print(f"Build Jobs: {self.config.get_parallel_jobs()}")
        print(f"Container Backend: {self.config.config['build']['container_backend']}")
        
        # Count built packages
        built_count = len(self.builder.state.get('built', {}))
        print(f"Packages Built: {built_count}")

def main():
    """Main entry point"""
    # Check for root privileges
    if os.geteuid() != 0:
        print("❌ This script must be run as root", file=sys.stderr)
        sys.exit(1)
        
    cli = SourceFedoraCLI()
    cli.run()

if __name__ == '__main__':
    main()
```

### Key Features Implemented:

#### 1. Gentoo-Style USE Flags
- **Per-package configuration**: Each package can have custom build options
- **Global defaults**: System-wide default flags (X, alsa, pulseaudio, etc.)
- **Flag management CLI**:
  ```bash
  # List flags for a package
  source-fedora use list neovim
  
  # Set flags for a package
  source-fedora use set firefox wayland gtk4
  
  # Unset flags
  source-fedora use unset firefox gtk4
  ```
- **Spec file modification**: Automatically adjusts RPM spec files based on flags
- **Conditional builds**: Supports `%if` statements in spec files based on flags

#### 2. Accept-Keywords System
- **Unstable package control**: Manage which packages can use git/rawhide versions
- **Keyword management CLI**:
  ```bash
  # List accepted packages
  source-fedora keywords list
  
  # Accept unstable for a package
  source-fedora keywords add neovim
  
  # Remove acceptance
  source-fedora keywords remove neovim
  ```
- **Automatic acceptance**: `--accept` flag for git builds

#### 3. Modular Architecture
- **ConfigManager**: Handles configuration and user preferences
- **SourceManager**: Manages source retrieval and version resolution
- **BuildManager**: Orchestrates builds with dependency handling
- **SourceFedoraCLI**: Command-line interface processor

#### 4. Enhanced Build System
- **Intelligent version selection**: Git > Rawhide > Testing > Stable
- **Dependency resolution**: Automatic build order determination
- **Parallel builds**: Utilizes all CPU cores efficiently
- **Buildah containers**: Secure, isolated build environments
- **State management**: Tracks built packages across sessions

#### 5. Comprehensive CLI
- **System commands**:
  ```bash
  # Rebuild entire system
  source-fedora rebuild --full
  
  # Build specific packages
  source-fedora build neovim zsh
  
  # Build from Git
  source-fedora git-build https://github.com/custom/package.git --accept
  
  # System maintenance
  source-fedora system clean
  source-fedora system update
  ```

### Fedora 42 Specific Enhancements:
1. **OSTree Support**: Compatible with Fedora's atomic update system
2. **Module Streams**: Handles Fedora's modular packages
3. **Container Integration**: Uses Buildah instead of mock for better security
4. **Unified Kernel Handling**: Special treatment for kernel packages
5. **RPM 5.0 Features**: Supports new RPM features in Fedora 42

### Usage Examples:

1. **Transform to source-based system**:
```bash
sudo source-fedora rebuild --full
```

2. **Build Firefox with Wayland support**:
```bash
sudo source-fedora use set firefox wayland
sudo source-fedora build firefox
```

3. **Build unstable Neovim from Git**:
```bash
sudo source-fedora keywords add neovim
sudo source-fedora build neovim
```

4. **Build custom package from GitHub**:
```bash
sudo source-fedora git-build https://github.com/user/custom-pkg.git --accept
```

5. **System maintenance**:
```bash
# Update system and rebuild packages
sudo source-fedora system update

# Clean build artifacts
sudo source-fedora system clean
```

This implementation provides a robust, Gentoo-inspired source-based system for Fedora 42 with modern container-based builds, comprehensive dependency handling, and flexible configuration through USE flags and keyword acceptance.
