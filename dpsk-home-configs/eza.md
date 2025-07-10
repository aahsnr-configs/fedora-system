# eza Catppuccin Mocha Configuration
*Optimized for Fedora 42*

## Issues Found and Fixed

### Critical Issues:
1. **Duplicate `deb` and `rpm` entries** - These appeared in both archives and executable sections
2. **Invalid YAML key `"7z"`** - Numbers starting keys need proper quoting
3. **Invalid YAML key `"~"`** - Tilde needs proper quoting in YAML
4. **Missing `punctuation` section** - Required for proper UI rendering
5. **Incorrect `file_type` section** - Should be `filekinds` according to eza documentation
6. **Missing `permission` section** - Required for file permission colors

### Minor Issues:
1. **Inconsistent color assignments** - Some file types had suboptimal color choices
2. **Missing common file extensions** - Added several important extensions
3. **Organizational improvements** - Better grouping and comments

## Configuration File: `~/.config/eza/theme.yml`

```yaml
# Catppuccin Mocha Theme for eza
# Place this file at: ~/.config/eza/theme.yml
# 
# Based on Catppuccin Mocha color palette:
# https://github.com/catppuccin/catppuccin
# 
# Catppuccin Mocha Colors:
# Base:      #1e1e2e    Surface0:  #313244    Surface1:  #45475a    Surface2:  #585b70
# Overlay0:  #6c7086    Overlay1:  #7f849c    Overlay2:  #9399b2    Subtext0:  #a6adc8
# Subtext1:  #bac2de    Text:      #cdd6f4    Lavender:  #b4befe    Blue:      #89b4fa
# Sapphire:  #74c7ec    Sky:       #89dceb    Teal:      #94e2d5    Green:     #a6e3a1
# Yellow:    #f9e2af    Peach:     #fab387    Maroon:    #eba0ac    Red:       #f38ba8
# Mauve:     #cba6f7    Pink:      #f5c2e7    Flamingo:  #f2cdcd    Rosewater: #f5e0dc

# File type colors
filetype:
  # Directories and special files
  directory: "#89b4fa"          # Blue
  executable: "#a6e3a1"         # Green
  
  # Links and pipes
  symlink: "#89dceb"            # Sky
  pipe: "#f5c2e7"               # Pink
  socket: "#f5c2e7"             # Pink
  block_device: "#f38ba8"       # Red
  char_device: "#f38ba8"        # Red
  
  # Special permissions
  setuid: "#fab387"             # Peach
  setgid: "#fab387"             # Peach
  sticky: "#89b4fa"             # Blue
  other_writable: "#89b4fa"     # Blue
  sticky_other_writable: "#cba6f7"  # Mauve

# Extension-based colors
extension:
  # Archives and compressed files
  "7z": "#fab387"               # Peach
  ace: "#fab387"                # Peach
  alz: "#fab387"                # Peach
  arc: "#fab387"                # Peach
  arj: "#fab387"                # Peach
  bz: "#fab387"                 # Peach
  bz2: "#fab387"                # Peach
  cab: "#fab387"                # Peach
  cpio: "#fab387"               # Peach
  deb: "#fab387"                # Peach
  dmg: "#fab387"                # Peach
  dz: "#fab387"                 # Peach
  ear: "#fab387"                # Peach
  esd: "#fab387"                # Peach
  gz: "#fab387"                 # Peach
  jar: "#fab387"                # Peach
  lha: "#fab387"                # Peach
  lrz: "#fab387"                # Peach
  lz: "#fab387"                 # Peach
  lz4: "#fab387"                # Peach
  lzh: "#fab387"                # Peach
  lzma: "#fab387"               # Peach
  lzo: "#fab387"                # Peach
  rar: "#fab387"                # Peach
  rpm: "#fab387"                # Peach - Fedora packages
  rz: "#fab387"                 # Peach
  sar: "#fab387"                # Peach
  srpm: "#fab387"               # Peach - Fedora source packages
  swm: "#fab387"                # Peach
  t7z: "#fab387"                # Peach
  tar: "#fab387"                # Peach
  taz: "#fab387"                # Peach
  tbz: "#fab387"                # Peach
  tbz2: "#fab387"               # Peach
  tgz: "#fab387"                # Peach
  tlz: "#fab387"                # Peach
  txz: "#fab387"                # Peach
  tz: "#fab387"                 # Peach
  tzo: "#fab387"                # Peach
  tzst: "#fab387"               # Peach
  war: "#fab387"                # Peach
  wim: "#fab387"                # Peach
  xz: "#fab387"                 # Peach
  z: "#fab387"                  # Peach
  zip: "#fab387"                # Peach
  zoo: "#fab387"                # Peach
  zst: "#fab387"                # Peach
  
  # Package formats
  appimage: "#fab387"           # Peach - AppImage packages
  flatpak: "#fab387"            # Peach - Flatpak packages
  snap: "#fab387"               # Peach - Snap packages
  pkg: "#fab387"                # Peach
  msi: "#fab387"                # Peach

  # Images
  avif: "#94e2d5"               # Teal
  bmp: "#94e2d5"                # Teal
  cgm: "#94e2d5"                # Teal
  emf: "#94e2d5"                # Teal
  gif: "#94e2d5"                # Teal
  heic: "#94e2d5"               # Teal
  heif: "#94e2d5"               # Teal
  ico: "#94e2d5"                # Teal
  jpeg: "#94e2d5"               # Teal
  jpg: "#94e2d5"                # Teal
  mjpeg: "#94e2d5"              # Teal
  mjpg: "#94e2d5"               # Teal
  mng: "#94e2d5"                # Teal
  pbm: "#94e2d5"                # Teal
  pcx: "#94e2d5"                # Teal
  pgm: "#94e2d5"                # Teal
  png: "#94e2d5"                # Teal
  ppm: "#94e2d5"                # Teal
  svg: "#94e2d5"                # Teal
  svgz: "#94e2d5"               # Teal
  tga: "#94e2d5"                # Teal
  tif: "#94e2d5"                # Teal
  tiff: "#94e2d5"               # Teal
  webp: "#94e2d5"               # Teal
  xbm: "#94e2d5"                # Teal
  xcf: "#94e2d5"                # Teal
  xpm: "#94e2d5"                # Teal
  xwd: "#94e2d5"                # Teal

  # Videos
  asf: "#74c7ec"                # Sapphire
  avi: "#74c7ec"                # Sapphire
  dl: "#74c7ec"                 # Sapphire
  flc: "#74c7ec"                # Sapphire
  fli: "#74c7ec"                # Sapphire
  flv: "#74c7ec"                # Sapphire
  gl: "#74c7ec"                 # Sapphire
  m2v: "#74c7ec"                # Sapphire
  m4v: "#74c7ec"                # Sapphire
  mkv: "#74c7ec"                # Sapphire
  mov: "#74c7ec"                # Sapphire
  mp4: "#74c7ec"                # Sapphire
  mp4v: "#74c7ec"               # Sapphire
  mpeg: "#74c7ec"               # Sapphire
  mpg: "#74c7ec"                # Sapphire
  nuv: "#74c7ec"                # Sapphire
  ogm: "#74c7ec"                # Sapphire
  ogv: "#74c7ec"                # Sapphire
  ogx: "#74c7ec"                # Sapphire
  qt: "#74c7ec"                 # Sapphire
  rm: "#74c7ec"                 # Sapphire
  rmvb: "#74c7ec"               # Sapphire
  vob: "#74c7ec"                # Sapphire
  webm: "#74c7ec"               # Sapphire
  wmv: "#74c7ec"                # Sapphire
  yuv: "#74c7ec"                # Sapphire

  # Audio
  aac: "#cba6f7"                # Mauve
  au: "#cba6f7"                 # Mauve
  flac: "#cba6f7"               # Mauve
  m4a: "#cba6f7"                # Mauve
  mid: "#cba6f7"                # Mauve
  midi: "#cba6f7"               # Mauve
  mka: "#cba6f7"                # Mauve
  mp3: "#cba6f7"                # Mauve
  mpc: "#cba6f7"                # Mauve
  oga: "#cba6f7"                # Mauve
  ogg: "#cba6f7"                # Mauve
  opus: "#cba6f7"               # Mauve
  ra: "#cba6f7"                 # Mauve
  spx: "#cba6f7"                # Mauve
  wav: "#cba6f7"                # Mauve
  wma: "#cba6f7"                # Mauve
  xspf: "#cba6f7"               # Mauve

  # Documents
  doc: "#f5c2e7"                # Pink
  docx: "#f5c2e7"               # Pink
  epub: "#f5c2e7"               # Pink
  md: "#f5c2e7"                 # Pink
  markdown: "#f5c2e7"           # Pink
  mobi: "#f5c2e7"               # Pink
  odt: "#f5c2e7"                # Pink
  odp: "#f5c2e7"                # Pink
  ods: "#f5c2e7"                # Pink
  pdf: "#f5c2e7"                # Pink
  ppt: "#f5c2e7"                # Pink
  pptx: "#f5c2e7"               # Pink
  ps: "#f5c2e7"                 # Pink
  rst: "#f5c2e7"                # Pink
  rtf: "#f5c2e7"                # Pink
  tex: "#f5c2e7"                # Pink
  xls: "#f5c2e7"                # Pink
  xlsx: "#f5c2e7"               # Pink

  # Text files
  diff: "#cdd6f4"               # Text
  log: "#a6adc8"                # Subtext0
  out: "#a6adc8"                # Subtext0
  patch: "#cdd6f4"              # Text
  txt: "#cdd6f4"                # Text

  # Configuration files
  cfg: "#94e2d5"                # Teal
  conf: "#94e2d5"               # Teal
  desktop: "#94e2d5"            # Teal
  ini: "#94e2d5"                # Teal
  json: "#f9e2af"               # Yellow
  rc: "#94e2d5"                 # Teal
  service: "#94e2d5"            # Teal - systemd service files
  socket: "#94e2d5"             # Teal - systemd socket files
  target: "#94e2d5"             # Teal - systemd target files
  timer: "#94e2d5"              # Teal - systemd timer files
  toml: "#f9e2af"               # Yellow
  xml: "#f9e2af"                # Yellow
  yaml: "#f9e2af"               # Yellow
  yml: "#f9e2af"                # Yellow

  # Programming languages
  bash: "#a6e3a1"               # Green
  c: "#89b4fa"                  # Blue
  cc: "#89b4fa"                 # Blue
  clj: "#a6e3a1"                # Green - Clojure
  cljs: "#a6e3a1"               # Green - ClojureScript
  cpp: "#89b4fa"                # Blue
  cs: "#cba6f7"                 # Mauve
  csh: "#a6e3a1"                # Green
  cxx: "#89b4fa"                # Blue
  dart: "#89b4fa"               # Blue
  fish: "#a6e3a1"               # Green
  fs: "#cba6f7"                 # Mauve - F#
  go: "#89dceb"                 # Sky
  h: "#89b4fa"                  # Blue
  hpp: "#89b4fa"                # Blue
  java: "#fab387"               # Peach
  js: "#f9e2af"                 # Yellow
  jsx: "#89b4fa"                # Blue
  ksh: "#a6e3a1"                # Green
  kt: "#fab387"                 # Peach - Kotlin
  lua: "#89b4fa"                # Blue
  perl: "#89b4fa"               # Blue
  php: "#cba6f7"                # Mauve
  pl: "#89b4fa"                 # Blue
  py: "#f9e2af"                 # Yellow
  r: "#89b4fa"                  # Blue
  rb: "#f38ba8"                 # Red
  rs: "#fab387"                 # Peach
  scala: "#f38ba8"              # Red
  sh: "#a6e3a1"                 # Green
  swift: "#fab387"              # Peach
  tcsh: "#a6e3a1"               # Green
  ts: "#89b4fa"                 # Blue
  tsx: "#89b4fa"                # Blue
  vb: "#cba6f7"                 # Mauve
  vue: "#a6e3a1"                # Green
  zig: "#fab387"                # Peach
  zsh: "#a6e3a1"                # Green

  # Web files
  css: "#89b4fa"                # Blue
  htm: "#fab387"                # Peach
  html: "#fab387"               # Peach
  less: "#89b4fa"               # Blue
  sass: "#f5c2e7"               # Pink
  scss: "#f5c2e7"               # Pink
  styl: "#89b4fa"               # Blue

  # Database files
  db: "#f9e2af"                 # Yellow
  sql: "#f9e2af"                # Yellow
  sqlite: "#f9e2af"             # Yellow
  sqlite3: "#f9e2af"            # Yellow

  # Fedora specific files
  kickstart: "#f38ba8"          # Red - Fedora kickstart files
  ks: "#f38ba8"                 # Red - Fedora kickstart files
  repo: "#89b4fa"               # Blue - Fedora repository files
  spec: "#a6e3a1"               # Green - RPM spec files

  # Container files
  containerfile: "#89dceb"      # Sky - Podman/Buildah
  docker-compose: "#89dceb"     # Sky
  dockerfile: "#89dceb"         # Sky

  # Executables
  bin: "#a6e3a1"                # Green
  exe: "#a6e3a1"                # Green
  run: "#a6e3a1"                # Green

  # Temporary/backup files
  "~": "#6c7086"                # Surface0
  bak: "#6c7086"                # Surface0
  backup: "#6c7086"             # Surface0
  orig: "#6c7086"               # Surface0
  rej: "#6c7086"                # Surface0
  swo: "#6c7086"                # Surface0
  swp: "#6c7086"                # Surface0
  temp: "#6c7086"               # Surface0
  tmp: "#6c7086"                # Surface0

# UI elements
ui:
  size:
    number: "#fab387"           # Peach
    unit: "#f38ba8"             # Red
  
  user: "#f9e2af"               # Yellow
  group: "#a6e3a1"              # Green
  
  date:
    day: "#89b4fa"              # Blue
    time: "#cba6f7"             # Mauve
  
  inode: "#cdd6f4"              # Text
  blocks: "#fab387"             # Peach
  header: "#b4befe"             # Lavender
  links: "#f5e0dc"              # Rosewater
  tree: "#cba6f7"               # Mauve

# Punctuation and symbols
punctuation: "#9399b2"          # Overlay2

# File permissions
permission:
  read: "#a6e3a1"               # Green
  write: "#f9e2af"              # Yellow
  exec: "#f38ba8"               # Red
  exec_sticky: "#cba6f7"        # Mauve
  no_access: "#6c7086"          # Surface0
  octal: "#fab387"              # Peach
  attribute: "#89dceb"          # Sky

# Git integration
git:
  clean: "#a6e3a1"              # Green
  new: "#89b4fa"                # Blue
  modified: "#f9e2af"           # Yellow
  deleted: "#f38ba8"            # Red
  renamed: "#cba6f7"            # Mauve
  typechange: "#fab387"         # Peach
  ignored: "#6c7086"            # Surface0
  conflicted: "#eba0ac"         # Maroon

# Security context colors
security_context:
  colon: "#cdd6f4"              # Text
  user: "#f9e2af"               # Yellow
  role: "#a6e3a1"               # Green
  type: "#89b4fa"               # Blue
  range: "#cba6f7"              # Mauve

# File kinds (replaces file_type)
filekinds:
  image: "#94e2d5"              # Teal
  video: "#74c7ec"              # Sapphire
  music: "#cba6f7"              # Mauve
  lossless: "#cba6f7"           # Mauve
  crypto: "#f38ba8"             # Red
  document: "#f5c2e7"           # Pink
  compressed: "#fab387"         # Peach
  temp: "#6c7086"               # Surface0
  compiled: "#fab387"           # Peach
  source: "#89b4fa"             # Blue
  executable: "#a6e3a1"         # Green
```

## Shell Aliases and Functions

Add these to your `~/.bashrc`, `~/.zshrc`, or shell configuration:

```bash
# Basic eza aliases
alias ls='eza --color=always --icons=always --group-directories-first'
alias ll='eza -l --color=always --icons=always --group-directories-first --git --header'
alias la='eza -la --color=always --icons=always --group-directories-first --git --header'
alias lt='eza --tree --color=always --icons=always --group-directories-first --level=3'
alias lr='eza -R --color=always --icons=always --group-directories-first'

# Development-focused aliases
alias lg='eza -l --git --git-ignore --color=always --icons=always --group-directories-first --header'
alias lG='eza -l --git --git-ignore --git-repos --color=always --icons=always --group-directories-first --header'
alias lsize='eza -l --sort=size --reverse --color=always --icons=always --group-directories-first --git --header'
alias ltime='eza -l --sort=modified --reverse --color=always --icons=always --group-directories-first --git --header'

# Fedora specific aliases
alias lrpm='eza -la --color=always --icons=always *.rpm *.srpm 2>/dev/null || echo "No RPM files found"'
alias lspec='eza -la --color=always --icons=always *.spec 2>/dev/null || echo "No spec files found"'
alias lbuild='eza -la --color=always --icons=always --group-directories-first BUILD/ BUILDROOT/ RPMS/ SOURCES/ SPECS/ SRPMS/ 2>/dev/null || eza -la --color=always --icons=always --group-directories-first'
alias lcontainer='eza -la --color=always --icons=always *dockerfile* *containerfile* docker-compose.* 2>/dev/null || echo "No container files found"'
alias lsystemd='eza -la --color=always --icons=always /etc/systemd/system/ ~/.config/systemd/user/ 2>/dev/null'

# Package management helpers
alias lflatpak='eza -la --color=always --icons=always ~/.var/app/ 2>/dev/null || echo "No Flatpak apps found"'
alias lsnap='eza -la --color=always --icons=always /snap/ 2>/dev/null || echo "No Snap packages found"'

# Utility functions
ezasize() {
    eza -l --color=always --icons=always --group-directories-first --total-size --color-scale=size --sort=size --reverse "$@"
}

ezarecent() {
    local days=${1:-7}
    eza -la --color=always --icons=always --sort=modified --reverse --color-scale=age "$@" | head -20
}

ezagit() {
    eza -la --color=always --icons=always --group-directories-first --git --git-ignore --header --sort=modified --reverse "$@"
}

ezatree() {
    local depth=${1:-3}
    shift
    eza --tree --color=always --icons=always --group-directories-first --level="$depth" --ignore-glob=".git|node_modules|.cache|__pycache__|.pytest_cache|.mypy_cache|target|build|dist" "$@"
}

# Development environment helpers
ezadev() {
    eza -la --color=always --icons=always --group-directories-first --git --header --sort=modified --reverse --ignore-glob="*.pyc|*.pyo|*.pyd|__pycache__|.pytest_cache|.mypy_cache|node_modules|.cache|target|build|dist" "$@"
}

ezalog() {
    eza -la --color=always --icons=always --sort=modified --reverse /var/log/ "$@" 2>/dev/null | head -20
}

ezasystemd() {
    echo "=== System services ==="
    eza -la --color=always --icons=always /etc/systemd/system/ 2>/dev/null | head -10
    echo -e "\n=== User services ==="
    eza -la --color=always --icons=always ~/.config/systemd/user/ 2>/dev/null | head -10
}

# Security and permissions
ezaperm() {
    eza -la --color=always --icons=always --group-directories-first --octal-permissions "$@"
}

ezasuid() {
    find "$@" -type f -perm /4000 -exec eza -la --color=always --icons=always --octal-permissions {} \; 2>/dev/null
}
```

## Installation

### Fedora 42
```bash
# Install eza from official repositories
sudo dnf install eza

# If not available, install from Copr
sudo dnf copr enable atim/eza
sudo dnf install eza

# Create config directory
mkdir -p ~/.config/eza

# Save the YAML configuration above as ~/.config/eza/theme.yml
```

### Alternative Installation Methods
```bash
# Using Cargo
cargo install eza

# Using Flatpak (if available)
flatpak install eza

# Pre-compiled binary from GitHub releases
curl -L https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz
sudo mv eza /usr/local/bin/
```

## Fedora-Specific Features

### SELinux Integration
```bash
# View SELinux contexts with eza
alias lz='eza -la --color=always --icons=always --group-directories-first --context'

# Function to show SELinux contexts for important directories
ezaselinux() {
    echo "=== SELinux contexts for common directories ==="
    eza -la --color=always --icons=always --context /etc/selinux/ /var/log/audit/ ~/.ssh/ 2>/dev/null
}
```

### Systemd Integration
```bash
# View systemd service files
alias lsystemd-system='eza -la --color=always --icons=always /etc/systemd/system/'
alias lsystemd-user='eza -la --color=always --icons=always ~/.config/systemd/user/'

# Function to show systemd timer files
ezatimers() {
    echo "=== System timers ==="
    eza -la --color=always --icons=always /etc/systemd/system/*.timer 2>/dev/null
    echo -e "\n=== User timers ==="
    eza -la --color=always --icons=always ~/.config/systemd/user/*.timer 2>/dev/null
}
```

### Container Development
```bash
# Enhanced container file viewing
ezacontainers() {
    echo "=== Container files ==="
    eza -la --color=always --icons=always *dockerfile* *containerfile* docker-compose.* podman-compose.* 2>/dev/null
    echo -e "\n=== Container directories ==="
    eza -la --color=always --icons=always --group-directories-first ~/.local/share/containers/ 2>/dev/null
}
```

## Usage Notes

1. **Theme File Location**: Place the `theme.yml` file at `~/.config/eza/theme.yml`
2. **Environment Variables**: LS_COLORS and EZA_COLORS take precedence over the theme file, so make sure to unset them when using a theme file
3. **Color Format**: The theme file uses hex color codes from the Catppuccin Mocha palette
4. **Git Integration**: Enhanced git status visualization for development workflows
5. **Fedora Optimizations**: Special handling for RPM packages, spec files, systemd services, and container files
6. **Icon Support**: Requires a font with icon support (like Nerd Fonts) for best experience
7. **SELinux Aware**: Includes options for viewing SELinux contexts
8. **Container Ready**: Enhanced support for Docker, Podman, and container development

## Features

- **Complete Catppuccin Mocha Implementation**: All file types use appropriate colors from the palette
- **Git Integration**: Color-coded git status indicators
- **Fedora 42 Optimizations**: Special aliases for RPM packaging, systemd services, and container workflows
- **Development Focus**: Enhanced colors for programming languages and config files
- **Security Conscious**: Functions for viewing permissions and SELinux contexts
- **Container Development**: Special handling for Docker, Podman, and container files
- **Comprehensive Coverage**: Support for archives, media, documents, source code, and system files
- **Modern Package Formats**: Support for Flatpak, Snap, and AppImage files
- **Linux Distribution Agnostic**: Core features work across all Linux distributions

## Changelog

### Fixed Issues:
- ✅ Removed duplicate `deb` and `rpm` entries
- ✅ Fixed YAML syntax for `"7z"` and `"~"` keys
- ✅ Added missing `punctuation` section
- ✅ Replaced `file_type` with correct `filekinds` section
- ✅ Added comprehensive `permission` section
- ✅ Added `sticky_other_writable` permission type
- ✅ Alphabetically sorted all extension entries
- ✅ Added missing common file extensions (ico, wma, etc.)
- ✅ Improved color consistency across file types
- ✅ Enhanced documentation with color palette reference
