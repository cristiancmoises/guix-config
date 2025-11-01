;; -*- mode: scheme; -*-
;; Guix System Configuration for Host "securityops"
;;
;; This configuration defines a secure, privacy-focused Guix system tailored for a machine
;; with AMD Ryzen 2200G and Radeon RX 5600/5700 series GPU. It uses a custom linux
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
;; Last Updated: August 02, 2025

;;; Module Imports
;; Import required Guix modules for package and service definitions
(use-modules
 (gnu)                         ; Core Guix module for system and package management
 (guix download)
 (guix utils)
 (guix build-system gnu)
 (guix ui)                     ; UI 
 (xlibre)
 (guix gexp)
 (gnu packages shells)
 (gnu packages apparmor)
 (guix build-system linux-module)
 (gnu packages gl)             ; OpenGL-related packages
 (gnu bootloader)              ; Bootloader utilities
 (gnu bootloader grub)         ; GRUB bootloader support
 (guix build syscalls)         ; System call utilities
 (gnu packages hardware)       ; Hardware-related packages
 (gnu packages haskell)        ; Haskell programming language packages
 (gnu packages haskell-apps)   ; Haskell application packages
 (gnu packages acct)           ; Audit
 (nongnu packages anydesk)     ; AnyDesk for remote desktop
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
 (gnu services admin)          ; Admin service definitions
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
 (gnu packages docker)         ; Docker containerization packages
 (gnu services docker)         ; Docker service definitions
 (gnu packages containers)     ; Podman packages
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
 (gnu services xorg)           ; Xlibre
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
 (nongnu packages node)
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
 guix base web security sysctl networking certbot shepherd nix cups desktop ssh docker xorg linux virtualization)

;; Import package modules for package management tools
(use-package-modules
 bootloaders package-management version-control gcc bash certs admin linux xorg)

(define-public securityops
  (package
    (inherit linux)
    (name "securityops")
    (version "6.17")
    (source (origin
              (method url-fetch)
              (uri "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.4.tar.xz")
              (sha256
               (base32 "1nwi0hzikziwkxm9xzf819wb3lsz93i1ns1nzybpbfkgdqli42h1"))))
    (arguments
     (substitute-keyword-arguments (package-arguments linux)
       ((#:defconfig _) (list (local-file "/etc/securityops.defconfig")))
       ;; Keep all default phases
       ((#:phases phases) phases)))))

;; -------------------------------------------------------------------
;; XLibre Configuration for AMDGPU with native resolution 1366x768
;; Description: Optimized configuration for AMDGPU using XLibre with
;;              Glamor acceleration, TearFree, DRI3, and adaptive
;;              flip/page-flip options. Keyboard layout set to Brazilian.
;;
;; Description:
;;   This configuration is for a single-monitor setup using an AMDGPU-based
;;   graphics card with XLibre (X.Org replacement). It is optimized for:
;;     - Native resolution: 1366x768
;;     - Tear-free experience
;;     - Smooth animations using triple buffering
;;     - Adaptive refresh and DRI3 support
;;     - Glamor acceleration for 2D and 3D
;;
;; Sections:
;;   1. Device
;;      - Identifies the GPU device and sets performance/display options.
;;      - Key options:
;;          TearFree: Prevents tearing on fast-moving content
;;          AccelMethod: Uses Glamor 2D acceleration
;;          DRI: Uses DRI3 for faster rendering
;;          TripleBuffer: Reduces stutter in animations
;;          ShadowPrimary: Helps reduce tearing
;;          ColorTiling / ColorTiling2D: Optimize memory layout for 2D/3D rendering
;;          AsyncFlipSecondaries / EnablePageFlip: Improve display flips performance
;;          SwapbuffersWait: Wait for sync for smoother frame presentation
;;          AllowGLXWithComposite: Allow GLX apps with compositing managers
;;
;;   2. Monitor
;;      - Defines the connected monitor, its sync ranges, and preferred resolution.
;;      - DPMS: Enables Display Power Management Signaling (power saving)
;;
;;   3. Screen
;;      - Connects GPU device to monitor
;;      - Defines default color depth and display modes
;;
;; Notes:
;;   - Keyboard layout is set to Brazilian (br)
;;   - This configuration is designed for a single HDMI monitor.
;;   - All X11 configuration is contained in 'extra-config' to avoid external
;;     xorg.conf files.
;;   - Ensure this configuration is loaded by XLibre at startup to avoid
;;     resolution or tearing issues.

(define my-xlibre-config
  (xlibre-configuration
    (modules (list xlibre-video-amdgpu xlibre-input-libinput))
    (drivers '("amdgpu"))
    (keyboard-layout (keyboard-layout "br"))
    (extra-config
     (list
 "Section \"Device\"\n\
    Identifier \"AMD-GPU\"\n\
    Driver \"amdgpu\"\n\
    Option \"TearFree\" \"on\"\n\
    Option \"AccelMethod\" \"glamor\"\n\
    Option \"DRI\" \"3\"\n\
    Option \"VariableRefresh\" \"true\"\n\
    Option \"AsyncFlipSecondaries\" \"true\"\n\
    Option \"EnablePageFlip\" \"true\"\n\
    Option \"ShadowPrimary\" \"true\"\n\
    Option \"ColorTiling\" \"true\"\n\
    Option \"ColorTiling2D\" \"true\"\n\
    Option \"EnableDepthMoves\" \"true\"\n\
    Option \"SwapbuffersWait\" \"true\"\n\
    Option \"AllowGLXWithComposite\" \"true\"\n\
    Option \"TripleBuffer\" \"true\"\n\
    Option \"DRI3SwapEvent\" \"true\"\n\
    Option \"AutoAddDevices\" \"false\"\n\
EndSection\n\
Section \"Monitor\"\n\
    Identifier \"HDMI-A-0\"\n\
    HorizSync 30.0-83.0\n\
    VertRefresh 56.0-76.0\n\
    Option \"PreferredMode\" \"1366x768\"\n\
    Option \"DPMS\" \"true\"\n\
EndSection\n\
Section \"Screen\"\n\
    Identifier \"Screen0\"\n\
    Device \"AMD-GPU\"\n\
    Monitor \"HDMI-A-0\"\n\
    DefaultDepth 32\n\
    SubSection \"Display\"\n\
        Depth 32\n\
        Modes \"1366x768\"\n\
    EndSubSection\n\
EndSection"
 ))))



(define my-env-vars
  (simple-service
   'my-env-vars
   session-environment-service-type
   (list
    (cons "LIBGL_ALWAYS_SOFTWARE" "0")
    (cons "LIBGL_DRI3_ENABLE" "1")
    (cons "VDPAU_DRIVER" "radeonsi")
    (cons "DRI_PRIME" "1")
    (cons "RADV_PERFTEST" "aco")
    (cons "CLUTTER_BACKEND" "x11")
    (cons "QT_QPA_PLATFORM" "xcb")
    (cons "QT_XCB_GL_INTEGRATION" "xcb_glx")
    (cons "QT_OPENGL" "desktop")
    (cons "GDK_BACKEND" "x11")
    (cons "GDK_GL" "glx")
    (cons "GDK_SCALE" "1")
    (cons "MOZ_X11_EGL" "1")
    (cons "MOZ_ENABLE_WAYLAND" "0")
    (cons "MOZ_WEBRENDER" "1"))))


;; Operating System Configuration
(operating-system            
  ;; Kernel Settings
(kernel securityops)
  (kernel-arguments
   '(
     ;; ─── Boot and General ─────────────────────────────────────────────
     "quiet"                           ; Minimize boot output
     "splash"                          ; Graphical splash screen
     "noatime"                         ; Disable file access time updates
     ;; ─── Memory Compression ───────────────────────────────────────────
     "zswap.enabled=1"                ; Enable zswap
     "zswap.compressor=zstd"          ; Zstandard compression
     "zswap.max_pool_percent=15"      ; Limit zswap to 15% of RAM
     "zswap.zpool=z3fold"             ; Z3fold allocator
     "zswap.accept_threshold_percent=90" ; Compress at 90% memory usage
     "zswap.same_filled_pages_enabled=1" ; Deduplicate pages
     ;; ─── I/O and Filesystem ──────────────────────────────────────────
     "elevator=bfq"                   ; BFQ scheduler
     "rootflags=data=ordered"         ; Ordered journaling
     "fsck.mode=auto"                 ; Auto filesystem checks
     "fsck.repair=preen"              ; Safe repairs
     "vm.dirty_writeback_centisecs=1000" ; Flush dirty pages every 10s
     ;; ─── CPU and Memory Security ─────────────────────────────────────
     "module.sig_enforce=1"           ; Enforce signed modules
     "kptr_restrict=2"                ; Hide kernel pointers
     "lockdown=confidentiality"       ; Kernel lockdown
     "slab_nomerge"                   ; Prevent slab merging
     "page_alloc.shuffle=1"           ; Randomize page allocator
     "random.trust_cpu=off"           ; Disable CPU RNG trust
     "preempt=full"                   ; Full preemption
     "sched_yield_type=2"             ; Aggressive yield
     "transparent_hugepage=always"    ; Enable hugepages
     "vsyscall=none"                  ; Disable vsyscall
     "randomize_kstack_offset=on"     ; Randomize kernel stack
     ;; ─── Security Mitigations ────────────────────────────────────────
     "mitigations=auto"               ; Auto-apply CPU mitigations
     "spec_store_bypass_disable=prctl" ; Spectre v4 mitigation
     "mce=1"                          ; Machine Check Exception handling
     ;; ─── USB Security ───────────────────────────────────────────────
     ; "usbcore.authorized_default=0"  ; Disable auto-authorizing USB devices (anti-badusb)
     ;; ─── Networking Optimizations ───────────────────────────────────
     "tcp_congestion_control=bbr"     ; Use BBR for efficient TCP congestion control
     "net.core.default_qdisc=fq_codel" ; Use fq_codel for fair network queuing
     "net.ipv4.tcp_fq_codel_quantum=1000" ; Set fq_codel quantum for TCP
     "net.ipv4.tcp_fq_codel_target=5000"  ; Set fq_codel target latency
     "net.ipv4.tcp_ecn=1"             ; Enable Explicit Congestion Notification
     "net.ipv4.tcp_fastopen=3"        ; Enable TCP Fast Open for faster connections
     "net.core.netdev_max_backlog=10000" ; Increase network device backlog
     "net.core.rmem_max=16777216"     ; Increase receive buffer size
     "net.core.wmem_max=16777216"     ; Increase send buffer size
     "net.ipv4.tcp_rmem=4096 87380 16777216" ; Set TCP receive buffer sizes
     "net.ipv4.tcp_wmem=4096 65536 16777216" ; Set TCP send buffer sizes
     "net.ipv4.tcp_mtu_probing=1"     ; Enable MTU probing for TCP
     "net.core.optmem_max=131072"     ; Increase socket option memory
     "net.ipv4.tcp_window_scaling=1"  ; Enable TCP window scaling
     "net.ipv4.tcp_sack=1"            ; Enable Selective Acknowledgments
     "net.ipv4.tcp_early_retrans=3"   ; Enable early retransmission for TCP
     "net.ipv4.tcp_thin_linear_timeouts=1" ; Optimize TCP timeouts
     "ipv6.disable=0"                 ; Enable IPv6 support
     ;; ─── AMD GPU Tuning ─────────────────────────────────────────────
     ;"amdgpu.ppfeaturemask=0xffffffff" ; Unlock all features
     ;"amdgpu.dc=0"                    ; Enable Display Core
     ;"amdgpu.dpm=0"                   ; Dynamic Power Management
     ;"amdgpu.aspm=1"                  ; Active State Power Management
     ;"amdgpu.gpu_recovery=1"          ; GPU recovery
     ;"amdgpu.mcbp=1"                  ; Mid-chain bus power
     ;"amdgpu.dcfeaturemask=0xffffffff" ; All Display Core features
     "amdgpu.sched_policy=2"          ; High-priority scheduling
     "amdgpu.abmlevel=0"              ; Disable Adaptive Backlight
     "amdgpu.backlight=0"             ; Disable backlight control
     ;"amdgpu.runpm=1"                 ; Enable runtime power management
     "h264_amf=1"                     ; H.264 encoding
     ;; ─── Power and Performance ──────────────────────────────────────
     "irqaffinity=1-3"                ; IRQs on CPUs 1-3
     "cpufreq.default_governor=schedutil" ; Schedutil scaling
     "amd_pstate=active"              ; AMD P-state driver
     "rcu_nocbs=0-3"                  ; Offload RCU from all CPUs
     ;; ─── IOMMU and Virtualization ───────────────────────────────────
     "amd_iommu=on"                   ; Enable AMD IOMMU
     "iommu=pt"                       ; Passthrough mode
     ;; ---- SELINUX ----------------------------------------------------
     "apparmor=1"
     "security=apparmor"
     ;; ─── System Behavior ────────────────────────────────────────────
     "noirqdebug"                     ; Disable IRQ debugging
     "watchdog"                       ; Hardware watchdog
     "noreplace-smp"                  ; Prevent SMP code replacement
     "sysrq_always_enabled=1"         ; Enable SysRq
     "modprobe.blacklist=firewire_core,firewire_ohci,dccp,sctp,rds,tipc"))

  (initrd microcode-initrd)
  
  ;; Include firmware for hardware support
  (firmware (list linux-firmware))


  ;; Set system locale to Brazilian Portuguese
  (locale "pt_BR.UTF-8")
  
  ;; Set timezone to São Paulo, Brazil
  (timezone "America/Sao_Paulo")
  
  ;; Configure Brazilian keyboard layout for console
  (keyboard-layout (keyboard-layout "br"))
  
  ;; Hostname of the system
  (host-name "securityops")
  
  ;; The list of user accounts ('root' is implicit).
(users
 (cons*
   (user-account
     (name "berkeley")
     (comment "berkeley")
     (group "users")
     (home-directory "/home/berkeley")
     (supplementary-groups '("wheel" "input" "docker" "kvm" "netdev" "audio" "video" "plugdev")))
   %base-user-accounts))

  
;; Minimal essential packages only

(packages
 (append
  ;; ===========================
  ;; Browser & Apps
  ;; ===========================
  (list 
   zen-browser-bin
   icecat
   torbrowser
   jami
   steam)
  ;; ===========================
  ;; Drivers and Firmware
  ;; ===========================
  (list
   acpi-call-linux-module
   util-linux
   v4l2loopback-linux-module
   xlibre-server
   xlibre-input-libinput
   xlibre-video-amdgpu
   amd-microcode
   amdgpu-firmware
   mesa
   mesa-headers
   llvm-for-mesa
   libva
   libva-utils
   vulkan-tools
   vulkan-loader
   linux-firmware
   openrgb
   )

  ;; ===========================
  ;; X Utilities (Essential)
  ;; ===========================
  (list
   xterm
   xdpyinfo
   xset
   xwininfo
   xprop
   xpra
   xkill
   setxkbmap
   xmodmap
   figlet
   xdg-utils
   xrandr
   xmonad
   ghc-xmonad-contrib
   )

  ;; ===========================
  ;; File and Disk Management
  ;; ===========================
  ( list
   lf
   mergerfs
   parted
   ntfs-3g
   exfat-utils
   exfatprogs
   fuse-exfat
   dosfstools
   bcachefs-tools
   smartmontools
   ueberzug++
   e2fsprogs
   dosfstools
   xfsprogs
   )

  ;; ===========================
  ;; Development / Build Essentials
  ;; ===========================
  (list
   gcc
   gcc-toolchain
   linux-libre-headers
   git
   git-lfs
   ghc
   cabal-install
   python
   python-pip
   rust
   go
   node
   haunt
   yarn
   cmake
   meson
   binutils
   strace
   edk2-tools
   kitty
   alacritty
   fish
   bat
   zoxide
   fastfetch
   pfetch
   )

  ;; ===========================
  ;; Security / VPN / Cryptography
  ;; ===========================
  (list
   apparmor
   acct
   ansible
   audit
   sysstat
   nftables
   clamav
   gnupg
   libfido2
   firejail
   privoxy
   openvpn
   tor
   torsocks
   nmap
   wireshark
   tcpdump
   openssl
   keepassxc
   hashcat
   )

  ;; ===========================
  ;; Virtualization / Containers
  ;; ===========================
  (list
   qemu
   virt-manager
   docker
   runc
   podman
   containerd
   )

  ;; ===========================
  ;; System Monitoring and Utilities
  ;; ===========================
  (list
   htop
   btop
   glances
   inxi
   lm-sensors
   radeontop
   net-tools
   fping
   netdiscover
   whois
   macchanger
   procps
   sqlite
   coreutils
   grep
   sed
   jq
   nix
   )

  ;; ===========================
  ;; Audio (System-Level)
  ;; ===========================
  (list
   alsa-lib
   alsa-utils
   pulseaudio
   pipewire
   wireplumber
   )

  ;; =========================
  ;; Fonts
  ;; =========================
  (list
   font-iosevka-term
   font-iosevka-term-slab
   font-iosevka-slab
   font-iosevka-etoile
   font-iosevka-curly
   font-iosevka-curly-slab
   font-iosevka-aile
   font-iosevka-ss01
   font-iosevka-ss02
   font-iosevka-ss03
   font-iosevka-ss04
   font-iosevka-ss05
   font-iosevka-ss06
   font-iosevka-ss07
   font-iosevka-ss08
   font-iosevka-ss09
   font-iosevka-ss10
   font-iosevka-ss11
   font-iosevka-ss12
   font-iosevka-ss13
   font-iosevka-ss14
   font-iosevka-ss15
   font-iosevka-ss16
   font-iosevka-ss17
   font-iosevka-ss18
   font-sarasa-gothic
   font-aporetic
   font-adwaita
)
  ;; ===========================
  ;; Base packages (Guix essentials)
  ;; ===========================
  %base-packages))

;; System Services
;; This section configures essential system services for connectivity, security,
;; input methods, virtualization, and desktop integration.
(services
 (append
  (list
   ;; AIDE Service for File Integrity (FINT-4316, FINT-4402)
   (simple-service 'aide
                   shepherd-root-service-type
                   (list
                    (shepherd-service
                     (provision '(aide))
                     (start #~(make-forkexec-constructor
                               '("/bin/sh" "-c" "/usr/bin/aide --config=/etc/aide.conf --check")))
                     (stop #~(make-kill-destructor))
                     (auto-start? #f))))
   ;; mlocate Service for Locate Database (FILE-6410)
   (simple-service 'mlocate
                   shepherd-root-service-type
                   (list
                    (shepherd-service
                     (provision '(mlocate))
                     (start #~(make-forkexec-constructor
                               '("/usr/bin/updatedb")))
                     (stop #~(make-kill-destructor))
                     (auto-start? #f))))
   ;; File Permissions Service for /home and /var/lib/aide (HOME-930 Republican: System: (HOME-9304, FILE-7524)
   (simple-service 'file-permissions
                   shepherd-root-service-type
                   (list
                    (shepherd-service
                     (provision '(file-permissions))
                     (start #~(make-forkexec-constructor
                               '("/bin/sh" "-c"
                                 "chmod 751 /home && chmod 750 /var/lib/aide")))
                     (stop #~(make-kill-destructor))
                     (auto-start? #t))))
   ;; Bluetooth Service
   ;; Enables automatic Bluetooth device connectivity
   (service bluetooth-service-type
            (bluetooth-configuration
             (auto-enable? #t)))
   
   ;; Device Authorization Udev Rules
(udev-rules-service
 'device-authorization
 (udev-rule
   "99-device-authorize.rules"
   (string-append
     "SUBSYSTEM==\"usb\", ATTR{authorized}=\"1\"\n"))
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
        iif \"lo\" accept comment \"Allow all loopback traffic (including Unix sockets for X11)\"
        ct state established,related accept comment \"Allow established connections\"
        udp dport 51820 limit rate 8/second accept comment \"Mullvad WireGuard\"
        ip saddr { $MULLVADIP } tcp sport 443 ct state established limit rate 4/second accept comment \"Mullvad control\"
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
        oif \"lo\" accept comment \"Allow loopback traffic (including Unix sockets for X11)\"
        ct state established,related accept comment \"Allow established connections\"
        udp dport 51820 limit rate 8/second accept comment \"Mullvad WireGuard\"
        ip daddr { $MULLVADIP } tcp dport 443 limit rate 4/second accept comment \"Mullvad control\"
        oif \"wg0-mullvad\" { udp dport 53, tcp dport 53 } ip daddr 100.64.0.23 limit rate 8/second accept comment \"Mullvad DNS\"
        oif \"wg0-mullvad\" tcp dport 443 limit rate 50/second accept comment \"HTTPS for browsing and Guix pull\"
        oif \"wg0-mullvad\" tcp dport 9418 limit rate 10/second accept comment \"Git for Guix pull\"
        oif \"wg0-mullvad\" { tcp dport 27015, udp dport 27015, tcp dport 27036, udp dport 27036 } ip daddr { 162.254.192.0/18, 146.66.152.0/21 } limit rate 20/second accept comment \"Steam gaming\"
        oif \"wg0-mullvad\" { tcp dport 6881-6890, udp dport 6881-6890 } limit rate 50/second accept comment \"Torrenting\"
        oif \"wg0-mullvad\" accept comment \"Fallback for all VPN traffic\"
        ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept comment \"Local networks\"
        ip6 daddr { fe80::/10, fc00::/7 } accept comment \"IPv6 local networks\"
        log prefix \"DROPPED_OUTPUT: \" level warn limit rate 5/minute drop comment \"Log dropped output\"
    }
}
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

;; Expose Root Cache for the user Berkeley
    (service shared-cache-service-type
             (shared-cache-configuration
               (mode 'expose)  ; use 'share se for single-user confiável
               (shared-directory "/root/.cache")
               (users (list (user-cache (user "berkeley"))))))

   ;; Custom SLiM service with Xlibre
   (service slim-service-type
            (slim-configuration
              (auto-login? #f)
              (default-user "berkeley")
              (xorg-configuration my-xlibre-config))))
 (modify-services
  %desktop-services
  (delete gdm-service-type))))
  
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

