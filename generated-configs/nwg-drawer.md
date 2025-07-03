# NWG-Drawer Configuration for macOS-like Application Menu

Here's a configuration for `nwg-drawer` (a popular application launcher for Wayland/Sway environments) that mimics the macOS application menu style:

## Configuration File (~/.config/nwg-drawer/config)

```ini
[general]
# General settings
hide_on_startup = false
hide_on_focus_lost = true
layer = overlay
width = 800
height = 600
padding = 20
margin = 50
anchor = center
categories_icon_size = 32
app_icon_size = 48
show_category_name = true
category_margin = 20
category_padding = 10
category_width = 180
category_height = 50
category_style = macos
app_style = macos

[search]
# Search bar settings
enable = true
placeholder_text = Search Applications...
width = 600
height = 40
position = top
style = macos

[colors]
# Color scheme similar to macOS
background = rgba(242, 242, 242, 0.95)
category_background = rgba(242, 242, 242, 0.8)
category_hover_background = rgba(200, 200, 200, 0.6)
category_text = #000000
category_hover_text = #000000
app_background = rgba(242, 242, 242, 0.0)
app_hover_background = rgba(200, 200, 200, 0.6)
app_text = #000000
app_hover_text = #000000
search_background = rgba(255, 255, 255, 0.9)
search_text = #000000
search_border = rgba(200, 200, 200, 0.8)

[shortcuts]
# Keyboard shortcuts
toggle = <Super>space
close = Escape
search = <Ctrl>f
```

## Additional Styling (~/.config/nwg-drawer/style.css)

For more macOS-like appearance, create this CSS file:

```css
/* macOS-like rounded corners */
window {
    border-radius: 12px;
    box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.15);
}

/* Search bar styling */
entry {
    border-radius: 18px;
    border: 1px solid #d1d1d1;
    padding: 8px 16px;
    font-size: 14px;
}

/* Category styling */
.category {
    border-radius: 8px;
    transition: all 0.2s ease;
}

/* Application item styling */
.app {
    border-radius: 8px;
    transition: all 0.2s ease;
}

.app:hover {
    background-color: rgba(0, 122, 255, 0.1);
}

/* Selected item highlight */
.app:selected {
    background-color: rgba(0, 122, 255, 0.2);
}
```

## Key Features of This Configuration:

1. **Light, translucent background** similar to macOS menu
2. **Rounded corners** on all elements
3. **Smooth hover effects** with subtle animations
4. **Search bar at the top** like Spotlight
5. **Sidebar categories** resembling macOS organization
6. **Keyboard shortcuts** similar to macOS (Super+Space to open)
7. **Consistent spacing and padding** for a clean look

## Installation Notes:

1. Make sure you have `nwg-drawer` installed
2. Create the config directory if it doesn't exist: `mkdir -p ~/.config/nwg-drawer`
3. Save the configuration to `~/.config/nwg-drawer/config`
4. Save the CSS to `~/.config/nwg-drawer/style.css`
5. Restart `nwg-drawer` or your Wayland compositor to apply changes

You can adjust the colors, sizes, and positions to better match your preferences or macOS version.
