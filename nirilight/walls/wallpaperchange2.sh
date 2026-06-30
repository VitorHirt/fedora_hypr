#!/usr/bin/env bash

# Folder where this script is located
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# File to store the last wallpaper used
LAST_SWAYBG_WALLPAPER="$SCRIPT_DIR/.last_swaybg_wallpaper"

# Enable nullglob so that non-matching patterns are ignored
shopt -s nullglob

# Get all jpg and png files in the folder
WALLPAPERS=("$SCRIPT_DIR"/*.jpg "$SCRIPT_DIR"/*.png)

# Check if we have any wallpapers
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "No jpg or png wallpapers found in $SCRIPT_DIR"
    exit 1
fi

# Get last wallpaper
if [ -f "$LAST_SWAYBG_WALLPAPER" ]; then
    LAST=$(cat "$LAST_SWAYBG_WALLPAPER")
else
    LAST=""
fi

# Pick a random wallpaper that is not the last one
while true; do
    RANDOM_WALLPAPER="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"
    if [ "$RANDOM_WALLPAPER" != "$LAST" ]; then
        break
    fi
done

# Apply the wallpaper
swaybg -i "$RANDOM_WALLPAPER" -m fill &

# Save this wallpaper as last used
echo "$RANDOM_WALLPAPER" > "$LAST_SWAYBG_WALLPAPER"


