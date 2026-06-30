#!/usr/bin/env bash

# File to store last Bluetooth state
STATE_FILE="/tmp/.bt_last_state"

# Notification ID (same for all notifications to replace previous)
NOTIFY_ID=9999

# Function to get Bluetooth state (checks only SOFT block column)
get_bt_state() {
    state=$(rfkill | awk '/bluetooth/ {print $4}')
    [[ "$state" == "unblocked" ]] && echo "on" || echo "off"
}

# Initialize state file if missing
if [[ ! -f "$STATE_FILE" ]]; then
    get_bt_state > "$STATE_FILE"
fi

# Main loop: watch for state changes
while true; do
    new_state=$(get_bt_state)
    old_state=$(cat "$STATE_FILE")

    # Only notify if state changed
    if [[ "$new_state" != "$old_state" ]]; then
        if [[ "$new_state" == "on" ]]; then
            notify-send -r $NOTIFY_ID -t 3000 "Bluetooth" "Bluetooth Turned ON"
        else
            notify-send -r $NOTIFY_ID -t 3000 "Bluetooth" "Bluetooth Turned OFF"
        fi
        echo "$new_state" > "$STATE_FILE"
    fi

    # Check every 2 seconds (adjust if desired)
    sleep 2
done

