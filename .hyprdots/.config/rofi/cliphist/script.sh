#!/usr/bin/env bash

# Ensure cliphist is available
if ! command -v cliphist &> /dev/null; then
    echo "cliphist not found. Please install it first."
    exit 1
fi

# Cache directory for images
CACHE_DIR="$HOME/.cache/rofi-cliphist"
mkdir -p "$CACHE_DIR"

# Function to handle different actions
handle_selection() {
    local selection="$1"
    local id="${selection%% *}"

    case "$ROFI_RETV" in
        # Enter key
        0)
            # Copy to clipboard
            cliphist decode "$id" | wl-copy
            ;;
        # Custom key 1 (Alt+1) - Delete entry
        1)
            cliphist delete "$id"
            ;;
        # Custom key 2 (Alt+2) - Pin entry
        2)
            cliphist pin "$id"
            ;;
        # Custom key 3 (Alt+3) - Unpin entry
        3)
            cliphist unpin "$id"
            ;;
        # Custom key 4 (Alt+4) - Edit entry
        4)
            edit_entry "$id"
            ;;
    esac
}

# Function to edit an entry
edit_entry() {
    local id="$1"
    local temp_file=$(mktemp)

    cliphist decode "$id" > "$temp_file"
    ${EDITOR:-nano} "$temp_file"

    if [ -s "$temp_file" ]; then
        local new_content=$(cat "$temp_file")
        echo "$new_content" | cliphist encode
        cliphist delete "$id"
    fi

    rm -f "$temp_file"
}

# Function to generate preview for images
generate_image_preview() {
    local id="$1"
    local preview_file="$CACHE_DIR/${id}.png"

    if [ ! -f "$preview_file" ]; then
        cliphist decode "$id" | convert - -resize 200x200 "$preview_file"
    fi

    echo -en "\0img\x1f$preview_file\n"
}

# Main function to generate the list
generate_list() {
    # Get pinned items first
    cliphist list-pinned | while read -r line; do
        local id=$(echo "$line" | cut -d$'\t' -f1)
        local content=$(echo "$line" | cut -d$'\t' -f2- | head -c 100)

        # Check if it's an image
        if echo "$content" | grep -q "^::IMAGE::"; then
            generate_image_preview "$id"
            echo -en "📌 󰉏 Image [Pinned] \0\n"
        else
            echo -en "📌 ${content//$'\n'/ } \0\n"
        fi
    done

    # Get regular items
    cliphist list | while read -r line; do
        local id=$(echo "$line" | cut -d$'\t' -f1)
        local content=$(echo "$line" | cut -d$'\t' -f2- | head -c 100)

        # Check if it's an image
        if echo "$content" | grep -q "^::IMAGE::"; then
            generate_image_preview "$id"
            echo -en "󰉏 Image \0\n"
        else
            echo -en "${content//$'\n'/ } \0\n"
        fi
    done
}

# Handle initial call or selection
if [ -z "$ROFI_INFO" ]; then
    generate_list
else
    handle_selection "$ROFI_INFO"
fi
