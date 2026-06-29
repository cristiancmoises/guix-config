function bg --description 'bg <image>: set the wallpaper; with no file arg, the job-control builtin'
    # Superset of the `bg` builtin: an existing image file -> set wallpaper,
    # anything else (no args, a %job, a PID) -> the real job-control builtin.
    if test (count $argv) -ge 1; and test -f "$argv[1]"
        setbg $argv
    else
        builtin bg $argv
    end
end
