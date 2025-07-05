# Hyprland HDR Setup Guide for Fedora 42 with NVIDIA Graphics Cards

## Overview

Fedora 42, released on April 15, 2025, includes native HDR support as a major feature. While this HDR support is primarily implemented for GNOME, it can be leveraged for Hyprland with additional configuration. This guide covers setting up HDR with Hyprland on Fedora 42 using NVIDIA graphics cards.

## NVIDIA Driver Requirements

For HDR support on NVIDIA graphics cards with Fedora 42, you need:
- **NVIDIA Driver 555+ (Stable)** or **565+ (Latest)** 
- **RTX 20 series or newer** (GTX 16 series has limited HDR support)
- **Hyprland 0.49.0 or later** (HDR support added in 0.47)
- **Compatible HDR monitor** with proper cable

## Current Status of NVIDIA HDR on Fedora 42

**Important**: While Fedora 42 has excellent HDR support in GNOME, HDR in Hyprland with NVIDIA requires additional setup using Gamescope and vk-hdr-layer. The experience may vary depending on your specific hardware and games.

## Prerequisites

### Hardware Requirements
- NVIDIA RTX 20 series or newer graphics card
- HDR10-capable monitor with DisplayPort 1.4+ or HDMI 2.0+
- High-quality DisplayPort 1.4+ cable (recommended over HDMI)

### Software Requirements
- **Fedora 42 Workstation** (with native HDR infrastructure)
- **NVIDIA Driver**: 555+ stable from RPM Fusion
- **Hyprland**: Available from Fedora repositories or COPR
- **vk-hdr-layer**: Required for Vulkan HDR support
- **Gamescope**: Primary HDR gaming solution

## System Preparation

### Update Fedora 42

```bash
# Update system to latest packages
sudo dnf update --refresh

# Reboot if kernel was updated
sudo reboot
```

### Enable RPM Fusion Repositories

```bash
# Enable RPM Fusion repositories for NVIDIA drivers
sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Refresh package database
sudo dnf update --refresh
```

## NVIDIA Driver Installation

### Method 1: Stable Driver from RPM Fusion (Recommended)

```bash
# Remove nouveau driver
sudo dnf remove xorg-x11-drv-nouveau

# Install NVIDIA driver and utilities
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686

# Install additional NVIDIA tools
sudo dnf install xorg-x11-drv-nvidia-cuda nvidia-settings nvidia-persistenced

# Build kernel modules (may take 5-10 minutes)
sudo akmods --force

# Generate initramfs
sudo dracut --regenerate-all --force

# Reboot system
sudo reboot
```

### Method 2: Latest Driver (If Needed)

```bash
# Install latest available NVIDIA driver
sudo dnf install akmod-nvidia-470xx # or whatever latest version is available

# Or install directly from NVIDIA (not recommended for daily use)
# wget https://us.download.nvidia.com/XFree86/Linux-x86_64/[VERSION]/NVIDIA-Linux-x86_64-[VERSION].run
```

### Verify Installation

```bash
# Check NVIDIA driver version and status
nvidia-smi

# Verify kernel modules are loaded
lsmod | grep nvidia

# Check if NVIDIA persistence daemon is running
systemctl status nvidia-persistenced
```

## HDR Prerequisites Installation

### Install vk-hdr-layer

```bash
# Option 1: Use jackgreiner COPR (recommended for Fedora 40+)
sudo dnf copr enable jackgreiner/vk-hdr-layer
sudo dnf install vk-hdr-layer

# Option 2: Alternative COPR
# sudo dnf copr enable vulongm/vk-hdr-layer
# sudo dnf install vk-hdr-layer

# Verify installation
ls /usr/share/vulkan/explicit_layer.d/ | grep -i hdr
```

### Install Gamescope

```bash
# Install Gamescope from Fedora repositories
sudo dnf install gamescope

# Install additional gaming tools
sudo dnf install steam lutris mangohud gamemode
```

### Install Hyprland

```bash
# Install Hyprland from Fedora repositories
sudo dnf install hyprland

# Or install latest version from COPR
sudo dnf copr enable solopasha/hyprland
sudo dnf install hyprland

# Install additional Hyprland tools
sudo dnf install waybar wofi dunst grim slurp wl-clipboard
```

## Hyprland Configuration for HDR

### Monitor Configuration

```bash
# ~/.config/hypr/hyprland.conf

# First, identify your monitor
# Run: hyprctl monitors

# Configure your HDR monitor
monitor = DP-1, 3840x2160@60, 0x0, 1
# For high refresh rate HDR
monitor = DP-1, 3840x2160@144, 0x0, 1
```

### Essential Environment Variables

```bash
# NVIDIA-specific variables
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia

# NVIDIA Wayland optimizations
env = NVIDIA_WAYLAND_USE_SPECIALIZATION_CONSTANTS,1
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

# HDR-specific variables
env = WLR_NO_HARDWARE_CURSORS,1
env = ENABLE_HDR_WSI,1
env = DXVK_HDR,1
env = VK_LAYER_PATH,/usr/share/vulkan/explicit_layer.d
```

### Core Hyprland Configuration

```bash
# ~/.config/hypr/hyprland.conf

# Monitor setup
monitor = DP-1, 3840x2160@60, 0x0, 1

# Environment variables
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = NVIDIA_WAYLAND_USE_SPECIALIZATION_CONSTANTS,1
env = __GL_GSYNC_ALLOWED,1
env = __GL_VRR_ALLOWED,1

# HDR environment
env = ENABLE_HDR_WSI,1
env = DXVK_HDR,1
env = VK_LAYER_PATH,/usr/share/vulkan/explicit_layer.d

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = false
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decoration
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Misc settings
misc {
    force_default_wallpaper = -1
    disable_hyprland_logo = false
}

# Window rules for HDR applications
windowrule = immediate, ^(gamescope)$
windowrule = immediate, ^(mpv)$
windowrule = noborder, ^(gamescope)$
windowrule = fullscreen, ^(gamescope)$

# Key bindings
$mainMod = SUPER

bind = $mainMod, Q, exec, kitty
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, dolphin
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
```

## HDR Gaming Setup

### Steam Configuration

```bash
# Steam launch options for HDR games
ENABLE_HDR_WSI=1 DXVK_HDR=1 gamescope -f -W 3840 -H 2160 --hdr-enabled -- %command%

# For better compatibility, use:
ENABLE_HDR_WSI=1 DXVK_HDR=1 VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d gamescope -f -W 3840 -H 2160 --hdr-enabled --hdr-debug-force-output -- %command%
```

### Lutris Configuration

```bash
# Environment variables for Lutris
ENABLE_HDR_WSI=1
DXVK_HDR=1
VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d
WINEDLLOVERRIDES=dxgi=n,b
```

### Direct Game Launch

```bash
# Launch games with HDR support
ENABLE_HDR_WSI=1 DXVK_HDR=1 gamescope -f --hdr-enabled -- your-game

# For debugging
ENABLE_HDR_WSI=1 DXVK_HDR=1 VK_LOADER_DEBUG=error,warn,info gamescope -f --hdr-enabled --hdr-debug-force-output -- your-game
```

## HDR Media Playback

### Install Media Codecs

```bash
# Install multimedia codecs for Fedora 42
sudo dnf install gstreamer1-plugins-{bad-*,good-*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel

# Install additional codecs
sudo dnf install lame* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia
```

### MPV Configuration

```bash
# ~/.config/mpv/mpv.conf
vo=gpu-next
gpu-api=vulkan
target-colorspace-hint=yes
tone-mapping=bt.2446a

# NVIDIA hardware decoding
hwdec=nvdec
hwdec-codecs=all

# HDR settings
profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp
video-sync=display-resample
interpolation=yes
```

### Launch HDR Media

```bash
# Play HDR content
ENABLE_HDR_WSI=1 VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d mpv --vo=gpu-next --target-colorspace-hint your-hdr-video.mkv

# Through Gamescope
gamescope -f --hdr-enabled -- mpv your-hdr-video.mkv
```

## Testing HDR Setup

### Verify Components

```bash
# Check NVIDIA driver
nvidia-smi

# Check Hyprland version
hyprctl version

# Check monitors
hyprctl monitors

# Check Vulkan HDR support
vulkaninfo | grep -i hdr

# Verify vk-hdr-layer
ls /usr/share/vulkan/explicit_layer.d/ | grep -i hdr

# Check environment variables
echo $ENABLE_HDR_WSI
echo $VK_LAYER_PATH
```

### Test HDR

```bash
# Test with Gamescope
ENABLE_HDR_WSI=1 VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d gamescope -f --hdr-enabled --hdr-debug-force-output -- glxgears

# Test with MPV
ENABLE_HDR_WSI=1 VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d mpv --vo=gpu-next /path/to/hdr-video.mkv
```

## Troubleshooting

### NVIDIA Driver Issues

```bash
# Rebuild NVIDIA modules
sudo akmods --force
sudo dracut --regenerate-all --force
sudo reboot

# Check for conflicts
sudo dnf list installed | grep nvidia
sudo dnf remove "*nvidia*" --skip-broken # if needed to start over
```

### HDR Not Working

1. **Check Monitor**: Ensure HDR is enabled in monitor settings
2. **Cable**: Use DisplayPort 1.4+ cable
3. **Driver**: Verify NVIDIA driver 555+ is installed
4. **vk-hdr-layer**: Confirm proper installation and VK_LAYER_PATH

### Performance Issues

```bash
# Reduce Hyprland effects for testing
decoration {
    blur {
        enabled = false
    }
    drop_shadow = false
}

animations {
    enabled = false
}
```

### Gamescope Issues

```bash
# Debug Gamescope
VK_LOADER_DEBUG=error,warn,info gamescope -f --hdr-enabled --hdr-debug-force-output -- your-app

# Check Gamescope version
gamescope --version
```

## Advanced Configuration

### Kernel Parameters

```bash
# Edit GRUB configuration
sudo nano /etc/default/grub

# Add NVIDIA parameters
GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 nvidia-drm.fbdev=1 rd.driver.blacklist=nouveau modprobe.blacklist=nouveau"

# Update GRUB
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### Multiple Monitor Setup

```bash
# HDR primary + standard secondary
monitor = DP-1, 3840x2160@60, 0x0, 1        # HDR monitor
monitor = DP-2, 1920x1080@144, 3840x0, 1    # Standard monitor

# Workspace assignment
workspace = 1, monitor:DP-1, default:true
workspace = 2, monitor:DP-2
```

## Important Notes

1. **Fedora 42 HDR**: Native HDR support is primarily for GNOME; Hyprland requires additional setup
2. **Experimental**: HDR gaming on Hyprland is still experimental
3. **Game Compatibility**: Not all games support HDR on Linux
4. **Performance**: HDR may impact performance on older hardware
5. **Updates**: Keep system updated as HDR support continues improving

## Alternative Approaches

If HDR doesn't work reliably in Hyprland:

1. **Switch to GNOME**: Fedora 42's native HDR support works best in GNOME
2. **Try KDE**: `sudo dnf install @kde-desktop-environment`
3. **Use X11**: Some applications work better with X11 HDR
4. **Dual Boot**: Windows for critical HDR gaming needs

## Verification Commands

```bash
# Complete system check
nvidia-smi                                      # NVIDIA status
hyprctl version                                # Hyprland version
hyprctl monitors                               # Monitor configuration
vulkaninfo | grep -i hdr                      # Vulkan HDR support
ls /usr/share/vulkan/explicit_layer.d/        # vk-hdr-layer
systemctl status nvidia-persistenced          # NVIDIA services
echo $ENABLE_HDR_WSI $VK_LAYER_PATH           # Environment variables
```

Keep your Fedora 42 system updated with regular `sudo dnf update` commands as HDR support continues to improve across the Linux ecosystem.
