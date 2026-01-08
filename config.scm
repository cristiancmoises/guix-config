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
;; Last Updated: January 03, 2026

;;; Module Imports
;; Import required Guix modules for package and service definitions
(use-modules
 (gnu)                         ; Core Guix module for system and package management
 (gnu system)
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
 (gnu packages llvm)           ; LLVM compiler infrastructure packages
 (gnu packages vulkan)         ; Vulkan graphics API packages
 (gnu packages gnome)          ; GNOME desktop environment packages
 (gnu packages firmware)       ; Firmware packages
 (gnu packages i2p)           ; I2P anonymous network packages
 (gnu packages telegram)
 (gnu packages ncdu)
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
 (radix packages linux)        ; Bustd
 (radix packages admin)
 (gnu packages ntp)
 (gnu packages dns)
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
 (gnu packages monitoring)
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
    (version "6.18.4") 
    (source (origin
              (method url-fetch)
              (uri "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.4.tar.xz") ;;  :)
              (sha256
               (base32 "1asza9m4vb7lghxaiy5fpnbwmb9a44pgjclbpgv1p77plnf16l7q"))))
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
 '("quiet"                          ; minimize boot messages
   "splash"                         ; show graphical boot splash
   "noatime"                        ; disable access time updates (perf + SSD life)
   "mitigations=auto"               ; apply all available CPU vulnerability mitigations
   "nosmt"                          ; disable SMT (hyper-threading) – strongest Spectre/MDS protection
   "amd_iommu=on"                   ; enable AMD IOMMU for DMA protection
   "iommu=pt"                       ; IOMMU passthrough mode (performance + security)
   "lsm=yama,apparmor,integrity,lockdown,landlock" ; strict LSM order
   "apparmor=1"                     ; force AppArmor activation
   "security=apparmor"              ; set AppArmor as primary security module
   "lockdown=confidentiality"       ; strongest kernel lockdown mode
   "module.sig_enforce=1"           ; require all modules to be signed
   "slab_nomerge"                   ; prevent slab cache merging (heap isolation)
   "page_alloc.shuffle=1"           ; randomize page allocator freelist
   "init_on_alloc=1"                ; zero memory on allocation (use-after-free protection)
   "init_on_free=1"                 ; zero memory on free (use-after-free protection)
   "kptr_restrict=2"                ; hide all kernel pointers from unprivileged users
   "randomize_kstack_offset=on"     ; randomize kernel stack offset (stack clash mitigation)
   "vsyscall=none"                  ; disable legacy vsyscall page (attack surface reduction)
   "preempt=full"                   ; full kernel preemption (best responsiveness)
   "amd_pstate=active"              ; enable modern AMD P-state driver
   "tcp_congestion_control=bbr"     ; use BBR TCP congestion control (best performance)
   "net.core.default_qdisc=fq_codel" ; fair queuing + CoDel (low latency network)
   "random.trust_cpu=off"           ; do not trust CPU hardware RNG (extra entropy caution)
   "spec_store_bypass_disable=prctl" ; Spectre v4 mitigation
   "mce=1"                          ; Machine Check Exception handling
   "amdgpu.sched_policy=2"          ; High-priority AMD GPU scheduling
   "amdgpu.abmlevel=0"              ; Disable Adaptive Backlight
   "amdgpu.backlight=0"             ; Disable backlight control
   "h264_amf=1"                     ; H.264 encoding
   "irqaffinity=1-3"                ; IRQs on CPUs 1-3
   "cpufreq.default_governor=schedutil" ; Schedutil scaling
   "rcu_nocbs=0-3"                  ; Offload RCU from all CPUs
   "noirqdebug"                     ; Disable IRQ debugging
   "watchdog"                       ; Hardware watchdog
   "noreplace-smp"                  ; Prevent SMP code replacement
   "modprobe.blacklist=firewire_core,firewire_ohci,dccp,sctp,rds,tipc" ; Blacklist dangerous modules
   ))

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
  (list openresolv)
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
   bustd
   xdpyinfo
   xset
   xwininfo
   xprop
   xpra
   xkill
   setxkbmap
   xmodmap
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
   ncdu
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
   emacs
   tdlib
   emacs-telega
   emacs-org
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

  ;; Fail2Ban
  (service fail2ban-service-type)
  ;; AIDE Service for File Integrity 
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

;; =============================================================================
;; NFTABLES - STRICT
;; =============================================================================
(service nftables-service-type
  (nftables-configuration
    (ruleset
      (plain-file "nftables.conf"
"flush ruleset

table inet filter {
    chain antispoof {
        # Anti-spoofing
        ip saddr 127.0.0.0/8 iif != lo drop
        ip6 saddr ::1 iif != lo drop
        ip saddr 0.0.0.0/8 drop
        ip6 saddr ::/128 drop
        log prefix \"SPOOFED_INPUT: \" level warn limit rate 5/minute drop
    }

    chain input {
        type filter hook input priority filter; policy drop;

        jump antispoof

        # Established/invalid
        ct state invalid drop
        ct state established,related accept

        # Loopback
        iif \"lo\" accept

        # Mullvad WireGuard
        udp dport 51820 accept

        # Mullvad control servers (TCP 443)
        ip saddr {$MULLVADIP} tcp sport 443 ct state established accept

        # Tor daemon local ports
        tcp dport {9050,9040,5353} iif \"lo\" accept
        udp dport 5353 iif \"lo\" accept

        # ICMP / ICMPv6 essential
        ip protocol icmp icmp type { echo-request, destination-unreachable, time-exceeded } accept
        ip6 nexthdr ipv6-icmp icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert, echo-request, destination-unreachable, time-exceeded } accept

        # Log everything else
        log prefix \"DROPPED_INPUT: \" level warn limit rate 5/minute drop
    }

    chain forward {
        type filter hook forward priority filter; policy drop
        ct state invalid drop
        ct state established,related accept
        iif \"wg0-mullvad\" accept
        oif \"wg0-mullvad\" accept
        log prefix \"DROPPED_FORWARD: \" level warn limit rate 5/minute drop
    }

    chain output {
        type filter hook output priority filter; policy drop
        ct state invalid drop
        ct state established,related accept

        # Loopback
        oif \"lo\" accept

        # Mullvad VPN
        oif \"wg0-mullvad\" accept
        udp dport 51820 accept  # WireGuard

        # Mullvad DNS
        oif \"wg0-mullvad\" { udp dport 53, tcp dport 53 } ip daddr 100.64.0.23 accept

        # Mullvad control servers
        ip daddr {$MULLVADIP} tcp dport 443 accept

        # Tor local ports
        oif \"lo\" tcp dport {9050,9040,5353} accept
        oif \"lo\" udp dport 5353 accept

        # Tor outgoing for directory & bridges
        oif != \"wg0-mullvad\" tcp dport {443,9001} accept

        # Custom DNS (NextDNS)
        meta l4proto {tcp, udp} th dport 53 ip daddr {45.90.28.213,45.90.30.213} accept
        meta l4proto {tcp, udp} th dport 53 ip6 daddr {2a07:a8c0::c9:678a,2a07:a8c1::c9:678a} accept

        # Steam ports
        oif \"wg0-mullvad\" { tcp dport 27014-27050, udp dport 27000-27150 } accept
        oif \"wg0-mullvad\" udp dport {3478,4379,4380} accept

        # Torrent ports
        oif \"wg0-mullvad\" tcp dport 6881-6999 accept
        oif \"wg0-mullvad\" udp dport 6881-6999 accept

        # Allow local networks
        ip daddr {10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16} accept
        ip6 daddr {fe80::/10,fc00::/7} accept

        # Log everything else
        log prefix \"DROPPED_OUTPUT: \" level warn limit rate 5/minute drop
    }
}"))))



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
      (plain-file "tor.conf"
"# Tor config - Minimal working daemon for Tor Browser
Log notice file /var/log/tor/tor.log
DataDirectory /var/lib/tor
SOCKSPort 127.0.0.1:9050
TransPort 9040
DNSPort 5353
AutomapHostsOnResolve 1
ExitPolicy reject *:*
SafeLogging 1
DisableDebuggerAttachment 1
ControlPort 9051
DisableNetwork 0"))))


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
      (image (local-file "/home/berkeley/Photos/wallpaper.png"))))))
  
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

