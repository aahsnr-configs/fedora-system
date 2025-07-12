# Comprehensive Containerization Setup Guide for Fedora Linux 42

## Overview

Fedora Linux 42 offers excellent containerization support with two primary options: **Podman** (recommended) and **Docker**. This guide covers both approaches, with Podman being the preferred solution due to its daemonless architecture, enhanced security, and seamless integration with Red Hat-based systems.

## Option 1: Podman Setup (Recommended)

### Why Choose Podman?

- **Daemonless Architecture**: No background daemon required
- **Enhanced Security**: Runs containers as non-root by default
- **Drop-in Docker Replacement**: Compatible with most Docker commands
- **Native Integration**: Pre-installed on Fedora and well-integrated with systemd
- **Pods Support**: Kubernetes-like pod management capabilities

### 1. Installing Podman

Podman is typically pre-installed on Fedora 42. If not present, install it:

```bash
# Update system first
sudo dnf update -y

# Install Podman and related tools
sudo dnf install podman podman-compose podman-docker -y

# Install additional useful tools
sudo dnf install buildah skopeo podman-tui -y
```

### 2. Verifying Installation

```bash
# Check Podman version
podman --version

# Test basic functionality
podman run hello-world

# Check system information
podman info
```

### 3. Basic Configuration

#### Enable Podman Socket (Optional)
For Docker compatibility APIs:

```bash
# Enable user socket
systemctl --user enable podman.socket
systemctl --user start podman.socket

# Enable system socket (if needed)
sudo systemctl enable podman.socket
sudo systemctl start podman.socket
```

#### Configure Registries
Edit `/etc/containers/registries.conf` to configure container registries:

```bash
sudo nano /etc/containers/registries.conf
```

Add or verify these registries:
```toml
[registries.search]
registries = ['registry.fedoraproject.org', 'registry.access.redhat.com', 'docker.io', 'quay.io']

[registries.insecure]
registries = []

[registries.block]
registries = []
```

### 4. Setting Up Rootless Containers

#### Configure User Namespaces
```bash
# Check current user namespace configuration
cat /etc/subuid
cat /etc/subgid

# If your user is missing, add entries (replace 'username' with your actual username)
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 username
```

#### Configure Storage
```bash
# Create user-specific storage configuration
mkdir -p ~/.config/containers
```

Create `~/.config/containers/storage.conf`:
```toml
[storage]
driver = "overlay"
runroot = "/run/user/1000/containers"
graphroot = "/home/username/.local/share/containers/storage"

[storage.options]
additionalimagestores = [
  "/var/lib/containers/storage",
]

[storage.options.overlay]
mountopt = "nodev,metacopy=on"
```

### 5. Docker Compatibility

Create Docker alias for seamless transition:

```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'alias docker=podman' >> ~/.bashrc
source ~/.bashrc

# Or install podman-docker package (already included above)
# This provides docker command that redirects to podman
```

### 6. Advanced Podman Features

#### Working with Pods
```bash
# Create a pod
podman pod create --name mypod -p 8080:80

# Run containers in the pod
podman run -d --pod mypod --name web-server nginx
podman run -d --pod mypod --name app-server node:alpine

# List pods
podman pod list

# Stop/start pods
podman pod stop mypod
podman pod start mypod
```

#### Systemd Integration
```bash
# Generate systemd service files
podman generate systemd --name container-name --files --new

# Enable container to start at boot
systemctl --user enable container-name.service
```

## Option 2: Docker Setup (Alternative)

### 1. Installing Docker

#### Remove Conflicting Packages
```bash
sudo dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
```

#### Add Docker Repository
```bash
# Install dnf-plugins-core
sudo dnf install dnf-plugins-core -y

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
```

#### Install Docker
```bash
# Install Docker CE
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

### 2. Configure Docker

#### Start and Enable Docker Service
```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start at boot
sudo systemctl enable docker

# Verify Docker is running
sudo systemctl status docker
```

#### Add User to Docker Group
```bash
# Add current user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, or use newgrp
newgrp docker

# Test Docker without sudo
docker run hello-world
```

### 3. Docker Compose Installation

Docker Compose is included with the Docker installation above as a plugin. Verify:

```bash
# Check Docker Compose version
docker compose version
```

## Container Management Tools

### 1. Podman Desktop (GUI)

#### Install via Flatpak
```bash
# Install Flatpak (if not already installed)
sudo dnf install flatpak -y

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Podman Desktop
flatpak install flathub io.podman_desktop.PodmanDesktop
```

#### Install via Package Download
```bash
# Download from podman-desktop.io
wget https://github.com/containers/podman-desktop/releases/latest/download/podman-desktop-*.x86_64.rpm

# Install the package
sudo dnf install podman-desktop-*.x86_64.rpm
```

### 2. Podman TUI (Terminal UI)

```bash
# Install podman-tui (already included in earlier installation)
sudo dnf install podman-tui -y

# Launch TUI
podman-tui
```

### 3. Buildah for Image Building

```bash
# Install Buildah (already included in earlier installation)
sudo dnf install buildah -y

# Basic usage
buildah from fedora:latest
buildah run fedora-working-container dnf install -y httpd
buildah commit fedora-working-container my-httpd-image
```

## Toolbox Integration

Fedora includes Toolbox for containerized development environments:

```bash
# Install Toolbox
sudo dnf install toolbox -y

# Create a development environment
toolbox create --distro fedora --release 42 dev-env

# Enter the toolbox
toolbox enter dev-env

# Install development tools inside toolbox
sudo dnf install gcc make git vim -y
```

## Best Practices and Security

### 1. Security Configuration

#### SELinux Configuration
```bash
# Check SELinux status
getenforce

# Install SELinux policy for containers
sudo dnf install container-selinux -y

# Set SELinux booleans for containers
sudo setsebool -P container_manage_cgroup on
```

#### Firewall Configuration
```bash
# Allow container networks through firewall
sudo firewall-cmd --permanent --zone=trusted --add-interface=podman0
sudo firewall-cmd --reload

# For specific ports
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

### 2. Resource Management

#### Configure cgroups v2
```bash
# Check cgroups version
cat /proc/filesystems | grep cgroup

# Enable cgroups v2 delegation for rootless containers
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo tee /etc/systemd/system/user@.service.d/delegate.conf << EOF
[Service]
Delegate=cpu cpuset io memory pids
EOF

sudo systemctl daemon-reload
```

### 3. Storage Configuration

#### Configure Storage Drivers
```bash
# Check current storage driver
podman info | grep -A 5 "Storage Driver"

# For performance tuning, edit storage configuration
sudo nano /etc/containers/storage.conf
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Permission Issues
```bash
# Reset user namespace configuration
podman system reset

# Recreate user namespace mappings
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
```

#### 2. Network Issues
```bash
# Reset network configuration
podman system reset --force

# Restart network services
sudo systemctl restart NetworkManager
```

#### 3. Storage Issues
```bash
# Check storage usage
podman system df

# Clean up unused resources
podman system prune -a

# Reset storage if needed
podman system reset
```

#### 4. Docker Installation Issues
If Docker repository isn't available for Fedora 42:
```bash
# Use Fedora 41 repository temporarily
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo sed -i 's/\$releasever/41/g' /etc/yum.repos.d/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io -y
```

## Performance Optimization

### 1. Image Optimization
```bash
# Use multi-stage builds in Containerfile/Dockerfile
# Use minimal base images (alpine, distroless)
# Clean package caches in images
```

### 2. Resource Limits
```bash
# Set memory limits
podman run -m 512m nginx

# Set CPU limits
podman run --cpus=1.5 nginx

# Set resource limits in systemd services
```

### 3. Storage Optimization
```bash
# Use overlay storage driver
# Configure storage on fast storage (SSD)
# Regular cleanup of unused images and containers
```

## Useful Commands Reference

### Podman Commands
```bash
# Container management
podman run -d --name myapp nginx
podman ps -a
podman stop myapp
podman start myapp
podman rm myapp

# Image management
podman images
podman pull fedora:latest
podman rmi image-name

# Pod management
podman pod create --name mypod
podman pod start/stop/rm mypod

# System management
podman system info
podman system prune
podman system reset
```

### Docker Commands
```bash
# Container management
docker run -d --name myapp nginx
docker ps -a
docker stop myapp
docker start myapp
docker rm myapp

# Image management
docker images
docker pull ubuntu:latest
docker rmi image-name

# System management
docker system info
docker system prune
```

## Conclusion

Fedora Linux 42 provides excellent containerization capabilities with both Podman and Docker. **Podman is the recommended choice** due to its security advantages, daemonless architecture, and native integration with Fedora systems. This guide provides a complete setup for both options, ensuring you can leverage containerization technology effectively and securely.

For most users, starting with Podman provides the best experience while maintaining compatibility with Docker workflows. The rootless container capabilities and systemd integration make it particularly well-suited for development and production environments on Fedora systems.
