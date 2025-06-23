#!/bin/bash

# Define the path to your custom config
config_dir="$HOME/.config/termonad"
config_file="$config_dir/termonad.hs"

# Run nix-shell with termonad and execute Termonad
nix-shell -p termonad --run "
  # Ensure the config file exists
  if [ -f \"$config_file\" ]; then
    # Run termonad
    termonad
  else
    echo \"Config file not found at $config_file\"
  fi
"
