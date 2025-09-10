#!/bin/bash

# Wallpaper directory
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
THUMB_DIR="$HOME/.cache/wall-thumbs"

# Create thumbnail cache dir
mkdir -p "$THUMB_DIR"

# Check if wallpapers exist
if [ ! -d "$WALLPAPER_DIR" ]; then
    rofi -e "Directory $WALLPAPER_DIR not found."
    exit 1
fi

cd "$WALLPAPER_DIR" || exit 1
files=(*)

if [ ${#files[@]} -eq 0 ]; then
    rofi -e "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Generate thumbnails (200x200, cropped square)
for f in "${files[@]}"; do
    if [[ -f "$f" ]]; then
        thumb="$THUMB_DIR/$(basename "$f")"
        if [ ! -f "$thumb" ]; then
            magick "$f" -resize 200x200^ -gravity center -extent 200x200 "$thumb"
        fi
    fi
done

# Build rofi entries with thumbnails
entries=""
for f in "${files[@]}"; do
    if [[ -f "$f" ]]; then
        entries+="$f\0icon\x1f$THUMB_DIR/$(basename "$f")\n"
    fi
done

# Show rofi menu with image previews
selected_wallpaper=$(echo -en "$entries" | rofi -dmenu -show-icons -p "Select Wallpaper")

# Apply wallpaper if chosen
if [ -n "$selected_wallpaper" ]; then
    swww img "$WALLPAPER_DIR/$selected_wallpaper"
fi
