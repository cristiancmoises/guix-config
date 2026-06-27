<p align="center">
  <img src="https://i.ibb.co/9thQktG/re.png" width="640" alt="SecurityOps • Guix Banner">
</p>

<p align="center">
  <img src="https://codeberg.org/guix/artwork/raw/branch/master/badges/gnu-guix-reproducible.svg" alt="Reproducible with GNU Guix">
  &nbsp;&nbsp;
  <img src="https://img.shields.io/liberapay/receives/securityops.svg?logo=liberapay" alt="Liberapay receives">
  &nbsp;&nbsp;
  <img src="https://img.shields.io/liberapay/patrons/securityops.svg?logo=liberapay" alt="Liberapay patrons">
</p>

<br>

# 💻 Predator Helios Neo 16 — Intel + NVIDIA (current daily driver)

**Hardened • Hybrid-GPU • Private • Fast** — a declarative GNU Guix System + Guix Home for host `securityops`, user `berkeley`, on an Acer gaming laptop.

> [!NOTE]
> 🟢 **CURRENT machine.** This is the active daily driver. The previous **AMD Ryzen 3 2200G** desktop is archived at [`../ryzen-2200g-amd/`](../ryzen-2200g-amd/README.md). The full migration story (every config delta, with reasons) lives in [`../comparison.md`](../comparison.md); the repo-wide overview is in [`../README.md`](../README.md).

> [!IMPORTANT]
> **Two display-stack variants live side by side** (identical kernel, security, firewall, Tor, Mullvad, zram, tmpfs, audio — they differ *only* in the display server + login manager):
>
> | File | Display server | Login manager | Session WM |
> |------|----------------|---------------|------------|
> | [`config-xlibre.scm`](config-xlibre.scm) | XLibre 25.1.7 (X11) | SLiM | xmonad |
> | [`config-sway.scm`](config-sway.scm) | **Sway / wlroots (Wayland)** | **greetd** (agreety text greeter) | **Sway** |
>
> `config.scm` is the **active** file and currently mirrors **`config-sway.scm`**. Because the laptop is MUX'd to the discrete NVIDIA RTX 4060 (no iGPU fallback), Sway is launched with `--unsupported-gpu` + an NVIDIA-Wayland env. The **`seatd` daemon** owns the seat (`LIBSEAT_BACKEND=seatd`); a `user-runtime-dir` service + a small launcher wrapper guarantee `XDG_RUNTIME_DIR` exists (and tee `sway -d` to a **user-readable** `~/sway-greetd.log`, so a failed login is diagnosable without root); and glvnd is pointed at the **NVIDIA EGL vendor** so the wlroots GLES2 renderer initialises on the proprietary blob. The per-user `~/.config/sway/config` sets the `br/abnt2` keymap (Wayland ignores the OS `keyboard-layout`).
>
> **Apply Sway:** `sudo bash ~/promote-sway-config.sh` (backs up `/etc/config.scm` → `.xlibre.bak-*`, installs the Sway config), then from a **physical TTY** `sudo guix system reconfigure --fallback /etc/config.scm`.
> **Revert to XLibre:** `sudo guix system roll-back` / pick the prior generation in GRUB, or reconfigure from `config-xlibre.scm`.

```text
┌─────────────────────────── HARDWARE ───────────────────────────┐
│ Laptop   Acer Predator Helios Neo 16 (PHN16-71)                 │
│ CPU      Intel Core i7-13700HX — Raptor Lake-HX                 │
│            8 P-cores + 8 E-cores · 24 threads                   │
│ GPU      NVIDIA GeForce RTX 4060 Laptop (Ada, AD107)            │
│            + Intel UHD iGPU (Optimus/MUX)                       │
│ RAM      16 GiB                                                 │
│ Storage  1 TB NVMe behind Intel VMD                            │
│ Disk     LUKS2 full-disk encryption (cryptroot + crypthome)    │
│ Host     securityops   ·   User  berkeley                       │
└────────────────────────────────────────────────────────────────┘
```

Files in this folder: [`config.scm`](./config.scm) · [`config-sway.scm`](./config-sway.scm) · [`config-xlibre.scm`](./config-xlibre.scm) · [`home.scm`](./home.scm) · [`securityops.defconfig`](./securityops.defconfig) · `README.md`.
Shared channels live at the repo root in [`../channels.scm`](../channels.scm).

<br>

## 🖥️ Sway (Wayland) vs XLibre (X11) — benefits & differences

Both variants boot the **same** kernel, hardening, firewall, Tor, Mullvad, zram, swapfile and NVIDIA graft. They differ **only** in the display layer — but that layer has real security and ergonomics consequences, so each variant is tuned for a different priority.

| | **`config-sway.scm`** — Sway / Wayland | **`config-xlibre.scm`** — XLibre / X11 |
|---|---|---|
| **Display server** | Sway (wlroots compositor) | XLibre X server 25.1.7 (X.Org fork) |
| **Login manager** | greetd (agreety **text** greeter on vt7) | SLiM (graphical X greeter on vt7) |
| **Window manager** | Sway (built-in tiling) | xmonad (+ xmobar) |
| **Seat / DRM master** | **`seatd`** daemon + libseat (`LIBSEAT_BACKEND=seatd`) | X server owns the device |
| **NVIDIA** | `--unsupported-gpu` + GBM (`nvidia-drm`) + NVIDIA EGL vendor (glvnd) + software cursor + linear buffers | native `nvidia` DDX, `ForceFullCompositionPipeline` |
| **Keymap** | `~/.config/sway/config` (`br/abnt2`) — Wayland ignores the OS layout | OS `(keyboard-layout)` drives X directly |
| **Screenshots** | `grim` + `slurp` | `scrot` / `flameshot` |
| **Per-monitor scaling / hotplug** | native (`wlr-randr`, `kanshi`, `wdisplays`) | `xrandr` / `autorandr` |
| **Brightness/gamma** | `brightnessctl` (Wayland has no `xrandr` gamma) | two-stage `brightness-step` (backlight + xrandr gamma) |
| **`/tmp`** | **16 GiB, `nosuid,nodev,noexec`** (hardened, see below) | 4 GiB `nosuid,nodev` |
| **`ptrace_scope`** | `1` (yama *relational*) — **baked** so Steam/RDR2/GTA run with no runtime toggle | `1` (same) |

### Why Sway is the **more secure** variant 🔐

- **Client isolation (the big one).** Under X11 *any* client can read every other window's keystrokes and pixels (global input + `XGetImage`) — a single compromised app can keylog your password manager or screen-scrape your banking tab. Wayland isolates clients: an app sees only its **own** surface and input. For a box handling sensitive data this is a categorical hardening that X11 cannot offer.
- **Smaller privileged surface.** No big, monolithic, historically-CVE-heavy X server brokering all input/output; wlroots is far smaller and runs unprivileged via libseat + the **`seatd`** daemon. The greeter is a minimal **text** prompt, so there is no compositor running at the login stage.
- **Hardened ephemeral scratch.** `/tmp` is a 16 GiB RAM tmpfs with `noexec` (no running dropped payloads), `nosuid`, `nodev`; it is wiped on every reboot and any spill goes to the **LUKS2-encrypted** swapfile (and hibernation is off), so sensitive scratch never hits disk in plaintext.
- **`ptrace` is yama-restricted on *both* variants** (`kernel.yama.ptrace_scope=1`): an unrelated process still cannot attach to another, so the cross-process snooping yama defends against is blocked — but a game's anti-tamper (Arxan's `PTRACE_TRACEME` on its **own** children) works with **no runtime toggle and no reconfigure**. The stricter `2` was dropped on purpose so Steam/RDR2/GTA run out of the box; it is *not* where Sway's security edge comes from — that is the three points above (client isolation, smaller surface, hardened scratch).

### When to pick XLibre instead

- You want the **xmonad** tiling workflow (xmobar, EZConfig keybinds, decades of muscle memory).
- You need rock-solid **NVIDIA X11** (no `--unsupported-gpu` caveats), `xrandr` gamma brightness, or X-only screen-share/record tooling.
- An app has no Wayland backend and XWayland isn't enough.

> Switch with `~/promote-sway-config.sh` (Sway) or reconfigure from `config-xlibre.scm`; both are one `guix system roll-back` away from each other.

**Keybinds & dotfiles:** the xmonad and Sway configs live in [`dotfiles/`](./dotfiles/) with a full **xmonad ↔ Sway keybind-parity map** and the writeup of the **xmonad "mod key sometimes stops working" fix** (PATH was never set in xmonad's process) — see [`dotfiles/README.md`](./dotfiles/README.md).

**Benchmarks:** measured CPU / GPU / disk / crypto / security numbers that validate this config — ~4.95 GHz turbo under `powersave`, AES-NI making LUKS2 nearly free (1.0 GB/s encrypted writes), RTX 4060 on Vulkan 1.4, 31 GiB active swap — in [`BENCHMARKS.md`](./BENCHMARKS.md).

<br>

## 🎮 Graphics — NVIDIA + Intel hybrid

This is the headline change versus the old AMD/Mesa box: a proprietary NVIDIA stack pinned in lockstep with the running kernel module, with Mesa kept around only for the Intel iGPU.

- **OS-wide NVIDIA graft.** The whole system is wrapped at the bottom of `config.scm`:
  ```scheme
  ((nonguix-transformation-nvidia
     #:driver nvda-580
     #:dynamic-boost? #t)
   %securityops-os)
  ```
  This grafts **`mesa → nvda-580`** across *every package and service closure*, so Steam / pressure-vessel and all GL/Vulkan apps run on the RTX 4060. It also adds the configured **`nvidia-service-type`** (driver / module / firmware) and injects `nvidia_drm.modeset=1` plus the nouveau/nova blacklist on the cmdline.
- **Driver version: 580.159.04.** `nvda-580` is pinned on purpose — it is byte-for-byte the driver matching the kernel module already loaded (`nvidia-smi`: `580.159.04`), so there is no rebuild.
- **`nvidia-powerd` / Dynamic Boost.** `#:dynamic-boost? #t` enables `nvidia-powerd`, the laptop CPU↔GPU power-sharing daemon.
- **Xorg forced onto NVIDIA.** `%desktop-services` is modified so GDM runs on Xorg with the NVIDIA driver — `(wayland? #f)`, `(modules (cons nvidia-driver %default-xorg-modules))`, `(drivers '("nvidia"))`.
- **Intel iGPU keeps Mesa.** `mesa`, `mesa-headers`, `libva`, `libva-utils` and **`intel-media-driver`** (the iHD VAAPI driver) are installed for the Intel UHD iGPU. `igt-gpu-tools` and `nvda` (`nvidia-smi` / `nvidia-settings`) round out the GPU userspace.
- **Session GL/EGL/VAAPI env.** `gpu-env-service` exports the NVIDIA GLX/GBM stack (`__GLX_VENDOR_LIBRARY_NAME=nvidia`, `GBM_BACKEND=nvidia-drm`, `LIBGL_DRI3_ENABLE=1`) and pins Firefox/Qt/GTK to X11/EGL.
- **nouveau blacklisted.** `modprobe.blacklist=nouveau,…` on the cmdline keeps the open driver from binding the 4060 (the defconfig mirrors this with `# CONFIG_DRM_NOUVEAU is not set`).
- **Guix Home graft too.** `home.scm` wraps its whole package list in `(replace-mesa … #:driver nvda-580)` because the OS transformation only covers the *system* profile — this also grafts `ffmpeg → ffmpeg/nvidia` (NVENC/NVDEC for mpv/obs/vlc) and `steam → steam-nvidia`.
- **Sway-on-NVIDIA bring-up (Wayland).** Driving wlroots on the proprietary blob needs more than the graft — the greetd → Sway session layers it on in order:
  1. the **`seatd`** daemon owns the seat (`LIBSEAT_BACKEND=seatd`; the elogind seat path fails under greetd here);
  2. a `user-runtime-dir` service + a launcher wrapper guarantee **`XDG_RUNTIME_DIR=/run/user/1000`** exists *before* Sway starts (greetd sets the variable but not the directory) and tee `sway -d` to a **user-readable `~/sway-greetd.log`**, so a failed login is diagnosable without root;
  3. **EGL/GBM discovery is wired up by hand**, because Guix ships none of the FHS default dirs (`/usr/share/glvnd`, `/etc/egl`, …) the NVIDIA stack hard-codes — three vars, each the missing piece for one layer: the **EGL vendor ICD** (`__EGL_VENDOR_LIBRARY_FILENAMES` → `10_nvidia` json; without it glvnd finds zero vendors → empty extension list → "Failed to create EGL context"), the **GBM EGL external-platform** (`__EGL_EXTERNAL_PLATFORM_CONFIG_DIRS` → `libnvidia-egl-gbm`; without it `EGL_KHR_platform_gbm` is absent → `eglGetPlatformDisplay(GBM)` returns no display), and the **GBM backend** (`GBM_BACKENDS_PATH` → `nvidia-drm_gbm.so`; sway's `libgbm` is mesa's and ships only `dri_gbm.so` by default);
  4. `GBM_BACKEND=nvidia-drm`, a **software cursor** (`WLR_NO_HARDWARE_CURSORS=1`, the HW cursor plane is broken on the blob), and **linear / no-modifier** scanout buffers (`WLR_DRM_NO_MODIFIERS=1`) on `card0` with atomic KMS (driver 580 supports it; `nvidia_drm.modeset=1` + `fbdev=1`);
  5. the renderer is left **unpinned** (no `WLR_RENDERER=gles2`) so wlroots tries hardware GLES2 first but can fall back to the **pixman software renderer** (`WLR_RENDERER_ALLOW_SOFTWARE=1`) into a usable, debuggable desktop instead of a greetd login-loop. *(The three EGL/GBM vars above were each verified load-bearing with a live `gbm + eglInitialize + eglCreateContext(GLES2)` probe — drop any one and context creation fails.)*

<br>

## 🐧 Kernel

The system **boots nonguix `linux`** (the stable, blob-enabled kernel) — `(kernel linux)`. This is required so the **prebuilt proprietary `nvidia.ko` loads**: nonguix's NVIDIA module is compiled against nonguix `linux`, and a self-built kernel would mismatch its ABI / RANDSTRUCT seed.

- **Custom kernel defined but commented out.** `config.scm` defines a `securityops` package (`(inherit linux)`, version `7.0.11`, `#:defconfig` → `securityops.defconfig`), but it is **not** wired into `(kernel …)`. It is left in the file for a nouveau-only future or a self-built NVIDIA module.
- **`securityops.defconfig` is dormant.** It is consumed *only* by that disabled package, so editing it changes nothing at runtime until the custom kernel actually boots.
- **The MOK-signing path to re-enable it.** The defconfig is deliberately *modular* and relaxed so the GPU can work; to restore the old monolithic hardening posture you would: build the NVIDIA module against this kernel, enrol a Machine Owner Key (MOK), sign `nvidia.ko`, then flip `CONFIG_MODULE_SIG_FORCE` on (currently `# … is not set`) and optionally re-enable lockdown. IMA stays **measure-only** in the meantime as a partial mitigation.

**Notable `securityops.defconfig` deltas** (Intel build, all read from the file):

| Symbol / area | Value | Purpose |
|---|---|---|
| `CONFIG_MNATIVE_INTEL=y` | graysky CPU-opt patch | Raptor Lake-HX native tuning (mirrors AMD's `MNATIVE`/`MZEN`) |
| `CONFIG_INTEL_IOMMU` (+`_SVM`, `_DEFAULT_ON`) | `y` | Intel IOMMU / DMA protection |
| `CONFIG_DRM_I915=y` | built-in | Intel UHD iGPU; `# CONFIG_DRM_NOUVEAU is not set` blocks nouveau |
| `CONFIG_VMD=y` | built-in | **Intel Volume Management Device** — without it the encrypted NVMe is invisible and the box will not boot |
| `CONFIG_NTSYNC=y` (+`CHECKPOINT_RESTORE`, `USERFAULTFD`, `FUTEX`) | built-in | Proton/Wine fast sync path (`/dev/ntsync`) |
| `CONFIG_INT340X/INT3400/INT3403_THERMAL`, `INTEL_RAPL`, `INTEL_POWERCLAMP`, `SENSORS_CORETEMP` | modules | Thermal sensors + RAPL power-capping so `thermald` can act under load |
| `CONFIG_IWLWIFI`+`IWLMVM`, `CONFIG_MT7921E`, `CONFIG_BT_*`/`BT_INTEL` | modules | Helios Neo ships either Intel/Killer or MediaTek radios — both enabled so the right one binds; Bluetooth via BTUSB |
| `CONFIG_ACER_WMI`, `ACER_WIRELESS`, `X86_PLATFORM_DEVICES` | modules | Acer laptop platform hooks; `# CONFIG_HIBERNATION is not set` (no swap partition) |

The defconfig also keeps the KSPP/Clear/Xanmod hardening baseline intact (`RANDOMIZE_BASE`, `STACKPROTECTOR_STRONG`, `HARDENED_USERCOPY`, `SLAB_FREELIST_*`, `PAGE_TABLE_CHECK*`, `RANDSTRUCT_FULL`, `SECCOMP`, IMA measure-only), and is set to perf-parity with the live cmdline (`# CONFIG_INIT_ON_FREE_DEFAULT_ON is not set`, `# CONFIG_NUMA_BALANCING is not set`).

> **Relaxed vs. the AMD profile, by necessity:** `CONFIG_MODULES n→y`, lockdown not force-confidentiality, `lockdown` dropped from `CONFIG_LSM`, `CONFIG_IMA_APPRAISE` off (measure-only), `CONFIG_MODULE_SIG_FORCE` not set. All required so the unsigned out-of-tree `nvidia.ko` can load.

<br>

## 💾 Boot & storage

These records are **preserved verbatim from the installed laptop config** — do not edit them:

- **VMD initrd module:** `(initrd-modules (append '("vmd") %base-initrd-modules))` — required to find the VMD-backed encrypted NVMe at boot.
- **Two LUKS mapped devices:**
  - `cryptroot` — UUID `9f72b7c5-51da-4582-8a95-7dfe68eeadde`, `luks-device-mapping`
  - `crypthome` — UUID `70b74c08-85cd-4161-9fb6-4b2eaacedaed`, `luks-device-mapping`
- **File systems:** `/boot/efi` (vfat, UUID `6447-6147`), `/` → `/dev/mapper/cryptroot` (ext4), `/home` → `/dev/mapper/crypthome` (ext4).
- **Bootloader:** `grub-efi-bootloader`, target `/boot/efi`, ABNT2 keyboard layout.
- **Microcode + firmware:** `(initrd microcode-initrd)` and `(firmware (list linux-firmware))`.

<br>

## 🌡️ Performance & thermals (2026-06-08 revision)

After the NVIDIA switch the desktop felt sluggish. The root cause was **not** the GPU graft and **not** the dormant defconfig — it was the *running* config pinning a `performance` governor on a thermally-limited laptop (GPU already at P0), which fed a heat → `thermald`-clamp → stutter loop, plus `init_on_free` zeroing overhead. The fix lives in `config.scm`:

- **`cpu-epp-balanced` shepherd service.** Instead of a pinned performance governor, a simple shepherd service writes `powersave` to every CPU's `scaling_governor` and `balance_performance` to its `energy_performance_preference`. With `intel_pstate=active`, `powersave` **still boosts to full turbo under load** — but with a fast ramp, cooler idle, and fewer thermald clamps. (Want max clocks on AC when temps allow? swap `balance_performance` → `performance`.)
- **`thermald-service-type`.** Manages the Raptor Lake-HX RAPL + INT340X zones so the CPU/GPU keep boosting instead of throttling under sustained load.
- **`init_on_free=0`** (was `=1`). `init_on_alloc=1` is kept; only the free-time page-zeroing is dropped, recovering alloc/free latency on desktop workloads.
- **`numa_balancing=disable`.** This is a single-node laptop — periodic NUMA scans only add latency.

CPU mitigations were **kept ON** (`mitigations=on`, `spectre_v2=on`, `spec_store_bypass_disable=on`, `tsx=off`); a one-line `mitigations=off` escape hatch (~5–15% on Raptor Lake) is documented in the cmdline but not enabled.

<br>

## 🕹️ Gaming

- **`steam-nvidia`** — the NVIDIA-aware Steam FHS container (so pressure-vessel captures NVIDIA, not Mesa). Installed at both system and Home level.
- **`gamemode`** — CPU governor + niceness + GPU perf during games (`gamemoderun`).
- **`mangohud`** — FPS / frametime / GPU+CPU overlay (`MANGOHUD=1`).
- **`vkbasalt`** — optional Vulkan post-processing (CAS sharpen).
- **NTSYNC for Proton.** A udev rule (`70-ntsync.rules`: `KERNEL=="ntsync", MODE="0660", TAG+="uaccess"`) makes `/dev/ntsync` rootless so `PROTON_USE_NTSYNC=1` works (kernel 7.0 sync primitive — a large latency win over esync/fsync).
- **Controller HID support.** The dormant defconfig has `JOYSTICK_XPAD`, `HID_NINTENDO`, `HID_PLAYSTATION`, `HID_STEAM`, `INPUT_JOYDEV` ready for the controllers.
- **NVIDIA shader disk cache** is enabled in `home.scm` (`__GL_SHADER_DISK_CACHE=1`, path `~/.cache/nvidia`).

<br>

## 🖥️ Display

Laptop HDMI/DP hotplug is handled WM-agnostically (works under Xmonad without a DE):

- **`autorandr`** (+ `arandr` GUI) auto-applies a saved layout on hotplug.
- **`~/.local/bin/dual-monitor`** — a helper installed by `home.scm` via `home-files-service-type`. It checks whether the external output (`HDMI-0`) is connected and lays it out to the right of the internal panel (`eDP-1`) at native resolution, with the external as primary; otherwise it falls back to internal-only. Run `xrandr --query` first and edit the output names, then either call it from your Xmonad `startupHook` or save it via `autorandr --save docked`. (Aliased as `dm` in fish.)

<br>

## ⚙️ Kernel arguments

The live `(kernel-arguments …)` from `config.scm`:

```scheme
(kernel-arguments
 '("quiet"
   "splash"
   ;; Speculative-execution mitigations (mitigations=on auto-applies what
   ;; Raptor Lake needs; nosmt dropped for full SMT performance).
   "mitigations=on"
   "spectre_v2=on"
   "spec_store_bypass_disable=on"
   "tsx=off"
   ;; Memory safety
   "slab_nomerge"
   "page_alloc.shuffle=1"
   "init_on_alloc=1"
   "init_on_free=0"            ; was =1 (KSPP) — =0 recovers alloc/free latency
   "randomize_kstack_offset=on"
   "vsyscall=none"
   ;; IOMMU / DMA (Intel)
   "intel_iommu=on"
   "iommu=pt"
   ;; LSM (no lockdown -> NVIDIA can load)
   "lsm=landlock,yama,apparmor"
   "apparmor=1"
   "security=apparmor"
   ;; CPU frequency / scheduler
   "intel_pstate=active"
   "preempt=full"
   "transparent_hugepage=madvise"
   "numa_balancing=disable"    ; single-node laptop: no periodic NUMA scan stalls
   ;; Entropy / reliability
   "random.trust_cpu=off"
   "mce=1"
   ;; NVIDIA (proprietary). nvidia_drm.modeset=1 is injected by
   ;; nonguix-transformation-nvidia (bottom of file); not duplicated here.
   "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
   ;; Attack-surface reduction + block nouveau
   "modprobe.blacklist=nouveau,firewire_core,firewire_ohci,dccp,sctp,rds,tipc"))
```

> Note: `nvidia_drm.modeset=1` and the nouveau/nova blacklist are **injected by `nonguix-transformation-nvidia`** at the bottom of the file, so they are not duplicated in the block above.

<br>

## 🚀 Apply

Channels are shared at the repo root; system and Home configs are folder-qualified:

```sh
# 1) Channels (shared by both machines)
guix pull -C channels.scm
guix pull

# 2) System
sudo guix system reconfigure predator-helios-intel/config.scm

# 3) Home
guix home reconfigure predator-helios-intel/home.scm
```

<br>

## ⚖️ Trade-offs vs the old AMD box

Honest about what the NVIDIA switch costs (full table in [`../comparison.md`](../comparison.md)):

- **Open-source → proprietary.** AMD/Mesa was 100% free (radeonsi GL + RADV Vulkan): no blob, no kernel↔module lockstep, no nouveau blacklist. NVIDIA buys raw RTX 4060 performance at a real maintenance cost (and `nvda-580` must stay pinned to the loaded module).
- **Monolithic → modular (a hardening regression).** The old box ran the custom SecurityOps kernel with `CONFIG_MODULES=n`, lockdown forced, and module-sig forced — a smaller attack surface. NVIDIA forces `CONFIG_MODULES=y`, lockdown off, and unsigned-module loading. Mitigated by IMA **measure-only** + the **MOK-signing path** in the defconfig header.
- **Sustained power → thermal ceiling.** The desktop held full power indefinitely; this laptop is capped by cooling/TGP — hence `thermald` + the EPP tuning above.

**Carried over unchanged from the AMD box:** LUKS2, nftables stateful firewall, Tor (transparent proxy), `mullvad-daemon`, docker/containerd/libvirt, zram (zstd, 8 GiB), sysctl hardening, fcitx5 IME, GRUB-EFI, and the fish + starship shell.

**See also:** [`../README.md`](../README.md) (repo overview) · [`../ryzen-2200g-amd/README.md`](../ryzen-2200g-amd/README.md) (archived AMD machine) · [`../comparison.md`](../comparison.md) (full AMD → Intel/NVIDIA migration).

<br>

---

<p align="center"><i>In Code We Trust — Security Ops</i></p>

**Maintainer:** Cristian Cezar Moisés — [linkedin.com/in/cristiancezarmoises](https://linkedin.com/in/cristiancezarmoises)
**License:** GNU GPL-3.0 (see [`../LICENSE`](../LICENSE))
**Last updated:** June 09, 2026
