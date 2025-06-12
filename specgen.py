#!/usr/bin/env python3
"""
specgen.py

Clone a Python package repository, extract metadata,
and render an RPM .spec file via a Jinja2 template.

Dependencies (Fedora):
  sudo dnf install -y \
    python3 python3-toml python3-requests python3-jinja2 git rpm-build

Features:
- Fetch Name, Version, Release, License, URL
- Determine Source URL (sdist or git archive)
- Infer BuildRequires and Requires
- Output a complete .spec file

Usage:
  python3 specgen.py https://github.com/psf/requests.git -o requests.spec
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile

import requests
import toml
from jinja2 import Environment, FileSystemLoader

# --- Git operations --- #


def clone_repo(git_url, dest):
    """Clone the repository shallowly."""
    subprocess.check_call(["git", "clone", "--depth", "1", git_url, dest])


def cleanup(path):
    """Remove the temporary directory."""
    shutil.rmtree(path, ignore_errors=True)


# --- Metadata extraction --- #


def parse_pyproject(pyproject_path):
    data = toml.load(pyproject_path)
    # PEP 621 or Poetry sections
    project = data.get("project") or data.get("tool", {}).get("poetry", {})
    name = project.get("name")
    version = project.get("version")
    license = None
    if isinstance(project.get("license"), dict):
        license = project["license"].get("text")
    else:
        license = project.get("license")
    url = (
        project.get("urls", {}).get("Homepage")
        or project.get("homepage")
        or project.get("repository")
    )
    dependencies = project.get("dependencies", {})
    return name, version, license, url, dependencies


def parse_setup_py(repo_path):
    # Fallback: generate egg-info and read PKG-INFO
    subprocess.check_call([sys.executable, "setup.py", "egg_info"], cwd=repo_path)
    # Find the .egg-info directory
    egg_info_dirs = [d for d in os.listdir(repo_path) if d.endswith(".egg-info")]
    if not egg_info_dirs:
        raise RuntimeError("egg-info directory not found")
    info_dir = os.path.join(repo_path, egg_info_dirs[0])
    info_file = os.path.join(info_dir, "PKG-INFO")
    meta = {}
    with open(info_file) as f:
        for line in f:
            if ": " in line:
                k, v = line.split(": ", 1)
                meta.setdefault(k, v.strip())
    name = meta.get("Name")
    version = meta.get("Version")
    license = meta.get("License")
    url = meta.get("Home-page")
    dependencies = {}
    return name, version, license, url, dependencies


def get_sdist_url(name, version):
    """Query PyPI JSON API for the sdist URL."""
    api_url = f"https://pypi.org/pypi/{name}/{version}/json"
    resp = requests.get(api_url)
    resp.raise_for_status()
    for file in resp.json().get("urls", []):
        if file.get("packagetype") == "sdist":
            return file.get("url")
    return None


# --- Spec file generation --- #


def generate_spec(context, template_dir, out_path):
    env = Environment(
        loader=FileSystemLoader(template_dir),
        trim_blocks=True,
        lstrip_blocks=True,
    )
    template = env.get_template("python-package.spec.jinja2")
    spec_content = template.render(**context)
    with open(out_path, "w") as f:
        f.write(spec_content)
    print(f"[+] Spec file written to {out_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate an RPM .spec from a Python repository"
    )
    parser.add_argument("git_url", help="Git URL of the Python package")
    parser.add_argument(
        "--template",
        default="templates",
        help="Directory containing the Jinja2 spec template",
    )
    parser.add_argument(
        "-o", "--output", default="package.spec", help="Output .spec filename"
    )
    args = parser.parse_args()

    tempdir = tempfile.mkdtemp(prefix="specgen_")
    try:
        print("[+] Cloning repository...")
        clone_repo(args.git_url, tempdir)

        # Metadata extraction
        pyproj = os.path.join(tempdir, "pyproject.toml")
        if os.path.exists(pyproj):
            name, version, license, url, deps = parse_pyproject(pyproj)
        else:
            name, version, license, url, deps = parse_setup_py(tempdir)

        if not name or not version:
            sys.exit("Error: Could not extract package name or version.")

        print(f"[+] Package: {name}  Version: {version}")

        # Release field
        release = "1%{?dist}"

        # Source URL: prefer PyPI sdist
        sdist_url = get_sdist_url(name, version)
        source_url = (
            sdist_url or f"{args.git_url.rstrip('.git')}/archive/v{version}.tar.gz"
        )

        # BuildRequires: base Python build tools
        build_requires = [
            "python3-devel",
            "python3-setuptools",
            "python3-pip",
        ]

        # Requires: map project dependencies
        requires = []
        for dep in deps:
            pkg = dep.lower().replace("_", "-")
            requires.append(f"python3-{pkg}")

        context = {
            "name": name,
            "version": version,
            "release": release,
            "summary": f"Python package {name}",
            "license": license or "BSD",
            "url": url or args.git_url,
            "source_url": source_url,
            "build_requires": build_requires,
            "requires": requires,
            "changelog": [],
        }

        generate_spec(context, args.template, args.output)

    finally:
        cleanup(tempdir)


if __name__ == "__main__":
    main()
