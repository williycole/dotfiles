#!/bin/bash
LAPTOP="eDP-1"
EXTERNAL="HDMI-A-1"

# === INITIAL STATE ===
if hyprctl monitors | grep -q "$EXTERNAL"; then
    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
    hyprctl keyword monitor "$LAPTOP,disable"
    notify-send "Display" "External ON → Laptop OFF" 2>/dev/null || true
else
    hyprctl keyword monitor "$LAPTOP,1920x1080@60,auto,1.5"
fi

# === LISTEN FOR EVENTS ===
socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    if [[ "$line" == *"monitoradded>>$EXTERNAL"* ]]; then
        hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
        hyprctl keyword monitor "$LAPTOP,disable"
        notify-send "Display" "External connected → Laptop OFF" 2>/dev/null || true
    elif [[ "$line" == *"monitorremoved>>$EXTERNAL"* ]]; then
        hyprctl keyword monitor "$LAPTOP,1920x1080@60,auto,1.5"
        notify-send "Display" "External disconnected → Laptop ON" 2>/dev/null || true
    fi
done
