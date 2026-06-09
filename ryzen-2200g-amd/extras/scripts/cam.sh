#!/usr/bin/env bash
# cam.sh — configure Logitech Brio 500, crop webcam, place ffplay + terminal

# --- Webcam quality settings ---
# Set resolution and frame rate (smooth mode)
v4l2-ctl -d /dev/video0 --set-fmt-video=width=1280,height=720,pixelformat=MJPG
v4l2-ctl -d /dev/video0 --set-parm=60   # 60 fps supported

# Lock exposure (manual mode)
v4l2-ctl -d /dev/video0 --set-ctrl=exposure_auto=1
v4l2-ctl -d /dev/video0 --set-ctrl=exposure_absolute=200

# Lock white balance (manual mode)
v4l2-ctl -d /dev/video0 --set-ctrl=white_balance_temperature_auto=0
v4l2-ctl -d /dev/video0 --set-ctrl=white_balance_temperature=4500

# --- Crop settings (based on 1280x720) ---
SCREEN_WIDTH=3840
SCREEN_HEIGHT=2160
CAM_WIDTH=1280
CAM_HEIGHT=720

# Crop: center vertical strip (36% width), 80% height, shifted down 10%
CROP_WIDTH=$((CAM_WIDTH * 36 / 100))   # 460
CROP_HEIGHT=$((CAM_HEIGHT * 80 / 100)) # 576
CROP_X=$((CAM_WIDTH * 32 / 100))       # 410
CROP_Y=$((CAM_HEIGHT * 10 / 100))      # 72

POS_X=$((SCREEN_WIDTH - CROP_WIDTH))   # 3380
POS_Y=$((SCREEN_HEIGHT - CROP_HEIGHT)) # 1584

# --- Launch ffplay ---
ffplay -vf "crop=${CROP_WIDTH}:${CROP_HEIGHT}:${CROP_X}:${CROP_Y}" /dev/video0 &

sleep 1

# --- Move windows ---
wmctrl -r "ffplay" -e 0,${POS_X},${POS_Y},${CROP_WIDTH},${CROP_HEIGHT}
wmctrl -r "securityops /dev/video0" -e 0,3525,1641,154,255
