# Complete Guide: Making Flatpak Apps Easier to Run from Terminal in Fedora

## Prerequisites: Ensure Flatpak is Properly Installed

Flatpak has been installed by default on Fedora Workstation since Fedora 24. However, let's verify and ensure system-wide installation is configured correctly.

### 1. Verify Flatpak Installation

```bash
# Check if Flatpak is installed
flatpak --version

# If not installed, install it system-wide
sudo dnf install flatpak -y
```

### 2. Enable Flathub Repository (System-Wide)

Flatpak commands are run system-wide by default, which is the recommended approach for day-to-day usage:

```bash
# Add Flathub repository system-wide (recommended)
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Verify the repository is added
flatpak remotes
```

### 3. Install Applications System-Wide

When installing Flatpak applications, use the default system-wide installation:

```bash
# Install apps system-wide (default behavior)
sudo flatpak install flathub com.spotify.Client -y
sudo flatpak install flathub com.visualstudio.code -y
sudo flatpak install flathub org.mozilla.firefox -y

# List installed system apps
flatpak list --app
```

**Note:** System-wide installations are available to all users on the system and can be updated by any user with administrator privileges.

## Why This Guide Matters

By default, running Flatpak applications requires typing long commands like `flatpak run com.spotify.Client`. This guide provides safe, effective methods to create short, memorable commands for your system-wide Flatpak apps.

## Method 1: Bash Aliases (Recommended)

This is the safest and most flexible approach that works for all users with system-wide Flatpak installations.

### Quick Setup

1. **Find your installed system Flatpak apps:**
```bash
# List all system-wide installed apps
flatpak list --app --columns=application

# Show more details including app IDs
flatpak list --app --columns=application,name,origin
```

2. **Create aliases in `~/.bashrc`:**
```bash
# Add to ~/.bashrc
alias spotify="flatpak run com.spotify.Client"
alias code="flatpak run com.visualstudio.code"
alias firefox="flatpak run org.mozilla.firefox"
alias discord="flatpak run com.discordapp.Discord"
alias vlc="flatpak run org.videolan.VLC"
alias gimp="flatpak run org.gimp.GIMP"
alias libreoffice="flatpak run org.libreoffice.LibreOffice"
alias telegram="flatpak run org.telegram.desktop"
alias flatseal="flatpak run com.github.tchx84.Flatseal"
```

3. **Reload your shell:**
```bash
source ~/.bashrc
```

### For Apps That Need Arguments

Use functions instead of aliases for applications that commonly receive command-line arguments:

```bash
# Add to ~/.bashrc
vscode() { flatpak run com.visualstudio.code "$@"; }
gimp() { flatpak run org.gimp.GIMP "$@"; }
libreoffice() { flatpak run org.libreoffice.LibreOffice "$@"; }
vlc() { flatpak run org.videolan.VLC "$@"; }
```

## Method 2: Dedicated Aliases File (Clean Organization)

For better organization, create a separate file for all your aliases:

1. **Create the aliases file:**
```bash
touch ~/.bash_aliases
```

2. **Add your Flatpak aliases:**
```bash
cat >> ~/.bash_aliases << 'EOF'
# Flatpak Application Aliases (System-Wide Installations)
alias spotify="flatpak run com.spotify.Client"
alias code="flatpak run com.visualstudio.code"
alias firefox="flatpak run org.mozilla.firefox"
alias discord="flatpak run com.discordapp.Discord"
alias vlc="flatpak run org.videolan.VLC"
alias gimp="flatpak run org.gimp.GIMP"
alias libreoffice="flatpak run org.libreoffice.LibreOffice"
alias audacity="flatpak run org.audacityteam.Audacity"
alias telegram="flatpak run org.telegram.desktop"
alias flatseal="flatpak run com.github.tchx84.Flatseal"
alias blender="flatpak run org.blender.Blender"
alias inkscape="flatpak run org.inkscape.Inkscape"

# Functions for apps that need arguments
vscode() { flatpak run com.visualstudio.code "$@"; }
lo() { flatpak run org.libreoffice.LibreOffice "$@"; }
vlc-play() { flatpak run org.videolan.VLC "$@"; }
gimp-edit() { flatpak run org.gimp.GIMP "$@"; }
EOF
```

3. **Ensure your `~/.bashrc` sources the file:**
```bash
# Check if already sourced
if ! grep -q "bash_aliases" ~/.bashrc; then
    echo '
# Load bash aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi' >> ~/.bashrc
fi
```

4. **Reload your shell:**
```bash
source ~/.bashrc
```

## Method 3: System-Wide Aliases (For All Users)

If you want these shortcuts available to all users on the system (useful for multi-user systems):

1. **Create a system-wide aliases file:**
```bash
sudo tee /etc/profile.d/flatpak-aliases.sh << 'EOF'
#!/bin/bash
# System-wide Flatpak aliases for system-wide installations

# Common Flatpak application shortcuts
alias spotify="flatpak run com.spotify.Client"
alias code="flatpak run com.visualstudio.code"
alias firefox="flatpak run org.mozilla.firefox"
alias discord="flatpak run com.discordapp.Discord"
alias vlc="flatpak run org.videolan.VLC"
alias gimp="flatpak run org.gimp.GIMP"
alias libreoffice="flatpak run org.libreoffice.LibreOffice"
alias telegram="flatpak run org.telegram.desktop"
alias flatseal="flatpak run com.github.tchx84.Flatseal"
EOF
```

2. **Make it executable:**
```bash
sudo chmod +x /etc/profile.d/flatpak-aliases.sh
```

3. **Restart your session** for changes to take effect.

## Automated Setup Script

Here's an improved script that automatically detects your system-wide Flatpak apps and creates appropriate aliases:

```bash
#!/bin/bash

# Flatpak Terminal Shortcuts Setup Script for Fedora
# This script creates convenient aliases for system-wide Flatpak applications

ALIASES_FILE="$HOME/.bash_aliases"
BASHRC_FILE="$HOME/.bashrc"

echo "=== Flatpak Terminal Shortcuts Setup ==="
echo "Setting up aliases for system-wide Flatpak applications..."

# Check if Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo "❌ Flatpak is not installed. Installing..."
    sudo dnf install flatpak -y
fi

# Check if Flathub is enabled
if ! flatpak remotes | grep -q flathub; then
    echo "❌ Flathub repository not found. Adding system-wide..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Create aliases file if it doesn't exist
if [ ! -f "$ALIASES_FILE" ]; then
    touch "$ALIASES_FILE"
    echo "✓ Created $ALIASES_FILE"
fi

# Ensure .bashrc sources the aliases file
if ! grep -q "bash_aliases" "$BASHRC_FILE"; then
    echo "" >> "$BASHRC_FILE"
    echo "# Load bash aliases" >> "$BASHRC_FILE"
    echo "if [ -f ~/.bash_aliases ]; then" >> "$BASHRC_FILE"
    echo "    . ~/.bash_aliases" >> "$BASHRC_FILE"
    echo "fi" >> "$BASHRC_FILE"
    echo "✓ Added aliases sourcing to .bashrc"
fi

# Remove existing flatpak aliases to avoid duplicates
sed -i '/# Flatpak Application Aliases/,/^$/d' "$ALIASES_FILE"

# Add header
echo "" >> "$ALIASES_FILE"
echo "# Flatpak Application Aliases (System-Wide Installations)" >> "$ALIASES_FILE"
echo "# Generated on $(date)" >> "$ALIASES_FILE"
echo "" >> "$ALIASES_FILE"

# Function to add alias if app is installed system-wide
add_alias_if_installed() {
    local app_id="$1"
    local alias_name="$2"
    local use_function="$3"
    
    # Check system-wide installation
    if flatpak list --app --columns=application 2>/dev/null | grep -q "^$app_id$"; then
        if [ "$use_function" = "true" ]; then
            echo "$alias_name() { flatpak run $app_id \"\$@\"; }" >> "$ALIASES_FILE"
            echo "✓ Added function: $alias_name"
        else
            echo "alias $alias_name=\"flatpak run $app_id\"" >> "$ALIASES_FILE"
            echo "✓ Added alias: $alias_name"
        fi
    else
        echo "⚠ Skipping $alias_name ($app_id not installed system-wide)"
    fi
}

# Popular applications with intuitive aliases
echo "Checking for popular system-wide applications..."
add_alias_if_installed "com.spotify.Client" "spotify"
add_alias_if_installed "com.visualstudio.code" "code"
add_alias_if_installed "org.mozilla.firefox" "firefox"
add_alias_if_installed "com.discordapp.Discord" "discord"
add_alias_if_installed "org.videolan.VLC" "vlc"
add_alias_if_installed "org.gimp.GIMP" "gimp"
add_alias_if_installed "org.libreoffice.LibreOffice" "libreoffice"
add_alias_if_installed "org.audacityteam.Audacity" "audacity"
add_alias_if_installed "org.blender.Blender" "blender"
add_alias_if_installed "org.inkscape.Inkscape" "inkscape"
add_alias_if_installed "org.telegram.desktop" "telegram"
add_alias_if_installed "com.github.tchx84.Flatseal" "flatseal"
add_alias_if_installed "org.gnome.Extensions" "gnome-extensions"
add_alias_if_installed "com.mattjakeman.ExtensionManager" "extension-manager"
add_alias_if_installed "org.kde.kdenlive" "kdenlive"
add_alias_if_installed "com.obsproject.Studio" "obs"
add_alias_if_installed "org.mozilla.Thunderbird" "thunderbird"
add_alias_if_installed "com.brave.Browser" "brave"
add_alias_if_installed "org.chromium.Chromium" "chromium"

# Applications that commonly need command-line arguments
echo "" >> "$ALIASES_FILE"
echo "# Functions for apps that commonly use arguments" >> "$ALIASES_FILE"
add_alias_if_installed "com.visualstudio.code" "vscode" "true"
add_alias_if_installed "org.libreoffice.LibreOffice" "lo" "true"
add_alias_if_installed "org.gimp.GIMP" "gimp-edit" "true"
add_alias_if_installed "org.videolan.VLC" "vlc-play" "true"

echo ""
echo "=== Setup Complete! ==="
echo "Run 'source ~/.bashrc' or restart your terminal to activate aliases."
echo ""
echo "Your new shortcuts:"
if [ -f "$ALIASES_FILE" ]; then
    grep -E "^alias|^[a-z].*\(\)" "$ALIASES_FILE" | grep -v "^#" | sed 's/alias /  /' | sed 's/="flatpak run / -> /' | sed 's/"$//' | sed 's/() { flatpak run / -> /' | sed 's/ "$@"; }//'
fi

echo ""
echo "System-wide Flatpak apps installed:"
flatpak list --app --columns=application,name | head -10
```

## Managing System-Wide Flatpak Applications

### Installing New Apps System-Wide
```bash
# Install apps system-wide (requires sudo)
sudo flatpak install flathub com.spotify.Client -y
sudo flatpak install flathub org.gimp.GIMP -y

# Install multiple apps at once
sudo flatpak install flathub com.spotify.Client org.gimp.GIMP org.mozilla.firefox -y
```

### Updating System-Wide Apps
```bash
# Update all system-wide apps
sudo flatpak update -y

# Update specific app
sudo flatpak update com.spotify.Client -y
```

### Removing System-Wide Apps
```bash
# Remove specific app
sudo flatpak uninstall com.spotify.Client -y

# Remove unused runtimes
sudo flatpak uninstall --unused -y
```

## Best Practices for System-Wide Flatpak

1. **Use system-wide installation:** For day-to-day usage, stick with system-wide installation
2. **Use intuitive names:** Choose aliases that match what you'd naturally type
3. **Avoid conflicts:** Don't use names that conflict with system commands (check with `which command`)
4. **Check for updates:** When you install new Flatpak apps, add their aliases
5. **Use functions for complex apps:** Apps that need arguments work better as functions
6. **Keep it organized:** Use a separate `.bash_aliases` file for better maintenance
7. **Test aliases:** Always test new aliases before finalizing them

## Testing Your Setup

After setting up aliases, test them:

```bash
# Test simple aliases
spotify
code
firefox
vlc

# Test functions with arguments
vscode ~/myproject
gimp ~/image.png
vlc-play ~/video.mp4
lo ~/document.odt
```

## Troubleshooting

### Common Issues and Solutions

**Aliases not working?**
- Check if `.bash_aliases` is sourced in `.bashrc`: `grep -n "bash_aliases" ~/.bashrc`
- Reload your shell: `source ~/.bashrc`
- Verify the Flatpak app ID: `flatpak list --app --columns=application`

**App not starting?**
- Check if the app is installed system-wide: `flatpak list --app | grep appname`
- Try running directly: `flatpak run com.application.Name`
- Verify Flathub is enabled: `flatpak remotes`
- Check for typos in app ID: `flatpak search appname`

**Permission issues?**
- System-wide installations require sudo for install/update/remove
- Running apps doesn't require sudo once installed
- Check user permissions: `groups $USER`

**Alias conflicts?**
- Check if command exists: `which commandname`
- Use a different alias name or prefix (e.g., `fp-spotify`)
- List all aliases: `alias | grep flatpak`

### Debugging Commands

```bash
# Check what's in your aliases file
cat ~/.bash_aliases | grep -E "^alias|^[a-z].*\(\)"

# Test if alias exists
type aliasname

# Check Flatpak installation
flatpak --version
flatpak remotes
flatpak list --app | wc -l

# Check shell configuration
echo $SHELL
ls -la ~/.bashrc ~/.bash_aliases
```

## Advanced Tips

### Creating Custom Shortcuts for App Categories

```bash
# Create shortcuts for different app categories
alias media="echo 'Media Apps:'; echo '  vlc, audacity, gimp, inkscape, blender'"
alias office="echo 'Office Apps:'; echo '  libreoffice, lo'"
alias dev="echo 'Development:'; echo '  code, vscode'"
alias social="echo 'Social:'; echo '  discord, telegram, spotify'"
```

### Auto-completion for Flatpak Commands

Add to your `.bashrc`:
```bash
# Enable bash completion for flatpak
if [ -f /usr/share/bash-completion/completions/flatpak ]; then
    . /usr/share/bash-completion/completions/flatpak
fi
```

### Backup and Restore Aliases

```bash
# Backup aliases
cp ~/.bash_aliases ~/.bash_aliases.backup

# Restore aliases
cp ~/.bash_aliases.backup ~/.bash_aliases
source ~/.bashrc
```

This approach provides a clean, maintainable way to access your system-wide Flatpak applications from the terminal, following Fedora's default configuration and best practices.
