# Comprehensive Distrobox Theming, Scaling & SELinux Guide for Fedora 42

This guide covers applying GTK/Qt theming, application scaling, and SELinux policies for applications installed using Distrobox with an Arch Linux-based image on Fedora 42.

## Table of Contents
1. [Initial Setup](#initial-setup)
2. [GTK Theming](#gtk-theming)
3. [Qt Theming](#qt-theming)
4. [Application Scaling](#application-scaling)
5. [SELinux Policies](#selinux-policies)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

## Initial Setup

### Prerequisites
```bash
# Install distrobox and podman (if not already installed)
sudo dnf install distrobox podman

# Create Arch Linux distrobox container
distrobox create --name arch-desktop --image archlinux:latest
distrobox enter arch-desktop
```

### Initial Container Configuration
Inside the Arch container, install essential packages:
```bash
# Update system
pacman -Syu

# Install display server and theming tools
pacman -S xorg-xauth xorg-server-xephyr wayland
pacman -S gtk3 gtk4 qt5-base qt6-base
pacman -S qt5ct qt6ct lxappearance
pacman -S adwaita-icon-theme papirus-icon-theme
pacman -S ttf-liberation ttf-dejavu noto-fonts
```

## GTK Theming

### Method 1: Using Host Theme Configuration

Create a script to sync host GTK settings:

```bash
# Create theme sync script
cat > ~/.local/bin/sync-gtk-theme.sh << 'EOF'
#!/bin/bash

# Get host GTK settings
HOST_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
HOST_ICON_THEME=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
HOST_FONT=$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null | tr -d "'")
HOST_CURSOR_THEME=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'")

# Apply to container
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "$HOST_THEME"
    gsettings set org.gnome.desktop.interface icon-theme "$HOST_ICON_THEME"
    gsettings set org.gnome.desktop.interface font-name "$HOST_FONT"
    gsettings set org.gnome.desktop.interface cursor-theme "$HOST_CURSOR_THEME"
fi

# Create GTK config files
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

# GTK3 settings
cat > ~/.config/gtk-3.0/settings.ini << EOL
[Settings]
gtk-theme-name=$HOST_THEME
gtk-icon-theme-name=$HOST_ICON_THEME
gtk-font-name=$HOST_FONT
gtk-cursor-theme-name=$HOST_CURSOR_THEME
EOL

# GTK4 settings
cat > ~/.config/gtk-4.0/settings.ini << EOL
[Settings]
gtk-theme-name=$HOST_THEME
gtk-icon-theme-name=$HOST_ICON_THEME
gtk-font-name=$HOST_FONT
gtk-cursor-theme-name=$HOST_CURSOR_THEME
EOL
EOF

chmod +x ~/.local/bin/sync-gtk-theme.sh
```

### Method 2: Manual Configuration

```bash
# Install lxappearance for GUI theme selection
pacman -S lxappearance

# Create GTK configuration directories
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

# Set GTK3 theme manually
cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Cantarell 11
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF

# Set GTK4 theme
cat > ~/.config/gtk-4.0/settings.ini << EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Cantarell 11
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF
```

## Qt Theming

### Qt5 Configuration

Install and configure Qt5ct:
```bash
# Install Qt5 configuration tool
pacman -S qt5ct

# Set Qt5 platform theme
echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> ~/.bashrc
echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> ~/.zshrc

# Create Qt5ct config directory
mkdir -p ~/.config/qt5ct

# Basic Qt5ct configuration
cat > ~/.config/qt5ct/qt5ct.conf << 'EOF'
[Appearance]
color_scheme_path=/usr/share/qt5ct/colors/airy.conf
custom_palette=false
icon_theme=Adwaita
standard_dialogs=default
style=Adwaita-Dark

[Fonts]
fixed=@Variant(\0\0\0@\0\0\0\x12\0M\0o\0n\0o\0s\0p\0\x61\0\x63\0\x65@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
general=@Variant(\0\0\0@\0\0\0\x16\0\x43\0\x61\0n\0t\0\x61\0r\0\x65\0l\0l@\"\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[SettingsWindow]
geometry=@ByteArray()
EOF
```

### Qt6 Configuration

```bash
# Install Qt6 configuration tool
pacman -S qt6ct

# Set Qt6 platform theme
echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> ~/.bashrc
echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> ~/.zshrc

# Create Qt6ct config
mkdir -p ~/.config/qt6ct

# Copy Qt5 config as base for Qt6
cp ~/.config/qt5ct/qt5ct.conf ~/.config/qt6ct/qt6ct.conf
```

### Unified Qt/GTK Theme Script

Create a unified theming script:

```bash
cat > ~/.local/bin/apply-unified-theme.sh << 'EOF'
#!/bin/bash

THEME_NAME="Adwaita-dark"
ICON_THEME="Adwaita"
FONT_NAME="Cantarell 11"
CURSOR_THEME="Adwaita"

# GTK Settings
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface font-name "$FONT_NAME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"

# Qt Settings via environment
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=Adwaita-Dark

# Apply theme synchronization
~/.local/bin/sync-gtk-theme.sh

echo "Unified theme applied successfully!"
EOF

chmod +x ~/.local/bin/apply-unified-theme.sh
```

## Application Scaling

### Environment Variables for Scaling

Create a scaling configuration script:

```bash
cat > ~/.local/bin/setup-scaling.sh << 'EOF'
#!/bin/bash

# Detect host scaling settings
HOST_SCALE_FACTOR=$(gsettings get org.gnome.desktop.interface scaling-factor 2>/dev/null || echo 1)
HOST_TEXT_SCALE=$(gsettings get org.gnome.desktop.interface text-scaling-factor 2>/dev/null || echo 1.0)

# Convert to usable values
if [ "$HOST_SCALE_FACTOR" = "uint32 0" ]; then
    # Auto-detection or no scaling
    SCALE_FACTOR=1
else
    SCALE_FACTOR=$HOST_SCALE_FACTOR
fi

# GTK Scaling
export GDK_SCALE=$SCALE_FACTOR
export GDK_DPI_SCALE=$HOST_TEXT_SCALE

# Qt Scaling
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=$SCALE_FACTOR
export QT_FONT_DPI=96

# X11 Scaling (for legacy apps)
export XSETTINGS_DPI=$((96 * SCALE_FACTOR))

# Write to environment files
echo "export GDK_SCALE=$SCALE_FACTOR" >> ~/.bashrc
echo "export GDK_DPI_SCALE=$HOST_TEXT_SCALE" >> ~/.bashrc
echo "export QT_AUTO_SCREEN_SCALE_FACTOR=0" >> ~/.bashrc
echo "export QT_SCALE_FACTOR=$SCALE_FACTOR" >> ~/.bashrc
echo "export QT_FONT_DPI=96" >> ~/.bashrc

echo "Scaling configured for factor: $SCALE_FACTOR"
EOF

chmod +x ~/.local/bin/setup-scaling.sh
```

### HiDPI Configuration

For high-DPI displays, create additional configuration:

```bash
# Create HiDPI settings
cat > ~/.local/bin/hidpi-setup.sh << 'EOF'
#!/bin/bash

# Detect display DPI
DISPLAY_DPI=$(xdpyinfo | grep dots | awk '{print $2}' | cut -d x -f 1 2>/dev/null || echo 96)

if [ "$DISPLAY_DPI" -gt 144 ]; then
    # High DPI detected
    SCALE=2
    echo "High DPI detected ($DISPLAY_DPI), setting scale to 2"
elif [ "$DISPLAY_DPI" -gt 120 ]; then
    # Medium DPI
    SCALE=1.5
    echo "Medium DPI detected ($DISPLAY_DPI), setting scale to 1.5"
else
    # Standard DPI
    SCALE=1
    echo "Standard DPI detected ($DISPLAY_DPI), setting scale to 1"
fi

# Apply scaling
export GDK_SCALE=$SCALE
export QT_SCALE_FACTOR=$SCALE

# Update Xresources for legacy apps
echo "Xft.dpi: $((96 * SCALE))" >> ~/.Xresources
xrdb -merge ~/.Xresources 2>/dev/null || true
EOF

chmod +x ~/.local/bin/hidpi-setup.sh
```

## SELinux Policies

### Understanding Distrobox SELinux Context

Distrobox containers run with specific SELinux contexts. Here's how to create and apply custom policies:

### 1. Install SELinux Development Tools

On the Fedora 42 host:
```bash
sudo dnf install policycoreutils-python-utils selinux-policy-devel udica
```

### 2. Generate Container-Specific Policies with Udica

```bash
# Create a policy for your Arch distrobox
# First, get the container ID
CONTAINER_ID=$(podman ps -a --format "{{.ID}} {{.Names}}" | grep arch-desktop | cut -d' ' -f1)

# Generate SELinux policy using udica
sudo udica -j $CONTAINER_ID distrobox_arch_policy

# This creates distrobox_arch_policy.cil file
```

### 3. Custom SELinux Policy Template

Create a custom policy for enhanced Distrobox functionality:

```bash
cat > distrobox_enhanced.te << 'EOF'
module distrobox_enhanced 1.0;

require {
    type container_t;
    type user_home_t;
    type user_home_dir_t;
    type tmp_t;
    type devpts_t;
    type proc_t;
    type sysfs_t;
    type device_t;
    class dir { create read write add_name remove_name };
    class file { create read write execute open getattr setattr };
    class chr_file { read write };
    class sock_file write;
}

# Allow container to access user home directory
allow container_t user_home_t:dir { create read write add_name remove_name };
allow container_t user_home_t:file { create read write execute open getattr setattr };

# Allow access to temporary files
allow container_t tmp_t:dir { read write add_name remove_name };
allow container_t tmp_t:file { create read write execute open };

# Allow access to devices needed for GUI
allow container_t devpts_t:chr_file { read write };
allow container_t device_t:chr_file { read write };

# Allow access to proc and sys filesystems
allow container_t proc_t:file { read open };
allow container_t sysfs_t:file { read open };
EOF
```

### 4. Compile and Install Custom Policy

```bash
# Compile the policy
make -f /usr/share/selinux/devel/Makefile distrobox_enhanced.pp

# Install the policy
sudo semodule -i distrobox_enhanced.pp

# Verify installation
sudo semodule -l | grep distrobox
```

### 5. Apply SELinux Labels for Distrobox

Create a script to set proper SELinux contexts:

```bash
cat > ~/.local/bin/selinux-distrobox-setup.sh << 'EOF'
#!/bin/bash

# Set SELinux contexts for Distrobox directories
sudo setsebool -P container_use_cephfs=1
sudo setsebool -P virt_use_fusefs=1
sudo setsebool -P virt_use_nfs=1

# Label container storage
sudo semanage fcontext -a -t container_file_t "$HOME/.local/share/containers(/.*)?"
sudo restorecon -R "$HOME/.local/share/containers" 2>/dev/null || true

# Label distrobox directories
sudo semanage fcontext -a -t container_file_t "$HOME/.local/share/distrobox(/.*)?"
sudo restorecon -R "$HOME/.local/share/distrobox" 2>/dev/null || true

echo "SELinux contexts configured for Distrobox"
EOF

chmod +x ~/.local/bin/selinux-distrobox-setup.sh
sudo ~/.local/bin/selinux-distrobox-setup.sh
```

### 6. Monitor and Debug SELinux Issues

Create monitoring tools:

```bash
cat > ~/.local/bin/selinux-distrobox-monitor.sh << 'EOF'
#!/bin/bash

echo "Monitoring SELinux denials for Distrobox..."
echo "Press Ctrl+C to stop"

# Monitor in real-time
sudo ausearch -m avc -ts recent | grep -i "distrobox\|container" || echo "No recent denials found"

# Alternative: use sealert
if command -v sealert &> /dev/null; then
    echo "Recent SELinux alerts:"
    sudo sealert -l "*" 2>/dev/null | grep -A 10 -B 10 "distrobox\|container" || echo "No alerts found"
fi
EOF

chmod +x ~/.local/bin/selinux-distrobox-monitor.sh
```

## Best Practices

### 1. Container Initialization Script

Create an initialization script that runs on container startup:

```bash
cat > ~/.local/bin/distrobox-init.sh << 'EOF'
#!/bin/bash

# Source theme and scaling configurations
source ~/.local/bin/setup-scaling.sh
source ~/.local/bin/apply-unified-theme.sh

# Set up font cache
fc-cache -f

# Initialize dbus if needed
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS
fi

# Set up X11 forwarding permissions
xhost +local: 2>/dev/null || true

echo "Distrobox environment initialized"
EOF

chmod +x ~/.local/bin/distrobox-init.sh

# Add to shell profile
echo '~/.local/bin/distrobox-init.sh' >> ~/.bashrc
```

### 2. Application Desktop Files

When installing GUI applications in the container, create proper desktop files:

```bash
# Example for a GUI application
cat > ~/.local/share/applications/example-app.desktop << 'EOF'
[Desktop Entry]
Name=Example App
Comment=Example application from Arch container
Exec=distrobox enter arch-desktop -- example-app
Icon=example-app
Terminal=false
Type=Application
Categories=Office;
StartupWMClass=example-app
EOF
```

### 3. Font Management

Sync fonts between host and container:

```bash
# Create font sync script
cat > ~/.local/bin/sync-fonts.sh << 'EOF'
#!/bin/bash

# Create fonts directory in container
mkdir -p ~/.fonts

# Link to host fonts (if available)
if [ -d "/usr/share/fonts" ]; then
    ln -sf /usr/share/fonts/* ~/.fonts/ 2>/dev/null || true
fi

# Update font cache
fc-cache -f -v

echo "Fonts synchronized"
EOF

chmod +x ~/.local/bin/sync-fonts.sh
```

### 4. Container Management Script

Create a comprehensive container management script:

```bash
cat > ~/.local/bin/manage-distrobox.sh << 'EOF'
#!/bin/bash

CONTAINER_NAME="arch-desktop"

case "$1" in
    start)
        echo "Starting distrobox container..."
        distrobox enter $CONTAINER_NAME
        ;;
    init)
        echo "Initializing container environment..."
        distrobox enter $CONTAINER_NAME -- ~/.local/bin/distrobox-init.sh
        ;;
    update)
        echo "Updating container..."
        distrobox enter $CONTAINER_NAME -- sudo pacman -Syu
        ;;
    theme)
        echo "Applying theme..."
        distrobox enter $CONTAINER_NAME -- ~/.local/bin/apply-unified-theme.sh
        ;;
    scale)
        echo "Setting up scaling..."
        distrobox enter $CONTAINER_NAME -- ~/.local/bin/setup-scaling.sh
        ;;
    selinux)
        echo "Configuring SELinux..."
        ~/.local/bin/selinux-distrobox-setup.sh
        ;;
    monitor)
        echo "Monitoring SELinux..."
        ~/.local/bin/selinux-distrobox-monitor.sh
        ;;
    *)
        echo "Usage: $0 {start|init|update|theme|scale|selinux|monitor}"
        exit 1
        ;;
esac
EOF

chmod +x ~/.local/bin/manage-distrobox.sh
```

## Troubleshooting

### Common Issues and Solutions

#### Theme Not Applied
```bash
# Force theme reload
distrobox enter arch-desktop -- gsettings reset-recursively org.gnome.desktop.interface
distrobox enter arch-desktop -- ~/.local/bin/apply-unified-theme.sh
```

#### Scaling Issues
```bash
# Debug scaling
distrobox enter arch-desktop -- env | grep -E "(SCALE|DPI)"
distrobox enter arch-desktop -- ~/.local/bin/hidpi-setup.sh
```

#### SELinux Denials
```bash
# Check for denials
sudo ausearch -m avc -ts recent | grep distrobox

# Generate allow rules (use with caution)
sudo ausearch -m avc -ts recent | grep distrobox | audit2allow -M distrobox_custom
sudo semodule -i distrobox_custom.pp
```

#### Font Issues
```bash
# Rebuild font cache
distrobox enter arch-desktop -- fc-cache -f -v
distrobox enter arch-desktop -- ~/.local/bin/sync-fonts.sh
```

### Verification Commands

Test your setup with these verification commands:

```bash
# Test theming
distrobox enter arch-desktop -- gsettings get org.gnome.desktop.interface gtk-theme
distrobox enter arch-desktop -- echo $QT_QPA_PLATFORMTHEME

# Test scaling
distrobox enter arch-desktop -- echo $GDK_SCALE
distrobox enter arch-desktop -- echo $QT_SCALE_FACTOR

# Test SELinux
sudo semodule -l | grep distrobox
ls -laZ ~/.local/share/containers/
```

This comprehensive guide should help you achieve consistent theming, proper scaling, and appropriate SELinux policies for your Distrobox setup on Fedora 42 with Arch Linux containers.
