#!/bin/bash

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." >&2
  exit 1
fi

# Install required build tools
dnf install -y \
  rpm-build \
  python3-devel \
  python3-setuptools \
  gcc \
  redhat-rpm-config \
  make

# Create temporary build directory
BUILD_DIR=$(mktemp -d -p /tmp python-rpm-build.XXXXXXXXXX)
function cleanup {
  rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

cd "$BUILD_DIR"

# Process each package argument
for pkg in "$@"; do
  # Create package build structure
  PKG_BUILD_DIR="$BUILD_DIR/$pkg"
  mkdir -p "$PKG_BUILD_DIR"
  cd "$PKG_BUILD_DIR"

  echo "==============================================="
  echo "Building package: $pkg"
  echo "==============================================="

  # Download package source
  pip3 download --no-binary :all: --no-deps "$pkg"
  if [ $? -ne 0 ]; then
    echo "Error downloading $pkg source" >&2
    continue
  fi

  # Extract source
  SOURCE_TAR=$(ls "$pkg"*.tar.gz)
  tar xzf "$SOURCE_TAR"
  cd "$(basename "$SOURCE_TAR" .tar.gz)"

  # Build RPM
  python3 setup.py bdist_rpm \
    --release 1.fc$(rpm -E %fedora) \
    --requires "$(rpm -qa python3-devel --queryformat '%{REQUIRES}' | tr '\n' ',')" \
    --spec-only

  # Find generated spec file
  SPEC_FILE=$(find . -name '*.spec' -print -quit)
  if [ -z "$SPEC_FILE" ]; then
    echo "Spec file not generated for $pkg" >&2
    continue
  fi

  # Install build dependencies
  dnf builddep -y "$SPEC_FILE"

  # Build binary package
  rpmbuild -bb "$SPEC_FILE" \
    --define "_topdir $PKG_BUILD_DIR/rpmbuild" \
    --define "_sourcedir $(pwd)" \
    --define "_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm"

  # Find and install built RPM
  RPM_FILE=$(find "$PKG_BUILD_DIR/rpmbuild/RPMS" -name '*.rpm' -print -quit)
  if [ -z "$RPM_FILE" ]; then
    echo "RPM not built for $pkg" >&2
    continue
  fi

  dnf install -y "$RPM_FILE"
  echo "Successfully installed $pkg"
done

echo "Build directory: $BUILD_DIR"
