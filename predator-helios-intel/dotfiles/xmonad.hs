import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers (isDialog, isFullscreen)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import qualified XMonad.StackSet as W
import XMonad.Actions.MouseResize
import XMonad.Util.EZConfig
import XMonad.Util.Loggers
import XMonad.Layout.Spacing
import XMonad.Util.SpawnOnce
import XMonad.Actions.SpawnOn
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.FocusNth (swapNth)
import XMonad.Actions.EasyMotion (selectWindow)
import XMonad.Actions.FindEmptyWorkspace (viewEmptyWorkspace, sendToEmptyWorkspace)
import XMonad.Layout.Reflect
import XMonad.Layout.WindowArranger
import XMonad.Layout.Decoration (Theme(..), decoHeight)
import Data.List (find)
import Control.Monad (when)
import System.Environment (setEnv)

-- Simplified doFullFloat
doFullFloat :: ManageHook
doFullFloat = doFloat

main :: IO ()
main = xmonad
  . ewmhFullscreen
  . ewmh
  . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
  $ myConfig
  `additionalKeysP` keyBinds

myConfig = def
  { modMask = mod4Mask
  , layoutHook = windowArrange myLayout
  , terminal = "wezterm"
  , focusedBorderColor = "#000000"
  , manageHook = myManageHook
  , startupHook = do
      -- Source Guix environment to ensure PATH and other variables are set
      spawn "bash -c 'source $HOME/.guix-home/setup-environment; export PATH'"
      spawn "xrandr --dpi 200"
      io $ setEnv "DRI_PRIME" "1"  -- set in xmonad's env so every spawned app inherits GPU offload
      spawn "modprobe -r dccp sctp rds tipc"
      spawn "xrandr --output HDMI-A-0 --mode 3280x1200 --rate 60.00"
      spawn "/home/berkeley/.local/bin/brightness-step restore" -- re-apply last saved screen brightness
      spawn "xrdb /home/berkeley/.Xresources"
      spawn "tor"
      spawn "mullvad-vpn"
      spawn "feh --bg-fill /home/berkeley/wallpaper/splash"
      spawnOn "1" "wezterm"
      spawnOn "2" "libre"
      spawnOnce "picom -b"     
      spawn "fcitx5 -d -r" -- Ensure fcitx5 is in Guix profile
  }

keyBinds :: [(String, X ())]
keyBinds =
  [ ("M-d", spawn "rofi -show run") -- Changed to spawn and rely on startupHook
  , ("M-0", spawn "/home/berkeley/.guix-home/profile/bin/wezterm")
  , ("M-i", spawn "scrot")
  , ("M-a", spawn "wezterm-gui")
  , ("M-o", spawn "sh -c 'wezterm -e /scripts/batata.sh'")
  , ("M-r", spawn "sh -c 'wezterm -e /usr/bin/turborecorder'")
  , ("M-e", spawn "/home/berkeley/.guix-home/profile/bin/librewolf")
  , ("M-p", runOrRaise "openshot-qt" (className =? "openshot"))
  , ("M-f", withFocused $ windows . W.sink)
  , ("M-S-q", return ())
  , ("M-q", kill)
  , ("M-S-r", spawn "xmonad --recompile && xmonad --restart") -- recompile+reload (M-q is rebound to kill)
  , ("M-n", spawn "scrot")
  , ("M-m", spawn "sh -c 'kitty -e /home/berkeley/.guix-home/profile/bin/cmus & /home/berkeley/.config/cmus/covers.sh'")
  , ("M-l", sendToEmptyWorkspace)
  , ("M-t", viewEmptyWorkspace)
  , ("M-z", spawn "/home/berkeley/.guix-home/profile/bin/flameshot gui")
  , ("M-we", spawn "/home/berkeley/.guix-home/profile/bin/chromium")
  , ("M-v", easySwap)
  , ("M-j", spawn "scrot")
  , ("M-k", spawn "~/scripts/tmp.sh")
  , ("M-ç", spawn "~/.local/bin/noisetorch")
  -- Screen brightness (Acer Fn keys): two-stage dimmer -> hardware backlight, then
  -- xrandr software gamma below the hardware minimum for much darker low-end dimming.
  , ("<XF86MonBrightnessUp>",   spawn "/home/berkeley/.local/bin/brightness-step up")
  , ("<XF86MonBrightnessDown>", spawn "/home/berkeley/.local/bin/brightness-step down")
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
