#!/bin/bash

# Ask for VPS code
read -p "Enter your VPS code: " vpscode

# Correctly apply VPS code to /etc/hosts
sudo tee /etc/hosts > /dev/null <<EOF
127.0.0.1       localhost ${vpscode}
::1     localhost ip6-localhost ip6-loopback
fe00::  ip6-localnet
ff00::  ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.2      e91e22096dd8
EOF

# Install basic packages (no VNC, no Firefox)
sudo apt update && sudo apt install -y \
    htop nano neofetch curl gnupg

# Display system info
neofetch

# Install playit
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install -y playit

# Run playit
playit

# Final message
echo "✅ Setup complete! VPS code '${vpscode}' has been applied to /etc/hosts."
echo "🚀 playit has been installed and started."
