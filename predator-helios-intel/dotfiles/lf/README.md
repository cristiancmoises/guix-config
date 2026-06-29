# lf — terminal file manager (+ ueberzugpp image previews on Sway/Wayland)

[`lf`](https://github.com/gokcehan/lf) config with working **image previews under
Sway/Wayland** via **ueberzugpp**.

## Deploy

| file | install path | what |
|------|--------------|------|
| [`lfrc`](./lfrc)       | `~/.config/lf/lfrc`       | lf config — sets `previewer ~/.local/bin/lf/preview`, `preview true` |
| [`colors`](./colors)   | `~/.config/lf/colors`     | color scheme |
| [`lfrun`](./lfrun)     | `~/.local/bin/lf/lfrun`   | wrapper that starts the ueberzugpp daemon, then `lf` — **`alias lf="~/.local/bin/lf/lfrun"`** (in `config.fish` + `.bashrc`) |
| [`preview`](./preview) | `~/.local/bin/lf/preview` | the previewer (text/image dispatch) |
| [`cleaner`](./cleaner) | `~/.local/bin/lf/cleaner` | clears the previous preview |

```sh
install -Dm644 lfrc   ~/.config/lf/lfrc
install -Dm755 colors ~/.config/lf/colors
install -Dm755 lfrun preview cleaner -t ~/.local/bin/lf/
```

## Image previews under Sway/Wayland — the fix

ueberzugpp (the system package, 2.9.x) is the previewer. The original scripts only
drew images under **pure X11** and otherwise fell back to inline `chafa --format=kitty`,
which lf's preview-pane redraw wipes — so on Sway you got **no image**. And when ueberzug
*did* run it used the **X11 overlay** backend, which mispositions under Sway/XWayland.

Two changes make it work on Wayland:

1. **`lfrun`** picks a Wayland-correct ueberzugpp **output backend per terminal** and
   starts the daemon with it:
   ```sh
   case "${TERM_PROGRAM:-}|${TERM:-}" in
       *WezTerm*|*kitty*|*ghostty*) UB_OUTPUT=kitty ;;   # kitty graphics protocol
       *foot*)                      UB_OUTPUT=sixel ;;   # sixel
       *)                           UB_OUTPUT=kitty ;;
   esac
   ueberzugpp layer -s -o "$UB_OUTPUT" <"$FIFO_UEBERZUG" &
   ```
2. **`preview`** uses the ueberzug daemon whenever its FIFO is up (instead of gating to
   X11): `if [ -n "$FIFO_UEBERZUG" ] && [ -p "$FIFO_UEBERZUG" ] && command -v ueberzugpp …`.

The terminal must speak the chosen protocol — **WezTerm/kitty/ghostty** do kitty
graphics, **foot** does sixel (both Wayland-native, correctly positioned). If a terminal
supports neither, set `UB_OUTPUT=wayland` (ueberzugpp's own layer-shell overlay).

## GIF + video thumbnails

`preview` also renders **gif and video** thumbnails (cached in `~/.cache/lf/`, pruned
after a day):

- **GIF** → static **first frame** via `ffmpeg -vframes 1` (ueberzugpp shows only the
  first frame of an animated gif anyway), shown through ueberzug. Replaces the old janky
  `mpv --vo=tct` terminal-blocks path.
- **Video** (`mp4/mkv/webm/avi/mov/flv/wmv/m4v/mpg/mpeg/ts/m2ts/ogv`) → thumbnail via
  **`ffmpegthumbnailer`**, falling back to **`ffmpeg`** (seek 3 s for a non-black frame,
  then frame 0 for very short clips). Robust if either tool is missing.

(Also handled the same way: svg, pdf, cbz/cbr/cbt, epub.)

> Apply lf changes: just relaunch `lf` (the wrapper re-reads these scripts each run).
