#!/bin/bash

BAT_PATH="/sys/class/power_supply/BAT0"
LAST_STATUS_FILE="/tmp/last_battery_status"

export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

capacity=$(cat "$BAT_PATH/capacity")
status=$(cat "$BAT_PATH/status")
current_state="$status $capacity"

last_state=$(cat "$LAST_STATUS_FILE" 2>/dev/null || echo "")
[[ "$last_state" == "$current_state" ]] && exit 0

case "$status" in
    "Discharging")
        if [[ "$capacity" -le 10 ]]; then
            notify-send -u critical "Low Battery ($capacity%)"
        elif [[ "$last_state" =~ "Charging" ]]; then
            notify-send -u low "Unplugged ($capacity%)"
        fi
        ;;
    "Charging")
        if [[ "$capacity" -ge 99 ]]; then
            notify-send -u normal "Battery Full (100%)"
        elif [[ "$last_state" =~ "Discharging" ]]; then
            notify-send -u low "Plugged In ($capacity%)"
        fi
        ;;
esac

echo "$current_state" > "$LAST_STATUS_FILE"
