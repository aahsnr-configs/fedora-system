``````
#!/bin/bash

# Hyprland Plugin Auto-Update System Service
# This creates a systemd service that automatically runs hyprpm update when hyprland-git is updated

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Run as a regular user."
    exit 1
fi

# Check if hyprland-git is installed
if ! rpm -q hyprland-git >/dev/null 2>&1; then
    print_error "hyprland-git package not found. Please install it first."
    exit 1
fi

# Check if hyprpm is available
if ! command -v hyprpm >/dev/null 2>&1; then
    print_error "hyprpm not found in PATH. Please ensure Hyprland is properly installed."
    exit 1
fi

# Create the service directories
SERVICE_DIR="$HOME/.config/systemd/user"
SCRIPT_DIR="$HOME/.local/bin"

mkdir -p "$SERVICE_DIR"
mkdir -p "$SCRIPT_DIR"

# Create the update script
cat > "$SCRIPT_DIR/hyprpm-auto-update.sh" << 'EOF'
#!/bin/bash

# Hyprland Plugin Auto-Update Script
# This script runs hyprpm update when hyprland-git is updated

LOG_FILE="$HOME/.local/share/hyprpm-auto-update.log"
LOCK_FILE="$HOME/.local/share/hyprpm-auto-update.lock"
LAST_UPDATE_FILE="$HOME/.local/share/hyprpm-last-update"

# Create directories if they don't exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$LOCK_FILE")"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if another instance is running
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        log_message "Another instance is already running (PID: $PID). Exiting."
        exit 0
    else
        log_message "Removing stale lock file"
        rm -f "$LOCK_FILE"
    fi
fi

# Create lock file
echo $$ > "$LOCK_FILE"

# Function to cleanup on exit
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

log_message "Starting hyprpm auto-update"

# Get current hyprland-git version
CURRENT_VERSION=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}' hyprland-git 2>/dev/null)
if [ $? -ne 0 ]; then
    log_message "Failed to get hyprland-git version. Exiting."
    exit 1
fi

# Check if this is the first run or if version has changed
if [ -f "$LAST_UPDATE_FILE" ]; then
    LAST_VERSION=$(cat "$LAST_UPDATE_FILE")
    if [ "$CURRENT_VERSION" = "$LAST_VERSION" ]; then
        log_message "hyprland-git version unchanged ($CURRENT_VERSION). No update needed."
        exit 0
    fi
    log_message "hyprland-git version changed from $LAST_VERSION to $CURRENT_VERSION"
else
    log_message "First run detected. Current hyprland-git version: $CURRENT_VERSION"
fi

# Check if hyprpm is available
if ! command -v hyprpm >/dev/null 2>&1; then
    log_message "hyprpm not found in PATH. Skipping plugin update."
    echo "$CURRENT_VERSION" > "$LAST_UPDATE_FILE"
    exit 0
fi

# Run hyprpm update
log_message "Running hyprpm update..."
if hyprpm update 2>&1 | tee -a "$LOG_FILE"; then
    log_message "hyprpm update completed successfully"
    echo "$CURRENT_VERSION" > "$LAST_UPDATE_FILE"
else
    log_message "hyprpm update failed with exit code $?"
    exit 1
fi

log_message "hyprpm auto-update completed"
EOF

# Make the script executable
chmod +x "$SCRIPT_DIR/hyprpm-auto-update.sh"

# Create the systemd service file
cat > "$SERVICE_DIR/hyprpm-auto-update.service" << EOF
[Unit]
Description=Hyprland Plugin Auto-Update Service
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_DIR/hyprpm-auto-update.sh
EOF

# Create DNF post-transaction action
DNF_ACTION_DIR="/etc/dnf/plugins/post-transaction-actions.d"
DNF_ACTION_FILE="$DNF_ACTION_DIR/hyprpm-update.action"

# Check if we can create the DNF action file
if [ -w "/etc/dnf/plugins" ] || [ -w "$DNF_ACTION_DIR" ] 2>/dev/null; then
    print_status "Creating DNF post-transaction action..."
    
    # Create the action file content
    DNF_ACTION_CONTENT="hyprland-git:install,update:/usr/bin/runuser -l $USER -c 'systemctl --user start hyprpm-auto-update.service'"
    
    cat > "$HOME/.hyprpm-dnf-action.tmp" << EOF
$DNF_ACTION_CONTENT
EOF
    
    print_status "DNF action file content created at $HOME/.hyprpm-dnf-action.tmp"
    print_status "To enable automatic updates on package installation, run as root:"
    print_status "  mkdir -p $DNF_ACTION_DIR"
    print_status "  cp $HOME/.hyprpm-dnf-action.tmp $DNF_ACTION_FILE"
    print_status "  dnf install dnf-plugins-core  # if not already installed"
    
else
    print_warning "Cannot create DNF post-transaction action (requires root). Manual setup instructions provided below."
fi

# Create manual trigger script
cat > "$SCRIPT_DIR/hyprpm-manual-trigger.sh" << 'EOF'
#!/bin/bash
# Manual trigger script for hyprpm update
systemctl --user start hyprpm-auto-update.service
EOF

chmod +x "$SCRIPT_DIR/hyprpm-manual-trigger.sh"

# Reload systemd user daemon
systemctl --user daemon-reload

print_status "Created hyprpm auto-update service files:"
print_status "  - Service: $SERVICE_DIR/hyprpm-auto-update.service"
print_status "  - Update Script: $SCRIPT_DIR/hyprpm-auto-update.sh"
print_status "  - Manual Trigger: $SCRIPT_DIR/hyprpm-manual-trigger.sh"

print_status "Setup complete!"
print_status ""
print_status "USAGE OPTIONS:"
print_status "1. Manual trigger after hyprland-git updates:"
print_status "   $SCRIPT_DIR/hyprpm-manual-trigger.sh"
print_status ""
print_status "2. Test the service:"
print_status "   systemctl --user start hyprpm-auto-update.service"
print_status ""
print_status "3. View logs:"
print_status "   journalctl --user -u hyprpm-auto-update.service"
print_status "   tail -f $HOME/.local/share/hyprpm-auto-update.log"
print_status ""
print_status "4. For automatic updates on package installation:"
print_status "   Run as root: mkdir -p $DNF_ACTION_DIR"
print_status "   Run as root: cp $HOME/.hyprpm-dnf-action.tmp $DNF_ACTION_FILE"
print_status "   Install if needed: dnf install dnf-plugins-core"

print_warning "Note: The service will only run hyprpm update when hyprland-git version changes."

# Test the service
read -p "Do you want to test the service now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Testing the service..."
    systemctl --user start hyprpm-auto-update.service
    
    # Show status
    print_status "Service status:"
    systemctl --user status hyprpm-auto-update.service --no-pager
    
    print_status "Recent log entries:"
    tail -n 10 "$HOME/.local/share/hyprpm-auto-update.log" 2>/dev/null || echo "No log entries yet"
fi
``````
