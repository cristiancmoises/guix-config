;; -*- mode: scheme; -*-
;; Guix System Configuration for Host "securityops"
;; Hardware: Acer Predator Helios Neo 16 (PHN16-71)
;;   CPU : Intel Core i7-13700HX  (8 P-cores + 8 E-cores, 24 threads, Raptor Lake-HX)
;;   GPU : NVIDIA GeForce RTX 4060 Laptop (Ada, AD107) + Intel UHD iGPU (Optimus/MUX)
;;   RAM : 16 GiB   NVMe: 1 TB (Intel VMD enabled in firmware)
;;   Disk: LUKS2 full-disk encryption (cryptroot + crypthome)
;;
;; PRESERVED VERBATIM from the installed laptop config: bootloader, ESP, the two
;; LUKS mapped-devices, the encrypted file-systems, and the "vmd" initrd module.
;;
;; PERF (2026-06-08): CPU pacing changed from a pinned 'performance' governor to
;; intel_pstate 'powersave' + EPP balance_performance (laptop thermals); plus
;; init_on_free=0 and numa_balancing=disable on the cmdline. See the CPU-pacing
;; service and the kernel-arguments block.
;;
;; Apply:
;;   sudo guix system reconfigure /etc/config.scm
;;
;; Maintainer: Cristian Cezar Moisés
;; Last Updated: June 08, 2026

;;; ──────────────────────────────────────────────────────────────────────────
;;; Module Imports
;;; ──────────────────────────────────────────────────────────────────────────
(use-modules
 (gnu)
 (gnu system)
 (gnu system locale)
 (guix download)
 (guix utils)
 (guix build-system gnu)
 (guix gexp)
 (guix store)
 (guix packages)
 (guix transformations)
 (guix git-download)
 (guix channels)
 (srfi srfi-1)

 ;; Display / GPU
 (gnu services xorg)             ; %default-xorg-modules, set-xorg-configuration
 (gnu packages gl)
 (gnu packages vulkan)
 (gnu packages graphics)         ; mangohud
 (gnu packages xorg)
 (gnu packages xdisorg)
 (gnu packages compton)

 ;; NVIDIA (nonguix)
 (nongnu packages nvidia)        ; nvidia-driver, nvda
 (nongnu services nvidia)        ; nvidia-service-type
 (nonguix transformations)       ; nonguix-transformation-nvidia, replace-mesa

 ;; Kernel / firmware / initrd (nonguix)
 (gnu packages linux)            ; igt-gpu-tools, linux-libre-headers, etc.
 (nongnu packages linux)         ; linux (stable, blob-enabled)
 (nongnu system linux-initrd)    ; microcode-initrd
 (gnu packages firmware)

 ;; Shells / terminals / editors
 (gnu packages shells)
 (gnu packages terminals)
 (gnu packages emacs)
 (gnu packages emacs-xyz)
 (gnu packages vim)

 ;; Languages / toolchains
 (gnu packages gcc)
 (gnu packages commencement)
 (gnu packages rust)
 (gnu packages rust-apps)
 (gnu packages golang)
 (gnu packages python)
 (gnu packages python-xyz)
 (gnu packages python-build)
 (gnu packages haskell)
 (gnu packages haskell-apps)
 (gnu packages haskell-xyz)
 (gnu packages node)
 (nongnu packages node)
 (nongnu packages benchmark)
 (gnu packages lisp)
 (gnu packages lisp-xyz)
 (gnu packages guile-xyz)
 (gnu packages zig-xyz)
 (gnu packages java)
 (gnu packages cmake)
 (gnu packages build-tools)
 (gnu packages ninja)
 (gnu packages version-control)

 ;; Browsers / desktop apps
 (gnu packages web)
 (gnu packages web-browsers)
 (gnu packages gnuzilla)
 (gnu packages librewolf)
 (nongnu packages chrome)
 (gnu packages tor-browsers)
 (gnu packages telegram)
 (gnu packages messaging)
 (gnu packages jami)

 ;; Window manager / suckless
 (gnu packages freedesktop)
 (gnu packages wm)
 (gnu packages suckless)

 ;; Security / crypto / net
 (gnu packages apparmor)
 (gnu packages acct)
 (gnu packages admin)
 (gnu packages security-token)
 (gnu packages gnupg)
 (gnu packages password-utils)
 (gnu packages tls)
 (gnu packages networking)
 (gnu packages dns)
 (gnu packages ntp)
 (gnu packages tor)
 (gnu packages vpn)
 (small-guix packages mullvad)
 (gnu packages curl)
 (gnu packages ssh)
 (gnu packages antivirus)

 ;; Virtualisation / containers
 (gnu packages virtualization)
 (gnu packages docker)
 (gnu packages containers)

 ;; Disks / filesystems
 (gnu packages disk)
 (gnu packages file-systems)

 ;; Multimedia / audio
 (gnu packages image-viewers)
 (gnu packages audio)
 (gnu packages pulseaudio)
 (gnu packages mpd)
 (gnu packages music)
 (gnu packages video)
 (nongnu packages video)
 (gnu packages gstreamer)

 ;; Monitoring / utilities
 (gnu packages monitoring)       ; btop, glances
 (gnu packages hardware)
 (gnu packages ncdu)
 (gnu packages compression)
 (nongnu packages compression)
 (gnu packages sqlite)
 (gnu packages base)
 (gnu packages ncurses)

 ;; Input methods
 (gnu packages fcitx5)
 (gnu packages ibus)

 ;; Misc package providers used by the old config
 (radix packages linux)          ; bustd
 (radix packages xdisorg)
 (nongnu packages game-client)   ; steam
 (gnu packages package-management)
 (gnu packages fonts)
 (gnu packages fontutils)

 ;; Services
 (gnu services)
 (gnu services base)
 (gnu services desktop)
 (gnu services networking)
 (gnu services ssh)
 (gnu services cups)
 (gnu services vpn)
 (gnu services dbus)
 (gnu services docker)
 (gnu services linux)
 (gnu services sysctl)
 (gnu services virtualization)
 (gnu services certbot)
 (gnu services mcron)
 (gnu services shepherd)
 (gnu services herd)
 (gnu services admin)
 (gnu services pm)               ; thermald-service-type
 (small-guix services mullvad)
 (gnu system shadow))

(use-service-modules
 base desktop networking ssh xorg cups docker linux virtualization
 sysctl security nix)

(use-package-modules
 bootloaders certs linux)

;;; ──────────────────────────────────────────────────────────────────────────
;;; OPTIONAL: custom hardened kernel (DISABLED). See README — incompatible with
;;; the prebuilt proprietary NVIDIA module. Left here for a nouveau-only future.
;;; ──────────────────────────────────────────────────────────────────────────
 (define-public securityops
   (package
     (inherit linux)
     (name "securityops")
     (version "7.0.11")
     (source (origin
               (method url-fetch)
               (uri "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.0.11.tar.xz")
               (sha256 (base32 "012307ni1v555a1rgzsxsg99pj8fplrghvhw0jk3c4d0vmb86v75"))))
     (arguments
      (substitute-keyword-arguments (package-arguments linux)
        ((#:defconfig _) (list (local-file "/etc/securityops.defconfig")))
        ((#:phases phases) phases)))))

;;; ──────────────────────────────────────────────────────────────────────────
;;; Keyboard layout (build once; the field name shadows the constructor inside records)
(define %kbd (keyboard-layout "br" "abnt2"))

;;; Session environment: NVIDIA + Intel GLX/EGL/VAAPI
;;; ──────────────────────────────────────────────────────────────────────────
(define gpu-env-service
  (simple-service
   'gpu-env-vars
   session-environment-service-type
   '(("LIBGL_DRI3_ENABLE"          . "1")
     ("__GLX_VENDOR_LIBRARY_NAME"  . "nvidia")
     ("GBM_BACKEND"                . "nvidia-drm")
     ("MOZ_X11_EGL"                . "1")
     ("MOZ_WEBRENDER"              . "1")
     ("MOZ_ENABLE_WAYLAND"         . "0")
     ("CLUTTER_BACKEND"            . "x11")
     ("GDK_BACKEND"                . "x11")
     ("QT_QPA_PLATFORM"            . "xcb")
     ("QT_XCB_GL_INTEGRATION"      . "xcb_glx")
     ("QT_OPENGL"                  . "desktop"))))

;;; ──────────────────────────────────────────────────────────────────────────
;;; Operating system
;;; ──────────────────────────────────────────────────────────────────────────
(define %securityops-os
 (operating-system

  ;; ── Kernel: nonguix `linux` (7.0.x). REQUIRED for the prebuilt NVIDIA
  ;; module to load — the custom `securityops` kernel mismatches it. ──
  (kernel linux)
  (kernel-arguments
   '("quiet"
     "splash"
     ;; Speculative-execution mitigations (mitigations=on auto-applies what
     ;; Raptor Lake needs; nosmt dropped for full SMT performance).
     ;; PERF: mitigations are the biggest CPU cost on syscall/context-switch-heavy
     ;; desktop work. For max speed (security cost) use just "mitigations=off"
     ;; instead of the mitigation lines below (Raptor Lake ~5-15%). Not by default.
     "mitigations=on"
     "spectre_v2=on"
     "spec_store_bypass_disable=on"
     "tsx=off"
     ;; Memory safety
     "slab_nomerge"
     "page_alloc.shuffle=1"
     "init_on_alloc=1"
     "init_on_free=0"            ; was =1 (KSPP) — =0 recovers alloc/free latency
     "randomize_kstack_offset=on"
     "vsyscall=none"
     ;; IOMMU / DMA (Intel)
     "intel_iommu=on"
     "iommu=pt"
     ;; LSM (no lockdown -> NVIDIA can load)
     "lsm=landlock,yama,apparmor"
     "apparmor=1"
     "security=apparmor"
     ;; CPU frequency / scheduler
     "intel_pstate=active"
     "preempt=full"
     "transparent_hugepage=madvise"
     "numa_balancing=disable"    ; single-node laptop: no periodic NUMA scan stalls
     ;; Entropy / reliability
     "random.trust_cpu=off"
     "mce=1"
     ;; NVIDIA (proprietary). nvidia_drm.modeset=1 is injected by
     ;; nonguix-transformation-nvidia (bottom of file); not duplicated here.
     "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
     ;; Attack-surface reduction + block nouveau
     "modprobe.blacklist=nouveau,firewire_core,firewire_ohci,dccp,sctp,rds,tipc"))

  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  (locale "pt_BR.UTF-8")
  (locale-definitions
   (list (locale-definition (name "pt_BR.UTF-8") (source "pt_BR"))
         (locale-definition (name "en_US.UTF-8") (source "en_US"))))
  (timezone "America/Sao_Paulo")
  (keyboard-layout %kbd)
  (host-name "securityops")        ; installer named it "matrix"

  ;; ── Users ──
  (users
   (cons*
    (user-account
     (name "berkeley")
     (comment "berkeley")
     (group "users")
     (home-directory "/home/berkeley")
     (supplementary-groups
      '("wheel" "input" "docker" "kvm" "libvirt" "netdev"
        "audio" "video" "plugdev")))
    %base-user-accounts))

  ;; plugdev is referenced above but is NOT in %base-groups; define it.
  (groups
   (cons (user-group (name "plugdev") (system? #t))
         %base-groups))

  ;;; ────────────────────────────────────────────────────────────────────────
  ;;; Packages
  ;;; ────────────────────────────────────────────────────────────────────────
  (packages
   (append
    ;; For MullvadVPN
    (list openresolv)

    ;; Browsers & apps
    (list librewolf
          icecat
          steam-nvidia)          ; NVIDIA-aware Steam FHS container (nonguix)

    ;; GPU userspace + display (Intel iGPU via Mesa, NVIDIA via nvda)
    (list mesa
          mesa-headers
          libva
          libva-utils
          intel-media-driver          ; iHD VAAPI for the Intel iGPU
          igt-gpu-tools
          vulkan-tools
          vulkan-loader
          nvda                         ; nvidia-smi / nvidia-settings
          linux-firmware
          ;; Wayland bits (secondary; Xmonad/X11 is primary)
          sway
          waybar
          wl-clipboard
          swayidle
          swaylock
          xorg-server-xwayland
          brightnessctl
          openrgb)

    ;; Gaming: performance + overlays (use per-game: gamemoderun / MANGOHUD=1)
    (list gamemode               ; CPU governor + niceness + GPU perf during games
          mangohud               ; FPS / frametime / GPU+CPU overlay
          vkbasalt)              ; optional Vulkan post-processing (CAS sharpen)

    ;; X utilities + dual-monitor management
    (list xkill
          setxkbmap
          xmodmap
          xdg-utils
          xrandr
          arandr                       ; GUI to lay out the 2 monitors
          autorandr                    ; auto-apply layout on hotplug
          xmonad
          ghc-xmonad-contrib)

    ;; File & disk management
    (list lf
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
          ueberzugpp
          e2fsprogs
          xfsprogs)

    ;; Development / build essentials
    (list emacs
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
          alacritty
          kitty
          foot
          fish
          bat
          zoxide
          fastfetch
          pfetch)

    ;; Security / VPN / cryptography
    (list apparmor
          acct
          ansible
          audit
          sysstat
          lynis
          nftables
          clamav
          gnupg
          libfido2
          firejail
          openvpn
          tor
          torsocks
          nmap
          wireshark
          tcpdump
          openssl
          keepassxc
          hashcat
          openssh)

    ;; Virtualisation / containers
    (list qemu
          virt-manager
          docker
          runc
          podman
          containerd)

    ;; System monitoring & utilities (radeontop -> nvidia-smi via nvda)
    (list htop
          btop
          glances
          inxi
          lm-sensors
          net-tools
          fping
          netdiscover
          whois
          macchanger
          procps
          sqlite
          coreutils
          findutils
          grep
          sed
          jq
          nix)

    ;; Audio (system level)
    (list alsa-lib
          alsa-utils
          pulseaudio
          pipewire
          wireplumber)

    ;; Fonts
    (list font-iosevka-term
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
          font-sarasa-gothic
          font-aporetic
          font-adwaita)

    %base-packages))

  ;;; ────────────────────────────────────────────────────────────────────────
  ;;; Services
  ;;; ────────────────────────────────────────────────────────────────────────
  (services
   (append
    ;; %desktop-services, but force GDM onto Xorg with the NVIDIA driver.
    (modify-services %desktop-services
      (gdm-service-type config =>
       (gdm-configuration
        (inherit config)
        (wayland? #f)
        (xorg-configuration
         (xorg-configuration
          (keyboard-layout %kbd)
          (modules (cons nvidia-driver %default-xorg-modules))
          (drivers '("nvidia"))))))
      ;; NetworkManager manages /etc/resolv.conf so Mullvad can set DNS through
      ;; it (Mullvad's Linux DNS path goes via NM). Put the NextDNS servers on
      ;; your NM connection (see notes) so DNS = NextDNS whenever the VPN is off.
      (network-manager-service-type config =>
       (network-manager-configuration
        (inherit config)
        (dns "default")))
      ;; Extend the sysctl service %desktop-services already provides
      ;; (a second instance triggers "service 'sysctl' provided more than once").
      (sysctl-service-type config =>
       (sysctl-configuration
        (inherit config)
        (settings
         (append
          '(("kernel.kptr_restrict"             . "2")
            ("kernel.dmesg_restrict"            . "1")
            ("kernel.yama.ptrace_scope"         . "2")
            ("kernel.unprivileged_bpf_disabled" . "1")
            ("net.core.bpf_jit_harden"          . "2")
            ("net.ipv4.tcp_congestion_control"  . "bbr")
            ("net.core.default_qdisc"           . "fq_codel")
            ("net.ipv4.conf.all.rp_filter"      . "1")
            ("net.ipv4.conf.default.rp_filter"  . "1")
            ("net.ipv6.conf.all.accept_redirects" . "0")
            ("net.ipv4.conf.all.accept_redirects" . "0")
            ("net.ipv4.conf.all.send_redirects"   . "0"))
          (sysctl-configuration-settings config))))))

    (list
     ;; NVIDIA proprietary stack (configured driver/module/firmware/powerd) is
     ;; added by nonguix-transformation-nvidia at the bottom of this file.

     ;; Remote login (firewalled off below; defence in depth).
     (service openssh-service-type)

     ;; Printing.
     (service cups-service-type)

     ;; GPU env vars (NVIDIA/Intel).
     gpu-env-service

     ;; ── Performance / thermal (gaming) ──────────────────────────────────
     ;; Intel thermald: manage Raptor Lake-HX thermals under sustained load
     ;; (RAPL + INT340X zones) so CPU/GPU keep boosting instead of throttling.
     (service thermald-service-type)

     ;; CPU pacing for a thermally-limited laptop. A *pinned* performance governor
     ;; keeps every core at max clocks; on this chassis that feeds the
     ;; heat -> thermald-clamp -> stutter loop. intel_pstate stays in 'powersave'
     ;; (active mode STILL boosts to full turbo under load) with EPP
     ;; 'balance_performance' = fast ramp, cooler idle, smoother response.
     ;; Want max clocks on AC (only if temps allow)? balance_performance -> performance.
     (simple-service 'cpu-epp-balanced shepherd-root-service-type
       (list (shepherd-service
              (provision '(cpu-epp-balanced))
              (requirement '(udev))
              (start #~(make-forkexec-constructor
                        '("/bin/sh" "-c"
                          "for c in /sys/devices/system/cpu/cpu*/cpufreq; do echo powersave > \"$c/scaling_governor\" 2>/dev/null; echo balance_performance > \"$c/energy_performance_preference\" 2>/dev/null; done; true")))
              (stop #~(make-kill-destructor))
              (auto-start? #t))))

     ;; /dev/ntsync rootless so Proton's PROTON_USE_NTSYNC=1 works (kernel 7.0).
     (simple-service 'ntsync-perms udev-service-type
       (list (udev-rule "70-ntsync.rules"
                        "KERNEL==\"ntsync\", MODE=\"0660\", TAG+=\"uaccess\"\n")))

     ;; Fail2Ban.
     (service fail2ban-service-type)

     ;; AIDE file-integrity (manual run).
     (simple-service 'aide shepherd-root-service-type
       (list (shepherd-service
              (provision '(aide))
              (start #~(make-forkexec-constructor
                        '("/bin/sh" "-c"
                          "/run/current-system/profile/bin/aide --config=/etc/aide.conf --check")))
              (stop #~(make-kill-destructor))
              (auto-start? #f))))

     ;; mlocate updatedb (manual run).
     (simple-service 'mlocate shepherd-root-service-type
       (list (shepherd-service
              (provision '(mlocate))
              (start #~(make-forkexec-constructor
                        '("/run/current-system/profile/bin/updatedb")))
              (stop #~(make-kill-destructor))
              (auto-start? #f))))

     ;; Tighten /home and /var/lib/aide perms at boot.
     (simple-service 'file-permissions shepherd-root-service-type
       (list (shepherd-service
              (provision '(file-permissions))
              (start #~(make-forkexec-constructor
                        '("/bin/sh" "-c"
                          "chmod 751 /home && chmod 750 /var/lib/aide")))
              (stop #~(make-kill-destructor))
              (auto-start? #t))))

     ;; Bluetooth.
     (service bluetooth-service-type
              (bluetooth-configuration (auto-enable? #t)))

     ;; USB authorisation udev rule (simple-service form; version-stable).
     (simple-service 'device-authorization udev-service-type
       (list (udev-rule "99-device-authorize.rules"
                        "SUBSYSTEM==\"usb\", ATTR{authorized}=\"1\"\n")))

     ;; ───────────────────────────────────────────────────────────────────
     ;; NFTABLES — stateful desktop firewall (NOT a VPN kill-switch).
     ;; Outbound is allowed so internet + DHCP + NextDNS + the Mullvad
     ;; handshake all work whether or not the tunnel is up. Inbound accepts
     ;; only replies to our own connections + loopback + ICMP + DHCP; no
     ;; services are exposed. Want a kill-switch? Use Mullvad's own:
     ;;   mullvad lockdown-mode set on   (blocks ALL traffic while VPN is off,
     ;;   including NextDNS — so leave it OFF for your use case).
     ;; ───────────────────────────────────────────────────────────────────
     (service nftables-service-type
       (nftables-configuration
        (ruleset
         (plain-file "nftables.conf"
"flush ruleset

table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;
        ct state invalid drop
        ct state established,related accept
        iif \"lo\" accept
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept
        udp dport 68 accept
        udp dport 546 accept
        log prefix \"DROP_IN: \" level warn limit rate 3/minute drop
    }

    chain forward {
        type filter hook forward priority filter; policy drop;
        ct state invalid drop
        ct state established,related accept
        iif \"wg0-mullvad\" accept
        oif \"wg0-mullvad\" accept
    }

    chain output {
        type filter hook output priority filter; policy accept;
    }
}"))))

     ;; Blueman D-Bus integration.
     (simple-service 'blueman dbus-root-service-type (list blueman))

     ;; Fcitx input-method environment.
     (simple-service 'jp-ime-env session-environment-service-type
       '(("GTK_IM_MODULE" . "fcitx")
         ("QT_IM_MODULE"  . "fcitx")
         ("GUIX_GTK2_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache")
         ("GUIX_GTK3_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache")
         ("XMODIFIERS" . "@im=fcitx")
         ("INPUT_METHOD" . "fcitx")
         ("XIM_PROGRAM" . "fcitx")
         ("GLFW_IM_MODULE" . "ibus")
         ("QML_DISABLE_DISTANCEFIELD" . "1")
         ("QT_QUICK_CONTROLS_STYLE" . "Fusion")
         ("QT_ENABLE_HIGHDPI_SCALING" . "0")))

     ;; Mullvad VPN daemon
     (service mullvad-daemon-service-type)

     ;; Containers.
     (service docker-service-type)
     (service containerd-service-type)

     ;; Nix.
     (service nix-service-type)

     ;; Tor (transparent proxy ports).
     (service tor-service-type
       (tor-configuration
        (config-file
         (plain-file "torrc"
"Log notice stderr
DataDirectory /var/lib/tor

SOCKSPort 127.0.0.1:9050
ControlPort 9051
TransPort 9040
DNSPort 5353

VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
ExitPolicy reject *:*
SafeLogging 1
DisableDebuggerAttachment 1
"))))

     ;; libvirt.
     (service libvirt-service-type
              (libvirt-configuration
               (unix-sock-group "libvirt")
               (tls-port "16555")))

     ;; zRAM swap (the laptop has NO swap partition; this replaces it).
     (service zram-device-service-type
              (zram-device-configuration
               (size (* 8 (expt 2 30)))     ; 8 GiB (you have 16 GiB RAM)
               (compression-algorithm 'zstd)
               (priority 100))))))

  ;;; ────────────────────────────────────────────────────────────────────────
  ;;; PRESERVED VERBATIM FROM THE INSTALLED LAPTOP CONFIG — DO NOT EDIT.
  ;;; ────────────────────────────────────────────────────────────────────────
  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets (list "/boot/efi"))
    (keyboard-layout %kbd)))

  ;; Intel VMD-backed NVMe: "vmd" is REQUIRED to find the encrypted root.
  (initrd-modules (append '("vmd") %base-initrd-modules))

  (mapped-devices
   (list (mapped-device
          (source (uuid "9f72b7c5-51da-4582-8a95-7dfe68eeadde"))
          (target "cryptroot")
          (type luks-device-mapping))
         (mapped-device
          (source (uuid "70b74c08-85cd-4161-9fb6-4b2eaacedaed"))
          (target "crypthome")
          (type luks-device-mapping))))

  (file-systems
   (cons* (file-system
            (mount-point "/boot/efi")
            (device (uuid "6447-6147" 'fat32))
            (type "vfat"))
          (file-system
            (mount-point "/")
            (device "/dev/mapper/cryptroot")
            (type "ext4")
            (dependencies mapped-devices))
          (file-system
            (mount-point "/home")
            (device "/dev/mapper/crypthome")
            (type "ext4")
            (dependencies mapped-devices))
          %base-file-systems))))

;;; ──────────────────────────────────────────────────────────────────────────
;;; Apply the Nonguix NVIDIA transformation to the WHOLE system:
;;;   * grafts mesa -> nvda-580 across every package + service closure, so
;;;     Steam/pressure-vessel and all GL/Vulkan apps use the RTX 4060;
;;;   * adds the configured nvidia-service-type (driver/module/firmware
;;;     580.159.04 — matches the running kernel module, so no rebuild);
;;;   * enables Dynamic Boost (laptop CPU<->GPU power sharing) via nvidia-powerd;
;;;   * injects nvidia_drm.modeset=1 + nouveau/nova blacklist on the cmdline.
;;; nvda-580 is pinned on purpose: it is byte-for-byte the driver matching the
;;; kernel module already loaded (nvidia-smi: 580.159.04).
;;; ──────────────────────────────────────────────────────────────────────────
((nonguix-transformation-nvidia
   #:driver nvda-580
   #:dynamic-boost? #t)
 %securityops-os)
