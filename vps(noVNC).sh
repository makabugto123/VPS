#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Add GPG key
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg > /dev/null

# Add repository
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list

# Update and install
sudo apt update
sudo apt install -y playit

# Run playit
playit
