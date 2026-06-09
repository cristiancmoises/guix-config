#!/usr/bin/env bash
# ~/.config/cmus/covers.sh
# FIXED: Dynamic right-side position, no overlap, black bg

set -euo pipefail

FEH="$(command -v feh)" || exit 0 
CLASS="cmus_cover_right" 
CACHE="/tmp/cmus-cover-${USER}"

# Dynamic geometry: 300x300, 30px from right, 80px from top
SCREEN_WIDTH=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d'x' -f1)
X_POS=$(($SCREEN_WIDTH - 100 - 30))
GEOMETRY="100x300+${X_POS}+80"

# Get current track
TRACK="$(cmus-remote -Q 2>/dev/null | grep '^file ' | cut -d' ' -f2-)" || exit 0
DIR="$(dirname "$TRACK")"

# Find cover
ART=""
for f in "$DIR"/{cover,folder,front,album}.{png,jpg,jpeg,webp} "$DIR"/*.{png,jpg,jpeg,webp}; do
    [[ -f "$f" ]] && ART="$f" && break
done
[[ -z "$ART" ]] && ART="$(find "$DIR" -maxdepth 2 \( -iname 'cover.*' -o -iname 'folder.*' -o -iname 'front.*' \) -print -quit 2>/dev/null || true)"

# No art → kill window
if [[ -z "$ART" || ! -f "$ART" ]]; then
    pkill -f "feh.*--class $CLASS" 2>/dev/null || true
    rm -f "$CACHE" 2>/dev/null || true
    exit 0
fi

# Kill old window
pkill -f "feh.*--class $CLASS" 2>/dev/null || true
sleep 0.05

# Launch on right, no overlap
"$FEH" \
  -g "$GEOMETRY" \
  --class "$CLASS" \
  --borderless \
  --auto-zoom \
  --image-bg black \
  --no-fehbg \
  --title "cmus-cover-right" \
  "$ART" >/dev/null 2>&1 &

echo "$!" > "$CACHE"
exit 0
