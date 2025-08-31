#!/usr/bin/env fish

# Start the guix shell and run zenbrowser inside it
guix shell --container --network \
  --preserve='^DISPLAY$' \
  --preserve='^XAUTHORITY$' \
  --expose=$XAUTHORITY \
  --expose=/etc/ssl/certs \
  zen-browser-bin -- zen

