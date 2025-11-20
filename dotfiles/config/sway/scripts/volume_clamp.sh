#!/bin/bash
# Volume control script that clamps at 100%

CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1)

if [ "$CURRENT_VOL" -lt 100 ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +1%
fi

