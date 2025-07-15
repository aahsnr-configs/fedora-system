#!/bin/bash

# Tmux Setup Script for Fedora 42
# Simple automated setup for tmux with TPM and systemd integration

set -e

echo "🚀 Setting up tmux on Fedora 42..."

# Hard-coded path to tmux configuration file
TMUX_CONFIG_FILE="$HOME/.hyprdots/.tmux.conf"

# Install required packages
echo "📦 Installing tmux and dependencies..."
sudo dnf install -y tmux git curl wl-clipboard

# Create tmux directories
echo "📁 Creating tmux directories..."
mkdir -p ~/.tmux/plugins
chmod 700 ~/.tmux

# Backup existing tmux config if it exists
if [ -f ~/.tmux.conf ]; then
    echo "💾 Backing up existing tmux configuration..."
    mv ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)
fi

# Symlink tmux configuration
echo "🔗 Setting up tmux configuration symlink..."
echo "Looking for tmux config at: $TMUX_CONFIG_FILE"

if [ ! -f "$TMUX_CONFIG_FILE" ]; then
    echo "❌ Error: tmux configuration file not found at '$TMUX_CONFIG_FILE'"
    echo "Please update the TMUX_CONFIG_FILE variable in this script to point to your tmux config file."
    exit 1
fi

ln -sf "$TMUX_CONFIG_FILE" ~/.tmux.conf
chmod 600 ~/.tmux.conf
echo "✅ Symlinked $TMUX_CONFIG_FILE to ~/.tmux.conf"

# Install TPM (tmux Plugin Manager)
echo "🔌 Installing TPM (tmux Plugin Manager)..."
if [ -d ~/.tmux/plugins/tpm ]; then
    echo "TPM already exists, updating..."
    cd ~/.tmux/plugins/tpm && git pull
else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Start tmux in detached mode to install plugins
echo "🔧 Installing tmux plugins..."
tmux new-session -d -s setup_session

# Wait for tmux to start
sleep 2

# Install plugins automatically
if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    tmux send-keys -t setup_session "$HOME/.tmux/plugins/tpm/bin/install_plugins" Enter
    # Wait for installation to complete
    sleep 10
else
    echo "⚠️ Warning: TPM install script not found, plugins may need manual installation"
fi

# Kill setup session
tmux kill-session -t setup_session 2>/dev/null || true

# Create systemd user service
echo "⚙️ Creating systemd user service..."
mkdir -p ~/.config/systemd/user

cat >~/.config/systemd/user/tmux.service <<'EOF'
[Unit]
Description=tmux default session (detached)
Documentation=man:tmux(1)
After=graphical-session.target

[Service]
Type=forking
WorkingDirectory=%h
ExecStart=/usr/bin/tmux new-session -d -s main
ExecStop=/usr/bin/tmux kill-session -t main
KillMode=none
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Enable and start tmux service
echo "🚦 Enabling tmux systemd service..."
systemctl --user daemon-reload
systemctl --user enable tmux.service
systemctl --user start tmux.service

# Add useful aliases to bashrc
echo "🔧 Adding tmux aliases..."
if ! grep -q "# tmux aliases" ~/.bashrc 2>/dev/null; then
    cat >>~/.bashrc <<'EOF'

# tmux aliases
alias tm='tmux'
alias tma='tmux attach -t'
alias tmn='tmux new-session -s'
alias tml='tmux list-sessions'
alias tmk='tmux kill-session -t'
alias tmr='tmux source-file ~/.tmux.conf'
EOF
fi

echo "✅ tmux setup complete!"
echo ""
echo "Usage:"
echo "  • Start tmux: tmux or tm"
echo "  • Attach to main session: tmux attach -t main"
echo "  • Prefix key: Ctrl-a"
echo "  • Reload config: Ctrl-a + r"
echo ""
echo "The tmux service will automatically start on login."
echo "Restart your shell or run 'source ~/.bashrc' to use the new aliases."
echo ""
echo "If plugins didn't install automatically, run inside tmux:"
echo "  Ctrl-a + I (capital i) to install plugins"
