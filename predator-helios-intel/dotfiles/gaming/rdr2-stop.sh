#!/usr/bin/env bash
set -uo pipefail; G="Red Dead"
pkill -TERM -f "$G Redemption 2" 2>/dev/null||true; pkill -TERM -f 'Rockstar Games/Social' 2>/dev/null||true; sleep 3
pkill -TERM -f 'ubuntu12_32/steam' 2>/dev/null||true; pkill -TERM -f '/steam\.sh' 2>/dev/null||true
for i in $(seq 1 30); do pgrep -f 'ubuntu12_32/steam' >/dev/null 2>&1||break; sleep 1; done
pkill -KILL -f 'ubuntu12_32/steam' 2>/dev/null||true; pkill -KILL -f '/steam\.sh' 2>/dev/null||true
pkill -KILL -f 'steamwebhelper' 2>/dev/null||true; pkill -KILL -f "$G Redemption 2" 2>/dev/null||true
pkill -x wineserver 2>/dev/null||true; sleep 2
pgrep -f 'ubuntu12_32/steam' >/dev/null 2>&1 && echo "steam still up" || echo "stopped clean"
