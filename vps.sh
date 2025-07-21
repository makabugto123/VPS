#!/bin/bash
set -e  # Exit on any error

# Ask for VPS code
read -p "Enter your VPS code: " vpscode

# Apply VPS code to /etc/hosts
sudo tee /etc/hosts > /dev/null <<EOF
127.0.0.1       localhost ${vpscode}
::1             localhost ip6-localhost ip6-loopback
fe00::          ip6-localnet
ff00::          ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
172.17.0.2      e91e22096dd8
EOF

# Install required packages including Firefox
sudo apt update && sudo apt install -y \
    xfce4 xfce4-goodies \
    novnc \
    python3-websockify \
    python3-numpy \
    tightvncserver \
    htop nano neofetch firefox

# Generate SSL certificate for noVNC
openssl req -x509 -nodes -newkey rsa:3072 \
    -keyout "$HOME/novnc.pem" -out "$HOME/novnc.pem" -days 3650 \
    -subj "/C=US/ST=None/L=None/O=NoVNC/CN=localhost"

# Start and configure VNC
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
websockify -D --web=/usr/share/novnc/ --cert="$HOME/novnc.pem" 6080 localhost:5901

# Display system info
neofetch

# Output access info
echo ""
echo "✅ Setup complete!"
echo "🌐 Access noVNC at: https://${vpscode}-6080.csb.app/vnc.html"
echo "📌 VPS code '${vpscode}' has been applied to /etc/hosts."
