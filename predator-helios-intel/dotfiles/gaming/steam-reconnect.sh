#!/usr/bin/env bash
# Clean Steam restart to clear its connection-token throttle, then watch whether it
# logs ONLINE. NO security changes, NO nscd share. pkill patterns live in this file.
set -uo pipefail
SBX="$HOME/.local/share/guix-sandbox-home/.local/share/Steam"
CLOG="$SBX/logs/connection_log.txt"
DISP=":0"; XAUTH="$HOME/.Xauthority"; STEAMBIN="$HOME/.guix-home/profile/bin/steam"
OUT="$HOME/steam-reconnect-test.txt"; : > "$OUT"; say(){ echo "$@" | tee -a "$OUT"; }

say "==> stopping steam"
pkill -TERM -f 'ubuntu12_32/steam' 2>/dev/null||true; pkill -TERM -f '/steam\.sh' 2>/dev/null||true
for i in $(seq 1 40); do pgrep -f 'ubuntu12_32/steam' >/dev/null 2>&1||pgrep -f 'steamwebhelper' >/dev/null 2>&1||break; sleep 1; done
pkill -KILL -f 'ubuntu12_32/steam' 2>/dev/null||true; pkill -KILL -f 'steamwebhelper' 2>/dev/null||true; sleep 4

MARK=$(wc -l < "$CLOG" 2>/dev/null || echo 0); say "    connection_log baseline: $MARK"
say "==> relaunch steam (-silent, plain — no nscd, no security change)"
setsid env DISPLAY="$DISP" XAUTHORITY="$XAUTH" __GLX_VENDOR_LIBRARY_NAME=nvidia \
  nohup "$STEAMBIN" -silent >/dev/null 2>&1 &
for i in $(seq 1 60); do ps -eo comm|grep -qx steamwebhelper && break; sleep 2; done

say "==> watching for logon (up to ~110s)..."
online=0
for i in $(seq 1 55); do
  new=$(tail -n +$((MARK+1)) "$CLOG" 2>/dev/null)
  if echo "$new" | grep -qiE 'Logged On|Connection established'; then
    say "    *** STEAM LOGGED ON (online) at ~$((i*2))s ***"; online=1; break
  fi
  if [ $((i % 10)) -eq 0 ]; then
    last=$(echo "$new" | grep -aiE 'Logged|Connect|token|cm ' | tail -1 | sed 's/\[U:1:[0-9]*\]//g')
    say "    [$((i*2))s] ${last:-(no new lines)}"
  fi
  sleep 2
done

say "============ VERDICT ============"
tail -n +$((MARK+1)) "$CLOG" 2>/dev/null | grep -aiE 'Logged On|Logged Off|cm |token|Connect' | tail -6 | sed 's/\[U:1:[0-9]*\]//g' | tee -a "$OUT"
[ "$online" = 1 ] && say "    SUCCESS — Steam online after clean restart; the failures were transient throttle, not a config issue." \
  || say "    Still NOT online — the block persists with Mullvad lockdown+LAN; needs a Mullvad-settings decision."
say "DONE-RECONNECT"
