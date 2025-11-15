#!/bin/sh
#=============================================================
# GNU Guix Installer Script
#=============================================================

echo "+-------------------------------------------------------------+"
echo "|                  GNU GUIX INSTALLATION                      |"
echo "|                  [ In Code We Trust ]                       |"
echo "+-------------------------------------------------------------+"
echo ""

CONFIG_FILE="/mnt/etc/config.scm"
CHANNELS_URL="https://codeberg.org/berkeley/guix-install/raw/branch/main/channel.scm"
CHANNELS_FILE="/mnt/etc/channels.scm"

#-------------------------------------------------------------
# Ensure config.scm exists
#-------------------------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[-] Error: $CONFIG_FILE not found!"
    exit 1
fi

#-------------------------------------------------------------
# Start herd and cow-store
#-------------------------------------------------------------
echo "[+] Starting herd cow-store /mnt ..."
herd start cow-store /mnt

#-------------------------------------------------------------
# Fix malformed (use-modules (gnu)) → (use-modules (gnu)
#-------------------------------------------------------------
echo "[+] Fixing malformed (use-modules (gnu)) entries ..."
sed -i 's/(use-modules *(gnu))/(use-modules (gnu)/g' "$CONFIG_FILE"

#-------------------------------------------------------------
# Add nongnu package modules under (use-modules (gnu)
#-------------------------------------------------------------
echo "[+] Ensuring (nongnu packages linux) and (nongnu packages firmware) exist..."

if ! grep -q "(nongnu packages linux)" "$CONFIG_FILE"; then
    sed -i '/(use-modules *(gnu)/a\ (nongnu packages linux))' "$CONFIG_FILE"
fi

if ! grep -q "(nongnu packages firmware)" "$CONFIG_FILE"; then
    sed -i '/(use-modules *(gnu)/a\ (nongnu packages firmware)' "$CONFIG_FILE"
fi

#-------------------------------------------------------------
# Add kernel and firmware fields under (operating-system
#-------------------------------------------------------------
echo "[+] Ensuring kernel and firmware entries exist..."

if ! grep -q "(firmware (list linux-firmware))" "$CONFIG_FILE"; then
    sed -i '/(operating-system/a\ (firmware (list linux-firmware))' "$CONFIG_FILE"
fi

if ! grep -q "(kernel linux)" "$CONFIG_FILE"; then
    sed -i '/(operating-system/a\ (kernel linux)' "$CONFIG_FILE"
fi

#-------------------------------------------------------------
# Make channels.scm writable before downloading
#-------------------------------------------------------------
echo "[+] Setting write permissions for channels.scm ..."
chmod +w "$CHANNELS_FILE" 2>/dev/null

#-------------------------------------------------------------
# Download channels.scm into /mnt/etc/
#-------------------------------------------------------------
echo "[+] Downloading channels.scm ..."
wget -q "$CHANNELS_URL" -O "$CHANNELS_FILE"

if [ ! -f "$CHANNELS_FILE" ]; then
    echo "[-] Download failed!"
    exit 1
fi

chmod +w "$CHANNELS_FILE"
echo "[✓] channels.scm downloaded successfully and permissions set."

#-------------------------------------------------------------
# Initialize Guix system using time-machine
#-------------------------------------------------------------
echo "[+] Initializing Guix system ..."
guix time-machine -C "$CHANNELS_FILE" -- system init "$CONFIG_FILE" /mnt

if [ $? -ne 0 ]; then
    echo "[-] guix system init failed!"
    exit 1
fi

#-------------------------------------------------------------
# Reboot system
#-------------------------------------------------------------
echo "[+] Installation complete. Rebooting ..."
reboot
