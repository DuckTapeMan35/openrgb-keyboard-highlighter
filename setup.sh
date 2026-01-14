#!/bin/bash

# OpenRGB Keyboard Highlighter Setup Script for Arch Linux
# This script installs dependencies, sets up the config directory, and creates a systemd service

# Configuration
USER=$(whoami)
CONFIG_DIR="$HOME/.config/openrgb-keyboard-highlighter"
OPENRGB_HIGHLIGHTER="openrgb_highlighter"
SERVICE_NAME="openrgb_highlighter.service"
CONFIG_NAME="config.yaml"

# Create config directory
echo "Creating config directory: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

# Create logs directory
mkdir -p "$CONFIG_DIR/logs"

# Copy script with proper permissions
echo "Copying script to /usr/bin..."
sudo cp "$OPENRGB_HIGHLIGHTER" "/usr/bin/"
sudo chmod +x "/usr/bin/$OPENRGB_HIGHLIGHTER"

# Install Python dependencies
echo "Installing Root Python packages..."
sudo python -m venv /root/openrgb_keyboard_highlighter_venv
sudo /root/openrgb_keyboard_highlighter_venv/bin/pip install --upgrade pip
sudo /root/openrgb_keyboard_highlighter_venv/bin/pip install keyboard openrgb-python watchdog pyyaml i3ipc

# Create default config file if needed
if [ ! -f "$CONFIG_DIR/config.yaml" ]; then
    echo "Creating default config.yaml..."
    cat > "$CONFIG_DIR/config.yaml" << 'EOL'
pywal: false
modes:
  base:
    rules:
      - keys: ['all']
        color: '[255,0,0]'
EOL
fi

# Create systemd service
echo "Creating systemd service..."

# Use current DISPLAY and XAUTHORITY values
CURRENT_DISPLAY=${DISPLAY:-":0"}

cat << EOL | sudo tee "/etc/systemd/system/openrgb_highlighter.service" > /dev/null
[Unit]
Description=Keyboard Highlighter Service
After=graphical.target display-manager.service
Wants=graphical.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/openrgb_highlighter
Environment=DISPLAY=${CURRENT_DISPLAY}
Environment=OPENRGB_USER=$USER

[Install]
WantedBy=default.target
EOL

# Start the service
echo "Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable openrgb_highlighter.service
sudo systemctl start openrgb_highlighter.service

echo "Installation complete!"
echo "The keyboard Listener service is now running."
echo ""
echo "Important: Log out and back in to apply group changes"
echo ""
echo "Service control:"
echo "  sudo systemctl status openrgb_highlighter.service"
echo "  sudo systemctl restart openrgb_highlighter.service"
echo ""
echo "View logs: tail -f $CONFIG_DIR/logs.txt"
echo "Edit config: $CONFIG_DIR/config.yaml"
