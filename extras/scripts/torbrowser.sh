#!/usr/bin/env fish

# Start the guix shell and run torbrowser inside it
guix shell --container --network \
  --preserve='^DISPLAY$' \
  --preserve='^XAUTHORITY$' \
  --expose=$XAUTHORITY \
  --expose=/etc/ssl/certs \
  torbrowser -- torbrowser

