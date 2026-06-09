if status is-interactive
function fish_greeting
    echo ""
end
alias vpn='mullvad relay set location br-sao-wg-201'
alias rustdesk='flatpak run com.rustdesk.RustDesk'
alias gi='eval (ssh-agent -c) && ssh-add ~/.ssh/securityops'
alias android='flatpak run com.google.AndroidStudio'
alias disc='flatpak run so.libdb.dissent'
alias tele='flatpak run io.github.kotatogram'
alias repair='guix gc --verify=repair,contents'
#alias zen='flatpak run app.zen_browser.zen'
alias tx='bash /files/scripts/tmp.sh'
alias wp='bash /files/scripts/wal.sh'
alias gu='guix package -u'
alias cvi='convert original.png -resize 500% resized.png'
alias cvv='ffmpeg -i video.mkv -codec copy video.mp4'
alias bgv='mplayer -quiet -nosound -loop 0 -vo xv vid.mp4'
alias l='ls -g'
alias ll='ls -l'
alias grep='grep --color=auto'
alias del='shred -uvz'
alias gob='/files/scripts/gob.sh'
alias noise='~/.local/bin/noisetorch'
alias delp='wipe -r '
alias q='exit'
alias n='neofetch'
alias p='pfetch'
alias ss='sudo env TERM=xterm su -'
alias x='xkill'
alias ee='exiftool -recursive -all= '
alias ex='exiftool -all= && del *original*'
alias bg='feh --bg-fill '
alias yt='/files/scripts/git/ytfzf/ytfzf --max-threads=4 --thumbnail-quality=maxres --features=hd -t --ii=https://yt.securityops.co'
alias enc='tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz'
alias dec='openssl enc -d -aes256 -in secured.tar.gz | tar xz'
alias s='sensors'
alias clean='/files/scripts/git/cleanall/clearner.sh'
alias e='cd ..'
alias up='/files/scripts/git/up.sh'
alias 7='7z x'
alias ia='/usr/local/bin/yai'
alias wall='cp /home/berkeley/Downloads/wall.jpg /tmp  && bg /tmp/wall.jpg'
alias help='del /tmp/*jpg /tmp/*webp /tmp/*png /tmp/*mp4 /tmp/*gif /tmp/*jpeg && rm -rf ad*'
alias now='cd /tmp && tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz && mv secured.tar.gz /files'
alias bb='bg /files/downloads/preto.jpg'
alias xx='bg /var/cache/wallpaper.png'
alias hot='cp /files/secured.tar.gz /tmp && cd /tmp/ && openssl enc -d -aes256 -in secured.tar.gz | tar xz'
alias big='find /home/berkeley -type f -size +1000M > /home/berkeley/big.txt'
alias zip='7z a arquivos'
alias h='haunt build && haunt serve'
alias vid='/files/scripts/vid.sh'
alias zap='/files/scripts/zap.sh'
alias torup='/files/scripts/torup.sh'
alias gangsta='/files/scripts/music.sh'
alias sss='/files/scripts/sss.sh'
alias lf="~/.local/bin/lf/lfrun"
alias gif="/files/scripts/gif.sh"
alias giff="/files/scripts/gif2.sh"
alias br="/files/scripts/br.sh"
alias wik="/files/scripts/wiki.sh"
alias upp="/files/scripts/up.sh"
alias rec="/files/scripts/record/record"
alias post="/files/scripts/copycat.sh"
alias tornado="/files/scripts/tornado.sh"
alias torb="/files/scripts/torbrowser.sh"
alias ice="/files/scripts/icecat.sh"
alias bw="bg /home/berkeley/Downloads/wall2.jpg"
alias mp="/files/scripts/mpv.sh"
alias term="/files/scripts/terminator.sh"
alias s1="/files/scripts/server.sh"
alias gitlfs="/files/scripts/lfs.sh"
#alias test="/virt/test.sh"
alias class="mpv /files/music/Classical/classic/*"
alias cam="/files/scripts/cam.sh"
alias c="clear"
alias chromium="nix-shell -p ungoogled-chromium"
alias vis="/home/berkeley/.guix-profile/bin/vis"
alias news="twtxt timeline"
alias tempo="curl 'wttr.in/caxias_do_sul?date=next7'"
end
alias bun="/home/berkeley/.bun/bin/bun"
export PATH="$HOME/.local/bin:$PATH"
/usr/local/bin/starship init fish | source
set -x NVM_DIR /home/berkeley/.config/nvm
bass source /home/berkeley/.config/nvm/nvm.sh --no-use
bash /files/scripts/process.sh
curl 'wttr.in/Caxias_do_Sul?format=4'
