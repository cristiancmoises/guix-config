#!/usr/bin/env bash
# ONE clean cycle (the proven pattern): stop -> launch steam (-silent, nscd shared for DNS/online)
# -> wait for steamwebhelper -> launch game in SAME context -> watch survival past the old ~100s
# max_map_count crash + window @1920x1200 + system.xml. All sysctls already live.
# pkill patterns live in THIS file (safe).
set -uo pipefail
SBX="$HOME/.local/share/guix-sandbox-home/.local/share/Steam"
CD="$SBX/steamapps/compatdata/1174180"
DOC="$CD/pfx/drive_c/users/steamuser/Documents/Rockstar Games/Red Dead Redemption 2"
SYSXML="$DOC/Settings/system.xml"
LAUNLOG="$CD/pfx/drive_c/users/steamuser/Documents/Rockstar Games/Launcher/launcher.log"
DISP=":0"; XAUTH="$HOME/.Xauthority"; STEAMBIN="$HOME/.guix-home/profile/bin/steam"; G="Red Dead"
OUT="$HOME/rdr2-boot-final.txt"; : > "$OUT"; say(){ echo "$@" | tee -a "$OUT"; }

say "==> sysctls: ptrace=$(cat /proc/sys/kernel/yama/ptrace_scope) max_map_count=$(cat /proc/sys/vm/max_map_count)"
say "==> clean stop of steam/game/wine"
pkill -TERM -f "$G Redemption 2" 2>/dev/null||true; pkill -TERM -f 'Rockstar Games/Social' 2>/dev/null||true; sleep 3
pkill -TERM -f 'ubuntu12_32/steam' 2>/dev/null||true; pkill -TERM -f '/steam\.sh' 2>/dev/null||true
for i in $(seq 1 45); do pgrep -f 'ubuntu12_32/steam' >/dev/null 2>&1||pgrep -f 'steamwebhelper' >/dev/null 2>&1||break; sleep 1; done
pkill -KILL -f 'ubuntu12_32/steam' 2>/dev/null||true; pkill -KILL -f 'steamwebhelper' 2>/dev/null||true
pkill -KILL -f "$G Redemption 2" 2>/dev/null||true; pkill -x wineserver 2>/dev/null||true; sleep 4

say "==> launch steam (-silent, NO nscd share — that broke /var/run audio -> GLA cancel)"
setsid env \
  DISPLAY="$DISP" XAUTHORITY="$XAUTH" __GLX_VENDOR_LIBRARY_NAME=nvidia \
  nohup "$STEAMBIN" -silent >/dev/null 2>&1 &
for i in $(seq 1 90); do ps -eo comm|grep -qx steamwebhelper && break; sleep 2; done
say "    steamwebhelper up; settling 12s before game launch"; sleep 12

say "==> launch RDR2 from SAME steam context (no second steam)"
env DISPLAY="$DISP" XAUTHORITY="$XAUTH" "$STEAMBIN" steam://rungameid/1174180 >/dev/null 2>&1 &

seen=0
for i in $(seq 1 240); do
  if ps -eo comm|grep -qx RDR2.exe; then seen=1; say "    >> RDR2.exe SPAWNED at ~$((i*2))s"; break; fi
  [ $((i % 30)) -eq 0 ] && say "    [$((i*2))s] waiting (launcher:$(ps -eo comm|grep -qx Launcher.exe && echo UP || echo down))"
  sleep 2
done

maxlife=0; maxgpu=0; res=""; past100=0; stable=0
if [ "$seen" = 1 ]; then
  for i in $(seq 1 200); do
    life=$(ps -eo etimes,comm | awk '$2=="RDR2.exe"{print $1; exit}')
    if [ -z "$life" ]; then say "    >> RDR2.exe EXITED after ${maxlife}s (peak GPU ${maxgpu}MiB)"; break; fi
    maxlife=$life
    mem=$(nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader,nounits 2>/dev/null | awk -F',' '/RDR2/{gsub(/ /,"",$2);print $2;exit}')
    [ -n "$mem" ] && [ "$mem" -gt "$maxgpu" ] 2>/dev/null && maxgpu=$mem
    line=$(DISPLAY="$DISP" XAUTHORITY="$XAUTH" xwininfo -root -tree 2>/dev/null | grep -iE 'steam_app_1174180' | grep -ivE 'kitty|wezterm|reinstall|alert|claude|launch issues|IME|no name' | head -1)
    [ -n "$line" ] && res=$(echo "$line" | grep -oE '[0-9]+x[0-9]+' | head -1)
    if [ "$past100" = 0 ] && [ "$life" -ge 110 ]; then say "    *** ALIVE ${life}s — PAST the old ~100s crash! (GPU ${mem:-0}MiB res ${res:-?})"; past100=1; fi
    if [ "$stable" = 0 ] && [ "$life" -ge 180 ]; then say "    *** STABLE ${life}s — menu/world (res ${res:-?} GPU ${mem:-0}MiB)"; stable=1; fi
    if [ -f "$SYSXML" ]; then say "    *** system.xml WRITTEN ($(wc -c < "$SYSXML" 2>/dev/null)B) — graphics editable"; fi
    [ "$life" -ge 240 ] && { say "    *** 240s stable — leaving it running."; break; }
    sleep 2
  done
fi

say "============ FINAL VERDICT ============"
grep -aE 'Game exited with code|exited before creating|Begin game launch' "$LAUNLOG" 2>/dev/null | tail -3 | tee -a "$OUT"
say "    seen=$seen maxlife=${maxlife}s peakGPU=${maxgpu}MiB res=${res:-none} system.xml=$( [ -f "$SYSXML" ] && echo yes || echo no)"
if [ "${maxlife:-0}" -ge 150 ]; then say "    *** SUCCESS — RDR2 stable past the crash ${res:+@ $res}."
elif [ "${maxlife:-0}" -ge 105 ]; then say "    PROGRESS past 100s, exited ${maxlife}s — check screen."
elif [ "$seen" = 1 ]; then say "    short exit ${maxlife}s — investigate (proton log)."
else say "    RDR2.exe never spawned — launcher/sign-in; check screen."; fi
say "DONE-BOOT-FINAL"
