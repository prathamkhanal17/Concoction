#!/bin/bash

# Path to your wallpaper image
WALLPAPER="$HOME/Pictures/wallpapers/nep.png"

# Check if swww is running, start it if not
if ! pgrep -x "swww-daemon" >/dev/null; then
  echo "Starting swww daemon..."
  swww-daemon &
  sleep 1 # Give it a second to initialize
fi

# Set the wallpaper with a fade transition
swww img "$WALLPAPER" --transition-type any --transition-fps 60 --transition-duration 1

echo "Wallpaper set to: $WALLPAPER"
