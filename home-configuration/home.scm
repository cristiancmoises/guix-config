(use-modules
  (gnu home)
  (gnu packages tls)
  (gnu packages xdisorg)
  (gnu packages shellutils)
  (gnu packages imagemagick)
  (gnu packages pkg-config)
  (gnu packages haskell-check)
  (gnu packages gtk)
  (gnu packages zile)
  (gnu packages lxde)
  (gnu packages gl)
  (gnu packages telegram)
  (gnu packages gnome)
  (gnu home services desktop)
  (gnu packages)
  (gnu services)
  (gnu services docker)
  (gnu packages docker)
  (rde home services i2p)
  (gnu packages java)
  (gnu packages guile-xyz)
  (gnu packages haskell)
  (gnu packages gimp)
  (gnu packages kde-multimedia)
  (saayix packages binaries)
  (gnu packages web)
  (gnu packages ebook)
  (gnu packages tor)
  (gnu packages ibus)
  (gnu packages package-management)
  (guix gexp)
  (gnu packages rust-apps)
  (gnu home services)
  (gnu home services shells)
  (gnu home services fontutils)
  (gnu home services xdg)
  (gnu packages photo)
  (gnu packages mpd)
  (gnu packages disk)
  (gnu packages emacs-xyz)
  (gnu packages text-editors)
  (gnu packages xfce)
  (gnu packages image-viewers)
  (gnu packages gnupg)
  (gnu packages freedesktop)
  (gnu packages fonts)
  (gnu packages qt)
  (nongnu packages game-client)
  (gnu packages mail)
  (gnu packages compression)
  (gnu packages xml)
  (gnu packages audio)
  (gnu packages bittorrent)
  (gnu packages xorg)
  (gnu packages gstreamer)
  (gnu packages video)
  (gnu packages emulators)
  (gnu packages web-browsers)
  (gnu packages tmux)
  (gnu packages terminals)
  (gnu packages linux)
  (gnu packages python)
  (gnu packages cmake)
  (gnu packages readline)
  (gnu packages curl)
  (gnu packages pdf)
  (gnu packages glib)
  (gnu packages admin)
  (gnu packages lisp-xyz)
  (gnu packages wm)
  (gnu packages compton)
  (gnu packages lisp)
  (gnu packages music)
  (gnu packages version-control)
  (gnu packages lxqt)
  (nongnu packages chrome)
  (gnu packages emacs)
  (gnu packages bash)
  (gnu packages image-processing)
  (gnu packages mp3)
  (gnu packages security-token)
  (gnu packages hardware)
  (gnu packages suckless)
  (srfi srfi-26))

(define fontconfig
  '(fontconfig
    (comment " Set subpixel arrangement for all fonts ")
    (match ((target "font")
            (edit (@ (name "rgba") (mode "assign"))
                  (const "bgr"))
            (edit (@ (name "hrgba") (mode "assign"))
                  (const "bgr"))
            (edit (@ (name "hinting") (mode "assign"))
                  (bool "true")))
      (comment " Alias for Migu 1P font ")
      (alias ((family "sans-serif")
              (prefer (family "Migu 1P")))))))

(home-environment
 (packages
  (cons*
   rofi
   wmctrl
   lf
   gnome-tweaks
   lxappearance
   ranger
   guile-ares-rs
   emacs-arei
   emacs-eat
   zile
   arandr
   nano
   html-xml-utils
   emacs-rainbow-delimiters
   higan
   pkg-config
   ghc-cabal-doctest
   at-spi2-core
   sbcl-coleslaw
   emacs-nyxt
   emacs-olivetti
   emacs-deadgrep
   emacs-rg
   emacs-dumb-jump
   emacs-slime
   emacs-dirvish
   qpdfview
   xclip
   emacs-nerd-icons
   emacs-telega
   flatpak-xdg-utils
   cl-clx
   cl-css
   bash
   ffmpeg
   mplayer
   feh
   imagemagick
   perl-image-exiftool
   openssl
   lm-sensors
   neofetch
   pfetch
   p7zip
   starship
  (specifications->packages
    (list
     "obs"))))
 (services
  (list
   (service home-bash-service-type
            (home-bash-configuration
             (aliases
              '(("analyze_video" . "~/.local/bin/analyze_video.sh")
                ("ct" . "~/.local/bin/compatibility.sh")
                ("grep" . "grep --color=auto")
                ("update" . "guix pull && sudo guix system reconfigure .config/guix/config.scm")
                ("lf" . "~/.local/bin/lf/lfrun")
                ("ll" . "ls -l")
                ("ls" . "ls -p --color=auto")
                ("run_code" . "g++ -o main main.cc -Ofast -std=c++23 -s -flto -march=native -I ~/dev/ajatt/hakurei/include/  && ./main")
                ("rgf" . "rg --files | rg")
                ("mpv" . "mpv --audio-pitch-correction=yes --vf=setpts=PTS/1")
                ("record" . "ffmpeg -f x11grab -r 23 -s 1920x1080 -i $DISPLAY -f pulse -i nui_mic_remap -filter_complex '[1:a]volume=2.0[a]' -map 0:v -map '[a]' -c:v libx264 -pix_fmt yuv420p -preset ultrafast -crf 23 -y /tmp/output.mp4")
                ("isolate" . "guix shell --container --network --preserve='^DISPLAY$' --preserve='^XAUTHORITY$' --expose=$XAUTHORITY --expose=/etc/ssl/certs --no-cwd ")))
             (bashrc (list (local-file "/etc/.bashrc" "bashrc")))
             (bash-profile (list (local-file "/etc/.bash_profile" "bash_profile")))
             (environment-variables
              '(("GTK_IM_MODULE" . "fcitx")
                ("QT_IM_MODULE" . "fcitx")
                ("GUIX_GTK2_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache")
                ("GUIX_GTK3_IM_MODULE_FILE" . "/run/current-system/profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache")
                ("XMODIFIERS=@im=" . "fcitx")
                ("INPUT_METHOD" . "fcitx")
                ("XIM_PROGRAM" . "fcitx")
                ("GLFW_IM_MODULE" . "ibus")
                ("XMONAD_CONFIG_DIR" . "$HOME/.xmonad")
                ("PS1" . "\\u \\wλ ")))))
   (service home-fish-service-type
            (home-fish-configuration
             (config
              (list
               (plain-file "fish_greeting.fish"
                           "function fish_greeting\n    echo \"\"\nend")
               (plain-file "fish_init.fish"
                           "set -x PATH $HOME/.guix-home/profile/bin $PATH\nstarship init fish | source\nbass source /home/berkeley/.config/nvm/nvm.sh --no-use\ncurl 'wttr.in/Caxias_do_Sul?format=4'")))
             (aliases
              '(("torando" . "~/torando/torando.sh")
                ("toroff" . "~/torando/toroff.sh")
                ("toggle-vpn" . "~/toggle-vpn.sh")
                ("vpn" . "mullvad relay set location br-sao-wg-201")
                ("rustdesk" . "flatpak run com.rustdesk.RustDesk")
                ("gi" . "eval (ssh-agent -c) && ssh-add ~/.ssh/securityops")
                ("android" . "flatpak run com.google.AndroidStudio")
                ("disc" . "flatpak run so.libdb.dissent")
                ("tele" . "flatpak run io.github.kotatogram")
                ("repair" . "guix gc --verify=repair,contents")
                ("tx" . "bash /files/scripts/tmp.sh")
                ("wp" . "bash /files/scripts/wal.sh")
                ("gu" . "guix package -u")
                ("cvi" . "convert original.png -resize 500% resized.png")
                ("cvv" . "ffmpeg -i video.mkv -codec copy video.mp4")
                ("bgv" . "mplayer -quiet -nosound -loop 0 -vo xv vid.mp4")
                ("l" . "ls -g")
                ("ll" . "ls -l")
                ("grep" . "grep --color=auto")
                ("del" . "shred -uvz")
                ("gob" . "/files/scripts/gob.sh")
                ("noise" . "~/.local/bin/noisetorch")
                ("delp" . "wipe -r ")
                ("q" . "exit")
                ("n" . "neofetch")
                ("p" . "pfetch")
                ("ss" . "sudo env TERM=xterm su -")
                ("x" . "xkill")
                ("ee" . "exiftool -recursive -all= ")
                ("ex" . "exiftool -all= && del *original*")
                ("bg" . "feh --bg-fill ")
                ("yt" . "/files/scripts/git/ytfzf/ytfzf --max-threads=4 --thumbnail-quality=maxres --features=hd -t --ii=https://yt.securityops.co")
                ("enc" . "tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz")
                ("dec" . "openssl enc -d -aes256 -in secured.tar.gz | tar xz")
                ("s" . "sensors")
                ("clean" . "/files/scripts/git/cleanall/clearner.sh")
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
                ("chromium" . "nix-shell -p ungoogled-chromium")
                ("vis" . "/home/berkeley/.guix-profile/bin/vis")
                ("news" . "twtxt timeline")
                ("tempo" . "curl 'wttr.in/caxias_do_sul?date=next7'")
                ("bun" . "/home/berkeley/.bun/bin/bun")))
             (environment-variables
              '(("PATH" . "$HOME/.local/bin:/home/berkeley/.bun/bin:$PATH")
                ("NVM_DIR" . "/home/berkeley/.config/nvm")))))
   (service home-xdg-mime-applications-service-type
            (home-xdg-mime-applications-configuration
             (default
              (list
               (cons 'emacs.desktop '("text/plain" "text/troff" "text/xml" "text/x-c" "text/x-c++" "text/x-diff" "text/x-lisp" "text/x-scheme" "text/x-shellscript" "text/x-tex" "image/vnd.djvu"))
               (cons 'lf.desktop '("inode/directory" "x-scheme-handler/ftp" "x-scheme-handler/nfs" "x-scheme-handler/smb" "x-scheme-handler/ssh" "application/x-directory"))
               (cons 'mpv.desktop '("image/gif" "audio/mpeg" "audio/ogg" "audio/opus" "audio/x-opus+ogg" "audio/flac" "video/mp4" "application/octet-stream" "video/mp2t" "video/x-matroska" "video/webm"))
               (cons 'nsxiv.desktop '("image/avif" "image/bmp" "image/jpeg" "image/png" "image/svg+xml" "image/webp"))
               (cons 'foliate.desktop '("application/epub+zip"))
               (cons 'sioyek.desktop '("application/pdf"))))))
   (simple-service 'font-antialias
                   home-fontconfig-service-type
                   (list "~/.local/share/fonts" fontconfig))
   (simple-service 'environment-variables-service
                   home-environment-variables-service-type
                   `(("PATH" . "$HOME/.local/bin:/home/berkeley/.bun/bin:$PATH")
                   ("GUIX_SANDBOX_EXTRA_SHARES" . "/mnt/games" )
                     ("XINITRC" . "$XDG_CONFIG_HOME/.xinitrc")
                     ("GUILE_WARN_DEPRECATED" . "detailed")
                     ("GUILE_LOAD_PATH" . "$HOME/dev/guix_channel/ajatt-tools-guix:$GUILE_LOAD_PATH")
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
                     ("WM" . "xmonad")
                     ("DRI_PRIME" . "1")
                     ("NVM_DIR" . "/home/berkeley/.config/nvm"))))))
