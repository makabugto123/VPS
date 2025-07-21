#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# URL of the file to download
URL="https://raw.githubusercontent.com/RealBeboy/VPS/refs/heads/main/VPSVNC.sh"
OUTPUT_FILE="$SCRIPT_DIR/VPSVNC.sh"

# Download the file
echo "[*] Downloading VPSVNC.sh..."
curl -s -o "$OUTPUT_FILE" "$URL"

# Make it executable
chmod +x "$OUTPUT_FILE"
echo "[*] Download complete. Running VPSVNC.sh..."

# Run the downloaded script
bash "$OUTPUT_FILE"
