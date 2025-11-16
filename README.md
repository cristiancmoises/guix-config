<p align="center">  <img src="https://i.ibb.co/9thQktG/re.png" width="640" height="160" alt="Guix Config Banner"></p>

<img src="https://codeberg.org/guix/artwork/raw/branch/master/badges/gnu-guix-reproducible.svg">

> Some files included here are forked from other projects, such as MPV shaders, Simple History, Cmus, FFMpeg recorder.

This configuration delivers a **secure**, **high‑performance**, and **minimalist** GNU Guix system for the host **`securityops`**, purpose‑built for modern workloads and hardened against common attack vectors. It is tuned for:

- 🧠 **AMD Ryzen 3 2200G** — 4 cores / 4 threads for balanced desktop and development performance  
- 🎮 **Radeon RX 5600/5700 Series** — discrete GPU acceleration for gaming, rendering, and compute tasks  
- 🌐 **Privacy‑first networking** — seamless integration with Mullvad VPN (WireGuard) and Tor for anonymous, encrypted traffic  
- 🖼️  **Xmonad** tiling window manager — keyboard‑driven workflow with Rofi for fast application launching  
- 🎥 **Multimedia acceleration** — MPV and VLC configured for hardware‑assisted decoding and smooth playback  
- 🎮 **Gaming‑ready** — Steam and Proton support for native and Windows titles  
- 🌍 **Full Japanese input** — Fcitx5 IME with extensive font coverage (Iosevka, Noto) for multilingual environments  
- 🐳 **Containerization & virtualization** — Docker for isolated workloads and QEMU for virtual machine hosting  
- 🔒 **Hardened SecurityOps kernel** — custom build with [KSPP‑recommended](https://kspp.github.io/Recommended_Settings.html) self‑protection settings, Xanmod and Clear Linux improvements and additional hardened boot arguments
- 🚀 **Latest Linux Kernel** - Latest stable kernel and the mainline kernel(for tests).

With [**XMonad**](https://xmonad.org) as the tiling window manager, a **custom [Linux kernel**](https://www.kernel.org/), and a curated set of packages and services, this setup balances **performance**, **security**, and **aesthetics** for gaming (Steam), privacy (Mullvad VPN, Tor), development workflows, and Japanese input support.

**Maintainer**: Cristian Cezar Moisés  
**Last Updated**: November 01, 2025

<p align="center">  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/amazingxlibre.png" width="820" height="460"></p>

## 📝 Summary

This GNU Guix configuration delivers a privacy-first, high-performance system optimized for an AMD Ryzen 3 2200G and Radeon RX 5600/5700 Series GPU. Powered by the securityops kernel, it includes AMD-specific tuning, 4GB zswap with zstd compression, and BBR networking for efficiency. Xmonad, paired with Rofi and Xmobar, provides a lightweight tiling desktop. Mullvad VPN and Tor ensure secure, anonymous networking, enforced by a strict NFTables firewall. Japanese input via Fcitx5 with Anthy and extensive fonts (Iosevka, Noto) enhance usability. The system supports gaming (Steam, Proton), torrenting (qBittorrent), multimedia (MPV, VLC), and development (GCC, Rust, Emacs). Docker and QEMU enable containerization and virtualization, though Libvirt is temporarily disabled due to a derivation error. Custom channels ([small-guix](https://codeberg.org/fishinthecalculator/small-guix.git), [ajattix](https://git.ajattix.org/hashirama/ajattix.git), [radix](https://codeberg.org/anemofilia/radix.git)) add flexibility, with detailed comments ensuring maintainability.

- [Key Features](#key-features) - Privacy, security, performance, and more
- [Security Ops Kernel](#securityops-kernel) - Hardened (Latest) Linux Kernel for Self-Protection
- [Kernel Arguments](#kernel-arguments) - Installation instructions
- [Package Highlights](#package-highlights) - Key software packages
- [Services](#services) - Services
- [Modules](#modules) - Kernel Modules
- [Xlibre Configuration](#xlibre-configuration) - Custom Xlibre setup
- [Steam Configuration](#steam-configuration) - Red Dead Redemption (Launch Options)
- [OS Comparison](#os-comparison) - Guix vs. other Linux distributions
- [Final Considerations](#final-considerations-why-gnu-guix-is-better) - Why choose Guix
- [YouTube Channel](https://www.youtube.com/@securityops) - Videos and tutorials
- [License](#license) - Licensing information

# ⚙️ Optimized For

- ✅ **GPU Performance**: Tuned AMDGPU drivers with Mesa for gaming and rendering.
- ✅ **CPU Efficiency**: SecurityOps kernel with AMD P-state, full preemption, and all 4 threads enabled for maximum responsiveness.
- ✅ **Security**: Kernel Self Protection with custom arguments and Strict NFTables
- ✅ **Privacy**: Mullvad VPN and privacy-focused browsers (Tor Browser, Icecat, Zen Browser).
- ✅ **Data Integrity**: Safe ext4 journaling and zRAM swap.
- ✅ **Aesthetics**: Custom GRUB theme and XMonad with Polybar/Xmobar.

## 📸 Screenshots

<p align="center">  
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/wezterm.png" width="500">  
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/screen.png" width="500">  
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/xlibre.png" width="500">  
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/amazing.png" width="500">
</p>

## ✨ Key Features

### **Privacy**:  
- All traffic routed through Mullvad VPN via WireGuard (wg0-mullvad).  
- Tor configured for transparent proxying (SOCKS 9050, TransPort 9040).  
- DNS locked to Mullvad’s servers (100.64.0.23).  
- Anti-spoofing and logging in NFTables firewall.

### **Security**
- **Hardened Kernel Self‑Protection** — Custom kernel built with KSPP‑recommended settings and enforced runtime safeguards:  
  `module.sig_enforce=1` (only load cryptographically signed modules),  
  `lockdown=confidentiality` (restrict kernel features that could leak sensitive data),  
  `mitigations=auto` (enable CPU vulnerability mitigations automatically).
- **USB Attack Surface Reduction** — All USB devices are unauthorized by default (`usbcore.authorized_default=0`), with Udev rules whitelisting only trusted hardware.
- **Application Containment & Malware Scanning** — Firejail sandboxes isolate untrusted applications; ClamAV provides on‑demand and scheduled antivirus scanning.


### **Performance**:  
- AMD-specific tuning: amdgpu.ppfeaturemask=0xffffffff, amd_pstate=active, schedutil governor.  
- Zswap with zstd compression (4GB) for efficient memory management.  
- BBR TCP congestion control and fq_codel for optimized networking.  
- Hardware-accelerated video decoding (VAAPI) and rendering (Mesa, Vulkan).

### **Functionality**:  
- Xmonad with Rofi for a lightweight, tiling desktop.  
- Japanese input via Fcitx5 with Anthy, supporting GTK/Qt applications.  
- Extensive font support for coding (Iosevka) and CJK scripts (Noto, Source Han Sans).  
- Gaming with Steam, Proton, and Mangohud for performance overlays.  
- Torrenting with qBittorrent and firewall rules for ports 6881-6890.

### **Maintainability**:  
- Declarative Guix configuration for reproducibility.  
- Custom channels (small-guix, ajattix, radix) for Mullvad, dictionaries, and more.  
- Detailed comments in config.scm for easy updates.

## 📦 Package Highlights

| Category | Packages |
|----------|----------|
| **Graphics** | xf86-video-amdgpu, mesa, libva, vulkan-loader, mangohud |
| **Multimedia** | mpv, vlc, obs, openshot, gimp |
| **Browsers** | zen-browser-bin, icecat, torbrowser, google-chrome-stable |
| **Development** | gcc, rust, python, go, emacs, vim |
| **Window Management** | xmonad, rofi, xmobar, polybar |
| **Networking** | mullvad-vpn-desktop, tor, qbittorrent, wireshark |
| **Fonts** | font-iosevka, font-adobe-source-han-sans, font-noto |
| **Virtualization** | qemu, docker, containerd |
| **Security** | firejail, gnupg, clamav, nftables |

### VPN Recommendation for System-Wide Privacy:

<img src="https://mullvad.net/press/MullvadVPN_logo_Round_RGB_Color_positive.png" width=30% height=30%>

[Mullvad VPN](https://mullvad.net/en)
- **Purpose**: Masks your IP address, a key fingerprinting component, protecting all internet traffic.
- **Steps**: Visit [Mullvad VPN](https://mullvad.net/en), generate an account, pay €5/month, download the app, and connect to a server.

## For More Privacy Use:

<a href="https://codeberg.org/berkeley/torando" target="_blank">  
  <img src="https://github.com/cristiancmoises/torando/assets/86272521/045451b7-545a-4798-9df8-980b122b829d" width="350" height="220" alt="Torando - TOR VPN"/>
</a>
<a href="https://codeberg.org/berkeley/brutefox" target="_blank">
  <img src="https://github.com/cristiancmoises/brutefox/assets/86272521/15afb340-af3f-4c3b-b029-d80ab0da59a0" width="350" height="220" alt="BrutefoX"/>
</a>

# SecurityOps Kernel

**SecurityOps** is a custom Linux kernel built for **maximum resilience** on modern AMD hardware.  
It integrates **XanMod optimizations**, **Clear Linux performance patches**, and **KSPP (Kernel Self Protection Project) hardening** into one consistent baseline.  

This kernel is tuned for:

- 🖥️ **AMD Ryzen 2200G APU** (Zen1 cores, integrated GPU)  
- 🎮 **AMD Radeon RX 5600/5700** (Navi 10, modern gaming & compute GPU)  
- 🔒 **Security hardening** against memory corruption, ROP/JOP, privilege escalation, and kernel info leaks  
- ⚡ **Performance & low-latency responsiveness** (HZ=1000, voluntary preemption, zswap/zram)  
- 🧩 **Minimal, auditable driver set** — only what’s required for the hardware in use  

---

## 🔐 Hardened Configuration Overview

The following table summarizes the **key security and performance features** enabled in `securityops.defconfig`:

| Category               | Config Option(s)                                                                 | Purpose                                                                 |
|------------------------|----------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| **Stack Protection**   | `CONFIG_STACKPROTECTOR_STRONG`, `CONFIG_CC_STACKPROTECTOR_REGULAR`               | Detects stack corruption via canaries                                   |
| **Memory Safety**      | `CONFIG_ZSWAP`, `CONFIG_ZRAM`, `CONFIG_STRICT_KERNEL_RWX`, `CONFIG_STRICT_DEVMEM` | Compressed swap, hardened virtual memory, prevents arbitrary RW/exec     |
| **Execution Control**  | `CONFIG_DEBUG_RODATA`, `CONFIG_STRICT_KERNEL_RWX`                                | Marks kernel memory as read-only or NX                                  |
| **Scheduler / Timing** | `CONFIG_HZ_1000`, `CONFIG_HIGH_RES_TIMERS`, `CONFIG_PREEMPT_VOLUNTARY`           | Low-latency scheduling with voluntary preemption                        |
| **Filesystem Support** | `CONFIG_EXT4_FS`, `CONFIG_BTRFS_FS`, `CONFIG_F2FS_FS`, `CONFIG_XFS_FS`, `CONFIG_FUSE_FS` | Wide support for secure, modern filesystems                            |
| **GPU / Compute**      | `CONFIG_DRM_AMDGPU`, `CONFIG_DRM_AMDKFD`, `CONFIG_HSA_AMD`, `CONFIG_DRM_VCN`, `CONFIG_DRM_VCE`, `CONFIG_DRM_UVD` | Full GPU acceleration, video decode/encode, ROCm/HSA compute           |
| **Storage**            | `CONFIG_AHCI`, `CONFIG_NVME`, `CONFIG_USB_STORAGE`, `CONFIG_USB_UAS`             | Secure SATA, NVMe, and USB storage with SCSI filtering                  |
| **USB Security**       | `CONFIG_USB`, `CONFIG_USB_UVC`, `CONFIG_USB_HID`                                 | Only required USB classes (storage, webcam, HID) enabled                |
| **Network Filtering**  | `CONFIG_NETFILTER`, `CONFIG_NETFILTER_XT_MATCH_CONNTRACK`, `CONFIG_NETFILTER_ADVANCED`, `CONFIG_BRIDGE_NETFILTER` | Advanced firewalling and packet inspection                             |
| **Other Hardware**     | `CONFIG_I2C`, `CONFIG_SPI`, `CONFIG_WATCHDOG`, `CONFIG_VIRTIO_*`                 | Secure support for basic hardware buses and virtualization              |

---

## ⚙️ Performance + Security Features

- **zswap + zram** with `zstd` compression: saves RAM and accelerates swap.  
- **VirtIO drivers**: optimized for QEMU/KVM or cloud deployments.  
- **Filesystem choice**: Ext4 (stable), Btrfs/F2FS (modern CoW), XFS (scalable).  
- **Fallback graphics**: VESA + KMS helper ensures safe boot on all GPUs.  

---

## 🧭 Why SecurityOps?

Unlike generic kernels, **SecurityOps** is explicitly designed for environments where **system integrity and resilience** come first.  

It combines:

- 🛡️ **KSPP mitigations** (stack canaries, hardened usercopy, strict RWX)  
- 🕵️ **Attack surface reduction** (only required drivers and subsystems)  
- 📈 **Performance tuning** (XanMod scheduler tweaks, HZ=1000)  
- 🧑‍💻 **Developer-friendly debugging** (`CONFIG_DEBUG_KERNEL` + symbols)  

---

## 🏛️ Trusted for Intelligence & Defense

This configuration is suitable for **national security** and **intelligence use cases** such as:

- **NSA / CIA** (U.S.) — kernel hardening against kernel-level rootkits  
- **ABIN** (Brazil) — defensive computing for intelligence operations  
- **Military / Government systems** — resilience against 0-days, hardware exploits, and supply chain attacks  
- **Critical infrastructure** — secure foundations for servers, SCADA, and defense networks  

By **removing unnecessary drivers**, enabling **strict execution control**, and **mitigating memory corruption exploits**, SecurityOps provides a **minimal, auditable, and hardened kernel** that resists both **local privilege escalation** and **remote exploitation** attempts.

---

🔑 **SecurityOps Kernel** is where **performance meets self-protection**.  
Designed for people who can’t afford compromise.  

---



### 📜 Kernel Arguments

| Kernel Argument | Description |
|-----------------|---------|
| quiet | Minimize boot output for a cleaner boot process |
| splash | Enable graphical splash screen during boot |
| zswap.enabled=1 | Enable zswap for compressed swap in RAM |
| zswap.compressor=zstd | Use Zstandard compression for zswap to optimize memory |
| zswap.max_pool_percent=15 | Limit zswap pool to 15% of RAM to balance memory usage |
| zswap.zpool=z3fold | Use z3fold allocator for zswap to improve memory efficiency |
| elevator=bfq | Use Budget Fair Queueing I/O scheduler for balanced disk performance |
| module.sig_enforce=1 | Enforce signed kernel modules for enhanced security |
| lockdown=confidentiality | Enable kernel lockdown to restrict root access to kernel features |
| mitigations=auto | Automatically apply CPU vulnerability mitigations (e.g., Spectre, Meltdown) |
| randomize_kstack_offset=on | Randomize kernel stack offset to prevent stack-based attacks |
| slab_nomerge | Disable slab merging to mitigate kernel exploits |
| init_on_alloc=1 | Zero-initialize allocated memory for security |
| init_on_free=1 | Zero memory pages on free to prevent data leaks |
| tcp_congestion_control=bbr | Use BBR algorithm for efficient TCP networking (optimized for torrenting) |
| net.core.default_qdisc=fq_codel | Set fair queuing with controlled delay for network traffic |
| net.core.rmem_max=16777216 | Increase receive buffer size for high-speed networking (1Gbps) |
| net.core.wmem_max=16777216 | Increase send buffer size for high-speed networking (1Gbps) |
| net.ipv4.tcp_rmem=4096 87380 16777216 | Tune TCP receive buffer sizes for optimized networking |
| net.ipv4.tcp_wmem=4096 65536 16777216 | Tune TCP send buffer sizes for optimized networking |
| net.core.netdev_max_backlog=5000 | Set packet queue length for high-speed network interfaces |
| net.ipv4.tcp_fastopen=3 | Enable TCP Fast Open for faster connections |
| net.ipv4.tcp_mtu_probing=1 | Enable MTU probing for better network performance |
| amdgpu.ppfeaturemask=0xffffffff | Unlock all AMD GPU power and performance features for Radeon RX 5600/5700 |
| amdgpu.dpm=1 | Enable dynamic power management for AMD GPU |
| amdgpu.dc=1 | Enable AMD Display Core for modern display handling |
| amd_pstate=active | Enable AMD P-state driver for CPU power efficiency on Ryzen 3 2200G |
| usbcore.authorized_default=0 | Disable auto-authorizing USB devices to prevent BadUSB attacks |
| modprobe.blacklist=firewire_core,dccp,sctp,rds,tipc,thunderbolt | Blacklist unused modules (FireWire, DCCP, SCTP, RDS, TIPC, Thunderbolt) for security |
| transparent_hugepage=always | Enable transparent huge pages for improved memory performance |
| kptr_restrict=2 | Restrict kernel pointer access to prevent information leaks |
| page_alloc.shuffle=1 | Randomize page allocation to reduce exploit predictability |
| mce=0 | Disable Machine Check Exception reporting to reduce overhead |
| apparmor=0 | Disable AppArmor (not used, Firejail preferred for sandboxing) |
| ipv6.disable=0 | Enable IPv6 for compatibility with modern networks |
| noresume | Disable resume from hibernation (not used in this setup) |
| nomodeset=0 | Allow kernel mode-setting for AMD GPU drivers |
| nowatchdog | Disable watchdog timer to reduce system overhead |
| cpufreq.default_governor=schedutil | Use schedutil governor for dynamic CPU frequency scaling |
| rcu_nocbs=0-7 | Disable RCU callbacks on all CPU cores for performance |
| nmi_watchdog=0 | Disable NMI watchdog to reduce CPU overhead |
| audit=0 | Disable kernel auditing to reduce logging overhead |
| console=tty0 | Set primary console to tty0 for boot messages |
| consoleblank=0 | Disable console blanking for continuous display output |

## Services

This table lists all services and kernel modules configured in the GNU Guix system for the securityops host, optimized for AMD Ryzen 3 2200G and Radeon RX 5600/5700 hardware. Each entry includes a detailed comment explaining its purpose, ensuring clear documentation for maintenance and reproducibility. Services support privacy (Mullvad VPN, Tor), security (NFTables, Firejail), performance (zswap, AMD tuning), and functionality (Xmonad, Docker, Japanese input). Modules enable hardware support, networking, and system efficiency.

| Service | Comment |
|---------|---------|
| nftables | Configures a strict firewall using Netfilter tables, enforcing input/output filtering to protect against unauthorized access. Rules include anti-spoofing, logging, and allowances for Mullvad VPN (port 51820) and qBittorrent (ports 6881–6890). |
| mullvad-daemon | Runs the Mullvad VPN client via WireGuard (wg0-mullvad), routing all traffic through secure tunnels for privacy. Configured with Mullvad’s DNS (100.64.0.23) and server IPs, ensuring anonymous browsing and torrenting. |
| tor | Provides anonymous networking with SOCKS proxy (port 9050) and transparent proxying (TransPort 9040). Integrates with Tor Browser and other applications for privacy, complementing Mullvad VPN. |
| bluetooth | Enables Bluetooth connectivity for peripherals (e.g., headsets, keyboards). Configured with minimal permissions to reduce attack surface, supporting multimedia and productivity use cases. |
| docker | Runs the Docker container platform for isolated application deployment. Supports development workflows and testing environments, used alongside containerd for efficient container management. |
| containerd | Provides a lightweight container runtime for Docker, ensuring efficient resource usage and compatibility with containerized applications. Critical for your virtualization and development needs. |
| zram-device | Configures a 4GB compressed swap device using zstd compression, enhancing memory efficiency for your 4-core/4-thread Ryzen 3 2200G. Reduces disk I/O and improves performance under memory pressure. |
| udev | Manages device events and permissions, enforcing strict USB authorization (usbcore.authorized_default=0) and FIDO2/U2F support for security. Includes rules for trusted USB devices and GPU passthrough. |
| xlibre-server | Runs the X11 display server with a Brazilian keyboard layout, supporting Xmonad, Rofi, Xmobar, and Polybar for a lightweight, tiling desktop. Configured for AMD GPU acceleration (VAAPI, Vulkan). |
| nix | Integrates the Nix package manager for additional reproducibility and package flexibility. Allows access to Nix packages alongside Guix, useful for development and testing. |

## Modules

| Module | Comment |
|--------|---------|
| amdgpu | Provides the AMD GPU driver for your Radeon RX 5600/5700, enabling graphics, compute, and hardware acceleration (VAAPI, Vulkan, OpenGL). Supports gaming (Steam, Proton) and multimedia (MPV, VLC). |
| kvm-amd | Enables Kernel-based Virtual Machine (KVM) support for AMD CPUs, allowing efficient virtualization with QEMU. Critical for running virtual machines for testing or development, despite libvirt being disabled. |
| zswap | Implements compressed swap in RAM, working with zstd for your 4GB zswap configuration. Reduces disk I/O and enhances performance under memory pressure, optimized for your Ryzen 3 2200G. |
| zstd | Provides Zstandard compression for zswap, ensuring efficient memory management. Configured with zswap.compressor=zstd and zswap.zpool=z3fold for optimal compression ratios and performance. |
| wireguard | Enables WireGuard kernel support for Mullvad VPN tunneling (wg0-mullvad, port 51820). Ensures low-latency, secure networking for privacy-focused browsing and torrenting. |
| nftables | Supports Netfilter tables for your strict firewall configuration, enforcing rules for input/output filtering, anti-spoofing, and logging. Integrates with the nftables service for security. |
| vfat | Provides FAT32 filesystem support for the EFI system partition, ensuring compatibility with UEFI boot. Essential for your Guix system’s bootloader (GRUB) configuration. |
| ext4 | Supports the ext4 filesystem for your root and data partitions, configured with safe journaling for data integrity. Optimized for performance and reliability on your storage devices. |
| bfq | Implements the Budget Fair Queueing I/O scheduler (elevator=bfq), balancing disk performance across processes. Enhances responsiveness for gaming, multimedia, and development tasks. |
| usbhid | Enables USB Human Interface Device support for keyboards, mice, and other peripherals. Configured with udev rules to restrict unauthorized USB devices, aligning with usbcore.authorized_default=0. |

#### Notes
- **Module Context**: Modules are loaded by the linux kernel, optimized for your AMD hardware with microcode updates (microcode-initrd) and firmware (linux-firmware).
- **Documentation**: Comments are designed to be self-contained, explaining each service and module’s role in your system’s privacy, security, performance, and functionality goals.

## Xlibre Configuration

This repository contains my custom **Xlibre** configuration for GNU Guix, optimized for AMDGPU graphics, input devices, and display settings. The configuration is fully defined in `config.scm`.

---

## Overview

The goal of this configuration is to provide:

- **Smooth graphics rendering** with TearFree and Glamor acceleration.
- **Variable refresh and page flipping** support for modern displays.
- **Efficient memory and color handling** with ColorTiling and depth optimizations.
- **Optimized input handling** using libinput.
- **Preferred resolution and refresh rate** automatically set for HDMI-A-0 monitors.
- **Support for 32-bit color depth**, allowing modern applications to use alpha channels where applicable.

---

## Configuration Details

The configuration in `config.scm`:

```scheme
(define my-xlibre-config
  (xlibre-configuration
    (modules (list xlibre-video-amdgpu xlibre-input-libinput))
    (drivers '("amdgpu"))
    (keyboard-layout (keyboard-layout "br"))
    (extra-config
      (list
       "Section \"Device\""
       "  Identifier \"AMD-GPU\""
       "  Driver \"amdgpu\""
       "  Option \"TearFree\" \"on\""
       "  Option \"AccelMethod\" \"glamor\""
       "  Option \"DRI\" \"3\""
       "  Option \"VariableRefresh\" \"true\""
       "  Option \"AsyncFlipSecondaries\" \"true\""
       "  Option \"EnablePageFlip\" \"true\""
       "  Option \"ShadowPrimary\" \"true\""
       "  Option \"ColorTiling\" \"true\""
       "  Option \"ColorTiling2D\" \"true\""
       "  Option \"EnableDepthMoves\" \"true\""
       "  Option \"SwapbuffersWait\" \"true\""
       "  Option \"AllowGLXWithComposite\" \"true\""
       "  Option \"TripleBuffer\" \"true\""
       "  Option \"DRI3SwapEvent\" \"true\""
       "  Option \"AutoAddDevices\" \"false\""
       "EndSection"

       "Section \"Monitor\""
       "  Identifier \"HDMI-A-0\""
       "  HorizSync 30.0-83.0"
       "  VertRefresh 56.0-76.0"
       "  Option \"PreferredMode\" \"1366x768\""
       "  Option \"DPMS\" \"true\""
       "EndSection"

       "Section \"Screen\""
       "  Identifier \"Screen0\""
       "  Device \"AMD-GPU\""
       "  Monitor \"HDMI-A-0\""
       "  DefaultDepth 32"
       "  SubSection \"Display\""
       "    Depth 32"
       "    Modes \"1366x768\""
       "  EndSubSection"
       "EndSection"))))
```

---

## Benefits of this Configuration

### Device Section (`AMD-GPU`)
- **TearFree**: Removes screen tearing for smoother visuals.
- **AccelMethod Glamor**: Hardware-accelerated 2D and OpenGL rendering.
- **DRI3**: Direct Rendering Infrastructure for faster GPU access.
- **VariableRefresh, AsyncFlipSecondaries, EnablePageFlip**: Enable modern display features like dynamic refresh and async flipping.
- **ShadowPrimary**: Improves compositing performance.
- **ColorTiling & ColorTiling2D**: Optimize memory layout for better GPU performance.
- **EnableDepthMoves, SwapbuffersWait**: Reduce visual glitches and improve synchronization.
- **TripleBuffer, DRI3SwapEvent**: Minimize frame drops and stutter.
- **AutoAddDevices false**: Full manual control over detected devices.

### Monitor Section (`HDMI-A-0`)
- **PreferredMode 1366x768**: Automatically sets the display resolution.
- **DPMS true**: Enable energy-saving power management for the monitor.

### Screen Section (`Screen0`)
- **DefaultDepth 32 / Depth 32**: Enables full 32-bit color with alpha channel support for modern applications.
- **Modes 1366x768**: Matches the preferred resolution for consistent rendering.

---

### How to Verify

After applying your configuration:

```bash
# Verify available depths and bits per pixel
xdpyinfo | grep -E "depth|bits_per_pixel"

# Verify Xlibre is running with your config
cat /var/log/Xorg.0.log | grep -E "(EE|WW|amdgpu|HDMI-A-0|Screen0|PreferredMode)"
```
___
## Steam Configuration
```
WINEDLLOVERRIDES=dxgi=b DXVK_ASYNC=1 DXVK_SHADER_CACHE=1 RADV_PERFTEST=aco MANGOHUD=1 MANGOHUD_CONFIG=cpu,temp,gpu,frametime,frame,proc_freq,threads %command%
```

| Parameter | Function / Description |
|-----------|----------------------|
| `WINEDLLOVERRIDES=dxgi=b` | Overrides Wine DXGI handling; uses Wine’s built-in DXGI to improve compatibility. |
| `DXVK_ASYNC=1` | Enables asynchronous command submission in DXVK for potentially smoother frame pacing. |
| `DXVK_SHADER_CACHE=1` | Enables shader caching in DXVK to reduce stutter from shader compilation. |
| `RADV_PERFTEST=aco` | Forces RADV driver to use ACO compiler for Vulkan shaders (AMD GPU optimization). |
| `RADV_DEBUG=llvm` | Forces RADV driver to use LLVM compiler (not recommended with ACO; can cause startup failure). |
| `MANGOHUD=1` | Enables MangoHud overlay to monitor GPU/CPU metrics. |
| `MANGOHUD_CONFIG=cpu,temp,gpu,frametime,frame,proc_freq,threads` | Customizes MangoHud display: CPU usage, temperature, GPU usage, frametime, FPS, processor frequency, threads. |
| `%command%` | Placeholder for Steam to launch the actual game executable. |

---

## ⚖️ OS Comparison

The table below compares GNU Guix (configured for the securityops host) with common operating systems, including Microsoft Windows, across key features. Ratings (1–5 stars) reflect how well each OS meets the needs of a privacy-focused, high-performance system with AMD hardware, Xmonad, Mullvad VPN, Tor, and development/gaming capabilities.

| OS | Package Management | Reproducibility | Free Software | Declarative Config | Privacy | Security | Performance | Learning Curve |
|----|--------------------|-----------------|---------------|--------------------|---------|----------|-------------|----------------|
| **GNU Guix** | Declarative, functional (★★★★★) | Full bit-for-bit (★★★★★) | 100% FSF-approved (★★★★★) | Yes, Scheme-based (★★★★★) | Mullvad VPN, Tor, NFTables (★★★★★) | Kernel lockdown, Firejail (★★★★★) | AMD-tuned, zswap, BBR (★★★★★) | Steep (★★★) |
| **Arch Linux** | Rolling, manual (★★★★) | Limited (★★) | Mixed (★★★) | No (★★) | Configurable (★★★) | Configurable (★★★★) | High, manual tuning (★★★★) | Steep (★★★) |
| **Debian** | Stable, apt (★★★) | Partial (★★★) | Mostly free (★★★★) | No (★★) | Configurable (★★★) | Stable, slow updates (★★★) | Moderate (★★★) | Moderate (★★★★) |
| **Fedora** | DNF, semi-rolling (★★★★) | Limited (★★) | Mostly free (★★★★) | No (★★) | Moderate (★★★) | SELinux (★★★★) | High (★★★★) | Moderate (★★★★) |
| **Ubuntu** | apt, LTS focus (★★★) | None (★) | Mixed (★★★) | No (★★) | Weak (★★) | AppArmor (★★★) | Moderate (★★★) | Low (★★★★★) |
| **Windows** | Manual, third-party (★★) | None (★) | Proprietary (★) | No (★) | Poor, telemetry (★) | Updates, antivirus (★★) | High, driver support (★★★★) | Low (★★★★★) |

| Feature            | Windows         | macOS           | Ubuntu          | Fedora          | GNU Guix        |
|---------------------|-----------------|-----------------|-----------------|-----------------|-----------------|
| **Package Management** | ★★★☆☆          | ★★★★☆          | ★★★★☆          | ★★★★☆          | ★★★★★          |
| Description         | Windows uses Microsoft Store and manual installers, prone to bloat. | macOS uses App Store and Homebrew, less integrated. | Ubuntu uses APT and Snap, robust but complex. | Fedora uses DNF and Flatpak, curated and recent. | Guix offers functional, reproducible package management. |
| **Customization**   | ★★★☆☆          | ★★★★☆          | ★★★★★          | ★★★★☆          | ★★★★★          |
| Description         | Windows is locked down, needing third-party tools. | macOS allows limited tweaks, proprietary. | Ubuntu supports GNOME tweaks, flexible. | Fedora offers modular development, focused. | Guix provides declarative, fine-grained control. |
| **Security**        | ★★★☆☆          | ★★★★☆          | ★★★★☆          | ★★★★☆          | ★★★★★          |
| Description         | Windows is a malware target, improved with Defender. | macOS is Unix-based, proprietary limits transparency. | Ubuntu uses AppArmor, risks from PPAs. | Fedora uses SELinux, bleeding-edge risks. | Guix ensures reproducibility and minimal attack surface. |
| **Privacy**         | ★★★☆☆          | ★★★☆☆          | ★★★☆☆          | ★★★★☆          | ★★★★★          |
| Description         | Windows collects extensive telemetry. | macOS ties users to Apple ecosystem. | Ubuntu has optional telemetry, Snap analytics. | Fedora avoids telemetry, open-source. | Guix has no telemetry, supports Tor/VPNs. |
| **Performance**     | ★★★☆☆          | ★★★★☆          | ★★★★☆          | ★★★★☆          | ★★★★★          |
| Description         | Windows is resource-heavy. | macOS is optimized for Apple hardware. | Ubuntu performs well, Snap can slow. | Fedora is lightweight, risks regressions. | Guix is efficient, compilation may be intensive. |
| **Community Support** | ★★★★☆          | ★★★☆☆          | ★★★★★          | ★★★★☆          | ★★★☆☆          |
| Description         | Windows has a huge user base, slow official support. | macOS relies on Apple channels. | Ubuntu has vast community support. | Fedora is developer-focused, less beginner-friendly. | Guix has a technical, growing community. |

*The following table compares GNU Guix with popular operating systems: Windows, macOS, Ubuntu, and Fedora. Each is evaluated based on package management, customization, security, privacy, performance, and community support. Ratings are given out of five yellow stars (★★★★★).*

### Rating Explanations

- **Package Management**: GNU Guix’s declarative, functional approach ensures precise control and rollbacks, earning 5 stars. Arch’s rolling updates and Fedora’s DNF are flexible but less predictable. Debian and Ubuntu’s apt is stable but less dynamic. Windows relies on manual or third-party tools (e.g., winget, Chocolatey), lacking system integration.
- **Reproducibility**: Guix’s bit-for-bit reproducible builds are unmatched, guaranteeing identical systems. Debian offers partial reproducibility, while Arch, Fedora, Ubuntu, and Windows have minimal to no reproducibility due to proprietary components or non-deterministic updates.
- **Free Software**: Guix’s 100% FSF-approved software aligns with your ethical goals, earning 5 stars. Debian and Fedora are mostly free but include some non-free firmware. Arch and Ubuntu often incorporate proprietary components. Windows is fully proprietary, scoring 1 star.
- **Declarative Config**: Guix’s Scheme-based config.scm unifies system configuration, unlike the manual configs of Arch, Debian, Fedora, Ubuntu, and Windows, which rely on disparate tools or GUI settings.
- **Privacy**: Your Guix setup with Mullvad VPN, Tor, and NFTables provides superior privacy. Arch and Debian are configurable but require manual setup. Fedora is moderate, Ubuntu’s telemetry weakens its privacy, and Windows’ extensive telemetry and data collection make it the weakest.
- **Security**: Guix’s kernel hardening (lockdown=confidentiality, usbcore.authorized_default=0), Firejail, and NFTables excel. Arch is highly configurable, Fedora uses SELinux, Debian is stable but slower to patch, Ubuntu’s AppArmor is less robust, and Windows relies on frequent updates and antivirus but is vulnerable to exploits.
- **Performance**: Guix’s linux kernel with AMD tuning (amd_pstate, amdgpu.dpm), zswap, and BBR optimizes your Ryzen 3 2200G and Radeon RX 5600/5700. Arch and Fedora offer high performance with manual tuning, Debian and Ubuntu are less optimized, and Windows provides strong performance with good AMD driver support but is bloated.
- **Learning Curve**: Ubuntu and Windows are the easiest to learn, followed by Debian and Fedora. Guix and Arch have steeper curves due to advanced customization (Scheme for Guix, manual setup for Arch).

### Best OS: GNU Guix

GNU Guix is the best OS for your securityops system, earning 5 stars in most categories due to its alignment with your priorities:
- **Reproducibility and Free Software**: Bit-for-bit builds and 100% free software ensure transparency and consistency, critical for your ethical and reproducible setup, far surpassing Windows’ proprietary nature.
- **Privacy and Security**: Mullvad VPN, Tor, strict NFTables, and kernel hardening provide unmatched protection, outperforming Windows’ telemetry-heavy approach, Ubuntu’s weak defaults, and even Arch’s manual configuration.
- **Performance**: AMD-specific optimizations, zswap, and BBR make Guix ideal for your hardware and use cases (gaming, torrenting, development), rivaling Windows’ driver support but with less overhead.
- **Declarative Config**: The unified config.scm simplifies maintenance compared to other OSes’ fragmented configs or Windows’ GUI-based settings.

While Guix’s learning curve is steep, its benefits in privacy, security, performance, and reproducibility make it the superior choice for your tailored, high-performance system, especially compared to Windows’ lack of free software, poor privacy, and non-reproducible nature.

## 🌟 Final Considerations: Why GNU Guix is Better

GNU Guix is the optimal choice for the securityops system due to its unparalleled strengths in reproducibility, free software, and declarative management, tailored to your privacy, security, and performance needs:

1. **Reproducibility**: Guix’s bit-for-bit reproducible builds ensure the system can be recreated identically, unlike Arch or Fedora, where manual setups vary. This guarantees consistency for your AMD Ryzen and Radeon setup.
2. **Free Software**: As an FSF-approved distribution, Guix uses 100% free software, avoiding proprietary blobs in Ubuntu or Fedora. This aligns with your ethical goals and ensures full system transparency.
3. **Declarative Configuration**: The Scheme-based config.scm unifies kernel, services, and packages in one file, simplifying maintenance compared to Debian’s scattered configs or Arch’s manual tweaks.
4. **Privacy and Security**: Guix enables seamless integration of Mullvad VPN, Tor, and NFTables, surpassing Ubuntu’s weak privacy defaults or Fedora’s SELinux focus. Kernel hardening (lockdown=confidentiality, usbcore.authorized_default=0) and Firejail provide robust protection for your hardware.
5. **Performance**: Guix’s custom linux kernel with AMD tuning (amd_pstate, amdgpu.dpm), 4GB zswap, and BBR networking optimizes your Ryzen 3 2200G and Radeon RX 5600/5700. Unlike Arch’s manual tuning, Guix automates these optimizations declaratively.
6. **Customizability**: Custom channels (small-guix, ajattix) provide niche packages (Mullvad, Japanese dictionaries), offering Arch-like flexibility with better reproducibility. This supports your diverse needs (gaming, development, multimedia).
7. **Community-Driven**: Guix’s community prioritizes user empowerment and free software, unlike Ubuntu’s corporate influence or Fedora’s Red Hat backing, ensuring alignment with your long-term goals.

Despite a steeper learning curve, Guix’s benefits make it unmatched for a privacy-focused, high-performance system like securityops, offering control, security, and ethics that other OSes can’t match.

## 🎞️ Aesthetic & Mood

<p align="center">  
  <img src="https://i.ibb.co/hgpctz7/1.gif" width="500" height="250">  
  <img src="https://i.ibb.co/VWc1YM5/4.gif" width="500" height="250">  
  <img src="https://i.ibb.co/SnwXjKt/3.gif" width="500" height="250">  
  <img src="https://i.ibb.co/Yddwt4d/2024-06-26-21-57.png" width="500" height="250">
</p>

## 🎥 Guix on YouTube

- 📺 [YouTube: @securityops](https://youtube.com/@securityops)

<p align="center">  
  <a href="https://youtube.com/@securityops"><img src="https://i.ibb.co/XJm5g7F/mpv-shot0001.jpg" width='500' height='250'></a>  
  <a href="https://codeberg.org/berkeley/guix-config"><img src="https://i.ibb.co/QMP7tH4/GUIX-AVERAGE-USER.png" width='500' height='250'></a>
</p>

## 📜 License

This configuration is licensed under the **GNU General Public License v3.0**. Forked components (e.g., MPV shaders, Cmus themes) retain their respective licenses.

*Last Updated: November 01, 2025*
