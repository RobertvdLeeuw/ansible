#!/bin/bash
# Workspace left/right navigation script

CURRENT_WS=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')
CURRENT_NUM=$(echo "$CURRENT_WS" | grep -o '[0-9]*$')
PREFIX=$(echo "$CURRENT_WS" | sed 's/[0-9]*$//')

if [ "$1" = "l" ]; then
    # Move left
    NEW_NUM=$((CURRENT_NUM - 1))
    if [ $NEW_NUM -lt 1 ]; then
        NEW_NUM=4
    fi
else
    # Move right
    NEW_NUM=$((CURRENT_NUM + 1))
    if [ $NEW_NUM -gt 4 ]; then
        NEW_NUM=1
    fi
fi

echo "${PREFIX}${NEW_NUM}"

