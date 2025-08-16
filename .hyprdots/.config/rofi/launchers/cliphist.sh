#!/usr/bin/env bash

# Clear cache older than 1 day
find ~/.cache/rofi-cliphist -type f -mtime +1 -delete

# Launch Rofi with our configuration
rofi -no-lazy-grab \
    -show cliphist \
    -modi cliphist \
    -theme ~/.config/rofi/cliphist/config.rasi
