# Advanced Ripgrep Configuration with Catppuccin Mocha Theme

This configuration provides an optimized ripgrep (`rg`) setup for Gentoo Linux with Catppuccin Mocha theme integration, Zsh enhancements, and quality-of-life improvements.

## 1. Ripgrep Configuration File (`~/.config/ripgrep/ripgreprc`)

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

# Binary handling
--binary
--text

```

## 2. Zsh Integration
Add to your `~/.zshrc`:

```bash
# Ripgrep integration with fzf and bat preview
if command -v rg &>/dev/null; then
    # Enhanced rg search with preview
    function rgf() {
        rg --color=always --heading --line-number "$@" | fzf --ansi \
            --preview 'bat --style=numbers --color=always --line-range :500 {}' \
            --preview-window 'right:60%:wrap'
    }

    # Search for contents and open in vim
    function rge() {
        local file
        local line

        read file line <<< "$(rg --no-heading --line-number $@ | fzf --ansi -0 -1 | awk -F: '{print $1, $2}')"

        if [[ -n $file ]]; then
            ${EDITOR:-nvim} $file +$line
        fi
    }

    # Search for files
    function rgf() {
        rg --files | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
    }

    # Use rg for zsh history search
    function history-rg() {
        history 1 | rg "$@"
    }

    # Use rg with bat for code search
    function rgg() {
        rg -p "$@" | less -RFX
    }

    # Completion enhancements
    compdef _rg rg
fi

# Gentoo-specific optimizations
if [[ -f /etc/gentoo-release ]]; then
    alias rg="rg --max-depth=8" # Gentoo's deep portage tree benefits from depth limit
    alias rgs="rg --type-set 'ebuild:*.ebuild' --type-set 'gentoo:*.ebuild,*.eclass,*.eselect,*.init.d' --type gentoo"
fi
```

## 3. Environment Variables

Add to your `~/.zshrc` or shell profile:

```bash
# Ripgrep environment variables
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/rc"

# Use bat for preview if available (with Catppuccin Mocha theme)
if command -v bat &>/dev/null; then
    export BAT_THEME="Catppuccin-mocha"
    export BAT_STYLE="numbers,changes,header"
    export BAT_PAGER="less -RF"
fi
```

## 4. Gentoo-Specific Installation

For optimal performance on Gentoo:

```bash
# Install with specific USE flags
sudo emerge -av sys-apps/ripgrep \
    app-shells/fzf \
    app-text/bat

# Recommended additional tools
sudo emerge -av \
    dev-vcs/git \
    sys-apps/fd \
    app-misc/jq
```

## 5. Additional Quality-of-Life Scripts

Create `~/.local/bin/rg-gentoo`:

```bash
#!/bin/bash

# Gentoo-specific ripgrep wrapper
case "$1" in
    -p|--portage)
        shift
        rg --type-set 'ebuild:*.ebuild' \
           --type-set 'eclass:*.eclass' \
           --type-set 'gentoo:*.ebuild,*.eclass,*.eselect,*.init.d' \
           --type gentoo \
           --smart-case \
           --hidden \
           --follow \
           "$@"
        ;;
    -k|--kernel)
        shift
        rg --type c \
           --type h \
           --type make \
           --type dts \
           --type dtsi \
           --type defconfig \
           --smart-case \
           --hidden \
           --follow \
           "$@"
        ;;
    *)
        rg "$@"
        ;;
esac
```

Make it executable:
```bash
chmod +x ~/.local/bin/rg-gentoo
```

## Usage Tips

1. **Basic search**: `rg pattern`
2. **Gentoo-specific search**: `rg-gentoo -p pattern` (for ebuilds/eclasses)
3. **Interactive search**: `rgf pattern` (with fzf preview)
4. **Edit matching file**: `rge pattern` (opens in $EDITOR)
5. **Search history**: `history-rg pattern`

This configuration provides a highly optimized ripgrep setup with:
- Catppuccin Mocha theme integration
- Zsh completions and helper functions
- Gentoo-specific optimizations
- Performance improvements
- Intelligent default excludes
- Integration with bat and fzf for previews
