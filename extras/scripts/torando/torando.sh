#!/bin/bash
# Enable Tor transparent proxy using NFTables on Guix System
# Stops Mullvad VPN, configures DNS for Tor, and sets up NFTables rules to redirect traffic

# Stop Mullvad VPN and DNS caching
sudo herd stop mullvad-daemon
sudo herd stop nscd

# Configure DNS for Tor (127.0.0.1:53)
sudo sh -c 'echo "nameserver 127.0.0.1" > /etc/resolv.conf.tor'
sudo ln -sf /etc/resolv.conf.tor /etc/resolv.conf

# Flush existing Tor NFTables rules
sudo nft delete table inet tor 2>/dev/null || true

# Apply NFTables rules for Tor transparent proxy
sudo nft -f - <<EOF
table inet tor {
    chain prerouting {
        type nat hook prerouting priority dstnat; policy accept;
        meta skuid "berkeley" ip daddr != { 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } tcp dport != { 9050, 9150, 9151 } dnat to 127.0.0.1:9040
        meta skuid "berkeley" udp dport 53 dnat to 127.0.0.1:53
        meta skuid "berkeley" tcp dport 53 dnat to 127.0.0.1:53
        meta skuid "berkeley" log prefix "TOR_DROPPED_PREROUTING: " drop
    }

    chain output {
        type filter hook output priority filter; policy accept;
        meta skuid "berkeley" oifname "lo" accept
        meta skuid "berkeley" ip daddr { 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept
        meta skuid "berkeley" tcp dport { 9050, 9150, 9151 } accept
        meta skuid "berkeley" accept
    }
}
EOF

# Restart Tor service
sudo herd restart tor

echo "Tor VPN enabled with NFTables"
