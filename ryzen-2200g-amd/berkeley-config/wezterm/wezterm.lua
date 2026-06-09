local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- GPU acceleration settings
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.prefer_egl = true

-- Disable close confirmation for tabs and window
config.skip_close_confirmation_for_processes_named = {}
config.window_close_confirmation = 'NeverPrompt'

-- Font configuration
config.font = wezterm.font('Iosevka Nerd Font', { weight = 'Regular', stretch = 'Normal', style = 'Normal' })
config.font_size = 16.0
config.line_height = 1.0

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'
config.colors = {
  background = '#000000', -- True black background
}

-- Background opacity settings
config.window_background_opacity = 0.95
config.macos_window_background_blur = 30

-- Window decoration settings
config.window_decorations = 'RESIZE'
config.window_padding = { left = 5, right = 5, top = 5, bottom = 5 }
config.enable_tab_bar = true
config.use_fancy_tab_bar = false

-- Cursor and animation settings
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.animation_fps = 120
config.max_fps = 144
config.scrollback_lines = 100000
config.use_resize_increments = true

-- Keybindings
local act = wezterm.action
config.keys = {
  { key = 't', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'q', mods = 'CTRL', action = act.CloseCurrentTab { confirm = false } },
  { key = 'v', mods = 'CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'CTRL', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'n', mods = 'CTRL', action = act.ActivatePaneDirection 'Next' },
  { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = 's', mods = 'CTRL|SHIFT', action = act.SpawnCommandInNewTab {
    args = { 'ssh', 'user@remote' }, -- Replace with your SSH details
  } },
}

-- Enable image display
config.term = 'xterm-256color'

-- Status bar updates
wezterm.on('update-right-status', function(window, pane)
  local workspace = window:active_workspace()
  local pane_info = pane:get_title() or 'unknown'
  window:set_right_status(wezterm.format {
    { Text = 'Workspace: ' .. workspace .. ' | Pane: ' .. pane_info },
  })
end)

-- Visual bell for notifications
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'BackgroundColor',
}

-- Ensure Iosevka is available
config.font_dirs = { '/home/' .. os.getenv('USER') .. '/.local/share/fonts' }

return config
