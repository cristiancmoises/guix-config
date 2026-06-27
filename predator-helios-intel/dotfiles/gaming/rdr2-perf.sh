#!/usr/bin/env bash
# RDR2 gaming-session PERFORMANCE toggle.  Run with sudo:
#   sudo bash ~/rdr2-perf.sh on    # before playing: apply smoothness tweaks (saves current values first)
#   sudo bash ~/rdr2-perf.sh off   # after playing:  restore your normal hardened/battery-friendly values
#
# These are SMOOTHNESS tweaks only — they reduce swap-thrash + CPU-ramp stutter under load.
# They do NOT change visual quality (that's maxed & permanent in system.xml).
# Intentionally NOT persisted to config.scm: swappiness=10 fights your zram design, and the
# performance governor hurts battery/heat 24/7. Toggle = perf on demand, hardened defaults the rest of the time.
# Process patterns live in this FILE (safe) and only ever renice/ionice (signal-safe, never freezes/kills).
set -uo pipefail
STATE=/run/rdr2-perf.state
mode="${1:-}"
GOV='/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
EPP='/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference'
BUILD_PAT='xorriso|grub-mkrescue|securityos-build-r2'

case "$mode" in
  on)
    # snapshot current values so 'off' restores YOUR exact originals
    {
      echo "SW=$(cat /proc/sys/vm/swappiness)"
      echo "WM=$(cat /proc/sys/vm/watermark_scale_factor)"
      echo "MF=$(cat /proc/sys/vm/min_free_kbytes)"
      echo "GV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
      echo "EP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo balance_performance)"
    } > "$STATE"
    sysctl -w vm.swappiness=10 vm.watermark_scale_factor=125 vm.min_free_kbytes=262144 >/dev/null
    for f in $GOV; do echo performance > "$f"; done
    for f in $EPP; do echo performance > "$f" 2>/dev/null || true; done
    for p in $(pgrep -f "$BUILD_PAT" 2>/dev/null); do renice +19 -p "$p" >/dev/null 2>&1 || true; ionice -c3 -p "$p" 2>/dev/null || true; done
    echo "RDR2 perf mode ON  -> swappiness=10, governor=performance, build deprioritized. Run 'off' when done."
    ;;
  off)
    if [ -f "$STATE" ]; then . "$STATE"; else SW=180; WM=10; MF=67584; GV=powersave; EP=balance_performance; fi
    sysctl -w vm.swappiness="${SW:-180}" vm.watermark_scale_factor="${WM:-10}" vm.min_free_kbytes="${MF:-67584}" >/dev/null
    for f in $GOV; do echo "${GV:-powersave}" > "$f"; done
    for f in $EPP; do echo "${EP:-balance_performance}" > "$f" 2>/dev/null || true; done
    for p in $(pgrep -f "$BUILD_PAT" 2>/dev/null); do renice 0 -p "$p" >/dev/null 2>&1 || true; ionice -c2 -n4 -p "$p" 2>/dev/null || true; done
    rm -f "$STATE"
    echo "RDR2 perf mode OFF -> restored swappiness=${SW:-180}, governor=${GV:-powersave} (your hardened defaults)."
    ;;
  *) echo "usage: sudo bash ~/rdr2-perf.sh on|off"; exit 1;;
esac
