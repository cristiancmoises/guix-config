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
Declarative GNU Guix system — AMD Ryzen 2200G + Radeon RX 5600/5700

**Kernel:** Custom SecurityOps 6.18.4 (KSPP + XanMod + Clear Linux + extreme hardening)

<br>

## ✨ Features at a Glance

- System-wide Mullvad WireGuard + Tor transparent proxy  
- lockdown=confidentiality • nosmt • init_on_{alloc,free}=1  
- USB deny-by-default + udev whitelist  
- XMonad + Rofi + Xmobar tiling workflow  
- Full Japanese input (Fcitx5-Anthy)  
- Steam • Proton • MangoHud • VAAPI/Vulkan  
- 4 GB zswap (zstd) • BBR • fq_codel  
- Docker + QEMU

<br>

## 📸 Screenshots

<p align="center">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/scream.png"     width="400">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/amazingxlibre.png" width="400">
</p>
<p align="center">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/cmus.png"       width="400">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/fastfetch.png"  width="400">
</p>

<br>

## 🔐 Hardened Kernel 
### > Flags
```scheme
# ┌────────────────────────────── Base ───────────────────────────────┐
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_HZ_1000=y               # High tick rate → very responsive desktop

# ┌────────────────────── CPU & Scheduling ──────────────────────┐
CONFIG_MZEN=y
CONFIG_MNATIVE=y
CONFIG_CPU_SUP_AMD=y
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_PREEMPT=y               # Full preemption
CONFIG_PREEMPT_DYNAMIC=y
CONFIG_NUMA_BALANCING=y
CONFIG_SCHED_HRTICK=y          # High-resolution scheduler ticks

# ┌──────────────────── Modern I/O & Network ─────────────────────┐
CONFIG_IO_URING=y              # Fast async I/O (io_uring)
CONFIG_TCP_CONG_BBR=y          # Best congestion control for high-speed/torrent
CONFIG_BFQ_GROUP_IOSCHED=y
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_DEFAULT_FQ_CODEL=y      # Low latency + fairness

# ┌───────────────────── Security Hardening ──────────────────────┐
CONFIG_SECURITY=y
CONFIG_SECURITY_APPARMOR=y
CONFIG_DEFAULT_SECURITY_APPARMOR=y
CONFIG_SECURITY_YAMA=y
CONFIG_SECURITY_LOCKDOWN_LSM=y
CONFIG_SECURITY_LANDLOCK=y
CONFIG_LSM="yama,apparmor,integrity,lockdown,landlock"

CONFIG_RANDOMIZE_BASE=y        # KASLR
CONFIG_PAGE_TABLE_ISOLATION=y  # KPTI (Meltdown)
CONFIG_RETPOLINE=y             # Spectre v2
CONFIG_HARDENED_USERCOPY=y
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_INIT_ON_ALLOC_DEFAULT_ON=y   # Zero memory on alloc
CONFIG_INIT_ON_FREE_DEFAULT_ON=y    # Zero memory on free
CONFIG_REFCOUNT_FULL=y
CONFIG_STRICT_DEVMEM=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_STRICT_MODULE_RWX=y

CONFIG_GCC_PLUGIN_RANDSTRUCT=y
CONFIG_RANDSTRUCT_FULL=y
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_SLAB_FREELIST_HARDENED=y
CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
CONFIG_PAGE_TABLE_CHECK=y
CONFIG_PAGE_TABLE_CHECK_ENFORCED=y

# ┌───────────────────────── Integrity ──────────────────────────┐
CONFIG_IMA=y
CONFIG_IMA_APPRAISE=y
CONFIG_IMA_TRUSTED_KEYRING=y
CONFIG_EVM=y
CONFIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_KEYRING=y

# ┌──────────────────────── Sandboxing ──────────────────────────┐
CONFIG_SECCOMP=y
CONFIG_SECCOMP_FILTER=y
# CONFIG_USER_NS=n             # Disabled → strongest sandboxing (containers need it)

# ┌────────────────────── Monolithic kernel ─────────────────────┐
CONFIG_MODULES=n               # No loadable modules → huge security + simplicity win

# ┌────────────────────────── Memory ────────────────────────────┐
CONFIG_ZSWAP=y
CONFIG_ZSWAP_COMPRESSOR=zstd
CONFIG_ZRAM=y
CONFIG_ZRAM_DEFAULT_COMPRESSOR=zstd
CONFIG_ZRAM_WRITEBACK=y
CONFIG_MGLRU=y                 # Multi-gen LRU → better memory pressure handling
CONFIG_TRANSPARENT_HUGEPAGE=y  # Performance + memory efficiency

# ┌─────────────────────── Filesystems ──────────────────────────┐
CONFIG_EXT4_FS=y
CONFIG_BTRFS_FS=y
CONFIG_FUSE_FS=y

# ┌────────────────────── Graphics (Navi 10) ────────────────────┐
CONFIG_DRM_AMDGPU=y
CONFIG_DRM_AMDKFD=y            # ROCm compute support
CONFIG_HSA_AMD=y

# ┌────────────────────── Storage & LUKS ────────────────────────┐
CONFIG_BLK_DEV_DM=y
CONFIG_DM_CRYPT=y
CONFIG_DM_VERITY=y
CONFIG_DM_INTEGRITY=y
CONFIG_NVME=y
CONFIG_AHCI=y
CONFIG_USB_STORAGE=y

# ┌────────────────────── Crypto (minimal) ──────────────────────┐
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_POLY1305=y

# ┌─────────────────────── AMD IOMMU ────────────────────────────┐
CONFIG_IOMMU_SUPPORT=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=y
```

### > Arguments
```scheme
(kernel-arguments
 '("quiet" "splash" "noatime"
   "mitigations=auto" "nosmt"
   "amd_iommu=on" "iommu=pt"
   "lsm=yama,apparmor,integrity,lockdown,landlock"
   "apparmor=1" "security=apparmor"
   "lockdown=confidentiality" "module.sig_enforce=1"
   "slab_nomerge" "page_alloc.shuffle=1"
   "init_on_alloc=1" "init_on_free=1"
   "kptr_restrict=2" "randomize_kstack_offset=on"
   "vsyscall=none" "preempt=full"
   "amd_pstate=active" "tcp_congestion_control=bbr"
   "net.core.default_qdisc=fq_codel"
   "random.trust_cpu=off" "spec_store_bypass_disable=prctl"
   "mce=1" "amdgpu.sched_policy=2"
   "irqaffinity=1-3" "rcu_nocbs=0-3"
   "modprobe.blacklist=firewire_core,firewire_ohci,dccp,sctp,rds,tipc"))
```   

## 📦 Package Highlights

- Graphics • mesa vulkan-loader libva mangohud
- Browsers • zen-browser torbrowser icecat
- Multimedia • mpv vlc obs
- Development • gcc rust python emacs
- WM • xmonad rofi xmobar polybar
- Network • mullvad-vpn tor qbittorrent
- Fonts • iosevka noto source-han-sans
- Containers • docker qemu
- Security • firejail clamav nftables

## 🌟 Why this config?

- 100% reproducible
- Very hard attack surface
- Pleasant daily driver
- Strong privacy defaults
- Modern AMD optimized
---

Maintainer: [Cristian Cezar Moisés](https://linkedin.com/in/cristiancezarmoises)
License: GNU GPL-3.0
Last update: January 08, 2026
Videos → https://youtube.com/@securityops

---

For more information about my project -> [Security Ops - Wiki](https://wiki.securityops.co)
