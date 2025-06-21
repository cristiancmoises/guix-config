# Bash initialization for interactive non-login shells and
# for remote shells (info "(bash) Bash Startup Files").

# Export 'SHELL' to child processes.  Programs such as 'screen'
# honor it and otherwise use /bin/sh.
export SHELL

if [[ $- != *i* ]]
then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile

    # Don't do anything else.
    return
fi

# Source the system-wide file.
[ -f /etc/bashrc ] && source /etc/bashrc
alias l='ls -g -p --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'
alias del='shred -uvz'
alias noise='~/.local/bin/noisetorch'
alias delp='wipe -r '
alias q='exit'
alias n='neofetch'
alias p='pfetch'
alias ss='sudo su'
alias xxx='xkill'
alias ee='exiftool -recursive -all= '
alias ex='exiftool -all= '
alias bg='feh --bg-fill '
alias yt='/files/scripts/git/ytfzf/ytfzf'
alias enc='tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz'
alias dec='openssl enc -d -aes256 -in secured.tar.gz | tar xz'
alias s='sensors'
alias clean='/files/scripts/git/cleanall/clearner.sh'
alias e='cd ..'
alias up='/files/scripts/git/up.sh'
alias 7='7z x'
alias wall='bg /files/pictures/wall.jpg'
alias nice='bg /tmp/0.jpg'
alias help='del /tmp/*jpg /tmp/*webp /tmp/*png /tmp/*mp4 /tmp/*gif /tmp/*jpeg && rm -rf ad*'
alias now='cd /tmp && tar -czf - * | openssl enc -e -aes256 -out secured.tar.gz && mv secured.tar.gz /files'
alias bb='bg /home/berkeley/Downloads/preto.jpg'
alias hot='cp /files/secured.tar.gz /tmp && cd /tmp/ && openssl enc -d -aes256 -in secured.tar.gz | tar xz'
alias big='find / -type f -size +1000M > /home/berkeley/big.txt'
alias zip='7z a arquivos'
alias h='haunt build && haunt serve'
alias t='texstudio'
alias vid='/files/scripts/vid.sh'
alias zap='zap.sh'
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
