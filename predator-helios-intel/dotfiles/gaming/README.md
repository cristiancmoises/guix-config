# Steam gaming adjustments — Predator Helios (Guix / nonguix Steam / Proton)

All the tuning for RDR2 and GTA V Enhanced on this box (RTX 4060 Laptop **8 GB**,
i7-13700HX, 15 GB RAM, X11 DP-4 = laptop panel 1920×1200@165, optional Philips
**32PHG5201** TV on HDMI-0 = 768p panel, max 1080p input). Steam runs double-nested:
nonguix `guix shell --container` → pressure-vessel sniper → Proton.

> Steam stores launch options in `userdata/<id>/config/localconfig.vdf` and Proton
> mappings in `config/config.vdf` — **Steam rewrites both on exit**, so it must be
> CLOSED to hand-edit them. The strings below are recorded here so they can be
> re-pasted via the in-game Properties UI if Steam ever resets them.

Steam data root: `~/.local/share/guix-sandbox-home/.local/share/Steam`
Save backups: `~/rdr2-save-backup/`

---

## System-level (already in `../config-xlibre.scm`, not here — reference only)

- **Steam stays online across VPN reconnects** — `/etc/resolv.conf` gets written
  `0600 root` by the Mullvad daemon; the nscd-less Steam container then can't read
  DNS and Steam goes OFFLINE. Fixed by services in `config-xlibre.scm`:
  `resolv-conf-watch` (inotify, instant re-chmod 0644) + `resolv-conf-readable`
  (mcron per-minute backstop) + fixed boot `file-permissions`. Manual one-shot if
  ever needed: `sudo chmod 0644 /etc/resolv.conf`. (See `steam-reconnect.sh` to
  restart Steam if it's stuck in offline-mode UI.)
- **RAGE sysctls** (also in `config-xlibre.scm` sysctl block): `kernel.yama.ptrace_scope=1`
  (RDR2's Arxan self-debugs via PTRACE_TRACEME — scope 2 = EPERM = clean-exit before
  a window) and `vm.max_map_count=1048576` (else world-load crash). Required by both
  RDR2 and GTA V Enhanced.

---

## Audio (`game-audio-speakers.sh`)

RAGE/Proton "audio error" = the default sink defaults to the NVIDIA **HDMI** output
(the TV) in **8-channel "Pro Audio"** mode → winepulse `pa_stream_get_time -15` +
`Unhandled channel aux` spam, broken sound. **Fix: default sink = laptop speakers**
(`alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink`, 2ch).
Run `game-audio-speakers.sh` after a reboot or after (un)plugging the TV. GTA's launch
options also pin `PULSE_SINK=<that speaker sink>` per-game.

## Display

- `../dotfiles/dual-monitor` (deployed to `~/.local/bin`) handles layout.
- Laptop native, best quality: `xrandr --output DP-4 --mode 1920x1200 --rate 60 --scale 1x1 --primary --output HDMI-0 --off`
  (165 Hz reverts on reboot and is wasted at Ultra — the 4060 runs <60 fps; 60 Hz is
  more stable for RAGE).
- TV is 768p (max 1080p input) — **lower quality than the laptop**; play on the laptop.

---

## RDR2 (appid 1174180) — `rdr2-system.xml`, `rdr2-boot-final.sh`, `vkBasalt.conf`

- **Proton:** GE-Proton10-34 (pinned). **Launch options (MangoHud REMOVED — see below):**
  `WINE_DISABLE_VULKAN_OPWR=0 PROTON_ENABLE_NVAPI=1 DXVK_LOG_LEVEL=none __GL_GSYNC_ALLOWED=0 __GL_SHADER_DISK_CACHE=1 __GL_SHADER_DISK_CACHE_SIZE=12000000000 __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 %command%`
- **Sway-era "won't launch" — ✅ CONFIRMED root cause + fix (RDR2 launches again):**
  RDR2 ran fine on X11 (Jun 25, 240 s stable) but on the Sway generation `PlayRDR2.exe`
  died in ~5 s before any window (Steam `console_log.txt`: process added → removed 5 s
  later, every attempt). The one env RDR2 carried that GTA V (which still launches) did
  NOT is **`MANGOHUD=1`** — its Vulkan *implicit layer* crashes the process at
  `vkCreateInstance` (a ~5 s death is that signature). **Fix: remove
  `MANGOHUD=1 MANGOHUD_CONFIG=…` from the launch options** (done above). **Verified
  2026-06-28:** after stripping MangoHud, `RDR2.exe` spawned at ~24 s and ran steadily
  (133 s+ uptime, **5.8 GB VRAM** on the RTX 4060) — fully past the old crash.
  - **How to remove it:** Steam rewrites `userdata/<id>/config/localconfig.vdf` on exit,
    so either (a) **close Steam first**, then delete the MangoHud substring from that file
    (back it up — a `localconfig.vdf.bak-mangohud-fix` was kept), or (b) edit it live via
    **Steam → RDR2 → Properties → Launch Options**. Don't re-add `MANGOHUD=1`.
  - If a future regression still exits ~5 s, append **`PROTON_LOG=1`** (safe — it exits
    fast, no I/O storm like GTA V's load-time logging) and read
    `~/.local/share/guix-sandbox-home/steam-1174180.log` for the failing module.
  - **Launch helper:** `bash rdr2-boot-final.sh` (stop → `steam -silent` → wait
    webhelper → `steam://rungameid/1174180` → monitor). It was fixed to **inherit the
    Sway/XWayland `DISPLAY`/`XAUTHORITY`** instead of the X11 `:0`/`~/.Xauthority`
    hardcodes (under Sway, Xwayland is `:0` with `-listenfd`/no-auth and the session
    exports no `XAUTHORITY`).
- **Graphics** (`rdr2-system.xml` → game's `…/Red Dead Redemption 2/Settings/system.xml`):
  all-Ultra; the stutter was RAM/swap thrash, not GPU, so quality stays maxed.
  **`windowed=0` (exclusive fullscreen)** for the single laptop display when the TV is
  connected — borderless (windowed=2) crashes during world-load at 16:10; borderless
  is OK only when mirroring. 1920×1200, HDR off (SDR-ish panel), sharpen 1.0,
  transferQueues on, DLSS Quality.
- **Launch recipe:** `rdr2-boot-final.sh` (stop → steam -silent → wait webhelper →
  `steam steam://rungameid/1174180`). `rdr2-stop.sh` to stop.
- **Smoothness toggle:** `rdr2-perf.sh on` before playing, `off` after (see below).
- **vkBasalt** (`vkBasalt.conf`, CAS only — deband CRASHES ~125s): configured but does
  NOT load in the pressure-vessel container yet. To make it load: add `vkbasalt` to the
  Steam container package set via the securityops channel (then `guix home reconfigure`)
  so its layer JSON lands in the FHS-union pv scans, like MangoHud. (Verified feasible.)
- Saves: `SRDR300xx` in `…/Profiles/11F27436/` (Rockstar/Social Club cloud; Steam Cloud
  inert for RDR2). On a cloud conflict pick **Keep Local**.

## GTA V Enhanced (appid 3240220) — `gtav-enhanced-settings.xml`

- **Proton:** **Proton Experimental** (pinned — needed for the BattlEye runtime).
  **Launch options:**
  `PROTON_ENABLE_NVAPI=1 PULSE_SINK=alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink __GL_SHADER_DISK_CACHE=1 __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 %command%`
  (NEVER add `PROTON_LOG=1` — it wrote a 78 MB log during load = I/O storm = crash.)
- **Settings** (`gtav-enhanced-settings.xml` → game's `…/GTAV Enhanced/settings.xml`):
  `ParticleQuality=2` (was 3 — the only maxed key, 8 GB glitch source),
  `dlssFrameGenMode=0` + `fsr3FrameGenMode=0` (FrameGen off), RT all off, Audio3d=false.
- **GTA Online / BattlEye:** needs the **Proton BattlEye Runtime (appid 1161040)** —
  install with `steam steam://install/1161040` (it did NOT auto-download). With that +
  Proton Experimental, Online works. `BEService` only runs once you actually enter
  Online. Vanilla Online play on Proton is officially BattlEye-supported (no ban; only
  mods/trainers in Online are bannable).
- **Story saves:** `SGTA50000` (+`.bak`) in `…/GTAV Enhanced/Profiles/11F27436/`. A
  downloaded 100%-completion save (built for build 1013.34) is installed there and
  survived the Social Club cloud sync. Story saves are single-player only — no Online
  effect, no ban. On a cloud conflict pick **Keep Local**.

---

## Performance toggle (`rdr2-perf.sh`, applies to any heavy game) — needs sudo

`sudo bash rdr2-perf.sh on` before playing, `sudo bash rdr2-perf.sh off` after.
Session-only (reverts on reboot) — intentionally NOT persisted to config.scm because
they'd hurt battery/hardening 24/7:
- `vm.swappiness 180→10` (180 is pathological for a live game working set),
- CPU governor + EPP → performance,
- `vm.watermark_scale_factor`/`min_free_kbytes` raised,
- renice/ionice the SECURITYOS ISO build (if running) so the game wins CPU/disk.
Also close LibreWolf + spare apps before entering an open world (15 GB RAM is tight).

## Scripts in this dir
| file | what |
|---|---|
| `rdr2-boot-final.sh` | RDR2 clean launch recipe |
| `rdr2-stop.sh` | stop RDR2/Steam |
| `rdr2-perf.sh on\|off` | gaming perf toggle (sudo) |
| `game-audio-speakers.sh` | route audio to laptop speakers (audio fix) |
| `steam-reconnect.sh` | restart Steam if stuck offline |
| `rdr2-system.xml` / `gtav-enhanced-settings.xml` / `vkBasalt.conf` | tuned game configs (reference copies) |

To deploy a script to `~/.local/bin` like the others, add a `home-files-service-type`
entry in `../home.scm` (see the existing `dual-monitor` / `brightness-step` entries).
