# WezTerm Configuration with Nerd Fonts, Catppuccin Theme, and Vim Syntax

Here's a comprehensive WezTerm configuration that includes:
- Nerd Fonts support
- Catppuccin Mocha theme (you can change to Latte, Frappé, or Macchiato if preferred)
- Vim-like key bindings
- Additional quality-of-life improvements

```lua
local wezterm = require 'wezterm'
local act = wezterm.action

-- Helper function to apply Catppuccin Mocha colors
local function setup_catppuccin_mocha()
  return {
    foreground = "#cdd6f4",
    background = "#1e1e2e",

    cursor_bg = "#f5e0dc",
    cursor_fg = "#1e1e2e",
    cursor_border = "#f5e0dc",

    selection_fg = "#1e1e2e",
    selection_bg = "#f5e0dc",

    scrollbar_thumb = "#585b70",
    split = "#181825",

    ansi = {
      "#45475a", -- black
      "#f38ba8", -- red
      "#a6e3a1", -- green
      "#f9e2af", -- yellow
      "#89b4fa", -- blue
      "#f5c2e7", -- magenta
      "#94e2d5", -- cyan
      "#bac2de", -- white
    },
    brights = {
      "#585b70", -- bright black
      "#f38ba8", -- bright red
      "#a6e3a1", -- bright green
      "#f9e2af", -- bright yellow
      "#89b4fa", -- bright blue
      "#f5c2e7", -- bright magenta
      "#94e2d5", -- bright cyan
      "#a6adc8", -- bright white
    },

    tab_bar = {
      background = "#181825",
      active_tab = {
        bg_color = "#cba6f7",
        fg_color = "#1e1e2e",
      },
      inactive_tab = {
        bg_color = "#313244",
        fg_color = "#cdd6f4",
      },
      inactive_tab_hover = {
        bg_color = "#45475a",
        fg_color = "#cdd6f4",
      },
      new_tab = {
        bg_color = "#181825",
        fg_color = "#cdd6f4",
      },
      new_tab_hover = {
        bg_color = "#cba6f7",
        fg_color = "#1e1e2e",
      },
    },
  }
end

return {
  -- General settings
  font = wezterm.font_with_fallback({
    -- Primary font with Nerd Font symbols
    { family = "FiraCode Nerd Font", weight = "Regular", stretch = "Normal", italic = false },
    -- Fallback fonts
    "JetBrains Mono",
    "Noto Sans CJK SC",
    "Symbols Nerd Font",
  }),
  font_size = 12.0,
  line_height = 1.2,
  harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
  warn_about_missing_glyphs = false,

  -- Color scheme
  color_schemes = {
    ["Catppuccin Mocha"] = setup_catppuccin_mocha(),
  },
  color_scheme = "Catppuccin Mocha",

  -- Window settings
  window_padding = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 5,
  },
  window_decorations = "RESIZE",
  window_close_confirmation = "NeverPrompt",
  enable_scroll_bar = true,
  adjust_window_size_when_changing_font_size = false,
  hide_tab_bar_if_only_one_tab = true,

  -- Tab bar settings
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,
  show_tab_index_in_tab_bar = true,

  -- Cursor settings
  default_cursor_style = "BlinkingBar",
  cursor_blink_rate = 800,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",

  -- Key bindings (Vim-like)
  disable_default_key_bindings = true,
  keys = {
    -- Vim-like pane navigation
    { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

    -- Vim-like tab navigation
    { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "p", mods = "CTRL", action = act.ActivateTabRelative(-1) },

    -- Copy/paste
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

    -- Font size
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },

    -- Misc
    { key = "f", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "u", mods = "CTRL|SHIFT", action = act.CharSelect{ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" } },
    { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane{ confirm = true } },
  },

  -- Mouse bindings
  mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = act.OpenLinkAtMouseCursor,
    },
  },

  -- Hyperlink rules
  hyperlink_rules = {
    -- Matches: http, https
    {
      regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
      format = "$0",
    },
    -- Matches: email addresses
    {
      regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
      format = "mailto:$0",
    },
  },
}
```

## Installation Instructions

1. Save this configuration to `~/.wezterm.lua` (or `~/.config/wezterm/wezterm.lua` on Linux)

2. Make sure you have the required Nerd Fonts installed:
   - Download and install "FiraCode Nerd Font" or your preferred Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/)
   - Configure your terminal to use the Nerd Font

3. Additional recommendations:
   - For full Vim keybindings in your shell, consider using `fish` with `vi` mode or `zsh` with `bindkey -v`
   - Install a Vim plugin manager like vim-plug and add syntax highlighting plugins

## Customization Options

1. To use a different Catppuccin variant, replace the color values with one of these:
   - Latte (light): https://github.com/catppuccin/catppuccin#-palette
   - Frappé: https://github.com/catppuccin/catppuccin#-palette-1
   - Macchiato: https://github.com/catppuccin/catppuccin#-palette-2

2. To change the font, modify the `font` section with your preferred Nerd Font.

3. Adjust key bindings in the `keys` table to match your preferences.

This configuration provides a beautiful, functional terminal environment with Vim-like navigation and all the benefits of Nerd Fonts for icons and symbols.
