#!/bin/bash
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
# Add (nongnu packages linux) and (nongnu packages firmware)
# under (use-modules (gnu)
#-------------------------------------------------------------
echo "[+] Adding non-GNU modules to (use-modules ...)"
sed -i '/(use-modules *(gnu)/a\  (nongnu packages linux)\n  (nongnu packages firmware)' "$CONFIG_FILE"

#-------------------------------------------------------------
# Add kernel and firmware definitions under (operating-system
#-------------------------------------------------------------
echo "[+] Adding kernel and firmware definitions to (operating-system ...)"
sed -i '/(operating-system/a\  (kernel linux)\n  (firmware (list linux-firmware))' "$CONFIG_FILE"

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
# Reconfigure system
#-------------------------------------------------------------
echo "[+] Reconfiguring system with Guix ..."
sudo guix system reconfigure "$CONFIG_FILE"

#-------------------------------------------------------------
# Reboot
#-------------------------------------------------------------
echo "[+] Rebooting system now ..."
reboot
