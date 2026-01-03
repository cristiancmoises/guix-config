;; -*- mode: scheme; -*-
;; Guix Home Configuration for User "berkeley"
;;
;; This configuration defines a privacy-focused, developer-friendly home environment
;; for the user "berkeley" on the "securityops" host, tailored for a machine with AMD
;; Ryzen 2200G and Radeon RX 5600/5700 series GPU. It integrates with the system
;; configuration in /etc/config.scm, which uses xlibre for graphics, Mullvad VPN for
;; privacy, and Tor for anonymity. The environment supports development (Emacs, Guile,
;; Rust, Haskell), multimedia (MPV, FFmpeg), file management (lf, ranger), and
;; Fish is the primary shell with Starship for prompt
;; customization, and Xmonad is used as the window manager (assumed compatible with
;; xlibre). MIME associations ensure seamless file handling, and font settings optimize
;; display rendering with Iosevka as the preferred sans-serif font.
;;
;; Key Features:
;;   - Shell: Fish with Starship prompt, Bash as fallback.
;;   - Development: Emacs with plugins, Guile, Haskell, Rust, and C++ support.
;;   - Multimedia: MPV, FFmpeg, and image processing tools.
;;   - Privacy: Tor, Mullvad VPN integration, and secure file handling.
;;   - Aesthetics: Iosevka font, MIME associations, and lightweight tools.
;;
;; Usage:
;;   - Update Guix: `guix pull`
;;   - Validate configuration: `guix home build ~/.config/guix/home.scm`
;;   - Apply configuration: `guix home reconfigure ~/.config/guix/home.scm`
;;   - Verify environment: `env | grep -E 'PATH|EDITOR|BROWSER|SHELL'`
;;   - Monitor logs: `tail -f ~/.local/share/xmonad/xmonad.log` (if Xmonad is used)
;;   - Verify font: `fc-match sans-serif` (should return Iosevka)
;;
;; Notes for Public Sharing (Codeberg):
;;   - Do not share sensitive paths or scripts (e.g., ~/.ssh/securityops, /files/scripts).
;;   - Replace placeholder paths (e.g., /files/scripts) with generic ones if sharing.
;;
;; Maintainer: Cristian Cezar Moisés
;; Last Updated: August 02, 2025

;;; Module Imports
;; Import required Guix modules for home environment, packages, and services
(use-modules
 (gnu packages base)
 (gnu home)                         ; Core Guix home environment module
 (gnu home services)                ; Home service definitions
 (gnu home services desktop)
 (gnu home services sound)
 (gnu home services fontutils)
 (gnu packages suckless)
 (gnu packages file-systems)
 (gnu packages libreoffice)
 (gnu packages ninja)
 (gnu packages w3m)
 (gnu packages dns)
 (gnu packages textutils)
 (gnu packages virtualization)
 (gnu packages gimp)
 (gnu packages haskell-xyz)
 (gnu packages xml)
 (gnu packages telegram)
 (gnu packages librewolf)
 (gnu packages games)
 (gnu packages luanti)
 (rosenthal packages web)
 (gnu packages nss)
 (gnu home services gnupg)     ; GnuPG home services
 (gnu home services xdg)       ; XDG home services
 (gnu home-services wm)        ; Window manager home services
 (gnu packages commencement)
 (gnu packages vulkan)
 (gnu packages glib)
 (nongnu packages compression)
 (gnu packages benchmark)
 (ajatt packages video)
 (ajatt packages audio)
 (gnu home services shells)         ; Shell configuration services
 (gnu home services xdg)            ; XDG MIME and desktop integration
 (gnu packages python-xyz)
 (gnu packages)
 (radix services admin)        ; Custom admin service definitions
 (radix packages xdisorg)      ; Custom X11 display organization packages
 (radix packages image-viewers) ; Custom image viewer packages
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
 (gnu packages admin)               ; System administration tools
 (gnu packages audio)               ; Audio-related packages
 (gnu packages bash)                ; Bash shell
 (gnu packages bittorrent)          ; BitTorrent clients
 (gnu packages compression)         ; Compression tools
 (gnu packages curl)                ; cURL for HTTP requests
 (gnu packages disk)                ; Disk management tools
 (gnu packages ebook)               ; Ebook readers
 (gnu packages emacs)               ; Emacs editor
 (gnu packages emacs-xyz)           ; Emacs plugins
 (gnu packages freedesktop)         ; Freedesktop.org standards
 (gnu packages build-tools)
 (gnu packages gl)                  ; OpenGL-related packages
 (gnu packages gtk)
 (gnu packages image-viewers)
 (gnu packages gstreamer)           ; GStreamer multimedia framework
 (gnu packages gnome)               ; GNOME desktop tools
 (gnu packages hardware)            ; Hardware-related packages
 (gnu packages haskell)             ; Haskell packages
 (gnu packages haskell-check)       ; Haskell check packages
 (gnu packages ibus)                ; IBus input method
 (gnu packages image-processing)    ; Image processing tools
 (gnu packages imagemagick)         ; ImageMagick for image manipulation
 (gnu packages linux)               ; Linux-related tools
 (gnu packages lisp)                ; Lisp programming
 (gnu packages lisp-xyz)            ; Lisp additional packages
 (gnu packages lxde)
 (gnu packages mail)                ; Mail-related tools
 (gnu packages mpd)                 ; Music Player Daemon
 (gnu packages package-management)  ; Package management tools
 (gnu packages pdf)                 ; PDF tools
 (gnu packages pkg-config)          ; Package configuration tool
 (gnu packages python)              ; Python programming
 (gnu packages qt)                  ; Qt framework
 (gnu packages rust-apps)           ; Rust applications
 (gnu packages terminals)           ; Terminal emulators
 (gnu packages text-editors)        ; Text editors
 (gnu packages tor)                 ; Tor anonymity network
 (gnu packages video)               ; Video tools
 (gnu packages music)               ; Audio tools 
 (gnu packages web)                 ; Web-related tools
 (gnu packages web-browsers)        ; Web browsers
 (gnu packages xdisorg)             ; X11 display organization (for xlibre compatibility)
 (gnu packages xfce)                ; XFCE desktop tools
 (gnu packages fonts)               ; Font packages
 (gnu packages emulators)           ; Emulators
 (gnu packages tls)                 ; TLS packages
 (gnu packages cmake)               ; CMake package
 (gnu packages shellutils)          ; Shell utilities
 (gnu packages photo)               ; Photo packages
 (gnu packages llvm)
 (gnu packages haskell-apps)
 (gnu packages pulseaudio)
 (gnu packages guile-xyz)           ; Guile additional packages
 (guix gexp)                        ; G-expressions for file handling
 (srfi srfi-26)                     ; SRFI-26 for partial application
 (nongnu packages game-client)      ; Non-GNU game clients
 (gnu packages chromium)            ; Chromium
 (nongnu packages chrome)           ; Non-GNU Chrome browser
 (saayix packages binaries)         ; Custom binary packages
 (saayix packages python-xyz)
 (small-guix packages lutris)
 (gnu services dbus)
 (gnu packages fcitx5)
 (gnu home services sound))

;;; Home Environment Configuration
(home-environment
 ;; Packages
 ;; List of packages installed in the user's home environment, grouped by
 ;; functionality for clarity. Includes development tools, multimedia, file
 ;; management, desktop utilities, and the Iosevka font.
;; -*- scheme -*-
;; GNU Guix Home Configuration for User "berkeley"
;; Contains user-specific packages: development tools, editors, multimedia, fonts, and utilities

(packages
 (append
  ;; ===========================
  ;; Development Tools
  ;; ===========================
  (list
   bash                        ; Shell
   cmake                       ; Build system
   llvm-for-mesa               ; LLVM optimized for Mesa
   meson                       ; Build system
   strace                       ; System call tracer
   edk2-tools                  ; UEFI dev tools
   fzf                         ; Fuzzy finder
   jq                          ; JSON processor
   pkg-config                  ; Package config tool
   haunt                       ; SCHEME Web builder
   bash-minimal
   qtgraphicaleffects
   gcc-toolchain
   pinentry-gtk2
   gtk
   proot
   glib
   alsa-lib
   pkg-config 
   glibc
   nspr
   nss
   alsa-lib
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
  ;; Programming Languages
   bundler                     ;
   ruby                        ; 
   ruby-json
   gcc
   jekyll
   phoronix-test-suite
   ghc                         ; Haskell compiler
   cabal-install               ; Haskell package manager
   cabal-doctest           ; Haskell doctest support
   go                           ; Go language
   openjdk                      ; Java Development Kit
   python                       ; Python
   python-pip                   ; Python package manager
   python-emoji                 ; Emoji support
   certbot
   rust                         ; Rust
   node                         ; Node.js runtime
   git                          ; Version control
   git-lfs                     ; Git extension for large files
   forgejo                     ; My Git service
   anubis                      ; Block Bad Bots
   cl-clx                       ; X11 client library for Common Lisp
   cl-css                       ; CSS generation in Common Lisp
   guile-ares-rs               ; Guile bindings for Rust
   )

  ;; ===========================
  ;; Multimedia / Audio / Video
  ;; ===========================
  (list
   mesa-utils
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
   pipewire
   wireplumber
   pavucontrol
   pulsemixer
   v4l-utils
   ffmpeg                       ; Audio/video processing
   ffmpegthumbnailer 
   guvcview
   cmatrix
   mpv
   cmus
   gpac
   vvdec-app
   gimp
   mplayer                       ; Media player
   obs
   obs-pipewire-audio-capture    ;
   imagemagick                   ; Image manipulation
   perl-image-exiftool           ; Metadata extraction
   noisetorch
   mpd                           ; Music Player Daemon
   bluez                          ; Bluetooth protocol stack
   bluez-alsa                    ; ALSA Bluetooth integration
   blueman                        ; Bluetooth manager
   alsa-lib
   alsa-utils
   pavucontrol-qt
   qtwebengine
   qtshadertools
   vlc
   steam
   lutris
   luanti
   luanti-server
   pcsx2
   pcsx2-patches
   navidrome-bin
   wmctrl
   )

  ;; ===========================
  ;; File and Disk Management
  ;; ===========================
  (list
   wipe
   lf                             ; Minimalist file manager
   ranger                          ; Console file manager
   p7zip                           ; Archive tool
   qpdfview                         ; PDF viewer
   unrar
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
   procps
   )

  ;; ===========================
  ;; Desktop Utilities / Window Management
  ;; ===========================
  (list
   fcitx5
   fcitx5-qt
   librewolf
   desktop-file-utils
   qemu
   gnome-tweaks
   lxappearance
   flatpak-xdg-utils
   flatpak
   starship
   neofetch
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
   mesa
   mesa-opencl
   qtwayland
   zoxide
   ;; Bars, notifications, and window management
   polybar
   waybar
   fnott
   swww
   wl-clipboard
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
   xterm
   xkeyboard-config
   st
   xpra
   xwininfo
   xdpyinfo
   )

  ;; ===========================
  ;; Security / Privacy (user-level)
  ;; ===========================
  (list
   wireguard-tools
   pwgen
   openssl
   firejail
   gnupg
   hashcat
   keepassxc
   ansible
   nftables
   tor
   tor-client
   torsocks
   openvpn
   privoxy
   nmap
   tcpdump
   wireshark
   iperf
   netcat-openbsd
   arp-scan
   dnstracer
   ldns
   knot
   )

  ;; ===========================
  ;; Text Editors / IDEs
  ;; ===========================
  (list
   nano
   emacs
   emacs-nerd-icons
   emacs-telega
   tdlib
   emacs-vterm
   emacs
   emacs-org 
   emacs-org-static-blog
   emacs-magit
   neovim
   gedit
   )

  ;; ===========================
  ;; Emulators / Misc
  ;; ===========================
  (list
   higan
   qbittorrent
   at-spi2-core                   ; Accessibility
   )

  ;; ===========================
  ;; Fonts
  ;; ===========================
  (list
 ;; Fonts
     font-gnu-unifont
     font-gnu-freefont
     font-dejavu               ; DejaVu font family for general use
     font-adobe-source-code-pro ; Monospace font for coding
     font-adobe-source-han-sans ; CJK font for Chinese, Japanese, Korean
     font-adobe-source-sans ; Sans-serif font for documents
     font-adobe-source-serif ; Serif font for documents
     font-anonymous-pro        ; Monospace font for programming
     font-anonymous-pro-minus  ; Variant of Anonymous Pro
     font-awesome              ; Icon font for UI elements
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
     font-vazirmatn                ; Persian font
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
   unicode-emoji
   r-emojifont
   emacs-emojify
   emacs-company-emoji
   )

  ;; ===========================
  ;; Optional / Extras moved from config.scm
  ;; ===========================
  (list
   google-chrome-stable
   librewolf
   ungoogled-chromium
   kitty
   alacritty
   flameshot
   qimgv
   geeqie
   ueberzug++
   )
  ))


 ;; Services
 ;; Configures shell, MIME associations, fonts, and environment variables for a
 ;; seamless user experience.
 (services
  (list 
     ;; D-Bus is required for PipeWire/Portals
      (service home-dbus-service-type)
      ;; PipeWire core service
      (service home-pipewire-service-type)
   ;; Bash Service
   ;; Configures Bash as a fallback shell with aliases and environment variables
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
                ("run_code" . "g++ -o main main.cc -Ofast -std=c++23 -s -flto -march=native -I ~/dev/ajatt/hakurei/include/ && ./main")
                ("rgf" . "rg --files | rg")
                ("mpv" . "mpv --audio-pitch-correction=yes --vf=setpts=PTS/1")
                ("record" . "ffmpeg -f x11grab -r 23 -s 1920x1080 -i $DISPLAY -f pulse -i nui_mic_remap -filter_complex '[1:a]volume=2.0[a]' -map 0:v -map '[a]' -c:v libx264 -pix_fmt yuv420p -preset ultrafast -crf 23 -y /tmp/output.mp4")
                ("isolate" . "guix shell --container --network --preserve='^DISPLAY$' --preserve='^XAUTHORITY$' --expose=$XAUTHORITY --expose=/etc/ssl/certs --no-cwd")))
             (bashrc (list (local-file "/etc/.bashrc" "bashrc")))
             (bash-profile (list (local-file "/etc/.bash_profile" "bash_profile")))))

   ;; Fish Service
   ;; Configures Fish as the primary shell with Starship prompt and custom aliases
 (service home-fish-service-type
  (home-fish-configuration
    (config
      (list
        (plain-file
          "fish_greeting.fish"
          "function fish_greeting\n    echo \"\"\nend")
        (plain-file
          "fish_init.fish"
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
        ("repair" . "guix gc --verify=repair,contents")
        ("tx" . "bash /files/scripts/tmp.sh")
        ("wp" . "bash /files/scripts/wal.sh")
        ("gu" . "guix package -u")
        ("cvi" . "convert original.png -resize 500% resized.png")
        ("cvv" . "ffmpeg -i video.mkv -codec copy video.mp4")
        ("bgv" . "mplayer -quiet -nosound -loop 0 -vo xv vid.mp4")
        ("l" . "du -h --max-depth=1 .")
        ("grep" . "grep --color=auto")
        ("del" . "shred -uvz")
        ("gob" . "/files/scripts/gob.sh")
        ("noise" . "~/.local/bin/noisetorch")
        ("delp" . "wipe -r")
        ("q" . "exit")
        ("n" . "neofetch")
        ("p" . "pfetch")
        ("f" . "fastfetch") 
        ("ss" . "sudo env TERM=xterm su -")
        ("ee" . "exiftool -recursive -all=")
        ("ex" . "exiftool -all= && del *original*")
        ("yt" . "/files/scripts/git/ytfzf/ytfzf --max-threads=4 --thumbnail-quality=maxres --features=hd -t --ii=https://invidious.nerdvpn.de")
        ("enc" . "tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz")
        ("dec" . "openssl enc -d -aes256 -in secured.tar.gz | tar xz")
        ("s" . "sensors")
        ("clean" . "/files/scripts/git/cleanall/cleaner.sh")
        ("e" . "cd ..")
        ("up" . "/files/scripts/git/up.sh")
        ("7" . "7z x")
        ("ia" . "/usr/local/bin/yai")
        ("wall" . "cp /home/berkeley/Downloads/wall.jpg /tmp && bg /tmp/wall.jpg")
        ("help" . "del /tmp/*jpg /tmp/*webp /tmp/*png /tmp/*mp4 /tmp/*gif /tmp/*jpeg && rm -rf ad*")
        ("now" . "cd /tmp && tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz && mv secured.tar.gz /files")
        ("bb" . "bg /files/downloads/preto.jpg")
        ("xx" . "bg /var/cache/wallpaper.png")
        ("hot" . "cp /files/secured.tar.gz /tmp && cd /tmp && openssl enc -d -aes256 -in secured.tar.gz | tar xz")
        ("big" . "find /home/berkeley -type f -size +1000M > /home/berkeley/big.txt")
        ("zip" . "7z a arquivos")
        ("h" . "haunt build && haunt serve")
        ("vid" . "/files/scripts/vid.sh")
        ("zap" . "/files/scripts/zap.sh")
        ("torup" . "/files/scripts/torup.sh")
        ("gangsta" . "/files/scripts/music.sh")
        ("sss" . "/files/scripts/sss.sh")
        ("lf" . "~/.local/bin/lf/lfrun")
        ("gif" . "/files/scripts/gif.sh")
        ("giff" . "/files/scripts/gif2.sh")
        ("br" . "/files/scripts/br.sh")
        ("wik" . "/files/scripts/wiki.sh")
        ("upp" . "/files/scripts/up.sh")
        ("rec" . "/files/scripts/record/record")
        ("post" . "bash /files/scripts/copycat.sh")
        ("torb" . "/files/scripts/torbrowser.sh")
        ("ice" . "/files/scripts/icecat.sh")
        ("bw" . "bg /home/berkeley/Downloads/wall2.jpg")
        ("mp" . "/files/scripts/mpv.sh")
        ("term" . "/files/scripts/terminator.sh")
        ("s1" . "/files/scripts/server.sh")
        ("gitlfs" . "/files/scripts/lfs.sh")
        ("class" . "mpv /files/music/Classical/classic/*")
        ("cam" . "/files/scripts/cam.sh")
        ("c" . "clear")
        ("vis" . "/home/berkeley/.guix-profile/bin/vis")
        ("news" . "twtxt timeline")
        ("tempo" . "curl 'wttr.in/caxias_do_sul?date=next7'")
        ("bun" . "/home/berkeley/.bun/bin/bun")))))


   ;; XDG MIME Applications
   ;; Configures default applications for file types and protocols
   (service home-xdg-mime-applications-service-type
            (home-xdg-mime-applications-configuration
             (default
              `(("emacs.desktop" . ("text/plain" "text/troff" "text/xml" "text/x-c" "text/x-c++" "text/x-diff" "text/x-lisp" "text/x-scheme" "text/x-shellscript" "text/x-tex" "image/vnd.djvu"))
                ("lf.desktop" . ("inode/directory" "x-scheme-handler/ftp" "x-scheme-handler/nfs" "x-scheme-handler/smb" "x-scheme-handler/ssh" "application/x-directory"))
                ("mpv.desktop" . ("image/gif" "audio/mpeg" "audio/ogg" "audio/opus" "audio/x-opus+ogg" "audio/flac" "video/mp4" "application/octet-stream" "video/mp2t" "video/x-matroska" "video/webm"))
                ("nsxiv.desktop" . ("image/avif" "image/bmp" "image/jpeg" "image/png" "image/svg+xml" "image/webp"))
                ("foliate.desktop" . ("application/epub+zip"))
                ("sioyek.desktop" . ("application/pdf"))))))

   ;; Environment Variables
   ;; Sets user-wide environment variables for paths, editors, and input methods
   (simple-service 'environment-variables-service
                   home-environment-variables-service-type
                   `(("PATH" . "$HOME/.local/bin:/home/berkeley/.bun/bin:$PATH")
                     ("GUIX_SANDBOX_EXTRA_SHARES" . "/mnt/games")
                     ("GUILE_WARN_DEPRECATED" . "detailed")
                     ("GTK_IM_MODULE" . "fcitx")
                     ("QT_IM_MODULE" . "fcitx")
                     ("XMODIFIERS" . "@im=fcitx")
                     ("LANG" . "en_US.UTF-8")
                     ("LANGUAGE" . "en_US.UTF-8")
                     ("LC_COLLATE" . "C")
                     ("BROWSER" . "nyxt")
                     ("EDITOR" . "gedit")
                     ("FCEDIT" . "gedit")
                     ("PAGER" . "less")
                     ("READER" . "foliate")
                     ("SHELL" . "fish")
                     ("TERMINAL" . "kitty")
                     ("VISUAL" . "nsxiv")
                     ("NVM_DIR" . "/home/berkeley/.config/nvm")
                     ("DRI_PRIME" . "1"))))))

