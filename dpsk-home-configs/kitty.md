Here's the modified `kitty.conf` configuration with the Tokyo Night theme (night variant) instead of Catppuccin Mocha:

```conf
# ~/.config/kitty/kitty.conf

#: === Tokyo Night Theme ===
foreground              #A9B1D6
background              #1A1B26
selection_foreground    #1A1B26
selection_background    #A9B1D6

# Black
color0                  #32344A
color8                  #444B6A

# Red
color1                  #F7768E
color9                  #F7768E

# Green
color2                  #9ECE6A
color10                 #9ECE6A

# Yellow
color3                  #E0AF68
color11                 #E0AF68

# Blue
color4                  #7AA2F7
color12                 #7AA2F7

# Magenta
color5                  #BB9AF7
color13                 #BB9AF7

# Cyan
color6                  #7DCFFF
color14                 #7DCFFF

# White
color7                  #C0CAF5
color15                 #ACB0D0

# Cursor
cursor                  #A9B1D6
cursor_text_color       #1A1B26

#: === Font Settings ===
font_family             JetBrainsMono Nerd Font
bold_font              auto
italic_font            auto
bold_italic_font       auto
font_size              12.0
disable_ligatures      never

#: === Window Settings ===
window_padding_width   1
window_margin_width    0
background_opacity     0.95
confirm_os_window_close 0
hide_window_decorations titlebar-only

#: === Tab Bar ===
tab_bar_style          powerline
tab_powerline_style    slanted
tab_title_template     "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}"
active_tab_foreground  #16161E
active_tab_background  #7AA2F7
inactive_tab_foreground #A9B1D6
inactive_tab_background #32344A

#: === Keyboard ===
kitty_mod              ctrl+shift

# Vim-like pane navigation
map kitty_mod+h neighboring_window left
map kitty_mod+l neighboring_window right
map kitty_mod+k neighboring_window up
map kitty_mod+j neighboring_window down

# Vim-like tab navigation
map kitty_mod+[ previous_tab
map kitty_mod+] next_tab

# Copy/paste
map kitty_mod+c copy_to_clipboard
map kitty_mod+v paste_from_clipboard

# Font size
map kitty_mod+equal    change_font_size all +1.0
map kitty_mod+minus    change_font_size all -1.0
map kitty_mod+backspace change_font_size all 0

# Scrollback
map kitty_mod+g show_last_command_output
map kitty_mod+e scroll_end

#: === Advanced ===
shell_integration      enabled
allow_remote_control   yes
editor                 nvim
copy_on_select         yes
strip_trailing_spaces  smart

#: === Performance ===
repaint_delay          10
input_delay            3
sync_to_monitor        yes

#: === URL Handling ===
url_color              #7AA2F7
url_style              single
open_url_with          xdg-open
copy_on_select         yes

#: === Mouse ===
mouse_hide_wait        3.0
focus_follows_mouse    yes

#: === Cursor Customization ===
cursor_shape           beam
cursor_beam_thickness  1.5
cursor_blink_interval  0.5
cursor_stop_blinking_after 15.0

wayland_titlebar_color background
linux_display_server wayland
```

### Changes Made

1. Replaced all Catppuccin Mocha color values with Tokyo Night (night variant) colors
2. Updated the following color elements:
   - Foreground, background, selection colors
   - All 16 terminal colors (color0-color15)
   - Tab bar active/inactive colors
   - URL color
   - Cursor colors

The rest of the configuration (keybindings, font settings, window settings, etc.) remains unchanged. The Tokyo Night theme maintains good contrast and readability while providing a different aesthetic with its blue-dominated palette.

For completeness, you might want to update your Neovim theme as well to match. The Tokyo Night theme is available for Neovim as well.
