# thefuck performance optimization script

# Create necessary directories
mkdir -p ~/.cache/thefuck
mkdir -p ~/.config/thefuck

# Set proper permissions
chmod 755 ~/.config/thefuck
chmod 644 ~/.config/thefuck/settings.py 2>/dev/null || true
chmod 644 ~/.config/thefuck/fedora_rules.py 2>/dev/null || true

# Clear old cache if it exists
if [[ -d ~/.cache/thefuck ]]; then
    find ~/.cache/thefuck -name "*.pyc" -delete 2>/dev/null || true
    find ~/.cache/thefuck -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
fi

# Precompile Python files for faster loading
if command -v python3 >/dev/null 2>&1; then
    python3 -m compileall ~/.config/thefuck/ 2>/dev/null || true
fi

# Test thefuck installation
if command -v thefuck >/dev/null 2>&1; then
    echo "thefuck is installed and ready"
    thefuck --version
else
    echo "thefuck is not installed or not in PATH"
    exit 1
fi

echo "thefuck optimization complete"
