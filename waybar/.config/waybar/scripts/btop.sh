#!/usr/bin/env bash


TITLE="btop-waybar"

# Find the window with the matching title
client_id=$(hyprctl clients -j | jq -r ".[] | select(.title == \"$TITLE\") | .address")

if [[ -n "$client_id" ]]; then
    # Focus the window using its address
    hyprctl dispatch focuswindow address:$client_id
else
    # Launch a new terminal with the desired title
    kitty --title "$TITLE" -e btop &
fi
