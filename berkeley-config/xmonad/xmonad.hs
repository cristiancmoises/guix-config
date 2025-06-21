import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (isDialog, isFullscreen)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import qualified XMonad.StackSet as W
import XMonad.Actions.MouseResize
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Layout.Magnifier
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Util.SpawnOnce
import XMonad.Actions.SpawnOn
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.FocusNth (swapNth)
import XMonad.Actions.EasyMotion (selectWindow)
import XMonad.Actions.FindEmptyWorkspace (viewEmptyWorkspace, sendToEmptyWorkspace)
import XMonad.Layout.Grid
import XMonad.Layout.PerScreen (ifWider)
import XMonad.Layout.Reflect
import XMonad.Layout.WindowArranger
import XMonad.Layout.Decoration (Theme(..), decoHeight)
import Data.List (find)
import Control.Monad (when)

-- Simplified doFullFloat to avoid type errors
doFullFloat :: ManageHook
doFullFloat = doFloat

main :: IO ()
main = xmonad
  . ewmhFullscreen
  . ewmh
  . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) def
  $ myConfig
  `additionalKeysP` keyBinds

myConfig = def
  { modMask = mod4Mask
  , layoutHook = windowArrange myLayout
  , terminal = "kitty"
  , focusedBorderColor = "#000000"
  , manageHook = myManageHook
  , startupHook = do
      spawnOnce "xrandr --dpi 192"
      spawnOnce "setxkbmap br"
      spawnOnce "xrandr --output HDMI-A-0 --mode 1920x1080 --rate 60.00"
      spawnOnce "xrdb /home/berkeley/.Xresources"
      spawnOnce "picom --backend glx --vsync -b"
      spawnOnce "tor"
      spawnOnce "feh --bg-fill /home/berkeley/wallpapers/background.png"
      spawnOn "1" "flatpak run org.wezfurlong.wezterm"
      spawnOn "2" "/files/scripts/zen.sh"
      spawnOn "3" "kitty"
      spawnOn "4" "mullvad-vpn"
      spawnOn "9" "sleep 2 && pavucontrol" 
      spawnOn "9" "sleep 2 && /home/berkeley/.local/bin/noisetorch" 
      spawnOnce "polybar top-monitor-1"
      spawnOnce "fcitx5 -d -r"
  }

keyBinds :: [(String, X ())]
keyBinds =
  [ ("M-d", spawn "rofi -show run")
  , ("M-0", spawn "flatpak run org.wezfurlong.wezterm")
  , ("M-i", spawn "qbittorrent")
  , ("M-e", runOrRaise "zen" (className =? "Navigator"))
  , ("M-p", runOrRaise "openshot-qt" (className =? "openshot"))
  , ("M-o", runOrRaise "obs" (className =? "obs"))
  , ("M-f", withFocused $ windows . W.sink)
  , ("M-x", spawn "google-chrome")
  , ("M-S-q", return ())
  , ("M-q", kill)
  , ("M-n", spawn "/files/scripts/emacs.sh")
  , ("M-g", spawn "/files/scripts/browser.sh")
  , ("M-m", spawn "alacritty -e sh -c 'cd /files/music/ && cmus'")
  , ("M-S-r", spawn "~/.local/bin/run_anki.sh")
  , ("M-b", spawn "alacritty -e sh -c 'cd /home/berkeley/git/cleanall/clearner.sh'")
  , ("M-a", spawn "/files/scripts/torbrowser.sh")
  , ("M-l", sendToEmptyWorkspace)
  , ("M-t", viewEmptyWorkspace)
  , ("M-z", spawn "flameshot gui")
  , ("M-w", spawn "steam")
  , ("M-v", easySwap)
  , ("M-j",  spawn "/files/scripts/telegram.sh")
  , ("M-k", spawn "/files/scripts/tmp.sh")
  , ("M-ç", spawn "~/.local/bin/noisetorch")
  ]

easySwap :: X ()
easySwap = do
  win <- selectWindow def
  stack <- gets (W.index . windowset)
  let match = find ((win ==) . Just . fst) $ zip stack [0 ..]
  when (match /= Nothing) $
    swapNth (snd $ maybe (error "Impossible") id match)

myManageHook :: ManageHook
myManageHook = composeAll
  [ isDialog --> doFloat
  , className =? "Gimp" --> doFloat
  , isFullscreen --> doFullFloat
  , resource =? "desktop_window" --> doIgnore
  , resource =? "kdesktop" --> doIgnore
  ]

myTheme :: Theme
myTheme = def { decoHeight = 20 }

myLayout =
  mouseResize
    $ spacingRaw True (Border 10 10 10 10) True (Border 10 10 10 10) True
    $ tallLayout
      ||| Full
  where
    tallLayout = reflectHoriz $ Tall 2 (3 / 100) (1 / 2)

toggleLayout :: X ()
toggleLayout = do
  currentLayout <- gets (W.layout . W.workspace . W.current . windowset)
  case description currentLayout of
    "Tall" -> sendMessage $ JumpToLayout "Mirror Tall"
    _ -> sendMessage $ JumpToLayout "Tall"

myXmobarPP :: PP
myXmobarPP =
  def
    { ppSep = cyan " • "
    , ppTitleSanitize = xmobarStrip
    , ppCurrent = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent = red . wrap (yellow "!") (yellow "!")
    , ppOrder = \(ws : l : _ : wins) -> [ws, l, unwords wins]
    , ppExtras = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused = wrap (white "[") (white "]") . cyan . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . vividGreen . ppWindow

ppWindow :: String -> String
ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

cyan, vividGreen, lowWhite, red, white, yellow :: String -> String
cyan = xmobarColor "#8be9fd" ""
vividGreen = xmobarColor "#50fa7b" ""
white = xmobarColor "#f8f8f2" ""
yellow = xmobarColor "#f1fa8c" ""
red = xmobarColor "#ff5555" ""
lowWhite = xmobarColor "#bbbbbb" ""
