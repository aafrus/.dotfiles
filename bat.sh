#!/bin/bash
LOCKFILE="/tmp/battery-notify.lock"

if [ -e "$LOCKFILE" ]; then
    exit 0
fi

touch "$LOCKFILE"

trap "rm -f $LOCKFILE" EXIT

while true; do
    for bat in /sys/class/power_supply/BAT?; do
        if [ -d "$bat" ]; then
            capacity=$(cat "$bat/capacity")
            status=$(cat "$bat/status")

            # Baterai lemah
            if [[ "$status" == "Discharging" && "$capacity" == 20 ]]; then
                notify-send "🪫 Battery Low" "Battery is at ${capacity}%. Please charge now." --urgency=critical
		aplay "$SOUND_LOW" &
                sleep 180

            # Baterai kritis
            elif [[ "$status" == "Discharging" && "$capacity" == 5 ]]; then
                notify-send "🪫 Battery Critical" "Battery is at ${capacity}%. It will die soon!" --urgency=critical
		aplay "$SOUND_LOW" &
                sleep 240

            # Baterai hampir penuh
            elif [[ "$status" == "Charging" && "$capacity" == 95 ]]; then
                notify-send "🔋 Battery Almost Full" "Battery is at ${capacity}%. You can unplug the charger." --urgency=normal
		aplay "$SOUND_FULL" &
                sleep 300
	    fi
        fi
    done
done
