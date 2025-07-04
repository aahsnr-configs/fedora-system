# Advanced Ripgrep Configuration for Fedora Linux 42

This configuration provides an optimized ripgrep (`rg`) setup for Fedora Linux 42 with Catppuccin Mocha theme integration, bash/zsh enhancements, and Fedora-specific optimizations including DNF5 package management support.

## 1. Ripgrep Configuration File (`~/.config/ripgrep/ripgreprc`)

Create the directory and file:
```bash
mkdir -p ~/.config/ripgrep
```

Configuration file content:
```bash
# Catppuccin Mocha theme colors
--colors=path:fg:#cba6f7      # Mauve (file paths)
--colors=path:style:bold
--colors=line:fg:#bac2de      # Subtext1 (line numbers)
--colors=line:style:nobold
--colors=column:fg:#9399b2    # Overlay2 (column numbers)
--colors=column:style:nobold
--colors=match:fg:#f5c2e7     # Pink (matches)
--colors=match:style:bold
--colors=separator:fg:#9399b2 # Overlay2 (separators)
--colors=context:fg:#6c7086   # Overlay0 (context lines)

# Performance optimizations
--max-columns=300
--max-columns-preview
--smart-case
--one-file-system
--mmap

# Search preferences
--hidden
--follow
--glob=!.git/
--glob=!.svn/
--glob=!.hg/
--glob=!CVS/
--glob=!.idea/
--glob=!.vscode/
--glob=!*.min.*
--glob=!*.o
--glob=!*.so
--glob=!*.pyc
--glob=!__pycache__/
--glob=!node_modules/
--glob=!target/
--glob=!*.swp
--glob=!*.swo
--glob=!*.aux
--glob=!*.out
--glob=!*.toc
--glob=!*.blg
--glob=!*.bbl
--glob=!*.fls
--glob=!*.fdb_latexmk

# Fedora-specific excludes
--glob=!*.rpm
--glob=!*.dnf
--glob=!*.cache
--glob=!*.tmp
--glob=!*.lock
--glob=!*.log
--glob=!*.pid
--glob=!*.socket
--glob=!*.service.d/
--glob=!*.target.d/
--glob=!/var/cache/dnf/
--glob=!/var/lib/dnf/
--glob=!/var/log/dnf*/
--glob=!/var/lib/rpm/
--glob=!/proc/
--glob=!/sys/
--glob=!/dev/
--glob=!/run/
--glob=!/tmp/
--glob=!/boot/
--glob=!/media/
--glob=!/mnt/

# Binary handling
--binary
--text
```

## 2. Shell Integration

### For Bash (`~/.bashrc`)

```bash
# Ripgrep integration with fzf and bat preview
if command -v rg &>/dev/null; then
    # Enhanced rg search with preview using fzf
    function rgfzf() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        rg --color=always --heading --line-number "$@" | fzf --ansi \
            --preview 'bat --style=numbers --color=always --line-range :500 {1}' \
            --preview-window 'right:60%:wrap' \
            --delimiter ':' \
            --bind 'enter:execute(${EDITOR:-vim} {1} +{2})'
    }

    # Search for contents and open in editor
    function rge() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        local selected
        selected=$(rg --no-heading --line-number "$@" | fzf --ansi -0 -1)
        
        if [[ -n "$selected" ]]; then
            local file=$(echo "$selected" | cut -d: -f1)
            local line=$(echo "$selected" | cut -d: -f2)
            ${EDITOR:-vim} "$file" +"$line"
        fi
    }

    # Search for files by name
    function rgfiles() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        rg --files | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
    }

    # Use rg for bash history search
    function history-rg() {
        history | rg "$@"
    }

    # Use rg with bat for code search
    function rgg() {
        if command -v bat &>/dev/null; then
            rg -p "$@" | bat --style=plain --color=always
        else
            rg -p "$@" | less -RFX
        fi
    }
fi

# Fedora-specific optimizations
if [[ -f /etc/fedora-release ]]; then
    alias rg="rg --max-depth=10" # Fedora's moderate directory depth
    alias rgs="rg --type-set 'spec:*.spec' --type-set 'rpm:*.spec,*.changes,*.patch' --type-set 'fedora:*.spec,*.changes,*.patch,*.service,*.target,*.mount' --type fedora"
    alias rgd="rg --type-set 'dnf:*.repo,*.conf' --type dnf"
    alias rgk="rg --type-set 'kernel:*.config,*.patch,*.spec' --type kernel"
fi
```

### For Zsh (`~/.zshrc`)

```bash
# Ripgrep integration with fzf and bat preview
if command -v rg &>/dev/null; then
    # Enhanced rg search with preview using fzf
    function rgfzf() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        rg --color=always --heading --line-number "$@" | fzf --ansi \
            --preview 'bat --style=numbers --color=always --line-range :500 {1}' \
            --preview-window 'right:60%:wrap' \
            --delimiter ':' \
            --bind 'enter:execute(${EDITOR:-nvim} {1} +{2})'
    }

    # Search for contents and open in editor
    function rge() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        local selected
        selected=$(rg --no-heading --line-number "$@" | fzf --ansi -0 -1)
        
        if [[ -n "$selected" ]]; then
            local file=$(echo "$selected" | cut -d: -f1)
            local line=$(echo "$selected" | cut -d: -f2)
            ${EDITOR:-nvim} "$file" +"$line"
        fi
    }

    # Search for files by name
    function rgfiles() {
        if ! command -v fzf &>/dev/null; then
            echo "fzf not found. Please install fzf first."
            return 1
        fi
        
        rg --files | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
    }

    # Use rg for zsh history search
    function history-rg() {
        history 1 | rg "$@"
    }

    # Use rg with bat for code search
    function rgg() {
        if command -v bat &>/dev/null; then
            rg -p "$@" | bat --style=plain --color=always
        else
            rg -p "$@" | less -RFX
        fi
    }

    # Completion enhancements
    if [[ -f /usr/share/zsh/site-functions/_rg ]]; then
        autoload -U compinit && compinit
    fi
fi

# Fedora-specific optimizations
if [[ -f /etc/fedora-release ]]; then
    alias rg="rg --max-depth=10" # Fedora's moderate directory depth
    alias rgs="rg --type-set 'spec:*.spec' --type-set 'rpm:*.spec,*.changes,*.patch' --type-set 'fedora:*.spec,*.changes,*.patch,*.service,*.target,*.mount' --type fedora"
    alias rgd="rg --type-set 'dnf:*.repo,*.conf' --type dnf"
    alias rgk="rg --type-set 'kernel:*.config,*.patch,*.spec' --type kernel"
fi
```

## 3. Environment Variables

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
# Ripgrep environment variables - FIXED PATH
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

# Use bat for preview if available (with Catppuccin Mocha theme)
if command -v bat &>/dev/null; then
    export BAT_THEME="Catppuccin-mocha"
    export BAT_STYLE="numbers,changes,header"
    export BAT_PAGER="less -RF"
fi

# Fedora-specific environment variables
export FEDORA_RIPGREP_SPEC_PATHS="/usr/src/packages/SPECS:/home/$USER/rpmbuild/SPECS"
export FEDORA_RIPGREP_SOURCE_PATHS="/usr/src/packages/SOURCES:/home/$USER/rpmbuild/SOURCES"
```

## 4. Fedora-Specific Installation

Install ripgrep and complementary tools using DNF:

```bash
# Install ripgrep and complementary tools
sudo dnf install ripgrep fzf bat git fd-find jq

# Note: Some packages might have different names:
# - fd-find (not just 'fd' in some repos)
# - bat might be 'batcat' in some versions

# Verify installations
rg --version
fzf --version
bat --version
fd --version

# Optional: Install development tools for RPM building
sudo dnf install rpm-build rpm-devel rpmdevtools

# Optional: Install additional development tools
sudo dnf install git-delta tokei exa zoxide
```

## 5. Fedora-Specific Helper Scripts

Create `~/.local/bin/rg-fedora`:

```bash
#!/bin/bash

# Fedora-specific ripgrep wrapper
# Ensure the script fails on errors
set -e

# Function to check if directory exists before searching
search_if_exists() {
    local dirs=("$@")
    local existing_dirs=()
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            existing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#existing_dirs[@]} -eq 0 ]]; then
        echo "No valid directories found for search."
        return 1
    fi
    
    echo "${existing_dirs[@]}"
}

case "$1" in
    -s|--spec)
        shift
        dirs=($(search_if_exists /usr/src/packages/SPECS ~/rpmbuild/SPECS))
        if [[ $? -eq 0 ]]; then
            rg --type-set 'spec:*.spec' \
               --type-set 'rpm:*.spec,*.changes,*.patch' \
               --type-set 'fedora:*.spec,*.changes,*.patch,*.service,*.target,*.mount' \
               --type fedora \
               --smart-case \
               --hidden \
               --follow \
               --glob='!*.rpm' \
               --glob='!*.cache' \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -d|--dnf)
        shift
        dirs=($(search_if_exists /etc/yum.repos.d /etc/dnf /var/lib/dnf))
        if [[ $? -eq 0 ]]; then
            rg --type-set 'dnf:*.repo,*.conf' \
               --type dnf \
               --smart-case \
               --hidden \
               --follow \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -k|--kernel)
        shift
        dirs=($(search_if_exists /usr/src/kernels /lib/modules))
        if [[ $? -eq 0 ]]; then
            rg --type c \
               --type h \
               --type make \
               --type-set 'kernel:*.config,*.patch,*.spec' \
               --type kernel \
               --smart-case \
               --hidden \
               --follow \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -r|--rpm)
        shift
        dirs=($(search_if_exists ~/rpmbuild /usr/src/packages))
        if [[ $? -eq 0 ]]; then
            rg --type-set 'rpm:*.spec,*.changes,*.patch' \
               --type rpm \
               --smart-case \
               --hidden \
               --follow \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -c|--config)
        shift
        dirs=($(search_if_exists /etc ~/.config))
        if [[ $? -eq 0 ]]; then
            rg --smart-case \
               --hidden \
               --follow \
               --glob='*.conf' \
               --glob='*.config' \
               --glob='*.cfg' \
               --glob='*.ini' \
               --glob='*.toml' \
               --glob='*.yaml' \
               --glob='*.yml' \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -l|--logs)
        shift
        dirs=($(search_if_exists /var/log /run/log))
        if [[ $? -eq 0 ]]; then
            rg --smart-case \
               --hidden \
               --follow \
               --glob='*.log' \
               --glob='*.journal' \
               --type-set 'log:*.log,*.journal' \
               --type log \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -p|--packages)
        shift
        dirs=($(search_if_exists /usr/share/doc /usr/share/man))
        if [[ $? -eq 0 ]]; then
            rg --smart-case \
               --hidden \
               --follow \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -h|--help)
        echo "Usage: rg-fedora [OPTION] PATTERN"
        echo "Fedora-specific ripgrep wrapper"
        echo ""
        echo "Options:"
        echo "  -s, --spec        Search RPM spec files"
        echo "  -d, --dnf         Search DNF configuration files"
        echo "  -k, --kernel      Search kernel source files"
        echo "  -r, --rpm         Search RPM build directories"
        echo "  -c, --config      Search configuration files"
        echo "  -l, --logs        Search log files"
        echo "  -p, --packages    Search package documentation"
        echo "  -h, --help        Show this help message"
        echo ""
        echo "Examples:"
        echo "  rg-fedora -s 'BuildRequires'"
        echo "  rg-fedora -d 'baseurl'"
        echo "  rg-fedora -l 'error'"
        ;;
    *)
        rg "$@"
        ;;
esac
```

Make it executable:
```bash
chmod +x ~/.local/bin/rg-fedora
```

## 6. Advanced Fedora Integration

Create `~/.local/bin/rg-dnf`:

```bash
#!/bin/bash

# DNF-specific ripgrep helper
set -e

# Function to check if directory exists before searching
search_if_exists() {
    local dirs=("$@")
    local existing_dirs=()
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            existing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#existing_dirs[@]} -eq 0 ]]; then
        echo "No valid directories found for search."
        return 1
    fi
    
    echo "${existing_dirs[@]}"
}

case "$1" in
    -m|--metadata)
        shift
        dirs=($(search_if_exists /var/cache/dnf /var/lib/dnf))
        if [[ $? -eq 0 ]]; then
            rg --smart-case \
               --hidden \
               --follow \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -h|--history)
        shift
        # Search DNF history and log files
        files=()
        [[ -f /var/lib/dnf/history.sqlite ]] && files+=(/var/lib/dnf/history.sqlite)
        [[ -f /var/log/dnf.log ]] && files+=(/var/log/dnf.log)
        [[ -f /var/log/dnf.rpm.log ]] && files+=(/var/log/dnf.rpm.log)
        
        if [[ ${#files[@]} -gt 0 ]]; then
            rg --smart-case \
               --hidden \
               --follow \
               "$@" \
               "${files[@]}"
        else
            echo "No DNF history or log files found."
        fi
        ;;
    -r|--repos)
        shift
        dirs=($(search_if_exists /etc/yum.repos.d /etc/dnf/repos.d))
        if [[ $? -eq 0 ]]; then
            rg --smart-case \
               --hidden \
               --follow \
               "$@" \
               "${dirs[@]}"
        fi
        ;;
    -h|--help)
        echo "Usage: rg-dnf [OPTION] PATTERN"
        echo "DNF-specific ripgrep helper"
        echo ""
        echo "Options:"
        echo "  -m, --metadata    Search DNF metadata"
        echo "  -h, --history     Search DNF history and logs"
        echo "  -r, --repos       Search repository files"
        echo "  --help            Show this help message"
        echo ""
        echo "Examples:"
        echo "  rg-dnf -m 'package-name'"
        echo "  rg-dnf -h 'install'"
        echo "  rg-dnf -r 'baseurl'"
        ;;
    *)
        echo "Usage: rg-dnf [OPTION] PATTERN"
        echo "Use 'rg-dnf --help' for more information."
        exit 1
        ;;
esac
```

Make it executable:
```bash
chmod +x ~/.local/bin/rg-dnf
```

## 7. Usage Examples

### Basic Usage
1. **Basic search**: `rg pattern`
2. **Interactive search**: `rgfzf pattern` (with fzf preview)
3. **Edit matching file**: `rge pattern` (opens in $EDITOR)
4. **Search history**: `history-rg pattern`
5. **Search files by name**: `rgfiles`

### Fedora-Specific Usage
1. **Search RPM specs**: `rg-fedora -s 'BuildRequires'`
2. **Search DNF configs**: `rg-fedora -d 'baseurl'`
3. **Search kernel sources**: `rg-fedora -k 'CONFIG_'`
4. **Search system configs**: `rg-fedora -c 'localhost'`
5. **Search logs**: `rg-fedora -l 'error'`
6. **Search DNF metadata**: `rg-dnf -m 'package-name'`
7. **Search DNF history**: `rg-dnf -h 'install'`

### Performance Tips for Fedora
- Use `--max-depth=10` for most searches (Fedora has moderate directory depth)
- Exclude common cache directories (`/var/cache/dnf`, `/var/lib/dnf`)
- Use type filters for specific file types (`.spec`, `.repo`, `.conf`)
- Leverage Fedora's structured directory layout for targeted searches

## 8. Integration with Common Fedora Tools

### With RPM Development
```bash
# Search in RPM build directories
alias rg-rpm="rg --type-set 'rpm:*.spec,*.patch,*.changes' --type rpm"

# Search in specific RPM build stages
alias rg-build="rg --glob='*/BUILD/*' --glob='*/BUILDROOT/*'"
```

### With SystemD
```bash
# Search systemd service files
alias rg-systemd="rg --type-set 'systemd:*.service,*.target,*.mount,*.socket' --type systemd"
```

### With Vim/Neovim Integration
```bash
# Add to your .vimrc or init.vim
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m
```

## 9. Troubleshooting

### Common Issues and Solutions

1. **Config file not loading**: 
   - Check `echo $RIPGREP_CONFIG_PATH` points to the correct file
   - Verify the file exists and is readable

2. **fzf integration not working**:
   - Ensure fzf is installed: `dnf install fzf`
   - Check if fzf shell integration is enabled

3. **bat preview not showing**:
   - Install bat: `dnf install bat`
   - Set BAT_THEME if needed

4. **Helper scripts not found**:
   - Ensure `~/.local/bin` is in your PATH
   - Check script permissions: `chmod +x ~/.local/bin/rg-*`

This configuration provides a highly optimized ripgrep setup for Fedora Linux 42 with:
- Correct configuration file paths and environment variables
- Robust error handling in shell functions and scripts
- Fedora-specific optimizations for DNF, RPM, and systemd
- Performance improvements tailored to Fedora's directory structure
- Intelligent default excludes for Fedora-specific cache and temporary files
- Integration with bat and fzf for enhanced previews
- Specialized tools for RPM development and system administration
- Comprehensive troubleshooting section
