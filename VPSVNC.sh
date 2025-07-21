#!/bin/bash
set -e  # Exit on error

# --- START FIX ---
# Check if a VPS code was provided as the first argument
if [ -n "$1" ]; then
  vpscode="$1"
else
  # If no argument, check if the script is running in an interactive terminal
  if [ -t 0 ]; then
    # Prompt for the VPS code if interactive
    read -p "Enter your VPS code: " vpscode
  else
    # Fail with an error if non-interactive and no code was provided
    echo "Error: This script needs a VPS code to continue."
    echo "Usage: $0 <your_vps_code>"
    exit 1
  fi
fi

# Exit if the vpscode is still empty
if [ -z "$vpscode" ]; then
    echo "Error: VPS code cannot be empty."
    exit 1
fi
# --- END FIX ---

# Apply VPS code to /etc/hosts
echo "Applying VPS code '${vpscode}' to /etc/hosts..."
sudo tee /etc/hosts > /dev/null <<EOF
127.0.0.1       localhost ${vpscode}
::1             localhost ip6-localhost ip6-loopback
fe00::          ip6-localnet
ff00::          ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
172.17.0.2      e91e22096dd8
EOF

# Update and install required packages
echo "Updating and installing packages..."
sudo apt update && sudo apt install -y \
    xfce4 xfce4-goodies \
    novnc \
    python3-websockify \
    python3-numpy \
    tightvncserver \
    htop nano neofetch firefox

# Generate SSL certificate for noVNC
echo "Generating SSL certificate..."
openssl req -x509 -nodes -newkey rsa:3072 \
    -keyout "$HOME/novnc.pem" -out "$HOME/novnc.pem" -days 3650 \
    -subj "/C=US/ST=None/L=None/O=NoVNC/CN=localhost"

# Initialize VNC config
echo "Configuring VNC server..."
vncserver
vncserver -kill :1

# Backup and create new xstartup
[ -f "$HOME/.vnc/xstartup" ] && mv "$HOME/.vnc/xstartup" "$HOME/.vnc/xstartup.bak"

cat <<EOF > "$HOME/.vnc/xstartup"
#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &
EOF

chmod +x "$HOME/.vnc/xstartup"

# Start VNC server
vncserver

# Start noVNC (websockify) in background
echo "Starting noVNC service..."
websockify -D --web=/usr/share/novnc/ --cert="$HOME/novnc.pem" 6080 localhost:5901

# Display system info
neofetch

# Output access info
echo ""
echo "✅ Setup complete!"
echo "🌐 Access noVNC at: https://${vpscode}-6080.csb.app/vnc.html"
echo "📌 VPS code '${vpscode}' has been applied to /etc/hosts."
