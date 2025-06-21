#!/usr/bin/env fish

# Start the guix shell and run telegram-desktop inside it
guix shell --container --network \
  --preserve='^DISPLAY$' \
  --preserve='^XAUTHORITY$' \
  --expose=$XAUTHORITY \
  --expose=/etc/ssl/certs \
  telegram-desktop -- telegram-desktop

