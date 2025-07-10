# Advanced and Optimized `imv` Configuration for Gentoo with Vim Keybindings and Catppuccin Mocha Theme

Here's a comprehensive `imv` configuration file that combines Vim-like keybindings with the Catppuccin Mocha color scheme, optimized for Gentoo Linux:

```ini
# ~/.config/imv/config

# ======================
# Catppuccin Mocha Theme
# ======================
[options]
background = 1E1E2EFF
fullscreen_background = 1E1E2EFF
overlay_text_color = CDD6F4FF
overlay_background = 1E1E2E80
overlay_border_color = 585B70FF

# ======================
# Vim-like Keybindings
# ======================
[binds]
# Navigation
h = prev
l = next
j = scroll down
k = scroll up
H = pan left
L = pan right
J = pan down
K = pan up
gg = goto first
G = goto last
^ = pan leftmost
$ = pan rightmost

# Zooming
+ = zoom in
- = zoom out
= = zoom actual
w = zoom fill
e = zoom fill
i = zoom in
o = zoom out

# Image manipulation
r = rotate clockwise
R = rotate anticlockwise
f = flip horizontal
F = flip vertical

# View modes
<Ctrl>f = fullscreen
<Ctrl>v = overlay
v = overlay
<Space> = toggle overlay

# File operations
:q = quit
ZZ = quit
:qa = quit
:q! = quit
:w = next
:wq = next
:x = next
n = next
N = prev
p = prev

# Slideshow
<Ctrl>s = slideshow
s = slideshow

# Window management
<Ctrl>w = close
<Ctrl>n = new_window

# ======================
# Performance Optimizations
# ======================
[options]
# Use hardware acceleration (adjust based on your GPU)
backend = gl
# Increase cache size for better performance with many images
cache_size = 512
# Use threaded loading for better responsiveness
threads = 4
# Disable EXIF rotation by default (can be toggled)
auto_rotate = false
# Use fast scaling algorithm (for performance)
scaling_algorithm = fast

# ======================
# Gentoo-specific Optimizations
# ======================
[options]
# Use the most optimized image loader available
# (Gentoo typically builds with all supported libraries)
preferred_loader = libjpeg-turbo,libpng,libtiff,librsvg
```

## Installation and Usage

1. Save this file as `~/.config/imv/config`
2. Ensure you have the required USE flags for optimal performance:
   ```sh
   # Add these to your package.use or make.conf
   media-gfx/imv X glib gif jpeg png svg tiff
   ```

## Additional Gentoo Optimization Tips

1. Rebuild imv with optimized CFLAGS:
   ```sh
   CFLAGS="-march=native -O2 -pipe" emerge -1 imv
   ```

2. For Wayland users, consider adding the `wayland` USE flag for better integration.

3. If you're using a dedicated GPU, ensure you have the appropriate drivers installed and consider adding:
   ```sh
   VIDEO_CARDS="amdgpu radeonsi intel nvidia"
   ```
   to your make.conf (adjust based on your hardware).

This configuration provides a vim-like workflow while maintaining the aesthetic of the Catppuccin Mocha theme. The performance optimizations are particularly beneficial on Gentoo where you can fine-tune the build for your specific hardware.
