# Advanced MPV Configuration for Gentoo Linux

Here's an optimized `mpv.conf` configuration file tailored for Gentoo Linux systems. This configuration focuses on performance, quality, and hardware acceleration while maintaining compatibility with Gentoo's flexible build options.

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

###########################
# Performance & Hardware Acceleration
###########################

# Enable hardware decoding (adjust based on your GPU)
hwdec=auto-safe
hwdec-codecs=all
vo=gpu
gpu-api=auto
gpu-context=auto

# VAAPI specific settings (for Intel/AMD)
#vo=gpu
#gpu-api=vaapi
#hwdec=vaapi-copy

# Vulkan backend (for modern systems)
#vo=gpu
#gpu-api=vulkan
#hwdec=vulkan

# NVDEC/NVENC specific settings
#hwdec=nvdec-copy
#vc=h264_nvenc,hevc_nvenc

###########################
# Video Output & Quality
###########################

profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp
dscale=mitchell
dither-depth=auto
correct-downscaling=yes
linear-downscaling=yes
sigmoid-upscaling=yes
deband=yes
deband-iterations=4
deband-grain=4

# HDR to SDR tone mapping
tone-mapping=bt.2446a
hdr-compute-peak=yes

###########################
# Audio
###########################

audio-channels=auto
audio-display=auto
audio-samplerate=48000
af=scaletempo2
volume-max=150
audio-file-auto=fuzzy

###########################
# Subtitles
###########################

sub-auto=fuzzy
sub-file-paths=subs:subtitles:sub
sub-font='Noto Sans'
sub-font-size=42
sub-color='#FFFFFFFF'
sub-border-color='#FF000000'
sub-border-size=3.0
sub-shadow-offset=1
sub-ass-override=yes
sub-ass-force-style=Kerning=yes

###########################
# Network & Streaming
###########################

ytdl=yes
ytdl-format=bestvideo[height<=?2160]+bestaudio/best
cache=yes
cache-secs=300
demuxer-max-bytes=100MiB
demuxer-max-back-bytes=50MiB

###########################
# Advanced Options
###########################

# Parallel frame decoding
vd-lavc-threads=0
vd-lavc-fast=yes
vd-lavc-skiploopfilter=all

# Color management
icc-profile-auto=yes
target-prim=auto
target-trc=auto

# Screenshot settings
screenshot-format=png
screenshot-png-compression=7
screenshot-tag-colorspace=yes
screenshot-directory=~/Pictures/mpv_screenshots

###########################
# Shaders (optional)
###########################

# Enable these if you have a powerful GPU
#glsl-shaders="~~/shaders/FSRCNNX_x2_16-0-4-1.glsl"
#glsl-shaders="~~/shaders/SSimSuperRes.glsl"
#glsl-shaders-append="~~/shaders/adaptive-sharpen.glsl"
```

## Gentoo-Specific Recommendations

1. **USE Flags**: Ensure you have these USE flags enabled for optimal performance:
   ```bash
   media-video/mpv gbm gles2 libmpv lua jpeg vulkan vaapi wayland X drm opengl
   ```

2. **Vulkan Support**: If you have Vulkan installed, uncomment the Vulkan section in the config.

3. **Hardware Acceleration**: Adjust the hardware acceleration settings based on your GPU:
   - Intel: Use vaapi
   - AMD: Use vaapi or vulkan
   - NVIDIA: Use nvdec or vulkan

4. **Performance Tuning**: For high-end systems, you can increase the cache values and enable more shaders.

5. **Gentoo Kernel**: Ensure your kernel has the appropriate DRM and GPU drivers enabled.

To use this configuration:
1. Save it to `~/.config/mpv/mpv.conf`
2. Create the watch_later directory: `mkdir -p ~/.config/mpv/watch_later`
3. For screenshots: `mkdir -p ~/Pictures/mpv_screenshots`

This configuration balances quality and performance while taking advantage of Gentoo's optimized builds. Adjust the hardware acceleration settings based on your specific GPU.
