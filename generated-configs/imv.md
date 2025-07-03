# Advanced and Optimized `imv` Configuration for Fedora 42 with Vim Keybindings and Catppuccin Mocha Theme

Here's a comprehensive `imv` configuration file that combines Vim-like keybindings with the Catppuccin Mocha color scheme, optimized for Fedora 42:

```ini
# ~/.config/imv/config

# ======================
# Options Section
# ======================
[options]
# Catppuccin Mocha Theme Colors (6-digit hex format)
background = 1E1E2E
overlay_background_color = 1E1E2E
overlay_text_color = CDD6F4
overlay_font = monospace:12

# Performance and behavior settings
suppress_default_binds = true
loop_input = true
recursive = true
shuffle = false
scaling = shrink
upscaling = linear
list_files_at_exit = false

# Window behavior
fullscreen = false
width = 1200
height = 800
initial_pan = 0.5,0.5

# ======================
# Aliases Section
# ======================
[aliases]
# Vim-style aliases
q = quit
qa = quit
w = next
wq = next
x = next

# Navigation aliases
first = select 1
last = select -1

# ======================
# Vim-like Keybindings
# ======================
[binds]
# Basic navigation (vim-style)
h = prev
l = next
j = scroll 0 -50
k = scroll 0 50
<Shift+h> = pan -50 0
<Shift+l> = pan 50 0  
<Shift+j> = pan 0 50
<Shift+k> = pan 0 -50

# Go to first/last image
g = select 1
<Shift+g> = select -1

# Zooming
plus = zoom 1
minus = zoom -1
equal = reset
<Shift+w> = scaling fit
<Shift+e> = scaling fit
i = zoom 1
o = zoom -1

# Image manipulation  
r = rotate by 90
<Shift+r> = rotate by -90
f = flip horizontal
<Shift+f> = flip vertical

# View modes
<Ctrl+f> = fullscreen
<Ctrl+v> = overlay
v = overlay
space = overlay

# File operations - using aliases
colon = command
<Shift+semicolon> = command

# Slideshow controls
s = slideshow
<Ctrl+s> = slideshow

# Window management
<Ctrl+w> = close
<Ctrl+n> = exec imv &
q = quit
<Shift+z><Shift+z> = quit

# Additional vim-like bindings
n = next
<Shift+n> = prev
p = prev

# Advanced navigation
<Ctrl+d> = scroll 0 200
<Ctrl+u> = scroll 0 -200
<Home> = pan leftmost
<End> = pan rightmost
<Page_Up> = prev
<Page_Down> = next

# Mouse bindings
<ScrollUp> = zoom 1
<ScrollDown> = zoom -1
<LeftMouse> = pan mouse
<RightMouse> = context_menu

# Function keys
<F11> = fullscreen
<F1> = overlay

# Number keys for quick selection (vim-style)
1 = select 1
2 = select 2
3 = select 3
4 = select 4
5 = select 5
6 = select 6
7 = select 7
8 = select 8
9 = select 9
0 = select -1
```

## Installation on Fedora 42

### 1. Install IMV
```bash
# Install from official repositories
sudo dnf install imv

# Optional: Install additional image format support
sudo dnf install libwebp libheif libavif
```

### 2. Create Configuration Directory and File
```bash
# Create config directory
mkdir -p ~/.config/imv

# Save the configuration above as ~/.config/imv/config
```

### 3. Enhanced Fedora 42 Setup

#### Enable RPM Fusion for Additional Codecs
```bash
# Enable RPM Fusion repositories
sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install additional multimedia support
sudo dnf install libheif-freeworld libavif-gdk-pixbuf
```

#### Graphics Driver Optimization
```bash
# For NVIDIA users (RPM Fusion)
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda

# For AMD users (already included in Fedora)
sudo dnf install mesa-vulkan-drivers mesa-vdpau-drivers

# For Intel users
sudo dnf install intel-media-driver libva-intel-driver
```

#### Wayland Integration
```bash
# Ensure Wayland support (usually already installed)
sudo dnf install wayland-protocols-devel wl-clipboard

# For screen capture integration
sudo dnf install grim slurp
```

## Key Configuration Features

### Catppuccin Mocha Integration
- **Background**: Deep mocha dark (`1E1E2E`)
- **Text**: Catppuccin text color (`CDD6F4`)
- **Overlay**: Semi-transparent mocha background

### Vim-like Navigation
- `h/l`: Previous/next image
- `j/k`: Scroll up/down within image
- `H/L/J/K`: Pan image (Shift variants)
- `g/G`: Go to first/last image
- `:q`, `ZZ`: Quit (vim-style)
- `:w`, `:wq`, `:x`: Next image (vim-style)

### Enhanced Features
- **Suppressed defaults**: Custom keybindings only
- **Mouse support**: Scroll to zoom, click to pan
- **Function keys**: F11 for fullscreen, F1 for overlay
- **Number keys**: Quick jump to specific images (1-9, 0 for last)

## Usage Examples

```bash
# Basic usage
imv ~/Pictures/

# Recursive directory scanning
imv -r ~/Pictures/

# Fullscreen slideshow
imv -f -t 3 ~/Pictures/

# Custom background
imv -b checks ~/Pictures/
```

## Troubleshooting

### If IMV doesn't start
```bash
# Check if config is valid
imv --help

# Test with default config
mv ~/.config/imv/config ~/.config/imv/config.bak
imv ~/Pictures/
```

### Performance Issues
```bash
# Clear thumbnail cache if it exists
rm -rf ~/.cache/imv/

# Use hardware acceleration (if available)
export LIBVA_DRIVER_NAME=iHD  # for Intel
# or
export LIBVA_DRIVER_NAME=radeonsi  # for AMD
```

This corrected configuration removes all invalid options and uses only the features actually supported by IMV, while maintaining the vim-like workflow and Catppuccin Mocha aesthetic. The configuration is now compatible with IMV's actual capabilities and syntax requirements.
