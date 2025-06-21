#!/bin/bash
# Disable Tor transparent proxy and restore Mullvad VPN on Guix System
# Removes Tor NFTables rules, restores DNS, and restarts Mullvad

# Flush Tor NFTables rules
sudo nft delete table inet tor 2>/dev/null || true

# Restore DNS configuration
sudo herd start nscd
sudo ln -sf /var/run/nscd/resolv.conf /etc/resolv.conf

# Restart Mullvad VPN
sudo herd restart mullvad-daemon

# Restart Tor service (to reset connections)
sudo herd restart tor

echo "Tor VPN disabled, Mullvad VPN restored with NFTables"
