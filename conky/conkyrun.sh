#!/usr/bin/env bash
    pkill rofi
if pgrep -f "conky -c /home/linuxfam/.config/conky/bars22/bars.conf" >/dev/null; then
    pkill conky
else
    conky -c "$HOME/.config/conky/bars22/bars.conf" &

fi

