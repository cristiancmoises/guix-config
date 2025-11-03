
#!/bin/bash

# Display banner
echo "+-------------------------------------------------------------+"
echo "|                  GNU GUIX INSTALLATION                      |"
echo "|                 [  In Code We Trust  ]                      |"
echo "+-------------------------------------------------------------+"
echo ""

CONFIG_FILE="/mnt/etc/config.scm"

# Ensure the file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: $CONFIG_FILE does not exist."
  exit 1
fi

# Insert (nongnu packages linux) and (nongnu packages firmware) into (use-modules ...)
sed -i '/(use-modules (gnu)/ {
  /nongnu packages linux/! s/)/ (nongnu packages linux)/
}' "$CONFIG_FILE"

sed -i '/(use-modules (gnu)/ {
  /nongnu packages firmware/! s/)/ (nongnu packages firmware)/
}' "$CONFIG_FILE"

# Insert (kernel linux) and (firmware (list linux-firmware)) into (operating-system ...)
sed -i '/(operating-system/ {
  N
  /kernel linux/! s/)/ (kernel linux)/
}' "$CONFIG_FILE"

sed -i '/(operating-system/ {
  N
  /firmware (list linux-firmware)/! s/)/ (firmware (list linux-firmware))/
}' "$CONFIG_FILE"

# Start cow-store
echo "[+] Starting cow-store service..."
herd start cow-store /mnt

# Download and move channels.scm
echo "[+] Downloading channels.scm..."
wget https://codeberg.org/berkeley/guix-config/raw/branch/main/based-channels.scm
 -O /mnt/etc/channels.scm

# Make it writable
chmod +w /mnt/etc/channels.scm

# Reconfigure system
echo "[+] Reconfiguring system with Guix..."
sudo guix system reconfigure /mnt/etc/config.scm
  
# Reboot
echo "[+] Rebooting system now..."
reboot
