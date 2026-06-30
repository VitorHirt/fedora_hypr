#!/bin/bash
# toggle_glava.sh — Toggle Glava visualizer on/off

# Check if Glava is running
if pgrep -x "glava" > /dev/null; then
    echo "Glava is running — killing it..."
    pkill glava
else
    echo "Glava not running — starting it..."
    glava --desktop &
fi

