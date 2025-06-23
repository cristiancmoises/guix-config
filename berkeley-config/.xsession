#!/bin/sh
# ~/.xsession - X11 startup script for GNU Guix + XMonad

### 1. Load X resources (fonts, DPI, etc.)
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

### 2. Environment: GPU acceleration for apps

# General OpenGL / GPU
export LIBGL_ALWAYS_SOFTWARE=0
export LIBGL_DRI3_ENABLE=1
export VDPAU_DRIVER=radeonsi
export DRI_PRIME=0
export CLUTTER_BACKEND=x11

# Qt applications (Telegram, etc.)
export QT_QPA_PLATFORM=xcb
export QT_XCB_GL_INTEGRATION=none
export QT_OPENGL=desktop

# GTK applications (IceCat, etc.)
export GDK_BACKEND=x11
export GDK_GL=egl
export GDK_SCALE=1

# Mozilla apps (IceCat, Firefox, etc.)
export MOZ_X11_EGL=1
export MOZ_ENABLE_WAYLAND=0
export MOZ_WEBRENDER=1

### 3. Startup utilities (background, IME, compositor, etc.)
feh --bg-fill ~/Downloads/wall.png &
fcitx5 -d &
picom --config ~/.config/picom.conf &
nm-applet &         # optional: network tray
pasystray &         # optional: audio tray
xset r rate 250 40  # optional: faster key repeat

### 4. Preload apps (optional)
# telegram-desktop &
# mpv --idle &

### 5. Run XMonad (final command must use exec)
exec xmonad
