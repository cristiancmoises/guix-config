# Predator — dotfiles

Per-user dotfiles for the two display-stack variants ([see the variant table](../README.md#️-sway-wayland-vs-xlibre-x11--benefits--differences)):

| File | Used by | Purpose |
|------|---------|---------|
| [`xmonad.hs`](./xmonad.hs) | **XLibre / X11** variant | xmonad window-manager config (`~/.xmonad/xmonad.hs`) |
| [`sway/config`](./sway/config) | **Sway / Wayland** variant | Sway config (`~/.config/sway/config`) |
| [`brightness-step`](./brightness-step) | XLibre | two-stage screen dimmer (backlight + xrandr gamma) |
| [`dual-monitor`](./dual-monitor) | XLibre | HDMI/DP hotplug helper |
| [`rofi-brightness.sh`](./rofi-brightness.sh) | XLibre | rofi brightness applet |
| [`gaming/`](./gaming/) | both | RDR2 / GTA V Proton tuning, Steam reconnect, vkBasalt |
| [`lf/`](./lf/) | both (terminal) | `lf` file manager + **ueberzugpp image previews** (Sway/Wayland fix) |

---

## 🩹 xmonad — fixing the "mod key sometimes stops working"

**Symptom:** the Super (mod) key occasionally does nothing; xmonad seems to "stop working."

**Root causes found & fixed in `xmonad.hs`:**

1. **PATH was never set in xmonad's own environment (main cause).** The old
   `startupHook` ran `spawn "bash -c 'source …/setup-environment; export PATH'"`.
   `spawn` forks a **throwaway subshell** — the `export` died with it and xmonad's
   environment was never touched. So every keybinding that launches a **bare
   command** (`rofi` on `M-d`, `scrot`, `kitty`, `wezterm-gui`, `mullvad-vpn`, …)
   silently failed to find its binary, while binds using **absolute paths** worked.
   That is exactly what "the mod key sometimes works, sometimes not" feels like —
   it depends on which binding you press.
   **Fix:** set PATH (and `DRI_PRIME`) **in-process** with `io $ setEnv "PATH" …`
   at the top of `startupHook`, so every later `spawn` inherits it.

2. **`M-we` typo** (was `M-w` for steam): `"M-we"` is an invalid EZConfig key
   string, which `mkKeymap` **silently drops** — so that binding did nothing.
   **Fix:** corrected to `M-w` (launches chromium).

3. Removed a `spawn "modprobe -r …"` that needs root and always failed silently
   (those modules are already blacklisted on the kernel command line).

**Runtime causes (not config bugs) — how to recover:**

- **fcitx5 (IME) grabbing keys.** When an app has input-method focus, fcitx5 can
  swallow key events. If the mod key dies inside one app, click another window, or
  set fcitx5's trigger key off `Super` in `~/.config/fcitx5/config`.
- **A fullscreen app (game/video) holds the keyboard grab** — the mod key won't
  reach xmonad until you leave fullscreen. Use the app's windowed mode, or
  `Ctrl+Alt+F2` → kill it.
- **`M-v` (EasyMotion `selectWindow`) is modal** — it grabs the keyboard and waits
  for a selection; press `Escape` to cancel if the overlay didn't appear.
- **Hard reset:** `M-S-r` recompiles + restarts xmonad (`xmonad --recompile &&
  xmonad --restart`); re-grabs all keys.

**Apply after editing:** `xmonad --recompile && xmonad --restart` (or `M-S-r`).
This config is validated — it recompiles clean against xmonad 0.18 / xmonad-contrib.

---

## ⌨️ Keybind parity — xmonad ↔ Sway

The Sway config reproduces the xmonad keybinds **1:1** so muscle memory carries
over. X11-only commands are swapped for the Wayland-native equivalent. `$mod` =
`Super`. Bindings that collided with Sway's stock focus/layout keys were
overridden on purpose, and the displaced ops relocated (see the table's notes).

| Key | xmonad (X11) | Sway (Wayland) | Note |
|-----|--------------|----------------|------|
| `M-Return` / `M-0` / `M-a` | wezterm | `exec wezterm` | |
| `M-o` | wezterm → `batata.sh` | same | |
| `M-r` | wezterm → `turborecorder` | same | Sway resize-mode → `$mod+Shift+r` |
| `M-d` | `rofi -show run` | `exec rofi -show run` | rofi runs under XWayland — same launcher as xmonad. (`fuzzel` was **not installed**, which made WIN+d a no-op — fixed.) |
| `M-S-d` | — | `exec rofi -show drun` | bonus: app (desktop-entry) launcher |
| `M-e` | librewolf | `exec librewolf` | Sway split-toggle → `$mod+Shift+s` |
| `M-w` | chromium | `exec chromium` | Sway tabbed → `$mod+Shift+w` |
| `M-m` | cmus (in kitty) | `exec kitty -e cmus` | |
| `M-p` | openshot | `exec openshot-qt` | |
| `M-k` | `~/scripts/tmp.sh` | same | |
| `M-ç` | noisetorch | `exec … noisetorch` | the ABNT2 `ç` key = keysym `ccedilla` |
| `M-i` / `M-n` / `M-j` | scrot | `exec grim …png` | scrot is X11 → **grim** |
| `M-z` | flameshot gui | `exec flameshot gui` | |
| `M-q` | kill window | `kill` | |
| `M-b` | toggle xmobar struts | `exec killall -SIGUSR1 waybar` | SIGUSR1 toggles waybar |
| `M-h` | shrink master | `resize shrink width` | |
| `M-Tab` | focus next | `focus next` | |
| `M-1`…`9` / `M-S-1`…`9` | workspace / move-to-ws | same | Sway ws10 (`$mod+0`) dropped (xmonad has 9) |
| arrows | — | focus / move | **focus/move is on arrows** since `h/j/k` are app/resize binds (`l` is now free — screen lock removed) |
| `XF86MonBrightness{Up,Down}` | `brightness-step` (xrandr gamma) | `brightnessctl` | gamma is X11-only → brightnessctl on Wayland |

### Bindings with **no Sway equivalent** (flagged in the config)

| xmonad | Why no equivalent | What Sway does instead |
|--------|-------------------|------------------------|
| `M-Space` — cycle layout (Tall↔Full) | per request | **`$mod+Space` = MAXIMIZE** (`fullscreen toggle`) — the "Full" half of xmonad's Space |
| `M-l` — send-to-empty-workspace | Sway has no "empty workspace" primitive | **`$mod+l` = cycle layout view** (`split→tabbed→stacking`) — the "change layout" half of xmonad's Space (`l` = Layout; the screen lock was removed) |
| `M-t` — view-empty-workspace | same | `$mod+t` = toggle focus tiling↔floating |
| `M-v` — EasyMotion window-swap | no EasyMotion on wlroots | `$mod+v` = `splitv` |
| `M-f` — `W.sink` (un-float) | — | `$mod+f` = **`floating disable`** (un-float — exact M-f match); maximize is `$mod+space` |

**Apply after editing the Sway config:** `$mod+Shift+c` (reload) — or
`swaymsg reload`. Validate offline with `sway --validate -c ~/.config/sway/config`.

### Troubleshooting — "my Sway keybinds aren't working"

- **`$mod` is `Mod4` = the Super/WIN key** (`set $mod Mod4`). WIN+d opens
  `rofi -show run`.
- **The whole modkey is dead (no `$mod+…` works at all, but typing works)?** The
  **Acer WIN-key lock** — the key with the **lock + Windows** icon disables Super at
  the firmware level so it emits *nothing*; `Mod4` never fires. Toggle it off (often
  `Fn` + that key). See the modkey section above. *(This is the #1 cause and looks
  exactly like "keybinds broke" — it bit us on a generation switch.)*
- **One specific window command does nothing (e.g. `$mod+Space` won't maximize)?**
  **Sway does NOT support inline `#` comments on command lines** — the comment text is
  parsed as command *arguments*, so strict verbs silently fail while `exec` and
  tolerant verbs (`layout`, `focus`) survive, which masks the bug. Example:
  `bindsym $mod+space fullscreen toggle  # MAXIMIZE…` →
  `Invalid fullscreen command (expected at most 2 arguments, got 10)` → no-op. This
  broke `fullscreen`/`floating`/`splitv`/`splith`/`resize` here. **Keep `bindsym`
  command lines comment-free** (put notes on their own line). Diagnose by running the
  exact command: `swaymsg 'fullscreen toggle  # x'` → `success: false` confirms it.
- **Launcher does nothing?** `fuzzel`/`wmenu`/`grim`/`slurp` are provided by
  `config-sway.scm` (system) — if you're not actually booted on the Sway
  generation they're missing. The launcher now uses **rofi** (from `home.scm`),
  which is always present; `grim`/`slurp` were added to `home.scm` so the
  screenshot binds also work regardless of the system generation.
- **Nothing reloads?** The keybinds live in `~/.config/sway/config`, **not** in
  `config-sway.scm`. After editing, `swaymsg reload` (or WIN+Shift+c) from inside
  the running Sway session — a `guix system reconfigure` does **not** re-read
  this user dotfile.
- **Not in Sway at all?** Check `echo $XDG_SESSION_TYPE` / `pgrep sway`. If you're
  still in the XLibre/xmonad X11 session, the Sway binds don't apply — log into
  the greetd → Sway session first.

### Modkey — Super/WIN (Mod4) and the Acer Windows-key lock

Both variants use **`Mod4` = the Super/WIN key** (`modMask = mod4Mask` in xmonad,
`set $mod Mod4` in Sway). If WIN "does nothing" as the modkey while only ALT
works, the X mapping is almost certainly fine (`xmodmap -pm` shows `Super_L`/
`Super_R` on `mod4`) — the cause is usually one of:

- **The Acer Windows-key lock (most common).** On the Predator the WIN key
  doubles as a **lock** (a key with a lock + Windows icon) so you don't hit it
  mid-game. **When locked it emits no event at all**, so `Mod4` never fires.
  Toggle it off on the keyboard (the lock/Windows key, often with `Fn`) — then
  `Mod4` works with zero config changes.
- **fcitx5 was grabbing `Super+space`.** Its `EnumerateGroupForward/Backward`
  hotkeys were `Super+space` / `Shift+Super+space`; cleared in
  [`fcitx5/config`](./fcitx5/config) so the WM owns Super. Apply: `fcitx5 -r &`.

### xmonad stops working after a VT switch

`Ctrl+Alt+Fn` to another VT and back leaves modifier keys "stuck" (the key
*release* is delivered to the other VT, so X on `:0` still thinks Ctrl/Alt are
held) and can drop xmonad's key grabs — so keybinds stop matching. Since the
modkey itself can't be used to recover, run [`fix-xmonad`](./fix-xmonad) from any
terminal: it releases stuck modifiers (via `xdotool`, now in `home.scm`) and
re-grabs everything (`xmonad --restart`). Quick manual fix without it: tap
`Ctrl`, then `Alt`, once each.
