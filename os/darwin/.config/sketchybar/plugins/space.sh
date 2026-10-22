#!/bin/sh

# NAME is e.g. "space.1", FOCUSED_WORKSPACE is e.g. "1"
SPACE_NUM="${NAME#space.}"

if [ "$FOCUSED_WORKSPACE" = "$SPACE_NUM" ]; then
  sketchybar --set "$NAME" background.drawing=on
else
  sketchybar --set "$NAME" background.drawing=off
fi
