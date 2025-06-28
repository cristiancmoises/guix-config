;; -*- mode: scheme; -*-
;; Guix System Configuration for Host "securityops"
;;
;; This configuration defines a secure, privacy-focused Guix system tailored for a machine
;; with AMD Ryzen 2200G and Radeon RX 5600/5700 series GPU. It uses a custom linux-xanmod
;; kernel optimized for performance and security, with a strict NFTables firewall to route
;; all traffic through Mullvad VPN (WireGuard, wg0-mullvad) by default. Tor is configured
;; for occasional use via torando scripts, providing transparent proxying (SOCKS 9050,
;; TransPort 9040). The system supports web browsing (Zen Browser, Icecat, Tor Browser),
;; Guix upgrades, torrenting (qBittorrent), Steam gaming, and SSH, with Xmonad as the
;; window manager, Rofi for launching applications, and Fish Shell with Starship for an
;; enhanced terminal experience.
;;
;; Key Features:
;;   - Privacy: Mullvad VPN, Tor, DNS lockdown to Mullvad's servers, kernel lockdown.
;;   - Security: Strict firewall, module signature enforcement, anti-spoofing.
;;   - Performance: AMD-specific GPU/CPU tuning, BBR networking, zswap compression.
;;   - Functionality: Supports browsing, gaming, torrenting, development, and Japanese input.
;;   - Maintainability: Declarative Guix setup, granular firewall rules, automated user environment.
;;
;; Usage:
;;   - Validate configuration: `guix system build /etc/config.scm`
;;   - Reconfigure system: `sudo guix system reconfigure /etc/config.scm`
;;   - Configure home environment: `guix home reconfigure ~/.config/guix/home.scm`
;;   - Apply Fontconfig: `fc-cache -fv`
;;   - Test Mullvad: `mullvad connect`, `curl https://am.i.mullvad.net/connected`
;;   - Test Tor: `sudo herd start tor`, `torsocks curl http://example.com`
;;   - Test Rofi: Press Mod+d in Xmonad
;;   - Monitor logs: `sudo journalctl -f | grep DROPPED`, `sudo tail -f /var/log/tor/tor.log`
;;
;; Notes for Public Sharing (Codeberg):
;;   - Replace `MULLVAD_SERVER_IP_X` with actual IPs from https://mullvad.net/en/servers
;;   - Set `MULLVAD_DNS_IP` to 100.64.0.23 for Mullvad's DNS.
;;   - Do not share Tor logs or DataDirectory contents.
;;
;; Maintainer: Cristian Cezar Moisés
;; Last Updated: June 19, 2025

;;; Module Imports
;; Import required Guix modules for package and service definitions
(use-modules
 (gnu)                         ; Core Guix module for system and package management
 (guix gexp)
 (guix utils)
 (gnu packages gl)             ; OpenGL-related packages
 (gnu bootloader)              ; Bootloader utilities
 (gnu bootloader grub)         ; GRUB bootloader support
 (gnu packages hardware)       ; Hardware-related packages
 (gnu packages haskell)        ; Haskell programming language packages
 (gnu packages haskell-apps)   ; Haskell application packages
 (nongnu packages anydesk)     ; AnyDesk for remote desktop
 (gnu packages telegram)       ; Telegram-related packages
 (gnu packages llvm)           ; LLVM compiler infrastructure packages
 (gnu packages vulkan)         ; Vulkan graphics API packages
 (gnu packages gnome)          ; GNOME desktop environment packages
 (gnu packages firmware)       ; Firmware packages
 (gnu packages i2p)           ; I2P anonymous network packages
 (gnu packages photo)          ; Photography-related packages
 (gnu packages kde-utils)      ; KDE utility packages
 (gnu packages algebra)        ; Algebra-related packages
 (gnu packages kde-multimedia) ; KDE multimedia packages
 (gnu packages graphviz)       ; Graph visualization packages
 (ajatt packages dictionaries) ; Custom dictionary packages
 (nongnu packages game-client) ; Non-GNU game client packages
 (ajatt packages suckless)     ; Custom suckless software packages
 (ajatt packages readers)      ; Custom reader software packages
 (ajatt packages audio)        ; Custom audio software packages
 (gnu packages zig-xyz)        ; Zig programming language packages
 (gnu packages databases)      ; Database-related packages
 (gnu packages antivirus)      ; Antivirus software packages
 (rosenthal packages binaries) ; Custom binary packages
 (rosenthal packages emacs-xyz); Custom Emacs packages
 (gnu packages tor-browsers)   ; Tor browser packages
 (small-guix packages mullvad) ; Mullvad VPN packages
 (radix services admin)        ; Custom admin service definitions
 (radix packages xdisorg)      ; Custom X11 display organization packages
 (radix packages image-viewers); Custom image viewer packages
 (saayix packages binaries)    ; Custom binary packages
 (guix store)                  ; Guix store management
 (guix packages)               ; Guix package management
 (guix transformations)        ; Guix package transformations
 (guix git-download)           ; Git-based package downloads
 (guix git)                    ; Git utilities for Guix
 (guix channels)               ; Guix channel management
 (guix inferior)               ; Inferior processes for Guix
 (gnu packages audio)          ; Audio-related packages
 (gnu packages sqlite)         ; SQLite database packages
 (gnu packages gdb)            ; GNU Debugger (GDB) packages
 (gnu packages graphics)       ; Graphics-related packages
 (gnu packages java)           ; Java-related packages
 (gnu packages fcitx5)         ; Fcitx5 input method framework packages
 (gnu packages ibus)           ; IBus input method framework packages
 (gnu packages gnuzilla)       ; GNUzilla (Firefox) packages
 (gnu services linux)          ; More services
 (gnu services mcron)          ; Mcron service for cron jobs
 (gnu packages ebook)          ; Ebook-related packages
 (gnu packages lisp-xyz)       ; Lisp-related packages
 (gnu packages rust-apps)      ; Rust application packages
 (rde features bluetooth)      ; Bluetooth feature definitions
 (gnu packages jami)           ; Jami secure communication packages
 (gnu packages suckless)       ; Suckless software packages
 (gnu packages finance)        ; Finance-related packages
 (gnu packages pdf)            ; PDF-related packages
 (gnu packages cran)           ; CRAN (R) packages
 (gnu packages kde)            ; KDE desktop environment packages
 (gnu packages samba)          ; Samba file sharing packages
 (gnu packages docker)         ; Docker containerization packages
 (gnu services docker)         ; Docker service definitions
 (gnu services certbot)        ; Certbot service for SSL/TLS certificates
 (gnu packages unicode)        ; Unicode-related packages
 (gnu packages python-build)   ; Python build tools
 (gnu packages glib)           ; GLib library packages
 (gnu packages mail)           ; Mail-related packages
 (gnu packages gcc)            ; GCC compiler packages
 (gnu packages rust)           ; Rust programming language packages
 (gnu packages commencement)   ; Commencement (initrd) packages
 (gnu packages golang)         ; Go programming language packages
 (gnu packages haskell-xyz)    ; Haskell-related packages
 (gnu packages kde-pim)        ; KDE personal information management packages
 (gnu packages guile-xyz)      ; Guile-related packages
 (gnu packages python-xyz)     ; Python-related packages
 (gnu packages pulseaudio)     ; PulseAudio sound server packages
 (gnu packages cmake)          ; CMake build system packages
 (gnu packages mpd)            ; Music Player Daemon (MPD) packages
 (gnu packages disk)           ; Disk management packages
 (gnu packages android)        ; Android-related packages
 (gnu packages freedesktop)    ; Freedesktop.org standards packages
 (gnu packages image)          ; Image-related packages
 (gnu packages terminals)      ; Terminal emulator packages
 (gnu packages music)          ; Music-related packages
 (gnu packages compton)        ; Compton compositor packages
 (gnu packages version-control); Version control system packages
 (gnu packages lxqt)           ; LXQt desktop environment packages
 (gnu packages file-systems)   ; File system management packages
 (gnu services base)           ; Base service definitions
 (gnu packages base)           ; Base system packages
 (gnu packages xfce)           ; XFCE desktop environment packages
 (srfi srfi-1)                 ; SRFI-1 list library
 (gnu packages tor)            ; Tor anonymity network packages
 (gnu packages image-viewers)  ; Image viewer packages
 (gnu packages messaging)      ; Messaging-related packages
 (gnu packages vim)            ; Vim editor packages
 (gnu packages gstreamer)      ; GStreamer multimedia framework packages
 (gnu packages virtualization) ; Virtualization-related packages
 (gnu packages web-browsers)   ; Web browser packages
 (gnu services)                ; General service definitions
 (gnu services vpn)            ; VPN service definitions
 (gnu services networking)     ; Network management
 (gnu services herd)           ; Herd service management
 (gnu services dbus)           ; D-Bus service definitions
 (gnu services shepherd)       ; Shepherd init system services
 (gnu system shadow)           ; Shadow password management
 (gnu services configuration)  ; Service configuration utilities
 (gnu packages build-tools)    ; Build tool packages
 (gnu packages admin)          ; Admin-related packages
 (gnu packages qt)             ; Qt framework packages
 (gnu packages lxde)           ; LXDE desktop environment packages
 (gnu packages python)         ; Python programming language packages
 (gnu packages bittorrent)     ; BitTorrent-related packages
 (gnu packages chromium)       ; Chromium browser packages
 (gnu packages compression)    ; Compression-related packages
 (gnu packages ncurses)        ; Ncurses library packages
 (gnu packages web)            ; Web-related packages
 (gnu packages fonts)          ; Font-related packages
 (gnu packages vpn)            ; VPN-related packages
 (gnu packages curl)           ; cURL library packages
 (gnu packages password-utils) ; Password utility packages
 (gnu packages emacs)          ; Emacs editor packages
 (gnu packages node)           ; Node.js packages
 (gnu packages emacs-xyz)      ; Emacs-related packages
 (gnu packages engineering)    ; Engineering-related packages
 (gnu packages fontutils)      ; Font utility packages
 (gnu packages gimp)           ; GIMP image editor packages
 (gnu packages gnome)          ; GNOME desktop environment packages
 (gnu packages gnome-xyz)      ; GNOME-related packages
 (gnu packages gnupg)          ; GnuPG encryption packages
 (gnu packages imagemagick)    ; ImageMagick image processing packages
 (gnu packages linux)          ; Linux kernel and related packages
 (gnu packages package-management) ; Package management tools
 (gnu packages apparmor) 
(gnu packages rsync)          ; Rsync file synchronization packages
 (gnu packages ssh)            ; SSH-related packages
 (gnu packages video)          ; Video-related packages
 (gnu packages wm)             ; Window manager packages
 (nongnu packages benchmark)   ; Non-GNU benchmark packages
 (gnu packages benchmark)      ; GNU benchmark packages
 (gnu packages xdisorg)        ; X11 display organization packages
 (gnu packages xorg)           ; Xorg server and related packages
 (gnu home services gnupg)     ; GnuPG home services
 (gnu home services xdg)       ; XDG home services
 (gnu home-services wm)        ; Window manager home services
 (small-guix services mullvad) ; Mullvad VPN services
 (gnu packages lisp)           ; Lisp programming language packages
 (gnu packages networking)     ; Networking-related packages
 (gnu packages security-token) ; Security token packages
 (gnu packages tls)            ; TLS-related packages
 (gnu packages figlet)         ; Figlet for custom terminal font
 (nongnu packages compression) ; Non-GNU compression packages
 (nongnu packages clojure)     ; Clojure programming language packages
 (nongnu packages linux)       ; Non-GNU Linux-related packages
 (nongnu packages chrome)      ; Non-GNU Chrome browser packages
 (nongnu system linux-initrd)  ; Non-GNU Linux initrd system
 )

;; Import service modules for system services
(use-service-modules
 base web security networking sysctl certbot shepherd nix cups desktop ssh docker xorg linux virtualization)

;; Import package modules for package management tools
(use-package-modules
 bootloaders package-management version-control gcc bash certs admin linux xorg)
 
;;; === Custom Kernel Definition ===
;; Define a hardened linux-xanmod kernel with enhanced security options to address
;; kernel-hardening-checker results (107 OK, 113 FAIL). The configuration enables
;; self-protection, attack surface reduction, and userspace hardening while ensuring
;; compatibility with Xorg and AMD hardware.
(define securityops-kernel linux-xanmod)

(operating-system
  ;; Kernel Settings
  (kernel securityops-kernel) ; Custom Linux-XanMod hardened kernel
  (kernel-arguments
   '(
     ;; ─── Boot and General ─────────────────────────────────────────────
     "quiet"                           ; Minimize boot output
     "splash"                          ; Graphical splash screen
     "noatime"                         ; Disable file access time updates

     ;; ─── Memory Compression ───────────────────────────────────────────
     "zswap.enabled=1"                ; Enable zswap
     "zswap.compressor=zstd"          ; Use Zstandard for compression
     "zswap.max_pool_percent=15"      ; Limit zswap to 15% of RAM
     "zswap.zpool=z3fold"             ; Use z3fold memory pool
     "zswap.accept_threshold_percent=90" ; Compress only when memory is 90% full
     "zswap.same_filled_pages_enabled=1" ; Deduplicate same-filled pages

     ;; ─── I/O and Filesystem ──────────────────────────────────────────
     "elevator=bfq"                   ; Use BFQ I/O scheduler for desktop interactivity
     "rootflags=data=ordered"         ; Journaling mode: write data before metadata
     "fsck.mode=auto"                 ; Enable fsck automatically at boot if needed
     "fsck.repair=preen"              ; Automatically fix safe filesystem errors
     "vm.dirty_writeback_centisecs=1000" ; Flush dirty pages every 10s

     ;; ─── CPU and Memory Security ─────────────────────────────────────
     "module.sig_enforce=1"           ; Only allow signed kernel modules
     "kptr_restrict=2"                ; Hide kernel pointers from non-root
     "lockdown=confidentiality"       ; Lockdown mode (no firmware access, etc.)
     "slab_nomerge"                   ; Prevent slab merging (hardening)
     "page_alloc.shuffle=1"           ; Randomize page allocator
     "random.trust_cpu=off"           ; Do not trust CPU RNG
     "preempt=full"                   ; Full preemption (low latency)
     "sched_yield_type=2"             ; Use aggressive yield policy
     "transparent_hugepage=always"    ; Enable THP to improve memory performance
     "vsyscall=none"                  ; Disable vsyscall for security
     "randomize_kstack_offset=on"     ; Randomize kernel stack offset

     ;; ─── Security Mitigations ────────────────────────────────────────
     "mitigations=auto"               ; Apply CPU mitigations automatically
     "spec_store_bypass_disable=prctl" ; Mitigate Spectre v4 (Speculative Store Bypass)
     "mce=1"                          ; Enable Machine Check Exception handling

     ;; ─── USB Security ───────────────────────────────────────────────
     "usbcore.authorized_default=0"  ; Block new USB devices by default (BadUSB mitigation)

     ;; ─── Networking Optimizations ───────────────────────────────────
     "tcp_congestion_control=bbr"     ; Use BBR TCP congestion control (low latency)
     "net.core.default_qdisc=fq_codel" ; FQ-CoDel queueing to reduce bufferbloat
     "net.ipv4.tcp_fq_codel_quantum=1000" ; FQ-CoDel quantum (packet batch size)
     "net.ipv4.tcp_fq_codel_target=5000"  ; FQ-CoDel target latency (in μs)
     "net.ipv4.tcp_ecn=1"             ; Enable Explicit Congestion Notification
     "net.ipv4.tcp_fastopen=3"        ; Enable TCP Fast Open for both client/server
     "net.core.netdev_max_backlog=10000" ; Increase network interface queue
     "net.core.rmem_max=16777216"     ; Max socket receive buffer (16 MB)
     "net.core.wmem_max=16777216"     ; Max socket send buffer (16 MB)
     "net.ipv4.tcp_rmem=4096 87380 16777216" ; Min/default/max TCP receive buffers
     "net.ipv4.tcp_wmem=4096 65536 16777216" ; Min/default/max TCP send buffers
     "net.ipv4.tcp_mtu_probing=1"     ; Enable MTU probing for broken PMTUD paths
     "net.core.optmem_max=131072"     ; Max ancillary buffer memory
     "net.ipv4.tcp_window_scaling=1"  ; Enable dynamic TCP window scaling
     "net.ipv4.tcp_sack=1"            ; Enable Selective Acknowledgments (SACK)
     "net.ipv4.tcp_early_retrans=3"   ; Allow early retransmission (better loss recovery)
     "net.ipv4.tcp_thin_linear_timeouts=1" ; Optimize timeouts for small TCP flows
     "ipv6.disable=0"                 ; Keep IPv6 enabled

     ;; ─── AMD GPU Tuning ─────────────────────────────────────────────
     "amdgpu.ppfeaturemask=0xffffffff" ; Unlock all PowerPlay features
     "amdgpu.dc=1"                    ; Enable Display Core
     "amdgpu.dpm=1"                   ; Dynamic Power Management
     "amdgpu.aspm=1"                  ; Enable PCIe ASPM (power saving)
     "amdgpu.gpu_recovery=1"          ; Automatic recovery from GPU hangs
     "amdgpu.mcbp=1"                  ; Mid-chain bus power savings
     "amdgpu.dcfeaturemask=0xffffffff" ; Enable all Display Core features
     "amdgpu.sched_policy=2"          ; High-priority GPU scheduling
     "amdgpu.abmlevel=0"              ; Disable Adaptive Brightness
     "amdgpu.backlight=0"             ; Disable kernel control of backlight
     "amdgpu.runpm=1"                 ; Enable runtime power management
     "amdgpu.audio=1"                 ; Enable HDMI/DP audio
     "amdgpu.vm_size=6144"            ; Set GPU virtual memory space to 6 GB
     "amdgpu.gtt_size=2048"           ; Set GTT size to 2 GB
     "amdgpu.sg_display=1"            ; Enable SG display mode
     "amdgpu.hard_reset=1"            ; Enable hard reset support
     "amdgpu.lock_vram=1"             ; Lock VRAM allocations (better perf/stability)
     "h264_amf=1"                     ; Enable H.264 AMF encoding (hardware acceleration)

     ;; ─── Power and Performance ──────────────────────────────────────
     "irqaffinity=1-3"                ; Bind IRQs to CPUs 1–3
     "cpufreq.default_governor=schedutil" ; Use scheduler-aware CPU governor
     "amd_pstate=active"              ; Enable AMD P-state driver for better scaling
     "rcu_nocbs=0-3"                  ; Offload RCU processing from CPUs 0–3

     ;; ─── IOMMU and Virtualization ───────────────────────────────────
     "amd_iommu=on"                   ; Enable AMD IOMMU
     "iommu=pt"                       ; Use passthrough mode (best for VFIO/PCI passthrough)

     ;; ─── System Behavior ────────────────────────────────────────────
     "noirqdebug"                     ; Disable IRQ debugging output
     "watchdog"                       ; Enable hardware watchdog timer
     "noreplace-smp"                  ; Prevent SMP code hot-replacement
     "sysrq_always_enabled=1"         ; Always allow SysRq for recovery/debugging
     "modprobe.blacklist=firewire_core,firewire_ohci,dccp,sctp,rds,tipc" ; Disable unused/insecure kernel modules
     ))

  
  ;; Initialize microcode for CPU security updates
  (initrd microcode-initrd)
  
  ;; Include firmware for hardware support
  (firmware (list linux-firmware))
  
  ;; Set system locale to Brazilian Portuguese
  (locale "pt_BR.UTF-8")
  
  ;; Set timezone to São Paulo, Brazil
  (timezone "America/Sao_Paulo")
  
  ;; Configure Brazilian keyboard layout
  (keyboard-layout (keyboard-layout "br"))
  
  ;; Hostname of the system
  (host-name "securityops")
  
  ;; The list of user accounts ('root' is implicit).
  (users
   (cons*
    ;; Existing user: Berkeley
    (user-account
     (name "berkeley")
     (comment "Berkeley")
     (group "users")
     (home-directory "/home/berkeley")
     (supplementary-groups '("wheel" "netdev" "audio" "video" "plugdev")))
    %base-user-accounts))
  
  ;; Installed Packages
  ;; This section lists all packages installed on the system, grouped by functionality
  ;; for clarity. Each package is essential for graphics, multimedia, development,
  ;; system utilities, security, networking, or aesthetics.
  (packages
   (append
    (list
     ;; Graphics and Multimedia
     xf86-video-amdgpu         ; AMD GPU driver for Xorg
     xf86-input-libinput       ; Input driver for touchpads, mice, and keyboards
     xf86-input-mouse          ; Legacy mouse input driver for Xorg
     xf86-input-synaptics      ; Synaptics touchpad driver for Xorg
     libva-utils               ; Utils for encoding
     libass                    ; Subtitle rendering library
     mesa                      ; OpenGL implementation for 3D rendering
     mesa-headers              ; Headers for Mesa development
     mesa-utils                ; Utilities for testing and debugging Mesa
     llvm-for-mesa             ; LLVM compiler optimized for Mesa
     vulkan-tools              ; Tools for Vulkan API development and debugging
     vulkan-loader             ; Vulkan API runtime loader
     libva                     ; Video Acceleration API for hardware video decoding
     libva-utils               ; Utilities for testing VAAPI
     gstreamer                 ; Multimedia framework for audio/video processing
     gst-plugins-bad           ; Additional GStreamer plugins (less stable)
     gst-plugins-good          ; High-quality GStreamer plugins
     mpv                       ; Lightweight, customizable media player
     vlc                       ; Versatile media player with broad codec support
     obs                       ; Streaming and recording software
     openshot                  ; Non-linear video editing software
     gimp                      ; Advanced image editing and graphic design
     imagemagick               ; Command-line image processing toolkit
     photoflare                ; Lightweight image editor with intuitive interface
     libbluray                 ; Blu-ray disc playback support
     libaacs                   ; AACS decryption for Blu-ray playback
     libbdplus                 ; BD+ decryption for Blu-ray playback
     v4l-utils                 ; Video4Linux utilities for webcam and TV tuner support
     mangohud                  ; Performance overlay for games and applications
     
     ;; Desktop and Window Management
     polybar                   ; Customizable status bar for window managers
     waybar                    ; Status bar for Wayland-based environments
     fnott                     ; Lightweight notification daemon for Wayland
     swww                      ; Wallpaper manager for Wayland
     fuzzel-lowercase          ; Application launcher for Wayland (lowercase variant)
     wl-clipboard              ; Clipboard management for Wayland
     wlrctl                    ; Utility for controlling Wayland compositors
     wlsunset                  ; Day/night gamma adjustment for Wayland
     xdg-utils                 ; Desktop integration utilities
     compton                   ; Lightweight X11 compositor
     picom                     ; Modern X11 compositor with advanced effects
     brightnessctl             ; Control display brightness
     feh                       ; Lightweight image viewer and wallpaper setter
     rofi                      ; Application launcher and window switcher
     xmonad                    ; Tiling window manager written in Haskell
     i3-wm                     ; Lightweight tiling window manager
     i3status                  ; Status bar for i3-wm
     dmenu                     ; Dynamic menu for X11
     xmobar                    ; Lightweight status bar for Xmonad
     xset                      ; X11 display settings utility
     lxrandr                   ; Monitor configuration for LXDE
     xrandr                    ; X11 display resolution and rotation utility
     xwininfo                  ; Window information utility for X11
     xprop                     ; Property display for X11 windows
     xpra                      ; Remote desktop and application forwarding
     xkill                     ; Utility to kill X11 windows
     setxkbmap                 ; Set X11 keyboard layout
     xmodmap                   ; Modify X11 keymaps
     figlet                    ; Terminal Enhancement
     
     ;; Browsers
     nyxt                      ; Keyboard-oriented, extensible web browser
     qutebrowser               ; Vim-like keybinding web browser
     icecat                    ; GNU version of Firefox with privacy enhancements
     torbrowser                ; Tor-enabled browser for anonymous browsing
     zen-browser-bin           ; Privacy-focused web browser
     google-chrome-stable      ; Chromium-based web browser
     
     ;; File and Disk Management
     gthumb                    ; Image viewer and organizer
     mergerfs                  ; Union filesystem for combining multiple drives
     parted                    ; Disk partitioning tool
     ntfs-3g                   ; NTFS filesystem support
     cifs-utils                ; Utilities for mounting SMB/CIFS shares
     samba                     ; SMB/CIFS file sharing server
     udevil                    ; Mount and unmount devices without root
     smartmontools             ; Disk health monitoring
     bcachefs-tools            ; Tools for Bcachefs filesystem
     exfat-utils               ; Utilities for exFAT filesystems
     exfatprogs                ; Modern exFAT filesystem tools
     fuse-exfat                ; FUSE-based exFAT filesystem support
     dosfstools                ; Tools for FAT filesystems
     gnome-disk-utility        ; GUI disk management tool
     gparted                   ; Graphical disk partitioning tool
     
     ;; Development Tools
     gcc                       ; GNU Compiler Collection
     gcc-toolchain             ; Complete GCC toolchain
     linux-libre-headers       ; Linux kernel headers for development
     git                       ; Version control system
     git-lfs                   ; Git extension for large files
     ghc                       ; Glasgow Haskell Compiler
     ghc-cabal-syntax          ; Cabal syntax for Haskell package management
     cabal-install             ; Haskell package manager
     ghc-git-lfs               ; Haskell bindings for Git LFS
     ghc-hackage-security      ; Security for Haskell package downloads
     ghc-xmonad-contrib        ; Xmonad window manager extensions
     guile-ncurses             ; Ncurses bindings for Guile
     ;guile-emacs               ; Emacs Lisp compatibility for Guile
     guile-semver              ; Semantic versioning for Guile
     go                        ; Go programming language
     openjdk                   ; Java Development Kit
     python                    ; Python programming language
     python-pip                ; Python package manager
     python-emoji              ; Emoji support for Python
     python-pdfminer-six       ; PDF text extraction library
     rust                      ; Rust programming language
     node                      ; Node.js JavaScript runtime
     cmake                     ; Cross-platform build system
     meson                     ; High-performance build system
     binutils                  ; GNU binary utilities
     strace                    ; System call tracer
     edk2-tools                ; UEFI firmware development tools
     fzf                       ; Command-line fuzzy finder
     jq                        ; JSON processor
     grep                      ; Pattern matching utility
     sed                       ; Stream editor for text manipulation
     coreutils                 ; GNU core utilities
     
     ;; Text Editors and IDEs
     emacs                     ; Extensible text editor
     emacs-latex-preview-pane  ; LaTeX preview for Emacs
     emacs-emojify             ; Emoji support for Emacs
     vim                       ; Lightweight text editor with modal editing
     neovim                    ; Modern Vim fork with enhanced features
     gedit                     ; GNOME text editor
     
     ;; System Monitoring and Utilities
     htop                      ; Interactive process viewer
     btop                      ; Modern system monitor
     glances                   ; Cross-platform system monitoring
     inxi                      ; System information tool
     neofetch                  ; System information display
     pfetch                    ; Lightweight system info fetcher
     sysbench                  ; System performance benchmark
     dmidecode                 ; Hardware information tool
     lm-sensors                ; Hardware monitoring sensors
     radeontop                 ; AMD GPU monitoring
     net-tools                 ; Basic networking tools
     fping                     ; Ping multiple hosts
     netdiscover               ; Network discovery tool
     whois                     ; Domain and IP lookup tool
     macchanger                ; MAC address spoofing utility
     
     ;; Security and Privacy
     audit                     ; Audit System
     sysstat                   ; System stat
     nftables                  ; Firewall
     iptables                  ; Dumb firewall
     clamav                    ; Antivirus software
     gnupg                     ; GNU Privacy Guard for encryption
     libfido2                  ; FIDO2/U2F authentication library
     firejail                  ; Security sandbox for applications
     privoxy                   ; Privacy-enhancing proxy
     openvpn                   ; VPN client for secure connections
     tor                       ; Anonymity network client
     tor-client                ; Tor network client
     torsocks                  ; Socks proxy for Tor
     nmap                      ; Network exploration and security auditing
     wireshark                 ; Network protocol analyzer
     tcpdump                   ; Packet analyzer
     openssl                   ; Cryptography and SSL/TLS toolkit
     keepassxc                 ; Password manager
     kleopatra                 ; GPG key management tool
     hashcat                   ; Password recovery tool
     haunt                     ; Static site generator with privacy focus
     
     ;; Input Methods
     ibus                      ; Intelligent Input Bus for input methods
     fcitx5                    ; Input method framework
     fcitx5-gtk                ; GTK integration for Fcitx5
     fcitx5-qt                 ; Qt integration for Fcitx5
     fcitx5-anthy              ; Japanese input method for Fcitx5
     fcitx5-gtk4               ; GTK4 integration for Fcitx5
     fcitx5-configtool         ; Configuration tool for Fcitx5
     
     ;; Communication
     matterbridge              ; Bridge for multiple messaging platforms
     qtox                      ; Tox-based secure messaging
     jami                      ; Secure peer-to-peer communication
     telegram-desktop          ; Telegram messaging client
     nheko                     ; Matrix client with a focus on simplicity
     senpai                    ; IRC client
     
     ;; Virtualization and Containers
     qemu                      ; Virtual machine emulator
     virt-manager              ; GUI for managing virtual machines
     docker                    ; Container platform
     containerd                ; Container runtime
     
     ;; Audio
     alsa-lib                  ; ALSA sound library
     alsa-utils                ; ALSA audio utilities
     pavucontrol               ; PulseAudio volume control
     pavucontrol-qt            ; Qt-based PulseAudio volume control
     mpd                       ; Music Player Daemon
     noisetorch                ; Noise suppression for audio
     bluez                     ; Bluetooth protocol stack
     bluez-alsa                ; ALSA integration for Bluetooth
     blueman                   ; Bluetooth manager
     cmus                      ; Lightweight console music player
     navidrome-bin             ; Music streaming server
     jamesdsp                  ; Audio Effects

     ;; PDF and Document Tools
     mupdf                     ; Lightweight PDF viewer
     zathura                   ; Customizable document viewer
     poppler                   ; PDF rendering library
     poppler-qt5               ; Qt5 bindings for Poppler
     python-pdfminer-six       ; PDF text extraction
     foliate                   ; Ebook reader
     kiwix-tools               ; Offline content access tools
     
     ;; Fonts
     font-dejavu               ; DejaVu font family for general use
     font-adobe-source-code-pro ; Monospace font for coding
     font-adobe-source-han-sans ; CJK font for Chinese, Japanese, Korean
     font-adobe-source-sans-pro ; Sans-serif font for documents
     font-adobe-source-serif-pro ; Serif font for documents
     font-anonymous-pro        ; Monospace font for programming
     font-anonymous-pro-minus  ; Variant of Anonymous Pro
     font-awesome              ; Icon font for UI elements
     font-cns11643             ; CJK font for traditional Chinese
     font-cns11643-swjz        ; Simplified Chinese variant of CNS11643
     font-comic-neue           ; Casual comic-style font
     font-culmus               ; Hebrew fonts
     font-dosis                ; Rounded sans-serif font
     font-dseg                 ; Retro-style segmented display font
     font-fantasque-sans       ; Monospace font with a quirky design
     font-fira-code            ; Monospace font with ligatures for coding
     font-fira-mono            ; Monospace font for programming
     font-fira-sans            ; Sans-serif font for UI and documents
     font-fontna-yasashisa-antique ; Japanese font with a soft aesthetic
     font-google-noto-emoji    ; Font Emojis
     font-google-material-design-icons ; Material Design icons
     font-google-noto          ; Comprehensive font for multiple scripts
     font-google-roboto        ; Modern sans-serif font
     font-gnu-freefont         ; GNU FREE
     font-hack                 ; Monospace font for coding
     font-hermit               ; Monospace font with clean design
     font-ibm-plex             ; Modern font family for UI and documents
     font-inconsolata          ; Monospace font for programming
     font-iosevka              ; Highly customizable monospace font
     font-iosevka-aile         ; Iosevka variant with cursive style
     font-iosevka-etoile       ; Iosevka variant with decorative style
     font-iosevka-slab         ; Iosevka with slab serifs
     font-iosevka-term         ; Iosevka optimized for terminals
     font-iosevka-term-slab    ; Iosevka terminal font with slab serifs
     font-ipa-mj-mincho        ; Japanese Mincho font
     font-jetbrains-mono       ; Monospace font for developers
     font-lato                 ; Sans-serif font for modern design
     font-liberation           ; Open-source font family
     font-linuxlibertine       ; Serif font for documents
     font-lohit                ; Fonts for Indian scripts
     font-meera-inimai         ; Tamil font
     font-mononoki             ; Monospace font for coding
     font-mplus-testflight     ; Japanese font family
     font-public-sans          ; Clean sans-serif font
     font-rachana              ; Malayalam font
     font-sarasa-gothic        ; CJK font with gothic style
     font-sil-andika           ; Font for literacy and education
     font-sil-charis           ; Serif font for publishing
     font-sil-gentium          ; High-quality serif font
     font-tamzen               ; Monospace bitmap font
     font-terminus             ; Monospace bitmap font
     font-tex-gyre             ; Professional font family for documents
     font-un                   ; Korean font
     font-vazir                ; Persian font
     font-wqy-microhei         ; CJK font for Chinese
     font-wqy-zenhei           ; CJK font for Chinese
     font-adobe100dpi          ; Adobe bitmap fonts (100 DPI)
     font-adobe75dpi           ; Adobe bitmap fonts (75 DPI)
     font-cronyx-cyrillic      ; Cyrillic bitmap fonts
     font-dec-misc             ; Miscellaneous bitmap fonts
     font-isas-misc            ; Miscellaneous bitmap fonts
     font-micro-misc           ; Small bitmap fonts
     font-misc-cyrillic        ; Cyrillic bitmap fonts
     font-misc-ethiopic        ; Ethiopic bitmap fonts
     font-misc-misc            ; Miscellaneous bitmap fonts
     font-mutt-misc            ; Bitmap fonts for Mutt
     font-schumacher-misc      ; Classic bitmap fonts
     font-screen-cyrillic      ; Cyrillic fonts for terminal
     font-sony-misc            ; Sony bitmap fonts
     font-sun-misc             ; Sun bitmap fonts
     font-util                 ; Font utilities
     font-winitzki-cyrillic    ; Cyrillic bitmap fonts
     font-xfree86-type1        ; Type1 fonts for X11
     font-google-noto-emoji    ; Noto emoji font
     font-openmoji             ; Open-source emoji font
     
     ;; Miscellaneous
     fnc                       ; Addon for fossil 
     fossil                    ; Fossil SCM 
     usbutils                  ; Tools for USB device management
     anydesk                   ; Remote desktop software
     flameshot                 ; Screenshot tool
     flatpak                   ; Application sandboxing and distribution
     xfe                       ; Lightweight file manager
     ranger                    ; Console-based file manager
     lf                        ; Minimalist file manager
     nomacs                    ; Cross-platform image viewer
     unzip                     ; Archive extraction tool
     p7zip                     ; 7-Zip archive tool
     unrar                     ; RAR archive extractor
     lz4                       ; Fast compression algorithm
     zstd                      ; High-performance compression
     coreutils                 ; GNU core utilities
     grep                      ; Pattern matching utility
     sed                       ; Stream editor
     jq                        ; JSON processor
     asciinema                 ; Terminal session recorder
     xmessage                  ; X11 message display utility
     xrdb                      ; X11 resource database utility
     linux-firmware            ; Firmware for hardware support
     nix                       ; Reproducible package manager
     sqlite                    ; Lightweight SQL database
     procps                    ; Process utilities
     scrot                     ; Screenshot tool
     maim                      ; Modern screenshot tool
     dconf                     ; Configuration storage system
     fdm                       ; Mail fetching and delivery tool
     kid3                      ; Audio tag editor
     qtsolutions               ; Qt utility libraries
     kitty                     ; Fast, GPU-accelerated terminal emulator
     alacritty                 ; GPU-accelerated terminal emulator
     wipe                      ; Secure file deletion
     fontconfig                ; Font configuration library
     libxfont                  ; X11 font library
     libxft                    ; X11 FreeType font library
     libgccjit                 ; JIT compilation library for GCC
     mcron                     ; Cron job scheduler
     kcalc                     ; KDE calculator
     bc                        ; Command-line calculator
     graphviz                  ; Graph visualization tool
     httrack                   ; Website mirroring tool
     geekbench5                ; System benchmarking tool
     vim-characterize          ; Vim plugin for character information
     r-emojifont               ; Emoji font for R
     unicode-emoji             ; Unicode emoji data
     emacs-company-emoji       ; Emoji completion for Emacs
     sbcl                      ; Steel Bank Common Lisp
     clisp                     ; GNU Common Lisp
     monero-gui                ; Monero cryptocurrency wallet
     qbittorrent               ; BitTorrent client
     ncurses                   ; Terminal interface library
     tdlib                     ; Telegram library
     virt-manager              ; GUI for managing virtual machines
     containerd                ; Container runtime
     guix                      ; Guix package manager
     nsxiv                     ; Lightweight image viewer
     ueberzug++                ; Image overlay for terminals
     )
    
    ;; Base Packages
    (list
     (specification->package "xmonad")          ; Tiling window manager
     (specification->package "i3-wm")           ; Lightweight tiling window manager
     (specification->package "i3status")        ; Status bar for i3-wm
     (specification->package "dmenu")           ; Dynamic menu for X11
     (specification->package "foliate")         ; Ebook reader
     (specification->package "kitty")           ; Fast terminal emulator
     (specification->package "mullvad-vpn-desktop") ; Mullvad VPN client
     (specification->package "tor")             ; Tor anonymity network
     (specification->package "docker")          ; Container platform
     (specification->package "docker-compose")  ; Multi-container Docker management
     (specification->package "emacs")           ; Extensible text editor
     (specification->package "jami")            ; Secure peer-to-peer communication
     (specification->package "steam")           ; Gaming platform
     (specification->package "protonup-ng")     ; Proton compatibility tool for Steam
     (specification->package "qemu")            ; Virtual machine emulator
     (specification->package "alacritty")       ; GPU-accelerated terminal
     (specification->package "xkill")           ; Utility to kill X11 windows
     (specification->package "guile")           ; GNU Scheme implementation
     (specification->package "ueberzug++")      ; Image overlay for terminals
     (specification->package "fcitx5-gtk4")     ; GTK4 integration for Fcitx5
     (specification->package "fcitx5-qt")       ; Qt integration for Fcitx5
     (specification->package "fcitx5-gtk")      ; GTK integration for Fcitx5
     (specification->package "torbrowser")      ; Tor-enabled browser
     (specification->package "i2pd")            ; I2P anonymous network
     (specification->package "unrar")           ; RAR archive extractor
     (specification->package "nicotine+")       ; Soulseek file-sharing client
     (specification->package "icecat")          ; GNU Firefox variant
     (specification->package "gimp")            ; Image editor
     (specification->package "tor-client")      ; Tor network client
     (specification->package "make")            ; GNU Make build tool
     (specification->package "element-desktop") ; Matrix messaging client
     (specification->package "telegram-desktop") ; Telegram client
     (specification->package "font-apple-color-emoji") ; Apple emoji font
     (specification->package "zen-browser-bin") ; Privacy-focused browser
     (specification->package "xmobar")          ; Status bar for Xmonad
     (specification->package "xmodmap")         ; X11 keymap modifier
     (specification->package "rofi")            ; Application launcher
     (specification->package "bluez-alsa")      ; ALSA integration for Bluetooth
     (specification->package "bluez")           ; Bluetooth protocol stack
     (specification->package "fuse")            ; Filesystem in Userspace
     (specification->package "blueman")        ; Bluetooth manager
     (specification->package "cmus")            ; Console music player
     (specification->package "navidrome-bin")  ; Music streaming server
     (specification->package "nftables")
     (specification->package "mlocate") 
     (specification->package "audit")
     (specification->package "aide")
)
    %base-packages))
  
  ;; System Services
  ;; This section configures essential system services for connectivity, security,
  ;; input methods, virtualization, and desktop integration.
  (services
   (append
    (list
     ;; Bluetooth Service
     ;; Enables automatic Bluetooth device connectivity
     (service bluetooth-service-type
              (bluetooth-configuration
               (auto-enable? #t)))
     
        ;; Device Authorization Udev Rules
        ;; Consolidates rules for FIDO2/U2F and trusted USB devices to avoid duplicate
        ;; `plugdev` group warnings, ensuring compatibility with
        ;; usbcore.authorized_default=0
        (udev-rules-service
          'device-authorization
          (udev-rule
            "99-device-authorize.rules"
            (string-append
              ;; FIDO2/U2F Devices
              "SUBSYSTEM==\"hidraw\", "
              "KERNEL==\"hidraw*\", "
              "ATTRS{idVendor}==\"1050\", " ; Yubico
              "GROUP=\"plugdev\", "
              "MODE=\"0660\"\n"
              "SUBSYSTEM==\"hidraw\", "
              "KERNEL==\"hidraw*\", "
              "ATTRS{idVendor}==\"2c97\", " ; Nitrokey
              "GROUP=\"plugdev\", "
              "MODE=\"0660\"\n"
              "SUBSYSTEM==\"hidraw\", "
              "KERNEL==\"hidraw*\", "
              "ATTRS{idVendor}==\"096e\", " ; Feitian FIDO2/U2F
              "GROUP=\"plugdev\", "
              "MODE=\"0660\"\n"
              ;; SINO WEALTH Gaming Keyboard
              "SUBSYSTEM==\"usb\", "
              "ATTRS{idVendor}==\"258a\", "
              "ATTRS{idProduct}==\"002a\", "
              "ATTR{authorized}=\"1\"\n"
              ;; Logitech USB Keyboard
              "SUBSYSTEM==\"usb\", "
              "ATTRS{idVendor}==\"046d\", "
              "ATTRS{idProduct}==\"c34b\", "
              "ATTR{authorized}=\"1\"\n"
              ;; Cambridge Silicon Radio Bluetooth Dongle
              "SUBSYSTEM==\"usb\", "
              "ATTRS{idVendor}==\"0a12\", "
              "ATTRS{idProduct}==\"0001\", "
              "ATTR{authorized}=\"1\"\n"
              ;; Logitech Wireless Receiver
              "SUBSYSTEM==\"usb\", "
              "ATTRS{idVendor}==\"046d\", "
              "ATTRS{idProduct}==\"c542\", "
              "ATTR{authorized}=\"1\"\n"
              ;; Logitech Mouse
              "SUBSYSTEM==\"usb\", "
              "ATTRS{idVendor}==\"046d\", "
              "ATTRS{idProduct}==\"c077\", "
              "ATTR{authorized}=\"1\"\n"
              ;; SanDisk 3.2Gen1 USB Storage
              "SUBSYSTEM==\"usb\", "
              "ATTRS{idVendor}==\"0781\", "
              "ATTRS{idProduct}==\"55a9\", "
              "ATTR{authorized}=\"1\"\n"))
          #:groups '("plugdev"))

     ;; NFTables Firewall
     ;; Implements a strict firewall with input and output filtering, allowing loopback,
     ;; established connections, Mullvad VPN (UDP port 51820), Tor (local-only),
     ;; Avahi (mDNS on virbr0), outgoing SSH, HTTPS for Guix and web browsing,
     ;; Steam, and Mullvad control traffic on UDP port 54347. Includes logging for dropped packets.
     (service nftables-service-type
              (nftables-configuration
               (ruleset
                (plain-file "nftables.conf" "
# Strict firewall for privacy and security
# Replace MULLVAD_SERVER_IP_X with IPs from https://mullvad.net/en/servers
# Replace MULLVAD_DNS_IP with 100.64.0.23
flush ruleset

table inet filter {
    # Anti-spoofing: Drop invalid source addresses
    chain antispoof {
        ip saddr 127.0.0.0/8 iif != lo drop
        ip6 saddr ::1 iif != lo drop
        ip saddr 0.0.0.0/8 drop
        ip6 saddr ::/128 drop
        log prefix \"SPOOFED_INPUT: \" level warn limit rate 5/minute drop
    }

    chain input {
        type filter hook input priority filter; policy drop;
        jump antispoof
        ct state invalid drop comment \"Drop invalid connections\"
        iif \"lo\" accept comment \"Allow loopback traffic\"
        ct state established,related accept comment \"Allow established connections\"
        udp dport 51820 limit rate 8/second accept comment \"Mullvad WireGuard\"
        ip saddr {$MULLVAD_IP`S HERE} tcp sport 443 ct state established limit rate 4/second accept comment \"Mullvad control\"
        ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded } limit rate 1/second accept comment \"Allow essential ICMP\"
        ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert, echo-request, destination-unreachable, time-exceeded } limit rate 1/second accept comment \"Allow essential IPv6 ICMP\"
        tcp dport { 9050, 9040 } iif \"lo\" limit rate 4/second accept comment \"Tor SOCKS and TransPort (local)\"
        tcp flags syn / fin,syn,rst,ack limit rate 12/second accept comment \"Allow new TCP connections\"
        tcp flags fin,psh,urg / fin,psh,urg drop comment \"Block Xmas scans\"
        tcp flags syn,rst,ack / syn,rst drop comment \"Block invalid TCP flags\"
        log prefix \"DROPPED_INPUT: \" level warn limit rate 5/minute drop comment \"Log dropped input\"
    }

    chain forward {
        type filter hook forward priority filter; policy drop;
        ct state invalid drop comment \"Drop invalid connections\"
        ct state established,related accept comment \"Allow established connections\"
        iif \"wg0-mullvad\" accept comment \"Allow VPN incoming for torrenting\"
        oif \"wg0-mullvad\" accept comment \"Allow VPN forwarding for torrenting\"
        log prefix \"DROPPED_FORWARD: \" level warn limit rate 5/minute drop comment \"Log dropped forward\"
    }

    chain output {
        type filter hook output priority filter; policy drop;
        ct state invalid drop comment \"Drop invalid connections\"
        oif \"lo\" accept comment \"Allow loopback traffic\"
        ct state established,related accept comment \"Allow established connections\"
        udp dport 51820 limit rate 8/second accept comment \"Mullvad WireGuard\"
        ip daddr {$MULLVAD_IP`S HERE} tcp dport 443 limit rate 4/second accept comment \"Mullvad control\"
        oif \"wg0-mullvad\" { udp dport 53, tcp dport 53 } ip daddr 100.64.0.23 limit rate 8/second accept comment \"Mullvad DNS\"
        oif \"wg0-mullvad\" tcp dport 443 limit rate 50/second accept comment \"HTTPS for browsing and Guix pull\"
        oif \"wg0-mullvad\" tcp dport 9418 limit rate 10/second accept comment \"Git for Guix pull\"
        oif \"wg0-mullvad\" { tcp dport 27015, udp dport 27015, tcp dport 27036, udp dport 27036 } ip daddr { 162.254.192.0/18, 146.66.152.0/21 } limit rate 20/second accept comment \"Steam gaming\"
        oif \"wg0-mullvad\" { tcp dport 6881-6890, udp dport 6881-6890 } limit rate 50/second accept comment \"Torrenting\"
        oif \"wg0-mullvad\" accept comment \"Fallback for all VPN traffic\"
        ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, XXX.XXX.0.0/16 } accept comment \"Local networks\"
        ip6 daddr { fe80::/10, fc00::/7 } accept comment \"IPv6 local networks\"
        log prefix \"DROPPED_OUTPUT: \" level warn limit rate 5/minute drop comment \"Log dropped output\"
}
"))))
     
     ;; Blueman D-Bus Service
     ;; Provides D-Bus integration for Blueman Bluetooth manager
     (simple-service 'blueman dbus-root-service-type (list blueman))
     
     ;; Japanese Input Method Environment
     ;; Configures environment variables for Fcitx input method framework, supporting
     ;; Japanese input and Qt/GTK integration. Includes settings for sharper Qt rendering
     ;; and anisotropic filtering for AMD GPUs
     (simple-service
      'my-jp-ime-env
      session-environment-service-type
      '(("GTK_IM_MODULE" . "fcitx")              ; Set GTK input method to Fcitx
        ("QT_IM_MODULE" . "fcitx")               ; Set Qt input method to Fcitx
        ("GUIX_GTK2_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache") ; GTK2 input module cache
        ("GUIX_GTK3_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache") ; GTK3 input module cache
        ("XMODIFIERS=@im=" . "fcitx")            ; X11 input method modifier
        ("INPUT_METHOD" . "fcitx")               ; Default input method
        ("XIM_PROGRAM" . "fcitx")                ; X11 input method program
        ("GLFW_IM_MODULE" . "ibus")              ; GLFW input method for compatibility
        ("QML_DISABLE_DISTANCEFIELD" . "1")      ; Disable QML distance field rendering
        ("QT_QUICK_CONTROLS_STYLE" . "Fusion")   ; Set Qt Quick Controls style
        ("QT_ENABLE_HIGHDPI_SCALING" . "0")      ; Disable Qt HiDPI scaling
        ("R600_TEX_ANISO" . "16")                ; Set anisotropic filtering for AMD GPUs
        ))
     
     ;; Mullvad VPN Service
     ;; Runs the Mullvad VPN daemon for secure, private networking
     (service mullvad-daemon-service-type)
     
     ;; Docker Services
     ;; Enables Docker container platform and containerd runtime for containerized applications
     (service docker-service-type)
     (service containerd-service-type)
     
     ;; Nix Service
     ;; Integrates Nix package manager for reproducible package environments
     (service nix-service-type)
     
     ;; Tor Service
     ;; Configured for transparent proxying with TransPort and DNSPort 
     (service tor-service-type
              (tor-configuration
               (config-file
                (plain-file "tor.conf" "
# Log Tor activity (do not share logs publicly)
Log notice file /var/log/tor/tor.log
# Directory for Tor data (do not share contents)
DataDirectory /var/lib/tor
# SOCKS proxy port for applications
SOCKSPort 9050
# Transparent proxy port for traffic redirection
TransPort 9040
# Prevent debugger access
DisableDebuggerAttachment 1
# Fail if config entries are missing
AllowMissingTorrcEntries 0
# Map hosts to .onion addresses
AutomapHostsOnResolve 1
# Prevent acting as an exit node
ExitPolicy reject *:*
# Scrub sensitive info from logs
SafeLogging 1
"))))

     ;; Libvirt Virtualization Service
     ;; Configures libvirt for virtual machine management with Unix socket group
     ;; and TLS port for secure connections
     (service
      libvirt-service-type
      (libvirt-configuration
       (unix-sock-group "libvirt")
       (tls-port "16555")))
     
     ;; ZRAM Device Service
     ;; Configures zRAM for compressed swap space with 4GB size and zstd compression
     (service
      zram-device-service-type
      (zram-device-configuration
       (size (* 4 (expt 2 30))) ; 4GB zRAM size
       (compression-algorithm 'zstd) ; Use zstd compression
       (priority 100))) ; Set swap priority
     
     ;; Xorg Configuration
     ;; Sets X11 display server with Brazilian keyboard layout
     (set-xorg-configuration
      (xorg-configuration
       (keyboard-layout keyboard-layout)))
     
     ;; Graphics Environment Variables
     ;; Configures environment variables for optimized graphics performance,
     ;; prioritizing X11 and EGL backends with AMD-specific settings
  (simple-service
 'my-env-vars
 session-environment-service-type
 (list
  ;; GPU Rendering and Direct Rendering
  (cons "LIBGL_ALWAYS_SOFTWARE" "0")       ; Disable software rendering
  (cons "LIBGL_DRI3_ENABLE" "1")           ; Enable DRI3 for direct rendering
  (cons "VDPAU_DRIVER" "radeonsi")         ; Use radeonsi VDPAU driver for AMD GPUs
  (cons "DRI_PRIME" "1")                   ; Enable PRIME GPU offloading
  (cons "RADV_PERFTEST" "aco")             ; Use ACO shader compiler backend (faster than LLVM)
  
  ;; GTK/Qt Environment
  (cons "CLUTTER_BACKEND" "x11")           ; Use X11 for Clutter backend
  (cons "QT_QPA_PLATFORM" "xcb")           ; Use XCB for Qt platform
  (cons "QT_XCB_GL_INTEGRATION" "xcb_glx") ; Enable Qt GL integration
  (cons "QT_OPENGL" "desktop")             ; Use desktop OpenGL
  
  ;; GDK Environment
  (cons "GDK_BACKEND" "x11")               ; Use X11 for GDK backend
  (cons "GDK_GL" "glx")                    ; Use GLX
  (cons "GDK_SCALE" "1")                   ; Set GDK scaling to 1
  
  ;; Firefox Optimization
  (cons "MOZ_X11_EGL" "1")                 ; Enable EGL rendering for Firefox on X11
  (cons "MOZ_ENABLE_WAYLAND" "0")          ; Disable Wayland for Firefox
  (cons "MOZ_WEBRENDER" "1")               ; Enable WebRender for GPU acceleration
 )))
 
    %desktop-services))

  ;; Bootloader Configuration
  ;; Configures GRUB bootloader with a custom theme and 1920x1080 resolution
  (bootloader
   (bootloader-configuration
    (bootloader grub-bootloader)
    (targets (list "/dev/nvme0n1"))
    (theme
     (grub-theme
      (resolution '(1920 . 1080))
      (image (local-file "/home/berkeley/wallpapers/back.png"))))))
  
  ;; Swap Space
  ;; Defines swap space with a specific UUID and priority
  (swap-devices
   (list
    (swap-space
     (priority 50)
     (target (uuid "85b7b3d8-657a-443c-b010-52d224bc4483")))))
  
  ;; File Systems
  ;; Defines mounted filesystems, including EFI, root, and additional partitions
  (file-systems
   (cons*
    (file-system
     (mount-point "/boot/efi")
     (device (uuid "02E2-0AB2" 'fat32))
     (type "vfat"))
    (file-system
     (mount-point "/")
     (device (uuid "38467002-a282-4387-8319-cff6d93cd23b" 'ext4))
     (type "ext4"))
    (file-system
     (mount-point "/files")
     (device (uuid "7b2cbf88-bc71-49ad-b2fa-a4bbdb71f886" 'ext4))
     (type "ext4"))
     (file-system
     (mount-point "/mnt/games")
     (device (uuid "9d009d01-d635-4d56-987a-ffc2699da9fb" 'ext4))
     (type "ext4"))
    %base-file-systems)))
