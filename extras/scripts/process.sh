#!/bin/bash
# Function to calculate memory usage based on a keyword in the command line
memory_usage() {
    local keyword="$1"
    local display_name="$2"
    local pids=$(pgrep -f "$keyword")
    local total_kb=0

    for pid in $pids; do
        mem_kb=$(ps -p "$pid" -o rss= 2>/dev/null | awk '{sum+=$1} END {print sum}')
        total_kb=$((total_kb + mem_kb))
    done

    local mem_mb=$(awk "BEGIN {printf \"%.2f\", $total_kb/1024}")
    printf "| %-15s | %8s MB |\n" "$display_name" "$mem_mb"
}

# Header
echo    "---------------------------------"
echo    "             Gnu Guix            "
echo    "---------------------------------"
# Process memory reports
memory_usage "guix" "Guix"
memory_usage "shepherd" "Shepherd"
memory_usage "xorg" "Xorg"
memory_usage "xmonad" "Xmonad"
memory_usage "alacritty" "Alacritty"
memory_usage "dbus" "D-Bus"
memory_usage "udevd" "Udev"
# Footer
echo "--------------------------------"
