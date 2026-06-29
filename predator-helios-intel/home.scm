;; -*- mode: scheme; -*-
;; Guix Home Configuration for User "berkeley"  —  Helios Neo 16 (i7 + RTX 4060)
;;
;; Ported from the older AMD home.scm. User-level packages are hardware-agnostic
;; and were kept as-is. The only hardware change: the AMD-only DRI_PRIME=1 offload
;; variable was REMOVED (NVIDIA uses __NV_PRIME_RENDER_OFFLOAD instead — set it
;; per-app when you want offload; in NVIDIA-only/MUX mode you need neither).
;;
;; Dual monitors: a ~/.local/bin/dual-monitor helper is installed and `autorandr`
;; is added. Workflow is documented in README.md (auto-applies a saved layout on
;; HDMI/DP hotplug, WM-agnostic — works under Xmonad without a DE).
;;
;; NVIDIA: the whole package list is wrapped in (replace-mesa … #:driver nvda-580)
;; so every Home-profile GL/Vulkan app uses the RTX 4060 — the OS transformation
;; in config.scm only covers the SYSTEM profile, not this Guix Home profile.
;; replace-mesa also grafts ffmpeg -> ffmpeg/nvidia (NVENC/NVDEC for mpv/obs/vlc).
;; Also: steam -> steam-nvidia; NVIDIA shader disk cache enabled.
;;
;; Apply: guix home reconfigure ~/.config/guix/home.scm
;;
;; Maintainer: Cristian Cezar Moisés
;; Last Updated: June 08, 2026

(use-modules
 (gnu packages base)
 (gnu packages backup)
 (gnu packages tor)
 (gnu packages ssh)
 (gnu home)
 (gnu home services)
 (gnu home services desktop)
 (gnu home services sound)
 (gnu home services fontutils)
 (gnu packages appimage)
 (gnu packages enlightenment)
 (gnu packages suckless)
 (gnu packages gawk)
 (gnu packages file-systems)
 (gnu packages libreoffice)
 (gnu packages ninja)
 (gnu packages w3m)
 (gnu packages dns)
 (gnu packages statistics)
 (gnu packages textutils)
 (gnu packages virtualization)
 (gnu packages gimp)
 (gnu packages kde-graphics)
 (gnu packages haskell-xyz)
 (gnu packages xml)
 (gnu packages video)
 (gnu packages chromium)
 (gnu packages telegram)
 (gnu packages librewolf)
 (gnu packages games)
 (gnu packages luanti)
 (gnu packages bioinformatics)
 (gnu packages bioconductor)
 (gnu packages nss)
 (gnu packages maths)
 (gnu home services gnupg)
 (gnu home services xdg)
 (gnu home services shepherd)
 (gnu packages commencement)
 (gnu packages vulkan)
 (gnu packages glib)
 (gnu packages benchmark)
 (gnu packages shells)
 (gnu home services shells)
 (gnu packages python-xyz)
 (gnu packages)
 (gnu packages gcc)
 (gnu packages vpn)
 (gnu packages image)
 (gnu packages vim)
 (gnu packages cran)
 (gnu packages gnupg)
 (gnu packages rust)
 (gnu packages ruby)
 (gnu packages ruby-xyz)
 (gnu packages compton)
 (gnu packages sqlite)
 (gnu packages wine)
 (nongnu packages wine)
 (nongnu packages nvidia)
 (gnu packages password-utils)
 (gnu packages python-build)
 (gnu packages unicode)
 (gnu packages lxqt)
 (gnu packages java)
 (gnu packages xorg)
 (gnu packages kde-pim)
 (gnu packages networking)
 (gnu packages golang)
 (gnu packages wm)
 (gnu packages ruby-check)
 (gnu packages firmware)
 (gnu packages version-control)
 (gnu packages node)
 (gnu packages admin)
 (gnu packages audio)
 (gnu packages bash)
 (gnu packages bittorrent)
 (gnu packages compression)
 (gnu packages curl)
 (gnu packages disk)
 ;(longdong packages disks)
 (gnu packages ebook)
 (gnu packages emacs)
 (gnu packages emacs-xyz)
 ;; --- added 2026-06-14: modules for Emacs LSP servers / linters / spell ---
 (gnu packages python-check)      ; python-pyflakes, python-bandit
 (gnu packages golang-apps)       ; gopls
 (gnu packages node-xyz)          ; node-typescript
 (gnu packages aspell)            ; aspell + en dictionary
 (gnu packages freedesktop)
 (gnu packages build-tools)
 (gnu packages gl)
 (gnu packages gtk)
 (gnu packages image-viewers)
 (gnu packages gstreamer)
 (gnu packages gnome)
 (gnu packages hardware)
 (gnu packages haskell)
 (gnu packages haskell-check)
 (gnu packages ibus)
 (gnu packages image-processing)
 (gnu packages imagemagick)
 (gnu packages linux)
 (gnu packages lisp)
 (gnu packages lisp-xyz)
 (gnu packages lxde)
 (gnu packages mail)
 (gnu packages mpd)
 (gnu packages package-management)
 (gnu packages pdf)
 (gnu packages pkg-config)
 (gnu packages python)
 (gnu packages qt)
 (gnu packages rust-apps)
 (gnu packages terminals)
 (gnu packages text-editors)
 ;(longdong packages tor)
 ;(longdong packages video)
 (gnu packages music)
 (gnu packages web)
 (rosenthal packages web)
 (gnu packages web-browsers)
 (gnu packages tor-browsers)
 (gnu packages xdisorg)
 (gnu packages xfce)
 (gnu packages fonts)
 (gnu packages emulators)
 (gnu packages tls)
 (gnu packages cmake)
 (gnu packages shellutils)
 (gnu packages photo)
 (gnu packages llvm)
 (gnu packages haskell-apps)
 (gnu packages pulseaudio)
 (gnu packages guile-xyz)
 (guix gexp)
 (guix packages)
 (srfi srfi-26)
 (nongnu packages game-client)
 (nongnu packages chrome)
 ;(longdong packages binaries)
 (gnu services dbus)
 (gnu packages fcitx5)
 (gnu home services sound)

 ;; securityops channel — latest-version overrides for the curated apps:
 ;;   kitty 0.47.4 (gnu 0.46.2), tor 0.4.9.9 (gnu 0.4.9.8),
 ;;   torbrowser 15.0.16 (gnu 15.0.14), google-chrome-stable 149 (nongnu 148),
 ;;   ungoogled-chromium-bin 149.0.7827.155 (prebuilt; source-build unavailable over Tor).
 ;; Imported behind the `so:' prefix so the bare gnu/nongnu bindings stay
 ;; available; only the symbols switched to so:… below use the channel.
 ((securityops packages terminals) #:prefix so:)   ; so:kitty
 ((securityops packages tor)       #:prefix so:)   ; so:tor, so:torbrowser
 ((securityops packages browsers)  #:prefix so:)   ; so:google-chrome-stable, so:ungoogled-chromium-bin
 ((securityops packages apps)      #:prefix so:))  ; so:moneyprinterturbo

(home-environment

 (packages
  ;; NVIDIA for the Guix Home profile (a SEPARATE closure from the OS): graft
  ;; mesa -> nvda-580 and ffmpeg -> ffmpeg/nvidia across every home GL/Vulkan app
  ;; (mpv/obs/vlc/terminals/games/emulators), which otherwise fall back to
  ;; llvmpipe under the proprietary driver. nvda-580 matches the running kernel
  ;; module (580.159.04) and the system config.scm — keep them in lockstep.
  (replace-mesa
   (append
   ;; ── Development tools ──
   (list bash
         gzip
         tar
         cmake
         llvm-for-mesa
         meson
         strace
         edk2-tools
         fzf
         jq
         pkg-config
         haunt
         bash-minimal
         qtgraphicaleffects
         gcc-toolchain
         pinentry-gtk2
         gtk
         appimage-type2-runtime
         proot
         glib
         alsa-lib
         glibc
         nspr
         nss
         libx11
         libxcomposite
         libxdamage
         libxext
         libxfixes
         libxrandr
         libxshmfence
         libdrm
         libxkbcommon
         libxcb
         ;; Programming languages
         bundler
         ruby
         ruby-json
         gcc
         jekyll
         phoronix-test-suite
         ghc
         cabal-install
         cabal-doctest
         go
         openjdk
         python
         python-pip
         python-emoji
         python-biopython
         python-virtualenv
         borg
         btrfs-progs
         r
         r-deseq2
         r-edger
         r-biocmanager
         certbot
         rust
         node
         git
         git-lfs
         forgejo
         anubis
         cl-clx
         cl-css
         guile-ares-rs)

   ;; ── Multimedia / audio / video ──
   (list mesa-utils
         libva
         libvdpau
         vulkan-loader
         vulkan-headers
         libass
         enca
         uchardet
         libdvdcss
         libdvdread
         libdvdnav
         libbluray
         libxml2
         ;; pipewire + wireplumber are provided by home-pipewire-service-type;
         ;; do NOT list them here — the replace-mesa graft (via ffmpeg) would make
         ;; a second, grafted variant and Guix rejects duplicate pipewire/wireplumber.
         pavucontrol
         pulsemixer
         v4l-utils
         ffmpeg
         ffmpegthumbnailer
         guvcview
         cmatrix
         mpv
         cmus
         gpac
         gimp
         jpegoptim
         krita
         mplayer
         obs
         obs-pipewire-audio-capture
         imagemagick
         perl-image-exiftool
         noisetorch
         mpd
         bluez
         bluez-alsa
         blueman
         alsa-utils
         pavucontrol-qt
         qtwebengine
         qtshadertools
         vlc
         so:moneyprinterturbo   ; securityops channel: MoneyPrinterTurbo 1.3.0 (venv-bootstrap over Tor)
         steam-nvidia
         wine
         winetricks
         luanti
         luanti-server
         pcsx2
         pcsx2-patches
         wmctrl)

   ;; ── File and disk management ──
   (list wipe
         lf
         ranger
         p7zip
         qpdfview
         libreoffice
         zip
         xlsx2csv
         odt2txt
         w3m
         atool
         poppler
         chafa
         librsvg
         exfat-utils
         exfatprogs
         fuse-exfat
         fuse
         ntfs-3g
         pandoc
         parted
         smartmontools
         mergerfs
         udevil
         gnome-disk-utility
         gparted
         bcachefs-tools
         dosfstools
         usbutils
         sqlite
         procps)

   ;; ── Desktop utilities / window management ──
   ;; Dual-monitor: autorandr (auto-apply layout on hotplug) + arandr (GUI).
   (list fcitx5
         fcitx5-qt
         librewolf              ; TEMP revert (was so:librewolf) until daemon builds on /var/tmp
         so:torbrowser          ; securityops channel: 15.0.16 thin-LTO source build (gnu 15.0.14)
         desktop-file-utils
         qemu
         gnome-tweaks
         lxappearance
         flatpak-xdg-utils
         flatpak
         starship
         pfetch
         lm-sensors
         fastfetch
         bat
         qtbase
         cool-retro-term
         qtdeclarative
         qtsvg
         qtwebview
         qttools
         ninja
         coreutils
         findutils
         grep
         sed
         gawk
         mesa
         mesa-opencl
         qtwayland
         zoxide
         autorandr               ; NEW: multi-monitor auto-layout
         arandr                  ; NEW: GUI monitor arrangement
         ;; Bars, notifications, window management
         polybar
         waybar
         fnott
         awww
         wl-clipboard
         grim                    ; Wayland screenshots (Sway WIN+i/n/j/z binds)
         slurp                   ; region selection for grim
         wlrctl
         wlsunset
         compton
         picom
         brightnessctl
         feh
         rofi
         xmonad
         xmobar
         xprop
         xrandr
         xset
         xdotool                 ; clear stuck modifiers after a VT switch (fix-xmonad)
         xterm
         xkeyboard-config
         st
         xpra
         xwininfo
         xdpyinfo)

   ;; ── Security / privacy (user-level) ──
   (list gnupg
         pinentry
         kleopatra
         wireguard-tools
         pwgen
         openssl
         firejail
         hashcat
         keepassxc
         nftables
         so:tor                 ; securityops channel: 0.4.9.9 (gnu 0.4.9.8)
         tor-client
         torsocks
         openvpn
         nmap
         tcpdump
         wireshark
         openssh
         iperf
         netcat-openbsd
         arp-scan
         dnstracer
         ldns
         knot)

   ;; ── Text editors / IDEs ──
   (list nano
         emacs
         emacs-nerd-icons
         emacs-telega
         tdlib
         emacs-vterm
         emacs-org
         emacs-org-static-blog
         emacs-magit
         neovim
         gedit)

   ;; ── Emulators / misc ──
   (list higan
         qbittorrent
         at-spi2-core
         calc)

   ;; ── Fonts ──
   (list font-gnu-unifont
         font-gnu-freefont
         font-dejavu
         font-adobe-source-code-pro
         font-adobe-source-han-sans
         font-adobe-source-sans
         font-adobe-source-serif
         font-anonymous-pro
         font-anonymous-pro-minus
         font-awesome
         font-cns11643-swjz
         font-comic-neue
         font-culmus
         font-dosis
         font-dseg
         font-fantasque-sans
         font-fira-code
         font-fira-mono
         font-fira-sans
         font-fontna-yasashisa-antique
         font-google-noto-emoji
         font-google-material-design-icons
         font-google-noto
         font-google-roboto
         font-hack
         font-hermit
         font-ibm-plex
         font-inconsolata
         font-iosevka
         font-iosevka-aile
         font-iosevka-etoile
         font-iosevka-slab
         font-iosevka-term
         font-iosevka-term-slab
         font-ipa-mj-mincho
         font-jetbrains-mono
         font-lato
         font-liberation
         font-linuxlibertine
         font-lohit
         font-meera-inimai
         font-mononoki
         font-mplus-testflight
         font-public-sans
         font-rachana
         font-sarasa-gothic
         font-sil-andika
         font-sil-charis
         font-sil-gentium
         font-tamzen
         font-terminus
         font-tex-gyre
         font-un
         font-vazirmatn
         font-wqy-microhei
         font-wqy-zenhei
         font-adobe100dpi
         font-adobe75dpi
         font-cronyx-cyrillic
         font-dec-misc
         font-isas-misc
         font-micro-misc
         font-misc-cyrillic
         font-misc-ethiopic
         font-misc-misc
         font-mutt-misc
         font-schumacher-misc
         font-screen-cyrillic
         font-sony-misc
         font-sun-misc
         font-util
         font-winitzki-cyrillic
         font-xfree86-type1
         font-openmoji
         unicode-emoji
         r-emojifont
         emacs-emojify
         emacs-company-emoji)

   ;; ── Emacs LSP servers / linters / spell-check (added 2026-06-14) ──
   ;; Back the lsp-mode / flycheck / apheleia / flyspell setup in
   ;; ~/.emacs.d/init.el. All verified present via `guix package -A`.
   ;; NOT packaged in Guix — install separately if you want them:
   ;;   typescript-language-server :  npm i -g typescript-language-server typescript
   ;;   semgrep                    :  pipx install semgrep
   ;;   trivy                      :  download the static binary release
   (list python-lsp-server          ; pylsp — Python LSP
         python-pyflakes            ; pylsp linting
         python-pycodestyle         ; pylsp style checks
         python-bandit              ; bandit — Python SAST (also in C-c k menu)
         gopls                      ; Go LSP
         shellcheck                 ; shell linting via flycheck
         node-typescript            ; tsc / tsserver
         ripgrep                    ; rg — consult-ripgrep / projectile
         fd                         ; fd — fast file finder
         aspell                     ; spell-checker (flyspell)
         aspell-dict-en)            ; English dictionary

   ;; ── Optional / extras ──
   (list opendoas
         so:ungoogled-chromium-bin ; securityops channel: PREBUILT 149.0.7827.155 (gnu source-build 147, unbuildable over Tor)
         so:google-chrome-stable ; securityops channel: 149 (nongnu 148)
         librewolf              ; TEMP revert (was so:librewolf) until daemon builds on /var/tmp
         telegram-desktop
         wezterm
         alacritty
         so:kitty               ; securityops channel: 0.47.4 (gnu 0.46.2) — Go deps packaged
         flameshot
         qimgv
         ueberzugpp
         xdg-desktop-portal
         xdg-desktop-portal-gtk))
   #:driver nvda-580))

 ;;; ───────────────────────────────────────────────────────────────────────
 ;;; Services
 ;;; ───────────────────────────────────────────────────────────────────────
 (services
  (list
   ;; D-Bus + PipeWire.
   (service home-dbus-service-type)
   (service home-pipewire-service-type)

   ;; A ready-to-edit dual-monitor helper (PATH includes ~/.local/bin).
   ;; Find your real output names with `xrandr --query`, edit, then either run
   ;; it from your Xmonad startupHook or save it via `autorandr --save docked`.
   (service home-files-service-type
            `((".local/bin/dual-monitor"
               ,(local-file
                 "/home/berkeley/guix-config/predator-helios-intel/dotfiles/dual-monitor"
                 #:recursive? #t))
              ;; Screen-brightness two-stage dimmer (repo: dotfiles/brightness-step):
              ;; hardware backlight, then xrandr software gamma below the hardware
              ;; floor for much darker low-end dimming, with cross-session persistence.
              ;; Bound to XF86MonBrightnessUp/Down in ~/.xmonad/xmonad.hs; the
              ;; `restore` subcommand runs from the xmonad startupHook on login.
              (".local/bin/brightness-step"
               ,(local-file
                 "/home/berkeley/guix-config/predator-helios-intel/dotfiles/brightness-step"
                 #:recursive? #t))))

   ;; ── Bash (fallback shell) ──
   (service home-bash-service-type
            (home-bash-configuration
             (aliases
              `(("analyze_video" . "~/.local/bin/analyze_video.sh")
                ("ct" . "~/.local/bin/compatibility.sh")
                ("grep" . "grep --color=auto")
                ("update" . "guix pull && sudo guix system reconfigure /etc/config.scm")
                ("lf" . "~/.local/bin/lf/lfrun")
                ("ll" . "ls -l")
                ("ls" . "ls -p --color=auto")
               ; ("run_code" . "g++ -o main main.cc -Ofast -std=c++23 -s -flto -march=native -I ~/dev/ajatt/hakurei/include/ && ./main")
                ("rgf" . "rg --files | rg")
                ("mpv" . "mpv --audio-pitch-correction=yes --vf=setpts=PTS/1")
                ("record" . "ffmpeg -f x11grab -r 23 -s 1920x1080 -i $DISPLAY -f pulse -i nui_mic_remap -filter_complex '[1:a]volume=2.0[a]' -map 0:v -map '[a]' -c:v libx264 -pix_fmt yuv420p -preset ultrafast -crf 23 -y /tmp/output.mp4")
                ("isolate" . "guix shell --container --network --preserve='^DISPLAY$' --preserve='^XAUTHORITY$' --expose=$XAUTHORITY --expose=/etc/ssl/certs --no-cwd")))
             (bashrc (list (local-file "/etc/.bashrc" "bashrc")
                           ;; `bg <image>` wallpaper shortcut — a superset of the job-control
                           ;; builtin (file arg -> set wallpaper via ~/.local/bin/setbg;
                           ;; otherwise the real builtin). Matches the fish functions/bg.fish.
                           (plain-file "bg-wallpaper.bash"
                                       "# bg <image-file>: set the wallpaper; else the job-control builtin.
bg() {
    if [ -n \"${1:-}\" ] && [ -f \"$1\" ]; then
        setbg \"$@\"
    else
        builtin bg \"$@\"
    fi
}
")))
             (bash-profile (list (local-file "/etc/.bash_profile" "bash_profile")))))

   ;; ── Fish (primary shell) ──
   (service home-fish-service-type
            (home-fish-configuration
             (config
              (list
               (plain-file "fish_greeting.fish"
                           "function fish_greeting\n    echo \"\"\nend")
               (plain-file "fish_init.fish"
                           "set -x PATH $HOME/.guix-home/profile/bin $PATH
starship init fish | source
zoxide init fish | source
bass source /home/berkeley/.config/nvm/nvm.sh --no-use")))
             (aliases
              `(("torando" . "~/torando/torando.sh")
                ("toroff" . "~/torando/toroff.sh")
                ("toggle-vpn" . "~/toggle-vpn.sh")
                ("gi" . "eval (ssh-agent -c) && ssh-add ~/.ssh/securityops")
                ("android" . "flatpak run com.google.AndroidStudio")
                ("disc" . "flatpak run so.libdb.dissent")
                ("repair" . "sudo guix gc --verify=repair,contents")
                ("tx" . "bash ~/scripts/tmp.sh")
                ("wp" . "bash ~/scripts/wal.sh")
                ("gu" . "guix package -u")
                ("cvi" . "convert original.png -resize 500% resized.png")
                ("cvv" . "ffmpeg -i video.mkv -codec copy video.mp4")
                ("bgv" . "mplayer -quiet -nosound -loop 0 -vo xv vid.mp4")
                ("l" . "du -h --max-depth=1 .")
                ("del" . "shred -uvz")
                ("gob" . "~/scripts/gob.sh")
                ("noise" . "~/.local/bin/noisetorch")
                ("delp" . "wipe -r")
                ("q" . "exit")
                ("p" . "pfetch")
                ("f" . "fastfetch")
                ("ss" . "sudo env TERM=xterm su -")
                ("ee" . "exiftool -recursive -all=")
                ("ex" . "exiftool -all= && del *original*")
                ("yt" . "~/scripts/git/ytfzf/ytfzf --max-threads=4 --thumbnail-quality=maxres --features=hd -t --ii=https://yt.securityops.co")
                ("enc" . "tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz")
                ("dec" . "openssl enc -d -aes256 -in secured.tar.gz | tar xz")
                ("s" . "sensors")
                ("clean" . "~/scripts/git/cleanall/cleaner.sh")
                ("e" . "cd ..")
                ("up" . "~/scripts/git/up.sh")
                ("7" . "7z x")
                ("ia" . "/usr/local/bin/yai")
                ("wall" . "cp /home/berkeley/Downloads/wall.jpg /tmp && bg /tmp/wall.jpg")
                ("help" . "del /tmp/*jpg /tmp/*webp /tmp/*png /tmp/*mp4 /tmp/*gif /tmp/*jpeg && rm -rf ad*")
                ("now" . "cd /tmp && tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz && mv secured.tar.gz /files")
                ("bb" . "feh --bg-fill ~/wallpapers/preto.png")
                ("xx" . "bg /var/cache/wallpaper.png")
                ("hot" . "cp ~/secured.tar.gz /tmp && cd /tmp && openssl enc -d -aes256 -in secured.tar.gz | tar xz")
                ("big" . "find /home/berkeley -type f -size +1000M > /home/berkeley/big.txt")
                ("zip" . "7z a arquivos")
                ("h" . "haunt build && haunt serve")
                ("vid" . "~/scripts/vid.sh")
                ("zap" . "~/scripts/zap.sh")
                ("torup" . "~/scripts/torup.sh")
                ("gangsta" . "~/scripts/music.sh")
                ("sss" . "~/scripts/sss.sh")
                ("lf" . "~/.local/bin/lf/lfrun")
                ("gif" . "~/scripts/gif.sh")
                ("giff" . "~/scripts/gif2.sh")
                ("br" . "~/scripts/br.sh")
                ("wik" . "~/scripts/wiki.sh")
                ("upp" . "~/scripts/up.sh")
                ("rec" . "~/scripts/record/record")
                ("post" . "bash ~/scripts/copycat.sh")
                ("torb" . "~/scripts/torbrowser.sh")
                ("ice" . "~/scripts/icecat.sh")
                ("bw" . "bg /home/berkeley/Downloads/wall2.jpg")
                ("mp" . "~/scripts/mpv.sh")
                ("term" . "~/scripts/terminator.sh")
                ("s1" . "~/scripts/server.sh")
                ("gitlfs" . "~/scripts/lfs.sh")
                ("cam" . "~/scripts/cam.sh")
                ("c" . "clear")
                ("vis" . "/home/berkeley/.guix-profile/bin/vis")
                ("news" . "twtxt timeline")
                ("dm" . "~/.local/bin/dual-monitor")
                ("tempo" . "curl 'wttr.in/caxias_do_sul?date=next7'")
                ("bun" . "/home/berkeley/.bun/bin/bun")))))

   ;; ── XDG MIME associations ──
   (service home-xdg-mime-applications-service-type
            (home-xdg-mime-applications-configuration
             (default
              `(("emacs.desktop" . ("text/plain" "text/troff" "text/xml" "text/x-c" "text/x-c++" "text/x-diff" "text/x-lisp" "text/x-scheme" "text/x-shellscript" "text/x-tex" "image/vnd.djvu"))
                ("lf.desktop" . ("inode/directory" "x-scheme-handler/ftp" "x-scheme-handler/nfs" "x-scheme-handler/smb" "x-scheme-handler/ssh" "application/x-directory"))
                ("mpv.desktop" . ("image/gif" "audio/mpeg" "audio/ogg" "audio/opus" "audio/x-opus+ogg" "audio/flac" "video/mp4" "application/octet-stream" "video/mp2t" "video/x-matroska" "video/webm"))
                ("nsxiv.desktop" . ("image/avif" "image/bmp" "image/jpeg" "image/png" "image/svg+xml" "image/webp"))
                ("foliate.desktop" . ("application/epub+zip"))
                ("sioyek.desktop" . ("application/pdf"))))))

   ;; ── WhatsApp.el 3.0.0 stack (Shepherd user services) ──
   ;; Two services replace the former Node/Baileys bridge: `wuzapi' (the
   ;; Go/whatsmeow WhatsApp engine, loopback :8080) and `whatsappel-bridge' (the
   ;; Guile bridge whatsappel.scm, loopback :7337) which talks to it. The bridge
   ;; `requires' wuzapi, so wuzapi starts first. Both respawn on failure. Secrets
   ;; are read at runtime from ~/wuzapi/.env and ~/whatsappel/.env (mode 600) —
   ;; never embedded in the world-readable store. The wuzapi session lives under
   ;; ~/.config/whatsappel/wuzapi-data, so the phone link survives restarts.
   (simple-service 'whatsappel-stack-service
                   home-shepherd-service-type
                   (list
                    ;; wuzapi — the WhatsApp multi-device engine (whatsmeow).
                    (shepherd-service
                     (provision '(wuzapi))
                     (documentation "wuzapi WhatsApp engine (whatsmeow), loopback :8080.")
                     (respawn? #t)
                     (start
                      #~(make-forkexec-constructor
                         (list (string-append (getenv "HOME") "/wuzapi/wuzapi")
                               "-datadir"
                               (string-append (getenv "HOME")
                                              "/.config/whatsappel/wuzapi-data")
                               "-logtype" "console")
                         #:directory (string-append (getenv "HOME") "/wuzapi")
                         #:log-file (string-append (getenv "HOME")
                                                   "/.config/whatsappel/logs/wuzapi.log")
                         #:environment-variables (environ)))
                     (stop #~(make-kill-destructor)))
                    ;; whatsappel bridge — Emacs-facing Guile bridge.
                    (shepherd-service
                     (provision '(whatsappel-bridge))
                     (requirement '(wuzapi))
                     (documentation "whatsappel Guile bridge (Emacs <-> wuzapi), loopback :7337.")
                     (respawn? #t)
                     (start
                      #~(make-forkexec-constructor
                         (list #$(file-append bash "/bin/bash") "-c"
                               (string-append
                                "export PATH=\"$HOME/.local/bin:"
                                "/run/current-system/profile/bin:"
                                "$HOME/.guix-home/profile/bin:$PATH\"; "
                                "set -a; . \"$HOME/whatsappel/.env\"; set +a; "
                                "exec guile \"$HOME/whatsappel/whatsappel.scm\""))
                         #:directory (string-append (getenv "HOME") "/whatsappel")
                         #:log-file (string-append (getenv "HOME")
                                                   "/.config/whatsappel/logs/bridge.log")
                         #:environment-variables (environ)))
                     (stop #~(make-kill-destructor)))))

   ;; ── Environment variables (AMD DRI_PRIME removed; NVIDIA shader cache added) ──
   (simple-service 'environment-variables-service
                   home-environment-variables-service-type
                   ;; Append the SYSTEM profile so packages declared in config.scm
                   ;; (lynis, mullvad-vpn, htop, btop, killall, nft, …) resolve in
                   ;; every shell (TTY, SSH, fish/bash, terminals). Home/Guix-Home
                   ;; binaries still win ties (they come before $PATH); the system
                   ;; profile is only consulted for packages Home doesn't provide.
                   `(("PATH" . "$HOME/.local/bin:/home/berkeley/.bun/bin:$PATH:/run/current-system/profile/bin:/run/current-system/profile/sbin")
                     ("GUILE_WARN_DEPRECATED" . "detailed")
                     ("GTK_IM_MODULE" . "fcitx")
                     ("QT_IM_MODULE" . "fcitx")
                     ("XMODIFIERS" . "@im=fcitx")
                     ("LANG" . "en_US.UTF-8")
                     ("LANGUAGE" . "en_US.UTF-8")
                     ("LC_COLLATE" . "C")
                     ("BROWSER" . "librewolf")
                     ("EDITOR" . "gedit")
                     ("FCEDIT" . "gedit")
                     ("PAGER" . "less")
                     ("READER" . "foliate")
                     ("SHELL" . "fish")
                     ("TERMINAL" . "wezterm")
                     ("VISUAL" . "nsxiv")
                     ("__GL_SHADER_DISK_CACHE" . "1")
                     ("__GL_SHADER_DISK_CACHE_PATH" . "/home/berkeley/.cache/nvidia")
                     ("__GL_SHADER_DISK_CACHE_SKIP_CLEANUP" . "1")
                     ("NVM_DIR" . "/home/berkeley/.config/nvm"))))))
