#!/bin/bash
set -e # Exit on error

# Loop until we get a non-empty VPS code
while [ -z "$vpscode" ]; do
  # Force the 'read' prompt to use the controlling terminal (/dev/tty)
  read -p "Enter your VPS code: " vpscode < /dev/tty
  if [ -z "$vpscode" ]; then
    echo "VPS code cannot be empty. Please try again." > /dev/tty
  fi
done

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

# --- START FINAL FIX ---
echo "Setting VNC password non-interactively..."
mkdir -p "$HOME/.vnc"

# Create a temporary file with the password. This is more reliable than piping.
TMP_PASS_FILE=$(mktemp)
echo "$vpscode" > "$TMP_PASS_FILE"

# Feed the temporary file into vncpasswd.
# The command will read the first line for the password and a second (non-existent)
# line for the "verify" step, which is fine.
vncpasswd -f < "$TMP_PASS_FILE"

# Securely remove the temporary password file.
rm -f "$TMP_PASS_FILE"

# Check that the password file was created.
if [ ! -f "$HOME/.vnc/passwd" ]; then
    echo "ERROR: VNC password file was not created. Halting."
    exit 1
fi
echo "VNC password file created successfully."
# --- END FINAL FIX ---

# Initialize VNC config (this will now run without prompting)
echo "Initializing VNC configuration..."
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
# Note: TightVNC passwords are truncated to 8 characters.
echo "🔑 VNC Password is the first 8 characters of your VPS code: ${vpscode:0:8}"
echo "📌 VPS code '${vpscode}' has been applied to /etc/hosts."
