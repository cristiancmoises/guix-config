#!/bin/sh
set -eu

echo "[+] Cleaning user..."
guix package --delete-generations=1m || true

echo "[+] Cleaning old generations..."
guix system delete-generations 1m || true

echo "[+] Colecting the garbage..."
guix gc --delete-generations=1m || true
guix gc --collect-garbage

echo "[+] Finishing..."
guix gc
