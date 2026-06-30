#!/bin/bash

BLUR="/tmp/rofi_blur.png"

# Take screenshot of current screen state
grim "$BLUR" &

wait

# Blur (fast Gaussian)
magick "$BLUR" -blur 0x18 "$BLUR"

# Launch Rofi immediately (no need for swaybg)
rofi -show drun -theme ~/.config/rofi/launcher.rasi

# Cleanup
rm -f "$BLUR"

