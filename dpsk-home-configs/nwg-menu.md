# NWG-Menu Configuration for Windows 11 Style

To configure `nwg-menu` to resemble the Windows 11 Start Menu, you'll need to modify the configuration file. Here's a sample configuration that approximates the Windows 11 look:

## Configuration Steps

1. First, locate or create your `nwg-menu` configuration file. It's typically found at:
   ```
   ~/.config/nwg-menu/config
   ```

2. Use the following configuration:

```ini
[general]
menu_margin_x = 20
menu_margin_y = 20
menu_width = 600
menu_height = 650
columns = 6
padding = 10
item_height = 80
icon_size = 32
terminal = alacritty
file_manager = thunar
display_name = true
display_icon = true
display_comment = false
category_icon_size = 16
category_icon = true
category_margin = 10
hover_color = #0078d7
background_color = #202020
category_color = #2a2a2a
name_color = #ffffff
comment_color = #aaaaaa
round_corners = 10
border_width = 1
border_color = #3a3a3a
hide_on_focus_lost = true
css_filename = ~/.config/nwg-menu/style.css

[categories]
1 = Accessories
2 = Development
3 = Education
4 = Games
5 = Graphics
6 = Internet
7 = Multimedia
8 = Office
9 = Science
10 = Settings
11 = System
```

3. Create a CSS file for additional styling at `~/.config/nwg-menu/style.css`:

```css
window {
    background-color: rgba(32, 32, 32, 0.95);
    border-radius: 15px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
}

#search {
    background-color: #2a2a2a;
    color: white;
    border-radius: 10px;
    margin: 10px;
    padding: 10px;
    font-size: 14px;
}

#categories {
    background-color: #2a2a2a;
    border-radius: 10px;
    margin: 10px;
    padding: 5px;
}

#items {
    background-color: #2a2a2a;
    border-radius: 10px;
    margin: 10px;
    padding: 5px;
}

#items flowboxchild {
    border-radius: 5px;
    padding: 5px;
}

#items flowboxchild:hover {
    background-color: #0078d7;
}
```

## Additional Tips

1. For the Windows 11 search bar effect, you might need to use `nwg-bar` alongside `nwg-menu`.

2. To get the rounded corners and acrylic/transparency effect, ensure you have:
   - A compositor like `sway` (for Wayland) or `picom` (for X11) running
   - Proper transparency settings in your compositor

3. For Windows-like icons, consider using:
   - `Windows-10-Icons` or similar icon themes
   - Set your icon theme in your GTK settings

4. You may need to adjust the `menu_width` and `menu_height` values based on your screen resolution.

5. For a more authentic Windows 11 look, you might want to position the menu at the center-bottom of your screen, which can be configured in your launcher settings (if you're using something like `nwg-launchers`).

Remember that `nwg-menu` is a GTK-based application, so it won't be an exact replica of the Windows 11 menu, but this configuration should give you a similar visual style and layout.
