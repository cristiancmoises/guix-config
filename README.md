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
│   ├── config.scm                #   Guix System: nonguix linux + NVIDIA graft + VMD initrd
│   ├── home.scm                  #   Guix Home: fish + starship, IME, apps
│   ├── securityops.defconfig     #   DORMANT custom-kernel defconfig (reference / future MOK build)
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
- **Last updated:** June 09, 2026
- **Videos** → https://youtube.com/@securityops

---

For more about the project → [Security Ops — Wiki](https://wiki.securityops.co)
