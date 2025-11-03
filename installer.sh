#!/bin/sh
#=============================================================
#  GNU Guix Installation Script
#=============================================================

echo "+-------------------------------------------------------------+"
echo "|                  GNU GUIX CONFIGURATION                     |"
echo "|                 [  In Code We Trust  ]                      |"
echo "+-------------------------------------------------------------+"
echo ""

CONFIG_FILE="/mnt/etc/config.scm"
CHANNELS_URL="https://codeberg.org/berkeley/guix-config/raw/branch/main/based-channels.scm"
CHANNELS_FILE="/mnt/etc/channels.scm"

#-------------------------------------------------------------
# Ensure config file exists
#-------------------------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[-] Error: $CONFIG_FILE not found!"
    exit 1
fi

#-------------------------------------------------------------
# Fix malformed (use-modules (gnu)) → (use-modules (gnu)
#-------------------------------------------------------------
echo "[+] Fixing malformed (use-modules (gnu)) entries ..."
sed -i 's/(use-modules *(gnu))/(use-modules (gnu)/g' "$CONFIG_FILE"

#-------------------------------------------------------------
# Add (nongnu packages linux) and (nongnu packages firmware)
# under (use-modules (gnu)
#-------------------------------------------------------------
echo "[+] Ensuring (nongnu packages ...) entries exist..."

if ! grep -q "(nongnu packages linux)" "$CONFIG_FILE"; then
    sed -i '/(use-modules *(gnu)/a\  (nongnu packages linux))' "$CONFIG_FILE"
fi

if ! grep -q "(nongnu packages firmware)" "$CONFIG_FILE"; then
    sed -i '/(use-modules *(gnu)/a\  (nongnu packages firmware)' "$CONFIG_FILE"
fi

#-------------------------------------------------------------
# Add (kernel linux) and (firmware (list linux-firmware))
# under (operating-system
#-------------------------------------------------------------
echo "[+] Ensuring kernel and firmware definitions exist..."

if ! grep -q "(kernel linux)" "$CONFIG_FILE"; then
    sed -i '/(operating-system/a\  (kernel linux)' "$CONFIG_FILE"
fi

if ! grep -q "(firmware (list linux-firmware))" "$CONFIG_FILE"; then
    sed -i '/(operating-system/a\  (firmware (list linux-firmware))' "$CONFIG_FILE"
fi

#-------------------------------------------------------------
# Download channels.scm
#-------------------------------------------------------------
echo "[+] Downloading channels.scm ..."
wget -q "$CHANNELS_URL" -O "$CHANNELS_FILE"

if [ ! -f "$CHANNELS_FILE" ]; then
    echo "[-] Download failed!"
    exit 1
fi

chmod +w "$CHANNELS_FILE"
echo "[✓] channels.scm downloaded and permissions set."

#-------------------------------------------------------------
# Initialize Guix system using time-machine
#-------------------------------------------------------------
echo "[+] Initializing Guix system with time-machine ..."
guix time-machine -C "$CHANNELS_FILE" -- system init "$CONFIG_FILE" /mnt

if [ $? -ne 0 ]; then
    echo "[-] guix system init failed!"
    exit 1
fi

#-------------------------------------------------------------
# Reboot
#-------------------------------------------------------------
echo "[+] Rebooting system now ..."
reboot
