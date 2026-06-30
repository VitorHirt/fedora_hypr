#!/bin/bash

# Kill only running conky processes
pkill -x conky

# Wait a moment to ensure conky is stopped
sleep 1

# Start new conky theme
conky -c "$HOME/.config/conky/linuxfamconky22/linuxfam.conf" &
conky -c "$HOME/.config/conky/bars22/bars.conf" &
conky -c "$HOME/.config/conky/clockk/clock.conf" &
conky -c "$HOME/.config/conky/weather22/weather.conf" &

