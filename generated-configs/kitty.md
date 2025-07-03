``````el
# ~/.config/kitty/kitty.conf

#: === Catppuccin Mocha Theme (Official Colors) ===
# The basic colors
foreground              #cdd6f4
background              #1e1e2e
selection_foreground    #1e1e2e
selection_background    #f5e0dc

# Cursor colors
cursor                  #f5e0dc
cursor_text_color       #1e1e2e

# URL underline color when hovering with mouse
url_color               #f5e0dc

# Kitty window border colors
active_border_color     #b4befe
inactive_border_color   #6c7086
bell_border_color       #f9e2af

# OS Window titlebar colors
wayland_titlebar_color  system
macos_titlebar_color    system

# Tab bar colors
active_tab_foreground   #11111b
active_tab_background   #cba6f7
inactive_tab_foreground #cdd6f4
inactive_tab_background #181825
tab_bar_background      #11111b

# Colors for marks (marked text in the terminal)
mark1_foreground #1e1e2e
mark1_background #b4befe
mark2_foreground #1e1e2e
mark2_background #cba6f7
mark3_foreground #1e1e2e
mark3_background #74c7ec

# The 16 terminal colors

# black
color0 #45475a
color8 #585b70

# red
color1 #f38ba8
color9 #f38ba8

# green
color2 #a6e3a1
color10 #a6e3a1

# yellow
color3 #f9e2af
color11 #f9e2af

# blue
color4 #89b4fa
color12 #89b4fa

# magenta
color5 #f5c2e7
color13 #f5c2e7

# cyan
color6 #94e2d5
color14 #94e2d5

# white
color7 #bac2de
color15 #a6adc8

#: === Font Configuration ===
font_family             JetBrainsMono Nerd Font
bold_font               JetBrainsMono Nerd Font Bold
italic_font             JetBrainsMono Nerd Font Italic
bold_italic_font        JetBrainsMono Nerd Font Bold Italic
font_size               12.0
disable_ligatures       never

# Adjust the line height
adjust_line_height      0
adjust_column_width     0

#: === Window Settings ===
remember_window_size    yes
initial_window_width    640
initial_window_height   400
window_padding_width    4
window_margin_width     0
single_window_margin_width -1
window_border_width     0.5pt
draw_minimal_borders    yes
placement_strategy      center
active_border_color     #b4befe
inactive_border_color   #6c7086
hide_window_decorations no
window_logo_path        none
window_logo_position    bottom-right
window_logo_alpha       0.5
resize_debounce_time    0.1
resize_draw_strategy    static
resize_in_steps         no
visual_window_select_characters 1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ
confirm_os_window_close 0

#: === Tab Bar Configuration ===
tab_bar_edge            bottom
tab_bar_margin_width    0.0
tab_bar_margin_height   0.0 0.0
tab_bar_style           powerline
tab_bar_align           left
tab_bar_min_tabs        2
tab_switch_strategy     previous
tab_fade                0.25 0.5 0.75 1
tab_separator           " ┇"
tab_powerline_style     slanted
tab_activity_symbol     none
tab_title_template      "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}"
active_tab_title_template none

#: === Color Scheme ===
background_opacity      0.95
background_image        none
background_image_layout tiled
background_image_linear no
dynamic_background_opacity no
background_tint         0.0
dim_opacity             0.75

#: === Advanced Settings ===
shell                   .
editor                  nvim
close_on_child_death    no
allow_remote_control    yes
listen_on               none
update_check_interval   24
startup_session         none
clipboard_control       write-clipboard write-primary
clipboard_max_size      64
allow_hyperlinks        yes
shell_integration       enabled
allow_cloning           ask
clone_source_strategies virt_env,conda,env_var,path
term                    xterm-kitty

#: === Keyboard Shortcuts ===
kitty_mod               ctrl+shift
clear_all_shortcuts     no

# Clipboard
map kitty_mod+c         copy_to_clipboard
map kitty_mod+v         paste_from_clipboard
map kitty_mod+s         paste_from_selection
map shift+insert        paste_from_selection
map kitty_mod+o         pass_selection_to_program

# Scrolling
map kitty_mod+up        scroll_line_up
map kitty_mod+k         scroll_line_up
map kitty_mod+down      scroll_line_down
map kitty_mod+j         scroll_line_down
map kitty_mod+page_up   scroll_page_up
map kitty_mod+page_down scroll_page_down
map kitty_mod+home      scroll_home
map kitty_mod+end       scroll_end
map kitty_mod+z         scroll_to_prompt -1
map kitty_mod+x         scroll_to_prompt 1
map kitty_mod+h         show_scrollback
map kitty_mod+g         show_last_command_output

# Window management
map kitty_mod+enter     new_window
map cmd+enter           new_window
map kitty_mod+n         new_os_window
map cmd+n               new_os_window
map kitty_mod+w         close_window
map kitty_mod+]         next_window
map kitty_mod+[         previous_window
map kitty_mod+f         move_window_forward
map kitty_mod+b         move_window_backward
map kitty_mod+`         move_window_to_top
map kitty_mod+r         start_resizing_window
map cmd+r               start_resizing_window
map kitty_mod+1         first_window
map kitty_mod+2         second_window
map kitty_mod+3         third_window
map kitty_mod+4         fourth_window
map kitty_mod+5         fifth_window
map kitty_mod+6         sixth_window
map kitty_mod+7         seventh_window
map kitty_mod+8         eighth_window
map kitty_mod+9         ninth_window
map kitty_mod+0         tenth_window

# Tab management
map kitty_mod+right     next_tab
map shift+cmd+]         next_tab
map ctrl+tab            next_tab
map kitty_mod+left      previous_tab
map shift+cmd+[         previous_tab
map ctrl+shift+tab      previous_tab
map kitty_mod+t         new_tab
map cmd+t               new_tab
map kitty_mod+q         close_tab
map cmd+w               close_tab
map shift+cmd+w         close_os_window
map kitty_mod+.         move_tab_forward
map kitty_mod+,         move_tab_backward
map kitty_mod+alt+t     set_tab_title
map shift+cmd+i         set_tab_title

# Layout management
map kitty_mod+l         next_layout
map kitty_mod+alt+t     goto_layout tall
map kitty_mod+alt+s     goto_layout stack
map kitty_mod+alt+p     goto_layout fat
map kitty_mod+alt+g     goto_layout grid
map kitty_mod+alt+h     goto_layout horizontal
map kitty_mod+alt+v     goto_layout vertical

# Font sizes
map kitty_mod+equal     change_font_size all +2.0
map kitty_mod+plus      change_font_size all +2.0
map kitty_mod+kp_add    change_font_size all +2.0
map cmd+plus            change_font_size all +2.0
map cmd+equal           change_font_size all +2.0
map kitty_mod+minus     change_font_size all -2.0
map kitty_mod+kp_subtract change_font_size all -2.0
map cmd+minus           change_font_size all -2.0
map kitty_mod+backspace change_font_size all 0
map cmd+0               change_font_size all 0

# Select and act on visible text
map kitty_mod+e         open_url_with_hints
map kitty_mod+p>f       kitten hints --type path --program -
map kitty_mod+p>shift+f kitten hints --type path
map kitty_mod+p>l       kitten hints --type line --program -
map kitty_mod+p>w       kitten hints --type word --program -
map kitty_mod+p>h       kitten hints --type hash --program -
map kitty_mod+p>n       kitten hints --type linenum

# Miscellaneous
map kitty_mod+f11       toggle_fullscreen
map kitty_mod+f10       toggle_maximized
map kitty_mod+u         kitten unicode_input
map kitty_mod+f2        edit_config_file
map kitty_mod+escape    kitty_shell window
map kitty_mod+a>m       set_background_opacity +0.1
map kitty_mod+a>l       set_background_opacity -0.1
map kitty_mod+a>1       set_background_opacity 1
map kitty_mod+a>d       set_background_opacity default
map kitty_mod+delete    clear_terminal reset active
map opt+cmd+r           clear_terminal reset active

#: === Mouse Actions ===
mouse_hide_wait         3.0
focus_follows_mouse     no
pointer_shape_when_grabbed arrow
default_pointer_shape   beam
pointer_shape_when_dragging beam

# Mouse button mappings
mouse_map left click ungrabbed mouse_handle_click selection link prompt
mouse_map shift+left click grabbed,ungrabbed mouse_handle_click selection link prompt
mouse_map ctrl+shift+left release grabbed,ungrabbed mouse_handle_click link
mouse_map ctrl+shift+left press grabbed discard_event
mouse_map middle release ungrabbed paste_from_selection
mouse_map left press ungrabbed mouse_selection normal
mouse_map ctrl+alt+left press ungrabbed mouse_selection rectangle
mouse_map left doubleclick ungrabbed mouse_selection word
mouse_map left tripleclick ungrabbed mouse_selection line
mouse_map ctrl+alt+left tripleclick ungrabbed mouse_selection line_from_point
mouse_map right press ungrabbed mouse_selection extend
mouse_map shift+middle release ungrabbed,grabbed paste_selection
mouse_map shift+middle press grabbed discard_event
mouse_map shift+left press ungrabbed,grabbed mouse_selection normal

#: === Performance Tuning ===
repaint_delay           10
input_delay             3
sync_to_monitor         yes

#: === Terminal Bell ===
enable_audio_bell       yes
visual_bell_duration    0.0
visual_bell_color       none
window_alert_on_bell    yes
bell_on_tab             "🔔 "
command_on_bell         none
bell_path               none

#: === Window Layout ===
enabled_layouts         *
window_resize_step_cells 2
window_resize_step_lines 2

#: === Advanced ===
copy_on_select          no
strip_trailing_spaces   never
select_by_word_characters @-./_~?&=%+#
click_interval          -1.0
mouse_map middle release ungrabbed paste_from_selection

#: === OS Specific ===
macos_option_as_alt     no
macos_hide_from_tasks   no
macos_quit_when_last_window_closed no
macos_window_resizable  yes
macos_thicken_font      0
macos_traditional_fullscreen no
macos_show_window_title_in all
macos_custom_beam_cursor no
linux_display_server    auto

#: === Wayland Specific ===
wayland_titlebar_color  background
``````


