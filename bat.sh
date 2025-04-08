#!/bin/bash
BAT_PATH="/sys/class/power_supply/BAT0"

capacity=$(cat "$BAT_PATH/capacity")
status=$(cat "$BAT_PATH/status")

# export krävs för notify-send via cron
export DISPLAY=:0
export XAUTHORITY=/home/$USER/.Xauthority
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Sätt ljudvägar (om du vill)
SOUND_LOW="$HOME/.config/sounds/low_battery.wav"
SOUND_FULL="$HOME/.config/sounds/full_battery.wav"

# Undvik att spamma – lagra senaste status
LAST_STATUS_FILE="/tmp/battery-status.txt"
CURRENT="$status $capacity"

if [[ "$status" == "Discharging" && "$capacity" -le 10 ]]; then
    notify-send -u critical "🪫 Battery Low ($capacity%)" "Plug in the charger!"
    [[ -f "$SOUND_LOW" ]] && aplay "$SOUND_LOW" &
elif [[ "$status" == "Charging" && "$capacity" -ge 95 ]]; then
    notify-send -u normal "🔋 Battery Almost Full ($capacity%)" "You can unplug now."
    [[ -f "$SOUND_FULL" ]] && aplay "$SOUND_FULL" &
elif [[ "$LAST_STATUS" != "$CURRENT" && "$status" == "Charging" ]]; then
    notify-send -u low "⚡ Charger Connected" "Battery is charging ($capacity%)."
elif [[ "$LAST_STATUS" != "$CURRENT" && "$status" == "Discharging" ]]; then
    notify-send -u low "🔌 Charger Disconnected" "Running on battery ($capacity%)."
fi

echo "$CURRENT" > "$LAST_STATUS_FILE"
