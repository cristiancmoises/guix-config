;; -*- mode: scheme; -*-
;; Guix System Configuration for Host "lisp"
;;
;; Overview:
;; This configuration defines a secure, privacy-focused Guix system tailored for a machine
;; with an AMD Ryzen 2200G CPU and Radeon RX 5600/5700 series GPU. It uses a custom
;; linux-xanmod kernel optimized for performance and security, with a strict NFTables
;; firewall to route all traffic through Mullvad VPN (WireGuard, wg0-mullvad) by default.
;; Tor is configured for occasional use via torando scripts, providing transparent proxying
;; (SOCKS 9050, TransPort 9040). The system supports web browsing (Zen Browser, Icecat,
;; Tor Browser), Guix upgrades, torrenting (qBittorrent), Steam gaming, and SSH, with
;; Xmonad as the window manager, Rofi for launching applications, and Fish Shell with
;; Starship for an enhanced terminal experience.
;;
;; Key Features:
;; - Privacy: Routes traffic through Mullvad VPN, supports Tor, locks down DNS to Mullvad's
;;   servers, and enforces kernel lockdown for enhanced isolation.
;; - Security: Implements a strict NFTables firewall, enforces module signature verification,
;;   and includes anti-spoofing measures.
;; - Performance: Optimizes for AMD hardware with GPU/CPU tuning, BBR networking, and
;;   zswap compression for efficient memory usage.
;; - Functionality: Supports browsing, gaming, torrenting, development, and Japanese input
;;   via Fcitx5.
;; - Maintainability: Fully declarative Guix setup with granular firewall rules and
;;   automated user environment configuration.
;;
;; Usage Instructions:
;; - Validate configuration: `guix system build /etc/config.scm`
;; - Apply configuration: `sudo guix system reconfigure /etc/config.scm`
;; - Configure home environment: `guix home reconfigure ~/.config/guix/home.scm`
;; - Apply Fontconfig: `fc-cache -fv`
;; - Test Mullvad VPN: `mullvad connect`, `curl https://am.i.mullvad.net/connected`
;; - Test Tor: `sudo herd start tor`, `torsocks curl http://example.com`
;; - Test Rofi: Press Mod+d in Xmonad to launch applications
;; - Monitor logs: `sudo journalctl -f | grep DROPPED`, `sudo tail -f /var/log/tor/tor.log`
;;
;; Notes for Public Sharing (e.g., Codeberg):
;; - Replace `MULLVAD_SERVER_IP_X` in NFTables with actual IPs from https://mullvad.net/en/servers
;; - Set `MULLVAD_DNS_IP` to 100.64.0.23 for Mullvad's DNS in NFTables
;; - Do not share Tor logs (/var/log/tor/tor.log) or DataDirectory contents (/var/lib/tor)
;; - Ensure sensitive information (e.g., UUIDs, IPs) is sanitized before sharing
;;
;; Maintainer: Cristian Cezar Moisés
;; Last Updated: June 20, 2025

;;; Module Imports
;; Import Guix modules required for package and service definitions, organized by category
(use-modules
 ;; Core Guix and System Utilities
 (gnu)                         ; Core Guix module for system and package management
 (guix gexp)                   ; G-expressions for dynamic code evaluation
 (guix store)                  ; Guix store management utilities
 (guix packages)               ; Package management functions
 (guix transformations)        ; Package transformation utilities
 (guix git-download)           ; Support for Git-based package downloads
 (guix git)                    ; Git utilities for Guix
 (guix channels)               ; Guix channel management
 (guix inferior)               ; Inferior processes for Guix

 ;; Bootloader and Firmware
 (gnu bootloader)              ; Bootloader configuration utilities
 (gnu bootloader grub)         ; GRUB bootloader support
 (gnu packages firmware)       ; Firmware packages for hardware support
 (nongnu system linux-initrd)  ; Non-GNU Linux initrd system

 ;; Graphics and Multimedia
 (gnu packages gl)             ; OpenGL and graphics-related packages
 (gnu packages vulkan)         ; Vulkan graphics API packages
 (gnu packages gstreamer)      ; GStreamer multimedia framework
 (gnu packages video)          ; Video processing and playback packages
 (gnu packages photo)          ; Photography and image editing packages
 (gnu packages imagemagick)    ; ImageMagick for image processing
 (gnu packages gimp)           ; GIMP image editor
 (radix packages image-viewers); Custom image viewer packages
 (gnu packages music)          ; Music-related packages
 (gnu packages pulseaudio)     ; PulseAudio sound server
 (gnu packages mpd)            ; Music Player Daemon (MPD)
 (ajatt packages audio)        ; Custom audio software packages

 ;; Desktop and Window Management
 (gnu packages xorg)           ; Xorg server and utilities
 (gnu packages xdisorg)        ; X11 display organization utilities
 (gnu packages wm)             ; Window manager packages (e.g., Xmonad, i3)
 (gnu packages compton)        ; Compton/Picom compositor
 (gnu packages freedesktop)    ; Freedesktop.org standards (e.g., XDG)
 (gnu packages lxde)           ; LXDE desktop utilities
 (gnu packages lxqt)           ; LXQt desktop environment
 (radix packages xdisorg)      ; Custom X11 display organization packages
 (gnu packages gnome)          ; GNOME desktop utilities
 (gnu packages xfce)           ; XFCE desktop utilities

 ;; Development Tools
 (gnu packages build-tools)    ; Build tools (e.g., Make, CMake)
 (gnu packages gcc)            ; GCC compiler and toolchain
 (gnu packages version-control); Version control systems (e.g., Git)
 (gnu packages haskell)        ; Haskell programming language
 (gnu packages haskell-apps)   ; Haskell applications (e.g., Xmonad)
 (gnu packages haskell-xyz)    ; Additional Haskell-related packages
 (gnu packages guile-xyz)      ; Guile-related packages
 (gnu packages python)         ; Python programming language
 (gnu packages python-build)   ; Python build tools
 (gnu packages python-xyz)     ; Additional Python packages
 (gnu packages java)           ; Java development tools
 (gnu packages golang)         ; Go programming language
 (gnu packages rust)           ; Rust programming language
 (gnu packages rust-apps)      ; Rust-based applications
 (gnu packages zig-xyz)        ; Zig programming language
 (gnu packages lisp)           ; Lisp programming language
 (gnu packages lisp-xyz)       ; Additional Lisp-related packages
 (nongnu packages clojure)     ; Clojure programming language
 (gnu packages cmake)          ; CMake build system
 (gnu packages commencement)   ; Commencement (initrd) packages
 (gnu packages engineering)    ; Engineering and development tools
 (rosenthal packages binaries) ; Custom binary packages
 (saayix packages binaries)    ; Additional custom binary packages

 ;; Text Editors and IDEs
 (gnu packages emacs)          ; Emacs text editor
 (gnu packages emacs-xyz)      ; Emacs-related packages
 (rosenthal packages emacs-xyz); Custom Emacs packages
 (gnu packages vim)            ; Vim and Neovim editors
 (gnu packages cran)           ; CRAN (R) packages for data analysis

 ;; System and Networking
 (gnu packages admin)          ; System administration tools
 (gnu packages linux)          ; Linux kernel and utilities
 (gnu packages networking)     ; Networking utilities
 (gnu packages base)           ; Base system utilities
 (gnu packages package-management) ; Package management tools (e.g., Guix, Nix)
 (gnu packages rsync)          ; Rsync file synchronization
 (gnu packages ssh)            ; SSH client and server
 (gnu packages curl)           ; cURL for HTTP/FTP transfers
 (nongnu packages linux)       ; Non-GNU Linux-related packages
 (gnu packages benchmark)      ; GNU benchmarking tools
 (nongnu packages benchmark)   ; Non-GNU benchmarking tools
 (gnu packages logging)        ; Logging utilities (e.g., rsyslog)
 (gnu packages ncurses)        ; Ncurses library for terminal interfaces

 ;; Security and Privacy
 (gnu packages tor)            ; Tor anonymity network
 (gnu packages tor-browsers)   ; Tor Browser for anonymous browsing
 (gnu packages vpn)            ; VPN client and server packages
 (small-guix packages mullvad) ; Mullvad VPN packages
 (small-guix services mullvad) ; Mullvad VPN service definitions
 (gnu packages security-token) ; Security token support (e.g., FIDO2)
 (gnu packages gnupg)          ; GNU Privacy Guard for encryption
 (gnu packages password-utils) ; Password management tools
 (gnu packages tls)            ; TLS/SSL libraries
 (gnu packages antivirus)      ; Antivirus software (e.g., ClamAV)
 (gnu packages i2p)            ; I2P anonymous network

 ;; Input Methods
 (gnu packages fcitx5)         ; Fcitx5 input method framework
 (gnu packages ibus)           ; IBus input method framework
 (ajatt packages dictionaries) ; Custom dictionary packages for input methods

 ;; Communication
 (gnu packages messaging)       ; Messaging clients (e.g., Telegram, Matrix)
 (gnu packages jami)           ; Jami secure communication
 (gnu packages telegram)       ; Telegram client packages

 ;; Virtualization and Containers
 (gnu packages virtualization)  ; Virtualization tools (e.g., QEMU, libvirt)
 (gnu packages docker)         ; Docker container platform

 ;; Fonts
 (gnu packages fonts)          ; Font packages for text rendering
 (gnu packages fontutils)      ; Font utilities (e.g., Fontconfig)
 (nongnu packages compression) ; Non-GNU compression utilities
 (gnu packages unicode)        ; Unicode and emoji support
 (gnu packages figlet)         ; Figlet for ASCII art in terminals

 ;; File and Disk Management
 (gnu packages file-systems)   ; Filesystem utilities (e.g., NTFS, exFAT)
 (gnu packages disk)           ; Disk management tools
 (gnu packages samba)          ; Samba for SMB/CIFS file sharing
 (gnu packages image-viewers)  ; Image viewer applications

 ;; Miscellaneous
 (nongnu packages anydesk)     ; AnyDesk for remote desktop
 (nongnu packages chrome)      ; Chromium-based browser (e.g., Google Chrome)
 (gnu packages web)            ; Web-related utilities
 (gnu packages web-browsers)   ; Web browsers (e.g., Icecat, Qutebrowser)
 (gnu packages gnuzilla)       ; GNUzilla (Firefox-based browsers)
 (gnu packages finance)        ; Financial tools (e.g., Monero)
 (gnu packages pdf)            ; PDF viewers and tools
 (gnu packages ebook)          ; Ebook readers (e.g., Foliate)
 (gnu packages kde)            ; KDE desktop environment
 (gnu packages kde-utils)      ; KDE utility tools
 (gnu packages kde-multimedia) ; KDE multimedia applications
 (gnu packages kde-pim)        ; KDE personal information management
 (gnu packages graphviz)       ; Graph visualization tools
 (ajatt packages suckless)     ; Custom suckless software
 (ajatt packages readers)      ; Custom reader applications
 (nongnu packages game-client) ; Non-GNU game clients (e.g., Steam)
 (gnu packages databases)      ; Database tools (e.g., SQLite)
 (gnu packages android)        ; Android-related tools
 (gnu packages terminals)      ; Terminal emulators (e.g., Kitty, Alacritty)
 (gnu packages mail)           ; Mail clients and utilities
 (gnu packages qt)             ; Qt framework for GUI applications
 (gnu packages bittorrent)     ; BitTorrent clients (e.g., qBittorrent)
 (gnu packages chromium)       ; Chromium-based browser utilities
 (gnu packages compression)    ; Compression tools (e.g., zstd, lz4)

 ;; Service Modules
 (gnu services)                ; General service definitions
 (gnu services base)           ; Base system services (e.g., udev, syslog)
 (gnu services linux)          ; Linux-specific services (e.g., zram)
 (gnu services mcron)          ; Mcron for scheduled tasks
 (gnu services shepherd)       ; Shepherd init system services
 (gnu services networking)     ; Networking services (e.g., NFTables)
 (gnu services vpn)            ; VPN services (e.g., Mullvad)
 (gnu services docker)         ; Docker and container services
 (gnu services nix)            ; Nix package manager service
 (gnu services tor)            ; Tor anonymity service
 (gnu services virtualization) ; Virtualization services (e.g., libvirt)
 (gnu services xorg)           ; Xorg display server services
 (gnu services dbus)           ; D-Bus inter-process communication
 (gnu services certbot)        ; Certbot for SSL/TLS certificates
 (gnu services configuration)  ; Service configuration utilities
 (gnu services herd)           ; Herd service management
 (gnu system shadow)           ; User and password management
 (rde features bluetooth)      ; Bluetooth service definitions
 (radix services admin)        ; Custom administrative services

 ;; SRFI Libraries
 (srfi srfi-1)                 ; SRFI-1 list manipulation library
)

;;; Package Definitions
;; Define package variables for use in services and configurations
(define my-kernel linux-xanmod)         ; Custom linux-xanmod kernel for performance
(define rottlog (specification->package "rottlog")) ; Log rotation utility
(define aide (specification->package "aide"))       ; File integrity checker
(define sysstat (specification->package "sysstat")) ; System performance monitoring
(define blueman (specification->package "blueman")) ; Bluetooth manager
(define libfido2 (specification->package "libfido2")); FIDO2/U2F authentication
(define rsyslog (specification->package "rsyslog"))  ; Enhanced logging system

;;; Doas Configuration
;; Defines general rules for doas, allowing wheel group users to execute commands
;; with preserved Guile environment variables
(define general
  (list
   (permit
    (identity ":wheel")  ; Allow users in the wheel group
    (setenv
     `(("GUILE_LOAD_PATH" . #t)          ; Preserve Guile load path
       ("GUILE_LOAD_COMPILED_PATH" . #t) ; Preserve compiled Guile path)))))

;;; Operating System Configuration
;; Defines the complete system configuration, including kernel, bootloader, services,
;; and filesystems
(operating-system
  ;; Kernel Configuration
  ;; Uses linux-xanmod kernel with optimized arguments for performance, security,
  ;; and privacy
  (kernel my-kernel)
  (kernel-arguments
   '(
     ;; Boot and General Settings
     "quiet"                           ; Suppress most boot messages for clean output
     "splash"                          ; Display graphical splash screen during boot
     "noatime"                         ; Disable file access time updates for performance

     ;; Memory Compression
     "zswap.enabled=1"                 ; Enable zswap for compressed swap cache
     "zswap.compressor=zstd"           ; Use Zstandard for efficient compression
     "zswap.max_pool_percent=15"       ; Limit zswap pool to 15% of RAM
     "zswap.zpool=z3fold"              ; Use z3fold allocator for compressed memory
     "zswap.accept_threshold_percent=90" ; Compress only when memory is 90% full
     "zswap.same_filled_pages_enabled=1" ; Deduplicate identical pages

     ;; I/O and Filesystem
     "elevator=bfq"                    ; Use BFQ I/O scheduler for desktop responsiveness
     "rootflags=data=ordered"          ; Use ordered journaling for ext4 filesystem
     "fsck.mode=auto"                  ; Automatically check filesystems on boot
     "fsck.repair=preen"               ; Perform safe filesystem repairs during boot
     "vm.dirty_writeback_centisecs=1000" ; Flush dirty pages every 10 seconds

     ;; CPU and Memory Security
     "module.sig_enforce=1"            ; Enforce signed kernel modules only
     "kptr_restrict=2"                 ; Restrict kernel pointer access for security
     "lockdown=confidentiality"        ; Enable kernel lockdown for root protection
     "slab_nomerge"                    ; Prevent slab cache merging (mitigates heap attacks)
     "page_alloc.shuffle=1"            ; Randomize page allocator for exploit mitigation
     "random.trust_cpu=off"            ; Disable CPU RNG trust for /dev/random
     "preempt=full"                    ; Enable full kernel preemption for responsiveness
     "sched_yield_type=2"              ; Optimize scheduling for low-latency yielding
     "transparent_hugepage=always"     ; Enable transparent hugepages for performance

     ;; Kernel Memory Initialization
     "init_on_alloc=1"                 ; Zero memory pages on allocation
     "init_on_free=1"                  ; Zero memory pages on free
     "vsyscall=none"                   ; Disable legacy vsyscall support for security
     "efi=disable_early_pci_dma"       ; Prevent early PCI DMA attacks

     ;; Spectre/Meltdown and CPU Bug Mitigations
     "pti=on"                          ; Enable Page Table Isolation for Meltdown
     "l1tf=full,force"                 ; Fully mitigate L1TF vulnerability
     "tsx=off"                         ; Disable TSX (exploit vector)
     "spec_store_bypass_disable=prctl" ; Mitigate Speculative Store Bypass
     "mitigations=auto"                ; Automatically apply appropriate mitigations

     ;; Stability and Debugging
     "oops=panic"                      ; Panic on kernel oops for stability
     "panic=10"                        ; Reboot after 10 seconds of panic
     "panic_on_oops=1"                 ; Ensure panic on oops

     ;; IRQ and RCU Optimization
     "threadirqs"                      ; Move IRQs to kernel threads for better latency
     "noirqdebug"                      ; Disable IRQ debugging to reduce noise
     "rcu_nocb_poll"                   ; Use polling for RCU callbacks
     "rcu_nocbs=1-3"                   ; Offload RCU callbacks from CPUs 1-3

     ;; Power Management and Performance
     "irqaffinity=1-3"                 ; Assign IRQs to CPUs 1-3
     "cpufreq.default_governor=schedutil" ; Use schedutil for CPU frequency scaling
     "amd_pstate=active"               ; Enable AMD P-State for power/performance
     "nmi_watchdog=0"                  ; Disable NMI watchdog to reduce overhead

     ;; Memory Behavior
     "vm.max_map_count=16777216"       ; Allow large memory mappings for containers
     "vm.swappiness=10"                ; Prefer RAM over swap (low swappiness)
     "vm.vfs_cache_pressure=50"        ; Retain inode/dentry cache longer

     ;; Optional Memory Debugging
     "page_poison=1"                   ; Poison freed memory to catch bugs
     "randomize_kstack_offset=on"      ; Randomize kernel stack for security

     ;; Networking Optimizations
     "tcp_congestion_control=bbr"      ; Use BBR for improved network latency
     "net.core.default_qdisc=fq_codel" ; Reduce bufferbloat with FQ-CoDel
     "net.ipv4.tcp_fq_codel_quantum=1000" ; Set quantum for FQ-CoDel
     "net.ipv4.tcp_fq_codel_target=5000" ; Set target latency for CoDel (µs)
     "net.ipv4.tcp_ecn=1"              ; Enable Explicit Congestion Notification
     "net.ipv4.tcp_fastopen=3"         ; Enable TCP Fast Open for client/server
     "net.core.netdev_max_backlog=10000" ; Large backlog for high-speed networking
     "net.core.rmem_max=16777216"      ; Max receive buffer size
     "net.core.wmem_max=16777216"      ; Max send buffer size
     "net.ipv4.tcp_rmem=4096 87380 16777216" ; TCP receive buffer sizes
     "net.ipv4.tcp_wmem=4096 65536 16777216" ; TCP send buffer sizes
     "net.ipv4.tcp_mtu_probing=1"      ; Enable MTU probing for performance
     "net.core.optmem_max=131072"      ; Max per-socket option memory
     "net.ipv4.tcp_window_scaling=1"   ; Enable TCP window scaling
     "net.ipv4.tcp_sack=1"             ; Enable selective acknowledgments
     "net.ipv4.tcp_early_retrans=3"    ; Enable early retransmissions
     "net.ipv4.tcp_thin_linear_timeouts=1" ; Optimize timeouts for low-latency
     "ipv6.disable=0"                  ; Keep IPv6 enabled for compatibility

     ;; USB Security
     "usbcore.authorized_default=0"    ; Disable auto-authorizing USB devices (anti-BadUSB)

     ;; AMD GPU Tuning
     "amdgpu.ppfeaturemask=0xffffffff" ; Unlock all AMD GPU performance features
     "amdgpu.dc=1"                     ; Enable Display Core for GPU
     "amdgpu.dpm=1"                    ; Enable Dynamic Power Management
     "amdgpu.aspm=1"                   ; Enable Active State Power Management
     "amdgpu.gpu_recovery=1"           ; Enable recovery from GPU hangs
     "amdgpu.mcbp=1"                   ; Enable Mid-Chain Bus Power Management
     "amdgpu.dcfeaturemask=0xffffffff" ; Unlock all display core features
     "amdgpu.sched_policy=2"           ; Use high-priority GPU scheduling
     "amdgpu.abmlevel=0"               ; Disable Adaptive Backlight Management
     "amdgpu.backlight=0"              ; Disable kernel backlight control
     "amdgpu.runpm=0"                  ; Keep GPU always on (disable runtime PM)
     "h264_amf=1"                      ; Enable H.264 hardware video encoding

     ;; IOMMU and Virtualization
     "amd_iommu=on"                    ; Enable AMD IOMMU for device isolation
     "iommu=pt"                        ; Use IOMMU passthrough mode for performance

     ;; System Behavior
     "watchdog"                        ; Enable kernel watchdog for crash detection
     "noreplace-smp"                   ; Prevent replacing SMP kernel code
     "sysrq_always_enabled=1"          ; Enable SysRq keys for emergency debugging
     "modprobe.blacklist=firewire_core,firewire_ohci,dccp,sctp,rds,tipc" ; Blacklist unneeded protocols
     "audit=1"                         ; Enable kernel auditing for security events
   ))

  ;; Microcode Initialization
  ;; Applies CPU microcode updates for security and stability
  (initrd microcode-initrd)

  ;; Firmware
  ;; Includes firmware for hardware compatibility (e.g., GPU, Wi-Fi)
  (firmware (list linux-firmware))

  ;; System Locale
  ;; Sets system-wide locale to Brazilian Portuguese with UTF-8 encoding
  (locale "pt_BR.UTF-8")

  ;; Timezone
  ;; Configures timezone to São Paulo, Brazil
  (timezone "America/Sao_Paulo")

  ;; Keyboard Layout
  ;; Sets Brazilian keyboard layout for console and X11
  (keyboard-layout (keyboard-layout "br"))

  ;; Hostname
  ;; Names the system "lisp" for network identification
  (host-name "lisp")

  ;; User Accounts
  ;; Defines user accounts, including the primary user "berkeley" with necessary groups
  (users
   (cons*
    (user-account
     (name "berkeley")             ; Primary user account
     (comment "Berkeley")          ; User description
     (group "users")               ; Primary group
     (home-directory "/home/berkeley") ; Home directory path
     (supplementary-groups
      '("wheel" "netdev" "audio" "video" "plugdev")) ; Groups for admin, network, and hardware access
    %base-user-accounts))

  ;; Installed Packages
  ;; Lists all system-wide packages, grouped by functionality for clarity
  (packages
   (append
    (list
     ;; Graphics and Multimedia
     ;; Packages for GPU rendering, video playback, and image editing
     openrgb                   ; Control RGB lighting for peripherals
     libva-utils               ; Utilities for hardware video acceleration
     libass                    ; Library for subtitle rendering in media players
     mesa                      ; OpenGL implementation for 3D graphics
     mesa-headers              ; Headers for Mesa development
     mesa-utils                ; Tools for testing Mesa OpenGL
     llvm-for-mesa             ; LLVM optimized for Mesa graphics
     vulkan-tools              ; Tools for Vulkan API development
     vulkan-loader             ; Vulkan API runtime loader
     libva                     ; Video Acceleration API for hardware decoding
     libva-utils               ; Utilities for testing VAAPI
     gstreamer                 ; Multimedia framework for audio/video
     gst-plugins-bad           ; Additional GStreamer plugins (less stable)
     gst-plugins-good          ; High-quality GStreamer plugins
     mpv                       ; Lightweight, customizable media player
     vlc                       ; Versatile media player with codec support
     obs                       ; Software for streaming and recording
     openshot                  ; Non-linear video editing software
     gimp                      ; Advanced image editing and graphic design
     imagemagick               ; Command-line image processing toolkit
     photoflare                ; Lightweight image editor with intuitive UI
     libbluray                 ; Support for Blu-ray disc playback
     libaacs                   ; AACS decryption for Blu-ray
     libbdplus                 ; BD+ decryption for Blu-ray
     v4l-utils                 ; Video4Linux utilities for webcams/TV tuners
     mangohud                  ; Performance overlay for games and apps

     ;; Desktop and Window Management
     ;; Tools for window management, compositing, and desktop integration
     polybar                   ; Customizable status bar for window managers
     waybar                    ; Status bar for Wayland environments
     fnott                     ; Lightweight notification daemon for Wayland
     swww                      ; Wallpaper manager for Wayland
     fuzzel-lowercase          ; Application launcher for Wayland (lowercase)
     wl-clipboard              ; Clipboard management for Wayland
     wlrctl                    ; Utility for controlling Wayland compositors
     wlsunset                  ; Day/night gamma adjustment for Wayland
     xdg-utils                 ; Desktop integration utilities (XDG standards)
     compton                   ; Lightweight X11 compositor
     picom                     ; Modern X11 compositor with effects
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
     xrandr                    ; X11 resolution and rotation utility
     xwininfo                  ; Window information utility for X11
     xprop                     ; Property display for X11 windows
     xpra                      ; Remote desktop and application forwarding
     xkill                     ; Utility to kill X11 windows
     setxkbmap                 ; Set X11 keyboard layout
     xmodmap                   ; Modify X11 keymaps
     figlet                    ; ASCII art generator for terminals

     ;; Web Browsers
     ;; Browsers optimized for privacy and performance
     nyxt                      ; Keyboard-oriented, extensible web browser
     qutebrowser               ; Web browser with Vim-like keybindings
     icecat                    ; GNU Firefox with privacy enhancements
     torbrowser                ; Tor-enabled browser for anonymous browsing
     zen-browser-bin           ; Privacy-focused web browser
     google-chrome-stable      ; Chromium-based web browser

     ;; File and Disk Management
     ;; Tools for filesystem management and disk operations
     gthumb                    ; Image viewer and organizer
     mergerfs                  ; Union filesystem for combining drives
     parted                    ; Disk partitioning tool
     ntfs-3g                   ; NTFS filesystem support
     cifs-utils                ; Utilities for SMB/CIFS shares
     samba                     ; SMB/CIFS file sharing server
     udevil                    ; Mount/unmount devices without root
     smartmontools             ; Disk health monitoring
     bcachefs-tools            ; Tools for Bcachefs filesystem
     exfat-utils               ; Utilities for exFAT filesystems
     exfatprogs                ; Modern exFAT filesystem tools
     fuse-exfat                ; FUSE-based exFAT support
     dosfstools                ; Tools for FAT filesystems
     gnome-disk-utility        ; GUI disk management tool
     gparted                   ; Graphical disk partitioning tool

     ;; Development Tools
     ;; Tools for programming and development workflows
     gcc                       ; GNU Compiler Collection
     gcc-toolchain             ; Complete GCC toolchain
     linux-libre-headers       ; Linux kernel headers for development
     git                       ; Version control system
     git-lfs                   ; Git extension for large files
     ghc                       ; Glasgow Haskell Compiler
     ghc-cabal-syntax          ; Cabal syntax for Haskell packages
     cabal-install             ; Haskell package manager
     ghc-git-lfs               ; Haskell bindings for Git LFS
     ghc-hackage-security      ; Security for Haskell package downloads
     ghc-xmonad-contrib        ; Xmonad window manager extensions
     guile-ncurses             ; Ncurses bindings for Guile
     guile-emacs               ; Emacs Lisp compatibility for Guile
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
     ;; Editors for coding and document editing
     emacs                     ; Extensible text editor
     emacs-latex-preview-pane  ; LaTeX preview for Emacs
     emacs-emojify             ; Emoji support for Emacs
     vim                       ; Lightweight modal text editor
     neovim                    ; Modern Vim fork with enhanced features
     gedit                     ; GNOME text editor

     ;; System Monitoring and Utilities
     ;; Tools for monitoring system resources and hardware
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
     ;; Tools for securing the system and protecting privacy
     audit                     ; Kernel auditing system
     sysstat                   ; System performance statistics
     rsyslog                   ; Enhanced system logging
     rottlog                   ; Log rotation utility
     nftables                  ; Firewall configuration tool
     iptables                  ; Legacy firewall tool
     clamav                    ; Antivirus software
     gnupg                     ; GNU Privacy Guard for encryption
     libfido2                  ; FIDO2/U2F authentication library
     firejail                  ; Security sandbox for applications
     privoxy                   ; Privacy-enhancing proxy
     openvpn                   ; VPN client for secure connections
     tor                       ; Anonymity network client
     tor-client                ; Tor network client
     torsocks                  ; SOCKS proxy for Tor
     nmap                      ; Network exploration and security auditing
     wireshark                 ; Network protocol analyzer
     tcpdump                   ; Packet analyzer
     openssl                   ; Cryptography and SSL/TLS toolkit
     keepassxc                 ; Password manager
     kleopatra                 ; GPG key management tool
     hashcat                   ; Password recovery tool
     haunt                     ; Static site generator with privacy focus

     ;; Input Methods
     ;; Frameworks for multilingual input, particularly Japanese
     ibus                      ; Intelligent Input Bus for input methods
     fcitx5                    ; Fcitx5 input method framework
     fcitx5-gtk                ; GTK integration for Fcitx5
     fcitx5-qt                 ; Qt integration for Fcitx5
     fcitx5-anthy              ; Japanese input method for Fcitx5
     fcitx5-gtk4               ; GTK4 integration for Fcitx5
     fcitx5-configtool         ; Configuration tool for Fcitx5

     ;; Communication
     ;; Applications for secure and open communication
     matterbridge              ; Bridge for multiple messaging platforms
     qtox                      ; Tox-based secure messaging
     jami                      ; Secure peer-to-peer communication
     telegram-desktop          ; Telegram messaging client
     nheko                     ; Matrix client with simple UI
     senpai                    ; IRC client

     ;; Virtualization and Containers
     ;; Tools for running virtual machines and containers
     qemu                      ; Virtual machine emulator
     virt-manager              ; GUI for managing virtual machines
     docker                    ; Container platform
     containerd                ; Container runtime

     ;; Audio
     ;; Audio playback, management, and Bluetooth integration
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
     jamesdsp                  ; Audio effects processor

     ;; PDF and Document Tools
     ;; Tools for viewing and processing PDFs and ebooks
     mupdf                     ; Lightweight PDF viewer
     zathura                   ; Customizable document viewer
     poppler                   ; PDF rendering library
     poppler-qt5               ; Qt5 bindings for Poppler
     python-pdfminer-six       ; PDF text extraction
     foliate                   ; Ebook reader
     kiwix-tools               ; Offline content access tools

     ;; Fonts
     ;; Comprehensive font collection for UI, coding, and multilingual support
     font-dejavu               ; General-purpose font family
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
     font-dseg                 ; Retro segmented display font
     font-fantasque-sans       ; Monospace font with quirky design
     font-fira-code            ; Monospace font with ligatures
     font-fira-mono            ; Monospace font for programming
     font-fira-sans            ; Sans-serif font for UI
     font-fontna-yasashisa-antique ; Japanese font with soft aesthetic
     font-google-noto-emoji    ; Emoji font
     font-google-material-design-icons ; Material Design icons
     font-google-noto          ; Comprehensive font for multiple scripts
     font-google-roboto        ; Modern sans-serif font
     font-gnu-freefont         ; GNU free font collection
     font-hack                 ; Monospace font for coding
     font-hermit               ; Clean monospace font
     font-ibm-plex             ; Modern font family for UI/documents
     font-inconsolata          ; Monospace font for programming
     font-iosevka              ; Highly customizable monospace font
     font-iosevka-aile         ; Iosevka cursive variant
     font-iosevka-etoile       ; Iosevka decorative variant
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
     font-screen-cyrillic      ; Cyrillic fonts for terminals
     font-sony-misc            ; Sony bitmap fonts
     font-sun-misc             ; Sun bitmap fonts
     font-util                 ; Font utilities
     font-winitzki-cyrillic    ; Cyrillic bitmap fonts
     font-xfree86-type1        ; Type1 fonts for X11
     font-google-noto-emoji    ; Noto emoji font
     font-openmoji             ; Open-source emoji font

     ;; Miscellaneous Utilities
     ;; Tools for various tasks (e.g., remote desktop, screenshots, archives)
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
    ;; Additional packages specified by name for essential functionality
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
     (specification->package "qutebrowser")     ; Vim-like web browser
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
     (specification->package "nftables")        ; Firewall configuration tool
     (specification->package "mlocate")         ; File locator utility
     (specification->package "audit")           ; Kernel auditing system
     (specification->package "aide")            ; File integrity checker
     (specification->package "sysstat")         ; System performance monitoring
     (specification->package "rottlog")         ; Log rotation utility
    )
    %base-packages))

  ;; System Services
  ;; Configures essential services for logging, security, networking, input methods,
  ;; virtualization, and desktop integration
  (services
   (append
    (list
     ;; Rottlog Job
     ;; Schedules daily log rotation with rottlog at 20:00 (8:00 PM)
     (simple-service 'rottlog-job
                     mcron-service-type
                     (list
                      #~(job
                         #:schedule "0 20 * * *" ; Run daily at 20:00
                         #:command
                         (lambda ()
                           (system* (string-append #$rottlog "/sbin/rottlog"))))))

     ;; Rsyslog Service
     ;; Runs the rsyslog daemon for enhanced system logging, storing logs in /var/log
     (simple-service 'rsyslog
                     shepherd-root-service-type
                     (list
                      (shepherd-service
                       (provision '(rsyslog))               ; Service name
                       (requirement '(user-processes))      ; Depends on user processes
                       (documentation "Run the rsyslog daemon for system logging.")
                       (start #~(make-forkexec-constructor
                                 (list (string-append #$rsyslog "/sbin/rsyslogd")
                                       "-n")))             ; Run in foreground
                       (stop #~(make-kill-destructor)))))  ; Stop via kill signal

     ;; AIDE Integrity Check
     ;; Schedules weekly file integrity checks with AIDE to detect unauthorized changes
     (simple-service 'aide-scan
                     shepherd-root-service-type
                     (list
                      (shepherd-service
                       (documentation "Weekly AIDE integrity check")
                       (provision '(aide-check))            ; Service name
                       (requirement '(user-processes))      ; Depends on user processes
                       (start #~(make-forkexec-constructor
                                 (list #$(file-append aide "/bin/aide") "--check")))
                       (respawn? #f))))                     ; Do not respawn on failure

     ;; Sysstat Data Collection
     ;; Collects system performance data every 10 minutes using sysstat
     (simple-service 'sysstat-schedule
                     shepherd-root-service-type
                     (list
                      (shepherd-service
                       (documentation "Sysstat data collection")
                       (provision '(sysstat-collect))       ; Service name
                       (start #~(make-forkexec-constructor
                                 (list #$(file-append sysstat "/lib/sa/sa1") "600" "6")))
                       (respawn? #f))))                     ; Do not respawn on failure

     ;; Kernel Module Restrictions
     ;; Disables unneeded/legacy protocols (dccp, sctp, rds, tipc) via modprobe
     (service special-files-service-type
              `(("/etc/modprobe.d/disable-protocols.conf"
                 ,(plain-file "disable-protocols.conf"
                              "install dccp /bin/true\ninstall sctp /bin/true\ninstall rds /bin/true\ninstall tipc /bin/true"))))

     ;; Bluetooth Service
     ;; Enables automatic Bluetooth device connectivity using Bluez
     (service bluetooth-service-type
              (bluetooth-configuration
               (auto-enable? #t)))  ; Automatically enable Bluetooth on boot

     ;; FIDO2/U2F Support
     ;; Configures udev rules for FIDO2/U2F devices, assigning them to the "plugdev" group
     (udev-rules-service 'fido2 libfido2 #:groups '("plugdev"))

     ;; NFTables Firewall
     ;; Implements a strict firewall with input/output filtering, allowing:
     ;; - Loopback traffic
     ;; - Established connections
     ;; - Mullvad VPN (UDP 51820)
     ;; - Tor (local-only, ports 9050, 9040)
     ;; - Essential ICMP and IPv6 ICMP
     ;; - HTTPS (port 443) for browsing and Guix
     ;; - Git (port 9418) for Guix pull
     ;; - Steam (ports 27015, 27036)
     ;; - Torrenting (ports 6881-6890)
     ;; Includes anti-spoofing and logging for dropped packets
     (service nftables-service-type
              (nftables-configuration
               (ruleset
                (plain-file "nftables.conf"
                            "
# Strict firewall for privacy and security
# Replace MULLVAD_SERVER_IP_X with IPs from https://mullvad.net/en/servers
# Replace MULLVAD_DNS_IP with 100.64.0.23
flush ruleset

table inet filter {
    # Anti-spoofing chain: Drops invalid source addresses
    chain antispoof {
        ip saddr 127.0.0.0/8 iif != lo drop
        ip6 saddr ::1 iif != lo drop
        ip saddr 0.0.0.0/8 drop
        ip6 saddr ::/128 drop
        log prefix \"SPOOFED_INPUT: \" level warn limit rate 5/minute drop
    }

    # Input chain: Filters incoming traffic with a default drop policy
    chain input {
        type filter hook input priority filter; policy drop;
        jump antispoof
        ct state invalid drop comment \"Drop invalid connections\"
        iif \"lo\" accept comment \"Allow loopback traffic\"
        ct state established,related accept comment \"Allow established connections\"
        udp dport 51820 limit rate 8/second accept comment \"Mullvad WireGuard\"
        ip saddr { MULLVADIP1,MULLVADIP2,MULLVADIP3 } tcp sport 443 ct state established limit rate 4/second accept comment \"Mullvad control\"
        ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded } limit rate 1/second accept comment \"Allow essential ICMP\"
        ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert, echo-request, destination-unreachable, time-exceeded } limit rate 1/second accept comment \"Allow essential IPv6 ICMP\"
        tcp dport { 9050, 9040 } iif \"lo\" limit rate 4/second accept comment \"Tor SOCKS and TransPort (local)\"
        tcp flags syn / fin,syn,rst,ack limit rate 12/second accept comment \"Allow new TCP connections\"
        tcp flags fin,psh,urg / fin,psh,urg drop comment \"Block Xmas scans\"
        tcp flags syn,rst,ack / syn,rst drop comment \"Block invalid TCP flags\"
        log prefix \"DROPPED_INPUT: \" level warn limit rate 5/minute drop comment \"Log dropped input\"
    }

    # Forward chain: Filters forwarded traffic with a default drop policy
    chain forward {
        type filter hook forward priority filter; policy drop;
        ct state invalid drop comment \"Drop invalid connections\"
        ct state established,related accept comment \"Allow established connections\"
        iif \"wg0-mullvad\" accept comment \"Allow VPN incoming for torrenting\"
        oif \"wg0-mullvad\" accept comment \"Allow VPN forwarding for torrenting\"
        log prefix \"DROPPED_FORWARD: \" level warn limit rate 5/minute drop comment \"Log dropped forward\"
    }

    # Output chain: Filters outgoing traffic with a default drop policy
    chain output {
        type filter hook output priority filter; policy drop;
        ct state invalid drop comment \"Drop invalid connections\"
        oif \"lo\" accept comment \"Allow loopback traffic\"
        ct state established,related accept comment \"Allow established connections\"
        udp dport 51820 limit rate 8/second accept comment \"Mullvad WireGuard\"
        ip daddr { MULLVADIP1, MULLVADIP2, MULLVADIP3 } tcp dport 443 limit rate 4/second accept comment \"Mullvad control\"
        oif \"wg0-mullvad\" { udp dport 53, tcp dport 53 } ip daddr 100.64.0.23 limit rate 8/second accept comment \"Mullvad DNS\"
        oif \"wg0-mullvad\" tcp dport 443 limit rate 50/second accept comment \"HTTPS for browsing and Guix pull\"
        oif \"wg0-mullvad\" tcp dport 9418 limit rate 10/second accept comment \"Git for Guix pull\"
        oif \"wg0-mullvad\" { tcp dport 27015, udp dport 27015, tcp dport 27036, udp dport 27036 } ip daddr { 162.254.192.0/18, 146.66.152.0/21 } limit rate 20/second accept comment \"Steam gaming\"
        oif \"wg0-mullvad\" { tcp dport 6881-6890, udp dport 6881-6890 } limit rate 50/second accept comment \"Torrenting\"
        oif \"wg0-mullvad\" accept comment \"Fallback for all VPN traffic\"
        ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, X.254.0.0/16 } accept comment \"Local networks\"
        ip6 daddr { fe80::/10, fc00::/7 } accept comment \"IPv6 local networks\"
        log prefix \"DROPPED_OUTPUT: \" level warn limit rate 5/minute drop comment \"Log dropped output\"
    }
}")))

     ;; Blueman D-Bus Service
     ;; Provides D-Bus integration for Blueman Bluetooth manager
     (simple-service 'blueman
                     dbus-root-service-type
                     (list blueman))

     ;; Japanese Input Method Environment
     ;; Configures environment variables for Fcitx5 to support Japanese input
     ;; and integrates with GTK/Qt applications
     (simple-service
      'my-jp-ime-env
      session-environment-service-type
      '(("GTK_IM_MODULE" . "fcitx")              ; Set GTK input method to Fcitx
        ("QT_IM_MODULE" . "fcitx")               ; Set Qt input method to Fcitx
        ("GUIX_GTK2_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache") ; GTK2 input module cache
        ("GUIX_GTK3_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache") ; GTK3 input module cache
        ("XMODIFIERS" . "@im=fcitx")            ; X11 input method modifier
        ("INPUT_METHOD" . "fcitx")               ; Default input method
        ("XIM_PROGRAM" . "fcitx")                ; X11 input method program
        ("GLFW_IM_MODULE" . "ibus")              ; GLFW input method for compatibility
        ("QML_DISABLE_DISTANCEFIELD" . "1")      ; Disable QML distance field rendering
        ("QT_QUICK_CONTROLS_STYLE" . "Fusion")   ; Set Qt Quick Controls style
        ("QT_ENABLE_HIGHDPI_SCALING" . "0")      ; Disable Qt HiDPI scaling
        ("R600_TEX_ANISO" . "16")                ; Set anisotropic filtering for AMD GPUs
        ))

     ;; Mullvad VPN Service
     ;; Runs the Mullvad VPN daemon for secure, private networking via WireGuard
     (service mullvad-daemon-service-type)

     ;; Docker Services
     ;; Enables Docker and containerd for containerized applications
     (service docker-service-type)      ; Docker container platform
     (service containerd-service-type)  ; Container runtime for Docker

     ;; Nix Service
     ;; Integrates Nix package manager for reproducible environments
     (service nix-service-type)

     ;; Tor Service
     ;; Configures Tor for anonymous networking with SOCKS (9050) and TransPort (9040)
     ;; Includes safe logging and no exit node functionality
     (service tor-service-type
              (tor-configuration
               (config-file
                (plain-file "tor.conf"
                            "
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
     ;; Configures libvirt for virtual machine management with secure Unix socket
     ;; and TLS port
     (service
      libvirt-service-type
      (libvirt-configuration
       (unix-sock-group "libvirt")  ; Group for Unix socket access
       (tls-port "16555")))         ; TLS port for secure connections

     ;; ZRAM Device Service
     ;; Configures zRAM for compressed swap space (4GB) with zstd compression
     (service
      zram-device-service-type
      (zram-device-configuration
       (size (* 4 (expt 2 30)))     ; 4GB zRAM swap space
       (compression-algorithm 'zstd) ; Use zstd for compression
       (priority 100)))             ; Set swap priority

     ;; Xorg Configuration
     ;; Configures X11 display server with Brazilian keyboard layout
     (set-xorg-configuration
      (xorg-configuration
       (keyboard-layout keyboard-layout))) ; Use defined keyboard layout

     ;; Graphics Environment Variables
     ;; Sets environment variables for optimized graphics performance with AMD GPUs
     (simple-service
      'my-env-vars
      session-environment-service-type
      (list
       ;; GPU Rendering and Direct Rendering
       (cons "LIBGL_ALWAYS_SOFTWARE" "0")       ; Disable software rendering
       (cons "LIBGL_DRI3_ENABLE" "1")           ; Enable DRI3 for direct rendering
       (cons "VDPAU_DRIVER" "radeonsi")         ; Use radeonsi VDPAU driver for AMD
       (cons "DRI_PRIME" "1")                   ; Enable PRIME GPU offloading
       (cons "RADV_PERFTEST" "aco")             ; Use ACO shader compiler for performance

       ;; GTK/Qt Environment
       (cons "CLUTTER_BACKEND" "x11")           ; Use X11 for Clutter backend
       (cons "QT_QPA_PLATFORM" "xcb")           ; Use XCB for Qt platform
       (cons "QT_XCB_GL_INTEGRATION" "none")    ; Disable Qt GL integration
       (cons "QT_OPENGL" "desktop")             ; Use desktop OpenGL

       ;; GDK Environment
       (cons "GDK_BACKEND" "x11")               ; Use X11 for GDK backend
       (cons "GDK_GL" "egl")                    ; Use EGL for GDK GL backend
       (cons "GDK_SCALE" "1")                   ; Set GDK scaling to 1

       ;; Firefox Optimization
       (cons "MOZ_X11_EGL" "1")                 ; Enable EGL rendering for Firefox
       (cons "MOZ_ENABLE_WAYLAND" "0")          ; Disable Wayland for Firefox
       (cons "MOZ_WEBRENDER" "1")               ; Enable WebRender for GPU acceleration
      ))
    )
    %desktop-services))

  ;; Bootloader Configuration
  ;; Configures GRUB bootloader with a custom theme and 1920x1080 resolution
  (bootloader
   (bootloader-configuration
    (bootloader grub-bootloader)               ; Use GRUB bootloader
    (targets (list "/dev/nvme0n1"))            ; Boot from NVMe drive
    (theme
     (grub-theme
      (resolution '(1920 . 1080))              ; Set GRUB resolution
      (image (local-file "cute-cat.png")))))) ; Custom background

  ;; Swap Space
  ;; Defines swap space with a specific UUID and priority
  (swap-devices
   (list
    (swap-space
     (priority 50)                             ; Set swap priority
     (target (uuid "SWAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP"))))) ; Swap partition UUID

  ;; File Systems
  ;; Defines mounted filesystems, including EFI, root, and additional partitions
  (file-systems
   (cons*
    (file-system
     (mount-point "/boot/efi")                 ; EFI system partition
     (device (uuid "02E2-0AB2" 'fat32))        ; UUID for EFI partition
     (type "vfat"))                            ; Filesystem type
    (file-system
     (mount-point "/")                         ; Root filesystem
     (device (uuid "ROOTS BLOODY ROOTS!" 'ext4)) ; Root UUID
     (type "ext4"))                            ; Filesystem type
    (file-system
     (mount-point "/files")                    ; Additional data partition
     (device (uuid "BACKUP IS IMPORTANT!" 'ext4)) ; Partition UUID
     (type "ext4"))                            ; Filesystem type
    (file-system
     (mount-point "/mnt/games")                ; Partition for games
     (device (uuid "BECAUSE I NEED IT TOO" 'ext4)) ; Partition UUID
     (type "ext4"))                            ; Filesystem type
    %base-file-systems)))                      ; Include base filesystems
