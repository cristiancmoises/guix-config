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
;; DISPLAY STACK (2026-06-21): this is the **Sway (Wayland)** variant. It drops
;; the XLibre X server + SLiM display manager (kept in config-xlibre.scm) and
;; replaces them with Sway driven by the greetd login manager (text greeter →
;; sway). The laptop is MUX'd to the discrete NVIDIA RTX 4060 (the Intel iGPU is
;; off — lspci shows only NVIDIA), so wlroots must drive the proprietary GPU:
;; sway is launched with --unsupported-gpu and NVIDIA-Wayland env (see
;; %sway-session-env + the greetd service). nvidia_drm.modeset=1 (required for
;; the GBM path) is injected by nonguix-transformation-nvidia at the foot of the
;; file. Everything else (kernel, security hardening, firewall, Tor, Mullvad,
;; zram, tmpfs /tmp, audio firmware) is identical to the XLibre variant.
;;
;; PERF (2026-06-08): CPU pacing changed from a pinned 'performance' governor to
;; intel_pstate 'powersave' + EPP balance_performance (laptop thermals); plus
;; init_on_free=0 and numa_balancing=disable on the cmdline. See the CPU-pacing
;; service and the kernel-arguments block.
;;
;; Apply (from a physical TTY — reconfigure restarts the login manager and drops
;; the running graphical session; if Sway fails to start you fall back to a TTY):
;;   sudo guix system reconfigure /etc/config.scm
;;
;; Maintainer: Cristian Cezar Moisés
;; Last Updated: June 21, 2026 (Sway/greetd variant)

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
 (gnu services xorg)             ; retained only for gdm-service-type (deleted from %desktop-services below)
 (gnu packages gl)
 (gnu packages vulkan)
 (gnu packages graphics)         ; mangohud
 (gnu packages xorg)
 (gnu packages xdisorg)
 (gnu packages compton)
 ;; (xlibre) removed — the Sway variant uses no X server. See config-xlibre.scm
 ;; for the XLibre + SLiM stack.

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

 ;; securityops channel — latest-version overrides for the curated apps:
 ;;   kitty 0.47.4 (gnu 0.46.2), tor 0.4.9.9 (gnu 0.4.9.8),
 ;;   mullvad-vpn-desktop 2026.3 (small-guix 2025.8).  Prefixed `so:' so the
 ;;   bare gnu/small-guix bindings stay available; only the so:… symbols below
 ;;   are switched to the channel.
 ((securityops packages terminals) #:prefix so:)   ; so:kitty
 ((securityops packages tor)       #:prefix so:)   ; so:tor
 ((securityops packages vpn)       #:prefix so:)   ; so:mullvad-vpn-desktop
 ((securityops packages browsers)  #:prefix so:)   ; so:librewolf 152.0.1-2 (gnu 151.0.4-1)
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
 (gnu packages image)            ; grim, slurp (Wayland screenshots)
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
 (securityops services torando)  ; torando-gui-service-type (Shepherd)
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
     (version "7.1.1")
     (source (origin
               (method url-fetch)
               (uri "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.1.1.tar.xz")
               (sha256 (base32 "0z8x6wafxzc5vkim9jh8wpycdkk9y5bpxgsirmdpyznw84szl5aj"))))
     (arguments
      (substitute-keyword-arguments (package-arguments linux)
        ((#:defconfig _) (list (local-file "/etc/securityops.defconfig")))
        ((#:phases phases) phases)))))

;;; ──────────────────────────────────────────────────────────────────────────
;;; Keyboard layout (build once; the field name shadows the constructor inside records)
(define %kbd (keyboard-layout "br" "abnt2"))

;;; Session environment: global GL/GBM vendor selection (login-wide)
;;; ──────────────────────────────────────────────────────────────────────────
;; Only the vendor-selection vars that are safe for EVERY login (the Sway
;; Wayland session AND XWayland clients AND plain TTY logins) live here. The
;; Wayland *application* backend hints (GDK/QT/MOZ/WLR_*) are deliberately NOT
;; global — they belong to the graphical session only and are set on the greetd
;; Sway session via %sway-session-env, so a bare TTY login is never told to use
;; a Wayland backend that isn't there.
(define gpu-env-service
  (simple-service
   'gpu-env-vars
   session-environment-service-type
   '(("LIBGL_DRI3_ENABLE"          . "1")
     ("__GLX_VENDOR_LIBRARY_NAME"  . "nvidia")
     ("GBM_BACKEND"                . "nvidia-drm"))))

;;; ──────────────────────────────────────────────────────────────────────────
;;; Sway (Wayland) session environment — NVIDIA proprietary on a MUX'd laptop
;;; ──────────────────────────────────────────────────────────────────────────
;; The discrete RTX 4060 is the ONLY GPU the OS sees (the Intel iGPU is MUX'd
;; off — lspci shows one GPU), so wlroots has to drive the proprietary NVIDIA
;; blob. wlroots refuses NVIDIA by default; sway is therefore started with
;; --unsupported-gpu (and the equivalent SWAY_UNSUPPORTED_GPU=true below). The
;; GBM path also needs nvidia_drm.modeset=1, which nonguix-transformation-nvidia
;; injects on the kernel command line at the foot of this file.
;;
;; These vars are attached ONLY to the greetd Sway user-session (extra-env), not
;; to the global session-environment, so a plain TTY login is never pushed onto
;; a Wayland backend. Each native-Wayland app hint carries an X11/XWayland
;; fallback so apps lacking a Wayland backend still run.
(define %sway-session-env
  '(;; wlroots on the NVIDIA blob: the hardware cursor plane is broken, so force
    ;; a software cursor — otherwise the pointer is invisible or garbled.
    ("WLR_NO_HARDWARE_CURSORS" . "1")
    ;; Seat backend: use seatd (seatd-service-type runs the daemon). The
    ;; logind/elogind seat path fails under greetd here ("Only owner of session
    ;; may take control"), so force seatd — the reliable wlroots backend on Guix.
    ("LIBSEAT_BACKEND"         . "seatd")
    ;; GLES2 is the most compatible wlroots renderer on the NVIDIA blob.
    ("WLR_RENDERER"            . "gles2")
    ;; Belt-and-suspenders with the --unsupported-gpu command-line flag.
    ("SWAY_UNSUPPORTED_GPU"    . "true")
    ;; GBM/GLX vendor (also set globally; repeated so the session is self-contained).
    ("GBM_BACKEND"               . "nvidia-drm")
    ("__GLX_VENDOR_LIBRARY_NAME" . "nvidia")
    ;; Desktop identity for xdg-desktop-portal / app theming.
    ("XDG_CURRENT_DESKTOP" . "sway")
    ("XDG_SESSION_DESKTOP" . "sway")
    ;; Native-Wayland application backends, each with an X11/XWayland fallback.
    ("MOZ_ENABLE_WAYLAND" . "1")
    ("QT_QPA_PLATFORM"    . "wayland;xcb")
    ("QT_WAYLAND_DISABLE_WINDOWDECORATION" . "1")
    ("GDK_BACKEND"        . "wayland,x11")
    ("CLUTTER_BACKEND"    . "wayland")
    ("SDL_VIDEODRIVER"    . "wayland")
    ("ELM_DISPLAY"        . "wl")
    ("_JAVA_AWT_WM_NONREPARENTING" . "1")
    ;; Chromium/Electron (google-chrome): use the Wayland/Ozone path.
    ("NIXOS_OZONE_WL"     . "1")
    ;; wlroots on the proprietary NVIDIA blob: disable atomic modesetting — the
    ;; standard workaround for GBM/atomic-modeset bring-up failures on NVIDIA.
    ("WLR_DRM_NO_ATOMIC"  . "1")))

;;; ──────────────────────────────────────────────────────────────────────────
;;; Operating system
;;; ──────────────────────────────────────────────────────────────────────────
(define %securityops-os
 (operating-system

  ;; ── Kernel: nonguix `linux` (7.0.x). REQUIRED for the prebuilt NVIDIA
  ;; module to load — the custom `securityops` kernel mismatches it. ──
  (kernel securityops)
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
     ;; =emulate (was =none): RDR2's Arxan anti-tamper READS the legacy vsyscall
     ;; page (0xffffffffff600000) as an env check; under =none that read faults and
     ;; Arxan clean-exits (ExitProcess 0) before opening a window. =emulate keeps the
     ;; page non-executable (trap+emulate) — far safer than =native, just un-faults
     ;; the read. Confirmed live: a read of the page SIGSEGVs under =none.
     "vsyscall=emulate"
     ;; IOMMU / DMA (Intel)
     "intel_iommu=on"
     "iommu=pt"
     ;; LSM (no lockdown -> NVIDIA can load)
     "lsm=landlock,yama,apparmor"
     "apparmor=1"
     ;; (security=apparmor dropped: superseded by lsm= above; the kernel ignores it)
     ;; CPU frequency / scheduler
     "intel_pstate=active"
     "preempt=full"
     "transparent_hugepage=madvise"
     "numa_balancing=disable"    ; single-node laptop: no periodic NUMA scan stalls
     ;; Entropy / reliability
     "random.trust_cpu=off"
     ;; NVIDIA (proprietary). nvidia_drm.modeset=1 is injected by
     ;; nonguix-transformation-nvidia (bottom of file). fbdev=1 gives the VT a
     ;; framebuffer console under modeset — REQUIRED so the greetd text greeter and
     ;; Sway have a visible console on NVIDIA. Without it the VT goes black and the
     ;; login fails ("does not start well"); XLibre never needs it because the X
     ;; server drives KMS directly. THIS is the most likely Sway-boot fix.
     "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
     "nvidia_drm.fbdev=1"
     ;; Attack-surface reduction. One authoritative blacklist (nouveau + nova folded
     ;; in here; nonguix also injects nouveau/nova as separate tokens).
     "modprobe.blacklist=nouveau,nova_core,nova_drm,firewire_core,firewire_ohci,dccp,sctp,rds,tipc"))

  (initrd microcode-initrd)
  ;; sof-firmware: Intel Sound Open Firmware DSP blobs + topology (sof-tplg).
  ;; REQUIRED for Raptor Lake on-board audio — speakers/headphones and the
  ;; SoundWire amps route through the SOF DSP, so without these the Intel
  ;; HDA card never registers and only HDMI (NVIDIA) audio appears.
  (firmware (list sof-firmware linux-firmware))

  (locale "pt_BR.UTF-8")
  (locale-definitions
   (list (locale-definition (name "pt_BR.UTF-8") (source "pt_BR"))
         (locale-definition (name "en_US.UTF-8") (source "en_US"))))
  (timezone "America/Sao_Paulo")
  (keyboard-layout %kbd)
  (host-name "securityops")        ; installer named it "matrix"

  ;; ── Swap ──
  ;; 24 GiB disk swapfile on the (ext4) encrypted root, layered over the 8 GiB
  ;; zram below.  Needed to build Firefox-class packages from source
  ;; (librewolf/torbrowser/icecat): their rust LTO crate `gkrust' is a single
  ;; ~14 GiB rustc that OOM-kills a bare 15 GiB box at ANY -j.  guix activates
  ;; (swapon) this at boot, but does NOT create the file — create it once:
  ;;   sudo fallocate -l 24G /var/swapfile && sudo chmod 600 /var/swapfile \
  ;;     && sudo mkswap /var/swapfile && sudo swapon /var/swapfile
  ;; NOTE: the swapfile lives on the LUKS2-encrypted root, so any /tmp pages that
  ;; spill here (incl. sensitive data) are encrypted at rest — no plaintext leak.
  (swap-devices
   (list (swap-space (target "/var/swapfile"))))

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
        "audio" "video" "plugdev"
        "seat")))   ; seat: libseat/seatd access so Sway/wlroots can take the seat
    %base-user-accounts))

  ;; plugdev is referenced above but is NOT in %base-groups; define it.
  (groups
   (cons* (user-group (name "plugdev") (system? #t))
          (user-group (name "seat") (system? #t))   ; seatd device-access group (Sway/wlroots)
          %base-groups))

  ;;; ────────────────────────────────────────────────────────────────────────
  ;;; Packages
  ;;; ────────────────────────────────────────────────────────────────────────
  (packages
   (append
    ;; For MullvadVPN
    (list openresolv)

    ;; Browsers & apps
    (list librewolf               ; TEMP revert (was so:librewolf) until daemon builds on /var/tmp
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
          ;; ── Sway / Wayland desktop (now the PRIMARY session) ───────────────
          sway                         ; the compositor
          swaybg                       ; wallpaper
          waybar                       ; status bar
          wmenu                        ; provides wmenu-run — the $menu in sway's default config
          fuzzel                       ; nicer app launcher (alternative to wmenu)
          mako                         ; notification daemon
          grim                         ; screenshots
          slurp                        ; region selection (pairs with grim)
          wl-clipboard                 ; wl-copy / wl-paste
          swayidle                     ; idle management (lock/dpms)
          swaylock                     ; screen locker
          wlr-randr                    ; query/set Wayland outputs from the CLI
          kanshi                       ; auto output profiles on hotplug
          wdisplays                    ; GUI output layout (the Wayland 'arandr')
          xorg-server-xwayland         ; run X11 apps under Sway
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
          so:kitty               ; securityops channel: 0.47.4 (gnu 0.46.2) — Go deps packaged
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
          so:tor                 ; securityops channel: 0.4.9.9 (gnu 0.4.9.8)
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
  ;; FHS dynamic-linker shim: lets foreign glibc ELF binaries exec on Guix
  ;; System (claude-code native build, prebuilt LSPs, etc.). PT_INTERP of
  ;; those binaries is hardcoded to /lib64/ld-linux-x86-64.so.2.
  (list (extra-special-file "/lib64/ld-linux-x86-64.so.2"
                            (file-append glibc "/lib/ld-linux-x86-64.so.2")))

  ;; Login manager: greetd (replaces SLiM/GDM). GDM is deleted from
  ;; %desktop-services; the greetd service is added to the service list below and
  ;; launches Sway after a text-mode login. %desktop-services still provides
  ;; elogind, which registers the logind session greetd opens — that is what
  ;; gives wlroots (via libseat) DRM master + input on this seat, so no separate
  ;; seatd service is required.
  (modify-services %desktop-services
    (delete gdm-service-type)
      ;; Laptop lid: DO NOTHING on close. elogind's default HandleLidSwitch is
      ;; 'suspend, which pauses every running task/app the instant the lid shuts.
      ;; Force all three lid handlers to 'ignore so closing the lid is a no-op —
      ;; builds, downloads, servers and scans keep running on battery AND on AC
      ;; (external-power), docked or not. IdleAction is already 'ignore, and the
      ;; suspend/power KEY presses keep their defaults — only the LID switch
      ;; changes. Heat note: running with the lid shut reduces airflow; thermald
      ;; (gnu services pm) stays active to throttle if needed.
      (elogind-service-type config =>
       (elogind-configuration
        (inherit config)
        (handle-lid-switch 'ignore)
        (handle-lid-switch-external-power 'ignore)
        (handle-lid-switch-docked 'ignore)))
      ;; NetworkManager manages /etc/resolv.conf when the VPN is OFF (put your
      ;; NextDNS servers on the NM connection so DNS = NextDNS then). When Mullvad
      ;; is UP it writes /etc/resolv.conf DIRECTLY via its talpid_dns static backend
      ;; (NOT through NM) as 0600 root-only — see the 'resolv-conf-watch /
      ;; 'resolv-conf-readable services below, which keep it 0644 for the Steam
      ;; container.
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
            ;; Hardened ptrace_scope=2 (capability-only) — the secure default for
            ;; this Sway variant. NOTE: RDR2's Arxan anti-tamper self-debugs via
            ;; PTRACE_TRACEME and clean-exits at scope 2; to play it, lower at
            ;; RUNTIME (no reconfigure, auto-reverts on reboot):
            ;;   sudo sysctl kernel.yama.ptrace_scope=1
            ("kernel.yama.ptrace_scope"         . "2")
            ("kernel.unprivileged_bpf_disabled" . "1")
            ("net.core.bpf_jit_harden"          . "2")
            ("net.ipv4.tcp_congestion_control"  . "bbr")
            ("net.core.default_qdisc"           . "fq_codel")
            ("net.ipv4.conf.all.rp_filter"      . "1")
            ("net.ipv4.conf.default.rp_filter"  . "1")
            ("net.ipv6.conf.all.accept_redirects" . "0")
            ("net.ipv4.conf.all.accept_redirects" . "0")
            ("net.ipv4.conf.all.send_redirects"   . "0")
            ;; Memory/tmpfs perf: zram is fast compressed swap, so prefer it
            ;; aggressively (frees RAM for page cache + the tmpfs /tmp) and turn
            ;; off swap read-ahead clustering (zram is random-access; page-cluster
            ;; 0 = 1 page per fault, lower latency). Pairs with the zram service.
            ("vm.swappiness"                      . "180")
            ("vm.page-cluster"                    . "0")
            ;; RDR2/DXVK (and other big Vulkan games) need a high mmap count;
            ;; Proton normally raises this itself but can't inside the no-CAP
            ;; nonguix Steam container. 65530 (default) -> world-load crash.
            ("vm.max_map_count"                   . "1048576"))
          (sysctl-configuration-settings config)))))
      ;; Build daemon: send build scratch to /var/tmp (on the encrypted root disk),
      ;; NOT the new RAM-backed tmpfs /tmp. Large LOCAL builds (the custom
      ;; securityops kernel, wlroots/sway, anything bordeaux lacks under Tor
      ;; --fallback) write GBs of scratch; on a tmpfs that would consume RAM and
      ;; OOM. Disk /var/tmp (~91G free) keeps them safe while /tmp stays a fast RAM
      ;; scratch for everything else. tmpdir is guix-daemon's dedicated field.
      (guix-service-type config =>
       (guix-configuration
        (inherit config)
        (tmpdir "/var/tmp"))))

    (list
     ;; ── Login manager: greetd → Sway (replaces SLiM/XLibre, replaces GDM) ──
     ;; A *text* greeter (agreety) runs on vt7 — no compositor at the login
     ;; stage, so none of the wlroots-on-NVIDIA fragility applies until the real
     ;; session starts. On a successful login greetd execs Sway directly as the
     ;; authenticated user with:
     ;;   * --unsupported-gpu  — wlroots will not drive the proprietary NVIDIA
     ;;     blob without it, and this MUX'd laptop has no other GPU;
     ;;   * %sway-session-env  — NVIDIA-Wayland env (software cursor, GBM/GLX
     ;;     vendor, native-Wayland app backends with XWayland fallback);
     ;;   * XDG_SESSION_TYPE=wayland (set by the greetd user-session helper).
     ;; tty1–6 keep their normal gettys; greetd takes vt7 (the VT SLiM used).
     ;; If Sway ever fails to come up you simply land back on a TTY — switch with
     ;; Ctrl+Alt+F1..F6 and reconfigure/rollback from there.
     ;; seatd: wlroots/Sway takes its seat (DRM master + input) from seatd, NOT
     ;; logind. Confirmed via `sway -d`: without this Sway dies instantly with
     ;; "libseat: No backend was able to open a seat" + "logind: Only owner of
     ;; session may take control". We run the seatd daemon DIRECTLY (not
     ;; seatd-service-type — that one also mounts /sys/fs/cgroup and provides
     ;; 'elogind, both of which collide with the elogind in %desktop-services that
     ;; we keep for sessions/power/lid). seatd creates /run/seatd.sock owned by the
     ;; "seat" group (defined above; berkeley is a member); %sway-session-env sets
     ;; LIBSEAT_BACKEND=seatd. cgroup is already mounted by elogind at boot.
     (simple-service 'seatd shepherd-root-service-type
       (list (shepherd-service
              (documentation "seatd seat-management daemon for wlroots/Sway.")
              (provision '(seatd))
              (requirement '(user-processes))
              (respawn? #t)
              (start #~(make-forkexec-constructor
                        (list #$(file-append seatd "/bin/seatd") "-g" "seat")
                        #:environment-variables '("SEATD_LOGLEVEL=info")
                        #:log-file "/var/log/seatd.log"))
              (stop #~(make-kill-destructor)))))

     (service greetd-service-type
       (greetd-configuration
        ;; video+input let a *graphical* greeter (if you later switch to
        ;; wlgreet/gtkgreet) reach DRM/evdev; harmless for the agreety greeter.
        (greeter-supplementary-groups (list "video" "input"))
        (terminals
         (list
          (greetd-terminal-configuration
           (terminal-vt "7")
           (terminal-switch #t)
           (default-session-command
             (greetd-agreety-session
              (command
               (greetd-user-session
                (command (file-append sway "/bin/sway"))
                (command-args '("--unsupported-gpu"))
                (xdg-session-type "wayland")
                (extra-env %sway-session-env))))))))))

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

     ;; Tighten /home perms at boot AND make /etc/resolv.conf world-readable.
     ;; resolv.conf is written 0600 root-only by the Mullvad daemon (talpid_dns
     ;; static backend), which breaks DNS for any non-root process that can't reach
     ;; nscd — notably Steam inside its nonguix FHS container (nscd isn't shared
     ;; there; sharing it breaks RDR2 audio). Without a readable resolv.conf, glibc
     ;; in the container finds no nameserver and every Steam CM connect fails
     ;; instantly ("neterror - Invalid"), leaving Steam stuck OFFLINE. 0644 is the
     ;; universal default and exposes only which DNS server is used — no secrets,
     ;; no effect on the VPN tunnel/kill-switch.
     ;; NOTE: this service MUST set an explicit PATH — shepherd's pid1 has an EMPTY
     ;; PATH, so the previous bare-"chmod" form silently failed (it left /home
     ;; 0755, never 0751). /var/lib/aide is dropped (it doesn't exist). The
     ;; 'resolv-conf-watch (inotify, instant) and 'resolv-conf-readable (mcron,
     ;; per-minute) services below are the steady-state guarantees; this one only
     ;; covers the boot instant.
     (simple-service 'file-permissions shepherd-root-service-type
       (list (shepherd-service
              (provision '(file-permissions))
              (start #~(make-forkexec-constructor
                        (list "/run/current-system/profile/bin/sh" "-c"
                              "chmod 751 /home 2>/dev/null || true; chmod 0644 /etc/resolv.conf 2>/dev/null || true")
                        #:environment-variables
                        (list "PATH=/run/current-system/profile/bin")))
              (stop #~(make-kill-destructor))
              (auto-start? #t))))

     ;; Keep /etc/resolv.conf world-readable so Steam (and anything else in the
     ;; nonguix FHS container, which has no nscd) can resolve DNS. Mullvad/NM
     ;; rewrite it 0600 on every (re)connect; re-chmod it at the top of each
     ;; minute. See the 'file-permissions service above for the full rationale.
     (simple-service 'resolv-conf-readable mcron-service-type
       (list #~(job '(next-minute)
                    "chmod 0644 /etc/resolv.conf 2>/dev/null || true")))

     ;; Zero-window guarantee: watch the /etc DIRECTORY with inotify and re-chmod
     ;; /etc/resolv.conf to 0644 the instant it is (re)written, closing the up-to-
     ;; 60s gap the mcron backstop leaves after each Mullvad reconnect. Notes, each
     ;; verified on this system: (1) watch the DIR, not the file — Mullvad/openresolv
     ;; REPLACE the inode, which would kill a single-file watch; (2) inotify-tools
     ;; 3.22.6.0 here has NO --exec, so events are piped into a Guile read-loop;
     ;; (3) we deliberately do NOT watch 'attrib' — chmod itself emits IN_ATTRIB,
     ;; which would self-trigger an infinite chmod loop. Mode bits only: no effect
     ;; on DNS content, the VPN tunnel, or the kill-switch.
     (simple-service 'resolv-conf-watch shepherd-root-service-type
       (list (shepherd-service
              (documentation "Instantly chmod 0644 /etc/resolv.conf on every (re)write.")
              (provision '(resolv-conf-watch))
              (requirement '(networking))
              (respawn? #t)
              (start
               #~(make-forkexec-constructor
                  (list #$(program-file "resolv-conf-watcher"
                           #~(begin
                               (use-modules (ice-9 popen) (ice-9 rdelim))
                               (let ((inotifywait #$(file-append inotify-tools "/bin/inotifywait"))
                                     (chmod-bin    #$(file-append coreutils "/bin/chmod")))
                                 (system* chmod-bin "0644" "/etc/resolv.conf")
                                 (let ((port (open-pipe* OPEN_READ inotifywait
                                                         "-m" "-q"
                                                         "-e" "close_write"
                                                         "-e" "create"
                                                         "-e" "moved_to"
                                                         "--include" "resolv\\.conf$"
                                                         "--format" "%f" "/etc")))
                                   (let loop ((line (read-line port)))
                                     (unless (eof-object? line)
                                       (when (string=? line "resolv.conf")
                                         (system* chmod-bin "0644" "/etc/resolv.conf"))
                                       (loop (read-line port)))))))))))
              (stop #~(make-kill-destructor)))))

     ;; Bluetooth.
     (service bluetooth-service-type
              (bluetooth-configuration (auto-enable? #t)))

     ;; USB authorisation udev rule (simple-service form; version-stable).
     (simple-service 'device-authorization udev-service-type
       (list (udev-rule "99-device-authorize.rules"
                        "SUBSYSTEM==\"usb\", ATTR{authorized}=\"1\"\n")))

     ;; ───────────────────────────────────────────────────────────────────
     ;; GAME CONTROLLERS (Steam Input). On this hardened box /dev/uinput and
     ;; /dev/hidraw* are root-only, which blocks Steam from emitting virtual
     ;; pads and from rumble/gyro/config. Load uinput at boot and grant the
     ;; logged-in seat uaccess to uinput, any detected joystick, and the
     ;; matching hidraw nodes. Covers GameSir (USB VID 3537, e.g. X5 Lite in
     ;; Android/HID mode) and Switch-mode pads (Nintendo VID 057e).
     ;; ───────────────────────────────────────────────────────────────────
     (service kernel-module-loader-service-type '("uinput"))
     (simple-service 'game-controller-udev udev-service-type
       (list (udev-rule "60-steam-input.rules"
              (string-append
               ;; Virtual controller output node for Steam Input.
               "KERNEL==\"uinput\", SUBSYSTEM==\"misc\", MODE=\"0660\", "
               "TAG+=\"uaccess\", OPTIONS+=\"static_node=uinput\"\n"
               ;; Any device udev tags as a joystick/gamepad (evdev + js).
               "SUBSYSTEM==\"input\", ENV{ID_INPUT_JOYSTICK}==\"1\", "
               "MODE=\"0660\", TAG+=\"uaccess\"\n"
               ;; GameSir (Guangzhou Chicken Run) USB + hidraw.
               "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"3537\", "
               "MODE=\"0660\", TAG+=\"uaccess\"\n"
               "KERNEL==\"hidraw*\", ATTRS{idVendor}==\"3537\", "
               "MODE=\"0660\", TAG+=\"uaccess\"\n"
               ;; X5 Lite in Switch mode reports as a Nintendo Switch Pro pad.
               "KERNEL==\"hidraw*\", ATTRS{idVendor}==\"057e\", "
               "MODE=\"0660\", TAG+=\"uaccess\"\n"))))

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

     ;; Mullvad VPN daemon — pointed at the securityops channel package
     ;; (2026.3 stable) so the running daemon matches the curated channel set
     ;; instead of small-guix's older 2025.8 default.
     (service mullvad-daemon-service-type
              (mullvad-daemon-configuration
               (mullvad-vpn-desktop so:mullvad-vpn-desktop)))

     ;; Containers.
     (service docker-service-type)
     (service containerd-service-type)

     ;; Nix.
     (service nix-service-type)

     ;; Torando Control — loopback web GUI + root daemon that routes one user's
     ;; egress through Tor (transparent proxy + killswitch).  Shepherd service
     ;; from the securityops channel; runs torando-guid on 127.0.0.1:8088.
     ;; The service auto-seeds /etc/torando-gui/config.json on first activation
     ;; with "manage_torrc": false (tor-service-type below owns the read-only
     ;; /etc/tor/torrc) and "dns_port": 5353 to match the tor-configuration
     ;; below; TransPort 9040 / SocksPort 9050 / ControlPort 9051 already match.
     (service torando-gui-service-type)

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
          ;; --- PRESERVED device/uuid/type/deps; only (flags '(no-atime)) ADDED ---
          ;; no-atime drops per-read atime writes: less SSD write-amplification and
          ;; a small read speedup. Mount-safe, reversible (delete the flags line).
          (file-system
            (mount-point "/")
            (device "/dev/mapper/cryptroot")
            (type "ext4")
            (flags '(no-atime))
            (dependencies mapped-devices))
          (file-system
            (mount-point "/home")
            (device "/dev/mapper/crypthome")
            (type "ext4")
            (flags '(no-atime))
            (dependencies mapped-devices))
          ;; --- Secure, RAM-backed /tmp (16 GiB, hardened for sensitive data) ---
          ;; tmpfs in RAM; size=16G is a CAP, not a reservation — an empty /tmp
          ;; uses ~0 RAM and only what you actually write is held. Files larger
          ;; than free RAM spill into the 24 GiB swapfile, which lives on the
          ;; LUKS2-encrypted root, so sensitive scratch is encrypted at rest —
          ;; no plaintext leak to disk. HIBERNATION is off too, so RAM is never
          ;; imaged out. tmpfs is wiped completely on every reboot, so nothing is
          ;; persisted ("files i don't need to store"). Hardening flags:
          ;;   no-suid — setuid bits in /tmp are ignored (no privilege escalation)
          ;;   no-dev  — device nodes in /tmp are ignored
          ;;   no-exec — code in /tmp CANNOT be executed: blocks malware/dropped
          ;;             payloads run straight from a download dir. guix builds
          ;;             already use /var/tmp (daemon tmpdir above), so this does
          ;;             NOT affect package builds; to run an installer/AppImage,
          ;;             run it from /var/tmp or $HOME instead.
          ;; The 16G cap (not all RAM) means a runaway writer hits ENOSPC, never
          ;; the OOM-killer. mode=1777 keeps standard sticky world-writable perms;
          ;; create sensitive files with a tight umask (umask 077) so other local
          ;; users can't read them.
          (file-system
            (device "tmpfs")
            (mount-point "/tmp")
            (type "tmpfs")
            (check? #f)
            ;; Match the known-good XLibre /tmp EXACTLY (4G, no noexec) to rule the
            ;; tmpfs out as the boot/partition failure — this makes config-sway's
            ;; file-systems identical to the booting XLibre config. Restore
            ;; size=16G (+ no-exec) once Sway is confirmed booting.
            (flags '(no-suid no-dev))
            (options "mode=1777,size=4G")
            (create-mount-point? #t))
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
