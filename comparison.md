# COMPARATIVO — `config.scm` + `securityops.defconfig`: old AMD → new Intel/NVIDIA

**Host:** `securityops` · **User:** `berkeley` · **Last updated:** 2026-06-09
**From:** AMD Ryzen 3 2200G desktop — GNU Guix (AMD / Mesa) → [`./ryzen-2200g-amd/`](./ryzen-2200g-amd/)
**To:** Acer Predator Helios Neo 16 (PHN16-71) — GNU Guix (Intel iGPU + NVIDIA RTX 4060, proprietary) → [`./predator-helios-intel/`](./predator-helios-intel/)

> **Source note — read this first.**
> Both columns are now sourced from **real files in this repo** — the AMD side is no longer
> reconstructed from memory:
> - **AMD column** ← [`./ryzen-2200g-amd/config.scm`](./ryzen-2200g-amd/config.scm) +
>   [`./ryzen-2200g-amd/securityops.defconfig`](./ryzen-2200g-amd/securityops.defconfig)
>   (the actual old desktop, now archived in-repo).
> - **Intel/NVIDIA column** ← [`./predator-helios-intel/config.scm`](./predator-helios-intel/config.scm) +
>   [`./predator-helios-intel/securityops.defconfig`](./predator-helios-intel/securityops.defconfig)
>   (the current daily driver).
>
> Cells previously guessed and now confirmed against the real AMD files are marked
> *(verified)*. Where the real AMD file genuinely does **not** contain a symbol (e.g. it has no
> Wi-Fi/Bluetooth, sensors, or game-controller section), the honest **n/a (not in file)** /
> *(not in file)* marker is kept — nothing here is fabricated. Everything in the NEW column is
> taken verbatim from the current `predator-helios-intel/` files.

---

## 1. `config.scm` — system configuration

| Area | Old — AMD / Mesa | New — Intel / NVIDIA | Why it changed |
|---|---|---|---|
| **Which kernel boots** | The custom `securityops` kernel (6.19), *monolithic* — confirmed by `CONFIG_MODULES=n` + `amdgpu` built-in *(verified)* | nonguix **`linux`**; the custom `securityops` kernel is **defined but commented out** | The prebuilt proprietary NVIDIA module only matches nonguix `linux`; a self-built kernel would need the module rebuilt against it |
| **`kernel` field** | `(kernel securityops)` *(verified)* | `(kernel linux)` | Same reason as above |
| **IOMMU cmdline** | `amd_iommu=on` + `iommu=force` *(verified)* | `intel_iommu=on` + `iommu=pt` | Platform vendor change (AMD pinned `force`, Intel uses `pt`) |
| **CPU freq cmdline** | `amd_pstate=active` + `cpufreq.default_governor=schedutil` *(verified)* | `intel_pstate=active` | Raptor Lake P-state driver |
| **GPU cmdline** | `amdgpu.sched_policy=2`, `amdgpu.abmlevel=0`, `amdgpu.backlight=0` (Navi 10) *(verified)* | `nvidia.NVreg_PreserveVideoMemoryAllocations=1`; `nvidia_drm.modeset=1` + `modprobe.blacklist=nouveau` **injected by the transformation** | Proprietary NVIDIA needs modeset + nouveau out of the way |
| **Memory-safety cmdline** | KSPP set: `slab_nomerge`, `page_alloc.shuffle=1`, `init_on_alloc=1`, `init_on_free=1`, `randomize_kstack_offset=on`, `vsyscall=none` *(verified)* — **plus extras** `page_poison=1`, `slub_debug=FZ`, `kptr_restrict=2` | Same KSPP base, **except** `init_on_free=0` and **added** `numa_balancing=disable`; the extra `page_poison`/`slub_debug`/`kptr_restrict` lines were dropped | Performance (see §3); the `init_on_free`/`numa` changes are perf tweaks, not security-driven |
| **`initrd-modules`** | not set → `%base-initrd-modules` default, no VMD *(verified — field absent in AMD `config.scm`)* | `(append '("vmd") %base-initrd-modules)` | Encrypted NVMe sits behind **Intel VMD**; without it the box will not boot |
| **GL/Vulkan userspace** | Mesa **radeonsi** (GL) + **RADV** (Vulkan, `RADV_PERFTEST=aco`), 100% open *(verified)* | **NVIDIA proprietary 580.159.04** (`nvda-580`) + Mesa kept only for the Intel iGPU | Discrete RTX 4060 |
| **Xorg driver** | no explicit Xorg driver block — `xlibre-video-amdgpu` is **commented out**, so default `modesetting`/`amdgpu` *(verified — no driver pinned)* | `nvidia` forced: GDM `(wayland? #f)`, `(drivers '("nvidia"))`, `nvidia-driver` in X modules | X server runs on the 4060 |
| **OS-wide graft** | none — Mesa used natively | `((nonguix-transformation-nvidia #:driver nvda-580 #:dynamic-boost? #t) %securityops-os)` grafts `mesa → nvda-580` across **every package + service** and adds `nvidia-service-type` + `nvidia-powerd` | So Steam/pressure-vessel and *all* GL/Vulkan apps hit the 4060; Dynamic Boost shares CPU↔GPU power |
| **Steam package** | `steam` *(verified)* | `steam-nvidia` (NVIDIA-aware FHS container) | Pressure-vessel must capture NVIDIA, not Mesa |
| **Gaming packages** | none beyond Mesa/`steam` *(verified)* | `gamemode`, `mangohud`, `vkbasalt` | Per-game perf + overlays |
| **GPU tools** | `radeontop` *(verified)* | `nvda` (`nvidia-smi`/`nvidia-settings`), `igt-gpu-tools`, `intel-media-driver` (iGPU VAAPI) | NVIDIA + Intel iGPU userspace |
| **Thermal / power services** | none — desktop, free power/thermal *(verified — no `thermald`/EPP service)* | `thermald-service-type` **+** a `cpu-epp-balanced` shepherd service (`powersave` governor + EPP `balance_performance`) | Laptop is thermally limited; see §3 |
| **Gaming device perms** | none *(verified — no `ntsync` rule)* | `ntsync` udev rule (`/dev/ntsync` for Proton `PROTON_USE_NTSYNC=1`) | New kernel sync primitive |
| **Display layout** | single output — no `autorandr`/`arandr` packaged *(verified)* | `autorandr` + `arandr` + a `~/.local/bin/dual-monitor` helper (in `home.scm`) | HDMI/DP hotplug on a laptop |
| **GPU offload env** | `DRI_PRIME=1` set system-wide in `my-env-vars` (AMD offload), with `VDPAU_DRIVER=radeonsi`, `RADV_PERFTEST=aco`, `R600_TEX_ANISO=16` *(verified — in `config.scm`)* | removed; replaced by NVIDIA `__GLX_VENDOR_LIBRARY_NAME=nvidia` / `GBM_BACKEND=nvidia-drm` + shader-disk-cache vars | AMD-only variables are meaningless on NVIDIA |
| **zram swap** | `zram-device` 4 GiB, zstd, priority 100 *(verified)* | `zram-device` 8 GiB, zstd, priority 100 (laptop has no swap partition) | More RAM (16 GiB) on the laptop |
| **Bootloader** | `grub-bootloader` (BIOS) targeting `/dev/nvme0n1`, 1920×1080 themed *(verified)* | `grub-efi-bootloader` targeting `/boot/efi` | UEFI boot on the laptop |
| **Carried over unchanged** | — | nftables stateful firewall, tor (same `torrc`), mullvad-daemon, docker/containerd/libvirt, zram (zstd), sysctl/KSPP hardening, fcitx5 IME | Hardware-agnostic; preserved (LUKS2 `cryptroot`+`crypthome` is **new** on the laptop — the AMD box used plain ext4 partitions) |

---

## 2. `securityops.defconfig` — custom kernel config

> Status change is the headline: on AMD this file **built the kernel that booted** — the AMD
> `config.scm` sets `(kernel securityops)` with `((#:defconfig _) (local-file ".../securityops.defconfig"))`,
> and the defconfig has modules off + `amdgpu` built in. On the new machine it is **dormant** — the
> system runs nonguix `linux` so the prebuilt NVIDIA module loads. Editing the defconfig changes
> nothing at runtime until that kernel is actually booted.

| Symbol / area | Old — AMD | New — Intel/NVIDIA | Why |
|---|---|---|---|
| **`CONFIG_MODULES`** | `n` *(verified)* | `y` | Out-of-tree `nvidia.ko` is a **loadable** module |
| **Lockdown** | `CONFIG_LOCK_DOWN_KERNEL_FORCE_CONFIDENTIALITY=y` *(verified)* | `# …FORCE_CONFIDENTIALITY is not set` | Lockdown refuses the unsigned NVIDIA blob |
| **`CONFIG_LSM`** | `"yama,apparmor,integrity,lockdown,landlock"` — includes `lockdown` *(verified)* | `"landlock,yama,integrity,apparmor,bpf"` (lockdown dropped) | Same reason |
| **`CONFIG_IMA_APPRAISE`** | `=y` **on** *(verified)* — plus `EVM`, `IMA_TRUSTED_KEYRING` | not set (measure-only); `# CONFIG_EVM is not set` | Appraisal/EVM would reject the blob + the Guix store |
| **Module signing** | `CONFIG_MODULES=n` makes module-sig moot in the file; signing is **forced at runtime** via `module.sig_enforce=1` on the cmdline *(verified — no `MODULE_SIG_FORCE` symbol in file)* | `# CONFIG_MODULE_SIG_FORCE is not set` (re-enable after MOK-signing) | Unsigned `nvidia.ko` must load |
| **CPU march** | `CONFIG_MZEN=y` + `CONFIG_MNATIVE=y` (graysky, AMD) *(verified)* | `MNATIVE_INTEL` | Raptor Lake |
| **CPU vendor / pstate / idle** | `CONFIG_CPU_SUP_AMD=y` + `X86_AMD_PLATFORM_DEVICE=y`; pstate driven from the cmdline (`amd_pstate=active`), no in-file pstate/idle symbol *(verified)* | `CPU_SUP_INTEL`, `X86_INTEL_PSTATE`, `INTEL_IDLE` | Vendor change |
| **Hybrid scheduling** | n/a — Zen is homogeneous; no `SCHED_MC_PRIO`/`HFI` in file *(verified — not in file)* | `SCHED_MC_PRIO` + `INTEL_HFI_THERMAL` | P-core/E-core Thread Director |
| **IOMMU** | `CONFIG_AMD_IOMMU=y` (+ `AMD_IOMMU_V2`) *(verified)* | `INTEL_IOMMU` (+`_SVM`, `_DEFAULT_ON`) | Vendor change |
| **GPU DRM** | `CONFIG_DRM_AMDGPU=y` (+ `DRM_AMDKFD`, `HSA_AMD`); no nouveau lines *(verified)* | `DRM_I915=y` **+** `# CONFIG_DRM_NOUVEAU is not set` | Intel iGPU in-tree; NVIDIA brings its own module; nouveau blocked |
| **Storage controller** | no VMD — `CONFIG_VMD` absent *(verified)* | `CONFIG_VMD=y` | Encrypted NVMe behind Intel VMD |
| **Thermal sensors / capping** | **no hwmon/sensors or RAPL section at all** in the AMD file (`SENSORS_K10TEMP` was a guess) *(not in file)* | `SENSORS_CORETEMP` + `INT340X/INT3400/INT3403_THERMAL` + `INTEL_RAPL` + `INTEL_POWERCLAMP` | Required for `thermald` to act on Raptor Lake-HX |
| **Gaming sync** | no `NTSYNC` — absent *(verified — not in file)* | `CONFIG_NTSYNC=y` + `CHECKPOINT_RESTORE` + `USERFAULTFD` | Proton/Wine fast path |
| **Game controllers (HID)** | only `CONFIG_INPUT`/`INPUT_EVDEV`; no joystick/controller HID *(verified — not in file)* | `JOYSTICK_XPAD`, `HID_NINTENDO`, `HID_PLAYSTATION`, `HID_STEAM` | Controllers on the new box |
| **Wi-Fi / Bluetooth** | no Wi-Fi/BT section in file (wired desktop) *(verified — not in file)* | `IWLWIFI` + `IWLMVM` + `MT7921E` + `BT_*` (modules) | Laptop radios |
| **Platform drivers** | `X86_AMD_PLATFORM_DEVICE=y` only; no Acer/laptop platform drivers, no explicit `HIBERNATION` line *(verified — not in file)* | `ACER_WMI`, `ACER_WIRELESS`, `X86_PLATFORM_DEVICES`; `# CONFIG_HIBERNATION is not set` (no swap) | Acer laptop platform |
| **`INIT_ON_FREE_DEFAULT_ON`** | `CONFIG_INIT_ON_FREE_DEFAULT_ON=y` *(verified)* | `# … is not set` | Parity with the cmdline perf change (§3) |
| **`NUMA_BALANCING`** | `CONFIG_NUMA_BALANCING=y` *(verified)* | `# … is not set` | Single-node laptop (§3) |
| **AES instruction set** | `CONFIG_CRYPTO_AES=y` (generic; no `_NI_INTEL` symbol) *(verified)* | `CRYPTO_AES_NI_INTEL` | Intel-named AES-NI acceleration |
| **MGLRU naming** | `CONFIG_MGLRU=y` (older symbol) *(verified)* | `CONFIG_LRU_GEN=y` (+`_ENABLED`) | Same multi-gen LRU, renamed symbol on 7.0 |
| **Kept identical** | — | KSPP core: `RANDOMIZE_BASE`, `STACKPROTECTOR_STRONG`, `HARDENED_USERCOPY`, `INIT_ON_ALLOC_DEFAULT_ON`, `SLAB_FREELIST_*`, `PAGE_TABLE_CHECK*`, `RANDSTRUCT_FULL`, `IMA` measure, `SECCOMP`, multi-gen LRU, `ZRAM`/`ZSWAP` zstd, BBR + fq_codel — all present on **both** sides *(verified)* | Security baseline unchanged |

---

## 3. Latest performance delta (2026-06-08) — why this revision exists

After the NVIDIA switch the desktop felt sluggish (laggy animations, slow app launch/response).
Root cause was **not** the GPU graft and **not** the dormant defconfig — it was the *running*
config: a pinned `performance` governor on a thermally-limited laptop (with the GPU already at
P0) drove the heat → `thermald` clamp → stutter loop, plus `init_on_free` overhead. Fixes:

- `init_on_free=1 → 0` on the cmdline (recovers alloc/free latency; `init_on_alloc=1` kept).
- **added** `numa_balancing=disable` (single-node laptop; kills periodic NUMA scans).
- pinned `performance` governor **→** `cpu-epp-balanced`: `intel_pstate` stays in `powersave`
  (active mode still boosts to **full turbo under load**) with EPP `balance_performance`.
  Cooler at idle, fewer thermald clamps, smoother sustained response.
- defconfig: `CONFIG_INIT_ON_FREE_DEFAULT_ON` and `CONFIG_NUMA_BALANCING` turned off (parity only — dormant).
- CPU mitigations were **kept ON** (KSPP posture); the one-line `mitigations=off` escape hatch
  is documented in the cmdline but not enabled.

---

## Honest trade-offs (AMD → NVIDIA)

- **Open-source → proprietary.** AMD/Mesa was 100% free: no blob, no kernel↔module version
  lockstep, no nouveau blacklist, no proprietary-VAAPI friction (`vainfo` works on Mesa; on
  NVIDIA the EGL VAAPI backend fails — use NVDEC directly). NVIDIA buys raw performance at a
  real maintenance cost.
- **Monolithic → modular (a hardening regression).** The AMD kernel could run with
  `CONFIG_MODULES=n`, lockdown forced, and module-sig forced — a smaller attack surface. NVIDIA
  forces `CONFIG_MODULES=y`, lockdown off, and unsigned-module loading. Partially mitigated by
  IMA measure-only + the MOK-signing path noted in the defconfig header.
- **Sustained power → thermal ceiling.** The desktop held full power indefinitely; the laptop is
  capped by cooling/TGP (~92 W GPU observed). "Full performance" here is a thermal limit — hence
  `thermald` + the EPP tuning in §3.
- **AMD Mesa (RX 5600/5700 *Navi 10* discrete + Vega 8 iGPU) → RTX 4060 *Laptop*** (not the desktop
  4060): the old box ran a discrete Navi 10 Radeon on the 100% free `radeonsi`/RADV stack
  (confirmed by `CONFIG_DRM_AMDGPU` + the Navi 10 cmdline args). The 4060 Laptop is still a category
  jump (3072 CUDA, 8 GB dedicated GDDR6, RT, DLSS, NVENC/NVDEC incl. AV1), but it is the lower-TGP
  mobile part — and it costs the free driver stack.

---

> **Last updated 2026-06-09.** The old AMD machine's `config.scm` and `securityops.defconfig` are
> now archived **in-repo** at [`./ryzen-2200g-amd/`](./ryzen-2200g-amd/), so every AMD-column cell
> above is checked against the real files rather than reconstructed from memory; the Intel/NVIDIA
> column lives in [`./predator-helios-intel/`](./predator-helios-intel/).

---
*In Code We Trust — Security Ops*
