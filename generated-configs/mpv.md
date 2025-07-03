# Advanced MPV Configuration for Fedora 42

Here's an optimized `mpv.conf` configuration file tailored for Fedora 42 systems. This configuration leverages Fedora's modern package defaults, Wayland support, and optimized multimedia stack while providing excellent performance and quality.

```conf
###########################
# Input & Behavior
###########################

# Use a more responsive input system
input-ipc-server=/tmp/mpv-socket
input-builtin-bindings=yes
input-default-bindings=yes
input-vo-keyboard=no
cursor-autohide=1000
keep-open=yes
save-position-on-quit=yes
watch-later-directory=~/.config/mpv/watch_later

# Better mouse/touchpad integration for Fedora
input-right-alt-gr=yes
input-cursor=yes

###########################
# Performance & Hardware Acceleration
###########################

# Use gpu-next (modern replacement for gpu)
vo=gpu-next
gpu-api=auto
gpu-context=auto
hwdec=auto-safe
hwdec-codecs=all

# Wayland-specific optimizations (Fedora 42 default)
wayland-app-id=mpv
wayland-configure-bounds=yes

# VAAPI settings (Intel/AMD - common in Fedora systems)
#hwdec=vaapi
#vaapi-device=/dev/dri/renderD128

# NVDEC settings for NVIDIA (RPM Fusion drivers)
#hwdec=nvdec
#vulkan-device=0

###########################
# Video Output & Quality
###########################

profile=gpu-hq
scale=ewa_lanczos
cscale=ewa_lanczos
dscale=mitchell
dither-depth=auto
correct-downscaling=yes
linear-downscaling=yes
sigmoid-upscaling=yes
interpolation=yes
video-sync=display-resample
deband=yes
deband-iterations=4
deband-grain=4

# HDR to SDR tone mapping (gpu-next specific)
tone-mapping=bt.2446a
hdr-compute-peak=yes
hdr-peak-percentile=99.995
hdr-contrast-recovery=0.30
gamut-mapping-mode=auto

# Color management (leverages Fedora's color profiles)
icc-profile-auto=yes
target-prim=auto
target-trc=auto
target-peak=auto

###########################
# Audio (PipeWire optimized)
###########################

# PipeWire is default in Fedora 42
audio-channels=auto
audio-display=auto
audio-samplerate=48000
af=scaletempo2
volume-max=150
audio-file-auto=fuzzy
audio-pitch-correction=yes

# Ensure proper audio output selection
ao=pipewire,pulse,alsa

###########################
# Subtitles
###########################

sub-auto=fuzzy
sub-file-paths=subs:subtitles:sub:Subs:Subtitles
sub-font='Liberation Sans'
sub-font-size=42
sub-color='#FFFFFFFF'
sub-border-color='#FF000000'
sub-border-size=3.0
sub-shadow-offset=1
sub-ass-override=yes
sub-ass-force-style=Kerning=yes
sub-codepage=utf8
sub-font-provider=fontconfig
sub-fonts-dir=/usr/share/fonts/

###########################
# Network & Streaming
###########################

ytdl=yes
ytdl-format=bestvideo[height<=?2160]+bestaudio/best
script-opts=ytdl_hook-ytdl_path=yt-dlp
cache=yes
cache-secs=300
demuxer-max-bytes=150MiB
demuxer-max-back-bytes=75MiB
network-timeout=60

# Streaming optimizations
hls-bitrate=max
ytdl-raw-options=ignore-errors=,sub-lang=en,write-auto-sub=

###########################
# Advanced Options
###########################

# Parallel frame decoding
vd-lavc-threads=0
vd-lavc-fast=yes
vd-lavc-skiploopfilter=all

# GPU film grain support (AV1, H.274)
vd-lavc-film-grain=gpu

# Screenshot settings
screenshot-format=png
screenshot-png-compression=7
screenshot-tag-colorspace=yes
screenshot-directory=~/Pictures/mpv-screenshots

# Performance tweaks for gpu-next
vulkan-async-compute=yes
vulkan-async-transfer=yes
vulkan-queue-count=1

###########################
# Shaders (optional)
###########################

# Enable these if you have a powerful GPU
# Make sure to install mpv-user-shaders package or download manually
#glsl-shaders="~~/shaders/FSRCNNX_x2_16-0-4-1.glsl"
#glsl-shaders-append="~~/shaders/SSimSuperRes.glsl"
#glsl-shaders-append="~~/shaders/adaptive-sharpen.glsl"

# Shader options (gpu-next specific)
#glsl-shader-opts=key=value

###########################
# Fedora-Specific Tweaks
###########################

# Better compatibility with Fedora's multimedia stack
demuxer-lavf-o=fflags=+genpts
video-latency-hacks=yes
hr-seek-framedrop=no

# Improved font rendering for Fedora's font stack
blend-subtitles=yes
```

## Fedora 42-Specific Setup Instructions

### 1. Package Installation

Install MPV and multimedia codecs:
```bash
# Enable RPM Fusion repositories first
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install MPV and codecs
sudo dnf install mpv mpv-libs ffmpeg yt-dlp
sudo dnf install mesa-va-drivers intel-media-driver libva-intel-driver  # Intel GPU
sudo dnf install mesa-vdpau-drivers  # AMD GPU
sudo dnf install nvidia-vaapi-driver  # NVIDIA GPU (if using RPM Fusion NVIDIA drivers)

# Install Vulkan support
sudo dnf install vulkan-tools mesa-vulkan-drivers
```

### 2. Hardware Acceleration Setup

**For Intel Graphics:**
```bash
# Verify VAAPI support
vainfo
# Uncomment in mpv.conf:
# hwdec=vaapi
```

**For AMD Graphics:**
```bash
# Verify Vulkan support
vulkaninfo
# The auto-safe setting should work automatically
```

**For NVIDIA Graphics:**
```bash
# Install NVIDIA drivers from RPM Fusion
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
# Uncomment in mpv.conf:
# hwdec=nvdec
```

### 3. Configuration Setup

```bash
# Create configuration directory
mkdir -p ~/.config/mpv/watch_later
mkdir -p ~/Pictures/mpv-screenshots

# Save the configuration to ~/.config/mpv/mpv.conf
```

### 4. Optional Enhancements

**Install user shaders:**
```bash
mkdir -p ~/.config/mpv/shaders
cd ~/.config/mpv/shaders
wget https://raw.githubusercontent.com/igv/FSRCNN-TensorFlow/master/FSRCNNX_x2_16-0-4-1.glsl
```

**PipeWire low-latency configuration:**
```bash
# Create PipeWire config for better audio performance
mkdir -p ~/.config/pipewire/pipewire.conf.d/
cat > ~/.config/pipewire/pipewire.conf.d/99-mpv.conf << 'EOF'
context.properties = {
    default.clock.quantum = 512
    default.clock.min-quantum = 512
    default.clock.max-quantum = 8192
}
EOF
systemctl --user restart pipewire
```

## Key Fixes and Improvements

### Fixed Issues:
1. **Removed `opengl-pbo=yes`** - This option doesn't exist in gpu-next
2. **Changed `ewa_lanczossharp` to `ewa_lanczos`** - The "sharp" variant was removed
3. **Removed deprecated options** like `--sharpen` and `--blend-subtitles=video`
4. **Added proper PipeWire audio output** with fallback chain
5. **Fixed font provider settings** for better Fedora integration
6. **Added gpu-next specific options** like `hdr-contrast-recovery`

### New Features:
1. **GPU film grain support** - `vd-lavc-film-grain=gpu` for AV1/H.274 content
2. **Better tone mapping** - Using bt.2446a with proper HDR handling
3. **Improved gamut mapping** - Auto mode for better color accuracy
4. **Vulkan optimizations** - Better async compute/transfer settings
5. **Modern shader support** - Ready for custom shader parameters

### Performance Improvements:
- **gpu-next backend** - Faster and more efficient than the old gpu backend
- **Better caching** - Optimized for modern systems
- **Reduced shader passes** - gpu-next automatically merges passes
- **Frame-exact peak detection** - Better HDR handling

This configuration takes full advantage of Fedora 42's modern multimedia stack while avoiding deprecated options and ensuring compatibility with the latest MPV features.
