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

**Hardened • Minimal • Private • Fast**
Declarative, hardened, private, and fast [GNU Guix](https://guix.gnu.org) System + Guix Home configurations for host `securityops` (user `berkeley`). Everything — the kernel stance, the firewall, the VPN, the desktop, the input methods — is expressed as reproducible Scheme. The repo now ships **two machines**: a current Intel/NVIDIA laptop daily driver and the previous, archived AMD desktop, sharing one set of channels and one hardening philosophy. *In Code We Trust — Security Ops.*

<br>

## 🖥️ Two machines

| Folder | Machine | CPU | GPU | Kernel / graphics stance | Status |
| --- | --- | --- | --- | --- | --- |
| [`predator-helios-intel/`](./predator-helios-intel/README.md) | Acer Predator Helios Neo 16 (PHN16-71) | Intel Core i7-13700HX (Raptor Lake-HX, 8P+8E / 24t) | NVIDIA RTX 4060 Laptop (Ada AD107) + Intel UHD iGPU (Optimus/MUX) | nonguix `linux` (blobs) + proprietary **NVIDIA 580.159.04 grafted** OS-wide; Mesa kept for the iGPU | 🟢 **ACTIVE** daily driver |
| [`ryzen-2200g-amd/`](./ryzen-2200g-amd/README.md) | AMD Ryzen 3 2200G desktop | AMD Ryzen 3 2200G (Zen, 4c/4t, Vega 8) | Radeon RX 5600/5700 (Navi 10) — 100% free **Mesa** (radeonsi + RADV) | Custom **monolithic** SecurityOps kernel (`CONFIG_MODULES=n`, lockdown forced, IMA appraise) | 🗄️ **ARCHIVED** (previous box) |

> The honest trade-off going from AMD → Intel/NVIDIA: a fully free Mesa stack became a proprietary NVIDIA graft, and a monolithic lockdown kernel became a modular one (modules on, unsigned `nvidia.ko`, lockdown off). See **[comparison.md](./comparison.md)** for the full accounting.

<br>

## 💻 Predator Helios — at a glance

The current daily driver: an Acer gaming laptop carrying the full SecurityOps stack with two interchangeable display variants.

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

- **Graphics:** proprietary **NVIDIA 580.159.04** grafted OS-wide (`mesa → nvda-580`) so Steam / pressure-vessel and every GL/Vulkan app hits the RTX 4060; **Mesa kept only for the Intel UHD iGPU**; `nvidia-powerd` Dynamic Boost on; nouveau blacklisted.
- **Kernel:** boots nonguix **`linux`** (blob-enabled) so the prebuilt `nvidia.ko` loads; a dormant custom `securityops` kernel + MOK-signing path is parked in the config for a future return to the monolithic posture.
- **Boot & storage:** `vmd` initrd module (the encrypted NVMe is invisible without it) → two LUKS2 mapped devices (`cryptroot` + `crypthome`) → `grub-efi-bootloader`.
- **Two display variants** (identical kernel, hardening, firewall, Tor, Mullvad, zram, audio — they differ *only* in the display server + login manager):

| File | Display server | Login manager | Session WM |
|------|----------------|---------------|------------|
| [`config-sway.scm`](./predator-helios-intel/config-sway.scm) | **Sway / wlroots (Wayland)** | **greetd** (agreety text greeter) | **Sway** |
| [`config-xlibre.scm`](./predator-helios-intel/config-xlibre.scm) | XLibre 25.1.7 (X11) | SLiM | xmonad |

> `config.scm` is the **active** file and currently mirrors **`config-sway.scm`**. Full writeup → [`predator-helios-intel/README.md`](./predator-helios-intel/README.md).

<br>

## 📊 Benchmarks

Measured **2026-06-27**, kernel **7.1.1**, governor `powersave` + EPP `balance_performance` (the laptop's normal thermal-balanced state — **not** a pinned performance mode), on AC power. Every number validates a specific choice in `config.scm` / `securityops.defconfig`. Full methodology and notes → [`predator-helios-intel/BENCHMARKS.md`](./predator-helios-intel/BENCHMARKS.md).

| Area | Metric | Result |
|------|--------|--------|
| **CPU** | 1-thread turbo under load (on `powersave`) | **~4.95 GHz** |
| **CPU** | 24-thread sustained clock | ~3.59 GHz |
| **CPU** | 7-Zip (all threads, compress + decompress) | **~52,400 MIPS** |
| **Crypto** | OpenSSL SHA-256 (1 thread, 16 KiB) | ~2.40 GB/s |
| **Crypto** | OpenSSL AES-256-GCM (1 thread, AES-NI) | **~7.15 GB/s** |
| **Crypto** | OpenSSL AES-256-GCM (24 threads, aggregate) | **~39.5 GB/s** |
| **Storage** | `/var/tmp` write — LUKS2-encrypted root, ext4 (`fdatasync`) | **~1.0 GB/s** |
| **Storage** | `/tmp` write — tmpfs (RAM) | **~5.7 GB/s** |
| **Memory** | RAM / zram (zstd) / encrypted swapfile → **total swap** | 16 GiB / 8 GiB / 24 GiB → **31 GiB** |
| **GPU** | NVIDIA RTX 4060 Laptop — driver / Vulkan / idle temp | **580.159.04** / **Vulkan 1.4.312** / **44 °C** |
| **Security** | lynis hardening index (non-root `--quick`, 205 tests) | **63** |

> Headline: the box hits **full single-core turbo (~4.95 GHz) under load even on the `powersave` governor**, AES-NI makes the LUKS2 full-disk encryption nearly free (1.0 GB/s encrypted writes), and the NVIDIA + zram + swap stack is live exactly as configured.

<br>

## 🖥️ Sway (Wayland) vs XLibre (X11)

Both variants boot the **same** kernel, hardening, firewall, Tor, Mullvad, zram and NVIDIA graft — they differ **only** in the display layer, but that layer has real security consequences. Condensed from [`predator-helios-intel/README.md`](./predator-helios-intel/README.md#-sway-wayland-vs-xlibre-x11--benefits--differences):

| | **`config-sway.scm`** — Sway / Wayland | **`config-xlibre.scm`** — XLibre / X11 |
|---|---|---|
| **Display server** | Sway (wlroots compositor) | XLibre X server 25.1.7 (X.Org fork) |
| **Login manager** | greetd (agreety **text** greeter) | SLiM (graphical X greeter) |
| **Window manager** | Sway (built-in tiling) | xmonad (+ xmobar) |
| **NVIDIA** | `--unsupported-gpu` + `nvidia_drm.modeset=1` + software cursor | native `nvidia` DDX, `ForceFullCompositionPipeline` |
| **`/tmp`** | **16 GiB, `nosuid,nodev,noexec`** (hardened) | 4 GiB `nosuid,nodev` |
| **`ptrace_scope`** | **`2` (hardened)** — RDR2 needs a runtime toggle | `1` (relaxed so RDR2/Arxan runs out of the box) |
| **Security posture** | **more secure** (client isolation, smaller surface) | more compatible (X11 tooling, no GPU caveats) |

### Why the Sway variant is more secure 🔐

- **Client isolation (the big one).** Under X11 *any* client can read every other window's keystrokes and pixels (global input + `XGetImage`) — one compromised app can keylog your password manager or screen-scrape a banking tab. Wayland isolates clients so an app sees only its **own** surface and input.
- **Smaller privileged surface.** No monolithic, historically-CVE-heavy X server brokering all I/O; wlroots is far smaller and runs unprivileged via libseat/elogind, and the greeter is a minimal **text** prompt (no compositor at the login stage).
- **Hardened ephemeral scratch + strongest `ptrace`.** `/tmp` is a 16 GiB `noexec` RAM tmpfs wiped each reboot with spill going to the **LUKS2-encrypted** swapfile (no plaintext leak), and `kernel.yama.ptrace_scope=2` by default (lower it at runtime only when a game's anti-tamper needs it).

<br>

## 🗂️ Repository layout

```text
guix-config/
├── README.md                     # ← you are here (overview / front page)
├── comparison.md                 # AMD desktop  →  Intel/NVIDIA laptop migration
├── channels.scm                  # shared Guix channels (self-hosted mirrors) — used by BOTH machines
├── LICENSE                       # GNU GPL-3.0
├── .gitignore                    # blocks *.mkv + build/cache artifacts
├── screenshots/                  # shared media (referenced by absolute codeberg URLs)
├── wallpapers/
├── videos/
│
├── predator-helios-intel/        # 🟢 CURRENT — Intel i7-13700HX + RTX 4060 laptop
│   ├── config.scm                #   ACTIVE system config (currently mirrors config-sway.scm)
│   ├── config-sway.scm           #   Sway / Wayland + greetd variant
│   ├── config-xlibre.scm         #   XLibre / X11 + SLiM + xmonad variant
│   ├── home.scm                  #   Guix Home: fish + starship, IME, apps, NVIDIA graft
│   ├── securityops.defconfig     #   DORMANT custom-kernel defconfig (reference / future MOK build)
│   ├── BENCHMARKS.md             #   measured CPU / GPU / disk / crypto / security numbers
│   ├── dotfiles/                 #   xmonad.hs + Sway config + keybind-parity map + helpers
│   └── README.md
│
└── ryzen-2200g-amd/              # 🗄️ ARCHIVED — Ryzen 3 2200G + RX 5600/5700 desktop
    ├── config.scm                #   Guix System: monolithic SecurityOps kernel, Mesa
    ├── home.scm                  #   Guix Home
    ├── securityops.defconfig     #   the (then-active) hardened monolithic defconfig
    ├── .bashrc
    ├── berkeley-config/          #   XMonad / Rofi / Xmobar+Polybar dotfiles (this machine)
    ├── extras/                   #   helper scripts
    └── README.md
```

<br>

## 🚀 Quick start / Apply

All paths are folder-qualified — pick the machine you are reconfiguring.

```sh
# 1) Pin channels (shared root file), then pull
guix pull -C channels.scm
guix pull

# 2) System (run as root)
sudo guix system reconfigure predator-helios-intel/config.scm     # current laptop
# sudo guix system reconfigure ryzen-2200g-amd/config.scm         # archived desktop

# 3) Home (run as your user)
guix home reconfigure predator-helios-intel/home.scm              # current laptop
# guix home reconfigure ryzen-2200g-amd/home.scm                  # archived desktop
```

> `channels.scm` lives at the repo **root** and is shared by both machines — same self-hosted mirrors at `git.securityops.co` (guix, nonguix, rde, radix, ajattix, rosenthal, guix-hpc, small-guix, guix-xlibre, saayix).
>
> **Switch display variants on the laptop:** apply Sway with `sudo bash ~/promote-sway-config.sh` then `sudo guix system reconfigure --fallback /etc/config.scm` from a physical TTY; revert with `sudo guix system roll-back` or by reconfiguring from `config-xlibre.scm`.

<br>

## 🔀 AMD → Intel/NVIDIA migration

The daily driver moved from a Ryzen 2200G desktop on a 100% free Mesa stack and a monolithic lockdown kernel to an Acer Predator Helios laptop running nonguix `linux` with the proprietary NVIDIA 580 driver grafted OS-wide (Mesa kept only for the Intel iGPU). It is a deliberate, documented hardening regression in exchange for working RTX 4060 acceleration — mitigated by IMA measure-only and a MOK-signing path. **Read the full side-by-side in [comparison.md](./comparison.md).**

<br>

## 🔐 Shared features at a glance

Both machines carry the same security and privacy core:

- **LUKS2 full-disk encryption** (separate `cryptroot` + `crypthome`)
- **nftables** stateful, deny-by-default firewall
- **Mullvad** WireGuard VPN (`mullvad-daemon`)
- **Tor** for transparent / app-level anonymity
- **zram** swap with `zstd` compression
- **fcitx5** input method (incl. Japanese / Anthy)
- **Docker / containerd / QEMU + libvirt** for containers and VMs
- `sysctl` hardening, GRUB boot (BIOS on the desktop, EFI on the laptop), and **fish + starship** as the interactive shell

<br>

## 🪶 Slim repo

The git history was rewritten to purge multi-GB screen recordings (`record.mkv` 3.7 GB, `game.mkv` 761 MB, `recorded.mkv` 450 MB, `game.webm` 382 MB, `game.mp4` 50 MB) that had bloated `.git` to ~5.1 GB — the working tree is now ~50 MB. The root [`.gitignore`](./.gitignore) blocks `*.mkv` plus build/cache artifacts (XMonad recompiles, the cmus library cache). Demo clips are hosted externally on **YouTube [@securityops](https://youtube.com/@securityops)**.

<br>

## 📚 Further reading

- **[`predator-helios-intel/README.md`](./predator-helios-intel/README.md)** — the current laptop in full: NVIDIA graft, kernel, boot/storage, Sway-vs-XLibre, gaming, kernel arguments.
- **[`predator-helios-intel/BENCHMARKS.md`](./predator-helios-intel/BENCHMARKS.md)** — measured CPU / GPU / disk / crypto / security numbers and methodology.
- **[`predator-helios-intel/dotfiles/README.md`](./predator-helios-intel/dotfiles/README.md)** — xmonad ↔ Sway keybind-parity map and the xmonad "mod key" PATH fix.
- **[`comparison.md`](./comparison.md)** — the complete AMD desktop → Intel/NVIDIA laptop migration (every config delta, with reasons).
- **[`ryzen-2200g-amd/README.md`](./ryzen-2200g-amd/README.md)** — the archived AMD desktop.

<br>

## 📸 Screenshots

<p align="center">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/scream.png"        width="400">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/amazingxlibre.png" width="400">
</p>
<p align="center">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/cmus.png"           width="400">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/fastfetch.png"      width="400">
</p>

<br>

---

- **Maintainer:** [Cristian Cezar Moisés](https://linkedin.com/in/cristiancezarmoises)
- **License:** GNU GPL-3.0
- **Last updated:** 2026-06-27
- **Videos** → https://youtube.com/@securityops

---

For more about the project → [Security Ops — Wiki](https://wiki.securityops.co)
