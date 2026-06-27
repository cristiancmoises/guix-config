#!/bin/sh
# Route audio to the laptop's INTERNAL SPEAKERS (Intel HDA, 2ch stereo).
#
# Fixes the RAGE/Proton "audio error": the system default PulseAudio sink defaults
# to the NVIDIA GPU HDMI output (the TV) forced into 8-channel "Pro Audio" mode
# (alsa_output.pci-0000_01_00.1.pro-output-*). With the TV disconnected (or even
# when stereo games hit that 8ch sink), winepulse spams
# 'pa_stream_get_time error -15' + 'Unhandled channel aux0-7' and audio breaks
# (this is what made GTA V Enhanced error/crash on load with PROTON_LOG=1).
#
# Re-run after a reboot, or after plugging/unplugging the HDMI TV. No sudo needed.
# (GTA's launch options also pin PULSE_SINK to this sink as a per-game safety-net.)
SPK=alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink
export PULSE_SERVER="${PULSE_SERVER:-/run/user/$(id -u)/pulse/native}"

pactl set-default-sink "$SPK" 2>/dev/null && echo "default sink -> laptop speakers" || { echo "failed (is pipewire/pulse up?)"; exit 1; }
# move any already-playing streams onto the speakers too
pactl list short sink-inputs 2>/dev/null | awk '{print $1}' | while read -r i; do
    pactl move-sink-input "$i" "$SPK" 2>/dev/null
done
echo "now default: $(pactl get-default-sink 2>/dev/null)"
