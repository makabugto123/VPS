#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# URL of the file to download
URL="https://raw.githubusercontent.com/RealBeboy/VPS/refs/heads/main/VPSVNC.sh"
OUTPUT_FILE="$SCRIPT_DIR/VPSVNC.sh"

# Download the file
echo "[*] Downloading VPSVNC.sh..."
curl -s -o "$OUTPUT_FILE" "$URL"

# Confirm that the file was downloaded
if [[ -s "$OUTPUT_FILE" ]]; then
    echo "[+] Download successful: $OUTPUT_FILE"
    echo "[*] Running VPSVNC.sh..."
    bash "$OUTPUT_FILE"
else
    echo "[!] Download failed or file is empty. Exiting."
    exit 1
fi
