#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

if [ -d "$WALLPAPER_DIR" ]; then
    cd "$WALLPAPER_DIR"
    files=(*)
    
    if [ ${#files[@]} -gt 0 ]; then
        selected_wallpaper=$(printf "%s\n" "${files[@]}" | rofi -dmenu -p "Select Wallpaper")
        
        if [ -n "$selected_wallpaper" ]; then
            swww img "$selected_wallpaper"
        fi
    else
        rofi -e "No wallpapers found in $WALLPAPER_DIR"
    fi
else
    rofi -e "Directory $WALLPAPER_DIR not found."
fi
