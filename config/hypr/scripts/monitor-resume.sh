#!/bin/bash
# Fix Intel i915 grey screen after DPMS resume on DP-4 (AOC)
hyprctl dispatch dpms on
sleep 1
hyprctl keyword monitor "DP-4,disable"
sleep 2
hyprctl keyword monitor "DP-4,1920x1080@60,0x0,1"
sleep 2
pkill -x swaybg
sleep 1
setsid uwsm-app -- swaybg \
    -o HDMI-A-1 -i "$HOME/.config/omarchy/current/background" -m fill \
    -o DP-4    -i "$HOME/.config/omarchy/current/background" -m fill \
    >/dev/null 2>&1 &
