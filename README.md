##### WARNING! I move to CODEBERG visit my profile [HERE](https://codeberg.org/berkeley/guix-config).
  <a href="" width='600' height='300'></a>
  <a href="https://codeberg.org/berkeley/guix-config"><img src="https://i.redd.it/lzoxnfhmglzc1.png" width="380">

<p align="center">
  <img src="https://i.ibb.co/9thQktG/re.png" width="640" height="160" alt="Guix Config Banner">
</p>

# 💡 Welcome to the **Guix Config** 

> Some files included here are forked from other projects, such as MPV shaders, Simple History, and Cmus themes.

This configuration defines a **secure**, **high-performance**, and **minimalist** GNU Guix system tailored for the host **"lisp"**, optimized for:

- 🧠 **AMD Ryzen 3 2200G** CPU (4 cores, 8 threads)
- 🎮 **AMD Radeon RX 5600 XT** (or 5600 OEM / 5700 / 5700 XT) GPU

With [**XMonad**](https://xmonad.org) as the tiling window manager, a **custom XanMod kernel**, and a curated set of packages and services, this setup balances **performance**, **security**, and **aesthetics** for gaming (Steam), privacy (Mullvad VPN, Tor), development workflows, and Japanese input support.


**Maintainer**: Cristian Cezar Moisés  
**Last Updated**: June 18, 2025


## ⚙️ Optimized For

- ✅ **GPU Performance**: Tuned AMDGPU drivers with Mesa for gaming and rendering.
- ✅ **CPU Efficiency**: XanMod kernel with AMD P-state, full preemption, and all 8 threads enabled for maximum responsiveness.
- ✅ **Security**: Strict NFTables firewall, Tor, and kernel hardening.
- ✅ **Privacy**: Mullvad VPN and privacy-focused browsers (Tor Browser, Icecat, Zen Browser).
- ✅ **Data Integrity**: Safe ext4 journaling and zRAM swap.
- ✅ **Aesthetics**: Custom GRUB theme and XMonad with Polybar/Xmobar.

## ✨ Key Features

- 🚀 **Fast & Minimal**: Zero bloat, rapid boot with XanMod kernel and 4GB zRAM.
- 🎨 **Aesthetic Design**: GRUB theme (`/home/berkeley/wallpapers/back1.png`), XMonad with Polybar/Xmobar, and Wayland-compatible tools.
- 🔒 **Secure Networking**: NFTables firewall allowing Mullvad VPN (UDP 51820), Tor, and essential traffic only.
- 🎮 **Gaming Ready**: Steam with Proton, Vulkan, and Mangohud for performance overlays.
- 🔧 **Customizable**: Extensive packages for development (Emacs, GCC, Rust, Python), virtualization (QEMU, Docker), and Japanese input (Fcitx5 with Anthy).
- 🛡️ **Privacy First**: Mullvad VPN, Tor, Firejail sandboxing, and privacy-enhancing tools like Privoxy.

## 🧠 Kernel Configuration

The system uses the **XanMod kernel** with optimized `kernel-arguments` for **performance**, **security**, and **stability**. All 8 threads of the Ryzen 3 2200G are enabled for maximum multithreaded performance. Below is a detailed table explaining each kernel argument in simple terms.

### 📜 Kernel Arguments Table

| **Argument** | **Description** |
|--------------|-----------------|
| `quiet` | Reduces boot messages on the screen for a cleaner startup. |
| `noatime` | Stops the system from recording when files are accessed, speeding up disk operations. |
| `splash` | Shows a graphical boot screen instead of text, improving the startup look. |
| `zswap.enabled=1` | Turns on zswap, which compresses data in memory to avoid using slower disk swap. |
| `zswap.compressor=zstd` | Uses zstd compression for zswap, balancing speed and efficiency. |
| `zswap.max_pool_percent=15` | Limits zswap to use only 15% of RAM, preventing memory overuse. |
| `zswap.zpool=z3fold` | Uses z3fold for zswap, allowing more efficient memory compression. |
| `zswap.accept_threshold_percent=90` | Starts compressing memory when RAM is 90% full, optimizing performance. |
| `zswap.same_filled_pages_enabled=1` | Removes duplicate memory pages in zswap, saving space. |
| `elevator=bfq` | Uses the BFQ disk scheduler to prioritize desktop tasks, making the system feel snappy. |
| `rootflags=data=ordered` | Ensures ext4 filesystem writes data safely to prevent corruption. |
| `fsck.mode=auto` | Automatically checks filesystems for errors during boot. |
| `fsck.repair=preen` | Fixes minor filesystem issues automatically without user input. |
| `vm.dirty_writeback_centisecs=1000` | Saves changed data to disk every 10 seconds, balancing speed and safety. |
| `module.sig_enforce=1` | Only allows verified kernel modules, blocking unauthorized code. |
| `kptr_restrict=2` | Hides kernel memory addresses to prevent hacker exploits. |
| `lockdown=confidentiality` | Locks down the kernel to block unauthorized access to sensitive data. |
| `slab_nomerge` | Keeps memory allocation separate to reduce the risk of memory-based attacks. |
| `page_alloc.shuffle=1` | Randomizes memory allocation to make hacking harder. |
| `random.trust_cpu=off` | Ensures random numbers are truly random, improving encryption security. |
| `preempt=full` | Allows the kernel to interrupt tasks quickly, making the system more responsive. |
| `rcu_nocbs=0-3` | Offloads CPU tasks from cores 0-3, freeing them for user applications. |
| `sched_yield_type=2` | Optimizes task switching for better gaming performance. |
| `transparent_hugepage=always` | Uses larger memory pages to improve performance for heavy apps like games. |
| `mitigations=auto` | Automatically applies CPU security patches to protect against vulnerabilities. |
| `mce=1` | Enables error detection for CPU hardware issues, improving reliability. |
| `spec_store_bypass_disable=prctl` | Protects against Spectre v4 attacks by allowing apps to opt-in to mitigation. |
| `tcp_congestion_control=bbr` | Uses BBR for faster, smoother internet connections. |
| `net.core.default_qdisc=fq_codel` | Reduces network lag by managing data packets efficiently. |
| `net.ipv4.tcp_fq_codel_quantum=1000` | Increases network throughput for high-speed connections. |
| `net.ipv4.tcp_fq_codel_target=5000` | Keeps network latency low for responsive browsing and gaming. |
| `net.ipv4.tcp_ecn=1` | Improves network performance by notifying congestion early. |
| `net.ipv4.tcp_fastopen=3` | Speeds up web page loading by reusing connections. |
| `net.core.netdev_max_backlog=10000` | Handles high network traffic for fast internet speeds. |
| `net.core.rmem_max=16777216` | Sets a large buffer (16MB) for receiving network data. |
| `net.core.wmem_max=16777216` | Sets a large buffer (16MB) for sending network data. |
| `net.ipv4.tcp_rmem=4096 87380 16777216` | Adjusts receive buffer sizes for efficient network performance. |
| `net.ipv4.tcp_wmem=4096 65536 16777216` | Adjusts send buffer sizes for efficient network performance. |
| `net.ipv4.tcp_mtu_probing=1` | Automatically adjusts packet sizes to avoid network issues. |
| `net.core.optmem_max=131072` | Increases buffer for network socket options, improving performance. |
| `net.ipv4.tcp_window_scaling=1` | Allows larger network data transfers for faster connections. |
| `net.ipv4.tcp_sack=1` | Recovers lost network packets faster, improving reliability. |
| `net.ipv4.tcp_early_retrans=3` | Quickly retransmits lost packets to reduce delays. |
| `net.ipv4.tcp_thin_linear_timeouts=1` | Reduces delays for low-bandwidth connections. |
| `ipv6.disable=0` | Enables IPv6 for modern network compatibility. |
| `amdgpu.ppfeaturemask=0xffffffff` | Unlocks all AMD GPU features for maximum performance. |
| `amdgpu.dc=1` | Enables AMD’s display core for better graphics output. |
| `amdgpu.dpm=1` | Allows dynamic power management for the GPU, balancing performance and efficiency. |
| `amdgpu.aspm=1` | Enables power-saving features for the GPU when idle. |
| `amdgpu.gpu_recovery=1` | Automatically recovers the GPU if it crashes during heavy tasks. |
| `amdgpu.mcbp=1` | Optimizes GPU power management for efficiency. |
| `amdgpu.dcfeaturemask=0xffffffff` | Enables all display core features for the AMD GPU. |
| `amdgpu.sched_policy=2` | Prioritizes GPU tasks for smoother gaming performance. |
| `amdgpu.abmlevel=0` | Disables adaptive backlight to maintain consistent display quality. |
| `amdgpu.backlight=0` | Disables GPU backlight control for stability. |
| `amdgpu.runpm=0` | Keeps the GPU always on for consistent performance, at the cost of higher power use. |
| `h264_amf=1` | Enables AMD hardware video encoding for faster video processing. |
| `irqaffinity=1-3` | Spreads hardware interrupts across CPUs 1-3, leaving CPU 0 for critical tasks. |
| `cpufreq.default_governor=schedutil` | Dynamically adjusts CPU speed based on workload for efficiency. |
| `amd_pstate=active` | Uses AMD’s P-state driver for precise CPU power management. |
| `amd_iommu=on` | Enables AMD’s IOMMU for secure virtual machine passthrough. |
| `iommu=pt` | Uses passthrough mode for IOMMU, improving virtualization performance. |
| `noirqdebug` | Disables IRQ debugging to reduce boot delays. |
| `watchdog` | Enables a hardware watchdog to reboot if the system freezes. |
| `noreplace-smp` | Prevents replacing SMP code, ensuring CPU stability. |
| `sysrq_always_enabled=1` | Allows emergency system controls (e.g., reboot) via SysRq key. |

> 💡 *This setup ensures low-latency gaming, secure networking, and data integrity, ideal for AMD hardware with full CPU utilization.*

## 🛠️ Application Stack

| 🧱 Category          | 🔧 Tool / App       | 📝 Description |
|---------------------|---------------------|----------------|
| **Window Manager**  | XMonad, i3-wm       | Tiling WMs with Polybar/Xmobar for status |
| **Terminal**        | Kitty, Alacritty    | GPU-accelerated terminals |
| **File Manager**    | LF, Ranger, XFE     | CLI and GUI file managers |
| **Media**           | MPV, VLC, CMus      | Versatile media and music players |
| **Gaming**          | Steam, ProtonUp-NG  | Gaming platform with compatibility tools |
| **Privacy**         | Mullvad VPN, Tor    | Secure VPN and anonymous browsing |
| **Browsers**        | Icecat, Tor Browser, Qutebrowser, Zen Browser | Privacy-focused web browsing |
| **Development**     | Emacs, Vim, GCC, Rust, Python | Tools for coding and scripting |
| **Virtualization**  | QEMU, Docker        | VMs and containerized apps |
| **Compositor**      | Picom               | X11 compositor for effects |
| **Firewall**        | NFTables            | Strict input filtering |
| **Input Methods**   | Fcitx5, Fcitx5-Anthy | Japanese and CJK input support |

## 🖥️ System Specs

| Component | Details |
|----------|---------|
| **CPU**  | AMD Ryzen 3 2200G (4 cores, 8 threads, 3.5 GHz base) |
| **GPU**  | AMD Radeon RX 5600 XT (6GB GDDR6, Navi 10) |
| **Driver** | Mesa (open-source AMD) |
| **RAM**  | 16-32GB (assumed based on zRAM and workload) |
| **OS**   | GNU Guix System |
| **Kernel** | XanMod |

## 🗂️ Partition Layout

| Mount Point | Device UUID | Type | Size | Description |
|-------------|-------------|------|------|-------------|
| `/boot/efi` | 02E2-0AB2   | vfat | 512MB | EFI System Partition |
| `/`         | 38467002-a282-4387-8319-cff6d93cd23b | ext4 | ~223GB | Root with Guix store |
| `/files`    | 7b2cbf88-bc71-49ad-b2fa-a4bbdb71f886 | ext4 | 931.5GB | User data storage |
| `/mnt/games`| 9d009d01-d635-4d56-987a-ffc2699da9fb | ext4 | 223.6GB | Game library |

## 🛡️ Security Features

- **NFTables Firewall**: Drops all inbound traffic except loopback, established connections, Mullvad VPN (UDP 51820), and limited ICMP/ICMPv6.
- **Mullvad VPN**: Runs as a daemon for encrypted, private networking.
- **Tor**: Configured with SOCKS and control ports for anonymous browsing.
- **Firejail**: Application sandboxing for enhanced security.
- **Kernel Hardening**: Mitigations, restricted kernel pointers, and randomized memory allocation.

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
<img src="https://github.com/cristiancmoises/brutefox/assets/86272521/15afb340-af3f-4c3b-b029-d80ab0da59a0" width="350" height="220" alt="BrutefoX"/></a>

## 📸 Screenshots

<p align="center">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/wezterm.png" width="600">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/screen.png" width="600">
  <img src="https://codeberg.org/berkeley/guix-config/raw/branch/main/screenshots/rdr2.png" width="600">
</p>

## 🎞️ Aesthetic & Mood

<p align="center">
  <img src="https://i.ibb.co/hgpctz7/1.gif" width="600" height="300">
  <img src="https://i.ibb.co/VWc1YM5/4.gif" width="600" height="300">
  <img src="https://i.ibb.co/SnwXjKt/3.gif" width="600" height="300">
  <img src="https://i.ibb.co/Yddwt4d/2024-06-26-21-57.png" width="600" height="300">
</p>

## 🎥 Guix on YouTube & Codeberg

- 📺 [YouTube: @securityops](https://youtube.com/@securityops)
- 📂 [Codeberg Repo](https://codeberg.org/berkeley/guix-config)

<p align="center">
  <a href="https://youtube.com/@securityops"><img src="https://i.ibb.co/XJm5g7F/mpv-shot0001.jpg" width='600' height='300'></a>
  <a href="https://codeberg.org/berkeley/guix-config"><img src="https://i.ibb.co/QMP7tH4/GUIX-AVERAGE-USER.png" width='600' height='300'></a>
</p>

## 📊 Operating System Comparison

The table below compares this GNU Guix configuration to other popular operating systems across key criteria, using a 5-star rating system (<span style="color: yellow;">★</span> = filled star, <span style="color: yellow;">☆</span> = empty star). The total score for each OS is calculated by summing filled stars (max 45). Ratings reflect your Guix setup’s specific optimizations on AMD hardware compared to general OS capabilities.

| **Category** | **Guix** | **Ubuntu** | **Fedora** | **Arch Linux** | **Debian** | **openSUSE** | **Gentoo** | **macOS** | **Windows 11** |
|--------------|----------|------------|------------|----------------|------------|--------------|------------|-----------|----------------|
| **Security** | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★☆☆</span> |
| **Privacy** | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★☆☆☆</span> | <span style="color: yellow;">★☆☆☆☆</span> |
| **Performance** | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★☆☆</span> |
| **Customizability** | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★☆☆☆☆</span> | <span style="color: yellow;">★☆☆☆☆</span> |
| **Reproducibility** | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★☆☆☆☆</span> | <span style="color: yellow;">★★☆☆☆</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★☆☆☆</span> | <span style="color: yellow;">★★☆☆☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★☆☆☆☆</span> | <span style="color: yellow;">★☆☆☆☆</span> |
| **Ease of Installation** | <span style="color: yellow;">★★☆☆☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★☆☆☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★☆☆☆☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★★</span> |
| **Software Availability** | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★★</span> |
| **Community Support** | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★☆☆</span> |
| **Stability** | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★★☆</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★☆☆</span> | <span style="color: yellow;">★★★★★</span> | <span style="color: yellow;">★★★★☆</span> |
| **Total Score** | **37/45** | **29/45** | **31/45** | **32/45** | **32/45** | **32/45** | **33/45** | **30/45** | **25/45** |

### Why GNU Guix (This Config) Stands Out
- **OS-Level Excellence**: GNU Guix offers unmatched reproducibility through its declarative configuration, ensuring consistent setups across machines. Its focus on free software and functional package management enhances security and privacy, minimizing proprietary vulnerabilities.
- **Config-Specific Strengths**: This setup leverages a XanMod kernel optimized for AMD Ryzen 3 2200G (8 threads fully utilized) and Radeon RX 5600 XT, delivering superior performance for gaming and multitasking. The NFTables firewall and Mullvad VPN provide robust security and privacy, while XMonad and custom GRUB themes create a sleek, minimalist experience. Compared to other OSes, it excels in control and efficiency, though it trades ease of installation and software variety for these benefits.

## ☑️ Final Thoughts

This Guix configuration is for users who:

- Run **AMD hardware** and demand high GPU/CPU performance.
- Value **privacy** and **security** with VPNs, Tor, and firewalls.
- Enjoy **gaming** with Steam and optimized drivers.
- Prefer a **minimalist**, **reproducible** Linux environment.
- Appreciate **aesthetic** and **functional** design with XMonad.

Fork, tweak, or connect if you’re crafting a similar setup!
