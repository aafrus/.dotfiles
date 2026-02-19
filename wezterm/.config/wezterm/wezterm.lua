local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- Font
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 11.0

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.animation_fps = 1
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.enable_tab_bar = false

-- Scrollback
config.scrollback_lines = 9999
config.enable_scroll_bar = false

-- Window
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }
config.window_decorations = 'NONE'

-- No confirmation on close
config.window_close_confirmation = 'NeverPrompt'

-- Colors (grey theme)
config.colors = {
  foreground = '#e0e0e0',
  background = '#0a0a0a',
  cursor_bg = '#e0e0e0',
  cursor_fg = '#0a0a0a',
  cursor_border = '#e0e0e0',
  ansi = { '#0a0a0a', '#555555', '#707070', '#888888', '#9e9e9e', '#b3b3b3', '#c7c7c7', '#e0e0e0' },
  brights = { '#333333', '#555555', '#707070', '#888888', '#9e9e9e', '#b3b3b3', '#c7c7c7', '#ffffff' },
}

config.keys = {}

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and #sel > 0 then
        window:copy_to_clipboard(sel, 'Clipboard')
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.PasteFrom 'Clipboard', pane)
      end
    end),
  },
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(-1),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = act.ScrollByLine(1),
  },
}

return config
