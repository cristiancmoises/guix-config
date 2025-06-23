#!/bin/bash
# Toggle between Tor VPN and Mullvad VPN using NFTables on Guix System
# Usage: ./toggle-vpn.sh [tor|mullvad]

# Check if Tor NFTables table exists
TOR_ACTIVE=$(sudo nft list tables 2>/dev/null | grep -c "table inet tor")

if [ "$1" = "tor" ] || [ "$TOR_ACTIVE" -eq 0 ]; then
    if [ "$TOR_ACTIVE" -eq 0 ]; then
        echo "Switching to Tor VPN..."
        ~/torando/torando.sh
    else
        echo "Tor VPN already active"
    fi
elif [ "$1" = "mullvad" ] || [ "$TOR_ACTIVE" -gt 0 ]; then
    if [ "$TOR_ACTIVE" -gt 0 ]; then
        echo "Switching to Mullvad VPN..."
        ~/torando/toroff.sh
    else
        echo "Mullvad VPN already active"
    fi
else
    echo "Usage: $0 [tor|mullvad]"
    exit 1
fi
