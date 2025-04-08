#!/bin/bash

# Batteridata
BAT_PATH="/sys/class/power_supply/BAT0"
CAPACITY=$(cat "$BAT_PATH/capacity")
STATUS=$(cat "$BAT_PATH/status")

# Emoji + färger för notify-send (via dunst)
ICON_LOW="🔋"
ICON_CHARGING="⚡"
ICON_FULL="✅"
ICON_WARNING="☠️"

# DBUS magic (krävs i cron/systemd timers ibland)
export DISPLAY=:0
export XAUTHORITY=/home/$USER/.Xauthority
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Notifieringslogik
if [[ "$STATUS" == "Discharging" && "$CAPACITY" -le 20 ]]; then
    notify-send -u critical "$ICON_LOW  Battery Low ($CAPACITY%)" "Plug in now or face the consequences $ICON_WARNING"
elif [[ "$STATUS" == "Charging" && "$CAPACITY" -ge 95 ]]; then
    notify-send -u normal "$ICON_FULL  Battery Full ($CAPACITY%)" "You can unplug now $ICON_CHARGING"
fi
