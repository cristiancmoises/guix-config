module Main where

import Termonad
  ( CursorBlinkMode(..), CursorShape(..), Option(..), ShowScrollbar(..),
    TMConfig(..), defaultConfigHooks, defaultConfigOptions, defaultTMConfig,
    FontConfig(..), FontSize(..), ShowTabBar(..), start
  )
import Termonad.Config.Colour
  ( AlphaColour, ColourConfig, addColourExtension, createColour,
    createColourExtension, defaultColourConfig, defaultStandardColours,
    setAlpha
  )
import Data.Colour.SRGB (sRGB24)

-- Font configuration
fontConfig :: FontConfig
fontConfig = FontConfig
  { fontFamily = "Iosevka"
  , fontSize = FontSizePoints 15
  }

-- Color configuration
colourConfig :: ColourConfig (AlphaColour Double)
colourConfig = defaultColourConfig
  { cCursorFgColour = Set $ createColour 143 238 150 -- #8fee96
  , cBackground = Set $ setAlpha 0.95 $ sRGB24 0 0 0 -- 95% opaque black
  }

-- Main Termonad configuration
tmConfig :: TMConfig
tmConfig = defaultTMConfig
  { options = defaultConfigOptions
      { showScrollbar = ShowScrollbarNever
      , cursorBlinkMode = CursorBlinkModeOn
      , shellOverride = Just "/nix/store/fhm0garvc73kk9kqrwxlf4mr3yjsx8pz-fish-3.7.1/bin/fish"
      , cursorShape = CursorShapeBlock
      , showTabBar = ShowTabBarNever
      , fontConfig = fontConfig
      , scrollbackLen = Just 10000
      , enableImages = True
      }
  }

-- Apply color extension
main :: IO ()
main = do
  colourExt <- createColourExte