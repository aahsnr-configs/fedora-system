#!/usr/bin/env python3

import os
import shutil
import subprocess
import sys
import tempfile


def run(cmd, cwd=None, check=True):
    print(f"> {' '.join(cmd)}")
    subprocess.run(cmd, cwd=cwd, check=check)


def install_build_deps():
    try:
        run(["sudo", "dnf", "-y", "group", "install", "development-tools"])
        run(
            [
                "sudo",
                "dnf",
                "-y",
                "install",
                "gcc",
                "make",
                "autoconf",
                "automake",
                "cmake",
                "git",
            ]
        )
    except subprocess.CalledProcessError:
        print("Failed to install required development tools.")
        sys.exit(1)


def clone_or_download(src_url, temp_dir):
    print(f"Cloning source from {src_url}...")
    if src_url.endswith(".git"):
        run(["git", "clone", src_url, temp_dir])
    else:
        archive_path = os.path.join(temp_dir, "src.tar.gz")
        run(["curl", "-L", "-o", archive_path, src_url])
        run(["tar", "xf", archive_path, "-C", temp_dir])
    print("Source downloaded.")


def detect_and_build(src_dir):
    print("Detecting build system...")
    if os.path.exists(os.path.join(src_dir, "configure")):
        run(["./configure"], cwd=src_dir)
        run(["make"], cwd=src_dir)
        run(["sudo", "make", "install"], cwd=src_dir)
    elif os.path.exists(os.path.join(src_dir, "CMakeLists.txt")):
        build_dir = os.path.join(src_dir, "build")
        os.makedirs(build_dir, exist_ok=True)
        run(["cmake", ".."], cwd=build_dir)
        run(["make"], cwd=build_dir)
        run(["sudo", "make", "install"], cwd=build_dir)
    elif os.path.exists(os.path.join(src_dir, "Makefile")):
        run(["make"], cwd=src_dir)
        run(["sudo", "make", "install"], cwd=src_dir)
    else:
        print("Unsupported or undetected build system.")
        sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 fedora_src_installer.py <source_git_or_tar_url>")
        sys.exit(1)

    src_url = sys.argv[1]
    temp_root = tempfile.mkdtemp(prefix="srcbuild-")

    try:
        install_build_deps()
        source_dir = os.path.join(temp_root, "src")
        clone_or_download(src_url, source_dir)
        # If extracted tarball creates a subdir
        if not os.path.exists(os.path.join(source_dir, "Makefile")):
            entries = os.listdir(source_dir)
            if len(entries) == 1 and os.path.isdir(
                os.path.join(source_dir, entries[0])
            ):
                source_dir = os.path.join(source_dir, entries[0])
        detect_and_build(source_dir)
    finally:
        print(f"Cleaning up {temp_root}")
        shutil.rmtree(temp_root)


if __name__ == "__main__":
    main()
