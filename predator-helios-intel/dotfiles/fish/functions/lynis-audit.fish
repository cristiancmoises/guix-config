function lynis-audit --description 'Full Lynis system audit with the securityops tuned profile'
    set -l prof /etc/lynis/custom.prf
    set -l lyn /run/current-system/profile/bin/lynis
    if test -f $prof
        sudo $lyn audit system --profile $prof $argv
    else
        echo "lynis-audit: $prof not found yet — run a 'sudo guix system reconfigure' first." >&2
        echo "lynis-audit: auditing WITHOUT the tuned profile for now." >&2
        sudo $lyn audit system $argv
    end
end
