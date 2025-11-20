#!/bin/bash
# Workspace selection script
# Maps workspace numbers to monitor-specific workspaces

FOCUSED_OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')

case "$FOCUSED_OUTPUT" in
    "HDMI-A-1")  # Ultrawide
        echo "$1"
        ;;
    "DP-1")  # Top
        echo "1$1"
        ;;
    "DP-3")  # Vertical
        echo "2$1"
        ;;
    *)
        echo "$1"
        ;;
esac

