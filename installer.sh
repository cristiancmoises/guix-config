#!/bin/bash
#=============================================================
#  GNU Guix Installation Script
#  [  In Code We Trust  ]
#=============================================================

echo "+-------------------------------------------------------------+"
echo "|                  GNU GUIX INSTALLATION                      |"
echo "|                 [  In Code We Trust  ]                      |"
echo "+-------------------------------------------------------------+"
echo ""

CONFIG_FILE="/mnt/etc/config.scm"
CHANNELS_URL="https://codeberg.org/berkeley/guix-config/raw/branch/main/based-channels.scm"

#-------------------------------------------------------------
# Ensure config file exists
#-------------------------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[-] Error: $CONFIG_FILE does not exist."
    exit 1
fi

#-------------------------------------------------------------
# Insert (nongnu packages linux) and (nongnu packages firmware)
# into (use-modules ...)
#-------------------------------------------------------------
echo "[+] Adding (nongnu packages linux) and (nongnu packages firmware) to (use-modules ...) ..."
sed -i '/(use-modules[[:space:]]*(gnu)/ {
    /nongnu packages linux/! s/))/ (nongnu packages linux))/
}' "$CONFIG_FILE"

sed -i '/(use-modules[[:space:]]*(gnu)/ {
    /nongnu packages firmware/! s/))/ (nongnu packages firmware))/
}' "$CONFIG_FILE"

#-------------------------------------------------------------
# Insert kernel and firmware entries inside (operating-system ...)
#-------------------------------------------------------------
echo "[+] Ensuring kernel and firmware entries exist in (operating-system ...) ..."
sed -i '/(operating-system/,/)/ {
    /kernel linux/! s/))/ (kernel linux))/
}' "$CONFIG_FILE"

sed -i '/(operating-system/,/)/ {
    /firmware (list linux-firmware)/! s/))/ (firmware (list linux-firmware)))/ 
}' "$CONFIG_FILE"

#-------------------------------------------------------------
# Start cow-store
#-------------------------------------------------------------
echo "[+] Starting cow-store service ..."
if ! herd start cow-store /mnt; then
    echo "[-] Warning: failed to start cow-store (might already be running)."
fi

#-------------------------------------------------------------
# Download channels.scm
#-------------------------------------------------------------
echo "[+] Downloading channels.scm ..."
if wget -q "$CHANNELS_URL" -O /mnt/etc/channels.scm; then
    chmod +w /mnt/etc/channels.scm
    echo "[✓] channels.scm downloaded successfully."
else
    echo "[-] Failed to download channels.scm!"
    exit 1
fi

#-------------------------------------------------------------
# Reconfigure the system
#-------------------------------------------------------------
echo "[+] Reconfiguring system with Guix ..."
if sudo guix system reconfigure /mnt/etc/config.scm; then
    echo "[✓] System reconfiguration completed successfully."
else
    echo "[-] Guix system reconfigure failed!"
    exit 1
fi

#-------------------------------------------------------------
# Reboot
#-------------------------------------------------------------
echo "[+] Rebooting system now ..."
reboot
