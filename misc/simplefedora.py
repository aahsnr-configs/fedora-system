#!/usr/bin/env python3
"""
SimpleFedoraBuilder: A tool to build Fedora packages from source with Gentoo-like USE flags and make.conf support.
Version 1.1.0
"""

import os
import subprocess
import sys
from argparse import ArgumentParser
from pathlib import Path

# === Configuration ===
CONFIG = {
    "make_conf": "/etc/simplefedora/make.conf",
    "use_flags_dir": "/etc/simplefedora/use_flags.d",
    "build_root": "/var/lib/simplefedora/builds",
    "state_file": "/var/lib/simplefedora/state.json",
}


def load_make_conf() -> dict:
    """Load key=value pairs from make.conf."""
    conf = {}
    path = Path(CONFIG["make_conf"])
    if path.exists():
        for line in path.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, val = line.split("=", 1)
            conf[key.strip()] = val.strip().strip('"')
    return conf


def get_use_flags(pkg: str) -> list:
    """Retrieve USE flags for a package from use_flags_dir."""
    use_dir = Path(CONFIG["use_flags_dir"])
    flags_file = use_dir / f"{pkg}.conf"
    if flags_file.exists():
        return [f.strip() for f in flags_file.read_text().split() if f.strip()]
    return []


def run(cmd: list, **kwargs) -> subprocess.CompletedProcess:
    """Run a subprocess command and return CompletedProcess."""
    try:
        result = subprocess.run(cmd, check=True, text=True, **kwargs)
        return result
    except subprocess.CalledProcessError as e:
        print(
            f"Error: command '{' '.join(e.cmd)}' returned non-zero exit status {e.returncode}."
        )
        if e.stderr:
            print("stderr:", e.stderr)
        sys.exit(e.returncode)


def setup_rpmbuild_tree(root: Path):
    """Create rpmbuild tree under root directory."""
    for sub in ["BUILD", "RPMS", "SOURCES", "SPECS", "SRPMS"]:
        (root / sub).mkdir(parents=True, exist_ok=True)


def build_package(pkg: str):
    """Download SRPM, apply USE flags and make.conf, then build via rpmbuild."""
    build_dir = Path(CONFIG["build_root"]) / pkg
    setup_rpmbuild_tree(build_dir)

    # Load configurations
    make_conf = load_make_conf()
    use_flags = get_use_flags(pkg)

    print(f"\n==> Building {pkg} with USE flags: {use_flags}")
    # 1. Download SRPM
    run(["dnf", "download", "--source", "--destdir", str(build_dir / "SRPMS"), pkg])
    srpms = list((build_dir / "SRPMS").glob("*.src.rpm"))
    if not srpms:
        print("Failed to download SRPM.")
        sys.exit(1)
    srpm = srpms[0]

    # 2. Install SRPM into our tree
    run(["rpm", "--define", f"_topdir {str(build_dir)}", "-ivh", str(srpm)])

    spec_file = build_dir / "SPECS" / f"{pkg}.spec"
    if not spec_file.exists():
        specs = list((build_dir / "SPECS").glob("*.spec"))
        if specs:
            spec_file = specs[0]
        else:
            print("No spec file found in rpmbuild tree.")
            sys.exit(1)

    # 3. Inject USE flags into spec
    if use_flags:
        lines = spec_file.read_text().splitlines()
        for flag in use_flags:
            define = f"%global with_{flag} 1"
            if define not in lines:
                lines.insert(0, define)
        spec_file.write_text("\n".join(lines))

    # 4. Prepare environment
    env = os.environ.copy()
    for k, v in make_conf.items():
        env[k] = v

    # 5. Build
    print(f"Running rpmbuild -ba {spec_file}")
    run(
        ["rpmbuild", "--define", f"_topdir {str(build_dir)}", "-ba", str(spec_file)],
        env=env,
    )

    print(f"<== Built {pkg}. RPMs located in {build_dir}/RPMS/")


def main():
    parser = ArgumentParser(
        description="SimpleFedoraBuilder: Build Fedora packages from source with Gentoo-like controls."
    )
    parser.add_argument("package", help="Name of the package to build")
    args = parser.parse_args()

    if os.geteuid() != 0:
        print("Must run as root.")
        sys.exit(1)

    # Ensure directories exist
    Path(CONFIG["use_flags_dir"]).mkdir(parents=True, exist_ok=True)
    Path(CONFIG["build_root"]).mkdir(parents=True, exist_ok=True)

    build_package(args.package)


if __name__ == "__main__":
    main()
