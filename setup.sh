#!/bin/bash

# OpenRGB Keyboard Highlighter Setup Script for Arch Linux
# This script installs dependencies, sets up the config directory, and creates a systemd service

# Configuration
USER=$(whoami)
CONFIG_DIR="$HOME/.config/openrgb-keyboard-highlighter"
OPENRGB_HIGHLIGHTER="openrgb_highlighter"
OPENRGB_KB_LISTENER="openrgb_kb_listener"
SERVICE_NAME="openrgb_kb_listener.service"
CONFIG_NAME="config.yaml"

check_aur_helper() {
    if command -v yay &> /dev/null; then
        echo "Found yay AUR helper"
        return 0
    elif command -v paru &> /dev/null; then
        echo "Found paru AUR helper"
        return 0
    else
        echo "Error: Neither yay nor paru is installed."
        echo "Please install one of these AUR helpers to continue:"
        echo "  yay: https://github.com/Jguer/yay"
        echo "  paru: https://github.com/Morganamilo/paru"
        exit 1
    fi
}

# Function to install AUR package using available helper
install_aur_package() {
    local package_name="$1"

    # Check if yay is available
    if command -v yay &> /dev/null; then
        echo "Installing $package_name using yay..."
        yay -S --noconfirm "$package_name"
    # Check if other AUR helpers are available (e.g., paru)
    elif command -v paru &> /dev/null; then
        echo "Installing $package_name using paru..."
        paru -S --noconfirm "$package_name"
    else
        echo "No AUR helper found."
}

check_aur_helper

# Create config directory
echo "Creating config directory: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

# Copy scripts to config directory
echo "Copying script and config file to config directory..."
sudo cp "$OPENRGB_HIGHLIGHTER" "/usr/bin/"
sudo cp "$OPENRGB_KB_LISTENER" "/usr/bin/"
chmod +x "/usr/bin/$OPENRGB_HIGHLIGHTER"
chmod +x "/usr/bin/$OPENRGB_KB_LISTENER"

# Install Arch Linux dependencies
echo "Installing $USER required packages..."
sudo pacman -Sy --noconfirm python python-pip openrgb python-watchdog python-yaml

# Install python-openrgb from AUR
install_aur_package "python-openrgb"

# Install Python dependencies
echo "Installing Root Python packages..."
sudo python -m venv /root/openrgb_keyboard_highlighter_venv
sudo /root/openrgb_keyboard_highlighter_venv/bin/pip install --upgrade pip
sudo /root/openrgb_keyboard_highlighter_venv/bin/pip install keyboard psutil

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

cat << EOL | sudo tee "/etc/systemd/system/keyboard-listener.service" > /dev/null
[Unit]
Description=Keyboard Listener Service
After=graphical.target display-manager.service
Wants=graphical.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/openrgb_kb_listener $USER
Environment=DISPLAY=${CURRENT_DISPLAY}

[Install]
WantedBy=default.target
EOL

# Start the service
echo "Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "Installation complete!"
echo "The keyboard Listener service is now running."
echo ""
echo "Important: Log out and back in to apply group changes"
echo ""
echo "Service control:"
echo "  sudo systemctl status $SERVICE_NAME"
echo "  sudo systemctl restart $SERVICE_NAME"
echo ""
echo "View logs: tail -f $CONFIG_DIR/logs.txt"
echo "Edit config: $CONFIG_DIR/config.yaml"
