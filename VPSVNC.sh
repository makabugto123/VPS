#!/bin/bash
set -e # Exit on error

# --- START FINAL FIX ---
# Check if a VPS code was provided as a command-line argument.
# This is for non-interactive use, e.g., curl ... | bash -s -- <your_code>
if [ -n "$1" ]; then
  vpscode="$1"
else
  # If no argument is provided, loop until we get a non-empty code.
  # Force the 'read' prompt to use the controlling terminal (/dev/tty)
  # instead of stdin, which is being used by the curl pipe.
  while [ -z "$vpscode" ]; do
    read -p "Enter your VPS code: " vpscode < /dev/tty
    if [ -z "$vpscode" ]; then
      # Write the error to the terminal as well.
      echo "VPS code cannot be empty. Please try again." > /dev/tty
    fi
  done
fi
# --- END FINAL FIX ---

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
