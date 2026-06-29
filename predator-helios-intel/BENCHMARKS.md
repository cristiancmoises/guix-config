# Benchmarks — Predator Helios Neo 16 (securityops)

Performance + security validation of the GNU Guix system on the current daily
driver. Run **2026-06-27**, kernel **7.1.1**, governor `powersave` + EPP
`balance_performance` (the `cpu-epp-balanced` service — i.e. the laptop's normal
thermal-balanced state, **not** a pinned performance mode), on AC power.

> Every number below confirms a specific design choice in `config.scm` /
> `securityops.defconfig`. Headline: the box hits **full single-core turbo
> (~4.95 GHz) under load even on the `powersave` governor**, AES-NI makes the
> LUKS2 full-disk encryption nearly free, and the NVIDIA + swap + zram stack is
> live exactly as configured.

## CPU — Intel Core i7-13700HX (8 P + 8 E cores, 24 threads)

| Test | Result | Notes |
|------|--------|-------|
| 1-thread turbo under load | **~4.95 GHz** | confirms `intel_pstate=active` boosts to full turbo despite the `powersave` governor |
| 24-thread sustained clock | ~3.59 GHz | all-core under the laptop thermal/EPP ceiling |
| 7-Zip (all threads) | **~52,400 MIPS** total (compress + decompress) | general multicore throughput |
| OpenSSL SHA-256 (1 thread, 16 KiB) | **~2.40 GB/s** | |
| OpenSSL AES-256-GCM (1 thread) | **~7.15 GB/s** | AES-NI (`CONFIG_CRYPTO_AES_NI_INTEL`) |
| OpenSSL AES-256-GCM (24 threads) | **~39.5 GB/s** | aggregate AES-NI throughput |

The AES-256 numbers are why full-disk encryption costs almost nothing here (see
Storage).

## Memory & swap

| Metric | Value |
|--------|-------|
| RAM | 16 GiB (15.3 GiB usable), ~12 GiB available at idle |
| **zram** | 8 GiB, `zstd` — active (`/dev/zram0`, prio 100) |
| **Disk swapfile** | 24 GiB `/var/swapfile` on the LUKS2-encrypted root (prio -1) |
| **Total swap** | **31 GiB** |

Confirms the `swap-devices` + zram configuration: zram (fast, compressed RAM) is
preferred first, with the 24 GiB encrypted swapfile as deep overflow for
Firefox-class source builds. Sensitive `/tmp` spill lands on the encrypted
swapfile → no plaintext leak.

## Storage — NVMe behind Intel VMD, LUKS2

| Target | Write (2 GiB, `fdatasync`) | Notes |
|--------|----------------------------|-------|
| `/var/tmp` (LUKS2-encrypted root, ext4) | **~1.0 GB/s** | encryption is nearly free thanks to AES-NI |
| `/tmp` (tmpfs, RAM) | **~5.7 GB/s** | RAM-backed scratch |

> ⚠️ At benchmark time the running `/tmp` was still **4 GiB** (the previous
> generation). The hardened **16 GiB + `noexec`** `/tmp` is in `config-sway.scm`
> and applies once you `guix system reconfigure` onto it and remount/reboot.

## GPU — NVIDIA GeForce RTX 4060 Laptop (Ada AD107)

| Metric | Value |
|--------|-------|
| Driver | **580.159.04** (proprietary, grafted OS-wide) |
| VRAM | 8 GiB GDDR6 (8188 MiB) |
| Vulkan | **1.4.312**, device `NVIDIA GeForce RTX 4060 Laptop GPU` |
| Idle temp | 44 °C |

Confirms the `nonguix-transformation-nvidia #:driver nvda-580` graft and the
`nvidia-service-type` / `nvidia-powerd` stack are live (Vulkan reports the 4060
directly, not Mesa/llvmpipe).

## Security — lynis audit

| Metric | Value |
|--------|-------|
| Hardening index (default) | **66** (non-root `--quick`) |
| Hardening index (tuned) | **73** via `lynis audit system --profile /etc/lynis/custom.prf` |
| | The profile (declared in `config-sway.scm`) documents/skips tests that conflict with this laptop's role (gaming/dev/USB/Docker/VPN) or are heavy logging the user declined — standard Lynis per-host tuning, each skip with a reason. After a `guix system reconfigure` the live KSPP sysctls (`perf_event_paranoid=3`, `dev.tty.ldisc_autoload=0`, `log_martians`) + the `/etc/issue` legal banner also clear KRNL-6000 and BANN-7126 *for real* (~76). |

Pairs with the kernel-level hardening baked in: KSPP `init_on_alloc`,
`slab_nomerge`, `randomize_kstack_offset`, `mitigations=on`, ~20 KSPP/Lynis
`sysctl`s, `yama ptrace_scope=1` (baked to 1 so RDR2/GTA run without a runtime
toggle), nftables deny-by-default, AppArmor + landlock + yama LSM stack, AIDE
file integrity, hardened OpenSSH. (Kernel `lockdown` is intentionally OFF so the
unsigned NVIDIA module loads.)

---

*Methodology: `openssl speed`, `7z b`, `dd … conv=fdatasync`, `free`/`zramctl`/
`swapon`, `nvidia-smi`, `vulkaninfo --summary`, `lynis audit system --quick`.
Re-run any of these to reproduce.*
